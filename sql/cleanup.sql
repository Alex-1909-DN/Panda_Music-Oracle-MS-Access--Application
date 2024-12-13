-- Cleanup cst2355_assignment2

DROP SEQUENCE genre_seq;
DROP SEQUENCE artist_seq;
DROP SEQUENCE album_seq;

DROP SEQUENCE bmember_seq;
DROP SEQUENCE band_member_seq;
DROP SEQUENCE atitle_seq;
DROP SEQUENCE album_title_seq;
DROP SEQUENCE gname_seq;
DROP SEQUENCE genre_name_seq;

DROP USER musicalAdmin CASCADE;
DROP USER DBuser;
DROP ROLE applicationAdmin;
DROP ROLE applicationUser;
DROP TABLESPACE cst2355_assignment2 INCLUDING CONTENTS AND DATAFILES;


