/*********************************************************************************
 _____ ____  _____ 
|  _  |    \|   __|
|     |  |  |   __|
|__|__|____/|__|   
ARMA Mission Development Framework
ADF version: 2.26 / Jul 2020

Script: Vehicle Cargo Script (BLUEFOR) - Ammunition Supply Truck
Author: Whiztler
Script version: 2.01

Game type: n/a
File: ADF_vCargo_B_TruckAmmo.sqf
**********************************************************************************
INSTRUCTIONS::

Paste below line in the INITIALIZATION box of the vehicle:
null = [this] execVM "mission\loadout\vehicles\ADF_cCargo_B_TruckAmmo.sqf";

You can comment out (//) lines of ammo you do not want to include
in the vehicle Cargo. 
*********************************************************************************/

// Init
if !isServer exitWith {};
params ["_v"];

waitUntil {time > 0 && !isNil "ADF_preInit"};

// start with an empty cargo
_v call ADF_fnc_stripVehicle;

///// VANILLA DEFAULT

// Primary weapon
private _ADF_INF_primaryWeapon	= "arifle_MX_Black_Hamr_pointer_F";
private _ADF_INF_primaryWeapon_lite = "arifle_MXC_Black_F";
private _ADF_INF_primaryWeapon_GL = "arifle_MX_GL_Black_Hamr_pointer_F";
private _ADF_INF_primaryWeapon_LMG = "LMG_Mk200_MRCO_F";
private _ADF_INF_primaryWeapon_MG = "MMG_02_black_RCO_BI_F";
private _ADF_INF_handWeapon = "hgun_P07_F";
private _ADF_INF_tube_Lite	= "launch_NLAW_F";
private _ADF_INF_tube_AT = "launch_B_Titan_short_F";
private _ADF_INF_tube_AA = "launch_B_Titan_F";

// Attachments
private _ADF_INF_primaryWeaponAttScope = "optic_Aco";
private _ADF_INF_primaryWeaponAttScope_LMG = "optic_MRCO";
private _ADF_INF_primaryWeaponAttLight = "acc_pointer_IR";
private _ADF_INF_primaryWeaponAttLight_LMG = "acc_pointer_IR";

// Ammunition
private _ADF_INF_primaryWeaponMag = "30Rnd_65x39_caseless_mag";
private _ADF_INF_primaryWeaponMag_LMG = "200Rnd_65x39_cased_Box_Tracer";
private _ADF_INF_primaryWeaponMag_MG = "130Rnd_338_Mag";
if ADF_mod_ACE3 then {
	_ADF_INF_primaryWeaponMag = "ACE_30Rnd_65x39_caseless_mag_Tracer_Dim";
	_ADF_INF_primaryWeaponMag_LMG=  "ACE_200Rnd_65x39_cased_Box_Tracer_Dim";
};	

private _ADF_INF_handWeapon_mag = "16Rnd_9x21_Mag";
private _ADF_INF_tubeMag_Lite = "NLAW_F";
private _ADF_INF_tubeMag_AT = "Titan_AT";
private _ADF_INF_tubeMag_AA = "Titan_AA";
private _ADF_INF_40mike = "1Rnd_HE_Grenade_shell";
private _ADF_INF_handgrenade = "HandGrenade";

// Misc
private _backpack = ["B_AssaultPack_cbr"];
private _nvg = "NVGoggles_OPFOR";

///// MODDED

