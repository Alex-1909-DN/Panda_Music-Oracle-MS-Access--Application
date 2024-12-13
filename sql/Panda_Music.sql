
-- Create sequences
CREATE SEQUENCE genre_seq START WITH 100 INCREMENT BY 1 NOCACHE NOCYCLE;
CREATE SEQUENCE artist_seq START WITH 100 INCREMENT BY 1 NOCACHE NOCYCLE;
CREATE SEQUENCE album_seq START WITH 100 INCREMENT BY 1 NOCACHE NOCYCLE;

CREATE SEQUENCE bmember_seq START WITH 100 INCREMENT BY 1 NOCACHE NOCYCLE;
CREATE SEQUENCE band_member_seq START WITH 100 INCREMENT BY 1 NOCACHE NOCYCLE;

CREATE SEQUENCE atitle_seq START WITH 100 INCREMENT BY 1 NOCACHE NOCYCLE;
CREATE SEQUENCE album_title_seq START WITH 100 INCREMENT BY 1 NOCACHE NOCYCLE;

CREATE SEQUENCE gname_seq START WITH 100 INCREMENT BY 1 NOCACHE NOCYCLE;
CREATE SEQUENCE genre_name_seq START WITH 100 INCREMENT BY 1 NOCACHE NOCYCLE;


CREATE TABLE Genre (
    GenreID INT NOT NULL,
    Description VARCHAR(255),
	DELETED_MARK varchar(1) DEFAULT 'N', 
    CONSTRAINT PK_Genre PRIMARY KEY (GenreID)
);

CREATE TABLE GName (
	GNameID INT NOT NULL,
	GenreName VARCHAR(50) NOT NULL,
	CONSTRAINT gname_pk PRIMARY KEY (GnameID)
);

CREATE TABLE Genre_Name (
	Genre_NameID INT NOT NULL,
	GNameID INT NOT NULL,
	GenreID INT NOT NULL,
	STARTDATE TIMESTAMP NOT NULL,
	ENDDATE TIMESTAMP DEFAULT NULL,
	CONSTRAINT genre_name_pk PRIMARY KEY (Genre_NameID),
	CONSTRAINT gname_fk FOREIGN KEY (GNameID) REFERENCES GName (GNameID),
	CONSTRAINT genre_fk FOREIGN KEY (GenreID) REFERENCES Genre (GenreID)
);


CREATE TABLE Artist (
    ArtistID INT DEFAULT artist_seq.NEXTVAL,
    Country VARCHAR(50),
    FirstName VARCHAR(50),
    LastName VARCHAR(50),
    BandName VARCHAR(75),
    GrammyWins INT NOT NULL,
    CONSTRAINT PK_Artist PRIMARY KEY (ArtistID)
);

CREATE TABLE Band (
    ArtistID INT NOT NULL,
    FormationYear INT,
    DELETED_MARK VARCHAR(1) DEFAULT 'N',
    CONSTRAINT FK_Band_ArtistID FOREIGN KEY (ArtistID) REFERENCES Artist(ArtistID) ON DELETE CASCADE,
    CONSTRAINT PK_Band PRIMARY KEY (ArtistID)
);

CREATE TABLE BMEMBER(
	BMemberID INT NOT NULL,
	MemberCount INT NOT NULL,
	CONSTRAINT bmember_pk PRIMARY KEY (BMemberID)
);

CREATE TABLE Band_Member(
	band_memberID INT NOT NULL,
	startdate TIMESTAMP NOT NULL,
	enddate TIMESTAMP DEFAULT NULL,
	bmemberid INT NOT NULL,
	bandid INT NOT NULL,
	CONSTRAINT band_member_pk PRIMARY KEY (Band_MemberID),
	CONSTRAINT  bmember_fk FOREIGN KEY (BMemberID) REFERENCES BMEMBER (BMemberID),
	CONSTRAINT  band_fk FOREIGN KEY (bandID) REFERENCES Band (ArtistID)
);

