
USE "Peng_DAMG6210";  
GO  


-- Table: Hospital table

CREATE TABLE Hospital ( 
HospitalID INT PRIMARY KEY, 
HospitalName VARCHAR(50),  
HospitalAddress1 VARCHAR(50),  
HospitalAddress2 VARCHAR(50),  
HospitalCity VARCHAR(50),  
HospitalState VARCHAR(50),  
HospitalZipCode VARCHAR(10)  
);  
GO


-- Table: Department

CREATE TABLE Department (  
DepartmentID INT PRIMARY KEY,  
HospitalID INT,  
DepartmentName VARCHAR(50),  
DepartmentLocation VARCHAR(50),  
FOREIGN KEY (HospitalID) REFERENCES Hospital(HospitalID)  
);  
GO


-- Table: Doctor

CREATE TABLE Doctor (  
DoctorID INT PRIMARY KEY,  
DepartmentID INT,
LastName VARCHAR(50), 
FirstName VARCHAR(50),   
FOREIGN KEY (DepartmentID) REFERENCES Department(DepartmentID)  
);  
GO  


-- Table: Nurse

CREATE TABLE Nurse (  
  NurseID INT PRIMARY KEY,  
  DepartmentID INT,  
  LastName VARCHAR(50),  
  FirstName VARCHAR(50),  
  FOREIGN KEY (DepartmentID) REFERENCES Department(DepartmentID)  
);  
GO


-- Table: Room
  
CREATE TABLE Room (
  RoomID INT PRIMARY KEY,  
  DepartmentID INT,  
  RoomLocation VARCHAR(50),  
  FOREIGN KEY (DepartmentID) REFERENCES Department(DepartmentID)  
);  
GO


-- Table: Blood Product Information

CREATE TABLE Blood_Product_Information (  
    BloodProductDetailID INT PRIMARY KEY,  
    BloodProductType VARCHAR(50),  
    Volume INT,  
    ABOType CHAR(2),  
    RHType CHAR(1)  
);  
GO


-- Table: Storage Type

CREATE TABLE Storage_Type (
    StorageTypeID INT PRIMARY KEY,  
    Temperature INT,  
    Capacity INT,  
    AllowedProduct VARCHAR(50)  
); 
GO


-- Table: Hospital Storage

CREATE TABLE HospitalStorage (  
StorageID INT PRIMARY KEY,  
DepartmentID INT,  
StorageTypeID INT,  
Name VARCHAR(50),  
CurrentLocation VARCHAR(50),  
HomeLocation VARCHAR(50),  
BloodProductQuantity INT,  
CurrentStatus VARCHAR(50),  
FOREIGN KEY (DepartmentID) REFERENCES Department(DepartmentID),  
FOREIGN KEY (StorageTypeID) REFERENCES Storage_Type(StorageTypeID)  
);  
GO


-- Table: Patient
CREATE TABLE Patient (  

PatientID INT PRIMARY KEY,  

RoomID INT,  

NurseID INT,  

DoctorID INT,

LastName VARCHAR(50),

FirstName VARCHAR(50),  

DateOfBirth DATE,  

PhoneNumber VARCHAR(20),  

ABOType VARCHAR(5),  

RHType VARCHAR(5),  

FOREIGN KEY (RoomID) REFERENCES Room(RoomID),  

FOREIGN KEY (NurseID) REFERENCES Nurse(NurseID),  

FOREIGN KEY (DoctorID) REFERENCES Doctor(DoctorID)  
); 

GO
  

-- Table: Blood Product
CREATE TABLE BloodProduct (  
BloodProductID INT PRIMARY KEY, 

StorageID INT, 

BloodProductEntryDateTime DATETIME,  

BloodProductExpireDateTime DATETIME, 

FOREIGN KEY (StorageID) REFERENCES HospitalStorage(StorageID)  
);  
GO


-- Table: Transfusion

CREATE TABLE Transfusion (
TransfusionID INT PRIMARY KEY,  
PatientID INT,  
BloodProductID INT,  
TransfusionDateTime DATETIME,  
FOREIGN KEY (PatientID) REFERENCES Patient(PatientID),  
FOREIGN KEY (BloodProductID) REFERENCES BloodProduct(BloodProductID)  
);  
GO


-- Table: Processed Blood Product Inventory

CREATE TABLE Processed_Blood_Product_Inventory (
    BloodProductID INT PRIMARY KEY,  
    StorageID INT,  
    TechID INT,  
    BloodProductDetailID INT FOREIGN KEY REFERENCES Blood_Product_Information(BloodProductDetailID),  
    ProcessedDateTime DATETIME,  
    ExpireDateTime DATETIME  
);  
GO  

  
-- Table: Donor 

CREATE TABLE Donor (
    DonorID INT PRIMARY KEY,
    FirstName VARCHAR(50),
    LastName VARCHAR(50), 
    PhoneNumber VARCHAR(20),
    DateOfBirth DATE, 
    Gender CHAR(1),
    ABOType CHAR(2),  
    RHType CHAR(1)  
);  
GO
  

-- Table: Donor History   
CREATE TABLE DonorHistory ( 
    DonorHistoryID INT PRIMARY KEY,
	MonthsSinceLast INT,
	NumDonations INT, 
    TotalVolume INT,   
    MonthsSinceFirst INT, 
    DonorID INT, 
    FOREIGN KEY (DonorID) REFERENCES Donor(DonorID) 
);  
GO


-- Table: BB Storage

CREATE TABLE BBStorage (
    StorageID INT PRIMARY KEY, 

    DepartmentID INT,   

    StorageTypeID INT, 

    Capacity INT     
);   
GO  


