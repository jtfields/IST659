/*
	Author	:	John Fields
	Course	:	IST659 M403
	Term	:	Winter 2019
	Project	:	MyHealthGoals
*/

--The app QS Access was used to export the iPhone health data to Excel to create a data set that was used to populate the Person, Device, Person_Device and Health Data tables manually for prototyping this database.
-- Prior to moving this application to production, consideration should be given to developing an API using the Apple Health Kit to automate the loading of this data.

--Creating the Person table
CREATE TABLE Person (
	--Columns for the Person table
	Person_ID int identity,
	Name varchar(30) not null,
	Birth_Date datetime,
	Gender char(1),
	Height decimal(3,1),
	--Constraints on the Person table
	CONSTRAINT PK_Person PRIMARY KEY (Person_ID)
)
--End creating the Person table

--Adding data to the Person table
--This table contains Personally Identifiable Information (PII) and it should be appropriately secured
INSERT INTO Person(Name,Birth_Date,Gender,Height)
	VALUES
		('John Fields','01/01/1966','M','72'),
		('Heather Fields','01/01/1966','F','63.5')

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
--This database is currently designed for Apple iOS devices.  If enhanced for other devices in the future, consideration would need to be made for the differences in how these devices handle health data.
INSERT INTO Device(Device_Type)
	VALUES
		('iPhone XS'),
		('iPhone 8+')

--SELECT * FROM Device

--Creating the Person Device table
CREATE TABLE Person_Device (
	--Columns for the Person_Device table
	Person_Device_ID int identity,
	Person_ID int not null,
	Device_ID int not null,
	--Constraints on the Person_Device table
	CONSTRAINT PK_Person_Device PRIMARY KEY (Person_Device_ID),
	CONSTRAINT FK1_Person_Device FOREIGN KEY (Person_ID) REFERENCES Person(Person_ID),
	CONSTRAINT FK2_Person_Device FOREIGN KEY (Device_ID) REFERENCES Device(Device_ID)
)
--End creating the Person Device table

--SELECT * FROM Person_Device

--Adding data to the Person Device table
INSERT INTO Person_Device (Person_ID,Device_ID)
VALUES
		((SELECT Person_ID FROM Person WHERE Name='John Fields'),
		(SELECT Device_ID FROM Device WHERE Device_Type='iPhone XS')),
		((SELECT Person_ID FROM Person WHERE Name='Heather Fields'),
		(SELECT Device_ID FROM Device WHERE Device_Type='iPhone 8+'))

--SELECT * FROM Person

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
	Person_Device_ID int,
	--Constraints on the Health Data table
	CONSTRAINT PK_Health_Data PRIMARY KEY (Health_Data_ID),
	CONSTRAINT FK1_Health_Data FOREIGN KEY (Person_Device_ID) REFERENCES Person_Device(Person_Device_ID)
)
--End creating the Health Data table

--Adding data to the Health Data table
--The QS Data iOS app was not initially synching the data from some IoT devices.  This was later corrected and the data was manually added.
--When the loading of this data is automated in the future, consideration should be given to how often the IoT device data is sent to the Apple Health app.
INSERT INTO Health_Data(Recorded_Date,Total_Sleep_Duration,Body_Weight,Body_Mass_Index,Body_Fat_Percentage,Step_Count,Flights_Climbed,Person_Device_ID)
	VALUES
		('1/8/19','369',null,null,null,'9247','9',2),
		('1/1/19','366','197.96','26.87','0.26','10853','10',1),
		('1/2/19','224',null,null,null,'1939',null,1),
		('1/3/19','438','197.14','26.76','0.263','290',null,1),
		('1/4/19',null,'196.45','26.67','0.257','1624',null,1),
		('1/5/19','512','196.06','26.61','0.259','1435',null,1),
		('1/2/19','258',null,null,null,'890',1,2),
		('1/3/19','461',null,null,null,'736',2,2),
		('1/4/19','322',null,null,null,'687',null,2)
		('1/5/19','403',null,null,null,'1061',null,2)
		('1/6/19','462','128.1',null,null,'5488',2,2)
SELECT * FROM Health_Data

