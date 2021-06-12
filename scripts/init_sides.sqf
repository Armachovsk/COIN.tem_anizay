///// SIDES CONFIG

COIN_sideMissions = [
/****************************************************************************************************************************
 [0:Number, 1:Type, 2:AO-type 3:Max Time, 4:Scene-size, 5:AO-Size, 6:#foot patrols, 7:#garrison, 8:#techs, 9:Inf Type, 10:flat surface?, 11:Name, 12:Brief]
	1:Mission Type
		1: rescue
		2: intel
		3: destroy
		4: defend
	2:AO-type
		1: location
		2: COIN AO marker
		3: Random map
	9:Inf Type
		1: Insurgents
		2: TKA
		3: Mixed
****************************************************************************************************************************/
	[0, 2, 3, 45, 20, 500, 4, 1, 1, 2, true, localize "STR_ADF_sides_0_Title", localize "STR_ADF_sides_0_Desc"], // Search and Retrieve Intel
	[1, 1, 1, 40, 0, 700, 2, 6, 0, 1, false, localize "STR_ADF_sides_1_Title", localize "STR_ADF_sides_1_Desc"], // Hostage rescue
	[2, 2, 1, 20, 0, 700, 1, 5, 0, 2, false, localize "STR_ADF_sides_2_Title", localize "STR_ADF_sides_2_Desc"], // Obtain Intel From Laptop
	[3, 3, 3, 30, 30, 500, 3, 1, 1, 2, true, localize "STR_ADF_sides_3_Title", localize "STR_ADF_sides_3_Desc"], // Destroy Computer Servers
	[4, 3, 1, 30, 0, 700, 1, 5, 1, 1, false, localize "STR_ADF_sides_4_Title", localize "STR_ADF_sides_4_Desc"], // assassinate targets
	[5, 3, 2, 30, 10, 1000, 3, 2, 1, 2, false, localize "STR_ADF_sides_5_Title", localize "STR_ADF_sides_5_Desc"], // Destroy Radar Communications Station
	[6, 3, 3, 30, 40, 500, 3, 1, 1, 2, true, localize "STR_ADF_sides_6_Title", localize "STR_ADF_sides_6_Desc"], // Destroy Armory
	[7, 3, 2, 45, 0, 800, 1, 6, 1, 1, false, localize "STR_ADF_sides_7_Title", localize "STR_ADF_sides_7_Desc"], //Search and Destroy Weapons Caches
	[8, 3, 3, 30, 10, 500, 4, 0, 0, 1, false, localize "STR_ADF_sides_8_Title", localize "STR_ADF_sides_8_Desc"], // Search and Destroy Helicopter
	[9, 3, 3, 30, 30, 800, 2, 2, 1, 1, false, localize "STR_ADF_sides_9_Title", localize "STR_ADF_sides_9_Desc"], // Search and Destroy Enemy Camp
	[10, 3, 1, 30, 40, 700, 3, 1, 1, 1, true, localize "STR_ADF_sides_10_Title", localize "STR_ADF_sides_10_Desc"], // Search and Destroy Opium Warehouse
	[11, 3, 3, 30, 30, 700, 3, 1, 1, 1, true, localize "STR_ADF_sides_11_Title", localize "STR_ADF_sides_11_Desc"], // Search and Destroy Oil Facility
	[12, 3, 1, 30, 20, 500, 2, 2, 1, 1, false, localize "STR_ADF_sides_12_Title", localize "STR_ADF_sides_12_Desc"], // Search and Destroy IED Production Facility
	[13, 3, 3, 30, 40, 800, 3, 1, 2, 2, false, localize "STR_ADF_sides_13_Title", localize "STR_ADF_sides_13_Desc"], // Destroy TKA Armoured Group
	[14, 3, 3, 30, 10, 800, 3, 0, 2, 1, false, localize "STR_ADF_sides_14_Title", localize "STR_ADF_sides_14_Desc"], // Search and Destroy Oil Tanker Vehicle
	[15, 1, 2, 40, 0, 1000, 1, 6, 2, 1, false, localize "STR_ADF_sides_15_Title", localize "STR_ADF_sides_15_Desc"], // Retrieve Informant
	[16, 4, 1, 40, 0, 300, 1, 0, 0, 1, false, localize "STR_ADF_sides_16_Title", localize "STR_ADF_sides_16_Desc"], // Defend Location
	[17, 3, 3, 30, 50, 800, 3, 1, 1, 2, false, localize "STR_ADF_sides_17_Title", localize "STR_ADF_sides_17_Desc"], // Destroy AA site
	[18, 3, 3, 30, 30, 800, 5, 0, 1, 2, false, localize "STR_ADF_sides_18_Title", localize "STR_ADF_sides_18_Desc"] // Destroy arti site
];
COIN_allSideMissions = COIN_sideMissions;
diag_log format ["« C O I N »  Number of COIN_sideMissions: %1", count COIN_sideMissions];

//COIN_ao_activeMarker = "mAO_1"; // debug

///// CLIENTS