CREATE TABLE IndividualArtist (
    ArtistID INT NOT NULL,
    StageName VARCHAR(75) NOT NULL,
    BirthYear INT NOT NULL,
    DebutYear INT NOT NULL,
    CONSTRAINT FK_IndividualArtist_ArtistID FOREIGN KEY (ArtistID) REFERENCES Artist(ArtistID) ON DELETE CASCADE,
    CONSTRAINT PK_IndividualArtist PRIMARY KEY (ArtistID)
);


CREATE TABLE Producer (
    ArtistID INT NOT NULL,
    Specialization VARCHAR(50) NOT NULL,
    Studio VARCHAR(65),
    CONSTRAINT FK_Producer_ArtistID FOREIGN KEY (ArtistID) REFERENCES Artist(ArtistID) ON DELETE CASCADE,
    CONSTRAINT PK_Producer PRIMARY KEY (ArtistID)
);

CREATE TABLE Writer (
    ArtistID INT NOT NULL,
    WriterType VARCHAR(50) NOT NULL,
    PublishingCompany VARCHAR(75),
    LyricLanguage VARCHAR(50),
    CONSTRAINT FK_Writer_ArtistID FOREIGN KEY (ArtistID) REFERENCES Artist(ArtistID) ON DELETE CASCADE,
    CONSTRAINT PK_Writer PRIMARY KEY (ArtistID)
);

CREATE TABLE Album (
    AlbumID INT DEFAULT album_seq.NEXTVAL,
    ReleaseYear INT NOT NULL,
    SongCount INT NOT NULL,
	Deleted_Mark VARCHAR(1) DEFAULT 'N',
    Duration INT NOT NULL,
    CONSTRAINT PK_Album PRIMARY KEY (AlbumID)
);

CREATE TABLE ATITLE (
	ATitleID INT NOT NULL,
	Title VARCHAR(100) NOT NULL,
	CONSTRAINT atitle_pk PRIMARY KEY (ATitleID)
);

CREATE TABLE Album_Title(
	Album_TitleID INT NOT NULL,
	ATitleID INT NOT NULL,
	AlbumID INT NOT NULL,
	STARTDATE TIMESTAMP NOT NULL,
	ENDDATE TIMESTAMP DEFAULT NULL,
	CONSTRAINT album_title_pk PRIMARY KEY (Album_TitleID),
	CONSTRAINT atitle_fk FOREIGN KEY (ATitleID) REFERENCES ATITLE (ATitleID),
	CONSTRAINT album_fk FOREIGN KEY (AlbumID) REFERENCES Album (AlbumID)
);


CREATE TABLE AlbumArtist (
    AlbumID INT NOT NULL,
    ArtistID INT NOT NULL,
    ArtistRole VARCHAR(50) NOT NULL,
    CONSTRAINT FK_AlbumArtist_AlbumID FOREIGN KEY (AlbumID) REFERENCES Album(AlbumID) ON DELETE CASCADE,
    CONSTRAINT FK_AlbumArtist_ArtistID FOREIGN KEY (ArtistID) REFERENCES Artist(ArtistID),
    CONSTRAINT PK_AlbumArtist PRIMARY KEY (AlbumID, ArtistID)
);


CREATE TABLE AlbumGenre (
    AlbumID INT NOT NULL,
    GenreID INT NOT NULL,
    CONSTRAINT FK_AlbumGenre_AlbumID FOREIGN KEY (AlbumID) REFERENCES Album(AlbumID) ON DELETE CASCADE,
    CONSTRAINT FK_AlbumGenre_GenreID FOREIGN KEY (GenreID) REFERENCES Genre(GenreID) ON DELETE CASCADE,
    CONSTRAINT PK_AlbumGenre PRIMARY KEY (AlbumID, GenreID)
);


------------------------------------------------------------------------------------------------------------
-- Views and triggers
------------------------------------------------------------------------------------------------------------

-- Genre name view
CREATE OR REPLACE VIEW Genre_View 
AS
SELECT g.GenreID,
	gn.genrename,
	g.Description,
	g_n.STARTDATE,
	g_n.ENDDATE
FROM Genre_Name g_n
LEFT JOIN Genre g ON g.GenreID = g_n.GenreID
LEFT JOIN GName gn ON gn.GNameID = g_n.GNameID
WHERE g_n.ENDDATE IS NULL;


