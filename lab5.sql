-- Variant 5

USE [AdventureWorks2012];
GO

-- Создайте scalar-valued функцию, которая будет принимать в качестве входного параметра id модели для продукта 
-- (Production.ProductModel.ProductModelID) и возвращать суммарную стоимость продуктов данной модели (Production.Product.ListPrice).
IF OBJECT_ID (N'Production.GetProductPriceSumByModelID') IS NOT NULL  
    DROP FUNCTION Production.GetProductPriceSumByModelID;  
GO  
CREATE FUNCTION Production.GetProductPriceSumByModelID(@ProductModelID INT)  
RETURNS MONEY   
AS   
BEGIN  
    DECLARE @ret MONEY;  
    SELECT @ret = SUM(p.ListPrice)   
    FROM Production.Product p   
    WHERE p.ProductModelID = @ProductModelID    
    IF (@ret IS NULL) SET @ret = 0;  
    RETURN @ret;  
END;  
GO  

-- Создайте inline table-valued функцию, которая будет принимать в качестве входного параметра id заказчика 
-- (Sales.Customer.CustomerID), а возвращать 2 последних заказа, оформленных заказчиком из Sales.SalesOrderHeader.
IF OBJECT_ID (N'Sales.GetLastTwoOrdersByCustomerID') IS NOT NULL  
    DROP FUNCTION Sales.GetLastTwoOrdersByCustomerID;  
GO 
CREATE FUNCTION Sales.GetLastTwoOrdersByCustomerID(@CustomerID INT)
RETURNS TABLE AS RETURN (
	SELECT TOP(2) 
		[SalesOrderID],
		[RevisionNumber],
		[OrderDate],
		[DueDate],
		[ShipDate],
		[Status],
		[OnlineOrderFlag],
		[SalesOrderNumber],
		[PurchaseOrderNumber],
		[AccountNumber],
		[CustomerID],
		[SalesPersonID],
		[TerritoryID],
		[BillToAddressID],
		[ShipToAddressID],
		[ShipMethodID],
		[CreditCardID],
		[CreditCardApprovalCode],
		[CurrencyRateID],
		[SubTotal],
		[TaxAmt],
		[Freight],
		[TotalDue],
		[Comment],
		[rowguid],
		[ModifiedDate]
	FROM Sales.SalesOrderHeader AS s
	WHERE s.CustomerID = @CustomerID
	ORDER BY s.OrderDate DESC
);
GO

-- Вызовите функцию для каждого заказчика, применив оператор CROSS APPLY. Вызовите функцию для каждого заказчика, применив оператор OUTER APPLY.
SELECT * FROM Sales.Customer AS c CROSS APPLY Sales.GetLastTwoOrdersByCustomerID(c.CustomerID);
GO

SELECT * FROM Sales.Customer AS c OUTER APPLY Sales.GetLastTwoOrdersByCustomerID(c.CustomerID);
GO

-- Измените созданную inline table-valued функцию, сделав ее multistatement table-valued (предварительно сохранив для проверки код создания inline table-valued функции).
IF OBJECT_ID (N'Sales.GetLastTwoOrdersByCustomerID') IS NOT NULL  
    DROP FUNCTION Sales.GetLastTwoOrdersByCustomerID;  
GO 
CREATE FUNCTION Sales.GetLastTwoOrdersByCustomerID(@CustomerID INT)
RETURNS @ret TABLE(
	[SalesOrderID] [int] NOT NULL,
	[RevisionNumber] [tinyint] NOT NULL,
	[OrderDate] [datetime] NOT NULL,
	[DueDate] [datetime] NOT NULL,
	[ShipDate] [datetime] NULL,
	[Status] [tinyint] NOT NULL,
	[OnlineOrderFlag] [dbo].[Flag] NOT NULL,
	[SalesOrderNumber] [nvarchar](23),
	[PurchaseOrderNumber] [dbo].[OrderNumber] NULL,
	[AccountNumber] [dbo].[AccountNumber] NULL,
	[CustomerID] [int] NOT NULL,
	[SalesPersonID] [int] NULL,
	[TerritoryID] [int] NULL,
	[BillToAddressID] [int] NOT NULL,
	[ShipToAddressID] [int] NOT NULL,
	[ShipMethodID] [int] NOT NULL,
	[CreditCardID] [int] NULL,
	[CreditCardApprovalCode] [varchar](15) NULL,
	[CurrencyRateID] [int] NULL,
	[SubTotal] [money] NOT NULL ,
	[TaxAmt] [money] NOT NULL,
	[Freight] [money] NOT NULL,
	[TotalDue] INT NOT NULL,
	[Comment] [nvarchar](128) NULL,
	[rowguid] [uniqueidentifier] ROWGUIDCOL  NOT NULL,
	[ModifiedDate] [datetime] NOT NULL 
) AS BEGIN
	INSERT INTO @ret
	SELECT TOP(2) 
		[SalesOrderID],
		[RevisionNumber],
		[OrderDate],
		[DueDate],
		[ShipDate],
		[Status],
		[OnlineOrderFlag],
		[SalesOrderNumber],
		[PurchaseOrderNumber],
		[AccountNumber],
		[CustomerID],
		[SalesPersonID],
		[TerritoryID],
		[BillToAddressID],
		[ShipToAddressID],
		[ShipMethodID],
		[CreditCardID],
		[CreditCardApprovalCode],
		[CurrencyRateID],
		[SubTotal],
		[TaxAmt],
		[Freight],
		[TotalDue],
		[Comment],
		[rowguid],
		[ModifiedDate]
	FROM Sales.SalesOrderHeader AS s
	WHERE s.CustomerID = @CustomerID
	ORDER BY s.OrderDate DESC
	RETURN;
END;
GO