declare @texto as nvarchar(4000) = 'BFR_Faturamento'
DECLARE @id int, @db nvarchar(max), @SQL_TXT NVARCHAR(4000)

if OBJECT_ID('tempdb..#tbl') is not null
drop table #tbl

create table #tbl (
dbname nvarchar(120),
scname nvarchar(255),
chname nvarchar(255),
tpname nvarchar(255)
)
--declare @db nvarchar(255), @txt nvarchar(4000)
declare crs cursor for
select name, database_id from sys.databases
where database_id > 4;


open crs

fetch next from crs
into @db, @id

while @@FETCH_STATUS = 0
begin
begin try
SET @SQL_TXT ='use ' + @db + '
insert into #tbl
select ''' + @db + ''' , S.name [SCHEMA],P.name, ''SP'' TIPO
from sys.procedures p
JOIN SYS.schemas S ON P.schema_id = S.schema_id
JOIN SYS.all_sql_modules M ON M.object_id = P.object_id
WHERE M.definition LIKE ''%' + @texto + '%''

union all

select ''' + @db + ''' , S.name [SCHEMA],v.name, ''VIEW'' 
from sys.views v
JOIN SYS.schemas S ON v.schema_id = S.schema_id
JOIN SYS.all_sql_modules M ON M.object_id = v.object_id
WHERE M.definition LIKE ''%' + @texto + '%''

union all

select ''' + @db + ''' , S.name [SCHEMA],t.name, ''TBL'' 
from sys.tables t
JOIN SYS.schemas S ON t.schema_id = S.schema_id
JOIN SYS.all_sql_modules M ON M.object_id = t.object_id
WHERE M.definition LIKE ''%' + @texto + '%''

union all

select ''' + @db + ''' , S.name [SCHEMA], tbl.name + ''.'' + t.name , ''TGR''
from sys.triggers t
join sys.tables tbl on tbl.object_id = t.parent_id
JOIN SYS.schemas S ON tbl.schema_id = S.schema_id
JOIN SYS.all_sql_modules M ON M.object_id = t.object_id
WHERE M.definition LIKE ''%' + @texto + '%''

order by 1, 2, 3'

--SELECT @SQL_TXT

EXEC(@SQL_TXT)

end try
begin catch
	print 'Erro ao acessar o ' + @db + ': ' + ERROR_MESSAGE()
		
end catch
fetch next from crs
into @db, @id
end

close crs
deallocate crs

select * from #tbl;

drop table #tbl
