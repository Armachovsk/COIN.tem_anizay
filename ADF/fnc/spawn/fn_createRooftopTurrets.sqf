/*********************************************************************************
 _____ ____  _____ 
|  _  |    \|   __|
|     |  |  |   __|
|__|__|____/|__|   
ARMA Mission Development Framework
ADF version: 2.26 / Jul 2020

Function: Create rooftop turrets
Author: Whiztler
Script version: 1.01
Diag: 

File: fn_createRooftopTurrets.sqf
**********************************************************************************
ABOUT
This function will spawn a number of turrets on rooftops of predetermined
buildings. The potential turret positions of each building are predetermined. the
position does not interfere with existing building positions that can be used by
AI for garrison purpose etc.

CUSTIMIZATION
The function does not require a lot of parameters; a center location, and a radius
as to how far out it should scan for suitable buildings.
You can determine the number of turrets or the function can calculate based on the
radius and the number of buildings found within the radius.
The default turret is ARMA Vanilla "B_HMG_01_high_F" .50 cal turret. You can pass
a string with a custom turret (e.g. RHS "rhs_KORD_high_MSV") or you can pass an
array of turrets and then a random turret will be used for each location.

WIP
Currently the function has only been configured for Middle-Eastern buildings.

INSTRUCTIONS:
Execute (spawn) from the server or headless client.

REQUIRED PARAMETERS:
0: Position:       position. Scan position. Marker, object or position [x,y,z].

OPTIONAL PARAMETERS:
1: Integer:        Radius in meters that will be used to scan for suitable 
                   buildings with rooftops. Default: 500
2. Integer/Bool:   Number of turrets that need to be created:
                   - integer e.g. 20
				   - true (default) automatically determine the number of turrets
				     to be created based on radius and nr of availabe buildings.
				   
3. String/Array:   Class (string) or classes (array of classes) of the turret to
                   be created. in case of an array of turret classes a random
                   turret from the array will be selected.
                   Default: "B_HMG_01_high_F"

EXAMPLES USAGE IN SCRIPT:
["myMarker", 250, true, "rhs_KORD_high_MSV"] spawn ADF_fnc_createRooftopTurrets;

EXAMPLES USAGE IN EDEN:
0 = [position this, 750, "rhs_KORD_high_MSV"] spawn ADF_fnc_createRooftopTurrets;

DEFAULT/MINIMUM OPTIONS
["myMarker"] spawn ADF_fnc_createRooftopTurrets;

RETURNS:
Array of turrets
*********************************************************************************/

// init
_diag_time = diag_tickTime;
params [
	["_centerPosition", [0, 0, 0], ["", objNull, locationNull, []]],
	["_radius", 500, [0, []]],
	["_turretCount", true, [0, false]],
	["_turretClass", "B_HMG_01_high_F", ["", []]],
	["_allQualifiedBuildings", [], [[]]],
	["_turrets", [], [[]]],
	["_exit", false, [true]]
];		
if (_centerPosition isEqualType "" && {!(_centerPosition in allMapMarkers)}) exitWith {[format ["ADF_fnc_createRoofTurrets - %1 does not appear to be a valid marker. Exiting", _centerPosition], true] call ADF_fnc_log;};
private _position = [_centerPosition] call ADF_fnc_checkPosition;

