/*********************************************************************************
 _____ ____  _____ 
|  _  |    \|   __|
|     |  |  |   __|
|__|__|____/|__|   
ARMA Mission Development Framework
ADF version: 2.26 / Jul 2020

Function: ADF_fnc_countUnits
Author: Whiztler
Script version: 1.03

File: fn_countUnits.sqf
**********************************************************************************
Counts units per side as stored in the ADF_groupsXXX array.

INSTRUCTIONS:
Call from script on the server. The function does not count civilian units

REQUIRED PARAMETERS:
0. Side         west, east, independent

OPTIONAL PARAMETERS:
N/A

EXAMPLES USAGE IN SCRIPT:
[west] call ADF_fnc_countUnits;

EXAMPLES USAGE IN EDEN:
N/A

DEFAULT/MINIMUM OPTIONS
[west] call ADF_fnc_countUnits;

RETURNS:
Number (unit count)
*********************************************************************************/

// Reporting
if (ADF_extRpt || {ADF_debug}) then {diag_log "ADF rpt: fnc - executing: ADF_fnc_countUnits"};

// Init
params [
	["_side", east, [west]]
];

// Check if the ADF_groupsInit has initialized
if (isNil "ADF_groupsInit") exitWith {
	if (ADF_debug || ADF_extRpt) then {["ADF Debug: ADF_fnc_countUnits - ERROR, array does not exist. Execute ADF_fnc_logGroup.sqf first. Exiting.", true] call ADF_fnc_log};
	0
};

private _count = 0;

switch _side do {
	case west		: {{_count = _count + (count _x)} forEach ADF_groupsWest};
	case east		: {{_count = _count + (count _x)} forEach ADF_groupsEast};
	case independent	: {{_count = _count + (count _x)} forEach ADF_groupsIndep};
	case default		  {0}
};

_count