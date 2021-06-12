/*********************************************************************************
 _____ ____  _____ 
|  _  |    \|   __|
|     |  |  |   __|
|__|__|____/|__|   
ARMA Mission Development Framework
ADF version: 2.26 / Jul 2020

Function: ADF_fnc_onPlayerRespawn
Author: Whiztler
Script version: 4.03

File: fn_onPlayerRespawn.sqf
**********************************************************************************
ABOUT
This function is automatically called when a player respawns. All functionality is
configured in the mission settings/mission information.

Custom scripts can be added via: mission\events\ADF_mission_playerRespawn.sqf

PARAMETERS
The following parameters are passed
_unit: Object - Object the event handler is assigned to
_corpse: Object - Object the event handler was assigned to, aka the corpse/unit
         player was previously controlling

RETURNS:
an alive player
*********************************************************************************/

diag_log "ADF rpt: Init - executing: ADF_onPlayerRespawn.sqf";

// Init
params ["_unit", "_corpse"];

// No respawn (0) or Bird respawn (1)
if ((getNumber (missionConfigFile >> "respawn")) < 2) exitWith {
	call {
		if ADF_mod_TFAR exitWith {[_unit, true] call TFAR_fnc_forceSpectator};
		if ADF_mod_ACRE exitWith {[true] call acre_api_fnc_setSpectator};
		["Initialize", [_unit]] call BIS_fnc_EGSpectator;
	};
}; 

// Disable Spectator
["Terminate"] call BIS_fnc_EGSpectator;

//  Respawn params/vars - announce (hint) number of remaining respawn tickets per side
if ADF_Tickets then {
	[] spawn {
		if (side _unit == west) then {
			private _m = parseText format ["<t color='#6C7169' size='1.5'>%1 Logistics</t><br/><br/><t color='#A1A4AD' align='left'>Reinforcement slot:</t><t color='#FFFFFF' align='right'>%2</t><br/><t color='#1262c4' align='left'>BLUEFOR</t><t color='#A1A4AD' align='left'> slots remaining: </t><t color='#FFFFFF' align='right'>%3</t><br/>", ADF_clanName, name _unit, [west] call BIS_fnc_respawnTickets];
			_m remoteExec ["hintSilent", west, false];		
			sleep 8;
			hintSilent "";
		};

		if (side _unit == east) then {
			private _m = parseText format ["<t color='#6C7169' size='1.5'>%1 Logistics</t><br/><br/><t color='#A1A4AD' align='left'>Reinforcement slot:</t><t color='#FFFFFF' align='right'>%2</t><br/><t color='#d45454' align='left'>OPFOR</t><t color='#A1A4AD' align='left'> slots remaining: </t><t color='#FFFFFF' align='right'>%3</t><br/>", ADF_clanName, name _unit, [east] call BIS_fnc_respawnTickets];
			_m remoteExec ["hintSilent", east, false];	
			sleep 8;
			hintSilent "";
		};
	};
};

// Use the ACE3 function rather than the ADF function
if (ADF_sameGearRespawn && {!ADF_mod_ACE3}) then {
	if ADF_uniformInsignia then {
		[_unit, ""] call BIS_fnc_setUnitInsignia;
		[_unit, "CLANPATCH"] call BIS_fnc_setUnitInsignia;
	};
}; 

if ADF_uniformInsignia then {
	[_unit, ""] call BIS_fnc_setUnitInsignia;
	[_unit, "CLANPATCH"] call BIS_fnc_setUnitInsignia;
};

// Altitude Based Fatigue
if ADF_ABF then {execVM "ADF\ADF_init_abf.sqf"};

// Undercover
if ADF_undercoverPlayers then {[_unit] spawn ADF_fnc_undercover};

// Disable 3rd person view?
if (ADF_disable3PC || {ADF_disable3PV}) then {_unit spawn ADF_fnc_disable3P};

// call custom mission onPlayerRespawn:
[_unit, _corpse] call ADF_mission_onPlayerRespawn;
