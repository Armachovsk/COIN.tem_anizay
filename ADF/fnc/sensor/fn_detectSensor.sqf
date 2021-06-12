/*********************************************************************************
 _____ ____  _____ 
|  _  |    \|   __|
|     |  |  |   __|
|__|__|____/|__|   
ARMA Mission Development Framework
ADF version: 2.26 / Jul 2020

Function: Detection Sensor
Author: Whiztler
Script version: 1.09

File: fn_DetectSensor.sqf
Diag: 0.0512 ms
*********************************************************************************
ABOUT
Sensor to 'activate' OpFor to make them more aware and respond better and quicker
to enemy presence.

INSTRUCTIONS::

Place a trigger:

Name:           Give the trigger a unique name
Axis A,B:       Whatever size you want. The is the catchment area'
Activation:     Blufor, once, detected by Opfor
MIN/MID/MAX:    5/7/10
Condition:      this
On Activation:  [thisTrigger, east, 500] call ADF_fnc_detectSensor;

REQUIRED PARAMETERS:
0: Position:    Center position. Marker, object, trigger or position array [x,y,z]

OPTIONAL PARAMETERS:
1. Side:        east, west, independent, civilian. Default: east
2. Number:      Radius to activate/make aware enemy units. Default: 500
3. String:      OpFor skill set:
                "untrained" - unskilled, slow to react 
                "recruit"   - semi skilled
                "novice"    - Skilled, trained. Vanilla+ setting (Default)
                "veteran"   - Very skilled, Well trained 
                "expert"    - Special forces skill set
4. Bool:        Set skill?
                True (default)
                false

EXAMPLES USAGE IN SCRIPT:
["myMarker", east, 500, "expert", true] call ADF_fnc_detectSensor;

EXAMPLES USAGE IN EDEN:
[thisTrigger, independent, 500] call ADF_fnc_detectSensor;

DEFAULT/MINIMUM OPTIONS
[thisTrigger] call ADF_fnc_detectSensor;

RETURNS:
Bool (success flag)
********************************************************************************/

if !isServer exitWith {};

// Reporting
if (ADF_extRpt || {ADF_debug}) then {diag_log "ADF rpt: fnc - executing: ADF_fnc_detectSensor"};

// Init
params [
	["_position", objNull, ["", [], objNull, grpNull]],
    ["_side", east, [west]],
    ["_radius", 500, [0]],
	["_skill", "novice", [""]],
	["_setSkill", true, [false]]
];

// Check the position location
_position = [_position] call ADF_fnc_checkPosition;

// Create a list of all units within the sensor radius
private _allNear = _position nearEntities ["Man", _radius];

// "Activate" the units
{
	if !(side _x == _side) exitWith {false};
	_x setBehaviour "COMBAT"; 
	_x setCombatMode "RED";
	if _setSkill then {[_x, _skill] call ADF_fnc_unitSetSkill};
} forEach _allNear;

true