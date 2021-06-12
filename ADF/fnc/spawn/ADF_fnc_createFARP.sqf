/*********************************************************************************
 _____ ____  _____ 
|  _  |    \|   __|
|     |  |  |   __|
|__|__|____/|__|   
ARMA Mission Development Framework
ADF version: 2.26 / Jul 2020

Function: ADF_fnc_createFARP
Author: Whiztler
Script version: 1.05

File: ADF_fnc_createFARP.sqf
**********************************************************************************
ABOUT
The createFARP function creates Repair/Refuel/Rearm site (F.A.R.P.). There are
three FARP types you can create: road vehicle, helicopter, airplane.
The FARPS are fully dressed up with FARP objects. AlMost all objects have
simulation disabled making it performance efficient.

INSTRUCTIONS:
This function is NOT automatically loaded on mission start. The function is used/
activated by the Create FARP Module. To manually use the function, load the
function on mission startup:

call compile preprocessFileLineNumbers "{pathToFunction}";

Call the function from the server only!

REQUIRED PARAMETERS:
0. String:      Name of the marker

OPTIONAL PARAMETERS:
1. String:      Type of FARP:
                - "car" for road vehicles (default).
                - "heli" for helicopters.
                - "jet" for planes.

EXAMPLES USAGE IN SCRIPT:
["_heliFarp", "car"] call ADF_fnc_createFARP;

EXAMPLES USAGE IN EDEN:
["myMarker", "heli"] call ADF_fnc_createFARP;

DEFAULT/MINIMUM OPTIONS
["farpMarker"] call ADF_fnc_createFARP;

RETURNS:
Bool (success flag)
*********************************************************************************/

