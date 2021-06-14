<div markdown class="margin900">

# The st_czAsyncExecInvoke procedure

It is the stored procedure for scheduling or launching asynchronous calls. That is the only procedure that you neeed to know how to use it to be able to use that solution, but also for the more advanced users is convenient to study the documentation related  to the table czAsyncExecResults.

The st_czAsyncExecInvoke procedure is defined as follows:

```sql
CREATE PROCEDURE [dbo].[st_czAsyncExecInvoke] @sentence NVARCHAR(MAX) = NULL,
                                              @next_sentence NVARCHAR(MAX) = NULL,
                                              @extra_info NVARCHAR(MAX) = NULL,
                                              @execGroup BIT = NULL,
                                              @group_id UNIQUEIDENTIFIER = NULL OUTPUT,
                                              @task_id UNIQUEIDENTIFIER = NULL OUTPUT
AS
   ... 
   
```

# Parameters and examples

## @sentence NVARCHAR(MAX) = NULL

It's the sentence to be executed asynchoronouslly. For example:

```sql
    EXEC st_czAsyncExecInvoke
         @sentence = 'insert into samples_results (example_name, value) values (''Use case 1'',  ''Executed'')'
```

This statement is defined as a string. The solution will attempt to replace the following sequences of specific characters to inject information about the asynchronous call into the sentence call.  You will be able to include one or more of these character sequences to receive these values:

***\##asyncCallerTask##*** : that will be replaced with the GUID that identify the asynchronous call, that is defined in the table czAsyncExecResults in the column queued_id.

You have to take in mind that the value that identify each task are: 

- task_id: created for each new created planned task.
- queued_id: created wheen the task is queued to be executed. 

***\##asyncGroupCallerId##*** : that will be replaced with the GUID that identify the group call. A calling group is a set of asynchronous instructions that will be treated as a unit, so that subsequent instructions defined in the group will not be executed until all asynchronous calls in the group have finished executing.

See the Use Case 2 to view how to use groups to execute simultaneus asynchronous sentences and other sentences when the all the firsts ones ended. 

Thus, by introducing the string of characters ##asyncGroupCallerId## in your statement, you will receive the group identifier, so that you can launch other new asynchronous statements from your asynchronous statements, including them in the same group to prevent subsequent calls from being executed before. your new asynchronous statements have finished.

The group id is defined by the st_czAsyncExecInvoke when the parameter @group_id is not specified or passed as null, and returned the same variable to give the possibility to add more sentences to the same group. When the parameter @group_id passed to the st_czAsyncExecInvoke is specified and not null, the sentence is added to the @group_id group. 

:>[c=yellow]Read the documentatio of the **@execGroup** parameter to understand how to add all your sentences to a group before start executing them.

That give the posibility to implement examples like that:

<center>
![Sencha](../data/docImages/use_case_2.png =850emx*)
</center>

Other example: 

<pre data-src='..\data\code\st_useCase_3.sql'></pre>

<pre data-src='..\data\code\st_useCase_3_next_steps.sql'></pre>

***\##asyncExtraInfo##*** : that string will be replaced by the value of the column extra_info in the table czAsyncExecResults and the row related to the sentence. That value could be defined passing the value to the parameter @extra_info in the same st_czAsyncExecInvoke call, or be updated directly in the row in any other way. 

## @next_sentence NVARCHAR(MAX) = NULL

The sentence to be executed asynchornouslly when the all sentences @sentence in the same group has finished. 

:>[c=blue]The strings ***\##asyncCallerTask##***, ***\##asyncGroupCallerId##*** and ***\##asyncExtraInfo##*** described in the @sentence documentation parameters are also replaced in the @next_sentence

But also the string ##asyncCallerErrorNumber## is replaced with the error number if an error is returned by the last execution in the group. That is only a valid error controlling when the group has only one element. For two or more elements, you have to use the ***\##asyncGroupCallerId##*** to query in the table czAsyncExecResults all the rows for that group and their error_number and error_message column values.

For example, for only one call in the group: 

```sql
EXEC st_czAsyncExecInvoke
         @sentence =  'exec st_proc_1',
         @next_sentence = 'exec st_proc_2'
```

For two or more calls in the group: 

```sql
DECLARE @group_id UNIQUEIDENTIFIER;

EXEC st_czAsyncExecInvoke
     @sentence =  'exec st_proc_1',
     @group_id = @group_id OUTPUT,
     @execGroup = 0

EXEC st_czAsyncExecInvoke
     @sentence =  'exec st_proc_2',
     @group_id = @group_id OUTPUT,
     @execGroup = 0

EXEC st_czAsyncExecInvoke
     @next_sentence =  'exec st_proc_final',
     @group_id = @group_id OUTPUT,
     @execGroup = 1
```

## @extra_info NVARCHAR(MAX) = NULL

That parameter allow you to directly specify the value to be replaced in the sentence, or the next sentence as descibed in @sentence parameter documentation section, ***\##asyncExtraInfo##*** info.

## @execGroup BIT = NULL

If that parameter is not specified, or specified as 1, all the sentences in the group will be started with that call.

Otherwise, with @execGroup = 0, the sentences in the group will no be started with that call.

For example: 

```sql
DECLARE @group_id UNIQUEIDENTIFIER;

EXEC st_czAsyncExecInvoke
     @sentence =  'exec st_proc_1',
     @group_id = @group_id OUTPUT,
     @execGroup = 0

EXEC st_czAsyncExecInvoke
     @sentence =  'exec st_proc_2',
     @group_id = @group_id OUTPUT,
     @execGroup = 0

EXEC st_czAsyncExecInvoke
     @next_sentence =  'exec st_proc_final',
     @group_id = @group_id OUTPUT,
     @execGroup = 1
```

## @group_id UNIQUEIDENTIFIER = NULL OUTPUT

That parameter allow to receive the new group_id created, or specify the group_id where the sentence, or next_sentence has to be assigned. 

For example:

```sql
DECLARE @group_id UNIQUEIDENTIFIER;

EXEC st_czAsyncExecInvoke
     @sentence =  'exec st_proc_1',
     @group_id = @group_id OUTPUT,
     @execGroup = 0

EXEC st_czAsyncExecInvoke
     @sentence =  'exec st_proc_2',
     @group_id = @group_id OUTPUT,
     @execGroup = 0

EXEC st_czAsyncExecInvoke
     @next_sentence =  'exec st_proc_final',
     @group_id = @group_id OUTPUT,
     @execGroup = 1
```

## @task_id UNIQUEIDENTIFIER = NULL OUTPUT

Retuns the new created task_id created in the czAsyncExecResults table for that call, knowing that:

</div>