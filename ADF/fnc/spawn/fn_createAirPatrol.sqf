/*********************************************************************************
 _____ ____  _____
|  _  |    \|   __|
|     |  |  |   __|
|__|__|____/|__|
ARMA Mission Development Framework
ADF version: 2.26 / Jul 2020

Function: Create Air Patrol
Author: Whiztler
Script version: 1.21

File: fn_createAirPatrol.sqf
Diag: 276.367 ms
**********************************************************************************
ABOUT
This function creates a crewed aircaft that patrols a given position. You can
define number of waypoints, type of aircraft (or classname), patrol radius, etc.

You can (optional) pass two functions. One that is executed on group level and one
that is executed for each unit of the group. See 'OPTIONAL PARAMETERS' for more
information.

INSTRUCTIONS:
Execute from the server or headless client.

REQUIRED PARAMETERS:
0. Position:    Spawn position. Marker, Object or Trigger.

OPTIONAL PARAMETERS:
1. Position:    Patrol position. Marker, Object or Trigger.
                Default: "" (Spawn position will be used)
2: Side:        west, east or independent. Default: east
3: Int/Str:     Type of aircraft:
                - 1 - Unarmed transport helicopter (default)
                - 2 - Armed transport helicopter
                - 3 - Attack helicopter
                - 4 - Fighter jet
                - 5 - UAV
                "class" - class name of the aircraft (string)
				Array of classes. Random class will be picked.
4. Integer:     Patrol radius in meters from the patrol position. Default: 2500
5. Integer:     Altitude. The aircraft patrol altitude in meters. Default: 75
6. Integer:     Number of patrol waypoints. Default: 4
7. String:      Waypoint type. Info: https://community.bistudio.com/wiki/Waypoint_types (default = "MOVE")
8. String:      Waypoint behaviour. Info: https://community.bistudio.com/wiki/setWaypointBehaviour (default = "SAFE")
9. String:      Combat mode. Info: https://community.bistudio.com/wiki/setWaypointCombatMode (default = "YELLOW")
10. String:     Waypojnt speed. Info: https://community.bistudio.com/wiki/waypointSpeed (default = "LIMITED")
11. String:     Waypoint formation. Info: https://community.bistudio.com/wiki/waypointFormation (default = "COLUMN")
12. Integer:    Completion radius. Info: https://community.bistudio.com/wiki/setWaypointCompletionRadius (default = 250)
13. String:     Code to execute on each unit of the crew (e.g. a function).
                Default = "". Code is CALLED. Each unit of the group is passed (_this select 0) to the code/fnc.
14. String:     Code to execute on the crew aa a group (e.g. a function).
                Default = "". Code is CALLED. The group is passed (_this select 0) to the code/fnc.

EXAMPLES USAGE IN SCRIPT:
[_spawnPos, _patrolPos, west, 1, 2500, 100, 5, "MOVE", "SAFE", "RED", "LIMITED", "FILE", 250, "ADF_fnc_heliPilotAI", ""] call ADF_fnc_createAirPatrol;

EXAMPLES USAGE IN EDEN:
[getMarkerPos "myMarker", getMarkerPos "PatrolMarker", east, 2, 3500, 50, 6, "MOVE", "SAFE", "RED", "LIMITED", "FILE", 250, "", ""] call ADF_fnc_createAirPatrol;

DEFAULT/MINIMUM OPTIONS
["myMarker"] call ADF_fnc_createAirPatrol;

RETURNS:
Array:   0. new vehicle (Object).
         1. all crew (Array of Objects).
         2. vehicle's group (Group).
*********************************************************************************/

// Reporting
if (ADF_extRpt || {ADF_debug}) then {diag_log "ADF rpt: fnc - executing: ADF_fnc_createAirPatrol"};

// Init
private _diag_time = diag_tickTime;
params [
	["_positionSpawn", "", ["", [], objNull, grpNull]],
	["_positionPatrol", "", ["", [], objNull, grpNull]],
	["_side", east, [west]],
	["_aircraftType", 1, [0, "", []]],
	["_radius", 2500, [0]],
	["_altitude", 75, [0]],		
	["_waypoints", 4, [0]],
	["_wp_type", "MOVE", [""]],
	["_wp_behaviour", "SAFE", [""]],
	["_wp_combatMode", "YELLOW", [""]],
	["_wp_speed", "LIMITED", [""]],
	["_wp_formation", "DIAMOND", [""]],
	["_wp_complRadius", 150, [0]],
	["_code_1", "", [""]],
	["_code_2", "", [""]],
	["_vehicleClass", "", [""]],
	["_custom", false, [true]]
];

// Check valid vars
if (_code_1 != "") then {if (isNil _code_1) then {if ADF_debug then {[format ["ADF_fnc_createAirPatrol - incorrect code (%1) passed. Defaulted to ''.", _code_1]] call ADF_fnc_log;}; _code_1 = "";}};
if (_code_2 != "") then {if (isNil _code_2) then {if ADF_debug then {[format ["ADF_fnc_createAirPatrol - incorrect code (%1) passed. Defaulted to ''.", _code_2]] call ADF_fnc_log;}; _code_2 = "";}};

