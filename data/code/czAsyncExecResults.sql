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
