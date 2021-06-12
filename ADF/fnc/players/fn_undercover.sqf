/*********************************************************************************
 _____ ____  _____ 
|  _  |    \|   __|
|     |  |  |   __|
|__|__|____/|__|   
ARMA Mission Development Framework
ADF version: 2.26 / Jul 2020

Function: ADF_fnc_undercover
Author: Whiztler
Script version: 1.01

File: fn_undercover.sqf
**********************************************************************************
ABOUT
This can be used to simulate undercover operations. E.g. moving around AO's
dressed as a civilian. You are undercover when:

1. You are wearing a civilian uniform
2. You are not using a weapon (you may carry in a backpack
3. You are not wearing a combatant vest
4. You are not wearing combatant headgear.

Once you comply with above 4 conditions you will automatically be undercover. 
Opfor will no longer see you as a threat nor engage you as an enemy. In scripting
terms you are captive.

INSTRUCTIONS:
Configure the function in 'ADF_mission_settings.sqf'.
For manual execution. Spawn the script for each player that requires to be 
undercover.
If enabled in 'ADF_mission_settings.sqf' then the script also (re)fires on respawn.

REQUIRED PARAMETERS:
Object:        Player 
				
OPTIONAL PARAMETERS:
n/a
				
EXAMPLE (MANUAL EXECUTION SINGLE PLAYER - PLAYER INIT FIELD)
[this] spawn ADF_fnc_undercover;

EXAMPLE (MANUAL EXECUTION ALL PLAYERS)
{[_x] spawn ADF_fnc_undercover} forEach allPlayers;

RETURNS
Nothing
*********************************************************************************/

// Reporting
if (ADF_extRpt || {ADF_debug}) then {diag_log "ADF rpt: fnc - executing: ADF_fnc_undercover"};

// Only players
if !hasInterface exitWith {diag_log "ADF Debug: ADF_fnc_undercover - ERROR! This entity cannot execute this function!"};

// init
params ["_player"];
private _civilianUniforms = [
	"U_C_man_sport_1_F", "U_C_man_sport_2_F", "U_C_man_sport_3_F",
	"U_C_Man_casual_1_F", "U_C_Man_casual_2_F", "U_C_Man_casual_3_F", "U_C_Man_casual_4_F", "U_C_Man_casual_5_F", "U_C_Man_casual_6_F",
	"U_C_Poloshirt_blue", "U_C_Poloshirt_burgundy",	"U_C_Poloshirt_redwhite", "U_C_Poloshirt_salmon", "U_C_Poloshirt_stripped", "U_C_Poloshirt_tricolour",
	"U_C_Poor_1", "U_C_Poor_2",
	"U_BG_Guerilla2_1", "U_IG_Guerilla2_2", "U_IG_Guerilla2_3",
	"U_IG_Guerilla3_1", "U_IG_Guerilla3_2",
	"U_C_HunterBody_grn", "U_C_HunterBody_brn",
	"U_C_ConstructionCoverall_Red_F", "U_C_ConstructionCoverall_vrana_F", "U_C_ConstructionCoverall_Black_F", "U_C_ConstructionCoverall_Blue_F",
	"U_C_IDAP_Man_cargo_F", "U_C_IDAP_Man_Tee_F", "U_C_IDAP_Man_casual_F",
	"U_C_Mechanic_01_F",
	"U_C_Paramedic_01_F",
	"U_Competitor",
	"U_C_WorkerCoveralls",	
	"U_C_Journalist",
	"U_C_Scientist",
	"U_Marshal",
	"U_Rangemaster"		
];
private _civilianHeadgear = [
	"H_Hat_tan", "H_StrawHat_dark", "H_Hat_grey", "H_Hat_checker", "H_Hat_brown",
	"H_Cap_tan", "H_Cap_red", "H_Cap_grn", "H_Cap_blu", "H_Cap_blk"
];	
_civilianUniforms append ADF_civilian_uniforms;
_civilianHeadgear append ADF_civilian_headgear;
_adf_script_debug = false;

while {alive player} do {

	// Check appearance status: undercover or combatant
	if (
		currentWeapon _player isEqualTo "" && {
			(vest _player isEqualTo "" || vest _player in ADF_civilian_jackets) && {
			uniform player in _civilianUniforms && {
			(headgear _player isEqualTo "" || headgear _player in _civilianHeadgear)
		}}}			
	) then {
		// Set player as undercover
		_player setCaptive true;
		if (_adf_script_debug || ADF_debug) then {hint "ADF_fnc_undercover: UNDERCOVER"};
		
		// Monitor change in appearance
		waitUntil { // diag: 0.0068
			sleep 10;
			!(currentWeapon _player isEqualTo "") || !(vest _player isEqualTo "" && vest _player in ADF_civilian_jackets) || !(uniform player in _civilianUniforms) || !(headgear _player isEqualTo "" && headgear _player in _civilianHeadgear)
		};
		
		// Player is no longer undercover, switch to combatabt
		_player setCaptive false;
		{_x reveal [_player, 3.5]} forEach (_player nearEntities 50);	
		if (_adf_script_debug || ADF_debug) then {hint "ADF_fnc_undercover: COMBATANT"};		

	} else {
		// Set player as combatant
		_player setCaptive false;
		if (_adf_script_debug || ADF_debug) then {hint "ADF_fnc_undercover: COMBATANT"};	
		
		// Monitor chnage in appearance
		waitUntil { // diag: 0.0079
			sleep 10;
			!(currentWeapon _player isEqualTo "") || !(vest _player isEqualTo "" && vest _player in ADF_civilian_jackets) || !(uniform player in _civilianUniforms) || !(headgear _player isEqualTo "" && headgear _player in _civilianHeadgear)
		};
		
		// Player switched to undercover mode. No longer seen as combatant
		_player setCaptive true;
		if (_adf_script_debug || ADF_debug) then {hint "ADF_fnc_undercover: UNDERCOVER"};
	};
	sleep 10;
};