-- Table: BB Unprocessed Blood Product Inventory

CREATE TABLE UnprocessedBloodProductInventory ( 

    UnprocessedBloodID INT PRIMARY KEY,   

    RawBloodID INT,   

    StorageID INT,   

    ExpireDateTime DATETIME, 

    FOREIGN KEY (StorageID) REFERENCES BBStorage(StorageID)   

);   
GO
  

-- Table: BB Department

CREATE TABLE BBDepartment (
    DepartmentID INT PRIMARY KEY,  
    StorageID INT,  
    Address1 VARCHAR(100), 
    Address2 VARCHAR(100),  
    City VARCHAR(50), 
    State VARCHAR(50), 
    Zipcode VARCHAR(10),
    FOREIGN KEY (StorageID) REFERENCES BBStorage(StorageID)  
);  
GO


-- Table: Tech

CREATE TABLE Tech (
    TechID INT PRIMARY KEY, 
    DepartmentID INT,
    Position VARCHAR(50),
    FirstName VARCHAR(50),
    LastName VARCHAR(50),
	FOREIGN KEY (DepartmentID) REFERENCES BBDepartment(DepartmentID)  
);  
GO
  

-- Table: Donation

CREATE TABLE Donation (
    DonationID INT PRIMARY KEY,
    DonorID INT,
    TechID INT,
    RawBloodID INT,
    DepartmentID INT,
    DonationDateTime DATETIME,
    DonationVolume INT,
    FOREIGN KEY (DonorID) REFERENCES Donor(DonorID),
    FOREIGN KEY (TechID) REFERENCES Tech(TechID),
    FOREIGN KEY (DepartmentID) REFERENCES BBDepartment(DepartmentID)  
);   
GO
  

-- Table: Transit

CREATE TABLE Transit (
    TransitID INT PRIMARY KEY,
    StorageID INT, 
    HospitalID INT,
    TransitDepartureTime DATETIME,  
    FOREIGN KEY (StorageID) REFERENCES BBStorage(StorageID),  
    FOREIGN KEY (HospitalID) REFERENCES Hospital(HospitalID)  
);  
GO


-- Table: Order

CREATE TABLE [Order] (  
    OrderID INT PRIMARY KEY, 
    TransitID INT,
    OrderArrivalDateTime DATETIME,
    OrderStatus VARCHAR(50),  
    OrderType VARCHAR(50),  
    FOREIGN KEY (TransitID) REFERENCES Transit (TransitID)  
);  
GO


-- Trigger: Calculate Expiration Date of Processed Blood Product Inverntory When Insert

CREATE TRIGGER TR_Inventory_Insert  
ON Processed_Blood_Product_Inventory  
FOR INSERT  
AS  
BEGIN  
    DECLARE @BloodProductType VARCHAR(50)  
    DECLARE @ProcessedDateTime DATETIME  
    DECLARE @ExpireDateTime DATETIME  

    SELECT 
		@BloodProductType = Blood_Product_Information.BloodProductType,  
        @ProcessedDateTime = inserted.ProcessedDateTime  
    FROM inserted  
    JOIN Blood_Product_Information 
		ON inserted.BloodProductDetailID = Blood_Product_Information.BloodProductDetailID  


    IF @BloodProductType = 'RBC'  
        SET @ExpireDateTime = DATEADD(day, 42, @ProcessedDateTime)  

    ELSE IF @BloodProductType = 'Platelets'  
        SET @ExpireDateTime = DATEADD(day, 5, @ProcessedDateTime)  

    ELSE IF @BloodProductType = 'Plasma' OR @BloodProductType = 'Cryo'  
        SET @ExpireDateTime = DATEADD(year, 1, @ProcessedDateTime)  

    UPDATE Processed_Blood_Product_Inventory  
    SET ExpireDateTime = @ExpireDateTime  
    FROM inserted  
    WHERE inserted.BloodProductID = Processed_Blood_Product_Inventory.BloodProductID
	
END  
GO


-- Trigger: Calculate Expiration Date of Hospital Blood Product When Insert  

CREATE TRIGGER TR_BloodProduct_Insert  
ON BloodProduct  
FOR INSERT
AS  
BEGIN  
    -- Declare variables for BloodProductType, ProcessedDateTime, and ExpireDateTime
    DECLARE @BloodProductType VARCHAR(50)
    DECLARE @EntryDateTime DATETIME
    DECLARE @ExpireDateTime DATETIME

    -- Get the BloodProductType and ProcessedDateTime from the inserted table 
    SELECT 
        @BloodProductType = bpi.BloodProductType,  
        @EntryDateTime = i.BloodProductEntryDateTime
    FROM inserted i
    JOIN Processed_Blood_Product_Inventory pbpi ON i.BloodProductID = pbpi.BloodProductID
    JOIN Blood_Product_Information bpi ON pbpi.BloodProductDetailID = bpi.BloodProductDetailID 

    -- Calculate the ExpireDateTime based on the BloodProductType
    IF @BloodProductType = 'RBC'  
        SET @ExpireDateTime = DATEADD(day, 42, @EntryDateTime)
    ELSE IF @BloodProductType = 'Platelets'  
        SET @ExpireDateTime = DATEADD(day, 5, @EntryDateTime)
    ELSE IF @BloodProductType = 'Plasma' OR @BloodProductType = 'Cryo'  
        SET @ExpireDateTime = DATEADD(year, 1, @EntryDateTime)

    -- Update the BloodProductExpireDateTime for the inserted row
    UPDATE BloodProduct  
    SET BloodProductExpireDateTime = @ExpireDateTime
    FROM inserted
    WHERE inserted.BloodProductID = BloodProduct.BloodProductID
