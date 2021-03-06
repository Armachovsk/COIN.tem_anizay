/*********************************************************************************
 _____ ____  _____ 
|  _  |    \|   __|
|     |  |  |   __|
|__|__|____/|__|   
ARMA Mission Development Framework
ADF version: 2.26 / Jul 2020

Script: Server init for connected clients
Author: Whiztler
Script version: 1.27

File: initPlayerServer.sqf
*********************************************************************************
DO NOT edit this file. To set-up and configure your mission, edit the files in
the  'mission\'  folder.
*********************************************************************************/

params ["_player", "_jipped"];
if (isNil "ADF_clanName") then {ADF_clanName = ""};

if isMultiplayer then {diag_log format ["ADF rpt: Init - executing: initPlayerServer.sqf | player: %1 | JIP: %2", _player, _jipped]
} else {
	diag_log "ADF rpt: Init - executing: initPlayerServer.sqf";
};

// Add player to curator object list
{_x addCuratorEditableObjects [[_player], true]} forEach allCurators;  

// Apply loadout Textures to JIP clients if needed
if (ADF_modded || {!_jipped}) exitWith {};
if (ADF_clanName == "Two Sierra") then {	
	[_player] spawn {
		params ["_player"];
		sleep 20; // wait till unit has geared up
		private _t = if (toUpper worldName == "CHERNARUS_SUMMER" || toUpper worldName == "WOODLAND_ACR") then {"\a3\characters_f\BLUFOR\Data\clothing_wdl_co.paa"} else {"\a3\characters_f\BLUFOR\Data\clothing_sage_co.paa"};
		_player setObjectTextureGlobal [0, _t];
		[_player, ""] call BIS_fnc_setUnitInsignia;
		[_player, "CLANPATCH"] call BIS_fnc_setUnitInsignia;
	};
};
if (ADF_clanName == "Wolfpack" && {ADF_wolfpack_nite_op}) then {
	[_player] spawn {
		params ["_player"];
		sleep 20; // wait till unit has geared up
		_player setObjectTextureGlobal [0, "\A3\Characters_F\Common\Data\basicbody_black_co.paa"];
		[_player, ""] call BIS_fnc_setUnitInsignia;
		[_player, "CLANPATCH"] call BIS_fnc_setUnitInsignia;
	};
};