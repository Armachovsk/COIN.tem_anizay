/*********************************************************************************
 _____ ____  _____ 
|  _  |    \|   __|
|     |  |  |   __|
|__|__|____/|__|   
ARMA Mission Development Framework
ADF version: 2.26 / Jul 2020

Function: Create AO
Author: Whiztler
Script version: 1.16

File: fn_createAO.sqf
**********************************************************************************
ABOUT
This function creates (populates) a given AO (position, markersize). The amount of
units/vehicles depend on the size of the ao (size of the marker). Infantry units
garrison or go on patrol (if no buildings near). Vehicles go on patrol.
NOTE THAT SPAWNING A LARGE AO CAN TAKE UP TO 5 MINUTES!

What the function spawns is based on the size of the marker:
< 100 meters        : 8 x inf, 1 vehicle
100  - 250 meters   : 16 x inf, 1 vehicle
250  - 500 meters   : 24 x inf, 2 x vehicle, 1 x apc
500  - 750 meters   : 32 x inf, 3 x vehicle, 2 x apc, 1 x armor
750  - 1000 meters  : 40 x inf, 5 x vehicle, 2 x apc, 2 x armor
1000 - 2000 meters  : 48 x inf, 5 x vehicle, 3 x apc, 2 x armor, 1 helicopter
2000 - 3000 meters  : 80 x inf, 7 x vehicle, 4 x apc, 3 x armor, 1 helicopter
> 3000 meters       : 112 x inf, 8 x vehicle, 5 x apc, 3 x armor, 1 helicopter

You can (optional) pass two functions. One that is executed on group level and one
that is executed for each unit of the group. See 'OPTIONAL PARAMETERS' for more
information.

INSTRUCTIONS:
Execute (spawn!) from the server or headless client.

REQUIRED PARAMETERS:
0. String:  Spawn marker name. Size of marker determines AO size.

OPTIONAL PARAMETERS:
1. Side:        west, east or independent. Default: east
2. Bool:        make AO maker transparent (invisible to players).
                - true: make transparent  (default)
                - false: leave as is
3. Bool:        Infantry units search nearby buildings?
                - true: search buildings
                - false: do not search buildings (default)
4. Bool:        Random IED's in the AO?
                - true: place random IED's
                - false: Do not place random IED's (default)
5. String:      Code to execute on each unit of the crew (e.g. a function).
                Default = "". Code is CALLED. Each unit of the group is passed
                (_this select 0) to the code/fnc.
6. String:      Code to execute on the crew aa a group (e.g. a function).
                Default = "". Code is CALLED. The group is passed
                (_this select 0) to the code/fnc.         

EXAMPLES USAGE IN SCRIPT:
[_AO1marker, independent, false, true, true, "", "myFunction"] spawn ADF_fnc_createAO;

EXAMPLES USAGE IN EDEN:
0 = ["myAOmarker", east, false, true, true, "", "myFunction"] spawn ADF_fnc_createAO;

DEFAULT/MINIMUM OPTIONS
["myAOmarker"] spawn ADF_fnc_createAO;

RETURNS:
Bool (success flag)
*********************************************************************************/

// Reporting
if (ADF_extRpt || {ADF_debug}) then {diag_log "ADF rpt: fnc - executing: ADF_fnc_createAO"};

// Init
private _dt = diag_tickTime;
params [
	["_aoMarker", "", [""]],
	["_side", east, [west]],
	["_markerTransparent", true, [false]],
	["_searchBuildings", false, [true]],
	["_ied", false, [true]],
	["_code_1", "", [""]],
	["_code_2", "", [""]],
	["_enemy_Infantry", 0, [0]],
	["_enemy_LightVehicle", 0, [0]],
	["_enemy_APC", 0, [0]],
	["_enemy_armor", 0, [0]],
	["_enemy_helicopter", 0, [0]],
	["_enemy_ied", 0, [0]]
];

// Check valid vars
if !(_aoMarker in allMapMarkers) exitWith {[format ["ADF_fnc_createAO - %1 does not appear to be a valid AO marker. Exiting", _aoMarker], true] call ADF_fnc_log; false};
if (_code_1 != "") then {if (isNil _code_1) then {if ADF_debug then {[format ["ADF_fnc_createAO - incorrect code (%1) passed. Defaulted to ''.", _code_1]] call ADF_fnc_log;}; _code_1 = "";}};
if (_code_2 != "") then {if (isNil _code_2) then {if ADF_debug then {[format ["ADF_fnc_createAO - incorrect code (%1) passed. Defaulted to ''.", _code_2]] call ADF_fnc_log;}; _code_2 = "";}};

