USE [AdventureWorks2012];

-- a) Создайте таблицу Sales.CreditCardHst, которая будет хранить информацию об изменениях в таблице Sales.CreditCard.
-- --------------------------------------------------------------------------------------------------------------------------
-- Обязательные поля, которые должны присутствовать в таблице: ID — первичный ключ IDENTITY(1,1); Action — совершенное 
-- действие (insert, update или delete); ModifiedDate — дата и время, когда была совершена операция; SourceID — первичный 
-- ключ исходной таблицы; UserName — имя пользователя, совершившего операцию. Создайте другие поля, если считаете их нужными.
CREATE TABLE [Sales].[CreditCardHst] (
    ID INT IDENTITY(1,1) PRIMARY KEY,
    Action CHAR(6) NOT NULL CHECK (Action IN('INSERT', 'UPDATE', 'DELETE')),
    ModifiedDate DATETIME NOT NULL,
    SourceID INT NOT NULL,
    UserName VARCHAR(50) NOT NULL
);

-- b) Создайте один AFTER триггер для трех операций INSERT, UPDATE, DELETE для таблицы Sales.CreditCard. Триггер должен заполнять 
-- таблицу Sales.CreditCardHst с указанием типа операции в поле Action в зависимости от оператора, вызвавшего триггер.
CREATE OR ALTER TRIGGER [Sales].[Trigger_CreditCard_After_DML]
ON [Sales].[CreditCard]
AFTER INSERT, UPDATE, DELETE AS 
    INSERT INTO [Sales].[CreditCardHst](Action, ModifiedDate, SourceID, UserName) 
    SELECT
      CASE WHEN inserted.CreditCardID IS NULL THEN 'DELETE'
           WHEN  deleted.CreditCardID IS NULL THEN 'INSERT'
                                              ELSE 'UPDATE'
      END                                                   AS Action,
      NOW()                                                 AS ModifiedDate,
	  COALESCE(inserted.CreditCardID, deleted.CreditCardID) AS SourceID,
      User_Name()                                           AS UserName
    FROM inserted FULL OUTER JOIN deleted
    ON inserted.CreditCardID = deleted.CreditCardID
GO

-- c) Создайте представление VIEW, отображающее все поля таблицы Sales.CreditCard.
CREATE OR ALTER VIEW [Sales].[View_CreditCard] AS SELECT * FROM [Sales].[CreditCard]


-- d) Вставьте новую строку в Sales.CreditCard через представление. Обновите вставленную строку. Удалите вставленную строку. 
-- Убедитесь, что все три операции отображены в Sales.CreditCardHst.
INSERT INTO [Sales].[CreditCard](CreditCardID, CardType, ExpYear, ModifiedDate)
VALUE (123456, 'Foo', 2021, NOW());

UPDATE [Sales].[CreditCard] SET CardType = 'Bar' WHERE CreditCardID = 123456;

DELETE FROM [Sales].[CreditCard] WHERE CreditCardID = 123456;

SELECT * FROM [Sales].[CreditCardHst];
GO