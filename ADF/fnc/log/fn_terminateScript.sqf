/*********************************************************************************
 _____ ____  _____ 
|  _  |    \|   __|
|     |  |  |   __|
|__|__|____/|__|   
ARMA Mission Development Framework
ADF version: 2.26 / Jul 2020

Function: ADF_fnc_terminateScript
Author: Whiztler
Script version: 1.00

File: fn_terminateScript.sqf
**********************************************************************************
ABOUT
This function is executed for debugging when invalid vars or positions are used.
Since most scripts have error correcting/defaulting methods in place sometimes
scrips run for no reason as for instance units are spawned at the lower edge of the
map [0,0,0].

This function alerts you with a predefined message regarding the error. The message
is also logged into the RPT.

INSTRUCTIONS:
Execute (call) from the server or HC. Hints are not displayed in multiplayer. For
local testing only!

REQUIRED PARAMETERS:
0. String:      the function name
1. String:      the error message

OPTIONAL PARAMETERS:
N/A     

EXAMPLES USAGE IN SCRIPT:
["ADF_fnc_ambientAirTraffic",_msg] call ADF_fnc_terminateScript;

EXAMPLES USAGE IN EDEN:
["ADF_fnc_ambientAirTraffic",_m] call ADF_fnc_terminateScript;

DEFAULT/MINIMUM OPTIONS
["ADF_fnc_ambientAirTraffic",_m] call ADF_fnc_terminateScript;

RETURNS:
Nothing
*********************************************************************************/

// Reporting
if (ADF_extRpt || {ADF_debug}) then {diag_log "ADF rpt: fnc - executing: ADF_fnc_terminateScript"};
	
params [
	["_function", "Unnamed ADF Function", [""]],
	["_errorMessage", "No error message provided", [""]]
];

hintSilent parseText format ["
	<t color='#FE2E2E' align='left' size='1.5'>ERROR</t><br/><br/>
	<t color='#FFFFFF' align='left' size='1.2'>%1 </t><t color='#A1A4AD' align='left'> %2</t><br/><br/>
", _function, _errorMessage];

[format ["%1 - %2. Exiting.", _function, _errorMessage], true] call ADF_fnc_log;