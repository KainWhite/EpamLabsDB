use [master]
go

use [AW]
go

-- 1) --------------------------------------------------------------------------------------------------------------------------------------
if object_id('dbo.GetMaxPrice') is not null drop function dbo.GetMaxPrice;
go
create function dbo.GetMaxPrice(@salesOrderId int)
returns money
as 
begin
	declare @maxPrice money;

	select @maxPrice = max(UnitPrice)
	from Sales.SalesOrderDetail
	where SalesOrderID = @salesOrderId;

	return @maxPrice;
end;
go

-- 2), 3) --------------------------------------------------------------------------------------------------------------------------------------
if object_id('dbo.GetProductInventoryARows') is not null drop function dbo.GetProductInventoryARows;
go
create function dbo.GetProductInventoryARows(@productId int, @rowCount int)
returns table
as
	return
	select top (@rowCount) *
	from Production.ProductInventory
	where ProductID = @productId and Shelf = 'A'
	order by Quantity desc;
go

-- 4) --------------------------------------------------------------------------------------------------------------------------------------
select
	p.ProductID,
	LocationID,
	Shelf,
	Bin,
	Quantity,
	*
from Production.Product p
cross apply dbo.GetProductInventoryARows(ProductID, 2);

select
	p.ProductID,
	LocationID,
	Shelf,
	Bin,
	Quantity,
	*
from Production.Product p
outer apply dbo.GetProductInventoryARows(ProductID, 2);
go

-- 5) --------------------------------------------------------------------------------------------------------------------------------------
/*alter function dbo.GetProductInventoryARows(@productId int, @rowCount int) -- doesn't work 'cos of different return type
returns @productInventoryARows table (
	ProductId int,
	LocationId smallint,
	Shelf nvarchar(10),
	Bin tinyint,
	Quantity smallint,
	rowguid uniqueidentifier,
	ModifiedDate datetime)
as
begin
	insert into @productInventoryARows
	select top (@rowCount) *
	from Production.ProductInventory
	where ProductID = @productId and Shelf = 'A'
	order by Quantity desc;

	return;
end;*/
if object_id('dbo.GetProductInventoryARows') is not null drop function dbo.GetProductInventoryARows;
go
create function dbo.GetProductInventoryARows(@productId int, @rowCount int)
returns @productInventoryARows table (
	ProductId int,
	LocationId smallint,
	Shelf nvarchar(10),
	Bin tinyint,
	Quantity smallint,
	rowguid uniqueidentifier,
	ModifiedDate datetime)
as
begin
	insert into @productInventoryARows
	select top (@rowCount) *
	from Production.ProductInventory
	where ProductID = @productId and Shelf = 'A'
	order by Quantity desc;

	return;
end;
go

use [master]
go