/*
=============================================================================
LAHMAN BASEBALL ENHANCED - DUAL LICENSE NOTICE
=============================================================================
This file contains both custom database architecture and third-party data.

1. THE CODE (MIT LICENSE)
All structural SQL code, including CREATE TABLE statements, schema statements, 
views, functions, and stored procedures are the work of 
Danny (CesiumSkater) and are licensed under the MIT License. 
Copyright (c) 2026 Danny (CesiumSkater).

2. THE DATA (CC BY-SA 3.0)
The statistical data contained within all INSERT INTO statements is derived 
from the Lahman Baseball Database (version 2025). This data is the property 
of the Lahman Database and is distributed here under the Creative Commons 
Attribution-ShareAlike 3.0 Unported License. 
Source: https://sabr.org/lahman-database/

DISCLAIMER:
This file is provided "as is" without warranty of any kind. The author 
assumes no liability for any claims or damages arising from the use of 
this software or the underlying data.
=============================================================================
*/

CREATE DATABASE IF NOT EXISTS mlb_baseball;
USE mlb_baseball;
SET NAMES utf8mb4;
SET character_set_client = utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;
SET UNIQUE_CHECKS = 0;
SET AUTOCOMMIT = 0;

-- DROP TABLES
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

-- CREATE TABLES
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