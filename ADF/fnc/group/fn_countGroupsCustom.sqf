/*********************************************************************************
 _____ ____  _____ 
|  _  |    \|   __|
|     |  |  |   __|
|__|__|____/|__|   
ARMA Mission Development Framework
ADF version: 2.26 / Jul 2020

Function: ADF_fnc_countGroupsCustom
Author: Whiztler
Script version: 1.02

File: fn_countGroupsCustom.sqf
**********************************************************************************
ABOUT
Counts groups per side as stored in a previously defined array of your choice. 

INSTRUCTIONS:
Call from script on the server. The function does not count civilian groups

REQUIRED PARAMETERS:
0. String       Existing array. E.g. "AO_Kavala"

OPTIONAL PARAMETERS:
1. Side         west, east, independent (default: east)

EXAMPLES USAGE IN SCRIPT:
["AO_Kavala", west] call ADF_fnc_countGroupsCustom;

EXAMPLES USAGE IN EDEN:
N/A

DEFAULT/MINIMUM OPTIONS
["AO_Kavala"] call ADF_fnc_countGroupsCustom;

RETURNS:
Number (group count)
*********************************************************************************/

// Reporting
if (ADF_extRpt || {ADF_debug}) then {diag_log "ADF rpt: fnc - executing: ADF_fnc_countGroupsCustom"};

// Init
params [
	["_array", "", [""]],
	["_side", east, [east]]
];

// Check if the array is valid
if (_array == "" || isNil _array) exitWith {
	if (ADF_debug || ADF_extRpt) then {["ADF Debug: ADF_fnc_countGroups - Error, array does not exist. Execute ADF_fnc_logGroupCustom first. Exiting", true] call ADF_fnc_log};
	0
};

_allGroups = missionNamespace getVariable [_array,[]];

private _count = switch _side do {
	case west		: {count _allGroups};
	case east		: {count _allGroups};
	case independent	: {count _allGroups};
	default			  {0}
};

_count