/*********************************************************************************
 _____ ____  _____ 
|  _  |    \|   __|
|     |  |  |   __|
|__|__|____/|__|   
ARMA Mission Development Framework
ADF version: 2.26 / Jul 2020

Function: ADF_fnc_typeWriter
Author: BIS / Larrow. Adapted for ADF by Whiztler
Script version: 1.02

File: fn_typeWriter.sqf
**********************************************************************************
ABOUT
Creates a typewriter effect on the players screen. Can be used on mission start.

INSTRUCTIONS:
Execute (call) from any client

REQUIRED PARAMETERS:
0. Array:      See below example

OPTIONAL PARAMETERS:
N/A   

EXAMPLES USAGE IN SCRIPT:
[
    ["19 MAY 2019", "<t align = 'center' shadow = '1' size = '0.7'>%1</t><br/>"],
    ["Your fantastic tagline here", "<t align = 'center' shadow = '1' size = '1.0'>%1</t><br/>"],
    ["Another tagline here", "<t align = 'center' shadow = '1' size = '1.0'>%1</t><br/>"]
] spawn ADF_fnc_typeWriter;

EXAMPLES USAGE IN EDEN:
N/A

DEFAULT/MINIMUM OPTIONS
N/A

RETURNS:
Bool (success flag)
*********************************************************************************/

// Reporting
if (ADF_extRpt || {ADF_debug}) then {diag_log "ADF rpt: fnc - executing: ADF_fnc_typeWriter"};

// Init
private _c	= count _this;
private _q	= "<t color ='#000000' shadow = '0'>_</t>";
private _bs	= [];
private _fs	= [];
private _qc	= 0;

{
	private _i = _x;
	private _b = [_i, 0, "", [""]] call BIS_fnc_param;
	private _f = [_i, 1, "<t align = 'center' shadow = '1' size = '0.7'>%1</t><br/>", [""]] call BIS_fnc_param;

	// convert strings into array of chars
	private _a = toArray _b;
	{_a set [_forEachIndex, toString [_x]]} forEach _a;

	_bs = _bs + [_a];
	_fs = _fs + [_f];
} forEach _this;

// init the message string
private _m = "";

{
	_a	= _x;
	private _bi	= _forEachIndex;
	private _bf	= _fs # _bi;
	private _bt1	= "";
	private _bt2	= "";
	private _bt3	= "";

	{
		private _k = _x;
		_bt1	= _bt1 + _k;
		_bt2	= format[_bf, _bt1 + _q];
		_bt3	= format[_bf, _bt1 + "_"];

		//print the output
		[(_m + _bt3), 0, 0.5, 5, 0, 0, 90] spawn BIS_fnc_dynamicText;
		playSound "click";
		sleep 0.08;
		[(_m + _bt2), 0, 0.5, 5, 0, 0, 90] spawn BIS_fnc_dynamicText;
		sleep 0.02;
	} forEach _a;

	if (_bi + 1 < _c) then {_qc = 5;} else {_qc = 15;};

	for "_i" from 1 to _qc do {
		[_m + _bt3, 0, 0.5, 5, 0, 0, 90] spawn BIS_fnc_dynamicText;
		sleep 0.08;
		[_m + _bt2, 0, 0.5, 5, 0, 0, 90] spawn BIS_fnc_dynamicText;
		sleep 0.02;
	};

	// store finished block
	_m = _m + _bt2;
} forEach _bs;

// erase from the screen
["", 0, 0.15, 5, 0, 0, 90] spawn BIS_fnc_dynamicText;