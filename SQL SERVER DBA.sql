
--back Up

BACKUP DATABASE [AdventureWorks2012] TO 
DISK = N'C:\Program Files\Microsoft SQL Server\MSSQL15.MSSQLSERVER\MSSQL\Backup\AdventureWorks2012_LogBackup_2023-04-15_04-02-51.bak'
WITH NOFORMAT, NOINIT,  NAME = N'AdventureWorks2012-Full Database Backup', 
SKIP, NOREWIND, NOUNLOAD,  STATS = 10
GO
--Back Up Model   (Full,Differential,Transaction Log)


--Restore Database


USE [master]
BACKUP LOG [AdventureWorks2012]
TO  DISK = N'C:\Program Files\Microsoft SQL Server\MSSQL15.MSSQLSERVER\MSSQL\Backup\AdventureWorks2012_LogBackup_2023-04-18_11-06-54.bak'
WITH NOFORMAT, NOINIT,  NAME = N'AdventureWorks2012_LogBackup_2023-04-18_11-06-54', 
NOSKIP, NOREWIND, NOUNLOAD,  NORECOVERY ,  STATS = 5
RESTORE DATABASE [AdventureWorks2012] 
FROM  DISK = N'C:\Program Files\Microsoft SQL Server\MSSQL15.MSSQLSERVER\MSSQL\Backup\AdventureWorks2012backup3'
WITH  FILE = 1,  NOUNLOAD,  STATS = 5

GO

--Recovery Model   SIMPLE,FULL,BULK LOGGED

USE [master]
GO
ALTER DATABASE [AdventureWorks2012] SET RECOVERY SIMPLE WITH NO_WAIT
GO

USE [master]
GO
ALTER DATABASE [AdventureWorks2012] SET RECOVERY BULK_LOGGED WITH NO_WAIT
GO


--Restore database With Recvery


use master
go
restore database [AdventureWorks2012] with recovery


--Creat Server Rol


USE [AdventureWorks2012]
GO
CREATE ROLE [MYdatabaserol] AUTHORIZATION [SQLTEST]
GO
use [AdventureWorks2012]
GO
DENY SELECT ON [HumanResources].[Employee] TO [MYdatabaserol]
GO
use [AdventureWorks2012]
GO
GRANT SELECT ON [HumanResources].[Department] TO [MYdatabaserol]
GO



USE [AdventureWorks2012]
GO
ALTER ROLE [db_datareader] ADD MEMBER [SQLTEST]
GO


--Creat User

USE [AdventureWorks2012]
GO

/****** Object:  User [SQLTEST]    Script Date: 4/18/2023 11:24:51 AM ******/
CREATE USER [SQLTEST] FOR LOGIN [DESKTOP-UKNILHG\SQLTEST] WITH DEFAULT_SCHEMA=[dbo]
GO



--SET SINGLE USER AND MULTI USER

exec sp_spaceused

ALTER DATABASE [AdventureWorks2012.buckup]SET SINGLE_USER WITH ROLLBACK IMMEDIATE

dbcc checkdb ([AdventureWorks2012.buckup],REPAIR_ALLOW_DATA_LOSS)

ALTER DATABASE [AdventureWorks2012.buckup] SET MULTI_USER




--creat schema

USE [AdventureWorks2012]
GO

/****** Object:  Schema [MYNEWSCHEMA]    Script Date: 4/15/2023 2:06:58 PM ******/
CREATE SCHEMA [MYNEWSCHEMA]
GO



-- Creat Cluster index

USE [AdventureWorks2012]

GO

