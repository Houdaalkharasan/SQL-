-- Table: FestivalGoer
-- Columns:
--   FestivalGoerId: primary key, unique identifier for a festival goer
--   FGFirstName: first name (required)
--   FGLastName: last name (required)
--   FGMailAddress: email address, unique and required
--   FGPhone: phone number, unique and required
CREATE TABLE FestivalGoer (FestivalGoerId SERIAL PRIMARY KEY,
                                                 FGFirstName VARCHAR(50) NOT NULL,
                                                                         FGLastName VARCHAR(50) NOT NULL,
                                                                                                FGMailAddress VARCHAR(100) UNIQUE NOT NULL,
                                                                                                                                  FGPhone VARCHAR(15) UNIQUE NOT NULL);

-- Note: TicketHolder is a subtype of FestivalGoer (overlapping, partial ISA)
-- Table: TicketHolder
-- Columns:
--   TicketHolderId: primary key for the ticket-holder record
--   FestivalGoerId: FK to FestivalGoer(FestivalGoerId), links subtype to parent
--   Balance: non-negative decimal representing credit balance
CREATE TABLE TicketHolder (TicketHolderId SERIAL PRIMARY KEY,
                                                 FestivalGoerId INTEGER NOT NULL,
                                                                        Balance DECIMAL NOT NULL CHECK (Balance >= 0),
                           FOREIGN KEY (FestivalGoerId) REFERENCES FestivalGoer(FestivalGoerId));


-- Table: SponsorRep (another partial overlapping subtype of FestivalGoer)
-- Columns:
--   SponsorRepId: primary key for sponsor representative
--   FestivalGoerId: FK to FestivalGoer(FestivalGoerId), links subtype to parent
--   TFN: tax file number, unique and required
--   BankAccount: bank account identifier, unique
--   SponsorshipRate: optional numeric rate
CREATE TABLE SponsorRep(SponsorRepId SERIAL PRIMARY KEY,
                                            FestivalGoerId INTEGER NOT NULL,
                                                                   TFN CHAR(9) UNIQUE NOT NULL,
                                                                                      BankAccount VARCHAR(20) UNIQUE NOT NULL,
                                                                                                                     SponsorshipRate DECIMAL,
                        FOREIGN KEY (FestivalGoerId) REFERENCES FestivalGoer(FestivalGoerId));


-- Table: Venue
-- Columns:
--   VenueId: primary key for a venue
--   NumberOfStages: integer count of stages (may be NULL)
--   Address: venue address, required
CREATE TABLE Venue (VenueId SERIAL PRIMARY KEY,
                                   NumberOfStages INTEGER, Address VARCHAR(100) NOT NULL);


-- Table: Facilities
-- Columns:
--   FacilityId: primary key for facility
--   Facility: description/name of the facility
CREATE TABLE Facilities (FacilityId SERIAL PRIMARY KEY,
                                           Facility VARCHAR(100) NOT NULL);


-- Table: VenueFacilities (many-to-many between Venue and Facilities)
-- Columns/constraints:
--   VenueId: FK to Venue(VenueId)
--   FacilityId: FK to Facilities(FacilityId)
--   Primary Key on (VenueId, FacilityId) to avoid duplicates
CREATE TABLE VenueFacilities (VenueId INTEGER, FacilityId INTEGER, PRIMARY KEY (VenueId,
                                                                                FacilityId),
                              FOREIGN KEY (VenueId) REFERENCES Venue(VenueId),
                              FOREIGN KEY (FacilityId) REFERENCES Facilities(FacilityId));


-- Table: Stage
-- Columns:
--   StageId: primary key for stage
--   Capacity: positive integer capacity of the stage
--   VenueId: FK to Venue(VenueId) indicating which venue contains the stage
--   Area: textual description of zone/area within venue
CREATE TABLE Stage (StageId SERIAL PRIMARY KEY,
                                   Capacity INTEGER CHECK (Capacity > 0), VenueId INTEGER NOT NULL,
                                                                                          Area VARCHAR(100) NOT NULL,
                    FOREIGN KEY (VenueId) REFERENCES Venue(VenueId));


-- Table: FestivalStaff
-- Columns and constraints:
--   FestivalStaffId: primary key for staff member
--   FSMailAddress: staff email, required
--   FSFirstName, FSLastName: staff name parts, required
--   FSName: generated full name concatenation (stored)
--   FSPhone: phone number (optional)
--   AssistedBy: self-referential FK to FestivalStaff(FestivalStaffId), may be NULL
CREATE TABLE FestivalStaff (FestivalStaffId SERIAL PRIMARY KEY,
                                                   FSMailAddress VARCHAR(100) NOT NULL,
                                                                              FSFirstName VARCHAR(50) NOT NULL,
                                                                                                      FSLastName VARCHAR(50) NOT NULL,
                                                                                                                             FSName VARCHAR(101) GENERATED ALWAYS AS (FSFirstName || ' ' || FSLastName) STORED,
                                                                                                                                                           FSPhone VARCHAR(20),
                                                                                                                                                                   AssistedBy INTEGER Null, -- Self-referencing foreign key and can be not assisted by any one,

                            FOREIGN KEY (AssistedBy) REFERENCES FestivalStaff(FestivalStaffId));


-- Table: WorkingDays
-- Columns:
--   WorkingDayId: PK for working day entry
--   WorkDayName: name of the day (e.g., 'Mon')
CREATE TABLE WorkingDays(WorkingDayId SERIAL PRIMARY KEY,
                                             WorkDayName VARCHAR(20) NOT NULL);


