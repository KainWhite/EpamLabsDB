RESTORE DATABASE AW
	FROM DISK = 'C:\Users\KainWhite\Documents\University\DB\EpamLabsDB\AW\AdventureWorks2012-Full Database Backup.bak'
	WITH
		MOVE 'AdventureWorks2012_Data' TO 'C:\Users\KainWhite\Documents\University\DB\EpamLabsDB\AW\AdventureWorks2012_Data.mdf',
		MOVE 'AdventureWorks2012_log' TO 'C:\Users\KainWhite\Documents\University\DB\EpamLabsDB\AW\AdventureWorks2012_log.ldf';
USE AW
GO

/* Task 1 */
SELECT [Name], [GroupName] FROM [HumanResources].[Department] WHERE [GroupName] = 'Executive General and Administration';

/* Task 2 */
SELECT MAX([VacationHours]) AS 'MaxVacationHours' FROM [HumanResources].[Employee];

/* Task 3 */
SELECT * FROM [HumanResources].[Employee] WHERE [JobTitle] LIKE '%Engineer%';

USE master
GO