CREATE CLUSTERED INDEX [ix_table_id] ON [dbo].[Table One]
(
	[ID] ASC

GO




--creat nuncluster index


USE [AdventureWorks2012]

GO

SET ANSI_PADDING ON


GO

CREATE NONCLUSTERED INDEX [ix_one_non] ON [dbo].[Table One]
(
	[ColorName] ASC
)
INCLUDE([Object Name]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF)

GO

--Drop index

USE [AdventureWorks2012]
GO

/****** Object:  Index [ix_one_non]    Script Date: 4/16/2023 12:46:50 AM ******/
DROP INDEX [ix_one_non] ON [dbo].[Table One]
GO


--REORGANIZE AND REBUILD  CONSIDER FRAGMENTATION


USE [AdventureWorks2012]
GO
ALTER INDEX [PK_Address_AddressID] ON [Person].[Address] REORGANIZE  
GO
USE [AdventureWorks2012]
GO
USE [AdventureWorks2012]
GO
ALTER INDEX [PK_Address_AddressID] ON [Person].[Address] REBUILD PARTITION = ALL WITH (ONLINE=ON)
USE [AdventureWorks2012]
GO



SELECT *
FROM SYS.dm_db_index_physical_stats(DB_ID('AdventureWorks2012')
   ,OBJECT_ID(N'[Person].[Address]'),NULL,NULL,NULL) AS state
join sys.indexes as i
on state.object_id=i.object_id and state.index_id=i.index_id 

Freg > 30 REBUILD WITH (ONLINE)
Freg   5-29.99   REORGANIZE

--CREAT FILLFACTOR

USE [AdventureWorks2012]

GO

ALTER INDEX [ix_table_id] ON [dbo].[Table One] REBUILD PARTITION = ALL WITH 
( FILLFACTOR = 80)

GO

--Creat fillter index


USE [AdventureWorks2012]

GO

SET ANSI_PADDING ON


GO

CREATE NONCLUSTERED INDEX [INC_Demo] ON [Person].[Address]
(
	[AddressID] ASC,
	[PostalCode] ASC
)
WHERE City='london'
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF)

GO


--unused index    Disable and Drop


select object_name(u.object_id)as [object name],*
from sys.dm_db_index_usage_stats u
join sys.indexes i
on u.object_id=i.object_id and u.index_id=i.index_id

USE [AdventureWorks2012]
GO
ALTER INDEX [IX_Address_StateProvinceID] ON [Person].[Address] DISABLE
GO


USE [AdventureWorks2012]
GO
/****** Object:  Index [IX_Address_StateProvinceID]    Script Date: 4/16/2023 3:20:21 AM ******/
DROP INDEX [IX_Address_StateProvinceID] ON [Person].[Address]
GO


--Creat statistics 

create statistics  st_Table_One on [dbo].[Table One]([ColorName])


--bULK inserte


create table dbo.FlatFile3
(Headline varchar(50),
Headline1 varchar(50))

Bulk insert [dbo][FlatFile3]
from 'c:\dba\FlatFile3.txt'
with
(FIELDTERMINATOR=',',
ROWTERMINATOR='\N',
FIRSTROW=2
)


--atach and unatach


