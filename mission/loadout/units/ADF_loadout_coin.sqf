/*********************************************************************************
 _____ ____  _____ 
|  _  |    \|   __|
|     |  |  |   __|
|__|__|____/|__|   
ARMA Mission Development Framework
ADF version: 2.26 / Jul 2020

Script: Loadout & Gear C O I N
Author: Whiztler
Script version: 1.00

Game type: COOP
File: ADF_loadout_coin.sqf
*********************************************************************************
Used exclusively for COIN missions. CUP -or- RHS loadout
*********************************************************************************/

diag_log format ["ADF rpt: Init - executing: ADF_loadout_twosierra.sqf for %1", _this]; // Reporting. Do NOT edit/remove

/********* INIT ********/

tf_no_auto_long_range_radio = false;
private _unit = _this;
private _role = toLower (((str _unit) splitString "_") select 1);

// Primary weapon
private _primaryWeapon = "arifle_MX_Black_Hamr_pointer_F";
private _primaryWeapon_lite = "arifle_MXC_Black_F";
private _primaryWeapon_GL = "arifle_MX_GL_Black_Hamr_pointer_F";
private _primaryWeapon_LMG = "LMG_Mk200_MRCO_F";
private _primaryWeapon_MG = "MMG_02_black_RCO_BI_F";
private _handWeapon = "hgun_P07_F";
private _tube_Lite = "launch_NLAW_F";
private _tube_AT = "launch_B_Titan_short_F";
private _tube_AA = "launch_B_Titan_F";

// Attachments
private _primaryWeaponAttScope = "optic_Aco";
if (_unit == leader (group _unit)) then {_primaryWeaponAttScope = "optic_MRCO"};
private _primaryWeaponAttScope_LMG = "optic_MRCO";
private _primaryWeaponAttLight = "acc_pointer_IR";
private _primaryWeaponAttLight_LMG = "acc_pointer_IR";

// Ammunition
private _primaryWeaponMag = "30Rnd_65x39_caseless_mag";
private _primaryWeaponMag_LMG = "200Rnd_65x39_cased_Box_Tracer";
private _primaryWeaponMag_MG = "130Rnd_338_Mag";

private _handWeapon_mag = "16Rnd_9x21_Mag";
private _tubeMag_Lite = "NLAW_F";
private _tubeMag_AT = "Titan_AT";
private _tubeMag_AA = "Titan_AA";
private _40mike = "1Rnd_HE_Grenade_shell";
private _handgrenade = "HandGrenade";

// Radios
private _TFAR_PersonalRadio = "tf_rf7800str";
private _TFAR_SWRadio = "tf_anprc152";
private _TFAR_LRRadio = "tf_rt1523g_big_rhs";

// Misc
private _microDAGR = "Chemlight_green"; // in case of no ACE3 or cTAB

// Default ACE3 kit
private _ACE3_kit = ["ACE_EarPlugs", "ace_mapTools", "ACE_CableTie", "ACE_IR_Strobe_Item", "ACE_morphine", "ACE_HandFlare_White", "ACE_HandFlare_White", "ACE_M84", "ACE_M84"];
private _ACE3_medikit = ["ACE_fieldDressing", "ACE_elasticBandage", "ACE_quikclot", "ACE_fieldDressing", "ACE_elasticBandage", "ACE_quikclot", "ACE_fieldDressing", "ACE_elasticBandage", "ACE_quikclot"];
								
// Strip the unit
[_unit, true] call ADF_fnc_stripUnit;

// Default kit
private _uniform = "";
private _nvg = "NVGoggles_OPFOR";
private _vest = ["V_TacVest_khk", "V_TacVest_brn"];
private _headGear = ["H_HelmetSpecB_paint2", "H_HelmetB_sand", "H_HelmetB_desert"];
private _backpack = ["B_AssaultPack_cbr"];
private _backpack_medium = ["B_FieldPack_cbr"];
private _backpack_large = ["B_Kitbag_cbr"];
private _backpack_heavy = ["B_Carryall_cbr"];
private _faceWear = ["G_Tactical_Clear"];

