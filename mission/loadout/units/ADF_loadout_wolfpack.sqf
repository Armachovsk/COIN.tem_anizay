/*********************************************************************************
 _____ ____  _____ 
|  _  |    \|   __|
|     |  |  |   __|
|__|__|____/|__|   
ARMA Mission Development Framework
ADF version: 2.26 / Jul 2020

Script: Loadout & Gear "Wolfpack campaign"
Author: Whiztler
Script version: 1.17

Game type: COOP
File: ADF_loadout_wolfpack.sqf
*********************************************************************************
Used exclusively for the Wolfpack COOP Campaign
*********************************************************************************/

params ["_unit"];
diag_log format ["ADF rpt: Init - executing: ADF_loadout_wolfpack.sqf for %1", _unit]; // Reporting. Do NOT edit/remove

// Init
if (!(isNil "GM_1") && {(player == GM_1)}) exitWith {};
private _role = toLower (((str _unit) splitString "_") select 1);
private _wetGear = if (toLower (((str _unit) splitString "_") select 0) isEqualTo "sod") then {true} else {false};
tf_no_auto_long_range_radio = true;

// Mission Params / Overrides
private _RHS = ADF_mod_RHS;
private _NIArms = if (ADF_mod_NIARMS && {("ADF_weaponsOverride_NIArms" call BIS_fnc_getParamValue) == 1}) then {true} else {false};
if (ADF_mod_CUP_U && {("ADF_CUPOverride" call BIS_fnc_getParamValue) == 1}) then {_RHS = false};
if (!isNil "ADF_moddedOverride" && {("ADF_moddedOverride" call BIS_fnc_getParamValue) == 1}) then {_RHS = false};

// Strip the unit
[_unit, true] call ADF_fnc_stripUnit;


/********* DEFAULT/BIS VANILLA KIT ********/

// Primary weapon
private _primaryWeapon = "arifle_MX_Black_F";
private _primaryWeapon_lite = "arifle_MXC_Black_F";
private _primaryWeapon_gl = "arifle_MX_GL_Black_F";
private _primaryWeapon_mm = if (ADF_dlc_Marksman) then {"srifle_DMR_02_F"} else {"srifle_EBR_F"};
private _primaryWeapon_wet = "arifle_SDAR_F";
private _handWeapon = "hgun_P07_F";
private _tube_at = "launch_I_Titan_short_F";

// Attachments
private _primaryWeaponAtt_scope = if ADF_wolfpack_nite_op then {selectRandom ["optic_Hamr", "optic_Arco_blk_F", "optic_MRCO"]} else {selectRandom ["optic_Arco", "optic_ERCO_snd_F"]};
private _primaryWeaponAtt_scope_lite = if ADF_wolfpack_nite_op then {"optic_ACO_grn"} else {"optic_Holosight"};
private _primaryWeaponAtt_scope_mm = if (ADF_dlc_Marksman) then {"optic_AMS"} else {"optic_DMS"};
private _primaryWeaponAtt_laser = "acc_pointer_IR";
private _primaryWeaponAtt_muz = if ADF_wolfpack_nite_op then {"muzzle_snds_H"} else {"muzzle_snds_H_snd_F"};
private _primaryWeaponAtt_muz_mm = if (ADF_dlc_Marksman) then {"muzzle_snds_338_black"} else {selectRandom ["muzzle_snds_B", "muzzle_snds_H_khk_F"]};
private _primaryWeaponAtt_bipod_mm = "bipod_01_F_blk";
private _handWeaponAtt_muz = "muzzle_snds_L";

// Ammunition
private _primaryWeaponMag = if ADF_mod_ACE3 then {"ACE_30Rnd_65x39_caseless_mag_Tracer_Dim"} else {"30Rnd_65x39_caseless_mag"};
private _primaryWeaponMag_mm = if ADF_dlc_Marksman then {if ADF_mod_ACE3 then {"ACE_10Rnd_338_API526_Mag"} else {"10Rnd_338_Mag"}} else {if ADF_mod_ACE3 then {"ACE_20Rnd_762x51_Mag_SD"} else {"20Rnd_762x51_Mag"}};
private _primaryWeaponMag_wet = "20Rnd_556x45_UW_mag";
private _handWeapon_mag = "11Rnd_45ACP_Mag";
private _tubeMag_at = "Titan_AT";
private _40mike = "1Rnd_HE_Grenade_shell";
private _handgrenade = "MiniGrenade";

// Misc
private _microDAGR = "Chemlight_green"; // in case of BIS Vanilla

// Default kit
private _uniform = if ADF_wolfpack_nite_op then {selectRandom ["U_B_SpecopsUniform_sgg", "U_B_CombatUniform_sgg_vest", "U_B_CombatUniform_mcam_worn"]} else {if (_role == "ssc") then {"U_I_G_resistanceLeader_F"} else {selectRandom ["U_B_SpecopsUniform_sgg", "U_B_CombatUniform_sgg_vest", "U_B_CombatUniform_mcam_worn", "U_B_survival_uniform", "U_I_G_Story_Protagonist_F"]}};
private _uniform_dry = ["U_B_survival_uniform", "U_I_G_Story_Protagonist_F", "U_BG_Guerilla2_1", "U_BG_Guerilla2_3", "U_BG_Guerrilla_6_1"];
private _uniform_wet = "U_B_Wetsuit";
private _nvg = "NVGoggles_OPFOR";
private _vest = if ADF_wolfpack_nite_op then {["V_PlateCarrier2_blk", "V_PlateCarrier1_blk", "V_TacVestIR_blk"]} else {["V_PlateCarrier2_rgr", "V_Chestrig_khk", "V_PlateCarrier1_rgr", "V_TacVestCamo_khk", "V_PlateCarrier2_rgr_noflag_F", "V_PlateCarrier1_rgr_noflag_F", "V_PlateCarrier_Kerry"]};
private _vest_wet = "V_RebreatherB";
private _headGear = if ADF_wolfpack_nite_op then {["H_Watchcap_blk", "H_Watchcap_cbr", "H_Watchcap_camo", "H_Bandanna_gry", "H_Cap_usblack", "H_Cap_blk"]} else {["H_Cap_oli_hs", "H_Cap_tan", "H_Cap_tan_specops_US", "H_Watchcap_camo", "H_Watchcap_cbr", "H_Watchcap_khk", "H_Shemag_olive_hs", "H_Bandanna_khk_hs", "H_Booniehat_khk_hs", "H_Booniehat_mcamo"]};
private _backpack = if ADF_wolfpack_nite_op then { ["B_TacticalPack_blk", "B_AssaultPack_blk", "B_FieldPack_blk"]} else { ["B_AssaultPack_khk", "B_AssaultPack_rgr", "B_AssaultPack_cbr", "B_AssaultPack_mcamo", "B_Kitbag_mcamo", "B_Kitbag_cbr", "B_TacticalPack_mcamo", "B_TacticalPack_oli", "B_FieldPack_cbr", "B_Carryall_mcamo", "B_Carryall_cbr"]};
private _backpack_wet = if ADF_wolfpack_nite_op then {["B_Carryall_oli", "B_Carryall_khk"]} else {["B_Carryall_oli", "B_Carryall_khk", "B_Carryall_mcamo"]};
private _faceWear = if ADF_wolfpack_nite_op then {["G_Tactical_Clear"]} else {["G_Shades_Black", "G_Shades_Blue", "G_Shades_Red", "G_Shades_Green", "G_Sport_Blackred", "G_Spectacles_Tinted"]};
private _faceWear_wet = "G_Diving";
private _opsCore = if ADF_wolfpack_nite_op then {["H_HelmetB_light_black"]} else {["H_HelmetB_light_sand", "H_HelmetB_light_grass", "H_HelmetB_light_desert"]};


