/*********************************************************************************
 _____ ____  _____ 
|  _  |    \|   __|
|     |  |  |   __|
|__|__|____/|__|   
ARMA Mission Development Framework
ADF version: 2.26 / Jul 2020

Module: Ambient Civilian Traffic
Author: Whiztler
Module version: 1.04

File: ADF_mod_ACT.sqf
**********************************************************************************
This module creates civilian man and civilian crew vehicles around the players. 
Man have waypoints leading to houses and enter houses to look around.
Cars have waypoints close to the players location en then drive off to a far
waypoint.

INSTRUCTIONS:
Execute the module on the SERVER! The module does not run on HC's or player clients
********************************************************************************/

/****  vv  COPY FROM HERE TILL THE END  vv  *****/

///// DO NOT EDIT BELOW
diag_log "ADF rpt: Init - executing: ADF_mod_ACT.sqf";
///// DO NOT EDIT ABOVE

// Maximum number of civilian vehicles that spawn around the players. 0 to disable.
ADF_ACT_vehiclesMax = 3;

// Distance (meters) from players that vehicles will spawn. Note there is no visibility check. Default: 1250
ADF_ACT_vehiclesRadiusSpawn 	= 1250;

// Distance (meters) from players that vehicles will be deleted. Default: 1500
ADF_ACT_vehiclesRadiusTerm 	= 1500;

// Maximum number of civilian man (foot mobiles) that spawn around the players. 0 to disable.
ADF_ACT_manMax = 2;

// Distance (meters) from players that man will be deleted. Default: 500
ADF_ACT_manRadiusTerm = 500;

// Enable terrorist suicide bombers? True to enable. False to disable
ADF_ACT_terrorist = false;

// Change (percentage) of the civilian becoming a suicide bomber (when enabled). Default: 10
ADF_ACT_terroristChance = 10;

// ACT Debug mode. True for on. False for off. Default: false
ACT_debug = false;

///// DO NOT EDIT BELOW
execVM "ADF\fnc\ambient\ADF_fnc_ACT.sqf";

