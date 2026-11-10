/*
==============================================================================================
  PROJECT      : HR Analytics - Workforce, Attrition & Pay
  DATABASE     : HRAnalyticsDB (Microsoft SQL Server, T-SQL)
  AUTHOR       : Shivanand S. Mathapati
  DATASET      : Kaggle - Human Resources Data Set (HRDataset_v14.csv)
                 311 employees, 36 columns

  PURPOSE
    End-to-end SQL pipeline: raw CSV -> validation -> cleaning -> star schema
    -> section-wise analysis views -> stored procedures -> reporting views
    for Power BI.


==============================================================================================

  SCRIPT STRUCTURE

  SECTION 1   DATABASE & SCHEMA SETUP

  SECTION 2   DATA VALIDATION

  SECTION 3   DATA CLEANING

  SECTION 4   DIMENSION & FACT TABLES

  SECTION 5   DATA ANALYSIS (views with standalone queries)

  SECTION 6   VIEWS FOR POWER BI
              vw_Fact_Employment, vw_Dim_Employee, vw_Dim_Department,
              vw_Dim_Position, vw_Dim_Manager, vw_Dim_RecruitmentSource,
              vw_Dim_PerformanceScore, vw_Dim_EmploymentStatus,
              vw_Dim_TermReason, vw_Dim_Date
==============================================================================================
*/


--===================================================================================
-- SECTION 1: DATABASE & SCHEMA SETUP
--===================================================================================


-- CREATING DATABASE
CREATE DATABASE HRAnalyticsDB;
GO

-- USING DATABASE
USE HRAnalyticsDB;
GO

-- CREATING SCHEMAS
CREATE SCHEMA original;
GO

CREATE SCHEMA datamodel;
GO

CREATE SCHEMA reporting;
GO


-- IMPORTING DATASET USING "IMPORTING FLAT FILE"

-- DESCRIBING TABLE
EXEC sp_help 'original.HRDataset_v14';


-- DISPLAYING TABLE DATA
SELECT * FROM original.HRDataset_v14;
-- 311 Records

-- COUNTING NUMBER OF RECORDS PRESENT TABLE
SELECT COUNT(*) AS [Total Rows] FROM original.HRDataset_v14;



-- DUPLICATING THE TABLE FOR CLEANING
SELECT *
INTO original.hrdataclean
FROM original.HRDataset_v14;


SELECT
    s.name AS [Schema Name],
    t.name AS [Table Name]
FROM sys.tables t
JOIN sys.schemas s
    ON t.schema_id = s.schema_id
WHERE s.name IN ('original', 'datamodel', 'reporting');



--===================================================================================
-- SECTION 2: DATA VALIDATION
--===================================================================================

-- ROW COUNT CHECK
SELECT
    COUNT(*) AS [Total Records]
FROM original.hrdataclean;
-- 311 Records


-- NULL/BLANK VALUES CHECK
SELECT 
    SUM(CASE WHEN Employee_Name IS NULL OR LTRIM(RTRIM(Employee_Name)) = '' THEN 1 ELSE 0 END) AS [Blank Emp Name],
    SUM(CASE WHEN EmpID IS NULL OR LTRIM(RTRIM(EmpID)) = '' THEN 1 ELSE 0 END) AS [Blank EmpID],
    SUM(CASE WHEN MarriedID IS NULL OR LTRIM(RTRIM(MarriedID)) = '' THEN 1 ELSE 0 END) AS [Blank MarriedID],
    SUM(CASE WHEN MaritalStatusID IS NULL OR LTRIM(RTRIM(MaritalStatusID)) = '' THEN 1 ELSE 0 END) AS [Blank MaritalStatusID],
    SUM(CASE WHEN GenderID IS NULL OR LTRIM(RTRIM(GenderID)) = '' THEN 1 ELSE 0 END) AS [Blank GenderID],
    SUM(CASE WHEN EmpStatusID IS NULL OR LTRIM(RTRIM(EmpStatusID)) = '' THEN 1 ELSE 0 END) AS [Blank EmpStatusID],
    SUM(CASE WHEN DeptID IS NULL OR LTRIM(RTRIM(DeptID)) = '' THEN 1 ELSE 0 END) AS [Blank DeptID],
    SUM(CASE WHEN PerfScoreID IS NULL OR LTRIM(RTRIM(PerfScoreID)) = '' THEN 1 ELSE 0 END) AS [Blank PerfScoreID],
    SUM(CASE WHEN FromDiversityJobFairID IS NULL OR LTRIM(RTRIM(FromDiversityJobFairID)) = '' THEN 1 ELSE 0 END) AS [Blank FromDiversityJobFairID],
    SUM(CASE WHEN Salary IS NULL OR LTRIM(RTRIM(Salary)) = '' THEN 1 ELSE 0 END) AS [Blank Salary],
    SUM(CASE WHEN Termd IS NULL OR LTRIM(RTRIM(Termd)) = '' THEN 1 ELSE 0 END) AS [Blank Termd],
    SUM(CASE WHEN PositionID IS NULL OR LTRIM(RTRIM(PositionID)) = '' THEN 1 ELSE 0 END) AS [Blank PositionID],
    SUM(CASE WHEN Position IS NULL OR LTRIM(RTRIM(Position)) = '' THEN 1 ELSE 0 END) AS [Blank Position],
    SUM(CASE WHEN State IS NULL OR LTRIM(RTRIM(State)) = '' THEN 1 ELSE 0 END) AS [Blank State],
    SUM(CASE WHEN Zip IS NULL OR LTRIM(RTRIM(Zip)) = '' THEN 1 ELSE 0 END) AS [Blank Zip],
    SUM(CASE WHEN DOB IS NULL OR LTRIM(RTRIM(DOB)) = '' THEN 1 ELSE 0 END) AS [Blank DOB],
    SUM(CASE WHEN Sex IS NULL OR LTRIM(RTRIM(Sex)) = '' THEN 1 ELSE 0 END) AS [Blank Sex],
    SUM(CASE WHEN MaritalDesc IS NULL OR LTRIM(RTRIM(MaritalDesc)) = '' THEN 1 ELSE 0 END) AS [Blank MaritalDesc],
    SUM(CASE WHEN CitizenDesc IS NULL OR LTRIM(RTRIM(CitizenDesc)) = '' THEN 1 ELSE 0 END) AS [Blank CitizenDesc],
    SUM(CASE WHEN HispanicLatino IS NULL OR LTRIM(RTRIM(HispanicLatino)) = '' THEN 1 ELSE 0 END) AS [Blank HispanicLatino],
    SUM(CASE WHEN RaceDesc IS NULL OR LTRIM(RTRIM(RaceDesc)) = '' THEN 1 ELSE 0 END) AS [Blank RaceDesc],
    SUM(CASE WHEN DateofHire IS NULL OR LTRIM(RTRIM(DateofHire)) = '' THEN 1 ELSE 0 END) AS [Blank DateofHire],
    SUM(CASE WHEN DateofTermination IS NULL OR LTRIM(RTRIM(DateofTermination)) = '' THEN 1 ELSE 0 END) AS [Blank DateofTermination],
    SUM(CASE WHEN TermReason IS NULL OR LTRIM(RTRIM(TermReason)) = '' THEN 1 ELSE 0 END) AS [Blank TermReason],
    SUM(CASE WHEN EmploymentStatus IS NULL OR LTRIM(RTRIM(EmploymentStatus)) = '' THEN 1 ELSE 0 END) AS [Blank EmploymentStatus],
    SUM(CASE WHEN Department IS NULL OR LTRIM(RTRIM(Department)) = '' THEN 1 ELSE 0 END) AS [Blank Department],
    SUM(CASE WHEN ManagerName IS NULL OR LTRIM(RTRIM(ManagerName)) = '' THEN 1 ELSE 0 END) AS [Blank ManagerName],
    SUM(CASE WHEN ManagerID IS NULL OR LTRIM(RTRIM(ManagerID)) = '' THEN 1 ELSE 0 END) AS [Blank ManagerID],
    SUM(CASE WHEN RecruitmentSource IS NULL OR LTRIM(RTRIM(RecruitmentSource)) = '' THEN 1 ELSE 0 END) AS [Blank RecruitmentSource],
    SUM(CASE WHEN PerformanceScore IS NULL OR LTRIM(RTRIM(PerformanceScore)) = '' THEN 1 ELSE 0 END) AS [Blank PerformanceScore],
    SUM(CASE WHEN EngagementSurvey IS NULL OR LTRIM(RTRIM(EngagementSurvey)) = '' THEN 1 ELSE 0 END) AS [Blank EngagementSurvey],
    SUM(CASE WHEN EmpSatisfaction IS NULL OR LTRIM(RTRIM(EmpSatisfaction)) = '' THEN 1 ELSE 0 END) AS [Blank EmpSatisfaction],
    SUM(CASE WHEN SpecialProjectsCount IS NULL OR LTRIM(RTRIM(SpecialProjectsCount)) = '' THEN 1 ELSE 0 END) AS [Blank SpecialProjectsCount],
    SUM(CASE WHEN LastPerformanceReview_Date IS NULL OR LTRIM(RTRIM(LastPerformanceReview_Date)) = '' THEN 1 ELSE 0 END) AS [Blank LastPerformanceReview_Date],
    SUM(CASE WHEN DaysLateLast30 IS NULL OR LTRIM(RTRIM(DaysLateLast30)) = '' THEN 1 ELSE 0 END) AS [Blank DaysLateLast30],
    SUM(CASE WHEN Absences IS NULL OR LTRIM(RTRIM(Absences)) = '' THEN 1 ELSE 0 END) AS [Blank Absences]
FROM original.hrdataclean;
-- 'DateofTermination' has 207 and ManagerID has 8 blank values and all other columns having 0 (zero) blank values


-- DUPLICATE EMPLOYEE NAME CHECK
SELECT
    Employee_Name,
    COUNT(*) AS [Duplicate Count]
FROM original.hrdataclean
GROUP BY Employee_Name
HAVING COUNT(*) > 1;
-- No duplicate empoyee names found


-- DUPLICATE EMPID CHECK
SELECT
    EmpID,
    COUNT(*) AS [Duplicate Count]
FROM original.hrdataclean
GROUP BY EmpID
HAVING COUNT(*) > 1;
-- No duplicate EmpID found


-- HIDDEN SPACES CHECK (LEADING OR TRAILING SPACES)
SELECT
    SUM(CASE WHEN DATALENGTH(Employee_Name) <> DATALENGTH(TRIM(Employee_Name)) THEN 1 ELSE 0 END) AS Employee_Name,  -- 70
    SUM(CASE WHEN DATALENGTH(State) <> DATALENGTH(TRIM(State)) THEN 1 ELSE 0 END) AS State,  -- 0
    SUM(CASE WHEN DATALENGTH(Zip) <> DATALENGTH(TRIM(Zip)) THEN 1 ELSE 0 END) AS Zip,  -- 0
    SUM(CASE WHEN DATALENGTH(Sex) <> DATALENGTH(TRIM(Sex)) THEN 1 ELSE 0 END) AS Sex,  -- 135
    SUM(CASE WHEN DATALENGTH(MaritalDesc) <> DATALENGTH(TRIM(MaritalDesc)) THEN 1 ELSE 0 END) AS MaritalDesc,  -- 0
    SUM(CASE WHEN DATALENGTH(CitizenDesc) <> DATALENGTH(TRIM(CitizenDesc)) THEN 1 ELSE 0 END) AS CitizenDesc,  -- 0
    SUM(CASE WHEN DATALENGTH(HispanicLatino) <> DATALENGTH(TRIM(HispanicLatino)) THEN 1 ELSE 0 END) AS HispanicLatino,  -- 0
    SUM(CASE WHEN DATALENGTH(RaceDesc) <> DATALENGTH(TRIM(RaceDesc)) THEN 1 ELSE 0 END) AS RaceDesc,  -- 0
    SUM(CASE WHEN DATALENGTH(TermReason) <> DATALENGTH(TRIM(TermReason)) THEN 1 ELSE 0 END) AS TermReason,  -- 0
    SUM(CASE WHEN DATALENGTH(EmploymentStatus) <> DATALENGTH(TRIM(EmploymentStatus)) THEN 1 ELSE 0 END) AS EmploymentStatus,  -- 0
    SUM(CASE WHEN DATALENGTH(Department) <> DATALENGTH(TRIM(Department)) THEN 1 ELSE 0 END) AS Department,  -- 209
    SUM(CASE WHEN DATALENGTH(ManagerName) <> DATALENGTH(TRIM(ManagerName)) THEN 1 ELSE 0 END) AS ManagerName,  -- 0
    SUM(CASE WHEN DATALENGTH(RecruitmentSource) <> DATALENGTH(TRIM(RecruitmentSource)) THEN 1 ELSE 0 END) AS RecruitmentSource,  -- 0
    SUM(CASE WHEN DATALENGTH(PerformanceScore) <> DATALENGTH(TRIM(PerformanceScore)) THEN 1 ELSE 0 END) AS PerformanceScore,  -- 0
    SUM(CASE WHEN DATALENGTH(Position) <> DATALENGTH(TRIM(Position))THEN 1 ELSE 0 END) AS Position  -- 1
FROM original.hrdataclean;



-- CASE VARIANTS CHECK
SELECT
    COUNT(DISTINCT HispanicLatino) AS Hisp_1st,  -- 2
        COUNT(DISTINCT HispanicLatino COLLATE Latin1_General_BIN2) AS Hisp_2nd,  -- 4     
    COUNT(DISTINCT Sex) AS Sex_1st,  -- 2
        COUNT(DISTINCT Sex COLLATE Latin1_General_BIN2) AS Sex_2nd,  -- 2
    COUNT(DISTINCT MaritalDesc) AS Marital_1st,  -- 5
        COUNT(DISTINCT MaritalDesc COLLATE Latin1_General_BIN2) AS Marital_2nd,  -- 5
    COUNT(DISTINCT CitizenDesc) AS Citizen_1st,  -- 3
        COUNT(DISTINCT CitizenDesc COLLATE Latin1_General_BIN2) AS Citizen_2nd,  -- 3
    COUNT(DISTINCT RaceDesc) AS Race_1st,  -- 6
        COUNT(DISTINCT RaceDesc COLLATE Latin1_General_BIN2) AS Race_2nd,  -- 6
    COUNT(DISTINCT Department) AS Dept_1st,  -- 6
        COUNT(DISTINCT Department COLLATE Latin1_General_BIN2) AS Dept_2nd,  -- 6
    COUNT(DISTINCT Position) AS Pos_1st,  -- 31
        COUNT(DISTINCT Position COLLATE Latin1_General_BIN2) AS Pos_2nd,  -- 31
    COUNT(DISTINCT EmploymentStatus) AS Status_1sr,  -- 3
        COUNT(DISTINCT EmploymentStatus COLLATE Latin1_General_BIN2) AS Status_2nd,  -- 3
    COUNT(DISTINCT TermReason) AS Reason_1st,  -- 18
        COUNT(DISTINCT TermReason COLLATE Latin1_General_BIN2) AS Reason_2nd,  -- 18
    COUNT(DISTINCT RecruitmentSource) AS Source_1st,  -- 9
        COUNT(DISTINCT RecruitmentSource COLLATE Latin1_General_BIN2) AS Source_2nd,  -- 9
    COUNT(DISTINCT PerformanceScore) AS Perf_1st,  -- 4
        COUNT(DISTINCT PerformanceScore COLLATE Latin1_General_BIN2) AS Perf_2nd,  -- 4
    COUNT(DISTINCT State) AS State_1st,  -- 28
        COUNT(DISTINCT State COLLATE Latin1_General_BIN2) AS State_2nd -- 28
FROM original.hrdataclean;



-- DISTINCT VALUE CHECK
SELECT
    COUNT(DISTINCT EmpID) AS [Unique EmpID],  -- 311
    COUNT(DISTINCT Employee_Name) AS [Unique Emp Name],  -- 311
    COUNT(DISTINCT Position) AS [Unique Position],  --31
    COUNT(DISTINCT State) AS [Unique State],  -- 28
    COUNT(DISTINCT Sex) AS [Unique Sex],  -- 2
    COUNT(DISTINCT MaritalDesc) AS [Unique MaritalDesc],  -- 5
    COUNT(DISTINCT CitizenDesc) AS [Unique CitizenDesc],  -- 3
    COUNT(DISTINCT HispanicLatino) AS [Unique HispanicLatino],  -- 2
    COUNT(DISTINCT RaceDesc) AS [Unique RaceDesc],  -- 6
    COUNT(DISTINCT EmploymentStatus) AS [Unique EmploymentStatus],  -- 3
    COUNT(DISTINCT Department) AS [Unique Department],  -- 6
    COUNT(DISTINCT TermReason) AS [Unique TermReason],  -- 18
    COUNT(DISTINCT ManagerID) AS [Unique ManagerID],  -- 23
    COUNT(DISTINCT ManagerName) AS [Unique ManagerName],  -- 21
    COUNT(DISTINCT RecruitmentSource) AS [Unique RecruitmentSource], -- 9
    COUNT(DISTINCT PerformanceScore) AS [Unique PerformanceScore]  -- 4
FROM original.hrdataclean;



