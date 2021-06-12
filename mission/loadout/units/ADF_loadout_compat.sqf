/*********************************************************************************
 _____ ____  _____ 
|  _  |    \|   __|
|     |  |  |   __|
|__|__|____/|__|   
ARMA Mission Development Framework
ADF version: 2.26 / Jul 2020

Script: Custom uniform texture
Author: Whiztler
Script version: 1.10

Game type: COOP
File: ADF_loadout_compat.sqf
*********************************************************************************
Used exclusively by the server to apply textures globally
*********************************************************************************/

if (ADF_clanName == "Two Sierra" && {!ADF_modded}) then {
	[] spawn {
		if isMultiplayer then {ADF_uArray = playableUnits;} else {ADF_uArray = switchableUnits};
		sleep 20; // wait till units have geared up
		private _t = if (toUpper worldName == "CHERNARUS_SUMMER" || toUpper worldName == "WOODLAND_ACR") then {"\a3\characters_f\BLUFOR\Data\clothing_wdl_co.paa"} else {"\a3\characters_f\BLUFOR\Data\clothing_sage_co.paa"};
		{_x setObjectTextureGlobal [0, _t]} forEach ADF_uArray; 
		ADF_uArray = nil;
	};
};
if (ADF_clanName == "Wolfpack" && {!ADF_modded && {ADF_wolfpack_nite_op}}) then {
	[] spawn {
		if isMultiplayer then {ADF_uArray = playableUnits;} else {ADF_uArray = switchableUnits};
		sleep 20; // wait till units have geared up
	
		{_x setObjectTextureGlobal [0, "\A3\Characters_F\Common\Data\basicbody_black_co.paa"]} forEach ADF_uArray; 
		ADF_uArray = nil;
	};
};
