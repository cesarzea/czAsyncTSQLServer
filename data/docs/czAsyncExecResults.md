<div markdown class="margin900">

# The czAsyncExecResults table

The czAsyncExecResults table is used to store the definition of the tasks executed and deefined to be executed, ids, results, errors, etc.

Understanding the meaning of each column is not needed to use the solution, but will give you more abilities to use that solution in the most advanced way. 

That table is defines as follow: 

```sql
CREATE TABLE czAsyncExecResults (
    submit_time   DATETIME2
        CONSTRAINT DF_JsAsyncExecResults_submit_time DEFAULT SYSUTCDATETIME() NOT NULL,
    task_id       UNIQUEIDENTIFIER                                            NOT NULL,
    group_id      UNIQUEIDENTIFIER,
    queued_time   DATETIME2,
    queued_id     UNIQUEIDENTIFIER,
    sentence      NVARCHAR(MAX),
    extra_info    NVARCHAR(MAX),
    start_time    DATETIME2,
    finish_time   DATETIME2,
    error_number  INT,
    error_message NVARCHAR(MAX),
    result        NVARCHAR(MAX),
    next_sentence NVARCHAR(MAX),
    next_task_id  UNIQUEIDENTIFIER,
    next_group_id UNIQUEIDENTIFIER,
    CONSTRAINT PK__AsyncExe__CA90DA7B4BD51208
        PRIMARY KEY (submit_time, task_id)
)
GO

CREATE INDEX [NonClusteredIndex-20180306-130204]
    ON czAsyncExecResults (group_id)
GO

CREATE UNIQUE INDEX IX_JsAsyncExecResults
    ON czAsyncExecResults (task_id)
GO
```

:>[c=red] That table need to be purged from time to time. The solution only add rows, never delete them. 

:>[c=yellow] For the an intense use of that solution is convenient to create more indexes that the defined. 

Next is defined the meaning of each column value, but to undestand all of then you need to study the st_czAsyncExecInvoke procedure documentation.

# Columns 

## submit_time   DATETIME2

Contains the UTC system time in the server when the row was created. 

## task_id       UNIQUEIDENTIFIER                          

Is an unique Id for each row. 

## group_id      UNIQUEIDENTIFIER

Is the group identification to know which tasks are to be considered as a group.

## queued_time   DATETIME2

Is the UTC system time in the server when the task has been sended to the Service Broker queue.

## queued_id     UNIQUEIDENTIFIER

Is the queue_id in the Service Broker queue for that task.

## sentence      NVARCHAR(MAX)

The sentence to be executed. That string can contain an specific strings that will be replaced for information related to the task. Please, refer to the st_czAsyncExecInvoke procedure documentation for more detailed information.

## extra_info    NVARCHAR(MAX)

Is the extra info defined in the st_czAsyncExecInvoke procedure documentation.

## start_time    DATETIME2

It is the UTC time when the task started to run.

## finish_time   DATETIME2

It is the UTC time when the task finished executing.

## error_number  INT

The error number if an error was returned by the execution. Null if none.

## error_message NVARCHAR(MAX)

The error message returned by  the execution. Null if none.

## result        NVARCHAR(MAX)

That colunn is not updated or readed by the solution. Is an utility column to be used by the tasks if needed to pass information. 

## next_sentence NVARCHAR(MAX)

The next sentence to be executed when all sentences ends their executions in the group. Please, refer to the st_czAsyncExecInvoke procedure documentation for more detailed information.

## next_task_id  UNIQUEIDENTIFIER

When all sentences in the group ends their executions, the next_sentence is programmed to be executed asynchronouslly as a new task. That is the task_id of the next sentence. 

## next_group_id UNIQUEIDENTIFIER

When all sentences in the group ends their executions, the next_sentence is programmed to be executed asynchronouslly as a new task. That is the task_id of the next group.

</div>