/********* MODDED KIT OVERRIDES ********/

if (ADF_modded || {_RHS}) then {
	call {
		if _RHS exitWith {	
			if ADF_wolfpack_nite_op then {
				_uniform = "rhs_uniform_g3_blk";
				_uniform_dry append ["rhs_uniform_g3_blk"];
				_faceWear append ["rhs_googles_clear"];
				_opsCore = ["rhsusf_opscore_bk_pelt", "rhsusf_opscore_bk"];
				
				// Primary weapon
				_primaryWeapon = selectRandom ["rhs_weap_mk18_KAC", "rhs_weap_mk18", "rhs_weap_m4a1_blockII_KAC_bk", "rhs_weap_m4a1_blockII_KAC", "rhs_weap_hk416d10_LMT", "rhs_weap_hk416d10_LMT_wd", "rhs_weap_hk416d145_wd"];
				_primaryWeapon_gl = selectRandom ["rhs_weap_mk18_m320", "rhs_weap_m4a1_blockII_M203", "rhs_weap_m4a1_blockII_M203_bk", "rhs_weap_hk416d10_m320", "rhs_weap_hk416d145_m320"];
				_primaryWeapon_mm = "rhs_weap_XM2010";
				
				// Attachments _ RHS			
				_primaryWeaponAtt_scope = selectRandom ["rhsusf_acc_su230", "rhsusf_acc_ACOG2_USMC", "rhsusf_acc_ACOG3", "rhsusf_acc_su230_mrds", "rhsusf_acc_ACOG_MDO"];
				_primaryWeaponAtt_muz = "rhsusf_acc_nt4_black";	
				_primaryWeaponAtt_laser = "rhsusf_acc_anpeq15side_bk";
				_primaryWeaponAtt_scope_mm = "optic_LRPS";			
				_primaryWeaponAtt_muz_mm = "rhsusf_acc_M2010S_wd";
				_primaryWeaponAtt_bipod_mm = "rhsusf_acc_harris_bipod";				
				
			} else {
				_uniform = selectRandom ["rhs_uniform_g3_mc", "rhs_uniform_cu_ocp"];
				_uniform_dry append  ["rhs_uniform_g3_mc", "rhs_uniform_cu_ocp", "U_B_SpecopsUniform_sgg"];
				_vest = ["rhsusf_spcs_ocp_teamleader", "rhsusf_spcs_ocp_teamleader_alt", "rhsusf_spcs_ocp_squadleader", "rhsusf_spcs_ocp_rifleman_alt", "rhsusf_iotv_ocp_Teamleader", "rhsusf_iotv_ocp_Squadleader"];
				_faceWear append ["rhs_googles_black", "rhs_googles_clear", "rhsusf_oakley_goggles_blk", "rhsusf_oakley_goggles_ylw", "rhsusf_shemagh2_tan", "rhsusf_shemagh_grn"];
				_headGear append ["rhs_booniehat2_marpatd", "rhs_Booniehat_ocp", "rhs_beanie_green"];	
				_opsCore = ["rhsusf_opscore_mc_cover_pelt_cam", "rhsusf_opscore_mc_pelt_nsw", "rhsusf_opscore_paint_pelt_nsw_cam", "rhsusf_opscore_ut_pelt_nsw_cam", "rhsusf_opscore_fg_pelt_nsw_cam"];
				
				// Primary weapon
				_primaryWeapon = selectRandom ["rhs_weap_m4a1_blockII_KAC_wd", "rhs_weap_mk18_KAC_d", "rhs_weap_m4a1_d", "rhs_weap_m4a1_blockII_KAC_d", "rhs_weap_m4a1_blockII_d", "rhs_weap_hk416d145_d", "rhs_weap_hk416d145_d_2", "rhs_weap_hk416d10_LMT_d", "rhs_weap_hk416d10_LMT_wd", "rhs_weap_hk416d145_wd", "rhs_weap_mk18_KAC_wd"];
				_primaryWeapon_gl = selectRandom ["rhs_weap_hk416d10_m320", "rhs_weap_hk416d145_m320", "rhs_weap_m4a1_blockII_M203_wd", "rhs_weap_m4a1_m203s_d"];
				_primaryWeapon_mm = "rhs_weap_XM2010_sa";
				
				// Attachments _ RHS			
				_primaryWeaponAtt_scope = selectRandom ["rhsusf_acc_su230", "rhsusf_acc_ACOG2_USMC", "rhsusf_acc_ACOG3", "rhsusf_acc_su230_mrds", "rhsusf_acc_ACOG_MDO"];
				_primaryWeaponAtt_muz = "rhsusf_acc_nt4_tan";	
				_primaryWeaponAtt_laser = "rhsusf_acc_anpeq15side";
				_primaryWeaponAtt_scope_mm = "rhsusf_acc_M8541_low_wd";			
				_primaryWeaponAtt_muz_mm = "rhsusf_acc_M2010S_sa";
				_primaryWeaponAtt_bipod_mm = "rhsusf_acc_harris_bipod";				
				
			};

			// Primary weapon
			_primaryWeapon_lite = "rhs_weap_m4a1_carryhandle_mstock";
			
			_handWeapon = "rhsusf_weap_glock17g4";
			_tube_at = "rhs_weap_M136_hp";

			// Attachments _ RHS	
			_primaryWeaponAtt_scope_lite = "rhsusf_acc_eotech_552";
			_handWeaponAtt_muz = "rhsusf_acc_omega9k";

			// Ammunition
			_primaryWeaponMag = "rhs_mag_30Rnd_556x45_M855A1_Stanag";
			_primaryWeaponMag_mm = "rhsusf_5Rnd_300winmag_xm2010";
			_handWeapon_mag = "rhsusf_mag_17Rnd_9x19_JHP";

			_tubeMag_at = "rhs_m136_hp_mag";
			_40mike = "rhs_mag_M441_HE";
			_handgrenade = "rhs_mag_m67";
			_headGear append ["rhsusf_Bowman", "rhs_Booniehat_m81"];
					
			_nvg = "rhsusf_ANPVS_15";		

			if (ADF_mod_3CB_FACT && {ADF_mod_PROPFOR}) exitWith {				
				if ADF_wolfpack_nite_op then {
					_headGear append ["LOP_H_Shemag_BLK", "UK3CB_H_Shemag_grey", "UK3CB_H_Shemag_blk"];
					_vest append ["LOP_V_CarrierLite_BLK", "LOP_V_CarrierLite_OLV", "LOP_V_CarrierRig_BLK", "LOP_V_CarrierLite_BLK", "LOP_V_CarrierLite_OLV", "LOP_V_CarrierRig_BLK", "UK3CB_ANP_B_V_TacVest_BLK", "UK3CB_TKA_B_V_GA_HEAVY_BLK", "UK3CB_TKP_I_V_6Sh92_Radio_Blk", "UK3CB_TKA_B_V_GA_LITE_BLK"];
				} else {
					_vest append ["UK3CB_ANP_B_V_GA_LITE_TAN"];
					_headgear append ["LOP_H_Booniehat_RACS"];
					_faceWear append ["UK3CB_G_Neck_Shemag_Oli", "UK3CB_G_Neck_Shemag_Tan", "UK3CB_G_Neck_Shemag"];
				};					
			};
			
			if ADF_mod_PROPFOR then {							
				if ADF_wolfpack_nite_op then {
					_headgear append ["LOP_H_Shemag_BLK"];
					_vest append ["LOP_V_CarrierLite_BLK", "LOP_V_CarrierLite_OLV", "LOP_V_CarrierRig_BLK", "LOP_V_CarrierLite_BLK", "LOP_V_CarrierLite_OLV", "LOP_V_CarrierRig_BLK"];
				} else {
					_headgear append ["LOP_H_Booniehat_RACS"];
				};
			};
			
			if ADF_mod_3CB_FACT then {								
				if ADF_wolfpack_nite_op then {
					_headgear append ["UK3CB_H_Shemag_grey", "UK3CB_H_Shemag_blk"];
					_vest append ["UK3CB_ANP_B_V_TacVest_BLK", "UK3CB_TKA_B_V_GA_HEAVY_BLK", "UK3CB_TKP_I_V_6Sh92_Radio_Blk", "UK3CB_TKA_B_V_GA_LITE_BLK"];
				} else {
					_vest append ["UK3CB_ANP_B_V_GA_LITE_TAN"];
					_faceWear append ["UK3CB_G_Neck_Shemag_Oli", "UK3CB_G_Neck_Shemag_Tan", "UK3CB_G_Neck_Shemag"];
				};					
			};
		};
	
		if ADF_mod_CUP_U exitWith {
			if ADF_wolfpack_nite_op then {
				_vest = ["CUP_V_I_RACS_Carrier_Vest_wdl", "CUP_V_PMC_CIRAS_Black_Veh", "CUP_V_PMC_CIRAS_Black_Grenadier", "CUP_V_PMC_CIRAS_Black_Patrol", "CUP_V_PMC_CIRAS_Black_TL", "CUP_V_PMC_IOTV_Black_AR", "CUP_V_PMC_IOTV_Black_Gren", "CUP_V_PMC_IOTV_Black_Patrol", "CUP_V_PMC_IOTV_Black_TL"];
				_backpack append ["CUP_B_AssaultPack_Black", "CUP_B_USPack_Black"];
				_headgear append ["CUP_H_PMC_PRR_Headset", "CUP_H_PMC_Beanie_Black", "CUP_H_PMC_Cap_Grey", "CUP_H_PMC_Cap_Back_PRR_Grey"];
				
				// Primary weapon
				_primaryWeapon = selectRandom ["CUP_arifle_HK416_CQB_Black", "CUP_arifle_HK416_Black", "CUP_arifle_Mk16_CQC_FG_black", "CUP_arifle_M4A1_black", "CUP_arifle_M4A3_black", "CUP_arifle_mk18_black"];
				_primaryWeapon_gl = selectRandom ["CUP_arifle_HK416_CQB_AG36", "CUP_arifle_M4A1_GL_carryhandle"];
				_primaryWeapon_mm = "CUP_srifle_AWM_wdl";
				
				// Attachments		
				_primaryWeaponAtt_scope = "CUP_optic_Elcan_reflex";
				_primaryWeaponAtt_scope_lite = "CUP_optic_Eotech553_Black";
				_primaryWeaponAtt_muz = "CUP_muzzle_snds_M16";	
				_primaryWeaponAtt_laser = "CUP_acc_ANPEQ_15_Top_Flashlight_Black_L";
				_primaryWeaponAtt_scope_mm = "CUP_optic_SB_3_12x50_PMII";			
				_primaryWeaponAtt_muz_mm = "CUP_muzzle_snds_AWM";
				_primaryWeaponAtt_bipod_mm = "bipod_01_F_blk";
				_handWeaponAtt_muz = "CUP_muzzle_snds_M9";					
			} else {
				_vest = ["CUP_V_B_Interceptor_Rifleman_Coyote", "CUP_V_B_Interceptor_Grenadier_Coyote", "CUP_V_B_RRV_Scout3", "CUP_V_B_RRV_DA2", "CUP_V_B_Interceptor_Grenadier_M81", "CUP_V_B_Eagle_SPC_DMR", "CUP_V_B_Eagle_SPC_Officer", "CUP_V_B_Eagle_SPC_Patrol", "CUP_V_B_Eagle_SPC_Rifleman", "CUP_V_B_Eagle_SPC_SL", "CUP_V_B_Eagle_SPC_TL", "CUP_V_I_RACS_Carrier_Vest", "CUP_V_I_RACS_Carrier_Vest_2"];
				_backpack append ["CUP_B_Bergen_BAF", "CUP_B_AssaultPack_Coyote", "CUP_B_USPack_Coyote", "CUP_B_USMC_AssaultPack", "CUP_B_USMC_MOLLE"];
				_headgear append ["CUP_H_PMC_PRR_Headset", "CUP_H_PMC_Cap_PRR_Grey", "CUP_H_SLA_BeanieGreen", "CUP_H_FR_BeanieGreen", "CUP_H_RUS_Bandana_HS", "CUP_H_USMC_BOONIE_DES", "CUP_H_USMC_BOONIE_PRR_DES", "CUP_H_PMC_Cap_Back_PRR_Tan", "CUP_H_PMC_Cap_PRR_Tan"];
				
				// Primary weapon
				_primaryWeapon = 	selectRandom ["CUP_arifle_M4A1_camo", "CUP_arifle_M4A3_camo", "CUP_arifle_M4A3_desert", "CUP_arifle_M4A1_desert_carryhandle", "CUP_arifle_mk18_black", "CUP_arifle_Mk16_CQC_FG_woodland", 	"CUP_arifle_HK416_CQB_Desert", "CUP_arifle_HK416_CQB_Wood"];
				_primaryWeapon_gl = selectRandom ["CUP_arifle_HK416_CQB_AG36", "CUP_arifle_HK416_CQB_M203_Wood", "CUP_arifle_HK416_CQB_AG36_Wood", "CUP_arifle_HK416_M203_Desert", "CUP_arifle_M4A1_GL_carryhandle_desert", "CUP_arifle_M4A1_GL_carryhandle_camo", "CUP_arifle_M4A1_BUIS_desert_GL"];
				_primaryWeapon_mm = "CUP_srifle_AWM_des";
				
				// Attachments		
				_primaryWeaponAtt_scope = "CUP_optic_Elcan_reflex";
				_primaryWeaponAtt_scope_lite = "CUP_optic_Eotech553_Black";
				_primaryWeaponAtt_muz = "CUP_muzzle_snds_M16";	
				_primaryWeaponAtt_laser = "CUP_acc_ANPEQ_15_Top_Flashlight_Black_L";
				_primaryWeaponAtt_scope_mm = "CUP_optic_LeupoldMk4_MRT_tan";			
				_primaryWeaponAtt_muz_mm = "CUP_muzzle_snds_AWM";
				_primaryWeaponAtt_bipod_mm = "CUP_bipod_VLTOR_Modpod";
				_handWeaponAtt_muz = "CUP_muzzle_snds_M9";				
			};		
			
			_primaryWeapon_lite = "CUP_arifle_HK416_CQB_Black";
			_handWeapon = "CUP_hgun_Glock17_blk";
			_tube_at = "CUP_launch_Mk153Mod0";			
			
			// Ammunition
			_primaryWeaponMag = "CUP_30Rnd_556x45_PMAG_QP";
			_primaryWeaponMag_mm = "CUP_5Rnd_86x70_L115A1";
			_handWeapon_mag = "CUP_17Rnd_9x19_glock17";

			_tubeMag_at = "CUP_SMAW_HEAA_M";
			_40mike = "CUP_1Rnd_HEDP_M203";
			
			// Gear
			_faceWear append ["CUP_FR_NeckScarf", "CUP_G_PMC_RadioHeadset_Glasses_Dark", "CUP_G_PMC_RadioHeadset_Glasses", "CUP_G_PMC_RadioHeadset", "G_Tactical_Clear"];
			_uniform_dry append ["CUP_I_B_PMC_Unit_17", "CUP_I_B_PMC_Unit_13", "CUP_I_B_PMC_Unit_24"];
			if ADF_wolfpack_nite_op then {
				_faceWear append ["CUP_FR_NeckScarf3"];
			} else {
				_faceWear append ["CUP_TK_NeckScarf", "CUP_G_Oakleys_Clr", "CUP_G_Oakleys_Drk", "CUP_FR_NeckScarf5", "CUP_FR_NeckScarf2", "CUP_FR_NeckScarf4"];
				_backpack_wet append ["CUP_B_HikingPack_Civ"];
			};
			
			if ADF_mod_CFP exitWith {
				_uniform_dry append ["SP_0000_Standard_TacticalUniform_Black_TS", "CFP_GUER_M81Tee", "SP_0000_Standard_TacticalUniform_ATacsFG_TS", "CFP_GUER_MCampants", "CFP_GUER_TanTee", "SP_0000_Standard_PulloverUniform_Black", "SP_0000_Standard_PulloverUniform_Green"];
				_faceWear append ["CFP_Beard", "CFP_Beard", "CFP_Beard"];
				if ADF_wolfpack_nite_op then {
					_opsCore = ["CUP_H_USArmy_Helmet_ECH1_Black", "CUP_H_USArmy_Helmet_Pro", "CFP_OPS2017_Helmet_Black2", "SP_ProTecHelmet_Black"];
					_backpack_wet = ["SP_Carryall_Black"];
					_uniform = selectRandom ["SP_0000_Standard_FieldUniform_Green_SS", "CUP_I_B_PMC_Unit_17", "CUP_I_B_PMC_Unit_13", "CUP_I_B_PMC_Unit_24", "SP_0000_Standard_TacticalUniform_Black_TS", "SP_0000_Standard_PulloverUniform_Black", "CFP_U_Crye_Black", "SP_0000_Standard_FieldUniform_Black", "CFP_U_Crye_Black_SS", "SP_0000_Standard_FieldUniform_Black_SS"];
					_vest append ["CUP_V_I_RACS_Carrier_Vest_wdl", "CUP_V_PMC_CIRAS_Black_Veh", "CUP_V_PMC_CIRAS_Black_Grenadier", "CUP_V_PMC_CIRAS_Black_Patrol", "CUP_V_PMC_CIRAS_Black_TL", "CUP_V_PMC_IOTV_Black_AR", "CUP_V_PMC_IOTV_Black_Gren", "CUP_V_PMC_IOTV_Black_Patrol", "CUP_V_PMC_IOTV_Black_TL", "CFP_AK_VEST_Black", "SP_Tactical1_Black", "SP_Harness1_Black", "V_PlateCarrier2_blk", "SP_Modular1_Black", "SP_Modular2_Black", "CFP_RAV_Black"];
					_faceWear append ["CFP_Shemagh_Half_Black"];
					_headgear append ["SP_Shemagh_Black", "SP_Bandana_Black", "SP_BaseballCap_Black", "SP_BeanieHat_Black", "SP_BeanieHat_Green", "SP_BoonieHat_Black", "CFP_BoonieHat_Multicam", "SP_HeadSet_Black"];
				} else {
					_opsCore = ["SP_ProTecHelmet_Tan", "SP_ProTecHelmet_Green", "VSM_OPS2017_Helmet_Tan", "CFP_OPS2017_Helmet_Multicam2", "CFP_OPS2017_Helmet_Multicam", "CFP_OpsC_Uncovered", "CFP_OpsC_Med", "CFP_OpsC_Covered2", "CFP_OpsC_Cov_Goggles_Off"];
					_vest append ["CFP_RAV_Breacher_OGA", "CFP_RAV_operator_OGA", "CFP_RAV_operator_OGA_OD", "CFP_RAV_Breacher_OGA_OD", "CFP_LBT6094_operator_OGA_OD", "CFP_LBT6094_breacher_OGA_OD", "CFP_FAPC_Breacher_OGA_OD", "CFP_LBT6094_operator_OGA", "CFP_LBT6094_breacher_OGA", "CFP_FAPC_Operator_OGA", "CFP_FAPC_Breacher_OGA", "CFP_LBT1961_OGA_OD"];
					_uniform = selectRandom ["CFP_75th_CRYE_V1b_Sleeved", "CFP_75th_CRYE_V3b_Sleeved", "CFP_75th_CRYE_Tee2", "CFP_U_Crye_Multicam2", "CFP_U_Crye_Multicam2_SS", "CFP_U_Crye_Multicam2plain_SS", "CFP_75th_CRYEG3_V1b", "CFP_75th_CRYEG3_V1", "CFP_75th_CRYEG3_V2b"];
					_faceWear append ["CFP_Neck_Wrap_Atacs2", "CFP_Neck_Plain2", "CFP_Neck_Plain4", "CFP_Neck_Wrap2", "CFP_Oakleys_Clr", "CFP_Oakleys_Drk", "CFP_Oakleys_Embr", "CFP_Scarfbeard_grey", "CFP_Scarfbeard_tan", "CFP_Scarfbeard_green", "CFP_Scarfshades_grey", "CFP_Scarfshades_tan", "SP_Shades_Black", "CFP_Shemagh_Neck_Creme", "CFP_Shemagh_Neck_M81", "CFP_Shemagh_Neck_Tan", "CFP_Shemagh_Half_Tan", "CFP_Tac_Goggles_Blk_Drk", "CFP_Tac_Goggles_Tan_Drk"];
					_headgear append ["SP_Shemagh_CheckGreen", "SP_Bandana_Tan", "SP_BaseballCap_Green", "SP_BeanieHat_Tan", "CFP_BoonieHat_AOR2", "SP_HeadSet_Green", "SP_HeadSet_Tan"];
				};
			};
			
			if ADF_mod_CUP_U then {			
				if ADF_wolfpack_nite_op then {
					_opsCore = ["CUP_H_USArmy_Helmet_ECH1_Black", "CUP_H_USArmy_Helmet_Pro", "CUP_H_USArmy_Helmet_Pro_gog"];
					_uniform = selectRandom ["CUP_I_B_PMC_Unit_17", "CUP_I_B_PMC_Unit_13", "CUP_I_B_PMC_Unit_24"];
				} else {
					_opsCore = ["CUP_H_USArmy_Helmet_ECH1_Black", "CUP_H_USArmy_Helmet_Pro"];
					_uniform = if (_role == "ssc") then {"U_I_G_resistanceLeader_F"} else {selectRandom ["U_B_SpecopsUniform_sgg", "U_B_CombatUniform_sgg_vest", "U_B_CombatUniform_mcam_worn", "U_B_survival_uniform", "U_I_G_Story_Protagonist_F"]};
				};				
			};			
		};
	};
};

