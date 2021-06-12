/*********************************************************************************
 _____ ____  _____ 
|  _  |    \|   __|
|     |  |  |   __|
|__|__|____/|__|   
ARMA Mission Development Framework
ADF version: 2.26 / Jul 2020

Module: Create Sea Patrol
Author: Whiztler
Module version: 1.06

File: ADF_mod_createSeaPatrol.sqf
**********************************************************************************
This module creates a crewed boat that patrols a given position. The module
creates water waypoints in a given radius. You can define which type of ship.

INSTRUCTIONS:
Execute the module on the SERVER or HC only!
*********************************************************************************/

/****  vv  COPY FROM HERE TILL THE END  vv  *****/
///// DO NOT EDIT BELOW
diag_log "ADF rpt: Init - executing: ADF_mod_createSeaPatrol.sqf";
[
///// DO NOT EDIT ABOVE

/*
	Step 1:	Copy from (COPY FROM HERE) into your script for each sea patrol you want to create.
	Step 2:	Determine a location where the vessel will spawn. This can be a marker, an editor placed object, trigger, etc.
	Step 3.	Fill out below parameters
    Note: Don't worry about the many comments as the ARMA engine ignores comments.
*/

"myMarker",         // Spawn location. This is the location on the map where the crewed vessel will be created. The location can be a marker, trigger, object, etc:
                    
"PatrolMarker",     // Patrol start location. Can be the same as the spawn location. If you want a different location than the spawn location than use:
                    // - "PatrolMarker" use the name of the marker where the vessel will move to after it has spawned. Markers are always a string ("")
                    // - myTrigger use the name of the trigger where the vessel will move to after it has spawned. (center). 
                    // - myObject use the name of an editor placed object where the vessel will move to after it has spawned.
                    
east,               // Side of the vessel and its crew. Can be east, west or independent

2,                  // Number that represents the type of vessel. Options are
                    // 1: speedboat mini gun (default)
                    // 2: assault boat (RHIB)

true,               // Crew the vessel with gunners?
                    // True - driver + gunner(s)/crew (default)
                    // false - driver only                  
                    
1500,               // Number that represents the patrol Radius in meters from the patrol start position.  (default: 1000)

6,                  // Number that represents the number of random patrol waypoints that should be created. (default: 4)

"MOVE",             // Waypoint type. (default: "MOVE"). More info: https://community.bistudio.com/wiki/Waypoint_types

"SAFE",             // Waypoint behavior. (default: "SAFE"). More info: https://community.bistudio.com/wiki/setWaypointBehaviour

"RED",              // Combat mode. (default: "YELLOW"). More info: https://community.bistudio.com/wiki/setWaypointCombatMode

"LIMITED",          // Patrol speed. (default: "LIMITED"). More info: https://community.bistudio.com/wiki/waypointSpeed

"FILE",             // Patrol formation. (default: "COLUMN"). More info: https://community.bistudio.com/wiki/waypointFormation

50,                 // Waypoint completion radius. (default: 25). More info: https://community.bistudio.com/wiki/setWaypointCompletionRadius

"",                 // String that represents a (custom) function (or code) that will be executed for EACH UNIT of the crew.
                    // E.g.: "my_fnc_redressTheCrew"  -or-  "ADF_fnc_objectBoatCrew"
                    // default: ""
                    
""                  // String that represents a (custom) function (or code) that will be executed on the crew as a group.
                    // E.g.: "my_fnc_setGroupID"  -or-  "ADF_fnc_groupSetSkill."
                    // default: ""

///// DO NOT EDIT BELOW
] call ADF_fnc_createSeaPatrol;