if hasInterface then {
	COIN_fnc_hackIntel = {
		params ["_duration"];
		private _sleep = _duration / 80; // passed sleep divided by number of transfer bars
		private _barsGray = 79;
		private _barsGreen = 1;

		waitUntil {
			private _stringGray = [];
			private _stringGreen = [];
			
			for "_i" from 1 to _barsGray do {
				_stringGray pushBack "|"
			};
			_stringGray = _stringGray joinString "";
			
			for "_y" from 1 to _barsGreen do {
				_stringGreen pushBack "|"
			};
			_stringGreen = _stringGreen joinString "";
			
			hintSilent parseText format ["<t color='#6C7169' size='1.1' font='EtelkaNarrowMediumPro'>Transfering</t><br/><t color='#00fc18' size='1.1' font='EtelkaNarrowMediumPro'>%1</t><t color='#2f2f2f' size='1.1' font='EtelkaNarrowMediumPro'>%2</t><br/><br/>", _stringGreen, _stringGray];
			_barsGray = _barsGray - 1;
			_barsGreen = _barsGreen + 1;
			uiSleep _sleep;
			_barsGreen == 80
		};
	};
	
	COIN_fnc_msg_sideMission = {
		// init
		params [
			["_messageType", 1, [0]],
			"_missionNr",
			["_completedNr", 0, [1]],
			["_rewardDesc", "", [""]],
			["_text_Hintdesc", "", [""]],
			["_text_logdesc", "", [""]]
		];

		call {
			if (_messageType == 1) exitWith { // Announce
				_text_Hintdesc = format ["<t color='#6C7169' size='1.1' align='left'>%1</t><br/><br/>", COIN_activeMission # 12];
				_text_logdesc = format ["<font color='#6C7169' size='14' align='left'>%1</font><br/><br/>", COIN_activeMission # 12];
			};
			if (_messageType == 2) exitWith { // Success
				_text_Hintdesc = format [localize "STR_ADF_side_msgAll_hint_2", _completedNr, _rewardDesc];
				_text_logedsc = format [localize "STR_ADF_side_msgAll_log_2", _completedNr, _rewardDesc];
			};
			if (_messageType == 3) exitWith { // Fail
				_text_Hintdesc = localize "STR_ADF_side_msgAll_hint_3";
				_text_logedsc = localize "STR_ADF_side_msgAll_log_3"
			};
			if (_messageType == 4) exitWith { // Reward deleted
				_text_Hintdesc = format [localize "STR_ADF_side_msgAll_hint_4", _rewardDesc];
				_text_logedsc = format [localize "STR_ADF_side_msgAll_log_4", _rewardDesc];
			};
		};
		private _logTime = [dayTime] call BIS_fnc_timeToString;
		private _logTimeText = format ["Log: %1", _logTime];		
		private _logMessage = format ["<br/><br/><font color='#9da698' size='14'>From: MOTHER</font><br/><font color='#9da698' size='14'>Time: %1</font><br/><br/><font color='#6c7169'>------------------------------------------------------------------------------------------</font><br/><br/><font color='#A1A4AD' size='15'>%2</font><br/><font color='#A1A4AD' size='17'>%3</font><br/><br/>%4", _logTime, localize "STR_ADF_sides_sideMission", COIN_activeMission # 11, _text_logdesc];
		player createDiaryRecord ["COIN Log", [_logTimeText, _logMessage]];

		hint parseText format ["<img size='5' shadow='false' image='mission\images\intro_coin.paa'/><br/><br/><t color='#A1A4AD' size='1.5'>%1</t><br/><t color='#A1A4AD' size='2'>%2</t><br/><br/>%3", localize "STR_ADF_sides_sideMission", COIN_activeMission # 11, _text_Hintdesc];
	};
	
	if (player isEqualTo COIN_leadership) then {
		COIN_fnc_assignSidesMissionSkip = {
			sidesActionID = COIN_leadership addAction [
				localize "STR_ADF_sides_skipAction",{
					COIN_sideMission_skipped = true;					
					publicVariableServer "COIN_sideMission_skipped";
					COIN_leadership removeAction _this # 2;	
					COIN_leadership call COIN_fnc_assignSidesMissionSkip;
				}, [], -95, false, true, "", ""
			];
		};
		player call COIN_fnc_assignSidesMissionSkip;
	};
};


///// HC/SERVER

if ADF_HC_execute then {
	COIN_fnc_spawnSideMission = {
		// init
		params [
			"_missionPosition",
			"_missionAOSize",
			"_missionInfType",
			"_missionInfPatrols",
			"_missionInfGarrison",
			"_missionTechs"
		];
		
		#include "init_vehicles.sqf"
		
		if ((_missionInfGarrison > 0) && !COIN_EXEC_aoMissions) then {_missionInfGarrison = _missionInfGarrison + 2};
		if ((_missionInfPatrols > 0) && !COIN_EXEC_aoMissions) then {_missionInfPatrols = _missionInfPatrols + 2};
		if !COIN_EXEC_aoMissions then {_missionTechs = _missionTechs + 1};
		
		private _loadout = switch _missionInfType do {
			case 1: {"ADF_fnc_redressInsurgents"};
			case 2: {"ADF_fnc_redressArmy_inf"};
			case 3: {-1};
			default {"ADF_fnc_redressInsurgents"};
		};
		
		// Infantry patrols
		if (_missionInfPatrols > 0) then {
			for "_i" from 1 to _missionInfPatrols do {
				private _sizeRandom = random 1.5;
				if (_loadout isEqualType 0) then {_loadout = selectRandom ["ADF_fnc_redressInsurgents", "ADF_fnc_redressArmy_inf"]};
				private _groupSize = [selectRandom [4, 8, 4, 8] ,selectRandom [2, 4, 2, 8, 4, 4]] select COIN_EXEC_aoMissions;
				private _group = [_missionPosition, east, _groupSize, false, _missionAOSize * _sizeRandom, 4, "MOVE", "SAFE", "RED", "LIMITED", "FILE", 5, false, _loadout, ""] call ADF_fnc_createFootPatrol;
				COIN_sideMission_groups pushBack _group;
			};
		};
		
		// Infantry garrison
		if (_missionInfGarrison > 0) then {
			for "_i" from 1 to _missionInfGarrison do {
				private _groupSize = [8 ,4] select COIN_EXEC_aoMissions;
				if (_loadout isEqualType 0) then {_loadout = selectRandom ["ADF_fnc_redressInsurgents", "ADF_fnc_redressArmy_inf"]};
				private _group = [_missionPosition, east, 8, false, _missionAOSize, false, _loadout, "", -1, selectRandom [true, false]] call ADF_fnc_createGarrison;
				COIN_sideMission_groups pushBack _group;
			};
		};
		
		// Technicals
		if (_missionTechs > 0) then {
			if (_missionAOSize < 750) then {_missionAOSize = 750};
			_missionPosition set [2, 0];
			for "_i" from 1 to _missionTechs do {

				// Find road position within the parameters (near to the random position)
				if (_missionAOSize < 750) then {_missionAOSize = 750};
				private _vehSpawnPosition = [_missionPosition, _missionAOSize * 2, 50, true, 7] call ADF_fnc_roadSidePos;
				
				// Create the vehicle
				private _vehicle = [_vehSpawnPosition # 0, "", east, selectRandom _army_tech, _missionAOSize * 2, 4, "MOVE", "SAFE", "RED", "NORMAL", 25, "ADF_fnc_redressArmy_inf"] call ADF_fnc_createVehiclePatrol;
				(_vehicle # 0) setVariable ["BIS_enableRandomization", false];
				(_vehicle # 0) limitSpeed 70;
				COIN_sideMission_groups pushBack _vehicle # 2;
				COIN_sideMission_vehicles pushBack (_vehicle # 0);
			};
		};
		COIN_sideMission_spawned = true;
		if !isServer then {			
			publicVariableServer "COIN_sideMission_spawned";
			publicVariableServer "COIN_sideMission_groups";
			publicVariableServer "COIN_sideMission_vehicles";
		};
		
		diag_log "--------------------------------------------------------------------------------------------------------";
		diag_log format ["« C O I N »   COIN_fnc_spawnSideMission - COIN_sideMission_spawned: %1", COIN_sideMission_spawned];
		diag_log format ["« C O I N »   COIN_fnc_spawnSideMission - Total side mission groups: %1", count COIN_sideMission_groups];
		diag_log format ["« C O I N »   COIN_fnc_spawnSideMission - Side mission groups: %1", COIN_sideMission_groups];
		diag_log format ["« C O I N »   COIN_fnc_spawnSideMission - Total side mission vehicles: %1", count COIN_sideMission_vehicles];
		diag_log format ["« C O I N »   COIN_fnc_spawnSideMission - Side mission vehicles: %1", COIN_sideMission_vehicles];
		diag_log "--------------------------------------------------------------------------------------------------------";
	};
	
	COIN_fnc_deleteSideMission = {
		// init
		params [
			"_missionPosition",
			"_missionAOSize",
			"_missionSceneSize",
			"_missionMarker",
			["_forcedDeletion", false, [true]]
		];
		
		// Delete the marker
		[_missionMarker] call ADF_fnc_delete;
		
		private _timeOut = time + (10 * 60); // 10 minutes
		waitUntil {
			sleep 5;
			private _playersClose = false;	
			// Check if players are still in the side mission AO
			{if ((_missionPosition distance _x) < _missionAOSize) exitWith {_playersClose = true}} forEach allPlayers select {((getPosATL _x) select 2) < 5};			
			!_playersClose || ADF_missionTest || time > _timeOut || _forcedDeletion
		};
		
		// Cleanup the scene, patrols and garrisoned units
		private _scene = nearestObjects [_missionPosition, ["all"], _missionSceneSize, true];
		[_scene] call ADF_fnc_delete;
		
		[COIN_sideMission_groups] call ADF_fnc_delete;
		[COIN_sideMission_vehicles] call ADF_fnc_delete;
		
		COIN_sideMission_groups = [];
		COIN_sideMission_vehicles = [];
		COIN_sideMission_spawned = false;
		true
	};	
}; // ADF_HC_execute


///// SERVER

if isServer then {
	///// MISSION START

	COIN_sideMission_test = false;
	private _delay = 300; // 5 mins
	if !COIN_EXEC_aoMissions then {_delay = 100};
	if ADF_missionTest then {_delay = 5};
	waitUntil {sleep 1; time > _delay};
	
	
	///// LOCATION
	
	// location Data Set. "COIN_ao_all" are all AO markers.	
	private _worldSize = worldSize;
	COIN_largeLocations = [];
	private _allLocations = [[_worldSize/2, _worldSize/2], _worldSize*1.3] call ADF_fnc_allLocations;
	{
		if (((_x # 4) # 0) > 25) then {
			(_x # 3) set [2,0];
			COIN_largeLocations pushBack (_x # 3);		
		};
	} forEach _allLocations;
	// Use AO markers in case no locations are found
	if (COIN_largeLocations isEqualTo []) then {
		{
			private _position = getMarkerPos _x;
			_position set [2, 0];
			COIN_largeLocations pushBack _position;
		} forEach COIN_ao_all;
	};	
	diag_log format ["« C O I N »   init_sides.sqf - COIN_largeLocations: %1", COIN_largeLocations];
	

	COIN_fnc_randomMapLocation = {
		params [
			"_worldSize",
			"_missionSceneSize",
			"_flatSurface"
		];
		private _position = [0,0,0];
		private _slope = [COIN_sides_maxGradlow, COIN_sides_maxGradHi] select _flatSurface; // map specific maximum slope grad.
		waitUntil {
			_position = [[_worldSize / 2, _worldSize / 2, 0], 0, -1, _missionSceneSize, 0, _slope, 0, [COIN_ao_activeMarker]] call BIS_fnc_findSafePos;
			(_position inArea [[_worldSize / 2, _worldSize / 2, 0], _worldSize / 2, _worldSize / 2, 0, true])
		};
		_position set [2, 0];
		_position
	};
	
	////// REWARD
	
	COIN_fnc_createReward = {
		// Init
		params [
			"_missionNr",
			"_completedNr",
			"_worldSize",
			"_reward"
		];	

		// Determine the reward vehicle
		if ADF_mod_RHS then {
			call {
				if (_completedNr > 12) exitWith {_reward = selectRandom ["RHS_AH64DGrey", "RHS_AH64D", "rhsusf_m1a2sep1tuskiid_usarmy", "rhsusf_m1a1aim_tuski_d", "rhsusf_M142_usarmy_D"]};
				if (_completedNr > 10) exitWith {_reward = selectRandom ["RHS_MELB_AH6M", "rhsusf_m1a1fep_d", "rhsusf_m109d_usarmy", "rhsusf_CH53E_USMC_GAU21_D", "RHS_CH_47F_light", "rhsusf_stryker_m1134_d"]};
				if (_completedNr > 7) exitWith {_reward = selectRandom ["rhsusf_m1245_m2crows_socom_deploy", "rhsusf_stryker_m1132_m2_d", "rhsusf_m1245_mk19crows_socom_deploy", "RHS_MELB_MH6M", "RHS_UH1Y_d", "rhsusf_M1078A1R_SOV_M2_D_fmtv_socom", "RHS_CH_47F_10", "rhsusf_CH53e_USMC_D_cargo"]};
				if (_completedNr > 5) exitWith {_reward = selectRandom ["RHS_MELB_H6M", "RHS_UH1Y_FFAR_d", "RHS_UH60M_MEV_d", "rhsusf_m1240a1_mk19crows_usmc_d", "rhsusf_m1240a1_m2crows_usmc_d", "rhsusf_stryker_m1127_m2_d", "rhsusf_stryker_m1126_mk19_d", "rhsusf_M1239_MK19_socom_d", "rhsusf_M1239_MK19_Deploy_socom_d"]};
				if (_completedNr > 2) exitWith {_reward = selectRandom ["rhsusf_mrzr4_d", "RHS_UH1Y_UNARMED_d", "rhsusf_M1238A1_M2_socom_d", "rhsusf_M1238A1_M2_socom_d", "rhsusf_CGRCAT1A2_Mk19_usmc_d", "rhsusf_m1240a1_mk19_usmc_d", "rhsusf_M977A4_REPAIR_BKIT_usarmy_d", "rhsusf_M1239_M2_Deploy_socom_d", "rhsusf_stryker_m1126_m2_d", "rhsusf_m113d_usarmy_medical", "rhsusf_m113d_usarmy_MK19", "rhsusf_M1239_M2_socom_d"]};
				_reward = selectRandom ["rhsusf_m1043_d_s_mk19", "rhsusf_m1045_d_s", "rhsusf_m1240a1_m240_usmc_d", "rhsusf_M977A4_REPAIR_BKIT_usarmy_d", "rhsusf_M1085A1P2_B_D_Medical_fmtv_usarmy", "rhsusf_m113d_usarmy", "rhsusf_m113d_usarmy_M240", "rhsusf_m113d_usarmy_medical", "rhsusf_M1239_M2_socom_d"];
			};
		} else {
			call {
				if (_completedNr > 12) exitWith {_reward = selectRandom ["CUP_B_Challenger2_Desert_BAF", "CFP_B_USARMY_2003_AH_64D_DES_01", "CFP_B_USARMY_2003_M2A3_ERA_Bradley_IFV_DES_01", "CFP_B_USMC_MH_60S_Knighthawk_ESSS_x4_DES_01", "CFP_B_USSEALS_MH_60L_DAP_4Pylons_DES_01", "CFP_B_USMC_MV_22B_Osprey_Ramp_Gun_DES_01", "CUP_B_M1A2_TUSK_MG_DES_USMC", "CUP_B_M1A2_TUSK_MG_USMC", "CFP_B_USSEALS_AH_6M_DES_01"];};
				if (_completedNr > 10) exitWith {_reward = selectRandom ["CUP_B_FV510_GB_D_SLAT", "CUP_B_MCV80_GB_D_SLAT", "CFP_B_USRANGERS_M1128_MGS_Slat_WDL_01", "CFP_B_USARMY_2003_CH_47F_DES_01", "CFP_B_USARMY_2003_M2A2_Bradley_IFV_DES_01", "CFP_B_USARMY_2003_M6_Linebacker_DES_01", "CFP_B_USMC_M270_MLRS_HE_DES_01", "CFP_B_USMC_MH_60S_Knighthawk_ESSS_x2_DES_01", "CFP_B_USMC_UH_1Y_Venom_Gunship_DES_01", "CUP_B_M1A1_DES_USMC", "CUP_B_M1A1_Woodland_USMC", "CFP_B_USSEALS_MH_47E_DES_01"];};
				if (_completedNr > 7) exitWith {_reward = selectRandom ["CFP_B_USRANGERS_M1135_ATGMV_Slat_WDL_01", "CFP_B_USRANGERS_M1135_ATGMV_Slat_WDL_01", "CFP_B_USARMY_2003_M7_Bradley_DES_01", "CFP_B_USARMY_2003_M1126_ICV_MK19_DES_01", "CUP_B_LAV25_desert_USMC", "CFP_B_USSEALS_MH_6J_Little_Bird_DES_01", "CUP_B_LAV25M240_desert_USMC", "CFP_B_USMC_MH_60S_Seahawk_DES_01", "CFP_B_USMC_MH_60S_Seahawk_M3M_DES_01", "CFP_B_USMC_UH_1Y_Venom_MEV_DES_01", "CFP_B_USMC_M60A3_Patton_DES_01", "CFP_B_USSEALS_HMMWV_SOV_Mk19_DES_01"];};
				if (_completedNr > 5) exitWith {_reward = selectRandom ["CUP_B_FV432_GB_GPMG", "CFP_B_USRANGERS_M1126_ICV_M2_CROWS_Slat_WDL_01", "CFP_B_USARMY_2003_M1126_ICV_M2_DES_01", "CFP_B_USSEALS_UH_60M_FFV_DES_01", "CFP_B_USSEALS_MH_6M_MELB_DES_01", "CFP_B_USMC_HMMWV_Avenger_DES_01", "CFP_B_USMC_AAVP7_A1_DES_01", "CFP_B_USMC_MH_60S_Seahawk_FFV_DES_01", "CFP_B_USMC_UH_1Y_Venom_Transport_DES_01", "CFP_B_USSEALS_HMMWV_SOV_M2_DES_01"];};
				if (_completedNr > 2) exitWith {_reward = selectRandom ["CFP_B_USRANGERS_M1133_MEV_Slat_WDL_01", "CFP_B_USARMY_2003_UH_60M_MEV_DES_01", "CFP_B_USARMY_2003_M113A3_DES_01", "CFP_B_USMC_HMMWV_MK19_DES_01", "CFP_B_USMC_HMMWV_TOW_DES_01", "CUP_B_M1151_Mk19_DSRT_USMC", "CUP_B_M1165_GMV_DSRT_USMC", "CUP_B_M1167_DSRT_USMC", "CFP_B_USMC_RG_31_Mk_19_OD_DES_01"];};
				_reward = selectRandom ["CFP_B_USARMY_1991_M113A3_Des_01", "CFP_B_USMC_HMMWV_Ambulance_DES_01", "CFP_B_USCIA_LSV_02","CFP_B_USMC_HMMWV_M2_DES_01", "CFP_B_USCIA_SUV_01", "CFP_B_USMC_M1030_DES_01", "CFP_B_USMC_HMMWV_M240_DES_01", "CUP_B_M1151_M2_DSRT_USMC", "CUP_B_M1151_Deploy_DSRT_USMC", "CFP_B_USMC_MTVR_Ammo_DES_01", "CFP_B_USMC_MTVR_Repair_DES_01"];
			};		
		};
		
		// Find a road location to spawn the reward vehicle
		private _roadSidePos = [[_worldSize/2, _worldSize/2, 0], worldSize/2, 150, true, "AUTO", _reward] call ADF_fnc_roadSidePos;
		_position = _roadSidePos # 0;
		_direction = _roadSidePos # 1;
		
		// Use the FOB drop-off LZ if no suitable road position found else clean up the found position.
		if (_position isEqualTo [0,0,0]) then {
			_position = getPosATL fob_lz;
			_direction = random 360;
		}; 
		
		// Create reward vehicle and map marker
		_rewardMarker = [format ["mReward_%1", _completedNr], _position, "ICON", "b_unknown", 1, 1, 0, "colorBLUFOR", "REWARD"] call ADF_fnc_createMarker;
		_vehicle = createVehicle [_reward, [0, 0, 0], [], 0, "CAN_COLLIDE"];
		_vehicle setDir _direction;
		_vehicle setPosATL _position;
		_rewardDesc = getText(configFile >> "CfgVehicles" >> _reward >> "displayName");	
		if (_rewardDesc isEqualTo "") then {_rewardDesc = _reward};
		
		// Announce
		[2, _missionNr, _completedNr, _rewardDesc] remoteExec ["COIN_fnc_msg_sideMission", 0];
		
		// 15-ish minutes to collect the reward vehicle.
		private _timeOut = time + (16 * 60);
		if ADF_missionTest then {_timeOut = time + 60;};
		waitUntil {
			sleep 1;
			time > _timeOut || (owner _vehicle) > 2
		};
		if (time > _timeOut) then {
			[_vehicle] call ADF_fnc_delete;
			[_rewardMarker] call ADF_fnc_delete;
			[4, _missionNr, _completedNr, _rewardDesc] remoteExec ["COIN_fnc_msg_sideMission", 0];
		};		
	};
	
	///// SPAWN MISSION
	
	COIN_fnc_createMission = {
		// Check if we have and side missions left in the array. If not then reset the array.
		if (COIN_sideMissions isEqualTo []) then {COIN_sideMissions = COIN_allSideMissions};		
		// Select a random side mission and remove that side mission from the side missions array
		COIN_activeMission = selectRandom COIN_sideMissions;
		publicVariable "COIN_activeMission";
		
		//COIN_activeMission = COIN_sideMissions select 18; // debug;		
		
		COIN_sideMissions = COIN_sideMissions - [COIN_activeMission];
		
		// Define mission specs
		private _worldSize = worldSize;
		private _missionPosition = [];
		private _missionNr = COIN_activeMission # 0;
		private _missionType = COIN_activeMission # 1;
		private _missionAOType = COIN_activeMission # 2;
		private _missionMaxTime = (COIN_activeMission # 3) * 60;
		private _missionSceneSize = COIN_activeMission # 4;
		private _missionAOSize = COIN_activeMission # 5;
		private _missionInfPatrols = COIN_activeMission # 6;
		private _missionInfGarrison = COIN_activeMission # 7;
		private _missionTechs = COIN_activeMission # 8;
		private _missionInfType = COIN_activeMission # 9;
		private _missionFlatSurface = COIN_activeMission # 10;
		private _sidemissionExit = false;
		COIN_sideMission_target1_KIA = false;
		COIN_sideMission_target2_KIA = false;
		COIN_sideMission_target3_KIA = false;
		COIN_sideMission_target4_KIA = false;
		COIN_sideMission_target5_KIA = false;
		
		#include "init_vehicles.sqf"
		
		// create the mission
		call {
			if (_missionNr == 0) exitWith { // Search and Retrieve Intel
				_missionPosition = [_worldSize, _missionSceneSize, _missionFlatSurface] call COIN_fnc_randomMapLocation;
				if (_missionPosition isEqualTo [0,0,0]) exitWith {["init_sides", format ["COIN_fnc_createMission could not find a suitable scene position for scene # %1 and returned [0,0,0]", _missionNr]] call ADF_fnc_terminateScript; false};
				private _missionScene = [
					["Land_MedicalTent_01_floor_light_F",[0.112061,0.187012,0],0,1,0,[0,0],"","",true,false], 
					["Land_MedicalTent_01_CSAT_brownhex_generic_outer_F",[0,0,0.1],0,1,0,[0,0],"hook","hook allowDamage false; hook enableSimulationGlobal false;",true,false],
					["Land_PortableDesk_01_sand_F",[-3.15942,-1.46094,-4.19617e-005],90,1,0,[0,0],"","",true,false], 
					["Land_PortableDesk_01_panel_sand_F",[-3.56519,0.865723,0],15,1,0,[0,0],"","",true,false],
					["Land_CampingChair_V2_F",[2.47949,0.643066,-1.90735e-006],323,1,0,[0,0],"","",true,false],
					["Land_CampingChair_V2_F",[2.57495,-1.96582,4.76837e-007],273,1,0,[0,6.05],"","",true,false],
					["FoldTable",[3.24683,0.128418,0],90.4057,1,0,[0,0],"","",true,false],
					["FoldTable",[3.40894,-2.24512,0],97.8146,1,0,[0,0],"","",true,false], 
					["Land_File_research_F",[-3.03564,-0.738281,1.3],253,1,0,[0,0],"","",true,false],				 
					["Land_Map_Enoch_F",[3.23804,0.275879,1.4],6.49596e-005,1,0,[0,0],"","",true,false], 
					["Land_DeskChair_01_sand_F",[-2.4646,-2.27832,0],264,1,0,[0,0],"","",true,false], 
					["Land_Notepad_F",[-3.01001,-1.29785,1.3],288.859,1,0,[0,0],"","",true,false], 
					["Land_PortableCabinet_01_bookcase_sand_F",[-3.38965,0.0419922,0],270,1,0,[0,0.39],"","",true,false], 
					["Land_Document_01_F",[-3.2854,-0.424316,1.3],295,1,0,[0,0],"","",true,false], 
					["Land_PortableLight_02_single_folded_olive_F",[3.29614,0.927246,0],60,1,0,[0,0],"","",true,false],					
					["Land_MapBoard_Enoch_F",[-2.23584,2.54785,-0.00223541],316.421,1,0,[-0.33,0],"","",true,false], 
					["Land_File1_F",[-3.37891,-0.747559,1.3],359.997,1,0,[0,0],"","",true,false], 
					["Land_Camping_Light_F",[-3.37183,-0.981445,1.4],0.0125233,1,0,[0,0],"","",true,false], 
					["Land_MultiScreenComputer_01_sand_F",[-3.03003,-2.17383,1.3],270,1,0,[0,0],"COIN_sideMission_target","COIN_sideMission_target enableSimulationGlobal false;",true,false], 
					["Land_PortableLight_02_double_olive_F",[-3.62329,2.31689,0],325.979,1,0,[0,0],"","",true,false], 
					["Land_MultiScreenComputer_01_closed_sand_F",[-2.95752,-3.50391,1.3],228,1,0,[0,3],"","",true,false], 
					["Land_PortableCabinet_01_7drawers_sand_F",[-3.16748,-1.40771,-0.00197697],266,1,0,[0,0],"","",true,false],
					["Land_PortableCabinet_01_bookcase_sand_F",[-3.37378,-3.05176,3.8147e-006],271,1,0,[0,0],"","",true,false], 
					["Land_PortableCabinet_01_4drawers_black_F",[-3.22754,-4.08301,0.331593],203,1,0,[0,0],"","",true,false],
					["Land_PortableCabinet_01_closed_sand_F",[-1.49121,4.04541,-4.76837e-007],170,1,0,[0,2],"","",true,false], 
					["Land_PortableCabinet_01_closed_sand_F",[-2.88208,4.2627,0],208.397,1,0,[4.8,3.77],"","",true,false], 
					["Land_PortableCabinet_01_closed_sand_F",[-2.88208,4.2627,0],208.397,1,0,[4.8,3.77],"","",true,false], 
					["Land_PortableCabinet_01_closed_sand_F",[-3.2417,-4.13721,-4.76837e-006],180,1,0,[0,0],"","",true,false], 
					["Land_PortableCabinet_01_closed_sand_F",[3.31006,4.44775,0],7,1,0,[1.66,1.93],"","",true,false], 
					["Land_TentLamp_01_standing_red_F",[3.75195,-3.98047,0],0,1,0,[0,0],"","",true,false], 
					["SatelliteAntenna_01_Small_Olive_F",[-3.18311,-5.66504,-0.00139332],225,1,0,[0,0],"","",true,false], 
					["Land_TTowerSmall_1_F",[4.96533,-3.69434,0],0,1,0,[0,0],"","",true,false]
				];
				// Set the scene			
				[_missionPosition, random 360, _missionScene] call BIS_fnc_ObjectsMapper;
				private _trigger = [getPosATL COIN_sideMission_target, false, 1, true, false, 2, 2, 0, -1, "ANYPLAYER", "PRESENT", true, "THIS", "COIN_sideMission_complete = true", ""] call ADF_fnc_createTrigger;			
			};
			
			
			if (_missionNr == 1) exitWith {  // Hostage rescue
			
				// Get random city/village
				_missionPosition = selectRandom COIN_largeLocations;
				if (_missionPosition distance (getMarkerPos COIN_ao_activeMarker) < 2000) then {
					private _timeOut = time + 5;
					waitUntil {
						_missionPosition = selectRandom COIN_largeLocations;
						(_missionPosition distance (getMarkerPos COIN_ao_activeMarker)) > 1999 || time > _timeOut
					};
				};

				_missionPosition set [2, 0];
				_allBuildings = [_missionPosition, _missionAOSize, -1] call ADF_fnc_buildingPositions;
				_building = selectRandom _allBuildings;
				_buildingPosition = getPosATL _building;
				_targetPosition = (_building getVariable ["ADF_garrPos", []]) # 0;
				_targetPosition set [2, (_targetPosition # 2) + 0.25];

				private _missionScene = [];

				// create hostage
				private _targetGroup = createGroup civilian;
				COIN_sideMission_target = _targetGroup createUnit ["C_man_pilot_F", _targetPosition, [], 0, "CAN_COLLIDE"];
				COIN_sideMission_target allowDamage false;
				COIN_sideMission_target disableAI "MOVE";

				// reDress hostage
				[COIN_sideMission_target] call ADF_fnc_stripUnit;
				COIN_sideMission_target forceAddUniform "U_B_HeliPilotCoveralls";
				COIN_sideMission_target addHeadgear "H_PilotHelmetHeli_B";
				COIN_sideMission_target linkItem "ItemMap";
				COIN_sideMission_target addItem "FirstAidKit";				

				COIN_sideMission_target addEventHandler ["killed", {COIN_sideMission_failed = true;}];		

				publicVariable "COIN_sideMission_target";

				// Target Sensor/Monitor > bugger addAction
				[_missionMaxTime] spawn {
					params ["_missionMaxTime"];
					private _timeOut = time + _missionMaxTime;
					COIN_sideMission_target allowDamage true;

					waitUntil {
						private _playersClose = false;
						{if ((COIN_sideMission_target distance2D _x) < 1) exitWith {_playersClose = true}} forEach allPlayers select {((getPosATL _x) select 2) < 5};					
						sleep 1;
						_playersClose || time > _timeOut || COIN_sideMission_skipped
					};

					if (time > _timeOut || COIN_sideMission_skipped) exitWith {[COIN_sideMission_target] call ADF_fnc_delete;};
					[COIN_sideMission_target] joinSilent group (_this select 1);   
					COIN_sideMission_target enableAI "MOVE";

					waitUntil {
						sleep 2;
						(COIN_sideMission_target distance2D teleportFlagPole) < 20 || time > _timeOut || COIN_sideMission_skipped
					};
					if (time > _timeOut || COIN_sideMission_skipped) exitWith {[COIN_sideMission_target] call ADF_fnc_delete;};
					COIN_sideMission_complete = true;
					sleep 5;
					[COIN_sideMission_target] call ADF_fnc_delete;
				};

				[_targetGroup] call ADF_fnc_addToCurator;		
			};


			if (_missionNr == 2) exitWith {  // Obtain Intel From Laptop
				// Get random city/village
				_missionPosition = selectRandom COIN_largeLocations;
				if (_missionPosition distance (getMarkerPos COIN_ao_activeMarker) < 2000) then {
					private _timeOut = time + 5;
					waitUntil {
						_missionPosition = selectRandom COIN_largeLocations;
						(_missionPosition distance (getMarkerPos COIN_ao_activeMarker)) > 1999 || time > _timeOut
					};
				};

				_missionPosition set [2, 0];
				_allBuildings = [_missionPosition, _missionAOSize, -1] call ADF_fnc_buildingPositions;
				_building = selectRandom _allBuildings;
				_buildingPosition = getPosATL _building;
				_targetPosition = (_building getVariable ["ADF_garrPos", []]) select 0;
				_targetPosition set [2, (_targetPosition # 2) + 0.03];

				private _missionScene = [
					["Desk",[0,0,0],0,1,0,[0,0],"hook","hook allowDamage false; hook enableSimulationGlobal false;",true,false], 
					["Land_Laptop_Intel_01_F",[0,0,0.92],0,1,0,[0,0],"COIN_sideMission_target","COIN_sideMission_target allowDamage false; COIN_sideMission_target enableSimulation false;",true,false]
				];

				// Set the scene			
				[_targetPosition, direction _building, _missionScene] call BIS_fnc_ObjectsMapper;

				// Target Sensor/Monitor
				[_missionMaxTime] spawn {				
					params ["_missionMaxTime"];
					private _timeOut = time + _missionMaxTime;

					waitUntil {
						private _playersClose = false;
						{if ((COIN_sideMission_target distance2D _x) < 1) exitWith {_playersClose = true}} forEach allPlayers select {((getPosATL _x) select 2) < 5};					
						sleep 1;
						_playersClose || time > _timeOut || COIN_sideMission_skipped
					};

					if (time > _timeOut || COIN_sideMission_skipped) exitWith {};
					private _duration = selectRandom [90,100,110,120,130,140,150];
					private _team = [];
					{
						if ((_x distance COIN_sideMission_target) < 200) then {_team pushBack _x};
					} forEach allPlayers;
					[_duration] remoteExec ["COIN_fnc_hackIntel", _team];
					sleep (_duration + 30);
					COIN_sideMission_complete = true;
				};			

				COIN_sideMission_target enableSimulation true;
			};
			

			if (_missionNr == 3) exitWith { // Destroy Computer Servers
				_missionPosition = [_worldSize, _missionSceneSize, _missionFlatSurface] call COIN_fnc_randomMapLocation;
				if (_missionPosition isEqualTo [0,0,0]) exitWith {["init_sides", format ["COIN_fnc_createMission could not find a suitable scene position for scene # %1 and returned [0,0,0]", _missionNr]] call ADF_fnc_terminateScript; false};
				private _missionScene = [
					["Land_Bunker_01_HQ_F",[-0.0715332,0.0737305,0],0,1,0,[0,0],"hook","hook allowDamage false; hook enableSimulationGlobal false; hook setVectorUp [0, 0, 1];",true,false], 
					["Land_TentLamp_01_standing_red_F",[0.25415,-0.236816,0.13],90,1,0,[0,0],"COIN_sideMission_target","",true,false], 
					["Land_TentLamp_01_standing_red_F",[0.262939,-0.88916,0.13],90,1,0,[0,0],"","",true,false], 
					["Land_PortableDesk_01_black_F",[-0.50293,0.412109,0.13],90,1,0,[0.07163,-0.0078691],"","",true,false], 
					["Land_PortableServer_01_black_F",[0.834229,-1.18701,0.13],270,1,0,[0,0],"","",true,false], 
					["Land_PortableServer_01_black_F",[0.810059,-0.394043,0.13],270,1,0,[0,0],"","",true,false], 
					["Land_PortableServer_01_black_F",[0.812988,0.38623,0.13],270,1,0,[0,0],"","",true,false], 
					["Land_PortableServer_01_black_F",[0.833496,-1.18799,0.48],270,1,0,[0,0],"","",true,false], 
					["Land_PortableServer_01_black_F",[0.805176,-0.399902,0.48],270,1,0,[0,0],"","",true,false],
					["Land_PortableServer_01_black_F",[0.811035,0.38623,0.48],270,1,0,[0,0],"","",true,false], 
					["Land_PortableServer_01_black_F",[0.83374,-1.19043,0.83],270,1,0,[0,0],"","",true,false], 
					["Land_PortableServer_01_black_F",[0.806641,-0.399902,0.83],270,1,0,[0,0],"","",true,false], 
					["Land_PortableServer_01_black_F",[0.811035,0.383789,0.83],270,1,0,[0,0],"","",true,false], 
					["Land_PortableServer_01_black_F",[0.835449,-1.19238,1.153],270,1,0,[0,0],"","",true,false], 
					["Land_PortableServer_01_black_F",[0.812256,0.384766,1.153],270,1,0,[0,0],"","",true,false], 
					["Land_PortableServer_01_black_F",[0.802979,-0.398926,1.153],270,1,0,[0,0],"","",true,false], 
					["Land_BatteryPack_01_closed_black_F",[-0.432129,-1.0376,0],0,1,0,[0,1.45],"","",true,false], 
					["Land_IPPhone_01_olive_F",[-0.463379,-0.217773,1.018],74,1,0,[0,0],"","",true,false], 
					["Land_Computer_01_black_F",[-0.410156,-0.669922,1.018],270,1,0,[0,0],"","",true,false], 
					["Land_laptop_03_closed_olive_F",[-0.55835,0.192871,1.027],81,1,0,[0,0],"","",true,false], 
					["Land_SatellitePhone_F",[-0.517334,1.29883,1.018],62,1,0,[0,0],"","",true,false], 
					["Land_Router_01_olive_F",[0.993164,0.410156,1.51],90,1,0,[0,0],"","",true,false], 
					["Land_PortableGenerator_01_F",[-1.59131,2.34277,0.13],180,1,0,[0,0],"","",true,false], 
					["Land_TentLamp_01_standing_red_F",[2.77539,2.68506,0.13],0,1,0,[0,0],"","",true,false], 
					["Land_TentLamp_01_suspended_red_F",[-2.38232,-2.73584,1.967],87,1,0,[0,0],"","",true,false], 
					["O_CargoNet_01_ammo_F",[-4.14014,-1.87402,0.13],0,1,0,[0,0],"","this call ADF_fnc_stripVehicle",true,false], 
					["Land_TentLamp_01_suspended_red_F",[-3.95288,2.32568,1.963],0,1,0,[0,0],"","",true,false], 
					["Land_TentLamp_01_suspended_red_F",[4.18701,-2.11475,1.963],180,1,0,[0,0],"","",true,false], 
					["SatelliteAntenna_01_Black_F",[2.98584,0.304199,3.341],124,1,0,[0,0],"","",true,false], 
					["Land_TTowerSmall_1_F",[-6.52808,4.07471,0],0,1,0,[0,0],"","this setVectorUp [0, 0, 1]",true,false]
				];
				
				// Set the scene			
				[_missionPosition, random 360, _missionScene] call BIS_fnc_ObjectsMapper;
				COIN_sideMission_target addEventHandler ["killed", {COIN_sideMission_complete = true;}];	
			};
			
			
			if (_missionNr == 4) exitWith { // assassinate targets
				
				// Get random city/village
				_missionPosition = selectRandom COIN_largeLocations;
				if (_missionPosition distance (getMarkerPos COIN_ao_activeMarker) < 2000) then {
					private _timeOut = time + 5;
					waitUntil {
						_missionPosition = selectRandom COIN_largeLocations;
						(_missionPosition distance (getMarkerPos COIN_ao_activeMarker)) > 1999 || time > _timeOut
					};
				};

				_missionPosition set [2, 0];
				_allBuildings = [_missionPosition, _missionAOSize, -1] call ADF_fnc_buildingPositions;
				_building = selectRandom _allBuildings;
				_buildingPosition = getPosATL _building;
				_targetPosition = (_building getVariable ["ADF_garrPos", []]) # 0;

				private _missionScene = [];

				// create officers/Insurgent targets
				private _group = createGroup east;					
				COIN_sideMission_target = _group createUnit ["o_officer_f", _missionPosition, [], 0, "NONE"];
				COIN_sideMission_target addEventHandler ["killed", {COIN_sideMission_target1_KIA = true;}];
				private _group = createGroup east;					
				private _target_2 = _group createUnit ["o_officer_f", _missionPosition, [], 0, "NONE"];
				_target_2 addEventHandler ["killed", {COIN_sideMission_target2_KIA = true;}];
				private _group = createGroup east;					
				private _target_3 = _group createUnit ["o_soldier_f", _missionPosition, [], 0, "NONE"];
				_target_3 addEventHandler ["killed", {COIN_sideMission_target3_KIA = true;}];
				private _group = createGroup east;					
				private _target_4 = _group createUnit ["o_soldier_f", _missionPosition, [], 0, "NONE"];
				_target_4 addEventHandler ["killed", {COIN_sideMission_target4_KIA = true;}];
					
				{_x call ADF_fnc_redressArmy_inf; removeHeadgear _x; removeBackpack _x; removeVest _x; _x addHeadgear "H_Beret_CSAT_01_F";} forEach [COIN_sideMission_target, _target_2];
				{_x call ADF_fnc_redressInsurgents; removeBackpack _x; removeVest _x;} forEach [_target_3, _target_4];
				
				// Move units to their meeting location
				{
					[_x, _targetPosition] spawn {
						params ["_target", "_targetPosition"];
						_target move _targetPosition; 
						private _timeOut = time + 300;
						waitUntil {sleep 1; unitReady _target || time > _timeOut};						
						_target disableAI "MOVE";																	
					}
				} forEach [COIN_sideMission_target, _target_2, _target_3, _target_4];

				// Target Sensor/Monitor
				[COIN_sideMission_target, _target_2, _target_3, _target_4, _missionMaxTime] spawn {
					params ["_target_1", "_target_2", "_target_3", "_target_4", "_missionMaxTime"];
					private _timeOut = time + _missionMaxTime;

					waitUntil {
						private _playersClose = false;
						{if ((COIN_sideMission_target distance2D _x) < 500) exitWith {_playersClose = true}} forEach allPlayers select {((getPosATL _x) select 2) < 5};					
						sleep 30;
						_playersClose || time > _timeOut || COIN_sideMission_skipped
					};

					if (time > _timeOut || COIN_sideMission_skipped) exitWith {};

					waitUntil {
						sleep 1;
						(COIN_sideMission_target1_KIA && COIN_sideMission_target2_KIA && COIN_sideMission_target3_KIA && COIN_sideMission_target4_KIA) || time > _timeOut || COIN_sideMission_skipped
					};

					if (time > _timeOut || COIN_sideMission_skipped) exitWith {{[_x] call ADF_fnc_delete} forEach [_target_1, _target_2, _target_3, _target_4];};
					COIN_sideMission_complete = true;
				};
			};
			
			
			if (_missionNr == 5) exitWith { // Destroy Radar Communications Station
				// Get random city/village
				_missionPosition = selectRandom COIN_largeLocations;
				if (_missionPosition distance (getMarkerPos COIN_ao_activeMarker) < 2000) then {
					private _timeOut = time + 5;
					waitUntil {
						_missionPosition = selectRandom COIN_largeLocations;
						(_missionPosition distance (getMarkerPos COIN_ao_activeMarker)) > 1999 || time > _timeOut
					};
				};
				
				// Find a position for the radio tower
				_targetPosition = [_missionPosition, 0, _missionAOSize, _missionSceneSize, 0, 0.05, 0, [COIN_ao_activeMarker]] call BIS_fnc_findSafePos;
			
				private _missionScene = [
					["Land_Vysilac_FM",[1.05322,-0.422363,0],0,1,0,[0,0],"COIN_sideMission_target","COIN_sideMission_target allowDamage false; COIN_sideMission_target enableSimulation false;",true,false], 
					[selectRandom _army_Static_HMG,[1.6416,-0.977051,14.6],0,1,0,[0,0],"","",true,false]
				];
				
				// Set the scene			
				[_targetPosition, random 360, _missionScene] call BIS_fnc_ObjectsMapper;
				COIN_sideMission_target addEventHandler ["killed", {COIN_sideMission_complete = true;}];
				COIN_sideMission_target allowDamage true;
				COIN_sideMission_target enableSimulation true;				
			};
			
			
			if (_missionNr == 6) exitWith { // Destroy Armory
				_missionPosition = [_worldSize, _missionSceneSize, _missionFlatSurface] call COIN_fnc_randomMapLocation;
				if (_missionPosition isEqualTo [0,0,0]) exitWith {["init_sides", format ["COIN_fnc_createMission could not find a suitable scene position for scene # %1 and returned [0,0,0]", _missionNr]] call ADF_fnc_terminateScript; false};
				private _missionScene = [
					["Land_Shed_Big_F",[0,-10.0518,0],0,1,0,[0,0],"hook","hook setVectorUp [0, 0, 1];",true,false], 
					["Land_Shed_Small_F",[7.86255,-10.1133,0],0,1,0,[0,0],"","this setVectorUp [0, 0, 1];",true,false], 
					["Land_CncWall4_F",[-8.02759,-0.966309,0],270,1,0,[0,0],"","this setVectorUp [0, 0, 1];",true,false],
					["Land_CncWall4_F",[-8.02148,4.24463,0],270,1,0,[0,0],"","this setVectorUp [0, 0, 1];",true,false],
					["Land_CncWall4_F",[-8.02686,-6.17114,0],270,1,0,[0,0],"","this setVectorUp [0, 0, 1];",true,false],
					["Land_CncWall4_F",[-0.098877,12.0081,0],0,1,0,[0,0],"","this setVectorUp [0, 0, 1];",true,false], 
					["Land_CncWall4_F",[-7.97705,9.46167,0],270,1,0,[0,0],"","this setVectorUp [0, 0, 1];",true,false],
					["Land_CncWall4_F",[5.11646,12.0581,0],0,1,0,[0,0],"","this setVectorUp [0, 0, 1];",true,false], 
					["Land_CncWall4_F",[-5.31519,12.021,0],0,1,0,[0,0],"","this setVectorUp [0, 0, 1];",true,false], 
					["Land_CncWall4_F",[-8.01025,-11.373,0],270,1,0,[0,0],"","this setVectorUp [0, 0, 1];",true,false],
					["Land_CncWall4_F",[5.24121,-13.928,0],180,1,0,[0,0],"","this setVectorUp [0, 0, 1];",true,false],
					["Land_CncWall4_F",[-8.0105,-15.6689,0],270,1,0,[0,0],"","this setVectorUp [0, 0, 1];",true,false],
					["Land_CncWall4_F",[-0.288574,-18.3296,0],180,1,0,[0,0],"","this setVectorUp [0, 0, 1];",true,false],
					["Land_CncWall4_F",[-5.49316,-18.3428,0],180,1,0,[0,0],"","this setVectorUp [0, 0, 1];",true,false],
					["Land_CncWall1_F",[2.31299,-14.3271,0],135,1,0,[0,0],"","this setVectorUp [0, 0, 1];",true,false],
					["Land_CncWall1_F",[8.02881,-12.6111,0],90,1,0,[0,0],"","this setVectorUp [0, 0, 1];",true,false], 
					["Land_CncWall1_F",[8.0293,-13.302,0],90,1,0,[0,0],"","this setVectorUp [0, 0, 1];",true,false],
					["Land_CncWall1_F",[3.77271,-16.946,0],135,1,0,[0,0],"","this setVectorUp [0, 0, 1];",true,false],
					["Land_CncWall1_F",[2.90967,-17.873,0],135,1,0,[0,0],"","this setVectorUp [0, 0, 1];",true,false], 
					["Land_ConcreteWall_01_m_4m_F",[-0.0463867,3.0105,-4.76837e-006],90,1,0,[0,0],"","this setVectorUp [0, 0, 1];",true,false], 
					["Land_ConcreteWall_01_m_4m_F",[-0.0471191,-3.08179,-4.76837e-006],90,1,0,[0,0],"","this setVectorUp [0, 0, 1];",true,false],
					["Land_ConcreteWall_01_m_4m_F",[2.76831,-7.13013,-4.76837e-006],90,1,0,[0,0],"","this setVectorUp [0, 0, 1];",true,false],
					["Land_ConcreteWall_01_m_4m_F",[1.80957,9.58252,-4.76837e-006],0,1,0,[0,0],"","this setVectorUp [0, 0, 1];",true,false],
					["Land_ConcreteWall_01_m_4m_F",[5.75171,9.57886,-4.76837e-006],0,1,0,[0,0],"","this setVectorUp [0, 0, 1];",true,false],
					["Land_ConcreteWall_01_m_4m_F",[2.78882,-11.8992,-4.76837e-006],90,1,0,[0,0],"","this setVectorUp [0, 0, 1];",true,false],
					["Land_ConcreteWall_01_l_8m_F",[3.77759,0.838623,0.649996],0,1,0,[0,0],"","this setVectorUp [0, 0, 1];",true,false],
					["Land_ConcreteWall_01_l_8m_F",[3.77954,-5.25098,0.649996],0,1,0,[0,0],"","this setVectorUp [0, 0, 1];",true,false],
					["Land_ConcreteWall_01_l_8m_F",[3.7915,6.82227,0.649996],0,1,0,[0,0],"","this setVectorUp [0, 0, 1];",true,false],
					["CUP_hromada_beden_dekorativniX",[6.64136,2.53345,0],175.407,1,0,[0,0],"","",true,false], 
					["CUP_hromada_beden_dekorativniX",[4.83716,5.38867,0],1.0647,1,0,[0,0],"","",true,false], 				
					["CUP_hromada_beden_dekorativniX",[2.65771,2.47949,0],87.4426,1,0,[0,0],"","",true,false], 
					["CUP_hromada_beden_dekorativniX",[7.08838,3.92163,0],267.145,1,0,[0,0],"","",true,false], 
					["Box_EAF_AmmoVeh_F",[3.65479,-1.42847,0.0305409],0,1,0,[0,0],"","",true,false], 
					["Box_EAF_AmmoVeh_F",[6.47705,-4.0625,0.0305405],0,1,0,[0,0],"","",true,false], 				
					["Box_EAF_AmmoVeh_F",[1.44092,-3.92261,0.0305414],4,1,0,[0,0],"","",true,false], 
					["Box_East_AmmoVeh_F",[3.72217,-3.98462,0.03054],0,1,0,[0,0],"","",true,false], 
					["Box_East_AmmoVeh_F",[6.34155,-1.49414,0.0305414],360,1,0,[0,0],"","",true,false],
					["IG_supplyCrate_F",[3.79224,-6.29492,1.43051e-006],0,1,0,[0,0],"","this call ADF_fnc_stripVehicle",true,false], 
					["IG_supplyCrate_F",[6.46387,-7.72095,-1.90735e-006],180,1,0,[0,0],"","this call ADF_fnc_stripVehicle",true,false], 
					["IG_supplyCrate_F",[6.51099,-6.19531,0],0,1,0,[0,0],"","this call ADF_fnc_stripVehicle",true,false], 
					["IG_supplyCrate_F",[3.74512,-7.82056,1.43051e-006],180,1,0,[0,0],"","this call ADF_fnc_stripVehicle",true,false], 
					["IG_supplyCrate_F",[6.4231,-9.36938,9.53674e-007],0,1,0,[0,0],"","this call ADF_fnc_stripVehicle",true,false], 
					["IG_supplyCrate_F",[3.77905,-11.1438,3.95775e-005],0,1,0.0218763,[0,0],"","this call ADF_fnc_stripVehicle",true,false], 					
					["Land_CampingTable_F",[1.04761,-5.88989,-0.00259209],360,1,0,[0,0],"","",true,false], 	
					["Land_TentLamp_01_suspended_red_F",[4.90063,7.04297,2.5],90,1,0,[0,0],"","",true,false],
					["Land_TentLamp_01_suspended_red_F",[4.99487,6.57031,2.5],90,1,0,[0,0],"","",true,false],
					["Land_TentLamp_01_suspended_red_F",[5.22778,-5.43359,2.5],90,1,0,[0,0],"","",true,false],
					["Land_TentLamp_01_suspended_red_F",[4.95581,0.603516,2.5],90,1,0,[0,0],"","",true,false],
					["IG_supplyCrate_F",[6.40649,-11.2251,7.15256e-006],0.000665764,1,0,[0,0],"COIN_sideMission_target","this call ADF_fnc_stripVehicle",true,false], 
					["IG_supplyCrate_F",[3.79248,-12.8022,1.43051e-006],179.999,1,0,[0,0],"","this call ADF_fnc_stripVehicle",true,false], 
					["IG_supplyCrate_F",[6.42651,-12.8318,0],180,1,0,[0,0],"","this call ADF_fnc_stripVehicle",true,false], 
					["Land_Cargo_Patrol_V3_F",[-4.34253,-15.875,-0.4],0,1,0,[0,0],"","this setVectorUp [0, 0, 1];",true,false], 
					[selectRandom _army_truck,[12.3674,10.2661,0],93,1,0,[0.222211,0.0167569],"COIN_side6_truck1","this call ADF_fnc_stripVehicle",true,false], 
					[selectRandom _army_truck,[12.585,-2.01465,0],272,1,0,[0.22223,0.0167516],"COIN_side6_truck2","this call ADF_fnc_stripVehicle",true,false], 
					[selectRandom _army_Static_HMG,[7.09985,-17.8137,0],180,1,0,[0,0],"","",true,false]
				];
				
				// Set the scene			
				[_missionPosition, random 360, _missionScene] call BIS_fnc_ObjectsMapper;
				{[_x, ["Camo7",1], ["bench_hide",1,"spare_hide",0,"people_tag_hide",0,"rear_numplate_hide",1,"light_hide",1]] call BIS_fnc_initVehicle} forEach [COIN_side6_truck1, COIN_side6_truck2];
				COIN_sideMission_target addEventHandler ["killed", {COIN_sideMission_complete = true;}];				
			};
			
			
			if (_missionNr == 7) exitWith { //Search and Destroy Weapons Caches
				
				// Get random city/village
				_missionPosition = selectRandom COIN_largeLocations;
				if (_missionPosition distance (getMarkerPos COIN_ao_activeMarker) < 2000) then {
					private _timeOut = time + 5;
					waitUntil {
						_missionPosition = selectRandom COIN_largeLocations;
						(_missionPosition distance (getMarkerPos COIN_ao_activeMarker)) > 1999 || time > _timeOut
					};
				};

				_missionPosition set [2, 0];
				_allBuildings = [_missionPosition, _missionAOSize, -1] call ADF_fnc_buildingPositions;
				_building_1 = selectRandom _allBuildings;
				_targetPosition_1 = selectRandom (_building_1 getVariable ["ADF_garrPos", []]);
				_allBuildings = _allBuildings - [_building_1];
				_building_2 = selectRandom _allBuildings;
				_targetPosition_2 = selectRandom (_building_2 getVariable ["ADF_garrPos", []]);
				_allBuildings = _allBuildings - [_building_2];
				_building_3 = selectRandom _allBuildings;
				_targetPosition_3 = selectRandom (_building_3 getVariable ["ADF_garrPos", []]);

				private _missionScene = [];

				// create caches
				COIN_sideMission_target = createVehicle ["Box_FIA_Ammo_F", [0,0,0], [], 0, "CAN_COLLIDE"];
				COIN_sideMission_target allowDamage false;				
				COIN_sideMission_target setPosATL _targetPosition_1;
				COIN_sideMission_target addEventHandler ["killed", {COIN_sideMission_target1_KIA = true;}];
				_target_2 = createVehicle ["Box_FIA_Ammo_F", [0,0,0], [], 0, "CAN_COLLIDE"];
				_target_2 allowDamage false;				
				_target_2 setPosATL _targetPosition_2;
				_target_2 addEventHandler ["killed", {COIN_sideMission_target2_KIA = true;}];
				_target_3 = createVehicle ["Box_FIA_Ammo_F", [0,0,0], [], 0, "CAN_COLLIDE"];
				_target_3 allowDamage false;				
				_target_3 setPosATL _targetPosition_3;
				_target_3 addEventHandler ["killed", {COIN_sideMission_target3_KIA = true;}];					
								
				{
					_x setDir random 360;
					_x setVectorUp surfaceNormal position _x;		
					_x allowDamage true;
					[_x] call ADF_fnc_stripVehicle;
					if ADF_missionTest then {[format ["cacheMarker%1", random 9990], getPos _x, "ICON", "mil_dot", 1, 1, 0, "colorYellow"] call ADF_fnc_createMarkerLocal;};
				} forEach [COIN_sideMission_target, _target_2, _target_3];

				// Target Sensor/Monitor
				[COIN_sideMission_target, _target_2, _target_3,  _missionMaxTime] spawn {
					params ["_target_1", "_target_2", "_target_3", "_missionMaxTime"];
					private _timeOut = time + _missionMaxTime;

					waitUntil {
						private _playersClose = false;
						{if ((COIN_sideMission_target distance2D _x) < 500) exitWith {_playersClose = true}} forEach allPlayers select {((getPosATL _x) select 2) < 5};					
						sleep 30;
						_playersClose || time > _timeOut || COIN_sideMission_skipped
					};

					if (time > _timeOut || COIN_sideMission_skipped) exitWith {};

					waitUntil {
						sleep 1;
						(COIN_sideMission_target1_KIA && COIN_sideMission_target2_KIA && COIN_sideMission_target3_KIA) || time > _timeOut
					};

					if (time > _timeOut || COIN_sideMission_skipped) exitWith {{[_x] call ADF_fnc_delete} forEach [_target_1, _target_2, _target_3];};
					COIN_sideMission_complete = true;
				};
			};
			
			
			if (_missionNr == 8) exitWith { // Search and Destroy Helicopter
				_missionPosition = [_worldSize, _missionSceneSize, _missionFlatSurface] call COIN_fnc_randomMapLocation;
				if (_missionPosition isEqualTo [0,0,0]) exitWith {["init_sides", format ["COIN_fnc_createMission could not find a suitable scene position for scene # %1 and returned [0,0,0]", _missionNr]] call ADF_fnc_terminateScript; false};
				
				private _missionScene = [
					["CraterLong_02_small_F",[-0.0241699,1.31592,0],0,1,0,[0,0],"hook","",true,false], 
					["B_Heli_Transport_01_F",[-0.475098,-0.828857,-0.2],360,0,0,[10,-10],"COIN_sideMission_target","this call ADF_fnc_stripVehicle",true,false], 
					["test_EmptyObjectForSmoke",[0,0,0],0,1,0,[0,0],"COIN_side8_smoke","",true,false], 
					["Land_ShellCrater_02_debris_F",[-3.948,-0.0241699,0],0,1,0,[0,0],"","",true,false], 
					["Land_ShellCrater_02_debris_F",[-2.5896,-3.10693,0],0,1,0,[0,0],"","",true,false], 
					["Land_ShellCrater_02_debris_F",[2.37354,-3.4978,0],283.238,1,0,[0,0],"","",true,false], 
					["Land_ShellCrater_02_debris_F",[-2.54468,4.23071,0],48.5424,1,0,[0,0],"","",true,false], 
					["Land_ShellCrater_02_debris_F",[3.31055,2.71484,0],0,1,0,[0,0],"","",true,false]
				];

				// Set the scene			
				[_missionPosition, random 360, _missionScene] call BIS_fnc_ObjectsMapper;
				COIN_sideMission_target setDamage 0.6; 
				private _smokePosition = getPosWorld COIN_sideMission_target;
				_smokePosition set [2, 2.5];
				COIN_side8_smoke setPosATL _smokePosition;
				COIN_sideMission_target addEventHandler ["killed", {COIN_sideMission_complete = true;}];
				COIN_sideMission_target lock 2;
			};
			
			
			if (_missionNr == 9) exitWith {  // Search and Destroy Enemy Camp
				_missionPosition = [_worldSize, _missionSceneSize, _missionFlatSurface] call COIN_fnc_randomMapLocation;
				if (_missionPosition isEqualTo [0,0,0]) exitWith {["init_sides", format ["COIN_fnc_createMission could not find a suitable scene position for scene # %1 and returned [0,0,0]", _missionNr]] call ADF_fnc_terminateScript; false};
				
				private _missionScene = [
					["Land_Camping_Light_F",[0,0,-0.0176358],0.1,1,0,[0,0],"hook","hook setVectorUp [0, 0, 1]",true,false], 
					["Land_tent_east",[-0.00634766,1.27441,0],90,1,0,[0,0],"COIN_sideMission_target","this allowDamage false",true,false], 
					["Land_CampingChair_V2_F",[-2.22168,-3.75806,4.76837e-006],0,1,0,[0,0],"","",true,false], 
					["Axe_woodblock",[2.54712,-3.74487,0],0,1,0,[0,0],"","",true,false], 
					["Land_A_tent",[5.92212,0.123291,0],62.4753,1,0,[0,0],"","",true,false], 
					["Land_A_tent",[-6.33057,0.154297,0],101.201,1,0,[0,0],"","",true,false], 
					["Land_A_tent",[5.94775,-2.58691,0],265.215,1,0,[0,0],"","",true,false], 
					["Land_A_tent",[5.88232,2.73975,0],97.7883,1,0,[0,0],"","",true,false], 
					["Land_A_tent",[-6.34277,-2.57373,0],94.1678,1,0,[0,0],"","",true,false], 
					["Land_A_tent",[-6.34741,2.76807,0],81.3154,1,0,[0,0],"","",true,false], 
					["Land_A_tent",[5.88574,5.48364,0],244.564,1,0,[0,0],"","",true,false], 
					["Land_A_tent",[-6.34717,5.51221,0],275.413,1,0,[0,0],"","",true,false], 
					["Land_BagFence_Long_F",[2.3291,-7.06226,0],0,1,0,[0,0],"","",true,false], 
					["Land_BagFence_Long_F",[-2.84595,-6.91821,0],0,1,0,[0,0],"","",true,false], 
					["Land_BagFence_Long_F",[2.06299,9.03979,0],0,1,0,[0,0],"","",true,false], 
					["Land_BagFence_Long_F",[-3.13794,9.17676,0],0,1,0,[0,0],"","",true,false], 
					["Land_BagFence_Long_F",[-8.94849,3.82202,0],90,1,0,[0,0],"","",true,false], 
					["Land_BagFence_Long_F",[8.20435,-1.3877,0],90,1,0,[0,0],"","",true,false],
					["Land_BagFence_Long_F",[-8.92261,-1.19238,0],90,1,0,[0,0],"","",true,false], 
					["Land_BagFence_Long_F",[8.11279,4.04102,0],90,1,0,[0,0],"","",true,false], 
					["Land_BagFence_Round_F",[7.8042,-6.52344,0],310,1,0,[0,0],"","",true,false],
					["Land_BagFence_Round_F",[-8.52466,-6.342530,0],45,1,0,[0,0],"","",true,false], 
					["Land_BagFence_Round_F",[7.42163,8.78198,0],217.327,1,0,[0,0],"","",true,false], 
					["Land_BagFence_Round_F",[-8.61646,8.73657,0],130,1,0,[0,0],"","",true,false],			
					["Land_WoodPile_F",[-2.98486,-6.30615,0],93.7722,1,0,[0,0],"","",true,false], 
					["FireLit",[4.85425,-5.15039,0],0,1,0,[0,0],"","",true,false], 
					["Land_CampingChair_V2_F",[-2.59961,6.59375,4.76837e-006],110,1,0,[0,0],"","",true,false], 
					["Land_WoodenLog_F",[-8.34595,-0.0187988,7.62939e-006],360,1,0,[0,0],"","",true,false], 
					["Land_CampingChair_V1_F",[2.57935,8.27466,0.0030899],51.7047,1,0,[0,0],"","",true,false], 
					[selectRandom _army_Static_HMG,[-7.70752,-4.87695,-0.0682845],204.7,1,0,[-5,5.7],"","",true,false], 
					[selectRandom _army_Static_HMG,[6.42676,7.54688,-0.0682855],40,1,0,[4.1,4],"","",true,false]
				];
				
				// Set the scene			
				[_missionPosition, random 360, _missionScene] call BIS_fnc_ObjectsMapper;
				COIN_sideMission_target addEventHandler ["killed", {COIN_sideMission_complete = true;}];
				COIN_sideMission_target allowDamage true;
			};
			
			
			if (_missionNr == 10) exitWith { // Search and Destroy Opium Warehouse
				_missionPosition = [_worldSize, _missionSceneSize, _missionFlatSurface] call COIN_fnc_randomMapLocation;
				if (_missionPosition isEqualTo [0,0,0]) exitWith {["init_sides", format ["COIN_fnc_createMission could not find a suitable scene position for scene # %1 and returned [0,0,0]", _missionNr]] call ADF_fnc_terminateScript; false};
				
				private _missionScene = [
					["Land_Hangar_2",[0.0336914,0.0993652,0],0,1,0,[0,0],"COIN_sideMission_target","COIN_sideMission_target setVectorUp [0, 0, 1]; COIN_sideMission_target allowDamage false;",true,false], 
					["Land_TentLamp_01_suspended_F",[-6.3335,0.894287,5.66872],90,1,0,[0,0],"","",true,false], 
					["Land_TentLamp_01_suspended_F",[5.61572,0.877441,5.66872],90,1,0,[0,0],"","",true,false], 
					["C_Truck_02_covered_F",[11.7739,-4.43018,0],355,1,0,[0,0],"","",true,false], 
					["C_Truck_02_covered_F",[-10.5405,-3.81128,0],174,1,0,[0,0],"","",true,false], 
					["Land_Sack_F",[0.562988,0.0200195,0],294,1,0,[0,0],"","",true,false], 
					["Land_Sack_F",[-0.400391,-0.407959,0],40,1,0,[0,0],"","",true,false], 
					["Land_Sack_F",[0.353027,-0.631836,0],329,1,0,[0,0],"","",true,false], 
					["Land_Sack_F",[-0.710938,0.209473,0],143,1,0,[0,0],"","",true,false], 
					["Land_Sack_F",[0.947754,-0.422607,0],219,1,0,[0,0],"","",true,false], 
					["Land_Sack_F",[0.76123,0.840576,0],38,1,0,[0,0],"","",true,false], 
					["Land_Sack_F",[1.21826,0.219482,0],195,1,0,[0,0],"","",true,false],
					["Land_Sack_EP1",[-0.188965,0.286133,0],132,1,0,[0,0],"","",true,false], 
					["Land_Sack_EP1",[-0.140137,-0.891113,0],131,1,0,[0,0],"","",true,false], 
					["Land_Sack_EP1",[-0.308105,0.690918,0],20,1,0,[0,0],"","",true,false], 
					["Land_FoodSacks_01_small_brown_F",[-1.32813,4.76196,0],0,1,0,[0,0],"","",true,false],
					["Land_FoodSacks_01_small_brown_F",[3.30078,4.93579,0],0,1,0,[0,0],"","",true,false],
					["Land_FoodSacks_01_small_brown_F",[-3.3291,5.93237,0.5],2,1,0,[0,0],"","",true,false], 
					["Land_FoodSacks_01_small_brown_F",[0.888672,6.86426,0],0,1,0,[0,0],"","",true,false], 
					["Land_FoodSacks_01_small_brown_F",[-5.44287,4.59839,0],2,1,0,[0,0],"","",true,false], 
					["Land_FoodSacks_01_small_brown_F",[-7.81104,6.63916,0],85,1,0,[0,0],"","",true,false], 
					["Land_FoodSacks_01_small_brown_F",[8.20264,4.84009,0],1,1,0,[0,0],"","",true,false], 
					["Land_FoodSacks_01_small_brown_F",[11.7021,5.04199,0],0,1,0,[0,0],"","",true,false], 
					["Land_FoodSacks_01_small_brown_F",[-10.6675,6.32129,0],0,1,0,[0,0],"","",true,false], 
					["Land_FoodSacks_01_small_brown_F",[10.9072,5.02173,0],2,1,0,[0,0],"","",true,false], 
					["Land_FoodSacks_01_small_brown_F",[-9.88477,6.35645,0],0,1,0,[0,0],"","",true,false], 
					["Land_bags_stack_EP1",[2.07959,5.2688,0],2.49542,1,0,[0,0],"","",true,false], 
					["Land_bags_stack_EP1",[0.774902,5.6311,0],182,1,0,[0,0],"","",true,false], 
					["Land_bags_stack_EP1",[-0.947266,5.73926,0],180,1,0,[0,0],"","",true,false], 
					["Land_bags_stack_EP1",[-2.54883,5.49585,0],181,1,0,[0,0],"","",true,false], 
					["Land_bags_stack_EP1",[-3.90088,4.89136,0],176,1,0,[0,0],"","",true,false], 
					["Land_bags_stack_EP1",[2.17822,6.26196,0],172,1,0,[0,0],"","",true,false], 
					["Land_bags_stack_EP1",[3.55518,6.04614,0],179,1,0,[0,0],"","",true,false], 
					["Land_bags_stack_EP1",[-4.06836,5.78931,0],182,1,0,[0,0],"","",true,false], 
					["Land_bags_stack_EP1",[-2.5752,6.66748,0],0,1,0,[0,0],"","",true,false], 
					["Land_bags_stack_EP1",[-1.07031,7.13013,0],0,1,0,[0,0],"","",true,false], 
					["Land_bags_stack_EP1",[5.26709,5.6167,0],178,1,0,[0,0],"","",true,false], 
					["Land_bags_stack_EP1",[2.08691,7.43018,0],356,1,0,[0,0],"","",true,false], 
					["Land_bags_stack_EP1",[3.51514,7.21704,0],0,1,0,[0,0],"","",true,false], 
					["Land_bags_stack_EP1",[-4.04395,6.96069,0],3,1,0,[0,0],"","",true,false], 
					["Land_bags_stack_EP1",[0.535645,8.1582,0],183,1,0,[0,0],"","",true,false], 
					["Land_bags_stack_EP1",[-2.56592,7.91357,0],180,1,0,[0,0],"","",true,false], 
					["Land_bags_stack_EP1",[-5.53369,6.43848,0],356,1,0,[0,0],"","",true,false], 
					["Land_bags_stack_EP1",[-0.931641,8.45679,0],180,1,0,[0,0],"","",true,false], 
					["Land_bags_stack_EP1",[5.22266,6.7876,0],359,1,0,[0,0],"","",true,false], 
					["Land_bags_stack_EP1",[6.80127,5.41333,0],176,1,0,[0,0],"","",true,false], 
					["Land_bags_stack_EP1",[-6.97217,5.47388,0],179,1,0,[0,0],"","",true,false], 
					["Land_bags_stack_EP1",[2.02734,8.67505,0],176,1,0,[0,0],"","",true,false], 
					["Land_bags_stack_EP1",[-3.97998,8.20532,0],182,1,0,[0,0],"","",true,false], 
					["Land_bags_stack_EP1",[3.50977,8.46338,0],179,1,0,[0,0],"","",true,false], 
					["Land_bags_stack_EP1",[0.564453,9.32959,0],3,1,0,[0,0],"","",true,false], 
					["Land_bags_stack_EP1",[6.70557,6.5813,0],356,1,0,[0,0],"","",true,false], 
					["Land_bags_stack_EP1",[-2.59229,9.08496,0],0,1,0,[0,0],"","",true,false], 
					["Land_bags_stack_EP1",[-5.59766,7.68311,0],176,1,0,[0,0],"","",true,false], 
					["Land_bags_stack_EP1",[5.2124,8.03394,0],179,1,0,[0,0],"","",true,false], 
					["Land_bags_stack_EP1",[-7.0166,6.64478,0],0,1,0,[0,0],"","",true,false], 
					["Land_bags_stack_EP1",[-0.954102,9.62842,0],0,1,0,[0,0],"","",true,false], 
					["Land_bags_stack_EP1",[1.93604,9.84326,0],356,1,0,[0,0],"","",true,false], 
					["Land_bags_stack_EP1",[8.1709,5.93213,0],182,1,0,[0,0],"","",true,false], 
					["Land_bags_stack_EP1",[-3.95508,9.37671,0],3,1,0,[0,0],"","",true,false], 
					["Land_bags_stack_EP1",[3.46924,9.63452,0],0,1,0,[0,0],"","",true,false], 
					["Land_bags_stack_EP1",[6.6416,7.82593,0],176,1,0,[0,0],"","",true,false], 
					["Land_bags_stack_EP1",[-8.68408,5.90332,0],179,1,0,[0,0],"","",true,false], 
					["Land_bags_stack_EP1",[-5.69336,8.85107,0],356,1,0,[0,0],"","",true,false], 
					["Land_bags_stack_EP1",[5.16846,9.20459,0],0,1,0,[0,0],"","",true,false], 
					["Land_bags_stack_EP1",[-7.02686,7.89111,0],179,1,0,[0,0],"","",true,false], 
					["Land_bags_stack_EP1",[8.19531,7.10352,0],2,1,0,[0,0],"","",true,false], 
					["Land_bags_stack_EP1",[6.5459,8.9939,0],356,1,0,[0,0],"","",true,false], 
					["Land_bags_stack_EP1",[9.69043,5.63867,0],180,1,0,[0,0],"","",true,false], 
					["Land_bags_stack_EP1",[-8.72412,7.07422,0],0,1,0,[0,0],"","",true,false], 
					["Land_bags_stack_EP1",[-7.0708,9.06177,0],0,1,0,[0,0],"","",true,false], 
					["Land_bags_stack_EP1",[-10.1499,5.44775,0],176,1,0,[0,0],"","",true,false], 
					["Land_bags_stack_EP1",[8.25928,8.34814,0],182,1,0,[0,0],"","",true,false], 
					["Land_bags_stack_EP1",[9.66406,6.8103,0],0,1,0,[0,0],"","",true,false], 
					["Land_bags_stack_EP1",[-8.72949,8.32056,0],179,1,0,[0,0],"","",true,false], 
					["Land_bags_stack_EP1",[-10.1523,7.28735,0],357,1,0,[0,0],"","",true,false], 
					["Land_bags_stack_EP1",[9.67334,8.0564,0],180,1,0,[0,0],"","",true,false], 
					["Land_bags_stack_EP1",[8.28418,9.51953,0],3,1,0,[0,0],"","",true,false], 
					["Land_bags_stack_EP1",[11.335,6.0791,0],182,1,0,[0,0],"","",true,false], 
					["Land_bags_stack_EP1",[-8.77002,9.4917,0],0,1,0,[0,0],"","",true,false], 
					["Land_bags_stack_EP1",[-11.8008,5.59961,0],183,1,0,[0,0],"","",true,false], 
					["Land_bags_stack_EP1",[-10.2119,8.53223,0],176,1,0,[0,0],"","",true,false], 
					["Land_bags_stack_EP1",[9.64697,9.22778,0],0,1,0,[0,0],"","",true,false],
					["Land_bags_stack_EP1",[11.3594,7.25049,0],2,1,0,[0,0],"","",true,false], 
					["Land_bags_stack_EP1",[-11.8979,6.5354,0],3,1,0,[0,0],"","",true,false], 
					["Land_bags_stack_EP1",[12.8545,5.78564,0],180,1,0,[0,0],"","",true,false], 
					["Land_bags_stack_EP1",[-10.3032,9.70044,0],356,1,0,[0,0],"","",true,false], 
					["Land_bags_stack_EP1",[-11.7036,8.01538,0],183,1,0,[0,0],"","",true,false], 
					["Land_bags_stack_EP1",[11.4233,8.49512,0],182,1,0,[0,0],"","",true,false], 
					["Land_bags_stack_EP1",[-13.1626,5.89624,0],180,1,0,[0,0],"","",true,false], 
					["Land_bags_stack_EP1",[12.8281,6.95728,0],0,1,0,[0,0],"","",true,false], 
					["Land_bags_stack_EP1",[-11.6748,9.18677,0],3,1,0,[0,0],"","",true,false], 
					["Land_bags_stack_EP1",[-13.1851,7.06787,0],0,1,0,[0,0],"","",true,false], 
					["Land_bags_stack_EP1",[11.4482,9.6665,0],2,1,0,[0,0],"","",true,false],  
					["Land_bags_stack_EP1",[12.8374,8.20337,0],180,1,0,[0,0],"","",true,false], 
					["Land_bags_stack_EP1",[-13.1709,8.31396,0],180,1,0,[0,0],"","",true,false], 
					["Land_bags_stack_EP1",[12.811,9.37476,0],0,1,0,[0,0],"","",true,false], 
					["Land_bags_stack_EP1",[-13.1934,9.4856,0],0,1,0,[0,0],"","",true,false], 
					["Land_FoodSacks_01_cargo_brown_idap_F",[-2.89258,-6.11523,0],0,1,0,[0,0],"","",true,false], 
					["Land_FoodSacks_01_cargo_brown_idap_F",[-3.00928,-9.02979,0],90,1,0,[0,0],"","",true,false], 
					["Land_FoodSacks_01_cargo_brown_idap_F",[3.23486,-8.98804,0],270,1,0,[0,0],"","",true,false], 
					["Land_FoodSacks_01_cargo_brown_idap_F",[1.64551,-8.9624,0],90,1,0,[0,0],"","",true,false],  
					["Land_FoodSacks_01_cargo_brown_idap_F",[0.125977,-8.97852,0],270,1,0,[0,0],"","",true,false],  
					["Land_FoodSacks_01_cargo_brown_idap_F",[-1.4292,-8.99146,0],0,1,0,[0,0],"","",true,false], 
					["Land_FoodSacks_01_cargo_brown_idap_F",[-1.41992,-7.49243,0],90,1,0,[0,0],"","",true,false], 
					["Land_FoodSacks_01_cargo_brown_idap_F",[1.646,-7.57373,0],0,1,0,[0,0],"","",true,false]
				];

				// Set the scene			
				[_missionPosition, random 360, _missionScene] call BIS_fnc_ObjectsMapper;
				COIN_sideMission_target addEventHandler ["killed", {COIN_sideMission_complete = true;}];
				COIN_sideMission_target allowDamage true;
			};
			
			
			if (_missionNr == 11) exitWith { // Search and Destroy Oil Facility
				_missionPosition = [_worldSize, _missionSceneSize, _missionFlatSurface] call COIN_fnc_randomMapLocation;
				if (_missionPosition isEqualTo [0,0,0]) exitWith {["init_sides", format ["COIN_fnc_createMission could not find a suitable scene position for scene # %1 and returned [0,0,0]", _missionNr]] call ADF_fnc_terminateScript; false};
				
				private _missionScene = [
					["Land_Misc_IronPipes_EP1",[0.081543,-0.29541,0],0,1,0,[0,0],"hook","",true,false], 
					["Land_Ind_Oil_Tower_EP1",[0.640137,6.79517,0],0,1,0,[0,0],"COIN_sideMission_target","this setVectorUp [0, 0, 1]",true,false], 
					["Land_Pipes_small_F",[3.23828,2.86621,0.31],28,1,0,[0,0],"","",true,false], 
					["Land_Pipes_large_F",[5.78467,4.16162,0.10],82,1,0,[0,0],"","",true,false], 
					["Land_Toilet",[7.70166,1.97534,0],0,1,0,[0,0],"","this setVectorUp [0, 0, 1]",true,false], 
					["Oil_Spill_F",[5.64453,0.711182,0],330,1,0,[0,0],"","",true,false], 
					["Oil_Spill_F",[-4.2002,-0.449219,0],0,1,0,[0,0],"","",true,false], 
					["Land_Chair_EP1",[4.96875,-0.159424,0],115,1,0,[0,0],"","",true,false], 
					["Land_Chair_EP1",[3.90479,-0.456787,0],46,1,0,[0,0],"","",true,false], 
					["Land_Chair_EP1",[5.64893,-1.17529,0],156,1,0,[0,0],"","",true,false], 
					["Land_MetalBarrel_F",[-8.2793,4.9873,1.431],162,1,0.00494899,[0,0],"","",true,false], 
					["Land_MetalBarrel_F",[-8.14307,5.73438,1.91],125,1,0.00494891,[0,0],"","",true,false], 
					["Land_MetalBarrel_F",[-8.9873,5.71118,1.431],3,1,0.00494822,[0,0],"","",true,false], 
					["Land_MetalBarrel_F",[-7.79492,7.80225,2],272,1,0.0049487,[0,0],"","",true,false], 
					["Land_MetalBarrel_F",[-1.72021,12.8711,0],139,1,0.0263412,[0,0],"","",true,false], 
					["Land_MetalBarrel_F",[-3.67188,13.4089,1.431],156,1,0.00494836,[0,0],"","",true,false], 
					["Land_MetalBarrel_F",[-2.65234,13.7581,1.431],86,1,0.00494838,[0,0],"","",true,false], 
					["Land_MetalBarrel_F",[-4.50488,13.9285,1.431],353,1,0.00494867,[0,0],"","",true,false], 
					["Land_MetalBarrel_F",[-3.64746,14.384,1.431],39,1,0.0049487,[0,0],"","",true,false], 
					["CargoNet_01_barrels_F",[-3.27783,10.7109,0],0,1,0,[0,0],"","",true,false], 
					[selectRandom _army_Static_HMG,[-4.98975,6.55396,8.27],180,1,0,[0,0],"","",true,false], 
					[selectRandom _army_Static_HMG,[1.21143,4.03564,17],180,1,0,[0,0],"","",true,false]
				];

				// Set the scene			
				[_missionPosition, random 360, _missionScene] call BIS_fnc_ObjectsMapper;
				COIN_sideMission_target addEventHandler ["killed", {COIN_sideMission_complete = true;}];
				COIN_sideMission_target allowDamage true;
			};
			
			
			if (_missionNr == 12) exitWith { // Search and Destroy IED Production Facility
				_missionPosition = [_worldSize, _missionSceneSize, _missionFlatSurface] call COIN_fnc_randomMapLocation;
				if (_missionPosition isEqualTo [0,0,0]) exitWith {["init_sides", format ["COIN_fnc_createMission could not find a suitable scene position for scene # %1 and returned [0,0,0]", _missionNr]] call ADF_fnc_terminateScript; false};
				
				private _missionScene = [
					["Land_House_C_4_EP1",[-1.38184,1.28784,0],0,1,0,[0,0],"COIN_sideMission_target","this setVectorUp [0, 0, 1]; this allowDamage false;",true,false], 
					["Land_WoodenTable_large_F",[1.80908,-1.08228,3.709],0,1,0,[0,0],"","this setVectorUp surfaceNormal position this;",true,false],
					["Land_WoodenTable_large_F",[-0.606934,-1.17456,3.709],0,1,0,[0,0],"","this setVectorUp surfaceNormal position this",true,false],
					["CUP_metalcrate",[0.221191,-0.912842,3.708],0,1,0,[0,0],"","this setVectorUp surfaceNormal position this",true,false], 
					["Barrels",[0.901855,2.68994,0.576],0,1,0,[0,0],"","",true,false],
					["Barrels",[2.44922,2.70313,0.576],270,1,0,[0,0],"","",true,false], 
					[selectRandom _army_Static_HMG,[4.44482,3.24121,6.87],360,1,0,[0,0],"","",true,false],
					[selectRandom _army_Static_HMG,[4.38428,-4.9314,6.87],126.77,1,0,[0,0],"","",true,false], 
					[selectRandom _army_Static_HMG,[-5.6,-2.8,3.71],180,1,0,[0,0],"","",true,false], 
					["CUP_ammobednaX",[-0.677246,-1.125,3.708],88.55,1,0,[0,0],"","this setVectorUp surfaceNormal position this",true,false], 
					["Land_TentLamp_01_suspended_F",[4.23975,-1.79346,1.372],0,1,0,[0,0],"","this setVectorUp surfaceNormal position this",true,false], 
					["CUP_hromada_beden_dekorativniX",[3.04395,-1.09888,3.708],88.901,1,0,[0,0],"","",true,false], 
					["CUP_kitchen_chair_a",[-3.59912,-5.04785,0],305,1,0,[0,0],"","",true,false], 
					["CUP_kitchen_chair_a",[-2.56494,-4.72705,0],0,1,0,[0,0],"","",true,false], 
					["CUP_kitchen_chair_a",[-1.53223,-5.0459,0],56,1,0,[0,0],"","",true,false], 
					["Box_IED_Exp_F",[1.78613,-1.44141,4.573],0.00344883,1,0,[0,0],"","this call ADF_fnc_stripVehicle; this setVectorUp surfaceNormal position this",true,false], 
					["CargoNet_01_barrels_F",[-5.37695,0.25708,0.576],0.000726752,1,0,[0,0],"","",true,false], 
					["Land_TentLamp_01_standing_F",[-0.171875,-4.52686,3.781],177.877,1,0,[0,0],"","",true,false], 
					["Land_WoodPile_F",[-5.26514,-4.56177,0],92.6505,1,0,[0,0],"","",true,false], 
					["Paleta2",[-2.89697,5.37842,0],0,1,0,[0,0],"","",true,false], 
					["Land_WoodenCrate_01_stack_x5_F",[5.35547,1.15381,3.709],0,1,0,[0,0],"","this setVectorUp surfaceNormal position this",true,false], 
					["Land_CratesWooden_F",[5.56201,-5.13232,0],0,1,0,[0,0],"","this setVectorUp surfaceNormal position this",true,false], 
					["Land_Campfire_burning",[-2.2251,-7.34546,-9.53674e-007],0,1,0,[0,0],"","",true,false], 
					["Land_PortableLight_02_single_folded_yellow_F",[5.85986,-2.12524,5.098],90,1,0,[0,0],"","this setVectorUp surfaceNormal position this",true,false], 
					["Box_FIA_Ammo_F",[1.66504,-2.06543,6.863],0.00131295,1,0,[0,0],"","this call ADF_fnc_stripVehicle",true,false]
				];

				// Set the scene			
				[_missionPosition, random 360, _missionScene] call BIS_fnc_ObjectsMapper;
				COIN_sideMission_target addEventHandler ["killed", {COIN_sideMission_complete = true;}];
				COIN_sideMission_target allowDamage true;
			};
			
			
			if (_missionNr == 13) exitWith { // Destroy TKA Armoured Group
				_missionPosition = [_worldSize, _missionSceneSize, _missionFlatSurface] call COIN_fnc_randomMapLocation;
				if (_missionPosition isEqualTo [0,0,0]) exitWith {["init_sides", format ["COIN_fnc_createMission could not find a suitable scene position for scene # %1 and returned [0,0,0]", _missionNr]] call ADF_fnc_terminateScript; false};
				
				private _missionScene = [
					["Barrel4",[0,0,0],321.231,1,0,[0,0],"hook","",true,false], 
					[_army_allArmor,[2.77637,3.59644,-0.0733671],346,1,0,[0,0],"COIN_sideMission_target","",true,false], 
					[_army_allArmor,[-6.18262,2.82056,-0.0753698],324,1,0,[0,0],"COIN_scene13_tank2","",true,false], 
					["Land_RefuelingHose_01_F",[-0.827148,0.195557,0],0,1,0,[0,0],"","",true,false], 
					["Barrel5",[-0.865723,-0.523193,0],11,1,0,[0,0],"","",true,false], 
					["Barrel2",[-0.72168,0.965088,0],225,1,0,[0,0],"","",true,false], 
					["Fuel_can",[-2.89307,1.74194,0],287,1,0,[0,0],"","",true,false], 
					["Fuel_can",[-3.06006,2.18286,0],12,1,0,[0,0],"","",true,false],
					[_army_allAPC,[14.5088,1.34985,0],207.628,1,0,[0,0],"COIN_scene13_apc","",true,false]
				];

				// Set the scene			
				[_missionPosition, random 360, _missionScene] call BIS_fnc_ObjectsMapper;
				[COIN_scene13_apc, ["Takistan", 1], ["crate_l1_unhide", 0, "crate_l2_unhide", 1, "crate_l3_unhide", 1, "crate_l4_unhide", 1, "crate_r1_unhide", 1, "crate_r2_unhide", 1, "crate_r3_unhide", 1, "crate_r4_unhide", 0, "water_1_unhide", 1, "water_2_unhide", 1, "wheel_1_unhide", 0, "wheel_2_unhide", 1]] call BIS_fnc_initVehicle;	
				COIN_sideMission_target lock 3;
				COIN_scene13_tank2 lock 2;
				COIN_scene13_apc lock 3;
				{[_x] call ADF_fnc_stripVehicle;} forEach [COIN_sideMission_target, COIN_scene13_tank2, COIN_scene13_apc];

				COIN_sideMission_target addEventHandler ["killed", {COIN_sideMission_target1_KIA = true;}];
				COIN_scene13_tank2 addEventHandler ["killed", {COIN_sideMission_target2_KIA = true;}];

				// Target Sensor/Monitor
				[COIN_sideMission_target, COIN_scene13_tank2, COIN_scene13_apc, _missionMaxTime] spawn {
					params ["_target_1", "_target_2", "_apc", "_missionMaxTime"];
					private _timeOut = time + _missionMaxTime;

					waitUntil {
						private _playersClose = false;
						{if ((COIN_sideMission_target distance2D _x) < 800) exitWith {_playersClose = true}} forEach allPlayers select {((getPosATL _x) select 2) < 5};					
						sleep 30;
						_playersClose || time > _timeOut || COIN_sideMission_skipped
					};

					if (time > _timeOut || COIN_sideMission_skipped) exitWith {};

					waitUntil {
						sleep 1;
						(COIN_sideMission_target1_KIA && COIN_sideMission_target2_KIA) || time > _timeOut || COIN_sideMission_skipped
					};

					if (time > _timeOut || COIN_sideMission_skipped) exitWith {{[_x] call ADF_fnc_delete} forEach [_target_1, _target_2, _apc];};
					COIN_sideMission_complete = true;
				};
			};
			
			
			if (_missionNr == 14) exitWith { // Search and Destroy Oil Tanker Vehicle
				private _roadSidePos = [[_worldSize/2, _worldSize/2, 0], worldSize/2, 150, true, "AUTO", "C_Van_01_fuel_F"] call ADF_fnc_roadSidePos;
				_missionPosition = _roadSidePos # 0;
				_direction = _roadSidePos # 1;
				private _missionScene = [
					["Land_RoadCone_01_F",[0,0,9.53674e-007],0,1,0.00493594,[0,0],"hook","",true,false], 
					["Land_RoadCone_01_F",[1.18652,-0.958984,5],0,1,0.0048816,[0,0],"","",true,false], 
					["Land_RoadCone_01_F",[0.121094,7.07715,5],0,1,0.0048816,[0,0],"","",true,false], 
					["Land_RoadCone_01_F",[1.51709,8.01392,7],0,1,0.004954,[0,0],"","",true,false],
					["C_Van_01_fuel_F",[0.688965,4.08472,0],0,1,0,[0,0],"COIN_sideMission_target","COIN_sideMission_target allowDamage false",true,false]
				];

				// Set the scene			
				[_missionPosition, _direction, _missionScene] call BIS_fnc_ObjectsMapper;
				[COIN_sideMission_target, ["Guerilla_03",1], true] call BIS_fnc_initVehicle;
				COIN_sideMission_target lock 2;
				COIN_sideMission_target setHitPointDamage ["HitLF2Wheel", 1];
				
				COIN_sideMission_target addEventHandler ["killed", {COIN_sideMission_complete = true;}];
				COIN_sideMission_target allowDamage true;
			};
			
			
			if (_missionNr == 15) exitWith { // Retrieve Informant
				// Get random city/village
				_missionPosition = selectRandom COIN_largeLocations;
				if (_missionPosition distance (getMarkerPos COIN_ao_activeMarker) < 2000) then {
					private _timeOut = time + 5;
					waitUntil {
						_missionPosition = selectRandom COIN_largeLocations;
						(_missionPosition distance (getMarkerPos COIN_ao_activeMarker)) > 1999 || time > _timeOut
					};
				};

				_missionPosition set [2, 0];
				_allBuildings = [_missionPosition, _missionAOSize, -1] call ADF_fnc_buildingPositions;
				_building = selectRandom _allBuildings;
				_buildingPosition = getPosATL _building;
				_targetPosition = (_building getVariable ["ADF_garrPos", []]) # 0;
				_targetPosition set [2, (_targetPosition # 2) + 0.25];

				private _missionScene = [];

				// create informant
				private _targetGroup = createGroup civilian;
				COIN_sideMission_target = _targetGroup createUnit ["C_man_pilot_F", _targetPosition, [], 0, "CAN_COLLIDE"];
				COIN_sideMission_target allowDamage false;
				COIN_sideMission_target disableAI "MOVE";

				// reDress informant
				[COIN_sideMission_target] call ADF_fnc_stripUnit;
				COIN_sideMission_target forceAddUniform "U_C_WorkerCoveralls";
				COIN_sideMission_target addHeadgear "H_Cap_red";
				COIN_sideMission_target linkItem "ItemMap";
				COIN_sideMission_target addItem "FirstAidKit";				

				COIN_sideMission_target addEventHandler ["killed", {COIN_sideMission_failed = true;}];		

				publicVariable "COIN_sideMission_target";

				// Target Sensor/Monitor > bugger addAction
				[_missionMaxTime] spawn {
					params ["_missionMaxTime"];
					private _timeOut = time + _missionMaxTime;
					COIN_sideMission_target allowDamage true;

					waitUntil {
						private _playersClose = false;
						{if ((COIN_sideMission_target distance2D _x) < 1) exitWith {_playersClose = true}} forEach allPlayers select {((getPosATL _x) select 2) < 5};					
						sleep 1;
						_playersClose || time > _timeOut || COIN_sideMission_skipped
					};

					if (time > _timeOut || COIN_sideMission_skipped) exitWith {[COIN_sideMission_target] call ADF_fnc_delete;};
					[COIN_sideMission_target] joinSilent group (_this select 1);   
					COIN_sideMission_target enableAI "MOVE";

					waitUntil {
						sleep 2;
						(COIN_sideMission_target distance2D teleportFlagPole) < 20 || time > _timeOut || COIN_sideMission_skipped
					};
					if (time > _timeOut || COIN_sideMission_skipped) exitWith {[COIN_sideMission_target] call ADF_fnc_delete;};
					COIN_sideMission_complete = true;
					sleep 5;
					[COIN_sideMission_target] call ADF_fnc_delete;
				};

				[_targetGroup] call ADF_fnc_addToCurator;		
			};
			
			
			if (_missionNr == 16) exitWith { // Defend Location
				// Get random city/village
				_missionPosition = selectRandom COIN_largeLocations;
				if (_missionPosition distance (getMarkerPos COIN_ao_activeMarker) < 2000) then {
					private _timeOut = time + 5;
					waitUntil {
						_missionPosition = selectRandom COIN_largeLocations;
						(_missionPosition distance (getMarkerPos COIN_ao_activeMarker)) > 1999 || time > _timeOut
					};
				};
				
				[_missionMaxTime, _missionPosition, _missionAOSize] spawn {
					params ["_missionMaxTime", "_missionPosition", "_missionAOSize"];
					private _timeOut = time + _missionMaxTime;
					private _spawnTimeOut = time + (_missionMaxTime / 2);
					if ADF_missionTest then {_spawnTimeOut = time + 10};
					_leader = objNull;

					waitUntil {
						sleep 1;
						 time > _spawnTimeOut
					};
					
					COIN_sideMission_groups = [];
					
					for "_i" from 0 to 5 do {
						private _group = createGroup east;
						private _spawnPos = [_missionPosition, _missionAOSize * 3] call ADF_fnc_randomPosMax;		
						for "_j" from 1 to 8 do {	
							private _unit = _group createUnit ["O_soldier_F", _spawnPos, [], 0, "NONE"];
							[_unit] call ADF_fnc_redressInsurgents;
							_unit allowSprint false;
							_unit doMove _missionPosition;
						};						
						if (_i == 1) then {_leader = leader _group;};
						COIN_sideMission_groups pushBack _group;
						[_group] call ADF_fnc_addToCurator;
						
						// Search and Destroy
						[_group, _missionPosition, _missionAOSize] spawn {
							params ["_assaultGroup", "_assaultPosition", "_missionAOSize"];
							waitUntil {									
								// Check how close the SAD group is to their target.
								private _distance = [_assaultGroup, _assaultPosition] call ADF_fnc_checkDistance;
								private _speedMode = "FULL";
								
								// If the assault group is within striking distance then enable combat mode
								if (_distance < 150) then {
									_assaultGroup setCombatMode "RED";
									_assaultGroup setBehaviour "COMBAT";	
									_assaultGroup enableGunLights "Auto"; 
									_assaultGroup enableIRLasers false;	
									_speedMode = "NORMAL";
									if (_distance < 50) then {
										_speedMode = "LIMITED";
										{_x setUnitPos "MIDDLE";} forEach units _assaultGroup;
									};			
								} else {
									_assaultGroup enableGunLights "forceOn"; 
									_assaultGroup enableIRLasers true;
									_speedMode = "FULL";
								};

								_assaultGroup setSpeedMode _speedMode;
								
								sleep 3;
								
								(
									((units _assaultGroup) isEqualTo []) || 
									((leader _assaultGroup distance2D _assaultPosition) < 10) 
								)								
							};
							
							if !((units _assaultGroup) isEqualTo []) then {
								[_assaultGroup, _assaultPosition, 150, 4, "SOD", "COMBAT", "RED", "LIMITED", "FILE", 5, true, [5,30,90]] call ADF_fnc_footPatrol;
							};
							
							COIN_sideMission_spawned = true;
						};					
					};
					
					if (!isNil "ADF_HC1" && !ADF_HC_execute) then {(owner ADF_HC1) publicVariableClient "COIN_sideMission_groups"};
					
					waitUntil {
						sleep 2;
						((_leader distance2D _missionPosition) < _missionAOSize / 1.5) || time > _timeOut || COIN_sideMission_skipped
					};
					if (time > _timeOut || COIN_sideMission_skipped) exitWith {};
					sleep 30;
					
					waitUntil {
						sleep 2;
						(([_missionPosition, east, _missionAOSize, "MAN"] call ADF_fnc_countRadius) < 3) || time > _timeOut || COIN_sideMission_skipped
					};					
					if (time > _timeOut || COIN_sideMission_skipped) exitWith {};
					
					COIN_sideMission_complete = true;
				};			
			};
			
			
			if (_missionNr == 17) exitWith { // Destroy AA site
				_missionPosition = [_worldSize, _missionSceneSize, _missionFlatSurface] call COIN_fnc_randomMapLocation;
				if (_missionPosition isEqualTo [0,0,0]) exitWith {["init_sides", format ["COIN_fnc_createMission could not find a suitable scene position for scene # %1 and returned [0,0,0]", _missionNr]] call ADF_fnc_terminateScript; false};
				
				private _missionScene = [
					["Land_Vysilac_FM",[-12.8472,-7.39233,0],90,1,0,[0,0],"","",true,false], 
					["Land_BagFence_Round_F",[-0.249023,-0.204346,-0.00130129],45,1,0,[0,0],"hook","this setVectorUp surfaceNormal position this",true,false],
					["Land_BagFence_Round_F",[4.46924,-0.241699,-0.00130129],315,1,0,[0,0],"","this setVectorUp surfaceNormal position this",true,false], 
					["Land_BagFence_Round_F",[-0.13623,4.63184,-0.00130129],135,1,0,[0,0],"","this setVectorUp surfaceNormal position this",true,false], 
					["Land_BagFence_Round_F",[4.55859,4.46069,-0.00130129],225,1,0,[0,0],"","this setVectorUp surfaceNormal position this",true,false], 
					["Box_FIA_Ammo_F",[1.06494,2.052,0],2,1,0,[0,0],"","this call ADF_fnc_stripVehicle",true,false], 
					["Box_FIA_Ammo_F",[3.54736,1.90723,1.90735e-006],88,1,0,[0,0],"","this call ADF_fnc_stripVehicle",true,false], 
					["Land_fort_rampart_EP1",[8.45117,6.25635,0],270,1,0,[0,0],"","this setVectorUp surfaceNormal position this",true,false], 
					["Land_fort_rampart_EP1",[8.51123,-3.41577,-0.0751281],270,1,0,[0,0],"","this setVectorUp surfaceNormal position this",true,false], 				
					["Land_fort_artillery_nest_EP1",[2.20068,18.6882,0],0,1,0,[0,0],"","this setVectorUp surfaceNormal position this",true,false],
					["Land_fort_artillery_nest_EP1",[2.32275,-15.3494,0],180,1,0,[0,0],"","this setVectorUp surfaceNormal position this",true,false], 					
					[_army_Static_ZU23 # 0,[2.51367,10.2498,-0.077702],180,1,0,[0,0],"COIN_sideMission_target","",true,false], 
					[_army_Static_ZU23 # 0,[2.17041,-6.64648,-0.0777025],0,1,0,[0,0],"COIN_sideMission_target2","",true,false], 
					["Land_BagBunker_Large_F",[-10.6333,2.02539,0],90,1,0,[0,0],"","this setVectorUp surfaceNormal position this",true,false], 
					["Land_Pallet_F",[-12.3584,-1.23218,-0.0010004],0,1,0,[0,0],"","this setVectorUp surfaceNormal position this",true,false], 
					["Land_Pallet_F",[-12.4531,5.23804,-0.000999451],0,1,0,[0,0],"","this setVectorUp surfaceNormal position this",true,false], 
					["Land_Pallet_F",[-13.8804,-1.23145,-0.000687122],0,1,0,[0,0],"","this setVectorUp surfaceNormal position this",true,false], 
					["Land_Pallet_F",[-13.9785,5.23706,-0.000683784],0,1,0,[0,0],"","this setVectorUp surfaceNormal position this",true,false],
					[selectRandom _army_Static_HMG,[-13.4844,-1.0332,-0.0883617],270,1,0,[0,0],"","this setVectorUp surfaceNormal position this",true,false], 
					[selectRandom _army_Static_HMG,[-13.5698,5.45972,-0.0884056],270,1,0,[0,0],"","this setVectorUp surfaceNormal position this",true,false]					
				];	

				// Set the scene			
				[_missionPosition, random 360, _missionScene] call BIS_fnc_ObjectsMapper;
				COIN_sideMission_target addEventHandler ["killed", {COIN_sideMission_target1_KIA = true}];
				COIN_sideMission_target2 addEventHandler ["killed", {COIN_sideMission_target2_KIA = true}];
				
				// Target Sensor/Monitor
				[COIN_sideMission_target, COIN_sideMission_target2,  _missionMaxTime] spawn {
					params ["_target_1", "_target_2", "_missionMaxTime"];
					private _timeOut = time + _missionMaxTime;

					waitUntil {
						private _playersClose = false;
						{if ((COIN_sideMission_target distance2D _x) < 750) exitWith {_playersClose = true}} forEach allPlayers select {((getPosATL _x) select 2) < 5};					
						sleep 30;
						_playersClose || time > _timeOut || COIN_sideMission_skipped
					};

					if (time > _timeOut || COIN_sideMission_skipped) exitWith {};

					waitUntil {
						sleep 1;
						(COIN_sideMission_target1_KIA && COIN_sideMission_target2_KIA) || time > _timeOut || COIN_sideMission_skipped
					};

					if (time > _timeOut || COIN_sideMission_skipped) exitWith {{[_x] call ADF_fnc_delete} forEach [_target_1, _target_2];};
					COIN_sideMission_complete = true;
				};
			};
			
			
			if (_missionNr == 18) exitWith { // Destroy arti site
				_missionPosition = [_worldSize, _missionSceneSize, _missionFlatSurface] call COIN_fnc_randomMapLocation;
				if (_missionPosition isEqualTo [0,0,0]) exitWith {["init_sides", format ["COIN_fnc_createMission could not find a suitable scene position for scene # %1 and returned [0,0,0]", _missionNr]] call ADF_fnc_terminateScript; false};
				
				private _BM21Class = "UK3CB_TKA_O_BM21";
				if (ADF_mod_RHS && !ADF_mod_3CB_FACT) then {
					private _BM21Class = "LOP_TKA_BM21";
				};			
				
				private _missionScene = 					[
					["Land_MetalBarrel_F",[0,0,1.43051e-006],111.148,1,0.00494883,[-0.000567135,-0.000520634],"hook","",true,false], 
					["Land_MetalBarrel_F",[-0.970215,0.475586,1.43051e-006],230.567,1,0.00494872,[-0.000553444,-0.000555622],"","",true,false], 
					["Land_MetalBarrel_F",[-0.14502,1.08545,1.43051e-006],212.021,1,0.00494855,[-0.000562485,-0.000541554],"","",true,false], 
					[_BM21Class,[2.48047,4.82617,-0.0372186],0,1,0,[0,0],"COIN_sideMission_target","",true,false], 
					[_BM21Class,[-7.34424,3.25537,-0.0374475],355,1,0,[0,0],"COIN_sideMission_target2","",true,false], 
					[_BM21Class,[13.0249,1.93848,-0.0374389],2,1,0,[0,0],"COIN_sideMission_target3","",true,false]
				];

				// Set the scene			
				[_missionPosition, random 360, _missionScene] call BIS_fnc_ObjectsMapper;
				{_x lock 2; [_x] call ADF_fnc_stripVehicle} forEach [COIN_sideMission_target, COIN_sideMission_target2, COIN_sideMission_target3];

				COIN_sideMission_target addEventHandler ["killed", {COIN_sideMission_target1_KIA = true;}];
				COIN_sideMission_target2 addEventHandler ["killed", {COIN_sideMission_target2_KIA = true;}];
				COIN_sideMission_target3 addEventHandler ["killed", {COIN_sideMission_target3_KIA = true;}];
				
				// Target Sensor/Monitor
				[COIN_sideMission_target, COIN_sideMission_target2, COIN_sideMission_target3,  _missionMaxTime] spawn {
					params ["_target_1", "_target_2", "_target_3", "_missionMaxTime"];
					private _timeOut = time + _missionMaxTime;

					waitUntil {
						private _playersClose = false;
						{if ((COIN_sideMission_target distance2D _x) < 500) exitWith {_playersClose = true}} forEach allPlayers select {((getPosATL _x) select 2) < 5};					
						sleep 30;
						_playersClose || time > _timeOut || COIN_sideMission_skipped
					};

					if (time > _timeOut || COIN_sideMission_skipped) exitWith {};

					waitUntil {
						sleep 1;
						(COIN_sideMission_target1_KIA && COIN_sideMission_target2_KIA && COIN_sideMission_target3_KIA) || time > _timeOut || COIN_sideMission_skipped
					};

					if (time > _timeOut || COIN_sideMission_skipped) exitWith {{[_x] call ADF_fnc_delete} forEach [_target_1, _target_2, _target_3];};
					COIN_sideMission_complete = true;
				};
			};
		};

		///// MISSION FLOW

		if _sidemissionExit exitWith {[] spawn COIN_fnc_createMission;};
		if (ADF_missionTest && !(isNil "COIN_sideMission_target")) then {["targetMarker", getPos COIN_sideMission_target, "ICON", "mil_dot", 1, 1, 0, "colorYellow"] call ADF_fnc_createMarkerLocal;};

		// Reporting
		diag_log "-----------------------------------------------------------------------------------------";
		diag_log format ["« C O I N »   COIN_fnc_createMission - Mission Nr: %1", _missionNr];
		diag_log format ["« C O I N »   COIN_fnc_createMission - Mission Name: %1", COIN_activeMission # 11];
		diag_log format ["« C O I N »   COIN_fnc_createMission - Max Time: %1 min.", _missionMaxTime/60];
		diag_log format ["« C O I N »   COIN_fnc_createMission - Position: %1", _missionPosition];
		diag_log format ["« C O I N »   COIN_fnc_createMission - AO Size: %1 meters", _missionAOSize];
		diag_log format ["« C O I N »   COIN_fnc_createMission - Infantry Type: %1", _missionInfType];
		diag_log format ["« C O I N »   COIN_fnc_createMission - Patrols: %1 groups", _missionInfPatrols];
		diag_log format ["« C O I N »   COIN_fnc_createMission - Garrison: %1 groups", _missionInfGarrison];
		diag_log format ["« C O I N »   COIN_fnc_createMission - Technicals: %1 vehicles", _missionTechs];
		diag_log "-----------------------------------------------------------------------------------------";
			
		private _missionReset = {
			// Reset vars
			COIN_sideMission_complete = false;
			COIN_sideMission_spawned = false;
			COIN_sideMission_skipped = false;
			COIN_sideMission_test = false;
			COIN_sideMission_groups = [];
			COIN_sideMission_vehicles = [];
			COIN_sideMission_target = nil;
		};

		// Pass on Opfor numbers to HC or Server to populate the AO
		if (isNil "ADF_HC1" && ADF_HC_execute) then {
			[_missionPosition, _missionAOSize, _missionInfType, _missionInfPatrols, _missionInfGarrison, _missionTechs] call COIN_fnc_spawnSideMission;
		} else {
			[_missionPosition, _missionAOSize, _missionInfType, _missionInfPatrols, _missionInfGarrison, _missionTechs] remoteExecCall ["COIN_fnc_spawnSideMission", (owner ADF_HC1)];
		};			
		
		// WaitUntil the AO has spawned fully
		waitUntil {sleep 0.5; COIN_sideMission_spawned};
		
		// Create Side Mission AO marker
		_aoSizeMarker = 2;
		_aoBrushMarker = "Border";
		_randomizeMarker = {
			_randomDist = random _missionAOSize;
			_return = selectRandom [_randomDist, 0 - _randomDist];
			_return
		};
		if !COIN_EXEC_aoMissions then {_aoSizeMarker = 3; _aoBrushMarker = "FDiagonal";};
		_missionMarker = [format ["_m%1-%2", _missionPosition, _missionNr], [(_missionPosition # 0) + (call _randomizeMarker), (_missionPosition # 1) + (call _randomizeMarker), 0], "ELLIPSE", "", _missionAOSize * _aoSizeMarker, _missionAOSize * _aoSizeMarker, 0, "ColorRed", "", _aoBrushMarker, 1] call ADF_fnc_createMarker;
		
		// Announce side mission
		[1, _missionNr] remoteExec ["COIN_fnc_msg_sideMission", 0];

		// Side mission progress monitoring				
		private _timeOut = time + _missionMaxTime;
		waitUntil {
			sleep 5;
			if ADF_missionTest then {diag_log format ["« C O I N »   COIN_fnc_createMission - Side Mission (%1) Monitor. Time left: %2 min", _missionNr, round((_timeOut - time)/60)];};
			COIN_sideMission_test || COIN_sideMission_complete || COIN_sideMission_skipped || COIN_sideMission_failed || time > _timeOut
		};
		if COIN_sideMission_test  then {COIN_sideMission_complete = true;};
		
		// Reporting
		diag_log "« C O I N »  -----------------------------------------------------------------------------------------";
		diag_log format ["« C O I N »   COIN_fnc_createMission - COIN_sideMission_complete: %1", COIN_sideMission_complete];
		diag_log format ["« C O I N »   COIN_fnc_createMission - COIN_sideMission_skipped: %1", COIN_sideMission_skipped];
		diag_log format ["« C O I N »   COIN_fnc_createMission - COIN_sideMission_failed: %1", COIN_sideMission_failed];
		diag_log format ["« C O I N »   COIN_fnc_createMission - COIN_sideMission_test: %1", COIN_sideMission_test];
		diag_log format ["« C O I N »   COIN_fnc_createMission - Timed out: %1", time > _timeOut];
		diag_log "« C O I N »  -----------------------------------------------------------------------------------------";

		// Clean-up, reward and messaging
		if (isNil "ADF_HC1" && ADF_HC_execute) then {
			[_missionPosition, _missionAOSize, _missionSceneSize, _missionMarker, COIN_sideMission_skipped] spawn COIN_fnc_deleteSideMission;
		} else {
			[_missionPosition, _missionAOSize, _missionSceneSize, _missionMarker, COIN_sideMission_skipped] remoteExec ["COIN_fnc_deleteSideMission", (owner ADF_HC1)];
		};
		
		if COIN_sideMission_skipped exitWith {
			call _missionReset;
			sleep 5; 
			[] spawn COIN_fnc_createMission;
		};
		
		if COIN_sideMission_failed then {[3, _missionNr] remoteExec ["COIN_fnc_msg_sideMission", 0]};
		if (time > _timeOut && {!COIN_sideMission_complete}) then {[3, _missionNr] remoteExec ["COIN_fnc_msg_sideMission", 0]};
		if (time < _timeOut && {COIN_sideMission_complete}) then {
			COIN_sideMission_completedNr = COIN_sideMission_completedNr + 1;
			[_missionNr, COIN_sideMission_completedNr, _worldSize] call COIN_fnc_createReward;
		};
		
		if COIN_sideMission_test exitWith {
			call _missionReset;
			sleep 5; 
			[] spawn COIN_fnc_createMission;
		};
				
		// Pause before spawning next side mission
		private _timeOut = [time + ((2 * 60) + (random (5 * 60))), time + ((20 * 60) + (random (20 * 60)))] select COIN_EXEC_aoMissions; 
		waitUntil {sleep 1; time > _timeOut};
		call _missionReset;
		[] spawn COIN_fnc_createMission;
		
	}; // COIN_fnc_createMission
	
	[] spawn COIN_fnc_createMission; // first run	
	
}; // isServer