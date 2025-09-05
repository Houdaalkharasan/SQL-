CREATE TABLE FestivalGoer (
    FestivalGoerId INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    FGFirstName VARCHAR(50) NOT NULL,
    FGLastName VARCHAR(50) NOT NULL,
    FGMailAddress VARCHAR(100) UNIQUE NOT NULL,
    FGPhone VARCHAR(15) UNIQUE NOT NULL
);

CREATE TABLE TicketHolder (
    TicketHolderId INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    Balance DECIMAL NOT NULL CHECK (Balance >= 0),
);

CREATE TABLE SponsorRep(
    SponserRepId INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    TFN CHAR(9) UNIQUE NOT NULL,
    BankAccount VARCHAR(20) UNIQUE NOT NULL,
    SponserShipRate DECIMAL,
);

CREATE TABLE IsA(
    FestivalGoerId INTEGER,
    TicketHolderId INTEGER,
    SponserRepId INTEGER,
    PRIMARY KEY (FestivalGoerId, TicketHolderId, SponserRepId),
    FOREIGN KEY (FestivalGoerId) REFERENCES FestivalGoer(FestivalGoerId),
    FOREIGN KEY (TicketHolderId) REFERENCES TicketHolder(TicketHolderId),
    FOREIGN KEY (SponserRepId) REFERENCES SponsorRep(SponserRepId)
)

CREATE TABLE Venue (
    VenueId INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    NumberOfStages INTEGER,
    Address VARCHAR(100) NOT NULL
);

CREATE TABLE Facilities (
    FacilityId INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    Facility VARCHAR(100) NOT NULL,
 
);

CREATE TABLE VenueFacilities (
    VenueId INTEGER,
    FacilityId INTEGER,
    PRIMARY KEY (VenueId, FacilityId),
    FOREIGN KEY (VenueId) REFERENCES Venue(VenueId),
    FOREIGN KEY (FacilityId) REFERENCES Facilities(FacilityId)
);

CREATE TABLE Stage (
    StageId INTEGER PRIMARY KEY,
    Capacity INTEGER CHECK (Capacity > 0),
    VenueId INTEGER NOT NULL,
    Area VARCHAR(100) NOT NULL,
    FOREIGN KEY (VenueId) REFERENCES Venue(VenueId)
);
CREATE TABLE FestivalStaff (
    FestivalStaffID INTEGER PRIMARY KEY,
    FSMailAddress VARCHAR(100) NOT NULL,
    FSName varchar(101) generated always as (fsfirstname || ' ' || fslastname) virtual,
    FSFirstName VARCHAR(50) NOT NULL,
    FSLastName VARCHAR(50) NOT NULL,
    FSPhone VARCHAR(20)
);

CREATE TABLE WorkingDays(
    WorkingDaysID INTEGER PRIMARY KEY,
    WorkDayName VARCHAR(20) NOT NULL
)

CREATE TABLE DaysWorking (
    FestivalStaffID INTEGER,
    WorkingDaysID VARCHAR(20) NOT NULL,
    PRIMARY KEY (FestivalStaffID, WorkDay),
    FOREIGN KEY (FestivalStaffID) REFERENCES FestivalStaff(FestivalStaffID)
    FOREIGN KEY (WorkingDaysID) REFERENCES WorkingDays(WorkingDaysID)
);

CREATE TABLE PerformanceSlot (
    SlotId INTEGER PRIMARY KEY,
    StartDateTime TIMESTAMP NOT NULL,
    EndDateTime TIMESTAMP NOT NULL,
    PerformanceFee DECIMAL NOT NULL CHECK (PerformanceFee >= 0),
    StageId INTEGER NOT NULL,
    FOREIGN KEY (StageId) REFERENCES Stage(StageId)
);

CREATE TABLE Sponsors (
    FestivalGoerId INTEGER,
    StageId INTEGER,
    StartDate DATE NOT NULL,
    EndDate DATE NOT NULL,
    SponsorshipAmount DECIMAL NOT NULL CHECK (SponsorshipAmount > 0),
    PRIMARY KEY (FestivalGoerId, StageId),
    FOREIGN KEY (FestivalGoerId) REFERENCES SponsorRepresentative(FestivalGoerId),
    FOREIGN KEY (StageId) REFERENCES Stage(StageId)
);

CREATE TABLE Contacts (
    FestivalStaffID INTEGER,
    FestivalGoerId INTEGER,
    LatestContactDate DATE NOT NULL,
    PRIMARY KEY (FestivalStaffID, FestivalGoerId),
    FOREIGN KEY (FestivalStaffID) REFERENCES FestivalStaff(FestivalStaffID),
    FOREIGN KEY (FestivalGoerId) REFERENCES FestivalGoer(FestivalGoerId)
);

CREATE TABLE PerformsAt (
    FestivalGoerId INTEGER,
    SlotId INTEGER,
    TicketPrice NOT NULL CHECK (TicketPrice >= 0),
    PRIMARY KEY (FestivalGoerId, SlotId),
    FOREIGN KEY (FestivalGoerId) REFERENCES FestivalGoer(FestivalGoerId),
    FOREIGN KEY (SlotId) REFERENCES PerformanceSlot(SlotId)
);

CREATE TABLE AppliesFor (
    FestivalGoerId INTEGER,
    SlotId INTEGER,
    ProposedFee DECIMAL NOT NULL CHECK (ProposedFee >= 0),
    RequestedDuration INTERVAL NOT NULL,
    PRIMARY KEY (FestivalGoerId, SlotId),
    FOREIGN KEY (FestivalGoerId) REFERENCES FestivalGoer(FestivalGoerId),
    FOREIGN KEY (SlotId) REFERENCES PerformanceSlot(SlotId)
);

CREATE TABLE Manages (
    FestivalStaffID INTEGER,
    StageId INTEGER,
    PRIMARY KEY (FestivalStaffID, StageId),
    FOREIGN KEY (FestivalStaffID) REFERENCES FestivalStaff(FestivalStaffID),
    FOREIGN KEY (StageId) REFERENCES Stage(StageId)
);
