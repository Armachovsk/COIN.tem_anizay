/*********************************************************************************
 _____ ____  _____ 
|  _  |    \|   __|
|     |  |  |   __|
|__|__|____/|__|   
ARMA Mission Development Framework
ADF version: 2.26 / Jul 2020

Function: ADF_fnc_log
Author: Whiztler
Script version: 1.03

File: fn_log.sqf
Diag: 0.0722 ms
**********************************************************************************
ABOUT
Creates an Error message or Debug message. Error messages are always show on the
BIS bottom info screen. Both SP and MP.
Debug messages are logged in the RPT and displayed using systemChat. Note that
the messages are only logged on the local machine.

INSTRUCTIONS:
Execute (call) from anywhere

REQUIRED PARAMETERS:
0. String:      Message

OPTIONAL PARAMETERS:
1. Bool:        Is this an error message?
                - true - for error message
                - false - for debug message (default)

EXAMPLES USAGE IN SCRIPT:
if ADF_debug then {["YourErrorMessageHere", true] call ADF_fnc_log}; // Only in debug mode

EXAMPLES USAGE IN EDEN:
["YourErrorMessageHere"] call ADF_fnc_log;

DEFAULT/MINIMUM OPTIONS
["YourErrorMessageHere"] call ADF_fnc_log; // Always show (also MP)

RETURNS:
Nothing
*********************************************************************************/

// Reporting
if (ADF_extRpt || {ADF_debug}) then {diag_log "ADF rpt: fnc - executing: ADF_fnc_log"};
	
// init
params [
	["_message", "", [""]],
	["_error", false, [true]]
];

// Error message?
if (_error) then { 
	private _header = "ADF Error: ";
	private _compiledText = format ["%1%2", _header, _message];
	[_compiledText] call BIS_fnc_error;
	diag_log _compiledText;
	
// Debug log message?	
} else { 
	private _header = "ADF Debug: ";
	private _compiledText = format ["%1%2", _header, _message];
	if ADF_debug then {_compiledText remoteExec ["systemChat", -2, false]};
	diag_log _compiledText;		
};	
