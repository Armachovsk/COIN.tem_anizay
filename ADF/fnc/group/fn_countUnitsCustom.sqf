/*********************************************************************************
 _____ ____  _____ 
|  _  |    \|   __|
|     |  |  |   __|
|__|__|____/|__|   
ARMA Mission Development Framework
ADF version: 2.26 / Jul 2020

Function: ADF_fnc_countUnitsCustom
Author: Whiztler
Script version: 1.03

File: fn_countUnitsCustom.sqf
**********************************************************************************
ABOUT
Counts units per side as stored in a predefined array of your choice. The function
does count civilian units

INSTRUCTIONS:
Execute (call) from the server or HC

REQUIRED PARAMETERS:
0. String       Existing array. E.g. "AO_Kavala"

OPTIONAL PARAMETERS:
1. Side         west, east, independent    

EXAMPLES USAGE IN SCRIPT:
["AO_Kavala", west] call ADF_fnc_countUnitsCustom;

EXAMPLES USAGE IN EDEN:
N/A

DEFAULT/MINIMUM OPTIONS
["AO_Kavala"] call ADF_fnc_countUnitsCustom;

RETURNS:
Number (unit count)
*********************************************************************************/

// Reporting
if (ADF_extRpt || {ADF_debug}) then {diag_log "ADF rpt: fnc - executing: ADF_fnc_countUnitsCustom"};

// Init
params [
	["_array", "", [""]],
	["_side", east, [west]]
];

// Chec if array is valid
if (_array isEqualTo "") exitWith {
	if (ADF_debug || ADF_extRpt) then {["ADF Debug: ADF_fnc_countUnitsCustom - ERROR, array does not exist. Execute ADF_fnc_logGroupCustom first. Exiting.", true] call ADF_fnc_log};
	0
};

private _count = 0;
_allGroups = missionNamespace getVariable [_array,[]];

switch _side do {
	case west		: {{_count = _count + (count _x)} forEach _allGroups};
	case east		: {{_count = _count + (count _x)} forEach _allGroups};
	case independent	: {{_count = _count + (count _x)} forEach _allGroups};
	case default		  {0}
};

_count