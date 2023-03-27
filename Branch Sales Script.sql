USE [master]
GO
/****** Object:  Database [BranchSales]    Script Date: 3/27/2023 5:55:39 PM ******/
CREATE DATABASE [BranchSales]
 CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = N'BranchSales', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL15.MSSQLSERVER\MSSQL\DATA\BranchSales.mdf' , SIZE = 8192KB , MAXSIZE = UNLIMITED, FILEGROWTH = 65536KB )
 LOG ON 
( NAME = N'BranchSales_log', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL15.MSSQLSERVER\MSSQL\DATA\BranchSales_log.ldf' , SIZE = 8192KB , MAXSIZE = 2048GB , FILEGROWTH = 65536KB )
 WITH CATALOG_COLLATION = DATABASE_DEFAULT
GO
ALTER DATABASE [BranchSales] SET COMPATIBILITY_LEVEL = 150
GO
IF (1 = FULLTEXTSERVICEPROPERTY('IsFullTextInstalled'))
begin
EXEC [BranchSales].[dbo].[sp_fulltext_database] @action = 'enable'
end
GO
ALTER DATABASE [BranchSales] SET ANSI_NULL_DEFAULT OFF 
GO
ALTER DATABASE [BranchSales] SET ANSI_NULLS OFF 
GO
ALTER DATABASE [BranchSales] SET ANSI_PADDING OFF 
GO
ALTER DATABASE [BranchSales] SET ANSI_WARNINGS OFF 
GO
ALTER DATABASE [BranchSales] SET ARITHABORT OFF 
GO
ALTER DATABASE [BranchSales] SET AUTO_CLOSE OFF 
GO
ALTER DATABASE [BranchSales] SET AUTO_SHRINK OFF 
GO
ALTER DATABASE [BranchSales] SET AUTO_UPDATE_STATISTICS ON 
GO
ALTER DATABASE [BranchSales] SET CURSOR_CLOSE_ON_COMMIT OFF 
GO
ALTER DATABASE [BranchSales] SET CURSOR_DEFAULT  GLOBAL 
GO
ALTER DATABASE [BranchSales] SET CONCAT_NULL_YIELDS_NULL OFF 
GO
ALTER DATABASE [BranchSales] SET NUMERIC_ROUNDABORT OFF 
GO
ALTER DATABASE [BranchSales] SET QUOTED_IDENTIFIER OFF 
GO
ALTER DATABASE [BranchSales] SET RECURSIVE_TRIGGERS OFF 
GO
ALTER DATABASE [BranchSales] SET  ENABLE_BROKER 
GO
ALTER DATABASE [BranchSales] SET AUTO_UPDATE_STATISTICS_ASYNC OFF 
GO
ALTER DATABASE [BranchSales] SET DATE_CORRELATION_OPTIMIZATION OFF 
GO
ALTER DATABASE [BranchSales] SET TRUSTWORTHY OFF 
GO
ALTER DATABASE [BranchSales] SET ALLOW_SNAPSHOT_ISOLATION OFF 
GO
ALTER DATABASE [BranchSales] SET PARAMETERIZATION SIMPLE 
GO
ALTER DATABASE [BranchSales] SET READ_COMMITTED_SNAPSHOT OFF 
GO
ALTER DATABASE [BranchSales] SET HONOR_BROKER_PRIORITY OFF 
GO
ALTER DATABASE [BranchSales] SET RECOVERY FULL 
GO
ALTER DATABASE [BranchSales] SET  MULTI_USER 
GO
ALTER DATABASE [BranchSales] SET PAGE_VERIFY CHECKSUM  
GO
ALTER DATABASE [BranchSales] SET DB_CHAINING OFF 
GO
ALTER DATABASE [BranchSales] SET FILESTREAM( NON_TRANSACTED_ACCESS = OFF ) 
GO
ALTER DATABASE [BranchSales] SET TARGET_RECOVERY_TIME = 60 SECONDS 
GO
ALTER DATABASE [BranchSales] SET DELAYED_DURABILITY = DISABLED 
GO
ALTER DATABASE [BranchSales] SET ACCELERATED_DATABASE_RECOVERY = OFF  
GO
EXEC sys.sp_db_vardecimal_storage_format N'BranchSales', N'ON'
GO
ALTER DATABASE [BranchSales] SET QUERY_STORE = OFF
GO
USE [BranchSales]
GO
/****** Object:  User [Namaa]    Script Date: 3/27/2023 5:55:39 PM ******/
CREATE USER [Namaa] FOR LOGIN [BranchUser] WITH DEFAULT_SCHEMA=[dbo]
GO
/****** Object:  User [BranchSalesNew]    Script Date: 3/27/2023 5:55:39 PM ******/
CREATE USER [BranchSalesNew] FOR LOGIN [BranchSalesNew] WITH DEFAULT_SCHEMA=[dbo]
GO
ALTER ROLE [db_owner] ADD MEMBER [BranchSalesNew]
GO
/****** Object:  UserDefinedFunction [dbo].[FN_IsAchivedTarget]    Script Date: 3/27/2023 5:55:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create function [dbo].[FN_IsAchivedTarget]
(
    @TransactionId int
)
returns bit
as
begin
    declare @BranchId int, @ProductId int,
            @TargetAmount decimal(15,3),@TargetCnt int,
            @Amount decimal(15,3), @Cnt int,@TargetYear char(4),
            @IsAchived bit


   select @BranchId = BranchId, @ProductId = ProductId
    from [Transaction]
    where TransacationID = @TransactionId


   select @TargetAmount = Amount, @TargetCnt = Cnt, @TargetYear = [Year]
    from Target
    where BranchId = @BranchId and ProductId = @ProductId


   select @Amount = sum(Amount),@Cnt = count(*)
    from [Transaction]
    where BranchId = @BranchId and ProductId = @ProductId and StatusId = 2 and year(TrDate) = @TargetYear
    group by BranchId,ProductId


   if @TargetAmount <= @Amount and @TargetCnt <=@Cnt
    begin
        set @IsAchived = 1
    end
    else
    begin
        set @IsAchived = 0
    end

return @IsAchived

end
GO
/****** Object:  Table [dbo].[ArchivedTransaction]    Script Date: 3/27/2023 5:55:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ArchivedTransaction](
	[TransacationID] [int] NOT NULL,
	[Amount] [decimal](10, 3) NULL,
	[BranchID] [int] NULL,
	[ProductID] [int] NULL,
	[UserID] [int] NULL,
	[StatusID] [int] NULL,
	[FlowID] [int] NULL,
	[CustomerID] [int] NULL,
	[TrDate] [datetime] NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Branchs]    Script Date: 3/27/2023 5:55:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Branchs](
	[BranchID] [int] IDENTITY(1,1) NOT NULL,
	[BranchEName] [varchar](50) NOT NULL,
	[BranchAName] [nvarchar](50) NOT NULL,
	[IsActive] [bit] NOT NULL,
 CONSTRAINT [PK_Branchs] PRIMARY KEY CLUSTERED 
(
	[BranchID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Product]    Script Date: 3/27/2023 5:55:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Product](
	[ProductID] [int] IDENTITY(1,1) NOT NULL,
	[ProductEDesc] [varchar](50) NOT NULL,
	[ProductADesc] [nvarchar](50) NOT NULL,
	[IsActive] [bit] NOT NULL,
 CONSTRAINT [PK_Product] PRIMARY KEY CLUSTERED 
(
	[ProductID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Customers]    Script Date: 3/27/2023 5:55:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Customers](
	[CustomerID] [int] IDENTITY(1,1) NOT NULL,
	[CustomerEName] [varchar](50) NOT NULL,
	[CustomerAName] [nvarchar](50) NOT NULL,
	[BranchID] [int] NOT NULL,
	[DOB] [date] NOT NULL,
	[NationalNo] [char](10) NOT NULL,
	[Email] [varchar](50) NULL,
	[PhoneNo] [char](12) NULL,
	[Income] [decimal](10, 3) NULL,
 CONSTRAINT [PK_Customers] PRIMARY KEY CLUSTERED 
(
	[CustomerID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Users]    Script Date: 3/27/2023 5:55:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Users](
	[UserID] [int] IDENTITY(1,1) NOT NULL,
	[UserName] [varchar](50) NOT NULL,
	[UserTypeID] [int] NOT NULL,
	[Passward] [varchar](50) NULL,
	[EfullName] [varchar](50) NOT NULL,
	[AfullName] [nvarchar](50) NOT NULL,
	[IsActive] [bit] NOT NULL,
	[EmployeeID] [int] NOT NULL,
	[BranchID] [int] NULL,
 CONSTRAINT [PK_Users] PRIMARY KEY CLUSTERED 
(
	[UserID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[TransactionFlow]    Script Date: 3/27/2023 5:55:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TransactionFlow](
	[FlowID] [int] IDENTITY(1,1) NOT NULL,
	[DepartmentDesc] [varchar](50) NOT NULL,
	[FlowOrder] [int] NOT NULL,
	[IsActice] [bit] NOT NULL,
 CONSTRAINT [PK_TransactionFlow] PRIMARY KEY CLUSTERED 
(
	[FlowID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Transaction]    Script Date: 3/27/2023 5:55:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Transaction](
	[TransacationID] [int] IDENTITY(1,1) NOT NULL,
	[Amount] [decimal](10, 3) NULL,
	[BranchID] [int] NULL,
	[ProductID] [int] NULL,
	[UserID] [int] NULL,
	[StatusID] [int] NULL,
	[FlowID] [int] NULL,
	[CustomerID] [int] NULL,
	[TrDate] [datetime] NULL,
 CONSTRAINT [PK_Transaction] PRIMARY KEY CLUSTERED 
(
	[TransacationID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Status]    Script Date: 3/27/2023 5:55:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Status](
	[StatusID] [int] IDENTITY(1,1) NOT NULL,
	[StatusDesc] [varchar](50) NOT NULL,
	[IsActive] [bit] NOT NULL,
 CONSTRAINT [PK_Status] PRIMARY KEY CLUSTERED 
(
	[StatusID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [dbo].[AllTransactionViewN]    Script Date: 3/27/2023 5:55:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create view [dbo].[AllTransactionViewN] 
as
 
select 
TransacationID , StatusDesc , Amount , DepartmentDesc ,c.CustomerAName,b.BranchAName , p.ProductADesc ,u.AfullName 			
from [Transaction] tr 								  
inner join Branchs B on b.BranchID=tr.BranchID  	   
inner join Customers C on c.CustomerID= tr.CustomerID 
inner join Product p on p.ProductID =tr.ProductID
inner join Users U on u.UserID= tr.UserID 
inner join TransactionFlow tf on tf.FlowID =tr.FlowID
inner join [Status] S on s.StatusID=tr.StatusID 

union

select 
TransacationID , StatusDesc , Amount , DepartmentDesc ,c.CustomerAName,b.BranchAName , p.ProductADesc ,u.AfullName 

from ArchivedTransaction tt
inner join Branchs B on b.BranchID=tt.BranchID  
inner join Customers C on c.CustomerID= tt.CustomerID 
inner join Product p on p.ProductID =tt.ProductID
inner join Users U on u.UserID= tt.UserID 
inner join TransactionFlow tf on tf.FlowID=tt.FlowID
inner join [Status] S on s.StatusID=tt.StatusID 
GO
/****** Object:  Table [dbo].[ActionType]    Script Date: 3/27/2023 5:55:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ActionType](
	[ActionTypeID] [int] IDENTITY(1,1) NOT NULL,
	[ActionTypeDesc] [varchar](50) NOT NULL,
 CONSTRAINT [PK_ActionType] PRIMARY KEY CLUSTERED 
(
	[ActionTypeID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[ArchivedDecsion]    Script Date: 3/27/2023 5:55:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ArchivedDecsion](
	[DecsionDate] [datetime] NOT NULL,
	[UserID] [int] NULL,
	[StatusID] [int] NULL,
	[FlowID] [int] NULL,
	[TransactionID] [int] NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[AuditTrailLog]    Script Date: 3/27/2023 5:55:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[AuditTrailLog](
	[AuditTrailLogID] [int] IDENTITY(1,1) NOT NULL,
	[TransactionDesc] [varchar](max) NOT NULL,
	[UserID] [int] NOT NULL,
	[TransactionDate] [datetime] NOT NULL,
 CONSTRAINT [PK_AuditTrailLog] PRIMARY KEY CLUSTERED 
(
	[AuditTrailLogID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[CustomerJson]    Script Date: 3/27/2023 5:55:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CustomerJson](
	[CustomerID] [int] NOT NULL,
	[CustomerEName] [varchar](50) NOT NULL,
	[CustomerAName] [nvarchar](50) NOT NULL,
	[BranchID] [int] NOT NULL,
	[DOB] [date] NOT NULL,
	[NationalNo] [char](10) NOT NULL,
	[Email] [varchar](50) NULL,
	[PhoneNo] [char](12) NULL,
	[Income] [decimal](10, 3) NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[DataLog]    Script Date: 3/27/2023 5:55:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DataLog](
	[DataLogID] [int] IDENTITY(1,1) NOT NULL,
	[TableName] [varchar](max) NULL,
	[RowID] [int] NULL,
	[OldValue] [varchar](max) NULL,
	[NewValue] [varchar](max) NULL,
	[ActionDate] [datetime] NULL,
	[ActionBy] [int] NULL,
	[ActionTypeID] [int] NULL,
 CONSTRAINT [PK_DataLog] PRIMARY KEY CLUSTERED 
(
	[DataLogID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Decsion]    Script Date: 3/27/2023 5:55:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Decsion](
	[DecsionDate] [datetime] NOT NULL,
	[UserID] [int] NULL,
	[StatusID] [int] NULL,
	[FlowID] [int] NULL,
	[TransactionID] [int] NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[DeleteDecsion]    Script Date: 3/27/2023 5:55:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DeleteDecsion](
	[DecsionDate] [datetime] NOT NULL,
	[UserID] [int] NULL,
	[StatusID] [int] NULL,
	[FlowID] [int] NULL,
	[TransactionID] [int] NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[DeleteTransaction]    Script Date: 3/27/2023 5:55:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DeleteTransaction](
	[TransacationID] [int] NOT NULL,
	[Amount] [decimal](10, 3) NULL,
	[BranchID] [int] NULL,
	[ProductID] [int] NULL,
	[UserID] [int] NULL,
	[StatusID] [int] NULL,
	[FlowID] [int] NULL,
	[CustomerID] [int] NULL,
	[TrDate] [datetime] NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[ErrorLog]    Script Date: 3/27/2023 5:55:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ErrorLog](
	[ErrorLogID] [int] IDENTITY(1,1) NOT NULL,
	[ErrorMessage] [varchar](max) NULL,
	[ErrorLocation] [varchar](max) NULL,
	[ErrorDate] [datetime] NULL,
	[ErrorUser] [int] NULL,
 CONSTRAINT [PK_ErrorLog] PRIMARY KEY CLUSTERED 
(
	[ErrorLogID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Information]    Script Date: 3/27/2023 5:55:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Information](
	[Name] [varchar](100) NULL,
	[Gender] [varchar](100) NULL,
	[Homeworld] [varchar](100) NULL,
	[Born] [varchar](5) NULL,
	[Jedi] [char](3) NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Target]    Script Date: 3/27/2023 5:55:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Target](
	[Year] [char](4) NOT NULL,
	[ProductID] [int] NOT NULL,
	[BranchID] [int] NOT NULL,
	[Amount] [decimal](10, 3) NOT NULL,
	[CNT] [int] NOT NULL,
	[IsActive] [bit] NOT NULL,
	[IsAchived] [bit] NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[TestIndex]    Script Date: 3/27/2023 5:55:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TestIndex](
	[EmpNo] [int] NULL,
	[EmpName] [varchar](150) NULL
) ON [PRIMARY]
GO
/****** Object:  Index [Test_Index]    Script Date: 3/27/2023 5:55:39 PM ******/
CREATE CLUSTERED INDEX [Test_Index] ON [dbo].[TestIndex]
(
	[EmpNo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[UserType]    Script Date: 3/27/2023 5:55:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[UserType](
	[UserTypeID] [int] IDENTITY(1,1) NOT NULL,
	[TypeDesc] [varchar](50) NULL,
	[IsActive] [bit] NOT NULL,
 CONSTRAINT [PK_UserType] PRIMARY KEY CLUSTERED 
(
	[UserTypeID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Customers]  WITH CHECK ADD  CONSTRAINT [FK_Customers_Branchs] FOREIGN KEY([BranchID])
REFERENCES [dbo].[Branchs] ([BranchID])
GO
ALTER TABLE [dbo].[Customers] CHECK CONSTRAINT [FK_Customers_Branchs]
GO
ALTER TABLE [dbo].[DataLog]  WITH CHECK ADD  CONSTRAINT [FK_DataLog_ActionType] FOREIGN KEY([ActionTypeID])
REFERENCES [dbo].[ActionType] ([ActionTypeID])
GO
ALTER TABLE [dbo].[DataLog] CHECK CONSTRAINT [FK_DataLog_ActionType]
GO
ALTER TABLE [dbo].[Decsion]  WITH CHECK ADD  CONSTRAINT [FK_Decsion_Status] FOREIGN KEY([StatusID])
REFERENCES [dbo].[Status] ([StatusID])
GO
ALTER TABLE [dbo].[Decsion] CHECK CONSTRAINT [FK_Decsion_Status]
GO
ALTER TABLE [dbo].[Decsion]  WITH CHECK ADD  CONSTRAINT [FK_Decsion_Transaction] FOREIGN KEY([TransactionID])
REFERENCES [dbo].[Transaction] ([TransacationID])
GO
ALTER TABLE [dbo].[Decsion] CHECK CONSTRAINT [FK_Decsion_Transaction]
GO
ALTER TABLE [dbo].[Decsion]  WITH CHECK ADD  CONSTRAINT [FK_Decsion_TransactionFlow] FOREIGN KEY([FlowID])
REFERENCES [dbo].[TransactionFlow] ([FlowID])
GO
ALTER TABLE [dbo].[Decsion] CHECK CONSTRAINT [FK_Decsion_TransactionFlow]
GO
ALTER TABLE [dbo].[Decsion]  WITH CHECK ADD  CONSTRAINT [FK_Decsion_Users] FOREIGN KEY([UserID])
REFERENCES [dbo].[Users] ([UserID])
GO
ALTER TABLE [dbo].[Decsion] CHECK CONSTRAINT [FK_Decsion_Users]
GO
ALTER TABLE [dbo].[Target]  WITH CHECK ADD  CONSTRAINT [FK_Target_Branchs] FOREIGN KEY([BranchID])
REFERENCES [dbo].[Branchs] ([BranchID])
GO
ALTER TABLE [dbo].[Target] CHECK CONSTRAINT [FK_Target_Branchs]
GO
ALTER TABLE [dbo].[Target]  WITH CHECK ADD  CONSTRAINT [FK_Target_Product] FOREIGN KEY([ProductID])
REFERENCES [dbo].[Product] ([ProductID])
GO
ALTER TABLE [dbo].[Target] CHECK CONSTRAINT [FK_Target_Product]
GO
ALTER TABLE [dbo].[Transaction]  WITH CHECK ADD  CONSTRAINT [FK_Transaction_Branchs] FOREIGN KEY([BranchID])
REFERENCES [dbo].[Branchs] ([BranchID])
GO
ALTER TABLE [dbo].[Transaction] CHECK CONSTRAINT [FK_Transaction_Branchs]
GO
ALTER TABLE [dbo].[Transaction]  WITH CHECK ADD  CONSTRAINT [FK_Transaction_Customers] FOREIGN KEY([CustomerID])
REFERENCES [dbo].[Customers] ([CustomerID])
GO
ALTER TABLE [dbo].[Transaction] CHECK CONSTRAINT [FK_Transaction_Customers]
GO
ALTER TABLE [dbo].[Transaction]  WITH CHECK ADD  CONSTRAINT [FK_Transaction_Product] FOREIGN KEY([ProductID])
REFERENCES [dbo].[Product] ([ProductID])
GO
ALTER TABLE [dbo].[Transaction] CHECK CONSTRAINT [FK_Transaction_Product]
GO
ALTER TABLE [dbo].[Transaction]  WITH CHECK ADD  CONSTRAINT [FK_Transaction_Status] FOREIGN KEY([StatusID])
REFERENCES [dbo].[Status] ([StatusID])
GO
ALTER TABLE [dbo].[Transaction] CHECK CONSTRAINT [FK_Transaction_Status]
GO
ALTER TABLE [dbo].[Transaction]  WITH CHECK ADD  CONSTRAINT [FK_Transaction_TransactionFlow] FOREIGN KEY([FlowID])
REFERENCES [dbo].[TransactionFlow] ([FlowID])
GO
ALTER TABLE [dbo].[Transaction] CHECK CONSTRAINT [FK_Transaction_TransactionFlow]
GO
ALTER TABLE [dbo].[Transaction]  WITH CHECK ADD  CONSTRAINT [FK_Transaction_Users] FOREIGN KEY([UserID])
REFERENCES [dbo].[Users] ([UserID])
GO
ALTER TABLE [dbo].[Transaction] CHECK CONSTRAINT [FK_Transaction_Users]
GO
ALTER TABLE [dbo].[Users]  WITH CHECK ADD  CONSTRAINT [FK_Users_Branchs] FOREIGN KEY([BranchID])
REFERENCES [dbo].[Branchs] ([BranchID])
GO
ALTER TABLE [dbo].[Users] CHECK CONSTRAINT [FK_Users_Branchs]
GO
ALTER TABLE [dbo].[Users]  WITH CHECK ADD  CONSTRAINT [FK_Users_UserType] FOREIGN KEY([UserTypeID])
REFERENCES [dbo].[UserType] ([UserTypeID])
GO
ALTER TABLE [dbo].[Users] CHECK CONSTRAINT [FK_Users_UserType]
GO
/****** Object:  StoredProcedure [dbo].[PC_BranchCusotmersInformation]    Script Date: 3/27/2023 5:55:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE    procedure [dbo].[PC_BranchCusotmersInformation]
 @LangIndecator char(2) 

 as 
 begin 

 select  b.BranchID ,  
 case when @LangIndecator = 'AR' then c.CustomerAName when @LangIndecator = 'EN' then c.CustomerEName end customername  , 
case when @LangIndecator = 'AR' then b.BranchAName when @LangIndecator = 'EN' then b.BranchEName end BrnachName

 from Branchs b 
inner join Customers c on c.BranchID= b.BranchID


end 
GO
/****** Object:  StoredProcedure [dbo].[PC_BranchCusotmersInformationwithApprovedRequists]    Script Date: 3/27/2023 5:55:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE  procedure [dbo].[PC_BranchCusotmersInformationwithApprovedRequists]
 @LangIndecator char(2)
 as 
 begin 

 select t.TransacationID ,  b.BranchID ,
 case when @LangIndecator = 'AR' then c.CustomerAName when @LangIndecator = 'EN' then c.CustomerEName end customername  , 
case when @LangIndecator = 'AR' then b.BranchAName when @LangIndecator = 'EN' then b.BranchEName end BrnachName ,
case when @LangIndecator = 'AR' then u.AfullName when @LangIndecator = 'EN' then u.EfullName end UserName  

 from [Transaction] t 
left join Customers c on c.CustomerID= t.CustomerID 
left join Branchs b on b.BranchID = t.BranchID
 left  join Users u on u.UserID = t.UserID 

where  t.StatusID = 2  

union 

 select tt.TransacationID ,  b.BranchID ,
 case when @LangIndecator = 'AR' then c.CustomerAName when @LangIndecator = 'EN' then c.CustomerEName end customername  , 
case when @LangIndecator = 'AR' then b.BranchAName when @LangIndecator = 'EN' then b.BranchEName end BrnachName ,
case when @LangIndecator = 'AR' then u.AfullName when @LangIndecator = 'EN' then u.EfullName end UserName  

 from ArchivedTransaction tt
left join Customers c on c.CustomerID= tt.CustomerID 
left join Branchs b on b.BranchID = tt.BranchID
 left  join Users u on u.UserID = tt.UserID 

where  tt.StatusID = 2  


end 
GO
/****** Object:  StoredProcedure [dbo].[PC_BranchCusotmersInformationwithPendingRequists]    Script Date: 3/27/2023 5:55:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE  procedure [dbo].[PC_BranchCusotmersInformationwithPendingRequists]
 @LangIndecator char(2)

 as 
 begin 

 select t.TransacationID ,  b.BranchID , StatusDesc ,
 case when @LangIndecator = 'AR' then c.CustomerAName when @LangIndecator = 'EN' then c.CustomerEName end customername  , 
case when @LangIndecator = 'AR' then b.BranchAName when @LangIndecator = 'EN' then b.BranchEName end BrnachName

 from [Transaction] t 
left join Customers c on c.CustomerID= t.CustomerID 
left join Branchs b on b.BranchID = t.BranchID
left join Status s on s.StatusID = t.StatusID

where  t.StatusID = 1 

end 
GO
/****** Object:  StoredProcedure [dbo].[PC_BranchCusotmersInformationwithrejecteddRequists]    Script Date: 3/27/2023 5:55:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE  procedure [dbo].[PC_BranchCusotmersInformationwithrejecteddRequists]
 @LangIndecator char(2)

 as 
 begin 

 select t.TransacationID ,  b.BranchID ,
 case when @LangIndecator = 'AR' then c.CustomerAName when @LangIndecator = 'EN' then c.CustomerEName end customername  , 
case when @LangIndecator = 'AR' then b.BranchAName when @LangIndecator = 'EN' then b.BranchEName end BrnachName ,
case when @LangIndecator = 'AR' then u.AfullName when @LangIndecator = 'EN' then u.EfullName end UserName  

 from [Transaction] t 
inner join Customers c on c.CustomerID= t.CustomerID 
inner join Branchs b on b.BranchID = t.BranchID
 inner join Decsion d on d.TransactionID=t.TransacationID  and d.StatusID=3
 inner join Users u on u.UserID= d.UserID
 
  union 

  select tt.TransacationID ,  b.BranchID ,
 case when @LangIndecator = 'AR' then c.CustomerAName when @LangIndecator = 'EN' then c.CustomerEName end customername  , 
case when @LangIndecator = 'AR' then b.BranchAName when @LangIndecator = 'EN' then b.BranchEName end BrnachName ,
case when @LangIndecator = 'AR' then u.AfullName when @LangIndecator = 'EN' then u.EfullName end UserName  

 from ArchivedTransaction tt 
inner join Customers c on c.CustomerID= tt.CustomerID 
inner join Branchs b on b.BranchID = tt.BranchID
 inner join ArchivedDecsion d on d.TransactionID=tt.TransacationID  and d.StatusID=3
 inner join Users u on u.UserID= d.UserID 
end 
GO
/****** Object:  StoredProcedure [dbo].[PC_GetCustomerInfromation]    Script Date: 3/27/2023 5:55:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[PC_GetCustomerInfromation]  
 @LangIndecator char(2)  

 as 
 begin 

 select  c.CustomerID , dob , NationalNo , Email, PhoneNo, Income ,
 case when @LangIndecator = 'AR' then c.CustomerAName when @LangIndecator = 'EN' then c.CustomerEName end customername  , 
case when @LangIndecator = 'AR' then b.BranchAName when @LangIndecator = 'EN' then b.BranchEName end BrnachName 
 
 from Customers  c
 inner join Branchs b on b.BranchID =c.BranchID 

 end 
GO
/****** Object:  StoredProcedure [dbo].[PC_GetCustomerInfromationWithApprovedLoans]    Script Date: 3/27/2023 5:55:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure  [dbo].[PC_GetCustomerInfromationWithApprovedLoans]  
 @LangIndecator char(2) 
 as 
 begin 

 select  c.CustomerID , dob , NationalNo , Email, PhoneNo, Income , StatusDesc , 
 case when @LangIndecator = 'AR' then c.CustomerAName when @LangIndecator = 'EN' then c.CustomerEName end customername  , 
case when @LangIndecator = 'AR' then b.BranchAName when @LangIndecator = 'EN' then b.BranchEName end BrnachName ,
case when @LangIndecator = 'AR' then u.AfullName when @LangIndecator = 'EN' then u.EfullName end Approvedby    

 from Customers c 
 inner join Branchs b on b.BranchID = c.BranchID
 inner join [Transaction] t on c.CustomerID = t.CustomerID and StatusID = 2 
 inner join Users u on u.UserID = t.UserID 
 inner join Status s on s.StatusID= t.StatusID

 end 
GO
/****** Object:  StoredProcedure [dbo].[PC_GetCustomerInfromationWithPendingRequist]    Script Date: 3/27/2023 5:55:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE  procedure [dbo].[PC_GetCustomerInfromationWithPendingRequist] 
 @LangIndecator char(2) 
 as 
 begin 

 select  c.CustomerID , dob , NationalNo , Email, PhoneNo, Income , 
 case when @LangIndecator = 'AR' then c.CustomerAName when @LangIndecator = 'EN' then c.CustomerEName end customername  , 
case when @LangIndecator = 'AR' then b.BranchAName when @LangIndecator = 'EN' then b.BranchEName end BrnachName ,
case when @LangIndecator = 'AR' then u.AfullName when @LangIndecator = 'EN' then u.EfullName end UserName  

 from Customers c 
 inner join [Transaction] t on c.CustomerID = t.CustomerID  and StatusID = 1 
 inner join Branchs b on b.BranchID = c.BranchID
 inner join Users u on u.UserID = t.UserID 

 end 
GO
/****** Object:  StoredProcedure [dbo].[PC_GetCustomerInfromationWithRejectdLoans]    Script Date: 3/27/2023 5:55:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   procedure [dbo].[PC_GetCustomerInfromationWithRejectdLoans]  
 @LangIndecator char(2) 
 as 
 begin 

 select TransacationID , dob , NationalNo , Email, PhoneNo, Income ,
 case when @LangIndecator = 'AR' then c.CustomerAName when @LangIndecator = 'EN' then c.CustomerEName end customername  , 
case when @LangIndecator = 'AR' then b.BranchAName when @LangIndecator = 'EN' then b.BranchEName end BrnachName ,
case when @LangIndecator = 'AR' then u.AfullName when @LangIndecator = 'EN' then u.EfullName end Rejectedby  

 from Customers c 
 inner join [Transaction] t on c.CustomerID = t.CustomerID 
 inner join Branchs b on b.BranchID = c.BranchID
 inner join Decsion d on d.TransactionID=t.TransacationID and d.StatusID  = 3 
  inner join Users u on u.UserID= d.UserID


 end 
GO
/****** Object:  StoredProcedure [dbo].[pc_InsertNewUsers]    Script Date: 3/27/2023 5:55:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[pc_InsertNewUsers]

@EFullName varchar(500),
@AFullName nvarchar(500),
@UserName varchar(50),
@Passward varchar(50),
@BranchId int,
@usertypeid int,
@EmployeeId int,
@UserId int,
@ErrorMessage varchar(max)
as 
begin 
begin transaction 
begin try
    insert into users 
    ( username , usertypeid , passward , efullname, afullname , isactive , employeeid , branchid) 
     values 
    ( @username , @usertypeid , @passward, @Efullname ,@Afullname,  1 , @employeeid, @branchid ) 

    insert into DataLog
    (TableName,RowId,OldValue,NewValue,ActionDate,ActionTypeID,ActionBy)
    values
    ('Users',IDENT_CURRENT('users'),'',
    'username: '+@username+' ,usertypeid: '+cast (@usertypeid as varchar ) +' ,passward: '+@passward+' ,efullname: '+@efullname+
    ' ,afullname: '+@afullname  + ',employeeid:' +cast (@employeeid as varchar ) + ',branchid:'+cast (@branchid as varchar(50) ) ,
	getdate(), 1, @userid )

insert into AuditTrailLog
	( TransactionDesc, TransactionDate, UserID)
	values 
	(' insert new user with id  : ' +cast ( IDENT_CURRENT ( 'users' ) as varchar(5) ) , GETDATE() , @UserId )

commit transaction 
end try 
  begin catch 
  rollback ; 

   insert into ErrorLog 
	   ( ErrorMessage,ErrorLocation,ErrorDate,ErrorUser ) 
	   values 
	   ( ERROR_MESSAGE() , ERROR_PROCEDURE()  , GETDATE() , @UserId) 
	   
	   set @ErrorMessage= ERROR_MESSAGE () ; 

  end catch 

end 
GO
/****** Object:  StoredProcedure [dbo].[PC_InsertTransactionByBrnachEMP]    Script Date: 3/27/2023 5:55:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[PC_InsertTransactionByBrnachEMP]

@BranchID  int ,
@CustomerID int ,
@ProductID int , 
@Amount  decimal (10,3) ,
@UserID int , 
@ErrorMessage varchar (max) out 

as 
begin 
begin transaction 
begin try

  declare @flowid int 
  select  top 1 @flowid=FlowID
  from TransactionFlow 
  order by FlowOrder 


insert into  [Transaction] 
( Amount,BranchID,ProductID,UserID,StatusID,FlowID,CustomerID, TrDate ) 
values 
( @Amount, @BranchID, @ProductID ,@UserID, 1, 1, @CustomerID , getdate() )

insert into DataLog
 (TableName,RowId,OldValue,NewValue,ActionDate,ActionTypeID,ActionBy)
 values 
 ( 'Transaction' , IDENT_CURRENT ( 'Transaction' ) , ' ' , 
 'Amount:' +cast( @Amount as varchar(50) )  + ',BranchID:' + cast( @BranchID as varchar(50) )  + ',ProductID:' +cast ( @ProductID as varchar(50) )  + ',UserID:' + cast( @UserID as varchar(50) ) +  ',FlowID:' + cast( @FlowID as varchar(50) ) +',CustomerID:' +cast( @CustomerID as varchar(50) )    , 
  getdate() ,1 , @UserID )


  insert into AuditTrailLog
  (TransactionDesc, UserID , TransactionDate) 
  values 
  ( 'Insert a new Transaction with id :' +  cast ( IDENT_CURRENT ( 'Transaction' ) as varchar (50)) , @UserID , getdate() ) 

  commit transaction 
  end try 
   begin catch 
      rollback ; 
	    insert into ErrorLog 
	   ( ErrorMessage,ErrorLocation,ErrorDate,ErrorUser ) 
	   values 
	   ( ERROR_MESSAGE() , ERROR_PROCEDURE()  , GETDATE() , @UserId) 
	    set @ErrorMessage= ERROR_MESSAGE () ; 
        end catch 
end 
GO
/****** Object:  StoredProcedure [dbo].[pc_UpdateCustomerInfrom]    Script Date: 3/27/2023 5:55:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[pc_UpdateCustomerInfrom] 

@Email varchar(50),
@PhoneNo char(12),
@BranchId int,
@Income decimal(15,3) ,
@customerid int ,
@userid int ,
@ErrorMessage  varchar(max) out 

as 
begin 

begin transaction 
begin try 

    insert into DataLog
    (TableName,RowId,OldValue,NewValue,ActionDate,ActionTypeID,ActionBy)
    select 
    'Customers',@customerid,
	'Email: '+Email+' ,PhoneNumber: '+PhoneNo + ',branchud:' + cast (BranchId as varchar(5) )+',Income:'+cast(Income as varchar(15)),
   'Email: '+@Email+' ,PhoneNumber: '+@PhoneNo + ',branchud:' + cast (@BranchId as varchar(5) ) +',Income:'+cast(@Income as varchar(15)),
    GETDATE(),2,@UserId
	from Customers
	where customerid=@customerid

update Customers
set Email= @email , 
    PhoneNo = @PhoneNo  ,
	BranchID =  @branchid  ,
	Income =  @Income 

where  CustomerID= @customerid 

	insert into AuditTrailLog
	( TransactionDesc, TransactionDate, UserID)
	values 
	(' update new customers with id  : ' +cast (@customerid as varchar(50)) , GETDATE() , @UserId )

commit transaction 
end try 
	
	begin catch 
	rollback ; 
   insert into ErrorLog 
	   ( ErrorMessage,ErrorLocation,ErrorDate,ErrorUser ) 
	   values 
	   ( ERROR_MESSAGE() , ERROR_PROCEDURE()  , GETDATE() , @UserId) 
	   
	   set @ErrorMessage= ERROR_MESSAGE () ; 

	end catch 
end 
GO
/****** Object:  StoredProcedure [dbo].[SP_Achivemnt]    Script Date: 3/27/2023 5:55:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[SP_Achivemnt]
as
begin

 declare  @ISamountachived bit , 
 @ISCNTachived bit , 
  @TargetAmount decimal(15,3),
  @TargetCnt int, @Amount decimal(15,3), @Cnt int , @BranchId int, @ProductId int, @TargetYear char(4)

  select @BranchId = BranchId, @ProductId = ProductId
    from [Transaction]
   

   select @TargetAmount = Amount, @TargetCnt = Cnt, @TargetYear = [Year]
    from Target
    where BranchId = @BranchId and ProductId = @ProductId


   select @Amount = sum(Amount),@Cnt = count(*)
    from [Transaction]
    where BranchId = @BranchId and ProductId = @ProductId and StatusId = 2 and year(TrDate) = @TargetYear
    group by BranchId,ProductId



	   if @TargetAmount<= @Amount --and @TargetCnt <=@Cnt
    begin
        set @ISamountachived = 1
    end
    else
    begin
        set @ISamountachived = 0
    end

	 if @TargetCnt<= @Amount --and @TargetCnt <=@Cnt
    begin
        set @ISCNTachived = 1
    end
    else
    begin
        set @ISCNTachived = 0
    end

end
GO
/****** Object:  StoredProcedure [dbo].[SP_ArchiveDecisionDataN]    Script Date: 3/27/2023 5:55:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
Create Procedure [dbo].[SP_ArchiveDecisionDataN]
as
begin

    
    begin transaction
        begin try
           
           insert into ArchivedDecsion
            select   DecsionDate, d.UserID, d.StatusID, d.FlowID, TransactionID
            from Decsion d
            inner join [Transaction] tr on tr.TransacationID =d.TransactionId
            where tr.StatusId in (2,3)
        

           delete from Decsion
            where TransactionId in (select TransactionID from [Transaction] where StatusId in (2,3))

           -- insert into Audit trail log
            insert into AuditTrailLog
            (TransactionDesc,TransactionDate,UserID)
            select
            'Archive FlowDecision TransactionId= '+cast(TransacationID as nvarchar), GETDATE(),0
            from [Transaction]
            where StatusId in (2,3)


           commit transaction
        end try
        begin catch

           rollback transaction

           insert into ErrorLog
            (ErrorLocation,ErrorMessage,ErrorDate,ErrorUser)
            values
            (ERROR_PROCEDURE(),ERROR_MESSAGE(),GETDATE(),0)

       end catch

end
GO
/****** Object:  StoredProcedure [dbo].[SP_ArchiveTransactionDataN]    Script Date: 3/27/2023 5:55:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure  [dbo].[SP_ArchiveTransactionDataN]
as
begin


   begin transaction
        begin try

           -- insert into data log
            insert into DataLog
            (TableName,RowID,ActionBy,ActionDate,ActionTypeID)
            select 'Transaction',TransacationID,
            0,GETDATE(),4
            from [Transaction]
            where StatusId in (2,3)

            insert into ArchivedTransaction
          ( TransacationID, Amount, BranchID, ProductID,UserID , StatusID,FlowID,CustomerID , TrDate )
          select  TransacationID, Amount, BranchID, ProductID,UserID , StatusID,FlowID,CustomerID , TrDate
           from [transaction]
           where StatusID in (2,3) 

           delete from [transaction]
            where StatusId in (2,3)

           -- insert into Audit trail log
            insert into AuditTrailLog
            (TransactionDesc,TransactionDate,UserID)             
            select 'Archive Transaction ID= '+cast(TransacationID as nvarchar), GETDATE(),0
          from [transaction]
            where StatusId in (2,3)

           commit transaction
        end try
        begin catch

           rollback transaction
           insert into ErrorLog
            (ErrorLocation,ErrorMessage,ErrorDate,ErrorUser)
            values
            (ERROR_PROCEDURE(),ERROR_MESSAGE(),GETDATE(),0)

       end catch
end
GO
/****** Object:  StoredProcedure [dbo].[SP_BrnachEmpDecsion]    Script Date: 3/27/2023 5:55:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[SP_BrnachEmpDecsion] 

@statusID int ,
@UserID int , 
@TransactionID int , 
@ErrorMessage varchar(max) out 

as
begin 
  begin transaction 
  begin try 
  declare  @nextstep int ,
           @currentstep int 

  select  top 1 @nextstep= FlowID
  from TransactionFlow
  where FlowOrder > ( select FlowOrder from TransactionFlow  where  FlowID= ( select FlowID from [Transaction] where  TransacationID=@TransactionID ))  
   and IsActice = 1 
   order by FlowOrder 

   select @currentstep=FlowID
   from [Transaction] 
   where  TransacationID=@TransactionID
  
  if @statusID = 2 
  begin 

   insert into Decsion
   (DecsionDate,UserID,StatusID,FlowID,TransactionID) 
   values 
   ( getdate() , @UserID, @statusID, @currentstep, @TransactionID ) 

   insert into DataLog
  (TableName,RowId,OldValue,NewValue,ActionDate,ActionTypeID,ActionBy)
  values 
  ( 'transaction' , @TransactionID , 'Flowid:' +  cast (@currentstep as varchar (5) ) , ',Flowid:' + cast( @nextstep  as varchar(5) ) , getdate() , 2 , @UserID)

    update [Transaction]
  set flowid = @nextstep
   where TransacationID= @TransactionID

   insert into AuditTrailLog 
     (TransactionDesc, UserID , TransactionDate) 
  values 
  ( 'the transcation with id  :' +  cast (@TransactionID as varchar (50))+ ' approved by employee '  , @UserID , getdate() ) 

 end 

 else if @statusID = 3
 begin 


   insert into Decsion
   (DecsionDate,UserID,StatusID,FlowID,TransactionID) 
   values 
   ( getdate() , @UserID, @statusID, @currentstep, @TransactionID ) 

   insert into DataLog
  (TableName,RowId,OldValue,NewValue,ActionDate,ActionTypeID,ActionBy)
select 
 'transaction' , @TransactionID , ',statusid:' + cast( statusID as varchar(5) ) , ',statusid:' + cast( @statusID as varchar(5) ) , getdate() , 2 , @UserID 
  from  [transaction] 
  where TransacationID= @TransactionID

    update [Transaction]
  set StatusID= @statusID 
   where TransacationID= @TransactionID

   insert into AuditTrailLog 
     (TransactionDesc, UserID , TransactionDate) 
  values 
  ( 'the transcation with id  :' +  cast (@TransactionID as varchar (50))+ ' rejected by employee '  , @UserID , getdate() ) 

 end 


  commit transaction 
  end try 
   begin catch 
      rollback ; 
	    insert into ErrorLog 
	   ( ErrorMessage,ErrorLocation,ErrorDate,ErrorUser ) 
	   values 
	   ( ERROR_MESSAGE() , ERROR_PROCEDURE()  , GETDATE() , @UserId) 
	    set @ErrorMessage= ERROR_MESSAGE () ; 
        end catch 
end 

GO
/****** Object:  StoredProcedure [dbo].[SP_DeleteTransaction]    Script Date: 3/27/2023 5:55:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
Create procedure [dbo].[SP_DeleteTransaction] 
@transactionid int ,
@userid int ,
@errormessage varchar(max) out 
as 
begin 
begin transaction 
begin try

insert into DeleteTransaction 
select TransacationID, Amount,BranchID, ProductID, UserID, StatusID, FlowID, CustomerID, TrDate
from [Transaction]
where TransacationID = @transactionID 

insert into DeleteDecsion 
select  DecsionDate,UserID, StatusID, FlowID, TransactionID 
from Decsion
where TransactionID = @transactionID 

insert into DataLog
 (TableName,RowId,OldValue,NewValue,ActionDate,ActionTypeID,ActionBy)
 values 
 ('transaction '  , @transactionid ,'' ,'',GETDATE() ,3 , @userid )


 insert into DataLog
 (TableName,RowId,OldValue,NewValue,ActionDate,ActionTypeID,ActionBy)
 values
 ('Decsion '  , @transactionid ,'' , '',
 GETDATE() ,3, @userid )


  insert into AuditTrailLog
  (TransactionDesc, UserID , TransactionDate) 
  values 
  ( 'delete a  Transaction with id :' +  cast ( @transactionid as varchar (50)) , @UserID , getdate() ) 



delete  from [Transaction] 
where TransacationID= @transactionID 

delete  from Decsion 
where TransactionID= @transactionID 

commit transaction 
end try 
     begin catch 
      rollback ; 
	    insert into ErrorLog 
	   ( ErrorMessage,ErrorLocation,ErrorDate,ErrorUser ) 
	   values 
	   ( ERROR_MESSAGE() , ERROR_PROCEDURE()  , GETDATE() , @UserId) 
	    set @ErrorMessage= ERROR_MESSAGE () ; 
        end catch 
end  
GO
/****** Object:  StoredProcedure [dbo].[SP_GetAllStepsInform]    Script Date: 3/27/2023 5:55:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[SP_GetAllStepsInform]

@transactionID int 

as
begin 
select TransacationID , c.CustomerEName, t.Amount, DepartmentDesc , StatusDesc , u.UserName
from [Transaction] t
inner join Decsion d on d.TransactionID=t.TransacationID 
inner  join TransactionFlow tf on tf.FlowID=d.FlowID
inner join Customers c on c.CustomerID=t.CustomerID
inner  join Status s on s.StatusID=d.StatusID 
inner join Users u on u.UserID=d.UserID
where TransacationID= @transactionID
 union 

select TransacationID , c.CustomerEName, t.Amount, DepartmentDesc , StatusDesc , u.UserName
from [Transaction] t
inner  join TransactionFlow tf on tf.FlowID=t.FlowID
inner join Customers c on c.CustomerID=t.CustomerID
inner  join Status s on s.StatusID=t.StatusID 
inner join Users u on u.UserID=t.UserID

where TransacationID= @transactionID

end
GO
/****** Object:  StoredProcedure [dbo].[SP_GetAllTransactionInfrom]    Script Date: 3/27/2023 5:55:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[SP_GetAllTransactionInfrom]

@LangIndecator char(2) 
as 
begin 
  
select 
case when @LangIndecator = 'AR' then c.CustomerAName when @LangIndecator = 'EN' then c.CustomerEName end customername  , 
case when @LangIndecator = 'AR' then b.BranchAName when @LangIndecator = 'EN' then b.BranchEName end BrnachName ,
case when @LangIndecator = 'AR' then p.ProductADesc when @LangIndecator = 'EN' then p.ProductEDesc end ProdectName ,
case when @LangIndecator = 'AR' then u.AfullName when @LangIndecator = 'EN' then u.EfullName end UserName  ,
TransacationID , StatusDesc, departmentdesc , Amount

from [Transaction] tr 
inner join Branchs B on b.BranchID=tr.BranchID  
inner join Customers C on c.CustomerID= tr.CustomerID 
inner join Product p on p.ProductID =tr.ProductID
inner join Users U on u.UserID= tr.UserID 
inner join TransactionFlow tf on tf.FlowID=tr.FlowID 
inner join [Status] S on s.StatusID=tr.StatusID 


end 
GO
/****** Object:  StoredProcedure [dbo].[SP_GetBestSalesProduct]    Script Date: 3/27/2023 5:55:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[SP_GetBestSalesProduct]
as
begin

    select  ProductEDesc,count(*) Cnt
    from Product P
    inner join [Transaction] T on P.ProductID = t.ProductId
    where t.StatusId = 2    
    group by ProductEDesc
    having count(*) = (select top 1 count(*) from [Transaction]
                        where StatusId = 2 group by ProductID order by 1 desc)
    order by 2 desc

end
GO
/****** Object:  StoredProcedure [dbo].[sp_GetTheAchivment]    Script Date: 3/27/2023 5:55:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[sp_GetTheAchivment]
	as
	begin

	select BranchEName , ProductEDesc , 
	case when tbl.targetamount <= tbl.amounti  then ' amountachived'  else ' amountnotachived'   end achivedamount , 
    case when tbl.targetcnt <= tbl.cnti  then ' countachived' else ' acount notachived'  end achivedcount   
	from 
	(
	select BranchEName , ProductEDesc  , sum (amount) amounti , count(*) cnti , 
	 (select amount from [Target] where BranchID= t.BranchID and ProductID= t.ProductID and [Year]= year (getdate ())) targetamount ,
	( select  CNT from [Target] where BranchID= t.BranchID and ProductID= t.ProductID and [Year]= year (getdate ()) ) targetcnt 

	from [Transaction] t 
	inner join Branchs b on b.BranchID=t.BranchID  
	inner join Product p on p.ProductID = t.ProductID
	where  StatusID= 2 
	group by  BranchEName , ProductEDesc , t.BranchID, t.ProductID) tbl 

	end 
GO
/****** Object:  StoredProcedure [dbo].[sp_GetTheAchivmentgab]    Script Date: 3/27/2023 5:55:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[sp_GetTheAchivmentgab]
 as
 begin
	   
	   select BranchEName , ProductEDesc , case when tbl.targetamount <= tbl.amounti  then 0  else tbl.targetamount- tbl.amounti  end untilachivedamount , 
	                                       case when tbl.targetcnt   <= tbl.cnti     then 0   else tbl.targetcnt -  tbl.cnti  end untilachivedcount   
	from 
	(
	select BranchEName , ProductEDesc  , sum (amount) amounti , count(*) cnti  , (select sum (amount ) from [Target] where BranchID= 1 and ProductID= 1) targetamount , ( select sum (CNT ) from [Target] where BranchID= 1 and ProductID= 1 ) targetcnt 
	from [Transaction] t 
	inner join Branchs b on b.BranchID=t.BranchID  
	inner join Product p on p.ProductID = t.ProductID
	where t.BranchID = 1
	and t.ProductID = 1 
	and StatusID= 2 
	group by  BranchEName , ProductEDesc) tbl 

	end
GO
/****** Object:  StoredProcedure [dbo].[SP_GetTransactionNew]    Script Date: 3/27/2023 5:55:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[SP_GetTransactionNew]

@LangIndecator char(2) 
as 
begin 
  
select 
case when @LangIndecator = 'AR' then c.CustomerAName when @LangIndecator = 'EN' then c.CustomerEName end customername  , 
case when @LangIndecator = 'AR' then b.BranchAName when @LangIndecator = 'EN' then b.BranchEName end BrnachName ,
case when @LangIndecator = 'AR' then p.ProductADesc when @LangIndecator = 'EN' then p.ProductEDesc end ProdectName ,
case when @LangIndecator = 'AR' then u.AfullName when @LangIndecator = 'EN' then u.EfullName end UserName  ,
TransacationID , StatusDesc , Amount , DepartmentDesc

from [Transaction] tr 
inner join Branchs B on b.BranchID=tr.BranchID  
inner join Customers C on c.CustomerID= tr.CustomerID 
inner join Product p on p.ProductID =tr.ProductID
inner join Users U on u.UserID= tr.UserID 
inner join TransactionFlow tf on tf.FlowID =tr.FlowID
inner join [Status] S on s.StatusID=tr.StatusID 

union

select 
case when @LangIndecator = 'AR' then c.CustomerAName when @LangIndecator = 'EN' then c.CustomerEName end customername  , 
case when @LangIndecator = 'AR' then b.BranchAName when @LangIndecator = 'EN' then b.BranchEName end BrnachName ,
case when @LangIndecator = 'AR' then p.ProductADesc when @LangIndecator = 'EN' then p.ProductEDesc end ProdectName ,
case when @LangIndecator = 'AR' then u.AfullName when @LangIndecator = 'EN' then u.EfullName end UserName  ,
TransacationID , StatusDesc , Amount  , DepartmentDesc

from ArchivedTransaction tt
inner join Branchs B on b.BranchID=tt.BranchID  
inner join Customers C on c.CustomerID= tt.CustomerID 
inner join Product p on p.ProductID =tt.ProductID
inner join Users U on u.UserID= tt.UserID 
inner join TransactionFlow tf on tf.FlowID=tt.FlowID
inner join [Status] S on s.StatusID=tt.StatusID 


end 
GO
/****** Object:  StoredProcedure [dbo].[SP_GetTransactionNewbyID]    Script Date: 3/27/2023 5:55:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[SP_GetTransactionNewbyID]
@TransacationID int , 
@LangIndecator char(2) 
as 
begin 
  
select 
case when @LangIndecator = 'AR' then c.CustomerAName when @LangIndecator = 'EN' then c.CustomerEName end customername  , 
case when @LangIndecator = 'AR' then b.BranchAName when @LangIndecator = 'EN' then b.BranchEName end BrnachName ,
case when @LangIndecator = 'AR' then p.ProductADesc when @LangIndecator = 'EN' then p.ProductEDesc end ProdectName ,
case when @LangIndecator = 'AR' then u.AfullName when @LangIndecator = 'EN' then u.EfullName end UserName  ,
TransacationID , StatusDesc , Amount , DepartmentDesc

from [Transaction] tr 
inner join Branchs B on b.BranchID=tr.BranchID  
inner join Customers C on c.CustomerID= tr.CustomerID 
inner join Product p on p.ProductID =tr.ProductID
inner join Users U on u.UserID= tr.UserID 
inner join TransactionFlow tf on tf.FlowID =tr.FlowID
inner join [Status] S on s.StatusID=tr.StatusID
where TransacationID = @TransacationID
union

select 
case when @LangIndecator = 'AR' then c.CustomerAName when @LangIndecator = 'EN' then c.CustomerEName end customername  , 
case when @LangIndecator = 'AR' then b.BranchAName when @LangIndecator = 'EN' then b.BranchEName end BrnachName ,
case when @LangIndecator = 'AR' then p.ProductADesc when @LangIndecator = 'EN' then p.ProductEDesc end ProdectName ,
case when @LangIndecator = 'AR' then u.AfullName when @LangIndecator = 'EN' then u.EfullName end UserName  ,
TransacationID , StatusDesc , Amount  , DepartmentDesc

from ArchivedTransaction tt
inner join Branchs B on b.BranchID=tt.BranchID  
inner join Customers C on c.CustomerID= tt.CustomerID 
inner join Product p on p.ProductID =tt.ProductID
inner join Users U on u.UserID= tt.UserID 
inner join TransactionFlow tf on tf.FlowID=tt.FlowID
inner join [Status] S on s.StatusID=tt.StatusID 
where TransacationID = @TransacationID

end 
GO
/****** Object:  StoredProcedure [dbo].[SP_Highest2branchsales]    Script Date: 3/27/2023 5:55:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[SP_Highest2branchsales]
as
begin

    select BranchEName,count(*) Cnt
    from [Transaction] T
    inner join Branchs b on b.BranchID = t.BranchID
    where t.StatusId = 2    
    group by BranchEName
    having count(*) in (select top 2 count(*) from [Transaction]
                       where StatusId = 2 group by BranchID order by 1 desc)
end
GO
/****** Object:  StoredProcedure [dbo].[SP_InsertCustomersByJSON]    Script Date: 3/27/2023 5:55:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[SP_InsertCustomersByJSON]
@json nvarchar(max),
@userid int,
@errormessage varchar(max)
as 
begin 
       begin transaction 
	   begin try

	     insert into customerjson
		 (customerId,customerEname,branchId,customerAname,DOB,NationalNO,Email,phoneNO,Income)
		 select customerId,customerEname,branchId,customerAname,cast(DOB as date),NationalNO,Email,phoneNO,Income
		 from openjson (@json)
		 with (customerId int ,customerEname varchar(200),BRANCHID int,customerAname nvarchar(200),DOB varchar(50),
		NationalNo varchar(50),Email varchar(100),PhoneNo varchar(100),Income Decimal (15,3))

		 COMMIT TRANSACTION;
		 END TRY 
		 BEGIN CATCH
		 ROLLBACK;
		      insert into ErrorLog
		(ErrorMessage,ErrorLocation,ErrorDate,ErrorUser)
		values
		(ERROR_MESSAGE(),ERROR_PROCEDURE(),getdate(),@UserId)
		set @errormessage=ERROR_MESSAGE();
		end catch
		END 

	
GO
/****** Object:  StoredProcedure [dbo].[SP_InsertNewCusotmer]    Script Date: 3/27/2023 5:55:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE  procedure  [dbo].[SP_InsertNewCusotmer]
@AName nvarchar(50),
@EName varchar(50),
@Email varchar(50),
@PhoneNo char(12),
@BrachId int,
@DOB date,
@NationalNo char(10),
@Income decimal(15,3),
@UserId int ,
@ErrorMessage varchar(100)  out 
as
begin
 begin transaction 
 begin try 

    insert into Customers
    (CustomerAName,CustomerEName,BranchID,dob,NationalNo,Email,PhoneNo,Income)
    values
    (@AName,@EName,@BrachId,@DOB,@NationalNo,@Email,@PhoneNo,@Income)

    insert into DataLog
    (TableName,RowId,OldValue,NewValue,ActionDate,ActionTypeID,ActionBy)
    values
    ('Customers',IDENT_CURRENT('Customers'),'',
    'ArName: '+@AName+' ,EnName: '+@EName+' ,Email: '+@Email+' ,PhoneNumber: '+@PhoneNo+
    ' ,DOB:'+cast(@DOB as varchar(100)) +' ,NationalNo: '+@NationalNo+' ,Income: '+cast(@Income as varchar(15)),
    GETDATE(),1,@UserId)

	insert into AuditTrailLog
	( TransactionDesc, TransactionDate, UserID)
	values 
	(' insert new customers with id  : ' +cast ( IDENT_CURRENT ( 'customers' ) as varchar(5) ) , GETDATE() , @UserId )

	commit transaction 
	end try

	begin catch 
	   rollback ; 
	   insert into ErrorLog 
	   ( ErrorMessage,ErrorLocation,ErrorDate,ErrorUser ) 
	   values 
	   ( ERROR_MESSAGE() , ERROR_PROCEDURE()  , GETDATE() , @UserId) 
	   
	   set @ErrorMessage= ERROR_MESSAGE () ; 

	   end catch 

	end    
GO
/****** Object:  StoredProcedure [dbo].[SP_ReturnTransactionFromDeleted]    Script Date: 3/27/2023 5:55:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE  procedure [dbo].[SP_ReturnTransactionFromDeleted]
@TransactionId int,
@UserId int,
@ErrorMessage varchar(50)
as
begin
begin transaction
begin try

   insert into DataLog
    (TableName,RowId,ActionBy,ActionDate,ActionTypeID)
    values
    ('Transactions',@TransactionId,@UserId,GETDATE(),5 )

   SET identity_insert [Transaction]ON

   insert into [Transaction]
    (TransacationID, Amount, BranchID,ProductID,UserID,StatusID,FlowID,CustomerID,TrDate)
    select TransacationID, Amount, BranchID,ProductID,UserID,StatusID,FlowID,CustomerID,TrDate
    from DeleteTransaction
    where TransacationID = @TransactionId

   SET identity_insert [Transaction] Off

   --SET identity_insert Decsion ON

   insert into Decsion
   ( DecsionDate, UserID, StatusID, FlowID, TransactionID )
    select DecsionDate, UserID, StatusID, FlowID, TransactionID
    from DeleteDecsion

  -- SET identity_insert Decsion Off

   delete from DeleteTransaction
    where TransacationID= @TransactionId

   delete from DeleteDecsion
    where TransactionId = @TransactionId

   insert into AuditTrailLog
    (TransactionDesc, TransactionDate,UserID )
    values
    ('Retrive transaction data with ID: '+cast(@TransactionId as varchar(5)),GETDATE(),@UserId)

   commit transaction

end try
begin catch

   rollback ;
    
    insert into ErrorLog
    (ErrorLocation,ErrorMessage,ErrorDate,ErrorUser)
    values
    (ERROR_PROCEDURE(),ERROR_MESSAGE(),GETDATE(),@UserId)

   set @ErrorMessage = ERROR_MESSAGE()

end catch
end
GO
/****** Object:  StoredProcedure [dbo].[sp_TransactinAllStages]    Script Date: 3/27/2023 5:55:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[sp_TransactinAllStages]

@statusID int ,
@UserID int , 
@TransactionID int , 
@ErrorMessage varchar(max) out 

as
begin 
begin transaction 
begin try

declare @nextstep int ,
         @currentstep int ,
		 @laststep int 

select top 1  @nextstep=FlowID
from TransactionFlow
where FlowOrder > ( select FlowOrder from TransactionFlow where FlowID =  ( select FlowID from [Transaction] where TransacationID=@TransactionID)) 

order by FlowOrder

select @currentstep=FlowID
from [Transaction]
where TransacationID= @TransactionID

select    @laststep=FlowID
from TransactionFlow
where FlowOrder =  (select max(FlowOrder) from TransactionFlow) 



if @statusID= 2 and @nextstep <> @laststep
begin 
select* from decsion 
insert into Decsion
(DecsionDate,UserID,StatusID,FlowID,TransactionID) 
values 
( GETDATE() ,@UserID, @statusID,@currentstep , @TransactionID) 

insert into DataLog
  (TableName,RowId,OldValue,NewValue,ActionDate,ActionTypeID,ActionBy)
  values 
  ( 'transaction' , @TransactionID, 'flowid:' +  cast ( @currentstep as varchar(5) ) , ',flowid:' +cast ( @nextstep as varchar(5) ) , GETDATE(), 2 , @UserID)


  insert into AuditTrailLog 
     (TransactionDesc, UserID , TransactionDate)
	select 
	  'tranasaction with id : ' + cast ( @TransactionID as varchar (5) ) + ' aprooved by :' + departmentdesc  , @UserID, GETDATE() 
	 from TransactionFlow
	 where FlowID= ( select FlowID from [Transaction] where TransacationID=@TransactionID ) 

  update  [Transaction]
  set FlowID = @nextstep
  where TransacationID=@TransactionID

  
	 end 

	 else if   @statusID= 3 
	 begin 

	 insert into Decsion
(DecsionDate,UserID,StatusID,FlowID,TransactionID) 
values 
( GETDATE() ,@UserID, @statusID,@currentstep , @TransactionID) 

insert into DataLog
  (TableName,RowId,OldValue,NewValue,ActionDate,ActionTypeID,ActionBy)
select 
 'transaction' , @TransactionID, 'StatudID:' +  cast ( Statusid as varchar(5) ) , ',StatudID:' +cast ( @statusID as varchar(5) ) , GETDATE(), 2 , @UserID
 from [Transaction]
 where TransacationID= @TransactionID

  update  [Transaction]
  set StatusID = @statusID
  where TransacationID=@TransactionID

  insert into AuditTrailLog 
     (TransactionDesc, UserID , TransactionDate)
	 select 
	'tranasaction with id : ' + cast ( @TransactionID as varchar (5) ) + ' Rejected by :' + departmentdesc , @UserID, GETDATE()  
	from TransactionFlow
	where FlowID= (select FlowID from [Transaction] where TransacationID=@TransactionID )

end 

else if  @statusID= 2 and   @nextstep=@laststep
	 begin 

	 insert into Decsion
(DecsionDate,UserID,StatusID,FlowID,TransactionID) 
values 
( GETDATE() ,@UserID, @statusID, @currentstep , @TransactionID) 

insert into DataLog
  (TableName,RowId,OldValue,NewValue,ActionDate,ActionTypeID,ActionBy)
select 
 'transaction' , @TransactionID, 'StatudID:' +  cast ( Statusid as varchar(5) ) +'flowid:' +  cast ( @currentstep as varchar(5) ), ',StatudID:' +cast ( @statusID as varchar(5) )+'flowid:' +  cast ( @laststep as varchar(5) ) , GETDATE(), 2 , @UserID
 from [Transaction]
 where TransacationID= @TransactionID

  insert into AuditTrailLog 
     (TransactionDesc, UserID , TransactionDate)
	select 
	  'tranasaction with id : ' + cast ( @TransactionID as varchar (5) ) + ' aprooved by :' + departmentdesc  , @UserID, GETDATE() 
	 from TransactionFlow
	 where FlowID= ( select FlowID from [Transaction] where TransacationID=@TransactionID ) 

	   update  [Transaction]
  set StatusID = @statusID  ,
   FlowID = @laststep
  where TransacationID=@TransactionID

  update target 
  set IsAchived = dbo.FN_IsAchivedTarget( @TransactionID) 
  where branchid = (select branchid from [transaction] where TransacationID= @TransactionID ) and 
  ProductID = (select ProductID from [transaction] where TransacationID= @TransactionID )
 select* from target 

end 

	 commit transaction 
	 end try 
	 begin catch 
      rollback ; 
	  insert into ErrorLog
	  ( ErrorMessage,ErrorLocation,ErrorDate,ErrorUser ) 
	   values 
	   ( ERROR_MESSAGE() , ERROR_PROCEDURE()  , GETDATE() , @UserId) 
	    set @ErrorMessage= ERROR_MESSAGE () ; 
        end catch 
	  
	  end 


GO
/****** Object:  StoredProcedure [dbo].[SP_UpdateUserInfrom]    Script Date: 3/27/2023 5:55:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[SP_UpdateUserInfrom]

@usertypeid int , 
@branchid int , 
@userid int ,
@ErrorMessage varchar (max) out 

as 
begin 
begin transaction 
begin try 

 insert into DataLog
    (TableName,RowId,OldValue,NewValue,ActionDate,ActionTypeID,ActionBy)
    select 
    'users',@userid,
	'usertypeid: '+cast (usertypeid as varchar(5) )+' ,branchid: '+cast (branchid as varchar(5) ) ,
  	'usertypeid: '+cast (@usertypeid as varchar(5) )+' ,branchid: '+cast (@branchid as varchar(5) ) ,
    GETDATE(),2,@UserId
	from users
	where userid = @userid 


update users 
set usertypeid =@usertypeid ,
    branchid = @branchid 

where userid = @userid 

	insert into AuditTrailLog
	( TransactionDesc, TransactionDate, UserID)
	values 
	(' update new users with id  : ' +cast (@userid as varchar(50)) , GETDATE() , @UserId )
	 
commit transaction 
end try 
begin catch 
  rollback ; 
   insert into ErrorLog 
	   ( ErrorMessage,ErrorLocation,ErrorDate,ErrorUser ) 
	   values 
	   ( ERROR_MESSAGE() , ERROR_PROCEDURE()  , GETDATE() , @UserId) 
	   set @ErrorMessage= ERROR_MESSAGE () ; 

	end catch 
end 

GO
USE [master]
GO
ALTER DATABASE [BranchSales] SET  READ_WRITE 
GO