if (ADF_modded || {ADF_mod_RHS}) then {
	call {
		if ADF_mod_RHS exitWith {
			_nvg = "rhsusf_ANPVS_15";

			// Primary weapon - RHS
			_ADF_INF_primaryWeapon = "rhs_weap_hk416d145";
			_ADF_INF_primaryWeapon_lite = "rhs_weap_hk416d10_LMT";			
			_ADF_INF_primaryWeapon_GL = "rhs_weap_hk416d145_m320";
			_ADF_INF_primaryWeapon_LMG = "rhs_weap_m249_pip_S";
			_ADF_INF_handWeapon = "rhsusf_weap_m1911a1";
			_ADF_INF_tube_Lite = "rhs_weap_M136";
			_ADF_INF_tube_AT = "rhs_weap_fgm148";
			_ADF_INF_tube_AA = "rhs_weap_fim92";

			// Attachments _ RHS
			_ADF_INF_primaryWeaponAttScope = "rhsusf_acc_eotech_552";
			_ADF_INF_primaryWeaponAttScope_LMG = "rhsusf_acc_ACOG2_USMC";
			_ADF_INF_primaryWeaponAttLight = "rhsusf_acc_anpeq15_bk";
			_ADF_INF_primaryWeaponAttLight_LMG = "rhsusf_acc_anpeq15side_bk";

			// Ammunition - RHS
			_ADF_INF_primaryWeaponMag = "rhs_mag_30Rnd_556x45_M855A1_Stanag";
			_ADF_INF_primaryWeaponMag_LMG = "rhsusf_200Rnd_556x45_box";
			_ADF_INF_handWeapon_mag = "rhsusf_mag_7x45acp_MHP";
			_ADF_INF_tubeMag_Lite = "rhs_m136_mag";
			_ADF_INF_tubeMag_AT = "rhs_fgm148_magazine_AT";
			_ADF_INF_tubeMag_AA = "rhs_fim92_mag";
			_ADF_INF_40mike = "rhs_mag_M441_HE";
			_ADF_INF_handgrenade = "rhs_mag_m67";			

		};
		if ADF_mod_CUP_U exitWith {
			// Primary weapon - CUP
			_ADF_INF_primaryWeapon = "CUP_arifle_HK416_Black";
			_ADF_INF_primaryWeapon_lite = "CUP_arifle_HK416_CQB_Black";			
			_ADF_INF_primaryWeapon_GL = "CUP_arifle_HK416_CQB_M203_Black";
			_ADF_INF_primaryWeapon_LMG = "CUP_lmg_minimi";
			_ADF_INF_handWeapon = "CUP_hgun_Colt1911";
			_ADF_INF_tube_Lite = "CUP_launch_Mk153Mod0";
			_ADF_INF_tube_AT = "CUP_launch_Javelin";
			_ADF_INF_tube_AA = "CUP_launch_FIM92Stinger";

			// Attachments _ CUP
			_ADF_INF_primaryWeaponAttScope = "CUP_optic_TrijiconRx01_black";
			_ADF_INF_primaryWeaponAttScope_LMG = "CUP_optic_ACOG2";
			_ADF_INF_primaryWeaponAttLight = "CUP_acc_ANPEQ_15_Flashlight_Black_L";
			_ADF_INF_primaryWeaponAttLight_LMG = "CUP_acc_ANPEQ_2";

			// Ammunition - CUP
			_ADF_INF_primaryWeaponMag = "CUP_30Rnd_556x45_PMAG_QP";
			_ADF_INF_primaryWeaponMag_LMG = "CUP_200Rnd_TE4_Red_Tracer_556x45_M249";

			_ADF_INF_handWeapon_mag = "CUP_7Rnd_45ACP_1911";
			_ADF_INF_tubeMag_Lite = "CUP_SMAW_HEAA_M";
			_ADF_INF_tubeMag_AT = "Chemlight_green";
			_ADF_INF_tubeMag_AA = "Chemlight_green";
			_ADF_INF_40mike = "1Rnd_HE_Grenade_shell";
			_ADF_INF_handgrenade = "CUP_HandGrenade_M67";			
	
			if ADF_mod_CFP exitWith {_nvg = "CFP_ANPVS15_Black";};
			if ADF_mod_CUP_U exitWith {_nvg = "CUP_NVG_PVS15_black";};			
		};
	};		
};


///// LOAD CARGO

// Primary weapon
_v addWeaponCargoGlobal [_ADF_INF_primaryWeapon_GL, 1]; // GL
_v addWeaponCargoGlobal [_ADF_INF_primaryWeapon_LMG, 1]; // LMG
_v addWeaponCargoGlobal [_ADF_INF_primaryWeapon_MG, 1]; // MG
_v addWeaponCargoGlobal [_ADF_INF_primaryWeapon, 10];

