CREATE PROCEDURE st_useCase_1 AS
BEGIN

    EXEC st_czAsyncExecInvoke
         @sentence = 'insert into samples_results (example_name, value) values (''Use case 1'',  ''Executed'')'

END