-- Insert Genres
INSERT INTO Genre_View (GenreName, Description) VALUES ('Rock', 'Guitar-driven popular music characterized by strong rhythms');
INSERT INTO Genre_View (GenreName, Description) VALUES ('Pop', 'Contemporary popular music with catchy melodies');
INSERT INTO Genre_View (GenreName, Description) VALUES ('Hip Hop', 'Urban music featuring rhythmic vocals and beats');
INSERT INTO Genre_View (GenreName, Description) VALUES ('Jazz', 'Complex harmony and improvisation-based music');
INSERT INTO Genre_View (GenreName, Description) VALUES ('Classical', 'Traditional Western orchestral and chamber music');

-- Insert Artists
INSERT INTO Artist (ArtistID, Country, FirstName, LastName, BandName, GrammyWins)
VALUES (artist_seq.NEXTVAL, 'USA', 'John', 'Smith', NULL, 2);

INSERT INTO Artist (ArtistID, Country, FirstName, LastName, BandName, GrammyWins)
VALUES (artist_seq.NEXTVAL, 'UK', NULL, NULL, 'The Soundwaves', 3);

INSERT INTO Artist (ArtistID, Country, FirstName, LastName, BandName, GrammyWins)
VALUES (artist_seq.NEXTVAL, 'Canada', 'Sarah', 'Johnson', NULL, 1);

INSERT INTO Artist (ArtistID, Country, FirstName, LastName, BandName, GrammyWins)
VALUES (artist_seq.NEXTVAL, 'USA', 'Michael', 'Davis', NULL, 4);

INSERT INTO Artist (ArtistID, Country, FirstName, LastName, BandName, GrammyWins)
VALUES (artist_seq.NEXTVAL, 'UK', NULL, NULL, 'Electric Dreams', 2);

-- Insert Individual Artists
INSERT INTO IndividualArtist (ArtistID, StageName, BirthYear, DebutYear)
SELECT ArtistID, 'Johnny Thunder', 1985, 2005
FROM Artist WHERE FirstName = 'John' AND LastName = 'Smith';

INSERT INTO IndividualArtist (ArtistID, StageName, BirthYear, DebutYear)
SELECT ArtistID, 'Starlight Sarah', 1990, 2010
FROM Artist WHERE FirstName = 'Sarah' AND LastName = 'Johnson';

-- Insert Bands
INSERT INTO Band_Members_View (ArtistID, MemberCount, FormationYear)
SELECT ArtistID, 4, 2000
FROM Artist WHERE BandName = 'The Soundwaves';

INSERT INTO Band_Members_View (ArtistID, MemberCount, FormationYear)
SELECT ArtistID, 3, 2015
FROM Artist WHERE BandName = 'Electric Dreams';

-- Insert Producers
INSERT INTO Producer (ArtistID, Specialization, Studio)
SELECT ArtistID, 'Rock Production', 'Sunset Studios'
FROM Artist WHERE FirstName = 'Michael' AND LastName = 'Davis';

-- Insert Writers
INSERT INTO Writer (ArtistID, WriterType, PublishingCompany, LyricLanguage)
SELECT ArtistID, 'Songwriter', 'Universal Music', 'English'
FROM Artist WHERE FirstName = 'Sarah' AND LastName = 'Johnson';

-- Insert Albums
INSERT INTO Album_View (Title, ReleaseYear, SongCount, Duration)
VALUES ('Thunder Road', 2020, 12, 2880);  -- Duration in seconds (48 minutes)

INSERT INTO Album_View (Title, ReleaseYear, SongCount, Duration)
VALUES ('Electric Night', 2021, 10, 2400);  -- 40 minutes

INSERT INTO Album_View (Title, ReleaseYear, SongCount, Duration)
VALUES ('Starlight Dreams', 2022, 8, 1920);  -- 32 minutes

-- Link Albums to Artists (assuming the sequence values - adjust based on actual IDs)
INSERT INTO AlbumArtist (AlbumID, ArtistID, ArtistRole)
SELECT a.AlbumID, art.ArtistID, 'Lead Artist'
FROM Album a
JOIN Album_Title at ON a.AlbumID = at.AlbumID
JOIN ATitle t ON at.ATitleID = t.ATitleID
CROSS JOIN Artist art
WHERE t.Title = 'Thunder Road'
AND art.FirstName = 'John' AND art.LastName = 'Smith';

INSERT INTO AlbumArtist (AlbumID, ArtistID, ArtistRole)
SELECT a.AlbumID, art.ArtistID, 'Band'
FROM Album a
JOIN Album_Title at ON a.AlbumID = at.AlbumID
JOIN ATitle t ON at.ATitleID = t.ATitleID
CROSS JOIN Artist art
WHERE t.Title = 'Electric Night'
AND art.BandName = 'Electric Dreams';

-- Link Albums to Genres
INSERT INTO AlbumGenre (AlbumID, GenreID)
SELECT a.AlbumID, g.GenreID
FROM Album a
JOIN Album_Title at ON a.AlbumID = at.AlbumID
JOIN ATitle t ON at.ATitleID = t.ATitleID
CROSS JOIN Genre_Name gn
JOIN Genre g ON gn.GenreID = g.GenreID
JOIN GName gname ON gn.GNameID = gname.GNameID
WHERE t.Title = 'Thunder Road'
AND gname.GenreName = 'Rock';

INSERT INTO AlbumGenre (AlbumID, GenreID)
SELECT a.AlbumID, g.GenreID
FROM Album a
JOIN Album_Title at ON a.AlbumID = at.AlbumID
JOIN ATitle t ON at.ATitleID = t.ATitleID
CROSS JOIN Genre_Name gn
JOIN Genre g ON gn.GenreID = g.GenreID
JOIN GName gname ON gn.GNameID = gname.GNameID
WHERE t.Title = 'Electric Night'
AND gname.GenreName = 'Pop';