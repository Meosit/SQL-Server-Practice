-- Variant 5

USE [AdventureWorks2012];
GO

-- a) добавьте в таблицу dbo.Employee поле EmpNum типа int;
ALTER TABLE [dbo].[Employee] ADD EmpNum INT;

-- b) объявите табличную переменную с такой же структурой как dbo.Employee и заполните ее данными из dbo.Employee. Поле VacationHours заполните из
-- таблицы HumanResources.Employee. Поле EmpNum заполните последовательными номерами строк (примените оконные функции или создайте SEQUENCE);
DECLARE @EmployeeVar TABLE ( 
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
[EmpNum]             INT                                     NULL);

INSERT INTO @EmployeeVar (
	[BusinessEntityID], 
	[NationalIDNumber], 
	[LoginID], 
	[JobTitle], 
	[BirthDate], 
	[MaritalStatus], 
	[Gender], 
	[HireDate], 
	[VacationHours],
	[SickLeaveHours],
	[ModifiedDate], 
	[EmpNum]) 
SELECT
	[BusinessEntityID], 
	[NationalIDNumber], 
	[LoginID], 
	[JobTitle], 
	[BirthDate], 
	[MaritalStatus], 
	[Gender], 
	[HireDate],
	(SELECT [HE].[VacationHours] FROM [HumanResources].[Employee] AS [HE] WHERE [HE].[BusinessEntityID] = [DE].[BusinessEntityID]),
	[SickLeaveHours],
	[ModifiedDate],
	ROW_NUMBER() OVER(ORDER BY (SELECT 0))
FROM [dbo].[Employee] AS [DE];

SELECT * FROM @EmployeeVar;

-- c) обновите поля VacationHours и EmpNum в dbo.Employee данными из табличной переменной. Если значение в табличной переменной в поле VacationHours = 0 — оставьте старое значение;
UPDATE [dbo].[Employee] SET 
	[Employee].[VacationHours] = IIF([TVAR].[VacationHours] != 0, 
	[TVAR].[VacationHours], [EMP].[VacationHours]), [EmpNum] = [TVAR].[EmpNum]
FROM @EmployeeVar AS [TVAR] 
INNER JOIN [dbo].[Employee] AS [EMP] 
ON [TVAR].[BusinessEntityID] = [EMP].[BusinessEntityID];

-- d) удалите данные из dbo.Employee, EmailPromotion которых равен 0 в таблице Person.Person;
DELETE [EMP] 
FROM [dbo].[Employee] AS [EMP] 
INNER JOIN [Person].[Person] AS [PSN] 
ON [EMP].[BusinessEntityID] = [PSN].[BusinessEntityID]
WHERE [PSN].[EmailPromotion] = 0;
GO

-- e) удалите поле EmpName из таблицы, удалите все созданные ограничения и значения по умолчанию.
ALTER TABLE [dbo].[Employee] DROP COLUMN EmpNum;
ALTER TABLE [dbo].[Employee] DROP CONSTRAINT AK_Employee_NationalIDNumber_Unique;
ALTER TABLE [dbo].[Employee] DROP CONSTRAINT CHK_Employee_VacationHours_Positive;
ALTER TABLE [dbo].[Employee] DROP CONSTRAINT DF_Employee_VacationHours;

-- f) удалите таблицу dbo.Employee.
IF OBJECT_ID('[dbo].[Employee]') IS NOT NULL 
DROP TABLE [dbo].[Employee] 
GO