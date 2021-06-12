/*********************************************************************************
 _____ ____  _____ 
|  _  |    \|   __|
|     |  |  |   __|
|__|__|____/|__|   
ARMA Mission Development Framework
ADF version: 2.26 / Jul 2020

Function: TFAR communication detection
Author: Whiztler
Script version: 1.19

File: fn_commDetect.sqf
**********************************************************************************
ABOUT
This function is executed by the TFAR_fnc_addEventHandler. The function reveals
position of players that can be heard communication by enemy ai's. The level of
knowledge of a player by an enemy unit depends on distance, loudness and the 
amount of information that the enemy already has about player units.

INSTRUCTIONS:
Execute via the TFAR event handler:
["MyID", "OnSpeak", {[_this select 0] call ADF_fnc_commDetect}, player] call TFAR_fnc_addEventHandler;

REQUIRED PARAMETERS:
0. Player:      The player the TFAR EH gets loaded onto

OPTIONAL PARAMETERS:
N/A     

EXAMPLES USAGE IN SCRIPT:
N/A

EXAMPLES USAGE IN EDEN:
N/A

DEFAULT/MINIMUM OPTIONS
N/A

RETURNS:
Bool (success flag)
*********************************************************************************/

// Reporting
if (ADF_extRpt || {ADF_debug}) then {diag_log "ADF rpt: fnc - executing: ADF_fnc_commDetect"};

// Let's check if we need to execute this function. If no TFAR is active then terminate.
if !(hasInterface) exitWith {["ADF_fnc_commDetect - Wrong client. Should only run on player clients."] call ADF_fnc_log; false}; 
if !(ADF_mod_TFAR) exitWith {["ADF_fnc_commDetect - No TFAR present. Exiting"] call ADF_fnc_log; false}; 

// Init
params [
	["_playerUnit", player, [objNull]]
];

// Vars check
if !(_playerUnit isKindOf "CAManBase" || isPlayer _playerUnit || alive _playerUnit) exitWith {[format ["ADF_fnc_commDetect - passed object does not seem to be a playable unit: '%1' (%2). Exiting", _playerUnit, typeOf _playerUnit], true] call ADF_fnc_log; false};

// Exit if the unit is isolated from traffic
if ((vehicle _playerUnit) call TFAR_fnc_isVehicleIsolated) exitWith {if ADF_debug then {["ADF_fnc_commDetect - Isolated client. Exiting"] call ADF_fnc_log;}};

private _units = _playerUnit nearEntities [["CAManBase", "Man"], (TF_speak_volume_meters * 1.45) - 3.5]; // minus 3.5 to compensate for whisper mode ADF 2.02
_units = _units - (playableUnits + switchableUnits + entities "HeadlessClient_F");
if ADF_debug then {private _msg = format ["ADF_fnc_commDetect - Enemies close to %1: %2", name _playerUnit, _units]; systemChat _msg; _msg call ADF_fnc_log;};

{
	if !([side _x, side _playerUnit] call BIS_fnc_sideIsEnemy) exitWith {if ADF_debug then {["ADF_fnc_commDetect - Only friendly sides detected. Exiting"] call ADF_fnc_log;}};
	if (_x knowsAbout _playerUnit > 2.95) exitWith {if ADF_debug then {private _msg = format ["ADF_fnc_commDetect - Enemy (%1) is already aware of player (%2). Exiting", _x, _playerUnit]; systemChat _msg; _msg call ADF_fnc_log;}};
	if ((alive _x) && (_x knowsAbout _playerUnit < 2.45)) then {		

		private _i = 1;
		private _enemy = _x;
		if ADF_debug then {private _msg = format ["ADF_fnc_commDetect - %1 knows about %2 (%3)", _enemy, name _playerUnit, _enemy knowsAbout _playerUnit]; systemChat _msg; _msg call ADF_fnc_log;};

		//Check if the AI has a radio
		if ([_enemy] call TFAR_fnc_haveSWRadio) then {_i = _i + 1};
		
		// If the AI knows about the player and has a radio then increase knowledge
		{if ((_enemy knowsAbout _x > 1.5) && ([_enemy] call TFAR_fnc_haveSWRadio)) then {_i = _i + 1}} forEach playableUnits + switchableUnits; 		

		// Is the AI able to alert others? If so increase knowledge
		if (!isNull ((leader (group _enemy)) findNearestEnemy (getPos leader (group _enemy)))) then { 
			private _leader = (leader (group _enemy)) findNearestEnemy (getPos leader (group _enemy));
			if (_leader distance _enemy < 1500) then {_i = _i + 1};					
		};
		
		// Debug
		if ADF_debug then {private _msg = format["'%1' is revealed to '%2' at level: %3 (%4).",name _playerUnit, _x, _x knowsAbout _playerUnit, _i]; [_msg] call ADF_fnc_log; systemChat _msg;};
		
		// Reveal the location of the speaker on the machine that owns the AI and instruct the AI to investigate if he knows the location of the speaker source.
		private _owner = groupOwner (group _enemy);
		[_enemy, [_playerUnit, _i]] remoteExec ["reveal", _owner];
		if ((_enemy knowsAbout _x > 2) && (canMove _enemy) && (isNull objectParent _enemy)) then {
			[group _enemy, getPosWorld _playerUnit, 20, "MOVE", "AWARE", "WHITE", "FULL", "DIAMOND", 5, "foot", false] remoteExec ["ADF_fnc_addWaypoint", _owner];			
		};
	};
} forEach _units;

// Result: 0.690131 ms // Cycles: 1449/10000 // Code: this call ADF_fnc_commDetect

true