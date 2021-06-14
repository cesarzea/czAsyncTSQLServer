<div markdown class="margin900">

## Introduction


## Step 1: Enabling Service Broker

To check if Service Broker is enabled in your database: 

```sql
SELECT name, database_id, is_broker_enabled FROM sys.databases

```

To enable Service Broker in a SQL Server database:

```sql
ALTER DATABASE [DB NAME] SET ENABLE_BROKER

```

If you want to execute the change inmediatelly, interrupting any other connection or process that could be a problem for the change: 

```sql
ALTER DATABASE [DB NAME] SET ENABLE_BROKER WITH ROLLBACK IMMEDIATE

```

## Step 2: Create the table czAsyncExecResults

<pre data-src='..\data\code\czAsyncExecResults.sql'></pre>

## Step 3: Create czAsyncExecQueue

:>[c=red][i=fa-exclamation-triangle] Be careful with the **MAX\_QUEUE\_READERS** value. Its value indicates how many simultaneous processes the queue will execute concurrently.

<pre data-src='..\data\code\czAsyncExecQueue.sql'></pre>

## Step 4: Create czAsyncExecService

<pre data-src='..\data\code\czAsyncExecService.sql'></pre>

## Step 5: Create st_czAsyncExecInvoke

<pre data-src='..\data\code\st_czAsyncExecInvoke.sql'></pre>

## Step 6:Create st_czAsyncExecActivated

<pre data-src='..\data\code\st_czAsyncExecActivated.sql'></pre>

</div>