if (toUpper worldName == "CHERNARUS_SUMMER" || toUpper worldName == "WOODLAND_ACR") then {
	_headGear = ["H_HelmetSpecB", "H_HelmetB", "H_HelmetSpecB_blk"];
	_vest = ["V_TacVest_oli", "V_TacVest_brn"];
	_backpack = ["B_AssaultPack_rgr"];
	_backpack_large = ["B_Kitbag_rgr"];
	_backpack = ["B_TacticalPack_blk"];
	_backpack_heavy = ["B_Carryall_oli"];
	_backpack_medium = ["B_FieldPack_oli"];	
};

// MODDED CONTAINERS
if (ADF_modded || {ADF_mod_RHS}) then {
	call {
		if ADF_mod_RHS exitWith {
			if (toUpper worldName == "CHERNARUS_SUMMER" || toUpper worldName == "WOODLAND_ACR") then {
				_uniform = "rhs_uniform_g3_m81";
				_headGear append ["rhsusf_mich_helmet_marpatwd", "rhsusf_mich_helmet_marpatwd_norotos_arc", "rhsusf_mich_helmet_marpatwd_norotos_arc_headset"];
			} else {
				_uniform = "rhs_uniform_g3_mc";					
				_headGear append ["rhsusf_mich_bare_norotos_arc_semi_headset", "rhsusf_mich_bare_norotos_arc_semi", "rhsusf_mich_bare_norotos_arc_alt_tan_headset"];
			};
			_vest append ["rhsusf_iotv_ocp_Rifleman", "rhsusf_iotv_ocp_Teamleader", "rhsusf_iotv_ocp_Squadleader", "rhsusf_mbav_rifleman", "rhsusf_spcs_ocp_rifleman"];
			_faceWear append ["rhs_googles_black", "rhs_googles_clear", "rhs_googles_yellow", "rhsusf_shemagh_tan", "rhsusf_shemagh_grn", "rhsusf_shemagh_gogg_tan", "rhsusf_shemagh_gogg_od", "rhsusf_oakley_goggles_blk", "rhsusf_oakley_goggles_ylw"];
			_nvg = "rhsusf_ANPVS_15";
			if ADF_mod_3CB_FACT then {
				_faceWear append ["UK3CB_G_Neck_Shemag", "UK3CB_G_Neck_Shemag_Tan", "UK3CB_G_Neck_Shemag_Oli"];
				_vest append ["UK3CB_ANP_B_V_GA_LITE_TAN", "UK3CB_TKA_B_V_GA_HEAVY_DES_MARPAT", "UK3CB_ANP_B_V_GA_HEAVY_TAN", "UK3CB_TKA_B_V_GA_LITE_DES_MARPAT"];
				_backpack append ["UK3CB_ANA_B_B_ASS", "UK3CB_TKA_B_B_ASS"];
				_backpack_medium append ["UK3CB_UN_B_B_RIF"];
				_backpack_large append ["UK3CB_TKA_B_B_RIF", "UK3CB_TKA_O_B_ENG_Tan", "UK3CB_TKA_O_B_RIF_Tan"];
				_backpack_heavy append [""];				
			};
			if ADF_mod_PROPFOR then {
				_vest append ["LOP_V_CarrierLite_TAN", "LOP_V_CarrierRig_TAN", "LOP_V_CarrierRig_WDL", "LOP_V_CarrierLite_WDL"];
			};			

			// Primary weapon - RHS
			_primaryWeapon = "rhs_weap_hk416d145";
			_primaryWeapon_lite = "rhs_weap_hk416d10_LMT";			
			_primaryWeapon_GL = "rhs_weap_hk416d145_m320";
			_primaryWeapon_LMG = "rhs_weap_m249_pip_S";
			_handWeapon = "rhsusf_weap_m1911a1";
			_tube_Lite = "rhs_weap_M136";
			_tube_AT = "rhs_weap_fgm148";
			//_tube_AT = "rhs_weap_smaw_green";
			_tube_AA = "rhs_weap_fim92";

			// Attachments _ RHS
			if (_unit == leader (group _unit)) then {_primaryWeaponAttScope = "rhsusf_acc_ACOG2"} else {_primaryWeaponAttScope = "rhsusf_acc_eotech_552"};
			_primaryWeaponAttScope_LMG = "rhsusf_acc_ACOG2_USMC";
			_primaryWeaponAttLight = "rhsusf_acc_anpeq15_bk";
			_primaryWeaponAttLight_LMG = "rhsusf_acc_anpeq15side_bk";

			// Ammunition - RHS
			_primaryWeaponMag = "rhs_mag_30Rnd_556x45_M855A1_Stanag";
			_primaryWeaponMag_LMG = "rhsusf_200Rnd_556x45_box";
			_handWeapon_mag = "rhsusf_mag_7x45acp_MHP";
			_tubeMag_Lite = "rhs_m136_mag";
			_tubeMag_AT = "rhs_fgm148_magazine_AT";
			_tubeMag_AA = "rhs_fim92_mag";
			_40mike = "rhs_mag_M441_HE";
			_handgrenade = "rhs_mag_m67";			

		};
		if ADF_mod_CUP_U exitWith {
			_faceWear append [
				"CUP_FR_NeckScarf4", "CUP_FR_NeckScarf2", "CUP_FR_NeckScarf", "CUP_TK_NeckScarf", 
				"CUP_G_PMC_RadioHeadset_Glasses_Dark", "CUP_G_PMC_RadioHeadset_Glasses", "CUP_G_PMC_RadioHeadset",
				"G_Tactical_Clear", "G_Tactical_Clear", "G_Tactical_Clear"
			];
		
			// Primary weapon - CUP
			_primaryWeapon = "CUP_arifle_HK416_Black";
			_primaryWeapon_lite = "CUP_arifle_HK416_CQB_Black";			
			_primaryWeapon_GL = "CUP_arifle_HK416_CQB_M203_Black";
			_primaryWeapon_LMG = "CUP_lmg_minimi";
			_handWeapon = "CUP_hgun_Colt1911";
			_tube_Lite = "CUP_launch_Mk153Mod0";
			_tube_AT = "CUP_launch_Javelin";
			_tube_AA = "CUP_launch_FIM92Stinger";

			// Attachments _ CUP
			if (_unit == leader (group _unit)) then {_primaryWeaponAttScope = "CUP_optic_RCO"} else {_primaryWeaponAttScope = "CUP_optic_TrijiconRx01_black"};
			_primaryWeaponAttScope_LMG = "CUP_optic_ACOG2";
			_primaryWeaponAttLight = "CUP_acc_ANPEQ_15_Flashlight_Black_L";
			_primaryWeaponAttLight_LMG = "CUP_acc_ANPEQ_2";

			// Ammunition - CUP
			_primaryWeaponMag = "CUP_30Rnd_556x45_PMAG_QP";
			_primaryWeaponMag_LMG = "CUP_200Rnd_TE4_Red_Tracer_556x45_M249";

			_handWeapon_mag = "CUP_7Rnd_45ACP_1911";
			_tubeMag_Lite = "CUP_SMAW_HEAA_M";
			_tubeMag_AT = "Chemlight_green";
			_tubeMag_AA = "Chemlight_green";
			_40mike = "1Rnd_HE_Grenade_shell";
			_handgrenade = "CUP_HandGrenade_M67";
			
			_vest append ["CUP_V_B_Interceptor_Grenadier_Coyote", "CUP_V_B_Interceptor_Rifleman_Coyote", "CUP_V_B_Interceptor_Grenadier_M81", "CUP_V_B_Interceptor_Rifleman_M81", "CUP_V_B_Interceptor_Grenadier_Olive", "CUP_V_B_Interceptor_Rifleman_Olive"];
			_backpack append ["CUP_B_Kombat_Olive", "CUP_B_USMC_AssaultPack"];
			_backpack_medium append ["CUP_B_Motherlode_MTP"];
			_backpack_large append ["CUP_B_USPack_Coyote"];
			
			if ADF_mod_CFP exitWith {
				_nvg = "CFP_ANPVS15_Black";	
				_vest append ["CFP_ITV_Rifleman_Brown", "CFP_ITV_Rifleman", "CFP_FAPC_Breacher_M81", "CFP_FAPC_MG_M81", "CFP_FAPC_Operator_M81", "CFP_CarrierRig_Breacher_M81", "CFP_CarrierRig_Gunner_M81", "CFP_CarrierRig_Operator_M81", "CFP_LBT6094_breacher_M81", "CFP_RAV_MG_M81", "CFP_RAV_operator_M81"];
				_backpack append ["CFP_AssaultPack_PolygonDesert", "CFP_AssaultPack_PolygonWoodland"];
				_backpack_medium append ["CFP_Kitbag_Brown", "CFP_Kitbag_M81", "CFP_Kitbag_MCam_Grn", "CFP_Kitbag_Tropentarn"];
				_backpack_large append ["CFP_Carryall_Multicam", "SP_Carryall_Tan"];				
				if (toUpper worldName == "CHERNARUS_SUMMER" || toUpper worldName == "WOODLAND_ACR") then {
					_uniform = "SP_0000_Standard_TacticalUniform_ATacsFG_SS";
				} else {
					_uniform = "CFP_U_Crye_ATacsAU_SS";
				};
			};
			if ADF_mod_CUP_U then {
				_nvg = "CUP_NVG_PVS15_black";			
				if (toUpper worldName == "CHERNARUS_SUMMER" || toUpper worldName == "WOODLAND_ACR") then {
					_uniform =  "CUP_U_O_SLA_MixedCamo";			
				} else {
					_uniform = "CUP_U_O_SLA_Desert";
				};
			};			
		};
	};		
} else {
	_uniform = "U_B_SpecopsUniform_sgg";
	
	// ACE overrides
	if ADF_mod_ACE3 then {
		_primaryWeaponMag = "ACE_30Rnd_65x39_caseless_mag_Tracer_Dim";
		_primaryWeaponMag_LMG = "ACE_200Rnd_65x39_cased_Box_Tracer_Dim";
	};	
};

