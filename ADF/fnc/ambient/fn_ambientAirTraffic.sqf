/*********************************************************************************
 _____ ____  _____ 
|  _  |    \|   __|
|     |  |  |   __|
|__|__|____/|__|   
ARMA Mission Development Framework
ADF version: 2.26 / Jul 2020

Function: ADF_fnc_ambientAirTraffic
Author: Whiztler
Script version: 1.13

File: fn_ambientAirTraffic.sqf
**********************************************************************************
ABOUT
Function to create ambient air traffic. You can create thru/thru traffic (no
landing) or traffic that lands and takes off again from an airport/helipad.
If landing is enabled the aircraft simulates a startup procedure before taking off
The aircraft remains stationary with the engine running until cleared for takeoff.
After the aircraft reaches the terminate location, the vehicle, group and crew are
deleted and the cycle starts again after a random pause (min max time configurable).

In case you wish to use a specific aircraft class (e.g. an addon class) then you
can use the class in params nr. 6. Note that the classname has to be a "string".

You can send along a variable as a string. The variable is checked at the end of 
each spawn cycle. If the variable returns true then the cycle stops and does not 
spawn a new aircraft. Example

in your script init: stop_air_show = false;
Pass along as "stop_air_show" (11th parameter)
In your script use stop_air_show = true to stop ambient air spawning of that specific
instance.

INSTRUCTIONS:
Execute (spawn) the function on the server or HC.

REQUIRED PARAMETERS:
0. Array:       Array of possible spawn locations. Markers, object, triggers, 
                etc. E.g.: ["startPos1", "startPos2", "startPos3"]
1. Array:       Array of possible terminate locations. Markers, object, triggers, 
                etc.
                E.g.: ["endPos1", "endPos2", "endPos3"]
2. Location     Landing location. Marker, object, trigger or position
                array [x, y, z]
                Helipad for helicopters, location on tarmac for jets.
                E.g.: MyHeliPad
                If you prefer thru and thru traffic (no landing) then use:
                FALSE

OPTIONAL PARAMETERS:              
3. Number       Minimum number of minutes to wait before a new aircraft
                spawns (default: 3 min)
4. Number       Maximum number of minutes to wait before a new aircraft
                spawns (default: 30 min)
5. Side         Side of aircraft west, east, independent, civilian (default: east)
6. Bool/String  Type of aircraft:
                - true: Helicopters (default)
                - False: airplanes
                Or "Classname" of the aircraft as a string
                Or an array of ["Classname", "Classname", "Classname"]
7. Bool         Attack or transport aircraft
                true: attack aircraft 
                false: transport aircraft (default)
                Has no effect when a classname (string) was used in 6.
5. String:      Code to execute on each unit of the crew (e.g. a function).
                Default = "". Code is CALLED. Each unit of the group is passed
                (_this select 0) to the code/fnc.
6. String:      Code to execute on the crew aa a group (e.g. a function).
                Default = "". Code is CALLED. The group is passed
                (_this select 0) to the code/fnc.    
10: Bool:       Does the crew respond to enemy behavior:
                - true: Docile crew does not attack enemy (default: true)
                - false: Normal behavior
11: String:     This can be a variable set to either true or false. At the end off
                each cycle it checks the variable. If set to true it stops the
                cycle. By default it is set to false (infinite cycle).
12: Side/Bool   If you want the crew to be of a different side than that of the
                aircraft then enter the side here. Else it will default in false.

EXAMPLES USAGE IN SCRIPT:
[["startPos1", "startPos2", "startPos3"], ["endPos1", "endPos2", "endPos3"], MyHeliPad, 5, 30, west, true, false, "myFunction", "", true, "AirLoop", independent] spawn ADF_fnc_ambientAirTraffic;

EXAMPLES USAGE IN SCRIPT WITH A RED HAMMER STUDIOS RUSSIAN MI8 HELICOPTER
[["startPos1", "startPos2", "startPos3"], ["endPos1", "endPos2", "endPos3"], MyHeliPad, 5, 30, east, "RHS_Mi8mt_Cargo_vv", false, "myFunction", "", true, "AirLoop"] spawn ADF_fnc_ambientAirTraffic;

EXAMPLES USAGE IN EDEN:
[["startPos1", "startPos2", "startPos3"], ["endPos1", "endPos2", "endPos3"], MyHeliPad, 5, 30, west, true, false] spawn ADF_fnc_ambientAirTraffic;

DEFAULT/MINIMUM OPTIONS
[["startPos1", "startPos2", "startPos3"], ["endPos1", "endPos2", "endPos3"], MyHeliPad] spawn ADF_fnc_ambientAirTraffic;

RETURNS:
True
*********************************************************************************/

