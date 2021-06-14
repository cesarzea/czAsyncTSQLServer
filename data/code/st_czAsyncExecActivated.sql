CREATE PROCEDURE [dbo].[st_czAsyncExecActivated]
AS
BEGIN

    SET NOCOUNT ON;
    DECLARE @h UNIQUEIDENTIFIER
        , @messageTypeName SYSNAME
        , @messageBody VARBINARY(MAX)
        , @xmlBody XML
        , @sentence NVARCHAR(MAX)
        , @startTime DATETIME2
        , @finishTime DATETIME2
        , @execErrorNumber INT
        , @execErrorMessage NVARCHAR(MAX)
        , @execErrorProcedureLine INT
        , @execErrorProcedure NVARCHAR(MAX)
        , @xactState SMALLINT
        , @queued_id UNIQUEIDENTIFIER
        , @extra_info NVARCHAR(MAX)
        , @next_sentence NVARCHAR(MAX)
        , @group_id UNIQUEIDENTIFIER

    BEGIN TRY

        RECEIVE TOP (1)
            @h = [conversation_handle]
            , @messageTypeName = [message_type_name]
            , @messageBody = [message_body]
            FROM [czAsyncExecQueue];


        IF (@h IS NOT NULL)
            BEGIN
                IF (@messageTypeName = N'DEFAULT')
                    BEGIN

                        SELECT @queued_id = [conversation_id]
                            FROM sys.conversation_endpoints
                            WHERE [conversation_handle] = @h;

                        SELECT @xmlBody = CAST(@messageBody AS XML);
                        SELECT @sentence = @xmlBody.value(
                                '(//procedure/name)[1]', 'nvarchar(max)');

                        SELECT @startTime = SYSUTCDATETIME();

                        UPDATE [czAsyncExecResults]
                        SET [start_time] = @starttime
                            WHERE queued_id = @queued_id;

                        SELECT @group_id = group_id,
                               @extra_info = extra_info
                            FROM czAsyncExecResults
                            WHERE queued_id = @queued_id;

                        IF (@sentence IS NOT NULL AND TRIM(@sentence) <> '')
                            BEGIN
                                SET @sentence = REPLACE(@sentence, '##asyncCallerTask##', @queued_id)
                                SET @sentence = REPLACE(@sentence, '##asyncGroupCallerId##', @group_id)
                                SET @sentence = REPLACE(@sentence, '##asyncExtraInfo##', COALESCE(@extra_info, ''))

                                BEGIN TRY
                                    EXEC (@sentence);
                                END TRY
                                BEGIN CATCH

                                    SELECT @execErrorNumber = ERROR_NUMBER(),
                                           @execErrorMessage = ERROR_MESSAGE(),
                                           @xactState = XACT_STATE(),
                                           @execErrorProcedureLine = ERROR_LINE(),
                                           @execErrorProcedure = ERROR_PROCEDURE();

                                    IF (@xactState = -1)
                                        BEGIN
                                            RAISERROR (N'sp_JsAsyncExecActivated: Unrecoverable error in procedure %s: %i: %s', 16, 10,
                                                @sentence, @execErrorNumber, @execErrorMessage);
                                        END
                                    ELSE
                                        IF (@xactState = 1)
                                            BEGIN
                                                PRINT 'Error sp_JsAsyncExecActivated = 1'
                                            END
                                END CATCH

                            END

                        SELECT @finishTime = SYSUTCDATETIME();

                        IF (@queued_id IS NULL)
                            BEGIN
                                RAISERROR (N'sp_JsAsyncExecActivated: Internal consistency error: conversation not found', 16, 20);
                            END

                        UPDATE czAsyncExecResults
                        SET [finish_time]   = @finishTime,
                            [error_number]  = @execErrorNumber,
                            [error_message] = CASE
                                                  WHEN @execErrorNumber IS NULL THEN NULL
                                                  ELSE COALESCE(@execErrorMessage, '') + ' at line ' + COALESCE(CAST(@execErrorProcedureLine AS VARCHAR(10)), '') END
                            WHERE queued_id = @queued_id;

                        IF (0 = @@ROWCOUNT)
                            BEGIN
                                RAISERROR (N'sp_JsAsyncExecActivated: Internal consistency error: token not found', 16, 30);
                            END


                        END CONVERSATION @h;

                        -- =====================================================================================
                        -- NEXT STEPS

                        -- Check if all task in the same group was ended.

                        DECLARE  @task_to_next UNIQUEIDENTIFIER,
							 @next_group_id UNIQUEIDENTIFIER

                        -- Check if all was ended

                        IF (NOT EXISTS(SELECT TOP 1 task_id
                                           FROM czAsyncExecResults
                                           WHERE group_id = @group_id
                                             AND finish_time IS NULL))
                            BEGIN

                                SELECT TOP 1 @task_to_next = task_id,
                                             @extra_info = extra_info,
                                             @next_sentence = next_sentence,
                                             @group_id = group_id
                                    FROM czAsyncExecResults
                                    WHERE group_id = @group_id
                                      AND next_sentence IS NOT NULL
                                      AND next_task_id IS NULL;

                                WHILE (@task_to_next IS NOT NULL)
                                    BEGIN

                                        SET @next_sentence = REPLACE(@next_sentence, '##asyncCallerTask##', @queued_id)
                                        SET @next_sentence = REPLACE(@next_sentence, '##asyncGroupCallerId##', @group_id)
                                        SET @next_sentence = REPLACE(@next_sentence, '##asyncCallerErrorNumber##', COALESCE(@execErrorNumber, 0))
                                        SET @next_sentence = REPLACE(@next_sentence, '##asyncExtraInfo##', COALESCE(@extra_info, ''))

                                        DECLARE
                                            @next_task_id UNIQUEIDENTIFIER

										set @next_task_id = NULL

                                        EXEC st_czAsyncExecInvoke
                                             @sentence = @next_sentence,
                                             @extra_info = @extra_info,
                                             @group_id = @next_group_id OUTPUT,
                                             @task_id = @next_task_id OUTPUT

                                        UPDATE czAsyncExecResults
                                        SET next_task_id  = @next_task_id,
                                            next_group_id = @next_group_id
                                            WHERE task_id = @task_to_next;

                                        SET @task_to_next = NULL;

                                        SELECT TOP 1 @task_to_next = task_id,
                                                     @extra_info = extra_info,
                                                     @next_sentence = next_sentence,
                                                     @group_id = group_id
                                            FROM czAsyncExecResults
                                            WHERE group_id = @group_id
                                              AND next_sentence IS NOT NULL
                                              AND next_task_id IS NULL;
                                    END
                            END
                    END
                ELSE
                    IF (@messageTypeName = N'http://schemas.microsoft.com/SQL/ServiceBroker/EndDialog')
                        BEGIN
                             END CONVERSATION @h
                        END
                    ELSE
                        IF (@messageTypeName = N'http://schemas.microsoft.com/SQL/ServiceBroker/Error')
                            BEGIN

                                DECLARE @errorNumber INT
                                    , @errorMessage NVARCHAR(MAX);
                                SELECT @xmlBody = CAST(@messageBody AS XML);
                                WITH XMLNAMESPACES (DEFAULT N'http://schemas.microsoft.com/SQL/ServiceBroker/Error')
                                SELECT @errorNumber = @xmlBody.value('(/Error/Code)[1]', 'INT'), @errorMessage = @xmlBody.value('(/Error/Description)[1]', 'NVARCHAR(MAX)');

                                -- Update the request with the received error
                                SELECT @queued_id = [conversation_id] FROM sys.conversation_endpoints WHERE [conversation_handle] = @h;
                                UPDATE [czAsyncExecResults]
                                SET [error_number]  = @errorNumber,
                                    [error_message] = @errorMessage
                                    WHERE task_id = @queued_id;

                                END CONVERSATION @h;

                            END
                        ELSE
                            BEGIN
                                RAISERROR (N'sp_JsAsyncExecActivated: Received unexpected message type: %s', 16, 50, @messageTypeName);
                            END
            END

    END TRY
    BEGIN CATCH

        DECLARE @error INT
            , @message NVARCHAR(2048);
        SELECT @error = ERROR_NUMBER(), @message = ERROR_MESSAGE(), @xactState = XACT_STATE();


        RAISERROR (N'sp_JsAsyncExecActivated: Error: %i, %s', 1, 60, @error, @message) WITH LOG;

    END CATCH
END
go

