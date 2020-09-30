USE master
GO

RESTORE DATABASE AW
	FROM DISK = 'C:\Users\KainWhite\Documents\University\DB\EpamLabsDB\AW\AdventureWorks2012-Full Database Backup.bak'
	WITH
		MOVE 'AdventureWorks2012_Data' TO 'C:\Users\KainWhite\Documents\University\DB\EpamLabsDB\AW\AdventureWorks2012_Data.mdf',
		MOVE 'AdventureWorks2012_log' TO 'C:\Users\KainWhite\Documents\University\DB\EpamLabsDB\AW\AdventureWorks2012_log.ldf';
USE AW
GO

/* Task 1 */
select
	d.[Name],
	e.[JobTitle],
	sum(count(*)) over(partition by d.[Name]) as EmpCount
from [HumanResources].[Employee] e
	inner join [HumanResources].[EmployeeDepartmentHistory] edh
		on edh.[BusinessEntityID] = e.[BusinessEntityID]
	inner join [HumanResources].[Department] d
		on edh.[DepartmentID] = d.[DepartmentID]
group by e.[JobTitle], d.[Name]
order by d.[Name];

/* query to check Task 1 */
/*select
	d.[Name],
	count(*) as EmpCount
from [HumanResources].[Employee] e
	inner join [HumanResources].[EmployeeDepartmentHistory] edh
		on edh.[BusinessEntityID] = e.[BusinessEntityID]
	inner join [HumanResources].[Department] d
		on edh.[DepartmentID] = d.[DepartmentID]
group by d.[Name]
order by d.[Name];*/

/* Task 2 */
select
	s.[Name],
	s.[StartTime],
	s.[EndTime],
	e.*
from [HumanResources].[Employee] e
	inner join [HumanResources].[EmployeeDepartmentHistory] edh
		on edh.[BusinessEntityID] = e.[BusinessEntityID]
	inner join [HumanResources].[Shift] s
		on edh.[ShiftID] = s.[ShiftID]
where s.Name = 'night'

/* Task 3 */
select
	e.[BusinessEntityID],
	eph.[Rate],
	lag(eph.[Rate], 1, 0) over(partition by e.[BusinessEntityID] order by eph.[RateChangeDate]) as PrevRate,
	eph.[Rate] - lag(eph.[Rate], 1, 0) over(partition by e.[BusinessEntityID] order by eph.[RateChangeDate]) as Increased
from [HumanResources].[Employee] e
	inner join [HumanResources].[EmployeePayHistory] eph
		on eph.[BusinessEntityID] = e.[BusinessEntityID]

USE master
GO