USE [master]
GO
CREATE DATABASE [AdventureWorks2012.buckup] ON 
( FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL15.MSSQLSERVER\MSSQL\DATA\AdventureWorks2012.buckup.mdf' ),
( FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL15.MSSQLSERVER\MSSQL\DATA\AdventureWorks2012.buckup_log.ldf' )
 FOR ATTACH
GO


USE [master]
GO
EXEC master.dbo.sp_detach_db @dbname = N'AdventureWorks2012.buckup'
GO



--Creat File group

USE [master]
GO
/****** Object:  Database [DBAdatabase]    Script Date: 4/16/2023 12:54:10 PM ******/
CREATE DATABASE [DBAdatabase]
 CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = N'DBAdatabase',
FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL15.MSSQLSERVER\MSSQL\DATA\DBAdatabase.mdf' ,
SIZE = 102400KB , MAXSIZE = UNLIMITED, FILEGROWTH = 65536KB ), 
 FILEGROUP [Secondary]  DEFAULT
( NAME = N'DBAdatabase2',
FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL15.MSSQLSERVER\MSSQL\DATA\DBAdatabase2.ndf' , 
SIZE = 102400KB , MAXSIZE = UNLIMITED, FILEGROWTH = 65536KB ), 
 FILEGROUP [Third] 
( NAME = N'DBAdatabase3', 
FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL15.MSSQLSERVER\MSSQL\DATA\DBAdatabase3.ndf' ,
SIZE = 8192KB , MAXSIZE = UNLIMITED, FILEGROWTH = 65536KB )
 LOG ON 
( NAME = N'DBAdatabase_log', 
FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL15.MSSQLSERVER\MSSQL\DATA\DBAdatabase_log.ldf' , 
SIZE = 69568KB , MAXSIZE = 2048GB , FILEGROWTH = 65536KB )
 WITH CATALOG_COLLATION = DATABASE_DEFAULT
GO

IF (1 = FULLTEXTSERVICEPROPERTY('IsFullTextInstalled'))
begin
EXEC [DBAdatabase].[dbo].[sp_fulltext_database] @action = 'enable'
end
GO


-- Creat Partition function and Partition scheme for Table


USE [DBAdatabase]
GO
BEGIN TRANSACTION
CREATE PARTITION FUNCTION [partitionfunction1](date) AS RANGE LEFT FOR 
VALUES (N'2022-01-01', N'2023-01-01')


CREATE PARTITION SCHEME [partitionschema1] AS PARTITION [partitionfunction1] TO ([PRIMARY]
, [Secondary], [Third])




CREATE CLUSTERED INDEX [ClusteredIndex_on_partitionschema1_638172920459027190] ON [dbo].[tblpartition]
(
	[DateofEntry]
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF) ON [partitionschema1]([DateofEntry])


DROP INDEX [ClusteredIndex_on_partitionschema1_638172920459027190] ON [dbo].[tblpartition]




--view used log space and some of dbcc


select *
from sys.dm_db_log_space_usage

select *
from sys.databases


dbcc shrinkfile([DBAdatabase_log],3)


select * from sys.database_files

dbcc shrinkdatabase (DBAdatabase,20)
dbcc shrinkfile(DBAdatabase,emptyfile)


--Allow sql server to contaied database authentication

EXEC sys.sp_configure N'contained database authentication', N'1'
GO
RECONFIGURE WITH OVERRIDE
GO


USE [master]
GO
ALTER DATABASE [DBAdatabase] SET CONTAINMENT = PARTIAL WITH NO_WAIT
GO


--Data Compression

USE [AdventureWorks2012]
ALTER TABLE [HumanResources].[Employee] REBUILD PARTITION = ALL
WITH
(DATA_COMPRESSION = PAGE
)

--index compression

USE [AdventureWorks2012]
ALTER INDEX [IX_Employee_OrganizationNode] ON [HumanResources].[Employee]
REBUILD PARTITION = ALL WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF,
SORT_IN_TEMPDB = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON,
DATA_COMPRESSION = PAGE)


--ColumnStore Index

USE [DBAdatabase]

GO

CREATE NONCLUSTERED COLUMNSTORE INDEX [NonClusteredColumnStoreIndex-20230417-042911]
ON [dbo].[tbaTable]
(
	[headline1]
)WITH (DROP_EXISTING = OFF, COMPRESSION_DELAY = 0)

GO


--Creat Alert

select * from sysjobsteps

select * from sysjobactivity

select * from sysjobhistory


select * from sys.messages
exec sp_addmessage 50001,16,'i am rasing on alert'




exec sp_who2

select * 
from sys.dm_tran_locks
where resource_database_id=4
 select * 
 from sys.databases

 select *
 from sys.dm_os_waiting_tasks

 select * 
 from sys.dm_exec_requests

 --Trac Flag
 dbcc traceon (1204,-1)
 dbcc traceon (1222,-1)

 --cpu useage

 select * 
 from sys.dm_os_schedulers

 --Buffer pool/Data Cache
 select count(database_id)*8/1224.0 as [cache inn mb],database_id
 from sys.dm_os_buffer_descriptors
 group by database_id

 select * 
 from sys.sysperfinfo
 where object_name like 'SQLServer:Buffer Manager%' 
