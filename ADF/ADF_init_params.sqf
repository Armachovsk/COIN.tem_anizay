/*********************************************************************************
 _____ ____  _____ 
|  _  |    \|   __|
|     |  |  |   __|
|__|__|____/|__|   
ARMA Mission Development Framework
ADF version: 2.26 / Jul 2020

Script: Mission pre-init params
Author: Whiztler
Script version: 1.01

File: ADF_init_params.sqf
**********************************************************************************
DO NOT edit this file. To set-up and configure your mission, edit the files in
the  '\mission\'  folder.
*********************************************************************************/

// Reporting
diag_log "ADF rpt: Init - executing: ADF_init_params.sqf";

////////////////// HEADLESS CLIENT

// Headless Client Load Balancing
ADF_headless = if (("ADF_HC_enable" call BIS_fnc_getParamValue) == 1) then {true} else {false};

// Headless Client Load Balancing
ADF_HCLB = if (("ADF_HCLB_enable" call BIS_fnc_getParamValue) == 1) then {true} else {false};

////////////////// DEBUG & REPORTING

// Debug
ADF_Debug = if (("ADF_debug_enable" call BIS_fnc_getParamValue) == 1) then {true} else {false};

// Extensive Reporting
ADF_extRpt = if (("ADF_extRpt_enable" call BIS_fnc_getParamValue) == 1) then {true} else {false};

////////////////// PERFORMANCE

// Environment (Ambient)
ADF_AmbientEnv = if (("ADF_AmbientEnv_enable" call BIS_fnc_getParamValue) == 1) then {true} else {false};

// Environment (Sound)
 ADF_AmbientSnd = if (("ADF_AmbientSnd_enable" call BIS_fnc_getParamValue) == 1) then {true} else {false};
 
 ////////////////// EQUIPMENT
 
 // Thermal Imaging in vehicles
if ((("ADF_tie_disable" call BIS_fnc_getParamValue) == 0) && isServer) then {{_x disableTIEquipment true} forEach vehicles};

 // Thermal Imaging in vehicles
if ((("ADF_nvg_disable" call BIS_fnc_getParamValue) == 0) && isServer) then {{_x disableNVGEquipment true} forEach vehicles};

 // Same gear respawn (ACE/ADF)
ADF_sameGearRespawn = if (("ADF_sameGear_enable" call BIS_fnc_getParamValue) == 1) then {true} else {false};

 // Force first person (Except in vehicles)
ADF_disable3PC = if (("ADF_disable3PC_enable" call BIS_fnc_getParamValue) == 1) then {true} else {false};

 // Force first person (Also in vehicles)
ADF_disable3PV = if (("ADF_disable3PV_enable" call BIS_fnc_getParamValue) == 1) then {true} else {false};