// Secondary weapon
_v addWeaponCargoGlobal [_ADF_INF_handWeapon, 3];

// Magazines primary weapon
_v addMagazineCargoGlobal [_ADF_INF_primaryWeaponMag, 100];
_v addMagazineCargoGlobal [_ADF_INF_primaryWeaponMag_LMG, 100]; // LMG
_v addMagazineCargoGlobal [_ADF_INF_primaryWeaponMag_MG, 50]; // MG

// Magazines secondary weapon
_v addMagazineCargoGlobal [_ADF_INF_handWeapon_mag, 20];

// Launchers
_v addWeaponCargoGlobal [_ADF_INF_tube_Lite, 5];
_v addWeaponCargoGlobal [_ADF_INF_tube_AT, 2];
_v addWeaponCargoGlobal [_ADF_INF_tube_AA, 2];

// Rockets/Missiles
if (!ADF_mod_ACE3 && !ADF_modded) then {_v addMagazineCargoGlobal ["NLAW_F", 10]};
_v addMagazineCargoGlobal [_ADF_INF_tubeMag_AT, 10];
_v addMagazineCargoGlobal [_ADF_INF_tubeMag_AA, 5];

// Demo/Explosives
_v addMagazineCargoGlobal ["DemoCharge_Remote_Mag", 15];
_v addMagazineCargoGlobal ["SatchelCharge_Remote_Mag", 10];
_v addMagazineCargoGlobal ["ATMine_Range_Mag", 15];
_v addMagazineCargoGlobal ["APERSBoundingMine_Range_Mag", 15];
if ADF_mod_ACE3 then {
	_v addItemCargoGlobal ["ACE_Clacker", 10];
	_v addItemCargoGlobal ["ACE_DefusalKit", 5];
	_v addItemCargoGlobal ["ACE_M26_Clacker", 5]; 
	_v addItemCargoGlobal ["ACE_wirecutter", 3];
};	

// Weapon mountings
// Weapon mountings
if ADF_mod_ACE3 then {
	_v addItemCargoGlobal [_ADF_INF_primaryWeaponAttLight, 10];
	_v addItemCargoGlobal ["acc_flashlight", 10];	
	_v addItemCargoGlobal ["ACE_optic_Hamr_2D", 5];
	_v addItemCargoGlobal ["ACE_optic_Hamr_PIP", 5];
	_v addItemCargoGlobal ["ACE_optic_Arco_2D", 5];
	_v addItemCargoGlobal ["ACE_optic_Arco_PIP", 5];
	_v addItemCargoGlobal ["ACE_optic_MRCO_2D", 5];
	// Sniper/Marksman
	_v addItemCargoGlobal ["ACE_optic_SOS_2D", 2];
	_v addItemCargoGlobal ["ACE_optic_SOS_PIP", 2];
	_v addItemCargoGlobal ["ACE_optic_LRPS_2D", 2];	
	_v addItemCargoGlobal ["ACE_optic_LRPS_PIP", 2];	
} else {
	_v addItemCargoGlobal [_ADF_INF_primaryWeaponAttLight, 10];
	_v addItemCargoGlobal ["acc_flashlight", 10];
	_v addItemCargoGlobal [_ADF_INF_primaryWeaponAttScope, 5];
	_v addItemCargoGlobal ["optic_NVS", 5];
	_v addItemCargoGlobal [_ADF_INF_primaryWeaponAttScope_LMG, 5];

};
if ADF_mod_ACE3 then {
	_v addItemCargoGlobal ["ACE_muzzle_mzls_H", 5];  
	_v addItemCargoGlobal ["ACE_muzzle_mzls_B", 5];  	
	_v addItemCargoGlobal ["ACE_muzzle_mzls_L", 5];	 
	_v addItemCargoGlobal ["ACE_muzzle_mzls_smg_01", 5];  
	_v addItemCargoGlobal ["ACE_muzzle_mzls_smg_02", 5];	 	
};
// GL Ammo
_v addMagazineCargoGlobal ["3Rnd_HE_Grenade_shell", 25];
_v addMagazineCargoGlobal ["3Rnd_Smoke_Grenade_shell", 25];
_v addMagazineCargoGlobal ["3Rnd_UGL_FlareCIR_F", 25];
if ADF_mod_ACE3 then {
	_v addItemCargoGlobal ["ACE_HuntIR_M203", 10];
	_v addItemCargoGlobal ["ACE_HuntIR_monitor", 2];
};

