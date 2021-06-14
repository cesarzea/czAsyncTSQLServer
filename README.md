# "Advanced" T-SQL Asynchronous Programing?

This is an advanced solution not only be able to execute several asynchronous T-SQL statements or procedures, but also be able to continue executing other statements when the asynchronous statements had finished, knowing when was errors, passing extra info, etc. 

That is an example that can be implemented with that solution with an easy code: 


<p align="center">
<img  src="https://github.com/cesarzea/czAsyncTSQLServer/blob/master/data/docImages/use_case_2.png?raw=true" width="90%">
</p>

It is a solution that I have used many times, so I consider it reliable.

> Read all the documentation, examples, etc. at https://www.cesarzea.com/czAsyncSQLServer

# How the files are stored here

That git repo include all source code in SQL fromat and the documentation in the *czJsDocShowcase* format (see https://github.com/cesarzea/czJsDocShowcase for more info about the czJsDocShowcase project):

Files and folders: 

- ./doc/: all source files and documentation.
- ./doc/code/: the source code with the use cases and examples. 

# Examples where I used it

I have used this solution, or previous versions, on projects such as:

- Many optimizations of query heavy data processing executions to make the most of all CPU cores of the server.
- Several high-performance BI report generation servers on demand, where a massive number of users should be able to request the generation of long-run time reports to be generated offline without overloading the server and limiting the number of reports generated simultaneously.
- Implementation of SQL Server Git solution to automatically log database schema changes to Git repositories.
- Datawarehouse and BI systems.
- A system for the transmission of large volumes of data in an ultra fast way between SQL Server servers.
- An utility for using SalesForce bridges from T-SQL.
- Etc.

I hope to have time to share some of these solutions soon.

I consider this solution so useful that it is rare to work SQL Server where I don’t use it. Once you get used to using it, it will become part of your regular work and you will use asynchronous executions with the same ease as you do any other T-SQL task.

I can certainly say that being able to count on it will greatly elevate your data processing skills in SQL Server.

Continue readint at: https://www.cesarzea.com/czAsyncSQLServer

# César Pedro Zea Gómez contact information

I am a freelance professional. Contact to request my professional services and also for any doubt, problem or proposal for improvement, to request a license, etc.

- Web: <a href="https://www.cesarzea.com" target="_blanc">https://www.cesarzea.com</a>
- LinkedIn: <a href="https://www.linkedin.com/in/cesarzea/" target="_blanc">https://www.linkedin.com/in/cesarzea/</a>
- Skype: cesar\_zea\_gomez