-- FROM THE ABOVE CHECK WE GOT SOME PROBLEM IN UNIQUE MANAGER ID (23) & MANAGERNAME (21)
-- THAT MEANS SOME NAMES CARRY MORE THAN ONE ID
SELECT
    ManagerName,
    COUNT(DISTINCT ManagerID) AS [ID Count]
FROM original.hrdataclean
GROUP BY ManagerName
HAVING COUNT(DISTINCT ManagerID) > 1;
-- I found that 'Brandon R. LeBlanc' & 'Michael Albert' each has 2 IDs


SELECT
    Department,
    ManagerName,
    ManagerID,
    COUNT(*) AS [Emp Count]
FROM original.hrdataclean
WHERE ManagerName IN ('Brandon R. LeBlanc', 'Michael Albert')
GROUP BY Department, ManagerName,ManagerID;
-- Here I found that ManagerID 3 & 30 are StrayID/Dummy because each ID has only 1 employee


-- CHECKING THE MANAGER NAMES WHO NOT HAVING IDs
SELECT
    ManagerName,
    COUNT(*) AS [Blank ID Rows]
FROM original.hrdataclean
WHERE ManagerID IS NULL OR NULLIF(LTRIM(RTRIM(ManagerID)), '') IS NULL
GROUP BY ManagerName;
-- All 8 blank IDs belongs to Manager 'Webster Butler'


-- CHECKING WHAT IDs DOES MANAGER 'Webster Butler' HAVE ON HIS OTHER ROWS
SELECT
    ManagerName,
    ManagerID,
    COUNT(*) AS [Emp Count]
FROM original.hrdataclean
WHERE ManagerName = 'Webster Butler'
    AND NULLIF(LTRIM(RTRIM(ManagerID)), '') IS NOT NULL
GROUP BY ManagerName, ManagerID;
-- Webster Butler has ID 39 So we have to fill those NULL with 39 while in cleaning


-- CHECKING CAN THE NUMERIC COLUMNS BE CONVERTED?
SELECT
    SUM(CASE
            WHEN NULLIF(LTRIM(RTRIM(Salary)), '') IS NOT NULL AND TRY_CAST(Salary AS INT) IS NULL
            THEN 1 ELSE 0
        END) AS [Invalid Salary],
    SUM(CASE
            WHEN NULLIF(LTRIM(RTRIM(EngagementSurvey)), '') IS NOT NULL AND TRY_CAST(EngagementSurvey AS DECIMAL(3,2)) IS NULL
            THEN 1 ELSE 0
        END) AS [Invalid EngagementSurvey],
    SUM(CASE
            WHEN NULLIF(LTRIM(RTRIM(EmpSatisfaction)), '') IS NOT NULL AND TRY_CAST(EmpSatisfaction AS INT) IS NULL
            THEN 1 ELSE 0
        END) AS [Invalid EmpSatisfaction],
    SUM(CASE
            WHEN NULLIF(LTRIM(RTRIM(SpecialProjectsCount)), '') IS NOT NULL AND TRY_CAST(SpecialProjectsCount AS INT) IS NULL
            THEN 1 ELSE 0
        END) AS [Invalid SpecialProjectsCount],
    SUM(CASE
            WHEN NULLIF(LTRIM(RTRIM(DaysLateLast30)), '') IS NOT NULL AND TRY_CAST(DaysLateLast30 AS INT) IS NULL
            THEN 1 ELSE 0
        END) AS [Invalid DaysLateLast30],
    SUM(CASE
            WHEN NULLIF(LTRIM(RTRIM(Absences)), '') IS NOT NULL AND TRY_CAST(Absences AS INT) IS NULL
            THEN 1 ELSE 0
        END) AS [Invalid Absences],
    SUM(CASE
            WHEN NULLIF(LTRIM(RTRIM(EmpID)), '') IS NOT NULL AND TRY_CAST(EmpID AS INT) IS NULL
            THEN 1 ELSE 0
        END) AS [Invalid EmpID],
    SUM(CASE
            WHEN NULLIF(LTRIM(RTRIM(MarriedID)), '') IS NOT NULL AND TRY_CAST(MarriedID AS INT) IS NULL
            THEN 1 ELSE 0
        END) AS [Invalid MarriedID],
    SUM(CASE
            WHEN NULLIF(LTRIM(RTRIM(MaritalStatusID)), '') IS NOT NULL AND TRY_CAST(MaritalStatusID AS INT) IS NULL
            THEN 1 ELSE 0
        END) AS [Invalid MaritalStatusID],
    SUM(CASE
            WHEN NULLIF(LTRIM(RTRIM(GenderID)), '') IS NOT NULL AND TRY_CAST(GenderID AS INT) IS NULL
            THEN 1 ELSE 0
        END) AS [Invalid GenderID],
    SUM(CASE
            WHEN NULLIF(LTRIM(RTRIM(EmpStatusID)), '') IS NOT NULL AND TRY_CAST(EmpStatusID AS INT) IS NULL
            THEN 1 ELSE 0
        END) AS [Invalid EmpStatusID],
    SUM(CASE
            WHEN NULLIF(LTRIM(RTRIM(DeptID)), '') IS NOT NULL AND TRY_CAST(DeptID AS INT) IS NULL
            THEN 1 ELSE 0
        END) AS [Invalid DeptID],
    SUM(CASE
            WHEN NULLIF(LTRIM(RTRIM(PerfScoreID)), '') IS NOT NULL AND TRY_CAST(PerfScoreID AS INT) IS NULL
            THEN 1 ELSE 0
        END) AS [Invalid PerfScoreID],
    SUM(CASE
            WHEN NULLIF(LTRIM(RTRIM(FromDiversityJobFairID)), '') IS NOT NULL AND TRY_CAST(FromDiversityJobFairID AS INT) IS NULL
            THEN 1 ELSE 0
        END) AS [Invalid FromDiversityJobFairID],
    SUM(CASE
            WHEN NULLIF(LTRIM(RTRIM(Termd)), '') IS NOT NULL AND TRY_CAST(Termd AS INT) IS NULL
            THEN 1 ELSE 0
        END) AS [Invalid Termd],
    SUM(CASE
            WHEN NULLIF(LTRIM(RTRIM(PositionID)), '') IS NOT NULL AND TRY_CAST(PositionID AS INT) IS NULL
            THEN 1 ELSE 0
        END) AS [Invalid PositionID],
    SUM(CASE
            WHEN NULLIF(LTRIM(RTRIM(ManagerID)), '') IS NOT NULL AND TRY_CAST(ManagerID AS INT) IS NULL
            THEN 1 ELSE 0
        END) AS [Invalid ManagerID]
FROM original.hrdataclean;
-- All columns are ready to convert from text to numeric (no conversion failures)



-- CHECKING CAN THE DATE COLUMNS BE CONVERTED?
SELECT
    SUM(CASE
            WHEN NULLIF(LTRIM(RTRIM(DOB)), '') IS NOT NULL AND TRY_CONVERT(DATE, DOB, 1) IS NULL   -- CODE 1 = MM/DD/YYYY
            THEN 1 ELSE 0
        END) AS [Invalid DOB],
    SUM(CASE
            WHEN NULLIF(LTRIM(RTRIM(DateofHire)), '') IS NOT NULL AND TRY_CONVERT(DATE, DateofHire, 101) IS NULL  -- CODE 101 = MM/DD/YYYY
            THEN 1 ELSE 0
        END) AS [Invalid DateofHire],
    SUM(CASE
            WHEN NULLIF(LTRIM(RTRIM(DateofTermination)), '') IS NOT NULL AND TRY_CONVERT(DATE, DateofTermination, 101) IS NULL
            THEN 1 ELSE 0
        END) AS [Invalid DateofTermination],
    SUM(CASE
            WHEN NULLIF(LTRIM(RTRIM(LastPerformanceReview_Date)), '') IS NOT NULL AND TRY_CONVERT(DATE, LastPerformanceReview_Date, 101) IS NULL
            THEN 1 ELSE 0
        END) AS [Invalid LastPerformanceReview_Date]
FROM original.hrdataclean;
-- All columns are ready to convert from text to date (no conversion failures)



-- SOME NUMERIC COLUMNS RANGE CHECK
SELECT
   MIN(TRY_CAST(Salary AS INT)) AS [Min Salary],  -- 45046
   MAX(TRY_CAST(Salary AS INT)) AS [Max Salary],  -- 250000
   MIN(TRY_CAST(EngagementSurvey AS DECIMAL(5, 2))) AS [Min EngagementSurvey],  -- 1.12
   MAX(TRY_CAST(EngagementSurvey AS DECIMAL(5, 2))) AS [Max EngagementSurvey],  -- 5.00
   MIN(TRY_CAST(EmpSatisfaction AS INT)) AS [Min EmpSatisfaction],  --  1
   MAX(TRY_CAST(EmpSatisfaction AS INT)) AS [Max EmpSatisfaction],  --  5
   MIN(TRY_CAST(DaysLateLast30 AS INT)) AS [Min DaysLateLast30],  -- 0
   MAX(TRY_CAST(DaysLateLast30 AS INT)) AS [Max DaysLateLast30],  -- 6
   MIN(TRY_CAST(Absences AS INT)) AS [Min Absences],  -- 1 (checking not to be negative)
   MAX(TRY_CAST(Absences AS INT)) AS [Max Absences],  -- 20
   MIN(TRY_CAST(SpecialProjectsCount AS INT)) AS [Min SpecialProjectsCount],  --  0 (checking not to be negative)
   MAX(TRY_CAST(SpecialProjectsCount AS INT)) AS [Max SpecialProjectsCount]   -- 8
FROM original.hrdataclean;
-- numeric ranges - all are valid, no fixes needed


-- SOME COLUMNS ALLOWED ONLY 0 & 1 CHECKING IS THOSE COLUMNS CONTAINS OTHER THAN 0 & 1
SELECT
    SUM(CASE WHEN LTRIM(RTRIM(MarriedID)) NOT IN ('0','1') THEN 1 ELSE 0 END) AS [Invalid MarriedID],
    SUM(CASE WHEN LTRIM(RTRIM(GenderID)) NOT IN ('0','1') THEN 1 ELSE 0 END) AS [Invalid GenderID],
    SUM(CASE WHEN LTRIM(RTRIM(Termd)) NOT IN ('0','1') THEN 1 ELSE 0 END) AS [Invalid Termd],
    SUM(CASE WHEN LTRIM(RTRIM(FromDiversityJobFairID)) NOT IN ('0','1') THEN 1 ELSE 0 END) AS [Invalid FromDiversityJobFairID]
FROM original.hrdataclean;
-- These columns conatins only 0/1, no fixes needed


-- ZIP AND STATE: LENGTH AND CONTENT CHECKS (counts of failing rows)
SELECT
    SUM(CASE WHEN LEN(LTRIM(RTRIM(Zip))) <> 5 THEN 1 ELSE 0 END) AS [Invalid Zip Length],
    SUM(CASE WHEN Zip LIKE '%[^0-9]%' THEN 1 ELSE 0 END) AS [Zip Non-Digit],
    SUM(CASE WHEN LEN(LTRIM(RTRIM(State))) <> 2 THEN 1 ELSE 0 END) AS [Invalid State Length],
    SUM(CASE WHEN State LIKE '%[^A-Za-z]%'  THEN 1 ELSE 0 END) AS [State Non-Letter]
FROM original.hrdataclean;
-- Zip and State: lengths and content valid, no fixes needed



-- DATA RANGE CHECK
SELECT
    MIN(TRY_CONVERT(DATE, DOB, 1)) AS [Min DOB],
    MAX(TRY_CONVERT(DATE, DOB, 1)) AS [Max DOB],
    MIN(TRY_CONVERT(DATE, DateofHire, 101)) AS [Min DateofHire],
    MAX(TRY_CONVERT(DATE, DateofHire, 101)) AS [Max DateofHire],
    MIN(TRY_CONVERT(DATE, DateofTermination, 101)) AS [Min DateofTermination],
    MAX(TRY_CONVERT(DATE, DateofTermination, 101)) AS [Max DateofTermination],
    MIN(TRY_CONVERT(DATE, LastPerformanceReview_Date, 101)) AS [Min LastPerformanceReview_Date],
    MAX(TRY_CONVERT(DATE, LastPerformanceReview_Date, 101)) AS [Max LastPerformanceReview_Date]
FROM original.hrdataclean;
-- date ranges valid; DOB - All in the 1900s, so the 2-digit years resolved to the right century


-- DATE ORDER CHECK
SELECT
    SUM(CASE
            WHEN TRY_CONVERT(DATE, DateofTermination, 101) IS NOT NULL
            AND TRY_CONVERT(DATE, DateofTermination, 101) < TRY_CONVERT(DATE, DateofHire, 101)
            THEN 1
            ELSE 0 
        END) AS [DateofTermination Before DateofHire],
    SUM(CASE
            WHEN TRY_CONVERT(DATE, LastPerformanceReview_Date, 101) IS NOT NULL
            AND TRY_CONVERT(DATE, LastPerformanceReview_Date, 101) < TRY_CONVERT(DATE, DateofHire, 101)
            THEN 1 
            ELSE 0 
        END) AS [LastPerformanceReview_Date Before DateofHire],
    SUM(CASE
            WHEN DATEADD(YEAR, 18, TRY_CONVERT(DATE, DOB, 1)) > TRY_CONVERT(DATE, DateofHire, 101)
            THEN 1
            ELSE 0
        END) AS [Under 18 At Hire]
FROM original.hrdataclean;
-- termination before hire: 0, under 18 at hire: 0, but 2 employees have a last performance review dated before their hire date.


-- CHECKING THAT TWO EMPLOYEES
SELECT
    EmpID,
    Employee_Name,
    DateofHire,
    LastPerformanceReview_Date,
    DateofTermination,
    EmploymentStatus,
    PerformanceScore
FROM original.hrdataclean
WHERE TRY_CONVERT(DATE, LastPerformanceReview_Date, 101) < TRY_CONVERT(DATE, DateofHire, 101);
-- I will keep these two results and later in cleaning i will add one flag column 'review date issue' to handle


-- TERMINATION CONSISTENCY CHECK
SELECT
    LTRIM(RTRIM(Termd)) AS [Termd],
    LTRIM(RTRIM(EmploymentStatus)) AS [Employment Status],
    CASE
        WHEN NULLIF(LTRIM(RTRIM(DateofTermination)), '') IS NULL
        THEN 'Blank' 
        ELSE 'Has date' 
        END AS [Termination Date],
    CASE
        WHEN LTRIM(RTRIM(TermReason)) = 'N/A-StillEmployed'
        THEN 'N/A' 
        ELSE 'Has reason'
        END AS [Termination Reason Type],
    COUNT(*) AS [Emp Count]
FROM original.hrdataclean
GROUP BY
    LTRIM(RTRIM(Termd)),
    LTRIM(RTRIM(EmploymentStatus)),
    CASE
        WHEN NULLIF(LTRIM(RTRIM(DateofTermination)), '') IS NULL
        THEN 'Blank' 
        ELSE 'Has date' 
        END,
    CASE
        WHEN LTRIM(RTRIM(TermReason)) = 'N/A-StillEmployed'
        THEN 'N/A' 
        ELSE 'Has reason'
        END
ORDER BY [Termd], [Employment Status];
-- Termd, status, termination date and reason all are consistent, no fixes needed



-- CHECKING DO THE ID COLUMNS MATCHING THEIR TEXT COLUMNS?
SELECT
    LTRIM(RTRIM(Sex)) AS [Sex],
    GenderID,
    COUNT(*) AS [Records]
FROM original.hrdataclean
GROUP BY LTRIM(RTRIM(Sex)), GenderID;

SELECT
    LTRIM(RTRIM(MaritalDesc)) AS [MaritalDesc],
    MaritalStatusID,
    COUNT(*) AS [Records]
FROM original.hrdataclean
GROUP BY LTRIM(RTRIM(MaritalDesc)), MaritalStatusID;

SELECT
    LTRIM(RTRIM(MaritalDesc)) AS [Marital Desc],
    MarriedID,
    COUNT(*) AS [Records]
FROM original.hrdataclean
GROUP BY LTRIM(RTRIM(MaritalDesc)), MarriedID
-- Sex, MaritalDesc and their ID columns are consistent, no fixes needed


-- DEPARTMENT, PERFORMANCE SCORE, EMPLOYMENT STATUS VS THEIR IDs 
SELECT
    LTRIM(RTRIM(Department)) AS [Department],
    DeptID,
    COUNT(*) AS [Records]
FROM original.hrdataclean
GROUP BY LTRIM(RTRIM(Department)), DeptID
ORDER BY TRY_CAST(DeptID AS INT) ASC;

SELECT
    LTRIM(RTRIM(PerformanceScore)) AS [Performance Score],
    PerfScoreID,
    COUNT(*) AS [Records]
FROM original.hrdataclean
GROUP BY LTRIM(RTRIM(PerformanceScore)), PerfScoreID
ORDER BY TRY_CAST(PerfScoreID AS INT) ASC;

SELECT
    LTRIM(RTRIM(EmploymentStatus)) AS [Employment Status],
    EmpStatusID,
    COUNT(*) AS [Records]
FROM original.hrdataclean
GROUP BY LTRIM(RTRIM(EmploymentStatus)), EmpStatusID
ORDER BY TRY_CAST(EmpStatusID AS INT) ASC;

