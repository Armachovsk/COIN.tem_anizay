/*********************************************************************************
 _____ ____  _____ 
|  _  |    \|   __|
|     |  |  |   __|
|__|__|____/|__|   
ARMA Mission Development Framework
ADF version: 2.26 / Jul 2020

Function: ADF_fnc_countGroups
Author: Whiztler
Script version: 1.04

File: fn_countGroups.sqf
**********************************************************************************
ABOUT
Counts groups per side as stored in the ADF_groupsXXX array.

INSTRUCTIONS:
Call from script on the server. The function does NOT count civilian groups

REQUIRED PARAMETERS:
0. Side     west, east, independent

OPTIONAL PARAMETERS:
n/a

EXAMPLES USAGE IN SCRIPT:
[west] call ADF_fnc_countGroups;

EXAMPLES USAGE IN EDEN:
N/A

DEFAULT/MINIMUM OPTIONS
[east] call ADF_fnc_countGroups;

RETURNS:
Number (group count)
*********************************************************************************/

// Reporting
if (ADF_extRpt || {ADF_debug}) then {diag_log "ADF rpt: fnc - executing: ADF_fnc_countGroups"};

// Init
params [
	["_side", east, [west]]
];

// Check if the ADF_groupsXXX array exist 
if (isNil "ADF_groupsInit") exitWith {
	if (ADF_debug || ADF_extRpt) then {[format ["ADF_fnc_countGroups - ERROR, array does not exist. Execute ADF_fnc_logGroup first. Exiting."], true] call ADF_fnc_log};
	0
};

// Count the current groups based on side
private _count = switch _side do {
	case west			: {count ADF_groupsWest};
	case east			: {count ADF_groupsEast};
	case independent		: {count ADF_groupsIndep};
	default				  {count ADF_groupsEast};
};

_count