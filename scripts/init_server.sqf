diag_log "ADF rpt: Init - executing: scripts\init_server.sqf"; // Reporting. Do NOT edit/remove
if (!isNil "init_Svr_Exec") then {
	if isMultiplayer then {	
		private _errorMessage = "ERROR: The server has tried to execute mission scripts twice. To avoid issues, please restart the mission!";
		_errorMessage remoteExecCall ["systemChat", -2];
		[_errorMessage, true] call ADF_fnc_log;
	} else {
		["ADF rpt: Init - init_server.sqf has already been executed! Terminating init_server.sqf for this client.", true] call ADF_fnc_log
	};
} else {
	init_Svr_Exec = true;
	publicVariable "init_Svr_Exec";
	if !isMultiplayer then {
		systemChat localize "STR_ADF_clientInit_SinglePlayer";
		[] spawn {
			waitUntil {time > 1};
			{
				if !(isPlayer _x) then {
					[_x] call ADF_fnc_delete;
				}
			} forEach switchableUnits;
		};
	};
	
	private _diagTime = diag_tickTime;
	private _fobNumber = 0;
	ADF_ACT_active = false;

	COIN_fnc_intelFoundServer = {	
		params ["_object", "_caller", "_intelFound", "_messageID"];		
		_mapIntel = {
			params ["_intelType"];	
			COIN_stopUnitTracking = false;
			{
				if !(side _x isEqualTo east) exitWith {};
				[_x, _intelType] spawn {
					
					// Init. Default is foot mobile (_intelType == 1)
					params [
						"_unit",
						["_intelType", 1, [0]],
						["_size", 0.5, [0]],
						["_type", "mil_triangle_noShadow", [""]],
						["_alpha", 1, [0]],
						["_exit", true, [false]]
					];
					
					call {
						if (_intelType == 1 && {isNull objectParent _unit}) exitWith {_exit = false};
						if (_intelType == 2) exitWith {
							if (isNull objectParent _unit) exitWith {};
							_size = 1;
							_type = "hd_dot_noShadow";							
							private _vehicle = objectParent _unit;
							if (_vehicle isKindOf "staticWeapon") exitWith {_exit = false};
							if (_vehicle isKindOf "tank" && {(speed _vehicle) == 0}) then {_exit = false};							
						};
						if (_intelType == 3) exitWith {
							if (isNull objectParent _unit) exitWith {};
							_size = 1;
							_type = "mil_arrow2_noShadow";							
							private _vehicle = objectParent _unit;
							if (_vehicle isKindOf "car") exitWith {_exit = false};
							if (_vehicle isKindOf "tank" && {(speed _vehicle) > 0}) then {_exit = false};	
						};
					};

					// Check if the unit is in aircraft. Aircraft always get a marker.
					if (!(isNull objectParent _unit) && {(vehicle _unit) isKindOf "Helicopter"}) then {
						if (_unit == driver (vehicle _unit)) then {
							_size = 1;
							_type = "mil_triangle_noShadow";
						} else {
							_alpha = 0;
						};
					};
					
					// Exit for all units that do not require a marker.
					if _exit exitWith {};
					
					// Create the initial marker
					private _marker = createMarker [format ["m_%1", _unit], getPos _unit];
					_marker setMarkerShape "ICON";
					_marker setMarkerType _type;
					_marker setMarkerSize [_size, _size];
					_marker setMarkerDir (getDir _unit);
					_marker setMarkerColor "colorOPFOR";
					_marker setMarkerAlpha _alpha;
					
					// Start marker update loop per unit
					waitUntil {
						_marker setMarkerPos (getPosATL _unit);
						_marker setMarkerDir (getDir _unit);
						sleep .5;
						COIN_stopUnitTracking || !alive _unit
					};				
					
					if COIN_stopUnitTracking exitWith {
						private _a = 1;
						for "_i" from 0 to 10 do {
							_a = _a - 0.1;
							_marker setMarkerAlpha _a;
							sleep 1;							
						};
						[_marker] call ADF_fnc_delete;
					};
					
					// Unit is no longer alive. Change the marker color to black
					if (!alive _unit) then {
						_marker setMarkerColor "ColorBlack";
						_marker setMarkerType "mil_destroy";
						_marker setMarkerAlpha 1;
						_timeOut = time + 30;
						waitUntil {sleep 1; time > _timeOut};
						[_marker] call ADF_fnc_delete;
					};
				}; // /spawn
			} forEach allUnits;
			true
		};
		
		// IntelType:
		// 1: foot mobiles
		// 2: static positions
		// 3: vehicle traffic
		_intelType = selectRandom [3, 1, 2];		
		
		[_intelType] call _mapIntel;		
		[_intelType] remoteExec ["COIN_fnc_intelFoundMsg", 0];
		
		_timeOut = time + (100 + random 50);
		waitUntil {sleep 1; time > _timeOut};
		
		// Disable tracking after the timer
		COIN_stopUnitTracking = true;		
		
		sleep ((10 + (random 10)) * 60);
		COIN_intelFoundActive = false;
		publicVariable "COIN_intelFoundActive";
	};

	ADF_fnc_aoActivation = {
		// Init
		params [
			["_ao_number", 0, [0]], 
			["_ao_trigger", objNull, [objNull]],
			["_ao_sizeOverride", 0, [0]],
			["_ao_ratio", 2, [0]],
			["_ao_name", "", [""]],
			["_ao_base", false, [true]],
			["_ao_baseMarker", "", [""]],
			["_ao_staticsBase", [], [[]]]
		];
		
		COIN_ao_active = true;
		COIN_ao_spawned = false;
		COIN_ao_currentNr = COIN_ao_currentNr + 1;
		COIN_ao_allRemainingVehicles = [];
		private _ao_number = call compile format ["%1", ((str _ao_trigger) splitString "_") # 1]; // 0.0037 ms		
		private _ao_marker = format ["mAO_%1", _ao_number];
		private _ao_layer = format ["lAO_%1", _ao_number];
		COIN_ao_markers = COIN_ao_markers - [_ao_marker];
		COIN_ao_activeMarker = format ["mAO_%1", _ao_number];
		
		diag_log format ["« C O I N »   ADF_fnc_aoActivation - Activating AO number %1.", _ao_number];
		
		#include "init_ao_names.sqf"
		
		// Marker color and size
		_ao_marker setMarkerColor "ColorRed";
		_ao_marker setMarkerAlpha 0.65;
		{_x setMarkerAlpha 0.25} count COIN_ao_markers;
		private _ao_size = ((markerSize _ao_marker) # 0);
		
		// Enable AO objects
		private _currentLayer = ((getMissionLayerEntities _ao_layer) # 0);
		if (count _currentLayer > 0) then {{_x hideObjectGlobal false; if !(isSimpleObject _x) then {_x enableSimulationGlobal true}} forEach _currentLayer};
		
		// AO has an army base/POI?
		if _ao_base then {
			_ao_baseMarker = format ["mBase_%1", _ao_number];
			// Check if the entire AO is an army base. If that is the case then the basemarker = AO marker
			if (_ao_baseMarker in allMapMarkers) then {
				diag_log format ["« C O I N »   ADF_fnc_aoActivation - AO base marker found: %1.", _ao_baseMarker];
			} else {
				_ao_baseMarker = _ao_marker;
			};
			
			// Populate weapon statics array for AO bases
			{				
				private _class = typeOf _x;			
				if ((_class isEqualTo "Sign_Arrow_Large_Yellow_F") && {(getPosWorld _x) inArea _ao_baseMarker}) then {
					private _pos = getPosASL _x;
					private _dir = getDir _x;
					[_x] call ADF_fnc_delete;
					private _class = if ADF_mod_RHS then { "rhs_KORD_high_MSV"} else {"CUP_O_KORD_high_TK"};
					
					private _turret = createVehicle [_class, [0, 0, 0], [], 0, "CAN_COLLIDE"];
					_turret allowDamage false;
					_turret setDir _dir;
					_turret setPosASL _pos;
					_turret setVectorUp surfaceNormal position _turret;
					_ao_staticsBase pushBack _turret;
					_turret allowDamage true;
				};
				if ((_class isEqualTo "Sign_Arrow_Large_F") && {(getPosWorld _x) inArea _ao_baseMarker}) then {
					private _pos = getPosASL _x;
					private _dir = getDir _x;
					[_x] call ADF_fnc_delete;
					private _class = if ADF_mod_RHS then { "RHS_ZU23_MSV"} else {"CUP_O_ZU23_TK"};
					
					private _turret = createVehicle [_class, [0, 0, 0], [], 0, "CAN_COLLIDE"];
					_turret allowDamage false;
					_turret setDir _dir;
					_turret setPosASL _pos;
					_turret setVectorUp surfaceNormal position _turret;
					_ao_staticsBase pushBack _turret;
					_turret allowDamage true;
				};		
			} forEach _currentLayer;
			
			if ADF_missionTest then {
				diag_log "--------------------------------------------------------------------------------------------------------";
				diag_log format ["« C O I N »   ADF_fnc_aoActivation - AO base statics added: %1", _ao_staticsBase];
				diag_log "--------------------------------------------------------------------------------------------------------";		
			};		
		}; // Army base


		// Update the AO trigger data set and disable remaining AO triggers
		COIN_ao_triggers = COIN_ao_triggers - [_ao_trigger];
		if ((count COIN_ao_triggers) > 0) then {{_x enableSimulation false} forEach COIN_ao_triggers;};
		[_ao_trigger] call ADF_fnc_delete;
		
		// AO size to determine the spawn ratio unless overriden by trigger params
		if (_ao_sizeOverride > 0) then {
			_ao_ratio = _ao_sizeOverride;
		} else {
			call {
				if (_ao_size > 1199) exitWith {_ao_ratio = 4}; // very large
				if (_ao_size > 899) exitWith {_ao_ratio = 3}; // large
				if (_ao_size > 699) exitWith {_ao_ratio = 2}; // normal
				_ao_ratio = 1; // < 700 = small
			};		
		};
		
		// Pass AO specifications to the "COIN_fnc_aoSpawn" function on either server or HC
		if ADF_init_AO then {
			if ADF_HC_execute then {
				[_ao_marker, _ao_ratio, _ao_base, _ao_baseMarker, _ao_staticsBase] spawn COIN_fnc_aoSpawn;
			} else {
				[_ao_marker, _ao_ratio, _ao_base, _ao_baseMarker, _ao_staticsBase] remoteExec ["COIN_fnc_aoSpawn", 0, false];
			};
		} else {
			[_ao_marker, _ao_ratio, _ao_base, _ao_baseMarker, _ao_staticsBase] spawn {
				params ["_ao_marker", "_ao_ratio", "_ao_base", "_ao_baseMarker", "_ao_staticsBase"];
				waitUntil {sleep 0.5; ADF_init_AO};				
				if ADF_HC_execute then {
					[_ao_marker, _ao_ratio, _ao_base, _ao_baseMarker, _ao_staticsBase] spawn COIN_fnc_aoSpawn;
				} else {
					[_ao_marker, _ao_ratio, _ao_base, _ao_baseMarker, _ao_staticsBase] remoteExec ["COIN_fnc_aoSpawn", 0, false];
				};
			};	
		};

		// Object markers
		[[
			"Land_Hlaska", "Land_Radar_Small_F", "Land_Ind_Workshop01_01", "Land_Ind_Workshop01_04", "Land_Ind_Workshop01_03", "Land_Ind_Workshop01_L", 
			"Land_TTowerBig_2_F", "Land_TTowerBig_1_F", "Land_dp_smallFactory_F", "Land_MilOffices_V1_F", "Land_Ind_Pec_02", "Land_i_Shed_Ind_F", "76n6ClamShell", 
			"Land_Airport_01_controlTower_F", "Land_Hangar_2", "Land_Mil_hangar_EP1", "Land_Airport_01_hangar_F", "Land_Airport_02_controlTower_F", 
			"Land_i_Barracks_V2_F", "Land_Offices_01_V1_F", "Land_HelipadRescue_F", "Land_Hospital", "Land_Airport_02_terminal_F", "Land_Letistni_hala", "Land_Ind_Shed_01_EP1", 
			"Land_ReservoirTank_Airport_F", "Land_Mil_Barracks_no_interior_EP1_CUP", "Land_Mil_Barracks_EP1", "Land_Mil_Barracks_L_EP1", "Land_Barracks_01_grey_F",
			"Land_Ind_Shed_02_EP1", "Land_MultistoryBuilding_03_F", "Land_MultistoryBuilding_04_F", "Land_i_Barracks_V1_F", "Land_Mil_Barracks_i_EP1", "Land_Shed_Big_F",
			"Land_MobileRadar_01_radar_F", "Land_Radar_F", "Land_BagBunker_Small_F", "Land_BagBunker_Large_F", "Land_SCF_01_storageBin_small_F",
			"Land_Fuel_tank_stairs", "Land_dp_smallTank_F", "Land_IndPipe1_valve_F", "Land_IndPipe1_ground_F", "Land_ServiceHangar_01_L_F", "Land_ServiceHangar_01_R_F"
		], _ao_marker, _ao_size] call ADF_fnc_objectMarkerArray;
		
		// Remarker existing markers
		_ao_marker call ADF_fnc_reMarker;
		{
			if ((getMarkerPos _x) inArea _ao_marker) then {
				if ("mMed_" in _x || {"mRRR_" in _x}) then {_x call ADF_fnc_reMarker;};
			};
		} forEach allMapMarkers;		

		///// START TRACKING
		
		// Check AO population and track progress
		waitUntil {sleep 1; COIN_ao_spawned};
		
		// African Theme?
		// Move from client to Server as 'BIS_fnc_setIdentity' function is global as off 1.90
		if COIN_africanTheme then {
			{
				if !(_x getVariable ["COIN_indentitySet", false]) then {
					[_x, selectRandom ADF_identFace, selectRandom ADF_identVoice] call BIS_fnc_setIdentity;
					_x setVariable ["COIN_indentitySet", true];
				};
			} forEach allUnits select {(side _x) isEqualTo east};
		};	
		
		private _opforSpawned = [_ao_marker, east, _ao_size * 1.2, ["MAN", "STATICWEAPON"]] call ADF_fnc_countRadius;
		private _victoryPct = round (85 + (random 10));
		private _winCondition = round (_opforSpawned - (_opforSpawned * (_victoryPct/100)));
		if (_winCondition < 5) then {_winCondition = 5};
		
		diag_log "--------------------------------------------------------------------------------------------------------";
		diag_log "« C O I N »   AO CONFIG";	
		diag_log format ["« C O I N »   ADF_fnc_aoActivation - AO number %1 activated.", _ao_number];
		diag_log format ["« C O I N »   ADF_fnc_aoActivation - AO with army base: %1", _ao_base];
		diag_log format ["« C O I N »   ADF_fnc_aoActivation - AO location: %1", _ao_name];
		diag_log format ["« C O I N »   ADF_fnc_aoActivation - AO Size: %1 meters", _ao_size];
		diag_log format ["« C O I N »  	ADF_fnc_aoActivation - Determined AO spawn size: %1", _ao_ratio];
		diag_log format ["« C O I N »   ADF_fnc_aoActivation - Total nr of Opfor ei spawned: %1", _opforSpawned];
		diag_log format ["« C O I N »   ADF_fnc_aoActivation - Victory percentage: %1", _victoryPct];
		diag_log format ["« C O I N »   ADF_fnc_aoActivation - Victory nr Opfor remaining, max: %1", _winCondition];
		diag_log "--------------------------------------------------------------------------------------------------------";
		diag_log format ["« C O I N »   ADF_fnc_aoActivation - AO groups array: %1", COIN_ao_groups];
		diag_log format ["« C O I N »   ADF_fnc_aoActivation - AO vehicles array: %1", COIN_ao_vehicles];
		diag_log format ["« C O I N »   ADF_fnc_aoActivation - AO base statics array: %1", _ao_staticsBase];
		diag_log "--------------------------------------------------------------------------------------------------------";
		private _startTime = time;
		
		// Announce the AO to the player clients
		private _sleep = if (COIN_ao_currentNr == 1) then {120} else {30};
		private _wait = time + _sleep;
		waitUntil {sleep 0.5; time > _wait};
		[_ao_marker, _opforSpawned, _winCondition, _ao_name] remoteExec ["COIN_fnc_announceAO", -2];
		
		// Track progress
		waitUntil {
			sleep 30;
			private _opforRemaining = [_ao_marker, east, _ao_size, ["MAN", "STATICWEAPON"]] call ADF_fnc_countRadius;
			diag_log format ["« C O I N »   ADF_fnc_aoActivation - AO number %1 - OpFor remaining: %2 - Win condition: < %3", _ao_number, _opforRemaining, _winCondition];
			_opforRemaining < _winCondition
		};
		
		// AO cleared
		_ao_marker setMarkerColor "ColorGreen";
		{_x setMarkerAlpha 0.65} count COIN_ao_markers;
		
		// Clean-up COIN_ao_groups array
		{if !((count (units _x)) > 0) then {COIN_ao_groups = COIN_ao_groups - [_x]}} forEach COIN_ao_groups;		
		
		// Remaining Opfor will surrender. If they are vehicle crew then add the empty vehicle to an array for deletion
		{
			if !(isNull objectParent (leader _x)) then {
				[_x] spawn {
					params ["_group"];
					_oldVehicle = typeOf (objectParent (leader _group));
					if ADF_missionTest then {diag_log format ["« C O I N »   ADF_fnc_aoActivation - Surrendered group is vehicle crew: %1", _oldVehicle];};
					
					_group call ADF_fnc_surrender;
					
					sleep 1;
					_vehicles = nearestObjects [(leader _group), ["CAR", "APC", "TANK"], 5, true];
					if ADF_missionTest then {diag_log format ["« C O I N »   ADF_fnc_aoActivation - Surrendered crew. Old vehicle: %1 -- Empty vehicle: %1", _oldVehicle, _vehicles # 0];};
					if ((typeOf (_vehicles # 0)) isEqualTo _oldVehicle) then {COIN_ao_allRemainingVehicles pushBack (_vehicles # 0)};
				};
			} else {
				_x call ADF_fnc_surrender;
			};
		} forEach COIN_ao_groups;
		diag_log "--------------------------------------------------------------------------------------------------------";
		diag_log format ["« C O I N »   ADF_fnc_aoActivation - AO vehicles of units surrendered: %1", COIN_ao_allRemainingVehicles];
		
		// Reset ACT values
		if (COIN_ACT && {ADF_ACT_active && {!(isNil "ADF_ACT_vehiclesMax")}}) then {
			ADF_ACT_vehiclesMax = ADF_ACT_vehiclesMaxOrg;
			ADF_ACT_manMax = ADF_ACT_manMaxOrg;
		};
		
		// Re-activate triggers and check end-mission
		if (COIN_ao_triggers isEqualTo [] || {COIN_ao_currentNr > (COIN_ao_number + 1)}) then {
			ADF_endMission = true;
			publicVariable "ADF_endMission";
		} else {
			{_x enableSimulation true} forEach COIN_ao_triggers;
			COIN_ao_active = false; 
			publicVariable "COIN_ao_active";
		};

		// Announce AO cleared
		private _duration = [(time - _startTime), "HH:MM"] call BIS_fnc_secondsToString;
		[_ao_name, _duration, COIN_ao_currentNr] remoteExec ["COIN_fnc_clearedAO", 0, true];
		
		// AO objects clean-up. Check if there are no players left in the AO.
		private _timeOut = time + (10 * 60);
		waitUntil {
			sleep 5;
			((allPlayers inAreaArray _ao_marker) select {alive _x && ((getPosATL _x) # 2) < 15}) isEqualTo [] || ADF_missionTest || time > _timeOut
		};		
		if !ADF_missionTest then {sleep 60} else {sleep 5};
		
		// (surrendered) AO groups + vehicles clean-up. ADF clean-up function will delete weapons and kit
		[COIN_ao_groups] call ADF_fnc_delete;
		[COIN_ao_allRemainingVehicles] call ADF_fnc_delete;
		sleep 3;
		COIN_ao_groups = [];
		COIN_ao_vehicles = [];
		if (!isNil "ADF_HC1" && !ADF_HC_execute) then { 
			(owner ADF_HC1) publicVariableClient "COIN_ao_groups";
			(owner ADF_HC1) publicVariableClient "COIN_ao_vehicles";
		};
		
		if (count _currentLayer > 0) then {{deleteVehicle _x} forEach _currentLayer};
		_ao_marker setMarkerColor "ColorBlue";
		
		// All done. Log AO cleared and close.
		diag_log "--------------------------------------------------------------------------------------------------------";
		diag_log format ["« C O I N »   ADF_fnc_aoActivation - AO number %1 closed and cleaned up.", _ao_number];
		diag_log "--------------------------------------------------------------------------------------------------------";
	};

	// Create FOB
	ADF_fnc_createFOB = {
		params [
			["_fobNumber", 0, [0]],
			["_allMedicalContainers", [], [[]]]
		];
		COIN_ao_active = true; // prevent units from activating multiple AO's which would decrease performance significantly
		
		// Default USMC equipment - RHS
		private _mrap = "rhsusf_CGRCAT1A2_M2_usmc_d";
		private _mrapXL = "rhsusf_M1232_MC_M2_usmc_d";
		private _cmdVehicle = "rhsusf_m1240a1_usmc_d";
		private _bradley = "RHS_M2A3_BUSKIII";
		private _attackHeli = "RHS_AH1Z";
		private _truck = "rhsusf_M1083A1P2_B_M2_D_fmtv_usarmy";
		if !ADF_mod_RHS then {
			_mrap = "CUP_B_RG31_M2_USMC";
			_mrapXL = "CUP_B_RG31E_M2_USMC";
			_cmdVehicle = "CUP_B_M1151_DSRT_USMC";
			_bradley = "CFP_B_USARMY_2003_M2A3_ERA_Bradley_IFV_DES_01";
			_attackHeli = "CFP_B_USMC_AH_1Z_DES_01";
			_truck = "CFP_B_USARMY_2003_MTVR_DES_01";
		};		
		
		private _fobMarker = format ["mBluSpawn_%1", _fobNumber];
		private _fobMarkerPos = getMarkerPos _fobMarker;
		private _fobMarkerDir = markerDir _fobMarker;
		private _fobObjects = [
			["FlagCarrierNATO_EP1", [-0.275391, 0.292236, 0], 121.782, 1, 0, [0.35669, 1.90095], "dummyFlag", "", true, false], 
			[_mrap, [-0.0371094, -13.0746, 0], 0, 1, 0, [1.49804, -1.42697], "vAlpha_1", "", true, false], 
			[_mrap, [5.41602, -13.0577, 0], 0, 1, 0.821925, [1.51174, -1.43133], "vAlpha_2", "", true, false], 
			[_mrap, [-5.54492, -13.0327, 0], 0, 1, 0, [1.1655, -1.30141], "vBravo_2", "", true, false],			
			[_mrap, [-11.1797, -13.0398, 0], 0, 1, 0, [-0.0842839, -0.0839432], "vBravo_1", "", true, false],
			[_cmdVehicle, [10.3828, -11.9618, 0], 0, 1, 0, [0.744045, -1.07204], "vCmd_1", "", true, false],
			[_attackHeli, [10.75, 14.9187, 0.1], 180.002, 1, 0, [0.0618422, -0.186538], "vHawk_1", "", true, false], 
			["Land_HelipadCivil_F", [10.8359, 13.6056, 0], 0, 1, 0, [-0.063, 0.186017], "oRRR_rotor_FOB", "[this] call ADF_fnc_heliPadLights;", true, false], 
			["BlockConcrete_F", [-8.39453, 13.5981, -1.84951], 90, 1, 0, [1.42756, 1.42891], "oRRR_veh_FOB", "", true, false], 
			["Land_ClutterCutter_large_F", [-8.39453, 13.5981, 0], 90, 1, 0, [1.42756, 1.42891], "", "", true, false], 
			["B_Slingload_01_Cargo_F", [15.1914, -13.963, 0], 0, 1, 0, [-2.73736e-005, 0.0623695], "oAmmo_FOB", "", true, false], 
			[_truck, [-3.65625, -22.8756, 0], 180, 1, 0, [0.0637295, -0.232721], "vAlpha_3", "", true, false], 
			[_truck, [-8.93359, -22.8597, 0], 180, 1, 0, [0.0649564, -0.231311], "MHQ", "", true, false], // rhsusf_M1083A1P2_B_M2_D_fmtv_usarmy - MHQ - instead of "vBravo_3"
			[_mrapXL, [1.66211, -23.4027, 0], 180, 1, 0, [-1.06624, 0.155], "vCharlie_1", "", true, false], 
			[_bradley, [8.32813, -22.9855, 0], 180, 1, 0, [-1.39547, 1.37048], "vCowboy_1", "", true, false], 
			["B_Slingload_01_Medevac_F", [15.3281, -21.7167, 0], 0, 1, 0, [1.63936, -1.37749], "oMed_FOB", "", true, false]
		];
		{_x hideObjectGlobal true;} forEach nearestTerrainObjects [_fobMarkerPos, ["TREE", "SMALL TREE", "BUSH", "ROCK", "ROCKS", "FOREST BORDER", "FOREST TRIANGLE", "FOREST SQUARE", "CROSS", "FORTRESS", "FOUNTAIN", "VIEW-TOWER", "LIGHTHOUSE", "QUAY", "HIDE", "BUSSTOP", "ROAD", "FOREST", "TRANSMITTER", "STACK", "TOURISM", "WATERTOWER", "TRACK", "MAIN ROAD", "POWER LINES", "RAILWAY", "POWERSOLAR", "POWERWAVE", "POWERWIND", "SHIPWRECK", "TRAIL"], 38];
		[_fobMarkerPos, _fobMarkerDir, _fobObjects, 0] call BIS_fnc_ObjectsMapper;
		{_x setVectorUp surfaceNormal position _x; _x setDamage 0; [_x, getPosATL _x, getDir _x, vehicleVarName _x] call ADF_fnc_vehicleRespawn} count [vAlpha_1, vAlpha_2, vAlpha_3, vBravo_1, vBravo_2, MHQ, vCmd_1, vCowboy_1, vCharlie_1, vHawk_1, oMed_FOB, oAmmo_FOB];
		private _posVehPlatform = getPosWorld oRRR_veh_FOB;
		private _posHeliPlatform = getPosWorld oRRR_rotor_FOB;
		private _posDummy = getPosWorld dummyFlag;
		
		// Vehicle Config & logi
		private _mod = "CUP";
		if ADF_mod_RHS then {
			[vCmd_1, ["rhs_desert", 1], ["DoorLF", 0, "DoorRF", 0, "DoorLB", 0, "DoorRB", 0, "DUKE_Hide", 0, "hide_spare", 0]] call BIS_fnc_initVehicle;
			{[_x, ["rhs_desert", 1], ["DUKE_Hide", 1]] call BIS_fnc_initVehicle;} forEach [vAlpha_1, vAlpha_2, vBravo_1, vBravo_2];
			_mod = "RHS";
		};
		{_x execVM format ["mission\loadout\vehicles\ADF_vCargo_B_%1_CarMRI.sqf", _mod]} forEach [vAlpha_1, vAlpha_2, vAlpha_3, vBravo_1, vBravo_2, MHQ, vCmd_1, vCowboy_1];
		oMed_FOB execVM "mission\loadout\vehicles\ADF_vCargo_B_facilMedi.sqf";
		vCharlie_1 execVM format ["mission\loadout\vehicles\ADF_vCargo_B_%1_CarMRWT.sqf", _mod];
		oAmmo_FOB execVM format ["mission\loadout\vehicles\ADF_vCargo_B_%1_TruckAmmo.sqf", _mod];

		// Move & set Triggers / Markers / Objects
		deleteVehicle dummyFlag;
		teleportFlagPole setPosWorld _posDummy;
		teleportFlagPole setVectorUp [0, 0, 1];
		publicVariable "teleportFlagPole";
		oRRR_veh_FOB setVectorUp surfaceNormal position oRRR_veh_FOB;
		tRRR_rotor_FOB setPosWorld _posHeliPlatform;
		tRRR_road_FOB setPosWorld _posVehPlatform;
		tRRR_road_FOB setDir _fobMarkerDir;

		"respawn_west" setMarkerPos _posDummy;
		"mRRR_rotor_FOB" setMarkerPos _posHeliPlatform;
		"mRRR_border_rotor_FOB" setMarkerPos _posHeliPlatform;
		"mRRR_veh_FOB" setMarkerPos _posVehPlatform;
		"mRRR_border_veh_FOB" setMarkerPos _posVehPlatform;
		"mRRR_border_veh_FOB" setMarkerDir _fobMarkerDir;
		"mRRR_border_rotor_FOB" setMarkerDir _fobMarkerDir;
		
		if !COIN_EXEC_aoMissions then {COIN_ao_activeMarker = ["m_ao_activeMarker", _posDummy, "ELLIPSE", "", 1000, 1000, 0, "colorBLUFOR", "", "", 0] call ADF_fnc_createMarkerLocal;};
		
		// Loadout & Supplies
		_allMedicalContainers pushBack oMed_FOB;
		oAmmo_FOB allowDamage false;
		oAmmo_FOB spawn ADF_fnc_reStock;
		
		{
			if (typeOf _x isEqualTo "B_Slingload_01_Medevac_F") then {
				_allMedicalContainers pushBack _x;
				_x call ADF_fnc_reloadMedi;
			};
		} forEach ((getMissionLayerEntities "Services") select 0);
		diag_log format ["« C O I N »   ADF_fnc_createFOB - All support medical containers: %1", _allMedicalContainers];
		{_x allowDamage false; [_x] spawn ADF_fnc_reStock} forEach _allMedicalContainers;
		
		private _FOB_LZ_position = format ["mFOB_LZ_%1", _fobNumber];
		if (_FOB_LZ_position in allMapMarkers) then {
			_FOB_LZ_position = getMarkerPos _FOB_LZ_position;
			_FOB_LZ_position set [2, 0];
			{_x hideObjectGlobal true;} forEach nearestTerrainObjects [_FOB_LZ_position, ["TREE", "SMALL TREE", "BUSH", "ROCK", "ROCKS", "FOREST BORDER", "FOREST TRIANGLE", "FOREST SQUARE", "POWER LINES"], 30];
			fob_lz = createVehicle ["Land_HelipadEmpty_F", [0, 0, 0], [], 0, "CAN_COLLIDE"];
			fob_lz setPosATL _FOB_LZ_position;	
			fob_lz setVehicleVarName "fob_lz";
			[fob_lz] call ADF_fnc_addToCurator;
		};

		// Clean up markers/Declutter for MP Zeus
		if isMultiplayer then {
			{				
				if ("MBluSpawn_" in _x || {"mSupport_" in _x || {"mFOB_LZ_" in _x || {"mN_AO_" in _x}}}) then {
					_x setMarkerText "";
					_x setMarkerAlpha 0;
				};		
			} forEach allMapMarkers;		
		};
	}; // ADF_fnc_createFOB

	// Restock the supply/Medi containers every 15-30 min.
	ADF_fnc_reStock = {
		params ["_object"];
		if ((typeOf _object == "B_Slingload_01_Medevac_F") && ADF_mod_ACE3) then {_object setVariable ["ace_medical_isMedicalFacility", true];};
		waitUntil {
			sleep ((random 30) + (15 * 60));
			if (typeOf _object == "B_Slingload_01_Medevac_F") then {
				_object call ADF_fnc_reloadMedi;
			} else {
				_object call ADF_fnc_reloadAmmo;
			};
			!alive _object;
		};
	};
	

	// Vehicle respawn
	ADF_fnc_vehicleRespawn = {
		// [_x, getPosATL _x, getDir _x, vehicleVarName _x] call ADF_fnc_vehicleRespawn
		// Init		
		params [
			["_vehicle", objNull, [objNull]], 
			["_position", [0, 0, 0], [[]], [3]], 
			["_direction", 0, [0]], 
			["_name", "", [""]], 
			["_pause", 120, [0]]
		];

		// Store vars
		_vehicle setVariable ["COIN_vehicleRespawn", [typeOf _vehicle, _position, _direction, _name, _pause]];
		if ADF_missionTest then {diag_log format ["ADF_fnc_vehicleRespawn - COIN_vehicleRespawn: %1 - %3", typeOf _vehicle, _name]};

		// Add the EH
		_vehicle addMPEventHandler [
			"MPKilled", 
			{
				if !isServer exitWith {};
				_this spawn {
					// Init
					params ["_vehicle"];
					private _array = _vehicle getVariable ["COIN_vehicleRespawn", ["rhsusf_rg33_m2_usmc_d", [0, 0, 0], 0, vehicleVarName _vehicle, 30]];
					_array params ["_className", "_position", "_direction", "_name", "_pause"];
					
					// Delete the EH and start the respawn delay
					_vehicle removeAllMPEventHandlers "mpkilled";
					sleep _pause;
					
					// Delete the destroyed vehicle and spawn a new one at the start location
					[_vehicle] call ADF_fnc_delete;
					private _vehicle = createVehicle [_className, [0, 0, 0], [], 0, "CAN_COLLIDE"];
					_vehicle setDamage 0;
					_vehicle allowDamage false;
					_vehicle enableSimulation false;
					_vehicle setDir _direction;	
					_vehicle setPosATL [_position select 0, _position select 1, (_position select 2) + 0.10];
					_vehicle setVectorUp surfaceNormal position _vehicle;			
					[_vehicle, _name] remoteExec ["setVehicleVarName", 0, true];
					_vehicle allowDamage true;
					_vehicle enableSimulation true;					
				
					// Add Loadout & Supplies
					private _mod = "RHS";
					if ADF_mod_CFP then {_mod = "CUP";};
					switch (vehicleVarName _vehicle) do {
						case "RHS_AH1Z": {};
						case "vAlpha_1";
						case "vAlpha_2";
						case "vAlpha_3";
						case "vBravo_1";
						case "vBravo_2";
						case "vCmd_1";
						case "MHQ": {_vehicle execVM format ["mission\loadout\vehicles\ADF_vCargo_B_%1_CarMRI.sqf", _mod]};
						case "vCowboy_1": {_vehicle execVM format ["mission\loadout\vehicles\ADF_vCargo_B_%1_CarMRWT.sqf", _mod]};						
						case "B_Slingload_01_Medevac_F": {
							_vehicle execVM "mission\loadout\vehicles\ADF_vCargo_B_facilMedi.sqf";
							_vehicle call ADF_fnc_reStock;
							if ADF_mod_ACE3 then {_vehicle setVariable ["ace_medical_isMedicalFacility", true]}
						};
						case "B_Slingload_01_Cargo_F": {
							_vehicle execVM format ["mission\loadout\vehicles\ADF_vCargo_B_%1_TruckAmmo.sqf", _mod];
							_vehicle call ADF_fnc_reStock;
						};
					};
				
					// Re-add the EH
					[_vehicle, _position, _direction, _name, _pause] call ADF_fnc_vehicleRespawn;						
				};	
			}
		];
		true
	};

	ADF_fnc_ambientAirRespawn = {
		// Init		
		params [
			["_airFrame", objNull, [objNull]],
			"_allHeliPads"
		];

		// Store vars
		_airFrame setVariable ["COIN_ambientAirClassname", typeOf _airFrame];
		_airFrame setVariable ["COIN_allHeliPads", _allHeliPads];
		
		// Add the EH
		_airFrame addMPEventHandler [
			"MPKilled", 
			{
				if !isServer exitWith {};
				_airFrame spawn {
					// Init
					params ["_airFrame"];
					#include "init_vehicles.sqf"
					private _className = _airFrame getVariable ["COIN_ambientAirClassname", "EXIT"];
					private _allHeliPads = _airFrame getVariable ["COIN_allHeliPads", "EXIT"];
					if (_className isEqualTo "EXIT" || {_allHeliPads isEqualTo "EXIT"}) exitWith {};
					
					// Delete the EH and start the respawn delay
					_airFrame removeAllMPEventHandlers "mpkilled";
					
					// Delete the destroyed vehicle and spawn a new one at the start location
					[_airFrame] call ADF_fnc_delete;
					
					// Add a long random sleep else airspace might seem too crowded
					sleep ((random (30 * 60)) + (random (30 * 60)));
					
					// Create a new air patrol across the enire map.
					private _airFrame = [selectRandom COIN_ambientAirSpawn, [worldSize / 2, worldsize / 2, 2500], east, _army_heli_trp, worldSize / 2, 125, 8, "MOVE", "SAFE", "RED", "NORMAL", "FILE", 150, "ADF_fnc_heliPilotAI"] call ADF_fnc_createAirPatrol;
					
					// Ambient landing
					[_airFrame # 0, _airFrame # 2, _allHeliPads] spawn ADF_fnc_ambientLand;
					
					// Re-add the EH
					[_airFrame # 0, _allHeliPads] call ADF_fnc_airFrameRespawn;

					// Add intel
					[_airFrame # 0, [], true, 20, "", "COIN_fnc_intelFound"] call ADF_fnc_searchIntel;		
				};	
			}
		];
		true	
	};
	
	ADF_fnc_ambientLand = {
		// init
		params [
			"_airFrame",
			"_group",
			"_allHeliPads",
			["_allPositions", [], [[]]]
		];
		
		sleep 90; // give heli change to gain speed + alt.
		
		private _allWaypoints = waypoints _group;
		private _altitude = (getPosATL _airFrame) select 2;
		private _airSpeed = speed _airFrame;	
		if (_altitude < 100) then {_altitude = 100;};
		
		{
			_pos = getPosATL _x;
			_allPositions pushBack _pos;
		} forEach _allHeliPads;
		
		waitUntil {
			{			
				private _distance = _airFrame distance _x;			
				if (_distance < 1000 && {random 100 > 60}) then {
					// Start landing process
					_group lockWP true;
					_airFrame limitSpeed (speed _airFrame/1.3);
					_airFrame flyInHeight 75;
					_group move _x;				
					
					waitUntil {sleep 0.5; (_airFrame distance _x) < 500};
					_airFrame limitSpeed 80;
					_airFrame land "land";
					
					// Aircraft has 90 secs to land. If successful with landing, it will wait on the tarmac before takeoff.
					private _timeout = time + 90;

					waitUntil {isTouchingGround _airFrame || (time > _timeout) || !(alive _airFrame)};
					if (!(alive _airFrame) || (time > _timeout)) exitWith {};
					
					// Switch off and wait
					_airFrame flyInHeight 0;
					_airFrame engineOn false;
					{_airFrame animateDoor [(configName _x), 1]} forEach ("((toLower (getText (_x >> 'source'))) == 'door')" configClasses (configFile >> "CfgVehicles" >> (typeOf _airFrame) >> "AnimationSources"));
					sleep ((random 5) * 60);
					
					// Take off and continue patrol
					if !(alive _airFrame) exitWith {};
					_airFrame setFuel 1;
					_airFrame setDamage 0;
					_airFrame engineOn true;
					_airFrame flyInHeight 0;
					{_airFrame animateDoor [(configName _x), 0]} forEach ("((toLower (getText (_x >> 'source'))) == 'door')" configClasses (configFile >> "CfgVehicles" >> (typeOf _airFrame) >> "AnimationSources"));
					sleep ((random 5) * 10);
					
					_airFrame engineOn true;
					_airFrame flyInHeight _altitude;
					_airFrame limitSpeed _airSpeed;
					_group lockWP false;
					sleep (300 + (15 * (random 60)));
				};			
			} forEach _allPositions;
			
			sleep 5;
			!alive _airFrame
		};
	};
	
	COIN_fnc_intelFound = {
		params ["_object", "_caller", "_intelFound", "_messageID"];
		if ADF_missionTest then {hint parseText format ["<t size='2'>INTEL FOUND</t><br/><br/><t align='left'>Object: %1<br/>Caller: %2<br/>IntelFound: %3<br/>MessageID: %4</t>", _object, _caller, _intelFound, _messageID]};
	};
	
	// Ambient Air Spawn locations
	private _worldSize = worldSize;
	private _edgeDist = call {
		if (_worldSize > 25000) exitWith {3000};
		if (_worldSize > 10000) exitWith {2000};
		if (_worldSize > 0) then {1000};
	};
	private _mapEdge = ((round (_worldSize / 1000)) * 1000);
	diag_log format ["« C O I N »   init_server.sqf - World %1, Size: %2", COIN_WorldName, _mapEdge];
	{
		private _name = format ["mAir_%1", (_forEachIndex + 1)];
		private _marker = createMarkerLocal [_name, _x];		
		COIN_ambientAirSpawn pushBack _name;
		if ADF_missionTest then {
			_marker setMarkerShapeLocal "ICON";
			_marker setMarkerTypeLocal "mil_box";
			_marker setMarkerSizeLocal [0.5 , 0.5];
			_marker setMarkerColorLocal "ColorGREEN";
			_marker setMarkerTextLocal format ["Nr: %1", (_forEachIndex + 1)];
		};
	} forEach [
		[_mapEdge + _edgeDist, _mapEdge + _edgeDist, 0],
		[_mapEdge + _edgeDist, -1000, 0],
		[-1000, _mapEdge + _edgeDist, 0],	
		[-1000, -1000, 0], 
		[-1000, _mapEdge / 2, 0], 
		[_mapEdge / 2, -1000, 0],
		[_mapEdge / 2, _mapEdge + _edgeDist, 0], 
		[_mapEdge + _edgeDist, _mapEdge / 2, 0]	
	];
	diag_log format ["« C O I N »   init_server.sqf - Ambient Air Traffic. Positions: %1", COIN_ambientAirSpawn];
	if (!isNil "ADF_HC1" && !ADF_HC_execute) then {(owner ADF_HC1) publicVariableClient "COIN_ambientAirSpawn";};
	
	waitUntil {!isNil "ADF_preInit"};
	
	///// FIRST RUN

	// Create data sets
	COIN_ao_number = -1;
	COIN_ao_triggers = [];
	COIN_ao_markers = [];
	COIN_ao_layers = [];

	{ // 0.122349 ms
		if ("mAO_" in _x) then {
			COIN_ao_number = COIN_ao_number + 1;
			COIN_ao_markers pushBack (format ["mAO_%1", COIN_ao_number]);
			COIN_ao_layers pushBack (format ["lAO_%1", COIN_ao_number]);		
			COIN_ao_triggers pushBack (missionNamespace getVariable [format ["tAO_%1", COIN_ao_number], objNull]);
		};
		if ("mRRR_veh_" in _x) then {_x call ADF_fnc_reMarker;};
		if ("mRRR_rotor" in _x) then {_x call ADF_fnc_reMarker;};			
		if ("mMed_" in _x) then {_x call ADF_fnc_reMarker;};			
	} forEach allMapMarkers;

	COIN_totalAOs = COIN_ao_number + 1;
	COIN_ao_markers pushBack (format ["mAO_%1", COIN_totalAOs]);
	COIN_ao_layers pushBack (format ["lAO_%1", COIN_totalAOs]);		
	COIN_ao_triggers pushBack (missionNamespace getVariable [format ["tAO_%1", COIN_totalAOs], objNull]);	
	
	// COIN_ao_markers changes when AO becomes active. COIN_ao_all is constant.
	COIN_ao_all = COIN_ao_markers;
	if (!isNil "ADF_HC1" && !ADF_HC_execute) then {missionNamespace setVariable ["COIN_ao_all", COIN_ao_markers, owner ADF_HC1]};
			
	publicVariable "COIN_totalAOs";
	diag_log "--------------------------------------------------------------------------------------------------------";
	diag_log "« C O I N »   MISSION PARAMS CONFIG";
	diag_log format ["« C O I N »   init_server.sqf - Params - Execute AO missions: %1", COIN_EXEC_aoMissions];
	diag_log format ["« C O I N »   init_server.sqf - Params - Execute side missions: %1", COIN_EXEC_sideMissions];
	diag_log format ["« C O I N »   init_server.sqf - Params - Mod config - RHS: %1 -  CUP %2", ADF_mod_RHS, ADF_mod_CFP];
	diag_log format ["« C O I N »   init_server.sqf - Params - Ambient Air Traffic: %1", [false, true] select (("ADF_air_traffic" call BIS_fnc_getParamValue) == 1)];
	diag_log format ["« C O I N »   init_server.sqf - Params - Ambient Civilian Traffic's: %1", [false, true] select (("ADF_map_ACT" call BIS_fnc_getParamValue) == 1)];
	diag_log format ["« C O I N »   init_server.sqf - Params - VBED's: %1",  [false, true] select (("ADF_ACT_VBEDs" call BIS_fnc_getParamValue) == 1)];
	diag_log format ["« C O I N »   init_server.sqf - Params - IED's: %1", [false, true] select (("ADF_map_IEDs" call BIS_fnc_getParamValue) == 1)];
	diag_log format ["« C O I N »   init_server.sqf - Params - Armed civilians: %1", [false, true] select (("ADF_ACT_armedCiv" call BIS_fnc_getParamValue) == 1)];
	diag_log format ["« C O I N »   init_server.sqf - Params - Suicide bombers: %1", [false, true] select (("ADF_ACT_suicideBombers" call BIS_fnc_getParamValue) == 1)];
	diag_log "--------------------------------------------------------------------------------------------------------";
	diag_log "« C O I N »   MISSION MAP/WORLD CONFIG";
	diag_log format ["« C O I N »   init_server.sqf - Total markers: %1", COIN_totalAOs];
	diag_log format ["« C O I N »   init_server.sqf - Trigger dataset created: %1", COIN_ao_triggers];
	diag_log format ["« C O I N »   init_server.sqf - Markers dataset created: %1", COIN_ao_markers];
	diag_log format ["« C O I N »   init_server.sqf - Layers dataset created: %1", COIN_ao_layers];
	diag_log "--------------------------------------------------------------------------------------------------------";
	
	// Set mission start time
	private _hour = 0;
	private _min = round (random 60);
	private _fog = false;
	switch ("ADF_missionTime" call BIS_fnc_getParamValue) do {	
		case 1: {_hour = 6; _fog = true};
		case 2: {_hour = 9;};
		case 3: {_hour = 12; _min = 0;};
		case 4: {_hour = 14;};
		case 6: {_hour = 19;};
		case 7: {_min = 0};
		case 5;
		case 0;
		default	{_hour = 16};
	};
	setDate [2011, 6, 8, _hour, _min];

	// Add fog for early morning missions
	if (_fog) then {
		1 setFog [1, 0.01, 0];
		(45*60) setFog 0;
	};

	// Compile scripts
	ADF_fnc_reloadMedi = compile preprocessFileLineNumbers "mission\loadout\vehicles\ADF_vCargo_B_facilMedi.sqf";
	ADF_fnc_reloadAmmo = compile preprocessFileLineNumbers "mission\loadout\vehicles\ADF_vCargo_B_RHS_TruckAmmo.sqf";

	// Hide AO objects globally
	{
		private _ao_layer = _x;
		{_x hideObjectGlobal true} forEach ((getMissionLayerEntities _ao_layer) select 0);
	} forEach COIN_ao_layers;
	

	///// INITIAL AO & SPAWN LOCATION

	COIN_ao_currentNr = 0; // counter for the number of AO's spawned

	// AO & FOB
	private _ao_number = floor random COIN_ao_number;
	//private _ao_number = 0; // debug	
	diag_log format ["« C O I N »   init_server.sqf - First AO number selected: %1", if COIN_EXEC_aoMissions then {_ao_number} else {false}];
	#include "init_ao_fob.sqf"	
	private _ao_trigger = call compile format ["tAO_%1", _ao_number];
	diag_log format ["« C O I N »   init_server.sqf - First FOB number selected: %1", _fobNumber];
	diag_log format ["« C O I N »   init_server.sqf - First AO trigger selected: %1", if COIN_EXEC_aoMissions then {_ao_trigger} else {false}];
	
	[_fobNumber] call ADF_fnc_createFOB;
	
	if COIN_EXEC_aoMissions then {
		[_ao_number, _ao_trigger] spawn ADF_fnc_aoActivation;
	} else {	
		{_x setMarkerAlpha 0} forEach COIN_ao_markers;
		{[_x] call ADF_fnc_delete} forEach COIN_ao_triggers;
		{
			_layer = _x;
			{				
				[_x] call ADF_fnc_delete
			} forEach (getMissionLayerEntities _layer);
		} forEach COIN_ao_layers;
	};
	
	// Easter Eggs
	
	if !(COIN_EasterEgg isEqualTo []) then {
		private _class = ["CUP_B_M1A2_TUSK_MG_DES_USMC", "rhsusf_m1a1fep_d"] select ADF_mod_RHS;
		{
			if (random 100 > 20) then {
				private _tank = createVehicle [_class, [0, 0, 0], [], 0, "CAN_COLLIDE"];
				_tank setDir _x # 1;
				_tank setPosATL _x # 0;
				diag_log format ["« C O I N »   Easter egg (%1) created at: %2", _class, mapGridPosition (_x # 0)];
			};
		} forEach COIN_EasterEgg
	};

	///// MISC

	// Ambient Air Traffic
	if (("ADF_air_traffic" call BIS_fnc_getParamValue) == 1) then {
		[] spawn {
			#include "init_vehicles.sqf"
			private _worldSize = worldSize;
			waitUntil {sleep 0.15; !(COIN_ambientAirSpawn isEqualTo [])};		
			if COIN_ambientAir then {
				[
					COIN_ambientAirSpawn, COIN_ambientAirSpawn, oPad_1, 10, 60, east, _army_heli_trp, false, "ADF_fnc_redressArmy_pilot", "", true, "COIN_air_2"
				] spawn ADF_fnc_ambientAirTraffic;
				sleep (30 + (random 600));	
				[
					COIN_ambientAirSpawn, COIN_ambientAirSpawn, oPad_2, 10, 60, east, _army_heli_trp, false, "ADF_fnc_redressArmy_pilot", "", true, "COIN_air_2"
				] spawn ADF_fnc_ambientAirTraffic;
				sleep (120 + (random 600));		
				[
					COIN_ambientAirSpawn, COIN_ambientAirSpawn, oPad_3, 10, 60, east, _army_heli_trp, false, "ADF_fnc_redressArmy_pilot", "", true, "COIN_air_3"
				] spawn ADF_fnc_ambientAirTraffic;			
				sleep (90 + (random 600));
				[
					COIN_ambientAirSpawn, COIN_ambientAirSpawn, oPad_4, 10, 60, east, _army_heli_trp, false, "ADF_fnc_redressArmy_pilot", "", true, "COIN_air_3"
				] spawn ADF_fnc_ambientAirTraffic;				
				sleep (60 + (random 600));
				[
					COIN_ambientAirSpawn, COIN_ambientAirSpawn, oPad_6, 5, 45, east, _army_heli_trp, false, "ADF_fnc_redressArmy_pilot", "", true, "COIN_air_1"
				] spawn ADF_fnc_ambientAirTraffic;			
				sleep (30 + (random 600));	
				[
					COIN_ambientAirSpawn, COIN_ambientAirSpawn, oPad_5, 5, 30, east, _army_heli_trp, false, "ADF_fnc_redressArmy_pilot", "", true, "COIN_air_1"
				] spawn ADF_fnc_ambientAirTraffic;
				if (_worldSize > 10000) then {
					sleep (30 + (random 600));	
					[
						COIN_ambientAirSpawn, COIN_ambientAirSpawn, false, 25, 60, east, _army_air_CAS, true, "ADF_fnc_redressArmy_pilot", "", false
					] spawn ADF_fnc_ambientAirTraffic;
				};
			} else {
				waitUntil {sleep 0.5; time > 45};				
				_allHeliPads = [_worldSize / 2, _worldSize / 2, 0] nearObjects ["HeliH", _worldSize * 1.5]; // 15.4 ms
				_allHeliPads deleteAt (_allHeliPads find fob_lz);
				_allHeliPads deleteAt (_allHeliPads find oRRR_rotor_FOB);
				if ADF_missionTest then {diag_log format ["« C O I N »   init_server.sqf - Helipads found: %1", _allHeliPads];};
				
				if (_worldSize < 7500) then {
					[COIN_ambientAirSpawn, COIN_ambientAirSpawn, false, 15, 45, east, _army_heli_trp, false, "ADF_fnc_redressArmy_pilot"] spawn ADF_fnc_ambientAirTraffic;			
				} else {
					private _airFrame = [selectRandom COIN_ambientAirSpawn, [_worldSize / 2, _worldSize / 2, 2500], east, selectRandom _army_heli_trp, _worldSize / 1.8, 125, 8, "MOVE", "SAFE", "RED", "NORMAL", "FILE", 150, "ADF_fnc_heliPilotAI"] call ADF_fnc_createAirPatrol;
					[_airFrame # 0, _allHeliPads] call ADF_fnc_ambientAirRespawn;
					[_airFrame # 0, _airFrame # 2, _allHeliPads] spawn ADF_fnc_ambientLand;
					if (_worldSize < 10000) exitWith {}; 
					[COIN_ambientAirSpawn, COIN_ambientAirSpawn, false, 15, 60, east, _army_heli_trp, false, "ADF_fnc_redressArmy_pilot"] spawn ADF_fnc_ambientAirTraffic;
					if (_worldSize < 12000) exitWith {}; 
					sleep (10 * 60);
					[COIN_ambientAirSpawn, COIN_ambientAirSpawn, false, 20, 60, east, _army_air_CAS, false, "ADF_fnc_redressArmy_pilot"] spawn ADF_fnc_ambientAirTraffic;	
				};
			};	
		};
	}; // Ambient Air Traffic
	

	// ADF_mod_ACT
	if COIN_EXEC_ACT then {
		[] spawn {
			// Delay spawn 10 min
			if !ADF_missionTest then {
				private _timeout = time + (60 * 10);
				waitUntil {sleep 1; time > _timeout};
			};

			// Init
			ADF_ACT_active = true;
			private _ACT_veh = 4;
			private _ACT_man = 3;	
			private _fps = round diag_fps;
			if (_fps < 25) then {
				ADF_ACT_active = false;
				diag_log "--------------------------------------------------------------------------------------------------------";
				diag_log format ["« C O I N »   Start-up of Ambient Civilians (ACT) PAUSED due to server FPS being < 25 (%1).", _fps];
				diag_log "--------------------------------------------------------------------------------------------------------";
				
				// wait another 10 minutes.
				private _timeout = time + (60 * 10);
				waitUntil {sleep 1; time > _timeout};
				private _fps = round diag_fps;
				
				if (_fps < 25) then {
					diag_log "--------------------------------------------------------------------------------------------------------";
					diag_log format ["« C O I N »   Start-up of Ambient Civilians (ACT) CANCELLED due to server FPS being < 25 (%1).", _fps];
					diag_log "--------------------------------------------------------------------------------------------------------";
					
				} else {
					ADF_ACT_active = true;
				};
			};
			if !ADF_ACT_active exitWith {};

			// Server FPS seems good. Let's start ACT
			diag_log "--------------------------------------------------------------------------------------------------------";
			diag_log format ["« C O I N »   init_server.sqf - Ambient Civilians (ACT) Started. FPS: %1", _fps];
			diag_log "--------------------------------------------------------------------------------------------------------";
			if (_fps > 40) then {_ACT_veh = 5; _ACT_man = 5;};
			
			ACT_debug = false;
			ADF_ACT_vehiclesMax = if COIN_ACT then {_ACT_veh} else {0};
			ADF_ACT_vehiclesRadiusSpawn = 750;
			ADF_ACT_vehiclesRadiusTerm = 1500;
			ADF_ACT_manMax = _ACT_man;
			ADF_ACT_manRadiusTerm = 500;
			ADF_ACT_terrorist = [false, true] select (("ADF_ACT_suicideBombers" call BIS_fnc_getParamValue) == 1);
			ADF_ACT_terroristChance = 5;
			ADF_ACT_armedCiv = [false ,true] select (("ADF_ACT_armedCiv" call BIS_fnc_getParamValue) == 1);
			ADF_ACT_armedCivChance = 10; 
			ADF_ACT_vbed = [false, true] select (("ADF_ACT_VBEDs" call BIS_fnc_getParamValue) == 1);
			ADF_ACT_vbedChance = 3;			

			execVM "ADF\fnc\ambient\ADF_fnc_ACT.sqf";
		};
	}; // ADF_mod_ACT

	// roadside IED's
	if ((("ADF_map_IEDs" call BIS_fnc_getParamValue) == 1) && {COIN_IED}) then {
		
		[true, west, round (_worldSize/1000), 100, 500] call ADF_fnc_createIED;
		
		// VBED's
		[true, west, round (_worldSize/4000), 100, 500, 5, true, ["C_Van_01_box_F", "C_Offroad_01_covered_F", "C_Van_01_fuel_F", "C_Truck_02_fuel_F", "C_Truck_02_covered_F", "RHS_Ural_Civ_01", "RHS_Ural_Civ_02"]] call ADF_fnc_createIED;
	};
	
	// Fly by
	if (random 100 > 66) then {
		[] spawn {	
			#include "init_vehicles.sqf"
			private _position = getMarkerPos (selectRandom COIN_ambientAirSpawn);
			private _direction = _position getDir teleportFlagPole;
			private _airframe = selectRandom _army_air_CAS;
			private _timeOut = time + (100 + (random 200));
			waitUntil {sleep 1; time > _timeOut};
			
			_group = createGroup civilian;
			private _air1 = [_position, _direction, _airframe, _group, "", "", false, false] call ADF_fnc_createCrewedVehicle;
			private _air2 = [[(_position # 0) + 500, (_position # 1) + 500, 300], _direction, _airframe, _group, "", "", false, false] call ADF_fnc_createCrewedVehicle;
			private _wp = [_group, getPos teleportFlagPole, 50, "MOVE", "SAFE", "WHITE", "NORMAL", "ECH LEFT", 25, "air"] call ADF_fnc_addWaypoint;
			private _wp = [_group, getMarkerPos (selectRandom COIN_ambientAirSpawn), 50, "MOVE", "SAFE", "WHITE", "NORMAL", "ECH LEFT", 25, "air"] call ADF_fnc_addWaypoint;
			waitUntil {(currentWaypoint (_wp select 0)) > (_wp select 1)};	
			{[_x] call ADF_fnc_delete} forEach [_air1 # 1, _air2 # 1, _air1 # 0, _air2 # 0, _group];
		};
	};

	[format ["init_server.sqf - Diag time to execute function: %1", diag_tickTime - _diagTime]] call ADF_fnc_log;
};	