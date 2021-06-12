/*********************************************************************************
 _____ ____  _____ 
|  _  |    \|   __|
|     |  |  |   __|
|__|__|____/|__|   
ARMA Mission Development Framework
ADF version: 2.26 / Jul 2020

Script: Mission Settings
Author: Whiztler
Script version: 2.19

Game type: n/a
File: ADF_mission_settings.sqf
*********************************************************************************
Use this script to configure framework and mission settings.
*********************************************************************************/

diag_log "ADF rpt: Init - executing: ADF_mission_settings.sqf";

/********** GENERAL **********/
ADF_mission_version = "0.92 beta"; // Mission version
_ADF_mission_init_time = 70; // Mission Init time counter. Min 30 secs. Add 1 sec per 2 players. 10 players = 35 secs.
ADF_playerSide = west; // Which side are playable units on [west / east / GUER / CIV]
ADF_clanName = "BCO"; // What is the name of your community/clan. Used in Hints, intro's etc.
ADF_clanTAG = "1ST RECON BN BCO"; // What is the tag of your community/clan. Used in Hints, intro's etc.
ADF_clanLogo = "mission\images\intro_coin.paa"; // Full path to the clan logo. 
ADF_clanFlag = ""; // Full path to the clan flag (dimensions 512 x 256, pref PAA format).
_ADF_MissionIntroImage = "mission\images\intro_coin.paa"; // Full path to the mission intro image (dimensions: 2038 x 1024, PAA format only). 
ADF_uniformInsignia = true; // Apply custom clan insignia on uniform. Define in the description.ext [true/false]. 
_ADF_preset = "1STRECON"; // pre-defined call sign/radio freq presets. [DEFAULT / SHAPE / NOPRYL / CUSTOM]. Configure the presets in 'ADF\modules\ADF_fnc_presets.sqf'
_ADF_briefingName = "ADF_briefing.sqf"; // Name of the briefing file (in '\mission\')
ADF_undercoverPlayers = false; // Enable or diable undercover ability. Can be manually started for selected players through scripting

/********** COMMS **********/
// TFAR
_ADF_TFAR_microDAGR = false; // enable/add the TFAR MicroDAGR [true/false]
ADF_TFAR_preset = true; // Preset TFAR freq's per group? Define in 'ADF\library\ADF_TFAR-freq.sqf'. [true/false].
// ACRE
_ADF_ACRE_fullDuplex = true; // Sets the duplex of radio transmissions. If set to true, it means that you will receive transmissions even while talking and multiple people can speak at the same time. [true/false].
_ADF_ACRE_interference = true; // Sets whether transmissions will interfere with each other. This, by default, causes signal loss when multiple people are transmitting on the same frequency. [true/false].
_ADF_ACRE_AIcanHear = true; // Sets whether AI can detect players speaking. [true/false].
ADF_ACRE_preset = false; // Preset ACRE freq's per group? Define in 'ADF\library\ADF_ACRE-freq.sqf'. [true/false].

/********** UNIT/VEHICLE CACHING **********/
_ADF_Caching = true; // // Enable/disable caching of units and vehicles. Auto Disabled when HC is active. [true/false].
_ADF_Caching_unitDistance = 1000; // AI Unit caching distance default = 1000 meters.
_ADF_Caching_vehicleDistance_land = 250; // Cars caching distance default = 250 meters.
_ADF_Caching_vehicleDistance_air = 1500; // aircraft caching distance default = 250 meters.
_ADF_Caching_vehicleDistance_sea = 2000; // boats caching distance default = 250 meters.
_ADF_Caching_debugInfo = false; // Show caching debug info in ADF_debug mode

/********** VIEW DISTANCE **********/
setViewDistance 1500; // Default view distance.
ADF_VD_foot = 2000; // Maximum view distance on foot.
ADF_VD_vehicle = 3000; // Maximum view distance in a vehicle.
ADF_VD_air = 7500; // Maximum view distance when airborne.
ADF_VD_allowNoGrass = false; // Set 'false' if you want to disable "Low" option for terrain [true/false].

/********** F.A.R.P. REPAIR/REFUEL/REARM **********/
ADF_FARP_repairTime = 300; // Maximum time in seconds it takes to repair a vehicle at the FARP.
ADF_FARP_reloadTime = 30; // Maximum time in seconds it takes to re-arm per turret magazine at the FARP.
ADF_FARP_refuelTime = 120; // Maximum time in seconds it takes to refuel a vehicle at the FARP.

/********** RESPAWN / MOBILE HQ (MOBILE RESPAWN FOB) **********/
ADF_Tickets = false; // enable respawn tickets [true/false]. Make sure to configure in description.ext as well!!
_ADF_wTixNr = 10; // Respawn Tickets. Number available respawns for west Blufor.
_ADF_eTixNr = 15; // Respawn Tickets. Number available respawns for east Opfor.

_ADF_mhq_enable = false; // enable the MHQ function [true/false].
_ADF_mhq_respawn_nr = 3; // Number of MHQ vehicle respawn available.
_ADF_mhq_respawn_time = 15; // MHQ vehicle respawn time in minutes.
_ADF_mhq_respawn_class = "B_APC_Tracked_01_CRV_F"; // MHQ vehicle classname (default is the 'Bobcat').
_ADF_mhq_deploy_time = 120; // MHQ deployment time in seconds.
_ADF_mhq_packup_time = 180; // MHQ packup time in seconds.

/********** THIRD PARTY MODS/SCRIPTS **********/
// Garbage collector
_ADF_CleanUp = true; // enable cleaning up of dead bodies (friendly, enemy, vehicles, etc.) [true/false].
_ADF_CleanUp_viewDist = 500; // min distance in meter from a player unit to allow delete, if you dont care if player sees the delete, set it to 0.
_ADF_CleanUp_manTimer = 300; // x seconds until delete of dead man units.
_ADF_CleanUp_vehTimer = 600; // x seconds until delete of dead vehicles, for destroyed and heavy damaged vehicles.
_ADF_CleanUp_abaTimer = 6000; // x seconds a vehicle must be unmanned to be deleted, for _abandoned option.

/********** MISC SETTINGS **********/
_ADF_altitude = false; // Enable altitude based fatigue (altitude mountain sickness)? True increases fatigue when > 1500 meter altitude [true/false].

enableSaving [false, false]; // Disables saving progress.
enableEngineArtillery false; // Disables BIS arty (map click).
enableTeamSwitch false; // Disables team switch.

/********** ADF DEV BUILD SETTINGS **********/
ADF_tpl_version = "2.26"; // ADF version DO NOT EDIT