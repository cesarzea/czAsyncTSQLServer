CREATE PROCEDURE st_useCase_3_next_steps(@value NVARCHAR(100),
                                         @asyncCallerTask NVARCHAR(100) = NULL,
                                         @asyncGroupCallerId NVARCHAR(100)= NULL,
                                         @asyncCallerErrorNumber NVARCHAR(100)= NULL,
                                         @asyncExtraInfo NVARCHAR(100)= NULL
)
AS
BEGIN

    DECLARE @RandomDelay INT = ABS(CHECKSUM(NEWID()) % 3)
    WAITFOR DELAY @RandomDelay

    DECLARE @stmt NVARCHAR(MAX)
    SET @stmt = 'insert into samples_results (example_name, value) values (''Example D'', ''{v}'')'

    DECLARE @st NVARCHAR(MAX)

    SET @st = REPLACE(@stmt, '{v}', @value + '.1')
    EXEC dbo.st_czAsyncExecInvoke
         @sentence = @st,
         @group_id = @asyncGroupCallerId

    SET @st = REPLACE(@stmt, '{v}', @value + '.2')
    EXEC dbo.st_czAsyncExecInvoke
         @sentence = @st,
         @group_id = @asyncGroupCallerId

END