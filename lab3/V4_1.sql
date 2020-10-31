use [master]
go

use [AW]
go

--a)
if not exists ( select * from sys.columns where object_id = object_id(N'[dbo].[StateProvince]') and name = 'CountryRegionName')
begin
	alter table [dbo].[StateProvince] add [CountryRegionName] nvarchar(50);
end
go

--b)
declare @stateProvince table (
	[StateProvinceID] [int],
	[StateProvinceCode] [nchar](3),
	[CountryRegionCode] [nvarchar](3),
	[Name] nvarchar(50),
	[TerritoryID] [int],
	[ModifiedDate] [datetime],
	[CountryNum] [int],
	[CountryRegionName] nvarchar(50));
insert into @stateProvince
select
	[StateProvinceID],
	[StateProvinceCode],
	d.[CountryRegionCode],
	d.[Name],
	[TerritoryID],
	d.[ModifiedDate],
	[CountryNum],
	p.[Name] as [CountryRegionName]
from [dbo].[StateProvince] d join [Person].[CountryRegion] p on d.[CountryRegionCode] = p.[CountryRegionCode];

--c)
update [dbo].[StateProvince] set [CountryRegionName] = v.[CountryRegionName]
from [dbo].[StateProvince] join @stateProvince v on [dbo].[StateProvince].[StateProvinceID] = v.[StateProvinceID]

--d)
delete from [dbo].[StateProvince] where [StateProvinceID] not in (
	select distinct [StateProvinceID] from [Person].[Address]);

--e)
alter table [dbo].[StateProvince] drop column [CountryRegionName];
--deleting all constraints
declare @dropAllConstraints nvarchar(max) = N'';
select @dropAllConstraints += N'alter table dbo.' + object_name(parent_object_id) + ' drop constraint ' + object_name(object_id) + ';' 
from sys.objects
where (type_desc like 'check_constraint' or type_desc like 'default_constraint') and parent_object_id = object_id(N'[dbo].[StateProvince]');
--print @dropAllConstraints;
execute(@dropAllConstraints)

--f)
drop table [dbo].[StateProvince];

use [master]
go