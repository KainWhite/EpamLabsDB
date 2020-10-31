use [master]
go

use [AW]
go

--a)
if not exists ( select * from sys.columns where object_id = object_id(N'dbo.StateProvince') and name = 'SalesYTD')
begin
	alter table dbo.StateProvince add SalesYTD money;
end
if not exists ( select * from sys.columns where object_id = object_id(N'dbo.StateProvince') and name = 'SumSales')
begin
	alter table dbo.StateProvince add SumSales money;
end
go
if not exists ( select * from sys.columns where object_id = object_id(N'dbo.StateProvince') and name = 'SalesPercent')
begin
	alter table dbo.StateProvince add SalesPercent as SumSales / SalesYTD * 100;
end
go


--b)
if object_id('tempdb..#StateProvince') is not null drop table #StateProvince;
go
create table #StateProvince (
	[StateProvinceID] [int],
	[StateProvinceCode] [nchar](3),
	[CountryRegionCode] [nvarchar](3),
	[Name] nvarchar(50),
	[TerritoryID] [int],
	[ModifiedDate] [datetime],
	[CountryNum] [int],
	[SalesYTD] [money],
	[SumSales] [money],
	PRIMARY KEY ([StateProvinceID]));

--c)
insert into #StateProvince
select
	StateProvinceID,
	StateProvinceCode,
	d.CountryRegionCode,
	d.[Name],
	d.TerritoryID,
	d.ModifiedDate,
	CountryNum,
	st.SalesYTD,
	sp.SumSales
from dbo.StateProvince d
	join Sales.SalesTerritory st 
		on d.TerritoryID = st.TerritoryID
	join (select sum(SalesYTD) as SumSales, TerritoryID from Sales.SalesPerson group by TerritoryID) sp
		on st.TerritoryID = sp.TerritoryID;

--d)
delete from dbo.StateProvince where StateProvinceID = 5;

--e)
set identity_insert dbo.StateProvince on;
merge into dbo.StateProvince as t
using #StateProvince as s
on t.StateProvinceID = s.StateProvinceID
when matched
	then update set SalesYTD = s.SalesYTD, SumSales = s.SumSales
when not matched
	then insert (
		StateProvinceID,
		StateProvinceCode,
		CountryRegionCode,
		[Name],
		TerritoryID,
		ModifiedDate,
		CountryNum,
		SalesYTD,
		SumSales)
	values (
		s.StateProvinceID,
		s.StateProvinceCode,
		s.CountryRegionCode,
		s.[Name],
		s.TerritoryID,
		s.ModifiedDate,
		s.CountryNum,
		s.SalesYTD,
		s.SumSales)
when not matched by source
	then delete;

set identity_insert dbo.StateProvince off;
select * from dbo.StateProvince;

use [master]
go