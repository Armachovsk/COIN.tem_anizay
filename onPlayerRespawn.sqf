/*********************************************************************************
 _____ ____  _____ 
|  _  |    \|   __|
|     |  |  |   __|
|__|__|____/|__|   
ARMA Mission Development Framework
ADF version: 2.26 / Jul 2020

Script: mission events
Author: Whiztler
Script version: 1.03

File: onPlayerRespawn.sqf
**********************************************************************************


PARAMETERS
_newUnit      Object - respawned player
_oldUnit      Object - player corpse

RETURNS:
an alive player
*********************************************************************************/

params [
	"_newUnit",
	"_oldUnit"
];
diag_log format ["ADF rpt: respawning client: %1 (old unit: %2)", _newUnit, _oldUnit];
private _timeOut = time + 30;

waitUntil {
	diag_log format ["« C O I N »   onPlayerRespawn.sqf - Unit %1 respawning. Waiting for player to initialize (%2)...", _newUnit, isPlayer _newUnit];
	sleep 1;
	isPlayer _newUnit || time > _timeOut
};

if (isNil "_newUnit" || time > _timeOut) exitWith {diag_log format ["« C O I N »   onPlayerRespawn.sqf - Unit %1 does not exist or did not initialize. Terminating ADF_mission_playerRespawn.", _newUnit];};

if (
	(_oldUnit getVariable ["COIN_isLeadership", false]) || 
	{(_newUnit getVariable ["COIN_isLeadership", false]) || 
	{(COIN_leadership == _oldUnit) || 
	{(COIN_leadership == _newUnit) || 
	{(COIN_leadership == player)}}}}
) then {
	diag_log "« C O I N »   onPlayerRespawn.sqf - Player is COIN_leadership";
	COIN_leadership = player;
	publicVariableServer "COIN_leadership";
	player setVariable ["COIN_isLeadership", true, 2];
	call COIN_fnc_assignViper;
	call COIN_fnc_assignKnight;
	call COIN_fnc_assignTomcat;
	call COIN_fnc_assignClipper;
	call COIN_fnc_assignSidesMissionSkip;
	diag_log "« C O I N »   onPlayerRespawn.sqf - Support command re-assigned";
};

setUnitLoadout COIN_loadout;
	
diag_log format ["« C O I N »   onPlayerRespawn.sqf - Player (%1) has respawned.", _newUnit];