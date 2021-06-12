#include "defines.h"
/*
	Author: Bryan "Tonic" Boardwine
	
	Description:
	Called via addAction and opens the TAW View Distance Menu
*/
if (isNull (findDisplay MENU_IDD)) then {
	if (!createDialog "TAW_VDMenu") exitWith {hint "Something went wrong, the menu won't open?"};
};
disableSerialization;

{
	ctrlSetText[SEL(_x, 0), str(SEL(_x, 1))];
} foreach [[INFANTRY_EDIT, tawvd_foot], [GROUND_EDIT, tawvd_car], [AIR_EDIT, tawvd_air], [OBJECT_EDIT, tawvd_object], [DRONE_EDIT, tawvd_drone]];

//Setup the sliders >> ADF 2.02 - added the maximum distance vars
{
	if (!isNil "tawvd_maxRange") then {
		slidersetRange [_x select 0, 100, _x select 2];
	} else {
		slidersetRange [_x select 0, 100, _x select 2];
	};
	
	((findDisplay MENU_IDD) displayCtrl (_x select 0)) sliderSetSpeed [100, 100, 100];
	sliderSetPosition [_x select 0, _x select 1];
	
} foreach [
	[INFANTRY_SLIDER, tawvd_foot, ADF_VD_foot],
	[GROUND_SLIDER, tawvd_car, ADF_VD_vehicle],
	[AIR_SLIDER, tawvd_air, ADF_VD_air],
	[OBJECT_SLIDER, tawvd_object, ADF_VD_vehicle * 2],
	[DRONE_SLIDER, tawvd_drone, ADF_VD_air / 2]
];

((findDisplay MENU_IDD) displayCtrl 2931) cbSetChecked tawvd_syncObject;

if (tawvd_syncObject) then {
	ctrlEnable [OBJECT_SLIDER, false];
	ctrlEnable [OBJECT_EDIT, false];
} else {
	ctrlEnable [OBJECT_SLIDER, true];
	ctrlEnable [OBJECT_EDIT, true];
};

//Lets disable it..
if (!isNil "tawvd_disablenone") then {
	ctrlEnable [TERRAIN_NONE, false];
};