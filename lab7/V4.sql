use [master]
go

use [AW]
go

-- 2) --------------------------------------------------------------------------------------------------------------------------------------
if object_id('dbo.VendorsXmlToTable') is not null drop function dbo.VendorsXmlToTable;
go
create function dbo.VendorsXmlToTable(@vendorsXml xml) -- stored procedures cannot return tables, so it's function
returns table
as
	return
	select
		vendorsXml.c.value('ID[1]', 'int') Id,
		vendorsXml.c.value('Name[1]', 'nvarchar(50)') [Name],
		vendorsXml.c.value('AccountNumber[1]', 'nvarchar(15)') AccountNumber
	from @vendorsXml.nodes('Vendors/Vendor') vendorsXml(c);
go

-- 1) --------------------------------------------------------------------------------------------------------------------------------------
declare @vendorsXml xml = (
	select
		BusinessEntityID ID,
		[Name],
		AccountNumber
	from [Purchasing].[Vendor]
	for xml path('Vendor'),root('Vendors')
);

-- 3) --------------------------------------------------------------------------------------------------------------------------------------
select @vendorsXml;
select * from dbo.VendorsXmlToTable(@vendorsXml);

use [master]
go