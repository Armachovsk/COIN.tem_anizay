/*********************************************************************************
 _____ ____  _____ 
|  _  |    \|   __|
|     |  |  |   __|
|__|__|____/|__|   
ARMA Mission Development Framework
ADF version: 2.26 / Jul 2020

Script: Cargo supplies Wolfpack
Author: Whiztler
Script version: 1.01

Game type: n/a
File: ADF_vCargo_B_Wolfpack.sqf
**********************************************************************************
INSTRUCTIONS::

Paste below line in the INITIALIZATION box of the vehicle:
null = [this, "small"] execVM "mission\loadout\vehicles\ADF_vCargo_B_Wolfpack.sqf";

"small" represents the vehicle size. E.g. SDV's get "small", heli's get "medium" and
assault boats get "large".

You can comment out (//) lines of ammo you do not want to include
in the vehicle Cargo. 
*********************************************************************************/

// Init
if !isServer exitWith {};
params [
	"_vehicle",
	["_size", "medium", [""]],
	"_weaponCargo",
	"_weaponAttCargo",
	"_magsCargo",
	"_mag_mmCargo",
	"_nadesCargo",
	"_demoCargo",
	"_demoItemsCargo",
	"_atTubeCargo",
	"_atAmmoCargo",
	"_medCargo",
	"_uniformCargo",
	"_backpackCargo",
	"_vestCargo",
	"_opsCoreCargo",
	"_radioCargo",
	"_cargo"
];

waitUntil {time > 0};

// Settings 
[_vehicle] call ADF_fnc_stripVehicle;
private _NIArms = if (ADF_mod_NIARMS && {("ADF_weaponsOverride_NIArms" call BIS_fnc_getParamValue) == 1}) then {true} else {false};
call {
	if ((toLower _size) isEqualTo "small") exitWith {
		_weaponCargo = 0;
		_weaponAttCargo = 0;
		_magsCargo = 12;
		_mag_mmCargo = 3;
		_nadesCargo = 0;
		_demoCargo = 1;
		_demoItemsCargo = 1;
		_atTubeCargo = 0;
		_atAmmoCargo = 0;
		_medCargo = 5;
		_uniformCargo = 0;
		_backpackCargo = 1;
		_vestCargo = 0;
		_opsCoreCargo = 1;
		_radioCargo = 1;
		_cargo = 1;
	};
	if ((toLower _size) isEqualTo "medium") exitWith {
		_weaponCargo = 1;
		_weaponAttCargo = 2;
		_magsCargo = 25;
		_mag_mmCargo = 5;
		_nadesCargo = 10;
		_demoCargo = 5;
		_demoItemsCargo = 2;
		_atTubeCargo = 1;
		_atAmmoCargo = 2;
		_medCargo = 10;
		_uniformCargo = 0;
		_backpackCargo = 3;
		_vestCargo = 2;
		_opsCoreCargo = 2;
		_radioCargo = 2;
		_cargo = 2;
	};
	if ((toLower _size) isEqualTo "large") exitWith {
		_weaponCargo = 2;
		_weaponAttCargo = 3;
		_magsCargo = 50;
		_mag_mmCargo = 10;
		_nadesCargo = 25;
		_demoCargo = 10;
		_demoItemsCargo = 3;
		_atTubeCargo = 2;
		_atAmmoCargo = 4;
		_medCargo = 25;
		_uniformCargo = 1;
		_backpackCargo = 5;
		_vestCargo = 3;
		_opsCoreCargo = 3;
		_radioCargo = 3;
		_cargo = 3;
	};	
};

// Primary weapon
private _primaryWeapon = "arifle_MX_Black_F";
private _tube_at = "launch_I_Titan_short_F";

