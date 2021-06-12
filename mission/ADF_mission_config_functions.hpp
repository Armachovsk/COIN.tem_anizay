/*********************************************************************************
 _____ ____  _____ 
|  _  |    \|   __|
|     |  |  |   __|
|__|__|____/|__|   
ARMA Mission Development Framework
ADF version: 2.26 / Jul 2020

Script: mission config entries
Author: Whiztler
Script version: 1.69

File: ADF_mission_config_functions.hpp
*********************************************************************************
Mission config functions. Do not EDIT unless you know what you are doing!
*********************************************************************************/


/************** DO NOT EDIT unless you know what you are doing!  ****************/


class CfgFunctions {

	// ADF Framework Functions
	class ADF {
	
		class ai {
			file = "ADF\fnc\ai";
			class heliApproach{};
			class heliPilotAI{};
			class objectSimulation{};
			class surrender{};
			class takeCover{};
			class unitSetSkill{};
			class vehicleCrewAI{};
			class waypointCombat{};
			class weaponFlashlight{};
		};
		
		class ambient {
			file = "ADF\fnc\ambient";
			class ambientAirTraffic{};
			class ambientAnimals{};
			class ambientCombatManager{};
			class ambientFlare{};
			class floodLight{};
			class hangarLights{};
			class heliPadLights{};
			class lightPoint{};
		};

		class core {
			file = "ADF\fnc\core";
			class addToCurator{};
			class addWaypoint{};
			class debugMarkers{};
			class delWaypoint{};
			class simpleStats{};
			class statsReporting{};
		};
		
		class comm {
			file = "ADF\FNC\comm";
			class commDetect{};
		};		

		class defend {
			file = "ADF\fnc\defend";
			class defendArea{};
			class defendArea_HC{};
			class getTurrets{};
			class searchBuilding{};
			class setGarrison{};
			class setTurretGunner{};
		};

		class delete {
			file = "ADF\fnc\delete";
			class delete{};
			class deleteCrewedVehicles{};
			class deleteEntities{};
		};
		
		class distance {
			file = "ADF\fnc\distance";
			class calcTravelTime{};
			class checkClosest{};
			class checkDistance{};
			class countRadius{};
		};

		class effect {
			file = "ADF\fnc\effect";
			class carBombDetonate{};
			class iedDetonate{};
		};
		
		class event {
			file = "ADF\fnc\event";
			class onPlayerKilled{};
			class onPlayerRespawn{};
		};		
		
		class group {
			file = "ADF\fnc\group";
			class countGroups{};
			class countGroupsCustom{};
			class countUnits{};
			class countUnitsCustom{};
			class groupSetSkill{};
			class logGroup{};
			class logGroupCustom{};
			class setGroupID{};
		};

		class interface {
			file = "ADF\fnc\interface";
			class messageParser{};
			class searchIntel{};
			class typeWriter{};
		};

		class loadout {
			file = "ADF\fnc\loadout";
			class storeLoadout{};
			class stripUnit{};
			class stripVehicle{};
		};

		class log {
			file = "ADF\fnc\log";
			class log{};
			class messageLog{};
			class terminateScript{};
		};

		class marker {
			file = "ADF\fnc\marker";
			class createMarker{};
			class createMarkerLocal{};
			class objectMarker{};
			class objectMarkerArray{};
			class reMarker{};
		};
		
		class patrol {
			file = "ADF\fnc\patrol";
			class airPatrol{};
			class defendAreaPatrol{};
			class footPatrol{};
			class recallPatrol{};
			class sad{};
			class seaPatrol{};
			class vehiclePatrol{};
		};

		class players {
			file = "ADF\fnc\players";
			class disable3P{};
			class spectator{};
			class teleport{};
			class teleportTrigger{};
			class teleportToLeader{};		
			class undercover{};		
		};
		
		class position {
			file = "ADF\fnc\position";
			class allLocations{};
			class altitudeAcending{};
			class altitudeDescending{};
			class buildingPositions{};
			class checkPosition{};
			class getRelPos{};
			class isFlat{};
			class outsidePos{};
			class outsidePosUnit{};
			class positionArraySort{};
			class positionDebug{};
			class randomPos{};
			class randomPos_IED{};
			class randomPosInArea{};
			class randomPosMax{};
			class roadDir{};			
			class roadPos{};
			class roadSidePos{};
		};
		
		class sensor {
			file = "ADF\fnc\sensor";
			class createTrigger{};
			class detectSensor{};
			class sensor{};
		};
		
		class spawn {
			file = "ADF\fnc\spawn";
			class createAirPatrol{};
			class createAO{};
			class createCarBomb{};
			class createConvoy{};
			class createCrewedVehicle{};
			class createFootPatrol{};
			class createGarrison{};
			class createIED{};
			class createPara{};
			class createRooftopTurrets{};
			class createSAD{};
			class createSeaPatrol{};
			class createVehiclePatrol{};			
			class objectsGrabber{};			
			class SOD{};
		};
		
		class support {
			file = "ADF\fnc\support";
			class airSupport{};
			class cas{};
			class paraDrop{};
			class rrr{};
		};	
	};

	//Tonic's View Distance script config
	class TAW_VD {
		tag = "TAWVD";

		class Initialize {
			file = "ADF\ext\taw_vd";
			class stateTracker {
				ext = ".fsm";
				postInit = 1;
				headerType = -1;
			};
				
			class onSliderChanged {};
			class onTerrainChanged {};
			class updateViewDistance {};
			class openMenu {};
			class onChar {};
			class openSaveManager {};
			class onSavePressed {};
			class onSaveSelectionChanged {};
		};
	};
};