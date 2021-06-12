/*********************************************************************************
 _____ ____  _____ 
|  _  |    \|   __|
|     |  |  |   __|
|__|__|____/|__|   
ARMA Mission Development Framework
ADF version: 2.26 / Jul 2020

Function: Create Vehicle Patrol
Author: Whiztler
Script version: 1.18

File: fn_createVehiclePatrol.sqf
Diag: 14.88281 ms
**********************************************************************************
ABOUT:
This function creates a vehicle and a vehicle crew and sends the vehicle out on
patrol. The function creates waypoints on roads in a predefined radius.

CUSTOMIZATION:
- Vehicle side (east, west, independent)
- Which type of vehicle (1: random truck, 2: unarmed MRAP, 3: armed MRAP,
  4: random APC, 5: random armored vehicle).
- Nr of waypoint, radius and other patrol/waypoint information.
- You can (optional) pass two functions. One that is executed on group level and
  one that is executed for each unit of the group. See 'OPTIONAL PARAMETERS' for
  more information.

INSTRUCTIONS:
Make sure the spawn position is close to roads (or on a road) and roads are within
the radius. Keep the radius below 1500 else the script might take a long time to
search for suitable locations.
Execute from the server or headless client.

REQUIRED PARAMETERS:
0. Position:    Spawn position. Marker, object, trigger or position array [x,y,z]

OPTIONAL PARAMETERS:
1. Position:    Patrol position.Marker, object, trigger or position array [x,y,z]
                Default: "" (Spawn position ill be used)
2: Side:        west, east or independent. Default: east
3: Int/Str:     Type of vehicle:
                - 1 - Random Transport truck (default)
                - 2 - Random Unarmed MRAP/Car
                - 3 - Random Armed MRAP/Car
                - 4 - Random APC
                - 5 - Random Armored
			   In case of a string then the vehicle class will be used.
4: Integer:     Patrol radius in meters from the spawn position.  (default = 750)
5: Integer:     Number of patrol waypoints (default = 4)
6. String:      Waypoint type. Info: https://community.bistudio.com/wiki/Waypoint_types (default = "MOVE")
7. String:      Waypoint behavior. Info: https://community.bistudio.com/wiki/setWaypointBehaviour (default = "SAFE")
8. String:      Combat mode. Info: https://community.bistudio.com/wiki/setWaypointCombatMode (default = "YELLOW")
9. String:      Waypoint speed. Info: https://community.bistudio.com/wiki/waypointSpeed (default = "LIMITED")
10. Integer:    Completion radius. Info: https://community.bistudio.com/wiki/setWaypointCompletionRadius (default = 25)
11. String:     Code to execute on each unit of the crew (e.g. a function).
                Default = "". Code is CALLED. Each unit of the group is passed
                (_this select 0) to the code/fnc.
12. String:     Code to execute on the crew as a group (e.g. a function).
                Default = "". Code is CALLED. The group is passed
                (_this select 0) to the code/fnc.
13. Array:      Waypoint time out. Default: "[0,0,0]"
                Info: https://community.bistudio.com/wiki/setWaypointTimeout

EXAMPLES USAGE IN SCRIPT:
["SpawnMarker", "PatrolMarker", east, 4, 800, 5, "MOVE", "SAFE", "RED", "LIMITED", 25, "myFunction", "anotherFunction"] call ADF_fnc_createVehiclePatrol;
["SpawnMarker", "PatrolMarker", east, "O_G_Offroad_01_armed_F", 800, 5, "MOVE", "SAFE", "RED", "LIMITED", 25, "myFunction", "anotherFunction", [5,10,15]] call ADF_fnc_createVehiclePatrol;

EXAMPLES USAGE IN EDEN:
["SpawnMarker", "PatrolMarker", west] call ADF_fnc_createVehiclePatrol;

DEFAULT/MINIMUM OPTIONS
["SpawnMarker"] call ADF_fnc_createVehiclePatrol;

RETURNS:
Array:          0. new vehicle (Object).
                1. all crew (Array of Objects).
                2. vehicle's group (Group).
*********************************************************************************/
// Reporting
if (ADF_extRpt || {ADF_debug}) then {diag_log "ADF rpt: fnc - executing: ADF_fnc_createVehiclePatrol"};

private _diag_time = diag_tickTime;

// Init
params [
	["_positionSpawn", "", ["", [], objNull, grpNull]],
	["_positionPatrol", "", ["", [], objNull, grpNull]],
	["_side", east, [west]],
	["_vehicleType", 1, [0, ""]],
	["_radius", 1000, [0]],
	["_waypoints", 4, [0]],
	["_wp_type", "MOVE", [""]],
	["_wp_behaviour", "UNCHANGED", [""]],
	["_wp_combatMode", "YELLOW", [""]],
	["_wp_speed", "NORMAL", [""]],
	["_wp_complRadius", 15, [0]],
	["_code_1", "", [""]],
	["_code_2", "", [""]],
	["_wp_timeOut", [0, 0, 0], [[]], [3]],
	["_vehicleClass", "", [""]]
];

// Check valid vars
if !(_side in [west, east, independent]) exitWith {[format ["ADF_fnc_createVehiclePatrol - %1  side passed. Exiting", _side], true] call ADF_fnc_log; objNull};
if (_code_1 != "") then {if (isNil _code_1) then {if ADF_debug then {[format ["ADF_fnc_createVehiclePatrol - incorrect code (%1) passed. Defaulted to ''.", _code_1]] call ADF_fnc_log;}; _code_1 = "";}};
if (_code_2 != "") then {if (isNil _code_2) then {if ADF_debug then {[format ["ADF_fnc_createVehiclePatrol - incorrect code (%1) passed. Defaulted to ''.", _code_2]] call ADF_fnc_log;}; _code_2 = "";}};
if !(_vehicleType isEqualType "") then {if (_vehicleType > 5 || {_vehicleType < 1}) then {_vehicleType = 1;}};