// Add kit
_unit forceAddUniform _uniform;
_unit addVest (selectRandom _vest);
_unit addHeadgear (selectRandom _headGear);
_unit addWeapon _nvg;
{_unit linkItem _x} forEach ["ItemWatch", "ItemCompass", "ItemMap"];

// MicroDAGR. If no ACE or CtAB than add chemlight
if ADF_mod_ACE3 then {_microDAGR = "ACE_microDAGR"};
if (!ADF_mod_ACE3 && ADF_mod_CTAB) then {_microDAGR = "itemMicroDagr"};

// Hand weapon
for "_i" from 1 to 2 do {_unit addMagazine _handWeapon_mag;};
_unit addWeapon _handWeapon;

private _plt_set = [_unit, _role, _handgrenade, _ACE3_kit, _ACE3_medikit, _TFAR_PersonalRadio, _microDAGR, _primaryWeaponAttScope, _primaryWeaponAttLight, _primaryWeaponAttScope_LMG, _primaryWeaponAttLight_LMG];

// Closing arguments
ADF_loadout_platoon = {
	params [
		"_unit",
		"_role",
		"_handgrenade",
		"_ACE3_kit",
		"_ACE3_medikit",
		"_TFAR_PersonalRadio",
		"_microDAGR",
		"_primaryWeaponAttScope",
		"_primaryWeaponAttLight",
		"_primaryWeaponAttScope_LMG",
		"_primaryWeaponAttLight_LMG"
	];
	
	_unit selectWeapon (primaryWeapon _unit);
	if (isMultiplayer && {ADF_mod_ACE3}) then {_unit setSpeaker "ACE_NoVoice";};
	if ADF_mod_ACE3 then {[_unit, currentWeapon _unit, currentMuzzle _unit] call ACE_SafeMode_fnc_lockSafety;};
	if (ADF_uniformInsignia) then {
		[_unit, ""] call BIS_fnc_setUnitInsignia;
		[_unit, "CLANPATCH"] call BIS_fnc_setUnitInsignia;
	};	
	
	// Misc 
	for "_i" from 1 to 2 do {
		_unit addItem "SmokeShell";
		_unit addItem "Chemlight_green";
		if (!ADF_mod_ACE3) then {
			_unit addItem "FirstAidKit";
			_unit addItem _handgrenade;
		};
	};
	
	// Attachments
	if (ADF_modded || {ADF_mod_RHS}) then {
		if (_role == "ar" || {_role == "mg"}) then {
			_unit addPrimaryWeaponItem _primaryWeaponAttScope_LMG;
			_unit addPrimaryWeaponItem _primaryWeaponAttLight_LMG;		
		} else {
			_unit addPrimaryWeaponItem _primaryWeaponAttScope;
			_unit addPrimaryWeaponItem _primaryWeaponAttLight;
		};
	} else {
		_unit addItem "acc_flashlight";
		_unit addPrimaryWeaponItem "acc_pointer_IR";
	};			
	
	// Add ACE3 default loadout items
	if ADF_mod_ACE3 then {
		for "_i" from 0 to (count _ACE3_kit) do {_unit addItem (_ACE3_kit select _i)};
		for "_i" from 0 to (count _ACE3_medikit) do {_unit addItem (_ACE3_medikit select _i)};
	};

	// cTab
	if ADF_mod_CTAB then {_unit addItemToUniform "ItemcTabHCam"};	

	// Personal Radios all units
	if ADF_mod_ACRE then {_unit addItem "ACRE_PRC343"}; // ACRE
	if ADF_mod_TFAR then {_unit linkItem _TFAR_PersonalRadio; _unit addItem "tf_microdagr";}; // TFAR
	if (!ADF_mod_ACRE && !ADF_mod_TFAR) then {_unit linkItem "ItemRadio"}; // Vanilla
	
	// mircoDAGR
	if (_role == "pc" || _role == "tto" || _role == "sql" || _role == "wtl" || _role == "ftl") then {_unit addItem _microDAGR;};
	
	// Set local Texture
	if (ADF_modded) then {
		ADF_gearLoaded = true;
	} else {
		private _t = if (toUpper worldName == "CHERNARUS_SUMMER" || toUpper worldName == "WOODLAND_ACR") then {"\a3\characters_f\BLUFOR\Data\clothing_wdl_co.paa"} else {"\a3\characters_f\BLUFOR\Data\clothing_sage_co.paa"};
		uniformContainer _unit setVariable ["texture", _t, true];
		player setObjectTextureGlobal [0, _t];
		ADF_gearLoaded = true;	
	};
};


