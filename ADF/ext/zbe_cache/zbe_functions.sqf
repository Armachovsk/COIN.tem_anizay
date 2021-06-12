///// ADF edit 2.25

zbe_cache = {
	_toCache = (units _group) - [(_leader)];
	{
		if (!(isPlayer _x) && {!("driver" in assignedVehicleRole _x)}) then {
			_x enableSimulationGlobal false;
			_x hideObjectGlobal true;			
			_x disableAI "FSM"; // ADF 1.42
		};
	} forEach _toCache;
};

zbe_unCache = {
	{
		if (!(isPlayer _x) && {!("driver" in assignedVehicleRole _x)}) then {
			_x enableSimulationGlobal true;
			_x hideObjectGlobal false;			
			_x enableAI "FSM";  // ADF 1.42
		};
	} forEach _toCache;
};

zbe_closestUnit = {
	params ["_units" ,"_unit"];
	private _dist = worldSize;
	{
		private _udist = _x distance _unit;
		if (_udist < _dist) then {_dist = _udist;};
	} forEach _units;
	_dist;
};

zbe_setPosLight = {
	{
		private _testpos = (formationPosition _x);
		if (!(isNil "_testpos") && (count _testpos > 0)) then {
			if (!(isPlayer _x) && (vehicle _x == _x)) then {_x setPos _testpos;};
		};
	} forEach _toCache;
};

zbe_setPosFull = {
	{
		private _testpos = (formationPosition _x);
		if (!(isNil "_testpos") && (count _testpos > 0)) then {
			if (!(isPlayer _x) && (vehicle _x == _x)) then {
				_x setPos _testpos;
				_x allowDamage false;
				[_x] spawn {sleep 3; (_this select 0) allowDamage true;};
			};
		};
	} forEach _toCache;
};

zbe_removeDead = {
	{
		if !(alive _x) then {
			_x enableSimulation true;
			_x hideObject false;
			if (zbe_debug) then {diag_log format ["ZBE_Cache %1 died while cached from group %2, uncaching and removing from cache loop", _x, _group];};
			_toCache = _toCache - [_x];
		};
	} forEach _toCache;
};

zbe_cacheEvent = {
	({_x distance _leader < _distance} count zbe_players > 0) || !isNull (_leader findNearestEnemy _leader)
};

zbe_vehicleCache = {
	_vehicle enableSimulationGlobal false;
};

zbe_vehicleUncache = {
	_vehicle enableSimulationGlobal true;
};