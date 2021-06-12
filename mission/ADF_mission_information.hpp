/*********************************************************************************
 _____ ____  _____ 
|  _  |    \|   __|
|     |  |  |   __|
|__|__|____/|__|   
ARMA Mission Development Framework
ADF version: 2.26 / Jul 2020

Script: Mission Information
Author: Whiztler
Script version: 1.52

File: ADF_mission_information.hpp
**********************************************************************************
Filling out the ADF_mission_information is mandatory.
**********************************************************************************/


//###########################################################################
// Mission type settings
//###########################################################################

class Header {

	// GameType: Coop, ZCoop (Zeus Coop). See:
	// https://community.bistudio.com/wiki/Multiplayer_Game_Types for other
	// game types.
	gameType = Coop;
	
	// minPlayers. Leave as 1.
	minPlayers = 1;
	
	// MaxPlayers: Change to the exact amount of available player slots
	// including the total number of headless client slots.
	maxPlayers = 45;
	
	// playerCountMultipleOf: COOP setting is 1. Set to 0 for other game types.
	playerCountMultipleOf = 1; 

};

__EXEC (ADF_rootPath = __FILE__ select [0, count __FILE__ - 15])

//###########################################################################
// Mission Respawn & JIP Settings
//###########################################################################

// Respawn: 
// 0 - No respawn
// 1 - Spectator
// 2 - Instant respawn. Respawn at KIA location
// 3 - Respawn at base (respawn_west marker)
// 4 - Respawn in your group
// 5 - Respawn into an AI unit on your side
// Info: https://community.bistudio.com/wiki/Arma_3_Respawn#Respawn_Types
respawn	= 3; 

// respawnDelay: Respawn delay time in seconds..
respawnDelay = 30;

// RespawnDialog: Respawn dialog in case of multiple repsawn locations.
// 0 - false (no dialog)
// 1 - true (show dialog).
RespawnDialog = 0;

// respawnOnStart: Run the respawn script on start of the mission (inc
// JIP players). Available only for INSTANT and BASE respawn types.
// 	1 - Respawn on start. Run respawn script on start
// 0 - Dont respawn on start. Do run respawn script on start.
// -1 - Dont respawn on start. Do not run respawn script on start.
respawnOnStart = -1; 

// joinUnassigned: Auto assign players to an empty slot on mission start.
// 0 - forces joining players into the first empty slot
// 1 - leaves players to select their own slot.
joinUnassigned = 1;

// RespawnTemplates (for info:
// https://community.bistudio.com/wiki/Arma_3_Respawn#Respawn_Templates)
// Respawn tickets can be defined in ADF_mission_config.sqf

respawnTemplatesWest[] 	= {"Counter"}; // Ticket system enabled. Respawn in spectator when tickets are finished.
//respawnTemplateswest[]	= {"ADF_Spectator", "Seagull"}; // Ticket system enabled. Respawn in spectator when tickets are finished.
//respawnTemplates[] = {""Spectator", "Seagull"}; // No tickets, No respawn. JIP joins as spectator when respawn = 0. Set respawn = 4 to enable JIP
//respawnTemplates[] = {"ace_spectator"}; // Respawn enabled. when respawn =3 or respawn = 4 is selected.
//respawnTemplateseast[]	= {"Tickets", "ADF_Spectator", "Seagull"};
respawnTemplatesCiv[] = {"counter"};
//respawnTemplatesVirtual[]	= {};


//###########################################################################
// Mission loading screen information and params
//###########################################################################

// author: Name of the mission maker 
author = "Whiztler";

// briefingName: Mission name displayed in the mission selection menu.
briefingName = $STR_ADF_selection_briefingName;

// overviewText: Shown on the loadscreen. Enter short mission description here
overviewText = $STR_ADF_loadScreen_overviewText;

// onLoadName: Shown on the loadscreen. This is the mission title.
onLoadName = $STR_ADF_loadscreen_onLoadName;

// onLoadMission: Displays a message while the mission is loading.  this is the
// name you see when selecting a mission and also the name that is presented to
// the MultiPlayer browser. Enter a short description here. E.g.:
// "Day 04 - Operation Top Screen";
onLoadMission = $STR_ADF_loadscreen_onLoadMission;

// onLoadMission: Define whether you will see the time and date displayed while
// the intro loads.
// 1 - visible
// 0 - hidden.
onLoadIntroTime = false;

// onLoadMissionTime: Define whether you will see the time and date displayed
// while the intro loads.
onLoadMissionTime = false;