// Grenades
_v addMagazineCargoGlobal [_ADF_INF_handgrenade, 50]; 	 
_v addMagazineCargoGlobal ["SmokeShell", 50]; 	 
_v addMagazineCargoGlobal ["SmokeShellGreen", 25]; 	 
_v addMagazineCargoGlobal ["SmokeShellRed", 25];
if ADF_mod_ACE3 then {
	_v addItemCargoGlobal ["ACE_HandFlare_White", 25];
	_v addItemCargoGlobal ["ACE_HandFlare_Red", 15];
	_v addItemCargoGlobal ["ACE_HandFlare_Green", 15];
	_v addItemCargoGlobal ["ACE_HandFlare_Yellow", 15];
	_v addItemCargoGlobal ["ACE_M84", 15];
}; 

// ACRE / TFAR and cTAB
if ADF_mod_ACRE then {
	_v addItemCargoGlobal ["ACRE_PRC343", 25];
	_v addItemCargoGlobal ["ACRE_PRC148", 5];
};
if ADF_mod_TFAR then {
	_v addItemCargoGlobal ["tf_anprc152", 25];
	//_v addItemCargoGlobal ["tf_rt1523g", 3];
	_v addBackpackCargoGlobal ["tf_rt1523g", 5];
};
if (!ADF_mod_ACRE && !ADF_mod_TFAR) then {_v addItemCargoGlobal ["ItemRadio", 25]};
if ADF_mod_CTAB then {
	//_v addItemCargoGlobal ["ItemAndroid", 5];
	//_v addItemCargoGlobal ["ItemcTab", 1];
	_v addItemCargoGlobal ["ItemcTabHCam", 25];
};

// ACE3 Specific	
if ADF_mod_ACE3 then {
	_v addItemCargoGlobal ["ACE_EarPlugs", 50];
	_v addItemCargoGlobal ["ace_mapTools", 10];
	_v addItemCargoGlobal ["ACE_CableTie", 50];
	_v addItemCargoGlobal ["ACE_UAVBattery", 5];
	_v addItemCargoGlobal ["ACE_TacticalLadder_Pack", 3];
};

// Medical Items
if ADF_mod_ACE3 then {
	_v addItemCargoGlobal ["ACE_fieldDressing", 10];
	_v addItemCargoGlobal ["ACE_personalAidKit", 1];
	_v addItemCargoGlobal ["ACE_morphine", 5];
	_v addItemCargoGlobal ["ACE_epinephrine", 5];
	_v addItemCargoGlobal ["ACE_bloodIV", 2];
} else {
	_v addItemCargoGlobal ["FirstAidKit", 10];
	_v addItemCargoGlobal ["Medikit", 1];
};

// Optical/Bino's/Goggles
_v addWeaponCargoGlobal ["Rangefinder", 2];
_v addWeaponCargoGlobal ["Binocular", 10];
_v addItemCargoGlobal ["G_Tatical_Clear", 5];
_v addItemCargoGlobal ["G_Shades_Black" , 5];
_v addItemCargoGlobal [_nvg, 10];
if ADF_mod_ACE3 then {
	_v addItemCargoGlobal ["ACE_Vector", 5];		
};

// Gear kit (not working from crates/veh)
_v addBackpackCargoGlobal ["B_Carryall_Base", 10];
_v addBackpackCargoGlobal ["B_AssaultPack_blk", 10];
_v addBackpackCargoGlobal ["B_Kitbag_mcamo", 5];

// Misc items
_v addItemCargoGlobal ["ItemGPS", 10];

// Misc items
_v addItemCargoGlobal ["ToolKit", 2];