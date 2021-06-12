/*********************************************************************************
 _____ ____  _____ 
|  _  |    \|   __|
|     |  |  |   __|
|__|__|____/|__|   
ARMA Mission Development Framework
ADF version: 2.26 / Jul 2020

Script: Ambient Combat Manager
Author: Whiztler
Script version: 1.21

Game type: N/A
File: fn_ambientCombatManager.sqf
**********************************************************************************
ABOUT
This script creates ambient combat in a predefined area. The area can be defined
by a marker, an object, position array, etc.

The script has the following options:
- Ambient artillery/grenade explosions
- Ambient vehicle explosions
- Ambient small arms fire
- side selection enemy (west, east, independent)
- Intensity (from 1 to 10). 10 is very intense and most resource heavy
- Duration. Can be set to run from anywhere from 1 minute to several hours
- Cancel function. Run ADF_cancel_ACM = true on the server to cancel ACM.
- Server FPS sensitive. When the server FPS drops below 20, ACM will pause.

Small arms fire units is not visible so make sure the center position + radius
is not too close to players.

You have have multiple ACM's active (e.g. different locations, duration, two
different sides). Although AMC is performance friendly, it is recommended not
to spawn more than 2 ACM's at the time.

INSTRUCTIONS:
Place a marker or object on the map that represents the center of the ACM radius.
Execute (spawn) from the server or HC. THIS FUNCTION MUST BE SPAWNED!!

REQUIRED PARAMETERS:
0. Position:    The center of the position where ACM is active. Marker, object,
                trigger or position array [x,y,z]

OPTIONAL PARAMETERS:
1. Number:      Radius in meters around the position. Size of the AO.
                Default: 750        
2. Number:      Time in MINUTES that ACM will be active on the position. You can
                have multiple ACM's with different positions / times        
3. Bool:        Ambient artillery/40 mike
                - true - enable ambient artillery (default)
                - false - disable ambient artillery
4. Bool:        Random vehicle explosions
                - true - enable random vehicle explosions (default)
                - false - disable random vehicle explosions     
5. Bool:        Small arms fire
                - true - enable Small arms fire (default)
                - false - disable Small arms fire
6. Side:        east, west, independent. Default: east
7. Number:      Intensity. Default: 2
                - 10 - Maximum intensity setting
                - 1 - minimum intensity setting
8. Number:      Distance from players for ambient combat activity to spawn
                Default: 150

EXAMPLES USAGE IN SCRIPT:
// Example with a marker and 500 meter radius, 15 minutes:
["ACM_markerarker", 500, 15, true, true, true, east, 3, 150] spawn ADF_fnc_ambientCombatManager;

EXAMPLES USAGE IN EDEN:
// Example around position player and 800 meter radius, 25 minutes, medium intensity:
[position player, 800, 25, true, true, true, east, 5, 300] spawn ADF_fnc_ambientCombatManager;

DEFAULT/MINIMUM OPTIONS
["Ambient_AO"] spawn ADF_fnc_ambientCombatManager;

RETURNS:
Bool (success flag)
*********************************************************************************/

// Reporting
if (time < 180 || {ADF_extRpt || {ADF_debug}}) then {diag_log "ADF rpt: fnc - executing: ADF_fnc_ambientCombatManager"};

