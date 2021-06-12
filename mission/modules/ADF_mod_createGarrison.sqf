/*********************************************************************************
 _____ ____  _____ 
|  _  |    \|   __|
|     |  |  |   __|
|__|__|____/|__|   
ARMA Mission Development Framework
ADF version: 2.26 / Jul 2020

Module: Create Garrison
Author: Whiztler
Module version: 1.02

File: ADF_mod_createGarrison.sqf
**********************************************************************************
This module creates a group (2, 4 or 8 pax) that will garrison/militarize a given
area. The units will first populate all available empty turrets (static weapons
and vehicle turrets).If you do not want a turret to be populated than lock the
turret in the editor (lock, NOT lock player).

Units will look for buildings that have predefined (ARMA 3 engine) garrison
positions. There is a 75% chance they will populate the highest (incl roof)
positions first. 
Once all the garrison positions have been populated, the units that could not
get a garrison position will patrol the area (same radius). You can order the
patrol units to search nearby houses (default is false).
You can execute (optional) two functions. One for the group and one for each unit
of the group.

INSTRUCTIONS:
Execute the module on the SERVER or HC only!
*********************************************************************************/

/****  vv  COPY FROM HERE TILL THE END  vv  *****/
///// DO NOT EDIT BELOW
diag_log "ADF rpt: Init - executing: ADF_mod_createGarrison.sqf";
[
///// DO NOT EDIT ABOVE

/*
	Step 1.	Copy from (COPY FROM HERE) into your script for each garrison group you want to create.
	Step 2.	Determine a location where the garrison group will spawn. This can be a marker, an editor placed object, trigger, etc.
			The garrison location is the same as the spawn location. So choose a spawn location near buildings.
	Step 3.	Fill out below parameters
    Note: Don't worry about the many comments as the ARMA engine ignores comments.
*/

"myMarker",  // Spawn location. This is the location on the map where the garrison units will be created. The location can be a marker, trigger, object, etc:

east,         // Side of the units. Can be east, west or independent

4,           // Size of the group, number of AI units in the group. Can be 1-8. Default: 4

false,        // In case of a squad (8) units, should it be a weapons squad or rifle squad. Default: false
             // - true for weapons squad
             // - false for rifle squad

100,         // Garrison radius in meter. The distance from the spawn position where AI units will look for buildings/static weapons to populate. Default: 50

false,        // Search nearby building? Should patrol units that have not been garrisoned search buildings on their patrol route?
             // - true. Search nearest building
             // - false. Do not search the nearest building (default)

"",          // String that represents a (custom) function (or code) that will be executed for EACH UNIT of the garrison group.
             // E.g.: "my_fnc_redressInfantry"
             // default: ""
                    
"",          // String that represents a (custom) function (or code) that will be executed on the group as a whole.
             // E.g.: "my_fnc_setGroupID"  -or-  "ADF_fnc_groupSetSkill."
             // default: ""
			 
-1,          // Maximum building occupancy. The maximum number of AI's per building. Use -1 for no maximum.
             // default: -1
			 
true          // Roof top and top floor positions get prioritized for garrison? True or False.
              // default: true

///// DO NOT EDIT BELOW
] call ADF_fnc_createGarrison;