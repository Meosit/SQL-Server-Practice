-- Variant 5

USE [AdventureWorks2012];
GO

-- a) Создайте представление VIEW, отображающее данные из таблиц Sales.CreditCard и Sales.PersonCreditCard. Сделайте 
-- невозможным просмотр исходного кода представления. Создайте уникальный кластерный индекс в представлении по полю CreditCardID.
DROP VIEW [Sales].[View_ExtendedCreditCard];
GO

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
DROP TRIGGER [Sales].[Trigger_View_ExtendedCreditCard_Instead_Insert];
DROP TRIGGER [Sales].[Trigger_View_ExtendedCreditCard_Instead_Update];
DROP TRIGGER [Sales].[Trigger_View_ExtendedCreditCard_Instead_Delete];
GO

CREATE TRIGGER [Sales].[Trigger_View_ExtendedCreditCard_Instead_Insert] ON [Sales].[View_ExtendedCreditCard]
INSTEAD OF INSERT AS
BEGIN
	INSERT INTO [Sales].[CreditCard] ([CardType], [CardNumber], [ExpMonth], [ExpYear], [ModifiedDate])
	SELECT  [CardType], [CardNumber], [ExpMonth], [ExpYear], COALESCE([ModifiedDate], GETDATE())
	FROM inserted;
	INSERT INTO [Sales].[PersonCreditCard] (BusinessEntityID, CreditCardID, ModifiedDate)
	SELECT I.BusinessEntityID, CC.CreditCardID, GETDATE() 
	FROM inserted AS I JOIN Sales.CreditCard AS CC ON I.CardNumber = CC.CardNumber
END;
GO

CREATE TRIGGER [Sales].[Trigger_View_ExtendedCreditCard_Instead_Update] ON [Sales].[View_ExtendedCreditCard]
INSTEAD OF UPDATE AS
BEGIN
	UPDATE [Sales].[CreditCard] SET 
		[CardType] = I.CardType, 
		[CardNumber] = I.CardNumber, 
		[ExpMonth] = I.ExpMonth, 
		[ExpYear] = I.ExpYear, 
		[ModifiedDate] = COALESCE(I.[ModifiedDate], [Sales].[CreditCard].[ModifiedDate])
	FROM inserted AS I
	WHERE I.CreditCardID = Sales.CreditCard.CreditCardID
END;
GO

CREATE TRIGGER [Sales].[Trigger_View_ExtendedCreditCard_Instead_Delete] ON [Sales].[View_ExtendedCreditCard]
INSTEAD OF DELETE AS
BEGIN
	DELETE FROM [Sales].[PersonCreditCard] WHERE BusinessEntityID IN (SELECT BusinessEntityID FROM deleted)
	DELETE FROM [Sales].[CreditCard] WHERE CreditCardID IN (SELECT CreditCardID FROM deleted) 
										AND CreditCardID NOT IN (SELECT CreditCardID FROM Sales.PersonCreditCard);
END;
GO

-- c) Вставьте новую строку в представление, указав новые данные для CreditCard для существующего BusinessEntityID (например 1). 
-- Триггер должен добавить новые строки в таблицы Sales.CreditCard и Sales.PersonCreditCard. Обновите вставленные строки через 
-- представление. Удалите строки.
SELECT * FROM Sales.View_ExtendedCreditCard
ORDER BY CreditCardID DESC;
GO

INSERT INTO [Sales].[View_ExtendedCreditCard](
	[CardType],
	[CardNumber],
	[ExpMonth],
	[ExpYear],
	[BusinessEntityID]
) VALUES ('TestCardType', '00000000000000000', 9, 2017, 4955);
GO

UPDATE [Sales].[View_ExtendedCreditCard] SET
	CardType = 'Updated',
	CardNumber = '00000000000000001',
	ExpMonth = 12,
	ExpYear = 2018
WHERE CreditCardID = 123475
GO

DELETE FROM [Sales].View_ExtendedCreditCard WHERE CardNumber = '00000000000000001';

SELECT * FROM Sales.CreditCardHst