// Reporting
if (ADF_extRpt || {ADF_debug}) then {diag_log "ADF rpt: fnc - executing: ADF_fnc_ambientAirTraffic"};

// Init
params [
	["_spawn_positions", [0, 0, 0], ["", [], objNull]], 
	["_terminate_positions", [0, 0, 0], ["", [], objNull]], 
	["_landing_position", [0, 0, 0], ["", [], objNull, false]], 
	["_minutes_min", 180, [0]], 
	["_minutes_max", 1800, [0]], 
	["_side", east, [east]], 
	["_type", true, [true, "", []]], 
	["_attackAircraft", false, [false]], 
	["_function_1", "", [""]], 
	["_function_2", "", [""]], 
	["_behaviourDisabled", true, [true]], 
	["_exit", false, ["", true]],
	["_crewSide", false, [west, false]]
];
private _vehicleArray = [];
private _position_landpad = [];
private _nonStop = false;

// Check valid vars
if (_minutes_min < 1) then {_minutes_min = 1;};
if (_minutes_max > 5400) then {_minutes_max = 5400;};
if (_function_1 != "") then {if (isNil _function_1) then {_function_1 = ""}; if ADF_debug then {[format ["ADF_fnc_ambientAirTraffic - incorrect code (%1) passed. Defaulted to ''.", _function_1]] call ADF_fnc_log;}};
if (_function_2 != "") then {if (isNil _function_2) then {_function_2 = ""}; if ADF_debug then {[format ["ADF_fnc_ambientAirTraffic - incorrect code (%1) passed. Defaulted to ''.", _function_2]] call ADF_fnc_log;}};

// Assign aircraft array based on the requested side
switch _side do {
	case west: {
		if (_attackAircraft) then {
			_vehicleArray = [
				["B_Heli_Light_01_armed_F", "B_Heli_Attack_01_F"], // Helicopters
				["B_Plane_CAS_01_F", "B_UAV_02_CAS_F", "B_T_UAV_03_F"] // airplanes/UAVS
			];
		} else {
			_vehicleArray = [
				["B_Heli_Light_01_F", "B_Heli_Transport_01_F", "B_Heli_Transport_01_camo_F", "B_Heli_Transport_03_F", "B_Heli_Transport_03_black_F", "B_Heli_Transport_03_unarmed_green_F", "B_CTRG_Heli_Transport_01_sand_F", "B_CTRG_Heli_Transport_01_tropic_F"], // Helicopters
				["B_T_VTOL_01_infantry_F", "B_T_VTOL_01_vehicle_F", "B_T_VTOL_01_armed_F", "B_T_VTOL_01_armed_olive_F"] // airplanes
			];		
		};
	};
	
	case east: {
		if (_attackAircraft) then {
			_vehicleArray = [
				["O_Heli_Light_02_F", "O_Heli_Attack_02_F", "O_Heli_Attack_02_black_F"], // Helicopters
				["O_Plane_CAS_02_F", "O_UAV_02_CAS_F", "O_T_VTOL_02_infantry_F", "O_T_VTOL_02_vehicle_F"] // airplanes
			];
		} else {
			_vehicleArray = [
				["O_Heli_Light_02_unarmed_F", "O_Heli_Light_02_v2_F", "O_Heli_Transport_04_F", "O_Heli_Transport_04_ammo_F", "O_Heli_Transport_04_bench_F", "O_Heli_Transport_04_box_F", 
				"O_Heli_Transport_04_covered_F", "O_Heli_Transport_04_fuel_F", "O_Heli_Transport_04_medevac_F", "O_Heli_Transport_04_repair_F", "O_Heli_Transport_04_black_F", 
				"O_Heli_Transport_04_ammo_black_F", "O_Heli_Transport_04_bench_black_F", "O_Heli_Transport_04_box_black_F", "O_Heli_Transport_04_covered_black_F", 
				"O_Heli_Transport_04_fuel_black_F", "O_Heli_Transport_04_medevac_black_F", "O_Heli_Transport_04_repair_black_F"], // Helicopters
				["O_T_VTOL_02_infantry_hex_F", "O_T_VTOL_02_infantry_ghex_F", "O_T_VTOL_02_infantry_grey_F", "O_T_VTOL_02_vehicle_hex_F", "O_T_VTOL_02_vehicle_ghex_F", "O_T_VTOL_02_vehicle_grey_F"] // airplanes
			];		
		};
	};
	
	case independent: {
		if (_attackAircraft) then {
			_vehicleArray = [
				["I_Heli_light_03_F", "I_Heli_light_03_dynamicLoadout_F"], // Helicopters
				["I_Plane_Fighter_03_CAS_F", "I_Plane_Fighter_03_AA_F", "I_UAV_02_CAS_F"] // airplanes?UAVS
			];
		} else {
			_vehicleArray = [
				["I_Heli_Transport_02_F", "I_Heli_light_03_unarmed_F"], // Helicopters
				["I_UAV_02_F", "I_C_Plane_Civil_01_F"] // UAVS
			];		
		};
	};
	
	case civilian: {
		_vehicleArray = [
			["C_Heli_Light_01_civil_F", "I_Heli_Transport_02_F", "C_Heli_light_01_blue_F", "C_Heli_light_01_red_F", "C_Heli_light_01_blueLine_F", "C_Heli_light_01_digital_F", 
			"C_Heli_light_01_elliptical_F", "C_Heli_light_01_furious_F", "C_Heli_light_01_graywatcher_F", "C_Heli_light_01_jeans_F", "C_Heli_light_01_light_F", 
			"C_Heli_light_01_shadow_F", "C_Heli_light_01_sheriff_F", "I_Heli_Transport_02_F", "C_Heli_light_01_speedy_F", "C_Heli_light_01_sunset_F", "C_Heli_light_01_vrana_F", 
			"C_Heli_light_01_wasp_F", "C_Heli_light_01_wave_F", "C_Heli_light_01_stripped_F", "C_Heli_light_01_luxe_F", "I_Heli_Transport_02_F"], // Helicopters
			["C_Plane_Civil_01_F", "C_Plane_Civil_01_racing_F", "I_C_Plane_Civil_01_F"] // Airplanes
		];	
	};
};