// NIArms override. If NIArms is selected in the mission params then it will override BIS Vanilla and RHS/CUP weapon selections.
if _NIArms then {
	// Primary weapon
	_primaryWeapon = if ADF_wolfpack_nite_op then {selectRandom ["hlc_rifle_CQBR", "hlc_rifle_416D10_st6", "hlc_rifle_mk18mod0", "hlc_rifle_mk18mod0"]} else {selectRandom ["hlc_rifle_CQBR", "hlc_rifle_416D10_st6", "hlc_rifle_416D10_ptato", "hlc_rifle_416D10_tan", "hlc_rifle_416D10_wdl", "hlc_rifle_416D10_geissele", "hlc_rifle_mk18mod0"]};
	_primaryWeapon_lite = "hlc_rifle_416C";
	_primaryWeapon_gl = selectRandom ["hlc_rifle_416D10_gl", "hlc_rifle_416D145_gl", "hlc_rifle_416N_gl"];
	_primaryWeapon_mm = "hlc_rifle_M14dmr_Rail";
	_handWeapon = if ADF_wolfpack_nite_op then {"hlc_pistol_P226R_40Combat"} else {"hlc_pistol_Mk25TR"};

	// Attachments _ RHS			
	_primaryWeaponAtt_scope = if ADF_wolfpack_nite_op then {selectRandom ["hlc_optic_HensoldtZO_Hi_Docter_2D", "hlc_optic_HensoldtZO_lo_Docter_2D", "optic_ERCO_blk_F", "optic_MRCO"]} else {selectRandom ["hlc_optic_HensoldtZO_Hi_Docter_2D", "hlc_optic_HensoldtZO_lo_Docter_2D", "optic_ERCO_blk_F", "optic_MRCO", "optic_Arco", "optic_ERCO_snd_F", "optic_Hamr_khk_F"]};
	_primaryWeaponAtt_scope_lite = "HLC_optic_DocterR";
	_primaryWeaponAtt_muz = if ADF_wolfpack_nite_op then {selectRandom ["hlc_muzzle_556NATO_KAC", "hlc_muzzle_556NATO_M42000", "muzzle_snds_M"]} else {selectRandom ["hlc_muzzle_556NATO_KAC", "hlc_muzzle_556NATO_rotexiiic_tan", "hlc_muzzle_556NATO_M42000", "muzzle_snds_M"]};
	_primaryWeaponAtt_scope_mm = "hlc_optic_LeupoldM3A";			
	_primaryWeaponAtt_muz_mm = "hlc_muzzle_300blk_KAC";
	_primaryWeaponAtt_bipod_mm = "hlc_optic_ATACR";
	_handWeaponAtt_muz = "hlc_muzzle_TiRant9S";

	// Ammunition
	_primaryWeaponMag = "hlc_30rnd_556x45_EPR";
	_primaryWeaponMag_mm = "hlc_20Rnd_762x51_B_M14";
	_handWeapon_mag = "hlc_15Rnd_9x19_B_P226";
};