CREATE OR REPLACE TRIGGER GENRENAME_REDIRECT
INSTEAD OF INSERT OR UPDATE OR DELETE ON Genre_View
FOR EACH ROW
DECLARE
v_GNameID NUMBER;
v_Genre_NameID NUMBER;
v_GenreID NUMBER;
BEGIN

IF INSERTING THEN
	SELECT gname_seq.NEXTVAL INTO v_GNameID FROM dual;
	
	INSERT INTO GName (GNameID, GenreName)
	VALUES (v_GNameID, :NEW.GenreName);
	
	SELECT genre_seq.NEXTVAL INTO v_GenreID FROM dual;
	INSERT INTO Genre (GenreID, Description, Deleted_Mark)
	VALUES (v_GenreID, :NEW.Description, 'N');
    
	SELECT genre_name_seq.NEXTVAL INTO v_Genre_NameID FROM dual;
	
	INSERT INTO Genre_Name (
		Genre_NameID,
		GNameID,
		GenreID,
		STARTDATE,
		ENDDATE)
		VALUES (v_Genre_NameID, v_GNameID, v_GenreID, SYSDATE, NULL);
    
ELSIF UPDATING THEN

	UPDATE Genre_Name
	SET ENDDATE = SYSDATE
	WHERE GenreID = :NEW.GenreID 
	AND ENDDATE IS NULL;

	SELECT gname_seq.NEXTVAL INTO v_GNameID FROM dual;

	INSERT INTO GName (GNameID, GenreName)
		VALUES (v_GNameID, :NEW.GenreName);

	SELECT genre_name_seq.NEXTVAL INTO v_Genre_NameID FROM dual;

	INSERT INTO Genre_Name (
		Genre_NameID,
		GNameID,
		GenreID,
		STARTDATE,
		ENDDATE)
		VALUES (v_Genre_NameID, v_GNameID, :NEW.GenreID, SYSDATE, NULL);
	
ELSIF DELETING THEN
	UPDATE Genre_Name
	SET ENDDATE = SYSDATE
	WHERE GenreID = :OLD.GenreID
	AND ENDDATE IS NULL;
	
	UPDATE Genre
	SET DELETED_MARK = 'Y'
	WHERE GenreID = :OLD.GenreID;
END IF;
END;
/


-- Band member count view

CREATE OR REPLACE VIEW BAND_MEMBERS_VIEW AS
SELECT B.ARTISTID, BMEM.MEMBERCOUNT, B.FORMATIONYEAR
FROM BAND_MEMBER BM
JOIN BAND B ON B.ARTISTID = BM.BANDID
JOIN BMEMBER BMEM ON BMEM.BMEMBERID=BM.BMEMBERID
WHERE BM.ENDDATE IS NULL;

CREATE OR REPLACE TRIGGER instead_of_band_members_view
INSTEAD OF INSERT OR UPDATE OR DELETE ON BAND_MEMBERS_VIEW
FOR EACH ROW
DECLARE
    new_bmemberid NUMBER;
    new_band_memberid NUMBER;
BEGIN
    IF INSERTING THEN
        select BMEMBER_SEQ.NEXTVAL INTO new_bmemberid FROM dual;
        INSERT INTO BMEMBER (BMEMBERID, MEMBERCOUNT)
        VALUES (new_bmemberid, :NEW.MEMBERCOUNT);
        
        INSERT INTO Band (ArtistID, FormationYear, Deleted_Mark)
        VALUES (:NEW.ArtistID, :NEW.FormationYear, 'N');
        
        SELECT ARTIST_SEQ.NEXTVAL INTO new_band_memberid FROM dual;
        INSERT INTO BAND_MEMBER (BAND_MEMBERID, STARTDATE, ENDDATE, BMEMBERID, BANDID)
        VALUES (new_band_memberid, SYSDATE, NULL, new_bmemberid, :NEW.ARTISTID);

    ELSIF UPDATING THEN
        UPDATE BAND_MEMBER
        SET ENDDATE = SYSDATE
        WHERE BANDID = :OLD.ARTISTID AND ENDDATE IS NULL;
        
        
        SELECT BMEMBER_SEQ.NEXTVAL INTO new_bmemberid FROM dual;
        INSERT INTO BMEMBER(BMEMBERID, MEMBERCOUNT)
        VALUES (new_bmemberid, :NEW.MEMBERCOUNT);
        
        SELECT ARTIST_SEQ.NEXTVAL INTO new_band_memberid FROM dual;
        INSERT INTO BAND_MEMBER(BAND_MEMBERID, STARTDATE, ENDDATE, BMEMBERID, BANDID)
        VALUES (new_band_memberid, SYSDATE, NULL, new_bmemberid, :NEW.ARTISTID);
    
    ELSIF DELETING THEN
        UPDATE BAND_MEMBER
        SET ENDDATE = SYSDATE
        WHERE BANDID= :OLD.ARTISTID AND ENDDATE IS NULL;
        
        UPDATE BAND
        SET DELETED_MARK = 'Y'
        WHERE ARTISTID = :OLD.ARTISTID;
    END IF;
