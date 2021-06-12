/*********************************************************************************
 _____ ____  _____ 
|  _  |    \|   __|
|     |  |  |   __|
|__|__|____/|__|   
ARMA Mission Development Framework
ADF version: 2.26 / Jul 2020

Script: mission config entries
Author: Whiztler
Script version: 1.51

File: ADF_mission_config_insignia.hpp
**********************************************************************************
Here you can define a custom arm patch/insignia.

More information: https://community.bistudio.com/wiki/Description.ext#CfgUnitInsignia
*********************************************************************************/

class CfgUnitInsignia {
	
	// CLAN insignia	
	class FIRSTRECON {
		displayName = "1ST RECON BN BCO"; // Name displayed in Arsenal
		author = "ADF / Whiztler";
		texture = "mission\images\patch_1strecon.paa";
		textureVehicles	= ""; // Does nothing currently, reserved for future use
	};

	class HMLA {
		displayName = "3RD MAW 267"; // Name displayed in Arsenal
		author = "ADF / Whiztler";
		texture = "mission\images\patch_hmla267.paa";
		textureVehicles	= ""; // Does nothing currently, reserved for future use
	};
	class TKA1 {
		displayName = "TKA 1 INF DIV"; // Name displayed in Arsenal
		author = "ADF / Whiztler";
		texture = "mission\images\patch_tka1inf.paa";
		textureVehicles	= ""; // Does nothing currently, reserved for future use
	};			
};