// loadScreen: You can define an image to be shown while the mission is loaded. 
loadScreen = "mission\images\loadScreen.jpg";
overviewPicture = "mission\images\loadScreen.paa";

// onLoadIntro: Displays a message while the intro is loading.
onLoadIntro = $STR_ADF_loadscreen_onLoadIntro;


//###########################################################################
// Mission restriction settings
//###########################################################################

// showGPS: Enables/disables the GPS functionality
// 0 - disable (no GPS allowed)
// 1 - enable (GPS allowed)
showGPS = 1;

// showCompass: Enables/disables the compass functionality
// 0 - disable (no compass allowed)
// 1 - enable (compass allowed)
showCompass = 1;

// showWatch: Enables/disables the watch functionality
// 0 - disable (no watch allowed)
// 1 - enable (watch allowed)
showWatch = 1;

// showMap - Enables/disables the map functionality
// 0 - disable (no map allowed)
// 1 - enable (map allowed)
showMap = 1;

// forceRotorLibSimulation: Force enable or disable RotorLib.
// 0 - options based
// 1 - force enable
// 2 - force disable
forceRotorLibSimulation = 0;

// disableChannels: Disable global, side, command and system chat. MOTD and
// admin say have exception and will show in global.
// 0 - Global
// 1 - Side
// 2 - Command
// 3 - Group
// 4 - Vehicle
// 5 - Direct
//6 - System
disableChannels[]={{1,  true,  false}, {2, true, true}, {3, false, false}, {4, false, false}, {5, false, false}};

// showGroupIndicator: Changes default GPS mini map into a radar like display
// that indicates group members relative position to the player.
// 0 - Disable
// 1 - Enable
showGroupIndicator = 0;

// disabledAI: Removes all playable units which do not have a human player.
// When 0, a logging out player will have AI take control of his character.
// Disabling all the AI units will prevent JIP into playable units.
// 0 - Disable
// 1 - Enable
disabledAI = 1;

// enableDebugConsole: Allows access to the Debug Console outside of the
// editor during normal gameplay.
// 0 - Default behavior, available only in editor
// 1 - Available for logged in admins
// 2 - Available for everyone
enableDebugConsole = 1;

// aiKills: Enables scorelist for AI players.
// 0 - Disable
// 1 - Enable
aiKills = 0;

enableItemsDropping = 0; // 0 = Disable, 1 = Enable
allowFunctionsLog = 0; // 0 = Disable, 1 = Enable


//###########################################################################
// Clean-up/garbage collection
//###########################################################################

// Note that ADF has a build-in clean-up function. When using the BIS function
// you should disable the ADF clean-up function (ADF_mission_settings.sqf).
// The BIS function is disAbled by default (0).

// corpseManagerMode: Sets the mode for corpse removal manager.
// 0 - None - None of the units are managed by the manager.
// 1 - All - All units are managed by the manager.
// 2 - None_But_Respawned - Only units that can respawn are managed by the manager.
// 3 - All_But_Respawned - All units are managed by the manager with exception of
//	  respawned (opposite to mode 2).
corpseManagerMode = 0;

// corpseLimit: Corpse limit before which ( <= ) corpseRemovalMaxTime applies
// and after which ( > ) corpseRemovalMinTime applies (see below).
corpseLimit = 15;

// corpseRemovalMinTime: Remove all bodies that have been dead longer than
// xx seconds when corpseLimit is breached.
corpseRemovalMinTime = 10;

// corpseRemovalMaxTime: Maximum time in seconds a corpse can remain on the
// ground if total number of corpses is equal or under corpseLimit.
corpseRemovalMaxTime = 3600;

// wreckManagerMode: Sets the mode for wreck removal manager.
// 0 - None - None of the vehicles are managed by the manager.
// 1 - All - All vehicles are managed by the manager.
// 2 - None_But_Respawned - Only vehicles that can respawn are managed by
//	  the manager.
// 3 - All_But_Respawned - All vehicles are managed by the manager with the
//	  exception of respawned (opposite to mode 2).
wreckManagerMode = 0;

// wreckLimit: Vehicle wreck limit before which ( <= ) wreckRemovalMaxTime
// applies and after which ( > ) wreckRemovalMinTime applies (see below).
wreckLimit = 15;

// wreckRemovalMinTime: Remove all wrecks that have existed longer than
// xx seconds when wreckLimit is breached.
wreckRemovalMinTime	= 10;

// wreckRemovalMaxTime: Maximum time in seconds a wreck can remain on the
// ground if total number of wrecks is equal or under wreckLimit.
wreckRemovalMaxTime	= 3500;