// Attachments
private _primaryWeaponAtt_scope = if ADF_wolfpack_nite_op then {selectRandom ["optic_Hamr", "optic_Arco_blk_F", "optic_MRCO"]} else {selectRandom ["optic_Arco", "optic_ERCO_snd_F"]};
private _primaryWeaponAtt_scope_lite = if ADF_wolfpack_nite_op then {"optic_ACO_grn"} else {"optic_Holosight"};;
private _primaryWeaponAtt_scope_mm = if (ADF_dlc_Marksman) then {"optic_AMS"} else {"optic_DMS"};
private _primaryWeaponAtt_laser = "acc_pointer_IR";
private _primaryWeaponAtt_muz = if ADF_wolfpack_nite_op then {"muzzle_snds_H"} else {"muzzle_snds_H_snd_F"};
private _primaryWeaponAtt_muz_mm = if (ADF_dlc_Marksman) then {"muzzle_snds_338_black"} else {selectRandom ["muzzle_snds_B", "muzzle_snds_H_khk_F"]};
private _primaryWeaponAtt_bipod_mm = "bipod_01_F_blk";

// Ammunition
private _primaryWeaponMag = if ADF_mod_ACE3 then {"ACE_30Rnd_65x39_caseless_mag_Tracer_Dim"} else {"30Rnd_65x39_caseless_mag"};
_primaryWeaponMag_mm = if ADF_dlc_Marksman then {if ADF_mod_ACE3 then {"ACE_10Rnd_338_API526_Mag"} else {"10Rnd_338_Mag"}} else {if ADF_mod_ACE3 then {"ACE_20Rnd_762x51_Mag_SD"} else {"20Rnd_762x51_Mag"}};
private _tubeMag_at = "Titan_AT";
private _40mike = "1Rnd_HE_Grenade_shell";
private _handgrenade = "HandGrenade";

// Radios
private _ADF_TFAR_PersonalRadio = "tf_rf7800str";
private _ADF_TFAR_SWRadio = "tf_anprc152";
private _ADF_TFAR_LRRadio = "tf_rt1523g_big_rhs";

// Misc
private _nvg = "NVGoggles_OPFOR";
private _microDAGR = "Chemlight_green"; // in case of BIS Vanilla

// Default kit
private _uniform = selectRandom ["U_B_SpecopsUniform_sgg", "U_B_CombatUniform_sgg_vest", "U_B_CombatUniform_mcam_worn", "U_B_survival_uniform", "U_I_G_Story_Protagonist_F"];
private _vest = if ADF_wolfpack_nite_op then {["V_PlateCarrier2_blk", "V_PlateCarrier1_blk", "V_TacVestIR_blk"]} else {["V_PlateCarrierGL_mtp", "V_PlateCarrierGL_rgr", "V_PlateCarrier2_rgr", "V_PlateCarrier1_rgr", "V_TacVestCamo_khk", "V_PlateCarrier_Kerry"]};
private _backpack = if ADF_wolfpack_nite_op then { ["B_TacticalPack_blk", "B_AssaultPack_blk", "B_FieldPack_blk"]} else { ["B_AssaultPack_khk", "B_AssaultPack_rgr", "B_AssaultPack_cbr", "B_AssaultPack_mcamo", "B_Kitbag_mcamo", "B_Kitbag_cbr", "B_TacticalPack_mcamo", "B_TacticalPack_oli", "B_FieldPack_cbr", "B_Carryall_mcamo", "B_Carryall_cbr"]};
private _opsCore = if ADF_wolfpack_nite_op then {["H_HelmetB_light_black"]} else {["H_HelmetB_light_sand", "H_HelmetB_light_grass", "H_HelmetB_light_desert"]};

/********* MODDED KIT OVERRIDES ********/

