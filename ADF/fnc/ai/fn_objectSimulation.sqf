/*********************************************************************************
 _____ ____  _____ 
|  _  |    \|   __|
|     |  |  |   __|
|__|__|____/|__|   
ARMA Mission Development Framework
ADF version: 2.26 / Jul 2020

Function: ADF_fnc_objectSimulation
Author: Whiztler
Script version: 1.01

File: fn_objectSimulation.sqf
Diag: 0.011 ms
**********************************************************************************
ABOUT
Disables/enables AI units/objects. Besides simulation it enables/disables:

- FSM (AI intelligence)
- Fire suppression
- Spotting and targeting
- Target orders
- Movement 

You can switch it off and on by script.

INSTRUCTIONS:
Execute (call) from the server or HC

REQUIRED PARAMETERS:
0. Object:      AI Unit, vehicle, object.
1. Bool:        Switch objectSSimulation on or off?
                - false - switch off (default)
                - true - switch on

OPTIONAL PARAMETERS:
N/A

EXAMPLES USAGE IN SCRIPT:
[_dumb_ai, true] call ADF_fnc_objectSimulation;

EXAMPLES USAGE IN EDEN:
[this, true] call ADF_fnc_objectSimulation;

DEFAULT/MINIMUM OPTIONS
[_dumb_ai] call ADF_fnc_objectSimulation;

RETURNS:
Bool (success flag)
*********************************************************************************/

// Reporting
if (ADF_extRpt || {ADF_debug}) then {diag_log "ADF rpt: fnc - executing: ADF_fnc_objectSimulation"};

// Init
params [
	["_object", objNull, [objNull]],
	["_simulation", false, [true]]
];

// Switch off simulation
if !_simulation then {
	_object enableSimulation false; 
	
	_object disableAI "FSM";
	_object disableAI "SUPPRESSION"; 
	_object disableAI "TARGET";
	_object disableAI "AUTOTARGET";
	_object disableAI "MOVE"; 

	// Debug reporting
	if (ADF_debug || ADF_extRpt) then {[format ["ADF_fnc_objectSimulation - Simulation aspects disabled for: %1", _object]] call ADF_fnc_log};

// Switch on simulation	
} else {
	_object enableAI "FSM";
	_object enableAI "SUPPRESSION"; 
	_object enableAI "TARGET";
	_object enableAI "AUTOTARGET";
	_object enableAI "MOVE"; 
	
	_object enableSimulation true;
	
	// Debug reporting
	if (ADF_debug || ADF_extRpt) then {[format ["ADF_fnc_objectSimulation - Simulation aspects enabled for: %1", _object]] call ADF_fnc_log};
};

true