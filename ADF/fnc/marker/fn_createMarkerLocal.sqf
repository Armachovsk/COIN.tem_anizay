/*********************************************************************************
 _____ ____  _____ 
|  _  |    \|   __|
|     |  |  |   __|
|__|__|____/|__|   
ARMA Mission Development Framework
ADF version: 2.26 / Jul 2020

Function: ADF_fnc_createMarkerLocal
Author: Whiztler
Script version: 1.00

File: fn_createMarkerLocal.sqf
Diag: 0.012 ms
**********************************************************************************
ABOUT
Creates a local marker, visibible by the entity that created the marker

INSTRUCTIONS:
Call from any client, or server.
To create a marker which is visible on the map you need to define at least the
name, position, shape and type.

REQUIRED PARAMETERS:
0. string:    marker name
1. position:  String / Array [x, y, z] / object or vehicle / group / location,
              representing the position where the marker will be created.

OPTIONAL PARAMETERS:
2. string:    Shape: determines shape (actual type) of the marker:
              - "ICON"
              - "RECTANGLE"
              - "ELLIPSE"
              - "POLYLINE"
			  - "" (default)
3. string:    Type: Marker type, a class name in CfgMarkers:
              https://community.bistudio.com/wiki/cfgMarkers
			  Default: ""
4. integer:   Width of the marker (default: 1)
5. integer:   Height of the marker (default: 1)
6. integer:   Direction of the marker 0-360 degrees (default: 0)
7. string:    Colour: Marker colour, according to CfgMarkColors:
              https://community.bistudio.com/wiki/Arma_3_CfgMarkerColors
			  Default: "ColorEAST"
8. string:    Text: text to be displayed on the map. Free format.
9. string:   Brush: fill texture for the marker ("RECTANGLE" or "ELLIPSE"):
			  "Solid"
			  "SolidFull"
			  "Horizontal"
			  "Vertical"
			  "Grid"
			  "FDiagonal"
			  "BDiagonal"
			  "DiagGrid"
			  "Cross"
			  "Border"
			  "SolidBorder"
			  "" (default)
10. integer:  Alpha: Sets the marker alpha channel (0 - 1):
              0 invisible
              1 fully visible (default)

EXAMPLES USAGE IN SCRIPT:
["myMarker", [4000,4000,0], "ICON", "b_hq", 1, 1, 0, "colorBLUFOR", "FOB", "", 0.7] call ADF_fnc_createMarkerLocal;

EXAMPLES USAGE IN EDEN:
n/a

DEFAULT/MINIMUM OPTIONS
["MyPosition", getPos player] call ADF_fnc_createMarkerLocal;

RETURNS:
Local marker
*********************************************************************************/

// Reporting
if (ADF_extRpt || {ADF_debug}) then {diag_log "ADF rpt: fnc - executing: ADF_fnc_createMarkerLocal"};

