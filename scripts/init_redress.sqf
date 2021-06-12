diag_log "ADF rpt: Init - executing: scripts\init_redress.sqf"; // Reporting. Do NOT edit/remove

/*********************************************************************
TAKISTAN ARMY/MILITIA REDRESS by Whiztler
v 1.08

Redresses default CSAT soldiers/groups into modern TKA units.
Requires:
	RHS USAF/AFRF/GREF mods + Project Opfor and/or 3CB Factions
-or-
	CUP Weaons/Units/Vehicles + Community Factions Project
*********************************************************************/

ADF_fnc_redressInsurgents = {
	// init
	params ["_unit"];
	private _role = typeOf _unit;

	// Strip the unit
	[_unit, true] call ADF_fnc_stripUnit;
	
	// Define containers
	private _AKM = [];
	private _AKMGP = [];
	private _AKS74U = [];
	private _ASVAL = [];
	private _PKP = [];
	private _PKM = [];
	private _SVD = [];
	private _FNFal = [];
	private _LeeEnfield = [];
	private _allUniforms = [];
	private _allVests = ["V_BandollierB_blk", "V_BandollierB_cbr", "V_BandollierB_khk"];
	private _allHeadGear = ["H_Shemag_olive_hs", "H_ShemagOpen_tan", "H_ShemagOpen_khk", "H_Shemag_olive"];
	private _addVest = true;
	private _backpackHeavy = ["B_Carryall_cbr", "B_TacticalPack_blk"];
	private _backpackLight = ["B_FieldPack_khk"];
	call {
		if ADF_mod_RHS exitWith {
			_AKM = ["rhs_weap_akm", "rhs_30Rnd_762x39mm"];
			_AKMGP = ["rhs_weap_akm_gp25", "rhs_30Rnd_762x39mm"];
			_AKS74U = ["rhs_weap_aks74u", "rhs_30Rnd_545x39_AK"];
			_ASVAL = ["rhs_weap_asval", "rhs_20rnd_9x39mm_SP5"];
			_PKP = ["rhs_weap_pkp", "rhs_100Rnd_762x54mmR"];
			_PKM = ["rhs_weap_pkm", "rhs_100Rnd_762x54mmR"];
			_SVD = ["rhs_weap_svdp", "rhs_10Rnd_762x54mmR_7N1"];
			_backpackHeavy append ["rhs_sidor", "rhsgref_hidf_alicepack"];
			//_backpackLight append [];
			if (ADF_mod_3CB_FACT && ADF_mod_PROPFOR) exitWith {
				_allUniforms append [
					"UK3CB_TKM_O_U_01", "UK3CB_TKM_O_U_03", "UK3CB_TKM_O_U_04", "UK3CB_TKM_O_U_05", "UK3CB_TKM_O_U_06", 
					"UK3CB_TKM_B_U_01", "UK3CB_TKM_B_U_03", "UK3CB_TKM_B_U_04", "UK3CB_TKM_B_U_05", "UK3CB_TKM_B_U_06", 
					"UK3CB_TKM_I_U_01", "UK3CB_TKM_I_U_03", "UK3CB_TKM_I_U_04", "UK3CB_TKM_I_U_05", "UK3CB_TKM_I_U_06", 			
					"LOP_U_AM_Fatigue_04", "LOP_U_AM_Fatigue_04_2", "LOP_U_AM_Fatigue_04_3", "LOP_U_AM_Fatigue_04_4", "LOP_U_AM_Fatigue_04_5", "LOP_U_AM_Fatigue_04_6", 
					"LOP_U_AM_Fatigue_03", "LOP_U_AM_Fatigue_03_2", "LOP_U_AM_Fatigue_03_3", "LOP_U_AM_Fatigue_03_4", "LOP_U_AM_Fatigue_03_5", "LOP_U_AM_Fatigue_03_6", 
					"LOP_U_AM_Fatigue_02", "LOP_U_AM_Fatigue_02_2", "LOP_U_AM_Fatigue_02_3", "LOP_U_AM_Fatigue_02_4", "LOP_U_AM_Fatigue_02_5", "LOP_U_AM_Fatigue_02_6", 
					"LOP_U_AM_Fatigue_01", "LOP_U_AM_Fatigue_01_2", "LOP_U_AM_Fatigue_01_3", "LOP_U_AM_Fatigue_01_4", "LOP_U_AM_Fatigue_01_5", "LOP_U_AM_Fatigue_01_6"		
				];
				_allHeadGear append [
					"UK3CB_TKC_H_Turban_01_1", "UK3CB_TKC_H_Turban_02_1", "UK3CB_TKC_H_Turban_03_1", "UK3CB_TKC_H_Turban_05_1", 
					"UK3CB_TKM_O_H_Turban_01_1", "UK3CB_TKM_O_H_Turban_02_1", "UK3CB_TKM_O_H_Turban_03_1", "UK3CB_TKM_O_H_Turban_04_1", "UK3CB_TKM_O_H_Turban_05_1", 
					"UK3CB_TKM_I_H_Turban_01_1", "UK3CB_TKM_I_H_Turban_02_1", 
					"LOP_H_Pakol", "LOP_H_Shemag_BLK", "LOP_H_Shemag_BLU", "LOP_H_Shemag_OLV", "LOP_H_Shemag_TAN", "LOP_H_Turban_mask"
				];
				_allVests = [
					"UK3CB_V_Pouch"
				];
				_LeeEnfield = selectRandom [["LOP_Weap_LeeEnfield", "LOP_10rnd_77mm_mag"], ["UK3CB_Enfield_Rail", "UK3CB_Enfield_Mag"]];
				_FNFal = selectRandom [["UK3CB_FNFAL_FULL", "UK3CB_FNFAL_762_20Rnd"], ["UK3CB_FNFAL_PARA", "UK3CB_FNFAL_762_20Rnd"], ["rhs_weap_svds_npz", "rhs_10Rnd_762x54mmR_7N1"], ["rhs_weap_svds", "rhs_10Rnd_762x54mmR_7N1"]];
				
			};
			if ADF_mod_3CB_FACT exitWith {
				_allUniforms append [
					"UK3CB_TKM_O_U_01", "UK3CB_TKM_O_U_03", "UK3CB_TKM_O_U_04", "UK3CB_TKM_O_U_05", "UK3CB_TKM_O_U_06", 
					"UK3CB_TKM_B_U_01", "UK3CB_TKM_B_U_03", "UK3CB_TKM_B_U_04", "UK3CB_TKM_B_U_05", "UK3CB_TKM_B_U_06", 
					"UK3CB_TKM_I_U_01", "UK3CB_TKM_I_U_03", "UK3CB_TKM_I_U_04", "UK3CB_TKM_I_U_05", "UK3CB_TKM_I_U_06"
				];
				_allVests append [
					"UK3CB_V_Pouch"
				];
				_allHeadGear append [
					"UK3CB_TKC_H_Turban_01_1", "UK3CB_TKC_H_Turban_02_1", "UK3CB_TKC_H_Turban_03_1", "UK3CB_TKC_H_Turban_05_1", 
					"UK3CB_TKM_O_H_Turban_01_1", "UK3CB_TKM_O_H_Turban_02_1", "UK3CB_TKM_O_H_Turban_03_1", "UK3CB_TKM_O_H_Turban_04_1", "UK3CB_TKM_O_H_Turban_05_1"
				];
				_LeeEnfield = ["UK3CB_Enfield_Rail", "UK3CB_Enfield_Mag"];
				_FNFal = selectRandom [["UK3CB_FNFAL_FULL", "UK3CB_FNFAL_762_20Rnd"], ["UK3CB_FNFAL_PARA", "UK3CB_FNFAL_762_20Rnd"], ["rhs_weap_svds", "rhs_10Rnd_762x54mmR_7N1"]];
			};			
			if ADF_mod_PROPFOR exitWith {
				_allUniforms append [
					"LOP_U_AM_Fatigue_04", "LOP_U_AM_Fatigue_04_2", "LOP_U_AM_Fatigue_04_3", "LOP_U_AM_Fatigue_04_4", "LOP_U_AM_Fatigue_04_5", "LOP_U_AM_Fatigue_04_6", 
					"LOP_U_AM_Fatigue_03", "LOP_U_AM_Fatigue_03_2", "LOP_U_AM_Fatigue_03_3", "LOP_U_AM_Fatigue_03_4", "LOP_U_AM_Fatigue_03_5", "LOP_U_AM_Fatigue_03_6", 
					"LOP_U_AM_Fatigue_02", "LOP_U_AM_Fatigue_02_2", "LOP_U_AM_Fatigue_02_3", "LOP_U_AM_Fatigue_02_4", "LOP_U_AM_Fatigue_02_5", "LOP_U_AM_Fatigue_02_6", 
					"LOP_U_AM_Fatigue_01", "LOP_U_AM_Fatigue_01_2", "LOP_U_AM_Fatigue_01_3", "LOP_U_AM_Fatigue_01_4", "LOP_U_AM_Fatigue_01_5", "LOP_U_AM_Fatigue_01_6"
				];
				_allHeadGear append [
					"LOP_H_Pakol", "LOP_H_Shemag_BLK", "LOP_H_Shemag_BLU", "LOP_H_Shemag_OLV", "LOP_H_Shemag_TAN", "LOP_H_Turban_mask"
				];
				_addVest = false;
				_LeeEnfield = ["LOP_Weap_LeeEnfield", "LOP_10rnd_77mm_mag"];
				_FNFal = ["rhs_weap_svds", "rhs_10Rnd_762x54mmR_7N1"];
			};
		};
		if ADF_mod_CFP exitWith {
			_AKM = selectRandom [["CUP_arifle_AKM_Early", "CUP_30Rnd_762x39_AK47_bakelite_M"], ["CUP_arifle_AKMS_Early", "CUP_30Rnd_762x39_AK47_bakelite_M"]];
			_AKMGP = selectRandom [["CUP_arifle_AKM_GL_Early", "CUP_30Rnd_762x39_AK47_bakelite_M"], ["CUP_arifle_AKMS_GL_Early", "CUP_30Rnd_762x39_AK47_bakelite_M"]];
			_AKS74U = selectRandom [["CUP_arifle_AKS74U", "CUP_30Rnd_545x39_AK74_plum_M"], ["CUP_arifle_AKS74", "CUP_30Rnd_545x39_AK_M"]];
			_ASVAL = ["CUP_arifle_AS_VAL", "CUP_20Rnd_9x39_SP5_VSS_M"];
			_PKP = ["CUP_lmg_Pecheneg", "CUP_100Rnd_TE4_LRT4_762x54_PK_Tracer_Green_M"];
			_PKM = ["CUP_arifle_RPK74", "CUP_75Rnd_TE4_LRT4_Green_Tracer_762x39_RPK_M"];
			_SVD = ["CUP_srifle_SVD", "CUP_10Rnd_762x54_SVD_M"];
			_FNFal = ["CUP_arifle_FNFAL5061_wooden", "CUP_20Rnd_762x51_FNFAL_M"];
			_LeeEnfield = ["CUP_srifle_Mosin_Nagant", "CUP_5Rnd_762x54_Mosin_M"];
			
			_allUniforms append [
				"CFP_U_KhetPartug_Long_Purple", "CFP_U_KhetPartug_Long_olive", "CFP_U_KhetPartug_Long_light_olive", "CFP_U_KhetPartug_Long_Grey", "CUP_O_TKI_Khet_Partug_01", "CFP_U_KhetPartug_Long_Creme", "CFP_U_KhetPartug_Long_Brown", "CUP_O_TKI_Khet_Partug_02", "CFP_U_KhetPartug_Long_BlueGrey", "CFP_U_KhetPartug_Long_Blue", "CFP_U_KhetPartug_Long_Black", "CUP_O_TKI_Khet_Partug_04", 
				"CFP_U_KhetPartug_Short_White", "CFP_U_KhetPartug_Short_Tan", "CFP_U_KhetPartug_Short_light_olive", "CUP_O_TKI_Khet_Partug_06", "CFP_U_KhetPartug_Short_Creme", "CUP_O_TKI_Khet_Partug_05", "CUP_O_TKI_Khet_Partug_08", "CFP_U_KhetPartug_Short_BlueGrey", "CUP_O_TKI_Khet_Partug_07", "CFP_U_KhetPartug_Short_Blue", "CFP_U_KhetPartug_Short_Black", 
				"CUP_U_C_Profiteer_02", "CUP_U_C_Profiteer_04", "CUP_U_C_Profiteer_03"
			];
			_allVests append [
				"CFP_AK_VEST_EDRL", "CFP_AK_VEST_EMR", "CFP_AK_VEST_LOlive", "CFP_AK_VEST_Tan", "CFP_AK_VEST_Olive",
				"CFP_HouthisJacket", 
				"CFP_TakJacket_AfricanWoodland", "CFP_TakJacket_ChocChip", "CFP_TakJacket_DDPM", "CFP_TakJacket_EDRL", "CFP_TakJacket_M81", "CFP_TakJacket_Marpat", "CFP_TakJacket_OD", "CFP_TakJacket_PolygonDesert", "CFP_TakJacket_PolygonWoodland", "CFP_TakJacket_SudanWoodland", "CFP_TakJacket_Woodland",
				"CFP_UtilityJacket_ChocChip", "CFP_UtilityJacket_EDRL", "CFP_UtilityJacket_M81", "CFP_UtilityJacket_PolygonDesert", "CFP_UtilityJacket_PolygonWoodland", "CFP_UtilityJacket_Woodland",
				"CUP_V_O_Ins_Carrier_Rig_Light", "CUP_V_O_Ins_Carrier_Rig_MG", "CUP_V_O_Ins_Carrier_Rig",
				"CUP_V_I_RACS_Carrier_Rig_wdl_3", "CUP_V_I_RACS_Carrier_Rig_2",
				"CUP_V_I_Guerilla_Jacket", "SP_OpforRig1_Black", "SP_OpforRig1_Green",
				"CUP_V_OI_TKI_Jacket2_01", "CUP_V_OI_TKI_Jacket2_02", "CUP_V_OI_TKI_Jacket2_03", "CUP_V_OI_TKI_Jacket2_04", "CUP_V_OI_TKI_Jacket2_05", "CUP_V_OI_TKI_Jacket2_06",
				"CUP_V_OI_TKI_Jacket6_01", "CUP_V_OI_TKI_Jacket6_02", "CUP_V_OI_TKI_Jacket6_03", "CUP_V_OI_TKI_Jacket6_04", "CUP_V_OI_TKI_Jacket6_05", "CUP_V_OI_TKI_Jacket6_06",
				"CUP_V_OI_TKI_Jacket3_01", "CUP_V_OI_TKI_Jacket3_02", "CUP_V_OI_TKI_Jacket3_03", "CUP_V_OI_TKI_Jacket3_04", "CUP_V_OI_TKI_Jacket3_05", "CUP_V_OI_TKI_Jacket3_06",
				"CUP_V_OI_TKI_Jacket5_01", "CUP_V_OI_TKI_Jacket5_02", "CUP_V_OI_TKI_Jacket5_03", "CUP_V_OI_TKI_Jacket5_04", "CUP_V_OI_TKI_Jacket5_05", "CUP_V_OI_TKI_Jacket5_06",
				"CUP_V_OI_TKI_Jacket4_01", "CUP_V_OI_TKI_Jacket4_02", "CUP_V_OI_TKI_Jacket4_03", "CUP_V_OI_TKI_Jacket4_04", "CUP_V_OI_TKI_Jacket4_05", "CUP_V_OI_TKI_Jacket4_06",
				"CUP_V_OI_TKI_Jacket1_03", "CUP_V_OI_TKI_Jacket1_02", "CUP_V_OI_TKI_Jacket1_03", "CUP_V_OI_TKI_Jacket1_04", "CUP_V_OI_TKI_Jacket1_05", "CUP_V_OI_TKI_Jacket1_06"
			];
			_allHeadGear append [
				"CFP_Lungee_BlueGrey", "CFP_Lungee_Brown", "CFP_Lungee_Grey", "CFP_Lungee_M81", "CFP_Lungee_Tan",
				"CFP_Lungee_Open_LightOlive", "CFP_Lungee_Open_M81", "CFP_Lungee_Open_Tan", "CFP_Lungee_Open_Creme", "CFP_Lungee_Open_Brown", "CFP_Lungee_Open_Blue", "CFP_Lungee_Open_BlueGrey",
				"CFP_Lungee_Shemagh_Yellow", "CFP_Lungee_Shemagh_White", "CFP_Lungee_Shemagh", "CFP_Lungee_Shemagh_Olive", "CFP_Lungee_Shemagh_M81", "CFP_Lungee_Shemagh_Grey", "CFP_Lungee_Shemagh_Green", "CFP_Lungee_Shemagh_BlueGrey", "CFP_Lungee_Shemagh_Black",
				"CFP_Shemagh_Full_Red", "CFP_Shemagh_Full_Tan", "CFP_Shemagh_Full_White", "CFP_Shemagh_Full_Green", "CFP_Shemagh_Full_Creme",
				"SP_Shemagh_Tan", "SP_Shemagh_Grey", "SP_Shemagh_Green", "SP_Shemagh_CheckWhite", "SP_Shemagh_CheckTan", "SP_Shemagh_CheckRed", "SP_Shemagh_CheckGreen", "SP_Shemagh_CheckBlue", "SP_Shemagh_CheckBlack", "SP_Shemagh_Black",
				"CUP_H_TKI_Pakol_1_01", "CUP_H_TKI_Pakol_1_02", "CUP_H_TKI_Pakol_1_03", "CUP_H_TKI_Pakol_1_04", "CUP_H_TKI_Pakol_1_05", "CUP_H_TKI_Pakol_1_06",
				"CUP_H_TKI_Pakol_2_01", "CUP_H_TKI_Pakol_2_02", "CUP_H_TKI_Pakol_2_03", "CUP_H_TKI_Pakol_2_04", "CUP_H_TKI_Pakol_2_05", "CUP_H_TKI_Pakol_2_06", 
				"CUP_H_TKI_SkullCap_01", "CUP_H_TKI_SkullCap_02", "CUP_H_TKI_SkullCap_03", "CUP_H_TKI_SkullCap_04", "CUP_H_TKI_SkullCap_05", "CUP_H_TKI_SkullCap_06"
			];
			_backpackHeavy append ["CUP_B_AlicePack_Khaki", "CFP_Kitbag_Drab"];
			_backpackLight append ["CFP_FieldPack_ATACSAU"];
		};
	};
	_allUniforms call BIS_fnc_arrayShuffle;
	_allHeadGear call BIS_fnc_arrayShuffle;
	_unit forceAddUniform (selectRandom _allUniforms);

	// Add vest
	if (_addVest) then {_unit addVest (selectRandom _allVests);};
	
	// Add head gear
	if ((random 100) < 65) then {
		_unit addHeadgear (selectRandom _allHeadGear);
	};	
	
	// Facegear
	if ((random 100) < 75) then {
		_unit addGoggles (selectRandom ADF_civilian_facewear);
	};		
	
	// Pri weapon
	private _allWeapons = selectRandom [
		[_akm # 0, _akm # 1], [_akm # 0, _akm # 1], [_akm # 0, _akm # 1], [_akm # 0, _akm # 1], 
		[_FNFal # 0, _FNFal # 1], [_FNFal # 0, _FNFal # 1],
		[_AKMGP # 0, _AKMGP # 1], [_AKMGP # 0, _AKMGP # 1], 
		[_AKS74U # 0, _AKS74U # 1], [_AKS74U # 0, _AKS74U # 1], 
		[_LeeEnfield # 0, _LeeEnfield # 1],
		[_LeeEnfield # 0, _LeeEnfield # 1],
		[_ASVAL # 0 , _ASVAL # 1], [_ASVAL # 0 , _ASVAL # 1],
		[_PKM # 0, _PKM # 1],
		[_PKP # 0, _PKP # 1],
		[_SVD # 0, _SVD # 1]
	];
	private _priWeapon = _allWeapons # 0;	
	private _priWeaponMag = _allWeapons # 1;
	
	if (_role == "O_medic_F" || _role == "O_recon_medic_F") then {
		if ADF_mod_RHS then {_unit addBackpack "rhs_medic_bag"} else {_unit addBackpack "CUP_B_SLA_Medicbag"};
		for "_i" from 1 to 5 do {
			_unit addMagazine "SmokeShellGreen";
			_unit addItem "FirstAidKit";
		};
		_unit addItem "Medikit";
		_unit addMagazine (_AKS74U # 1);
		_unit addWeapon (_AKS74U # 0);
	} else {
		_unit addMagazine _priWeaponMag;	
		_unit addWeapon _priWeapon;
		if (random 100 > 75) then {_unit addBackpack (selectRandom _backpackLight)};
	};
		
	switch _priWeapon do {
		case (_PKP # 0);		
		case (_PKM # 0): {		
			_unit addBackpack (selectRandom _backpackHeavy);
			_unit addMagazines [_priWeaponMag, 2];
		};
		case (_SVD # 0): {
			_unit addMagazines [_priWeaponMag, 4];
			if ADF_mod_RHS then {_unit addPrimaryWeaponItem "rhs_acc_pso1m21"} else {_unit addPrimaryWeaponItem "CUP_optic_PSO_1_1_open"};
		};
		case (_FNFal # 0);
		case (_ASVAL # 0);
		case (_LeeEnfield # 0): {
			_unit addMagazines [_priWeaponMag, 4];
		};
		case (_AKMGP # 0): {
			_unit addMagazines [_priWeaponMag, 3];
			private _he = ["CUP_1Rnd_HE_GP25_M", "rhs_VOG25"] select ADF_mod_RHS;
			for "_i" from 1 to 5 do {_unit addItem _he;};
		};
		case (_AKS74U # 0): {
			_unit addMagazines [_priWeaponMag, 5];
			if ADF_mod_RHS then {
				_unit addBackpack "rhs_rpg_empty";
				if ((random 1) > 0.20) then {
					// AT					
					[_unit, "rhs_weap_rpg7", 1, "rhs_rpg7_PG7VL_mag"] call BIS_fnc_addWeapon;
					_unit addSecondaryWeaponItem "rhs_acc_pgo7v3";
					_unit addItemToBackpack "rhs_rpg7_PG7VL_mag";
					_unit addItemToBackpack "rhs_rpg7_PG7VL_mag";
				} else {
					// AA
					[_unit, "rhs_weap_igla", 2, "rhs_mag_9k38_rocket"] call BIS_fnc_addWeapon;
				};
			} else {
				_unit addBackpack (selectRandom ["CFP_RPGPack_Grey", "CFP_RPGPack_Khaki", "CFP_RPGPack_Black"]);
				if ((random 1) > 0.20) then {
					// AT					
					[_unit, "CUP_launch_RPG7V", 1, "CUP_PG7V_M"] call BIS_fnc_addWeapon;
					_unit addSecondaryWeaponItem "CUP_optic_PGO7V";
					_unit addItemToBackpack "CUP_PG7V_M";
					_unit addItemToBackpack "CUP_PG7V_M";
				} else {
					// AA
					[_unit, "CUP_launch_Igla", 2] call BIS_fnc_addWeapon;
				};
			};
		};
		default {
			_unit addMagazines [_priWeaponMag, 6];
			if (random 100 > 10) then {
				_unit addBackpack (selectRandom _backpackLight);
				_unit addMagazine "SmokeShell";
				_unit addMagazine "SmokeShell";
			};
		};	
	};	

	_unit addItem "FirstAidKit";
	_unit addMagazine "SmokeShell";
	
	// Weapon light
	if (((date select 3) < 5) && ((date select 3) > 19) && (random 1 < 0.33)) then {_unit enableGunLights "forceOn"};
	
	// Add intel
	[_unit, [], true, 10, "", "COIN_fnc_intelFound"] call ADF_fnc_searchIntel;
	
	// Misc
	_unit allowDamage true; // hack ADF 2.22

	true
};

ADF_fnc_redressArmy_inf = {
	// init
	params ["_unit"];
	private _role = typeOf _unit;

	// Strip the unit
	[_unit, true] call ADF_fnc_stripUnit;
	
	// Add containers
	private _backpack = [];
	private _faceWear = ["G_Aviator", "G_Lowprofile", "G_Sport_Blackred", "G_Sport_Greenblack", "G_Spectacles_Tinted"];
	call {
		if ADF_mod_RHS exitWith {
			_backpack append ["B_AssaultPack_khk", "B_Kitbag_sgg"];
			_faceWear = ["rhs_scarf", "G_Bandanna_khk", "rhsusf_shemagh_gogg_white", "rhsusf_shemagh_gogg_tan"];
			if (ADF_mod_3CB_FACT && ADF_mod_PROPFOR) exitWith {
				_unit forceAddUniform "LOP_U_TKA_Fatigue_01";
				_unit addHeadgear "LOP_H_SSh68Helmet_TAN";
			};
			if ADF_mod_3CB_FACT exitWith {
				_unit forceAddUniform "UK3CB_TKA_I_U_CombatUniform_01_OLI";
				_unit addHeadgear "UK3CB_TKA_I_H_SSh68_Khk";
			};			
			if ADF_mod_PROPFOR exitWith {
				_unit forceAddUniform "LOP_U_TKA_Fatigue_01";
				_unit addHeadgear "LOP_H_SSh68Helmet_TAN";
			};
		};		
		_unit forceAddUniform "CUP_U_O_TK_Green";
		_unit addHeadgear selectRandom ["CUP_H_SLA_Helmet_DES", "CUP_H_SLA_Helmet_DES_worn"];		
		_backpack append ["B_FieldPack_cbr", "B_Kitbag_cbr", "CUP_B_USPack_Coyote"];
		_faceWear = [
			"CFP_Beard", "CFP_Beard_Grey", "CFP_Beard_red",
			"CFP_Neck_Plain_Atacs", "CFP_Neck_Plain_Atacs2", "CFP_Neck_Plain2", "CFP_Neck_Plain3", "CFP_Neck_Plain4",
			"CFP_Neck_Wrap2", "CFP_Neck_Wrap4", "CFP_Neck_Wrap3",
			"CFP_Scarfbeard_grey", "CFP_Scarfbeard_tan", "CFP_Scarfbeard_white", "CFP_Scarfbeard_green", "CFP_Scarfbeard_grey",
			"CFP_Shemagh_Neck_Creme", "CFP_Shemagh_Neck_Gold", "CFP_Shemagh_Neck_M81",
			"CUP_G_ESS_BLK_Scarf_Blk", "CUP_G_ESS_BLK_Scarf_Grn", "CUP_G_ESS_BLK_Scarf_Red", "CUP_G_ESS_BLK_Scarf_Tan", "CUP_G_ESS_BLK_Scarf_White",
			"CUP_G_Scarf_Face_Red", "CUP_G_Scarf_Face_Tan", "CUP_G_Scarf_Face_White",
			"CUP_G_Oakleys_Embr",
			"CUP_G_Grn_Scarf_Shades", "CUP_G_Tan_Scarf_Shades", "CUP_FR_NeckScarf5"
		];
	};	
	
	// Primary weapon
	private _akm = [];
	private _akm_gp25 = [];
	private _aks74u = [];
	private _pkm = [];
	private _pkp = [];
	private _svd = [];	
	if ADF_mod_RHS then {
		_akm = ["rhs_weap_akm", "rhs_30Rnd_762x39mm"];
		_akm_gp25 = ["rhs_weap_akm_gp25", "rhs_30Rnd_762x39mm"];
		_aks74u = ["rhs_weap_aks74u", "rhs_30Rnd_545x39_AK"];
		_pkm = ["rhs_weap_pkm", "rhs_100Rnd_762x54mmR"];
		_pkp = ["rhs_weap_pkp", "rhs_100Rnd_762x54mmR"];
		_svd = ["rhs_weap_svdp_wd", "rhs_10Rnd_762x54mmR_7N1"];		
	} else {
		_akm = ["CUP_arifle_AKM", "CUP_30Rnd_762x39_AK47_bakelite_M"];
		_akm_gp25 = ["CUP_arifle_AKM_GL", "CUP_30Rnd_762x39_AK47_bakelite_M"];
		_aks74u = ["CUP_arifle_AKS74U", "CUP_30Rnd_545x39_AK74_plum_M"];
		_pkm = ["CUP_lmg_PKMN", "CUP_100Rnd_TE4_LRT4_762x54_PK_Tracer_Green_M"];
		_pkp = ["CUP_lmg_Pecheneg_desert", "CUP_100Rnd_TE4_LRT4_762x54_PK_Tracer_Green_M"];
		_svd = ["CUP_srifle_SVD_wdl_top_rail", "CUP_10Rnd_762x54_SVD_M"];	
	};
	
	private _allWeapons = selectRandom [
		[_akm_gp25 # 0, _akm # 1], [_akm_gp25 # 0, _akm # 1], 
		[_pkm # 0, _pkp # 1], [_pkp # 0, _pkp # 1], 		
		[_akm # 0, _akm # 1], [_akm # 0, _akm # 1], [_akm # 0, _akm # 1], [_akm # 0, _akm # 1], 
		[_akm_gp25 # 0, _akm # 1], 		
		[_akm # 0, _akm # 1], [_akm # 0, _akm # 1], [_akm # 0, _akm # 1], [_akm # 0, _akm # 1], 
		[_svd # 0, _svd # 1], 		
		[_pkm # 0, _pkp # 1]		
	];
	private _priWeapon = _allWeapons # 0;	
	private _priWeaponMag = _allWeapons # 1;
	
	if (_role == "O_medic_F" || _role == "O_recon_medic_F") then {
		if ADF_mod_RHS then {_unit addVest "rhs_6b5_medic_khaki"} else {_unit addVest "SP_OpforRig1_Tan"};
		for "_i" from 1 to 5 do {
			_unit addMagazine "SmokeShellGreen";
			_unit addItem "FirstAidKit";
		};
		_unit addItem "Medikit";
		_unit addMagazine (_aks74u # 1);
		_unit addWeapon (_aks74u # 0);
	} else {
		if (_priWeapon == (_akm_gp25 # 0)) then {
			if ADF_mod_RHS then {_unit addVest "rhs_6b5_sniper_khaki"} else {_unit addVest "CUP_V_O_SLA_M23_1_BRN"};
		} else {
			if ADF_mod_RHS then {_unit addVest "rhs_6b5_rifleman_khaki"} else {_unit addVest "CUP_V_O_TK_Vest_2"};
		};
		_unit addMagazine _priWeaponMag;	
		_unit addWeapon _priWeapon;
	};
		
	switch _priWeapon do {
		case (_pkp # 0);	
		case (_pkm # 0): {		
			_unit addBackpack (selectRandom _backpack);
			_unit addMagazines [_priWeaponMag, 2];
			_unit addGoggles "G_Combat";		
		};
		case (_svd # 0): {
			_unit addMagazines [_priWeaponMag, 4];
			if ADF_mod_RHS then {_unit addPrimaryWeaponItem "rhs_acc_pso1m21"} else {_unit addPrimaryWeaponItem "CUP_optic_PSO_1_1_open"};	
			_unit addGoggles (selectRandom _faceWear);				
		};
		default {
			_unit addMagazines [_priWeaponMag, 6];

			// GL
			if (_priWeapon == _akm_gp25 # 0) then {
				private _he = ["CUP_1Rnd_HE_GP25_M", "rhs_VOG25"] select ADF_mod_RHS;
				for "_i" from 1 to 5 do {_unit addItem _he;};
			};
			
			// Add Launcher?
			if ((random 100) > 35) then {				
				if ((random 100) > 35 && {_priWeapon == _akm # 0}) then { // AT					
					_unit addBackpack (selectRandom _backpack);
					if ((random 100) > 25) then {
						private _at = [["CUP_launch_RPG7V", "CUP_PG7V_M", "CUP_optic_PGO7V"], ["rhs_weap_rpg7", "rhs_rpg7_PG7VL_mag", "rhs_acc_pgo7v3"]] select ADF_mod_RHS;
						[_unit, _at # 0, 1, _at # 1] call BIS_fnc_addWeapon;
						_unit addSecondaryWeaponItem (_at # 2);
						_unit addItemToBackpack (_at # 1);
						_unit addItemToBackpack (_at # 1);
					} else {
						private _at = [["CUP_launch_MAAWS", "CUP_MAAWS_HEAT_M"], ["launch_MRAWS_olive_rail_F", "MRAWS_HE_F"]] select ADF_mod_RHS;
						[_unit, _at # 0, 2, _at # 1] call BIS_fnc_addWeapon;
					};
				};
			} else {
				// AA
				private _aa = ["CUP_launch_Igla", "rhs_weap_igla"] select ADF_mod_RHS;
				if ((random 100) > 50 && {_priWeapon == (_akm # 0)}) then {
					_unit addBackpack (selectRandom _backpack);
					[_unit, _aa, 2] call BIS_fnc_addWeapon;
				};
			};
			
			if ((backpack _unit) == "") then {if ((random 100) > 75) then {
				_unit addBackpack (selectRandom _backpack);
				for "_i" from 1 to 2 do {					
					_unit addMagazine "HandGrenade";
					_unit addMagazine "SmokeShell";		
				};
			}};
			
			// Facegear
			if ((random 1) > 0.4) then {_unit addGoggles (selectRandom _faceWear)};	
		};	
	};

	// Default items
	_unit linkItem "ItemMap";
	_unit linkItem "ItemCompass";
	
	for "_i" from 1 to 2 do {
		_unit addItem "FirstAidKit";
		_unit addMagazine "HandGrenade";
		_unit addMagazine "SmokeShell";		
	};
	
	// Give leaders NVG & leader kit
	if (rank _unit != "PRIVATE") then {
		_unit linkItem "Binocular";
		_unit linkItem "ItemRadio";
		_unit linkItem "NVGoggles_OPFOR";
		_unit linkItem "ItemWatch";
		_unit linkItem "ItemGPS";
	};
	
	// Weapon light
	if (((date select 3) < 5) && ((date select 3) > 19) && (random 1 < 0.33)) then {_unit enableGunLights "forceOn"};
	
	// Add intel
	[_unit, [], true, 10, "", "COIN_fnc_intelFound"] call ADF_fnc_searchIntel;
	
	// Misc
	_unit allowDamage true; // hack ADF 2.22
	
	[_unit, ""] call BIS_fnc_setUnitInsignia;
	[_unit, "TKA1"] call BIS_fnc_setUnitInsignia;
	true
};

ADF_fnc_redressArmy_crew = {
	// init
	params ["_unit"];

	// Strip the unit
	[_unit, true] call ADF_fnc_stripUnit;
	
	// Add Uniform container
	if ADF_mod_RHS then {
		_unit forceAddUniform "rhs_uniform_gorka_r_y";	
		_unit addVest "rhsgref_otv_khaki";	
		_unit addHeadgear "rhs_tsh4_ess";	

		_unit addMagazine ["rhs_30Rnd_545x39_AK", 30];
		_unit addWeapon "rhs_weap_aks74u";
		_unit addMagazines ["rhs_30Rnd_545x39_AK", 2];
		_unit addPrimaryWeaponItem "rhs_acc_dtk1983";
	} else {
		_unit forceAddUniform "CFP_BDU_OD_Sudan3";	
		_unit addVest "CUP_V_O_TK_CrewBelt";	
		_unit addHeadgear "CUP_H_TK_TankerHelmet";	

		_unit addMagazine ["CUP_30Rnd_545x39_AK_M", 30];
		_unit addWeapon "CUP_arifle_AKS74U";
		_unit addMagazines ["CUP_30Rnd_545x39_AK_M", 2];
	};

	// Crew kit default items
	_unit linkItem "ItemMap";
	_unit linkItem "ItemCompass";
	_unit linkItem "NVGoggles_OPFOR";
	_unit linkItem "ItemGPS";
	_unit linkItem "ItemRadio";
	for "_i" from 1 to 2 do {
		_unit addItem "FirstAidKit";
		_unit addMagazine "HandGrenade";
		_unit addMagazine "SmokeShell";		
	};
	
	// NVG & leader kit
	_unit addWeapon "Rangefinder";		
	_unit linkItem "ItemWatch";
	
	// Weapon light
	if (((date select 3) < 5) && ((date select 3) > 19) && (random 1 < 0.33)) then {_unit enableGunLights "forceOn"};
	
	// Add intel
	[_unit, [], true, 10, "", "COIN_fnc_intelFound"] call ADF_fnc_searchIntel;
		
	// Misc
	_unit allowDamage true; // hack ADF 2.22	
	[_unit, ""] call BIS_fnc_setUnitInsignia;
	[_unit, "TKA1"] call BIS_fnc_setUnitInsignia;
	
	true
};

ADF_fnc_redressArmy_pilot = {
	// init
	params ["_unit"];

	// Strip the unit
	[_unit, true] call ADF_fnc_stripUnit;
	
	// Add Uniform container
	_unit forceAddUniform "U_I_pilotCoveralls";	
	_unit addVest "V_Rangemaster_belt";	
	
	if ADF_mod_RHS then {
		_unit addHeadgear "rhs_zsh7a_mike_green";	
		
		_unit addMagazine ["rhs_mag_9x18_8_57N181S", 16];
		_unit addWeapon "rhs_weap_makarov_pm";
		_unit addMagazines ["rhs_30Rnd_545x39_AK", 2];	
	} else {
		_unit addHeadgear "CUP_H_TK_PilotHelmet";	
		
		_unit addMagazine ["CUP_8Rnd_9x18_Makarov_M", 16];
		_unit addWeapon "CUP_hgun_Makarov";
		_unit addMagazines ["CUP_8Rnd_9x18_Makarov_M", 2];		
	};

	// Crew kit default items
	_unit linkItem "ItemMap";
	_unit linkItem "ItemCompass";
	_unit linkItem "NVGoggles_OPFOR";
	_unit linkItem "ItemGPS";
	_unit linkItem "ItemRadio";
	_unit linkItem "ItemWatch";	
	for "_i" from 1 to 2 do {
		_unit addItem "FirstAidKit";
		_unit addMagazine "SmokeShell";		
	};
	
	// Add intel
	[_unit, [], true, 10, "", "COIN_fnc_intelFound"] call ADF_fnc_searchIntel;
			
	// Misc
	_unit allowDamage true; // hack ADF 2.22	
	
	[_unit, ""] call BIS_fnc_setUnitInsignia;
	[_unit, "TKA1"] call BIS_fnc_setUnitInsignia;
	true
};