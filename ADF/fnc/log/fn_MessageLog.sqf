/*********************************************************************************
 _____ ____  _____ 
|  _  |    \|   __|
|     |  |  |   __|
|__|__|____/|__|   
ARMA Mission Development Framework
ADF version: 2.26 / Jul 2020

Function: ADF_fnc_messageLog
Author: Whiztler
Script version: 1.03

File: fn_messageLog.sqf
**********************************************************************************
This function is exclusively used by ADF_fnc_messageParser.
*********************************************************************************/

// Reporting
if (ADF_extRpt || {ADF_debug}) then {diag_log "ADF rpt: fnc - executing: ADF_fnc_messageLog"};

if !hasInterface exitWith {};

// Init
params ["_caller", "_message"];

// Create the Message Parser logbook entry (if enabled)
private _time = [dayTime] call BIS_fnc_timeToString;
private _logTime = format ["Log: %1", _time];
private _compiledText = format ["<br/><br/><font color='#9DA698' size='14'>From: %1<br/>Time: %2</font><br/><br/><font color='#6C7169'>------------------------------------------------------------------------------------------</font><br/><br/><font color='#6C7169'>%3</font><br/><br/>", _caller, _time, _message];
player createDiaryRecord [ADF_messageParserLogName, [_logTime, _compiledText]];

true