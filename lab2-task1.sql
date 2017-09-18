-- Variant 5

-- Вывести на экран время работы каждого сотрудника.
SELECT 
	[Employee].[BusinessEntityID], 
	[Employee].[JobTitle], 
	[Shift].[Name], 
	[Shift].[StartTime], 
	[Shift].[EndTime] 
FROM [AdventureWorks2012].[HumanResources].[Employee]
INNER JOIN [AdventureWorks2012].[HumanResources].[EmployeeDepartmentHistory] 
	ON [Employee].[BusinessEntityID] = [EmployeeDepartmentHistory].[BusinessEntityID]
INNER JOIN [AdventureWorks2012].[HumanResources].[Shift] 
	ON [EmployeeDepartmentHistory].[ShiftID] = [Shift].[ShiftID];
GO

-- Вывести на экран количество сотрудников в каждой группе отделов.
SELECT 
	[Department].[GroupName],
	COUNT([Employee].[BusinessEntityID]) AS 'EmpCount'
FROM [AdventureWorks2012].[HumanResources].[Department]
INNER JOIN [AdventureWorks2012].[HumanResources].[EmployeeDepartmentHistory] 
	ON [EmployeeDepartmentHistory].[DepartmentID] = [Department].[DepartmentID]
INNER JOIN [AdventureWorks2012].[HumanResources].[Employee]
	ON [Employee].[BusinessEntityID] = [EmployeeDepartmentHistory].[BusinessEntityID]
GROUP BY [Department].[GroupName];
GO

-- Вывести на экран почасовые ставки сотрудников, с указанием максимальной ставки для каждого отдела в столбце [MaxInDepartment]. 
-- В рамках каждого отдела разбейте все ставки на группы, таким образом, чтобы ставки с одинаковыми значениями входили в состав одной группы.
SELECT 
	[Department].[Name],
	[Employee].[BusinessEntityID],
	[EmployeePayHistory].[Rate],
	MAX([EmployeePayHistory].[Rate]) OVER(PARTITION BY [Department].[Name]) AS 'MaxInDepartment',
	DENSE_RANK() OVER (PARTITION BY [Department].[Name] ORDER BY [EmployeePayHistory].[Rate]) AS 'RateGroup'
FROM [AdventureWorks2012].[HumanResources].[Department]
INNER JOIN [AdventureWorks2012].[HumanResources].[EmployeeDepartmentHistory] 
	ON [EmployeeDepartmentHistory].[DepartmentID] = [Department].[DepartmentID]
INNER JOIN [AdventureWorks2012].[HumanResources].[Employee]
	ON [Employee].[BusinessEntityID] = [EmployeeDepartmentHistory].[BusinessEntityID] 
INNER JOIN [AdventureWorks2012].[HumanResources].[EmployeePayHistory]
	ON [Employee].[BusinessEntityID] = [EmployeePayHistory].[BusinessEntityID] 
GROUP BY [Department].[Name] ,[Employee].[BusinessEntityID], [EmployeePayHistory].[Rate]
ORDER BY [Department].[Name] ASC;
GO