// Check type of aircraft
_vehicleArray = if (_type isEqualType false) then {if (_type) then {_vehicleArray # 0} else {_vehicleArray # 1}} else {if (_type isEqualType "") then {[_type]} else {_type}};
if ADF_debug then {[format ["ADF_fnc_ambientAirTraffic - selected aircraft array: %1", _vehicleArray]] call ADF_fnc_log};

// Check if thru & thru traffic -or- landing/takeoff traffic
if 	(_landing_position isEqualType false) then {
	_nonStop = true;
	if ADF_debug then {["ADF Debug: ADF_fnc_ambientAirTraffic - Through & Through traffic selected. No landing"] call ADF_fnc_log};
} else {_position_landpad 	= [_landing_position] call ADF_fnc_checkPosition};

// Check if the vehicle crew is of the same side as the aircraft side
if (_crewSide isEqualType false) then {_crewSide = _side};

///// Start the show

waitUntil {
	// set the scope
	scopeName "trafficLoop";
	
	// select a random spawn and terminate position. Check which kind of location position for spawn, terminate and land.
	private _position_spawn = selectRandom _spawn_positions;
	private _position_terminate = selectRandom _terminate_positions;	
	
	// Are spawn and terminate position the same? 
	if (_position_spawn isEqualTo _position_terminate) then {
		// Try 3 times to make sure the spawn and terminate position are not the same. If still the same then assume it was intentional.
		for "_i" from 1 to 3 do {		
			_position_terminate = selectRandom _terminate_positions;
			_position_spawn = selectRandom _spawn_positions;
			if !(_position_spawn isEqualTo _position_terminate) exitWith {};
		};	
	};
	
	// Check the position location
	_position_spawn = [_position_spawn] call ADF_fnc_checkPosition;
	_position_terminate = [_position_terminate] call ADF_fnc_checkPosition;

	_randomEdgePos = {
		params ["_positionType", "_oldPosition"];
		private _mapEdge = ((round (worldSize / 1000)) * 1000);
		_newPosition = selectRandom [
			[_mapEdge + 2000, _mapEdge + 2000, 0],
			[_mapEdge + 2000, -1000, 0],
			[-1000, _mapEdge + 2000, 0],	
			[-1000, -1000, 0], 
			[-1000, _mapEdge / 2, 0], 
			[_mapEdge / 2, -1000, 0],
			[_mapEdge / 2, _mapEdge + 2000, 0], 
			[_mapEdge + 2000, _mapEdge / 2, 0]	
		];
		[format ["ADF_fnc_ambientAirTraffic: Incorrect location provided. %1: %2. New position: %3", _positionType, _oldPosition, _newPosition]] call ADF_fnc_log;
		_newPosition
	};
	
	// If there is an empty or incorrect position then determin a random position on the outer edge of the map
	if (_position_terminate isEqualTo [] || {_position_terminate isEqualTo [0, 0, 0] || {(count _position_terminate) < 3}}) then {_position_terminate = ["terminate", _position_terminate] call _randomEdgePos};	
	if (_position_spawn isEqualTo [] || {_position_spawn isEqualTo [0, 0, 0] || {(count _position_spawn) < 3}}) then {_position_spawn = ["spawn", _position_spawn] call _randomEdgePos};	
	if ADF_debug then {[format ["ADF_fnc_ambientAirTraffic - spawn: %1 - exit: %2", _position_spawn, _position_terminate]] call ADF_fnc_log};
	if (ADF_debug && !_nonStop) then {[format ["ADF_fnc_ambientAirTraffic - landing at: %1", _position_landpad]] call ADF_fnc_log};
	
	// check if the land position is 0, 0, 0. If it is then set the error var to true.
	if !_nonStop then {
		if (_position_landpad isEqualTo [0, 0, 0]) exitWith {
			["ADF_fnc_ambientAirTraffic", format ["Incorrect location provided. Land: %1", _position_landpad]] call ADF_fnc_terminateScript;	
			breakOut "trafficLoop";
		};
	};
	
	// Select an aircraft from the predetermined array per side and type
	private _vehicleClass	= selectRandom _vehicleArray;
	if ADF_debug then {[format ["ADF_fnc_ambientAirTraffic - selected aircraft: %1", _vehicleClass]] call ADF_fnc_log};

	// random cycle sleep and random wait sleep before takeoff	
	private _cyclePause = [_minutes_min * 60, _minutes_max * 60] call BIS_fnc_randomNum;
	private _landPause = [_minutes_min * 60, _minutes_min * 15] call BIS_fnc_randomNum;
	if ADF_debug then {[format ["ADF_fnc_ambientAirTraffic - cycle sleep: %1 secs - takeoff delay: %2 secs", _cyclePause, _landPause]] call ADF_fnc_log};

	// Create the vehicle and crew
	private _crewGroup = createGroup _crewSide;	
	private _vehicle = [_position_spawn, random 360, _vehicleClass, _crewGroup, _function_1, _function_2, true] call ADF_fnc_createCrewedVehicle;
	private _aircraft	= _vehicle # 0;
	
	// Add to Zeus
	if isServer then {
		[_aircraft] call ADF_fnc_addToCurator;
	} else {
		[_aircraft] remoteExecCall ["ADF_fnc_addToCurator", 2];
	};	
	
	//Reskin the CH-49 for civilian use
	if ((_side == civilian) && (_vehicleClass == "I_Heli_Transport_02_F")) then {
		if ((random 1) > .5) then {
			_aircraft setObjectTextureGlobal [0, "\a3\air_f_beta\Heli_Transport_02\Data\Skins\heli_transport_02_1_dahoman_co.paa"];
			_aircraft setObjectTextureGlobal [1, "\a3\air_f_beta\Heli_Transport_02\Data\Skins\heli_transport_02_2_dahoman_co.paa"];
			_aircraft setObjectTextureGlobal [2, "\a3\air_f_beta\Heli_Transport_02\Data\Skins\heli_transport_02_3_dahoman_co.paa"];
		} else {
			_aircraft setObjectTextureGlobal [0, "a3\air_f_beta\Heli_Transport_02\Data\Skins\heli_transport_02_1_ion_co.paa"];
			_aircraft setObjectTextureGlobal [1, "a3\air_f_beta\Heli_Transport_02\Data\Skins\heli_transport_02_2_ion_co.paa"];
			_aircraft setObjectTextureGlobal [2, "a3\air_f_beta\Heli_Transport_02\Data\Skins\heli_transport_02_3_ion_co.paa"]; 				
		};
	};
	
	// Lock the aircraft for players 
	_aircraft lock 3;
	
	// For docile pilots we give them lots of alcohol
	if (_behaviourDisabled) then {[driver _aircraft] call ADF_fnc_heliPilotAI};
	
	// Set a random altitude. Planes get a higher altitude
	if (_aircraft isKindOf "Helicopter")  then {_aircraft flyInHeight 50 + (random 50)} else {_aircraft flyInHeight 100 + (random 100)};

	// Check if landing is needed. Start flight
	if !_nonStop then {
		private _waypoint = _crewGroup addWaypoint [_position_landpad, 0];
		_waypoint setWaypointType "MOVE";
		_waypoint setWaypointBehaviour "SAFE";
		_waypoint setWaypointSpeed "NORMAL";
					
		// Wait at airport/helipad. Helis wait till they reach the WP
		if (_type isEqualType false) then { 
			if (_type) then {_waypoint setWaypointCompletionRadius 25; waitUntil {sleep 1; ((currentWaypoint (_waypoint # 0)) > (_waypoint # 1)) || !(alive _aircraft)}};	
		} else {
			if (_aircraft isKindOf "Helicopter") then {_waypoint setWaypointCompletionRadius 25; waitUntil {sleep 1; ((currentWaypoint (_waypoint # 0)) > (_waypoint # 1)) || !(alive _aircraft)}};	
		};
		_aircraft flyInHeight 0;
		_aircraft land "land";
		
		// Start timer in case the aircraft gets stuck somehow. Aircraft has 60 secs (jets 180 secs) to land. If successful with landing, it will wait on the tarmac before takeoff.
		private _m = time;
		private _n = 60;
		if !(_aircraft isKindOf "Helicopter") then {_n = 180};
		if ADF_debug then {[format ["ADF_fnc_ambientAirTraffic - Landing timer started at: %1", time]] call ADF_fnc_log};

		// Touchdown
		waitUntil {isTouchingGround _aircraft || (time > (_m + _n)) || !(alive _aircraft)};
		if !(alive _aircraft) exitWith {};
		if (time > (_m + _n)) exitWith {if ADF_debug then {[format ["ADF_fnc_ambientAirTraffic - Aircraft could not land. Timer ran out: %1 secs", time-_m]] call ADF_fnc_log}};
		if ADF_debug then {[format ["ADF_fnc_ambientAirTraffic - Aircraft touchdown. Timer %1 secs", time-_m]] call ADF_fnc_log};
		
		// Switch off and wait
		_aircraft flyInHeight 0;
		sleep (5 + random 5);
		_aircraft setFuel 0;			
		{_aircraft animateDoor [(configName _x), 1]} forEach ("((toLower (getText (_x >> 'source'))) == 'door')" configClasses (configFile >> "CfgVehicles" >> (typeOf _aircraft) >> "AnimationSources"));
		sleep _landPause;
		
		// Take off for termination waypoint
		if !(alive _aircraft) exitWith {};
		_aircraft setFuel 1;
		_aircraft engineOn true;
		_aircraft flyInHeight 0;
		{_aircraft animateDoor [(configName _x), 0]} forEach ("((toLower (getText (_x >> 'source'))) == 'door')" configClasses (configFile >> "CfgVehicles" >> (typeOf _aircraft) >> "AnimationSources"));
		
		// Do checklist and wait for takeoff clearing
		sleep ([60, 180] call BIS_fnc_randomNum);			
		_aircraft flyInHeight 50 + (random 100);
	};
	
	// Terminate waypoint
	private _waypoint = _crewGroup addWaypoint [_position_terminate, 0];
	_waypoint setWaypointType "MOVE";
	_waypoint setWaypointBehaviour "SAFE";
	_waypoint setWaypointSpeed "NORMAL";		
	
	// Wait till the termination waypoint is reached and delete the aircraft and its crew
	waitUntil {sleep 1; ((currentWaypoint (_waypoint # 0)) > (_waypoint # 1)) || !(alive _aircraft)};	
	if !(isNil "_aircraft") then {[_aircraft] call ADF_fnc_delete};
	
	// Rewind
	sleep _cyclePause;
	
	// Check cycle loop status
	if (_exit isEqualType "") then {missionNamespace getVariable [_exit, false]} else {_exit}
};

true