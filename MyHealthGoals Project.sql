/*
	Author	:	John Fields
	Course	:	IST659 M403
	Term	:	Winter 2019
	Project	:	MyHealthGoals
*/

--DROP Table Health_Data_Goals
--DROP Table Health_Data_Baseline
--DROP Table Health_Data
--DROP Table Person_Device
--DROP Table Device
--DROP Table Person

--Creating the Person table
CREATE TABLE Person (
	--Columns for the Person table
	Person_ID int identity,
	Name varchar(30) not null,
	Birth_Date datetime,
	Gender char(1),
	Height decimal(3,1)
	--Constraints on the Person table
	CONSTRAINT PK_Person PRIMARY KEY (Person_ID)
)
--End creating the Person table

--Adding data to the Person table
INSERT INTO Person(Name,Birth_Date,Gender,Height)
	VALUES
		('Theophilus','01/01/1966','M','72'),
		('Florence','01/01/1966','F','63.5')

--SELECT * FROM Person

--Creating the Device table
CREATE TABLE Device (
	--Columns for the Device table
	Device_ID int identity,
	Device_Type varchar(30) not null,
	--Constraints on the Device table
	CONSTRAINT PK_Device PRIMARY KEY (Device_ID)
)
--End creating the Device table

--Adding data to the Device table
INSERT INTO Device(Device_Type)
	VALUES
		('iPhone XS'),
		('iPhone 8+')

--SELECT * FROM Device

--NOTE: The Person Device table was not working so I eliminated it
--Creating the Person Device table
--CREATE TABLE Person_Device (
	--Columns for the Person_Device table
	--Person_Device_ID int identity,
	--Person_ID int not null,
	--Device_ID int not null,
	--Constraints on the Person_Device table
	--CONSTRAINT PK_Person_Device PRIMARY KEY (Person_Device_ID),
	--CONSTRAINT FK1_Person_Device FOREIGN KEY (Person_ID) REFERENCES Person(Person_ID),
	--CONSTRAINT FK2_Person_Device FOREIGN KEY (Device_ID) REFERENCES Device(Device_ID)
--End creating the Person Device table

--Creating the Health Data table
CREATE TABLE Health_Data (
	--Columns for the Health Data table
	Health_Data_ID int identity,
	Recorded_Date datetime,
	Total_Sleep_Duration int,
	Body_Weight decimal(5,2),
	Body_Mass_Index decimal(4,2),
	Body_Fat_Percentage decimal(4,3),
	Step_Count int,
	Flights_Climbed int,
	Person_ID int,
	Device_ID int,
	--Constraints on the Health Data table
	CONSTRAINT PK_Health_Data PRIMARY KEY (Health_Data_ID),
	CONSTRAINT FK1_Health_Data FOREIGN KEY (Person_ID) REFERENCES Person(Person_ID),
	CONSTRAINT FK2_Health_Data FOREIGN KEY (Device_ID) REFERENCES Device(Device_ID)
)
--End creating the Health Data table

--Adding data to the Health Data table
INSERT INTO Health_Data(Recorded_Date,Total_Sleep_Duration,Body_Weight,Body_Mass_Index,Body_Fat_Percentage,Step_Count,Flights_Climbed,Person_ID,Device_ID)
	VALUES
		('1/1/19','369','0','0','0','9247','9','2','2')
		('1/1/19','366','197.96','26.87','0.26','10853','10','1','1')
--SELECT * FROM Health_Data

--Creating the Health Data Baseline table
CREATE TABLE Health_Data_Baseline (
	--Columns for the Health Data table
	Baseline_ID int identity,
	Total_Sleep_Duration_Baseline int,
	Body_Weight_Baseline decimal(5,2),
	Body_Mass_Index_Baseline decimal(4,2),
	Body_Fat_Percentage_Baseline decimal(4,3),
	Step_Count_Baseline int,
	Flights_Climbed_Baseline int,
	Person_ID int,
	Device_ID int,
	Health_Data_ID int,
	--Constraints on the Health Data Baseline table
	CONSTRAINT PK_Health_Data_Baseline PRIMARY KEY (Baseline_ID),
	CONSTRAINT FK1_Health_Data_Baseline FOREIGN KEY (Person_ID) REFERENCES Person (Person_ID),
	CONSTRAINT FK2_Health_Data_Baseline FOREIGN KEY (Device_ID) REFERENCES Device (Device_ID),
	CONSTRAINT FK3_Health_Data_Baseline FOREIGN KEY (Health_Data_ID) REFERENCES Health_Data (Health_Data_ID)
)

--Adding data to the Health Data Baseline table
--INSERT INTO Health_Data_Baseline((Total_Sleep_Duration_Baseline,Body_Weight_Baseline,Body_Mass_Index_Baseline, Body_Fat_Percentage_Baseline, Step_Count_Baseline, Flights_Climbed_Baseline, Person_ID, Device_ID, Health_Data_ID)
	SELECT 
	AVG(Body_Weight) as "Average Weight in Pounds"
	,AVG(Body_Mass_Index) as "Average Body Mass Index"
	,AVG(Body_Fat_Percentage) as "Average Body Fat %"
	,AVG(Step_Count) as "Average Step Count"
	,AVG(Flights_Climbed) as "Average Flights Climbed"
	FROM Health_Data
	GROUP BY Person_ID
	
--Creating the Health Goals table
CREATE TABLE Health_Data_Goals (
	--Columns for the Health Goals table
	Goals_ID int identity,
	Total_Sleep_Duration_Goal int,
	Body_Weight_Goal decimal(5,2),
	Body_Mass_Index_Goal decimal(4,2),
	Body_Fat_Percentage_Goal decimal(4,3),
	Step_Count_Goal int,
	Flights_Climbed_Goal int,
	Baseline_ID int,
	Person_ID int,
	--Constraints on the Health Goals table
	CONSTRAINT PK_Health_Data_Goals PRIMARY KEY (Goals_ID),
	CONSTRAINT FK1_Health_Data_Goals FOREIGN KEY (Baseline_ID) REFERENCES Health_Data_Baseline (Baseline_ID),
	CONSTRAINT FK2_Health_Data_Goals FOREIGN KEY (Person_ID) REFERENCES Person (Person_ID)
)
