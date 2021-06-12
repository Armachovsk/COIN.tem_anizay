/*********************************************************************************
 _____ ____  _____ 
|  _  |    \|   __|
|     |  |  |   __|
|__|__|____/|__|   
ARMA Mission Development Framework
ADF version: 2.26 / Jul 2020

Function: ADF_fnc_deleteCrewedVehicles
Author: Whiztler
Script version: 1.03

File: fn_deleteCrewedVehicles.sqf
**********************************************************************************
ABOUT
Deletes vehicles, including its crew and the crew's group.

INSTRUCTIONS:
Execute (call) from the server or HC

REQUIRED PARAMETERS:
0. Array:       Array of crewed vehicles

OPTIONAL PARAMETERS:
N/A

EXAMPLES USAGE IN SCRIPT:
[[veh1, veh2, veh3]] call ADF_fnc_deleteCrewedVehicles;

EXAMPLES USAGE IN EDEN:
[[veh1, veh2, veh3]] call ADF_fnc_deleteCrewedVehicles;

DEFAULT/MINIMUM OPTIONS
[[veh1]] call ADF_fnc_deleteCrewedVehicles;

RETURNS:
Bool (success flag)
*********************************************************************************/

/////////////////////////////////////////////////////////////////////////////////
// REPLACED BY ADF_fnc_delete. // Remains for backwards compatibility 
/////////////////////////////////////////////////////////////////////////////////

// Reporting
if (ADF_extRpt || {ADF_debug}) then {diag_log "ADF rpt: fnc - executing: ADF_fnc_deleteCrewedVehicles"};

// init
params [
	["_a", [], [[]]]
];

[_a] call ADF_fnc_delete;

true