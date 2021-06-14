CREATE PROCEDURE st_useCase_2 AS
BEGIN

    DECLARE @group_id UNIQUEIDENTIFIER

    -- A
    EXEC st_czAsyncExecInvoke
         @sentence = 'declare @t int = 2; waitfor delay @t; insert into samples_results (example_name, value) values (''Use case 2'',  ''Executed A'')',
         @group_id = @group_id OUTPUT,
         @execGroup = 0

    -- B
    EXEC st_czAsyncExecInvoke
         @sentence = 'declare @t int = 2; waitfor delay @t; insert into samples_results (example_name, value) values (''Use case 2'',  ''Executed B'')',
         @group_id = @group_id OUTPUT,
         @execGroup = 0

    -- C
    EXEC st_czAsyncExecInvoke
         @sentence = 'declare @t int = 2; waitfor delay @t; insert into samples_results (example_name, value) values (''Use case 2'',  ''Executed C'')',
         @group_id = @group_id OUTPUT,
         @execGroup = 0

    -- When all finished => D
    EXEC st_czAsyncExecInvoke
         @next_sentence = 'insert into samples_results (example_name, value) values (''Use case 2'',  ''END'')',
         @group_id = @group_id OUTPUT,
         @execGroup = 1


END