END
  
GO
  
-- Trigger: Update patient Room ID when one's room is changed 

CREATE TRIGGER Update_Patient_RoomID   
ON Patient  
FOR UPDATE  
AS  
IF UPDATE(RoomID)
BEGIN  
  UPDATE Patient
  SET RoomID = i.RoomID
  FROM Patient p  
  JOIN inserted i 
	ON p.PatientID = i.PatientID  
END;  
GO 


-- Create view to list doctors and nurses of each department of each hospital

CREATE VIEW HospitalDepartmentView AS
WITH temp AS(
SELECT
	h.HospitalID,
	h.HospitalName , 
	(h.HospitalAddress1+', '+ h.HospitalAddress2+', '
		+ h.HospitalCity+', '+ h.HospitalState+', '
			+ h.HospitalZipCode) AS [Hospital Address],
	d.DepartmentID, d.DepartmentName, d.DepartmentLocation,
    (dr.FirstName+' '+dr.LastName) AS Doctor,
    (n.FirstName+' '+n.LastName) AS Nurse
FROM Hospital h
JOIN Department d ON h.HospitalID = d.HospitalID
JOIN Doctor dr ON d.DepartmentID = dr.DepartmentID
JOIN Nurse n ON d.DepartmentID = n.DepartmentID
) 
SELECT 
	HospitalName, [Hospital Address],
	DepartmentName,DepartmentLocation,
	STRING_AGG(Doctor,', ') AS [Doctor],
	STRING_AGG(Nurse,', ') AS Nurse
FROM temp
GROUP BY HospitalName,[Hospital Address],
DepartmentName,DepartmentLocation;
GO


-- Create view to list details of each blood transfusion

CREATE VIEW TransfusionDetailsView AS
SELECT 
	(p.LastName +', ' + p.FirstName) AS [Patient Name],
	t.TransfusionDateTime,
	h.HospitalName,
	(d.LastName +', ' + d.FirstName) AS [Doctor Name],
	(n.LastName +', ' + n.FirstName) AS [Nurse Name],
	r.RoomLocation,
	bpi.BloodProductType, bpi.Volume AS [Volume (mL)] 
FROM Transfusion t
JOIN Patient p ON t.PatientID = p.PatientID
JOIN Room r ON p.RoomID = r.RoomID
JOIN Nurse n ON p.NurseID = n.NurseID
JOIN Doctor d ON p.DoctorID = d.DoctorID
JOIN Department dep ON dep.DepartmentID = d.DepartmentID
JOIN Hospital h ON dep.HospitalID = h.HospitalID
JOIN BloodProduct bp ON t.BloodProductID = bp.BloodProductID
JOIN Processed_Blood_Product_Inventory pbpi ON bp.BloodProductID = pbpi.BloodProductID
JOIN Blood_Product_Information bpi ON pbpi.BloodProductDetailID = bpi.BloodProductDetailID;
GO


-- Create view to list all donation records of each donor

CREATE VIEW DonationRecord AS
SELECT
    (D.LastName + ', ' + D.FirstName) AS [Donor Name],
    (D.ABOType + D.RHType) AS [Blood Type],
    DN.DonationDateTime,
    DN.DonationVolume,
    (T.LastName + ', ' + T.FirstName) AS [Tech Name],
    (DD.Address1 + ', ' + DD.Address2 +', '+ DD.City 
	+ ', '+ DD.State +', '+ DD.Zipcode) AS [Department Address]
FROM
    Donation DN
JOIN Donor D ON DN.DonorID = D.DonorID
JOIN Tech T ON DN.TechID = T.TechID
JOIN BBDepartment DD ON DN.DepartmentID = DD.DepartmentID;
GO


-- Insert Data to Hospital table

INSERT INTO Hospital (HospitalID, HospitalName, HospitalAddress1, HospitalAddress2, HospitalCity, HospitalState, HospitalZipCode)   
VALUES  

	(1, 'University of Washington Medical Center', '1959 NE Pacific St', null ,'Seattle', 'WA', '98195'),

	(2, 'Harborview Medical Center', '325 9th Ave', null ,'Seattle', 'WA', '98104'),

	(3, 'Nortwest Medical Center','1550 N. 115th Street', null ,'Seattle', 'WA', '98133');
	
GO 


-- Insert Data to Department table

INSERT INTO Department (DepartmentID, HospitalID, DepartmentName, DepartmentLocation)   
VALUES

	(1, 1, 'ER', 'Emergency Room'),

    (2, 1, 'ICU', '1st Floor'),

    (3, 1, 'Oncology', '3rd Floor'),

    (4, 1, 'OR', '1st Floor'),

    (5, 1, 'Radiology', '4th Floor'),

    (6, 2, 'ER', 'Emergency Room'),

    (7, 2, 'ICU', '1st Floor'),

    (8, 2,'Pediatrics', '2nd Floor'),

    (9, 2, 'OR', '1st Floor'),

    (10, 3, 'Radiology', '4th Floor'),

    (11, 3, 'ER', 'Emergency Room'),

    (12, 3, 'ICU', '1st Floor'),

    (13, 3,'Neurology', '2nd Floor'),

    (14, 3, 'OR', '1st Floor'),

    (15, 3, 'Radiology', '4th Floor'); 

GO 


-- Insert Data to Doctor table

