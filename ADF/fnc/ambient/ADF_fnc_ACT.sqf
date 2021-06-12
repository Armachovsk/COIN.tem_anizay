/*********************************************************************************
 _____ ____  _____ 
|  _  |    \|   __|
|     |  |  |   __|
|__|__|____/|__|   
ARMA Mission Development Framework
ADF version: 2.26 / Jul 2020

Script: Ambient Civilian Traffic (ACT)
Author: Whiztler
Script version: 1.71

File: ADF_fnc_ACT.sqf
**********************************************************************************
ABOUT
ACT spawns civilian population around player positions. The script utilizes gear
(optional) from 3rd party mods such as CUP, RHS, Project Opfor, 3CB Factions.
The script is fully automated and checks server performance and adapts number of
civilian population when needed to improve performance.

A terrorist suicide bomber and a VBED function are included. You may also arm a 
percentage of the civilians. They will carry a Russian made weapon with 1 magazine.
Armed civilians have the variable "ACT_armedCiv" set to true.

Edit and inlude the following snippet into your server init script or in 
scripts\init_server.sqf

////// MANDATORY CONFIG 
ADF_ACT_vehiclesMax = 3; // Maximum number of civilian vehicles 
ADF_ACT_vehiclesRadiusSpawn = 1250; // Vehicle spawn distance from players
ADF_ACT_vehiclesRadiusTerm = 2000; // Vehicle delete distance from players
ADF_ACT_manMax = 5; // Maximum number of civilian foot mobiles
ADF_ACT_manRadiusTerm = 500; // civilian foot mobiles spawn/delete distance from players
////// OPTIONAL CONFIG 
ADF_ACT_armedCiv = true; // Arm civilians with AK's or handweapons + 1 magazine.
ADF_ACT_armedCivChance = 10; // Chance % of civilians being armed.
ADF_ACT_terrorist = false; // Enable civilian suicide bombers (true).
ADF_ACT_terroristChance = 5; // Chance % a civilian becomes a suicide bomber.
ADF_ACT_vbed = false; // Vehicle Based Explosive Device. Enable = true. Disable = false.
ADF_ACT_vbedChance = 5; // Chance % a civilian vehicle becomes a VBED.
ACT_debug = false; // ACT specific debug mode (RPT logging).
execVM "ADF\fnc\ambient\ADF_fnc_ACT.sqf";
*********************************************************************************/

// Check if the module is executed on the server and if the module needs to run at all.
if !isServer exitWith {};
if (isNil "ADF_ACT_vehiclesMax" && {isNil "ADF_ACT_manMax"}) exitWith {["ADF_fnc_ACT - Incident Report: service started but both 'ADF_ACT_vehiclesMax' and 'ADF_ACT_manMax' are NOT defined! Exciting."] call ADF_fnc_log;};
if (ADF_ACT_vehiclesMax == 0 && {ADF_ACT_manMax == 0}) exitWith {["ADF_fnc_ACT - Incident Report: service started but both 'ADF_ACT_vehiclesMax' and 'ADF_ACT_manMax' are defined as zero! Exciting."] call ADF_fnc_log;};

// Reporting
diag_log "ADF rpt: fnc - executing: ADF_fnc_ACT";

// Check if already running. If so, reset the module.
if (!isNil "ADF_ACT_execute") then {
	ADF_ACT_vTerminate = true;
	waitUntil {sleep 1; !ADF_ACT_execute};
};

// Init
ADF_ACT_execute = true;
ADF_ACT_vTerminate = false;
ADF_ACT_vehicles = [];
ADF_ACT_vehicleDrivers = [];
ADF_ACT_man = [];
ADF_ACT_vehiclesMaxOrg = ADF_ACT_vehiclesMax;
ADF_ACT_manMaxOrg = ADF_ACT_manMax;
if (isNil "ADF_ACT_terrorist") then {ADF_ACT_terrorist = false};
if (isNil "ADF_ACT_vbed") then {ADF_ACT_vbed = false};
if (isNil "ADF_ACT_armedCiv") then {ADF_ACT_armedCiv = false};
if (isNil "ADF_ACT_terroristChance") then {ADF_ACT_terroristChance = 10};
if (isNil "ADF_ACT_vbedChance") then {ADF_ACT_vbedChance = 5};
if (isNil "ADF_ACT_armedCivChance") then {ADF_ACT_armedCivChance = 10};
if (isNil "ADF_ACT_autoPopulate") then {ADF_ACT_autoPopulate = true};

// Debug reporting
if ACT_debug then {diag_log format ["ACT-Debug: INITIAL - ADF_ACT_vehiclesMax: %1", ADF_ACT_vehiclesMax]};
if ACT_debug then {diag_log format ["ACT-Debug: INITIAL - ADF_ACT_manMax: %1", ADF_ACT_manMax]};

ADF_ACT_searchRoadPos = {
	// Init
	params [
		["_position", [], [[]], [3]],
		["_radius", 1500, [0]],
		["_fixed", true, [false]],
		["_maxTries", 10, [0]]
	];
	private _road = [];
	private _i = 0;
	private _searchHeading = random 360;
	private _searchID = round (random 9999);
	private _roadRadius = 150;
	if (_fixed && {_radius < 1250}) then {_radius = 1250};
	
	// Debug reporting
	if ACT_debug then {diag_log format ["ACT-Debug: ADF_ACT_searchRoadPos - radius: %1", _radius];};

	// Find road position within the parameters (near to the random position)
	for "_i" from 1 to _maxTries do {
		private _k = [_position, _radius, _searchHeading] call ADF_fnc_randomPosMax;
		_road = [_k, _roadRadius] call ADF_fnc_roadPos;		
		if (isOnRoad _road) exitWith {_position = _road};
		_searchHeading = _searchHeading + 36;
		_radius = _radius + 100;
		_roadRadius = _roadRadius + 25;
		if (_i == _maxTries) exitWith {_position = false};
		if ACT_debug then {[format ["ADF_ACT_searchRoadPos - Search ID #%1, Searched %2 times", _searchID, _i]] call ADF_fnc_log;};
	};
	
	// Debug marker
	if ACT_debug then {[_position, false, grpNull, "road", _i] call ADF_fnc_positionDebug};
	
	// Return the road position
	_position
};

