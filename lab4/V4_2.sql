use [master]
go

use [AW]
go

--a) --------------------------------------------------------------------------------------------------------------------------------------
if object_id('ProductView') is not null drop view ProductView;
go
create view ProductView with encryption, schemabinding as
select
	pm.ProductModelID,
	pm.CatalogDescription,
	pm.Instructions,
	pm.ModifiedDate,
	pm.[Name],
	pm.rowguid,
	pmpdc.ModifiedDate as PMPDCModifiedDate,
	c.CultureID,
	c.[Name] as CName,
	c.ModifiedDate as CModifiedDate,
	pd.ProductDescriptionID,
	pd.[Description] as PDDescription,
	pd.ModifiedDate as PDModifiedDate,
	pd.rowguid as PDRowguid
from Production.ProductModel pm
join Production.ProductModelProductDescriptionCulture pmpdc
	on pm.ProductModelID = pmpdc.ProductModelID
join Production.Culture c
	on pmpdc.CultureID = c.CultureID
join Production.ProductDescription pd
	on pmpdc.ProductDescriptionID = pd.ProductDescriptionID;
go

create unique clustered index ucidxPMIdCId
	on ProductView(ProductModelID, CultureID);
go

--b) --------------------------------------------------------------------------------------------------------------------------------------
if exists (select * from sys.objects where [name] = 'trgInsteadI' and [type] = 'tr')
begin
      drop trigger Production.trgInsteadI;
end
go
create trigger trgInsteadI on ProductView
instead of insert as
begin
	declare @modifiedDate datetime = getdate();

	insert into Production.ProductModel (CatalogDescription, Instructions, ModifiedDate, [Name], rowguid)
	select 
		CatalogDescription,
		Instructions,
		@modifiedDate,
		[Name],
		rowguid
	from inserted;

	insert into Production.Culture (CultureID, ModifiedDate, [Name])
	select
		CultureID,
		@modifiedDate,
		CName
	from inserted i;

	insert into Production.ProductDescription ([Description], ModifiedDate, rowguid)
	select 
		PDDescription,
		@modifiedDate,
		PDRowguid
	from inserted i;

	insert into Production.ProductModelProductDescriptionCulture (CultureID, ModifiedDate, ProductDescriptionID, ProductModelID)
	select 
		CultureID,
		@modifiedDate,
		ident_current('Production.ProductDescription'),
		ident_current('Production.ProductModel')
	from inserted;
end
go

if exists (select * from sys.objects where [name] = 'trgInsteadU' and [type] = 'tr')
begin
      drop trigger Production.trgInsteadU;
end
go
create trigger trgInsteadU on ProductView
instead of update as
begin
	declare @modifiedDate datetime = getdate();

	update Production.ProductModel set
		CatalogDescription = i.CatalogDescription,
		Instructions = i.Instructions,
		ModifiedDate = @modifiedDate,
		[Name] = i.[Name],
		rowguid = i.rowguid
	from inserted i
	join deleted d
		on d.ProductModelID = i.ProductModelID
	where Production.ProductModel.ProductModelID = d.ProductModelID;

	update Production.Culture set
		ModifiedDate = @modifiedDate,
		[Name] = i.CName
	from inserted i
	join deleted d
		on d.CultureID = i.CultureID
	where Production.Culture.CultureID = d.CultureID;

	update Production.ProductDescription set
		[Description] = i.PDDescription,
		ModifiedDate = @modifiedDate,
		rowguid = i.PDRowguid
	from inserted i
	join deleted d
		on d.ProductDescriptionID = i.ProductDescriptionID
	where Production.ProductDescription.ProductDescriptionID = d.ProductDescriptionID;
end
go

if exists (select * from sys.objects where [name] = 'trgInsteadD' and [type] = 'tr')
begin
      drop trigger Production.trgInsteadD;
end
go
create trigger trgInsteadD on ProductView
instead of delete as
begin
	delete pdmpdc
	from Production.ProductModelProductDescriptionCulture pdmpdc
	join deleted d
		on pdmpdc.CultureID = d.CultureID 
			and pdmpdc.ProductDescriptionID = d.ProductDescriptionID
			and pdmpdc.ProductModelID = d.ProductModelID;

	delete pm
	from deleted d
	left join Production.ProductModelProductDescriptionCulture pmpdc
		on d.ProductModelID = pmpdc.ProductModelID
	join Production.ProductModel pm
		on d.ProductModelID = pm.ProductModelID
	where pmpdc.ProductModelID is null;

	delete c
	from deleted d
	left join Production.ProductModelProductDescriptionCulture pmpdc
		on d.CultureID = pmpdc.CultureID
	join Production.Culture c
		on d.CultureID = c.CultureID
	where pmpdc.CultureID is null;

	delete pd
	from deleted d
	left join Production.ProductModelProductDescriptionCulture pmpdc
		on d.ProductDescriptionID = pmpdc.ProductDescriptionID
	join Production.ProductDescription pd
		on d.ProductDescriptionID = pd.ProductDescriptionID
	where pmpdc.ProductDescriptionID is null;
end
go

--c) --------------------------------------------------------------------------------------------------------------------------------------
select * from Production.ProductModel where ProductModelID = ident_current('Production.ProductModel');
select * from Production.ProductDescription where ProductDescriptionID = ident_current('Production.ProductDescription');
select * from Production.Culture where CultureID = 'el';
select * from Production.ProductModelProductDescriptionCulture where CultureID = 'el';

insert into ProductView (CultureID, CName, [Name], PDDescription, PDRowguid, rowguid)
select
	'el',
	'Elvish',
	'Elven bow',
	'Some elven text here',
	newid(),
	newid();
select * from Production.ProductModel where ProductModelID = ident_current('Production.ProductModel');
select * from Production.ProductDescription where ProductDescriptionID = ident_current('Production.ProductDescription');
select * from Production.Culture where CultureID = 'el';
select * from Production.ProductModelProductDescriptionCulture where CultureID = 'el';

update ProductView set
	[Name] = 'Elven bow with lazer sight',
	PDDescription = 'Some elven text here about useless bow lazers',
	CName = 'New elvish'
where [Name] = 'Elven bow';
select * from Production.ProductModel where ProductModelID = ident_current('Production.ProductModel');
select * from Production.ProductDescription where ProductDescriptionID = ident_current('Production.ProductDescription');
select * from Production.Culture where CultureID = 'el';
select * from Production.ProductModelProductDescriptionCulture where CultureID = 'el';

delete from ProductView
where [Name] = 'Elven bow with lazer sight';
select * from Production.ProductModel where ProductModelID = ident_current('Production.ProductModel');
select * from Production.ProductDescription where ProductDescriptionID = ident_current('Production.ProductDescription');
select * from Production.Culture where CultureID = 'el';
select * from Production.ProductModelProductDescriptionCulture where CultureID = 'el';


use [master]
go