/********* ASSIGN GEAR ********/

// Add primary containers
if _wetGear then {
	_unit forceAddUniform _uniform_wet;
	_unit addVest _vest_wet;
	_unit addGoggles _faceWear_wet;
} else {
	_unit forceAddUniform _uniform;
	_unit addVest (selectRandom _vest);
	_unit addHeadgear (selectRandom _headGear);
	_unit addGoggles (selectRandom _faceWear);
};
{_unit linkItem _x} count ["ItemWatch", "ItemCompass", "ItemMap", "ItemGPS"];

// Backpacks
if (_role != "uav") then {
	if _wetGear then {
		_unit addBackpack (selectRandom _backpack_wet);
		if (_role == "ssc") then {_unit addItemToBackpack "U_I_G_resistanceLeader_F";} else {_unit addItemToBackpack (selectRandom _uniform_dry)};
		if ADF_wolfpack_nite_op then {(backpackContainer _unit) setObjectTextureGlobal [0, "A3\weapons_f\ammoboxes\bags\data\backpack_tortila_blk_co.paa"]}; 
		(backpackContainer _unit) addItemCargoGlobal [selectRandom _vest, 1];
		_unit addItemToBackpack (selectRandom _headGear);
		_unit addItemToBackpack (selectRandom _faceWear);
		if ADF_mod_CTAB then {_unit addItemToBackpack "ItemcTabHCam"};
		if ADF_mod_ACRE then {(backpackContainer _unit) addItemCargoGlobal ["ACRE_PRC343", 1]};
		if ADF_mod_TFAR then {_unit linkItem "tf_anprc152"};
		if (!ADF_mod_ACRE && !ADF_mod_TFAR) then {(backpackContainer _unit) addItemCargoGlobal ["ItemRadio", 1]};			
	} else {
		if (_role == "ssc" || {_role == "rtl"}) then {	
			if ADF_mod_ACRE then {_unit addBackpack (selectRandom _backpack); _unit addItem "ACRE_PRC148";};
			if ADF_mod_TFAR then {if ADF_wolfpack_nite_op then {_unit addBackpack "tf_rt1523g_black";} else {_unit addBackpack "tf_rt1523g_big_rhs";}};
			if (!ADF_mod_TFAR && !ADF_mod_ACRE) then {_unit addBackpack (selectRandom _backpack)};
		} else {
			if (_role != "rm") then {
				_unit addBackpack (selectRandom _backpack);
			} else {
				_unit addBackpack "B_Carryall_oli";
				if ADF_wolfpack_nite_op then {(backpackContainer _unit) setObjectTextureGlobal [0, "A3\weapons_f\ammoboxes\bags\data\backpack_tortila_blk_co.paa"]};
			};
		};	
	};
};