SELECT
    LTRIM(RTRIM(Position)) AS [Position],
    PositionID,
    COUNT(*) AS [Records]
FROM original.hrdataclean
GROUP BY LTRIM(RTRIM(Position)), PositionID
ORDER BY TRY_CAST(PositionID AS INT) ASC;
-- I found some issues here, i will not use these, well create our own while cleaning


-- CHECKING DOES EACH POSITION BELONGS TO EXACTLY ONE DEPARTMENT?
SELECT
    LTRIM(RTRIM(Position)) AS [Position],
    COUNT(DISTINCT LTRIM(RTRIM(Department))) AS [Department Count]
FROM original.hrdataclean
GROUP BY LTRIM(RTRIM(Position))
HAVING COUNT(DISTINCT LTRIM(RTRIM(Department))) > 1;
-- no issues found
GO


--===================================================================================
-- SECTION 3: DATA CLEANING
--===================================================================================

-- CREATING ONE FULLY CLEANED TABLE 
WITH Manager AS (
    SELECT ManagerName, ManagerID
    FROM (
        SELECT
            ManagerName,
            TRY_CAST(ManagerID AS INT) AS [ManagerID],
            ROW_NUMBER() OVER(PARTITION BY ManagerName ORDER BY COUNT(*) DESC, TRY_CAST(ManagerID AS INT)) AS [rnk]
        FROM original.hrdataclean
        WHERE NULLIF(LTRIM(RTRIM(ManagerID)), '') IS NOT NULL
        GROUP BY ManagerName, TRY_CAST(ManagerID AS INT)
        ) mng
    WHERE rnk = 1
)
SELECT
    TRIM(dc.Employee_Name) AS [EmployeeName],
    TRY_CAST(dc.EmpID AS INT) AS [EmpID],
    TRY_CAST(dc.MaritalStatusID AS INT) AS [MaritalStatusID],
    TRY_CAST(dc.GenderID AS INT) AS [GenderID],
    -- Here I excluded some columns like MarriedID, DeptID, PerfScoreID, EmpStatusID because of inconsistency
    -- well we create our won Key for these IDs later in while creating Dimension Table
    TRY_CAST(dc.FromDiversityJobFairID AS INT) AS [FromDiversityJobFairID],
    TRY_CAST(dc.Salary AS DECIMAL(10, 2)) AS [Salary],
    TRY_CAST(dc.Termd AS INT) AS [Termd],
    TRY_CAST(dc.PositionID AS INT) AS [PositionID],
    TRIM(dc.Position) AS [Position],
    TRIM(dc.State) AS [State],
    TRIM(dc.Zip) AS [Zip],  -- I am keeping Zip Code as text (if need we will convert later)
    TRY_CONVERT(DATE, dc.DOB, 1) AS [DOB],
    TRIM(dc.Sex) AS [Sex],
    TRIM(dc.MaritalDesc) AS [MaritalDesc],
    TRIM(dc.CitizenDesc) AS [CitizenDesc],
    CASE TRIM(dc.HispanicLatino)
         WHEN 'yes' THEN 'Yes'
         WHEN 'no' THEN 'No'
    END AS [HispanicLatino],
    TRIM(dc.RaceDesc) AS [RaceDesc],
    TRY_CONVERT(DATE, dc.DateofHire, 101) AS [DateofHire],
    TRY_CONVERT(DATE, NULLIF(TRIM(dc.DateofTermination), ''), 101) AS [DateofTermination],
    TRIM(dc.TermReason) AS [TermReason],
    TRIM(dc.EmploymentStatus) AS [EmploymentStatus],
    TRIM(dc.Department) AS [Department],
    TRIM(dc.ManagerName) AS [ManagerName],
    mg.ManagerID AS [ManagerID],
    TRIM(dc.RecruitmentSource) AS [RecruitmentSource],
    TRIM(dc.PerformanceScore) AS [PerformanceScore],
    TRY_CAST(dc.EngagementSurvey AS DECIMAL(5, 2)) AS [EngagementSurvey],
    TRY_CAST(dc.EmpSatisfaction AS INT) AS [EmpSatisfaction],
    TRY_CAST(dc.SpecialProjectsCount AS INT) AS [SpecialProjectsCount],
    TRY_CONVERT(DATE, dc.LastPerformanceReview_Date, 101) AS [LastPerformanceReview_Date],
    TRY_CAST(dc.DaysLateLast30 AS INT) AS [DaysLateLast30],
    TRY_CAST(dc.Absences AS INT) AS [Absences],
    CASE
        WHEN TRY_CONVERT(DATE, dc.LastPerformanceReview_Date, 101) < TRY_CONVERT(DATE, dc.DateofHire, 101)
        THEN 1
        ELSE 0
    END AS [ReviewDateIssue]
INTO datamodel.EmployeeClean
FROM original.hrdataclean dc
LEFT JOIN Manager mg
    ON dc.ManagerName = mg.ManagerName;
GO

SELECT * FROM datamodel.EmployeeClean;


-- CHECKING EMPLOYEECLEAN COLUMNS ARE REALLY CONVERTED OR NOT?
SELECT
    COLUMN_NAME,
    DATA_TYPE,
    CHARACTER_MAXIMUM_LENGTH,
    NUMERIC_PRECISION,
    NUMERIC_SCALE,
    IS_NULLABLE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'datamodel'
  AND TABLE_NAME   = 'EmployeeClean'
ORDER BY ORDINAL_POSITION;



-- CHECKING MANAGERID COLUMN
SELECT
    ManagerName,
    ManagerID,
    COUNT(*) AS [Emp Count]
FROM datamodel.EmployeeClean
GROUP BY ManagerName, ManagerID
ORDER BY ManagerName;
-- all are good



-- COLUMNS QUALITY CHECKING
SELECT
    COUNT(*) AS [Total Records],  -- 311
    COUNT(DISTINCT EmpID) AS [Unique EmpID],  -- 311
    SUM(CASE WHEN ManagerID IS NULL THEN 1 ELSE 0 END) AS [Blank/Null ManagerID],  -- 0
    COUNT(DISTINCT ManagerID) AS [Unique ManagerID],  -- 21
    COUNT(DISTINCT ManagerName) AS [Unique ManagerName],  -- 21
    COUNT(DISTINCT HispanicLatino COLLATE Latin1_General_BIN2) AS [HispanicLatino unique values],  -- 2
    SUM(CASE WHEN DateofTermination IS NULL THEN 1 ELSE 0 END) AS [Blank/Null DateofTermination],  -- 207
    SUM(CASE
            WHEN Salary IS NULL OR EngagementSurvey IS NULL OR EmpSatisfaction IS NULL
              OR SpecialProjectsCount IS NULL OR DaysLateLast30 IS NULL OR Absences IS NULL
              OR EmpID IS NULL OR MaritalStatusID IS NULL OR GenderID IS NULL
              OR FromDiversityJobFairID IS NULL OR Termd IS NULL OR PositionID IS NULL
              OR DOB IS NULL OR DateofHire IS NULL OR LastPerformanceReview_Date IS NULL
              OR HispanicLatino IS NULL
            THEN 1
            ELSE 0
        END) AS [Unexpected Blanks/Nulls],  -- 0
    SUM(CASE
            WHEN DATALENGTH(EmployeeName) <> DATALENGTH(TRIM(EmployeeName))
              OR DATALENGTH(Sex) <> DATALENGTH(TRIM(Sex))
              OR DATALENGTH(Department) <> DATALENGTH(TRIM(Department))
              OR DATALENGTH(Position) <> DATALENGTH(TRIM(Position))
            THEN 1
            ELSE 0
        END) AS [Records with hidden spaces],  -- 0
    MIN(Salary) AS [Min Salary],  -- 45046.00
    MAX(Salary) AS [Max Salary],  -- 250000.00
    SUM(ReviewDateIssue) AS [ReviewDateIssue]  -- 2
FROM datamodel.EmployeeClean; 


-- CREATED REVIEW DATE ISSUE COLUMN CHECK
SELECT
    EmpID,
    EmployeeName,
    DateofHire,
    LastPerformanceReview_Date
FROM datamodel.EmployeeClean
WHERE ReviewDateIssue = 1;




--===================================================================================
-- SECTION 4: DIMENSION TABLE CREATION
--===================================================================================


-- CREATING DIMENSION DEPARTMENT TABLE
--------------------------------------------------------------------------------------
DROP TABLE IF EXISTS datamodel.Dim_Department;
GO


CREATE TABLE datamodel.Dim_Department (
    DepartmentID INT PRIMARY KEY,
    Department NVARCHAR(100) NOT NULL
);
GO

INSERT INTO datamodel.Dim_Department (DepartmentID, Department)
VALUES
    (1, 'Admin Offices'),
    (2, 'Executive Office'),
    (3, 'IT/IS'),
    (4, 'Software Engineering'),
    (5, 'Production'),
    (6, 'Sales');
GO

-- CHECK
SELECT * FROM datamodel.Dim_Department;


-- CHECKING Employees with NULL ID
SELECT
    COUNT(*) AS [Unmatched Employees]
FROM datamodel.EmployeeClean AS ec
LEFT JOIN datamodel.Dim_Department AS dm
       ON ec.Department = dm.Department
WHERE dm.DepartmentID IS NULL;



-- CREATING DIMENSION POSITION TABLE
--------------------------------------------------------------------------------------
DROP TABLE IF EXISTS datamodel.Dim_Position;
GO


CREATE TABLE datamodel.Dim_Position (
    PositionID INT IDENTITY(1, 1) PRIMARY KEY,
    Position NVARCHAR(100) NOT NULL,
    DepartmentID INT NOT NULL,
    CONSTRAINT FK_Dim_Position_Dim_Department FOREIGN KEY(DepartmentID) REFERENCES datamodel.Dim_Department(DepartmentID) 
);
GO


INSERT INTO datamodel.Dim_Position(Position, DepartmentID)
SELECT DISTINCT
    ec.Position,
    dd.DepartmentID
FROM datamodel.EmployeeClean ec
JOIN datamodel.Dim_Department dd
    ON ec.Department = dd.Department
ORDER BY ec.Position;
GO

SELECT * FROM datamodel.Dim_Position;


-- CHECKING DUPLICATE POSITION
SELECT
    COUNT(*) AS [Total Records],
    COUNT(DISTINCT Position) AS [Unique Positions]
FROM datamodel.Dim_Position;


-- CHECKING Employees with NULL ID
SELECT
    COUNT(*) AS [Unmatched Employees]
FROM datamodel.EmployeeClean AS ec
LEFT JOIN datamodel.Dim_Position AS ps
       ON ec.PositionID = ps.PositionID
WHERE ps.PositionID IS NULL;




-- CREATING DIMENSION MANAGER TABLE
--------------------------------------------------------------------------------------
DROP TABLE IF EXISTS datamodel.Dim_Manager;
GO

CREATE TABLE datamodel.Dim_Manager (
    ManagerID INT PRIMARY KEY,
    ManagerName NVARCHAR(100) NOT NULL
);
GO

INSERT INTO datamodel.Dim_Manager(ManagerID, ManagerName)
SELECT DISTINCT
    ManagerID,
    ManagerName
FROM datamodel.EmployeeClean
ORDER BY ManagerID;
GO

-- CHECK
SELECT * FROM datamodel.Dim_Manager ORDER BY ManagerID;

-- CHECKING DUPLICATE MANAGER NAMES
SELECT
    COUNT(*) AS [Total Records],
    COUNT(DISTINCT ManagerName) AS [Unique Managers]
FROM datamodel.Dim_Manager;


-- Confirming Results (To removing Stray IDs)
SELECT
    ManagerName,
    ManagerID,
    COUNT(*) AS [Emp Count]
FROM datamodel.EmployeeClean
WHERE ManagerName IN ('Brandon R. LeBlanc', 'Michael Albert')
GROUP BY ManagerName, ManagerID;


-- CHECKING Employees with NULL ID
SELECT
    COUNT(*) AS [Unmatched Employees]
FROM datamodel.EmployeeClean AS ec
LEFT JOIN datamodel.Dim_Manager AS mg
       ON ec.ManagerID = mg.ManagerID
WHERE mg.ManagerID IS NULL;



-- CREATING DIMENSION RECRUITMENT SOURCE TABLE
--------------------------------------------------------------------------------------
DROP TABLE IF EXISTS datamodel.Dim_RecruitmentSource;
GO

CREATE TABLE datamodel.Dim_RecruitmentSource (
    RecruitmentSourceID INT IDENTITY(1, 1) PRIMARY KEY,
    RecruitmentSource NVARCHAR(100)NOT NULL
);
GO

INSERT INTO datamodel.Dim_RecruitmentSource(RecruitmentSource)
SELECT DISTINCT
    RecruitmentSource
FROM datamodel.EmployeeClean
ORDER BY RecruitmentSource ASC;
GO


-- CHECK
SELECT * FROM datamodel.Dim_RecruitmentSource;


-- CHECKING DUPLICATE SOURCE NAMES
SELECT
    COUNT(*) AS [Total Records],
    COUNT(DISTINCT RecruitmentSource) AS [Unique Recruitment Sources]
FROM datamodel.Dim_RecruitmentSource;


-- CHECKING Employees with NULL ID
SELECT
    COUNT(*) AS [Unmatched Employees]
FROM datamodel.EmployeeClean AS ec
LEFT JOIN datamodel.Dim_RecruitmentSource AS rs
       ON ec.RecruitmentSource = rs.RecruitmentSource
WHERE rs.RecruitmentSourceID IS NULL;



-- CREATING DIMENSION PERFORMANCE SCORE TABLE
--------------------------------------------------------------------------------------
DROP TABLE IF EXISTS datamodel.Dim_PerformanceScore;
GO

CREATE TABLE datamodel.Dim_PerformanceScore (
    PerformanceScoreID INT PRIMARY KEY,
    PerformanceScore NVARCHAR(100) NOT NULL
);
GO

INSERT INTO datamodel.Dim_PerformanceScore(PerformanceScoreID, PerformanceScore)
VALUES
    (1, 'PIP'),
    (2, 'Needs Improvement'),
    (3, 'Fully Meets'),
    (4, 'Exceeds');
GO


-- CHECK
SELECT * FROM datamodel.Dim_PerformanceScore;


-- CHECKING Employees with NULL ID
SELECT
    COUNT(*) AS [Unmatched Employees]
FROM datamodel.EmployeeClean AS ec
LEFT JOIN datamodel.Dim_PerformanceScore AS ps
       ON ec.PerformanceScore = ps.PerformanceScore
WHERE ps.PerformanceScoreID IS NULL;



-- CREATING DIMENSION EMPLOYMENT STATUS TABLE
--------------------------------------------------------------------------------------
DROP TABLE IF EXISTS datamodel.Dim_EmploymentStatus;
GO

CREATE TABLE datamodel.Dim_EmploymentStatus (
    EmploymentStatusID INT IDENTITY(1, 1) PRIMARY KEY,
    EmploymentStatus NVARCHAR(100) NOT NULL
);
GO

INSERT INTO datamodel.Dim_EmploymentStatus (EmploymentStatus)
SELECT DISTINCT
    EmploymentStatus
FROM datamodel.EmployeeClean
ORDER BY EmploymentStatus ASC;


-- CHECK
SELECT * FROM datamodel.Dim_EmploymentStatus;


-- CHECKING DUPLICATE SOURCE NAMES
SELECT
    COUNT(*) AS [Total Records],
    COUNT(DISTINCT EmploymentStatus) AS [Unique Employment Status]
FROM datamodel.Dim_EmploymentStatus;


-- CHECKING Employees with NULL ID
SELECT
    COUNT(*) AS [Unmatched Employees]
FROM datamodel.EmployeeClean AS ec
LEFT JOIN datamodel.Dim_EmploymentStatus AS es
       ON ec.EmploymentStatus = es.EmploymentStatus
WHERE es.EmploymentStatusID IS NULL;




-- CREATING DIMENSION TERMINATION REASON TABLE
--------------------------------------------------------------------------------------
DROP TABLE IF EXISTS datamodel.Dim_TermReason;
GO

CREATE TABLE datamodel.Dim_TermReason (
    TermReasonID INT IDENTITY(1, 1) PRIMARY KEY,
    TermReason NVARCHAR(100) NOT NULL
);
GO

INSERT INTO datamodel.Dim_TermReason(TermReason)
SELECT DISTINCT
    TermReason
FROM datamodel.EmployeeClean
ORDER BY TermReason ASC;


-- CHECK
SELECT * FROM datamodel.Dim_TermReason;


-- CHECKING DUPLICATE REASONS
SELECT
    COUNT(*) AS [Total Records],
    COUNT(DISTINCT TermReason) AS [Unique TermReason]
FROM datamodel.Dim_TermReason;


-- CHECKING Employees with NULL ID
SELECT
    COUNT(*) AS [Unmatched Employees]
FROM datamodel.EmployeeClean AS ec
LEFT JOIN datamodel.Dim_TermReason AS tr
       ON ec.TermReason = tr.TermReason
WHERE tr.TermReasonID IS NULL;




-- CREATING DIMENSION EMPLOYEE DETAILS TABLE
--------------------------------------------------------------------------------------
DROP TABLE IF EXISTS datamodel.Dim_Employee;
GO

