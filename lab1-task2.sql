-- Variant 5

-- Вывести на экран список отделов, принадлежащих группе ‘Research and Development’, отсортированных по названию отдела в порядке A-Z.
SELECT * FROM [AdventureWorks2012].[HumanResources].[Department]
WHERE [GroupName] = 'Research and Development'
ORDER BY [Name] ASC;
GO

-- Вывести на экран минимальное количество оставшихся больничных часов у сотрудников. Назовите столбец с результатом ‘MinSickLeaveHours’.
SELECT MIN([SickLeaveHours]) AS 'MinSickLeaveHours' FROM [AdventureWorks2012].[HumanResources].[Employee];
GO

--Вывести на экран список неповторяющихся должностей в порядке A-Z. Вывести только первые 10 названий. Добавить столбец, в котором вывести первое слово из поля [JobTitle].
SELECT DISTINCT TOP 10 [JobTitle], SUBSTRING([JobTitle],1,(CHARINDEX(' ',[JobTitle]+ ' ')-1)) AS 'FirstWord' 
FROM [AdventureWorks2012].[HumanResources].[Employee]
ORDER BY [JobTitle] ASC;
GO