// Init
params [
	["_name", "", [""]],
	["_position", [0, 0, 0], ["", objNull, grpNull, locationNull, [], 0]],
	["_shape", "SYSTEM", [""]],
	["_type", "", [""]],
	["_sizeX", 1, [0]],
	["_sizeY", 1, [0]],
	["_direction", 0, [360]],
	["_color", "ColorEAST", [""]],
	["_text", "", [""]],
	["_brush", "", [""]],
	["_alpha", 1, [0]]
];
private _validTypes = ["Contact_arrow1", "Contact_arrow2", "Contact_arrow3", "Contact_arrowLeft", "Contact_arrowRight", "Contact_arrowSmall1", "Contact_arrowSmall2", "Contact_art1", "Contact_art2", "Contact_circle1", "Contact_circle2", "Contact_circle3", "Contact_circle4", "Contact_dashedLine1", "Contact_dashedLine2", "Contact_dashedLine3", "Contact_defenseLine", "Contact_defenseLineOver", "Contact_dot1", "Contact_dot2", "Contact_dot3", "Contact_dot4", "Contact_dot5", "Contact_pencilCircle1", "Contact_pencilCircle2", "Contact_pencilCircle3", "Contact_pencilDoodle1", "Contact_pencilDoodle2", "Contact_pencilDoodle3", "Contact_pencilDot1", "Contact_pencilDot2", "Contact_pencilDot3", "Contact_pencilTask1", "Contact_pencilTask2", "Contact_pencilTask3", "Empty", "EmptyIcon", "Flag", "GroundSupport_ARTY_EAST", "GroundSupport_ARTY_RESISTANCE", "GroundSupport_ARTY_WEST", "GroundSupport_CAS_EAST", "GroundSupport_CAS_RESISTANCE", "GroundSupport_CAS_WEST", "KIA", "MemoryFragment", "Minefield", "MinefieldAP", "RedCrystal", "Select", "White", "b_Ordnance", "b_air", "b_antiair", "b_armor", "b_art", "b_hq", "b_inf", "b_installation", "b_maint", "b_mech_inf", "b_med", "b_mortar", "b_motor_inf", "b_naval", "b_plane", "b_recon", "b_service", "b_support", "b_uav", "b_unknown", "c_air", "c_car", "c_plane", "c_ship", "c_unknown", "flag_AAF", "flag_Altis", "flag_AltisColonial", "flag_Astra", "flag_Belgium", "flag_CSAT", "flag_CTRG", "flag_Canada", "flag_Catalonia", "flag_Croatia", "flag_CzechRepublic", "flag_Denmark", "flag_EAF", "flag_EU", "flag_Enoch", "flag_EnochLooters", "flag_FIA", "flag_France", "flag_Georgia", "flag_Germany", "flag_Greece", "flag_Hungary", "flag_IDAP", "flag_Iceland", "flag_Italy", "flag_Luxembourg", "flag_NATO", "flag_Netherlands", "flag_Norway", "flag_Poland", "flag_Portugal", "flag_Russia", "flag_Slovakia", "flag_Slovenia", "flag_Spain", "flag_Spetsnaz", "flag_Syndicat", "flag_Tanoa", "flag_TanoaGendarmerie", "flag_UK", "flag_UN", "flag_USA", "flag_Viper", "group_0", "group_1", "group_10", "group_11", "group_2", "group_3", "group_4", "group_5", "group_6", "group_7", "group_8", "group_9", "hd_ambush", "hd_ambush_noShadow", "hd_arrow", "hd_arrow_noShadow", "hd_destroy", "hd_destroy_noShadow", "hd_dot", "hd_dot_noShadow", "hd_end", "hd_end_noShadow", "hd_flag", "hd_flag_noShadow", "hd_join", "hd_join_noShadow", "hd_objective", "hd_objective_noShadow", "hd_pickup", "hd_pickup_noShadow", "hd_start", "hd_start_noShadow", "hd_unknown", "hd_unknown_noShadow", "hd_warning", "hd_warning_noShadow", "loc_Ambush", "loc_Attack", "loc_Box", "loc_Bunker", "loc_BusStop", "loc_Bush", "loc_Chapel", "loc_Church", "loc_CivilDefense", "loc_Cross", "loc_CulturalProperty", "loc_DangerousForces", "loc_Fortress", "loc_Fountain", "loc_Frame", "loc_Fuelstation", "loc_Hospital", "loc_LetterA", "loc_LetterB", "loc_LetterC", "loc_LetterD", "loc_LetterE", "loc_LetterF", "loc_LetterG", "loc_LetterH", "loc_LetterI", "loc_LetterJ", "loc_LetterK", "loc_LetterL", "loc_LetterM", "loc_LetterN", "loc_LetterO", "loc_LetterP", "loc_LetterQ", "loc_LetterR", "loc_LetterS", "loc_LetterT", "loc_LetterU", "loc_LetterV", "loc_LetterW", "loc_LetterX", "loc_LetterY", "loc_LetterZ", "loc_Lighthouse", "loc_Pick", "loc_Power", "loc_PowerSolar", "loc_PowerWave", "loc_PowerWind", "loc_Quay", "loc_Rifle", "loc_Rock", "loc_Ruin", "loc_SafetyZone", "loc_SmallTree", "loc_Stack", "loc_Tourism", "loc_Transmitter", "loc_Tree", "loc_Truck", "loc_ViewTower", "loc_WaterTower", "loc_boat", "loc_car", "loc_container", "loc_defend", "loc_destroy", "loc_download", "loc_heal", "loc_heli", "loc_help", "loc_interact", "loc_meet", "loc_mine", "loc_move", "loc_plane", "loc_radio", "loc_rearm", "loc_refuel", "loc_repair", "loc_save", "loc_sdv", "loc_search", "loc_talk", "loc_use", "mil_ambush", "mil_ambush_noShadow", "mil_arrow", "mil_arrow2", "mil_arrow2_noShadow", "mil_arrow_noShadow", "mil_box", "mil_box_noShadow", "mil_circle", "mil_circle_noShadow", "mil_destroy", "mil_destroy_noShadow", "mil_dot", "mil_dot_noShadow", "mil_end", "mil_end_noShadow", "mil_flag", "mil_flag_noShadow", "mil_join", "mil_join_noShadow", "mil_marker", "mil_marker_noShadow", "mil_objective", "mil_objective_noShadow", "mil_pickup", "mil_pickup_noShadow", "mil_start", "mil_start_noShadow", "mil_triangle", "mil_triangle_noShadow", "mil_unknown", "mil_unknown_noShadow", "mil_warning", "mil_warning_noShadow", "n_Ordnance", "n_air", "n_antiair", "n_armor", "n_art", "n_hq", "n_inf", "n_installation", "n_maint", "n_mech_inf", "n_med", "n_mortar", "n_motor_inf", "n_naval", "n_plane", "n_recon", "n_service", "n_support", "n_uav", "n_unknown", "o_Ordnance", "o_air", "o_antiair", "o_armor", "o_art", "o_hq", "o_inf", "o_installation", "o_maint", "o_mech_inf", "o_med", "o_mortar", "o_motor_inf", "o_naval", "o_plane", "o_recon", "o_service", "o_support", "o_uav", "o_unknown", "respawn_air", "respawn_armor", "respawn_inf", "respawn_motor", "respawn_naval", "respawn_para", "respawn_plane", "respawn_unknown", "selector_selectable", "selector_selectedEnemy", "selector_selectedFriendly", "selector_selectedMission", "u_installation", "waypoint"];