CREATE TABLE datamodel.Dim_Employee (
    EmpID INT PRIMARY KEY,
    EmployeeName NVARCHAR(100) NOT NULL,
    DOB DATE NOT NULL,
    Sex NVARCHAR(20) NOT NULL,
    MaritalDesc NVARCHAR(50) NOT NULL,
    CitizenDesc NVARCHAR(50) NOT NULL,
    HispanicLatino NVARCHAR(5) NOT NULL,
    RaceDesc NVARCHAR(100) NOT NULL,
    State NVARCHAR(3) NOT NULL,
    Zip NVARCHAR(5) NOT NULL
);
GO


INSERT INTO datamodel.Dim_Employee(EmpID, EmployeeName, DOB, Sex, MaritalDesc, CitizenDesc, HispanicLatino, RaceDesc, State, Zip)
SELECT
    EmpID,
    EmployeeName,
    DOB,
    Sex,
    MaritalDesc,
    CitizenDesc,
    HispanicLatino,
    RaceDesc,
    State,
    Zip
FROM datamodel.EmployeeClean
ORDER BY EmpID;


-- CHECK
SELECT * FROM datamodel.Dim_Employee;


-- CHECKING DUPLICATES EMPLOYEE ID
SELECT
    COUNT(*) AS [Total Records],
    COUNT(DISTINCT EmpID) AS [Unique EmpID]
FROM datamodel.Dim_Employee;


-- CHECKING FOR THE ZIP COLUMN LEADING ZEROS ARE SURVIVED OR NOT
SELECT
    COUNT(*) AS [Zip Starting With 0]
FROM datamodel.Dim_Employee
WHERE Zip LIKE '0%';
-- 287 Records - Yes survived.




-- CREATING DIMENSION DATE TABLE
--------------------------------------------------------------------------------------
DROP TABLE IF EXISTS Datamodel.Dim_Date;
GO

CREATE TABLE datamodel.Dim_Date (
    [Date] DATE PRIMARY KEY,
    [Year] INT NOT NULL,
    [Quarter] INT NOT NULL,
    [QuarterName] NVARCHAR(5) NOT NULL,
    [Month] INT NOT NULL,
    [MonthName] NVARCHAR(25) NOT NULL,
    [MonthYear] NVARCHAR(25) NOT NULL,
    [MonthYearSort] INT NOT NULL,
    [DayofWeekNumber] INT NOT NULL,
    [DayName] NVARCHAR(25) NOT NULL
);
GO

SELECT * FROM datamodel.Dim_Date;


-- INSERT DATA TO DATE TABLE
WITH DateRange AS (
    SELECT
        DATEFROMPARTS(YEAR(MIN(DateofHire)), 1, 1) AS [StartDate],
        DATEFROMPARTS(YEAR(MAX(LastPerformanceReview_Date)), 12, 31) AS [EndDate]
    FROM datamodel.EmployeeClean
),
Date_Build AS (
    SELECT
        StartDate,
        EndDate
    FROM DateRange

    UNION ALL

    SELECT
        DATEADD(Day, 1, StartDate),
        EndDate
    FROM Date_Build
    WHERE StartDate < EndDate
)
INSERT INTO datamodel.Dim_Date([Date], [Year], [Quarter], QuarterName, [Month], [MonthName], MonthYear, MonthYearSort, [DayofWeekNumber], [DayName])
SELECT
    StartDate,
    YEAR(StartDate),
    DATEPART(QUARTER, StartDate),
    'Q' + CAST(DATEPART(QUARTER, StartDate) AS NVARCHAR(1)),
    MONTH(StartDate),
    DATENAME(MONTH, StartDate),
    LEFT(DATENAME(MONTH, StartDate), 3) + ' ' + CAST(YEAR(StartDate) AS NVARCHAR(4)),
    YEAR(StartDate)*100 + MONTH(StartDate),
    DATEPART(WEEKDAY, StartDate),
    DATENAME(WEEKDAY, StartDate)
FROM Date_Build
OPTION (MAXRECURSION 0); -- Since we are using recursive CTE it limit 100 levels, so this option removes default 100 limit
-- For a daily calendar, one level equals one day, so the default would stop after 100 days.


-- CHECK
SELECT * FROM datamodel.Dim_Date
-- 5113 Records


-- DATE RANGE CHECK
SELECT
    MIN([Date])            AS [Min Date],
    MAX([Date])            AS [Max Date],
    COUNT(*)               AS [Total Records],
    COUNT(DISTINCT [Date]) AS [Unique Dates]
FROM datamodel.Dim_Date;




-- CREATING FACT EMPLOYMENT TABLE
--------------------------------------------------------------------------------------
DROP TABLE IF EXISTS datamodel.Fact_Employment;
GO

CREATE TABLE datamodel.Fact_Employment (
    EmpID INT PRIMARY KEY NOT NULL,
    DepartmentID INT NOT NULL,
    PositionID INT NOT NULL,
    ManagerID INT NOT NULL,
    RecruitmentSourceID INT NOT NULL,
    PerformanceScoreID INT NOT NULL,
    EmploymentStatusID INT NOT NULL,
    TermReasonID INT NOT NULL,
    HireDate DATE NOT NULL,
    TerminationDate DATE NULL,
    LastReviewDate DATE NOT NULL,
    Salary DECIMAL(10, 2) NOT NULL,
    EngagementSurvey DECIMAL(5, 2),
    EmpSatisfaction INT NOT NULL,
    SpecialProjectCount INT NOT NULL,
    DaysLateLast30 INT NOT NULL,
    Absences INT NOT NULL,
    Termd INT NOT NULL,
    FromDiversityJobFairID INT NOT NULL,
    ReviewDateIssue INT NOT NULL,
    EmpCurrentStatus NVARCHAR(50),
    DiversityJobFairHire NVARCHAR(50),
    ReviewDateIssueFlag NVARCHAR(50)
    CONSTRAINT FK_Fact_Employee FOREIGN KEY(EmpID) REFERENCES datamodel.Dim_Employee(EmpID),
    CONSTRAINT FK_Fact_Department FOREIGN KEY(DepartmentID) REFERENCES datamodel.Dim_Department(DepartmentID),
    CONSTRAINT FK_Fact_Psition FOREIGN KEY(PositionID) REFERENCES datamodel.Dim_Position(PositionID),
    CONSTRAINT FK_Fact_Manager FOREIGN KEY(ManagerID) REFERENCES datamodel.Dim_Manager(ManagerID),
    CONSTRAINT FK_Fact_RecruitmentSource FOREIGN KEY(RecruitmentSourceID) REFERENCES datamodel.Dim_RecruitmentSource(RecruitmentSourceID),
    CONSTRAINT FK_Fact_PerformanceScore FOREIGN KEY(PerformanceScoreID) REFERENCES datamodel.Dim_PerformanceScore(PerformanceScoreID),
    CONSTRAINT FK_Fact_EmploymentStatus FOREIGN KEY(EmploymentStatusID) REFERENCES datamodel.Dim_EmploymentStatus(EmploymentStatusID),
    CONSTRAINT FK_Fact_TermReason FOREIGN KEY(TermReasonID) REFERENCES datamodel.Dim_TermReason(TermReasonID),
    CONSTRAINT FK_Fact_HireDate FOREIGN KEY(HireDate) REFERENCES datamodel.Dim_Date(Date),
    CONSTRAINT FK_Fact_TerminationDate FOREIGN KEY(TerminationDate) REFERENCES datamodel.Dim_Date(Date),
    CONSTRAINT FK_Fact_LastReviewDate FOREIGN KEY(LastReviewDate) REFERENCES datamodel.Dim_Date(Date),
);
GO


INSERT INTO datamodel.Fact_Employment (
    EmpID, DepartmentID, PositionID, ManagerID, RecruitmentSourceID, PerformanceScoreID, EmploymentStatusID, TermReasonID,
    HireDate, TerminationDate, LastReviewDate, Salary, EngagementSurvey, EmpSatisfaction, SpecialProjectCount, DaysLateLast30,
    Absences, Termd, FromDiversityJobFairID, ReviewDateIssue, EmpCurrentStatus, DiversityJobFairHire, ReviewDateIssueFlag)
SELECT
    de.EmpID,
    dd.DepartmentID,
    dp.PositionID,
    dm.ManagerID,
    rs.RecruitmentSourceID,
    ps.PerformanceScoreID,
    es.EmploymentStatusID,
    tr.TermReasonID,
    ec.DateofHire,
    ec.DateofTermination,
    ec.LastPerformanceReview_Date,
    ec.Salary,
    ec.EngagementSurvey,
    ec.EmpSatisfaction,
    ec.SpecialProjectsCount,
    ec.DaysLateLast30,
    ec.Absences,
    ec.Termd,
    ec.FromDiversityJobFairID,
    ec.ReviewDateIssue,
    CASE
        WHEN Termd = 1 THEN 'Terminated' 
        ELSE 'Active'
    END AS [EmpCurrentStatus],
    CASE
        WHEN FromDiversityJobFairID = 1 THEN 'Yes'
        ELSE 'No'
    END AS [DiversityJobFairHire],
    CASE
        WHEN ReviewDateIssue = 1 THEN 'Yes'
        ELSE 'No'
    END AS [ReviewDateIssueFlag]
FROM datamodel.EmployeeClean ec
LEFT JOIN datamodel.Dim_Employee de
    ON ec.EmpID = de.EmpID
LEFT JOIN datamodel.Dim_Department dd
    ON ec.Department = dd.Department
LEFT JOIN datamodel.Dim_Position dp
    ON ec.Position = dp.Position
LEFT JOIN datamodel.Dim_Manager dm
    ON ec.ManagerID = dm.ManagerID
LEFT JOIN datamodel.Dim_RecruitmentSource rs
    ON ec.RecruitmentSource = rs.RecruitmentSource
LEFT JOIN datamodel.Dim_PerformanceScore ps
    ON ec.PerformanceScore = ps.PerformanceScore
LEFT JOIN datamodel.Dim_EmploymentStatus es
    ON ec.EmploymentStatus = es.EmploymentStatus
LEFT JOIN datamodel.Dim_TermReason tr
    ON ec.TermReason = tr.TermReason
ORDER BY ec.EmpID;
GO


-- CHECK
SELECT * FROM datamodel.Fact_Employment;

-- DUPLICATE EMPID CHECK
SELECT
    COUNT(*) AS [Total Records],  -- 311
    COUNT(DISTINCT EmpID) AS [Unique EmpID],  -- 311
    SUM(CASE WHEN TerminationDate IS NULL THEN 1 ELSE 0 END) AS [Blank/Null TerminationDate]  -- 207
FROM datamodel.Fact_Employment;


-- CHECKING VALUES OF TWO TABLES ARE SAME OR NOT
SELECT
    'Fact_Employment' AS [Source],
    COUNT(*) AS [Total Records],
    SUM(Salary) AS [Total Salary],
    SUM(Termd) AS [Terminated],
    SUM(ReviewDateIssue) AS [Review Issues],
    SUM(Absences) AS [Total Absences],
    SUM(SpecialProjectCount) AS [Total Projects]
FROM datamodel.Fact_Employment

UNION ALL

SELECT
    'EmployeeClean',
    COUNT(*),
    SUM(Salary),
    SUM(Termd),
    SUM(ReviewDateIssue),
    SUM(Absences),
    SUM(SpecialProjectsCount)
FROM datamodel.EmployeeClean;



SELECT
    EmpCurrentStatus,
    COUNT(EmpCurrentStatus) AS [Total Emp]
FROM datamodel.Fact_Employment
GROUP BY EmpCurrentStatus;


SELECT
    DiversityJobFairHire,
    COUNT(DiversityJobFairHire) AS [Total Emp]
FROM datamodel.Fact_Employment
GROUP BY DiversityJobFairHire;


SELECT 
    RecruitmentSource,
    FromDiversityJobFairID,
    COUNT(*) AS [Total Emp]
FROM datamodel.EmployeeClean
GROUP BY RecruitmentSource, FromDiversityJobFairID;


SELECT
    ReviewDateIssueFlag,
    COUNT(ReviewDateIssueFlag) AS [Total Emp]
FROM datamodel.Fact_Employment
GROUP BY ReviewDateIssueFlag;


SELECT TOP(1) * FROM datamodel.Fact_Employment;
GO



--===================================================================================
-- SECTION 5: DATA ANALYSIS
--===================================================================================


--===================================================================================
-- SECTION 5A: WORKFORCE OVERVIEW
--===================================================================================

CREATE OR ALTER VIEW reporting.vw_Workforce_Overview AS
SELECT
    de.EmpID,
    de.EmployeeName,
    dd.Department,
    dp.Position,
    dm.ManagerName,
    es.EmploymentStatus,
    fe.EmpCurrentStatus
FROM datamodel.Fact_Employment fe
JOIN datamodel.Dim_Employee de
    ON fe.EmpID = de.EmpID
LEFT JOIN datamodel.Dim_Department dd
    ON fe.DepartmentID = dd.DepartmentID
LEFT JOIN datamodel.Dim_Position dp
    ON fe.PositionID = dp.PositionID
LEFT JOIN datamodel.Dim_Manager dm
    ON fe.ManagerID = dm.ManagerID
LEFT JOIN datamodel.Dim_EmploymentStatus es
    ON fe.EmploymentStatusID = es.EmploymentStatusID;
 GO   

SELECT
    COUNT(*) AS [Total Records],  -- 311
    COUNT(DISTINCT EmpID) AS [Unique EmpID]  -- 311
FROM reporting.vw_Workforce_Overview;


-- TOTAL EMPLOYEES, ACTIVE, TERMINATED
SELECT
    COUNT(EmpID) AS [Total Employees],
    SUM(CASE WHEN EmpCurrentStatus = 'Active' THEN 1 ELSE 0 END) AS [Active Employees],
    SUM(CASE WHEN EmpCurrentStatus = 'Terminated' THEN 1 ELSE 0 END) AS [Terminated Employees]
FROM reporting.vw_Workforce_Overview
/* Total Employees = 311, Active = 207, Terminated = 104 */


-- DEPARTMENT WISE WORKFORCE DISTRIBUTION
SELECT
    Department,
    COUNT(EmpID) AS [Total Employees],
    SUM(CASE WHEN EmpCurrentStatus = 'Active' THEN 1 ELSE 0 END) AS [Active Employees],
    SUM(CASE WHEN EmpCurrentStatus = 'Terminated' THEN 1 ELSE 0 END) AS [Terminated Employees],
    CAST(
        100.0 * SUM(CASE WHEN EmpCurrentStatus = 'Active' THEN 1 ELSE 0 END)
        / SUM(SUM(CASE WHEN EmpCurrentStatus = 'Active' THEN 1 ELSE 0 END)) OVER() 
    AS DECIMAL(10, 2)) AS [Active Share %]
FROM reporting.vw_Workforce_Overview
GROUP BY Department
ORDER BY [Total Employees] DESC;



-- POSITION WISE ACTIVE WORKFORCE DISTRIBUTION
SELECT
    Position,
    Department,
    SUM(CASE WHEN EmpCurrentStatus = 'Active' THEN 1 ELSE 0 END) AS [Active Employees]
FROM reporting.vw_Workforce_Overview
GROUP BY Position, Department
ORDER BY [Active Employees] DESC;


-- MANAGER WISE WORKFORCE DISTRIBUTION
SELECT
    ManagerName AS [Manager Name],
    COUNT(EmpID) AS [Total Employees],
    SUM(CASE WHEN EmpCurrentStatus = 'Active' THEN 1 ELSE 0 END) AS [Active Employees],
    SUM(CASE WHEN EmpCurrentStatus = 'Terminated' THEN 1 ELSE 0 END) AS [Terminated Employees]
FROM reporting.vw_Workforce_Overview
GROUP BY ManagerName
ORDER BY [Total Employees] DESC;


-- EMPLOYMENT STATUS DISTRIBUTION
SELECT
    EmploymentStatus,
    COUNT(EmpID) AS [Total Employees],
    CAST(
        100.0 * COUNT(EmpID) / SUM(COUNT(EmpID)) OVER()
    AS DECIMAL(10, 2)) AS [Emp %]
FROM reporting.vw_Workforce_Overview
GROUP BY EmploymentStatus
ORDER BY [Total Employees] DESC;


-- MANAGER TEAM SIZE
SELECT
    ManagerName AS [Manager Name],
    SUM(CASE WHEN EmpCurrentStatus = 'Active' THEN 1 ELSE 0 END) AS [Total Employess]
FROM reporting.vw_Workforce_Overview
GROUP BY ManagerName
ORDER BY [Total Employess] DESC, [Manager Name] ASC;
GO



--===================================================================================
-- SECTION 5B: GEOGRAPHICAL ANALYSIS
--===================================================================================

CREATE OR ALTER VIEW reporting.vw_Geographical_Analysis AS
SELECT
    de.EmpID,
    de.EmployeeName,
    de.State,
    de.Zip,
    dd.Department,
    dp.Position,
    es.EmploymentStatus,
    fe.EmpCurrentStatus
FROM datamodel.Fact_Employment fe
JOIN datamodel.Dim_Employee de
    ON fe.EmpID = de.EmpID
LEFT JOIN datamodel.Dim_Department dd
    ON fe.DepartmentID = dd.DepartmentID
LEFT JOIN datamodel.Dim_Position dp
    ON fe.PositionID = dp.PositionID
