-- =============================================
-- MLB Baseball Database - CREATE TABLES
-- Corrected schema with:
--   1) lgID char(3) to support Negro League codes (NNL, ECL, NAL, etc.)
--   2) allstarfull.gameNum allows NULL for pre-1959 single-game years
-- =============================================

CREATE DATABASE  IF NOT EXISTS mlb_baseball;
USE mlb_baseball;
SET NAMES utf8 ;
SET character_set_client = utf8mb4;
/* DROP TABLES */
DROP TABLE IF EXISTS seriespost;
DROP TABLE IF EXISTS salaries;
DROP TABLE IF EXISTS pitchingpost;
DROP TABLE IF EXISTS pitching;
DROP TABLE IF EXISTS managershalf;
DROP TABLE IF EXISTS managers;
DROP TABLE IF EXISTS homegames;
DROP TABLE IF EXISTS parks;
DROP TABLE IF EXISTS halloffame;
DROP TABLE IF EXISTS fieldingpost;
DROP TABLE IF EXISTS fieldingofsplit;
DROP TABLE IF EXISTS fieldingof;
DROP TABLE IF EXISTS fielding;
DROP TABLE IF EXISTS collegeplaying;
DROP TABLE IF EXISTS schools;
DROP TABLE IF EXISTS battingpost;
DROP TABLE IF EXISTS batting;
DROP TABLE IF EXISTS awardsshareplayers;
DROP TABLE IF EXISTS awardssharemanagers;
DROP TABLE IF EXISTS awardsplayers;
DROP TABLE IF EXISTS awardsmanagers;
DROP TABLE IF EXISTS appearances;
DROP TABLE IF EXISTS allstarfull;
DROP TABLE IF EXISTS people;
DROP TABLE IF EXISTS teamshalf;
DROP TABLE IF EXISTS teams;
DROP TABLE IF EXISTS teamsfranchises;
DROP TABLE IF EXISTS divisions;
DROP TABLE IF EXISTS leagues;
CREATE TABLE leagues (
  lgID char(3) NOT NULL,
  league varchar(50) NOT NULL,
  active char NOT NULL,
  PRIMARY KEY (lgID)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;
CREATE TABLE divisions (
  ID INT NOT NULL AUTO_INCREMENT,
  divID char(2) NOT NULL,
  lgID char(3) NOT NULL,
  division varchar(50) NOT NULL,
  active char NOT NULL,
  PRIMARY KEY (ID),
  UNIQUE KEY (divID,lgID),
  FOREIGN KEY (lgID) REFERENCES leagues(lgID)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;
CREATE TABLE teamsfranchises (
  franchID varchar(3) NOT NULL,
  franchName varchar(50) DEFAULT NULL,
  active varchar(2) DEFAULT NULL,
  NAassoc varchar(3) DEFAULT NULL,
  PRIMARY KEY (franchID)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;
CREATE TABLE teams (
  ID INT NOT NULL AUTO_INCREMENT,
  yearID smallint(6) NOT NULL,
  lgID char(3) DEFAULT NULL,
  teamID char(3) NOT NULL,
  franchID varchar(3) DEFAULT NULL,
  divID char(1) DEFAULT NULL,
  div_ID INT DEFAULT NULL,
  teamRank smallint(6) DEFAULT NULL,
  G smallint(6) DEFAULT NULL,
  Ghome smallint(6) DEFAULT NULL,
  W smallint(6) DEFAULT NULL,
  L smallint(6) DEFAULT NULL,
  DivWin varchar(1) DEFAULT NULL,
  WCWin varchar(1) DEFAULT NULL,
  LgWin varchar(1) DEFAULT NULL,
  WSWin varchar(1) DEFAULT NULL,
  R smallint(6) DEFAULT NULL,
  AB smallint(6) DEFAULT NULL,
  H smallint(6) DEFAULT NULL,
  2B smallint(6) DEFAULT NULL,
  3B smallint(6) DEFAULT NULL,
  HR smallint(6) DEFAULT NULL,
  BB smallint(6) DEFAULT NULL,
  SO smallint(6) DEFAULT NULL,
  SB smallint(6) DEFAULT NULL,
  CS smallint(6) DEFAULT NULL,
  HBP smallint(6) DEFAULT NULL,
  SF smallint(6) DEFAULT NULL,
  RA smallint(6) DEFAULT NULL,
  ER smallint(6) DEFAULT NULL,
  ERA double DEFAULT NULL,
  CG smallint(6) DEFAULT NULL,
  SHO smallint(6) DEFAULT NULL,
  SV smallint(6) DEFAULT NULL,
  IPouts int(11) DEFAULT NULL,
  HA smallint(6) DEFAULT NULL,
  HRA smallint(6) DEFAULT NULL,
  BBA smallint(6) DEFAULT NULL,
  SOA smallint(6) DEFAULT NULL,
  E int(11) DEFAULT NULL,
  DP int(11) DEFAULT NULL,
  FP double DEFAULT NULL,
  name varchar(50) DEFAULT NULL,
  park varchar(255) DEFAULT NULL,
  attendance int(11) DEFAULT NULL,
  BPF int(11) DEFAULT NULL,
  PPF int(11) DEFAULT NULL,
  teamIDBR varchar(3) DEFAULT NULL,
  teamIDlahman45 varchar(3) DEFAULT NULL,
  teamIDretro varchar(3) DEFAULT NULL,
  PRIMARY KEY (ID),
  UNIQUE KEY (yearID,lgID,teamID),
  FOREIGN KEY (lgID) REFERENCES leagues(lgID),
  FOREIGN KEY (div_ID) REFERENCES divisions(ID),
  FOREIGN KEY (franchID) REFERENCES teamsfranchises(franchID)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;
CREATE TABLE teamshalf (
  ID INT NOT NULL AUTO_INCREMENT,
  yearID smallint(6) NOT NULL,
  lgID char(3) NOT NULL,
  teamID char(3) NOT NULL,
  team_ID INT DEFAULT NULL,
  Half varchar(1) NOT NULL,
  divID char(1) DEFAULT NULL,
  div_ID INT DEFAULT NULL,
  DivWin varchar(1) DEFAULT NULL,
  teamRank smallint(6) DEFAULT NULL,
  G smallint(6) DEFAULT NULL,
  W smallint(6) DEFAULT NULL,
  L smallint(6) DEFAULT NULL,
  PRIMARY KEY (ID),
  UNIQUE KEY (yearID,lgID,teamID,Half),
  FOREIGN KEY (lgID) REFERENCES leagues(lgID),
  FOREIGN KEY (div_ID) REFERENCES divisions(ID),
  FOREIGN KEY (team_ID) REFERENCES teams(ID)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;
CREATE TABLE people (
  playerID varchar(9) NOT NULL,
  birthYear int(11) DEFAULT NULL,
  birthMonth int(11) DEFAULT NULL,
  birthDay int(11) DEFAULT NULL,
  birthCountry varchar(255) DEFAULT NULL,
  birthState varchar(255) DEFAULT NULL,
  birthCity varchar(255) DEFAULT NULL,
  deathYear int(11) DEFAULT NULL,
  deathMonth int(11) DEFAULT NULL,
  deathDay int(11) DEFAULT NULL,
  deathCountry varchar(255) DEFAULT NULL,
  deathState varchar(255) DEFAULT NULL,
  deathCity varchar(255) DEFAULT NULL,
  nameFirst varchar(255) DEFAULT NULL,
  nameLast varchar(255) DEFAULT NULL,
  nameGiven varchar(255) DEFAULT NULL,
  weight int(11) DEFAULT NULL,
  height int(11) DEFAULT NULL,
  bats varchar(255) DEFAULT NULL,
  throws varchar(255) DEFAULT NULL,
  debut varchar(255) DEFAULT NULL,
  finalGame varchar(255) DEFAULT NULL,
  retroID varchar(255) DEFAULT NULL,
  bbrefID varchar(255) DEFAULT NULL,
  birth_date date DEFAULT NULL,
  debut_date date DEFAULT NULL,
  finalgame_date date DEFAULT NULL,
  death_date date DEFAULT NULL,
  PRIMARY KEY (playerID)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;
CREATE TABLE allstarfull (
  ID INT NOT NULL AUTO_INCREMENT,
  playerID varchar(9) NOT NULL,
  yearID smallint(6),
  gameNum smallint(6) DEFAULT NULL,
  gameID varchar(12) DEFAULT NULL,
  teamID char(3) DEFAULT NULL,
  team_ID INT DEFAULT NULL,
  lgID char(3) DEFAULT NULL,
  GP smallint(6) DEFAULT NULL,
  startingPos smallint(6) DEFAULT NULL,
  PRIMARY KEY (ID),
  UNIQUE KEY (playerID,yearID,gameNum,gameID,lgID),
  FOREIGN KEY (lgID) REFERENCES leagues(lgID),
  FOREIGN KEY (team_ID) REFERENCES teams(ID)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;
CREATE TABLE appearances (
  ID INT NOT NULL AUTO_INCREMENT,
  yearID smallint(6) NOT NULL,
  teamID char(3) NOT NULL,
  team_ID INT DEFAULT NULL,
  lgID char(3) DEFAULT NULL,
  playerID varchar(9) NOT NULL,
  G_all smallint(6) DEFAULT NULL,
  GS smallint(6) DEFAULT NULL,
  G_batting smallint(6) DEFAULT NULL,
  G_defense smallint(6) DEFAULT NULL,
  G_p smallint(6) DEFAULT NULL,
  G_c smallint(6) DEFAULT NULL,
  G_1b smallint(6) DEFAULT NULL,
  G_2b smallint(6) DEFAULT NULL,
  G_3b smallint(6) DEFAULT NULL,
  G_ss smallint(6) DEFAULT NULL,
  G_lf smallint(6) DEFAULT NULL,
  G_cf smallint(6) DEFAULT NULL,
  G_rf smallint(6) DEFAULT NULL,
  G_of smallint(6) DEFAULT NULL,
  G_dh smallint(6) DEFAULT NULL,
  G_ph smallint(6) DEFAULT NULL,
  G_pr smallint(6) DEFAULT NULL,
  PRIMARY KEY (ID),
  UNIQUE KEY (yearID,teamID,playerID),
  FOREIGN KEY (lgID) REFERENCES leagues(lgID),
  FOREIGN KEY (team_ID) REFERENCES teams(ID),
  FOREIGN KEY (playerID) REFERENCES people(playerID)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;
CREATE TABLE awardsmanagers (
  ID INT NOT NULL AUTO_INCREMENT,
  playerID varchar(10) NOT NULL,
  awardID varchar(75) NOT NULL,
  yearID smallint(6) NOT NULL,
  lgID char(3) NOT NULL,
  tie varchar(1) DEFAULT NULL,
  notes varchar(100) DEFAULT NULL,
  PRIMARY KEY (ID),
  UNIQUE KEY (playerID,awardID,yearID,lgID),
  FOREIGN KEY (lgID) REFERENCES leagues(lgID),
  FOREIGN KEY (playerID) REFERENCES people(playerID)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;
CREATE TABLE awardsplayers (
  ID INT NOT NULL AUTO_INCREMENT,
  playerID varchar(9) NOT NULL,
  awardID varchar(255) NOT NULL,
  yearID smallint(6) NOT NULL,
  lgID char(3),
  tie varchar(1) DEFAULT NULL,
  notes varchar(100) DEFAULT NULL,
  PRIMARY KEY (ID),
  UNIQUE KEY (playerID,awardID,yearID,lgID,notes),
  FOREIGN KEY (lgID) REFERENCES leagues(lgID),
  FOREIGN KEY (playerID) REFERENCES people(playerID)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;
CREATE TABLE awardssharemanagers (
  ID INT NOT NULL AUTO_INCREMENT,
  awardID varchar(25) NOT NULL,
  yearID smallint(6) NOT NULL,
  lgID char(3) NOT NULL,
  playerID varchar(10) NOT NULL,
  pointsWon smallint(6) DEFAULT NULL,
  pointsMax smallint(6) DEFAULT NULL,
  votesFirst smallint(6) DEFAULT NULL,
  PRIMARY KEY (ID),
  UNIQUE KEY (playerID,awardID,yearID,lgID),
  FOREIGN KEY (lgID) REFERENCES leagues(lgID),
  FOREIGN KEY (playerID) REFERENCES people(playerID)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;
CREATE TABLE awardsshareplayers (
  ID INT NOT NULL AUTO_INCREMENT,
  awardID varchar(25) NOT NULL,
  yearID smallint(6) NOT NULL,
  lgID char(3) NOT NULL,
  playerID varchar(9) NOT NULL,
  pointsWon double DEFAULT NULL,
  pointsMax smallint(6) DEFAULT NULL,
  votesFirst double DEFAULT NULL,
  PRIMARY KEY (ID),
  UNIQUE KEY (playerID,awardID,yearID,lgID),
  FOREIGN KEY (lgID) REFERENCES leagues(lgID),
  FOREIGN KEY (playerID) REFERENCES people(playerID)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;
CREATE TABLE batting (
  ID INT NOT NULL AUTO_INCREMENT,
  playerID varchar(9) NOT NULL,
  yearID smallint(6) NOT NULL,
  stint smallint(6) NOT NULL,
  teamID char(3) DEFAULT NULL,
  team_ID INT DEFAULT NULL,
  lgID char(3) DEFAULT NULL,
  G smallint(6) DEFAULT NULL,
  G_batting smallint(6) DEFAULT NULL,
  AB smallint(6) DEFAULT NULL,
  R smallint(6) DEFAULT NULL,
  H smallint(6) DEFAULT NULL,
  2B smallint(6) DEFAULT NULL,
  3B smallint(6) DEFAULT NULL,
  HR smallint(6) DEFAULT NULL,
  RBI smallint(6) DEFAULT NULL,
  SB smallint(6) DEFAULT NULL,
  CS smallint(6) DEFAULT NULL,
  BB smallint(6) DEFAULT NULL,
  SO smallint(6) DEFAULT NULL,
  IBB smallint(6) DEFAULT NULL,
  HBP smallint(6) DEFAULT NULL,
  SH smallint(6) DEFAULT NULL,
  SF smallint(6) DEFAULT NULL,
  GIDP smallint(6) DEFAULT NULL,
  PRIMARY KEY (ID),
  UNIQUE KEY (playerID,yearID,stint),
  FOREIGN KEY (lgID) REFERENCES leagues(lgID),
  FOREIGN KEY (team_ID) REFERENCES teams(ID),
  FOREIGN KEY (playerID) REFERENCES people(playerID)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;
CREATE TABLE battingpost (
  ID INT NOT NULL AUTO_INCREMENT,
  yearID smallint(6) NOT NULL,
  round varchar(10) NOT NULL,
  playerID varchar(9) NOT NULL,
  teamID char(3) DEFAULT NULL,
  team_ID INT DEFAULT NULL,
  lgID char(3) DEFAULT NULL,
  G smallint(6) DEFAULT NULL,
  AB smallint(6) DEFAULT NULL,
  R smallint(6) DEFAULT NULL,
  H smallint(6) DEFAULT NULL,
  2B smallint(6) DEFAULT NULL,
  3B smallint(6) DEFAULT NULL,
  HR smallint(6) DEFAULT NULL,
  RBI smallint(6) DEFAULT NULL,
  SB smallint(6) DEFAULT NULL,
  CS smallint(6) DEFAULT NULL,
  BB smallint(6) DEFAULT NULL,
  SO smallint(6) DEFAULT NULL,
  IBB smallint(6) DEFAULT NULL,
  HBP smallint(6) DEFAULT NULL,
  SH smallint(6) DEFAULT NULL,
  SF smallint(6) DEFAULT NULL,
  GIDP smallint(6) DEFAULT NULL,
  PRIMARY KEY (ID),
  UNIQUE KEY (yearID,round,playerID),
  FOREIGN KEY (lgID) REFERENCES leagues(lgID),
  FOREIGN KEY (team_ID) REFERENCES teams(ID),
  FOREIGN KEY (playerID) REFERENCES people(playerID)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;
CREATE TABLE schools (
  schoolID varchar(15) NOT NULL,
  name_full varchar(255) DEFAULT NULL,
  city varchar(55) DEFAULT NULL,
  state varchar(55) DEFAULT NULL,
  country varchar(55) DEFAULT NULL,
  PRIMARY KEY (schoolID)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;
CREATE TABLE collegeplaying (
  ID INT NOT NULL AUTO_INCREMENT,
  playerID varchar(9) NOT NULL,
  schoolID varchar(15) DEFAULT NULL,
  yearID smallint(6) DEFAULT NULL,
  PRIMARY KEY (ID),
  FOREIGN KEY (schoolID) REFERENCES schools(schoolID),
  FOREIGN KEY (playerID) REFERENCES people(playerID)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;
CREATE TABLE fielding (
  ID INT NOT NULL AUTO_INCREMENT,
  playerID varchar(9) NOT NULL,
  yearID smallint(6) NOT NULL,
  stint smallint(6) NOT NULL,
  teamID char(3) DEFAULT NULL,
  team_ID INT DEFAULT NULL,
  lgID char(3) DEFAULT NULL,
  POS varchar(2) NOT NULL,
  G smallint(6) DEFAULT NULL,
  GS smallint(6) DEFAULT NULL,
  InnOuts smallint(6) DEFAULT NULL,
  PO smallint(6) DEFAULT NULL,
  A smallint(6) DEFAULT NULL,
  E smallint(6) DEFAULT NULL,
  DP smallint(6) DEFAULT NULL,
  PB smallint(6) DEFAULT NULL,
  WP smallint(6) DEFAULT NULL,
  SB smallint(6) DEFAULT NULL,
  CS smallint(6) DEFAULT NULL,
  ZR double DEFAULT NULL,
  PRIMARY KEY (ID),
  UNIQUE KEY (playerID,yearID,stint,POS),
  FOREIGN KEY (lgID) REFERENCES leagues(lgID),
  FOREIGN KEY (team_ID) REFERENCES teams(ID),
  FOREIGN KEY (playerID) REFERENCES people(playerID)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;
CREATE TABLE fieldingof (
  ID INT NOT NULL AUTO_INCREMENT,
  playerID varchar(9) NOT NULL,
  yearID smallint(6) NOT NULL,
  stint smallint(6) NOT NULL,
  Glf smallint(6) DEFAULT NULL,
  Gcf smallint(6) DEFAULT NULL,
  Grf smallint(6) DEFAULT NULL,
  PRIMARY KEY (ID),
  UNIQUE KEY (playerID,yearID,stint),
  FOREIGN KEY (playerID) REFERENCES people(playerID)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;
CREATE TABLE fieldingofsplit (
  ID INT NOT NULL AUTO_INCREMENT,
  playerID varchar(9) NOT NULL,
  yearID smallint(6) NOT NULL,
  stint smallint(6) NOT NULL,
  teamID char(3) DEFAULT NULL,
  team_ID INT DEFAULT NULL,
  lgID char(3) DEFAULT NULL,
  POS varchar(2) NOT NULL,
  G smallint(6) DEFAULT NULL,
  GS smallint(6) DEFAULT NULL,
  InnOuts smallint(6) DEFAULT NULL,
  PO smallint(6) DEFAULT NULL,
  A smallint(6) DEFAULT NULL,
  E smallint(6) DEFAULT NULL,
  DP smallint(6) DEFAULT NULL,
  PB smallint(6) DEFAULT NULL,
  WP smallint(6) DEFAULT NULL,
  SB smallint(6) DEFAULT NULL,
  CS smallint(6) DEFAULT NULL,
  ZR double DEFAULT NULL,
  PRIMARY KEY (ID),
  UNIQUE KEY (playerID,yearID,stint,POS),
  FOREIGN KEY (lgID) REFERENCES leagues(lgID),
  FOREIGN KEY (team_ID) REFERENCES teams(ID),
  FOREIGN KEY (playerID) REFERENCES people(playerID)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;
CREATE TABLE fieldingpost (
  ID INT NOT NULL AUTO_INCREMENT,
  playerID varchar(9) NOT NULL,
  yearID smallint(6) NOT NULL,
  teamID char(3) DEFAULT NULL,
  team_ID INT DEFAULT NULL,
  lgID char(3) DEFAULT NULL,
  round varchar(10) NOT NULL,
  POS varchar(2) NOT NULL,
  G smallint(6) DEFAULT NULL,
  GS smallint(6) DEFAULT NULL,
  InnOuts smallint(6) DEFAULT NULL,
  PO smallint(6) DEFAULT NULL,
  A smallint(6) DEFAULT NULL,
  E smallint(6) DEFAULT NULL,
  DP smallint(6) DEFAULT NULL,
  TP smallint(6) DEFAULT NULL,
  PB smallint(6) DEFAULT NULL,
  SB smallint(6) DEFAULT NULL,
  CS smallint(6) DEFAULT NULL,
  PRIMARY KEY (ID),
  UNIQUE KEY (playerID,yearID,round,POS),
  FOREIGN KEY (lgID) REFERENCES leagues(lgID),
  FOREIGN KEY (team_ID) REFERENCES teams(ID),
  FOREIGN KEY (playerID) REFERENCES people(playerID)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;
CREATE TABLE halloffame (
  ID INT NOT NULL AUTO_INCREMENT,
  playerID varchar(10) NOT NULL,
  yearid smallint(6) NOT NULL,
  votedBy varchar(64) NOT NULL,
  ballots smallint(6) DEFAULT NULL,
  needed smallint(6) DEFAULT NULL,
  votes smallint(6) DEFAULT NULL,
  inducted varchar(1) DEFAULT NULL,
  category varchar(20) DEFAULT NULL,
  needed_note varchar(255) DEFAULT NULL,
  PRIMARY KEY (ID),
  UNIQUE KEY (playerID,yearid,votedBy),
  FOREIGN KEY (playerID) REFERENCES people(playerID)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;
CREATE TABLE parks (
  ID INT NOT NULL AUTO_INCREMENT,
  parkalias varchar(255) DEFAULT NULL,
  parkkey varchar(255) DEFAULT NULL,
  parkname varchar(255) DEFAULT NULL,
  city varchar(255) DEFAULT NULL,
  state varchar(255) DEFAULT NULL,
  country varchar(255) DEFAULT NULL,
  PRIMARY KEY (ID)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;
CREATE TABLE homegames (
  ID INT NOT NULL AUTO_INCREMENT,
  yearkey int(11) DEFAULT NULL,
  leaguekey char(3) DEFAULT NULL,
  teamkey char(3) DEFAULT NULL,
  team_ID INT DEFAULT NULL,
  parkkey varchar(255) DEFAULT NULL,
  park_ID INT DEFAULT NULL,
  spanfirst varchar(255) DEFAULT NULL,
  spanlast varchar(255) DEFAULT NULL,
  games int(11) DEFAULT NULL,
  openings int(11) DEFAULT NULL,
  attendance int(11) DEFAULT NULL,
  spanfirst_date date DEFAULT NULL,
  spanlast_date date DEFAULT NULL,
  PRIMARY KEY (ID),
  FOREIGN KEY (leaguekey) REFERENCES leagues(lgID),
  FOREIGN KEY (team_ID) REFERENCES teams(ID),
  FOREIGN KEY (park_ID) REFERENCES parks(ID)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;
CREATE TABLE managers (
  ID INT NOT NULL AUTO_INCREMENT,
  playerID varchar(10) DEFAULT NULL,
  yearID smallint(6) NOT NULL,
  teamID char(3) NOT NULL,
  team_ID INT DEFAULT NULL,
  lgID char(3) DEFAULT NULL,
  inseason smallint(6) NOT NULL,
  G smallint(6) DEFAULT NULL,
  W smallint(6) DEFAULT NULL,
  L smallint(6) DEFAULT NULL,
  teamRank smallint(6) DEFAULT NULL,
  plyrMgr varchar(1) DEFAULT NULL,
  PRIMARY KEY (ID),
  UNIQUE KEY (yearID,teamID,inseason),
  FOREIGN KEY (lgID) REFERENCES leagues(lgID),
  FOREIGN KEY (team_ID) REFERENCES teams(ID),
  FOREIGN KEY (playerID) REFERENCES people(playerID)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;
CREATE TABLE managershalf (
  ID INT NOT NULL AUTO_INCREMENT,
  playerID varchar(10) NOT NULL,
  yearID smallint(6) NOT NULL,
  teamID char(3) NOT NULL,
  team_ID INT DEFAULT NULL,
  lgID char(3) DEFAULT NULL,
  inseason smallint(6) DEFAULT NULL,
  half smallint(6) NOT NULL,
  G smallint(6) DEFAULT NULL,
  W smallint(6) DEFAULT NULL,
  L smallint(6) DEFAULT NULL,
  teamRank smallint(6) DEFAULT NULL,
  PRIMARY KEY (ID),
  UNIQUE KEY (playerID,yearID,teamID,half),
  FOREIGN KEY (lgID) REFERENCES leagues(lgID),
  FOREIGN KEY (team_ID) REFERENCES teams(ID),
  FOREIGN KEY (playerID) REFERENCES people(playerID)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;
CREATE TABLE pitching (
  ID INT NOT NULL AUTO_INCREMENT,
  playerID varchar(9) NOT NULL,
  yearID smallint(6) NOT NULL,
  stint smallint(6) NOT NULL,
  teamID char(3) DEFAULT NULL,
  team_ID INT DEFAULT NULL,
  lgID char(3) DEFAULT NULL,
  W smallint(6) DEFAULT NULL,
  L smallint(6) DEFAULT NULL,
  G smallint(6) DEFAULT NULL,
  GS smallint(6) DEFAULT NULL,
  CG smallint(6) DEFAULT NULL,
  SHO smallint(6) DEFAULT NULL,
  SV smallint(6) DEFAULT NULL,
  IPouts int(11) DEFAULT NULL,
  H smallint(6) DEFAULT NULL,
  ER smallint(6) DEFAULT NULL,
  HR smallint(6) DEFAULT NULL,
  BB smallint(6) DEFAULT NULL,
  SO smallint(6) DEFAULT NULL,
  BAOpp double DEFAULT NULL,
  ERA double DEFAULT NULL,
  IBB smallint(6) DEFAULT NULL,
  WP smallint(6) DEFAULT NULL,
  HBP smallint(6) DEFAULT NULL,
  BK smallint(6) DEFAULT NULL,
  BFP smallint(6) DEFAULT NULL,
  GF smallint(6) DEFAULT NULL,
  R smallint(6) DEFAULT NULL,
  SH smallint(6) DEFAULT NULL,
  SF smallint(6) DEFAULT NULL,
  GIDP smallint(6) DEFAULT NULL,
  PRIMARY KEY (ID),
  UNIQUE KEY (playerID,yearID,stint),
  FOREIGN KEY (lgID) REFERENCES leagues(lgID),
  FOREIGN KEY (team_ID) REFERENCES teams(ID),
  FOREIGN KEY (playerID) REFERENCES people(playerID)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;
CREATE TABLE pitchingpost (
  ID INT NOT NULL AUTO_INCREMENT,
  playerID varchar(9) NOT NULL,
  yearID smallint(6) NOT NULL,
  round varchar(10) NOT NULL,
  teamID char(3) DEFAULT NULL,
  team_ID INT DEFAULT NULL,
  lgID char(3) DEFAULT NULL,
  W smallint(6) DEFAULT NULL,
  L smallint(6) DEFAULT NULL,
  G smallint(6) DEFAULT NULL,
  GS smallint(6) DEFAULT NULL,
  CG smallint(6) DEFAULT NULL,
  SHO smallint(6) DEFAULT NULL,
  SV smallint(6) DEFAULT NULL,
  IPouts int(11) DEFAULT NULL,
  H smallint(6) DEFAULT NULL,
  ER smallint(6) DEFAULT NULL,
  HR smallint(6) DEFAULT NULL,
  BB smallint(6) DEFAULT NULL,
  SO smallint(6) DEFAULT NULL,
  BAOpp double DEFAULT NULL,
  ERA double DEFAULT NULL,
  IBB smallint(6) DEFAULT NULL,
  WP smallint(6) DEFAULT NULL,
  HBP smallint(6) DEFAULT NULL,
  BK smallint(6) DEFAULT NULL,
  BFP smallint(6) DEFAULT NULL,
  GF smallint(6) DEFAULT NULL,
  R smallint(6) DEFAULT NULL,
  SH smallint(6) DEFAULT NULL,
  SF smallint(6) DEFAULT NULL,
  GIDP smallint(6) DEFAULT NULL,
  PRIMARY KEY (ID),
  UNIQUE KEY (playerID,yearID,round),
  FOREIGN KEY (lgID) REFERENCES leagues(lgID),
  FOREIGN KEY (team_ID) REFERENCES teams(ID),
  FOREIGN KEY (playerID) REFERENCES people(playerID)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;
CREATE TABLE salaries (
  ID INT NOT NULL AUTO_INCREMENT,
  yearID smallint(6) NOT NULL,
  teamID char(3) NOT NULL,
  team_ID INT DEFAULT NULL,
  lgID char(3) NOT NULL,
  playerID varchar(9) NOT NULL,
  salary double DEFAULT NULL,
  PRIMARY KEY (ID),
  UNIQUE KEY (yearID,teamID,lgID,playerID),
  FOREIGN KEY (lgID) REFERENCES leagues(lgID),
  FOREIGN KEY (team_ID) REFERENCES teams(ID),
  FOREIGN KEY (playerID) REFERENCES people(playerID)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;
CREATE TABLE seriespost (
  ID INT NOT NULL AUTO_INCREMENT,
  yearID smallint(6) NOT NULL,
  round varchar(5) NOT NULL,
  teamIDwinner varchar(3) DEFAULT NULL,
  lgIDwinner char(3) DEFAULT NULL,
  team_IDwinner INT DEFAULT NULL,
  teamIDloser varchar(3) DEFAULT NULL,
  team_IDloser INT DEFAULT NULL,
  lgIDloser char(3) DEFAULT NULL,
  wins smallint(6) DEFAULT NULL,
  losses smallint(6) DEFAULT NULL,
  ties smallint(6) DEFAULT NULL,
  PRIMARY KEY (ID),
  UNIQUE KEY (yearID,round),
  FOREIGN KEY (lgIDwinner) REFERENCES leagues(lgID),
  FOREIGN KEY (lgIDloser) REFERENCES leagues(lgID),
  FOREIGN KEY (team_IDwinner) REFERENCES teams(ID),
  FOREIGN KEY (team_IDloser) REFERENCES teams(ID)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

-- =============================================
-- VIEWS
-- =============================================

CREATE OR REPLACE VIEW fieldingpost_view AS
SELECT
    fielding.*
FROM fieldingpost AS fielding
ORDER BY fielding.playerID ASC, fielding.yearID ASC;
CREATE OR REPLACE VIEW fielding_view AS
SELECT
    fielding.*
FROM fielding
ORDER BY fielding.playerID ASC, fielding.yearID ASC;
CREATE OR REPLACE VIEW battingpost_view AS
SELECT
    batting.*,
    (batting.AB + batting.BB + batting.HBP + batting.SF + batting.SH) as PA,
    round((batting.BB / (batting.AB + batting.BB + batting.HBP + batting.SF + batting.SH)), 3) as BBpct,
    round((batting.SO / (batting.AB + batting.BB + batting.HBP + batting.SF + batting.SH)), 3) as Kpct,
    round((((batting.2B) + (2 * batting.3B) + ( 3 * batting.HR)) / batting.AB), 3) as ISO,
    round(((batting.H - batting.HR) / ((batting.AB + batting.BB + batting.HBP + batting.SF + batting.SH) - batting.SO - batting.BB - batting.HR)), 3) as BABIP,
    round((batting.H / batting.AB), 3) as AVG,
    round(((batting.H + batting.BB + batting.HBP) / (batting.AB + batting.BB + batting.HBP + batting.SF)), 3) as OBP,
    round(((batting.H + batting.2B + 2 * batting.3B + 3 * batting.HR) / batting.AB), 3) as SLG,
    round(((batting.H + batting.BB + batting.HBP) / (batting.AB + batting.BB + batting.HBP + batting.SF)) + (((batting.H - batting.2B - batting.3B - batting.HR) + (2 * batting.2B) + (3 * batting.3B) + (4 * batting.HR)) / batting.AB), 3) as OPS
FROM battingpost AS batting
ORDER BY batting.playerID ASC, batting.yearID ASC;
CREATE OR REPLACE VIEW Top_Current_HR_Hitters AS
SELECT p.playerID, p.nameFirst, p.nameLast, b.yearID, SUM(b.HR) AS totalHR
FROM people p
JOIN batting b ON p.playerID = b.playerID
GROUP BY p.playerID, p.nameFirst, p.nameLast, b.yearID
HAVING b.yearID = (SELECT MAX(yearID) FROM batting)
ORDER BY totalHR DESC
LIMIT 20;
CREATE OR REPLACE VIEW Career_Batting_Averages AS
SELECT p.playerID, p.nameFirst, p.nameLast,
       SUM(b.H) AS totalHits, SUM(b.AB) AS totalAB,
       ROUND(SUM(b.H) / NULLIF(SUM(b.AB), 0), 3) AS careerBA
FROM people p
JOIN batting b ON p.playerID = b.playerID
GROUP BY p.playerID, p.nameFirst, p.nameLast
HAVING totalAB > 1000
ORDER BY careerBA DESC;
CREATE OR REPLACE VIEW AllTime_Strikeout_Leaders AS
SELECT p.playerID, p.nameFirst, p.nameLast, SUM(pi.SO) AS totalStrikeouts
FROM people p
JOIN pitching pi ON p.playerID = pi.playerID
GROUP BY p.playerID, p.nameFirst, p.nameLast
ORDER BY totalStrikeouts DESC
LIMIT 20;
CREATE OR REPLACE VIEW MVP_Leaders AS
SELECT p.playerID, p.nameFirst, p.nameLast, COUNT(*) AS MVP_Count
FROM awardsplayers ap
JOIN people p ON ap.playerID = p.playerID
WHERE ap.awardID = 'Most Valuable Player'
GROUP BY p.playerID, p.nameFirst, p.nameLast
ORDER BY MVP_Count DESC;
CREATE OR REPLACE VIEW Team_WS_Wins AS
SELECT teamID, COUNT(*) AS WorldSeriesWins
FROM teams
WHERE WSWin = 'Y'
GROUP BY teamID
ORDER BY WorldSeriesWins DESC;
CREATE OR REPLACE VIEW Team_ERA_Rankings_By_Season AS
SELECT yearID, teamID, ERA
FROM teams
ORDER BY yearID DESC, ERA ASC;
CREATE OR REPLACE VIEW Yearly_HR_Leaders AS
SELECT b.yearID, p.playerID, p.nameFirst, p.nameLast, SUM(b.HR) AS totalHR
FROM batting b
JOIN people p ON b.playerID = p.playerID
GROUP BY b.yearID, b.playerID
HAVING totalHR = (
  SELECT MAX(SUM_HR) FROM (
    SELECT b2.playerID, SUM(b2.HR) AS SUM_HR
    FROM batting b2
    WHERE b2.yearID = b.yearID
    GROUP BY b2.playerID
  ) AS yearly
)
ORDER BY b.yearID DESC;
CREATE OR REPLACE VIEW Player_Team_Count AS
SELECT p.playerID, p.nameFirst, p.nameLast, COUNT(DISTINCT b.teamID) AS numTeams
FROM batting b
JOIN people p ON p.playerID = b.playerID
GROUP BY p.playerID, p.nameFirst, p.nameLast
ORDER BY numTeams DESC;
CREATE OR REPLACE VIEW Power_Hitters_Seasons AS
SELECT p.playerID, p.nameFirst, p.nameLast, b.yearID, SUM(b.HR) AS HRs, SUM(b.RBI) AS RBIs
FROM batting b
JOIN people p ON b.playerID = p.playerID
GROUP BY p.playerID, p.nameFirst, p.nameLast, b.yearID
HAVING HRs >= 30 AND RBIs >= 100
ORDER BY b.yearID DESC, HRs DESC;
CREATE OR REPLACE VIEW Rookie_BA_Leaders AS
SELECT p.playerID, p.nameFirst, p.nameLast, b.yearID,
       SUM(b.H) AS Hits, SUM(b.AB) AS AB,
       ROUND(SUM(b.H)/NULLIF(SUM(b.AB), 0), 3) AS BattingAverage
FROM people p
JOIN batting b ON p.playerID = b.playerID
WHERE DATEDIFF(CONCAT(b.yearID,'-12-31'), p.debut) <= 365
GROUP BY p.playerID, p.nameFirst, p.nameLast, b.yearID
HAVING AB > 100
ORDER BY BattingAverage DESC;
CREATE OR REPLACE VIEW Power_Speed_Combo AS
SELECT p.playerID, p.nameFirst, p.nameLast, b.yearID, SUM(b.HR) AS HRs, SUM(b.SB) AS SBs
FROM batting b
JOIN people p ON b.playerID = p.playerID
GROUP BY p.playerID, p.nameFirst, p.nameLast, b.yearID
HAVING HRs >= 40 AND SBs >= 20
ORDER BY b.yearID DESC;
CREATE OR REPLACE VIEW High_OBP_Seasons AS
SELECT p.playerID, p.nameFirst, p.nameLast, b.yearID,
       ROUND((SUM(b.H) + SUM(b.BB) + SUM(b.HBP)) /
             NULLIF(SUM(b.AB) + SUM(b.BB) + SUM(b.HBP) + SUM(b.SF), 0), 3) AS OBP
FROM batting b
JOIN people p ON b.playerID = p.playerID
GROUP BY p.playerID, p.nameFirst, p.nameLast, b.yearID
HAVING OBP >= 0.400
ORDER BY b.yearID DESC, OBP DESC;
CREATE OR REPLACE VIEW Career_StolenBase_Leaders AS
SELECT p.playerID, p.nameFirst, p.nameLast, SUM(b.SB) AS totalSB
FROM people p
JOIN batting b ON p.playerID = b.playerID
GROUP BY p.playerID, p.nameFirst, p.nameLast
ORDER BY totalSB DESC
LIMIT 20;
CREATE OR REPLACE VIEW Career_Durability_Leaders AS
SELECT p.playerID, p.nameFirst, p.nameLast, SUM(b.G) AS totalGames
FROM people p
JOIN batting b ON p.playerID = b.playerID
GROUP BY p.playerID, p.nameFirst, p.nameLast
ORDER BY totalGames DESC
LIMIT 20;
CREATE OR REPLACE VIEW Career_Save_Leaders AS
SELECT p.playerID, p.nameFirst, p.nameLast, SUM(pi.SV) AS totalSaves
FROM people p
JOIN pitching pi ON p.playerID = pi.playerID
GROUP BY p.playerID, p.nameFirst, p.nameLast
ORDER BY totalSaves DESC
LIMIT 20;
CREATE OR REPLACE VIEW Yearly_Top_Salaries AS
SELECT s.yearID, p.playerID, p.nameFirst, p.nameLast, s.salary
FROM salaries s
JOIN people p ON s.playerID = p.playerID
ORDER BY s.yearID DESC, s.salary DESC;
CREATE OR REPLACE VIEW Gold_Glove_Winners AS
SELECT p.playerID, p.nameFirst, p.nameLast, COUNT(*) AS GoldGloveCount
FROM awardsplayers ap
JOIN people p ON ap.playerID = p.playerID
WHERE ap.awardID = 'Gold Glove'
GROUP BY p.playerID, p.nameFirst, p.nameLast
ORDER BY GoldGloveCount DESC;
CREATE OR REPLACE VIEW Player_Count_By_Country AS
SELECT birthCountry, COUNT(*) AS playerCount
FROM people
GROUP BY birthCountry
ORDER BY playerCount DESC;
CREATE OR REPLACE VIEW Player_Heights AS
SELECT playerID, nameFirst, nameLast, height
FROM people
ORDER BY height DESC;
CREATE OR REPLACE VIEW Players_By_College AS
SELECT s.schoolID, sc.name_full AS schoolName, COUNT(*) AS PlayerCount
FROM collegeplaying s
JOIN schools sc ON s.schoolID = sc.schoolID
GROUP BY s.schoolID, schoolName
ORDER BY PlayerCount DESC;
CREATE OR REPLACE VIEW Estimated_Career_WAR AS
SELECT p.playerID, p.nameFirst, p.nameLast,
       SUM(b.HR * 0.3 + b.RBI * 0.2 + b.SB * 0.2 - b.SO * 0.1) AS Estimated_WAR
FROM people p
JOIN batting b ON p.playerID = b.playerID
GROUP BY p.playerID, p.nameFirst, p.nameLast
ORDER BY Estimated_WAR DESC;
CREATE OR REPLACE VIEW Hall_Of_Fame_Inductees AS
SELECT p.playerID, p.nameFirst, p.nameLast, h.yearID, h.inducted
FROM halloffame h
JOIN people p ON h.playerID = p.playerID
WHERE h.inducted = 'Y'
ORDER BY h.yearID DESC;
CREATE OR REPLACE VIEW batting_view AS
SELECT
    batting.*,
    (batting.AB + batting.BB + batting.HBP + batting.SF + batting.SH) as PA,
    round((batting.BB / (batting.AB + batting.BB + batting.HBP + batting.SF + batting.SH)), 3) as BBpct,
    round((batting.SO / (batting.AB + batting.BB + batting.HBP + batting.SF + batting.SH)), 3) as Kpct,
    round((((batting.2B) + (2 * batting.3B) + ( 3 * batting.HR)) / batting.AB), 3) as ISO,
    round(((batting.H - batting.HR) / ((batting.AB + batting.BB + batting.HBP + batting.SF + batting.SH) - batting.SO - batting.BB - batting.HR)), 3) as BABIP,
    round((batting.H / batting.AB), 3) as AVG,
    round(((batting.H + batting.BB + batting.HBP) / (batting.AB + batting.BB + batting.HBP + batting.SF)), 3) as OBP,
    round(((batting.H + batting.2B + 2 * batting.3B + 3 * batting.HR) / batting.AB), 3) as SLG,
    round(((batting.H + batting.BB + batting.HBP) / (batting.AB + batting.BB + batting.HBP + batting.SF)) + (((batting.H - batting.2B - batting.3B - batting.HR) + (2 * batting.2B) + (3 * batting.3B) + (4 * batting.HR)) / batting.AB), 3) as OPS
FROM batting
ORDER BY batting.playerID ASC, batting.yearID ASC;
CREATE OR REPLACE VIEW pitching_view AS
SELECT
    pitching.*,
    round((pitching.IPouts / 3), 3) as IP,
    round((pitching.SO * 9) / (pitching.IPouts / 3), 3) as k_9,
    round((pitching.BB * 9) / (pitching.IPouts / 3), 3) as BB_9,
    round((pitching.SO / pitching.BB), 3) as K_BB,
    round((pitching.SO / pitching.BFP), 3) as Kpct,
    round((pitching.BB / pitching.BFP), 3) as BBpct,
    round((pitching.HR * 9) / (pitching.IPouts / 3), 3) as HR_9,
    round((pitching.H / (pitching.IPouts - pitching.BB - pitching.HBP - pitching.SH - pitching.SF)), 3) as AVG,
    round(((pitching.BB + pitching.H) / (pitching.IPouts / 3)), 3) as WHIP,
    round(((pitching.H - pitching.HR) / (pitching.BFP - pitching.SO - pitching.BB - pitching.HR)), 3) as BABIP
FROM pitching
ORDER BY pitching.playerID ASC, pitching.yearID ASC;
CREATE OR REPLACE VIEW pitchingpost_view AS
SELECT
    pitching.*,
    round((pitching.IPouts / 3), 3) as IP,
    round((pitching.SO * 9) / (pitching.IPouts / 3), 3) as k_9,
    round((pitching.BB * 9) / (pitching.IPouts / 3), 3) as BB_9,
    round((pitching.SO / pitching.BB), 3) as K_BB,
    round((pitching.SO / pitching.BFP), 3) as Kpct,
    round((pitching.BB / pitching.BFP), 3) as BBpct,
    round((pitching.HR * 9) / (pitching.IPouts / 3), 3) as HR_9,
    round((pitching.H / (pitching.IPouts - pitching.BB - pitching.HBP - pitching.SH - pitching.SF)), 3) as AVG,
    round(((pitching.BB + pitching.H) / (pitching.IPouts / 3)), 3) as WHIP,
    round(((pitching.H - pitching.HR) / (pitching.BFP - pitching.SO - pitching.BB - pitching.HR)), 3) as BABIP
FROM pitchingpost AS pitching
ORDER BY pitching.playerID ASC, pitching.yearID ASC;