END;
/

UPDATE Band_Members_View SET MemberCount = 44 WHERE ArtistID = 105;
SELECT * FROM Band;
SELECT * FROM BMember;

-- Album title view
CREATE OR REPLACE VIEW Album_View 
AS
SELECT a.AlbumID,
	at.Title,
	a.SongCount,
    a.ReleaseYear,
	a.Duration,
	a_t.STARTDATE,
	a_t.ENDDATE
FROM Album_title a_t
LEFT JOIN Album a ON a.AlbumID = a_t.AlbumID
LEFT JOIN ATitle at ON at.ATitleID = a_t.ATitleID
WHERE a_t.ENDDATE IS NULL;


CREATE OR REPLACE TRIGGER ALBUMTITLE_REDIRECT
INSTEAD OF INSERT OR UPDATE OR DELETE ON Album_View
FOR EACH ROW
DECLARE
v_ATitleID NUMBER;
v_Album_TitleID NUMBER;
v_AlbumID NUMBER;
BEGIN

IF INSERTING THEN
	SELECT atitle_seq.NEXTVAL INTO v_ATitleID FROM dual;
	
	INSERT INTO ATitle (ATitleID, Title)
	VALUES (v_ATitleID, :NEW.Title);
	
    SELECT album_seq.NEXTVAL INTO v_AlbumID FROM dual;
	INSERT INTO Album (AlbumID, ReleaseYear, SongCount, Duration, Deleted_Mark)
	VALUES (v_AlbumID, :NEW.ReleaseYear, :NEW.SongCount, :NEW.Duration, 'N');

	SELECT album_title_seq.NEXTVAL INTO v_Album_TitleID FROM dual;

	INSERT INTO Album_Title (
		Album_TitleID,
		ATitleID,
		AlbumID,
		STARTDATE,
		ENDDATE)
		VALUES (v_Album_TitleID, v_ATitleID, v_AlbumID, SYSDATE, NULL);
	
ELSIF UPDATING THEN

	UPDATE Album_Title
	SET ENDDATE = SYSDATE
	WHERE AlbumID = :NEW.AlbumID 
	AND ENDDATE IS NULL;

	SELECT atitle_seq.NEXTVAL INTO v_ATitleID FROM dual;

	INSERT INTO ATitle (ATitleID, Title)
		VALUES (v_ATitleID, :NEW.Title);

	SELECT album_title_seq.NEXTVAL INTO v_Album_TitleID FROM dual;

	INSERT INTO Album_Title (
		Album_TitleID,
		AtitleID,
		AlbumID,
		STARTDATE,
		ENDDATE)
		VALUES (v_Album_TitleID, v_ATitleID, :NEW.AlbumID, SYSDATE, NULL);
	
ELSIF DELETING THEN
	UPDATE Album_Title
	SET ENDDATE = SYSDATE
	WHERE AlbumID = :OLD.AlbumID
	AND ENDDATE IS NULL;
	
	UPDATE Album
	SET DELETED_MARK = 'Y'
	WHERE AlbumID = :OLD.AlbumID;
END IF;
END;
/

