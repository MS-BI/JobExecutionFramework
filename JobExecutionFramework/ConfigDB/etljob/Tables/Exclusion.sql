CREATE TABLE [etljob].[Exclusion]
(
	[ExclusionID] INT IDENTITY (1, 1) NOT NULL PRIMARY KEY, 
    [Exclusion] NVARCHAR(255) NULL, 
    [JobStepClusterID_Candidate] INT NOT NULL DEFAULT 0, 
    [JobStepClusterID_Running] INT NOT NULL DEFAULT 0
)