// Init vars
if _markerTransparent then {_aoMarker setMarkerAlpha 0};
private _radius = (((getMarkerSize _aoMarker) # 0) + ((getMarkerSize _aoMarker) # 1)) / 2;
private _roadRadius = _radius;
private _position = getMarkerPos _aoMarker;

// Set spawn size based on marker size
call {
	if (_radius > 2999) exitWith {_enemy_Infantry = 14; _enemy_LightVehicle = 8; _enemy_APC = 5; _enemy_armor = 3; _enemy_helicopter = 1; _enemy_ied = 12};
	if (_radius > 1999) exitWith {_enemy_Infantry = 10; _enemy_LightVehicle = 7; _enemy_APC = 4; _enemy_armor = 3; _enemy_helicopter = 1; _enemy_ied = 8};
	if (_radius > 999) exitWith {_enemy_Infantry = 6; _enemy_LightVehicle = 5; _enemy_APC = 3; _enemy_armor = 2; _enemy_helicopter = 1; _enemy_ied = 5};
	if (_radius > 750) exitWith {_enemy_Infantry = 5; _enemy_LightVehicle = 5; _enemy_APC = 2; _enemy_armor = 2; _enemy_helicopter = 0; _enemy_ied = 4};
	if (_radius > 500) exitWith {_enemy_Infantry = 4; _enemy_LightVehicle = 3; _enemy_APC = 2; _enemy_armor = 1; _enemy_helicopter = 0; _enemy_ied = 3};
	if (_radius > 250) exitWith {_enemy_Infantry = 3; _enemy_LightVehicle = 2; _enemy_APC = 1; _enemy_armor = 0; _enemy_helicopter = 0; _enemy_ied = 3};
	if (_radius > 100) exitWith {_enemy_Infantry = 2; _enemy_LightVehicle = 1; _enemy_APC = 0; _enemy_armor = 0; _enemy_helicopter = 0; _enemy_ied = 1};
	// < 100 m
	_enemy_Infantry = 1; _enemy_LightVehicle = 1; _enemy_APC = 0; _enemy_armor = 0; _enemy_helicopter = 0; _enemy_ied = 1;
};
	
// FOOT: Garrison & patrol
if (_enemy_Infantry > 1) then {
	for "_i" from 1 to _enemy_Infantry do {
		private _waypoints = if (random 1 > 0.60) then {true} else {false};
		// half patrol / half garrison
		private _spawnPosition = [_position, _radius, random 360] call ADF_fnc_randomPos;
		[_spawnPosition, _side, 4, true, (_radius/2), _searchBuildings, _code_1, _code_2] call ADF_fnc_createGarrison;
		[_position, _side, 4, _waypoints, _radius, 4, "MOVE", "SAFE", "RED", "LIMITED", "FILE", 5, _searchBuildings, _code_1, _code_2] call ADF_fnc_createFootPatrol;
	};
} else {
	if (_enemy_Infantry == 0) exitWith {};
	private _spawnPosition = [_position, _radius, random 360] call ADF_fnc_randomPos;
	[_spawnPosition, _side, 8, true, (_radius/4), _searchBuildings, _code_1, _code_2] call ADF_fnc_createGarrison;
};

// ROAD: Transport vehicles & IFV's
if (_enemy_LightVehicle > 1) then {
	for "_i" from 1 to _enemy_LightVehicle do {
		private _type = selectRandom [1, 2, 3];
		
		// Get a random spawn position on a road with the AO		
		for "_i" from 1 to 4 do {
			private _searchPosition = [_position, _radius, random 360] call ADF_fnc_randomPos;
			_rd = [_searchPosition, _roadRadius] call ADF_fnc_roadPos;
			// If a suitable position has been found then exit else continue looking
			if (isOnRoad _rd) exitWith {_position = _rd};
			_roadRadius = _roadRadius + (_radius / 10);
			if (_i == 3) then {_roadRadius = _roadRadius + (_radius / 7)};
			if (_i == 4) then {_position = [_position, _radius, (random 180) + (random 180)] call ADF_fnc_randomPosMax;};
		};	
		
		// Create a crewed veicle and send it on patrol
		[_position, _position, _side, _type, _radius, 4, "MOVE", "SAFE", "RED", "LIMITED", 25, _code_1, _code_2] call ADF_fnc_createVehiclePatrol;
		sleep 1;
	};
} else {
	if (_enemy_LightVehicle == 0) exitWith {};
	// Create a crewed vehicle and send it on patrol
	private _type = selectRandom [1, 2, 3];
	[_position, _position, _side, _type, _radius, 4, "MOVE", "SAFE", "RED", "LIMITED", 25, _code_1, _code_2] call ADF_fnc_createVehiclePatrol;
};

// ROAD: APC's
if (_enemy_APC > 1) then {
	for "_i" from 1 to _enemy_APC do {
	
			// Get a random spawn position on a road with the AO		
			for "_i" from 1 to 4 do {
				private _searchPosition = [_position, _radius, random 360] call ADF_fnc_randomPos;
				_rd = [_searchPosition, _roadRadius] call ADF_fnc_roadPos;
				// If a suitable position has been found then exit else continue looking
				if (isOnRoad _rd) exitWith {_position = _rd};
				_roadRadius = _roadRadius + (_radius / 10);
				if (_i == 3) then {_roadRadius = _roadRadius + (_radius / 7)};
				if (_i == 4) then {_position = [_position, _radius, (random 180) + (random 180)] call ADF_fnc_randomPosMax;};
			};	
	
		// Create a crewed vehicle and send it on patrol
		[_position, _position, _side, 4, _radius, 4, "MOVE", "SAFE", "RED", "LIMITED", 25, _code_1, _code_2] call ADF_fnc_createVehiclePatrol;
		sleep 1;
	};
} else {
	if (_enemy_APC == 0) exitWith {};
	// Create a crewed vehicle and send it on patrol
	[_position, _position, _side, 4, _radius, 4, "MOVE", "SAFE", "RED", "LIMITED", 25, _code_1, _code_2] call ADF_fnc_createVehiclePatrol;
};

// ROAD: Armored/MBT
if (_enemy_armor > 1) then {
	for "_i" from 1 to _enemy_armor do {
	
		// Get a random spawn position on a road with the AO		
		for "_i" from 1 to 4 do {
			private _searchPosition = [_position, _radius, random 360] call ADF_fnc_randomPos;
			_rd = [_searchPosition, _roadRadius] call ADF_fnc_roadPos;
			// If a suitable position has been found then exit else continue looking
			if (isOnRoad _rd) exitWith {_position = _rd};
			_roadRadius = _roadRadius + (_radius / 10);
			if (_i == 3) then {_roadRadius = _roadRadius + (_radius / 7)};
			if (_i == 4) then {_position = [_position, _radius, (random 180) + (random 180)] call ADF_fnc_randomPosMax;};
		};	
		
		// Create a crewed vehicle and send it on patrol	
		[_position, _position, _side, 5, _radius, 4, "MOVE", "SAFE", "RED", "LIMITED", 25, _code_1, _code_2] call ADF_fnc_createVehiclePatrol;
		sleep 1;
	};
} else {
	if (_enemy_armor == 0) exitWith {};
	// Create a crewed vehicle and send it on patrol
	[_position, _position, _side, 5, _radius, 4, "MOVE", "SAFE", "RED", "LIMITED", 25, _code_1, _code_2] call ADF_fnc_createVehiclePatrol;
};

// AIR: Helicopter
if (_enemy_helicopter > 0) then {
	private _type = selectRandom [1, 2, 3, 5];
	if (_radius > 1999) then {_type = selectRandom [3, 5]};
	[_position, _position, _side, _type, (_radius * 2), 30 + (random 100), 5, "MOVE", "SAFE", "RED", "LIMITED", "FILE", 250, _code_1, _code_2] call ADF_fnc_createAirPatrol;
};

// Random IED's
if _ied then {
	for "_i" from 1 to _enemy_ied do {
		private _searchPosition = [_position, _radius, random 360] call ADF_fnc_randomPos;
		[_searchPosition, _radius / 4, 100, 4.5] call ADF_fnc_createIED;
	};
};

// Debug Diag reporting
if ADF_debug then {[format ["ADF_fnc_createAO - Diag time to execute function: %1",diag_tickTime - _dt]] call ADF_fnc_log};

true