ADF_ACT_createTerrorist = {
	// Init
	params [
		"_unit",
		["_vehicle", objNull, [objNull]],
		["_isVBED", false, [true]],
		["_attack", false, [true]],
		["_exit", false, [true]],
		["_timer", 300, [0]],
		["_target", objNull, [objNull]],
		["_allAlivePlayers", [], [[]]],
		["_playerPosition", [], [[]]],
		["_actionDistance", 25, [0]],
		["_actionDistanceFar", 250, [0]],
		["_activationDistance", 7, [0]]
	];

	private _group = group _unit;
	private _allAlivePlayers = ((allPlayers - entities "HeadlessClient_F") select {alive _x && !((objectParent _x) isKindOf "Air")});
	_group setBehaviour "CARELESS";	
	_group allowFleeing 0;
	_group setSpeedMode "FULL";
	_unit enableFatigue false;
	_unit setSkill 1;

	// Add the unit to Zeus
	[_unit] call ADF_fnc_addToCurator;
	
	if _isVBED then {
		_actionDistance = 250;
		_actionDistanceFar = 500;
		_activationDistance = 15;
		
		if (isNull _vehicle) exitWith {
			ADF_ACT_man = ADF_ACT_man - [_unit];
			_group = group _unit;
			[_group] call ADF_fnc_delete;
		};
		
		{if (isOnRoad getPosATL _x) exitWith {_playerPosition = getPosATL _x}} forEach _allAlivePlayers;		
		if (_playerPosition isEqualTo []) then {_playerPosition = getPosATL (selectRandom _allAlivePlayers)};
		[_unit, ADF_ACT_vehiclesRadiusTerm + ADF_ACT_vehiclesRadiusSpawn, true, _playerPosition, _vehicle] call ADF_ACT_vehicleWaypoint;
		
		_vehicle limitSpeed 80;		
	} else {
		removeAllWeapons _unit;
		removeVest _unit;
		_unit addVest (selectRandom ["V_BandollierB_blk", "V_BandollierB_cbr", "V_BandollierB_khk", "V_HarnessO_gry", "V_HarnessO_brn", "V_HarnessOGL_brn"]);		
	};
	
	// Check distance terrorist to player
	waitUntil {
		{	
			if (((_x distance _unit) < 300) && {(speed _x) < 20}) exitWith {
				_attack = true;
				_target = _x;
			};
		} forEach _allAlivePlayers;		
		sleep 3;
	
		!alive _unit || _attack
	};

	if (!alive _unit) exitWith {};
	if (!alive _target) exitWith {[_unit] spawn ADF_ACT_createTerrorist;};
	if _isVBED then {[group _unit] call ADF_fnc_delWaypoint;};

	// Order to move the terrorist to its target
	while {alive _unit && !(_timer < 1) && !_exit} do {
		if (_isVBED && {!canMove _vehicle}) exitWith {};
		_unit moveTo (getPosATL _target);
		
		if (_target distance _unit < _actionDistance) exitWith {
			_group setCombatMode "BLUE";
			_unit setBehaviour "CARELESS";
			_unit disableAI "TARGET";
			_unit disableAI "AUTOTARGET";
			if _isVBED then {
				_vehicle forceSpeed 300;
			} else {
				_unit forceSpeed (_unit getSpeed "FAST");
				_unit allowSprint false;
				_unit setAnimSpeedCoef 1.5;
				
				// Terror call
				if (random 100 > 33) then {
					private _sound = selectRandom ["allahu_akbar_01", "allahu_akbar_02", "allahu_akbar_03", "allahu_akbar_04", "allahu_akbar_05", "allahu_akbar_06", "allahu_akbar_07", "allahu_akbar_08"];
					[_unit, [_sound, 100]] remoteExec ["say3d"];
					sleep 2.5;
					[_unit, [_sound, 100]] remoteExec ["say3d"];
				};
			};
			
			_unit doMove (getPos _target);
			waitUntil {
				sleep 0.5;
				if (_target distance _unit > (_actionDistance + 5)) exitWith {};
				(_target distance _unit < _activationDistance) || (!alive _unit)
			};			
			if (!alive _unit) exitWith {_exit = true};
			if (_target distance _unit > _actionDistance) exitWith {[_unit] spawn ADF_ACT_createTerrorist; _exit = true};
			
			// Determine the size of the explosion
			if _isVBED then {
				// VBED end of the ride.
				private _vbedPosition = getPos _vehicle;
				private _bomb = "Bo_GBU12_LGB" createVehicle _vbedPosition;
				sleep 0.15;
				private _bomb = "2Rnd_Bomb_03_F" createVehicle _vbedPosition;
				sleep 0.5;
				private _bomb = "HelicopterExploSmall" createVehicle _vbedPosition;
			} else {
				private _explosive = if (isNull objectParent _target) then {
					selectRandom ["SmallSecondary", "M_Mo_82mm_AT_LG"]
				} else {
					call {
						if ((objectParent _target) isKindOf "Car") exitWith {"HelicopterExploSmall"};
						if ((objectParent _target) isKindOf "Tank") exitWith {"HelicopterExploBig"};
						if ((objectParent _target) isKindOf "LandVehicle") exitWith {selectRandom ["HelicopterExploBig", "HelicopterExploSmall"]};
					};	
				};
				
				// S-vest does his thing
				private _bomb = createVehicle [_explosive, getPos _unit, [], 0, "CAN_COLLIDE"];			
				_unit setDamage 1;
			};
			[_unit] call ADF_fnc_delete;
		};
		
		if _exit exitWith {};
		
		if ((_target distance _unit > _actionDistanceFar) || {!alive _target}) exitWith {
			// Target player no longer alive or he got away			
			[_unit] spawn ADF_ACT_createTerrorist;
		};
		sleep 3;
		
		_timer = _timer - 3;
	};
	
	// Something went wrong. In case of VBED we'll detonate. In case of Svest we'll let them run off in despair
	if _isVBED then {
		[_unit] call ADF_fnc_delete;
		_vehicle setDamage 1;
	} else {
		if (alive _unit && (_timer < 1)) then {
			_group allowFleeing 1;
			[_unit] spawn ADF_ACT_migrate;	
		};
	};
};

