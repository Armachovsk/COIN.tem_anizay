/*********************************************************************************
 _____ ____  _____ 
|  _  |    \|   __|
|     |  |  |   __|
|__|__|____/|__|   
ARMA Mission Development Framework
ADF version: 2.26 / Jul 2020

Function: ADF_fnc_setGroupID
Author: Whiztler
Script version: 1.04

File: fn_setGroupID.sqf
**********************************************************************************
Applies a custom group ID (Call sign) to an unit. Use on every unit of the group.

INSTRUCTIONS:
Call from script on the local client.

REQUIRED PARAMETERS:
0. Group:       Existing group
1. String:      GroupID

OPTIONAL PARAMETERS:
N/A

EXAMPLE
[_myGroup, "SEAL-6"] call ADF_fnc_setGroupID;

RETURNS:
Bool
*********************************************************************************/

// Reporting
if (ADF_extRpt || {ADF_debug}) then {diag_log "ADF rpt: fnc - executing: ADF_fnc_setGroupID"};
	
params [
	["_group", "empty", ["", grpNull]],
	["_groupID", "empty", [""]]
];

if ((_group isEqualType "") && {_group == "empty"}) exitWith {false};
if ((_group isEqualType grpNull) && {_group isEqualTo grpNull}) exitWith {false};
if (_groupID == "empty") exitWith {false};

if (_group isEqualType "") then {_group = call compile format ["%1", _group]};

if isServer then {
	_group setGroupIdGlobal [format ["%1", _groupID]];
} else {
	_group setGroupId [format ["%1", _groupID]];
};

true