CREATE PROCEDURE [dbo].[st_czAsyncExecInvoke] @sentence NVARCHAR(MAX) = NULL,
                                              @next_sentence NVARCHAR(MAX) = NULL,
                                              @extra_info NVARCHAR(MAX) = NULL,
                                              @execGroup BIT = NULL,
                                              @group_id UNIQUEIDENTIFIER = NULL OUTPUT,
                                              @task_id UNIQUEIDENTIFIER = NULL OUTPUT
AS
BEGIN
    ------------------------------------------------------------------------
    -- Author: Cesar Pedro Zea Gomez <cesarzea@jaunesistemas.com>
    -- https://www.cesarzea.com
    ------------------------------------------------------------------------
    DECLARE @h UNIQUEIDENTIFIER,
        @xmlBody XML,
        @queued_time DATETIME2,
        @submit_time DATETIME2 = SYSUTCDATETIME(),
        @queued_id UNIQUEIDENTIFIER;

    IF (@task_id IS NOT NULL)
        BEGIN

            SELECT @group_id = group_id,
                   @sentence = sentence
                FROM czAsyncExecResults
                WHERE task_id = @task_id

        END
    ELSE
        BEGIN

            IF (@group_id IS NULL)
                SET @group_id = NEWID()

        END

    BEGIN TRY

        IF (@sentence IS NOT NULL OR @next_sentence IS NOT NULL)
            BEGIN

                IF ((@execGroup IS NULL OR @execGroup = 1))
                    BEGIN
                        BEGIN DIALOG CONVERSATION @h
                            FROM SERVICE [czAsyncExecService]
                            TO SERVICE N'czAsyncExecService', 'current database'
                            WITH ENCRYPTION = OFF;

                        SELECT @queued_id = [conversation_id]
                            FROM sys.conversation_endpoints
                            WHERE [conversation_handle] = @h;

                        SET @queued_time = @submit_time;

                        SELECT @xmlBody =
                               (
                                   SELECT @sentence AS [name]
                                       FOR XML PATH ('procedure'), TYPE
                               );

                        SEND ON CONVERSATION @h(@xmlBody);
                    END

                --select * from sys.dm_broker_queue_monitors
                --select * from sys.service_queues
                --select is_broker_enabled, * from sys.databases
                --ALTER QUEUE [dbo].[AsyncExecQueue] WITH ACTIVATION (STATUS = OFF);
                --ALTER QUEUE [dbo].[AsyncExecQueue]  WITH ACTIVATION (STATUS = ON);

                IF (@task_id IS NULL)
                    BEGIN

                        SET @task_id = NEWID();

                        INSERT INTO [czAsyncExecResults] ([task_id],
                                                          group_id,
                                                          [sentence],
                                                          extra_info,
                                                          next_sentence,
                                                          queued_id,
                                                          queued_time)
                            VALUES (@task_id,
                                    @group_id,
                                    @sentence,
                                    @extra_info,
                                    @next_sentence,
                                    @queued_id,
                                    @queued_time);

                    END
                ELSE
                    BEGIN

                        UPDATE czAsyncExecResults
                        SET queued_id   = @queued_id,
                            queued_time = @queued_time
                            WHERE task_id = @task_id

                    END

            END

        -- if @execGroup = true -> check if exists non programed task in the group
        IF (@execGroup IS NULL OR @execGroup = 1)
            BEGIN

                DECLARE @task_to_program UNIQUEIDENTIFIER

                SELECT @task_to_program = task_id
                    FROM czAsyncExecResults
                    WHERE queued_id IS NULL
                      AND sentence IS NOT NULL
                      AND group_id = @group_id

                WHILE (@task_to_program IS NOT NULL)
                    BEGIN

                        EXEC st_czAsyncExecInvoke
                             @task_id = @task_to_program,
                             @group_id = @group_id

                        SET @task_to_program = NULL

                        SELECT @task_to_program = task_id
                            FROM czAsyncExecResults
                            WHERE queued_id IS NULL
                              AND sentence IS NOT NULL
                              AND group_id = @group_id

                    END
            END

    END TRY
    BEGIN CATCH

        DECLARE @error INT, @message NVARCHAR(2048), @xactState SMALLINT;

        SELECT @error = ERROR_NUMBER(),
               @message = ERROR_MESSAGE(),
               @xactState = XACT_STATE();

        RAISERROR (N'Error: %i, %s', 16, 1, @error, @message);

    END CATCH;
END;
go

