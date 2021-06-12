/*********************************************************************************
 _____ ____  _____ 
|  _  |    \|   __|
|     |  |  |   __|
|__|__|____/|__|   
ARMA Mission Development Framework
ADF version: 2.26 / Jul 2020

Script: COIN tank support
Author: Whiztler
Script version: 0.92

File: init_sup_tankSupport.sqf
**********************************************************************************
DO NOT edit this file. This is part of the COIN mission code base.
**********************************************************************************/

if hasInterface then {
	COIN_fnc_reassignKnight = {
		if !(player isEqualTo COIN_leadership) exitWith {};
		// wait for 45 minutes and then re-add the menu options to the leadership player
		if !ADF_missionTest then {
			private _timer = time + (60 * 45);
			waitUntil {sleep 1; time > _timer};
		}; 		
		call COIN_fnc_assignKnight;	
	};

	COIN_fnc_msg_knightAnnounce = {
		params ["_minutes"];
		sleep 20;
		["KNIGHT", "BCO", format [localize "STR_ADF_supp_knight1", round (_minutes * 1.5)]] call ADF_fnc_MessageParser;
	};

	COIN_fnc_msg_knightDestroyed = {
		params ["_number"];
		["CMD", "BCO", format [localize "STR_ADF_supp_knight2", _number, _number + 1]] call ADF_fnc_MessageParser;
	};

	COIN_fnc_msg_knightDestroyedAO = {
		params ["_number"];
		["BCO", "CMD", format [localize "STR_ADF_supp_knight3", _number]] call ADF_fnc_MessageParser;
		call COIN_fnc_reassignKnight;
	};

	COIN_fnc_msg_knightAOarrive = {
		["KNIGHT", "BCO", localize "STR_ADF_supp_knight4"] call ADF_fnc_MessageParser;
		sleep 12;
		["BCO", "KNIGHT", localize "STR_ADF_supp_knight5"] call ADF_fnc_MessageParser;
	};

	COIN_fnc_msg_knightRTB = {
		["KNIGHT", "BCO", localize "STR_ADF_supp_knight6"] call ADF_fnc_MessageParser;
		sleep 12;
		["BCO", "KNIGHT", localize "STR_ADF_supp_thanks"] call ADF_fnc_MessageParser;		
		call COIN_fnc_reassignKnight;		
	};
	
	COIN_fnc_tankSupportRequest = {
		// Init
		params ["_unit", "_index"];
		
		if COIN_supportActive exitWith {systemChat localize "STR_ADF_supp_supportActive"};
		COIN_supportActive = true;

		// Map click process.
		openMap true;
		hint parseText format [localize "STR_ADF_supp_knight7", name _unit];		
		[_unit, _index] onMapSingleClick {
			params [
				"_unit",
				"_index"
			];
			COIN_tankSupportPosition = _pos;
			publicVariableServer "COIN_tankSupportPosition";
			[_unit, _pos] remoteExec ["COIN_fnc_spawnTankSupport", 2];
			_unit removeAction _index;			
			onMapSingleClick ""; true;
			openMap false; hint "";
		};	
	};
	
	///// ASSIGN KNIGHT TO THE LEADERSHIP PLAYER

	COIN_fnc_assignKnight = {
		tanksupportActionID = COIN_leadership addAction [
			localize "STR_ADF_supp_knightSuppMenu",{
				[_this # 1, _this # 2] call COIN_fnc_tankSupportRequest
			}, [], -95, false, true, "", ""
		];
	};	
};

if isServer then {
	COIN_fnc_spawnTankSupport = {
		params [
			"_unit",
			["_supportPosition", [], [[]]],
			["_spawnPosition", "mSupport_1", ["", []]],
			["_knightDisabled", false, [true]],
			["_closest", 50000, [0]],
			["_spawnDirection", 0, [0]],
			["_allSpawnPositions", [], [[]]]
		];
		
		if (COIN_knightNr > 3) exitWith {};
		
		// Determe closest spawn location
		// Determine amount of ambient road Opfor spawn locations

		if (_spawnPosition isEqualType "") then {
			{
				if ("mSupport_" in _x) then {_allSpawnPositions pushBack _x;};
			} forEach allMapMarkers;		
			
			{		
				private _distance = (markerPos _x distance _supportPosition);
				if (_distance < _closest) then {
					_closest = _distance;
					_spawnPosition = _x;
				};	
			} forEach _allSpawnPositions;
			_spawnDirection = markerDir _spawnPosition;
			_spawnPosition = getMarkerPos _spawnPosition;				
		} else {
			_spawnDirection = random 360;
		};
		
		// Announce KNIGHT
		private _travelTime = [_spawnPosition, _supportPosition, 50] call ADF_fnc_calcTravelTime;
		[_travelTime # 1] remoteExec ["COIN_fnc_msg_knightAnnounce", 0];
		
		// Create KNIGHT // speed 45 kmh
		private _group = createGroup west;
		_group deleteGroupWhenEmpty false;
		_group setGroupIdGlobal [format ["KNIGHT %1", COIN_knightNr + 1], "%GroupColors", "GroupColor6"];
		_class = if ADF_mod_RHS then {"rhsusf_m1a1fep_d"} else {"CUP_B_M1A2_TUSK_MG_DES_USMC"};
		private _vehicle = [_spawnPosition, _spawnDirection, _class, _group] call ADF_fnc_createCrewedVehicle;
		private _knight = _vehicle # 0;
		private _crew = _vehicle # 1;
		_knight lock 3;
		_group allowFleeing 0;
		_group setCombatMode "YELLOW";
		_group setSpeedMode "FULL";
		_knight enableDynamicSimulation false;
		{_x setSkill 0.9; _x setBehaviour "SAFE";} forEach units _group;
		
		// Move order	
		private _timeOut = time + 90;		
		waitUntil {
			_knight move _supportPosition;
			sleep 5;
			(_knight distance2D _spawnPosition) > 10 || !alive _knight || time > _timeOut;
		};
		if (time > _timeOut) exitWith {
			_knight setDamage 1;
			COIN_knightNr = COIN_knightNr - 1;
			["COIN_fnc_spawnTankSupport - Knight was stuck at spawn position. Terminating!", true] call ADF_fnc_log;
		};		
		
		// Keep track of KNIGHT moving to the support position
		[_knight, _supportPosition] spawn {
			// init
			params [
				"_knight", 
				"_supportPosition", 
				["_knightDisabled", false, [true]],
				["_noMoveCount", 0, [0]]
			];
			private _startPos = getPosWorld _knight;
			private _timeOut = time + (30*60);			
			
			_reset = {
				params ["_knight"];
				private _group = group driver _knight;
				_group setCombatMode "YELLOW";
				_group setSpeedMode "FULL";	
				_group setBehaviour "SAFE";	
			};
			
			// Start tracking when KNIGHT is on the move
			waitUntil {
				sleep 5;
				((_knight distance _startPos) > 50) || !alive _knight
			};
			
			// Tracking KNIGHT movement
			waitUntil {
				if (!alive _knight || {!(canMove _knight) || {!(canFire _knight)}}) then {_knightDisabled = true};
				
				// Check if KNIGHT is still moving. If the speed is below 10 kmh then assume he has stopped.
				if (speed _knight > 10) then {
					_noMoveCount = 0;
				} else {
					_noMoveCount = _noMoveCount + 1;
					
					// KNIGHT has stopped for more than 10 secs. Let's check if he's in combat.
					if (_noMoveCount > 10) then {
						
						// Check if KNIGHT is possible in combat
						private _enemy = _knight findNearestEnemy _knight;
						
						// No enemies near. Order KNIGHT to move on.
						if (_enemy isEqualTo objNull) then {
							
							// If no enemies near and stopped for 60+ secs than enable dumb AI specs to get them moving.
							if (_noMoveCount > 60) then {
								{[_x] call ADF_fnc_heliPilotAI;} forEach units group (commander _knight);
								_knight allowDamage false; // Make sure he does not get destroyed when moving on without the ability to fight back.
								_knight move _supportPosition;
								COIN_knightDumbAI = true;
							} else {
								[_knight] call _reset;
								_knight move _supportPosition;
							};
						
						// Enemies near. Check if the are alive. If dead order KNIGHT to move on. Delete the dead enemies just in case.
						} else {
							if !(alive _enemy) then {
								[_enemy] call ADF_fnc_delete;
								[_knight] call _reset;
								_knight move _supportPosition;
							};							
						};
					};
				};
				sleep 1;
				time > _timeOut || (_knight distance _supportPosition) < 350 || _knightDisabled
			};
		};
		
		// Create map marker for KNIGHT.
		[_knight] spawn {
			params ["_knight"];
			_markerKnight = createMarker [format ["mKnight_%1", COIN_knightNr], getPosWorld _knight];
			_markerKnight setMarkerShape "ICON";
			_markerKnight setMarkerType "b_armor";
			_markerKnight setMarkerSize [1 ,1];
			_markerKnight setMarkerColor "ColorWEST";
			_markerKnight setMarkerDir 0;
			
			waitUntil {
				sleep 0.1;
				_markerKnight setMarkerPos (getPosWorld _knight);
				!alive _knight 
			};
			[_markerKnight] call ADF_fnc_delete;
		};
		
		// Order KNIGHT to move to the support position
		private _timeOut = time + (30*60);
		waitUntil {
			sleep 1 + (random 1);
			if (!alive _knight || {!(canMove _knight) || {!(canFire _knight)}}) then {_knightDisabled = true};
			time > _timeOut || (_knight distance _supportPosition) < 300 || _knightDisabled
		};	
		
		// If KNIGHT was damaged in any way then destroy knight and re-start the KNIGHT spawn function. 2 retries possible.
		if _knightDisabled exitWith {
			_knight setDamage 1;
			COIN_knightNr = COIN_knightNr + 1;
			if (COIN_knightNr <= 3) then {			
				[COIN_knightNr] remoteExec ["COIN_fnc_msg_knightDestroyed", 0];				
				sleep 30;
				[_unit, _supportPosition, _spawnPosition] spawn COIN_fnc_spawnTankSupport
			};			
		};
		
		// KNIGHT is within 300m from the support position. Show map marker and make the crew join the group of the player that requested KNIGHT.
		_group setBehaviour "COMBAT";	
		_crew joinSilent (group _unit);
		remoteExec ["COIN_fnc_msg_knightAOarrive", 0];
		if COIN_knightDumbAI then {
			_knight allowDamage true;
			{
				_x enableAI "SUPPRESSION"; 
				_x enableAI "CHECKVISIBLE";
				_x enableAI "TARGET";
				_x enableAI "AUTOTARGET";
				_x enableAI "AUTOCOMBAT";
				_x enableAttack true;
			} forEach _crew;			
		};
		
		// 25% chance opfor will call in close air support to combat the M1A1 armor
		if (random 100 > 75) then {
			[_supportPosition, _knight] spawn {				
				params ["_supportPosition", "_knight"];
				#include "init_vehicles.sqf"
				sleep ((random (6 * 60)) + (random (6 * 60)));
				if (!alive _knight) exitWith {};
				private _allSpawnPos = COIN_ambientAirSpawn;
				private _spawnPos = selectRandom _allSpawnPos;
				private _airFrame = [_spawnPos, markerDir _spawnPos, selectRandom _army_heli_CAS] call ADF_fnc_createCrewedVehicle;
				_group = _airFrame # 2;
				_crew = _airFrame # 1;
				_airFrame = _airFrame # 0;
				_airFrame flyInHeight 50;
				{_x call ADF_fnc_redressArmy_pilot} forEach _crew;
				
				private _waypoint = _group addWaypoint [_supportPosition, 0];
				_waypoint setWaypointType "MOVE";
				_waypoint setWaypointBehaviour "AWARE";
				_waypoint setWaypointSpeed "FULL";
				waitUntil {sleep 1; ((currentWaypoint (_waypoint # 0)) > (_waypoint # 1)) || !alive _airFrame};
				if (!alive _airFrame) exitWith {};
				
				private _waypoint = _group addWaypoint [getPosWorld _knight, 0];
				_group setCombatMode "RED";
				_waypoint setWaypointSpeed "LIMITED";
				_waypoint setWaypointType "SAD";
				
				private _timeOut = time + 600;
				waitUntil {!alive _airFrame || !alive _knight || time > _timeOut};
				if (!alive _airFrame) exitWith {};
				{[_x] call ADF_fnc_heliPilotAI} forEach _crew; 
				_group call ADF_fnc_delWaypoint; 
						
				private _waypoint = _group addWaypoint [getMarkerPos (selectRandom _allSpawnPos), 0];			
				_waypoint setWaypointType "MOVE";
				_waypoint setWaypointBehaviour "SAFE";
				_waypoint setWaypointSpeed "FULL";
				_waypoint setWaypointStatements ["true", "[this] call ADF_fnc_delete;"];
				_airFrame flyInHeight 200;			
			};
		};
		
		private _timeOut = time + (30*60);
		//private _timeOut = time + (5*60); // debug
		waitUntil {
			sleep 1 + (random 1);
			if (!alive _knight || {!(canMove _knight) || {!(canFire _knight)}}) then {_knightDisabled = true};
			time > _timeOut || _knightDisabled || !COIN_ao_active
		};
		if _knightDisabled exitWith {
			_knight setDamage 1;
			sleep 10;
			COIN_supportActive = false;
			[COIN_knightNr] remoteExec ["COIN_fnc_msg_knightDestroyedAO", 0];			
		};
		
		// KNIGHT RTB. They'll ignore opfor from now on.
		_crew joinSilent _group;
		{[_x] call ADF_fnc_heliPilotAI;} forEach _crew;
		if (_spawnPosition isEqualType "") then {
			_knight move (getMarkerPos _spawnPosition);
			_spawnPosition = markerPos _spawnPosition;
		} else {_knight move _spawnPosition};
		_knight allowDamage false;
		_group setSpeedMode "FULL";
		if !COIN_ao_active then {sleep 30};
		remoteExec ["COIN_fnc_msg_knightRTB", 0];
		
		COIN_supportActive = false;
		COIN_leadershipID publicVariableClient "COIN_supportActive";
		
		private _timeOut = time + (30*60);		
		waitUntil {
			sleep 3;
			time > _timeOut || (_knight distance _spawnPosition) < 25
		};
		if ((_knight distance _spawnPosition) > 500) then { // knight probably got stuck somewhere.
			_knight allowDamage true;
			_knight setDamage 1;
		};
		[_knight] call ADF_fnc_delete;
		COIN_knightNr = 1;
	};
};