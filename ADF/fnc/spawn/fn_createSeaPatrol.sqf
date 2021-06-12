/*********************************************************************************
 _____ ____  _____ 
|  _  |    \|   __|
|     |  |  |   __|
|__|__|____/|__|   
ARMA Mission Development Framework
ADF version: 2.26 / Jul 2020

Function: Create Sea Patrol
Author: Whiztler
Script version: 1.13

File: fn_createSeaPatrol.sqf
**********************************************************************************
ABOUT:
This function creates a crewed boat that patrols a given position. The module
creates water waypoints in a given radius. You can define which type of ship.

You can (optional) pass two functions. One that is executed on group level and one
that is executed for each unit of the group. See 'OPTIONAL PARAMETERS' for more
information.

INSTRUCTIONS:
Execute from the server or headless client.

REQUIRED PARAMETERS:
0: Position:    Spawn position. Marker, object, trigger or position array [x,y,z]

OPTIONAL PARAMETERS:
1. Position:    Patrol position. Marker, object, trigger or position array [x,y,z]
                Default: "" (Spawn position will be used)
2. Side:        west, east or independent. Default: east
3. Number       Type of vessel:
                - 1 - speedboat mini-gun (default)
                - 2 - assault boat (RHIB)
4. Bool:        Gunner(s):
                - True - driver + gunner(s)/crew (default)
                - false - driver only
5. Integer:     Patrol Radius in meters from the spawn position. Default: 1000
6. Integer:     Number of patrol waypoints. Default: 4
7. String:      Waypoint type. Info: https://community.bistudio.com/wiki/Waypoint_types (default = "MOVE")
8. String:      Waypoint behavior. Info: https://community.bistudio.com/wiki/setWaypointBehaviour (default = "SAFE")
9. String:      Combat mode. Info: https://community.bistudio.com/wiki/setWaypointCombatMode (default = "YELLOW")
10. String:     Waypoint speed. Info: https://community.bistudio.com/wiki/waypointSpeed (default = "LIMITED")
11. String:     Waypoint formation. Info: https://community.bistudio.com/wiki/waypointFormation (default = "COLUMN")
12. Integer:    Completion radius. Info: https://community.bistudio.com/wiki/setWaypointCompletionRadius (default = 25)
13. String:     Code to execute on each unit of the crew (e.g. a function).
                Default = "". Code is CALLED. Each unit of the group is passed
                (_this select 0) to the code/fnc.
14. String:     Code to execute on the crew aa a group (e.g. a function).
                Default = "". Code is CALLED. The group is passed
                (_this select 0) to the code/fnc.
15. Array:	   Waypoint time out. Default: "[0,0,0]"
                Info: https://community.bistudio.com/wiki/setWaypointTimeout				

EXAMPLES USAGE IN SCRIPT:
[_spawnPos, PatrolPos, west, 1, false, 300, 5, "MOVE", "SAFE", "RED", "LIMITED", "FILE", 5, "", ""] call ADF_fnc_createSeaPatrol;

EXAMPLES USAGE IN EDEN:
["spawnMarker", "PatrolMarker", east, 2, true, 500, 6, "MOVE", "SAFE", "RED", "LIMITED", "FILE", 5, "", "fnc_myFunction", [5,10,15]] call ADF_fnc_createSeaPatrol;

DEFAULT/MINIMUM OPTIONS
[_spawnPos] call ADF_fnc_createSeaPatrol;

RETURNS:
Object
*********************************************************************************/

// Reporting
if (ADF_extRpt || {ADF_debug}) then {diag_log "ADF rpt: fnc - executing: ADF_fnc_createSeaPatrol"};

// Init
private _diag_time = diag_tickTime;
params [
	["_positionSpawn", "", ["", [], objNull, grpNull]], 
	["_positionPatrol", "", ["", [], objNull, grpNull]], 
	["_side", east, [west]], 
	["_vehicleType", 1, [0]], 
	["_vehicleGunner", true, [true]], 
	["_radius", 1000, [0]], 
	["_waypoints", 4, [0]], 
	["_wp_type", "MOVE", [""]], 
	["_wp_behaviour", "SAFE", [""]], 
	["_wp_combatMode", "YELLOW", [""]], 
	["_wp_speed", "LIMITED", [""]], 
	["_wp_formation", "COLUMN", [""]], 
	["_wp_complRadius", 25, [0]], 
	["_code_1", "", [""]], 
	["_code_2", "", [""]],
	["_wp_timeOut", [0,0,0], [[]], [3]],
	["_vehicleClass", "", [""]],
	["_crewClass", "", [""]]
];