/********* TWO SIERRA UNIT LOADOUT ********/

// Platoon Commander
if (_role == "pc") exitWith {
	_unit linkItem "ItemGPS";
	_unit addGoggles (selectRandom _faceWear);
	_unit addWeapon "Laserdesignator_01_khk_F";
	_unit addItem "Laserbatteries";
	
	// Mod Items
	if ADF_mod_ACRE then {_unit addBackpack (selectRandom _backpack); _unit addItem "ACRE_PRC148"; _unit addItemToBackpack "ACRE_PRC117F";};
	if ADF_mod_TFAR then {_unit addBackpack _TFAR_LRRadio} else {_unit addBackpack (selectRandom _backpack)};	
	if ADF_mod_ACE3 then {_unit addItem "ace_dagr";};
	if ADF_mod_CTAB then {_unit addItem "ItemcTab";};

	// Weapons
	for "_i" from 1 to 5 do {_unit addMagazine _primaryWeaponMag;};
	_unit addWeapon _primaryWeapon_lite;
	
	_plt_set call ADF_loadout_platoon;
};

// Platoon/Squad: RTO
if (_role == "rto") exitWith {
	_unit linkItem "ItemGPS";
	_unit addGoggles (selectRandom _faceWear);
	
	// Bino's	
	if (ADF_modded || {ADF_mod_RHS}) then {
		if ADF_mod_RHS exitWith {_unit addWeapon "rhsusf_bino_lrf_Vector21";};
		_unit addWeapon "CUP_Vector21Nite"; // CUP
	} else {
		if ADF_mod_ACE3 then { _unit addWeapon "ACE_Vector";} else {_unit addWeapon "Rangefinder";};
	};		
	
	// Mod items
	if ADF_mod_ACRE then {_unit addBackpack (selectRandom _backpack); _unit addItem "ACRE_PRC148"; _unit addItemToBackpack "ACRE_PRC117F";};
	if ADF_mod_TFAR then {_unit addBackpack _TFAR_LRRadio};
	if (!ADF_mod_ACRE && !ADF_mod_TFAR) then {_unit addBackpack (selectRandom _backpack);};
	if ADF_mod_ACE3 then {_unit addItem "ace_dagr";};
	if ADF_mod_CTAB then {_unit addItem "ItemAndroid";};	
	
	// Weapons
	for "_i" from 1 to 8 do {_unit addMagazine _primaryWeaponMag;};
	_unit addWeapon _primaryWeapon_lite;

	_plt_set call ADF_loadout_platoon;
};