_allTurretBuildings = switch ADF_worldTheme do {
	case "EasternEuropean"; 
	case "European": {_exit = true};
	case "Tropical";
	case "MiddleEastern": {
		// Middle Eastern buildings with turrent positions (BIS / CUP / JBAD / FFAA). Created with ADF_fnc_objectsMapper
		[
			["Land_Mil_ControlTower_EP1", [[_turretClass,[9.82178,5.5293,9.15],45,1,0,[0,0],"","",true,false], [_turretClass,[5.47461,2.60596,13.05],270,1,0,[0,0],"","",true,false]]],
			["Land_Mil_ControlTower_dam_EP1", [[_turretClass,[9.82178,5.5293,9.15],45,1,0,[0,0],"","",true,false], [_turretClass,[5.47461,2.60596,13.05],270,1,0,[0,0],"","",true,false]]],
			["Land_Mil_ControlTower_no_interior_EP1_CUP", [[_turretClass,[9.82178,5.5293,9.15],45,1,0,[0,0],"","",true,false], [_turretClass,[5.47461,2.60596,13.05],270,1,0,[0,0],"","",true,false]]],
			["Land_Mil_ControlTower_no_interior_dam_EP1_CUP", [[_turretClass,[9.82178,5.5293,9.15],45,1,0,[0,0],"","",true,false], [_turretClass,[5.47461,2.60596,13.05],270,1,0,[0,0],"","",true,false]]],
			["Land_Dum_istan4", [[_turretClass,[6.28906,5.90234,12.115],45,1,0,[0,0],"","",true,false], [_turretClass,[-2.53369,-5.4707,15.23],225,1,0,[0,0],"","",true,false]]],
			["jbad_dum_istan4", [[_turretClass,[6.28906,5.90234,12.115],45,1,0,[0,0],"","",true,false], [_turretClass,[-2.53369,-5.4707,15.23],225,1,0,[0,0],"","",true,false]]],
			["Land_Dum_istan4_big", [[_turretClass,[-5.80029,6.39844,0.1],270,1,0,[0,0],"","",true,false], [_turretClass,[6.56396,5.9502,0.1],90,1,0,[0,0],"","",true,false], [_turretClass,[-5.66797,-5.48682,18.135],2225,1,0,[0,0],"","",true,false]]],
			["Land_Dum_istan2_02", [[_turretClass,[-1.7002,0.266113,-0.0682855],270,1,0,[0,0],"","",true,false], [_turretClass,[-1.56738,0.201172,3.35],270,1,0,[0,0],"","",true,false]]],
			["Land_Dum_istan2_04a", [[_turretClass,[-5.47998,-2.51367,6.625],135,1,0,[0,0],"","",true,false], [_turretClass,[-2.51855,6.36279,6.625],225,1,0,[0,0],"","",true,false]]],
			["Land_Dum_istan2_03", [[_turretClass,[-3.91895,4.68262,7.20],325,1,0,[0,0],"","",true,false], [_turretClass,[-0.516113,0.25293,13.963],180,1,0,[0,0],"","",true,false]]],
			["Land_Dum_istan2_03a", [[_turretClass,[-3.91895,4.68262,7.20],325,1,0,[0,0],"","",true,false], [_turretClass,[-0.516113,0.25293,13.963],180,1,0,[0,0],"","",true,false]]],
			["Land_Dum_istan4_detaily1", [[_turretClass,[-5.77637,6.20508,0.07],270,1,0,[0,0],"","",true,false], [_turretClass,[6.70459,5.91602,0.07],90,1,0,[0,0],"","",true,false], [_turretClass,[6.60791,1.31494,12.12],135,1,0,[0,0],"","",true,false]]],
			["Land_Dum_istan4_big_inverse", [[_turretClass,[5.65479,5.96973,0.07],90,1,0,[0,0],"","",true,false], [_turretClass,[-6.63379,6.46387,0.07],270,1,0,[0,0],"","",true,false]]],
			["Land_Dum_istan3_hromada", [[_turretClass,[2.22168,-1.3335,5.89],90,1,0,[0,0],"","",true,false], [_turretClass,[-5.14697,4.96289,5.89],270,1,0,[0,0],"","",true,false]]],
			["Land_House_C_10_EP1", [[_turretClass,[-2.75293,3.67334,0.08],270,1,0,[0,0],"","",true,false], [_turretClass,[1.69971,6,9.485],180,1,0,[0,0],"","",true,false]]],
			["jbad_House_c_10", [[_turretClass,[-2.75293,3.67334,0.08],270,1,0,[0,0],"","",true,false], [_turretClass,[1.69971,6,9.485],180,1,0,[0,0],"","",true,false]]],
			["Land_House_C_11_EP1", [[_turretClass,[-4.68311,-3.47461,2.77],225,1,0,[0,0],"","",true,false]]],
			["jbad_House_c_11", [[_turretClass,[-4.68311,-3.47461,2.77],225,1,0,[0,0],"","",true,false]]],
			["Land_Dum_istan3_pumpa", [[_turretClass,[-1.88818,-1.54395,3.37],0,1,0,[0,0],"_3_37_D0","",true,false], [_turretClass,[3.56689,-2.52637,3.37],180,1,0,[0,0],"","",true,false]]],
			["Land_House_C_5_EP1", [[_turretClass,[-3.34717,0.265137,2.97],315,1,0,[0,0],"","",true,false]]],
			["jbad_House_c_5", [[_turretClass,[-3.34717,0.265137,2.97],315,1,0,[0,0],"","",true,false]]],
			["Land_House_C_5_V1_EP1", [[_turretClass,[-3.34717,0.265137,2.97],315,1,0,[0,0],"","",true,false]]],
			["jbad_House_c_5_v1", [[_turretClass,[-3.34717,0.265137,2.97],315,1,0,[0,0],"","",true,false]]],
			["Land_House_C_5_V2_EP1", [[_turretClass,[-3.34717,0.265137,2.97],315,1,0,[0,0],"","",true,false]]],
			["jbad_House_c_5_v2", [[_turretClass,[-3.34717,0.265137,2.97],315,1,0,[0,0],"","",true,false]]],
			["Land_House_C_5_V3_EP1", [[_turretClass,[-3.34717,0.265137,2.97],315,1,0,[0,0],"","",true,false]]],
			["jbad_House_c_5_v3", [[_turretClass,[-3.34717,0.265137,2.97],315,1,0,[0,0],"","",true,false]]],
			["Land_Dum_istan2", [[_turretClass,[-2.56201,-4.56348,3.13],180,1,0,[0,0],"","",true,false], [_turretClass,[5.77441,-3.00488,3.13],90,1,0,[0,0],"","",true,false], [_turretClass,[-18.4502,16.9297,6.1],45,1,0,[0,0],"","",true,false]]],
			["jbad_dum_istan2", [[_turretClass,[-2.56201,-4.56348,3.13],180,1,0,[0,0],"","",true,false], [_turretClass,[5.77441,-3.00488,3.13],90,1,0,[0,0],"","",true,false], [_turretClass,[-18.4502,16.9297,6.1],45,1,0,[0,0],"","",true,false]]],
			["Land_Dum_istan2b", [[_turretClass,[-2.56201,-4.56348,3.13],180,1,0,[0,0],"","",true,false], [_turretClass,[5.77441,-3.00488,3.13],90,1,0,[0,0],"","",true,false], [_turretClass,[-18.4502,16.9297,6.1],45,1,0,[0,0],"","",true,false]]],
			["Land_Dum_mesto3_istan", [[_turretClass,[-2.9873,8.97217,4.12],0,1,0,[0,0],"","",true,false], [_turretClass,[-3.22949,-8.93652,4.12],180,1,0,[0,0],"","",true,false]]],
			["Land_Dum_istan3", [[_turretClass,[3.53076,-2.12012,6.1],135,1,0,[0,0],"","",true,false], [_turretClass,[-8.34521,-0.961914,3.1],270,1,0,[0,0],"","",true,false], [_turretClass,[9.84814,0.566895,3.1],45,1,0,[0,0],"","",true,false]]],
			["Land_Dum_istan3_hromada2", [[_turretClass,[-6.88428,1.81885,3.375],270,1,0,[0,0],"","",true,false], [_turretClass,[0.381348,3.94336,6.75],0,1,0,[0,0],"","",true,false], [_turretClass,[14.5693,-10.5537,6.75],90,1,0,[0,0],"","",true,false]]],
			["Land_A_Villa_EP1", [[_turretClass,[-6.81934,3.69336,0.14],270,1,0,[0,0],"","",true,false], [_turretClass,[-4.4502,-4.7749,7.33],225,1,0,[0,0],"","",true,false], [_turretClass,[-4.86475,-3.98584,7.33],225,1,0,[0,0],"","",true,false], [_turretClass,[7.56592,-17.5508,0.14],225,1,0,[0,0],"","",true,false], [_turretClass,[17.6416,2.26904,7.32],45,1,0,[0,0],"","",true,false], [_turretClass,[2.71875,17.6362,7.32],45,1,0,[0,0],"","",true,false], [_turretClass,[7.54395,-17.4297,7.32],225,1,0,[0,0],"","",true,false], [_turretClass,[-17.9131,8.13232,7.32],225,1,0,[0,0],"","",true,false]]],
			["Jbad_A_Villa", [[_turretClass,[-6.81934,3.69336,0.14],270,1,0,[0,0],"","",true,false], [_turretClass,[-4.4502,-4.7749,7.33],225,1,0,[0,0],"","",true,false], [_turretClass,[-4.86475,-3.98584,7.33],225,1,0,[0,0],"","",true,false], [_turretClass,[7.56592,-17.5508,0.14],225,1,0,[0,0],"","",true,false], [_turretClass,[17.6416,2.26904,7.32],45,1,0,[0,0],"","",true,false], [_turretClass,[2.71875,17.6362,7.32],45,1,0,[0,0],"","",true,false], [_turretClass,[7.54395,-17.4297,7.32],225,1,0,[0,0],"","",true,false], [_turretClass,[-17.9131,8.13232,7.32],225,1,0,[0,0],"","",true,false]]],
			["Land_A_Villa_dam_EP1", [[_turretClass,[-6.81934,3.69336,0.14],270,1,0,[0,0],"","",true,false], [_turretClass,[-4.4502,-4.7749,7.33],225,1,0,[0,0],"","",true,false], [_turretClass,[-4.86475,-3.98584,7.33],225,1,0,[0,0],"","",true,false], [_turretClass,[7.56592,-17.5508,0.14],225,1,0,[0,0],"","",true,false], [_turretClass,[17.6416,2.26904,7.32],45,1,0,[0,0],"","",true,false], [_turretClass,[2.71875,17.6362,7.32],45,1,0,[0,0],"","",true,false], [_turretClass,[7.54395,-17.4297,7.32],225,1,0,[0,0],"","",true,false], [_turretClass,[-17.9131,8.13232,7.32],225,1,0,[0,0],"","",true,false]]],
			["Land_House_C_4_EP1", [[_turretClass,[-5.85303,-2.82031,3.71],180,1,0,[0,0],"","",true,false], [_turretClass,[4.47754,3.68164,6.85],45,1,0,[0,0],"","",true,false]]],
			["jbad_House_c_4", [[_turretClass,[-5.33838,-2.68701,3.71],180,1,0,[-0.0408432,0.0499517],"","",true,false], [_turretClass,[5.47559,3.45459,6.86],45,1,0,[0,0],"","",true,false]]],
			["Land_A_Office01_EP1", [[_turretClass,[-2.93018,-3.74219,0.363],180,1,0,[0,0],"","",true,false], [_turretClass,[-7.83545,5.40234,5.354],0,1,0,[0,0],"","",true,false], [_turretClass,[-9.81104,-4.83154,2.86],180,1,0,[0,0],"","",true,false], [_turretClass,[1.65576,2.79785,11.086],0,1,0,[0,0],"","",true,false], [_turretClass,[11.0425,-3.73877,5.353],180,1,0,[0,0],"","",true,false]]],
			["Land_A_BuildingWIP_EP1", [[_turretClass,[0.139648,11.1504,8.375],0,1,0,[0,0],"","",true,false], [_turretClass,[13.6216,-0.911621,8.35],0,1,0,[0,0],"","",true,false], [_turretClass,[-0.17627,11.3506,12.305],0,1,0,[0,0],"","",true,false], [_turretClass,[6.14258,-10.2515,12.29],180,1,0,[0,0],"","",true,false], [_turretClass,[14.9316,-9.15283,8.34],180,1,0,[0,0],"","",true,false], [_turretClass,[-17.1416,-12.9868,8.34],270,1,0,[0,0],"","",true,false], [_turretClass,[-24.2876,-3.88574,8.35],270,1,0,[0,0],"","",true,false], [_turretClass,[-21.9814,11.186,8.38],0,1,0,[0,0],"","",true,false]]],
			["Jbad_A_BuildingWIP", [[_turretClass,[0.139648,11.1504,8.375],0,1,0,[0,0],"","",true,false], [_turretClass,[13.6216,-0.911621,8.35],0,1,0,[0,0],"","",true,false], [_turretClass,[-0.17627,11.3506,12.305],0,1,0,[0,0],"","",true,false], [_turretClass,[6.14258,-10.2515,12.29],180,1,0,[0,0],"","",true,false], [_turretClass,[14.9316,-9.15283,8.34],180,1,0,[0,0],"","",true,false], [_turretClass,[-17.1416,-12.9868,8.34],270,1,0,[0,0],"","",true,false], [_turretClass,[-24.2876,-3.88574,8.35],270,1,0,[0,0],"","",true,false], [_turretClass,[-21.9814,11.186,8.38],0,1,0,[0,0],"","",true,false]]],
			["Land_Ind_Coltan_Main_EP1", [[_turretClass,[4.39453,-10.3594,9.11],38,1,0,[0,0],"","",true,false], [_turretClass,[6.7627,16.5439,11.55],270,1,0,[0,0],"","",true,false]]],
			["Land_Ind_Oil_Tower_EP1", [[_turretClass,[-1.34229,0.881348,8.28],0,1,0,[0,0],"","",true,false], [_turretClass,[6.7666,-6.34033,5.32],180,1,0,[0,0],"","",true,false]]],
			["Land_fortified_nest_small_EP1", [[_turretClass,[-0.138672,0.299316,0.02],180,1,0,[0,0],"","",true,false]]],
			["Land_Fort_Watchtower_EP1", [["rhs_KORD_MSV",[-0.0209961,2.26416,2.78],0,1,0,[0,0],"","",true,false], [_turretClass,[-0.812988,-2.0293,2.8],180,1,0,[0,0],"","",true,false]]],
			["Land_Mil_House_EP1", [[_turretClass,[-1.79053,3.6748,9.08],90,1,0,[0,0],"","",true,false], [_turretClass,[-14.7822,-6.58203,8.92],270,1,0,[0,0],"","",true,false]]],
			["Jbad_Mil_House", [[_turretClass,[-1.79053,3.6748,9.08],90,1,0,[0,0],"","",true,false], [_turretClass,[-14.7822,-6.58203,8.92],270,1,0,[0,0],"","",true,false]]],
			["Land_Mil_House_no_interior_EP1_CUP", [[_turretClass,[-1.79053,3.6748,9.08],90,1,0,[0,0],"","",true,false], [_turretClass,[-14.7822,-6.58203,8.92],270,1,0,[0,0],"","",true,false]]],
			["Land_Mil_House_no_interior_dam_EP1_CUP", [[_turretClass,[-0.142578,4.97461,9.11],90,1,0,[0,0],"","",true,false], [_turretClass,[-13.1489,-5.29492,8.98],270,1,0,[0,0],"","",true,false]]],
			["Land_A_Mosque_big_hq_EP1", [[_turretClass,[-9.75928,10.7139,10.07],270,1,0,[0,0],"","",true,false], [_turretClass,[10.5186,-10.7407,10.07],90,1,0,[0,0],"","",true,false]]],
			["Land_A_Mosque_big_wall_corner_EP1", [[_turretClass,[4.83447,3.81104,7.6],45,1,0,[0,0],"","",true,false]]],
			["Land_A_Stationhouse_ep1", [[_turretClass,[0.8125,-6.49316,5.02],180,1,0,[0,0],"","",true,false], [_turretClass,[0.999023,3.26416,9.02],0,1,0,[0,0],"","",true,false], [_turretClass,[-16.6758,-4.53613,9.02],270,1,0,[0,0],"","",true,false], [_turretClass,[18.9541,-6.70801,5.02],130,1,0,[0,0],"","",true,false], [_turretClass,[-2.63574,-7.87402,18.02],180,1,0,[0,0],"","",true,false]]],
			["Land_a_stationhouse", [[_turretClass,[0.8125,-6.49316,5.02],180,1,0,[0,0],"","",true,false], [_turretClass,[0.999023,3.26416,9.02],0,1,0,[0,0],"","",true,false], [_turretClass,[-16.6758,-4.53613,9.02],270,1,0,[0,0],"","",true,false], [_turretClass,[18.9541,-6.70801,5.02],130,1,0,[0,0],"","",true,false], [_turretClass,[-2.63574,-7.87402,18.02],180,1,0,[0,0],"","",true,false]]],
			["Jbad_A_Stationhouse", [[_turretClass,[0.8125,-6.49316,5.02],180,1,0,[0,0],"","",true,false], [_turretClass,[0.999023,3.26416,9.02],0,1,0,[0,0],"","",true,false], [_turretClass,[-16.6758,-4.53613,9.02],270,1,0,[0,0],"","",true,false], [_turretClass,[18.9541,-6.70801,5.02],130,1,0,[0,0],"","",true,false], [_turretClass,[-2.63574,-7.87402,18.02],180,1,0,[0,0],"","",true,false]]],
			["Land_House_C_9_EP1", [[_turretClass,[-3.65137,-3.82422,6.61],230,1,0,[0,0],"","",true,false]]],
			["jbad_House_c_9", [[_turretClass,[-3.65137,-3.82422,6.61],230,1,0,[0,0],"","",true,false]]],
			["Land_House_C_3_EP1", [[_turretClass,[-1.11621,-2.73438,9.56],340,1,0,[0,0],"","",true,false], [_turretClass,[-6.49072,-2.87012,8.41],180,1,0,[0,0],"","",true,false]]],
			["jbad_House_c_3", [[_turretClass,[-1.11621,-2.73438,9.56],340,1,0,[0,0],"","",true,false], [_turretClass,[-6.49072,-2.87012,8.41],180,1,0,[0,0],"","",true,false]]],
			["Land_House_C_2_EP1", [[_turretClass,[2.66406,-1.23926,0.13],180,1,0,[0,0],"","",true,false], [_turretClass,[1.62207,-4.66553,3.44],110,1,0.0368518,[0,0],"","",true,false]]],
			["jbad_House_c_2", [[_turretClass,[2.66406,-1.23926,0.13],180,1,0,[0,0],"","",true,false], [_turretClass,[1.62207,-4.66553,3.44],110,1,0.0368518,[0,0],"","",true,false]]],
			["Land_House_C_1_EP1", [[_turretClass,[-0.226074,-3.87891,0.02],180,1,0,[0,0],"","",true,false], [_turretClass,[3.67041,-2.66016,0.11],180,1,0,[0,0],"","",true,false], [_turretClass,[7.95703,0.629883,0.13],0,1,0,[0,0],"","",true,false]]],
			["jbad_House_c_1", [[_turretClass,[-0.226074,-3.87891,0.02],180,1,0,[0,0],"","",true,false], [_turretClass,[3.67041,-2.66016,0.11],180,1,0,[0,0],"","",true,false], [_turretClass,[7.95703,0.629883,0.13],0,1,0,[0,0],"","",true,false]]],
			["Land_House_C_1_v2_EP1", [[_turretClass,[-0.0791016,-2.47998,0.02],180,1,0,[0,0],"","",true,false], [_turretClass,[3.63867,-1.5498,0.11],180,1,0,[0,0],"","",true,false], [_turretClass,[7.78857,2.13477,0.11],0,1,0,[0,0],"","",true,false]]],
			["jbad_House_c_1_v2", [[_turretClass,[-0.0791016,-2.47998,0.02],180,1,0,[0,0],"","",true,false], [_turretClass,[3.63867,-1.5498,0.11],180,1,0,[0,0],"","",true,false], [_turretClass,[7.78857,2.13477,0.11],0,1,0,[0,0],"","",true,false]]],
			["Land_House_L_3_EP1", [[_turretClass,[-3.2793,1.13281,3.07],90,1,0,[0,0],"","",true,false]]],
			["jbad_House_3_old", [[_turretClass,[-3.2793,1.13281,3.07],90,1,0,[0,0],"","",true,false]]],
			["Land_House_L_3_H_EP1", [[_turretClass,[-3.2793,1.13281,3.07],90,1,0,[0,0],"","",true,false]]],
			["jbad_House_3_old_h", [[_turretClass,[-3.2793,1.13281,3.07],90,1,0,[0,0],"","",true,false]]],
			["Land_House_L_6_EP1", [[_turretClass,[-2.55273,0.138184,3.01],270,1,0,[0,0],"","",true,false]]],
			["jbad_House6", [[_turretClass,[-2.55273,0.138184,3.01],270,1,0,[0,0],"","",true,false]]],
			["Land_House_K_8_EP1", [[_turretClass,[-1.35303,3.67578,3.18],270,1,0,[0,0],"","",true,false], [_turretClass,[0.899414,-0.0317383,6.41],120,1,0.026205,[0,0],"","",true,false]]],
			["jbad_House8", [[_turretClass,[-1.35303,3.67578,3.18],270,1,0,[0,0],"","",true,false], [_turretClass,[0.899414,-0.0317383,6.41],120,1,0.026205,[0,0],"","",true,false]]],
			["Land_House_K_6_EP1", [[_turretClass,[-2.61279,-2.19141,3.68],180,1,0,[0,0],"","",true,false], [_turretClass,[-6.02441,5.85107,0.61],270,1,0,[0,0],"","",true,false], [_turretClass,[-4.13184,-1.2876,6.58],270,1,0,[0,0],"","",true,false]]],
			["Land_House_K_3_EP1", [[_turretClass,[1.45166,0.712402,4.19],180,1,0,[0,0],"","",true,false]]],
			["jbad_House3", [[_turretClass,[1.45166,0.712402,4.19],180,1,0,[0,0],"","",true,false]]],
			["Land_House_K_7_EP1", [[_turretClass,[-7.75293,1.52686,3.81],180,1,0,[0,0],"","",true,false]]],
			["jbad_House7", [[_turretClass,[-7.75293,1.52686,3.81],180,1,0,[0,0],"","",true,false]]],
			["Land_Terrace_K_1_EP1", [[_turretClass,[-5.8916,-6.75146,5.83],240,1,0,[0,0],"","",true,false]]],
			["jbad_terrace_R", [[_turretClass,[-5.8916,-6.75146,5.83],240,1,0,[0,0],"","",true,false]]],
			["Land_Letistni_hala", [[_turretClass,[2.76172,-3.88574,12.52],180,1,0,[0,0],"","",true,false]]],
			["Land_Ind_TankBig", [[_turretClass,[-0.455078,-5.67969,10.02],180,1,0,[0,0],"","",true,false]]],
			["Land_Tovarna2", [[_turretClass,[-5.27881,8.88721,10.89],0,1,0,[0,0],"","",true,false], [_turretClass,[1.25732,-8.55078,12.32],120,1,0,[0,0],"","",true,false]]],
			["Land_Garaz_s_tankem", [[_turretClass,[-6.5127,-0.400879,6.08],180,1,0,[0,0],"","",true,false], [_turretClass,[7.55957,4.75195,6.08],90,1,0,[0,0],"","",true,false]]],
			["Land_Garaz_bez_tanku", [[_turretClass,[-6.5127,-0.400879,6.08],180,1,0,[0,0],"","",true,false], [_turretClass,[7.55957,4.75195,6.08],90,1,0,[0,0],"","",true,false]]],
			["Land_Hlaska", [["Land_Pallet_F",[-0.00292969,0.898926,6.92],0,1,0,[0,0],"","",true,false], [_turretClass,[0.260254,0.651855,7.11],0,1,0,[0,0],"","",true,false]]],
			["Land_Hotel_riviera1", [[_turretClass,[2.71631,8.27686,6.7],0,1,0,[0,0],"","",true,false], [_turretClass,[-12.9888,0.274902,3.09],340,1,0,[0,0],"","",true,false]]],
			["Land_Hotel_riviera2", [[_turretClass,[-1.18262,7.41748,6.7],0,1,0,[0,0],"","",true,false]]],
			["Land_House_C_12_EP1", [[_turretClass,[-2.64258,1.00464,3.84],315,1,0,[0,0],"","",true,false], [_turretClass,[2.35449,-5.64868,7.18],90,1,0,[0,0],"","",true,false]]],
			["jbad_House_c_12", [[_turretClass,[-2.64258,1.00464,3.84],315,1,0,[0,0],"","",true,false], [_turretClass,[2.35449,-5.64868,7.18],90,1,0,[0,0],"","",true,false]]],
			["land_ffaa_casa_barrancon_1", [[_turretClass,[-14.1816,6.99219,3.65],310,1,0,[0,0],"","",true,false], [_turretClass,[14.6895,-7.13013,3.69],130,1,0,[0,0],"","",true,false]]],
			["land_ffaa_casa_af_1", [[_turretClass,[3.08984,-3.35986,6.1],135,1,0,[0,0],"","",true,false]]],
			["land_ffaa_casa_af_2", [[_turretClass,[4.34766,-1.88721,0.03],180,1,0,[0,0],"","",true,false], [_turretClass,[-4.33984,-2.09351,0.04],180,1,0,[0,0],"","",true,false]]],
			["land_ffaa_casa_af_3", [[_turretClass,[4.34766,-1.88721,0.03],180,1,0,[0,0],"","",true,false], [_turretClass,[-4.33984,-2.09351,0.04],180,1,0,[0,0],"","",true,false]]],
			["land_ffaa_casa_af_3A", [[_turretClass,[4.34766,-1.88721,0.03],180,1,0,[0,0],"","",true,false], [_turretClass,[-4.33984,-2.09351,0.04],180,1,0,[0,0],"","",true,false]]],
			["land_ffaa_casa_af_4", [[_turretClass,[4.78418,-1.5979,2.92],180,1,0,[0,0],"","",true,false]]],
			["land_ffaa_casa_af_4A", [[_turretClass,[4.78418,-1.5979,2.92],180,1,0,[0,0],"","",true,false]]],
			["land_ffaa_casa_af_4A", [[_turretClass,[4.78418,-1.5979,2.92],180,1,0,[0,0],"","",true,false]]],
			["land_ffaa_casa_af_5", [["Land_Pallet_F",[1.95313,-1.02295,6.45],0,1,0,[0,0],"","",true,false], ["Land_Pallet_F",[6.06543,-1.65698,6.46],0,1,0,[0,0],"","",true,false],[_turretClass,[5.55762,-1.67773,6.65],90,1,0,[0,0],"","",true,false]]],
			["land_ffaa_casa_af_9", [[_turretClass,[-4.33984,-3.26392,0.79],180,1,0,[0,0],"","",true,false], [_turretClass,[1.84082,2.62061,4.41],90,1,0,[0,0],"","",true,false]]],
			["land_ffaa_casa_urbana_1", [[_turretClass,[-1.42676,-2.29736,0.17],180,1,0,[0,0],"","",true,false], [_turretClass,[3.93945,-2.26904,0.18],180,1,0,[0,0],"","",true,false], [_turretClass,[-6.64746,-2.27515,0.15],180,1,0,[0,0],"","",true,false]]],
			["land_ffaa_casa_urbana_2", [[_turretClass,[2.73633,-1.37793,0.38],180,1,0,[0,0],"","",true,false]]],
			["land_ffaa_casa_urbana_3", [[_turretClass,[1.18652,-3.13086,0.19],180,1,0,[0,0],"","",true,false]]],
			["land_ffaa_casa_urbana_4", [[_turretClass,[0.147461,-3.32251,0.28],180,1,0,[0,0],"","",true,false], [_turretClass,[0.0292969,-3.43018,3.47],180,1,0,[0,0],"","",true,false], [_turretClass,[-9.11328,-2.34131,0.25],110,1,0,[0,0],"","",true,false], [_turretClass,[9.81641,-3.39673,0.3],180,1,0,[0,0],"","",true,false], [_turretClass,[9.53906,-3.4646,3.49],180,1,0,[0,0],"","",true,false], [_turretClass,[10.792,0.217529,6.49],90,1,0,[0,0],"","",true,false], [_turretClass,[-10.4395,-3.10596,6.46],220,1,0,[0,0],"","",true,false]]],
			["land_ffaa_casa_urbana_5", [[_turretClass,[-2.46289,-4.38428,6.35],180,1,0.0207767,[0,0],"","",true,false], [_turretClass,[1.41406,-5.12769,9.61],180,1,0,[0,0],"","",true,false], [_turretClass,[6.3125,7.85596,6.4],45,1,0,[0,0],"","",true,false]]],
			["land_ffaa_casa_urbana_6", [[_turretClass,[4.32422,-8.79224,0.31],180,1,0,[0,0],"","",true,false],[_turretClass,[-7.30664,-9.13354,7.48],180,1,0,[0,0],"","",true,false], [_turretClass,[-7.40332,-9.01978,11.03],180,1,0,[0,0],"","",true,false], [_turretClass,[13.0566,-8.81958,15.04],130,1,0,[0,0],"","",true,false], [_turretClass,[-14.584,-8.48486,15.01],230,1,0,[0,0],"","",true,false]]],
			["land_ffaa_casa_urbana_7", [[_turretClass,[1.08594,-3.99414,0.09],180,1,0,[0,0],"","",true,false], [_turretClass,[-5.2793,2.86011,0.02],0,1,0,[0,0],"","",true,false], [_turretClass,[4.88281,3.62207,3.09],2,1,0,[0,0],"","",true,false], [_turretClass,[6.5791,-4.35962,6.13],130,1,0,[0,0],"","",true,false]]],
			["land_ffaa_casa_urbana_7A", [[_turretClass,[-0.0107422,2.96265,0.02],0,1,0,[0,0],"","",true,false], [_turretClass,[1.88672,-3.55664,0.09],180,1,0,[0,0],"","",true,false], [_turretClass,[5.91406,-3.95654,3.02],100,1,0.0117993,[0,0],"","",true,false], [_turretClass,[-4.63477,-5.72339,3.26],180,1,0,[0,0],"","",true,false], [_turretClass,[-5.67188,4.40234,6.09],0,1,0,[0,0],"","",true,false]]],
			["land_ffaa_casa_urbana_8", [[_turretClass,[-0.838867,-10.4575,0.21],180,1,0,[0,0],"","",true,false], [_turretClass,[-7.53613,-10.6396,8.34],180,1,0,[0,0],"","",true,false], [_turretClass,[13.2959,9.75537,0.2],0,1,0,[0,0],"","",true,false], [_turretClass,[-14.0879,-10.4905,12.39],180,1,0,[0,0],"","",true,false], [_turretClass,[10.6738,-10.2341,17.1],180,1,0,[0,0],"","",true,false], [_turretClass,[-15.7969,7.78418,17.05],270,1,0,[0,0],"","",true,false]]],
			["land_ffaa_casa_sha_2", [[_turretClass,[3.41309,3.28809,6.56],315,1,0,[0,0],"","",true,false], [_turretClass,[-8.98828,-6.08813,6.56],225,1,0,[0,0],"","",true,false]]],
			["land_ffaa_casa_sha_3", [[_turretClass,[-3.08398,7.25928,0.47],0,1,0,[0,0],"","",true,false], [_turretClass,[-7.66309,-6.60522,13.74],180,1,0,[0,0],"","",true,false], [_turretClass,[7.23633,7.2251,13.74],45,1,0,[0,0],"","",true,false]]],
			["land_ffaa_casa_aeropuerto_torre", [[_turretClass,[3.44434,2.14624,15.06],180,1,0,[0,0],"","",true,false], [_turretClass,[14.8193,-9.08228,3.68],125,1,0,[0,0],"","",true,false], [_turretClass,[-16.9463,10.4849,5.78],315,1,0,[0,0],"","",true,false]]]
		];
	}; 
	//case "Tropical": {_exit = true}; 
	case "Mediterranean": {_exit = true}; 
};
if _exit exitWith {[format ["ADF_fnc_createRoofTurrets - No buildings have yet been defined for the -%1- world theme. Termination script", ADF_worldTheme], true] call ADF_fnc_log;};
if ADF_missionTest then {[format ["ADF_fnc_createRooftopTurrets - Number of allTurretBuildings loaded: %1", count _allTurretBuildings], false] call ADF_fnc_log;};

