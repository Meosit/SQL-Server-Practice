USE [AdventureWorks2012];

-- a) выполните код, созданный во втором задании второй лабораторной работы. Добавьте в таблицу dbo.Employee поля SumTotal MONEY и SumTaxAmt MONEY. 
-- Также создайте в таблице вычисляемое поле WithoutTax, вычисляющее разницу между общей суммой уплаченых налогов (SumTaxAmt) и общей суммой продаж (SumTotal).
ALTER TABLE [dbo].[Employee] ADD SumTotal MONEY, SumTaxAmt MONEY, WithoutTax AS (SumTotal - SumTaxAmt);

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

-- c) заполните временную таблицу данными из dbo.Employee. Посчитайте сумму продаж (TotalDue) и сумму налогов (TaxAmt) для каждого сотрудника (EmployeeID) в таблице Purchasing.PurchaseOrderHeader и 
-- заполните этими значениями поля SumTotal и SumTaxAmt. Выберите только те записи, где SumTotal > 5 000 000. Подсчет суммы продаж и суммы налогов осуществите в Common Table Expression (CTE).

WITH PSUMS AS (SELECT
	SUM([TotalDue]) AS SumTotal,
	SUM([TaxAmt]) AS SumTaxAmt
FROM [Purchasing].[PurchaseOrderHeader]
GROUP BY EmployeeID)
SELECT 

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
	[ModifiedDate]    
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
	[ModifiedDate]    
FROM [dbo].[Employee];

-- d) удалите из таблицы dbo.Employee строки, где MaritalStatus = ‘S’
DELETE FROM [dbo].[Employee] WHERE [MaritalStatus] = 'S';

-- e) напишите Merge выражение, использующее dbo.Employee как target, а временную таблицу как source. Для связи target и source используйте BusinessEntityID. Обновите поля SumTotal и SumTaxAmt, 
-- если запись присутствует в source и target. Если строка присутствует во временной таблице, но не существует в target, добавьте строку в dbo.Employee. Если в dbo.Employee присутствует такая 
-- строка, которой не существует во временной таблице, удалите строку из dbo.Employee.
MERGE INTO [dbo].[Employee] AS Target
USING [dbo].[#Employee] AS Source
ON Target.[BusinessEntityID] = Source.[BusinessEntityID]
WHEN MATCHED THEN UPDATE SET 
	