// Squad: Leader
if (_role == "sql") exitWith {
	_unit linkItem "ItemGPS";
	_unit addGoggles (selectRandom _faceWear);
	
	// Bino's	
	if (ADF_modded || {ADF_mod_RHS}) then {
		if ADF_mod_RHS exitWith {_unit addWeapon "rhsusf_bino_lrf_Vector21";};
		_unit addWeapon "CUP_Vector21Nite"; // CUP
	} else {
		if ADF_mod_ACE3 then { _unit addWeapon "ACE_Vector";} else {_unit addWeapon "Rangefinder";};
	};	
	
	// Mod items
	if ADF_mod_ACRE then {_unit addBackpack (selectRandom _backpack_large); _unit addItemToBackpack "ACRE_PRC148";};
	if ADF_mod_TFAR then {_unit addBackpack _TFAR_LRRadio};
	if (!ADF_mod_ACRE && !ADF_mod_TFAR) then {_unit addBackpack (selectRandom _backpack_large);};	
	if ADF_mod_ACE3 then {_unit addItem "ACE_HuntIR_M203"; _unit addItem "ACE_HuntIR_monitor"; _unit addItem "ace_dagr";};
	if ADF_mod_CTAB then {_unit addItem "ItemAndroid";};
	
	// Weapons
	for "_i" from 1 to 8 do {_unit addMagazine _primaryWeaponMag; _unit addItemToVest _40mike;};
	_unit addWeapon _primaryWeapon_GL;
	
	_plt_set call ADF_loadout_platoon;
};

