/*********************************************************************************
 _____ ____  _____ 
|  _  |    \|   __|
|     |  |  |   __|
|__|__|____/|__|   
ARMA Mission Development Framework
ADF version: 2.26 / Jul 2020

Module: Create Para drop
Author: Whiztler
Module version: 1.14

File: ADF_mod_createPara.sqf
**********************************************************************************
This module creates a transport helicopter and an infantry fire team or infantry
squad. The AI units are loaded into the helicopter and then flown to the drop off
point where they will para drop.
You can pass 2 functions to the script:

Function1 will run (call) on individual units once the infantry group has been
created (e.g. a loadout script). Params passed to the function: _this select 0: unit 

Function2 will run (spawn) on the group itself. Can be used to give the group
directives once they have landed (e.g. assault waypoints). Params passed to the
function: _this select 0: group.

After dropping off the para group, the helicopter returns to the spawn position
where the helicopter and its crew are deleted.

INSTRUCTIONS:
Execute the module on the SERVER or HC only!
*********************************************************************************/

/****  vv  COPY FROM HERE TILL THE END  vv  *****/
///// DO NOT EDIT BELOW
diag_log "ADF rpt: Init - executing: ADF_mod_createPara.sqf";
[
///// DO NOT EDIT ABOVE

/*
	Step 1.	Copy from (COPY FROM HERE) into your script for each para group you want to create.
	Step 2.	Create a spawn position the map where the helicopter and the para group will spawn ("Marker", Object, Trigger, Araay [X,Y,Z])
	Step 3.	Create a drop position the map where the para group will jump ("Marker", Object, Trigger, Araay [X,Y,Z])
	Step 4.	Fill out below parameters
    Note: Don't worry about the many comments as the ARMA engine ignores comments.	
*/

"spawnMarker",          //  Location where both the helicopter and the para group are created. This can be:                 
                        //  * Marker. E.g. "mySpawnMarker"
                        //  * Object. E.g. myFlagPole
                        //  * Trigger E.g. myTrigger
                        //  * Array. Position array [X,Y,Z]

"paraDropMarker",       //  Para drop location. Please note that the group will start jumping out of the aircraft 350 meters from the para drop location:                   
                        //  * Marker. E.g. "myParaDropMarker"
                        //  * Object. E.g. myCar
                        //  * Trigger E.g. myTrigger
                        //  * Array. Position array [X,Y,Z]

east,                   //  Side of the helicopter and the para group. Can be west, east or independent. Default: east

2,                      //  Size of the para infantry group. Make sure the helicopter can accommodate the para group:
                        // - 1: Fire team - 4 pax
                        // - 2: Squad - 8 pax (default) 
                        // - 3: Squad plus one fire team, - 12 pax
                        // - 4: Two squads - 16 pax

"",                     //  Code to execute on each unit of the para group (e.g. a function)  (default = "") 
                        //  code is CALLED. each unit is passed (_this select 0) to the code/fnc.

""                      //  Code to execute on the para group (e.g. a function)  (default = "")
                        //  code is CALLED. each unit is passed (_this select 0) to the code/fnc.

///// DO NOT EDIT BELOW
] spawn ADF_fnc_createPara;