--Update Heather Data where data is now available for some Null values
UPDATE Health_Data 
SET Total_Sleep_Duration='258',Body_Weight='127.5',Body_Mass_Index=null,Body_Fat_Percentage='0.252',Step_Count='890',Flights_Climbed='1'
WHERE Recorded_Date='1/2/19'AND Person_Device_ID=2
UPDATE Health_Data 
SET Total_Sleep_Duration='461',Body_Weight='127.2',Body_Mass_Index=null,Body_Fat_Percentage='0.267',Step_Count='736',Flights_Climbed='2'
WHERE Recorded_Date='1/7/19'AND Person_Device_ID=2

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
	Baseline_Date_Stamp datetime not null default GetDate(),
	Person_Device_ID int,
	--Constraints on the Health Data Baseline table
	CONSTRAINT PK_Health_Data_Baseline PRIMARY KEY (Baseline_ID),
	CONSTRAINT FK1_Health_Data_Baseline FOREIGN KEY (Person_Device_ID) REFERENCES Person_Device (Person_Device_ID)
)

SELECT * FROM Health_Data_Baseline

--Adding data to the Health Data Baseline table
--The Baseline is the average of the existing values from the Health Data table.
--At the end of this SQL code, a trigger was added to run the Baseline each time the Health Data table was updated.

INSERT INTO Health_Data_Baseline(Total_Sleep_Duration_Baseline,Body_Weight_Baseline,Body_Mass_Index_Baseline,Body_Fat_Percentage_Baseline,Step_Count_Baseline,Flights_Climbed_Baseline,Health_Data.Person_Device_ID)
	SELECT 
	AVG(Total_Sleep_Duration) as "Average Minutes of Sleep Per Night"
	,AVG(Body_Weight) as "Average Weight in Pounds"
	,AVG(Body_Mass_Index) as "Average Body Mass Index"
	,AVG(Body_Fat_Percentage) as "Average Body Fat %"
	,AVG(Step_Count) as "Average Step Count"
	,AVG(Flights_Climbed) as "Average Flights Climbed"
	,Health_Data.Person_Device_ID
	FROM Health_Data 
	JOIN Person_Device ON Person_Device.Person_Device_ID = Health_Data.Person_Device_ID
	GROUP BY Health_Data.Person_Device_ID
	
SELECT * FROM Health_Data_Baseline

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
	Goal_Date_Stamp datetime not null default GetDate(),
	Baseline_ID int,
	Person_ID int,
	--Constraints on the Health Goals table
	CONSTRAINT PK_Health_Data_Goals PRIMARY KEY (Goals_ID),
	CONSTRAINT FK1_Health_Data_Goals FOREIGN KEY (Baseline_ID) REFERENCES Health_Data_Baseline (Baseline_ID),
	CONSTRAINT FK2_Health_Data_Goals FOREIGN KEY (Person_ID) REFERENCES Person (Person_ID)
)

SELECT * FROM Health_Data_Goals

--Adding data to the Health Data Goals table
--As mentioned above, a trigger was written to run the Baseline each time Health Data was updated.  One future enhancement is to insert the most recent Baseline ID in the SQL code below whenever the Goals are updated.
--For the prototyping of this project, the Baseline IDs were manually inserted.
INSERT Health_Data_Goals(Total_Sleep_Duration_Goal,Body_Weight_Goal,Body_Mass_Index_Goal,Body_Fat_Percentage_Goal,Step_Count_Goal,Flights_Climbed_Goal,Baseline_ID,Person_ID)
	VALUES 
	('450','126','25','0.26','3000','5',11,2)
	('420','126',null,'0.25','4000','5',2,2),
	('456','190','26','0.25','4000','12',1,1)

SELECT * FROM Health_Data_Goals
SELECT * FROM Health_Data_Baseline

--Query to compare Goal to Baseline
SELECT
	Person.Name,
	Goal_Date_Stamp,
	Health_Data_Baseline.Total_Sleep_Duration_Baseline,
	Total_Sleep_Duration_Goal,
	Body_Weight_Baseline,
	Body_Weight_Goal,
	Body_Mass_Index_Baseline,
	Body_Mass_Index_Goal,
	Body_Fat_Percentage_Baseline,
	Body_Fat_Percentage_Goal,
	Step_Count_Baseline,
	Step_Count_Goal,
	Flights_Climbed_Baseline,
	Flights_Climbed_Goal,
	Health_Data_Goals.Baseline_ID
