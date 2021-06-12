/*********************************************************************************
 _____ ____  _____ 
|  _  |    \|   __|
|     |  |  |   __|
|__|__|____/|__|   
ARMA Mission Development Framework
ADF version: 2.26 / Jul 2020

Script: Crate Cargo Script (BLUEFOR) - Demolition
Author: Whiztler
Script version: 2.0

Game type: n/a
File: ADF_cCargo_B_Demo.sqf
**********************************************************************************
INSTRUCTIONS::

Paste below line in the INITIALIZATION box of the crate:
null = [this] execVM "mission\loadout\crates\ADF_cCargo_B_Demo.sqf";

You can comment out (//) lines of ammo you do not want to include
in the vehicle Cargo. 
*********************************************************************************/

if !isServer exitWith {};

waitUntil {time > 0 && !isNil "ADF_preInit"};

// Init
params ["_crate"];

_crate allowDamage false;
private _dem = 25;
private _itm = 5;

// Settings 
_crate call ADF_fnc_stripVehicle;

// Demo/Explosives
_crate addMagazineCargoGlobal ["DemoCharge_Remote_Mag", _dem];
_crate addMagazineCargoGlobal ["SatchelCharge_Remote_Mag", _dem];
_crate addMagazineCargoGlobal ["ATMine_Range_Mag", _dem];
_crate addMagazineCargoGlobal ["APERSBoundingMine_Range_Mag", _dem];
_crate addMagazineCargoGlobal ["APERSMine_Range_Mag", _dem];
_crate addMagazineCargoGlobal ["APERSTripMine_Wire_Mag", _dem];
_crate addMagazineCargoGlobal ["SLAMDirectionalMine_Wire_Mag", _dem];
_crate addMagazineCargoGlobal ["ClaymoreDirectionalMine_Remote_Mag", _dem];
_crate addItemCargoGlobal ["MineDetector", 2];
if ADF_mod_ACE3 then {
	_crate addItemCargoGlobal ["ACE_Clacker", _itm];
	_crate addItemCargoGlobal ["ACE_Cellphone", _itm];
	_crate addItemCargoGlobal ["ACE_M26_Clacker", _itm];
	_crate addItemCargoGlobal ["ACE_DeadManSwitch", _itm];
	_crate addItemCargoGlobal ["ACE_DefusalKit", _itm];
	_crate addItemCargoGlobal ["ACE_wirecutter", _itm];	
};


