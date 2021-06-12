/*********************************************************************************
 _____ ____  _____ 
|  _  |    \|   __|
|     |  |  |   __|
|__|__|____/|__|   
ARMA Mission Development Framework
ADF version: 2.26 / Jul 2020

Function: ADF_fnc_carBombDetonate
Author: Whiztler
Script version: 1.07

File: fn_carBombDetonate.sqf
Diag: 0.0277 ms
**********************************************************************************
ABOUT
Detonates a car bomb. Can be used manually or via the createCarBomb module.

INSTRUCTIONS (MANUAL USAGE):
Place a fuel truck (or other vehicle) on the map. Create a trigger around  the 
fuel truck and call the function on trigger activation.
Or call from script on the server.

REQUIRED PARAMETERS:
0. Position:        Marker, object, trigger or position array [x,y,z]

OPTIONAL PARAMETERS:
n/a

EXAMPLES USAGE IN SCRIPT:
[iedTrigger] call ADF_fnc_carBombDetonate;

EXAMPLES USAGE IN EDEN:
[thisTrigger] call ADF_fnc_carBombDetonate;

DEFAULT/MINIMUM OPTIONS
[iedTrigger] call ADF_fnc_carBombDetonate;

RETURNS:
Bool (success flag)
*********************************************************************************/

// Reporting
if (ADF_extRpt || {ADF_debug}) then {diag_log "ADF rpt: fnc - executing: ADF_fnc_carBombDetonate"};

if !isServer exitWith {};

// init
params [
	["_position", "", ["", [], objNull, grpNull, locationNull]]
];

// check position location
_position = [_position] call ADF_fnc_checkPosition;

private _allObjects = nearestObjects [_position, ["CAR"], 8];

// Terminate when no vehicle found
if (_allObjects isEqualTo []) exitWith {if ADF_debug then {["ADF Debug: ADF_fnc_carBombDetonate - ERROR, no vehicle found. Exiting", true] call ADF_fnc_log}; false};

// Disable vehicle simulation
private _object = _allObjects # 0;
_object allowDamage false;
_object enableSimulationGlobal false;

// Create the explosion
private _explosion = createVehicle ["HelicopterExploBig", _position, [], 0, "CAN_COLLIDE"];
private _explosion = createVehicle ["Bo_GBU12_LGB", [_position select 0, _position select 1, (_position select 2) + 3], [], 0, "CAN_COLLIDE"];

// Enable vehicle simulation + destroy the vehicle
enableCamShake true;
addCamShake [4, 3, 3];
_object allowDamage true;
_object enableSimulationGlobal true;
_object setDamage 1;

true