// Determine vehicle based on side and type
if (_vehicleType isEqualType 0) then {
	if (_side == west) then {
		switch _vehicleType do {
			case 1: {_vehicleClass = selectRandom ["B_Truck_01_transport_F", "B_Truck_01_covered_F", "B_Truck_01_mover_F", "B_Truck_01_box_F", "B_Truck_01_Repair_F", "B_Truck_01_ammo_F", "B_Truck_01_fuel_F", "B_Truck_01_medical_F"]};
			case 2: {_vehicleClass = selectRandom ["B_MRAP_01_F", "B_Quadbike_01_F"]};
			case 3: {_vehicleClass = selectRandom ["B_MRAP_01_gmg_F", "B_MRAP_01_hmg_F"]};
			case 4: {_vehicleClass = selectRandom ["B_APC_Tracked_01_rcws_F", "B_APC_Tracked_01_CRV_F", "B_APC_Wheeled_01_cannon_F"]};
			case 5: {_vehicleClass = selectRandom ["B_APC_Tracked_01_AA_F", "B_MBT_01_cannon_F", "B_MBT_01_arty_F", "B_MBT_01_TUSK_F"]};
		}
	};
	if (_side == east) then {
		switch (_vehicleType) do {		
			case 1: {_vehicleClass = selectRandom ["O_Truck_02_covered_F", "O_Truck_02_transport_F", "O_Truck_03_transport_F", "O_Truck_03_covered_F", "O_Truck_03_repair_F", "O_Truck_03_ammo_F", "O_Truck_03_fuel_F", "O_Truck_03_medical_F", "O_Truck_03_device_F", "O_Truck_02_box_F", "O_Truck_02_Ammo_F", "O_Truck_02_fuel_F", "O_Truck_02_covered_F"]};
			case 2: {_vehicleClass = selectRandom ["O_MRAP_02_F", "O_Quadbike_01_F"]};
			case 3: {_vehicleClass = selectRandom ["O_MRAP_02_hmg_F", "O_MRAP_02_gmg_F"]};
			case 4: {_vehicleClass = selectRandom ["O_APC_Wheeled_02_rcws_F", "O_APC_Tracked_02_cannon_F"]};
			case 5: {_vehicleClass = selectRandom ["O_APC_Tracked_02_AA_F", "O_MBT_02_cannon_F", "O_MBT_02_arty_F"]};
		};
	};
	if (_side == independent) then {
		switch (_vehicleType) do {
			case 1: {_vehicleClass = selectRandom ["I_Truck_02_covered_F", "I_Truck_02_transport_F", "I_Truck_02_ammo_F", "I_Truck_02_box_F", "I_Truck_02_medical_F", "I_Truck_02_fuel_F"]};
			case 2: {_vehicleClass = selectRandom ["I_MRAP_03_F", "I_Quadbike_01_F"]};
			case 3: {_vehicleClass = selectRandom ["I_MRAP_03_hmg_F", "I_MRAP_03_gmg_F"]};
			case 4: {_vehicleClass = "I_APC_Wheeled_03_cannon_F"};
			case 5: {_vehicleClass = "I_MBT_03_cannon_F"};
		};
	};
} else {
	_vehicleClass = _vehicleType;
};

//Create the crew and determine the spawn direction
private _group = createGroup _side;
private _direction = if (_positionSpawn isEqualType "") then {markerDir _positionSpawn} else {random 360};
_group deleteGroupWhenEmpty true;

// Check the location position. If no patrol position was provided then assume the spawn position as the patrol position
_positionSpawn = [_positionSpawn] call ADF_fnc_checkPosition;
if (_positionPatrol isEqualType "") then {
	if (_positionPatrol == "") then {
		_positionPatrol = _positionSpawn
	} else {
		_positionPatrol = [_positionPatrol] call ADF_fnc_checkPosition;
	};
} else {
	_positionPatrol = [_positionPatrol] call ADF_fnc_checkPosition;
};

// create the vehicle
private _vehicle = [_positionSpawn, _direction, _vehicleClass, _group] call ADF_fnc_createCrewedVehicle;
private _combatVehicle = if (!((allTurrets [_vehicle # 0, false]) isEqualTo [])) then {true} else {false};

// Execute custom passed code/function
if (_code_1 != "") then {
	// Each unit in the crew
	{[_x] call (call compile format ["%1", _code_1])} forEach units _group;
	// Debug reporting
	if ADF_debug then {[format ["ADF_fnc_createVehiclePatrol - call %1 for units of group: %2",_code_1,_group]] call ADF_fnc_log};
};

if (_code_2 != "") then {
	// Crew
	[_group] call (call compile format ["%1", _code_2]);
	// Debug reporting
	if ADF_debug then {[format ["ADF_fnc_createVehiclePatrol - call %1 for group: %2",_code_2,_group]] call ADF_fnc_log};	
};

// Create the vehicle patrol
[_group, _positionPatrol, _radius, _waypoints, _wp_type, _wp_behaviour, _wp_combatMode, _wp_speed, _wp_complRadius, _wp_timeOut] call ADF_fnc_vehiclePatrol;

if _combatVehicle then {[_group] spawn ADF_fnc_waypointCombat}; // v.1.17
{_x allowDamage true} forEach units _group; // hack ADF 2.22

// Debug Diag reporting
if ADF_debug then {[format ["ADF_fnc_createVehiclePatrol - Diag time to execute function: %1",diag_tickTime - _diag_time]] call ADF_fnc_log};

// Return the vehicle array
_vehicle