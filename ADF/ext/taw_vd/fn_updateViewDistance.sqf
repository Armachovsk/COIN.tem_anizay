#include "defines.h"
/*
	Author: Bryan "Tonic" Boardwine
	
	Description:
	Updates the view distance dependant on whether the player
	is on foot, a car or an aircraft.
	ADF edit: 2.16
*/
private _dist = 0; // ADF 2.02

switch true do {
	case (!(EQUAL(SEL(UAVControl getConnectedUAV player,1),""))): {
		setViewDistance tawvd_drone;
		_dist = tawvd_drone;
	};
	
	case (objectParent player isKindOf "Man"): {
		setViewDistance tawvd_foot;
		_dist = tawvd_foot;
	};
	
	case ((objectParent player isKindOf "LandVehicle") || {objectParent player isKindOf "Ship"}): {
		setViewDistance tawvd_car;
		_dist = tawvd_car;
	};
	
	case (objectParent player isKindOf "Air"): {
		setViewDistance tawvd_air;
		_dist = tawvd_air;
	};
};

if (tawvd_syncObject) then {
	setObjectViewDistance [_dist, 100];
	tawvd_object = _dist;
};