INSERT INTO Doctor (DoctorID, DepartmentID, LastName, FirstName)
VALUES  

	(1, 1, 'FINE', 'JIM'),   

	(2, 2, 'THORSON', 'CYNTHIA'),   

	(3, 3, 'SCHMIDT', 'MICHELLE'),   

	(4, 4, 'KNOX.', 'JULIE A'),   

	(5, 5, 'HARDIN', 'MICHAEL'),   

	(6, 6, 'GORDON', 'ANTHONY'),   

	(7, 7, 'AGUDA', 'MELCHOR'),   

	(8, 8, 'STEERS', 'SPENCER'),   

	(9, 9, 'COOMBS', 'BOB'),   

	(10, 10, 'CIRIDON', 'WILHELMINA (HMC)'), 

	(11, 11, 'EDENFIELD', 'MICHAEL'), 

	(12, 12, 'SUNQUEST', 'PERSONEL'), 

	(13, 13, 'MANGALINDAN', 'OFELIA'), 

	(14, 14, 'CHEE', 'JACQUELINE'), 

	(15, 15, 'HANISCH', 'UTE'), 

	(16, 12, 'SCHMELING', 'MICHAEL'), 

	(17, 3, 'KEY', 'LISA (HMC)'), 

	(18, 1, 'KNOWLTON', 'STEVE'), 

	(19, 5, 'SANTOS', 'ERIC'), 

	(20, 9, 'AKAGI', 'LAURA'); 

GO 


-- Insert Data to Nurse table

INSERT INTO Nurse (NurseID, DepartmentID, LastName, FirstName)   
VALUES  

	(1, 1, 'MEJINO', 'JOSE'),   

	(2, 2, 'CARLSON', 'TIMOTHY'),   

	(3, 3, 'HUTCHERSON', 'JENNY (HMC)'),   

	(4, 4, 'GRETCH', 'DAVID'),   

	(5, 5, 'VELDEE', 'MEGAN'),   

	(6, 6, 'NANCE', 'CAROLYN'),   

	(7, 7, 'OTA-BISHOP', 'COURTNEY'),   

	(8, 8, 'MC MINN', 'RICHARD'),   

	(9, 9, 'ANDREOTII', 'JILL (HMC)'),   

	(10, 10, 'ROA', 'PAUL'), 

	(11, 11, 'MAXIM', 'KEVIN'), 

	(12, 12, 'SCHNEIDER', 'JOE'), 

	(13, 13, 'AGUDA' , 'MA NANCY'), 

	(14, 14, 'FELIX', 'JORGE'), 

	(15, 15, 'RYAN', 'MICHAEL'), 

	(16, 2, 'HOGARTH', 'SUSAN'), 

	(17, 5, 'ORTEGA', 'JOSE PAZ'), 

	(18, 9, 'LOVERIDGE', 'PATRICIA'), 

	(19, 10, 'JENSEN', 'DIANE'), 

	(20, 11, 'BRILLAULT', 'JEANNE M.'); 
	
GO


-- Insert Data to Room table

INSERT INTO Room (RoomID, DepartmentID, RoomLocation)   
VALUES  

	(1, 1, 'Room 101'),   

	(2, 1, 'Room 102'),   

	(3, 2, 'Room 201'),   

	(4, 3, 'Room 301'),   

	(5, 2, 'Room 202'),   

	(6, 3, 'Room 302'),   

	(7, 1, 'Room 103'),   

	(8, 3, 'Room 303'),   

	(9, 2, 'Room 203'),   

	(10, 1, 'Room 104');   

GO 

-- Insert Data to Blood Product Information table

INSERT INTO Blood_Product_Information (BloodProductDetailID, BloodProductType, Volume, ABOType, RHType)
VALUES

    (1, 'RBC', 350, 'A', '+'),   

    (2, 'Plasma', 300, 'B', '-'),   

    (3, 'Cryo', 20, 'AB', '-'),   

    (4, 'Platelets', 300, 'O', '+'),   

    (5, 'RBC', 350, 'B', '-'),   

    (6, 'Plasma', 300, 'A', '-'),   

    (7, 'Cryo', 20, 'O', '+'),   

    (8, 'Platelets', 300, 'AB', '-'),   

    (9, 'RBC', 350, 'O', '-'),   

    (10, 'Plasma', 300, 'AB', '+'); 
	
GO


-- Insert Data to Storage Type table

INSERT INTO Storage_Type (StorageTypeID, Temperature, Capacity, AllowedProduct)   
VALUES    

    (1, 5, 350, 'RBC'),   

    (2, -40, 300, 'Plasma'),   

    (3, -40, 20, 'Cryo'),   

	(4, 5, 300, 'Platelets'),

    (5, 5, 300, 'WholeBlood'); 

GO 


-- Insert Data to Hospital Storage table

INSERT INTO HospitalStorage (StorageID, DepartmentID, StorageTypeID, Name, CurrentLocation, HomeLocation, BloodProductQuantity, CurrentStatus)  
VALUES  

(1, 9, 1, 'Blood Storage', '3rd Floor, Building A', '1st Floor, Building A', 100, 'In Transit'), 

(2, 6, 2, 'Vaccine Storage', '4th Floor, Building B', '2nd Floor, Building B', 50, '4th Floor, Building B'), 

(3, 14, 1, 'Plasma Storage', '2nd Floor, Building C', '3rd Floor, Building C', 75, 'In Transit'), 

(4, 11, 3, 'Medicine Storage', '5th Floor, Building D', '4th Floor, Building D', 200, 'In Transit'), 

(5, 5, 2, 'Vaccine Storage', '7th Floor, Building E', '5th Floor, Building E', 40, 'In Transit'), 

(6, 7, 1, 'Blood Storage', '6th Floor, Building F', '6th Floor, Building F', 90, 'In Transit'), 

