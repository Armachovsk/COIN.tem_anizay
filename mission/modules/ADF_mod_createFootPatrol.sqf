/*********************************************************************************
 _____ ____  _____ 
|  _  |    \|   __|
|     |  |  |   __|
|__|__|____/|__|   
ARMA Mission Development Framework
ADF version: 2.26 / Jul 2020

Module: Create Foot Patrol
Author: Whiztler
Module version: 1.11

File: ADF_mod_createFootPatrol.sqf
**********************************************************************************
This module creates a group (2, 4 or 8 pax) that patrols a given position. The 
module creates waypoints in a given radius. There are options you can define 
such as waypoint behavior/speed/etc. and search nearest building.
You can execute two (optional) functions. One for the group and one for each unit
of the group.

INSTRUCTIONS:
Execute the module on the SERVER or HC only!
*********************************************************************************/

/****  vv  COPY FROM HERE TILL THE END  vv  *****/
///// DO NOT EDIT BELOW
diag_log "ADF rpt: Init - executing: ADF_mod_createFootPatrol.sqf";
[
///// DO NOT EDIT ABOVE

/*
	Step 1:	Copy from (COPY FROM HERE) into your script for each air patrol you want to create.
	Step 2.	Determine a location where the foot patrol group will spawn. This can be a marker, an editor placed object, trigger, etc.
			The patrol start location is the same as the spawn location.
	Step 3.	Fill out below parameters
    Note: Don't worry about the many comments as the ARMA engine ignores comments.
*/

"myMarker",         // Spawn location. This is the location on the map where the patrol units will be created. The location can be a marker, trigger, object, etc:
                    // - "myMarker" use the name of the marker to span an airborne aircraft on the marker location. Markers are always a string ("")
                    // - myTrigger use the name of the trigger to spawn an airborne aircraft at the center of the trigger location. 
                    // - myObject use the name of an editor placed object to spawn the aircraft (airborne)

east,               // Side of the units. Can be east, west or independent

8,                  // Size of the group, number of AI units in the group. Can be 1-8. Default: 4

true,               // In case of a squad (8) units, should it be a weapons squad or rifle squad. Default: false
                    // - true for weapons squad
                    // - false for rifle squad

500,                // Number that represents the patrol Radius in meters from the patrol start position. Default: 250

6,                  // Number that represents the number of random patrol waypoints that should be created. (default: 4)

"MOVE",             // Waypoint type. (default: "MOVE"). More info: https://community.bistudio.com/wiki/Waypoint_types

"SAFE",             // Waypoint behavior. (default: "SAFE"). More info: https://community.bistudio.com/wiki/setWaypointBehaviour

"RED",              // Combat mode. (default: "RED"). More info: https://community.bistudio.com/wiki/setWaypointCombatMode

"LIMITED",          // Patrol speed. (default: "LIMITED"). More info: https://community.bistudio.com/wiki/waypointSpeed

"FILE",             // Patrol formation. (default: "COLUMN"). More info: https://community.bistudio.com/wiki/waypointFormation

5,                  // Waypoint completion radius. (default: 5). More info: https://community.bistudio.com/wiki/setWaypointCompletionRadius

false,              // Search nearby building? At the end of a waypoint, the leader of the patrol group can search the nearest building:
                    // - true. Search nearest building
                    // - false. Do not search the nearest building (default)

"",                 // String that represents a (custom) function (or code) that will be executed for EACH UNIT of the patrol group.
                    // E.g.: "my_fnc_redressInfantry"
                    // default: ""
                    
""                  // String that represents a (custom) function (or code) that will be executed on the group as a whole.
                    // E.g.: "my_fnc_setGroupID"  -or-  "ADF_fnc_groupSetSkill."
                    // default: ""
                    

///// DO NOT EDIT BELOW
] call ADF_fnc_createFootPatrol;