// Fire Team: Leader
if (_role == "ftl") exitWith {
	_unit linkItem "ItemGPS";
	_unit addGoggles (selectRandom _faceWear);
	
	// Bino's	
	if (ADF_modded || {ADF_mod_RHS}) then {
		if ADF_mod_RHS exitWith {_unit addWeapon "rhsusf_bino_lrf_Vector21";};
		_unit addWeapon "CUP_Vector21Nite"; // CUP
	} else {
		if ADF_mod_ACE3 then { _unit addWeapon "ACE_Vector";} else {_unit addWeapon "Rangefinder";};
	};		
	
	// Mod items
	if ADF_mod_ACRE then {_unit addBackpack (selectRandom _backpack_large); _unit addItemToBackpack "ACRE_PRC148";};
	if ADF_mod_TFAR then {_unit addBackpack _TFAR_LRRadio};
	if (!ADF_mod_ACRE && !ADF_mod_TFAR) then {_unit addBackpack (selectRandom _backpack_large);};	
	if ADF_mod_ACE3 then {_unit addItem "ACE_HuntIR_M203"; _unit addItem "ACE_HuntIR_monitor"; _unit; _unit addItem "ace_dagr";};
	if ADF_mod_CTAB then {_unit addItem "ItemAndroid";};
	
	// Weapons
	for "_i" from 1 to 8 do {_unit addMagazine _primaryWeaponMag; _unit addItemToVest _40mike;};
	_unit addWeapon _primaryWeapon_GL;
	
	_plt_set call ADF_loadout_platoon;
};

