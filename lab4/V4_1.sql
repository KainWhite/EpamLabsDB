use [master]
go

use [AW]
go

--a)
if object_id('Production.ProductModelHst') is not null drop table Production.ProductModelHst;
go
create table Production.ProductModelHst (
	ID int identity(1, 1),
	[Action] nvarchar(10),
	ModifiedDate datetime,
	SourceId int,
	UserName nvarchar(100)
);
go

--b)
if exists (select * from sys.objects where [name] = 'trgIUD' and [type] = 'tr')
begin
      drop trigger Production.trgIUD;
end
go
create trigger trgIUD on Production.ProductModel
after insert, update, delete as
begin
	insert into Production.ProductModelHst ([Action], ModifiedDate, SourceId, UserName)
	select 
		CASE WHEN i.ProductModelID IS NULL THEN 'delete'
			 WHEN d.ProductModelID IS NULL THEN 'insert'
             ELSE 'update'
        END,
		getdate(),
		coalesce(i.ProductModelID, d.ProductModelID),
		system_user --user_name()
	from inserted i full join deleted d on i.ProductModelID = d.ProductModelID;
end
go

--c)
if object_id('ProductModelView') is not null drop view ProductModelView;
go
create view ProductModelView as
select * from Production.ProductModel;
go

--d)
insert into ProductModelView ([Name]) values ('lol');
select * from ProductModelView where [Name] like 'lol';

update ProductModelView set [Name] = 'kek' where [Name] = 'lol';
select * from ProductModelView where [Name] = 'kek';

delete from ProductModelView where [Name] = 'kek';
select * from ProductModelView where [Name] = 'kek';

select * from Production.ProductModelHst;

use [master]
go