/*********************************************************************************
 _____ ____  _____ 
|  _  |    \|   __|
|     |  |  |   __|
|__|__|____/|__|   
ARMA Mission Development Framework
ADF version: 2.26 / Jul 2020

Module: Create AO
Author: Whiztler
Module version: 1.11

File: ADF_mod_createAO.sqf
**********************************************************************************
This module creates (populates) a given AO (position, marker size). The amount of
units/vehicles depend on the size of the ao (size of the marker). Infantry units
garrison or go on patrol (if no buildings near). Vehicles go on patrol.
NOTE THAT SPAWNING AN AO CAN TAKE UP TO 5 MINUTES!

INSTRUCTIONS:
Execute (spawn!) from the server or headless client.
*********************************************************************************/

/****  vv  COPY FROM HERE TILL THE END vv  *****/
///// DO NOT EDIT BELOW
diag_log "ADF rpt: Init - executing: ADF_mod_createAO.sqf";
[
///// DO NOT EDIT ABOVE

/*
	Step 1.	Copy from (COPY FROM HERE) into your script for each AO you want to create.
	Step 2.	Place a rectangular or ellipse marker on the map. Size of the marker determines size (number of units) of the AO.
			The marker color does not matter as the script will make the marker transparent upon mission start. The marker is
			there as a visual aid for the mission maker. The size of the circular marker determines the size of the AO:
			< 100 meters			: 8 x inf, 1 vehicle
			100 - 250 meters		: 16 x inf, 1 vehicle
			250 - 500 meters		: 24 x inf, 2 x vehicle, 1 x apc
			500 - 750 meters		: 32 x inf, 3 x vehicle, 2 x apc, 1 x armor
			750 - 1000 meters		: 48 x inf, 5 x vehicle, 2 x apc, 2 x armor
			> 1000 meters			: 48 x inf, 5 x vehicle, 2 x apc, 2 x armor, 1 helicopter
	Step 3.	Fill out below parameters
	Note: Don't worry about the many comments as the ARMA engine ignores comments.	
*/

"myAOmarker",   // The AO marker (string).
                
east,           // Side of the AO units. east, west or independent

false,          // Make the AO marker transparent (invisible to players). Default: true
                // - true: make transparent
                // - false: leave as is
                
true,           // Make infantry patrol units search nearby buildings? Default: false
                // - true: search buildings
                // - false: do not search buildings
                
true,           // Create random IED's in the AO?  Default: false.
                // - TRUE: place random IED's
                // - FALSE: Do not place random IED's
                
"",             // Code or function that is executed on EACH UNIT of a group after spawn. Default: ""
                // code is CALLED. each unit is passed (_this select 0) to the code/fnc.
                
""              // Code or function that is executed on THE ENTIRE GROUP after spawn. Default: ""
                // code is CALLED. each unit is passed (_this select 0) to the code/fnc.

///// DO NOT EDIT BELOW
] spawn ADF_fnc_createAO;