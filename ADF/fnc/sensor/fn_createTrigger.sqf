/*********************************************************************************
 _____ ____  _____ 
|  _  |    \|   __|
|     |  |  |   __|
|__|__|____/|__|   
ARMA Mission Development Framework
ADF version: 2.26 / Jul 2020

Function: ADF_fnc_createTrigger
Author: Whiztler
Script version: 1.00

File: fn_createTrigger.sqf
Diag: 0.012 ms
**********************************************************************************
ABOUT
Creates a trigger, either local (e.g. server) or global.

INSTRUCTIONS:
Call from script on the server or hc. 

REQUIRED PARAMETERS:
0. position:  String / Array [x, y, z] / object or vehicle / group / location,
              representing the position where the trigger will be created.

OPTIONAL PARAMETERS:
1. bool:      Make the trigger global?
              - true
			  - false (default)
2. Integer:   Interval time in seconds. Determines how often the condition is checked. Default: 1
3. Bool:      Enable simultation?
              - true (default)
              - false
              Setting this to false will disable the trigger condition check. 			  
4. Bool:      Shape of the trigger:
              - true for rectangular
              - false for circular (default)
5. Integer:   Size of X-axis in meters of the catchment area. Default: 5
6. Integer:   Size of y-axis in meters of the catchment area. Default: 5
7. Integer:   Angle of the trigger. Default: 0
8. Integer:   Height in meters of the catchment area. Default: -1 (unlimited)
9. String:    Who activates trigger. Can be "NONE" or
              - Side: "EAST", "WEST", "GUER", "CIV", "LOGIC", "ANY", "ANYPLAYER" (default)
              - Radio: "ALPHA", "BRAVO", "CHARLIE", "DELTA", "ECHO", "FOXTROT", "GOLF", "HOTEL", "INDIA", "JULIET"
              - Object: "STATIC", "VEHICLE", "GROUP", "LEADER", "MEMBER"
              - Status: "WEST SEIZED", "EAST SEIZED" or "GUER SEIZED"
10. String:   How trigger is it activated. Can be:
              - Presence: "PRESENT" (default), "NOT PRESENT"
              - Detection: "WEST D", "EAST D", "GUER D" or "CIV D"
11. Bool:     Repeating. Activation can happen repeatedly:
              - true for repeating
              - false for once off (default)
12. String    Condition. Code containing trigger condition. Special variables available here:
              this (Boolean) - detection event
              thisTrigger (Object) - trigger instance
              thisList (Array) - array of all detected entities
13. String    Activation. Code that is executed when the trigger is activated. Special variables available here:
              thisTrigger (Object) - trigger instance
              thisList (Array) - array of all detected entities
14. String    Deactivation: Code that is executed when the trigger is deactivated. Special variable available here:
              thisTrigger (Object) - trigger instance
			  
EXAMPLES USAGE IN SCRIPT:
["myMarker", true, 5, true, false, 100, 100, 0, -1, "ANYPLAYER", "PRESENT", true, "THIS", "hint 'trigger switched ON'", "hint 'trigger switched OFF'"] call ADF_fnc_createTrigger;

EXAMPLES USAGE IN EDEN:
n/a

DEFAULT/MINIMUM OPTIONS
["triggerMarker"] call ADF_fnc_createTrigger;

RETURNS:
Trigger


*********************************************************************************/

if !(isServer || ADF_isHC) exitWith {};

// Reporting
if (ADF_extRpt || {ADF_debug}) then {diag_log "ADF rpt: fnc - executing: ADF_fnc_createTrigger"};

// Init
params [
	["_position", [0, 0, 0], ["", objNull, grpNull, locationNull, [], 0]],
	["_isGlobal", false, [true]],
	["_interval", 1, [0]],
	["_enableSimulation", true, [false]],
	["_rectangular", false, [true]],
	["_size_x", 5, [0]],
	["_size_y", 5, [0]],
	["_angle", 0, [0]],
	["_height", -1, [0]],
	["_activation_who", "ANYPLAYER", [""]],
	["_activation_type", "PRESENT", [""]],
	["_repeating", false, [true]],
	["_condition", "THIS", [""]],
	["_activation", "", [""]],
	["_deactivation", "", [""]]
];
_activation_who = toUpperANSI _activation_who;
_activation_type = toUpperANSI _activation_type;
_position = [_position] call ADF_fnc_checkPosition;

// Validation
if (_position isEqualTo [0, 0, 0]) exitWith {["ADF_fnc_createTrigger", format ["Position: '%1' is not a valid position", _position]] call ADF_fnc_terminateScript;};
if ((_size_x > 5000) || {_size_y > 5000}) then {[format ["ADF_fnc_createTrigger - unusual large trigger area passed. Trigger size is %1 by %2 meters.", _size_x, _size_y]] call ADF_fnc_log;};
if !(_activation_who in ["EAST", "WEST", "GUER", "CIV", "LOGIC", "ANY", "ANYPLAYER", "ALPHA", "BRAVO", "CHARLIE", "DELTA", "ECHO", "FOXTROT", "GOLF", "HOTEL", "INDIA", "JULIET", "STATIC", "VEHICLE", "GROUP", "LEADER", "MEMBER", "WEST SEIZED", "EAST SEIZED", "GUER SEIZED"]) then {[format ["ADF_fnc_createTrigger - incorrect param (activated by who) passed: %1. Defaulting to 'ANYPLAYER'.", _activation_who]] call ADF_fnc_log; _activation_who = "ANYPLAYER";}; 
if !(_activation_type in ["PRESENT", "NOT PRESENT", "WEST D", "EAST D", "GUER D", "CIV D"]) then {[format ["ADF_fnc_createTrigger - incorrect param (activated type) passed: %1. Defaulting to 'PRESENT'.", _activation_type]] call ADF_fnc_log; _activation_type = "PRESENT";}; 

// Create the trigger
_trigger = createTrigger ["EmptyDetector", _position, _isGlobal];
_trigger setTriggerArea [_size_x, _size_y, _angle, _rectangular, _height];
_trigger setTriggerActivation [_activation_who, _activation_type, _repeating];
_trigger setTriggerStatements [_condition, _activation, _deactivation];
_trigger setTriggerInterval _interval;

// Check if we need to disable simulation
if !_enableSimulation then {if _isGlobal then {_trigger enableSimulationGlobal _enableSimulation;} else {_trigger enableSimulation _enableSimulation;}};

// Debug reporting
if ADF_debug then {[format ["ADF_fnc_createTrigger trigger (%1) Created", _trigger]] call ADF_fnc_log};

// Return the new trigger
_trigger