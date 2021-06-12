/*********************************************************************************
 _____ ____  _____ 
|  _  |    \|   __|
|     |  |  |   __|
|__|__|____/|__|   
ARMA Mission Development Framework
ADF version: 2.26 / Jul 2020

Function: ADF_fnc_logGroup
Author: Whiztler
Script version: 1.03

File: fn_logGroup.sqf
**********************************************************************************
ABOUT
The logGroup function is a relay function. The meta relay is to store groups into
a list (array). The array can be used to track/manipulate groups.

INSTRUCTIONS:
Call the function after each created group (e.g. with BIS_fnc_spawnGroup).
Run the function on mission start to initialize and add editor place groups to the
arrays. The following arrays will be created:

- ADF_groupsWest
- ADF_groupsEast
- ADF_groupsIndep

the function does not track civilian groups

REQUIRED PARAMETERS:
0. Group:       Existing group

OPTIONAL PARAMETERS:
N/A

EXAMPLE
[_grp] call ADF_fnc_logGroup;

RETURNS:
Bool (success Flag)
*********************************************************************************/

// Reporting
if (ADF_extRpt || {ADF_debug}) then {diag_log "ADF rpt: fnc - executing: ADF_fnc_logGroup"};

// Init
params [
	["_group", grpNull, [grpNull]]
];

// Check if the passed group is valid
if (_group == grpNull) exitWith {
	if ADF_debug then {diag_log "ADF Debug: ADF_fnc_logGroup - ERROR, group does not exist. Exiting."};
	false
};

// First run initialization
if (isNil "ADF_groupsInit") exitWith {
	ADF_groupsInit	= true;
	ADF_groupsWest	= [];
	ADF_groupsEast	= [];
	ADF_groupsIndep	= [];
	
	{
		switch (side _x) do {
			case west		:	{ADF_groupsWest pushBackUnique _x};
			case east		:	{ADF_groupsEast pushBackUnique _x};
			case independent	:	{ADF_groupsIndep pushBackUnique _x};
			case civilian		:	{};
			default				{};
		};
	} forEach allGroups;
	
	// Loop through all groups every 5 seconds to check for empty groups
	[] spawn {
		waitUntil {
			{
				if (count (units _x) == 0) then {
					switch (side _x) do {
						case west		: {ADF_groupsWest = ADF_groupsWest - [_x];};
						case east		: {ADF_groupsEast = ADF_groupsEast - [_x]};
						case independent	: {ADF_groupsIndep = ADF_groupsIndep - [_x]};
						default			  {};
					};
				};
			} forEach allGroups;
			sleep 5;
			false
		};
	};
	
	[format ["ADF_fnc_logGroup - Groups logged. # Groups West: %1", count ADF_groupsWest]] call ADF_fnc_log;
	[format ["ADF_fnc_logGroup - Groups logged. # Groups East: %1", count ADF_groupsEast]] call ADF_fnc_log;
	[format ["ADF_fnc_logGroup - Groups logged. # Groups Independent: %1", count ADF_groupsIndep]] call ADF_fnc_log;
};

switch (side _group) do {
	case west		: 	{ADF_groupsWest pushBackUnique _group};
	case east		: 	{ADF_groupsEast pushBackUnique _group};
	case independent	: 	{ADF_groupsIndep pushBackUnique _group};
	case civilian		: 	{};
	default				{};	
};

if (ADF_debug || ADF_extRpt) then {[format ["ADF_fnc_logGroup - Group logged: %1 (%2)",_group, side _group]] call ADF_fnc_log};

true