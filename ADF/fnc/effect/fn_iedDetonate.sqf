/*********************************************************************************
 _____ ____  _____ 
|  _  |    \|   __|
|     |  |  |   __|
|__|__|____/|__|   
ARMA Mission Development Framework
ADF version: 2.26 / Jul 2020

Function: ADF_fnc_iedDetonate
Author: Whiztler
Script version: 1.10

File: fn_iedDetonate.sqf
Diag: 0.0268 ms
**********************************************************************************
ABOUT
Detonates an IED. Function is executed by the createIED module

INSTRUCTIONS (MANUAL USAGE):
Call from script on the server.

REQUIRED PARAMETERS:
0. Object - Trigger

OPTIONAL PARAMETERS:
n/a

EXAMPLE
[thisTrigger] call ADF_fnc_iedDetonate;

RETURNS:
Bool (success flag)
*********************************************************************************/

// Reporting
if (ADF_extRpt || {ADF_debug}) then {diag_log "ADF rpt: fnc - executing: ADF_fnc_iedDetonate"};

if !isServer exitWith {};

// Init
params [
	["_trigger", objNull, [objNull]],
	["_demo", "HelicopterExploSmall", [""]],
	["_vbed", false, [true]]
];
// check position location
_position = [_trigger] call ADF_fnc_checkPosition;
_secondaryPosition = _position;

// Debug reporting
if ADF_debug then {[format ["ADF_fnc_iedDetonate - trigger (%1) position: %2", _trigger, _position]] call ADF_fnc_log};

// Check for IED objects
private _allObjects = nearestObjects [_position, ["Car", "Truck", "Land_PlasticBucket_01_closed_F", "Land_GasTank_01_yellow_F", "Land_GasTank_01_khaki_F", "Land_GasTank_01_blue_F", "FlexibleTank_01_sand_F", "Land_Wreck_Car3_F", "Land_GarbagePallet_F", "Land_CanisterPlastic_F", "Land_Sack_F", "Land_JunkPile_F", "Land_BarrelTrash_F", "Land_GarbageBarrel_01_F"], 8];
// If no IED object found then terminate the script
if (_allObjects isEqualTo []) exitWith {if ADF_debug then {["ADF Debug: ADF_fnc_iedDetonate - ERROR, no IED object found. Exiting", true] call ADF_fnc_log; false}};

// VBED's
if ((_allObjects # 0) isKindOf "car" || {(_allObjects # 0) isKindOf "truck"}) then {
	_demo = "HelicopterExploBig";
	_vbed = true;
	_secondaryPosition set [2, (_position select 2) + 3];
};

// Get the IED object position and delete the object
private _objectPosition = getPos (_allObjects # 0);

[_allObjects] call ADF_fnc_delete;

// Create the explosion and crater
private _crater = createVehicle ["Crater", _objectPosition, [], 0, "CAN_COLLIDE"];
private _explosion = createVehicle [_demo, _objectPosition, [], 0, "CAN_COLLIDE"];
if _vbed then {
	private _explosion = createVehicle ["Bo_GBU12_LGB", _secondaryPosition, [], 0, "CAN_COLLIDE"]
};
true