CREATE DATABASE NewDatabase;
GO

USE NewDatabase;
GO

CREATE SCHEMA persons;
GO

CREATE SCHEMA sales;
GO

CREATE TABLE sales.Orders (OrderNum INT NULL);

BACKUP DATABASE NewDatabase
TO DISK = 'D:\Programs\Microsoft SQL Server\MSSQL11.SQLEXPRESS\MSSQL\Backup\NewDatabase-backup.bak'
WITH FORMAT,
      MEDIANAME = 'DB-tasks-backup',
      NAME = 'Full Backup of NewDatabase';
GO

USE master;
GO

DROP DATABASE NewDatabase;
GO

RESTORE DATABASE NewDatabase
FROM DISK = 'D:\Programs\Microsoft SQL Server\MSSQL11.SQLEXPRESS\MSSQL\Backup\NewDatabase-backup.bak'
GO

USE NewDatabase;
GO



