// ZBE cache by Zorrobyte. Edited by whiztler for ADF
// ADF v 2.25

if isServer then {diag_log "ADF rpt: Init - executing: zbe_cache\main.sqf"}; // Reporting. Do NOT edit/remove

zbe_aiCacheDist = _this # 0;
zbe_minFrameRate = _this # 1;
zbe_debug = _this # 2;
zbe_vehicleCacheDistCar = _this # 3;
zbe_vehicleCacheDistAir = _this # 4;
zbe_vehicleCacheDistBoat = _this # 5;
_ADF_Caching_debugInfo = _this # 6;

zbe_allGroups = 0;
zbe_cachedGroups = [];
zbe_cachedUnits = 0;
zbe_allVehicles = 0;
zbe_cachedVehicles = 0;
zbe_objectView = 0;
zbe_players = [];

call compileFinal preprocessFileLineNumbers "ADF\ext\zbe_cache\zbe_functions.sqf";

if (zbe_minFrameRate == -1) then {if isDedicated then {zbe_minFrameRate = 16} else {zbe_minFrameRate = 31};};

zbe_mapsize = worldSize;
zbe_mapside = zbe_mapsize / 2;
zbe_centerPOS = [zbe_mapside, zbe_mapside, 0];

// 5 min delayed start so that AO's can properly initialize before caching process starts
waitUntil {sleep 1; time > 300}; 

// Check if  the HC connected late. if that's the case than terminate caching.
//if (ADF_HC_connected) exitWith {["zbe_cache - even though caching was enabled, an HC connected after mission start, resulting in the caching script to terminate.", true] call ADF_fnc_log;};

[] spawn  {
	while {true} do {
		sleep 15;
		zbe_players = allPlayers - entities "HeadlessClient_F";
		{
			private _e = _x getVariable ["zbe_cacheDisabled", false];
			if !(_e && (_x in zbe_cachedGroups)) then {
				zbe_cachedGroups pushBack _x;
				[zbe_aiCacheDist, _x, zbe_minFrameRate, zbe_debug] execFSM "ADF\ext\zbe_cache\zbe_aiCaching.fsm";
			};
		} forEach allGroups;
	};
};

// Vehicle Caching Beta (for client FPS)
[] spawn {
	private ["_assetscar", "_assetsair", "_assetsboat"];
	zbe_cached_cars = [];
	zbe_cached_air 	= [];
	zbe_cached_boat	= [];
	
	while {true} do {
		_assetscar = zbe_centerPOS nearEntities ["LandVehicle", zbe_mapside];
		{
			if !(_x in zbe_cached_cars) then {
				zbe_cached_cars pushBack _x;
				[_x, zbe_vehicleCacheDistCar] execFSM "ADF\ext\zbe_cache\zbe_vehicleCaching.fsm";
			};
		} forEach _assetscar;
		
		_assetsair = zbe_centerPOS nearEntities ["Air", zbe_mapside];
		{
			if !(_x in zbe_cached_air) then {
				zbe_cached_air pushBack _x;
				[_x, zbe_vehicleCacheDistAir] execFSM "ADF\ext\zbe_cache\zbe_vehicleCaching.fsm";
			};
		} forEach _assetsair;
		
		_assetsboat = zbe_centerPOS nearEntities ["Ship", zbe_mapside];
		{
			if !(_x in zbe_cached_boat) then {
				zbe_cached_boat pushBack _x;
				[_x, zbe_vehicleCacheDistBoat] execFSM "ADF\ext\zbe_cache\zbe_vehicleCaching.fsm";
			};
		} forEach _assetsboat;

		{
			if !(_x in _assetscar) then {
				zbe_cached_cars = zbe_cached_cars - [_x];
			};
		} forEach zbe_cached_cars;
		
		{
			if !(_x in _assetsair) then {
				zbe_cached_air = zbe_cached_air - [_x];
			};
		} forEach zbe_cached_air;
		
		{
			if !(_x in _assetsboat) then {
				zbe_cached_boat = zbe_cached_boat - [_x];
			};
		} forEach zbe_cached_boat;
		
		zbe_allVehicles = (_assetscar + _assetsair + _assetsboat);
		sleep 15;
	};
};

if (zbe_debug && _ADF_Caching_debugInfo) then {
	[] spawn {	
		while {true} do {
			uiSleep 15;
			zbe_cachedUnits = (count allUnits - ({simulationEnabled _x} count allUnits));
			zbe_cachedVehicles = (zbe_allVehicles - ({simulationEnabled _x} count zbe_allVehicles));
			zbe_allVehiclesCount = (count zbe_allVehicles);
			hintSilent parseText format ["<t color='#FFFFFF' size='1.5'>ZBE Caching</t><br/><t color='#FFFFFF'>Debug data</t><br/><br/><t color='#A1A4AD' align='left'>Game time in seconds:</t><t color='#FFFFFF' align='right'>%1</t><br/><br/><t color='#A1A4AD' align='left'>Number of groups:</t><t color='#FFFFFF' align='right'>%2</t><br/><t color='#A1A4AD' align='left'>All units:</t><t color='#FFFFFF' align='right'>%3</t><br/><t color='#A1A4AD' align='left'>Cached units:</t><t color='#39a0ff' align='right'>%4</t><br/><br/><t color='#A1A4AD' align='left'>All vehicles:</t><t color='#FFFFFF' align='right'>%5</t><br/><t color='#A1A4AD' align='left'>Cached vehicles:</t><t color='#00ff33' align='right'>%6</t><br/><br/><t color='#A1A4AD' align='left'>FPS:</t><t color='#FFFFFF' align='right'>%7</t><br/><br/><t color='#A1A4AD' align='left'>Obj draw distance:</t><t color='#FFFFFF' align='right'>%8</t><br/>", (round time), count allGroups, count allUnits, zbe_cachedUnits, zbe_allVehiclesCount, zbe_cachedVehicles, (round diag_fps), zbe_objectView];			zbe_log_stats = format ["Groups: %1 # All/Cached Units: %2/%3 # All/Cached Vehicles: %4/%5 # FPS: %6 # ObjectDrawDistance: %7", count allGroups, count allUnits, zbe_cachedUnits, zbe_allVehiclesCount, zbe_cachedVehicles, (round diag_fps), zbe_objectView];
			diag_log format ["%1 ZBE_Cache (%2) ---  %3", (round time), name player, zbe_log_stats];
		};
	};
};