USE master
GO
alter database AW set offline with rollback immediate;
RESTORE DATABASE AW
	FROM DISK = 'C:\Users\KainWhite\Documents\University\DB\EpamLabsDB\AW\AdventureWorks2012-Full Database Backup.bak'
	WITH
		MOVE 'AdventureWorks2012_Data' TO 'C:\Users\KainWhite\Documents\University\DB\EpamLabsDB\AW\AdventureWorks2012_Data.mdf',
		MOVE 'AdventureWorks2012_log' TO 'C:\Users\KainWhite\Documents\University\DB\EpamLabsDB\AW\AdventureWorks2012_log.ldf';
alter database AW set online;
USE AW
GO

drop table if exists [StateProvince];

/* Task a) */
select top 0 * into [StateProvince] from [Person].[StateProvince];
alter table [StateProvince] drop column [rowguid];

/* Task b) */
alter table [StateProvince] add constraint [AK_StateProvince_Name] unique ([Name]);

/* Task c) */
alter table [StateProvince] add constraint [CK_StateProvince_CountryRegionCode] check ([CountryRegionCode] not like('[0-9]'));

/* Task d) */
alter table [StateProvince] add constraint [DF_StateProvince_ModifiedDate] default GETDATE() for [ModifiedDate];

/* Task e) */
set identity_insert [StateProvince] on;
insert into [StateProvince] (
	[CountryRegionCode],
	[IsOnlyStateProvinceFlag],
	[ModifiedDate],
	[Name],
	[StateProvinceCode],
	[StateProvinceID],
	[TerritoryID]
) select 
	[CountryRegionCode],
	[IsOnlyStateProvinceFlag],
	[ModifiedDate],
	[Name],
	[StateProvinceCode],
	[StateProvinceID],
	[TerritoryID]
from [Person].[StateProvince] sp
where sp.[CountryRegionCode] = sp.StateProvinceCode;
set identity_insert [StateProvince] off;

/* Task f) */
alter table [StateProvince] drop column [IsOnlyStateProvinceFlag];
alter table [StateProvince] add [CountryNum] int null;

USE master
GO