ADF_fnc_createFARP = {
	// Reporting
	if (ADF_extRpt || {ADF_debug}) then {diag_log "ADF rpt: fnc - executing: ADF_fnc_createFARP"};

	// init
	private _diag_time = diag_tickTime;
	params [
		["_position", "mEmptyDummyMarker", ["", [], objNull]],
		["_serviceType", "car", [""]]
		["_direction", 0, [0]],
		["_composition", [], [0]],
		["_marker_size_X", 0, [0]],
		["_marker_size_Y", 0, [0]],
		["_trigger_size_X", 0, [0]],
		["_trigger_size_Y", 0, [0]],
		["_trigger_init", [], [0]],			
	];
	
	if (_position isEqualType "") then {
		// Check if valid marker is passed. Terminate script if invalid
		if !(_position in allMapMarkers) exitWith {
			["ADF Debug: ADF_fnc_createFARP - ERROR! No valid marker provided. Place a marker on the map where you want the FARP to be created.", true] call ADF_fnc_log;
			false
		};
		_direction = markerDir _position;		
	};
	if (_position isEqualType objNull) then {_direction = getDir _position};	
	_position = [_position] call ADF_fnc_checkPosition;

	// FARP compositions
	private _comp_helicopter	= [
		["Land_WorkStand_F", [11.4692, 9.65137, -1.43051e-006], 309.523, 1, 0, [-0.000757742, -9.81405e-005], "", "_this enableSimulationGlobal false; _this allowDamage false;", true, false],  	
		["Land_WorkStand_F", [9.04907, 12.2617, 7.96318e-005], 322.019, 1, 0, [-0.0109881, -0.000562438], "", "_this enableSimulationGlobal false; _this allowDamage false;", true, false],  		
		["Land_Workbench_01_F", [-0.0407715, 13.3613, 0], 359.942, 1, 0, [0.000203737, 2.96087e-005], "", "_this enableSimulationGlobal false; _this allowDamage false;", true, false],  
		["Land_Workbench_01_F", [-4.0708, 13.4414, 0], 1.34418, 1, 0, [0.000586462, 2.54348e-005], "", "_this enableSimulationGlobal false; _this allowDamage false;", true, false],  
		["Land_Flush_Light_yellow_F", [5.62695, 0.207031, 0], 0, 1, 0, [0, 0], "", "_this allowDamage false;", true, false],  
		["Land_Flush_Light_yellow_F", [-0.0332031, -5.66406, 0], 0, 1, 0, [0, 0], "", "_this allowDamage false;", true, false],  
		["Land_Flush_Light_yellow_F", [-5.78906, 0.126953, 0], 0, 1, 0, [0, 0], "", "_this allowDamage false;", true, false],  
		["Land_Flush_Light_yellow_F", [-0.140625, 6.00977, 0], 0, 1, 0, [0, 0], "", "_this allowDamage false;", true, false],
		["Land_Flush_Light_yellow_F", [5.63281, -5.63867, 0], 0, 1, 0, [0, 0], "", "_this allowDamage false;", true, false],  
		["Land_Flush_Light_yellow_F", [5.47461, 5.97656, 0], 0, 1, 0, [0, 0], "", "_this allowDamage false;", true, false],  
		["Land_Flush_Light_yellow_F", [-5.82031, -5.67578, 0], 0, 1, 0, [0, 0], "", "_this allowDamage false;", true, false],  
		["Land_Flush_Light_yellow_F", [-5.90625, 5.93945, 0], 0, 1, 0, [0, 0], "", "_this allowDamage false;", true, false],  		
		["Land_WheelChock_01_F", [6.27905, -0.00830078, 0], 55.6447, 1, 0, [0.000115426, 0.000540016], "", "_this enableSimulationGlobal false; _this allowDamage false;", true, false],  
		["Land_HelicopterWheels_01_assembled_F", [6.58911, -2.13867, -0.00152302], 70.0452, 1, 0, [0.385156, 0.000499762], "", "_this enableSimulationGlobal false; _this allowDamage false;", true, false],  
		["Land_WheelChock_01_F", [6.64917, -2.74854, -9.53674e-007], 55.2972, 1, 0, [0.000496237, 0.000286661], "", "_this enableSimulationGlobal false; _this allowDamage false;", true, false],  
		["Land_WheelChock_01_F", [6.95923, -2.57861, 0], 91.0181, 1, 0, [0.000143541, 0.000535614], "", "_this enableSimulationGlobal false; _this allowDamage false;", true, false],  
		["Land_DieselGroundPowerUnit_01_F", [10.2593, -4.64844, -0.00129366], 218.21, 1, 0.0105341, [-0.0629981, -0.0027205], "", "_this enableSimulationGlobal false; _this allowDamage false;", true, false],  
		["Land_HelicopterWheels_01_disassembled_F", [9.77905, 7.81152, -0.000794411], 359.773, 1, 0, [-0.00765996, -0.173737], "", "_this enableSimulationGlobal false; _this allowDamage false;", true, false],  
		["StorageBladder_01_fuel_forest_F", [-1.37085, -13.1953, 0], 0, 1, 0, [0, 0], "", "_this allowDamage false;", true, false],  
		["Land_Camping_Light_F", [1.0791, 13.2915, -0.0510569], 1.35559, 1, 0, [-0.163851, -0.126619], "", "_this allowDamage false;", true, false],  
		["Land_Hammer_F", [1.76929, 13.2612, 0.880836], 0.766613, 1, 0, [7.83246, -2.82657], "", "_this enableSimulationGlobal false; _this allowDamage false;", true, false],  
		["Land_Meter3m_F", [2.08911, 13.2515, 0.525024], 351.084, 1, 0, [0.0153263, 0.108515], "", "_this enableSimulationGlobal false; _this allowDamage false;", true, false],  
		["Land_Pliers_F", [1.9292, 13.2915, 0.901533], 316.891, 1, 0, [-3.19029, -1.99025], "", "_this enableSimulationGlobal false; _this allowDamage false;", true, false],  
		["Land_Screwdriver_V1_F", [1.56885, 13.3516, 0.518016], 356.515, 1, 0, [-5.65413, 0.354711], "", "_this enableSimulationGlobal false; _this allowDamage false;", true, false],  
		["Land_ToolTrolley_01_F", [1.96924, 13.3013, 1.28746e-005], 95.3644, 1, 0, [0.00298076, 0.00815666], "", "_this enableSimulationGlobal false; _this allowDamage false;", true, false],  
		["Land_DrillAku_F", [1.51074, 13.3906, 0.772235], 9.13448, 1, 0, [0.182057, -92.9802], "", "_this enableSimulationGlobal false; _this allowDamage false;", true, false],  
		["Land_ToolTrolley_01_F", [11.3389, 7.2915, 4.48227e-005], 336.915, 1, 0, [0.000504582, -0.00938332], "", "_this enableSimulationGlobal false; _this allowDamage false;", true, false],  
		["Land_DischargeStick_01_F", [11.3889, 7.25146, 0.901255], 164.373, 1, 0, [-2.9536, 0.483839], "", "_this enableSimulationGlobal false; _this allowDamage false;", true, false],  
		["Land_ToolTrolley_02_F", [-2.06079, 13.3613, 8.58307e-006], 271.32, 1, 0, [-0.00190224, 0.00170557], "", "_this enableSimulationGlobal false; _this allowDamage false;", true, false],  
		["Land_Screwdriver_V1_F", [2.26953, 13.3315, 0.913746], 297.911, 1, 0, [-8.26238, 59.5621], "", "_this enableSimulationGlobal false; _this allowDamage false;", true, false],  
		["Land_ExtensionCord_F", [-1.99072, 13.4014, 0.910019], 2.26273, 1, 0, [-0.0149973, -0.00837398], "", "_this enableSimulationGlobal false; _this allowDamage false;", true, false],  
		["Land_PressureWasher_01_F", [6.36914, 12.0015, 0], 298.566, 1, 0, [-0.000135214, -2.61495e-005], "", "_this enableSimulationGlobal false; _this allowDamage false;", true, false],  
		["Land_MultiMeter_F", [1.9292, 13.4614, 0.902173], 0.0426447, 1, 0, [-0.254887, -2.95273], "", "_this enableSimulationGlobal false; _this allowDamage false;", true, false],  
		["Land_WeldingTrolley_01_F", [3.59912, 13.1216, 9.53674e-006], 237.648, 1, 0, [0.00171359, -0.00127287], "", "_this enableSimulationGlobal false; _this allowDamage false;", true, false],  
		["Land_BarrelTrash_grey_F", [-5.56079, 12.5713, 5.81741e-005], 356.952, 1, 0, [-0.0128217, -0.0138625], "", "_this enableSimulationGlobal false; _this allowDamage false;", true, false],  
		["CamoNet_BLUFOR_Curator_F", [-0.14502, 14.3408, 0], 0, 1, 0, [0, 0], "", "_this enableSimulationGlobal false; _this allowDamage false;", true, false],  
		["Land_GasTank_02_F", [2.91919, 13.8916, 0.000234604], 354.173, 1, 0, [0.0578241, 0.11655], "", "_this enableSimulationGlobal false; _this allowDamage false;", true, false],  
		["Land_PlasticCase_01_medium_F", [-4.71094, 13.6616, .7], 272.452, 1, 0, [0.000568749, -0.00591065], "", "_this enableSimulationGlobal false; _this allowDamage false;", true, false],  
		["Land_MetalBarrel_F", [5.28906, 13.4717, 5.43594e-005], 359.967, 1, 0.00981107, [0.00121281, -0.0158148], "", "_this enableSimulationGlobal false; _this allowDamage false;", true, false],  
		["Land_MetalCase_01_medium_F", [11.2192, 9.2417, 0.7], 224.061, 1, 0, [0.000361126, 0.00976872], "", "_this enableSimulationGlobal false; _this allowDamage false;", true, false],  
		["Land_EngineCrane_01_F", [-0.490723, 14.7813, 7.15256e-006], 264.779, 1, 0, [0.000270021, 0.00116899], "", "_this enableSimulationGlobal false; _this allowDamage false;", true, false],  
		["Land_Portable_generator_F", [-6.14087, 13.6113, 0], 192.869, 1, 0, [0.0062308, 0.220284], "", "_this enableSimulationGlobal false; _this allowDamage false;", true, false],  
		["Windsock_01_F", [12.5491, -8.46875, 0], 0, 1, 0, [0, 0], "", "_this allowDamage false;", true, false],  
		["Land_WheelieBin_01_F", [2.20923, 15.0415, 2.52724e-005], 0.0863441, 1, 0, [-0.00752241, 0.00170903], "", "_this enableSimulationGlobal false; _this allowDamage false;", true, false],  
		["Land_MetalCase_01_small_F", [11.7292, 9.69141, 0.6], 313.372, 1, 0, [-0.0106096, 0.00405146], "", "_this enableSimulationGlobal false; _this allowDamage false;", true, false],  
		["Land_MetalBarrel_F", [4.86914, 14.4316, 5.48363e-005], 359.985, 1, 0.00980468, [0.00059116, -0.0158079], "", "_this enableSimulationGlobal false; _this allowDamage false;", true, false],  
		["Land_MetalBarrel_F", [5.8291, 14.3516, 5.43594e-005], 359.965, 1, 0.0098111, [0.00121231, -0.0158071], "", "_this enableSimulationGlobal false; _this allowDamage false;", true, false],  
		["CargoNet_01_barrels_F", [15.5891, 3.13135, -9.53674e-007], 355.875, 1, 0, [-0.000218269, -0.000486838], "", "_this enableSimulationGlobal false; _this allowDamage false;", true, false],  
		["Land_PortableLight_single_F", [-6.16968, 14.7656, 0], 288.833, 1, 0, [0, 0], "", "_this allowDamage false;", true, false],  
		["CargoNet_01_barrels_F", [15.4993, 4.76123, 0], 359.927, 1, 0, [-0.000553942, 0.000354597], "", "_this enableSimulationGlobal false; _this allowDamage false;", true, false],  
		["Land_MetalBarrel_F", [15.2192, 5.88135, 5.43594e-005], 359.978, 1, 0.00981083, [0.00122684, -0.0158337], "", "_this enableSimulationGlobal false; _this allowDamage false;", true, false],  
		["Land_WoodenBox_F", [10.0691, 13.0015, 0.820179], 313.359, 1, 0, [0.0731745, 0.00564672], "", "_this enableSimulationGlobal false; _this allowDamage false;", true, false],  
		["Land_WaterTank_F", [16.5193, -0.21875, -4.29153e-006], 359.985, 1, 0, [-4.33141e-006, 0.000231657], "", "_this enableSimulationGlobal false; _this allowDamage false;", true, false],  
		["Land_BarrelEmpty_F", [-5.56079, 15.7715, 5.96046e-005], 359.307, 1, 0, [-0.0140854, -0.0137263], "", "_this enableSimulationGlobal false; _this allowDamage false;", true, false],  
		["Land_Pallet_F", [16.4292, -4.08838, 0], 359.998, 1, 0, [-3.7019e-006, -5.61981e-006], "", "_this enableSimulationGlobal false; _this allowDamage false;", true, false],  
		["CargoNet_01_barrels_F", [17.3491, 3.23145, 9.53674e-007], 359.97, 1, 0, [-0.000657197, 0.000200588], "", "_this enableSimulationGlobal false; _this allowDamage false;", true, false],  
		["CamoNet_BLUFOR_open_Curator_F", [18.3025, 1.05664, 0], 270.318, 1, 0, [0, 0], "", "_this enableSimulationGlobal false; _this allowDamage false;", true, false],  
		["Land_Pipes_small_F", [17.5591, -2.84863, 0], 359.981, 1, 0, [-9.3834e-005, -6.99779e-006], "", "_this enableSimulationGlobal false; _this allowDamage false;", true, false],  
		["Land_Cargo10_military_green_F", [15.1191, 9.40137, 0], 47.8214, 1, 0, [-3.0972e-005, -1.24172e-005], "", "_this enableSimulationGlobal false; _this allowDamage false;", true, false],  
		["Land_Pallet_vertical_F", [17.3591, -4.22852, -0.00755644], 269.425, 1, 0, [-0.087335, 0.00355966], "", "_this enableSimulationGlobal false; _this allowDamage false;", true, false],  
		["CargoNet_01_barrels_F", [17.3291, 4.86133, 0], 0.0344296, 1, 0, [-5.33495e-006, -0.00012216], "", "_this enableSimulationGlobal false; _this allowDamage false;", true, false],  
		["CargoNet_01_box_F", [18.3792, 1.12158, 1.90735e-006], 264.392, 1, 0, [0.000195224, 9.68179e-005], "", "_this enableSimulationGlobal false; _this allowDamage false;", true, false],  
		["Land_Pallets_stack_F", [18.2292, -4.02832, 4.76837e-007], 359.945, 1, 0, [-0.00010015, -0.000176207], "", "_this enableSimulationGlobal false; _this allowDamage false;", true, false],  
		["Land_MetalBarrel_F", [18.8591, 2.66162, 5.43594e-005], 359.978, 1, 0.00981135, [0.001206, -0.0158055], "", "_this enableSimulationGlobal false; _this allowDamage false;", true, false],  
		["Land_WaterBarrel_F", [19.1492, -0.46875, 6.67572e-006], 359.01, 1, 0, [-0.000780047, 0.00140973], "", "_this enableSimulationGlobal false; _this allowDamage false;", true, false],  
		["Land_MetalBarrel_F", [18.7292, 5.31152, 5.43594e-005], 359.992, 1, 0.00984643, [0.000515854, -0.0156539], "", "_this enableSimulationGlobal false; _this allowDamage false;", true, false],  
		["Land_PaperBox_open_full_F", [19.9492, -2.01758, 0], 0, 1, 0, [0, 0], "", "_this enableSimulationGlobal false; _this allowDamage false;", true, false],  
		["CargoNet_01_box_F", [20.2192, 1.18164, 0], 0.0579091, 1, 0, [0.0010605, 0.000136143], "", "_this enableSimulationGlobal false; _this allowDamage false;", true, false],  
		["Box_NATO_AmmoVeh_F", [20.2791, 3.22168, 0.0305414], 359.832, 1, 0.00514273, [0.000972963, -0.000943332], "", "_this enableSimulationGlobal false; _this allowDamage false;", true, false],  
		["Land_FieldToilet_F", [20.2593, -4.61865, 4.29153e-005], 359.938, 1, 0, [-0.00193019, 0.000699348], "", "_this enableSimulationGlobal false; _this allowDamage false;", true, false],  
		["Land_AirIntakePlug_01_F", [10.6492, 8.4917, 0.7], 4.78982, 1, 0, [-0.00545794, -0.00624936], "", "_this enableSimulationGlobal false; _this allowDamage false;", true, false],  
		["Land_AirIntakePlug_02_F", [8.05908, 11.5415, 0.7], 192.368, 1, 0, [0.0047803, 0.0107271], "", "_this enableSimulationGlobal false; _this allowDamage false;", true, false],  
		["Land_RotorCoversBag_01_F", [7.20923, 10.6714, 0], 3.21583, 1, 0, [0.00774672, -0.00265271], "", "_this enableSimulationGlobal false; _this allowDamage false;", true, false],  
		["Land_PitotTubeCover_01_F", [11.239, 7.15137, 0.7], 245.009, 1, 0, [-0.0696147, 0.0445125], "", "_this enableSimulationGlobal false; _this allowDamage false;", true, false],  
		["Box_NATO_AmmoVeh_F", [20.2192, 5.06152, 0.0305433], 359.84, 1, 0.00512377, [0.000829665, -0.000757694], "", "_this enableSimulationGlobal false; _this allowDamage false;", true, false]
	];

	private _comp_roadVehicles = [
		["Land_CncBarrier_stripes_F", [3.88599, 1.72803, -0.5], 90, 1, 0, [0, -0], "", "_this enableSimulationGlobal false; _this allowDamage false;", true, false],  
		["Land_CncBarrier_stripes_F", [-4.08643, 1.68994, -0.5], 90, 1, 0, [0, -0], "", "_this enableSimulationGlobal false; _this allowDamage false;", true, false],  
		["Land_CncBarrier_stripes_F", [3.82959, -2.40674, -0.5], 90, 1, 0, [0, -0], "", "_this enableSimulationGlobal false; _this allowDamage false;", true, false],  
		["Land_Ammobox_rounds_F", [4.58887, 0.166504, -0.000163078], 11.8721, 1, 0, [-0.00268867, -0.058229], "", "_this enableSimulationGlobal false; _this allowDamage false;", true, false],  
		["Land_Ammobox_rounds_F", [4.62891, 0.566406, -0.000163555], 324.386, 1, 0, [-0.0025183, -0.0582673], "", "_this enableSimulationGlobal false; _this allowDamage false;", true, false],  
		["Land_MetalBarrel_F", [4.5874, 1.2207, 0.0191965], 7.04212, 1, 0.00462526, [4.1171, 1.74697], "", "_this enableSimulationGlobal false; _this allowDamage false;", true, false],  
		["Land_CncBarrier_stripes_F", [-4.14282, -2.44482, -0.5], 90, 1, 0, [0, -0], "", "_this enableSimulationGlobal false; _this allowDamage false;", true, false],  
		["Land_FireExtinguisher_F", [-4.6814, 1.68652, 0.000126839], 359.873, 1, 0, [-0.0475408, 0.0880664], "", "_this enableSimulationGlobal false; _this allowDamage false;", true, false],  
		["Land_Workbench_01_F", [-5.05103, -0.973633, 0], 269.097, 1, 0, [1.48535e-005, 6.81315e-005], "", "_this enableSimulationGlobal false; _this allowDamage false;", true, false],  
		["Land_PressureWasher_01_F", [4.62891, -2.29346, -4.76837e-007], 267.809, 1, 0, [-0.000180486, -0.000304969], "", "_this enableSimulationGlobal false; _this allowDamage false;", true, false],  
		["Land_MetalBarrel_F", [-4.6311, 2.33643, 5.43594e-005], 359.985, 1, 0.00980962, [0.000585132, -0.0157653], "", "_this enableSimulationGlobal false; _this allowDamage false;", true, false],  
		["Land_ToolTrolley_02_F", [-5.22095, 1.20654, 4.76837e-006], 228.772, 1, 0, [-0.00182621, 0.00203124], "", "_this enableSimulationGlobal false; _this allowDamage false;", true, false],  
		["Land_Camping_Light_F", [-5.37109, 0.146484, 1], 359.911, 1, 0, [-0.183932, -0.129417], "", "_this allowDamage false;", true, false],  
		["Land_CanisterFuel_F", [-4.54102, -3.02344, 5.29289e-005], 359.141, 1, 0, [0.0474165, 0.00369389], "", "_this enableSimulationGlobal false; _this allowDamage false;", true, false],  
		["Land_ExtensionCord_F", [-5.15112, -1.87354, -0.0500011], 4.25655, 1, 0, [-0.00164248, -0.000404366], "", "_this enableSimulationGlobal false; _this allowDamage false;", true, false],  
		["Land_CanisterOil_F", [-5.40112, 1.34619, 0.910153], 64.9264, 1, 0, [-0.0611619, 0.0296763], "", "_this enableSimulationGlobal false; _this allowDamage false;", true, false],  
		["Land_BarrelEmpty_grey_F", [-4.97095, -2.60352, 5.8651e-005], 359.297, 1, 0, [-0.0137733, -0.0133944], "", "_this enableSimulationGlobal false; _this allowDamage false;", true, false],  
		["Land_CanisterFuel_F", [-4.54102, -3.32373, 5.34058e-005], 357.819, 1, 0, [0.0475606, 0.00364671], "", "_this enableSimulationGlobal false; _this allowDamage false;", true, false],  
		["Land_PaperBox_closed_F", [5.85815, 0.453613, 0], 194.116, 1, 0, [0, 0], "", "_this enableSimulationGlobal false; _this allowDamage false;", true, false],  
		["Land_PlasticCase_01_medium_F", [-4.81079, 3.46631, -0.0499754], 359.658, 1, 0, [-0.00421175, -0.00182237], "", "_this enableSimulationGlobal false; _this allowDamage false;", true, false],  
		["Land_GasTank_01_khaki_F", [-5.021, -3.20361, 2.71797e-005], 359.906, 1, 0, [-0.0105459, -0.0166789], "", "_this enableSimulationGlobal false; _this allowDamage false;", true, false],  
		["Land_CanisterPlastic_F", [-5.54102, 2.24658, 0], 259.027, 1, 0, [0.00886006, -0.0020513], "", "_this enableSimulationGlobal false; _this allowDamage false;", true, false],  
		["Land_GasTank_02_F", [-5.37109, -2.74365, 0.000236988], 170.158, 1, 0, [0.057124, 0.118945], "", "_this enableSimulationGlobal false; _this allowDamage false;", true, false],  
		["Land_PalletTrolley_01_khaki_F", [5.90723, -1.39941, 0.00342321], 53.3619, 1, 0, [-0.494527, 0.0603241], "", "_this enableSimulationGlobal false; _this allowDamage false;", true, false],  
		["Land_ToolTrolley_01_F", [-4.57104, 3.99658, 1.62125e-005], 93.3365, 1, 0, [0.000221469, 0.00447951], "", "_this enableSimulationGlobal false; _this allowDamage false;", true, false],  
		["B_supplyCrate_F", [6.19263, -1.79004, 0.0628147], 232.833, 1, 0.00699812, [-0.0552665, -1.7847], "", "_this enableSimulationGlobal false; _this allowDamage false;", true, false],  
		["Land_MobileScafolding_01_F", [-4.84082, 4.63623, 1.90735e-006], 269.505, 1, 0, [0.0015517, -0.000282306], "", "_this enableSimulationGlobal false; _this allowDamage false;", true, false],  
		["Land_Bucket_clean_F", [-5.08081, 4.49658, -0.0498533], 358.466, 1, 0, [0.0369438, -0.0683937], "", "_this enableSimulationGlobal false; _this allowDamage false;", true, false],  
		["Land_Pallet_vertical_F", [6.83887, 0.0664063, 0.000179291], 111.565, 1, 0, [-0.083683, 0.00376358], "", "_this enableSimulationGlobal false; _this allowDamage false;", true, false],  
		["Land_CncBarrier_stripes_F", [3.84277, 5.7124, -0.5], 90, 1, 0, [0, -0], "", "_this enableSimulationGlobal false; _this allowDamage false;", true, false],  
		["Land_CncBarrier_stripes_F", [-4.12964, 5.67432, -0.5], 90, 1, 0, [0, -0], "", "_this enableSimulationGlobal false; _this allowDamage false;", true, false],  
		["Land_EngineCrane_01_F", [5.20898, -4.81348, 0], 292.137, 1, 0, [0.000702687, 0.000760989], "", "_this enableSimulationGlobal false; _this allowDamage false;", true, false],  
		["Land_ScrapHeap_1_F", [5.98145, 4.5918, 0], 0, 1, 0, [0, 0], "", "_this enableSimulationGlobal false; _this allowDamage false;", true, false],  
		["Land_CncBarrier_stripes_F", [3.82104, -6.31348, -0.5], 90, 1, 0, [0, -0], "", "_this enableSimulationGlobal false; _this allowDamage false;", true, false],  
		["Land_CncBarrier_stripes_F", [-4.15137, -6.35156, -0.5], 90, 1, 0, [0, -0], "", "_this enableSimulationGlobal false; _this allowDamage false;", true, false],  
		["Land_WeldingTrolley_01_F", [-5.12109, 5.65625, 9.53674e-006], 147.013, 1, 0, [0.00168198, -0.00129925], "", "_this enableSimulationGlobal false; _this allowDamage false;", true, false],  
		["Land_PlasticCase_01_small_F", [-4.80078, 5.94629, -0.0499969], 359.502, 1, 0, [-0.00671507, 0.00489575], "", "_this enableSimulationGlobal false; _this allowDamage false;", true, false],  
		["Land_Portable_generator_F", [-4.66113, -6.21338, -0.000821114], 359.938, 1, 0, [-0.000252622, 0.224231], "", "_this enableSimulationGlobal false; _this allowDamage false;", true, false],  
		["RoadCone_L_F", [3.84741, 7.23682, -0.551133], 0, 1, 0, [0, 0], "", "_this allowDamage false; _this setPosATL [getPosATL _this select 0, getPosATL _this select 1, (getPosATL _this select 2) - 0.55];", true, false],  
		["RoadCone_L_F", [-4.125, 7.19873, -0.551133], 0, 1, 0, [0, 0], "", "_this allowDamage false; _this setPosATL [getPosATL _this select 0, getPosATL _this select 1, (getPosATL _this select 2) - 0.55];", true, false],  
		["RoadCone_L_F", [3.823, -7.83105, -0.551133], 0, 1, 0, [0, 0], "", "_this allowDamage false; _this setPosATL [getPosATL _this select 0, getPosATL _this select 1, (getPosATL _this select 2) - 0.55];", true, false],  
		["RoadCone_L_F", [-4.14941, -7.86914, -0.551133], 0, 1, 0, [0, 0], "", "_this allowDamage false; _this setPosATL [getPosATL _this select 0, getPosATL _this select 1, (getPosATL _this select 2) - 0.55];", true, false]
	];

	private _comp_airplane = [
		["Land_Flush_Light_yellow_F", [7.53271, -1.77441, 0], 0, 1, 0, [0, 0], "", "", true, false],  
		["Land_Flush_Light_yellow_F", [7.5127, 2.41553, 0], 0, 1, 0, [0, 0], "", "", true, false],  
		["Land_Flush_Light_yellow_F", [-8.59741, -1.81445, 0], 0, 1, 0, [0, 0], "", "", true, false],  
		["Land_Flush_Light_yellow_F", [-8.51733, 2.23584, 0], 0, 1, 0, [0, 0], "", "", true, false],  
		["Land_Flush_Light_yellow_F", [7.5127, -5.73438, 0], 0, 1, 0, [0, 0], "", "", true, false],  
		["Land_Flush_Light_yellow_F", [7.45264, 6.55566, 0], 0, 1, 0, [0, 0], "", "", true, false],  
		["Land_Flush_Light_yellow_F", [-8.66724, -5.83447, 0], 0, 1, 0, [0, 0], "", "", true, false],  
		["Land_Flush_Light_yellow_F", [-8.52734, 6.30566, 0], 0, 1, 0, [0, 0], "", "", true, false], 
		["Land_Flush_Light_yellow_F", [7.44263, -9.79443, 0], 0, 1, 0, [0, 0], "", "", true, false],  
		["Land_Flush_Light_yellow_F", [7.34277, 10.3359, 0], 0, 1, 0, [0, 0], "", "", true, false], 
		["Land_Flush_Light_yellow_F", [-0.057373, -13.7744, 0], 0, 1, 0, [0, 0], "", "", true, false],  
		["Land_Flush_Light_yellow_F", [-8.61743, 9.9458, 0], 0, 1, 0, [0, 0], "", "", true, false],  
		["Land_Flush_Light_yellow_F", [-8.57739, -9.99414, 0], 0, 1, 0, [0, 0], "", "", true, false],  
		["Land_Flush_Light_yellow_F", [3.85278, -13.7544, 0], 0, 1, 0, [0, 0], "", "", true, false],  
		["Land_Flush_Light_yellow_F", [-4.16724, -13.7642, 0], 0, 1, 0, [0, 0], "", "", true, false], 
		["Land_Flush_Light_yellow_F", [7.34277, -13.7344, 0], 0, 1, 0, [0, 0], "", "", true, false],  	
		["Land_Flush_Light_yellow_F", [7.36255, 14.1958, 0], 0, 1, 0, [0, 0], "", "", true, false],  	
		["Land_Flush_Light_yellow_F", [-8.59741, -13.7842, 0], 0, 1, 0, [0, 0], "", "", true, false],  	
		["Land_Flush_Light_yellow_F", [-8.69727, 14.0659, 0], 0, 1, 0, [0, 0], "", "", true, false],  
		["Land_Flush_Light_yellow_F", [-0.757324, 18.2056, 0], 0, 1, 0, [0, 0], "", "", true, false],  
		["Land_Flush_Light_yellow_F", [3.42261, 18.2256, 0], 0, 1, 0, [0, 0], "", "", true, false], 
		["Land_Flush_Light_yellow_F", [-4.57739, 18.1655, 0], 0, 1, 0, [0, 0], "", "", true, false], 
		["Land_Flush_Light_yellow_F", [7.30273, 18.2358, 0], 0, 1, 0, [0, 0], "", "", true, false], 
		["Land_Flush_Light_yellow_F", [-8.66724, 18.2559, 0], 0, 1, 0, [0, 0], "", "", true, false], 
		["Land_Workbench_01_F", [14.2327, 11.4756, 0], 91.8753, 1, 0, [2.00347e-006, -5.88341e-006], "", "_this enableSimulationGlobal false; _this allowDamage false;", true, false],  
		["Land_Workbench_01_F", [14.1626, 7.41553, 0], 88.1957, 1, 0, [-0.000293439, -5.43641e-005], "", "_this enableSimulationGlobal false; _this allowDamage false;", true, false], 
		["Land_ToolTrolley_01_F", [14.1323, 5.48584, 2.14577e-005], 186.553, 1, 0, [-0.000798806, 0.00501416], "", "_this enableSimulationGlobal false; _this allowDamage false;", true, false],  
		["CargoNet_01_barrels_F", [-11.0574, -1.98438, -4.76837e-007], 262.737, 1, 0, [-3.10097e-005, -0.000424931], "", "_this enableSimulationGlobal false; _this allowDamage false;", true, false],  
		["CargoNet_01_barrels_F", [-11.0474, -3.97412, 4.76837e-007], 169.658, 1, 0, [-0.000299376, 8.5017e-005], "", "_this enableSimulationGlobal false; _this allowDamage false;", true, false],  
		["Land_MetalBarrel_F", [-11.9272, -5.21436, 5.38826e-005], 324.966, 1, 0.00979834, [-8.49325e-005, -0.015383], "", "_this enableSimulationGlobal false; _this allowDamage false;", true, false],  
		["CargoNet_01_barrels_F", [-12.8875, -2.24414, 4.76837e-007], 179.966, 1, 0, [-3.22536e-005, -0.000129164], "", "_this enableSimulationGlobal false; _this allowDamage false;", true, false],  
		["CargoNet_01_barrels_F", [-12.7273, -3.98438, -9.53674e-007], 86.4188, 1, 0, [-0.00050813, -0.000184561], "", "_this enableSimulationGlobal false; _this allowDamage false;", true, false],  
		["Land_PlasticCase_01_medium_F", [13.3428, 4.65576, 0], 233.626, 1, 0, [0.000186682, -0.000194494], "", "_this enableSimulationGlobal false; _this allowDamage false;", true, false],  
		["Land_MetalBarrel_F", [-14.0474, -3.11426, 5.53131e-005], 324.95, 1, 0.00981305, [0.000654194, -0.0159637], "", "_this enableSimulationGlobal false; _this allowDamage false;", true, false],  
		["Land_WeldingTrolley_01_F", [13.9626, 3.88574, 1.04904e-005], 326.876, 1, 0, [0.00166043, -0.00133849], "", "_this enableSimulationGlobal false; _this allowDamage false;", true, false],  
		["Land_MetalBarrel_F", [14.3428, 2.1958, 5.24521e-005], 88.8651, 1, 0.00979815, [0.000512621, -0.0154206], "", "_this enableSimulationGlobal false; _this allowDamage false;", true, false],  
		["StorageBladder_01_fuel_forest_F", [-13.9006, 4.31592, 0], 270, 1, 0, [0, 0], "", "_this enableSimulationGlobal false; _this allowDamage false;", true, false],  
		["Land_Meter3m_F", [13.9924, 5.17578, 0.524984], 76.7814, 1, 0, [-0.0102035, 0.133553], "", "_this enableSimulationGlobal false; _this allowDamage false;", true, false],  
		["Land_DrillAku_F", [14.0322, 5.41553, 0.90954], 100.247, 1, 0, [0.230356, -2.75153], "", "_this enableSimulationGlobal false; _this allowDamage false;", true, false],  
		["Land_Screwdriver_V1_F", [14.1724, 5.24561, 0.910233], 26.4708, 1, 0, [-8.46568, -1.24443], "", "_this enableSimulationGlobal false; _this allowDamage false;", true, false],  
		["Land_Pliers_F", [14.1223, 5.64551, 0.895342], 46.1683, 1, 0, [-3.25715, -1.91275], "", "_this enableSimulationGlobal false; _this allowDamage false;", true, false],  
		["Land_MultiMeter_F", [14.2222, 5.40576, 0.908666], 89.5675, 1, 0, [-0.353365, -2.91578], "", "_this enableSimulationGlobal false; _this allowDamage false;", true, false],  
		["Land_Hammer_F", [14.0823, 5.91553, 0.869078], 88.7209, 1, 0, [7.63744, -2.84099], "", "_this enableSimulationGlobal false; _this allowDamage false;", true, false],  
		["Land_Screwdriver_V1_F", [14.1123, 5.8457, 0.518031], 84.7097, 1, 0, [-5.66103, 0.371015], "", "_this enableSimulationGlobal false; _this allowDamage false;", true, false],  
		["Land_MetalBarrel_F", [15.2327, 1.67578, 5.24521e-005], 88.8631, 1, 0.00979811, [0.000502057, -0.0154519], "", "_this enableSimulationGlobal false; _this allowDamage false;", true, false],  
		["Land_GasTank_02_F", [14.7227, 4.57568, 0.000239372], 81.0222, 1, 0, [0.057377, 0.120468], "", "_this enableSimulationGlobal false; _this allowDamage false;", true, false],  
		["Land_MetalBarrel_F", [15.2927, 2.63574, 5.24521e-005], 88.8824, 1, 0.00981315, [0.000561124, -0.0154098], "", "_this enableSimulationGlobal false; _this allowDamage false;", true, false],  
		["Land_Camping_Light_F", [14.4326, 6.30566, .6], 69.9439, 1, 0, [-0.170107, -0.132375], "", "_this allowDamage false;", true, false],  
		["Land_MetalBarrel_F", [-10.6572, 11.9458, 5.48363e-005], 2.03936, 1, 0.00980121, [-9.94775e-005, -0.0158154], "", "_this enableSimulationGlobal false; _this allowDamage false;", true, false],  
		["Land_JetEngineStarter_01_F", [-12.8774, -10.124, -3.33786e-006], 340.823, 1, 0.0131157, [0.000361294, 0.0011493], "", "_this enableSimulationGlobal false; _this allowDamage false;", true, false],  
		["Land_Cargo10_military_green_F", [16.5828, -0.564453, 3.8147e-006], 317.82, 1, 0, [0.000243477, 0.000105968], "", "_this enableSimulationGlobal false; _this allowDamage false;", true, false],  
		["Land_MetalBarrel_F", [-10.2773, 13.1758, 8.7738e-005], 2.54441, 1, 0.00696486, [0.0194315, -0.000372872], "", "_this enableSimulationGlobal false; _this allowDamage false;", true, false],  
		["Land_WheelieBin_01_F", [15.8625, 5.30566, 8.24928e-005], 88.9188, 1, 0, [-0.00782189, -0.0126521], "", "_this enableSimulationGlobal false; _this allowDamage false;", true, false],  
		["CamoNet_BLUFOR_Curator_F", [15.1216, 7.64307, 0], 89.062, 1, 0, [0, 0], "", "_this enableSimulationGlobal false; _this allowDamage false;", true, false],  
		["CargoNet_01_box_F", [-11.8674, 12.1855, 4.76837e-007], 1.54325, 1, 0, [0.000345342, 0.000190287], "", "_this enableSimulationGlobal false; _this allowDamage false;", true, false],  
		["Land_ToolTrolley_02_F", [14.1125, 9.5459, -5.00679e-005], 0.264232, 1, 0, [-0.0102691, -0.00247951], "", "_this enableSimulationGlobal false; _this allowDamage false;", true, false],  
		["Land_ExtensionCord_F", [14.1724, 9.47559, 0.00203943], 91.7027, 1, 0, [-0.486456, 0.113298], "", "_this enableSimulationGlobal false; _this allowDamage false;", true, false],  
		["CargoNet_01_box_F", [-13.6973, 12.1855, -9.53674e-007], 267.79, 1, 0, [0.000945956, 0.000284818], "", "_this enableSimulationGlobal false; _this allowDamage false;", true, false],  
		["Box_NATO_AmmoVeh_F", [-11.8374, 14.1357, 0.0305424], 1.55726, 1, 0.00512262, [0.000423442, -0.000579814], "", "_this enableSimulationGlobal false; _this allowDamage false;", true, false],  
		["Land_BarrelTrash_grey_F", [13.2627, 13.0352, 0.00012207], 86.1753, 1, 0, [0.0224048, 0.0237266], "", "_this enableSimulationGlobal false; _this allowDamage false;", true, false],  
		["Land_PressureWasher_01_F", [10.5027, 15.6958, -4.76837e-007], 27.6174, 1, 0, [-0.000302288, -9.35375e-005], "", "_this enableSimulationGlobal false; _this allowDamage false;", true, false],  
		["Land_Portable_generator_F", [14.2927, 13.6357, -0.000823498], 282.112, 1, 0, [0.00123972, 0.223129], "", "_this enableSimulationGlobal false; _this allowDamage false;", true, false],  
		["Box_NATO_AmmoVeh_F", [-11.8374, 15.9858, 0.0305438], 2.12433, 1, 0.00510482, [0.000217687, -0.00136104], "", "_this enableSimulationGlobal false; _this allowDamage false;", true, false],  
		["Land_PortableLight_single_F", [15.4451, 13.6753, 0], 17.895, 1, 0, [0, 0], "", "_this allowDamage false;", true, false],  
		["Land_WaterTank_F", [12.0828, 17.0259, -3.8147e-006], 178.693, 1, 0, [2.37081e-005, 0.000241799], "", "_this enableSimulationGlobal false; _this allowDamage false;", true, false],  
		["Land_BarrelEmpty_F", [16.4626, 13.0859, 9.91821e-005], 88.356, 1, 0, [-0.00596975, -0.0272173], "", "_this enableSimulationGlobal false; _this allowDamage false;", true, false],  
		["Land_EngineCrane_01_F", [13.9927, 15.7256, 4.29153e-006], 54.7014, 1, 0, [0.000547839, 0.000389164], "", "_this enableSimulationGlobal false; _this allowDamage false;", true, false],  
		["Land_DieselGroundPowerUnit_01_F", [-11.2173, 18.3257, -0.00128555], 128.204, 1, 0.0106983, [-0.0624681, -0.00209726], "", "_this enableSimulationGlobal false; _this allowDamage false;", true, false]
	];	

	// Determine marker and trigger params
	switch _serviceType do {
		case "car"	: {
			_composition	= _comp_roadVehicles;
			_marker_size_X = 4;
			_marker_size_Y = 8;
			_trigger_size_X = 3.5;
			_trigger_size_Y = 6;
			_trigger_init	= [
				"(('CAR' countType thisList  > 0) || ('TRUCK' countType thisList  > 0) || ('TANK' countType thisList  > 0) || ('APC' countType thisList  > 0)) &&  ((getPos (thisList select 0)) select 2 < 2);",
				"0 = [(thisList select 0)] spawn ADF_fnc_rrr",
				""
			];
		};
		case "heli"	: {
			_composition = _comp_helicopter;
			_direction = _direction - 90;
			_marker_size_X = 8;
			_marker_size_Y = 8;
			_trigger_size_X = 5;
			_trigger_size_Y = 5;
			_trigger_init	= [
				"('Helicopter' countType thisList  > 0) && ((getPos (thisList select 0)) select 2 < .5);",
				"0 = [(thisList select 0)] spawn ADF_fnc_rrr",
				""
			];			
		};
		case "jet"	: {
			_composition	= _comp_airplane;
			_marker_size_X = 8;
			_marker_size_Y = 16;
			_trigger_size_X = 7;
			_trigger_size_Y = 8;
			_trigger_init	= [
				"(('Plane' countType thisList  > 0) || ('airplane' countType thisList  > 0) || ('airplanex' countType thisList  > 0)) && ((getPos (thisList select 0)) select 2 < 1) && (speed (thisList select 0) < 10);",
				"0 = [(thisList select 0)] spawn ADF_fnc_rrr",
				""
			];			
		};	
	};

	// Create the FARP markers
	private _marker = createMarker [(format ["mBorder%1%2", round (_position select 0), round (_position select 1)]), _position];	
	_marker setMarkerShape "RECTANGLE";
	_marker setMarkerType "Empty";
	_marker setMarkerDir _direction;
	_marker setMarkerColor "ColorYellow";
	_marker setMarkerSize [_marker_size_X, _marker_size_Y];
	_marker setMarkerBrush "Border";

	private _marker = createMarker [(format ["mIcon%1%2", round (_position select 0), round (_position select 1)]), _position];
	_marker setMarkerSize [0.8, 0.8];
	_marker setMarkerShape "ICON";
	_marker setMarkerType "b_maint";
	_marker setMarkerColor "ColorYellow";

	// Create the FARP trigger
	private _trigger = createTrigger ["EmptyDetector", _position, false];
	_trigger setTriggerActivation ["ANY", "PRESENT", true];
	_trigger setTriggerArea [_trigger_size_X, _trigger_size_Y, _direction, true];
	_trigger setTriggerTimeout [1, 2, 3, false];
	_trigger setTriggerStatements _trigger_init;

	// Put it all together
	[_position, _direction, _composition] call BIS_fnc_ObjectsMapper;

	// Debug Diag reporting
	if ADF_debug then {[format ["ADF_fnc_createFARP - Diag time to execute function: %1",diag_tickTime - _diag_time]] call ADF_fnc_log};	

	true
};