if (ADF_modded || {ADF_mod_RHS}) then {
	call {
		if ADF_mod_RHS exitWith {	
			if ADF_wolfpack_nite_op then {
				_uniform = "rhs_uniform_g3_blk";
				_opsCore = ["rhsusf_opscore_bk_pelt", "rhsusf_opscore_bk"];
				
				// Primary weapon
				_primaryWeapon = selectRandom ["rhs_weap_mk18_KAC", "rhs_weap_mk18", "rhs_weap_m4a1_blockII_KAC_bk", "rhs_weap_m4a1_blockII_KAC", "rhs_weap_hk416d10_LMT", "rhs_weap_hk416d10_LMT_wd", "rhs_weap_hk416d145_wd"];
				
				// Attachments		
				_primaryWeaponAtt_scope = selectRandom ["rhsusf_acc_su230", "rhsusf_acc_ACOG2_USMC", "rhsusf_acc_ACOG3", "rhsusf_acc_su230_mrds", "rhsusf_acc_ACOG_MDO"];
				_primaryWeaponAtt_muz = "rhsusf_acc_nt4_black";	
				_primaryWeaponAtt_laser = "rhsusf_acc_anpeq15side_bk";
				_primaryWeaponAtt_scope_mm = "optic_LRPS";			
				_primaryWeaponAtt_muz_mm = "rhsusf_acc_M2010S_wd";
				_primaryWeaponAtt_bipod_mm = "rhsusf_acc_harris_bipod";				
				
			} else {
				_uniform = selectRandom ["rhs_uniform_g3_mc", "rhs_uniform_cu_ocp"];
				_vest = ["rhsusf_spcs_ocp_teamleader", "rhsusf_spcs_ocp_teamleader_alt", "rhsusf_spcs_ocp_squadleader", "rhsusf_spcs_ocp_rifleman_alt", "rhsusf_iotv_ocp_Teamleader", "rhsusf_iotv_ocp_Squadleader"];
				_opsCore = ["rhsusf_opscore_mc_cover_pelt_cam", "rhsusf_opscore_mc_pelt_nsw", "rhsusf_opscore_paint_pelt_nsw_cam", "rhsusf_opscore_ut_pelt_nsw_cam", "rhsusf_opscore_fg_pelt_nsw_cam"];
				
				// Primary weapon
				_primaryWeapon = selectRandom ["rhs_weap_m4a1_blockII_KAC_wd", "rhs_weap_mk18_KAC_d", "rhs_weap_m4a1_d", "rhs_weap_m4a1_blockII_KAC_d", "rhs_weap_m4a1_blockII_d", "rhs_weap_hk416d145_d", "rhs_weap_hk416d145_d_2", "rhs_weap_hk416d10_LMT_d", "rhs_weap_hk416d10_LMT_wd", "rhs_weap_hk416d145_wd", "rhs_weap_mk18_KAC_wd"];
				
				// Attachments		
				_primaryWeaponAtt_scope = selectRandom ["rhsusf_acc_su230", "rhsusf_acc_ACOG2_USMC", "rhsusf_acc_ACOG3", "rhsusf_acc_su230_mrds", "rhsusf_acc_ACOG_MDO"];
				_primaryWeaponAtt_muz = "rhsusf_acc_nt4_tan";	
				_primaryWeaponAtt_laser = "rhsusf_acc_anpeq15side";
				_primaryWeaponAtt_scope_mm = "rhsusf_acc_M8541_low_wd";			
				_primaryWeaponAtt_muz_mm = "rhsusf_acc_M2010S_sa";
				_primaryWeaponAtt_bipod_mm = "rhsusf_acc_harris_bipod";				
			};

			_tube_at = "rhs_weap_M136_hp";

			// Ammunition
			_primaryWeaponMag = "rhs_mag_30Rnd_556x45_M855A1_Stanag";
			_primaryWeaponMag_mm = "rhsusf_5Rnd_300winmag_xm2010";

			_tubeMag_at = "rhs_m136_hp_mag";
			_40mike = "rhs_mag_M441_HE";
			_handgrenade = "rhs_mag_m67";	
			_nvg = "rhsusf_ANPVS_15";		

			if (ADF_mod_3CB_FACT && {ADF_mod_PROPFOR}) exitWith {				
				if ADF_wolfpack_nite_op then {
					_vest append ["LOP_V_CarrierLite_BLK", "LOP_V_CarrierLite_OLV", "LOP_V_CarrierRig_BLK", "LOP_V_CarrierLite_BLK", "LOP_V_CarrierLite_OLV", "LOP_V_CarrierRig_BLK", "UK3CB_ANP_B_V_TacVest_BLK", "UK3CB_TKA_B_V_GA_HEAVY_BLK", "UK3CB_TKP_I_V_6Sh92_Radio_Blk", "UK3CB_TKA_B_V_GA_LITE_BLK"];
				} else {
					_vest append ["UK3CB_ANP_B_V_GA_LITE_TAN"];
				};					
			};		
			if ADF_mod_PROPFOR then {							
				if ADF_wolfpack_nite_op then {
					_vest append ["LOP_V_CarrierLite_BLK", "LOP_V_CarrierLite_OLV", "LOP_V_CarrierRig_BLK", "LOP_V_CarrierLite_BLK", "LOP_V_CarrierLite_OLV", "LOP_V_CarrierRig_BLK"];
				};	
			};		
			if ADF_mod_3CB_FACT then {								
				if ADF_wolfpack_nite_op then {
					_vest append ["UK3CB_ANP_B_V_TacVest_BLK", "UK3CB_TKA_B_V_GA_HEAVY_BLK", "UK3CB_TKP_I_V_6Sh92_Radio_Blk", "UK3CB_TKA_B_V_GA_LITE_BLK"];
				} else {
					_vest append ["UK3CB_ANP_B_V_GA_LITE_TAN"];
				};					
			};
		};
	
		if ADF_mod_CUP_U exitWith {
			if ADF_wolfpack_nite_op then {
				_vest = ["CUP_V_I_RACS_Carrier_Vest_wdl", "CUP_V_PMC_CIRAS_Black_Veh", "CUP_V_PMC_CIRAS_Black_Grenadier", "CUP_V_PMC_CIRAS_Black_Patrol", "CUP_V_PMC_CIRAS_Black_TL", "CUP_V_PMC_IOTV_Black_AR", "CUP_V_PMC_IOTV_Black_Gren", "CUP_V_PMC_IOTV_Black_Patrol", "CUP_V_PMC_IOTV_Black_TL"];
				_backpack append ["CUP_B_AssaultPack_Black", "CUP_B_USPack_Black"];
				
				// Primary weapon
				_primaryWeapon = selectRandom ["CUP_arifle_HK416_CQB_Black", "CUP_arifle_HK416_Black", "CUP_arifle_Mk16_CQC_FG_black", "CUP_arifle_M4A1_black", "CUP_arifle_M4A3_black", "CUP_arifle_mk18_black"];
				
				// Attachments		
				_primaryWeaponAtt_scope = "CUP_optic_Elcan_reflex";
				_primaryWeaponAtt_muz = "CUP_muzzle_snds_M16";	
				_primaryWeaponAtt_laser = "CUP_acc_ANPEQ_15_Top_Flashlight_Black_L";
				_primaryWeaponAtt_scope_mm = "CUP_optic_SB_3_12x50_PMII";			
				_primaryWeaponAtt_muz_mm = "CUP_muzzle_snds_AWM";
				_primaryWeaponAtt_bipod_mm = "bipod_01_F_blk";
			} else {
				_vest = ["CUP_V_B_Interceptor_Rifleman_Coyote", "CUP_V_B_Interceptor_Grenadier_Coyote", "CUP_V_B_RRV_Scout3", "CUP_V_B_RRV_DA2", "CUP_V_B_Interceptor_Grenadier_M81", "CUP_V_B_Eagle_SPC_DMR", "CUP_V_B_Eagle_SPC_Officer", "CUP_V_B_Eagle_SPC_Patrol", "CUP_V_B_Eagle_SPC_Rifleman", "CUP_V_B_Eagle_SPC_SL", "CUP_V_B_Eagle_SPC_TL", "CUP_V_I_RACS_Carrier_Vest", "CUP_V_I_RACS_Carrier_Vest_2"];
				_backpack append ["CUP_B_Bergen_BAF", "CUP_B_AssaultPack_Coyote", "CUP_B_USPack_Coyote", "CUP_B_USMC_AssaultPack", "CUP_B_USMC_MOLLE"];
				
				// Primary weapon
				_primaryWeapon = 	selectRandom ["CUP_arifle_M4A1_camo", "CUP_arifle_M4A3_camo", "CUP_arifle_M4A3_desert", "CUP_arifle_M4A1_desert_carryhandle", "CUP_arifle_mk18_black", "CUP_arifle_Mk16_CQC_FG_woodland",	"CUP_arifle_HK416_CQB_Desert", "CUP_arifle_HK416_CQB_Wood"];
				
				// Attachments		
				_primaryWeaponAtt_scope = "CUP_optic_Elcan_reflex";
				_primaryWeaponAtt_muz = "CUP_muzzle_snds_M16";	
				_primaryWeaponAtt_laser = "CUP_acc_ANPEQ_15_Top_Flashlight_Black_L";
				_primaryWeaponAtt_scope_mm = "CUP_optic_LeupoldMk4_MRT_tan";			
				_primaryWeaponAtt_muz_mm = "CUP_muzzle_snds_AWM";
				_primaryWeaponAtt_bipod_mm = "CUP_bipod_VLTOR_Modpod";
			};		
			
			_tube_at = "CUP_launch_Mk153Mod0";			
			
			// Ammunition
			_primaryWeaponMag = "CUP_30Rnd_556x45_PMAG_QP";
			_primaryWeaponMag_mm = "CUP_5Rnd_86x70_L115A1";

			_tubeMag_at = "CUP_SMAW_HEAA_M";
			_40mike = "CUP_1Rnd_HEDP_M203";
			
	
			if ADF_mod_CFP exitWith {
				if ADF_wolfpack_nite_op then {
					_opsCore = ["CUP_H_USArmy_Helmet_ECH1_Black", "CUP_H_USArmy_Helmet_Pro", "CFP_OPS2017_Helmet_Black2", "SP_ProTecHelmet_Black"];
					_uniform = selectRandom ["SP_0000_Standard_FieldUniform_Green_SS", "CUP_I_B_PMC_Unit_17", "CUP_I_B_PMC_Unit_13", "CUP_I_B_PMC_Unit_24", "SP_0000_Standard_TacticalUniform_Black_TS", "SP_0000_Standard_PulloverUniform_Black", "CFP_U_Crye_Black", "SP_0000_Standard_FieldUniform_Black", "CFP_U_Crye_Black_SS", "SP_0000_Standard_FieldUniform_Black_SS"];
					_vest append ["CUP_V_I_RACS_Carrier_Vest_wdl", "CUP_V_PMC_CIRAS_Black_Veh", "CUP_V_PMC_CIRAS_Black_Grenadier", "CUP_V_PMC_CIRAS_Black_Patrol", "CUP_V_PMC_CIRAS_Black_TL", "CUP_V_PMC_IOTV_Black_AR", "CUP_V_PMC_IOTV_Black_Gren", "CUP_V_PMC_IOTV_Black_Patrol", "CUP_V_PMC_IOTV_Black_TL", "CFP_AK_VEST_Black", "SP_Tactical1_Black", "SP_Harness1_Black", "V_PlateCarrier2_blk", "SP_Modular1_Black", "SP_Modular2_Black", "CFP_RAV_Black"];
				} else {
					_opsCore = ["SP_ProTecHelmet_Tan", "SP_ProTecHelmet_Green", "VSM_OPS2017_Helmet_Tan", "CFP_OPS2017_Helmet_Multicam2", "CFP_OPS2017_Helmet_Multicam", "CFP_OpsC_Uncovered", "CFP_OpsC_Med", "CFP_OpsC_Covered2", "CFP_OpsC_Cov_Goggles_Off"];
					_vest append ["CFP_RAV_Breacher_OGA", "CFP_RAV_operator_OGA", "CFP_RAV_operator_OGA_OD", "CFP_RAV_Breacher_OGA_OD", "CFP_LBT6094_operator_OGA_OD", "CFP_LBT6094_breacher_OGA_OD", "CFP_FAPC_Breacher_OGA_OD", "CFP_LBT6094_operator_OGA", "CFP_LBT6094_breacher_OGA", "CFP_FAPC_Operator_OGA", "CFP_FAPC_Breacher_OGA", "CFP_LBT1961_OGA_OD"];
					_uniform = selectRandom ["CFP_75th_CRYE_V1b_Sleeved", "CFP_75th_CRYE_V3b_Sleeved", "CFP_75th_CRYE_Tee2", "CFP_U_Crye_Multicam2", "CFP_U_Crye_Multicam2_SS", "CFP_U_Crye_Multicam2plain_SS", "CFP_75th_CRYEG3_V1b", "CFP_75th_CRYEG3_V1", "CFP_75th_CRYEG3_V2b"];
			};	};
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

	// Attachments			
	_primaryWeaponAtt_scope = if ADF_wolfpack_nite_op then {selectRandom ["hlc_optic_HensoldtZO_Hi_Docter_2D", "hlc_optic_HensoldtZO_lo_Docter_2D", "optic_ERCO_blk_F", "optic_MRCO"]} else {selectRandom ["hlc_optic_HensoldtZO_Hi_Docter_2D", "hlc_optic_HensoldtZO_lo_Docter_2D", "optic_ERCO_blk_F", "optic_MRCO", "optic_Arco", "optic_ERCO_snd_F", "optic_Hamr_khk_F"]};
	_primaryWeaponAtt_muz = if ADF_wolfpack_nite_op then {selectRandom ["hlc_muzzle_556NATO_KAC", "hlc_muzzle_556NATO_M42000", "muzzle_snds_M"]} else {selectRandom ["hlc_muzzle_556NATO_KAC", "hlc_muzzle_556NATO_rotexiiic_tan", "hlc_muzzle_556NATO_M42000", "muzzle_snds_M"]};
	_primaryWeaponAtt_scope_mm = "hlc_optic_LeupoldM3A";			
	_primaryWeaponAtt_muz_mm = "hlc_muzzle_300blk_KAC";
	_primaryWeaponAtt_bipod_mm = "hlc_optic_ATACR";
	_handWeaponAtt_muz = "hlc_muzzle_TiRant9S";

	// Ammunition
	_primaryWeaponMag = "hlc_30rnd_556x45_EPR";
	_primaryWeaponMag_mm = "hlc_20Rnd_762x51_B_M14";
};


/********* ADD SUPPLIES ********/

// Primary weapon/ammunition/attachments
if (_weaponCargo > 0) then {_vehicle addWeaponCargoGlobal [_primaryWeapon, _weaponCargo]};
if (_weaponAttCargo >0) then {
	_vehicle addItemCargoGlobal [_primaryWeaponAtt_scope, _weaponAttCargo];
	_vehicle addItemCargoGlobal [_primaryWeaponAtt_muz, _weaponAttCargo];
	_vehicle addItemCargoGlobal [_primaryWeaponAtt_laser, _weaponAttCargo];
	_vehicle addItemCargoGlobal [_primaryWeaponAtt_scope_mm, 1];
	_vehicle addItemCargoGlobal [_primaryWeaponAtt_muz_mm, 1];
	_vehicle addItemCargoGlobal [_primaryWeaponAtt_bipod_mm, 1];
};
_vehicle addMagazineCargoGlobal [_primaryWeaponMag, _magsCargo];
_vehicle addMagazineCargoGlobal [_primaryWeaponMag_mm, _mag_mmCargo];

// Launchers
if (_atTubeCargo > 0) then {_vehicle addWeaponCargoGlobal [_tube_at, _atTubeCargo]};
if (_atAmmoCargo > 0) then {_vehicle addMagazineCargoGlobal [_tubeMag_at, _atAmmoCargo]};

// GL Ammo & Grenades
if (_nadesCargo > 0) then {
	_vehicle addMagazineCargoGlobal [_40mike, _nadesCargo];
	_vehicle addMagazineCargoGlobal [_handgrenade, _nadesCargo];
	_vehicle addMagazineCargoGlobal ["Chemlight_green", _nadesCargo];
	_vehicle addMagazineCargoGlobal ["Chemlight_red", _nadesCargo];
	_vehicle addMagazineCargoGlobal ["SmokeShellGreen", _nadesCargo];
	_vehicle addMagazineCargoGlobal ["SmokeShellRed", _nadesCargo];	
	if ADF_mod_ACE3 then {
		_vehicle addItemCargoGlobal ["ACE_HuntIR_M203", 1];
		_vehicle addItemCargoGlobal ["ACE_HuntIR_monitor", 1];
		_vehicle addItemCargoGlobal ["ACE_M84", _nadesCargo];
		_vehicle addItemCargoGlobal ["ACE_HandFlare_White", _nadesCargo];
		_vehicle addItemCargoGlobal ["ACE_HandFlare_Red", _nadesCargo];
		_vehicle addItemCargoGlobal ["ACE_HandFlare_Green", _nadesCargo];
		_vehicle addItemCargoGlobal ["ACE_HandFlare_Yellow", _nadesCargo];
	};
};

// Demo/Explosives
_vehicle addMagazineCargoGlobal ["DemoCharge_Remote_Mag", _demoCargo];
_vehicle addMagazineCargoGlobal ["SatchelCharge_Remote_Mag", _demoCargo];
_vehicle addMagazineCargoGlobal ["ClaymoreDirectionalMine_Remote_Mag", _demoCargo];
if ADF_mod_ACE3 then {
	_vehicle addItemCargoGlobal ["ACE_Clacker", _demoItemsCargo];
	_vehicle addItemCargoGlobal ["ACE_Cellphone", 1];
	_vehicle addItemCargoGlobal ["ACE_M26_Clacker", _demoItemsCargo];
	_vehicle addItemCargoGlobal ["ACE_DefusalKit", 1];
	_vehicle addItemCargoGlobal ["ACE_wirecutter", 1];
};	

// ACRE / TFAR and cTAB
if ADF_mod_ACRE then {
	_vehicle addItemCargoGlobal ["ACRE_PRC343", _radioCargo];
	_vehicle addItemCargoGlobal ["ACRE_PRC148", 1];
};
if ADF_mod_TFAR then {
	_vehicle addItemCargoGlobal ["tf_anprc152", 1];
	_vehicle addItemCargoGlobal ["tf_rf7800str", _radioCargo];
	_vehicle addItemCargoGlobal ["tf_microdagr", _radioCargo];
	if (_radioCargo > 2) then {_vehicle addBackpackCargoGlobal ["tf_rt1523g", 1]};
};
if (ADF_mod_CTAB && {_cargo > 2}) then {
	_vehicle addItemCargoGlobal ["ItemcTab", 1];
	_vehicle addItemCargoGlobal ["ItemAndroid", 1];
	_vehicle addItemCargoGlobal ["ItemcTabHCam", 5];
};
if (!ADF_mod_ACRE && !ADF_mod_TFAR) then {_vehicle addItemCargoGlobal ["ItemRadio", _radioCargo]};

// ACE3 Specific	
if ADF_mod_ACE3 then {
	_vehicle addItemCargoGlobal ["ACE_EarPlugs", 5];
	_vehicle addItemCargoGlobal ["ace_mapTools", 2];
	_vehicle addItemCargoGlobal ["ACE_CableTie", 2];
	_vehicle addItemCargoGlobal ["ACE_UAVBattery", 1];	
	if (_cargo > 1) then {
		_vehicle addItemCargoGlobal ["ace_spottingscope", 1];				
		_vehicle addItemCargoGlobal ["ace_yardage450", 1];		
		_vehicle addItemCargoGlobal ["ace_dagr", 3];		
	};
	if (_cargo > 2) then {
		_vehicle addItemCargoGlobal ["ace_mx2a", 1];
		_vehicle addItemCargoGlobal ["ACE_TacticalLadder_Pack", 1];
		_vehicle addItemCargoGlobal ["ACE_Vector", 1];		
		_vehicle addItemCargoGlobal ["ACE_Kestrel4500", 1];		
		_vehicle addItemCargoGlobal ["ACE_RangeCard", 1];		
		_vehicle addItemCargoGlobal ["ACE_ATragMX", 1];		
		_vehicle addItemCargoGlobal ["ACE_TacticalLadder_Pack", 1];	
	};
};

// Medical Items
if ADF_mod_ACE3 then {
	_vehicle addItemCargoGlobal ["ACE_fieldDressing", _medCargo];
	_vehicle addItemCargoGlobal ["ACE_personalAidKit", _medCargo];
	_vehicle addItemCargoGlobal ["ACE_morphine", _medCargo];
	_vehicle addItemCargoGlobal ["ACE_epinephrine",_medCargo];
	_vehicle addItemCargoGlobal ["ACE_bloodIV", _medCargo];
	if (_cargo == 2) exitWith {
		_vehicle addItemCargoGlobal ["ACE_packingBandage", 10];
		_vehicle addItemCargoGlobal ["ACE_elasticBandage", 10];
		_vehicle addItemCargoGlobal ["ACE_quikclot", 10];
		_vehicle addItemCargoGlobal ["ACE_tourniquet", 2];
		_vehicle addItemCargoGlobal ["ACE_surgicalKit", 1];
		_vehicle addItemCargoGlobal ["ACE_atropine", 5];
		_vehicle addItemCargoGlobal ["ACE_bloodIV_500", 5];
		_vehicle addItemCargoGlobal ["ACE_bloodIV_250", 5];
		_vehicle addItemCargoGlobal ["ACE_plasmaIV", 2];
		_vehicle addItemCargoGlobal ["ACE_plasmaIV_500", 5];
		_vehicle addItemCargoGlobal ["ACE_plasmaIV_250", 5];
		_vehicle addItemCargoGlobal ["ACE_salineIV", 5];
		_vehicle addItemCargoGlobal ["ACE_salineIV_500", 5];
		_vehicle addItemCargoGlobal ["ACE_salineIV_250", 5];	
		_vehicle addItemCargoGlobal ["ACE_bodyBag", 2];
	};		
	if (_cargo == 3) exitWith {
		_vehicle addItemCargoGlobal ["ACE_packingBandage", 25];
		_vehicle addItemCargoGlobal ["ACE_elasticBandage", 25];
		_vehicle addItemCargoGlobal ["ACE_quikclot", 25];
		_vehicle addItemCargoGlobal ["ACE_tourniquet", 5];
		_vehicle addItemCargoGlobal ["ACE_surgicalKit", 1];
		_vehicle addItemCargoGlobal ["ACE_atropine", 10];
		_vehicle addItemCargoGlobal ["ACE_bloodIV_500", 10];
		_vehicle addItemCargoGlobal ["ACE_bloodIV_250", 10];
		_vehicle addItemCargoGlobal ["ACE_plasmaIV", 5];
		_vehicle addItemCargoGlobal ["ACE_plasmaIV_500", 10];
		_vehicle addItemCargoGlobal ["ACE_plasmaIV_250", 10];
		_vehicle addItemCargoGlobal ["ACE_salineIV", 5];
		_vehicle addItemCargoGlobal ["ACE_salineIV_500", 10];
		_vehicle addItemCargoGlobal ["ACE_salineIV_250", 10];	
		_vehicle addItemCargoGlobal ["ACE_bodyBag", 5];
	};	
} else {
	_vehicle addItemCargoGlobal ["FirstAidKit", _medCargo];
	_vehicle addItemCargoGlobal ["Medikit", 1];
};

// Gear
if (_uniformCargo > 0) then {_vehicle addItemCargoGlobal [_uniform, _uniformCargo]};
if (_vestCargo > 0) then {_vehicle addItemCargoGlobal [selectRandom _vest, _vestCargo]};
_vehicle addItemCargoGlobal [selectRandom _backpack, _backpackCargo];
_vehicle addItemCargoGlobal [selectRandom _opsCore, _opsCoreCargo];

// Misc
_vehicle addWeaponCargoGlobal ["B_UavTerminal", 1];
if (_cargo > 2) then {_vehicle addItemCargoGlobal ["ItemGPS", 1]};
if (_cargo > 1) then {_vehicle addItemCargoGlobal ["Laserbatteries", 1]};
if (_cargo > 2) then {_vehicle addItemCargoGlobal ["B_Static_Designator_01_weapon_F", 1]};
