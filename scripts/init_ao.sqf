// Prevent double accidental execution in the event the HC jip's or when the server and HC have both set 'ADF_HC_execute' to true
if (!isNil "init_AO_Exec") then {
	if isMultiplayer then {
		private _entity = "A headless client";
		if isDedicated then {_entity = "The server"};
		private _errorMessage = format ["ERROR: %1 has tried to execute mission scripts (init_ao.sqf) twice. To avoid issues, please restart the mission!", _entity];
		_errorMessage remoteExecCall ["systemChat", -2];
		[_errorMessage, true] call ADF_fnc_log;
	} else {
		["Init - init_ao.sqf has already been executed! Terminating init_ao.sqf for this client.", true] call ADF_fnc_log
	};
};
init_AO_Exec = true; publicVariable "init_AO_Exec";

diag_log "ADF rpt: Init - executing: scripts/init_AO.sqf"; // Reporting. Do NOT edit/remove

COIN_fnc_aoSpawn = {
	// Init
	params [
		["_ao_marker", "mAO_1", [""]],
		["_ao_ratio", 2, [0]],
		["_ao_base", false, [true]],
		["_ao_baseMarker", "", [""]],
		["_ao_staticsBase", [], [[]]],
		["_ao_aa_sites", [], [[]]]
	];
	private _diag_time = diag_tickTime;
	COIN_selectedRoadPos = [[0, 0, 0]];
	private _ao_size = (markerSize _ao_marker) # 0;
	diag_log "--------------------------------------------------------------------------------------------------------";
	diag_log format ["« C O I N »   COIN_fnc_aoSpawn - Preparing AO -- Nr: %1 -- Size/spawn ratio: %2 -- Army base: %3", _ao_marker, _ao_ratio, _ao_base];
	diag_log "--------------------------------------------------------------------------------------------------------";

	#include "init_vehicles.sqf"
	
	// Vehicle spawn location (road position)
	_fnc_roadPos = {
		// Init
		params [
			["_ao_marker", "mAO_12", [""]],
			["_radius", 1000, [0]]
		];
		private _road = [];
		private _position = [];
		private _direction = random 360;
		private _roadRadius = 150;
		private _exit = false;

		// Find road position within the parameters (near to the random position)
		for "_i" from 1 to 250 do {
			private _posMax = [getMarkerPos _ao_marker, _radius, _direction] call ADF_fnc_randomPosMax;
			_road = [_posMax, _roadRadius] call ADF_fnc_roadPos;
			
			if (isOnRoad _road) then {
				_position = _road;
				{if ((_position distance2D _x) > 10) exitWith {_exit = true};} forEach COIN_selectedRoadPos;
			};
			
			if _exit exitWith {
				// Add the position to the blacklist
				COIN_selectedRoadPos pushBack _position;
				_position
			};
			_direction = _direction + 36;
			_radius = _radius + 50;
			_roadRadius = _roadRadius + 15;
			if (_i == 249) exitWith {_position = getMarkerPos _ao_marker};
		};		
		
		// Return the road position
		_position
	}; // _fnc_roadPos

	// AO HAS ARMY BASE
	if (_ao_base) then {
	
		// ENTIRE AO IS AN ARMY BASE
		if (_ao_marker isEqualTo _ao_baseMarker) then {

			// Populate army base statics. 100% of the statics get populated.			
			if !(_ao_staticsBase isEqualTo []) then {
				_group = createGroup east; // army
				{
					_x setDamage 0;
					private _unit = _group createUnit ["o_Soldier_F", getMarkerPos _ao_marker, [], 0, "NONE"];
					_unit moveInGunner _x;
					[_unit] call ADF_fnc_redressArmy_inf;			
				} forEach _ao_staticsBase;
				COIN_ao_groups pushBack _group;
				if isServer then {[_group] call ADF_fnc_addToCurator;} else {[_group] remoteExecCall ["ADF_fnc_addToCurator", 2];};
			};
			
			// Spawn Armor Sites, 50% spawn chance
			_group = createGroup east;
			for "_i" from 1 to (2 * _ao_ratio) do {
				if (random 100 > 50) then {
					_position = [getMarkerPos _ao_marker, _ao_size * 0.2, _ao_size * 1.10, 10, 0, 0, 0, _ao_aa_sites, [0,0,0]] call BIS_fnc_findSafePos;
					if (_position isEqualTo [0,0,0]) exitWith {diag_log format ["« C O I N »   COIN_fnc_aoSpawn - Could not find an suitable site for a tank. AO: %1", _ao_marker];};
					_ao_aa_sites pushBack [_position, 4];
					_position set [2, 0];					
					_vehicle = [_position, random 360, selectRandom _army_tank_heavy, _group, "ADF_fnc_redressArmy_crew"] call ADF_fnc_createCrewedVehicle;
					doStop [commander (_vehicle # 0), driver (_vehicle # 0)];
					(_vehicle # 0) setVectorUp surfaceNormal position (_vehicle # 0);
					COIN_ao_vehicles pushBack (_vehicle # 0);
				};			
			};
			if ((count units _group) > 0) then {COIN_ao_groups pushBack _group;} else {[_group] call ADF_fnc_delete};

			// Spawn army patrol and garrison groups
			for "_i" from 1 to (2 * _ao_ratio) do {
				private _group = [_ao_marker, east, selectRandom [4, 2, 4, 8, 2, 4], selectRandom [true, false], _ao_size, 4, "MOVE", "SAFE", "RED", "LIMITED", "FILE", 5, false, "ADF_fnc_redressArmy_inf", ""] call ADF_fnc_createFootPatrol;
				COIN_ao_groups pushBack _group;
				if ADF_missionTest then {diag_log format ["« C O I N »   COIN_fnc_aoSpawn - ARMY BASE AO - ADF_fnc_createFootPatrol - %1", _group];};
				private _group = [_ao_marker, east, 8, false, _ao_size, false, "ADF_fnc_redressArmy_inf", "", -1, selectRandom [true, false]] call ADF_fnc_createGarrison;
				COIN_ao_groups pushBack _group;
				if ADF_missionTest then {diag_log format ["« C O I N »   COIN_fnc_aoSpawn - ARMY BASE AO - ADF_fnc_createGarrison - %1", _group];};
				private _group = [_ao_marker, east, 8, false, _ao_size, false, "ADF_fnc_redressArmy_inf", "", -1, selectRandom [true, false]] call ADF_fnc_createGarrison;
				COIN_ao_groups pushBack _group;
				if ADF_missionTest then {diag_log format ["« C O I N »   COIN_fnc_aoSpawn - ARMY BASE AO - ADF_fnc_createGarrison - %1", _group];};
				// FPS check
				private _pause = 0;
				private _cycle = 0;
				private _time = time;
				while {diag_fps < 20} do {
					_pause = _pause + 0.15;
					_cycle = _cycle + 1;
					sleep _pause;
					diag_log format ["« C O I N »   COIN_fnc_aoSpawn - Spawn army patrol and garrison groups - FPS spawn delay cycle # %1 -- FPS: %2 -- delay: %3 secs.",_cycle, round diag_fps, _pause];
					if (time > _time + (5 * 60)) exitWith {diag_log format ["« C O I N »   COIN_fnc_aoSpawn - Spawn army patrol and garrison groups - FPS: %1 -- Breaking out after 5 minutes. No recovery from low FPS", round diag_fps];}
				};
			};
				
		// para's
		[_ao_marker, _ao_size] spawn {
			// init
			params [
				"_ao_marker",
				"_ao_size"
			];
			
			// 50% chance
			if (random 100 < 50 && !ADF_missionTest) exitWith {};
			
			_TKA_created = [_ao_marker, east, _ao_size * 1.2, ["MAN", "STATICWEAPON"]] call ADF_fnc_countRadius;		
			
			// Check alive TK units. If < 50% alive then activate para's	
			waitUntil {
				sleep 2;
				_TKA_actual = [_ao_marker, east, _ao_size * 1.2, ["MAN", "STATICWEAPON"]] call ADF_fnc_countRadius;
				COIN_ao_spawned && (_TKA_actual < (_TKA_created / 2))
			};
			
			// Create para's
			#include "init_vehicles.sqf"
			
			COIN_fnc_TKApara = {
				params ["_group"];
				COIN_ao_groups pushBack _group;
				private _leader = leader _group;
				_leader setSkill 1;
				_group allowFleeing 0;
				private _timeOut = time + 240;
				waitUntil {
					sleep 1; 
					isTouchingGround _leader || time > _timeOut
				}; 
				[_group, getPos leader _group, 300, 5, "SAD", "COMBAT", "RED", "LIMITED", "FILE", 5, true, [5,50,150]] call ADF_fnc_footPatrol;
			};
			
			[selectRandom COIN_ambientAirSpawn, _ao_marker, selectRandom _army_heli_trp, 3, "ADF_fnc_redressArmy_inf", "COIN_fnc_TKApara"] spawn ADF_fnc_createPara;	
		};
			
		// ARMY BASE AND INSURGENTS AO		
		
		} else {
		
			// Populate army base statics
			if (_ao_staticsBase isEqualTo []) exitWith {};
			private _i = 0;
			private _group = createGroup east; // army
			{
				_x setDamage 0;
				private _unit = _group createUnit ["o_Soldier_F", getMarkerPos _ao_marker, [], 0, "NONE"];
				_unit moveInGunner _x;
				if ADF_missionTest then {diag_log format ["« C O I N »   COIN_fnc_aoSpawn - Army turrets -- Index: %1 -- Adding %2 to turret %3 -- Turrets populated: %4", _i, _unit, _x, count _ao_staticsBase];};
				[_unit] call ADF_fnc_redressArmy_inf;				
				_i = _i + 1;
			} forEach _ao_staticsBase;
			
			COIN_ao_groups pushBack _group;
			if isServer then {[_group] call ADF_fnc_addToCurator;} else {[_group] remoteExecCall ["ADF_fnc_addToCurator", 2];};
			
			// Create and populate insurgents statics.
			private _turrets = [_ao_marker, _ao_size, true, _army_Static_HMG] call ADF_fnc_createRooftopTurrets;
			if !(_turrets isEqualTo []) then {
				private _group = createGroup east; // insurgents turret gunners				
				{
					if (_forEachIndex > 10) then {private _group = createGroup east;};
					if (_forEachIndex > 20) then {private _group = createGroup east;};
					if (_forEachIndex > 30) then {private _group = createGroup east;};
					_x setDamage 0;
					private _unit = _group createUnit ["o_Soldier_F", getMarkerPos _ao_marker, [], 0, "NONE"];
					_unit moveInGunner _x;
					[_unit] call ADF_fnc_redressInsurgents;
				} forEach _turrets;
				COIN_ao_groups pushBack _group;
				if isServer then {[_group] call ADF_fnc_addToCurator;} else {[_group] remoteExecCall ["ADF_fnc_addToCurator", 2];};
			};
			
			// Spawn armor sites, 35% spawn chance
			_group = createGroup east;
			for "_i" from 1 to _ao_ratio do {
				if (random 100 > 65) then {
					_position = [getMarkerPos _ao_baseMarker, 0, ((markerSize _ao_baseMarker) # 0) * 1.25, 10, 0, 0, 0, _ao_aa_sites, [0,0,0]] call BIS_fnc_findSafePos;
					if (_position isEqualTo [0,0,0]) exitWith {diag_log format ["« C O I N »   COIN_fnc_aoSpawn - Could not find an suitable site for a tank. AO: %1",_ao_marker];};
					_ao_aa_sites pushBack [_position, 4];
					_position set [2, 0];					
					_vehicle = [_position, random 360, selectRandom _army_tank_heavy, _group, "ADF_fnc_redressArmy_crew"] call ADF_fnc_createCrewedVehicle;
					doStop [commander (_vehicle # 0), driver (_vehicle # 0)];
					(_vehicle # 0) setVectorUp surfaceNormal position (_vehicle # 0);
					COIN_ao_vehicles pushBack (_vehicle # 0);
				};			
			};
			if ((count units _group) > 0) then {COIN_ao_groups pushBack _group;} else {[_group] call ADF_fnc_delete};

			
			// Spawn army patrol and garrison groups
			for "_i" from 1 to _ao_ratio do {
				private _ao_baseMarkerSize = ((markerSize _ao_baseMarker) # 0) * 1.10; // + 10%
				private _group = [_ao_baseMarker, east, 8, false, _ao_baseMarkerSize, false, "ADF_fnc_redressArmy_inf", "", 4, true] call ADF_fnc_createGarrison;				
				COIN_ao_groups pushBack _group;
				if ADF_missionTest then {diag_log format ["« C O I N »   COIN_fnc_aoSpawn - ARMY BASE AND INSURGENTS AO - Army - ADF_fnc_createGarrison - %1", _group];};
				private _group = [_ao_baseMarker, east, selectRandom [4, 2], selectRandom [true, false], _ao_baseMarkerSize, 4, "MOVE", "SAFE", "RED", "LIMITED", "FILE", 5, false, "ADF_fnc_redressArmy_inf", ""] call ADF_fnc_createFootPatrol;
				COIN_ao_groups pushBack _group;
				if ADF_missionTest then {diag_log format ["« C O I N »   COIN_fnc_aoSpawn - ARMY BASE AND INSURGENTS AO -Army -  ADF_fnc_createFootPatrol - %1", _group];};
				// FPS check
				private _pause = 0;
				private _cycle = 0;
				private _time = time;
				while {diag_fps < 20} do {
					_pause = _pause + 0.15;
					_cycle = _cycle + 1;
					sleep _pause;
					diag_log format ["« C O I N »   COIN_fnc_aoSpawn - Spawn army patrol and garrison groups - FPS spawn delay cycle # %1 -- FPS: %2 -- delay: %3 secs.",_cycle, round diag_fps, _pause];
					if (time > _time + (5 * 60)) exitWith {diag_log format ["« C O I N »   COIN_fnc_aoSpawn - Spawn army patrol and garrison groups - FPS: %1 -- Breaking out after 5 minutes. No recovery from low FPS", round diag_fps];}
				};
			};
			
			// Spawn insurgents patrol and garrison groups
			for "_i" from 1 to (_ao_ratio * 2) do {
				private _group = [_ao_marker, east, 8, false, _ao_size, false, "ADF_fnc_redressInsurgents", "", 4, true] call ADF_fnc_createGarrison;
				COIN_ao_groups pushBack _group;
				if ADF_missionTest then {diag_log format ["« C O I N »   COIN_fnc_aoSpawn - ARMY BASE AND INSURGENTS AO -Insurg -  ADF_fnc_createGarrison - %1", _group];};
				private _group = [_ao_marker, east, 8, false, _ao_size, false, "ADF_fnc_redressInsurgents", "", 4, true] call ADF_fnc_createGarrison;
				COIN_ao_groups pushBack _group;
				if ADF_missionTest then {diag_log format ["« C O I N »   COIN_fnc_aoSpawn - ARMY BASE AND INSURGENTS AO -Insurg -  ADF_fnc_createGarrison - %1", _group];};
				private _group = [_ao_marker, east, selectRandom [4, 2, 4 , 8, 2, 4], selectRandom [true, false], _ao_size, 4, "MOVE", "SAFE", "RED", "LIMITED", "FILE", 5, false, "ADF_fnc_redressInsurgents", ""] call ADF_fnc_createFootPatrol;
				COIN_ao_groups pushBack _group;
				if ADF_missionTest then {diag_log format ["« C O I N »   COIN_fnc_aoSpawn - ARMY BASE AND INSURGENTS AO -Insurg -  ADF_fnc_createFootPatrol - %1", _group];};
				// FPS check
				private _pause = 0;
				private _cycle = 0;
				private _time = time;
				while {diag_fps < 20} do {
					_pause = _pause + 0.15;
					_cycle = _cycle + 1;
					sleep _pause;
					diag_log format ["« C O I N »   COIN_fnc_aoSpawn - Spawn insurgents patrol and garrison groups - FPS spawn delay cycle # %1 -- FPS: %2 -- delay: %3 secs.",_cycle, round diag_fps, _pause];
					if (time > _time + (5 * 60)) exitWith {diag_log format ["« C O I N »   COIN_fnc_aoSpawn - Spawn insurgents patrol and garrison groups - FPS: %1 -- Breaking out after 5 minutes. No recovery from low FPS", round diag_fps];}
				};
			};
		};
		
	// INSURGENTS AO
	
	} else {
		// Create and populate insurgents statics.
		private _turrets = [_ao_marker, _ao_size, true, _army_Static_HMG] call ADF_fnc_createRooftopTurrets;
		if !(_turrets isEqualTo []) then {
			private _group = createGroup east; // insurgents turret gunners
			{
				if (_forEachIndex > 10) then {private _group = createGroup east;};
				if (_forEachIndex > 20) then {private _group = createGroup east;};
				if (_forEachIndex > 30) then {private _group = createGroup east;};
				_x setDamage 0;
				private _unit = _group createUnit ["o_Soldier_F", getMarkerPos _ao_marker, [], 0, "NONE"];
				_unit moveInGunner _x;
				[_unit] call ADF_fnc_redressInsurgents;
			} forEach _turrets;		
			COIN_ao_groups pushBack _group;
			if isServer then {[_group] call ADF_fnc_addToCurator;} else {[_group] remoteExecCall ["ADF_fnc_addToCurator", 2];};		
		};
	
		// Spawn armor sites, 20% spawn chance
		_group = createGroup east;
		for "_i" from 1 to (2 * _ao_ratio) do {
			if (random 100 > 80) then {
				_position = [getMarkerPos _ao_marker, _ao_size * 0.2, _ao_size * 1.5, 10, 0, 0, 0, _ao_aa_sites] call BIS_fnc_findSafePos;
				_ao_aa_sites pushBack [_position, 4];				
				_position set [2, 0];				
				_vehicle = [_position, random 360, selectRandom _army_allArmor, _group, "ADF_fnc_redressArmy_crew"] call ADF_fnc_createCrewedVehicle;
				doStop [commander (_vehicle # 0), driver (_vehicle # 0)];
				(_vehicle # 0) setVectorUp surfaceNormal position (_vehicle # 0);
				COIN_ao_vehicles pushBack (_vehicle # 0);
			};			
		};
		if ((count units _group) > 0) then {COIN_ao_groups pushBack _group;} else {[_group] call ADF_fnc_delete};

	
		// Spawn insurgents patrol groups
		for "_i" from 1 to (_ao_ratio * 3) do {
			private _group = [_ao_marker, east, selectRandom [4, 2, 4, 8, 2, 4], selectRandom [true, false], _ao_size, 4, "MOVE", "SAFE", "RED", "LIMITED", "FILE", 5, false, "ADF_fnc_redressInsurgents", ""] call ADF_fnc_createFootPatrol;
			COIN_ao_groups pushBack _group;
			if ADF_missionTest then {diag_log format ["« C O I N »   COIN_fnc_aoSpawn - INSURGENTS AO -Insurg -  ADF_fnc_createFootPatrol - %1", _group];};
			// FPS check
			private _pause = 0;
			private _cycle = 0;
			private _time = time;
			while {diag_fps < 20} do {
				_pause = _pause + 0.15;
				_cycle = _cycle + 1;
				sleep _pause;
				diag_log format ["« C O I N »   COIN_fnc_aoSpawn - Spawn insurgents patrol groups - FPS spawn delay cycle # %1 -- FPS: %2 -- delay: %3 secs.",_cycle, round diag_fps, _pause];
				if (time > _time + (5 * 60)) exitWith {diag_log format ["« C O I N »   COIN_fnc_aoSpawn - Spawn insurgents patrol groups - FPS: %1 -- Breaking out after 5 minutes. No recovery from low FPS", round diag_fps];}
			};
		};

				
		// Spawn insurgents garrison groups
		for "_i" from 1 to (_ao_ratio * 3) do {
			private _group = [_ao_marker, east, 8, false, _ao_size, false, "ADF_fnc_redressInsurgents", "", 4, true] call ADF_fnc_createGarrison;
			COIN_ao_groups pushBack _group;
			if ADF_missionTest then {diag_log format ["« C O I N »   COIN_fnc_aoSpawn - INSURGENTS AO -Insurg -  ADF_fnc_createGarrison - %1", _group];};
			// FPS check
			private _pause = 0;
			private _cycle = 0;
			private _time = time;
			while {diag_fps < 20} do {
				_pause = _pause + 0.15;
				_cycle = _cycle + 1;
				sleep _pause;
				diag_log format ["« C O I N »   COIN_fnc_aoSpawn - Spawn insurgents garrison groups - FPS spawn delay cycle # %1 -- FPS: %2 -- delay: %3 secs.",_cycle, round diag_fps, _pause];
				if (time > _time + (5 * 60)) exitWith {diag_log format ["« C O I N »   COIN_fnc_aoSpawn - Spawn insurgents garrison groups - FPS: %1 -- Breaking out after 5 minutes. No recovery from low FPS", round diag_fps];}
			};
		};

	}; // if else _ao_base
	
	// Unarmed vehicles (cars / trucks)
	for "_i" from 1 to _ao_ratio do {
		if (_ao_size < 750) then {_ao_size = 750};
		private _className = selectRandom _army_allCars;
		private _position = [_ao_marker, _ao_size * 1.25] call _fnc_roadPos;
		private _vehicle = [_position, "", east, _className, _ao_size * 2, 4, "MOVE", "SAFE", "RED", "NORMAL", 25, "ADF_fnc_redressArmy_inf"] call ADF_fnc_createVehiclePatrol;
		(_vehicle # 0) limitSpeed 70;
		COIN_ao_groups pushBack _vehicle # 2;
		COIN_ao_vehicles pushBack (_vehicle # 0);
		if ADF_missionTest then {diag_log format ["« C O I N »   COIN_fnc_aoSpawn - Unarmed vehicles (cars / trucks) -  ADF_fnc_createVehiclePatrol - %1", _vehicle select 0];};
	};

	// Technicals
	for "_i" from 0 to _ao_ratio do {
		if (_ao_size < 750) then {_ao_size = 750};
		private _class = selectRandom _army_tech;
		private _faction = "ADF_fnc_redressArmy_inf";
		if !_ao_base then {
			_faction = "ADF_fnc_redressInsurgents";
			_class = selectRandom _civ_tech;
		};		
		private _position = [_ao_marker, _ao_size * 1.25] call _fnc_roadPos;
		private _vehicle = [_position, "", east, _class, _ao_size * 4, 4, "MOVE", "SAFE", "RED", "NORMAL", 25, _faction] call ADF_fnc_createVehiclePatrol;
		(_vehicle # 0) limitSpeed 70;
		COIN_ao_groups pushBack _vehicle # 2;
		COIN_ao_vehicles pushBack (_vehicle # 0);
		if ADF_missionTest then {diag_log format ["« C O I N »   COIN_fnc_aoSpawn - Technicals -  ADF_fnc_createVehiclePatrol - %1", _vehicle select 0];};
	};

	// APC's and such
	if (_ao_ratio > 1) then {
		for "_i" from 1 to 2 do {
			if (_ao_size < 750) then {_ao_size = 750};
			private _position = [_ao_marker, _ao_size * 1.25] call _fnc_roadPos;
			private _vehicle = [_position, "", east, selectRandom _army_allAPC, _ao_size * 4, 4, "MOVE", "SAFE", "RED", "NORMAL", 25, "ADF_fnc_redressArmy_crew"] call ADF_fnc_createVehiclePatrol;
			(_vehicle # 0) limitSpeed 70;
			COIN_ao_groups pushBack _vehicle # 2;
			COIN_ao_vehicles pushBack (_vehicle # 0);
			if ADF_missionTest then {diag_log format ["« C O I N »   COIN_fnc_aoSpawn - APC's -  ADF_fnc_createVehiclePatrol - %1", _vehicle select 0];};
		};

		// Armor
		if (_ao_ratio > 2) then {
			private _position = [_ao_marker, _ao_size * 1.25] call _fnc_roadPos;
			private _vehicle = [_position, "", east, selectRandom _army_allArmor, 3500, 4, "MOVE", "SAFE", "RED", "NORMAL", 25, "ADF_fnc_redressArmy_crew"] call ADF_fnc_createVehiclePatrol;
			(_vehicle # 0) limitSpeed 70;
			COIN_ao_groups pushBack _vehicle # 2;
			COIN_ao_vehicles pushBack (_vehicle # 0);
			if ADF_missionTest then {diag_log format ["« C O I N »   COIN_fnc_aoSpawn - Armor -  ADF_fnc_createVehiclePatrol - %1", _vehicle select 0];};
		};
	};		

	COIN_ao_spawned = true;
	COIN_selectedRoadPos = nil;
	if !isServer then {
		publicVariableServer "COIN_ao_spawned";
		publicVariableServer "COIN_ao_groups";
		publicVariableServer "COIN_ao_vehicles";
	};
	
	// Add intel option to AO vehicles
	{[_x, [], true, 20, "", "COIN_fnc_intelFound"] call ADF_fnc_searchIntel;} forEach COIN_ao_vehicles;
	diag_log"« C O I N »   COIN_fnc_aoSpawn - Intel added to units and vehicles";
	diag_log "--------------------------------------------------------------------------------------------------------";
	diag_log format ["« C O I N »   COIN_fnc_aoSpawn -  - AO groups array: %1", COIN_ao_groups];
	diag_log format ["« C O I N »   COIN_fnc_aoSpawn -  - AO vehicles array: %1", COIN_ao_vehicles];
	diag_log "--------------------------------------------------------------------------------------------------------";
	[format ["COIN_fnc_aoSpawn - Diag time to execute function: %1", diag_tickTime - _diag_time]] call ADF_fnc_log;
}; // COIN_fnc_aoSpawn

ADF_fnc_mapPatrolRespawn = {
	// Init
	params [
		["_vehicle", objNull, [objNull]],
		["_position", [0, 0, 0], [[]], [3]]
	];

	// Store vars
	_vehicle setVariable ["ADF_vehicleRespawnPos", _position];
	_vehicle setVariable ["ADF_vehicleRespawnClass", typeOf _vehicle];

	// Add the EH
	_vehicle addEventHandler [
		"killed",
		{
			_this spawn {
				// Init
				params ["_vehicle"];
				private _position = _vehicle getVariable ["ADF_vehicleRespawnPos", [0, 0, 0]];
				private _class = _vehicle getVariable ["ADF_vehicleRespawnClass", "O_G_Offroad_01_armed_F"];

				// Delete the EH and start the respawn delay
				_vehicle removeEventHandler ["killed", 0];
				
				// Check if there is a player close to the spawn position or wait 15 min.
				private _time = time;
				waitUntil {
					sleep 5;
					((allPlayers findIf {_x distance _position > 500}) != -1) || (time > _time + (15 * 60))
				};

				// Spawn vehicle patrol
				_vehicle = [_position, "", east, _class, 7500, 4, "MOVE", "SAFE", "RED", "NORMAL", 25, "ADF_fnc_redressArmy_inf"] call ADF_fnc_createVehiclePatrol;
	
				// Add intel
				[_unit, [], true, 20, "", "COIN_fnc_intelFound"] call ADF_fnc_searchIntel;	

				// Re-add the EH/Var
				[(_vehicle # 0), _position] call ADF_fnc_mapPatrolRespawn;
				diag_log format ["« C O I N »   ADF_fnc_mapPatrolRespawn - %1 has respawned succesfully", _vehicle];
			};
		}
	];
	true
}; // ADF_fnc_mapPatrolRespawn

// Determine amount of ambient road Opfor spawn locations
private _ao_ambientVehicles = 0;
{if ("mVeh_" in _x) then {_ao_ambientVehicles = _ao_ambientVehicles + 1;}} forEach allMapMarkers;

// Spawn ambient opfor vehicle patrols
_ambientVeh = {
	params ["_ao_ambientVehicles", "_wait"];
	#include "init_vehicles.sqf"
	
	sleep _wait;
	for "_i" from 1 to _ao_ambientVehicles do {
		private _position = format ["mVeh_%1", _i];
		private _vehicle = [_position, "", east, selectRandom _army_tech, 7500, 4, "MOVE", "SAFE", "RED", "NORMAL", 25, "ADF_fnc_redressArmy_inf"] call ADF_fnc_createVehiclePatrol;
		(_vehicle # 0) setVectorUp surfaceNormal position (_vehicle # 0);
		(_vehicle # 0) setVariable ["BIS_enableRandomization", false];
		(_vehicle # 0) limitSpeed 70;
		[_vehicle # 2] spawn ADF_fnc_waypointCombat;
		[_vehicle # 0, getMarkerPos _position] call ADF_fnc_mapPatrolRespawn;
			
		// Add intel
		[_vehicle select 0, [], true, 20, "", "COIN_fnc_intelFound"] call ADF_fnc_searchIntel;
		
		if ADF_missionTest then {diag_log format ["« C O I N »   init_ao.sqf - AO ambient road Opfor -  ADF_fnc_createVehiclePatrol - %1", _vehicle select 0];};
	};	
};

[_ao_ambientVehicles, 0] spawn _ambientVeh;
// In case map AO's have been disabled in the params, spawn an additional set of map vehicle patrols. 
if !COIN_EXEC_aoMissions then {[_ao_ambientVehicles, 180] spawn _ambientVeh;};

ADF_init_AO = true; 
if !isServer then {publicVariable "ADF_init_AO"};