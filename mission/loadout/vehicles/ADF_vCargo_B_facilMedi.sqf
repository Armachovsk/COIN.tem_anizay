/*********************************************************************************
 _____ ____  _____ 
|  _  |    \|   __|
|     |  |  |   __|
|__|__|____/|__|   
ARMA Mission Development Framework
ADF version: 2.26 / Jul 2020

Script: Medical Facility/Vehicle Script (BLUEFOR) - Medical Truck/Ambulance
Author: Whiztler
Script version: 2.01

Game type: n/a
File: ADF_vCargo_B_facilMedi.sqf
**********************************************************************************
INSTRUCTIONS::

Paste below line in the INITIALIZATION box of the vehicle:
null = [this] execVM "mission\loadout\vehicles\ADF_vCargo_B_facilMedi.sqf";

You can comment out (//) lines of ammo you do not want to include
in the vehicle Cargo. 
*********************************************************************************/

// Init
if !isServer exitWith {};
params ["_v"];

waitUntil {time > 0 && !isNil "ADF_preInit"};

// Settings 
_v call ADF_fnc_stripVehicle;

// Grenades
_v addMagazineCargoGlobal ["SmokeShell", 25]; 	 
_v addMagazineCargoGlobal ["SmokeShellGreen", 50];
_v addMagazineCargoGlobal ["SmokeShellYellow", 10];
_v addMagazineCargoGlobal ["SmokeShellPurple", 10];
_v addMagazineCargoGlobal ["SmokeShellRed", 10];
_v addMagazineCargoGlobal ["SmokeShellBlue", 10];
_v addMagazineCargoGlobal ["SmokeShellOrange", 10];

// Medical Items
if ADF_mod_ACE3 then {
	_v addItemCargoGlobal ["ACE_fieldDressing", 150];
	_v addItemCargoGlobal ["ACE_packingBandage", 50];
	_v addItemCargoGlobal ["ACE_elasticBandage", 50];
	_v addItemCargoGlobal ["ACE_quikclot", 25];
	_v addItemCargoGlobal ["ACE_tourniquet", 25];
	_v addItemCargoGlobal ["ACE_surgicalKit", 5];
	_v addItemCargoGlobal ["ACE_personalAidKit", 25];
	_v addItemCargoGlobal ["ACE_morphine", 50];
	_v addItemCargoGlobal ["ACE_epinephrine", 50];
	_v addItemCargoGlobal ["ACE_atropine", 50];
	_v addItemCargoGlobal ["ACE_bloodIV", 25];
	_v addItemCargoGlobal ["ACE_bloodIV_500", 35];
	_v addItemCargoGlobal ["ACE_bloodIV_250", 50];
	_v addItemCargoGlobal ["ACE_plasmaIV", 25];
	_v addItemCargoGlobal ["ACE_plasmaIV_500", 35];
	_v addItemCargoGlobal ["ACE_plasmaIV_250", 50];
	_v addItemCargoGlobal ["ACE_salineIV", 25];
	_v addItemCargoGlobal ["ACE_salineIV_500", 35];
	_v addItemCargoGlobal ["ACE_salineIV_250", 50];	
	_v addItemCargoGlobal ["ACE_bodyBag", 50];	
	_v setVariable ["ace_medical_isMedicalFacility", true];
} else {
	_v addItemCargoGlobal ["FirstAidKit", 150];
	_v addItemCargoGlobal ["Medikit", 5];
};

// Gear kit 
_v addBackpackCargoGlobal ["B_AssaultPack_rgr_Medic", 3];