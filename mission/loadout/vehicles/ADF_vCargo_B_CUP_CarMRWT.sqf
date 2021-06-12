/*********************************************************************************
 _____ ____  _____ 
|  _  |    \|   __|
|     |  |  |   __|
|__|__|____/|__|   
ARMA Mission Development Framework
ADF version: 2.26 / Jul 2020

Script: Vehicle Cargo Script (BLUEFOR) - Car Marine Recon Weapons Team - CUP
Author: Whiztler
Script version: 1.0

Game type: n/a
File: ADF_vCargo_B_CUP_CarMRWT.sqf
**********************************************************************************
INSTRUCTIONS::

Paste below line in the INITIALIZATION box of the vehicle:
null = [this] execVM "mission\loadout\vehicles\ADF_vCargo_B_CUP_CarMRWT.sqf";

You can comment out (//) lines of ammo you do not want to include
in the vehicle Cargo. 
*********************************************************************************/

// Init
if !isServer exitWith {};
params ["_v"];

waitUntil {time > 0 && !isNil "ADF_preInit"};

// Settings 
_v call ADF_fnc_stripVehicle;

private _default = 6;

// Magazines primary weapon
_v addMagazineCargoGlobal ["CUP_30Rnd_556x45_Stanag", 10]; // M4
_v addMagazineCargoGlobal ["CUP_200Rnd_TE4_Red_Tracer_556x45_M249", 5]; // M249
_v addMagazineCargoGlobal ["CUP_100Rnd_TE4_LRT4_Red_Tracer_762x51_Belt_M", 10]; // MK 48
_v addMagazineCargoGlobal ["CUP_10Rnd_127x99_M107", 5]; // M107
_v addMagazineCargoGlobal ["CUP_15Rnd_9x19_M9", 4];// 1911 Side arm

// Launchers
_v addWeaponCargoGlobal ["CUP_launch_M136", 2];
_v addWeaponCargoGlobal ["CUP_launch_Javelin", 1];

// Missiles
_v addMagazineCargoGlobal ["CUP_M136_M", 2];
_v addMagazineCargoGlobal ["CUP_Javelin_M", 2];

// Demo/Explosives
_v addMagazineCargoGlobal ["DemoCharge_Remote_Mag", 1];

//_v addMagazineCargoGlobal ["SatchelCharge_Remote_Mag", 1];
//_v addMagazineCargoGlobal ["ClaymoreDirectionalMine_Remote_Mag", 1];
if ADF_mod_ACE3 then {
	_v addItemCargoGlobal ["ACE_Clacker", 1];
	//_v addItemCargoGlobal ["ACE_Cellphone", 1];
	//_v addItemCargoGlobal ["ACE_M26_Clacker", 1];
	//_v addItemCargoGlobal ["ACE_DefusalKit", 1];
	//_v addItemCargoGlobal ["ACE_wirecutter", 1];
};	

// GL Ammo
_v addMagazineCargoGlobal ["CUP_1Rnd_HEDP_M203", 6];
_v addMagazineCargoGlobal ["CUP_FlareWhite_M203", 2];
_v addMagazineCargoGlobal ["CUP_1Rnd_SmokeRed_M203", 2];
if ADF_mod_ACE3 then {
	_v addItemCargoGlobal ["ACE_HuntIR_M203", 1];
	_v addItemCargoGlobal ["ACE_HuntIR_monitor", 1];
};

// Grenades

_v addMagazineCargoGlobal ["SmokeShellGreen", 2]; 	 
_v addMagazineCargoGlobal ["SmokeShellRed", 1]; 
if ADF_mod_ACE3 then {
	_v addItemCargoGlobal ["ACE_HandFlare_White", 3];
	_v addItemCargoGlobal ["ACE_HandFlare_Red", 1];
	_v addItemCargoGlobal ["ACE_HandFlare_Green", 1];
	_v addItemCargoGlobal ["ACE_HandFlare_Yellow", 1];
	_v addItemCargoGlobal ["ACE_M84", 3];
} else {
	_v addMagazineCargoGlobal ["CUP_HandGrenade_M67", 3]; 	 
	_v addMagazineCargoGlobal ["Chemlight_green", _default]; 	 
	_v addMagazineCargoGlobal ["Chemlight_red", _default]; 	 
};

// ACRE / TFAR and cTAB
if ADF_mod_ACRE then {
	_v addItemCargoGlobal ["ACRE_PRC343", _default];
	_v addItemCargoGlobal ["ACRE_PRC148", 1];
};
if ADF_mod_TFAR then {
	_v addItemCargoGlobal ["tf_anprc152", 1];
	_v addItemCargoGlobal ["tf_rf7800str", _default];
	_v addItemCargoGlobal ["tf_microdagr", _default];
	_v addBackpackCargoGlobal ["tf_rt1523g", 1];
};
if (!ADF_mod_ACRE && !ADF_mod_TFAR) then {_v addItemCargoGlobal ["ItemRadio", _default]};

// ACE3 Specific	
if ADF_mod_ACE3 then {
	_v addItemCargoGlobal ["ACE_EarPlugs", _default];
	_v addItemCargoGlobal ["ace_mapTools", 2];
	_v addItemCargoGlobal ["ACE_CableTie", 2];
	//_v addItemCargoGlobal ["ACE_UAVBattery", 1];
	//_v addItemCargoGlobal ["ACE_TacticalLadder_Pack", 1];
};

// Medical Items
if ADF_mod_ACE3 then {
	_v addItemCargoGlobal ["ACE_fieldDressing", _default];
	_v addItemCargoGlobal ["ACE_personalAidKit", 1];
	_v addItemCargoGlobal ["ACE_morphine", 3];
	_v addItemCargoGlobal ["ACE_epinephrine", 2];
	_v addItemCargoGlobal ["ACE_bloodIV", 1];
} else {
	_v addItemCargoGlobal ["FirstAidKit", _default];
	_v addItemCargoGlobal ["Medikit", 1];
};

// Optical/Bino's/Goggles
_v addItemCargoGlobal ["CUP_Vector21Nite", 2];
if ADF_mod_ACE3 then {
	_v addItemCargoGlobal ["ACE_Vector", 1];		
};	

// Misc items
_v addItemCargoGlobal ["ToolKit", 1];