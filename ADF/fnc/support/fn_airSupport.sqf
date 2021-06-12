/*********************************************************************************
 _____ ____  _____ 
|  _  |    \|   __|
|     |  |  |   __|
|__|__|____/|__|   
ARMA Mission Development Framework
ADF version: 2.26 / Jul 2020

Script: air support script
Author: Whiztler
Script version: 1.15

File: ADF_fnc_airSupport.sqf
**********************************************************************************
ABOUT
Air support function that activates the BIS cas run.

INSTRUCTIONS:
Execute (call) from the server

REQUIRED PARAMETERS:
0. Side:        west, east, independent. Side of the CAS support plane
1. Position:    CAS position. Marker, object, trigger or position array [x,y,z]

OPTIONAL PARAMETERS:
2. Number       Approach vector in degrees. Default: -1 (direction of the marker)
3. Number       CAS weapons type:
                0 - Machine gun (Blufor/west only)
                1 - Missiles (default)
                2 - Machine gun and missiles 

EXAMPLES USAGE IN SCRIPT:
[west, "support", -1, 0] call ADF_fnc_airSupport;

EXAMPLES USAGE IN EDEN:
[independent, CSAThmg, 95, 1] call ADF_fnc_airSupport; // CSAThmg is a named enemy vehicle

DEFAULT/MINIMUM OPTIONS
[west, "myCAS"] call ADF_fnc_airSupport;

RETURNS:
Bool (success flag)
*********************************************************************************/

// Reporting
if (ADF_extRpt || {ADF_debug}) then {diag_log "ADF rpt: fnc - executing: ADF_fnc_airSupport"};
	
// init
private _diag_time = diag_tickTime;
params [
	["_side", west, [east]],
	["_position", "", ["", [], objNull, grpNull]],
	["_direction", -1, [0]],
	["_weapons", 1, [0]]
];
private _vector = 0;
private _attach = false;
private _dummy = objNull;
private _aircraftClass = "";

// Check valid vars
if !(_side in [west, east, independent]) exitWith {[format ["ADF_fnc_airSupport - %1  side passed. Exiting", _side], true] call ADF_fnc_log; grpNull};
if (_weapons > 2) then {_weapons = 1};

// Check approach vector type
if (_direction == -1) then {
	if (_position isEqualType "") then {_vector = markerDir _position};
	if (_position isEqualType objNull) then {
		_vector = getDir _position;
		_attach = true;
		_dummy = _position
	};
} else {
	_vector = _direction;
};

// Check the location position
_position = [_position] call ADF_fnc_checkPosition;

// Determine aircraft based on side
switch _side do {
	case west 		: {_aircraftClass = "B_Plane_CAS_01_F"};
	case east 		: {_aircraftClass = "O_Plane_CAS_02_F"; _weapons = 1};
	case independent	: {_aircraftClass = "I_Plane_Fighter_03_CAS_F";  _weapons = 1};	
};

// Create simulation object for CAS target purpose
private _target = "Land_PenBlack_F" createVehicle [0,0,0];
_target setPos _position;
if (_attach) then {_target attachTo [_dummy]} else {_target enableSimulationGlobal false};	
_target hideObjectGlobal true;
_target setVariable ["type", _weapons];
_target setVariable ["vehicle", _aircraftClass];	
_target setDir _vector;
// Delete the simulation object after 30 seconds
[_target] spawn {params ["_target"]; sleep 30; deleteVehicle _target};

//  Call the BIS CAS module
[_target, nil, true] call BIS_fnc_moduleCAS;

// Debug reporting
if ADF_debug then {
	[format ["ADF_fnc_airSupport - CAS (%1) created. Expedite to position: %2", _aircraftClass, _position]] call ADF_fnc_log;
	[format ["ADF_fnc_airSupport - Diag time to execute function: %1",diag_tickTime - _diag_time]] call ADF_fnc_log;
};

// return bool
true	