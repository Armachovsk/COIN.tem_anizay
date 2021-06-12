/*********************************************************************************
 _____ ____  _____ 
|  _  |    \|   __|
|     |  |  |   __|
|__|__|____/|__|   
ARMA Mission Development Framework
ADF version: 2.26 / Jul 2020

Script: Crate Cargo Script (BLUEFOR) - SpecOps items/weapons (Wolf)
Author: Whiztler
Script version: 1.7

Game type: n/a
File: ADF_cCargo_B_WetGear.sqf
**********************************************************************************
INSTRUCTIONS::

Paste below line in the INITIALIZATION box of the crate:
null = [this] execVM "mission\loadout\crates\ADF_cCargo_B_WetGear.sqf";

You can comment out (//) lines of ammo you do not want to include
in the vehicle Cargo. 
*********************************************************************************/

if !isServer exitWith {};

waitUntil {time > 0 && !isNil "ADF_preInit"};

// Init
params ["_crate"];

_crate allowDamage false;
private _wpn = 10; 	// Regular Weapons
private _mag = 40;	// Magazines
private _uni = 10;	// Uniform/Vest/Backpack/etc

// Settings 
_crate call ADF_fnc_stripVehicle;

// Primary weapon
_crate addWeaponCargoGlobal ["arifle_SDAR_F", _wpn]; // Divers

// Magazines primary weapon
_crate addMagazineCargoGlobal ["30Rnd_556x45_Stanag", _mag]; // SDAR

// Diving Gear
_crate addBackpackCargoGlobal ["B_Carryall_mcamo", _uni];

_crate addItemCargoGlobal ["U_B_Wetsuit", _uni];
_crate addItemCargoGlobal ["G_Diving", _uni];
_crate addItemCargoGlobal ["V_RebreatherIR", _uni];	