// NV
if !(ADF_wolfpack_nite_op || _wetGear) then {_unit addItemToBackpack _nvg} else {_unit addWeapon _nvg;};

///// MODDED ITEMS

// cTab
if ADF_mod_CTAB then {_unit addItemToUniform "ItemcTabHCam"};	

// ACE3 
if ADF_mod_ACE3 then {
	for "_i" from 1 to 3 do {
		_unit addItem "ACE_M84";
		_unit addItem "ACE_fieldDressing";
		_unit addItem "ACE_elasticBandage";
		_unit addItem "ACE_quikclot";	
		_unit addItem "ACE_morphine";	
	};	
	_unit addItem "ACE_EarPlugs";
	_unit addItem "ace_mapTools";
	_unit addItem "ACE_CableTie";
	_unit addItem "ACE_IR_Strobe_Item";
	_unit addItem "ACE_microDAGR";
} else {
	_unit addItem _handgrenade;
	_unit addItem _handgrenade;
	_unit addItemToUniform "FirstAidKit";
	_unit addItemToUniform "FirstAidKit";		
};

// Personal Radios
if (ADF_mod_ACRE && {!_wetGear}) then {_unit linkItem "ACRE_PRC343"};
if (ADF_mod_TFAR && {!_wetGear}) then {_unit linkItem "tf_anprc152"};
if (!ADF_mod_ACRE && {!ADF_mod_TFAR && {!_wetGear}}) then {_unit linkItem "ItemRadio"};

