-- Variant 5

USE [AdventureWorks2012];
GO

-- a) Создайте представление VIEW, отображающее данные из таблиц Sales.CreditCard и Sales.PersonCreditCard. Сделайте 
-- невозможным просмотр исходного кода представления. Создайте уникальный кластерный индекс в представлении по полю CreditCardID.
CREATE VIEW [Sales].[View_ExtendedCreditCard] (
	[CreditCardID],
	[CardType],
	[CardNumber],
	[ExpMonth],
	[ExpYear],
	[BusinessEntityID],
	[ModifiedDate],
	[PersonModifiedDate]
) WITH ENCRYPTION, SCHEMABINDING AS SELECT 
	CC.CreditCardID,
	CC.CardType,
	CC.CardNumber,
	CC.ExpMonth,
	CC.ExpYear,
	PCC.BusinessEntityID,
	CC.ModifiedDate,
	PCC.ModifiedDate
FROM [Sales].[CreditCard] AS CC INNER JOIN [Sales].[PersonCreditCard] AS PCC
ON CC.CreditCardID = PCC.CreditCardID
GO

CREATE UNIQUE CLUSTERED INDEX [AK_View_ExtendedCreditCard_CreditCardID] ON [Sales].[View_ExtendedCreditCard] ([CreditCardId]);
GO

-- b) Создайте три INSTEAD OF триггера для представления на операции INSERT, UPDATE, DELETE. Каждый триггер должен выполнять 
-- соответствующие операции в таблицах Sales.CreditCard и Sales.PersonCreditCard для указанного BusinessEntityID. Обновление 
-- должно происходить только в таблице Sales.CreditCard. Удаление строк из таблицы Sales.CreditCard производите только в том 
-- случае, если удаляемые строки больше не ссылаются на Sales.PersonCreditCard.
CREATE TRIGGER [Sales].[Trigger_View_ExtendedCreditCard_Instead_Insert] ON [Sales].[View_ExtendedCreditCard]
INSTEAD OF INSERT AS
BEGIN
	INSERT INTO [Sales].[CreditCard] ([CardType], [CardNumber], [ExpMonth], [ExpYear], [ModifiedDate])
	SELECT  [CardType], [CardNumber], [ExpMonth], [ExpYear], [ModifiedDate]
	FROM inserted;
	INSERT INTO [Sales].[PersonCreditCard]
	SELECT  [BusinessEntityID], [CreditCardID], [PersonModifiedDate]
	FROM inserted
END;
GO

-- c) Вставьте новую строку в представление, указав новые данные для CreditCard для существующего BusinessEntityID (например 1). 
-- Триггер должен добавить новые строки в таблицы Sales.CreditCard и Sales.PersonCreditCard. Обновите вставленные строки через 
-- представление. Удалите строки.