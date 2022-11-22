-- NewWorldMedicalDM developed and written by Hunter Hootman
-- Written exclusively for INFO 3300
-- Originally written: October 2022 | Updated: October 2022
-----------------------------------------------------------
IF NOT EXISTS(SELECT * FROM sys.databases
	WHERE NAME = N'NewWorldMedicalDM')
	CREATE DATABASE NewWorldMedicalDM
GO 
--
USE NewWorldMedicalDM
GO
--
-- Check if tables exist and drop them if they do
IF EXISTS(
	SELECT *
	FROM sys.tables
	WHERE NAME = N'FactOrders'
	)
	DROP TABLE FactOrders;
--
IF EXISTS(
	SELECT *
	FROM sys.tables
	WHERE NAME = N'DimDate'
	)
	DROP TABLE DimDate;
--
IF EXISTS(
	SELECT *
	FROM sys.tables
	WHERE NAME = N'DimOrgan'
	)
	DROP TABLE DimOrgan;
--
IF EXISTS(
	SELECT *
	FROM sys.tables
	WHERE NAME = N'DimDoctor'
	)
	DROP TABLE DimDoctor;
-- 
IF EXISTS(
	SELECT *
	FROM sys.tables
	WHERE NAME = N'DimPrescription'
	)
	DROP TABLE DimPrescription;
-- 
IF EXISTS(
	SELECT *
	FROM sys.tables
	WHERE NAME = N'DimPatient'
	)
	DROP TABLE DimPatient;
-- 
-- Begin creating the tables here:
CREATE TABLE DimDate 
	(Date_SK			INT CONSTRAINT pk_date_sk PRIMARY KEY, 
	Date				DATE,
	FullDate			NCHAR(10), -- Date in MM-dd-yyyy format
	DayOfMonth			INT, -- Field will hold day number of Month
	DayName				NVARCHAR(9), -- Contains name of the day, Sunday, Monday 
	DayOfWeek			INT, -- First Day Sunday=1 and Saturday=7
	DayOfWeekInMonth	INT, -- 1st Monday or 2nd Monday in Month
	DayOfWeekInYear		INT,
	DayOfQuarter		INT,
	DayOfYear			INT,
	WeekOfMonth			INT, -- Week Number of Month 
	WeekOfQuarter		INT, -- Week Number of the Quarter
	WeekOfYear			INT, -- Week Number of the Year
	Month				INT, -- Number of the Month 1 to 12{}
	MonthName			NVARCHAR(9), -- January, February etc
	MonthOfQuarter		INT, -- Month Number belongs to Quarter
	Quarter				NCHAR(2), 
	QuarterName			NVARCHAR(9), -- First,Second...
	Year				INT, -- Year value of Date stored in Row
	YearName			NCHAR(7), -- CY 2017,CY 2018
	MonthYear			NCHAR(10), -- Jan-2018,Feb-2018
	MMYYYY				INT,
	FirstDayOfMonth		DATE,
	LastDayOfMonth		DATE,
	FirstDayOfQuarter	DATE,
	LastDayOfQuarter	DATE,
	FirstDayOfYear		DATE,
	LastDayOfYear		DATE,
	IsHoliday			BIT, -- Flag 1=National Holiday, 0-No National Holiday
	IsWeekday			BIT, -- 0=Week End ,1=Week Day
	Holiday				NVARCHAR(50), -- Name of Holiday in US
	Season				NVARCHAR(10) -- Name of Season
	);
--
CREATE TABLE DimOrgan
	(Organ_SK						INT IDENTITY (1,1) NOT NULL CONSTRAINT pk_organ_sk PRIMARY KEY,
	Organ_AK						INT NOT NULL,
	OrganType						NVARCHAR(20) NOT NULL,		--What kind of organ (Heart, Liver, Lung, etc...)
	OrganSize						NVARCHAR(5)  NOT NULL,		--Size of the organ (XL,L,M,S, etc...)
	PrescriptionOrganMaterial		NVARCHAR(20) NOT NULL,		--Material organ is made of (Gelatin, Bioink, etc...)
	);
--
CREATE TABLE DimDoctor
	(Doctor_SK			INT IDENTITY(1,1) NOT NULL CONSTRAINT pk_doctor_sk PRIMARY KEY,
	Doctor_AK			INT NOT NULL,
	DoctorFirstName		NVARCHAR(30) NOT NULL,
	DoctorLastName		NVARCHAR(50) NOT NULL,
	MedSchoolName		NVARCHAR(100) NOT NULL,  --Name of the medical school the doctor attended
	YearsExperience     INT NOT NULL,   --Years of experience the doctor has (1,2,3,4,etc...)
	DoctorCategory		NVARCHAR(50) NOT NULL,   --Organ that they specialize in (heart, liver, lung, etc...)
	StartDate			DATETIME NOT NULL,
	EndDate				DATETIME NULL,
	);
--
CREATE TABLE DimPrescription
	(Prescription_SK	INT IDENTITY(1,1) NOT NULL CONSTRAINT pk_prescription_sk PRIMARY KEY,
	Prescription_AK		INT NOT NULL,
	MedicineName		NVARCHAR(50) NOT NULL, --Name of the medicine (CellCept, Cyclosplorine, Prograf)
	Quantity			INT NOT NULL,		  --Quantity of the medicine (1,2,3,4,etc...)
	PrescriptionDate	DATE NOT NULL,		  --Date the prescription was given (1/1/2022)
	);
--
CREATE TABLE DimPatient
	(Patient_SK			INT IDENTITY(1,1) NOT NULL CONSTRAINT pk_patient_sk PRIMARY KEY,
	Patient_AK			INT NOT NULL,
	BillCategory		NVARCHAR(50) NOT NULL,  --Surgery, Checkup, etc...
	DOB					DATE NOT NULL,		   --Patient date of birth (1/1/2001)
	);
--
CREATE TABLE FactOrders
	(Date_SK			INT NOT NULL,
	Organ_SK			INT NOT NULL,
	Doctor_SK			INT NOT NULL,
	Prescription_SK		INT NOT NULL,
	Patient_SK			INT NOT NULL,
	QuantityOrdered		INT DEFAULT 0 NOT NULL,  --Number of units ordered (1,2,3,4,etc...)
	OrderPrice			MONEY NOT NULL,			--The cost of the order ($1.50)
	BillTotal			MONEY NOT NULL,			--The amount of the bill ($10,000)
	CONSTRAINT pk_fact_orders PRIMARY KEY (Date_SK,Organ_SK,Patient_SK,Doctor_SK,Prescription_SK), -- Define a primary key
	CONSTRAINT fk_dim_organ FOREIGN KEY (Organ_SK) REFERENCES DimOrgan(Organ_SK),				   -- Define foreign keys
	CONSTRAINT fk_dim_doctor FOREIGN KEY (Doctor_SK) REFERENCES DimDoctor(Doctor_SK),
	CONSTRAINT fk_dim_prescription FOREIGN KEY (Prescription_SK) REFERENCES DimPrescription(Prescription_SK),
	CONSTRAINT fk_dim_patient FOREIGN KEY (Patient_SK) REFERENCES DimPatient(Patient_SK),
	CONSTRAINT fk_dim_date FOREIGN KEY (Date_SK) REFERENCES DimDate(Date_SK),
	);