// MicroDAGR
if (ADF_mod_CTAB && {_unit isEqualTo leader group _unit}) then {_unit addItem "itemMicroDagr"};	


///// WEAPONS

// Primary weapon
call {
	// Leadership	
	if (_role == "rtl" || {_role == "ssc" || {_role == "atl"}}) exitWith {
		if _wetGear then {
			(backpackContainer _unit) addWeaponCargoGlobal [_primaryWeapon_gl, 1];
			(backpackContainer _unit) addMagazineCargoGlobal [_primaryWeaponMag, 4];
			_unit addItem _primaryWeaponAtt_scope;
			_unit addItem _primaryWeaponAtt_laser;			
			_unit addItem _primaryWeaponAtt_muz;
			[_unit, _primaryWeapon_wet, 2, _primaryWeaponMag_wet] call BIS_fnc_addWeapon;
		} else {
			[_unit, _primaryWeapon_gl, 6, _primaryWeaponMag] call BIS_fnc_addWeapon;
			_unit addPrimaryWeaponItem _primaryWeaponAtt_scope;
			_unit addPrimaryWeaponItem _primaryWeaponAtt_laser;			
			_unit addPrimaryWeaponItem _primaryWeaponAtt_muz;		
		};
	};
	// Medic
	if (_role == "rm") exitWith {
		if _wetGear then {
			(backpackContainer _unit) addWeaponCargoGlobal [_primaryWeapon_lite, 1];
			(backpackContainer _unit) addMagazineCargoGlobal [_primaryWeaponMag, 4];
			_unit addItem _primaryWeaponAtt_scope_lite;
			_unit addItem _primaryWeaponAtt_laser;
			_unit addItem _primaryWeaponAtt_muz;
			[_unit, _primaryWeapon_wet, 2, _primaryWeaponMag_wet] call BIS_fnc_addWeapon;
		} else {
			[_unit, _primaryWeapon_lite, 6, _primaryWeaponMag] call BIS_fnc_addWeapon;
			_unit addPrimaryWeaponItem _primaryWeaponAtt_scope_lite;
			_unit addPrimaryWeaponItem _primaryWeaponAtt_laser;		
			_unit addPrimaryWeaponItem _primaryWeaponAtt_muz;	
		};
	};
	// Marksman
	if (_role == "rmm") exitWith {
		if _wetGear then {
			(backpackContainer _unit) addWeaponCargoGlobal [_primaryWeapon_mm, 1];
			(backpackContainer _unit) addMagazineCargoGlobal [_primaryWeaponMag_mm, 4];
			_unit addItem _primaryWeaponAtt_scope_mm;
			_unit addItem "optic_Nightstalker";
			_unit addItem _primaryWeaponAtt_bipod_mm;
			_unit addItem _primaryWeaponAtt_laser;
			_unit addItem _primaryWeaponAtt_muz_mm;
			[_unit, _primaryWeapon_wet, 2, _primaryWeaponMag_wet] call BIS_fnc_addWeapon;			
		} else {
			[_unit, _primaryWeapon_mm, 5, _primaryWeaponMag_mm] call BIS_fnc_addWeapon;
			_unit addPrimaryWeaponItem _primaryWeaponAtt_scope_mm;
			_unit addPrimaryWeaponItem _primaryWeaponAtt_bipod_mm;
			_unit addPrimaryWeaponItem _primaryWeaponAtt_laser;			
			_unit addPrimaryWeaponItem _primaryWeaponAtt_muz_mm;
			_unit addItem "optic_Nightstalker";
		};
	};
	// Assault Operators
	if _wetGear then {
		(backpackContainer _unit) addWeaponCargoGlobal [_primaryWeapon, 1];
		(backpackContainer _unit) addMagazineCargoGlobal [_primaryWeaponMag, 4];
		_unit addItem _primaryWeaponAtt_scope;
		_unit addItem _primaryWeaponAtt_laser;			
		_unit addItem _primaryWeaponAtt_muz;
		[_unit, _primaryWeapon_wet, 2, _primaryWeaponMag_wet] call BIS_fnc_addWeapon;
	} else {
		[_unit, _primaryWeapon, 8, _primaryWeaponMag] call BIS_fnc_addWeapon;
		_unit addPrimaryWeaponItem _primaryWeaponAtt_scope;
		_unit addPrimaryWeaponItem _primaryWeaponAtt_laser;			
		_unit addPrimaryWeaponItem _primaryWeaponAtt_muz;		
	};
};

