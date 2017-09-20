-- Variant 5
USE [AdventureWorks2012];

-- a) создайте таблицу dbo.Employee с такой же структурой как HumanResources.Employee, кроме полей OrganizationLevel, 
-- SalariedFlag, CurrentFlag, а также кроме полей с типом hierarchyid, uniqueidentifier, не включая индексы, ограничения и триггеры;
IF OBJECT_ID('[dbo].[Employee]') IS NOT NULL 
DROP TABLE [dbo].[Employee]

CREATE TABLE [dbo].[Employee] ( 
[BusinessEntityID]   INT                                     NOT NULL,
[NationalIDNumber]   NVARCHAR(15)                            NOT NULL,
[LoginID]            NVARCHAR(256)                           NOT NULL,
[JobTitle]           NVARCHAR(50)                            NOT NULL,
[BirthDate]          DATE                                    NOT NULL,
[MaritalStatus]      NCHAR(1)                                NOT NULL,
[Gender]             NCHAR(1)                                NOT NULL,
[HireDate]           DATE                                    NOT NULL,
[VacationHours]      SMALLINT                                NOT NULL,
[SickLeaveHours]     SMALLINT                                NOT NULL,
[ModifiedDate]       DATETIME                                NOT NULL,
CONSTRAINT   [PK_Employee_BusinessEntityID]  PRIMARY KEY CLUSTERED    ([BusinessEntityID] asc))

-- b) используя инструкцию ALTER TABLE, создайте для таблицы dbo.Employee ограничение UNIQUE для поля NationalIDNumber;
ALTER TABLE [dbo].[Employee] 
ADD CONSTRAINT AK_Employee_NationalIDNumber_Unique UNIQUE ([NationalIDNumber]); 

-- c) используя инструкцию ALTER TABLE, создайте для таблицы dbo.Employee ограничение для поля VacationHours, запрещающее заполнение этого поля значениями меньшими или равными 0;
ALTER TABLE [dbo].[Employee] 
ADD CONSTRAINT CHK_Employee_VacationHours_Positive CHECK ([VacationHours] > 0);

-- d) используя инструкцию ALTER TABLE, создайте для таблицы dbo.Employee ограничение DEFAULT для поля VacationHours, задайте значение по умолчанию 144;
ALTER TABLE [dbo].[Employee] 
ADD CONSTRAINT DF_Employee_VacationHours DEFAULT 144 FOR VacationHours;

-- e) заполните новую таблицу данными из HumanResources.Employee о сотрудниках на позиции ‘Buyer’. Не указывайте для выборки поле VacationHours, чтобы оно заполнилось значениями по умолчанию;
INSERT INTO [dbo].[Employee] (
	[BusinessEntityID], 
	[NationalIDNumber], 
	[LoginID], 
	[JobTitle], 
	[BirthDate], 
	[MaritalStatus], 
	[Gender], 
	[HireDate],
	[SickLeaveHours],
	[ModifiedDate]
) SELECT
	[BusinessEntityID], 
	[NationalIDNumber], 
	[LoginID], 
	[JobTitle], 
	[BirthDate], 
	[MaritalStatus], 
	[Gender], 
	[HireDate],
	[SickLeaveHours],
	[ModifiedDate]
FROM [HumanResources].[Employee]
WHERE [JobTitle] = 'Buyer';

-- f) измените тип поля ModifiedDate на DATE и разрешите добавление null значений для него.
ALTER TABLE [dbo].[Employee] 
ALTER COLUMN [ModifiedDate] DATE NULL;
GO