// Weapons Team: Leader
if (_role == "wtl") exitWith {
	_unit linkItem "ItemGPS";
	_unit addGoggles (selectRandom _faceWear);
	
	// Bino's	
	if (ADF_modded || {ADF_mod_RHS}) then {
		if ADF_mod_RHS exitWith {_unit addWeapon "rhsusf_bino_lrf_Vector21";};
		_unit addWeapon "CUP_Vector21Nite"; // CUP
	} else {
		if ADF_mod_ACE3 then { _unit addWeapon "ACE_Vector";} else {_unit addWeapon "Rangefinder";};
	};			
	
	// Mod items
	if ADF_mod_ACRE then {_unit addBackpack (selectRandom _backpack_large); _unit addItemToBackpack "ACRE_PRC148";};
	if ADF_mod_TFAR then {_unit addBackpack _TFAR_LRRadio};
	if (!ADF_mod_ACRE && !ADF_mod_TFAR) then {_unit addBackpack (selectRandom _backpack_large);};		
	if ADF_mod_ACE3 then {_unit addItem "ACE_HuntIR_M203"; _unit addItem "ACE_HuntIR_monitor"; _unit addItem "ace_dagr";};
	if ADF_mod_CTAB then {_unit addItem "ItemAndroid";};
	
	// Weapons
	for "_i" from 1 to 8 do {_unit addMagazine _primaryWeaponMag;};
	for "_i" from 1 to 3 do {_unit addItemToVest _40mike;};
	_unit addWeapon _primaryWeapon_GL;
	_unit addMagazine _tubeMag_AA;
	_unit addWeapon _tube_AA;
	
	_plt_set call ADF_loadout_platoon;
};

// Squad: Medic
if (_role == "cls") exitWith {
	_unit linkItem "ItemGPS";
	_unit addBackpack (selectRandom _backpack_heavy);
	_unit addGoggles (selectRandom _faceWear);
	
	// Weapons
	for "_i" from 1 to 8 do {_unit addMagazine _primaryWeaponMag;};
	_unit addWeapon _primaryWeapon;
	for "_i" from 1 to 4 do {_unit addItemToVest "SmokeShell"; _unit addItemToVest "Chemlight_green";};
	
	// ACE3 Medical
	if ADF_mod_ACE3 then { // ACE3 Advanced Medical
		for "_i" from 1 to 10 do {			
			_unit addItemToBackpack "ACE_fieldDressing";
			_unit addItemToBackpack "ACE_elasticBandage";
			_unit addItemToBackpack "ACE_quikclot";
			_unit addItemToBackpack "ACE_atropine";				
		};		
		for "_i" from 1 to 7 do {			
			_unit addItemToBackpack "ACE_morphine";
			_unit addItemToBackpack "ACE_epinephrine";				
			_unit addItemToBackpack "ACE_packingBandage";			
		};
		for "_i" from 1 to 4 do {			
			_unit addItemToBackpack "ACE_salineIV_500";					
			_unit addItemToBackpack "ACE_tourniquet";				
		};
		for "_i" from 1 to 2 do {			
			_unit addItemToBackpack "ACE_bloodIV";				
			_unit addItemToBackpack "ACE_plasmaIV";
			_unit addItemToBackpack "ACE_personalAidKit";
		};
		_unit addItemToBackpack "ACE_surgicalKit";
	} else { // Vanilla
		for "_i" from 1 to 10 do {			
			_unit addItemToBackpack "FirstAidKit";
		};
		_unit addItemToBackpack "Medikit";
	};
	
	_plt_set call ADF_loadout_platoon;
};

// Fire Team: Automatic Rifleman (LMG) 
if (_role == "ar") exitWith {
	_unit addBackpack (selectRandom _backpack_large);
	_unit addGoggles "G_Combat";
	
	for "_i" from 1 to 3 do {_unit addMagazine _primaryWeaponMag_LMG;};
	_unit addWeapon _primaryWeapon_LMG;

	_plt_set call ADF_loadout_platoon;
};

// Fire Team: Asst Automatic Rifleman (LMG)
if (_role == "aar") exitWith {
	_unit addBackpack (selectRandom _backpack_large);
	_unit addGoggles (selectRandom _faceWear);
	
	for "_i" from 1 to 11 do {_unit addMagazine _primaryWeaponMag;};
	_unit addWeapon _primaryWeapon;
	for "_i" from 1 to 3 do {_unit addItemToBackpack _primaryWeaponMag_LMG;};
	
	_plt_set call ADF_loadout_platoon;
};

// Fire Team: Rifleman
if (_role == "r") exitWith {
	_unit addBackpack (selectRandom _backpack);
	_unit addGoggles (selectRandom _faceWear);
	
	for "_i" from 1 to 13 do {_unit addMagazine _primaryWeaponMag;};
	_unit addWeapon _primaryWeapon;

	_plt_set call ADF_loadout_platoon;

};