(7, 3, 3, 'Medicine Storage', '9th Floor, Building G', '7th Floor, Building G', 150, '9th Floor, Building G'), 

(8, 12, 2, 'Vaccine Storage', '8th Floor, Building H', '8th Floor, Building H', 60, '8th Floor, Building H'), 

(9, 1, 3, 'Medicine Storage', '10th Floor, Building I', '9th Floor, Building I', 175, 'In Transit'), 

(10, 8, 1, 'Plasma Storage', '11th Floor, Building J', '10th Floor, Building J', 80, 'In Transit'), 

(11, 2, 2, 'Vaccine Storage', '12th Floor, Building K', '11th Floor, Building K', 30, '12th Floor, Building K'), 

(12, 15, 3, 'Medicine Storage', '13th Floor, Building L', '12th Floor, Building L', 120, 'In Transit'), 

(13, 4, 1, 'Blood Storage', '14th Floor, Building M', '13th Floor, Building M', 70, 'In Transit'), 

(14, 10, 2, 'Vaccine Storage', '15th Floor, Building N', '14th Floor, Building N', 20, 'In Transit'), 

(15, 13, 1, 'Plasma Storage', '16th Floor, Building O', '15th Floor, Building O', 50, 'In Transit'), 

(16, 1, 3, 'Medicine Storage', '17th Floor, Building P', '16th Floor, Building P', 180, '17th Floor, Building P'), 

(17, 3, 2, 'Vaccine Storage', '18th Floor, Building Q', '17th Floor, Building Q', 70, '18th Floor, Building Q'), 

(18, 5, 1, 'Blood Storage', '19th Floor, Building R', '18th Floor, Building R', 85, '19th Floor, Building R'), 

(19, 11, 3, 'Medicine Storage', '20th Floor, Building S', '19th Floor, Building S', 250, 'In Transit'), 

(20, 7, 2, 'Vaccine Storage', '2nd Floor', '1st Floor', 70, 'In Transit'), 

(21, 6, 1, 'Plasma Storage', '4th Floor', '3rd Floor', 60, 'In Transit'), 

(22, 11, 1, 'Blood Storage', '8th Floor', '6th Floor', 100, 'In Transit'), 

(23, 4, 3, 'Medicine Storage', '7th Floor', '5th Floor', 175, '5th Floor'), 

(24, 15, 2, 'Vaccine Storage', '6th Floor', '5th Floor', 80, 'In Transit'), 

(25, 8, 1, 'Blood Storage', '11th Floor', '10th Floor', 110, 'In Transit'), 

(26, 3, 3, 'Medicine Storage', '10th Floor', '9th Floor', 200, 'In Transit'), 

(27, 12, 2, 'Vaccine Storage', '11th Floor', '10th Floor', 90, 'In Transit'), 

(28, 2, 3, 'Medicine Storage', '2nd Floor', '1st Floor', 150, '2nd Floor'), 

(29, 9, 1, 'Plasma Storage', '12th Floor', '11th Floor', 120, 'In Transit'), 

(30, 13, 2, 'Vaccine Storage', '7th Floor', '5th Floor', 50, '7th Floor'); 

GO


-- Insert Data to Patient table

INSERT INTO Patient (PatientID, RoomID, NurseID, DoctorID, LastName, FirstName, DateOfBirth, PhoneNumber, ABOType, RHType)   
VALUES

(1, 1, 1, 1, 'Holloway', 'Karen', '1986-05-22', '555-1234', 'A', '+'),   

(2, 2, 2, 2, 'Thatcher', 'Pamela', '1975-12-10', '555-5678', 'O', '-'),   

(3, 3, 3, 3, 'Seyedirashti', 'Ray', '1990-08-15', '555-9876', 'AB', '+'),   

(4, 4, 4, 4, 'Chhabra' , 'Ajay', '1982-11-07', '555-2468', 'B', '-'),   

(5, 5, 5, 5, 'Thorne', 'Kellie', '1978-03-31', '555-1357', 'A', '+'),   

(6, 6, 6, 6, 'Bidar', 'Mimi', '1995-06-01', '555-8642', 'O', '-'),   

(7, 7, 7, 7, 'Nebeker', 'Angie', '1989-09-24', '555-3333', 'AB', '+'),   

(8, 8, 8, 8, 'Chavez', 'Sarah', '1980-02-28', '555-8888', 'A', '+'),   

(9, 9, 9, 9, 'Lo', 'Jean Chow', '1972-12-17', '555-6789', 'B', '-'),   

(10, 10, 10, 10, 'Laha', 'Thomas', '1992-07-04', '555-4321', 'O', '-'), 

(11, 7, 11, 11, 'Parekh', 'Bulbul', '1984-10-26', '555-2468', 'AB', '+'), 

(12, 2, 12, 12, 'Sommers', 'Clare', '1976-02-19', '555-9876', 'B', '-'), 

(13, 8, 13, 13, 'Condon', 'Judy', '1998-04-13', '555-7777', 'A', '+'), 

(14, 4, 14, 14, 'Nordstrom', 'Gloria', '1991-09-06', '555-5555', 'O', '-'), 

(15, 5, 15, 15, 'Barrus', 'Elinor', '1987-01-30', '555-2468', 'AB', '+'), 

(16, 6, 3, 13, 'Bradshaw', 'Marcy', '1979-05-23', '555-2222', 'B', '-'), 

(17, 10, 5, 10, 'Astion', 'Mike', '1996-08-19', '555-8888', 'A', '+'), 

(18, 9, 9, 14, 'Cookson', 'Brad', '1983-11-11', '555-3333', 'O', '-'), 