_createTurret = { // Based on BIS_fnc_objectMapper by Joris-Jan van 't Land / BIS		
	// Init
	params [
		["_position", [0,0,0], [[]], [2,3]],
		["_directionBuilding", 0, [0]],
		["_allTurrets", [], [[]]],
		["_turretArray", [], [[]]],
		["_turret", [], [[]]]
	];
	private _position_X = _position select 0;
	private _position_Y = _position select 1;

	// Select one of the turrets. In case the building has > 5 turrent positions then select two turrets.
	private _selectedTurret = selectRandom _allTurrets;		
	if ((count _allTurrets) > 5) then {
		_turretArray pushBack _selectedTurret;
		//_allTurrets = _allTurrets - [_selectedTurret];
		_allTurrets deleteAt (_allTurrets find _selectedTurret);			
		_turretArray pushBack (selectRandom _allTurrets);			
	} else {
		_turretArray pushBack _selectedTurret;
	};
	
	//Function to multiply a [2, 2] matrix by a [2, 1] matrix
	private _multiplyMatrixFunc = {
		params ["_array1", "_array2"];
		private _result = [
			(((_array1 # 0) # 0) * (_array2 # 0)) + (((_array1 # 0) # 1) * (_array2 # 1)),
			(((_array1 # 1) # 0) * (_array2 # 0)) + (((_array1 # 1) # 1) * (_array2 # 1))
		];
		_result
	};		

	{
		private _turretClass = _x # 0;
		private _relPos = _x # 1;
		private _directionTurret = _x # 2;
		
		if (_turretClass isEqualType []) then {_turretClass = selectRandom _turretClass;};

		//Rotate the relative position using a rotation matrix
		private _rotMatrix =
		[
			[cos _directionBuilding, sin _directionBuilding],
			[-(sin _directionBuilding), cos _directionBuilding]
		];
		private _newRelPos = [_rotMatrix, _relPos] call _multiplyMatrixFunc;
		private _newPos = [_position_X + (_newRelPos # 0), _position_Y + (_newRelPos # 1), _relPos # 2];

		//Create the turret and move it to the selected rooftop position.
		_turret = createVehicle [_turretClass, [0, 0, 0], [], 0, "CAN_COLLIDE"];
		_turret setDir (_directionBuilding + _directionTurret);
		_turret setPos _newPos;
	} forEach _turretArray;

	_turret
};

// Get all the buildings in the designated area
private _allBuildings = _position nearObjects ["house", _radius];	
if ADF_missionTest then {[format ["ADF_fnc_createRooftopTurrets - Number of buildings found (%1) within the designated area of %2 meters from %3.", count _allBuildings, _radius, _position], false] call ADF_fnc_log;};

{ // Filter the buildings and resize the selection according to the number of turret positions needed
	private _building = _x;
	{
		if ((typeOf _building) isEqualTo (_x # 0)) then {_allQualifiedBuildings pushBack _building};			
	} forEach _allTurretBuildings;
} forEach _allBuildings;

_allQualifiedBuildings = _allQualifiedBuildings call BIS_fnc_arrayShuffle;
if ADF_missionTest then {[format ["ADF_fnc_createRooftopTurrets - Number of qualified buildings found: %1", count _allQualifiedBuildings], false] call ADF_fnc_log;};
if (_turretCount isEqualType true) then {_turretCount = round ((_radius / 500) * ((count _allQualifiedBuildings) / 25))};
if ((count _allQualifiedBuildings) > _turretCount) then {_allQualifiedBuildings resize _turretCount};	

{ // Create a turret on (one of) the predetermined building position(s)
	private _building = _x;		
	{
		if ((typeOf _building) isEqualTo (_x # 0)) then {
			_position = getPosATL _building;
			_directionBuilding = getDir _building;			
			private _turret = [_position, _directionBuilding, _x # 1] call _createTurret;
			_turrets pushback _turret;
			if ADF_missionTest then {[format ["m%1%2",_position, _directionBuilding], _position, "ICON", "mil_dot", 1, 1, 0, "colorYellow"] call ADF_fnc_createMarker;};
		};
	} forEach _allTurretBuildings;
} forEach _allQualifiedBuildings;	

if ADF_debug then {[format ["ADF_fnc_createRooftopTurrets - Diag time to execute function: %1",diag_tickTime - _diag_time]] call ADF_fnc_log};

_turrets