/*********************************************************************************
 _____ ____  _____ 
|  _  |    \|   __|
|     |  |  |   __|
|__|__|____/|__|   
ARMA Mission Development Framework
ADF version: 2.26 / Jul 2020

Function: ADF_fnc_setGarrison
Author: Whiztler
Script version: 1.19

File: fn_setGarrison.sqf
**********************************************************************************
ABOUT
The setGarrison function is executed by the defendArea function for units that
have been assigned a position within a building. It makes the unit move (walk/run)
to the position. Once at the position the unit remain stationary untill a thread
has been detected. Used by ADF_fnc_defendArea.

INSTRUCTIONS:
Execute (spawn) from the server or HC

REQUIRED PARAMETERS:
0. Object:      The AI unit that needs to garrison.
1. Array:       Position within a building (buildingposition)
2. Object:      The building in question

OPTIONAL PARAMETERS:
N/a

EXAMPLES USAGE IN SCRIPT:
[_myAiUnit, [1234,1234,3], [building:mapobject]] spawn ADF_fnc_setGarrison;

EXAMPLES USAGE IN EDEN:
N/A

DEFAULT/MINIMUM OPTIONS
N/A

RETURNS:
Nothing
*********************************************************************************/

// Reporting
if (ADF_extRpt || {ADF_debug}) then {diag_log "ADF rpt: fnc - executing: ADF_fnc_setGarrison"};

// init
private _diag_time = diag_tickTime;
params [
	["_unit", objNull, [objNull]],
	["_position", [0, 0, 0], [[]], [3]],
	["_building", objNull, [objNull]]
];

// Move the unit inside the predefined building position. Give the unit 60 secs to reach its position.	
private _stance = "UP";

if ((_unit distance _position) < 50) then {
	private _time = time;
	_unit doMove _position;
	_unit forceSpeed 6;
	sleep 5;
	waitUntil {unitReady _unit || (time > _time + 10)};
};

// Set unit just in case the building or building position is bugged
_unit allowDamage false;
_unit setPosATL [_position # 0, _position # 1, ( _position # 2) + .15];
_unit allowDamage true;

// Attempt to make the unit face outside 
private _direction = (_unit getRelDir _building) - 180;
private _watchPosition = _unit getRelPos [1000, _direction];
_unit doWatch _watchPosition;
_unit setDir _direction;	

// Store the units direction
_unit setVariable ["ADF_garrSetDir", _direction];

if !([_unit] call ADF_fnc_outsidePosUnit) then {
	if (random 1 < 0.25) then {
		_unit setUnitPos "MIDDLE";
		_stance = "MIDDLE";
	} else {
		_unit setUnitPos "UP";
	};
};

// Add the EH that starts the takeCover function
_unit addEventHandler ["FiredNear", {[_this # 0, _stance] call ADF_fnc_takeCover}];

_unit disableAI "move";
doStop _unit;
commandStop _unit;

//_unit setVariable ["ADF_garrSetBuilding", [true, _position]];

// Debug Diag reporting
if ADF_debug then {[format ["ADF_fnc_setGarrison - Diag time to execute function: %1",diag_tickTime - _diag_time]] call ADF_fnc_log};

waitUntil {sleep 1 + (random 1); !(unitReady _unit)};
_unit enableAI "move";