(19, 1, 10, 6, 'Ortiz', 'Boyoun Seely', '1985-05-22', '555-1234', 'AB', '+'), 

(20, 3, 9, 3, 'Neuman', 'Sue', '1978-08-15', '555-5678', 'O', '-'); 

GO 


-- Insert Data to Processed Blood Product Inventory table

INSERT INTO Processed_Blood_Product_Inventory (BloodProductID, StorageID, TechID, BloodProductDetailID, ProcessedDateTime)   

VALUES (1, 4, 2, 3, '2022-04-07 12:15:00');   
  

INSERT INTO Processed_Blood_Product_Inventory (BloodProductID, StorageID, TechID, BloodProductDetailID, ProcessedDateTime)   
VALUES (2, 7, 5, 8, '2022-04-07 11:20:00');   

  
INSERT INTO Processed_Blood_Product_Inventory (BloodProductID, StorageID, TechID, BloodProductDetailID, ProcessedDateTime)   
VALUES (3, 5, 1, 6, '2022-04-07 14:45:00');   
  

INSERT INTO Processed_Blood_Product_Inventory (BloodProductID, StorageID, TechID, BloodProductDetailID, ProcessedDateTime)   
VALUES (4, 3, 3, 7, '2022-04-07 10:30:00');   
 

INSERT INTO Processed_Blood_Product_Inventory (BloodProductID, StorageID, TechID, BloodProductDetailID, ProcessedDateTime)   
VALUES (5, 2, 4, 1, '2022-04-07 13:00:00');   
  

INSERT INTO Processed_Blood_Product_Inventory (BloodProductID, StorageID, TechID, BloodProductDetailID, ProcessedDateTime)   
VALUES (6, 9, 2, 10, '2022-04-07 15:30:00');   
  

INSERT INTO Processed_Blood_Product_Inventory (BloodProductID, StorageID, TechID, BloodProductDetailID, ProcessedDateTime)   
VALUES (7, 6, 5, 4, '2022-04-07 11:45:00');   


INSERT INTO Processed_Blood_Product_Inventory (BloodProductID, StorageID, TechID, BloodProductDetailID, ProcessedDateTime)   
VALUES (8, 8, 1, 5, '2022-04-07 14:00:00');   


INSERT INTO Processed_Blood_Product_Inventory (BloodProductID, StorageID, TechID, BloodProductDetailID, ProcessedDateTime)   
VALUES (9, 1, 3, 2, '2022-04-07 12:45:00');   

  
INSERT INTO Processed_Blood_Product_Inventory (BloodProductID, StorageID, TechID, BloodProductDetailID, ProcessedDateTime)   
VALUES (10, 10, 4, 9, '2022-04-07 16:00:00');   

GO

-- Insert Data to Blood Product table

INSERT INTO BloodProduct (BloodProductID, StorageID, BloodProductEntryDateTime)   
VALUES 

(1, 1, '2022-04-10 12:00:00');

INSERT INTO BloodProduct (BloodProductID, StorageID, BloodProductEntryDateTime)   
VALUES 

(2, 2, '2022-04-11 11:00:00');

INSERT INTO BloodProduct (BloodProductID, StorageID, BloodProductEntryDateTime)   
VALUES

(3, 3, '2022-04-11 12:00:00');   

INSERT INTO BloodProduct (BloodProductID, StorageID, BloodProductEntryDateTime)   
VALUES 

(4, 4, '2022-04-11 13:00:00');   

INSERT INTO BloodProduct (BloodProductID, StorageID, BloodProductEntryDateTime)   
VALUES

(5, 5, '2022-04-11 14:00:00');

INSERT INTO BloodProduct (BloodProductID, StorageID, BloodProductEntryDateTime)   
VALUES

(6, 6, '2022-04-11 15:00:00');   

INSERT INTO BloodProduct (BloodProductID, StorageID, BloodProductEntryDateTime)   
VALUES

(7, 7, '2022-04-11 16:00:00');  

INSERT INTO BloodProduct (BloodProductID, StorageID, BloodProductEntryDateTime)   
VALUES

(8, 8, '2022-04-11 17:00:00');   

INSERT INTO BloodProduct (BloodProductID, StorageID, BloodProductEntryDateTime)   
VALUES  

(9, 9, '2022-04-11 18:00:00'); 

INSERT INTO BloodProduct (BloodProductID, StorageID, BloodProductEntryDateTime)   
VALUES  

(10, 10, '2022-04-11 19:00:00');  

GO


-- Insert Data to Transfusion table

INSERT INTO Transfusion (TransfusionID, PatientID, BloodProductID, TransfusionDateTime)   
VALUES  

(1, 1, 1, '2022-05-02 09:30:00'),   

(2, 2, 2, '2022-05-03 10:45:00'),   

(3, 3, 3, '2022-05-04 11:15:00'),   

(4, 4, 4, '2022-05-05 12:30:00'),   

(5, 5, 5, '2022-05-06 13:45:00'),   

(6, 6, 6, '2022-05-07 14:15:00'),   

(7, 7, 7, '2022-05-08 15:30:00'),   

(8, 8, 8, '2022-05-09 16:45:00'),   

(9, 9, 9, '2022-05-10 17:15:00'),   

(10, 10, 10, '2022-05-11 18:10:00'); 

GO 


-- Insert Data to Donor table

