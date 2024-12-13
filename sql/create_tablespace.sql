
-- Create STORAGE
CREATE TABLESPACE cst2355_assignment2
DATAFILE 'cst2355_assignment2.dat' SIZE 40M 
ONLINE; 

-- Create Users
CREATE USER musicalAdmin IDENTIFIED BY musicalAdminPassword ACCOUNT UNLOCK
	DEFAULT TABLESPACE cst2355_assignment2
	QUOTA 20M ON cst2355_assignment2;
	
CREATE USER DBuser IDENTIFIED BY DBuserPassword ACCOUNT UNLOCK
	DEFAULT TABLESPACE cst2355_assignment2
	QUOTA 5M ON cst2355_assignment2;
	
-- Create for user
CREATE ROLE applicationUser;

-- Grant PRIVILEGES
GRANT CONNECT, RESOURCE TO applicationUser;

GRANT DBA TO musicalAdmin;
GRANT applicationUser TO DBuser;


-- Connect as musicalAdmin user
CONNECT musicalAdmin/musicalAdminPassword;