---- First, insert into Genre directly to establish the parent records
--INSERT INTO Genre (GenreID, Description) VALUES (100, 'Electronic dance music with heavy bass and synthesizers');
--INSERT INTO Genre (GenreID, Description) VALUES (101, 'Traditional rock music with guitar-driven sound');
--INSERT INTO Genre (GenreID, Description) VALUES (102, 'Contemporary pop music with catchy melodies');
--
---- Now use Genre_View to add the names
--INSERT INTO Genre_View (GenreID, GenreName, Description) 
--SELECT 100, 'EDM', Description FROM Genre WHERE GenreID = 100;
--INSERT INTO Genre_View (GenreID, GenreName, Description) 
--SELECT 101, 'Rock', Description FROM Genre WHERE GenreID = 101;
--INSERT INTO Genre_View (GenreID, GenreName, Description) 
--SELECT 102, 'Pop', Description FROM Genre WHERE GenreID = 102;
--
---- Insert Artists first (parent records)
--INSERT INTO Artist (ArtistID, Country, FirstName, LastName, BandName, GrammyWins)
--VALUES (100, 'USA', NULL, NULL, 'Electric Dreams', 2);
--INSERT INTO Artist (ArtistID, Country, FirstName, LastName, BandName, GrammyWins)
--VALUES (101, 'UK', 'John', 'Smith', NULL, 1);
--INSERT INTO Artist (ArtistID, Country, FirstName, LastName, BandName, GrammyWins)
--VALUES (102, 'Canada', NULL, NULL, 'The Rockstars', 3);
--
---- Now we can insert Bands since Artist records exist
--INSERT INTO Band (ArtistID, FormationYear)
--VALUES (100, 2015);
--INSERT INTO Band (ArtistID, FormationYear)
--VALUES (102, 2010);
--
---- Insert Band Members for existing bands
--INSERT INTO BAND_MEMBERS_VIEW (ARTISTID, MEMBERCOUNT, FORMATIONYEAR)
--SELECT 100, 4, FormationYear FROM Band WHERE ArtistID = 100;
--INSERT INTO BAND_MEMBERS_VIEW (ARTISTID, MEMBERCOUNT, FORMATIONYEAR)
--SELECT 102, 5, FormationYear FROM Band WHERE ArtistID = 102;
--
---- Insert Individual Artist for existing artist
--INSERT INTO IndividualArtist (ArtistID, StageName, BirthYear, DebutYear)
--VALUES (101, 'J.Smith', 1985, 2005);
--
---- Insert Albums
--INSERT INTO Album (AlbumID, ReleaseYear, SongCount, Duration)
--VALUES (100, 2020, 12, 2880);
--INSERT INTO Album (AlbumID, ReleaseYear, SongCount, Duration)
--VALUES (101, 2021, 10, 2400);
--INSERT INTO Album (AlbumID, ReleaseYear, SongCount, Duration)
--VALUES (102, 2022, 8, 1920);
--
---- Add Album titles via the view for existing albums
--INSERT INTO Album_View (AlbumID, Title, SongCount, Duration)
--SELECT 100, 'Electric Dreams Vol.1', SongCount, Duration FROM Album WHERE AlbumID = 100;
--INSERT INTO Album_View (AlbumID, Title, SongCount, Duration)
--SELECT 101, 'Rock Revolution', SongCount, Duration FROM Album WHERE AlbumID = 101;
--INSERT INTO Album_View (AlbumID, Title, SongCount, Duration)
--SELECT 102, 'Pop Sensation', SongCount, Duration FROM Album WHERE AlbumID = 102;
--
--
---- Now we can create Album-Artist relationships since both exist
--INSERT INTO AlbumArtist (AlbumID, ArtistID, ArtistRole)
--VALUES (100, 100, 'Primary Artist');
--INSERT INTO AlbumArtist (AlbumID, ArtistID, ArtistRole)
--VALUES (101, 101, 'Primary Artist');
--INSERT INTO AlbumArtist (AlbumID, ArtistID, ArtistRole)
--VALUES (102, 102, 'Primary Artist');
--
---- Finally, create Album-Genre relationships
--INSERT INTO AlbumGenre (AlbumID, GenreID)
--VALUES (100, 100);
--INSERT INTO AlbumGenre (AlbumID, GenreID)
--VALUES (101, 101);
--INSERT INTO AlbumGenre (AlbumID, GenreID)
--VALUES (102, 102);