// Local function: create random explosion 
private _ACM_explosion = {
	params [["_position", [0, 0, 0], [[]], [3]]];
	
	private _bombClass = selectRandom ["Bo_GBU12_LGB", "M_Mo_82mm_AT_LG", "R_80mm_HE", "G_40mm_HE", "HelicopterExploBig"];
	private _explosion = createVehicle [_bombClass, [_position # 0, _position # 1, (_position # 2) + 3], [], 0, "CAN_COLLIDE"];
	
	if ADF_debug then {
		private _markerarker = createMarker [ format["p_%1%2", round (random 500), round (_position # 1)], _position];
		_markerarker setMarkerSize [.7, .7];
		_markerarker setMarkerShape "ICON";
		_markerarker setMarkerType "hd_dot";
		_markerarker setMarkerColor "ColorYellow";
		[format ["_ACM_explosion - explosion created at position: %1", _position]] call ADF_fnc_log;
	};
	
	true
};

// local function: create a temp agent for the purpose of machine gun fire simulation
private _ACM_createAgent = {
	// init
	params [
		"_side",
		["_ammo", "", [""]],
		["_unitClass", "", [""]]
	];
	
		// Check side
	switch _side do {
		case east: {_ammo = "200Rnd_65x39_belt_Tracer_Green"; _unitClass = "o_soldier_f"};
		case west: {_ammo = "200Rnd_65x39_belt_Tracer_Red"; _unitClass = "b_soldier_f"};
		case independent: {_ammo = "200Rnd_65x39_belt_Tracer_Yellow"; _unitClass = "i_soldier_f"};
		default {_ammo = "200Rnd_65x39_belt_Tracer_Green"; _unitClass = "o_soldier_f"};
	};
	
	// Create the agent
	private _unit = createAgent [_unitClass, [0, 0, 0], [], 0, "CAN_COLLIDE"];	
	_unit allowDamage false;
	_unit setCaptive true;
	_unit hideObject true;	

	// FSM aspects
	_unit disableAI "anim";
	_unit disableAI "move";
	_unit disableAI "target";
	_unit disableAI "autotarget";
	_unit setBehaviour "careless";
	_unit setCombatMode "blue";
	
	// Disarm and arm the agent
	removeAllWeapons _unit;
	private _weapon = "FakeWeapon_moduleTracers_F";
	_unit addMagazine _ammo;
	_unit addWeapon _weapon;
	_unit selectWeapon _weapon;
	_unit switchMove "amovpercmstpsraswrfldnon";
	
	_unit
};


// local function: small arms flare and smoke simulation
private _ACM_smallArms = {
	// init
	params [
		"_unit",
		["_position", [0, 0, 0], [[]], [3]]
	];

	_unit setPosATL _position;
	
	if ADF_debug then {
		private _marker = createMarker [format ["p_%1%2", round (random 500), round (_position # 1)], _position];
		_marker setMarkerSize [.7, .7];
		_marker setMarkerShape "ICON";
		_marker setMarkerType "hd_dot";
		_marker setMarkerColor "ColorWhite";
		[format ["_ACM_smallArms - small arms agent at position: %1", _position]] call ADF_fnc_log;
	};		
	
	_unit setVehicleAmmo 1;
	
	// Smoke effects
	if ((random 100) > 80) then {
		private _effect = (selectRandom ["SmokeShell", "SmokeShellRed", "SmokeShellGreen"]) createVehicle _position;		
	};
	
	// flares
	if (((date # 3) > 18 || (date # 3) < 4.5) && {(random 100) > 95}) then {
		private _flareRadius = selectRandom [50, 500, 175, 700, 250];
		private _flareCount = selectRandom [1, 2, 3, 2, 1];
		[_position, _flareRadius, "white", _flareCount] spawn ADF_fnc_ambientFlare;		
	};	
	
	private _pause = 0.05 + random 0.1;
	private _dirAdjust = -5 + random 10;
	private _axis = 30 + random 60;
	
	_unit setDir (random 360);		
	[_unit, _axis, 0] call BIS_fnc_setPitchBank;
	
	sleep 0.1;
	
	_time = time + 0.1 + random 0.9;
	
	while {time < _time} do {
		_unit forceWeaponFire [primaryWeapon _unit, "MANUAL"];
		sleep _pause;
		_unit setDir (direction _unit + _dirAdjust);
		[_unit, _axis, 0] call BIS_fnc_setPitchBank;
		if (random 1 > 0.95) then {sleep (2 * _pause)};
	};
	
	true
};


// local function - vehicle explosion simulation	
private _ACM_vehicle = {
	params [
		["_position", [0, 0, 0], [[]], [3]],
		["_radius", 750, [0]]
	];
	
	_position = [_position, _radius] call ADF_fnc_roadPos;
	
	private _vehicleClass = selectRandom ["O_mRAP_02_F", "O_Truck_02_covered_F", "O_mBT_02_arty_F", "O_APC_Tracked_02_cannon_F"];
	private _vehicle = createVehicle [_vehicleClass, _position, [], 0, "CAN_COLLIDE"];
	_vehicle setDamage 1;
	
	if ADF_debug then {
		private _marker = createMarker [format ["p_%1%2", round (random 500), round (_position # 1)], _position];
		_marker setMarkerSize [.7, .7];
		_marker setMarkerShape "ICON";
		_marker setMarkerType "hd_dot";
		_marker setMarkerColor "ColorRed";
		[format ["_ACM_vehicle - vehicle created at position: %1", _position]] call ADF_fnc_log;
	};
	
	sleep 60;
	[_vehicle] call ADF_fnc_delete;
	
	true
};	
	
// init
params [
	["_position", [0, 0, 0], ["", [], objNull, grpNull]], 
	["_radius", 750, [0]],
	["_minutes", 20, [0]],
	["_artillery", true, [true]],
	["_vehicleEffect", true, [true]],
	["_smallArmsEffect", true, [true]],
	["_effectSide", east, [west]],
	["_intensity", 2, [0]],
	["_distancePlayer", 150, [0]]
];
ADF_cancel_ACM = false;
private _pause = 2;
private _unit = objNull;
diag_log format ["ADF rpt: Starting ADF_fnc_ACM. Params: %1, %2, %3, %4, %5, %6, %7, %8, %9", _position, _radius, _minutes, _artillery, _vehicleEffect, _smallArmsEffect, _effectSide, _intensity, _distancePlayer];

// Check the position (marker, array, etc.)
_position = [_position] call ADF_fnc_checkPosition;
// convert minutes to seconds
private _seconds = _minutes * 60;

// Cycle time
if (_seconds < 120) then {
	_pause = (_intensity / 10) * 2;		
} else {
	_pause = (_intensity / 10) + 2;
};	

// Intensity	
_intensity = 1 - (_intensity / 10);
if (_intensity < 0.1) then {_intensity = 0.1};
if (_intensity > 0.8) then {_intensity = 0.8};	

// Create agent for small arms function
if (_smallArmsEffect) then {_unit = [_effectSide] call _ACM_createAgent};

if ADF_debug then {
	private _marker = createMarker [format ["m_%1%2", round (random 9999), round (random 9999)], _position];
	_marker setMarkerSize [_radius, _radius];
	_marker setMarkerShape "ELLIPSE";
	_marker setMarkerBrush "Solid";
	_marker setMarkerColor "ColorGreen";
};	

for "_i" from _seconds to 0 step -1 do {
	private _diagTime = diag_tickTime;
	private _randomNumber = random 100;
	private _fps	= 0;

	// Select a random position within the pre-defined radius
	private _randomPos = [_position, _radius, random 360] call ADF_fnc_randomPos;
	
	// Check FPS in multiplayer
	if isMultiplayer then {_fps = diag_fps} else {_fps = 25};
	
	// No effects when FPS drops below 20
	if (_fps > 20) then {
		// Check if no players are near
		if ({alive _x && _randomPos distance _x < _distancePlayer} count allPlayers == 0) then {
			// Select a random effect
			if (_artillery && {_randomNumber > 50} && {(random 1) > _intensity}) then {[_randomPos] call _ACM_explosion};
			if (_vehicleEffect && {_randomNumber < 20} && {((random 1) > (_intensity + 0.1))}) then {[_randomPos, _radius] spawn _ACM_vehicle};
			if (_smallArmsEffect && {((random 1) > (_intensity - 0.1))}) then {[_unit, _randomPos] call _ACM_smallArms};
		};
	} else {
		_pause = 5; // FPS below 20. Sleep 5 seconds.
	};
	
	// Reporting
	if ADF_debug then {
		hintSilent format ["ACM Timer: %1 left (FPS: %2)", [((_i) / 60) + .01, "HH:MM"] call BIS_fnc_timeToString, _fps];
		[format ["ADF_fnc_ambientCombatManager - Cycle diag: %1", diag_tickTime]] call ADF_fnc_log;			
	};	
	if ADF_extRpt then {
		diag_log format ["ADF rpt: ACM Timer - %1 left (FPS: %2)", [((_i) / 60) + .01, "HH:MM"] call BIS_fnc_timeToString, _fps];
	};
	if ADF_debug then {[format ["ADF_fnc_ambientCombatManager - Diag time to execute function: %1", diag_tickTime - _diagTime]] call ADF_fnc_log};
	
	// Cancel function for scripts. To cancel ACM: ADF_cancel_ACM = true; // (server)
	if (ADF_cancel_ACM) exitWith {if (ADF_debug || ADF_extRpt) then {[format ["ADF Debug: ADF_fnc_ACM - ACM cancelled at cycle %1", _i]] call ADF_fnc_log}};
	
	sleep _pause;
};

// Delete the small arms agent if small arms was activated.
if (_smallArmsEffect) then {deleteVehicle _unit; deleteGroup (group _unit); _unit = nil};
if (ADF_debug || ADF_extRpt) then {format ["ADF_fnc_ambientCombatManager finished."] call ADF_fnc_log};