LEFT JOIN datamodel.Dim_EmploymentStatus es
    ON fe.EmploymentStatusID = es.EmploymentStatusID;
GO

SELECT
    COUNT(*) AS [Total Records],  -- 311
    COUNT(DISTINCT EmpID) AS [Unique EmpID]  -- 311
FROM reporting.vw_Geographical_Analysis;




-- STATE WISE DISTRIBUTION
SELECT
    State,
    COUNT(EmpID) AS [Total Employees],
    SUM(CASE WHEN EmpCurrentStatus = 'Active' THEN 1 ELSE 0 END) AS [Active Employees],
    SUM(CASE WHEN EmpCurrentStatus = 'Terminated' THEN 1 ELSE 0 END) AS [Terminated Employees],
    CAST(
        100.0 * COUNT(EmpID)
        / SUM(COUNT(EmpID)) OVER() 
    AS DECIMAL(10, 2)) AS [Employee Share %]
FROM reporting.vw_Geographical_Analysis
GROUP BY State
ORDER BY [Total Employees] DESC, State;



-- MASSACHUSETTS (MA) VS OTHER STATE
SELECT
    CASE WHEN State = 'MA' THEN 'Massachusetts' ELSE 'Other States' END AS [States],
    COUNT(EmpID) AS [Total Employees],
    SUM(CASE WHEN EmpCurrentStatus = 'Active' THEN 1 ELSE 0 END) AS [Active Employees],
    SUM(CASE WHEN EmpCurrentStatus = 'Terminated' THEN 1 ELSE 0 END) AS [Terminated Employees],
    CAST(
        100.0 * SUM(CASE WHEN EmpCurrentStatus = 'Terminated' THEN 1 ELSE 0 END)
        / COUNT(EmpID)
    AS DECIMAL(10, 2)) AS [Attrition Rate %]
FROM reporting.vw_Geographical_Analysis
GROUP BY CASE WHEN State = 'MA' THEN 'Massachusetts' ELSE 'Other States' END;



-- TOP 10 ZIP CODES BY COUNTS
SELECT TOP(10)
    Zip,
    State,
    COUNT(EmpID) AS [Total Employees]
FROM reporting.vw_Geographical_Analysis
GROUP BY Zip, State
ORDER BY [Total Employees] DESC, Zip;
GO



--===================================================================================
-- SECTION 5C: ATTRITION AND TURNOVER ANALYSIS
--===================================================================================


CREATE OR ALTER VIEW reporting.vw_Attrition_Analysis AS
SELECT
    de.EmpID,
    de.EmployeeName,
    dd.Department,
    dp.Position,
    dm.ManagerName,
    rs.RecruitmentSource,
    es.EmploymentStatus,
    fe.EmpCurrentStatus,
    tr.TermReason,
    YEAR(fe.HireDate) AS [HireYear],
    YEAR(fe.TerminationDate) AS [TerminationYear],
    CAST(DATEDIFF(DAY, fe.HireDate, fe.TerminationDate) / 365.25 AS DECIMAL(10, 2)) AS [TenureAtExitYear]
FROM datamodel.Fact_Employment fe
JOIN datamodel.Dim_Employee de
    ON fe.EmpID = de.EmpID
LEFT JOIN datamodel.Dim_Department dd
    ON fe.DepartmentID = dd.DepartmentID
LEFT JOIN datamodel.Dim_Position dp
    ON fe.PositionID = dp.PositionID
LEFT JOIN datamodel.Dim_Manager dm
    ON fe.ManagerID = dm.ManagerID
LEFT JOIN datamodel.Dim_RecruitmentSource rs
    ON fe.RecruitmentSourceID = rs.RecruitmentSourceID
LEFT JOIN datamodel.Dim_EmploymentStatus es
    ON fe.EmploymentStatusID = es.EmploymentStatusID
LEFT JOIN datamodel.Dim_TermReason tr
    ON fe.TermReasonID = tr.TermReasonID;
GO


SELECT
    COUNT(*) AS [Total Records],  -- 311
    COUNT(DISTINCT EmpID) AS [Unique EmpID]  -- 311
FROM reporting.vw_Attrition_Analysis;



-- TOTAL EMPLOYEES , TERMINATED, ATTRITION RATE
SELECT
    COUNT(EmpID) AS [Total Employees],
    SUM(CASE WHEN EmpCurrentStatus = 'Terminated' THEN 1 ELSE 0 END) AS [Terminated Employees],
    CAST(
        100.0 * SUM(CASE WHEN EmpCurrentStatus = 'Terminated' THEN 1 ELSE 0 END)
        / COUNT(EmpID)
    AS DECIMAL(10, 2)) AS [Attrition Rate %]
FROM reporting.vw_Attrition_Analysis;



-- DEPARTMENT WISE ATTRITION RATE
SELECT
    Department,
    COUNT(EmpID) AS [Total Employess],
    SUM(CASE WHEN EmpCurrentStatus = 'Terminated' THEN 1 ELSE 0 END) AS [Terminated Employees],
    CAST(
        100.0 * SUM(CASE WHEN EmpCurrentStatus = 'Terminated' THEN 1 ELSE 0 END)
        / COUNT(EmpID)
    AS DECIMAL(10, 2)) AS [Attrition Rate %]
FROM reporting.vw_Attrition_Analysis
GROUP BY Department
ORDER BY [Attrition Rate %] DESC;



-- POSITION WISE ATTRITION RATE
SELECT
    Position,
    COUNT(EmpID) AS [Total Employess],
    SUM(CASE WHEN EmpCurrentStatus = 'Terminated' THEN 1 ELSE 0 END) AS [Terminated Employees],
    CAST(
        100.0 * SUM(CASE WHEN EmpCurrentStatus = 'Terminated' THEN 1 ELSE 0 END)
        / COUNT(EmpID)
    AS DECIMAL(10, 2)) AS [Attrition Rate %]
FROM reporting.vw_Attrition_Analysis
GROUP BY Position
ORDER BY [Attrition Rate %] DESC;


-- MANAGER TEAM WISE ATTRITION RATE
SELECT
    ManagerName AS [Manager Name],
    COUNT(EmpID) AS [Total Employess],
    SUM(CASE WHEN EmpCurrentStatus = 'Terminated' THEN 1 ELSE 0 END) AS [Terminated Employees],
    CAST(
        100.0 * SUM(CASE WHEN EmpCurrentStatus = 'Terminated' THEN 1 ELSE 0 END)
        / COUNT(EmpID)
    AS DECIMAL(10, 2)) AS [Attrition Rate %]
FROM reporting.vw_Attrition_Analysis
GROUP BY ManagerName
ORDER BY [Attrition Rate %] DESC, [Manager Name] ASC;


-- TERMINATED VOLUNTARILY VS TERMINATED FOR CAUSE
SELECT
    EmploymentStatus AS [Employment Status],
    SUM(CASE WHEN EmpCurrentStatus = 'Terminated' THEN 1 ELSE 0 END) AS [Terminated Employees],
    CAST(
        100.0 * SUM(CASE WHEN EmpCurrentStatus = 'Terminated' THEN 1 ELSE 0 END)
        / SUM(SUM(CASE WHEN EmpCurrentStatus = 'Terminated' THEN 1 ELSE 0 END)) OVER()
    AS DECIMAL(10, 2)) AS [Termination %]
FROM reporting.vw_Attrition_Analysis
WHERE EmploymentStatus <> 'Active'
GROUP BY EmploymentStatus
ORDER BY [Terminated Employees] DESC;



-- ATTRITION BY TERMINATION REASON
SELECT
    TermReason AS [Termination Reason],
    SUM(CASE WHEN EmpCurrentStatus = 'Terminated' THEN 1 ELSE 0 END) AS [Terminated Employees],
    CAST(
        100.0 * SUM(CASE WHEN EmpCurrentStatus = 'Terminated' THEN 1 ELSE 0 END)
        / SUM(SUM(CASE WHEN EmpCurrentStatus = 'Terminated' THEN 1 ELSE 0 END)) OVER()
    AS DECIMAL(10, 2)) AS [Termination %]
FROM reporting.vw_Attrition_Analysis
WHERE EmploymentStatus <> 'Active'
GROUP BY TermReason
ORDER BY [Terminated Employees] DESC, TermReason ASC;



-- ATTRITION BY RECRUITMENT SOURCE
SELECT
    RecruitmentSource AS [Recruitment Source],
    COUNT(EmpID) AS [Total Employess],
    SUM(CASE WHEN EmpCurrentStatus = 'Terminated' THEN 1 ELSE 0 END) AS [Terminated Employees],
    CAST(
        100.0 * SUM(CASE WHEN EmpCurrentStatus = 'Terminated' THEN 1 ELSE 0 END)
        / COUNT(EmpID)
    AS DECIMAL(10, 2)) AS [Attrition Rate %]
FROM reporting.vw_Attrition_Analysis
GROUP BY RecruitmentSource
ORDER BY [Attrition Rate %] DESC, [Recruitment Source] ASC;


-- TERMINATION BY YEARS
SELECT
    TerminationYear AS [Termination Year],
    SUM(CASE WHEN EmpCurrentStatus = 'Terminated' THEN 1 ELSE 0 END) AS [Terminated Employees],
    CAST(
        100.0 * SUM(CASE WHEN EmpCurrentStatus = 'Terminated' THEN 1 ELSE 0 END)
        / SUM(SUM(CASE WHEN EmpCurrentStatus = 'Terminated' THEN 1 ELSE 0 END)) OVER()
    AS DECIMAL(10, 2)) AS [Termination %]
FROM reporting.vw_Attrition_Analysis
WHERE EmploymentStatus <> 'Active'
GROUP BY TerminationYear
ORDER BY [Termination Year] ASC;



-- ATTRITION BY TENURE BAND
WITH TenureYear AS (
SELECT
    *,
    CASE
        WHEN TenureAtExitYear < 1 THEN 'Less than 1 Year'
        WHEN TenureAtExitYear < 3 THEN '1-3 Years'
        WHEN TenureAtExitYear < 5 THEN '3-5 Years'
        ELSE '5+ Years'
    END AS [Tenure Band],
    CASE
        WHEN TenureAtExitYear < 1 THEN 1
        WHEN TenureAtExitYear < 3 THEN 2
        WHEN TenureAtExitYear < 5 THEN 3
        ELSE 4
    END AS [Sort Tenure Band]
FROM reporting.vw_Attrition_Analysis
WHERE EmpCurrentStatus = 'Terminated'
)
SELECT
    [Tenure Band],
    COUNT(*) AS [Terminated Employees],
    CAST(
        100.0 * COUNT(*) / SUM(COUNT(*)) OVER()
    AS DECIMAL(10, 2)) AS [Termination %]
FROM TenureYear
GROUP BY [Sort Tenure Band], [Tenure Band]
ORDER BY [Sort Tenure Band] ASC;
GO





--===================================================================================
-- SECTION 5D: HIRING AND TENURE ANALYSIS
--===================================================================================

CREATE OR ALTER VIEW reporting.vw_Hiring_Tenure_Analysis AS
SELECT
    de.EmpID,
    de.EmployeeName,
    dd.Department,
    dp.Position,
    rs.RecruitmentSource,
    fe.EmpCurrentStatus,
    fe.HireDate,
    fe.TerminationDate, 
    YEAR(fe.HireDate) AS [HireYear],
    CAST(
        DATEDIFF(DAY, fe.HireDate, COALESCE(fe.TerminationDate, MAX(fe.LastReviewDate) OVER())) / 365.25
    AS DECIMAL(10, 2)) AS [TenureYears]
FROM datamodel.Fact_Employment fe
JOIN datamodel.Dim_Employee de
    ON fe.EmpID = de.EmpID
LEFT JOIN datamodel.Dim_Department dd
    ON fe.DepartmentID = dd.DepartmentID
LEFT JOIN datamodel.Dim_Position dp
    ON fe.PositionID = dp.PositionID
LEFT JOIN datamodel.Dim_RecruitmentSource rs
    ON fe.RecruitmentSourceID = rs.RecruitmentSourceID;
GO


SELECT
    COUNT(*) AS [Total Records],  -- 311
    COUNT(DISTINCT EmpID) AS [Unique EmpID]  -- 311
FROM reporting.vw_Hiring_Tenure_Analysis;


-- HIRES BY YEAR
SELECT
    HireYear AS [Hiring Year],
    COUNT(EmpID) AS [Total Hires]
FROM reporting.vw_Hiring_Tenure_Analysis
GROUP BY HireYear
ORDER BY [Hiring Year] ASC;



-- AVERAGE TENURE - ACTIVE VS TERMINATED
SELECT
    EmpCurrentStatus AS [Employees Current Status],
    COUNT(EmpID) AS [Total Employees],
    CAST(AVG(TenureYears) AS DECIMAL(10, 2)) AS [Avg Tenure Years]
FROM reporting.vw_Hiring_Tenure_Analysis
GROUP BY EmpCurrentStatus
ORDER BY [Total Employees] DESC;


-- ACTIVE EMPLOYEES BY TENURE BAND
WITH TenureYear AS (
SELECT
    *,
    CASE
        WHEN TenureYears < 1 THEN 'Less than 1 Year'
        WHEN TenureYears < 3 THEN '1-3 Years'
        WHEN TenureYears < 5 THEN '3-5 Years'
        ELSE '5+ Years'
    END AS [Tenure Band],
    CASE
        WHEN TenureYears < 1 THEN 1
        WHEN TenureYears < 3 THEN 2
        WHEN TenureYears < 5 THEN 3
        ELSE 4
    END AS [Sort Tenure Band]
FROM reporting.vw_Hiring_Tenure_Analysis
WHERE EmpCurrentStatus = 'Active'
)
SELECT
    [Tenure Band],
    COUNT(*) AS [Active Employees],
    CAST(
        100.0 * COUNT(*) / SUM(COUNT(*)) OVER()
    AS DECIMAL(10, 2)) AS [Active %]
FROM TenureYear
GROUP BY [Sort Tenure Band], [Tenure Band]
ORDER BY [Sort Tenure Band] ASC;




-- AVERAGE TENURE BY DEPARTMENT
SELECT
    Department,
    COUNT(EmpID) AS [Total Employees],
    CAST(
        AVG(TenureYears)
    AS DECIMAL(10, 2)) AS [Avg Tenure Years]
FROM reporting.vw_Hiring_Tenure_Analysis
GROUP BY Department
ORDER BY [Total Employees] DESC;


-- HIRING BY YEAR AND DEPARTMENT
SELECT
    HireYear AS [Hiring Year],
    Department,
    COUNT(EmpID) AS [Total Hires]
FROM reporting.vw_Hiring_Tenure_Analysis
GROUP BY HireYear, Department
ORDER BY [Hiring Year] ASC;


-- AVERAGE TENURE BY POSITION
SELECT
    Position,
    CAST(AVG(TenureYears) AS DECIMAL(10, 2)) AS [Avg Tenure]
FROM reporting.vw_Hiring_Tenure_Analysis
GROUP BY Position
ORDER BY [Avg Tenure] DESC;
GO





--===================================================================================
-- SECTION 5E: COMPENSATION AND PAY EQUITY ANALYSIS
--===================================================================================

CREATE OR ALTER VIEW reporting.vw_Compensation_Analysis AS
SELECT
    de.EmpID,
    de.EmployeeName,
    dd.Department,
    dp.Position,
    de.Sex,
    ps.PerformanceScore,
    ps.PerformanceScoreID,
    fe.EmpCurrentStatus,
    fe.Salary,
    CASE
        WHEN fe.Salary < 50000 THEN 'Under 50K'
        WHEN fe.Salary < 75000 THEN '50K - 75K'
        WHEN fe.Salary < 100000 THEN '75K - 100K'
        WHEN fe.Salary < 125000 THEN '100K - 125K'
        ELSE '125K+'
     END AS [SalaryBand],
     CASE
        WHEN fe.Salary < 50000 THEN 1
        WHEN fe.Salary < 75000 THEN 2
        WHEN fe.Salary < 100000 THEN 3
        WHEN fe.Salary < 125000 THEN 4
        ELSE 5
     END AS [SortSalaryBand]
FROM datamodel.Fact_Employment fe
JOIN datamodel.Dim_Employee de
    ON fe.EmpID = de.EmpID
LEFT JOIN datamodel.Dim_Department dd
    ON fe.DepartmentID = dd.DepartmentID
LEFT JOIN datamodel.Dim_Position dp
    ON fe.PositionID = dp.PositionID
LEFT JOIN datamodel.Dim_PerformanceScore ps
    ON fe.PerformanceScoreID = ps.PerformanceScoreID;
GO


SELECT
    COUNT(*) AS [Total Records],  -- 311
    COUNT(DISTINCT EmpID) AS [Unique EmpID]  -- 311
FROM reporting.vw_Compensation_Analysis;


-- SALARY SUMMARY BY EMPLOYEE CURRENT STATUS
SELECT
    EmpCurrentStatus AS [Employee Current Status],
    COUNT(EmpID) AS [Total Employees],
    MIN(Salary) AS [Min Salary],
    MAX(Salary) AS [Max Salary],
    CAST(AVG(Salary) AS DECIMAL(10, 2)) AS [Avg Salary],
    SUM(Salary) AS [Total Salary]