FROM Health_Data_Goals
JOIN Health_Data_Baseline ON Health_Data_Baseline.Baseline_ID = Health_Data_Goals.Baseline_ID
JOIN Person ON Person.Person_ID = Health_Data_Goals.Person_ID

-- Create a view to retrieve the Goal to Baseline
-- To enable an authorized IT user to view information in this database, a guestuser account was created to allow access to the MyHealthGoalProgress view.
ALTER VIEW MyHealthGoalProgress AS
	SELECT
		Person.Name,
		Goal_Date_Stamp,
		Health_Data_Baseline.Total_Sleep_Duration_Baseline,
		Total_Sleep_Duration_Goal,
		Body_Weight_Baseline,
		Body_Weight_Goal,
		Body_Mass_Index_Baseline,
		Body_Mass_Index_Goal,
		Body_Fat_Percentage_Baseline,
		Body_Fat_Percentage_Goal,
		Step_Count_Baseline,
		Step_Count_Goal,
		Flights_Climbed_Baseline,
		Flights_Climbed_Goal,
		Health_Data_Baseline.Baseline_ID,
		Goals_ID
	FROM Health_Data_Goals
	JOIN Health_Data_Baseline ON Health_Data_Baseline.Baseline_ID = Health_Data_Goals.Baseline_ID
	JOIN Person ON Person.Person_ID = Health_Data_Goals.Person_ID
GO

SELECT * FROM MyHealthGoalProgress

-- Creating a guestuser database user --
CREATE USER guestuser FOR LOGIN guestuser

--After creating the ODBC connection between SQL Server and Microsoft Access, more data was needed for the report and form in Access to work properly.
--Adding additional data to the Person table
INSERT INTO Person(Name,Birth_Date,Gender,Height)
	VALUES
		('Jason Fields','01/01/1999','M','70'),
		('Alice Fields','01/01/1997','F','68'),
		('Theophilus Fields', '01/01/1950','M','70')

SELECT * FROM Person

DELETE FROM Person WHERE Person_ID = 3
DELETE FROM Person WHERE Person_ID = 4

--Adding additional data to the Device table
INSERT INTO Device(Device_Type)
	VALUES
		('iPhone 6'),
		('iPhone 7'),
		('iPhone 8')

SELECT * From Device

--Adding data to the Person Device table
INSERT INTO Person_Device (Person_ID,Device_ID)
VALUES
		((SELECT Person_ID FROM Person WHERE Name='Jason Fields'),
		(SELECT Device_ID FROM Device WHERE Device_Type='iPhone 7')),
		((SELECT Person_ID FROM Person WHERE Name='Alice Fields'),
		(SELECT Device_ID FROM Device WHERE Device_Type='iPhone 8')),
		((SELECT Person_ID FROM Person WHERE Name='Theophilus Fields'),
		(SELECT Device_ID FROM Device WHERE Device_Type='iPhone 6'))

SELECT * FROM Person_Device

--Creating a trigger to update the baseline table whenever a new record is inserted in the health data table
--As mentioned above, adding a trigger improved the database so each time data is added to the Health Data table, the Baseline is updated.
CREATE TRIGGER BaselineUpdate
ON Health_Data
AFTER INSERT
AS
INSERT INTO Health_Data_Baseline(Total_Sleep_Duration_Baseline,Body_Weight_Baseline,Body_Mass_Index_Baseline,Body_Fat_Percentage_Baseline,Step_Count_Baseline,Flights_Climbed_Baseline,Health_Data.Person_Device_ID)
	SELECT 
	AVG(Total_Sleep_Duration) as "Average Minutes of Sleep Per Night"
	,AVG(Body_Weight) as "Average Weight in Pounds"
	,AVG(Body_Mass_Index) as "Average Body Mass Index"
	,AVG(Body_Fat_Percentage) as "Average Body Fat %"
	,AVG(Step_Count) as "Average Step Count"
	,AVG(Flights_Climbed) as "Average Flights Climbed"
	,Health_Data.Person_Device_ID
	FROM Health_Data 
	JOIN Person_Device ON Person_Device.Person_Device_ID = Health_Data.Person_Device_ID
	GROUP BY Health_Data.Person_Device_ID
	
SELECT * FROM Health_Data_Baseline