// Hand weapon
[_unit, _handWeapon, 2, _handWeapon_mag] call BIS_fnc_addWeapon;
_unit addHandgunItem _handWeaponAtt_muz;

// Ops Core
_unit addItem (selectRandom _opsCore);

////// closing arguments

ADF_loadout_wolfpack = {
	params ["_unit"];
	_unit selectWeapon (primaryWeapon _unit);
	if ADF_mod_ACE3 then {[_unit, currentWeapon _unit, currentMuzzle _unit] call ACE_SafeMode_fnc_lockSafety;};
	if (ADF_uniformInsignia) then {
		[_unit, ""] call BIS_fnc_setUnitInsignia;
		[_unit, "CLANPATCH"] call BIS_fnc_setUnitInsignia;
	};	

	if ADF_wolfpack_nite_op then {
		private _SOR_face = selectRandom ["CamoHead_African_01_F", "CamoHead_African_02_F", "CamoHead_African_03_F", "CamoHead_Asian_01_F", "CamoHead_Greek_01_F", "CamoHead_Greek_02_F", "CamoHead_Greek_03_F", "CamoHead_Greek_04_F", "CamoHead_Greek_05_F", "CamoHead_Greek_06_F", "CamoHead_Greek_07_F", "CamoHead_Greek_08_F", "CamoHead_Greek_09_F", "CamoHead_White_01_F", "CamoHead_White_02_F", "CamoHead_White_03_F", "CamoHead_White_04_F", "CamoHead_White_05_F", "CamoHead_White_06_F", "CamoHead_White_07_F", "CamoHead_White_08_F", "CamoHead_White_09_F", "CamoHead_White_10_F", "CamoHead_White_11_F", "CamoHead_White_12_F", "CamoHead_White_13_F", "CamoHead_White_14_F", "CamoHead_White_15_F", "CamoHead_White_16_F", "CamoHead_White_17_F", "CamoHead_White_18_F", "CamoHead_White_19_F", "CamoHead_White_20_F", "CamoHead_White_21_F"];
		[_unit, _SOR_face] remoteExec ["setFace", 0, _unit];
	};
	
	if (ADF_modded || {ADF_mod_RHS}) exitWith {ADF_gearLoaded = true;};	
	
	[_unit] spawn {
		params ["_unit"];
		_unit setVariable ["BIS_enableRandomization", false];				
		waitUntil {time > (10 + random 2)};
		
		// Add Uniform EH
		_unit addEventHandler ["Take", {
			params ["_unit", "_container", "_item"];
			if ADF_wolfpack_nite_op then {
				(getObjectTextures _unit + [uniformContainer _unit getVariable "texture"]) params ["_texUniform", "_texInsignia", "_texCustom"];
				if (isNil "_texCustom") exitWith {};
				if (_texUniform == _texCustom) exitWith {};
				_unit setObjectTextureGlobal [0, _texCustom];
			};
			if (ADF_uniformInsignia) then {
				[_unit, ""] call BIS_fnc_setUnitInsignia;
				[_unit, "CLANPATCH"] call BIS_fnc_setUnitInsignia;
			};
			false
		}];
		
		ADF_gearLoaded = true;
		if !ADF_wolfpack_nite_op exitWith {};
		// Set local Texture for Vanilla
		_texture = "\A3\Characters_F\Common\Data\basicbody_black_co.paa";
		_unit setObjectTextureGlobal [0, _texture]; 
		uniformContainer _unit setVariable ["texture", _texture, true];
	};	
};