FROM reporting.vw_Compensation_Analysis
GROUP BY EmpCurrentStatus
ORDER BY [Total Employees] DESC;



-- AVERAGE SALARY BY DEPARTMENT FOR ACTIVE EMPLOYEES
SELECT
    Department,
    COUNT(EmpID) AS [Active Employees],
    CAST(AVG(Salary) AS DECIMAL(10, 2)) AS [Avg Salary],
    MIN(Salary) AS [Min Salary],
    MAX(Salary) AS [Max Salary]
FROM reporting.vw_Compensation_Analysis
WHERE EmpCurrentStatus = 'Active'
GROUP BY Department
ORDER BY [Avg Salary] DESC;


-- AVERAGE SALARY BY Gender FOR ACTIVE EMPLOYEES
SELECT
    CASE WHEN Sex = 'M' THEN 'Male' ELSE 'Female' END AS [Gender],
    COUNT(EmpID) AS [Active Employees],
    CAST(AVG(Salary) AS DECIMAL(10, 2)) AS [Avg Salary],
    MIN(Salary) AS [Min Salary],
    MAX(Salary) AS [Max Salary]
FROM reporting.vw_Compensation_Analysis
WHERE EmpCurrentStatus = 'Active'
GROUP BY CASE WHEN Sex = 'M' THEN 'Male' ELSE 'Female' END
ORDER BY [Active Employees] DESC;



