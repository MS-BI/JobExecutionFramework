/*
Post-Deployment Script Template							
--------------------------------------------------------------------------------------
 This file contains SQL statements that will be appended to the build script.		
 Use SQLCMD syntax to include a file in the post-deployment script.			
 Example:      :r .\myfile.sql								
 Use SQLCMD syntax to reference a variable in the post-deployment script.		
 Example:      :setvar TableName MyTable							
               SELECT * FROM [$(TableName)]					
--------------------------------------------------------------------------------------
*/

:r .\FillSSISStatus.sql
GO
:r .\FillDataTypeLookUp.sql
Go
:r .\FillSystem.sql
Go
:r .\FillClient.sql
Go
:r .\FillApplication.sql
Go
:r .\FillJob.sql
Go
:r .\FillReservedParameter.sql
Go
:r .\FillJobExecutionEndStatus.sql
Go
:r .\FillParameterValueLevel.sql
Go

