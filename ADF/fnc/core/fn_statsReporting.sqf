/*********************************************************************************
 _____ ____  _____ 
|  _  |    \|   __|
|     |  |  |   __|
|__|__|____/|__|   
ARMA Mission Development Framework
ADF version: 2.26 / Jul 2020

Function: ADF_fnc_statsReporting
Author: Whiztler
Script version: 1.06

File: fn_statsReporting.sqf
**********************************************************************************
ABOUT
Server/HC stats reporting. Executed on the server and all connected headless
clients. Stamps the following information in the RTP:

ADF rpt: Server PERF - Total players: 37 | Total local AI's: 197
ADF rpt: Server PERF - Elapsed time: 41:33 | SVR FPS: 42 | SVR Min FPS: 38 

REQUIRED PARAMETERS:
N/A

OPTIONAL PARAMETERS:
0. Number:      Default cycle time in seconds (default: 60)
1. String:      Full name of reporting entity (e.g. "Server" or "Headless Client")
                default: "Server"   
2. String:      Abbreviation of reporting entity (e.g. "Svr" or "HC")
                default: "svr"

EXAMPLES USAGE IN SCRIPT:
[60, "Headless Client", "HC"] spawn ADF_fnc_statsReporting;

EXAMPLES USAGE IN EDEN:
N/A

DEFAULT/MINIMUM OPTIONS
[] spawn ADF_fnc_statsReporting;    

RETURNS:
Nothing
*********************************************************************************/

// Reporting
if (ADF_extRpt || {ADF_debug}) then {diag_log "ADF rpt: fnc - executing: ADF_fnc_statsReporting"};

// Exits for playable clients in multiplayer mode. Runs in single player/local mode
if (hasInterface && isMultiplayer) exitWith {};

// Init
params [
	["_pause", 60, [0]],
	["_entity", "Server", [""]],
	["_entityAbbr", "svr", [""]]
];

waitUntil {
	// Performance params and check umber of AI and player units
	private _fps = round (diag_fps);	
	private _headless	= count (entities "HeadlessClient_F");
	private _alivePlayers	= {alive _x} count allPlayers;
	private _aiUnits = ({local _x} count allUnits) - (_alivePlayers + _headless);
	
	// Determine reporting cycle based on FPS
	if (_aiUnits < 0)  then {_aiUnits = 0};
	if (_fps < 30) then {_pause = 30};
	if (_fps < 20) then {_pause = 20};
	if (_fps < 10) then {_pause = 10};
	
	private _message_1 = format ["ADF rpt: %1 PERF - Total players: %2 | Total local AI's: %3", _entity, _alivePlayers - _headless, _aiUnits];
	private _message_2 = format ["ADF rpt: %1 PERF - Elapsed time: %2 | %3 FPS: %4 | %3 Min FPS: %5", _entity, [(round time)] call BIS_fnc_secondsToString, _entityAbbr, _fps, round (diag_fpsmin)];
	
	// Stamp the RPT
	diag_log "─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────";
	diag_log _message_1;
	diag_log _message_2;
	diag_log "─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────";
	
	// Display the performance data in system chat when the debug mode is on.
	if (ADF_Debug && (_entity == "Server")) then {
		_message_1 remoteExec ["systemChat", -2, false];
		_message_2 remoteExec ["systemChat", -2, false];
	};
	
	// Pause the cycle
	uiSleep _pause;
	false
};