-- PAY GAP WITHIN THE SAME POSITION B/N MALE AND FEMALE ACTIVE EMPLOYEES
SELECT
    Position,
    SUM(CASE WHEN Sex = 'F' THEN 1 ELSE 0 END) AS [# of Female Employees],
    SUM(CASE WHEN Sex = 'M' THEN 1 ELSE 0 END) AS [# of Male Employees],
    CAST(AVG(CASE WHEN Sex = 'F' THEN Salary END) AS DECIMAL(10, 2)) AS [Avg Female Salary],
    CAST(AVG(CASE WHEN Sex = 'M' THEN Salary END) AS DECIMAL(10, 2)) AS [Avg Male Salary],
    CAST(
        AVG(CASE WHEN Sex = 'M' THEN Salary END)
        - AVG(CASE WHEN Sex = 'F' THEN Salary END)
    AS DECIMAL(10, 2)) AS [Gap (M - F)],
    CAST(
        100.0 * (AVG(CASE WHEN Sex = 'M' THEN Salary END)
        - AVG(CASE WHEN Sex = 'F' THEN Salary END))
        / AVG(CASE WHEN Sex = 'F' THEN Salary END)
    AS DECIMAL(10, 2)) AS [Gap %]
FROM reporting.vw_Compensation_Analysis
WHERE EmpCurrentStatus = 'Active'
GROUP BY Position
HAVING COUNT(DISTINCT Sex) = 2
ORDER BY [Gap (M - F)] DESC, Position;



-- AVERAGE SALARY BY PERFORMANCE SCORE FOR ACTIVE EMPLOYEES
SELECT
    PerformanceScore AS [Performance Score],
    COUNT(EmpID) AS [Active Employees],
    CAST(AVG(Salary) AS DECIMAL(10, 2)) AS [Avg Salary]
FROM reporting.vw_Compensation_Analysis
WHERE EmpCurrentStatus = 'Active'
GROUP BY PerformanceScoreID, PerformanceScore
ORDER BY PerformanceScoreID ASC;



-- SALARY BAND
SELECT
    SalaryBand,
    COUNT(EmpID) AS [Active Employees],
    CAST(
        100.0 * COUNT(*) / SUM(COUNT(*)) OVER()
    AS DECIMAL(10, 2)) AS [Active %]
FROM reporting.vw_Compensation_Analysis
WHERE EmpCurrentStatus = 'Active'
GROUP BY SortSalaryBand, SalaryBand
ORDER BY SortSalaryBand ASC;




-- ATTRITION RATE BY SALARY BAND
SELECT
    SalaryBand,
    COUNT(EmpID) AS [Total Employees],
    SUM(CASE WHEN EmpCurrentStatus = 'Terminated' THEN 1 ELSE 0 END) AS [Terminated Employees],
    CAST(
        100.0 * SUM(CASE WHEN EmpCurrentStatus = 'Terminated' THEN 1 ELSE 0 END)
        / COUNT(EmpID)
    AS DECIMAL(10, 2)) AS [Attrition Rate %]
FROM reporting.vw_Compensation_Analysis
GROUP BY SortSalaryBand, SalaryBand
ORDER BY SortSalaryBand ASC;


---------------------------------------------------------------------------------------------
-- FOLLOW-UP: IS THE PAY EFFECT JUST A PRODUCTION EFFECT?
---------------------------------------------------------------------------------------------

-- ATTRITION RATE BY SALARY BAND FOR PRODUCTION DEPARTMENT
SELECT
    SalaryBand,
    COUNT(EmpID) AS [Total Employees],
    SUM(CASE WHEN EmpCurrentStatus = 'Terminated' THEN 1 ELSE 0 END) AS [Terminated Employees],
    CAST(
        100.0 * SUM(CASE WHEN EmpCurrentStatus = 'Terminated' THEN 1 ELSE 0 END)
        / COUNT(EmpID)
    AS DECIMAL(10, 2)) AS [Attrition Rate %]
FROM reporting.vw_Compensation_Analysis
WHERE Department = 'Production'
GROUP BY SortSalaryBand, SalaryBand
ORDER BY SortSalaryBand ASC;


-- ATTRITION RATE BY SALARY BAND FOR ALL DEPARTMENTS EXCEPT PRODUCTION DEPARTMENT
SELECT
    SalaryBand,
    COUNT(EmpID) AS [Total Employees],
    SUM(CASE WHEN EmpCurrentStatus = 'Terminated' THEN 1 ELSE 0 END) AS [Terminated Employees],
    CAST(
        100.0 * SUM(CASE WHEN EmpCurrentStatus = 'Terminated' THEN 1 ELSE 0 END)
        / COUNT(EmpID)
    AS DECIMAL(10, 2)) AS [Attrition Rate %]
FROM reporting.vw_Compensation_Analysis
WHERE Department <> 'Production'
GROUP BY SortSalaryBand, SalaryBand
ORDER BY SortSalaryBand ASC;
GO





--===================================================================================
-- SECTION 5F: PERFORMANCE (SCORE) ANALYSIS
--===================================================================================

CREATE OR ALTER VIEW reporting.vw_Performance_Analysis AS
SELECT
    de.EmpID,
    de.EmployeeName,
    dd.Department,
    dp.Position,
    dm.ManagerName,
    ps.PerformanceScoreID,
    ps.PerformanceScore,
    fe.EmpCurrentStatus,
    fe.Salary,
    fe.SpecialProjectCount
FROM datamodel.Fact_Employment fe
JOIN datamodel.Dim_Employee de
    ON fe.EmpID = de.EmpID
LEFT JOIN datamodel.Dim_Department dd
    ON fe.DepartmentID = dd.DepartmentID
LEFT JOIN datamodel.Dim_Position dp
    ON fe.PositionID = dp.PositionID
LEFT JOIN datamodel.Dim_Manager dm
    ON fe.ManagerID = dm.ManagerID
LEFT JOIN datamodel.Dim_PerformanceScore ps
    ON fe.PerformanceScoreID = ps.PerformanceScoreID;
GO


SELECT
    COUNT(*) AS [Total Records],  -- 311
    COUNT(DISTINCT EmpID) AS [Unique EmpID]  -- 311
FROM reporting.vw_Performance_Analysis;



-- PERFORMANCE DISTRIBUTION
SELECT
    PerformanceScore AS [Performance Score],
    COUNT(EmpID) AS [Total Employees],
    CAST(
        100.0 * COUNT(EmpID) / SUM(COUNT(EmpID)) OVER()
    AS DECIMAL(10, 2)) AS [Employee %]
FROM reporting.vw_Performance_Analysis
GROUP BY PerformanceScoreID, PerformanceScore
ORDER BY PerformanceScoreID ASC;



-- PERFORMANCE SCORE BY DEPARTMENT
SELECT
    Department,
    COUNT(EmpID) AS [Total Employees],
    SUM(CASE WHEN PerformanceScore = 'PIP' THEN 1 ELSE 0 END) AS [PIP Employees],
    SUM(CASE WHEN PerformanceScore = 'Needs Improvement' THEN 1 ELSE 0 END) AS [Needs Improvement Employees],
    SUM(CASE WHEN PerformanceScore = 'Fully Meets' THEN 1 ELSE 0 END) AS [Fully Meets Employees],
    SUM(CASE WHEN PerformanceScore = 'Exceeds' THEN 1 ELSE 0 END) AS [Exceeds Employees],
    CAST(
        100.0 * SUM(CASE WHEN PerformanceScore = 'Exceeds' THEN 1 ELSE 0 END)
        / COUNT(EmpID)
    AS DECIMAL(10, 2)) AS [Exceeds %]
FROM reporting.vw_Performance_Analysis
GROUP BY Department
ORDER BY [Total Employees] DESC, Department;



-- ATTRITION BY PERFORMANCE SCORE
SELECT
    PerformanceScore AS [Performance Score],
    COUNT(EmpID) AS [Total Employees],
    SUM(CASE WHEN EmpCurrentStatus = 'Terminated' THEN 1 ELSE 0 END) AS [Terminated Employees],
    CAST(
        100.0 * SUM(CASE WHEN EmpCurrentStatus = 'Terminated' THEN 1 ELSE 0 END)
        / COUNT(EmpID)
    AS DECIMAL(10, 2)) AS [Attrition Rate %]
FROM reporting.vw_Performance_Analysis
GROUP BY PerformanceScoreID, PerformanceScore
ORDER BY PerformanceScoreID ASC;


-- TOTAL SPECIAL PROJECTS BY PERFORMANCE SCORE
SELECT
    PerformanceScore AS [Performance Score],
    COUNT(EmpID) AS [Total Employees],
    SUM(CASE WHEN SpecialProjectCount > 0 THEN 1 ELSE 0 END) AS [Employee With Projects],
    CAST(
        100.0 * SUM(CASE WHEN SpecialProjectCount > 0 THEN 1 ELSE 0 END)
        / COUNT(EmpID)
    AS DECIMAL(10, 2)) AS [With Projects %],
    CAST(
        AVG(CAST(SpecialProjectCount AS DECIMAL(10, 2)))
    AS DECIMAL(10, 2)) AS [Avg Projects]
FROM reporting.vw_Performance_Analysis
GROUP BY PerformanceScoreID, PerformanceScore
ORDER BY PerformanceScoreID ASC;



-- SALARY BY PERFORMANCE SCORE
SELECT
    PerformanceScore AS [Performance Score],
    COUNT(EmpID) AS [Total Employees],
    CAST(AVG(Salary) AS DECIMAL(10, 2)) AS [Avg Salary],
    MIN(Salary) AS [Min Salary],
    MAX(Salary) AS [Max Salary]
FROM reporting.vw_Performance_Analysis
GROUP BY PerformanceScoreID, PerformanceScore
ORDER BY PerformanceScoreID ASC;
GO





--===================================================================================
-- SECTION 5G: ENGAGEMENT AND SATISFACTION ANALYSIS
--===================================================================================

CREATE OR ALTER VIEW reporting.vw_Engagement_Analysis AS
SELECT
    de.EmpID,
    de.EmployeeName,
    dd.Department,
    dp.Position,
    dm.ManagerName,
    fe.EmpCurrentStatus,
    fe.EngagementSurvey,
    fe.EmpSatisfaction,
    CASE
        WHEN fe.EngagementSurvey < 3.00 THEN 'Low'
        WHEN fe.EngagementSurvey < 4.00 THEN 'Medium'
        WHEN fe.EngagementSurvey >= 4.00 THEN 'High'
    END AS [EngagementLevel],
    CASE
        WHEN fe.EngagementSurvey < 3.00 THEN 1
        WHEN fe.EngagementSurvey < 4.00 THEN 2
        WHEN fe.EngagementSurvey >= 4.00 THEN 3
    END AS [SortEngagementLevel]
FROM datamodel.Fact_Employment fe
JOIN datamodel.Dim_Employee de
    ON fe.EmpID = de.EmpID
LEFT JOIN datamodel.Dim_Department dd
    ON fe.DepartmentID = dd.DepartmentID
LEFT JOIN datamodel.Dim_Position dp
    ON fe.PositionID = dp.PositionID
LEFT JOIN datamodel.Dim_Manager dm
    ON fe.ManagerID = dm.ManagerID;
GO


SELECT
    COUNT(*) AS [Total Records],  -- 311
    COUNT(DISTINCT EmpID) AS [Unique EmpID]  -- 311
FROM reporting.vw_Engagement_Analysis;



-- EMPLOYEES ENGAGEMENT AND SATISFACTION BY CURRENT STATUS
SELECT
    EmpCurrentStatus AS [Employee Status],
    COUNT(EmpID) AS [Total Employees],
    CAST(AVG(EngagementSurvey) AS DECIMAL(5, 2)) AS [Avg Engagement],
    CAST(AVG(CAST(EmpSatisfaction AS DECIMAL(5, 2))) AS DECIMAL(5, 2)) AS [Avg Satisfaction]
FROM reporting.vw_Engagement_Analysis
GROUP BY EmpCurrentStatus
order by [Total Employees] DESC;



-- EMPLOYEES ENGAGEMENT AND SATISFACTION BY DEPARTMENT
SELECT
    Department,
    COUNT(EmpID) AS [Total Employees],
    CAST(AVG(EngagementSurvey) AS DECIMAL(5, 2)) AS [Avg Engagement],
    CAST(AVG(CAST(EmpSatisfaction AS DECIMAL(5, 2))) AS DECIMAL(5, 2)) AS [Avg Satisfaction]
FROM reporting.vw_Engagement_Analysis
GROUP BY Department
ORDER BY [Avg Engagement] DESC;



-- EMPLOYEE ENGAGEMENT LEVEL DISTRIBUTION
SELECT
    EngagementLevel AS [Engagement Level],
    COUNT(EmpID) AS [Total Employees],
    CAST(
        100.0 * COUNT(EmpID) / SUM(COUNT(EmpID)) OVER()
    AS DECIMAL(10, 2)) AS [Employee %],
    SUM(CASE WHEN EmpCurrentStatus = 'Active' THEN 1 ELSE 0 END) AS [Active Employees],
    SUM(CASE WHEN EmpCurrentStatus = 'Terminated' THEN 1 ELSE 0 END) AS [Terminated Employees]
FROM reporting.vw_Engagement_Analysis
GROUP BY SortEngagementLevel, EngagementLevel
ORDER BY SortEngagementLevel ASC;




-- ATTRITION BY ENGAGEMENT LEVEL
SELECT
    EngagementLevel AS [Engagement Level],
    COUNT(EmpID) AS [Total Employees],
    CAST(
        100.0 * COUNT(EmpID) / SUM(COUNT(EmpID)) OVER()
    AS DECIMAL(10, 2)) AS [Employee %],
    SUM(CASE WHEN EmpCurrentStatus = 'Terminated' THEN 1 ELSE 0 END) AS [Terminated Employees],
    CAST(
        100.0 * SUM(CASE WHEN EmpCurrentStatus = 'Terminated' THEN 1 ELSE 0 END)
        / COUNT(EmpID)
    AS DECIMAL(10, 2)) AS [Attrition Rate %]
FROM reporting.vw_Engagement_Analysis
GROUP BY SortEngagementLevel, EngagementLevel
ORDER BY SortEngagementLevel ASC;



-- EMPLOYEE SATISFACTION SCORE DISTRIBUTION
SELECT
    EmpSatisfaction AS [Satisfaction Score],
    COUNT(EmpID) AS [Total Employees],
    CAST(
        100.0 * COUNT(EmpID) / SUM(COUNT(EmpID)) OVER()
    AS DECIMAL(10, 2)) AS [Employee %],
    SUM(CASE WHEN EmpCurrentStatus = 'Active' THEN 1 ELSE 0 END) AS [Active Employees],
    SUM(CASE WHEN EmpCurrentStatus = 'Terminated' THEN 1 ELSE 0 END) AS [Terminated Employees]
FROM reporting.vw_Engagement_Analysis
GROUP BY EmpSatisfaction
ORDER BY [Satisfaction Score] ASC;




-- ATTRITION BY EMPLOYEE SATISFACTION SCORE
SELECT
    EmpSatisfaction AS [Satisfaction Score],
    COUNT(EmpID) AS [Total Employees],
    SUM(CASE WHEN EmpCurrentStatus = 'Terminated' THEN 1 ELSE 0 END) AS [Terminated Employees],
    CAST(
        100.0 * SUM(CASE WHEN EmpCurrentStatus = 'Terminated' THEN 1 ELSE 0 END)
        / COUNT(EmpID)
    AS DECIMAL(10, 2)) AS [Attrition Rate %]
FROM reporting.vw_Engagement_Analysis
GROUP BY EmpSatisfaction
ORDER BY [Satisfaction Score] ASC;
GO



--===================================================================================
-- SECTION 5H: ATTENDENCE ANALYSIS
--===================================================================================

CREATE OR ALTER VIEW reporting.vw_Attendance_Analysis AS
SELECT
    de.EmpID,
    de.EmployeeName,
    dd.Department,
    dp.Position,
    dm.ManagerName,
    ps.PerformanceScoreID,
    ps.PerformanceScore,
    fe.EmpCurrentStatus,
    fe.Absences,
    fe.DaysLateLast30,
    CASE
        WHEN fe.Absences BETWEEN 1 AND 5 THEN '1-5 days'
        WHEN fe.Absences BETWEEN 6 AND 10 THEN '6-10 days'
        WHEN fe.Absences BETWEEN 11 AND 15 THEN '11-15 days'
        WHEN fe.Absences BETWEEN 16 AND 20 THEN '16-20 days'
    END AS [AbsenceBand],
    CASE
        WHEN fe.Absences BETWEEN 1 AND 5 THEN 1
        WHEN fe.Absences BETWEEN 6 AND 10 THEN 2
        WHEN fe.Absences BETWEEN 11 AND 15 THEN 3
        WHEN fe.Absences BETWEEN 16 AND 20 THEN 4
    END AS [SortAbsenceBand]
FROM datamodel.Fact_Employment fe
JOIN datamodel.Dim_Employee de
    ON fe.EmpID = de.EmpID
LEFT JOIN datamodel.Dim_Department dd
    ON fe.DepartmentID = dd.DepartmentID
LEFT JOIN datamodel.Dim_Position dp
    ON fe.PositionID = dp.PositionID
LEFT JOIN datamodel.Dim_Manager dm
    ON fe.ManagerID = dm.ManagerID
LEFT JOIN datamodel.Dim_PerformanceScore ps
    ON fe.PerformanceScoreID = ps.PerformanceScoreID;
GO


SELECT
    COUNT(*) AS [Total Records],  -- 311
    COUNT(DISTINCT EmpID) AS [Unique EmpID]  -- 311
FROM reporting.vw_Attendance_Analysis;


-- EMPLOYEE ATTENDENCE BY CURRENT STATUS
SELECT
    EmpCurrentStatus AS [Employee Current Status],
    COUNT(EmpID) AS [Total Employees],
    CAST(AVG(CAST(Absences AS DECIMAL(5,2))) AS DECIMAL(5, 2)) AS [Avg Absences],
    CAST(AVG(CAST(DaysLateLast30 AS DECIMAL(5,2))) AS DECIMAL(5, 2)) AS [Avg Days Late]
FROM reporting.vw_Attendance_Analysis
GROUP BY EmpCurrentStatus
ORDER BY [Total Employees] DESC;



-- EMPLOYEE ATTENDENCE BY DEPARTMENT
SELECT
    Department,
    COUNT(EmpID) AS [Total Employees],
    CAST(AVG(CAST(Absences AS DECIMAL(5,2))) AS DECIMAL(5, 2)) AS [Avg Absences],
    CAST(AVG(CAST(DaysLateLast30 AS DECIMAL(5,2))) AS DECIMAL(5, 2)) AS [Avg Days Late]
FROM reporting.vw_Attendance_Analysis
GROUP BY Department
ORDER BY [Avg Absences] DESC;


-- EMPLOYEE ATTENDENCE BY PERFORMANCE SCORE
SELECT
    PerformanceScore AS [Performance Score],
    COUNT(EmpID) AS [Total Employees],
    CAST(AVG(CAST(Absences AS DECIMAL(5,2))) AS DECIMAL(5, 2)) AS [Avg Absences],
    CAST(AVG(CAST(DaysLateLast30 AS DECIMAL(5,2))) AS DECIMAL(5, 2)) AS [Avg Days Late]
FROM reporting.vw_Attendance_Analysis
GROUP BY PerformanceScoreID, PerformanceScore
ORDER BY PerformanceScoreID ASC;


-- ATTRITION BY ABSENCES BAND
SELECT
    AbsenceBand AS [Absence Days],
    COUNT(EmpID) AS [Total Employees],
    SUM(CASE WHEN EmpCurrentStatus = 'Terminated' THEN 1 ELSE 0 END) AS [Terminated Employees],
    CAST(
        100.0 * SUM(CASE WHEN EmpCurrentStatus = 'Terminated' THEN 1 ELSE 0 END)
        / COUNT(EmpID)
    AS DECIMAL(10, 2)) AS [Attrition Rate %]
FROM reporting.vw_Attendance_Analysis
GROUP BY SortAbsenceBand, AbsenceBand
ORDER BY SortAbsenceBand ASC;



-- LATENESS VS ATTRITION
WITH LatenessGroup AS (
    SELECT
        *,
        CASE
            WHEN DaysLateLast30 = 0 THEN 'Never Late (0 days)'
            ELSE 'Late (1+ days)'
        END AS [LatenessCategory],
        CASE
            WHEN DaysLateLast30 = 0 THEN 1
            ELSE 2
        END AS [SortLatenessCategory]
    FROM reporting.vw_Attendance_Analysis
)
SELECT
    LatenessCategory AS [Lateness Category],
    COUNT(EmpID) AS [Total Employees],
    SUM(CASE WHEN EmpCurrentStatus = 'Terminated' THEN 1 ELSE 0 END) AS [Terminated Employees],
    CAST(
        100.0 * SUM(CASE WHEN EmpCurrentStatus = 'Terminated' THEN 1 ELSE 0 END)
        / COUNT(EmpID)
    AS DECIMAL(10, 2)) AS [Attrition Rate %]
FROM LatenessGroup
GROUP BY SortLatenessCategory, LatenessCategory
ORDER BY SortLatenessCategory;
GO





--===================================================================================
-- SECTION 5I: RECRUITMENT ANALYSIS
--===================================================================================

CREATE OR ALTER VIEW reporting.vw_Recruitment_Analysis AS
SELECT
    de.EmpID,
    de.EmployeeName,
    dd.Department,
    dp.Position,
    rs.RecruitmentSource,
    ps.PerformanceScoreID,
    ps.PerformanceScore,
    fe.EmpCurrentStatus,
    YEAR(fe.HireDate) AS [HireYear],
    fe.Salary
FROM datamodel.Fact_Employment fe
JOIN datamodel.Dim_Employee de
    ON fe.EmpID = de.EmpID
LEFT JOIN datamodel.Dim_Department dd
    ON fe.DepartmentID = dd.DepartmentID
LEFT JOIN datamodel.Dim_Position dp
    ON fe.PositionID = dp.PositionID
LEFT JOIN datamodel.Dim_RecruitmentSource rs
    ON fe.RecruitmentSourceID = rs.RecruitmentSourceID
LEFT JOIN datamodel.Dim_PerformanceScore ps
    ON fe.PerformanceScoreID = ps.PerformanceScoreID;
GO


SELECT
    COUNT(*) AS [Total Records],  -- 311
    COUNT(DISTINCT EmpID) AS [Unique EmpID]  -- 311
FROM reporting.vw_Recruitment_Analysis;



-- HIRE BY RECRUITMENT SOURCE
SELECT
    RecruitmentSource AS [Recruitment Source],
    COUNT(EmpID) AS [Total Hires],
    CAST(
        100.0 * COUNT(EmpID) / SUM(COUNT(EmpID)) OVER()
    AS DECIMAL(10, 2)) AS [All Hires Share %],
    SUM(CASE WHEN EmpCurrentStatus = 'Active' THEN 1 ELSE 0 END) AS [Active Employees],
    SUM(CASE WHEN EmpCurrentStatus = 'Terminated' THEN 1 ELSE 0 END) AS [Terminated Employees]
FROM reporting.vw_Recruitment_Analysis
GROUP BY RecruitmentSource
ORDER BY [Total Hires] DESC, [Recruitment Source];



-- PERFORMANCE MIX BY RECRUITMENT SOURCE
SELECT
    RecruitmentSource AS [Recruitment Source],
    COUNT(EmpID) AS [Total Hires],
    SUM(CASE WHEN PerformanceScore = 'PIP' THEN 1 ELSE 0 END) AS [PIP Employees],
    SUM(CASE WHEN PerformanceScore = 'Needs Improvement' THEN 1 ELSE 0 END) AS [Needs Improvement Employees],
    SUM(CASE WHEN PerformanceScore = 'Fully Meets' THEN 1 ELSE 0 END) AS [Fully Meets Employees],
    SUM(CASE WHEN PerformanceScore = 'Exceeds' THEN 1 ELSE 0 END) AS [Exceeds Employees],
    CAST(
        100.0 * SUM(CASE WHEN PerformanceScore = 'Exceeds' THEN 1 ELSE 0 END)
        / COUNT(EmpID)
    AS DECIMAL(10, 2)) AS [Exceeds %]
FROM reporting.vw_Recruitment_Analysis
GROUP BY RecruitmentSource
ORDER BY [Total Hires] DESC, [Recruitment Source];


-- ATTRITION BY RECRUITMENT SOURCE
SELECT
    RecruitmentSource AS [Recruitment Source],
    COUNT(EmpID) AS [Total Hires],
    SUM(CASE WHEN EmpCurrentStatus = 'Terminated' THEN 1 ELSE 0 END) AS [Terminated Employees],
    CAST(
        100.0 * SUM(CASE WHEN EmpCurrentStatus = 'Terminated' THEN 1 ELSE 0 END)
        / COUNT(EmpID)
    AS DECIMAL(10, 2)) AS [Attrition Rate %]
FROM reporting.vw_Recruitment_Analysis
GROUP BY RecruitmentSource
ORDER BY [Attrition Rate %] DESC;



-- ATTRITION BY RECRUITMENT SOURCE, PRODUCTION VS OTHER DEPARTMENTS
WITH DepartmentGroup AS (
    SELECT
        *,
        CASE 
            WHEN Department = 'Production' THEN 'Production Department'
            ELSE 'Other Departments'
        END AS [DepartmentCategory],
        CASE 
            WHEN Department = 'Production' THEN 1
            ELSE 2
        END AS [SortDepartmentCategory]
    FROM reporting.vw_Recruitment_Analysis
)
SELECT
    DepartmentCategory AS [Department Category],
    RecruitmentSource AS [Recruitment Source],
    COUNT(EmpID) AS [Total Hires],
    SUM(CASE WHEN EmpCurrentStatus = 'Terminated' THEN 1 ELSE 0 END) AS [Terminated Employees],
    CAST(
        100.0 * SUM(CASE WHEN EmpCurrentStatus = 'Terminated' THEN 1 ELSE 0 END)
        / COUNT(EmpID)
    AS DECIMAL(10, 2)) AS [Attrition Rate %]
FROM DepartmentGroup
GROUP BY SortDepartmentCategory, DepartmentCategory, RecruitmentSource
ORDER BY SortDepartmentCategory ASC, [Total Hires] DESC, [Recruitment Source];



-- DIVERSITY JOB FAIR VS ALL OTHER SOURCES
WITH SourceGroup AS (
    SELECT
        *,
        CASE 
            WHEN RecruitmentSource = 'Diversity Job Fair' THEN 'Diversity Job Fair'
            ELSE 'All Other Sources'
        END AS [RecruitmentSourceGroup]
    FROM reporting.vw_Recruitment_Analysis
)
SELECT
    RecruitmentSourceGroup AS [Recruitment Source],
    COUNT(EmpID) AS [Total Hires],
    SUM(CASE WHEN EmpCurrentStatus = 'Terminated' THEN 1 ELSE 0 END) AS [Terminated Employees],
    CAST(
        100.0 * SUM(CASE WHEN EmpCurrentStatus = 'Terminated' THEN 1 ELSE 0 END)
        / COUNT(EmpID)
    AS DECIMAL(10, 2)) AS [Attrition Rate %],
    CAST(
        100.0 * SUM(CASE WHEN PerformanceScore = 'Exceeds' THEN 1 ELSE 0 END)
        / COUNT(EmpID)
    AS DECIMAL(10, 2)) AS [Exceeds %]
FROM SourceGroup
GROUP BY RecruitmentSourceGroup
ORDER BY [Total Hires] DESC;
GO




--===================================================================================
-- SECTION 5j: DIVERSITY ANALYSIS
--===================================================================================

CREATE OR ALTER VIEW reporting.vw_Diversity_Analysis AS
WITH AgeCalculation AS (
    SELECT
        de.EmpID,
        dd.Department,
        de.Sex,
        de.RaceDesc,
        de.HispanicLatino,
        de.MaritalDesc,
        de.CitizenDesc,
        fe.EmpCurrentStatus,
        CAST(
            DATEDIFF(DAY, de.DOB, MAX(fe.LastReviewDate) OVER()) / 365.25
        AS INT) AS [Age]
    FROM datamodel.Fact_Employment fe
    JOIN datamodel.Dim_Employee de
        ON fe.EmpID = de.EmpID
    LEFT JOIN datamodel.Dim_Department dd
        ON fe.DepartmentID = dd.DepartmentID
)
SELECT
    EmpID,
    Department,
    Sex,
    RaceDesc,
    HispanicLatino,
    MaritalDesc,
    CitizenDesc,
    EmpCurrentStatus,
    CASE
        WHEN Age < 30 THEN 'Under 30'
        WHEN Age BETWEEN 30 AND 39 THEN '30-39'
        WHEN Age BETWEEN 40 AND 49 THEN '40-49'
        WHEN Age >= 50 THEN '50+'
    END AS [AgeGroup],
    CASE
        WHEN Age < 30 THEN 1
        WHEN Age BETWEEN 30 AND 39 THEN 2
        WHEN Age BETWEEN 40 AND 49 THEN 3
        WHEN Age >= 50 THEN 4
    END AS [SortAgeGroup]
FROM AgeCalculation;
GO


SELECT
    COUNT(*) AS [Total Records],  -- 311
    COUNT(DISTINCT EmpID) AS [Unique EmpID],  -- 311
    SUM(CASE WHEN AgeGroup IS NULL THEN 1 ELSE 0 END) AS [Null Age Group Records]  -- 0
FROM reporting.vw_Diversity_Analysis;


-- GENDER DISTRIBUTION
SELECT
    CASE WHEN Sex = 'F' THEN 'Female' ELSE 'Male' END AS [Gender],
    COUNT(*) AS [Total Employees],
    CAST(
        100.0 * COUNT(EmpID) / SUM(COUNT(EmpID)) OVER()
    AS DECIMAL(10, 2)) AS [Employee %]
FROM reporting.vw_Diversity_Analysis
GROUP BY CASE WHEN Sex = 'F' THEN 'Female' ELSE 'Male' END
ORDER BY [Total Employees] DESC;


-- RACE DISTRIBUTION
SELECT
    RaceDesc AS [Race],
    COUNT(EmpID) AS [Total Employees],
    CAST(
        100.0 * COUNT(EmpID) / SUM(COUNT(EmpID)) OVER()
    AS DECIMAL(10, 2)) AS [Employee %]
FROM reporting.vw_Diversity_Analysis
GROUP BY RaceDesc
ORDER BY [Total Employees] DESC, [Race];


-- AGE GROUP DISTRIBUTION
SELECT
    AgeGroup AS [Age Group],
    COUNT(EmpID) AS [Total Employees],
    CAST(
        100.0 * COUNT(EmpID) / SUM(COUNT(EmpID)) OVER()
    AS DECIMAL(10, 2)) AS [Employee %]
FROM reporting.vw_Diversity_Analysis
GROUP BY SortAgeGroup, AgeGroup
ORDER BY SortAgeGroup;


-- ATTRITION BY GENDER
SELECT
    CASE WHEN Sex = 'M' THEN 'Male' ELSE 'Female' END AS [Gender],
    COUNT(EmpID) AS [Total Employees],
    SUM(CASE WHEN EmpCurrentStatus = 'Active' THEN 1 ELSE 0 END) AS [Active Employees],
    SUM(CASE WHEN EmpCurrentStatus = 'Terminated' THEN 1 ELSE 0 END) AS [Terminated Employees],
    CAST(
        100.0 * SUM(CASE WHEN EmpCurrentStatus = 'Terminated' THEN 1 ELSE 0 END)
        / COUNT(EmpID)
    AS DECIMAL(10, 2)) AS [Attrition Rate %]
FROM reporting.vw_Diversity_Analysis
GROUP BY CASE WHEN Sex = 'M' THEN 'Male' ELSE 'Female' END
ORDER BY [Total Employees] DESC;



-- ATTRITION BY RACE
SELECT
    RaceDesc AS [Race],
    COUNT(EmpID) AS [Total Employees],
    SUM(CASE WHEN EmpCurrentStatus = 'Active' THEN 1 ELSE 0 END) AS [Active Employees],
    SUM(CASE WHEN EmpCurrentStatus = 'Terminated' THEN 1 ELSE 0 END) AS [Terminated Employees],
    CAST(
        100.0 * SUM(CASE WHEN EmpCurrentStatus = 'Terminated' THEN 1 ELSE 0 END)
        / COUNT(EmpID)
    AS DECIMAL(10, 2)) AS [Attrition Rate %]
FROM reporting.vw_Diversity_Analysis
GROUP BY RaceDesc
ORDER BY [Total Employees] DESC, Race;



-- ATTRITION BY AGE GROUP
SELECT
    AgeGroup AS [Age Group],
    COUNT(EmpID) AS [Total Employees],
    SUM(CASE WHEN EmpCurrentStatus = 'Active' THEN 1 ELSE 0 END) AS [Active Employees],
    SUM(CASE WHEN EmpCurrentStatus = 'Terminated' THEN 1 ELSE 0 END) AS [Terminated Employees],
    CAST(
        100.0 * SUM(CASE WHEN EmpCurrentStatus = 'Terminated' THEN 1 ELSE 0 END)
        / COUNT(EmpID)
    AS DECIMAL(10, 2)) AS [Attrition Rate %]
FROM reporting.vw_Diversity_Analysis
GROUP BY SortAgeGroup, AgeGroup
ORDER BY SortAgeGroup;



-- GENDER MIX BY DEPARTMENT
SELECT
    Department,
    COUNT(EmpID) AS [Active Employees],
    SUM(CASE WHEN Sex = 'F' THEN 1 ELSE 0 END) AS [Active Womens],
    SUM(CASE WHEN Sex = 'M' THEN 1 ELSE 0 END) AS [Active Men],
    CAST(
        100.0 * SUM(CASE WHEN Sex = 'F' THEN 1 ELSE 0 END)
        / COUNT(EmpID)
    AS DECIMAL(10, 2)) AS [Active Women Share %]
FROM reporting.vw_Diversity_Analysis
WHERE EmpCurrentStatus = 'Active'
GROUP BY Department
ORDER BY [Active Employees] DESC, Department;
GO




--===================================================================================
-- SECTION 5K: MANAGER EFFECTIVENESS ANALYSIS
--===================================================================================

CREATE OR ALTER VIEW reporting.vw_Manager_Analysis AS
SELECT
    fe.EmpID,
    dm.ManagerName,
    dd.Department,
    fe.EmpCurrentStatus,
    ps.PerformanceScoreID,
    ps.PerformanceScore,
    fe.EngagementSurvey,
    fe.EmpSatisfaction,
    fe.Salary,
    fe.Absences
FROM datamodel.Fact_Employment fe
JOIN datamodel.Dim_Employee de
    ON fe.EmpID = de.EmpID
LEFT JOIN datamodel.Dim_Department dd
    ON fe.DepartmentID = dd.DepartmentID
LEFT JOIN datamodel.Dim_Manager dm
    ON fe.ManagerID = dm.ManagerID
LEFT JOIN datamodel.Dim_PerformanceScore ps
    ON fe.PerformanceScoreID = ps.PerformanceScoreID;
GO


SELECT
    COUNT(*) AS [Total Records],  -- 311
    COUNT(DISTINCT EmpID) AS [Unique EmpID],  -- 311
    SUM(CASE WHEN ManagerName IS NULL THEN 1 ELSE 0 END) AS [Null Manager Name Records]  -- 0
FROM reporting.vw_Manager_Analysis;



-- MANAGER SCORECARD
SELECT
    ManagerName AS [Manager Name],
    COUNT(EmpID) AS [Total Employees Managed],
    SUM(CASE WHEN EmpCurrentStatus = 'Active' THEN 1 ELSE 0 END) AS [Active Employees],
    SUM(CASE WHEN EmpCurrentStatus = 'Terminated' THEN 1 ELSE 0 END) AS [Terminated Employees],
    CAST(
        100.0 * SUM(CASE WHEN EmpCurrentStatus = 'Terminated' THEN 1 ELSE 0 END)
        / COUNT(EmpID)
    AS DECIMAL(10, 2)) AS [Attrition Rate %],
    CAST(AVG(EngagementSurvey) AS DECIMAL(5, 2)) AS [Avg Engagement],
    CAST(AVG(CAST(EmpSatisfaction AS DECIMAL(5, 2))) AS DECIMAL(5, 2)) AS [Avg Satisfaction],
    CAST(
        100.0 * SUM(CASE WHEN PerformanceScore = 'Exceeds' THEN 1 ELSE 0 END)
        / COUNT(EmpID)
    AS DECIMAL(10, 2)) AS [Exceeds %]
FROM reporting.vw_Manager_Analysis
GROUP BY ManagerName
ORDER BY [Attrition Rate %] DESC, [Manager Name];



-- HOW MANY DEPARTMENTS EACH MANAGER HANDLE?
SELECT
    ManagerName AS [Manager Name],
    COUNT(DISTINCT Department) AS [Total Departments Handled],
    COUNT(EmpID) AS [Total Employees]
FROM reporting.vw_Manager_Analysis
GROUP BY ManagerName
ORDER BY [Total Departments Handled] DESC, [Manager Name];


-- ATTRITION BY MANAGER WITHIN DEPARTMENT
SELECT
    Department,
    ManagerName AS [Manager Name],
    COUNT(EmpID) AS [Total Employees],
    SUM(CASE WHEN EmpCurrentStatus = 'Terminated' THEN 1 ELSE 0 END) AS [Terminated Employees],
    CAST(
        100.0 * SUM(CASE WHEN EmpCurrentStatus = 'Terminated' THEN 1 ELSE 0 END)
        / COUNT(EmpID)
    AS DECIMAL(10, 2)) AS [Attrition Rate %]
FROM reporting.vw_Manager_Analysis
GROUP BY Department, ManagerName
ORDER BY Department, [Attrition Rate %] DESC, [Manager Name];



-- PERFORMANCE MIX BY MANAGERS
SELECT
    ManagerName AS [Manager Name],
    COUNT(EmpID) AS [Total Employees],
    SUM(CASE WHEN PerformanceScore = 'Exceeds' THEN 1 ELSE 0 END) AS [Exceeds Employees],
    CAST(
        100.0 * SUM(CASE WHEN PerformanceScore = 'Exceeds' THEN 1 ELSE 0 END)
        / COUNT(EmpID)
    AS DECIMAL(10, 2)) AS [Exceeds %]
FROM reporting.vw_Manager_Analysis
GROUP BY ManagerName
ORDER BY [Exceeds Employees] DESC;
GO




--===================================================================================
-- SECTION 5L: STORED PROCEDURES
--===================================================================================

-- CHECK ATTRITION DETAILS WITH DEPARTMENT
CREATE OR ALTER PROCEDURE reporting.usp_Attrition_Details @Department NVARCHAR(50) = NULL AS 
BEGIN
    SET NOCOUNT ON;

    SELECT
        COUNT(EmpID) AS [Total Employees],
        SUM(CASE WHEN EmpCurrentStatus = 'Terminated' THEN 1 ELSE 0 END) AS [Terminated Employees],
        CAST(
            100.0 * SUM(CASE WHEN EmpCurrentStatus = 'Terminated' THEN 1 ELSE 0 END)
            / NULLIF(COUNT(EmpID), 0)
        AS DECIMAL(10, 2)) AS [Attrition Rate %]
    FROM reporting.vw_Attrition_Analysis
    WHERE (@Department IS NULL OR Department = @Department)
END;
GO



EXEC reporting.usp_Attrition_Details;
EXEC reporting.usp_Attrition_Details @Department = 'Production';
EXEC reporting.usp_Attrition_Details @Department = 'IT/IS';
EXEC reporting.usp_Attrition_Details @Department = 'Finance';
GO


-- CHECK TERMINATION BY YEAR
CREATE OR ALTER PROCEDURE reporting.usp_Termination_by_Year @Year INT = NULL AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        TerminationYear,
        COUNT(EmpID) AS [Terminated Employees]
    FROM reporting.vw_Attrition_Analysis
    WHERE EmpCurrentStatus <> 'Active'
        AND (@Year IS NULL OR [TerminationYear] = @Year)
    GROUP BY TerminationYear
    ORDER BY TerminationYear ASC
END;
GO


EXEC reporting.usp_Termination_by_Year;
EXEC reporting.usp_Termination_by_Year @Year = 2016;
EXEC reporting.usp_Termination_by_Year @Year = 2015;
GO


-- CHECK EMPLOYEE DETAILS/PROFILE BY EMPID
CREATE OR ALTER PROCEDURE reporting.usp_Employee_Profile_Check @EmpID INT AS
BEGIN
    SET NOCOUNT ON;

        IF NOT EXISTS (
            SELECT 1
            FROM datamodel.Dim_Employee
            WHERE EmpID = @EmpID
        )
        BEGIN
            SELECT
                CONCAT('EmpID ', @EmpID, ' Not Found.') AS [Message];
            RETURN;
        END;

        SELECT
            de.EmpID,
            de.EmployeeName AS [Employee Name],
            dd.Department,
            dp.Position,
            dm.ManagerName AS [Manager Name],
            rs.RecruitmentSource AS [Recruitment Source],
            fe.HireDate AS [Hire Date],
            fe.TerminationDate AS [Termination Date],
            fe.EmpCurrentStatus AS [Employee Current Status],
            tr.TermReason AS [Reason For Termination],
            ps.PerformanceScore AS [Performance Score],
            fe.Salary,
            fe.EngagementSurvey AS [Engagement Survey],
            fe.EmpSatisfaction AS [Employee Satisfaction Score],
            fe.Absences,
            fe.DaysLateLast30,
            fe.SpecialProjectCount AS [Special Projects],
            de.MaritalDesc AS [Marital Status],
            de.RaceDesc AS [Race],
            CASE WHEN de.Sex = 'F' THEN 'Female'
                 WHEN de.Sex = 'M' THEN 'Male' 
            END AS [Gender],
            de.State,
            de.CitizenDesc AS [Citizenship],
            de.Zip
        FROM datamodel.Fact_Employment fe
        JOIN datamodel.Dim_Employee de
            ON fe.EmpID = de.EmpID
        LEFT JOIN datamodel.Dim_Department dd
            ON fe.DepartmentID = dd.DepartmentID
        LEFT JOIN datamodel.Dim_Position dp
            ON fe.PositionID = dp.PositionID
        LEFT JOIN datamodel.Dim_Manager dm
            ON fe.ManagerID = dm.ManagerID
        LEFT JOIN datamodel.Dim_RecruitmentSource rs
            ON fe.RecruitmentSourceID = rs.RecruitmentSourceID
        LEFT JOIN datamodel.Dim_PerformanceScore ps
            ON fe.PerformanceScoreID = ps.PerformanceScoreID
        LEFT JOIN datamodel.Dim_TermReason tr
            ON fe.TermReasonID = tr.TermReasonID
        WHERE de.EmpID = @EmpID
END;
GO



EXEC reporting.usp_Employee_Profile_Check @EmpID = 10001;
EXEC reporting.usp_Employee_Profile_Check @EmpID = 10004;
EXEC reporting.usp_Employee_Profile_Check @EmpID = 99999;




---------------------------------------------------------------------
-- DATABASE INVENTORY CHECK
---------------------------------------------------------------------
SELECT
    s.name AS [Schema Name],
    CASE o.type
        WHEN 'U' THEN 'Table'
        WHEN 'V' THEN 'View'
        WHEN 'P' THEN 'Procedure'
    END AS [Object Type],
    COUNT(*) AS [Object Count]
FROM sys.objects o
INNER JOIN sys.schemas s
    ON o.schema_id = s.schema_id
WHERE o.type IN ('U', 'V', 'P')
GROUP BY s.name, o.type
ORDER BY s.name, o.type;



SELECT
    s.name AS [Schema Name],
    CASE o.type
        WHEN 'U' THEN 'Table'
        WHEN 'V' THEN 'View'
        WHEN 'P' THEN 'Procedure'
    END AS [Object Type],
    o.name AS [Object Name]
FROM sys.objects o
JOIN sys.schemas s
    ON o.schema_id = s.schema_id
WHERE s.name IN ('original', 'datamodel', 'reporting')
  AND o.type IN ('U', 'V', 'P')
ORDER BY s.name, o.type, o.name;
GO


--===================================================================================
-- SECTION 06: VIEWS FOR POWER BI CONNECT
--===================================================================================

-- TABLE 01
CREATE OR ALTER VIEW reporting.vw_Fact_Employment AS
SELECT
    EmpID,
    DepartmentID,
    PositionID,
    ManagerID,
    RecruitmentSourceID,
    PerformanceScoreID,
    EmploymentStatusID,
    TermReasonID,
    HireDate,
    TerminationDate,
    LastReviewDate,
    Salary,
    EngagementSurvey,
    EmpSatisfaction,
    SpecialProjectCount,
    DaysLateLast30,
    Absences,
    Termd,
    FromDiversityJobFairID,
    ReviewDateIssue,
    EmpCurrentStatus,
    DiversityJobFairHire,
    ReviewDateIssueFlag
FROM datamodel.Fact_Employment;
GO

SELECT COUNT(*) AS [Total Records] FROM reporting.vw_Fact_Employment;  -- 311
GO


-- TABLE 02
CREATE OR ALTER VIEW reporting.vw_Dim_Employee AS
SELECT
    de.EmpID,
    de.EmployeeName,
    de.Sex,
    CASE
        WHEN de.Sex = 'F' THEN 'Female'
        WHEN de.Sex = 'M' THEN 'Male'
    END AS [Gender],
    de.MaritalDesc,
    de.CitizenDesc,
    de.HispanicLatino,
    de.RaceDesc,
    de.State,
    de.Zip,
    da.AgeGroup,
    da.SortAgeGroup
FROM datamodel.Dim_Employee de
JOIN reporting.vw_Diversity_Analysis da
    ON de.EmpID = da.EmpID;
GO

SELECT COUNT(*) AS [Total Records] FROM reporting.vw_Dim_Employee; -- 311
GO



-- TABLE 03
CREATE OR ALTER VIEW reporting.vw_Dim_Department AS
SELECT
    DepartmentID,
    Department
FROM datamodel.Dim_Department;
GO

SELECT COUNT(*) AS [Total Records] FROM reporting.vw_Dim_Department; -- 6
GO


-- TABLE 04
CREATE OR ALTER VIEW reporting.vw_Dim_Position AS
SELECT
    PositionID,
    Position,
    DepartmentID
FROM datamodel.Dim_Position;
GO

SELECT COUNT(*) AS [Total Records] FROM reporting.vw_Dim_Position;  -- 31
GO


-- TABLE 05
CREATE OR ALTER VIEW reporting.vw_Dim_Manager AS
SELECT
    ManagerID,
    ManagerName
FROM datamodel.Dim_Manager;
GO

SELECT COUNT(*) AS [Total Records] FROM reporting.vw_Dim_Manager; -- 21
GO


-- TABLE 06
CREATE OR ALTER VIEW reporting.vw_Dim_RecruitmentSource AS
SELECT
    RecruitmentSourceID,
    RecruitmentSource
FROM datamodel.Dim_RecruitmentSource;
GO

SELECT COUNT(*) AS [Total Records] FROM reporting.vw_Dim_RecruitmentSource; -- 9
GO


-- TABLE 07
CREATE OR ALTER VIEW reporting.vw_Dim_PerformanceScore AS
SELECT
    PerformanceScoreID,
    PerformanceScore
FROM datamodel.Dim_PerformanceScore;
GO

SELECT COUNT(*) AS [Total Records] FROM reporting.vw_Dim_PerformanceScore; -- 4
GO


-- TABLE 08
CREATE OR ALTER VIEW reporting.vw_Dim_EmploymentStatus AS
SELECT
    EmploymentStatusID,
    EmploymentStatus
FROM datamodel.Dim_EmploymentStatus;
GO

SELECT COUNT(*) AS [Total Records] FROM reporting.vw_Dim_EmploymentStatus; -- 3
GO


-- TABLE 09
CREATE OR ALTER VIEW reporting.vw_Dim_TermReason AS
SELECT
    TermReasonID,
    TermReason
FROM datamodel.Dim_TermReason;
GO

SELECT COUNT(*) AS [Total Records] FROM reporting.vw_Dim_TermReason; -- 18
GO


-- TABLE 10
CREATE OR ALTER VIEW reporting.vw_Dim_Date AS
SELECT
    [Date],
    [Year],
    [Quarter],
    [QuarterName],
    [Month],
    [MonthName],
    [MonthYear],
    [MonthYearSort],
    [DayofWeekNumber],
    [DayName]
FROM datamodel.Dim_Date;
GO

SELECT COUNT(*) AS [Total Records] FROM reporting.vw_Dim_Date; -- 5113



-- ROW COUNT CHECK
SELECT 'vw_Fact_Employment' AS [View Name], COUNT(*) AS [Total Records]
FROM reporting.vw_Fact_Employment

UNION ALL

SELECT 'vw_Dim_Employee', COUNT(*)
FROM reporting.vw_Dim_Employee

UNION ALL

SELECT 'vw_Dim_Department', COUNT(*)
FROM reporting.vw_Dim_Department

UNION ALL

SELECT 'vw_Dim_Position', COUNT(*)
FROM reporting.vw_Dim_Position

UNION ALL

SELECT 'vw_Dim_Manager', COUNT(*)
FROM reporting.vw_Dim_Manager

UNION ALL

SELECT 'vw_Dim_RecruitmentSource', COUNT(*)
FROM reporting.vw_Dim_RecruitmentSource

UNION ALL

SELECT 'vw_Dim_PerformanceScore', COUNT(*)
FROM reporting.vw_Dim_PerformanceScore

UNION ALL

SELECT 'vw_Dim_EmploymentStatus', COUNT(*)
FROM reporting.vw_Dim_EmploymentStatus

UNION ALL

SELECT 'vw_Dim_TermReason', COUNT(*)
FROM reporting.vw_Dim_TermReason

UNION ALL

SELECT 'vw_Dim_Date', COUNT(*)
FROM reporting.vw_Dim_Date

ORDER BY [View Name];