INSERT INTO Donor (DonorID, FirstName, LastName, PhoneNumber, DateOfBirth, Gender, ABOType, RHType)   
VALUES   

    (1, 'John', 'Smith', '555-1234', '1980-01-01', 'M', 'A', '+'),   

    (2, 'Jane', 'Doe', '555-5678', '1990-05-05', 'F', 'B', '-'),   

    (3, 'Bob', 'Johnson', '555-9999', '1975-12-31', 'M', 'O', '+'),   

    (4, 'Samantha', 'Lee', '555-1111', '1988-09-15', 'F', 'AB', '-'),   

    (5, 'David', 'Kim', '555-2222', '1972-03-20', 'M', 'B', '+'),   

    (6, 'Maria', 'Garcia', '555-3333', '1995-07-10', 'F', 'O', '-'),   

    (7, 'Michael', 'Nguyen', '555-4444', '1984-11-25', 'M', 'A', '-'),   

    (8, 'Karen', 'Chen', '555-5555', '1978-06-02', 'F', 'B', '+'),   

    (9, 'Daniel', 'Park', '555-6666', '1992-02-14', 'M', 'O', '+'),   

    (10, 'Jessica', 'Wang', '555-7777', '1986-04-30', 'F', 'AB', '-'),

	(11, 'John', 'Kim', '555-1234', '1980-01-01', 'M', 'A', '+'),   

    (12, 'Jane', 'Lee', '555-5678', '1990-10-05', 'F', 'B', '-'),   

    (13, 'Maria', 'Johnson', '566-9999', '1976-12-31', 'F', 'O', '+'),   

    (14, 'Samantha', 'Lee', '566-1111', '1988-09-15', 'F', 'AB', '-'),   

    (15, 'David', 'Nguyen', '666-2222', '1972-04-20', 'M', 'B', '+'),   

    (16, 'Maria', 'Garcia', '665-3333', '1995-07-20', 'F', 'O', '-'),   

    (17, 'Michael', 'Nguyen', '555-4444', '1984-12-25', 'M', 'A', '-'),   

    (18, 'Samantha', 'Chen', '555-5555', '1978-09-02', 'F', 'B', '+'),   

    (19, 'Karen', 'Park', '555-6666', '1992-05-24', 'F', 'O', '+'),   

    (20, 'Daniel', 'Wang', '555-7777', '1996-03-30', 'F', 'AB', '-');

GO 


-- Insert Data to Donor History table

INSERT INTO DonorHistory (DonorHistoryID, MonthsSinceLast, NumDonations, TotalVolume, MonthsSinceFirst, DonorID)   
VALUES   

    (619, 2, 50, 12500, 98, 1),   

    (664, 0, 13, 3250, 28 ,2),   

    (441, 1, 16, 4000, 35, 3),   

    (160, 2, 20, 5000, 45, 4),   
  
    (358, 1, 24, 6000, 77, 5),    

    (335, 4, 4, 1000, 4, 6),   

    (47, 2, 7, 1750, 14, 7),   

    (164, 1, 12, 3000, 35, 8),   

    (736, 5, 46, 11500, 98, 9),   

    (436, 0, 3, 750, 4, 10), 

	(460, 2, 10, 2500, 28, 11),
	
	(285, 1, 13, 3250, 47, 12), 

	(499, 2, 6, 1500, 15, 13), 

	(356, 2, 5, 1250, 11, 14), 

	(40, 2, 14, 3500, 48, 15), 

	(191, 2, 15, 3750, 49, 16), 

	(638, 2, 6, 1500, 15, 17), 

	(345, 2, 3, 750, 4, 18), 

	(463, 2, 3, 750, 4, 19), 

	(372, 4, 11, 2750, 28, 20); 
	
GO


-- Insert Data to BB Storage table

INSERT INTO BBStorage (StorageID, DepartmentID, StorageTypeID, Capacity) 
VALUES 

    (1, 1, 1, 100), 

    (2, 1, 1, 50), 

    (3, 1, 2, 15), 

    (4, 1, 3, 40), 

    (5, 1, 4, 60), 

    (6, 1, 5, 80), 

    (7, 2, 5, 20), 

    (8, 3, 5, 30), 

    (9, 4, 5, 100), 

    (10, 5, 5, 70); 

GO


-- Insert Data to Unprocessed Blood Product Inventory table

INSERT INTO UnprocessedBloodProductInventory (UnprocessedBloodID, RawBloodID, StorageID, ExpireDateTime)   
VALUES   

    (1, 1, 1, '2022-05-01 12:00:00'),   

    (2, 2, 2, '2022-06-15 10:30:00'),   

    (3, 3, 3,'2022-06-30 14:45:00'),   

    (4, 4, 4,'2022-07-15 17:00:00'),   

    (5, 5, 5,'2022-07-31 19:15:00'),   

    (6, 6, 1,'2022-08-15 08:00:00'),   

    (7, 7, 2,'2022-08-30 11:30:00'),   

    (8, 8, 3,'2022-09-15 15:45:00'),   

    (9, 9, 4,'2022-09-30 18:00:00'),   

    (10, 10, 5,'2022-10-15 20:15:00'); 
	
GO 


-- Insert Data to BB Department

INSERT INTO BBDepartment (DepartmentID, StorageID, Address1, Address2, City, State, Zipcode)   
VALUES   

(1, 1,'921 Terry Ave','', 'Seattle', 'WA', '98104'),  

(2, 2, '10357 Stone Ave N', '', 'Seattle', 'WA', '98133'),  

(3, 3, '2211 Minor Ave N', '', 'Seattle', 'WA', '98109'),  

(4, 4, '921 E James St', '', 'Seattle', 'WA', '98122'),  

(5, 5, '4534 University Way NE', '', 'Seattle', 'WA', '98105'); 

GO 


-- Insert Data to Tech table

