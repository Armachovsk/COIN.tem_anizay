/*********************************************************************************
 _____ ____  _____ 
|  _  |    \|   __|
|     |  |  |   __|
|__|__|____/|__|   
ARMA Mission Development Framework
ADF version: 2.26 / Jul 2020

Function: ADF_fnc_simpleStats
Author: Whiztler
Script version: 1.05

File: fn_simpleStats.sqf
**********************************************************************************
This function displays server/headless client statistics and information. In the 
ADF sample mission the function is activated using a radio trigger [0-0-0]. But
you can call the function from anywhere, anytime. As long as it is executed by all
connected clients.

REQUIRED PARAMETERS:
N/A

OPTIONAL PARAMETERS:
N/A

EXAMPLE:
[] spawn ADF_fnc_simpleStats;

RETURNS:
A hint on the clients' screen
*********************************************************************************/

// Reporting
if (ADF_extRpt || {ADF_debug}) then {diag_log "ADF rpt: fnc - executing: ADF_fnc_simpleStats"};

// Init
ADF_simpleStats_textServer = "";
ADF_simpleStats_textHeadless1 = "";
ADF_simpleStats_textHeadless2 = "";
ADF_simpleStats_textHeadless3 = "";
private _pause = 0.5;
private _index = 0;

while {(_index != 20)} do {
	_index = _index + 1;
	
	private _generate = {
		params ["_entity", "_name", "_display"];
		private _fps = 0;
		
		if isMultiplayer then {_fps = round (diag_fps)} else {_fps = "N/A";};
		
		_display = format [localize "STR_ADF_simpleStats1",
			_name,														// 1
			_fps, 														// 2			
			{(local _x) && (side _x == west)} count allUnits, 			// 3
			{(local _x) && (side _x == east)} count allUnits, 			// 4
			{(local _x) && (side _x == independent)} count allUnits, 	// 5
			{(local _x) && (side _x == civilian)} count allUnits 		// 6
		];

		if (_entity == 0) exitWith {ADF_simpleStats_textServer = _display; publicVariable "ADF_simpleStats_textServer"};
		if (_entity == 1) exitWith {ADF_simpleStats_textHeadless1 = _display; publicVariable "ADF_simpleStats_textHeadless1"};
		if (_entity == 2) exitWith {ADF_simpleStats_textHeadless2 = _display; publicVariable "ADF_simpleStats_textHeadless2"};
		if (_entity == 3) exitWith {ADF_simpleStats_textHeadless3 = _display; publicVariable "ADF_simpleStats_textHeadless3"};
		
	};	

	if (isDedicated || {isServer}) then {[0, "Server", ADF_simpleStats_textServer] call _generate};
	if (ADF_isHC1) then {[1, "Headless Client 1", ADF_simpleStats_textHeadless1] call _generate};
	if (ADF_isHC2) then {[2, "Headless Client 2", ADF_simpleStats_textHeadless2] call _generate};
	if (ADF_isHC3) then {[3, "Headless Client 3", ADF_simpleStats_textHeadless3] call _generate};
		
	private _display = format [localize "STR_ADF_simpleStats2",
		[(round time)] call BIS_fnc_secondsToString, 						//1
		count allUnits,														//2
		{alive _x} count (allPlayers - (entities "HeadlessClient_F")),		//3
		count allGroups														//4		
	];
		
	if hasInterface then {hintSilent parseText (_display + ADF_simpleStats_textServer + ADF_simpleStats_textHeadless1 + ADF_simpleStats_textHeadless2 + ADF_simpleStats_textHeadless3)};
	
	uiSleep _pause;
};

// Delete the display
hintSilent "";

// Delete the vars
{_x = nil} count [ADF_simpleStats_textServer, ADF_simpleStats_textHeadless1, ADF_simpleStats_textHeadless2, ADF_simpleStats_textHeadless3];