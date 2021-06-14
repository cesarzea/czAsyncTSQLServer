CREATE PROCEDURE st_useCase_3 AS
BEGIN

    -- TRUNCATE TABLE samples.samples_results
    -- TRUNCATE TABLE JsAsyncExecResults

    DECLARE @group_id UNIQUEIDENTIFIER;

    ------- A -> A.1, A.2
    EXEC st_czAsyncExecInvoke
         @sentence =  'exec st_useCase_3_next_steps @value=''D.A'', @asyncGroupCallerId=''##asyncGroupCallerId##''',
         @group_id = @group_id OUTPUT,
         @execGroup = 0

    ------ B -> B.1, B.2
    EXEC st_czAsyncExecInvoke
         @sentence = 'exec st_useCase_3_next_steps @value=''D.B'', @asyncGroupCallerId=''##asyncGroupCallerId##''',
         @group_id = @group_id OUTPUT,
         @execGroup = 0

    ------ C
    EXEC st_czAsyncExecInvoke
         @sentence =  'insert into samples_results (example_name, value) values (''Example D'',  ''D.C'')',
         @group_id = @group_id OUTPUT,
         @execGroup = 0

    ----- END
    EXEC st_czAsyncExecInvoke
         @next_sentence ='insert into samples_results (example_name, value) values ('Example D',  '----> END D')' ,
         @group_id = @group_id OUTPUT,
         @execGroup = 1

END