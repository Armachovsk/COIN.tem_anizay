/*********************************************************************************
 _____ ____  _____ 
|  _  |    \|   __|
|     |  |  |   __|
|__|__|____/|__|   
ARMA Mission Development Framework
ADF version: 2.26 / Jul 2020

Function: ADF_fnc_addToCurator
Author: Whiztler
Script version: 1.01

File: fn_addToCurator.sqf
Diag: 0.041746 ms
**********************************************************************************
ABOUT
This function adds units to the curator so that zeus can see/manage the units.

INSTRUCTIONS:
Execute (call) from the from any client:
[units _group] remoteExecCall ["ADF_fnc_addToCurator", 2];

REQUIRED PARAMETERS:
0. Object/Array:      Single unit, group, or array of units or objects.

EXAMPLES USAGE IN SCRIPT:
[_groupAlpha] remoteExecCall ["ADF_fnc_addToCurator", 2];

EXAMPLES USAGE IN EDEN:
Do NOT use in Eden

DEFAULT/MINIMUM OPTIONS
[_grp] remoteExecCall ["ADF_fnc_addToCurator", 2];

RETURNS:
Bool (succesflag)
*********************************************************************************/

// Reporting
if (ADF_extRpt || {ADF_debug}) then {diag_log "ADF rpt: fnc - executing: ADF_fnc_addToCurator"};

// init	
params [
	["_addThis", grpNull, [grpNull, objNull, []]]
];

if (allCurators isEqualTo []) exitWith {[format ["ADF_fnc_addToCurator - No Zeus/Curator module active (%1)", _addThis], true] call ADF_fnc_log; false};
if !isServer exitWith {[_addThis] remoteExecCall ["ADF_fnc_addToCurator", 2]; false};

call {
	if (_addThis isEqualType grpNull) exitWith {
		{_x addCuratorEditableObjects [units _addThis, false]} count allCurators;
	};
	if (_addThis isEqualType objNull) exitWith {
		private _addCrew = if (_addThis isKindOf "MAN") then {false} else {true};
		{_x addCuratorEditableObjects [[_addThis], _addCrew]} count allCurators
	};
	if (_addThis isEqualType []) exitWith {
		{[_x] call ADF_fnc_addToCurator} count _addThis;		
	};
};

true
