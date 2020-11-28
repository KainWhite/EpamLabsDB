use [master]
go

use [AW]
go

if object_id('dbo.EmpCountByDep') is not null drop procedure dbo.EmpCountByDep;
go
create procedure dbo.EmpCountByDep
	@years nvarchar(100)
as
begin
	declare @sql nvarchar(1000) = '
		select * from
			(select
				BusinessEntityID,
				[Name] DepartmentName,
				year(StartDate) StartDateYear
			from HumanResources.EmployeeDepartmentHistory edh
			join HumanResources.Department d
				on d.DepartmentID = edh.DepartmentID) hist
			pivot (
				count(BusinessEntityID)
				for StartDateYear in ('+ @years + ')
			) piv';
	exec sp_executesql @sql;
end;
go

exec dbo.EmpCountByDep '[2001],[2002],[2003],[2004],[2005],[2006],[2007]';

use [master]
go
