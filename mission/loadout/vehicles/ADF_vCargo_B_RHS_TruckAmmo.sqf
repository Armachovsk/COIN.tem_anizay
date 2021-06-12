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
null = [this] execVM "mission\loadout\vehicles\ADF_cCargo_B_RHS_TruckAmmo.sqf";

You can comment out (//) lines of ammo you do not want to include
in the vehicle Cargo. 
*********************************************************************************/

// Init
if !isServer exitWith {};
params ["_v"];

waitUntil {time > 0 && !isNil "ADF_preInit"};

// Settings 
_v call ADF_fnc_stripVehicle;

// Primary weapon
_v addWeaponCargoGlobal ["rhs_weap_m4a1_carryhandle", 1]; // R
_v addWeaponCargoGlobal ["rhsusf_weap_m1911a1", 1]; // Side arm
_v addItemCargoGlobal ["rhsusf_acc_ACOG_d", 1];
_v addItemCargoGlobal ["rhsusf_acc_ACOG2_USMC", 1];
_v addItemCargoGlobal ["rhsusf_acc_grip3", 1];
_v addItemCargoGlobal ["rhsusf_acc_ACOG_MDO", 1];

// Magazines primary weapon
_v addMagazineCargoGlobal ["rhs_mag_30Rnd_556x45_M855_Stanag", 250]; // M4
_v addMagazineCargoGlobal ["rhsusf_100Rnd_556x45_M855_soft_pouch", 25]; // M249
_v addMagazineCargoGlobal ["rhsusf_50Rnd_762x51", 25]; // M240
_v addMagazineCargoGlobal ["rhsusf_mag_10Rnd_STD_50BMG_M33", 15]; // M107
_v addMagazineCargoGlobal ["rhs_mag_30Rnd_556x45_M855_Stanag_Tracer_Red", 20]; // Tracer
_v addMagazineCargoGlobal ["rhsusf_mag_7x45acp_MHP", 25];// 1911 Side arm

// Launchers
_v addMagazineCargoGlobal ["rhs_fgm148_magazine_AT", 2];
_v addWeaponCargoGlobal ["rhs_weap_M136", 10];

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

// GL Ammo
_v addMagazineCargoGlobal ["rhs_mag_M441_HE", 55];
_v addMagazineCargoGlobal ["rhs_mag_M585_white", 25];
if ADF_mod_ACE3 then {
	_v addItemCargoGlobal ["ACE_HuntIR_M203", 10];
	_v addItemCargoGlobal ["ACE_HuntIR_monitor", 2];
};

// Grenades
_v addMagazineCargoGlobal ["rhs_mag_mk84", 50]; 	 
_v addMagazineCargoGlobal ["SmokeShellGreen", 50]; 	 
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
_v addItemCargoGlobal ["NVGoggles", 10];
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