ADF_ACT_createMan = {
	// Init
	params [
		["_position", [], [[]]],
		["_count", 1, [0]],
		["_isDriver", false, [true]]
	];
	private _allBuildings = [];
	private _spawnPosition = _position;
	private _spawnCount = ADF_ACT_manMax - _count;
	private _unit = objNull;
	
	_createCivilian = {
		// Init
		params [
			["_spawnPosition", [0,0,0], [[], 0]]
		];
		if (_spawnPosition isEqualType [] && {_spawnPosition isEqualTo [0,0,0]}) exitWith {objNull};
		if (_spawnPosition isEqualType 0) exitWith {objNull};
		
		private _allCivilanUniforms = ADF_civilian_uniforms call BIS_fnc_arrayShuffle;
		private _allCivilanFaces = ADF_identFace call BIS_fnc_arrayShuffle;
		private _group = createGroup civilian;
		
		// Spawn civilian		
		private _unit = _group createUnit ["c_man_1", [0,0,0], [], 0, "CAN_COLLIDE"];
		_unit allowDamage false;
		_unit setVariable ["BIS_enableRandomization", false];
		_unit setPosATL _spawnPosition;
		
		// Strip and redress the unit. 
		[_unit, true] call ADF_fnc_stripUnit;
		_unit forceAddUniform (selectRandom _allCivilanUniforms);	
		
		// Identity
		private _face = selectRandom _allCivilanFaces;
		//private _voice = selectRandom ADF_identVoice;
		[_unit, _face] remoteExec ["setFace", 0, _unit];
		//[_unit, _voice] remoteExec ["setSpeaker", 0, _unit];
		
		// Eye wear / Hats
		private _mapType = switch ADF_worldTheme do {
			case "EasternEuropean": {[20, 20]};
			case "European": {[15, 20]};
			case "MiddleEastern": {[50, 40]};
			case "Mediterranean": {[60, 60]};
			case "Tropical": {[55, 75]};
			default {[33, 45]}		
		};
		
		// Head gear
		if (random 100 < (_mapType # 0)) then {
			private _allHats = ADF_civilian_headgear call BIS_fnc_arrayShuffle;
			_unit addGoggles (selectRandom _allHats);
		};
		
		// Face wear
		if (random 100 < (_mapType # 1)) then {
			private _allGoggles = ["G_Lady_Blue", "G_Shades_Black", "G_Shades_Black", "G_Shades_Black", "G_Shades_Blue", "G_Shades_Green", "G_Shades_Red", "G_Shades_Red", "G_Shades_Red", "G_Spectacles", "G_Sport_Red", "G_Sport_Blackred", "G_Sport_Greenblack", "G_Squares_Tinted", "G_Aviator", "G_Aviator", "G_Aviator", "G_Spectacles_Tinted", "G_Sport_Checkered"];
			_allGoggles append ADF_civilian_facewear;
			_allGoggles call BIS_fnc_arrayShuffle;
			_unit addGoggles (selectRandom _allGoggles);
		};
		
		// AI Enhance mods overrides
		if ADF_mod_VCOMAI then {
			_group setVariable ["VCM_NOFLANK", true];
			_group setVariable ["VCM_NORESCUE", true];
			_group setVariable ["VCM_TOUGHSQUAD", true];
			_group setVariable ["Vcm_Disable", true]; 
			_group setVariable ["VCM_DisableForm", true]; 
			_group setVariable ["VCM_Skilldisable", true];
		};
		if ADF_mod_BCOMBAT then {(leader _group) setVariable ["bcombat_fnc_is_active", false]};
		//if (ADF_mod_ASRAI) then {};
		
		// ADF
		_group setVariable ["ADF_noHC_transfer", true];
		_group getVariable ["zbe_cacheDisabled", true];		

		// Check if terrorist option is set to true
		if (!_isDriver && {ADF_ACT_terrorist && {ADF_modded && {(random 100) < ADF_ACT_terroristChance}}}) exitWith {
			_unit allowDamage true;
			if ACT_debug then {diag_log format ["ACT-Debug: ADF_ACT_createMan _createCivilian: unit %1 volutered for s-vest duty.", _unit];};
			[_unit] spawn ADF_ACT_createTerrorist;
			_unit
		};
		
		// Arm the civilian if 'ADF_ACT_armedCiv' is set to true
		if (ADF_ACT_armedCiv && {random 100 < ADF_ACT_armedCivChance}) then {
			_allWeapons = call {
				if (ADF_mod_3CB_FACT && ADF_mod_PROPFOR) exitWith {
					selectRandom [
						["rhs_acc_dtk", "rhs_30Rnd_545x39_7N6M_AK", 30],
						["rhs_weap_akm", "rhs_30Rnd_762x39mm", 30],
						["rhs_weap_aks74u", "rhs_30Rnd_545x39_AK", 30],
						["rhs_acc_pgs64_74u", "rhs_30Rnd_545x39_7N6M_AK", 30],
						["rhs_acc_dtk1983", "rhs_30Rnd_545x39_7N6M_AK", 30],
						["rhs_acc_dtkakm", "rhs_30Rnd_762x39mm_bakelite", 30],
						["LOP_Weap_LeeEnfield", "LOP_10rnd_77mm_mag", 10],
						["UK3CB_Enfield_Rail", "UK3CB_Enfield_Mag", 10],
						["UK3CB_FNFAL_FULL", "UK3CB_FNFAL_762_20Rnd", 20]
					];
				};
				if ADF_mod_3CB_FACT exitWith {
					selectRandom [
						["rhs_acc_dtk", "rhs_30Rnd_545x39_7N6M_AK", 30],
						["rhs_weap_akm", "rhs_30Rnd_762x39mm", 30],
						["rhs_weap_aks74u", "rhs_30Rnd_545x39_AK", 30],
						["rhs_acc_pgs64_74u", "rhs_30Rnd_545x39_7N6M_AK", 30],
						["rhs_acc_dtk1983", "rhs_30Rnd_545x39_7N6M_AK", 30],
						["rhs_acc_dtkakm", "rhs_30Rnd_762x39mm_bakelite", 30],
						["UK3CB_Enfield_Rail", "UK3CB_Enfield_Mag", 10],
						["UK3CB_FNFAL_FULL", "UK3CB_FNFAL_762_20Rnd", 20]
					];
				};
				if ADF_mod_PROPFOR exitWith {
					selectRandom [
						["rhs_acc_dtk", "rhs_30Rnd_545x39_7N6M_AK", 30],
						["rhs_weap_akm", "rhs_30Rnd_762x39mm", 30],
						["rhs_weap_aks74u", "rhs_30Rnd_545x39_AK", 30],
						["rhs_acc_pgs64_74u", "rhs_30Rnd_545x39_7N6M_AK", 30],
						["rhs_acc_dtk1983", "rhs_30Rnd_545x39_7N6M_AK", 30],
						["rhs_acc_dtkakm", "rhs_30Rnd_762x39mm_bakelite", 30],
						["LOP_Weap_LeeEnfield", "LOP_10rnd_77mm_mag", 10]
					];
				};
				if ADF_mod_RHS exitWith {
					selectRandom [
						["rhs_acc_dtk", "rhs_30Rnd_545x39_7N6M_AK", 30],
						["rhs_weap_akm", "rhs_30Rnd_762x39mm", 30],
						["rhs_weap_aks74u", "rhs_30Rnd_545x39_AK", 30],
						["rhs_acc_pgs64_74u", "rhs_30Rnd_545x39_7N6M_AK", 30],
						["rhs_acc_dtk1983", "rhs_30Rnd_545x39_7N6M_AK", 30],
						["rhs_acc_dtkakm", "rhs_30Rnd_762x39mm_bakelite", 30]
					]
				};
				if ADF_mod_CUP_W exitWith {
					selectRandom [
						["CUP_arifle_AK47_Early", "CUP_30Rnd_762x39_AK47_M", 30],
						["CUP_arifle_AK74_Early", "CUP_30Rnd_545x39_AK_M", 30],
						["CUP_arifle_AK74M", "CUP_30Rnd_545x39_AK74M_M", 30],
						["CUP_arifle_AK74", "CUP_30Rnd_545x39_AK_M", 00],
						["CUP_arifle_AKM_Early", "CUP_30Rnd_762x39_AK47_bakelite_M", 00],
						["CUP_arifle_AKMS_Early", "CUP_30Rnd_762x39_AK47_bakelite_M", 00],
						["CUP_arifle_AKS", "CUP_30Rnd_762x39_AK47_M", 00],
						["CUP_arifle_AKS74U", "CUP_30Rnd_545x39_AK74_plum_M", 00],
						["CUP_arifle_AKS_Gold", "CUP_30Rnd_762x39_AK47_M", 00]
					];
				};
				// Vanilla
				selectRandom [
					["arifle_AK12_F", "30Rnd_762x39_Mag_F", 30],
					["arifle_AKM_F", "30Rnd_762x39_Mag_F", 30],
					["arifle_AKS_F", "30Rnd_545x39_Mag_F", 30],
					["arifle_AK12U_F", "30Rnd_762x39_AK12_Mag_F", 30]
				];
			};			
			_unit addMagazine _allWeapons # 1;
			_unit addWeapon _allWeapons # 0;
			_unit setVariable ["ACT_armedCiv", true];
		} else {
			_unit setVariable ["ACT_armedCiv", false];
		};
		
		// Jacket/Vest (CUP)
		if (!(ADF_civilian_jackets isEqualTo []) && {random 100 > 25}) then {_unit addVest (selectRandom ADF_civilian_jackets)};		
		
		[_unit] call ADF_fnc_heliPilotAI;
		_group allowFleeing 0.4;	

		if ACT_debug then {diag_log format ["ACT-Debug: ADF_ACT_createMan _createCivilian: Spawned %1 at position %2", _unit, _spawnPosition];};
		
		// Return the unit
		_unit
	};
	
	// Do we need to create a driver or a foot mobile?
	if (_isDriver) exitWith {
		if ACT_debug then {diag_log format ["ACT-Debug: ADF_ACT_createMan (DRIVER) - position: %1", _spawnPosition];};
		_unit = [_spawnPosition] call _createCivilian;
		if (_unit isEqualTo ObjNull) exitWith {if (ADF_Debug || {ACT_debug}) then {["ADF_ACT_createMan (DRIVER): _createCivilian returned ObjNull. Exiting"] call ADF_fnc_log;}};
		_unit allowDamage true;
		_unit
	};	
	
	for "_i" from 1 to _spawnCount do {
		if (count ADF_ACT_man > (ADF_ACT_manMax + 1)) exitWith {if (ADF_Debug || {ACT_debug}) then {[format ["ADF_ACT_createMan (FOOT MOBILE): Maximum number of man already spawned", count ADF_ACT_man]] call ADF_fnc_log;}};

		_allBuildings = nearestObjects [_position, ADF_civilian_buildings, ADF_ACT_manRadiusTerm];
		if (_allBuildings isEqualTo []) exitWith {if (ADF_Debug || {ACT_debug}) then {[format ["ADF_ACT_createMan (FOOT MOBILE): No buildings found to spawn units at %1", _position]] call ADF_fnc_log;}};
	
		_spawnPosition = getPosATL (selectRandom _allBuildings);

		if ACT_debug then {diag_log format ["ACT-Debug: ADF_ACT_createMan (FOOT MOBILE) - position: %1", _spawnPosition];};
		_unit = [_spawnPosition] call _createCivilian;
		if (_unit isEqualTo ObjNull) exitWith {if (ADF_Debug || {ACT_debug}) then {["ADF_ACT_createMan (FOOT MOBILE): _createCivilian returned ObjNull. Exiting"] call ADF_fnc_log;}};
		if ACT_debug then {diag_log format ["ACT-Debug: ADF_ACT_createMan (FOOT MOBILE): Civilian unit created: %1", _unit];};
		ADF_ACT_man pushBack _unit;
		
		// Create random waypoints. Instruct the man to visit friends in other houses (ADF_fnc_searchBuilding)
		for "_i" from 0 to (floor (3 + random 3)) do {
			private _waypointPosition = getPosATL (selectRandom _allBuildings);
			[(group _unit), _waypointPosition, 50, "MOVE", "SAFE", "WHITE", "LIMITED", "COLUMN", 5, "foot", true] call ADF_fnc_addWaypoint;
		};
		_waypoint = (group _unit) addWaypoint [_position, (count waypoints (group _unit))];
		_waypoint setWaypointType "CYCLE";
		_unit allowDamage true;
		
		// Disable collision with ACT vehicles
		[_unit] spawn ADF_ACT_vehicleCollision;
		
		// Add the unit to Zeus
		[_unit] call ADF_fnc_addToCurator;	
	};
};

ADF_ACT_vehicleCollision = {
	// Init
	params ["_unit"];
	
	private _handleDamageEH = _unit addEventHandler ["HandleDamage", {
		// Init
		params [
			"_unit",
			"_hitSelection",
			"_damage",
			"_source"
		];
		
		if (isNull _source) exitWith {0};
		if (_source in ADF_ACT_vehicleDrivers) exitWith {_unit setDamage 0};
		if (damage _unit > 0.95) exitWith {
			private _eh = _unit getVariable ["ADF_ACT_handleDamageEH", false];
			if (_eh isEqualType false) exitWith {1};
			_unit removeEventHandler ["HandleDamage", _eh];
			_damage
		};		
	}];
	
	_unit setVariable ["ADF_ACT_handleDamageEH", _handleDamageEH];
	
	waitUntil {
		{
			_unit disableCollisionWith _x;
		} count ADF_ACT_vehicles;
		
		sleep 2 + (random 3);
		!alive _unit
	};
};

ADF_ACT_carToManTransfer = {
	// Function is called by the EH that fires up when a driver disembarks its vehicle
	
	// Init
	params [
		["_vehicle", objNull, [objNull]],
		["_role", "", [""]],
		["_unit", objNull, [objNull]]
	];
		
	// switch arrays?
	[_vehicle, _unit] spawn {
		params ["_vehicle", "_unit"];
		
		// Let's check if the unit got back into the car
		sleep 30;
		if (!(isNull objectParent _unit) && {(objectParent _unit) isEqualTo _vehicle}) exitWith {false};
		
		// Remove the empty vehicle from the vehicle array and add the driver to the man array.
		ADF_ACT_vehicles = ADF_ACT_vehicles - [_vehicle];
		ADF_ACT_vehicleDrivers = ADF_ACT_vehicleDrivers - [_unit];		
		ADF_ACT_man pushBack _unit;
		if ACT_debug then {diag_log format ["ACT-Debug: ADF_ACT_carToManTransfer - Disembarked driver (%1) added to the ADF_ACT_man array", _unit];};
		
		// Check if the empty vehicle is close to any players. If so wait until this is not the case
		private _allAlivePlayers = ((allPlayers - entities "HeadlessClient_F") select {alive _x});
		private _timeOut = time + 600;
		waitUntil {
			private _exit = true;
			{if ((_vehicle distance _x) < 300) then {_exit = false}} forEach allPlayers select {((getPosATL _x) select 2) < 5};
			
			sleep 5;
			_exit || time > _timeOut
		};
		
		// Vehicle is minn 300 meters away. Lets delete it
		if ACT_debug then {diag_log format ["ACT-Debug: ADF_ACT_carToManTransfer - Driver disembarked its vehicle (%1). Deleting the vehicle.", _vehicle];};
		[_vehicle] call ADF_fnc_delete;
	};
	
	true	
};

ADF_ACT_createVehicle = {
	// Init
	params [
		["_position", [], [[]]],
		["_isVbed", false, [true]]
	];
	private _allCivilianVehicles = if (random 100 < 75) then {ADF_civilian_general_vehicles call BIS_fnc_arrayShuffle} else {ADF_civilian_commercial_vehicles call BIS_fnc_arrayShuffle};
	private _vehicleClass = selectRandom _allCivilianVehicles;
	
	// Check if we are maxed out with civilian vehicles
	if (count ADF_ACT_vehicles >= ADF_ACT_vehiclesMax) exitWith {};	
	
	// Copy the passed (player) position and find a road within the given radius of the position
	_spawnPosition = [_position, ADF_ACT_vehiclesRadiusSpawn] call ADF_ACT_searchRoadPos;
	if (_spawnPosition isEqualType true) exitWith {if (ADF_Debug || {ACT_debug}) then {[format ["ADF_ACT_createVehicle - ERROR! No road position found (%1)", _spawnPosition]] call ADF_fnc_log;}; false}; 

	// Get the direction of the road so the car spawns in the correct direction
	private _roadDirection = [_spawnPosition] call ADF_fnc_roadDir;
	
	// Create the driver
	private _unit = [_spawnPosition, 1, true] call ADF_ACT_createMan;
	if (isNil "_unit" || {_unit isEqualTo objNull || {_unit isEqualType true}}) exitWith {["ADF_ACT_createVehicle - ERROR! No driver created. Exiting"] call ADF_fnc_log; false};
	private _group = group _unit;
	
	// VBED
	if (ADF_ACT_vbed && {random 100 < ADF_ACT_vbedChance}) then {
		_isVbed = true;
		_vehicleClass = selectRandom ADF_civilian_commercial_vehicles;
	};
	
	// create the vehicle
	private _vehicle = createVehicle [_vehicleClass, _spawnPosition, [], 0, "CAN_COLLIDE"];
	_unit assignAsDriver _vehicle;
	_unit moveInDriver _vehicle;
	_vehicle setDir _roadDirection;
	
	// Set variables for silly vehicle skin randomization
	_vehicle setVariable ["BIS_enableRandomization", false];
	
	// Add an EH in case the car gets damaged and the driver disembarks
	_vehicle addEventHandler ["GetOut", {[_this # 0, _this # 1, _this # 2] spawn ADF_ACT_carToManTransfer}];
	
	// Add the new vehicle to the vehicles array
	ADF_ACT_vehicles pushBack _vehicle;
	ADF_ACT_vehicleDrivers pushBack _unit;
	
	// VBED exits here to assign terrorist orders.
	if (_isVbed) exitWith {[_unit, _vehicle, _isVbed] spawn ADF_ACT_createTerrorist; true};

	// Check if all is good and send the driver on its way else delete the service
	if ((_group isEqualTo grpNull) || {(_vehicle isEqualTo objNull)}) exitWith {
		if (ADF_Debug || {ACT_debug}) then {[format ["ADF_ACT_createVehicle - ERROR! ObjNull (%1) or GrpNull (%2)", _vehicle, _group]] call ADF_fnc_log};
		ADF_ACT_vehicles = ADF_ACT_vehicles - [_vehicle];
		[[_vehicle, _group]] call ADF_fnc_delete;		
		false
	};
	private _t = selectRandom [false, false, true, false];
	[_unit, ADF_ACT_vehiclesRadiusTerm + ADF_ACT_vehiclesRadiusSpawn, _t, _position, _vehicle] call ADF_ACT_vehicleWaypoint;
	_vehicle limitSpeed 80;	
	
	// Add the vehicle to Zeus
	[_vehicle] call ADF_fnc_addToCurator;	
	
	true
};

ADF_ACT_vehicleWaypoint = {
	// Init
	params [
		["_unit", objNull, [objNull]],
		["_radius", 5000, [0]],
		["_playerWaypoint", false, [true]],
		["_playerPosition", [], [[]], [3]],
		["_vehicle", objNull, [objNull]]
	];
	private _position = [];
	private _roadRadius = 250;
	
	
	
	// Check if the initial waypoint is around a player position
	if (_playerWaypoint) then {
		// Player waypoint it is
		_position = _playerPosition;
		_roadRadius = 350;
	} else {
		// Get a random driving waypoint in the given radius
		private _allLocations = nearestLocations [getPosWorld _unit, ["NameVillage", "NameCity", "NameCityCapital", "NameLocal", "CityCenter"], _radius];
		if (_allLocations isEqualTo []) then {
			_position = [getPos _vehicle, 2500, false, 100] call ADF_ACT_searchRoadPos;
		} else {
			_position = locationPosition (_allLocations # (floor (random (count _allLocations))));
		};
	};
	
	// Position check
	_position = [_position] call ADF_fnc_checkPosition;
	if (_position isEqualTo [0,0,0]) exitWith {["ADF_ACT_vehicleWaypoint",format ["Incorrect position passed for : %C (%2)", group _unit, _position]] call ADF_fnc_terminateScript; false};
		
	// Debug marker
	if ACT_debug then {[_position, false, grpNull, "road", 99] call ADF_fnc_positionDebug};	
	
	// Check for a valid road location. If no valid location is found then delete the vehicle plus its driver and exit the process.
	_position = [_position, _roadRadius, false, 100] call ADF_ACT_searchRoadPos;
	if !(isOnRoad _position) exitWith {
		if (ADF_Debug || {ACT_debug}) then {[format ["ADF_ACT_vehicleWaypoint - ERROR! Could not find a WP for %1 within %2 meters of %3. Deleting the vehicle + crew.", _vehicle, _roadRadius, _position]] call ADF_fnc_log};
		ADF_ACT_vehicles = ADF_ACT_vehicles - [_vehicle];
		[_vehicle] call ADF_fnc_delete;
		false
	};
	
	// We have a valid road location. Let's create the waypoint.
	private _waypoint = (group _unit) addWaypoint [_position, 0];
	_waypoint setWaypointType "MOVE";
	_waypoint setWaypointBehaviour "SAFE";
	_waypoint setWaypointCompletionRadius 25;
	_waypoint setWaypointStatements ["true", "[this] call ADF_ACT_vehicleWaypoint"];
	
	true
};

ADF_ACT_deleteMan = {
	// Init
	params [
		["_allAlivePlayers", [], [[]]]
	];
	_check_objNull = false;

	if (_allAlivePlayers isEqualTo []) then {
		_allAlivePlayers = ((allPlayers - entities "HeadlessClient_F") select {alive _x && ((getPosATL _x) select 2) < 15});
	};	
	
	{
		if (!alive _x or isNull _x) then {
			ADF_ACT_man set [_forEachIndex, objNull];
			_check_objNull = true
		}
	} forEach ADF_ACT_man;
	if (_check_objNull) then {
		[ADF_ACT_man, "ADF_ACT_man"] call ADF_ACT_cleanArray;
	};

	{
		private _unit = _x;
		private _count = 0;
		
		// Check the distance players - civilian men
		{if (_unit distance _x > ADF_ACT_manRadiusTerm) then {_count = _count + 1}} forEach _allAlivePlayers;

		if (_count == (count _allAlivePlayers)) then {
			ADF_ACT_man = ADF_ACT_man - [_unit];
			_group = group _unit;
			[_group] call ADF_fnc_delete;
		};
	} forEach ADF_ACT_man;
	true
};

ADF_ACT_deleteVehicle = {
	// Init
	params [
		["_allAlivePlayers", [], [[]]]
	];
	
	// Initial run
	if (_allAlivePlayers isEqualTo []) then {
		_allAlivePlayers = ((allPlayers - entities "HeadlessClient_F") select {alive _x && ((getPosATL _x) select 2) < 15});
	};

	{
		private _count = 0;
		private _vehicle = _x;
		
		// Check the distance players - civilian vehicles
		{
			if (_vehicle distance _x > ADF_ACT_vehiclesRadiusTerm) then {
				_count = _count + 1;
			}
		} forEach _allAlivePlayers;
		
		if (_count == (count _allAlivePlayers)) then {		
			ADF_ACT_vehicles = ADF_ACT_vehicles - [_vehicle];
			[_vehicle] call ADF_fnc_delete;
		};
	} forEach ADF_ACT_vehicles;
	
	true
};

ADF_ACT_cleanArray = {
	params [
		["_array", [], [[]]],
		["_nameArray", "", [""]]
	];
	
	if ACT_debug then {diag_log format ["ACT-Debug: ADF_ACT_cleanArray executed for: %1", _nameArray]};
	{
		if (_x isEqualTo objNull) then {
			_array deleteAt _forEachIndex;
			if ACT_debug then {diag_log format ["ACT-Debug: ADF_ACT_cleanArray - Array: %1 - Index: %2 (%3)", _nameArray, _forEachIndex, _x]};
		}
	} forEach _array;
	
	true
};

ADF_ACT_PopulationCenter = {
	// Init
	params [
		"_allAlivePlayers"
	];
	private _allNearestLocations = [];
	
	// Check if a player is near a population center
	{
		private _nearestLocation = [getPosWorld _x, ADF_ACT_manRadiusTerm, ["NameVillage", "NameCity", "NameCityCapital"]] call ADF_fnc_allLocations;	
		if !(_nearestLocation isEqualTo []) exitWith {
			_allNearestLocations append _nearestLocation;			
		};
	} forEach _allAlivePlayers;
	
	if !(_allNearestLocations isEqualTo []) then {
		private _locationSize = selectMax ((_allNearestLocations # 0) # 4);
		if ACT_debug then {hint format ["location: %1 (size: %2)", ((_allNearestLocations # 0) # 1), _locationSize]};
		call {
			if (_locationSize > 399) exitWith {ADF_ACT_manMax = ADF_ACT_manMax + 3};
			if (_locationSize > 299) exitWith {ADF_ACT_manMax = ADF_ACT_manMax + 2};
			if (_locationSize > 199) exitWith {ADF_ACT_manMax = ADF_ACT_manMax + 1};
		};
	} else {
		ADF_ACT_manMax = ADF_ACT_manMaxOrg;
	};
	true
};

ADF_ACT_migrate = {
	// Init
	params [
		"_unit"
	];
	
	private _endPosition = [getPosWorld _unit, 5000, random 360] call ADF_fnc_randomPosMax;
	if !(isNull objectParent _unit) then {_endPosition = [getPos _vehicle, 5000, false, 100] call ADF_ACT_searchRoadPos;};
	private _timeOut = time + 300; // 5 minutes
	[group _unit] call ADF_fnc_delWaypoint; 
	_unit doMove _endPosition;	

	waitUntil {
		sleep 1 + (random 1);
		(_unit distance _endPosition < 10) || time > _timeOut
	};
	
	if (isNull objectParent _unit) then {
		[_unit] call ADF_fnc_delete;
	} else {
		[objectParent _unit] call ADF_fnc_delete;
		[_unit] call ADF_fnc_delete;
	};
};

// Start the ACT activation cycle. Checks and executes every 10 secs. In case of server performance decrease a performance manager
// kicks in to decrease spawned civilians or terminate ACT all together.
[] spawn {
	
	diag_low_fps = 0;
	private _sunRiseSunSet = date call BIS_fnc_sunriseSunsetTime;
	private _dayTime = if (daytime > (_sunRiseSunSet # 0) && {daytime < ((_sunRiseSunSet # 1) + 0.5)}) then {true} else {false};
	
	waitUntil {
		// Init the player array. Repopulate every cycle. Airborne / fast traveling players will be ignore for spawn positions
		private _allAlivePlayers = ((allPlayers - entities "HeadlessClient_F") select {alive _x && (((getPosATL _x) select 2) < 15) && ((speed _x) < 70)});
		private _cyclePause = 10;
		private _fps = diag_fps;
		private _diag_time = diag_tickTime;
		
		if (ADF_ACT_vehiclesMax > 0) then {[_allAlivePlayers] call ADF_ACT_deleteVehicle};
		if (ADF_ACT_manMax > 0) then {[_allAlivePlayers] call ADF_ACT_deleteMan};
		if ACT_debug then {diag_log format ["ACT-Debug: ********** ACT LOOP ****************************** FPS: %1", _fps]};
		
		// Clean the arrays - remove ObjNul's
		[ADF_ACT_man, "ADF_ACT_man"] call ADF_ACT_cleanArray;
		[ADF_ACT_vehicles, "ADF_ACT_vehicles"] call ADF_ACT_cleanArray;
		
		// Auto populate - auto population is (large) villages and cities when performance is sufficient
		if (ADF_ACT_autoPopulate && {_dayTime && {_fps > 40}}) then {
			if (_fps > 45) then {
				if (ADF_ACT_vehiclesMax > 0 && {(ADF_ACT_vehiclesMax <= (ADF_ACT_vehiclesMaxOrg * 2))}) then {ADF_ACT_vehiclesMax = ADF_ACT_vehiclesMax + 1};
				if (ADF_ACT_manMax <= (ADF_ACT_vehiclesMaxOrg * 5)) then {[_allAlivePlayers] call ADF_ACT_PopulationCenter};
				_cyclePause = 15;
			} else {	
				if (ADF_ACT_vehiclesMax > 0 && {(ADF_ACT_vehiclesMax <= floor (ADF_ACT_vehiclesMaxOrg * 1.5))}) then {ADF_ACT_vehiclesMax = ADF_ACT_vehiclesMax + 1};
				if (ADF_ACT_manMax <= (ADF_ACT_manMaxOrg * 3)) then {[_allAlivePlayers] call ADF_ACT_PopulationCenter};
			};				
		};
		
		// Any server FPS over 30 is considered smooth gameplay with some frames to spare for ACT.
		if (_fps > 30) then {
			{
				private _player = _x;
				private _count_vehicles = 0;
				private _count_men = 0;
				if ACT_debug then {diag_log format ["ACT-Debug: ACT LOOP - ADF_ACT_vehiclesMax: %1 - ADF_ACT_vehicles: %2", ADF_ACT_vehiclesMax, count ADF_ACT_vehicles]};
				if (ADF_ACT_vehiclesMax > 0 ) then {					
					{
						if (_x distance _player < ADF_ACT_vehiclesRadiusTerm) then {
							_count_vehicles = _count_vehicles + 1
						}
					} forEach ADF_ACT_vehicles;
					
					if (_count_vehicles < ADF_ACT_vehiclesMax) then {
						if ACT_debug then {diag_log format ["ACT-Debug: ACT LOOP - _count_vehicles: %1", _count_vehicles]};
						[getPosWorld _player] call ADF_ACT_createVehicle;
					};				
				};
				
				if ACT_debug then {diag_log format ["ACT-Debug: ACT LOOP - ADF_ACT_manMax: %1 - ADF_ACT_man: %2", ADF_ACT_manMax, count ADF_ACT_man]};
				if (ADF_ACT_manMax > 0) then {						
					{
						if (_x distance _player < ADF_ACT_manRadiusTerm) then {
							_count_men = _count_men + 1
						}
					} forEach ADF_ACT_man;
					
					if (_count_men < ADF_ACT_manMax) then {
						if ACT_debug then {diag_log format ["ACT-Debug: ACT LOOP - _count_men: %1", _count_men]};
						[(getPosWorld _player), _count_men, false] call ADF_ACT_createMan;
					};
				};				
			} forEach _allAlivePlayers;
			
			diag_low_fps = 0;
		
		// In case FPS < 30 then we'll start the performance management cycle to reduce ACT load.
		} else {			
			
			diag_low_fps = diag_low_fps + 1;
			
			// Performance management. In case of prolonged low FPS, the ACT function will terminate.			
			call {		
				if (diag_low_fps <= 3) exitWith {
					_cyclePause = 7;
					if ACT_debug then {diag_log format ["ACT-Debug: ACT LOOP - FPS < 3. diag_low_fps: %1. Cycle pause: 20 secs.", diag_low_fps]};
					
					// Reset civilian population value to the default numbers
					ADF_ACT_vehiclesMax = ADF_ACT_vehiclesMaxOrg;
					ADF_ACT_manMax = ADF_ACT_manMaxOrg;	
				};
				if (diag_low_fps <= 5) exitWith {
					_cyclePause = 6;
					if ACT_debug then {diag_log format ["ACT-Debug: ACT LOOP - FPS < 5. diag_low_fps: %1. Cycle pause: 20 secs.", diag_low_fps]};
					
					// Cancel "auto populate" to improve performance
					ADF_ACT_autoPopulate = false;				
				};					
				if (diag_low_fps <= 10) exitWith {
					_cyclePause = 5;
					if ACT_debug then {diag_log format ["ACT-Debug: ACT LOOP - FPS < 10. diag_low_fps: %1. Cycle pause: 30 secs.", diag_low_fps]};
				};			
				if (diag_low_fps > 30) exitWith {
					// Performance still low after prolonged time. Start the ACT termination process.
					_cyclePause = 0; 
					diag_log ""; ["ADF_fnc_ACT - Incident Report: Low server FPS for 30 cycles. Terminating ACT."] call ADF_fnc_log; diag_log "";
					ADF_ACT_vTerminate = true;
					ADF_ACT_vehiclesMax = 0;
					ADF_ACT_manMax = 0;
				};
				if (diag_low_fps > 20) exitWith {
					_cyclePause = 5; 
					diag_log ""; ["ADF_fnc_ACT - Incident Report: Low server FPS for 20+ cycles. Cycle pause: 5 secs."] call ADF_fnc_log; diag_log "";
					ADF_ACT_manMax = 0;
				};
				if (diag_low_fps > 10) exitWith {
					_cyclePause = 15;
					diag_log ""; ["ADF_fnc_ACT - Incident Report: Low server FPS for 10+ cycles. Cycle pause: 15 secs."] call ADF_fnc_log; diag_log "";
				};
			};	
		};	
	
		if ACT_debug then {diag_log format ["ACT-Debug: Loop perf diag: %1 secs.", diag_tickTime - _diag_time]};
		sleep _cyclePause;
		ADF_ACT_vTerminate
	};
	
	// ACT has been terminated.
	// Start civilian immigration process. Next step is cleaning up.
	{[_x] spawn ADF_ACT_migrate} forEach (ADF_ACT_vehicles + ADF_ACT_man);
	private _timer = 0;
	
	// Clean up remaining civilan foot mobiles and civilian vehicles. After max. 5 minutes all ACT units will be deleted.
	waitUntil {
		if ACT_debug then {diag_log format ["ACT-Debug: ACT LOOP - Termination Cleanup. Vehicles remaining: %1 -- Foot mobiles remaining: %2", count ADF_ACT_vehicles, count ADF_ACT_man]};
		private _allAlivePlayers = ((allPlayers - entities "HeadlessClient_F") select {alive _x});
		
		if !(ADF_ACT_vehicles isEqualTo []) then {
			[_allAlivePlayers] call ADF_ACT_deleteVehicle;
			if (_timer > 300) then {[ADF_ACT_vehicles] call ADF_fnc_delete};
		};
		if !(ADF_ACT_man isEqualTo []) then {
			[_allAlivePlayers] call ADF_ACT_deleteMan;
			if (_timer > 300) then {[ADF_ACT_man] call ADF_fnc_delete};
		};		
		
		sleep 30;
		_timer = _timer + 30;
		(ADF_ACT_vehicles isEqualTo [] && ADF_ACT_man isEqualTo [])
	};
	
	// Give the server 2 minutes to cool down
	sleep 120;
	
	// Restart?
	if (diag_fps > 35) exitWith {
		ADF_ACT_vehiclesMax = ADF_ACT_vehiclesMaxOrg;
		ADF_ACT_manMax = ADF_ACT_manMaxOrg;
		ADF_ACT_vTerminate = false;
		execVM "ADF\fnc\ambient\ADF_fnc_ACT.sqf";
	};
	
	// No restart, seems the server is still struggling. ACT has been deactivated and all ACT units have deleted. 
	// Log the incident in the server RPT
	diag_log "---------------------------------------------------------------------------------------------------";
	["ADF_fnc_ACT - Incident Report: SERVICE TERMINATED"] call ADF_fnc_log;
	diag_log "---------------------------------------------------------------------------------------------------";
	
	// Module has stopped. lets set the var to false in case of a module restart.
	ADF_ACT_execute = false;
};

diag_log "ADF rpt: fnc - loaded: ADF_fnc_ACT";