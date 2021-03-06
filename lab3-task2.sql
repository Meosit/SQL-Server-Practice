﻿-- Variant 5

USE [AdventureWorks2012];
GO

-- a) выполните код, созданный во втором задании второй лабораторной работы. Добавьте в таблицу dbo.Employee поля SumTotal MONEY и SumTaxAmt MONEY. 
-- Также создайте в таблице вычисляемое поле WithoutTax, вычисляющее разницу между общей суммой уплаченых налогов (SumTaxAmt) и общей суммой продаж (SumTotal).
ALTER TABLE [dbo].[Employee] ADD SumTotal MONEY, SumTaxAmt MONEY, WithoutTax AS (SumTotal - SumTaxAmt);
GO

-- b) создайте временную таблицу #Employee, с первичным ключом по полю BusinessEntityID. Временная таблица должна включать все поля таблицы dbo.Employee за исключением поля WithoutTax.
CREATE TABLE dbo.#Employee ( 
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
[SumTotal]           MONEY                                   NULL,
[SumTaxAmt]          MONEY                                   NULL,
PRIMARY KEY CLUSTERED    ([BusinessEntityID] asc));
GO

-- c) заполните временную таблицу данными из dbo.Employee. Посчитайте сумму продаж (TotalDue) и сумму налогов (TaxAmt) для каждого сотрудника (EmployeeID) в таблице Purchasing.PurchaseOrderHeader и 
-- заполните этими значениями поля SumTotal и SumTaxAmt. Выберите только те записи, где SumTotal > 5 000 000. Подсчет суммы продаж и суммы налогов осуществите в Common Table Expression (CTE).

WITH ENHANCED_EMPLOYEE AS (SELECT
    [BusinessEntityID],
	[NationalIDNumber],
	[LoginID]         ,
	[JobTitle]        ,
	[BirthDate]       ,
	[MaritalStatus]   ,
	[Gender]          ,
	[HireDate]        ,
	[VacationHours]   ,
	[SickLeaveHours]  ,
	[Employee].[ModifiedDate]    ,
	SUM([TotalDue]) AS SumTotal,
	SUM([TaxAmt]) AS SumTaxAmt
FROM [dbo].[Employee]
INNER JOIN [Purchasing].[PurchaseOrderHeader]
ON [BusinessEntityID] = [EmployeeID]
GROUP BY [BusinessEntityID],
	[NationalIDNumber],
	[LoginID]         ,
	[JobTitle]        ,
	[BirthDate]       ,
	[MaritalStatus]   ,
	[Gender]          ,
	[HireDate]        ,
	[VacationHours]   ,
    [SickLeaveHours]  ,
    [Employee].[ModifiedDate]
HAVING SUM([TotalDue]) > 5000000)

INSERT INTO [dbo].[#Employee](
    [BusinessEntityID],
    [NationalIDNumber],
    [LoginID]         ,
    [JobTitle]        ,
    [BirthDate]       ,
    [MaritalStatus]   ,
    [Gender]          ,
    [HireDate]        ,
    [VacationHours]   ,
    [SickLeaveHours]  ,
    [ModifiedDate]    ,
    [SumTotal]        ,
    [SumTaxAmt]
) SELECT 
    [BusinessEntityID],
    [NationalIDNumber],
    [LoginID]         ,
    [JobTitle]        ,
    [BirthDate]       ,
    [MaritalStatus]   ,
    [Gender]          ,
    [HireDate]        ,
    [VacationHours]   ,
    [SickLeaveHours]  ,
    [ModifiedDate]    ,
    [SumTotal]        ,
    [SumTaxAmt]
FROM ENHANCED_EMPLOYEE;
GO

-- d) удалите из таблицы dbo.Employee строки, где MaritalStatus = ‘S’
DELETE FROM [dbo].[Employee] WHERE [MaritalStatus] = 'S';
SELECT * FROM [dbo].#Employee
-- e) напишите Merge выражение, использующее dbo.Employee как target, а временную таблицу как source. Для связи target и source используйте BusinessEntityID. Обновите поля SumTotal и SumTaxAmt, 
-- если запись присутствует в source и target. Если строка присутствует во временной таблице, но не существует в target, добавьте строку в dbo.Employee. Если в dbo.Employee присутствует такая 
-- строка, которой не существует во временной таблице, удалите строку из dbo.Employee.
MERGE INTO [dbo].[Employee] AS Target
USING [dbo].[#Employee]
ON Target.[BusinessEntityID] = [#Employee].[BusinessEntityID]
WHEN MATCHED THEN UPDATE SET
    SumTotal = [#Employee].SumTotal,
    SumTaxAmt = [#Employee].SumTaxAmt
WHEN NOT MATCHED BY TARGET THEN
    INSERT (
		[BusinessEntityID],
        [NationalIDNumber],
        [LoginID]         ,
        [JobTitle]        ,
        [BirthDate]       ,
        [MaritalStatus]   ,
        [Gender]          ,
        [HireDate]        ,
        [VacationHours]   ,
        [SickLeaveHours]  ,
        [ModifiedDate]    ,
        [SumTotal]        ,
        [SumTaxAmt]
    ) VALUES (
		[#Employee].[BusinessEntityID],
        [#Employee].[NationalIDNumber],
        [#Employee].[LoginID]         ,
        [#Employee].[JobTitle]        ,
        [#Employee].[BirthDate]       ,
        [#Employee].[MaritalStatus]   ,
        [#Employee].[Gender]          ,
        [#Employee].[HireDate]        ,
        [#Employee].[VacationHours]   ,
        [#Employee].[SickLeaveHours]  ,
        [#Employee].[ModifiedDate]    ,
        [#Employee].[SumTotal]        ,
        [#Employee].[SumTaxAmt]
    )
WHEN NOT MATCHED BY SOURCE THEN
    DELETE;
GO    
    