// Check marker params
_position = [_position] call ADF_fnc_checkPosition;

if (_position isEqualTo [0, 0, 0]) exitWith {["ADF_fnc_createMarkerLocal", format ["Position: '%1' is not a valid position", _position]] call ADF_fnc_terminateScript;};
if (!(_type isEqualTo "") && {!(_type in _validTypes)}) then {_shape = "ICON"; _type = "hd_dot"; _colour = "ColorUNKNOWN"; _text = "ADF_fnc_createMarkerLocal ERROR (type)";};
if (!(_shape isEqualTo "SYSTEM") && {!(_shape in ["ICON", "RECTANGLE", "ELLIPSE", "POLYLINE"])}) then {_shape = "ICON"; _type = "hd_dot"; _colour = "ColorUNKNOWN"; _text = "ADF_fnc_createMarkerLocal ERROR (shape)";};

private _marker = createMarkerLocal [_name, _position];
if !(_shape isEqualTo "SYSTEM") then {
	_marker setMarkerShapeLocal _shape;
	if !(_type == "") then {_marker setMarkerTypeLocal _type};
	if !(_text == "") then {_marker setMarkerTextLocal _text};
	if !(_brush == "") then {_marker setMarkerBrushLocal _brush};
	_marker setMarkerColorLocal _color;
	_marker setMarkerSizeLocal [_sizeX, _sizeY];
	_marker setMarkerDirLocal _direction;	
	_marker setMarkerAlphaLocal _alpha;
};

// Debug reporting
if ADF_debug then {[format ["ADF_fnc_createMarker marker (%1) Created", _name]] call ADF_fnc_log};

// Return the new marker
_marker