-- Table: DaysWorking (many-to-many between FestivalStaff and WorkingDays)
-- Columns/constraints:
--   FestivalStaffId: FK to FestivalStaff
--   WorkingDayId: FK to WorkingDays
--   PK on (FestivalStaffId, WorkingDayId)
CREATE TABLE DaysWorking (FestivalStaffId INTEGER, WorkingDayId INTEGER, PRIMARY KEY (FestivalStaffId,
                                                                                      WorkingDayId),
                          FOREIGN KEY (FestivalStaffId) REFERENCES FestivalStaff(FestivalStaffId),
                          FOREIGN KEY (WorkingDayId) REFERENCES WorkingDays(WorkingDayId));


-- Table: PerformanceSlot
-- Columns:
--   SlotId: primary key for performance slot
--   StartDateTime, EndDateTime: start and end timestamps for the slot (end must be after start)
--   PerformanceFee: non-negative agreed fee
--   StageId: FK to Stage indicating where the slot occurs
CREATE TABLE PerformanceSlot (SlotId SERIAL PRIMARY KEY,
                                            StartDateTime TIMESTAMP NOT NULL,
                                                                    EndDateTime TIMESTAMP NOT NULL,
                                                                                          PerformanceFee DECIMAL NOT NULL CHECK (PerformanceFee >= 0), StageId INTEGER NOT NULL,
                              FOREIGN KEY (StageId) REFERENCES Stage(StageId));


-- Table: Sponsors (which sponsor reps fund which stages and intervals)
-- Columns/constraints:
--   SponsorRepId: FK to SponsorRep
--   StageId: FK to Stage
--   StartDate, EndDate: sponsorship interval (both NOT NULL in this design)
--   SponsorshipAmount: positive amount
--   Primary key on (SponsorRepId, StageId) to avoid duplicate active rows for same pair
CREATE TABLE Sponsors (SponsorRepId INTEGER, StageId INTEGER, StartDate DATE NOT NULL,
                                                                             EndDate DATE NOT NULL,
                                                                                          SponsorshipAmount DECIMAL NOT NULL CHECK (SponsorshipAmount > 0), PRIMARY KEY (SponsorRepId,
                                                                                                                                                                         StageId),
                       FOREIGN KEY (SponsorRepId) REFERENCES SponsorRep(SponsorRepId),
                       FOREIGN KEY (StageId) REFERENCES Stage(StageId));


-- Table: Contacts (records most recent contact between staff and festival goer)
-- Columns/constraints:
--   FestivalStaffId: FK to FestivalStaff
--   FestivalGoerId: FK to FestivalGoer
--   LatestContactDate: date of most recent contact
--   PK on (FestivalStaffId, FestivalGoerId)
CREATE TABLE Contacts (FestivalStaffId INTEGER, FestivalGoerId INTEGER, LatestContactDate DATE NOT NULL,
                                                                                               PRIMARY KEY (FestivalStaffId,
                                                                                                            FestivalGoerId),
                       FOREIGN KEY (FestivalStaffId) REFERENCES FestivalStaff(FestivalStaffId),
                       FOREIGN KEY (FestivalGoerId) REFERENCES FestivalGoer(FestivalGoerId));

-- For PerformsAt, checking the ER diagram shows a relationship between TicketHolder and PerformanceSlot
-- Table: PerformsAt
-- Columns/constraints:
--   TicketHolderId: FK to TicketHolder
--   SlotId: FK to PerformanceSlot
--   TicketPrice: non-negative final ticket price for the performance
--   PK on (TicketHolderId, SlotId)
CREATE TABLE PerformsAt (TicketHolderId INTEGER, SlotId INTEGER, TicketPrice DECIMAL NOT NULL CHECK (TicketPrice >= 0), PRIMARY KEY (TicketHolderId,
                                                                                                                                     SlotId),
                         FOREIGN KEY (TicketHolderId) REFERENCES TicketHolder(TicketHolderId),
                         FOREIGN KEY (SlotId) REFERENCES PerformanceSlot(SlotId));

-- For AppliesFor, relationship between TicketHolder and PerformanceSlot representing applications
-- Table: AppliesFor
-- Columns/constraints:
--   TicketHolderId: FK to TicketHolder
--   SlotId: FK to PerformanceSlot
--   ProposedFee: non-negative proposed fee
--   RequestedDuration: integer minutes requested (positive)
--   PK on (TicketHolderId, SlotId)
CREATE TABLE AppliesFor (TicketHolderId INTEGER, SlotId INTEGER, ProposedFee DECIMAL NOT NULL CHECK (ProposedFee >= 0), -- Stored as integer number of minutes for compatibility
 RequestedDuration INTEGER NOT NULL CHECK (RequestedDuration > 0), PRIMARY KEY (TicketHolderId,
                                                                                SlotId),
                         FOREIGN KEY (TicketHolderId) REFERENCES TicketHolder(TicketHolderId),
                         FOREIGN KEY (SlotId) REFERENCES PerformanceSlot(SlotId));


-- Table: Manages (links staff to stages they manage)
-- Columns/constraints:
--   FestivalStaffId: FK to FestivalStaff
--   StageId: FK to Stage
--   PK on (FestivalStaffId, StageId)
CREATE TABLE Manages (FestivalStaffId INTEGER, StageId INTEGER, PRIMARY KEY (FestivalStaffId,
                                                                             StageId),
                      FOREIGN KEY (FestivalStaffId) REFERENCES FestivalStaff(FestivalStaffId),
                      FOREIGN KEY (StageId) REFERENCES Stage(StageId));