// Fire Team: Rifleman AT
if (_role == "rat") exitWith {
	_unit addBackpack (selectRandom _backpack_medium);
	_unit addGoggles (selectRandom _faceWear);
	
	for "_i" from 1 to 8 do {_unit addMagazine _primaryWeaponMag;};
	_unit addWeapon _primaryWeapon;
	_unit addMagazine _tubeMag_Lite;
	_unit addWeapon _tube_Lite;
	
	_plt_set call ADF_loadout_platoon;
};

// Weapons Team: Machine Gunner
if (_role == "mg") exitWith {
	_unit addBackpack (selectRandom _backpack_large);
	_unit addGoggles "G_Combat";
	
	for "_i" from 1 to 4 do {_unit addMagazine _primaryWeaponMag_MG;};
	_unit addWeapon _primaryWeapon_MG;
	if ADF_mod_CTAB then {_unit addItem "ItemAndroid";};	
	
	_plt_set call ADF_loadout_platoon;
};

// Weapons Team: Asst. Machinegunner
if (_role == "amg") exitWith {
	_unit addBackpack (selectRandom _backpack_heavy);
	_unit addGoggles (selectRandom _faceWear);
	
	for "_i" from 1 to 8 do {_unit addMagazine _primaryWeaponMag;};
	_unit addWeapon _primaryWeapon_lite;
	for "_i" from 1 to 4 do {_unit addItemToBackpack _primaryWeaponMag_MG;};
	
	_plt_set call ADF_loadout_platoon;
};

// Weapons Team: Missile Specialist
if (_role == "ms") exitWith {
	_unit addBackpack (selectRandom _backpack_large);
	_unit addGoggles (selectRandom _faceWear);
	
	for "_i" from 1 to 5 do {_unit addMagazine _primaryWeaponMag;};
	_unit addWeapon _primaryWeapon_lite;
	_unit addMagazine _tubeMag_AT;
	_unit addItemToBackpack _tubeMag_AT;
	_unit addWeapon _tube_AT;
	if ADF_mod_CTAB then {_unit addItem "ItemAndroid";};	
	
	_plt_set call ADF_loadout_platoon;
};

// Weapons Team: Asst. Missile Specialist
if (_role == "ams") exitWith {
	_unit addBackpack (selectRandom _backpack_heavy);
	_unit addGoggles (selectRandom _faceWear);
	
	for "_i" from 1 to 5 do {_unit addMagazine _primaryWeaponMag;};
	_unit addWeapon _primaryWeapon_lite;
	for "_i" from 1 to 2 do {_unit addItemToBackpack _tubeMag_AT;};
	
	_plt_set call ADF_loadout_platoon;
};

// Weapons Team: HMG specialist
if (_role == "hmg") exitWith {
	if (ADF_modded || {ADF_mod_RHS}) then {
		if (ADF_mod_CFP || {ADF_mod_CUP_U}) exitWith {_unit addBackpack  "CUP_B_M2_Gun_Bag"};
		_unit addBackpack  "RHS_M2_Gun_Bag"
	} else {
		_unit addBackpack "B_HMG_01_weapon_F";
	};
	_unit addGoggles "G_Combat";
	
	for "_i" from 1 to 5 do {_unit addMagazine _primaryWeaponMag;};
	_unit addWeapon _primaryWeapon_lite;
	if ADF_mod_CTAB then {_unit addItem "ItemAndroid";};	
	
	_plt_set call ADF_loadout_platoon;
};

// Weapons Team: Asst. HMG specialist
if (_role == "ahmg") exitWith {
	if (ADF_modded || {ADF_mod_RHS}) then {
		if (ADF_mod_CFP || {ADF_mod_CUP_U}) exitWith {_unit addBackpack  "CUP_B_M2_MiniTripod_Bag"};
		_unit addBackpack  "RHS_M2_Tripod_Bag"
	} else {
		_unit addBackpack "B_HMG_01_support_F";
	};	
	_unit addGoggles (selectRandom _faceWear);
	
	for "_i" from 1 to 5 do {_unit addMagazine _primaryWeaponMag;};
	_unit addWeapon _primaryWeapon_lite;
	
	_plt_set call ADF_loadout_platoon;
};