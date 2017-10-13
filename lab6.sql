-- Variant 5

USE [AdventureWorks2012];
GO
 
-- Создайте хранимую процедуру, которая будет возвращать сводную таблицу (оператор PIVOT), отображающую данные о количестве оформленных 
-- заказов каждым сотрудником (Purchasing.PurchaseOrderHeader.EmployeeID), доставленных определенным образом (Purchasing.ShipMethod). 
-- Список типов доставки передайте в процедуру через входной параметр.
DROP PROCEDURE Purchasing.OrderCountByShipMethod;
GO
CREATE PROCEDURE Purchasing.OrderCountByShipMethod(@ShipMethodNames NVARCHAR(300)) AS
	SET NOCOUNT ON
	DECLARE @SQLQuery AS NVARCHAR(900);
	SET @SQLQuery = '
SELECT EmployeeID, ' + @ShipMethodNames + '
FROM (
	SELECT EmployeeID, PurchaseOrderID, Name FROM Purchasing.PurchaseOrderHeader POH 
	JOIN Purchasing.ShipMethod SH 
	ON POH.ShipMethodID = SH.ShipMethodID
) AS pol
PIVOT (COUNT(PurchaseOrderID) FOR pol.Name IN(' + @ShipMethodNames + ')) AS pvt'
    EXECUTE sp_executesql @SQLQuery
                
    IF @@ERROR <> 0 GOTO ErrorHandler
    SET NOCOUNT OFF
    RETURN(0)
  
ERRORHANDLER:
    RETURN(@@ERROR)
GO

-- Таким образом, вызов процедуры будет выглядеть следующим образом:
EXECUTE Purchasing.OrderCountByShipMethod '[CARGO TRANSPORT 5],[OVERNIGHT J-FAST],[OVERSEAS — DELUXE]'