/********* UNITS ROLE LOADOUT ********/

///// Leadership

if (_role == "ssc" || {_role == "rtl" || {_role == "atl"}}) exitWith {
	if ADF_mod_CTAB then {
		if (_role == "ssc") then {
			_unit addItem "ItemcTab";
		} else {
			_unit addItem "ItemAndroid";
		};
	};
	if (_role == "ssc") then {
		_unit addWeapon "Laserdesignator";
		_unit addItemToBackpack "Laserbatteries";
	} else {
		_unit addWeapon "Rangefinder"
	};
	//40 mike
	for "_i" from 0 to 2 do {_unit addItem _40mike};
	if ADF_mod_ACE3 then {
		_unit addItem "ACE_HuntIR_M203";
		_unit addItem "ACE_HuntIR_monitor";		
	};			

	[_unit] call ADF_loadout_wolfpack;
}; 

///// Recon Marksman
if (_role == "rmm") exitWith {	
	_unit addItemToBackpack "ClaymoreDirectionalMine_Remote_Mag";
	_unit addItemToUniform ADF_microDAGR;
	if ADF_mod_ACE3 then {
		_unit addWeapon "ACE_Vector";
		_unit addItem "ACE_Kestrel4500";
		_unit addItem "ACE_ATragMX";
		_unit addItem "ACE_RangeCard";
	} else {
		_unit addWeapon "Rangefinder";
	};
	if ADF_mod_ACRE then {(backpackContainer _unit) addItemCargoGlobal ["ACRE_PRC148", 1]};	
	[_unit] call ADF_loadout_wolfpack;
}; 

///// Recon Demolition / Demolition Diver	
if (_role == "dem" || {_role == "add"}) exitWith {	
	// Store in Backpack
	for "_i" from 1 to 5 do {
		_unit addItemToBackpack "DemoCharge_Remote_Mag";
	};		
	if ADF_mod_ACE3 then {
		_unit addItemToBackpack "ACE_DeadManSwitch";
		_unit addItemToBackpack "ACE_DefusalKit";
		_unit addItemToBackpack "ACE_M26_Clacker";
		_unit addItemToBackpack "ACE_Clacker";	
		_unit addItemToBackpack "ACE_Cellphone";			
	};
	[_unit] call ADF_loadout_wolfpack;
}; 

///// Recon Medic
if (_role == "rm") exitWith { 
	for "_i" from 1 to 6 do {			
		_unit addItem "SmokeShell";
		_unit addItem "Chemlight_green";
	};
	if ADF_mod_ACE3 then { // ACE3 Advanced Medical
		for "_i" from 1 to 10 do {			
			_unit addItem "ACE_fieldDressing";
			_unit addItem "ACE_elasticBandage";
			_unit addItem "ACE_quikclot";
			_unit addItem "ACE_atropine";				
		};		
		for "_i" from 1 to 7 do {			
			_unit addItem "ACE_morphine";
			_unit addItem "ACE_epinephrine";				
			_unit addItem "ACE_packingBandage";			
		};
		for "_i" from 1 to 4 do {			
			_unit addItem "ACE_salineIV_500";					
			_unit addItem "ACE_tourniquet";				
		};
		for "_i" from 1 to 2 do {			
			_unit addItem "ACE_bloodIV";				
			_unit addItem "ACE_plasmaIV";
			_unit addItem "ACE_personalAidKit";
		};
		_unit addItem "ACE_surgicalKit";
	} else { // Vanilla
		for "_i" from 1 to 10 do {			
			_unit addItem "FirstAidKit";
		};
		_unit addItem "Medikit";
	};
	[_unit] call ADF_loadout_wolfpack;
};	

///// Recon AT
if (_role == "at") exitWith { 
	_unit addItemToBackpack _tubeMag_AT;
	_unit addWeapon _tube_AT;
	[_unit] call ADF_loadout_wolfpack;
};	

///// UAV specialist
if (_role == "uav") exitWith { 
	_unit addBackpack "B_UAV_01_backpack_F";
	_unit addItem "B_UavTerminal";
	_unit assignItem "B_UavTerminal";
	if ADF_mod_ACE3 then {
		_unit addItem "ACE_UAVBattery";
		_unit addItem "ace_dagr";
	};
	[_unit] call ADF_loadout_wolfpack;
};

// All other roles
[_unit] call ADF_loadout_wolfpack;