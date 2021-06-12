/*********************************************************************************
 _____ ____  _____ 
|  _  |    \|   __|
|     |  |  |   __|
|__|__|____/|__|   
ARMA Mission Development Framework
ADF version: 2.26 / Jul 2020

Function: Create Crewed Vehicle
Author: Whiztler. Adapted from BIS_fnc_spawnVehicle
Script version: 1.16

File: fn_createCrewedVehicle.sqf
Diag: 15.625 ms
**********************************************************************************
This function creates a vehicle and vehicle crew according to the available
vehicle role and positions. If no group is passed the function will create a group
based on the side of given the vehicle class.

VehicleCrewAI will be applied to the vehicle crew so that they only abandon their
vehicles when it looses combat capability (too much damage).

You can (optional) pass two functions. One that is executed on group level and one
that is executed for each unit of the group. See 'OPTIONAL PARAMETERS' for more
information.

INSTRUCTIONS:
Execute from the server or headless client.

REQUIRED PARAMETERS:
0. Position:    Spawn position. Marker, object, trigger or position araay [x, y, z]
2. Integer:     Spawn direction (0-360)
3. String:      Vehicle classname

OPTIONAL PARAMETERS:
4. Group:       Group. if no group exists one will be created based on the side of
                the vehicle.
5. String:      Code to execute on each unit of the crew (e.g. a function).
                Default = "". Code is CALLED. Each unit of the group is passed
                (_this select 0) to the code/fnc.
6. String:      Code to execute on the crew aa a group (e.g. a function).
                Default = "". Code is CALLED. The group is passed
                (_this select 0) to the code/fnc.  
7. Bool:        Force precise position:
                - true (default)
                - false
8. Bool:        Apply vehicle crew aggressiveness setting (false for convoys and such):
                - true (default)
                - false
9. Bool:        Set skill of crew
                - true (default)
                - false			

EXAMPLES USAGE IN SCRIPT:
[_markerName, 90, "O_MBT_02_cannon_F", _grp, "", "", true, true] call ADF_fnc_createCrewedVehicle;

EXAMPLES USAGE IN EDEN:
["SpawnMarker", 90, "O_MBT_02_cannon_F", myGroupName, "", "", true, true] call ADF_fnc_createCrewedVehicle;

DEFAULT/MINIMUM OPTIONS
["SpawnMarker", 45, "O_MBT_02_cannon_F", _grp] call ADF_fnc_createCrewedVehicle;

RETURNS:
Array:          0. new vehicle (Object).
                1. all crew (Array of Objects).
                2. vehicle's group (Group).
*********************************************************************************/

// Reporting
if (ADF_extRpt || {ADF_debug}) then {diag_log "ADF rpt: fnc - executing: ADF_fnc_createCrewedVehicle"};

// Init
params [
	["_position", "", ["", [], objNull, grpNull]], 
	["_direction", 0, [0]], 
	["_vehicleClass", "", [""]], 
	["_group", grpNull, [grpNull]], 
	["_code_1", "", [""]], 
	["_code_2", "", [""]], 			
	["_spotPos", true, [false]], 
	["_crewBehavior", true, [false]],
	["_setSkill", true, [false]],
	["_vehicle", objNull, [objNull]]
];

// Check valid vars
if (_code_1 != "") then {if (isNil _code_1) then {if ADF_debug then {[format ["ADF_fnc_createCrewedVehicle - incorrect code (%1) passed. Defaulted to ''.", _code_1]] call ADF_fnc_log;}; _code_1 = "";}};
if (_code_2 != "") then {if (isNil _code_2) then {if ADF_debug then {[format ["ADF_fnc_createCrewedVehicle - incorrect code (%1) passed. Defaulted to ''.", _code_2]] call ADF_fnc_log;}; _code_2 = "";}};

// Check the location position
_position = [_position] call ADF_fnc_checkPosition;

// Check if a valid group was passed. If not, create a group based on the side of the vehicle
if (_group isEqualTo grpNull) then {	
	switch (getNumber(configFile >> "CfgVehicles" >> _vehicleClass >> "side")) do {
		case 0 : {_group = createGroup east};
		case 1 : {_group = createGroup west};
		case 2 : {_group = createGroup independent};
		case 3 : {_group = createGroup civilian};
	};	
};

// Determine vehicle
private _vehicleConfigClass = getText(configFile >> "CfgVehicles" >> _vehicleClass >> "simulation");

switch (toLowerANSI _vehicleConfigClass) do {
	case "soldier": {_vehicle = _group createUnit [_vehicleClass, _position, [], 0, "NONE"]};
	case "airplanex";
	case "helicopterrtd";
	case "helicopterx": {if (count _position == 2) then {_position set [2, 0]}; _position = [_position # 0, _position # 1, (_position # 2) + 50]; _vehicle = createVehicle [_vehicleClass, _position, [], 0, "FLY"];}; //Spawn airborne
	default {_vehicle = createVehicle [_vehicleClass, _position, [], 0, "CAN_COLLIDE"]};
};

// Apply spawn direction and positioning.
_vehicle setDir _direction;
if (_spotPos) then {_vehicle setPos _position};

// Apply velocity for aircraft
if (_vehicleConfigClass == "airplanex") then {_vehicle setVelocity [100 * (sin _direction), 100 * (cos _direction), 0]};

// Create the crew and assign them to the vehicle.
createVehicleCrew _vehicle;
private _crew = crew _vehicle;
_crew joinSilent _group;
_group addVehicle _vehicle;

// Set the vehicle crew AI
if _crewBehavior then {[_vehicle, "novice", false] call ADF_fnc_vehicleCrewAI;};

// Unload cargo units when in combat
_vehicle setUnloadInCombat [true, false];

// Execute custom passed code/function
if (_code_1 != "") then {
	// Each unit in the crew
	{[_x] call (call compile format ["%1", _code_1])} forEach units _group;
	// Debug reporting
	if ADF_debug then {[format ["ADF_fnc_createCrewedVehicle - call %1 for units of group: %2", _code_1, _group]] call ADF_fnc_log};
};

if (_code_2 != "") then {
	// Crew
	[_group] call (call compile format ["%1", _code_2]);
	// Debug reporting
	if ADF_debug then {[format ["ADF_fnc_createCrewedVehicle - call %1 for the vessel crew: %2", _code_2, _group]] call ADF_fnc_log};	
};

// Add the vehicle + crew to Zeus
if isServer then {
	[_vehicle] call ADF_fnc_addToCurator;
} else {
	[_vehicle] remoteExecCall ["ADF_fnc_addToCurator", 2];
};	

[_vehicle, _crew, _group]