// Check valid vars
if !(_side in [west, east, independent]) exitWith {[format ["ADF_fnc_createSeaPatrol - %1  side passed. Exiting", _side], true] call ADF_fnc_log; grpNull};
if (_code_1 != "") then {if (isNil _code_1) then {if ADF_debug then {[format ["ADF_fnc_createSeaPatrol - incorrect code (%1) passed. Defaulted to ''.", _code_1]] call ADF_fnc_log;}; _code_1 = "";}};
if (_code_2 != "") then {if (isNil _code_2) then {if ADF_debug then {[format ["ADF_fnc_createSeaPatrol - incorrect code (%1) passed. Defaulted to ''.", _code_2]] call ADF_fnc_log;}; _code_2 = "";}};
if (_vehicleType > 2 || {_vehicleType < 1}) then {_vehicleType = 2;};
if (_vehicleType == 2) then {_vehicleGunner = false};

// Check the location position. If no patrol position was provided then assume the spawn position as the patrol position
if !(_positionSpawn isEqualType []) then {_positionSpawn = [_positionSpawn] call ADF_fnc_checkPosition};
if (_positionPatrol isEqualType "") then {if (_positionPatrol == "") then {_positionPatrol = _positionSpawn}};

// Select vessel and crew based on the determined side
if (_side == west) then {
	if (_vehicleType == 1) then {_vehicleClass = "B_Boat_Armed_01_minigun_F"} else {_vehicleClass = "B_Boat_Transport_01_F";};
	_crewClass = "B_Soldier_F";
};
if (_side == east) then {
	if (_vehicleType == 1) then {_vehicleClass = "O_Boat_Armed_01_hmg_F"} else {_vehicleClass = "O_Boat_Transport_01_F";};
	_crewClass = "O_Soldier_F";
};
if (_side == independent) then {
	if (_vehicleType == 1) then {_vehicleClass = "I_Boat_Armed_01_minigun_F"} else {_vehicleClass = "I_Boat_Transport_01_F";};
	_crewClass = "I_Soldier_F";
};

// Create the vessel
private _vehicle = createVehicle [_vehicleClass, [0,0,0], [], 0, "CAN_COLLIDE"];
_vehicle setPos _positionSpawn;

//Create the boat crew and assign to the position with the vessel
private _group = createGroup _side;
private _unit = _group createUnit [_crewClass, _positionSpawn, [], 0, "CAN_COLLIDE"];
_unit moveInDriver _vehicle;
_group deleteGroupWhenEmpty true;

if (_vehicleGunner) then {
	private _unit = _group createUnit [_crewClass, _positionSpawn, [], 0, "CAN_COLLIDE"];
	_unit setRank "LIEUTENANT";
	_unit moveInCommander _vehicle;
	private _unit = _group createUnit [_crewClass, _positionSpawn, [], 0, "CAN_COLLIDE"];
	_unit moveInGunner _vehicle;
} else {
	private "_i";
	for "_i" from 1 to 3 do {
		private _unit = _group createUnit [_crewClass, _positionSpawn, [], 0, "CAN_COLLIDE"]; _unit moveInCargo _vehicle;
	};	
};

// Execute custom passed code/function
if (_code_1 != "") then {
	// Each unit in the crew
	{[_x] call (call compile format ["%1", _code_1])} forEach units _group;
	// Debug reporting
	if ADF_debug then {[format ["ADF_fnc_createSeaPatrol - call %1 for units of group: %2",_code_1,_group]] call ADF_fnc_log};
};

if (_code_2 != "") then {
	// Crew
	[_group] call (call compile format ["%1", _code_2]);
	// Debug reporting
	if ADF_debug then {[format ["ADF_fnc_createSeaPatrol - call %1 for the vessel crew: %2",_code_2,_group]] call ADF_fnc_log};	
};

// Create the sea patrol
[_group, _positionPatrol, _radius, _waypoints, _wp_type, _wp_behaviour, _wp_combatMode, _wp_speed , _wp_formation , _wp_complRadius, _wp_timeOut] call ADF_fnc_seaPatrol;
{_x allowDamage true} forEach units _group; // hack ADF 2.22

// Add the vessel + crew to Zeus
if isServer then {
	[_vehicle] call ADF_fnc_addToCurator;
} else {
	[_vehicle] remoteExecCall ["ADF_fnc_addToCurator", 2];
};	

// Debug Diag reporting
if ADF_debug then {[format ["ADF_fnc_createSeaPatrol - Diag time to execute function: %1", diag_tickTime - _diag_time]] call ADF_fnc_log};

// Return the vessel
_vehicle