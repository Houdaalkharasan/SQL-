CREATE TABLE FestivalGoer (
    FestivalGoerId SERIAL PRIMARY KEY,
    FGFirstName VARCHAR(50) NOT NULL,
    FGLastName VARCHAR(50) NOT NULL,
    FGMailAddress VARCHAR(100) UNIQUE NOT NULL,
    FGPhone VARCHAR(15) UNIQUE NOT NULL
);

-- For ISA relationship (overlapping, partial): using foreign keys to parent
CREATE TABLE TicketHolder (
    TicketHolderId SERIAL PRIMARY KEY,
    FestivalGoerId INTEGER NOT NULL,
    Balance DECIMAL NOT NULL CHECK (Balance >= 0),
    FOREIGN KEY (FestivalGoerId) REFERENCES FestivalGoer(FestivalGoerId)
);

CREATE TABLE SponsorRep(
    SponsorRepId SERIAL PRIMARY KEY,
    FestivalGoerId INTEGER NOT NULL,
    TFN CHAR(9) UNIQUE NOT NULL,
    BankAccount VARCHAR(20) UNIQUE NOT NULL,
    SponsorshipRate DECIMAL,
    FOREIGN KEY (FestivalGoerId) REFERENCES FestivalGoer(FestivalGoerId)
);

CREATE TABLE Venue (
    VenueId SERIAL PRIMARY KEY,
    NumberOfStages INTEGER,
    Address VARCHAR(100) NOT NULL
);

CREATE TABLE Facilities (
    FacilityId SERIAL PRIMARY KEY,
    Facility VARCHAR(100) NOT NULL
);

CREATE TABLE VenueFacilities (
    VenueId INTEGER,
    FacilityId INTEGER,
    PRIMARY KEY (VenueId, FacilityId),
    FOREIGN KEY (VenueId) REFERENCES Venue(VenueId),
    FOREIGN KEY (FacilityId) REFERENCES Facilities(FacilityId)
);

CREATE TABLE Stage (
    StageId SERIAL PRIMARY KEY,
    Capacity INTEGER CHECK (Capacity > 0),
    VenueId INTEGER NOT NULL,
    Area VARCHAR(100) NOT NULL,
    FOREIGN KEY (VenueId) REFERENCES Venue(VenueId)
);

CREATE TABLE FestivalStaff (
    FestivalStaffId SERIAL PRIMARY KEY,
    FSMailAddress VARCHAR(100) NOT NULL,
    FSFirstName VARCHAR(50) NOT NULL,
    FSLastName VARCHAR(50) NOT NULL,
    FSPhone VARCHAR(20)
);

CREATE TABLE WorkingDays(
    WorkingDayId SERIAL PRIMARY KEY,
    WorkDayName VARCHAR(20) NOT NULL
);

CREATE TABLE DaysWorking (
    FestivalStaffId INTEGER,
    WorkingDayId INTEGER,
    PRIMARY KEY (FestivalStaffId, WorkingDayId),
    FOREIGN KEY (FestivalStaffId) REFERENCES FestivalStaff(FestivalStaffId),
    FOREIGN KEY (WorkingDayId) REFERENCES WorkingDays(WorkingDayId)
);

CREATE TABLE PerformanceSlot (
    SlotId SERIAL PRIMARY KEY,
    StartDateTime TIMESTAMP NOT NULL,
    EndDateTime TIMESTAMP NOT NULL,
    PerformanceFee DECIMAL NOT NULL CHECK (PerformanceFee >= 0),
    StageId INTEGER NOT NULL,
    FOREIGN KEY (StageId) REFERENCES Stage(StageId)
);

CREATE TABLE Sponsors (
    SponsorRepId INTEGER,
    StageId INTEGER,
    StartDate DATE NOT NULL,
    EndDate DATE NOT NULL,
    SponsorshipAmount DECIMAL NOT NULL CHECK (SponsorshipAmount > 0),
    PRIMARY KEY (SponsorRepId, StageId),
    FOREIGN KEY (SponsorRepId) REFERENCES SponsorRep(SponsorRepId),
    FOREIGN KEY (StageId) REFERENCES Stage(StageId)
);

CREATE TABLE Contacts (
    FestivalStaffId INTEGER,
    FestivalGoerId INTEGER,
    LatestContactDate DATE NOT NULL,
    PRIMARY KEY (FestivalStaffId, FestivalGoerId),
    FOREIGN KEY (FestivalStaffId) REFERENCES FestivalStaff(FestivalStaffId),
    FOREIGN KEY (FestivalGoerId) REFERENCES FestivalGoer(FestivalGoerId)
);

-- For PerformsAt, checking the ER diagram shows a relationship between TicketHolder and PerformanceSlot
CREATE TABLE PerformsAt (
    TicketHolderId INTEGER,
    SlotId INTEGER,
    TicketPrice DECIMAL NOT NULL CHECK (TicketPrice >= 0),
    PRIMARY KEY (TicketHolderId, SlotId),
    FOREIGN KEY (TicketHolderId) REFERENCES TicketHolder(TicketHolderId),
    FOREIGN KEY (SlotId) REFERENCES PerformanceSlot(SlotId)
);

-- For AppliesFor, checking the ER diagram shows a relationship between TicketHolder and PerformanceSlot
CREATE TABLE AppliesFor (
    TicketHolderId INTEGER,
    SlotId INTEGER,
    ProposedFee DECIMAL NOT NULL CHECK (ProposedFee >= 0),
    -- Stored as integer number of minutes for compatibility
    RequestedDuration INTEGER NOT NULL CHECK (RequestedDuration > 0),
    PRIMARY KEY (TicketHolderId, SlotId),
    FOREIGN KEY (TicketHolderId) REFERENCES TicketHolder(TicketHolderId),
    FOREIGN KEY (SlotId) REFERENCES PerformanceSlot(SlotId)
);

CREATE TABLE Assists (
    FestivalStaffId INTEGER,
    FestivalGoerId INTEGER,
    PRIMARY KEY (FestivalStaffId, FestivalGoerId),
    FOREIGN KEY (FestivalStaffId) REFERENCES FestivalStaff(FestivalStaffId),
    FOREIGN KEY (FestivalGoerId) REFERENCES FestivalGoer(FestivalGoerId)
);

CREATE TABLE Manages (
    FestivalStaffId INTEGER,
    StageId INTEGER,
    PRIMARY KEY (FestivalStaffId, StageId),
    FOREIGN KEY (FestivalStaffId) REFERENCES FestivalStaff(FestivalStaffId),
    FOREIGN KEY (StageId) REFERENCES Stage(StageId)
);