// Check the location position. If no patrol position was provided then assume the spawn position as the patrol position
if !(_positionSpawn isEqualType []) then {_positionSpawn = [_positionSpawn] call ADF_fnc_checkPosition};
if (_positionPatrol isEqualType "") then {if (_positionPatrol == "") then {_positionPatrol = _positionSpawn}};
if ((_aircraftType isEqualType "") || ((_aircraftType isEqualType []))) then {_custom = true;};

// Select the aircraft based on side, type, etc
if !_custom then {
	switch _side do {
		case west: {
			switch (_aircraftType) do {
				case 1: {_vehicleClass = selectRandom ["B_Heli_Light_01_F", "B_Heli_Transport_03_unarmed_F", "B_Heli_Transport_03_unarmed_green_F"]};
				case 2: {_vehicleClass = selectRandom ["B_Heli_Transport_01_F", "B_Heli_Transport_01_camo_F", "B_Heli_Transport_03_F", "B_Heli_Transport_03_black_F"]};
				case 3: {_vehicleClass = selectRandom ["B_Heli_Attack_01_F", "B_Heli_Light_01_armed_F"]};
				case 4: {_vehicleClass = "B_Plane_CAS_01_F"};
				case 5: {_vehicleClass = "B_UAV_02_CAS_F"};
			}
		};
		case independent: {
			switch (_aircraftType) do {
				case 1: {_vehicleClass = selectRandom ["I_Heli_light_03_unarmed_F", "I_Heli_Transport_02_F"]};
				case 2: {_vehicleClass = "I_Heli_light_03_F"};
				case 3: {_vehicleClass = "I_Heli_light_03_F"};
				case 4: {_vehicleClass = selectRandom ["I_Plane_Fighter_03_CAS_F", "I_Plane_Fighter_03_AA_F"]};
				case 5: {_vehicleClass = "I_UAV_02_CAS_F"};
			};

		};
		case east;
		default {
			switch (_aircraftType) do {		
				case 1: {_vehicleClass = selectRandom ["O_Heli_Light_02_unarmed_F", "O_Heli_Transport_04_F", "O_Heli_Transport_04_ammo_F", "O_Heli_Transport_04_bench_F", "O_Heli_Transport_04_box_F", "O_Heli_Transport_04_covered_F", "O_Heli_Transport_04_fuel_F", "O_Heli_Transport_04_medevac_F", "O_Heli_Transport_04_repair_F", "O_Heli_Transport_04_black_F"]};
				case 2: {_vehicleClass = selectRandom ["O_Heli_Light_02_F", "O_Heli_Light_02_v2_F"]};
				case 3: {_vehicleClass = selectRandom ["O_Heli_Attack_02_F", "O_Heli_Attack_02_black_F"]};
				case 4: {_vehicleClass = "O_Plane_CAS_02_F"};
				case 5: {_vehicleClass = "O_UAV_02_CAS_F"};
			};
		};		
	};
} else {
	if (_aircraftType isEqualType []) then {_vehicleClass = selectRandom _aircraftType;} else {_vehicleClass = _aircraftType;};	
};

// Create the vehicle and vehicle crew
private _group = createGroup _side;
_group deleteGroupWhenEmpty true;
private _vehicle = [_positionSpawn, (random 360), _vehicleClass, _group] call ADF_fnc_createCrewedVehicle;
(_vehicle # 0) setPosATL [_positionSpawn # 0, _positionSpawn # 1, _altitude];

// Execute custom passed code/function
if (_code_1 != "") then {
	// Each unit in the crew
	{[_x] call (call compile format ["%1", _code_1])} forEach units _group;
	// Debug reporting
	if ADF_debug then {[format ["ADF_fnc_createAirPatrol - call %1 for units of the aircraft crew: %2",_code_1,_group]] call ADF_fnc_log};
};

if (_code_2 != "") then {
	// Crew group
	[_group] call (call compile format ["%1", _code_2]);
	// Debug reporting
	if ADF_debug then {[format ["ADF_fnc_createAirPatrol - call %1 for crew (group): %2",_code_2,_group]] call ADF_fnc_log};	
};

// Execute the air patrol function
[_group, _positionPatrol, _radius, _altitude, _waypoints, _wp_type, _wp_behaviour, _wp_combatMode, _wp_speed, _wp_formation, _wp_complRadius] call ADF_fnc_airPatrol;
{_x allowDamage true} forEach units _group; // hack ADF 2.22

// Debug Diag reporting
if ADF_debug then {[format ["ADF_fnc_createAirPatrol - Diag time to execute function: %1",diag_tickTime - _diag_time]] call ADF_fnc_log};

// return the vehicle, crew and group array
_vehicle