INSERT INTO Tech (TechID, DepartmentID, Position, FirstName, LastName)  
VALUES   

    (1, 1, 'blood collection specialist', 'John', 'Doe'),  

    (2, 1, 'blood processing technician', 'Jane', 'Doe'),  

    (3, 2, 'blood collection specialist', 'Bob', 'Smith'),  

    (4, 2, 'blood processing technician', 'Sara', 'Johnson'),  

    (5, 3, 'blood collection specialist', 'Mike', 'Lee'),  

    (6, 3, 'blood processing technician', 'Karen', 'Kim'),  

    (7, 4, 'blood collection specialist', 'David', 'Jones'),  

    (8, 4, 'blood processing technician', 'Linda', 'Davis'),  

    (9, 5, 'blood collection specialist', 'Tom', 'Brown'),  

    (10, 5, 'blood processing technician', 'Amy', 'Miller'),  

    (11, 4, 'blood collection specialist', 'Mark', 'Taylor'),  

    (12, 3, 'blood processing technician', 'Julia', 'Clark'), 

    (13, 2, 'blood collection specialist', 'Chris', 'Evans'),  

    (14, 1, 'blood processing technician', 'Emma', 'Watson'),  

    (15, 1, 'blood collection specialist', 'Adam', 'Garcia'),  

    (16, 2, 'blood processing technician', 'Olivia', 'Harris'),  

    (17, 3, 'blood collection specialist', 'Alex', 'Moore'),  

    (18, 4, 'blood processing technician', 'Sophia', 'Allen'),  

    (19, 5, 'blood collection specialist', 'Luke', 'Wright'),  

	(20, 1, 'blood processing technician', 'Ava', 'Roberts'); 
	
GO


-- Insert Data to Donation table

INSERT INTO Donation (DonationID, DonorID, TechID, RawBloodID, DepartmentID, DonationDateTime, DonationVolume)   
VALUES   

    (1, 1, 1, 1, 1, '2023-04-07 10:00:00', 500),   

    (2, 2, 3, 2, 2, '2023-04-07 11:00:00', 450),   

    (3, 3, 5, 3, 3, '2023-04-07 12:00:00', 550),   

    (4, 4, 7, 4, 4, '2023-04-07 13:00:00', 600),   

    (5, 5, 9, 5, 5, '2023-04-07 14:00:00', 700),   

    (6, 6, 11, 6, 5, '2023-04-07 15:00:00', 650),   

    (7, 7, 13, 7, 4, '2023-04-07 16:00:00', 550),   

    (8, 8, 15, 8, 3, '2023-04-07 17:00:00', 600),   

    (9, 9, 17, 9, 2, '2023-04-07 18:00:00', 450), 

    (10, 10, 19, 10, 1, '2023-04-07 19:00:00', 500);   

GO 


-- Insert Data to Transit table

INSERT INTO Transit (TransitID, StorageID, HospitalID, TransitDepartureTime)   
VALUES    

    (1, 1, 2, '2022-04-10 12:00:00'),   

    (2, 3, 3, '2022-04-10 13:00:00'),   

    (3, 2, 1, '2022-04-10 14:00:00'),   

    (4, 4, 1, '2022-04-10 15:00:00'),   

    (5, 5, 2, '2022-04-10 16:00:00'),   

    (6, 7, 3, '2022-04-10 17:00:00'),   

    (7, 9, 2, '2022-04-10 18:00:00'),   

    (8, 8, 1, '2022-04-10 19:00:00'),   

    (9, 6, 3, '2022-04-10 20:00:00'),   

    (10, 10, 2, '2022-04-10 21:00:00');   

GO 


-- Insert Data to Order table

INSERT INTO [Order] (OrderID, TransitID, OrderArrivalDateTime, OrderStatus, OrderType)    
VALUES     

    (1, 1, '2022-04-11 10:00:00', 'Arrived', 'Red Blood Cells'),    

    (2, 2, '2022-04-11 11:00:00', 'Arrived', 'Plasma'),    

    (3, 3, '2022-04-11 12:00:00', 'In Transit', 'Platelets'),    

    (4, 4, '2022-04-11 13:00:00', 'In Transit', 'Red Blood Cells'),    

    (5, 5, '2022-04-11 14:00:00', 'Pending', 'Plasma'),    

    (6, 6, '2022-04-11 15:00:00', 'Pending', 'Red Blood Cells '),    

    (7, 7, '2022-04-11 16:00:00', 'Arrived', 'Red Blood Cells'),    

    (8, 8, '2022-04-11 17:00:00', 'In Transit', 'Platelets'),    

    (9, 9, '2022-04-11 18:00:00', 'Arrived', 'Red Blood Cells'),    

    (10, 10, '2022-04-11 19:00:00', 'Pending', 'Platelets');  

GO 

-- Encrypt Donors' Phone Number
-- Create a symmetric key
CREATE SYMMETRIC KEY PhoneNumberKey
WITH ALGORITHM = AES_256
ENCRYPTION BY PASSWORD = 'DAMG6210';

-- Open the symmetric key
OPEN SYMMETRIC KEY PhoneNumberKey
DECRYPTION BY PASSWORD = 'DAMG6210';

-- Encrypt the PhoneNumber column
UPDATE Donor
SET PhoneNumber = EncryptByKey(Key_GUID('PhoneNumberKey'), PhoneNumber);

-- Close the symmetric key
CLOSE SYMMETRIC KEY PhoneNumberKey;

-- Drop the symmetric key
DROP SYMMETRIC KEY PhoneNumberKey;


-- Make some changes

UPDATE Patient

SET RoomID = 2 

WHERE PatientID = 1;  
GO

UPDATE Hospital 
SET HospitalAddress2 = ' '
WHERE HospitalAddress2 IS NULL;
