/*********************************************************************************
 _____ ____  _____ 
|  _  |    \|   __|
|     |  |  |   __|
|__|__|____/|__|   
ARMA Mission Development Framework
ADF version: 2.26 / Jul 2020

Function: Search for Intel
Author: Whiztler
Script version: 1.07

File: fn_searchIntel.sqf
**********************************************************************************
ABOUT
This function let's you add intel to ai units, vehicles, boxes, buildings, etc. In
case of an ai unit, the unit needs to be dead or (ACE3) handcuffed. In case of
buildings/vehicles/etc they need to be alive/not destroyed.

The function has 50+ default messages for 'no intel found' and 25 default messages
for 'intel found'. The intel found messages also have an ID which is passed to a
custom function (optional) so you can run custom code based on the intel found.

You can also pass your own 'intel found' messages. The ID number needs to start at
at least 21 (0-20 are taken by the default messages). In this example we start with
number 50:

[
	[50, "Intel found msg 1"], // Message ID, message
	[51, "Intel found msg 2"], // Message ID, message
	[52, "Intel found msg 3"], // Message ID, message
	[53, "Intel found msg 4"], // Message ID, message
	[54, "Intel found msg 5"] // Message ID, message
	// No comma for the last entry!
]

You can pass 2 functions / snippets of code:
Code 1: Code/Function is called upon activation. So when the 'Search for intel'
        menu/action becomes available for the player when the player is within 2
        meters of the searchable object (body/vehicle/etc). See below for params        
Code 2: Code/Function is called after the search message has been displayed. The
        code is called for valid intel and a no-intel search result. A variable
        (bool) is passed that holds if intel was found (true) or not (false).
        See below for further params.

INSTRUCTIONS:
Execute (call) from the server or headless client. It needs to be executed from
the owner of the object. Players are prohibited to execute the function!

To save performance you can add the action the moment an AI dies, e.g.
_unit addEventHandler ["killed", {[_this # 0] call ADF_fnc_searchIntel}];

REQUIRED PARAMETERS:
0: Object:  Man / Vehicle / Aircraft / Box / Building / etc.		  

OPTIONAL PARAMETERS:
1: Array:   Array of intel messages. Format:
            [[50, "Intel found msg 1"], [51, "Intel found msg 2"]]
2. Bool:    Add the custom (1) intel messages to the default messages?
            -true - Merge with the default messages (default).
            -false - Do not merge. Only use the custom messages.
3. Integer: What is the chance (percentage) of finding intel (number 1 - 100)?
            Default: 15
4. String:  Code 1. Code/funcgion to execute on activation but before the search.
            Default = "".
            Params passed to the function:
            _this select 0 - object: object (that will be searched)
            _this select 1 - player: player that will do the searching
            _this select 2 - bool: true for intel to be found. False for no intel
5. String:  Code 2.Code/funcgion to execute after the search.
            Default = "".
            Params passed to the function:
            _this select 0 - object: object (that will be searched)
            _this select 1 - player: player that will do the searching
            _this select 2 - bool: true for intel to be found. False for no intel
            _this select 3 - integer: message ID (number). -1 for 'No intel found'		  

EXAMPLES USAGE IN SCRIPT:
[_unit, [[50, "Intel found msg 1"], [51, "Intel found msg 2"]], false, 25, "my_intel_function"] call ADF_fnc_searchIntel;
[_unit, [], true, 25, "", "myFnc_IntelFound"] call ADF_fnc_searchIntel;

EXAMPLES USAGE IN EDEN:
[this, [[50, "Intel found msg 1"], [51, "Intel found msg 2"]], true, 20, "intel_searching_function", "intel_found_function"] call ADF_fnc_searchIntel;
[this, [], true, 10, "", "myFnc_IntelFound"] call ADF_fnc_searchIntel;

DEFAULT/MINIMUM OPTIONS
[_unit] call ADF_fnc_searchIntel;

RETURNS:
Success flag (bool)
*********************************************************************************/

// Init
params [
	["_object", objNull, [objNull, grpNull]], 
	["_intel", [], [[]]],	
	["_addIntel", true, [false]],	
	["_intelChance", 15, [0]],	
	["_code_1", "", [""]], 
	["_code_2", "", [""]], 
	["_isMan", false, [true]], 
	["_isLandVehicle", false, [true]], 
	["_isAircraft", false, [true]], 
	["_isGroup", false, [true]], 
	["_group", grpNull, [grpNull]], 
	["_leader", false, [true]], 
	["_ace_handCuffed", false, [true]],
	["_actionDescription", "", [""]],
	["_intelFound", false, [true]]
];

// Set vars and check valid vars
//if hasInterface exitWith {[format ["ADF_fnc_searchIntel - Client is a player. Not allowed (%1). Exiting!", _object], true] call ADF_fnc_log; false};
if !(local _object) exitWith {[format ["ADF_fnc_searchIntel - No owner. Another entity is trying to add the search intel action to: %1. Exiting!", _object], true] call ADF_fnc_log; false};
if (_object isEqualType grpNull) then {_group = _object; _object = leader _group; _isGroup = true;};
if (_code_1 != "") then {if (isNil _code_1) then {if ADF_debug then {[format ["ADF_fnc_searchIntel - incorrect code 1 (%1) passed. Defaulted to ''.", _code_1]] call ADF_fnc_log;}; _code_1 = "";}};
if (_code_2 != "") then {if (isNil _code_2) then {if ADF_debug then {[format ["ADF_fnc_searchIntel - incorrect code 2 (%1) passed. Defaulted to ''.", _code_2]] call ADF_fnc_log;}; _code_2 = "";}};
if (_object isKindOf "CAManBase") then {_isMan = true;};
if (_object isKindOf "LandVehicle") then {_isLandVehicle = true;};
if (_isLandVehicle && {!alive _object}) exitWith {["ADF_fnc_searchIntel - Cannot run on a fully destroyed land vehicle. Exiting!", true] call ADF_fnc_log; false};
if (_object isKindOf "Plane" || {_object isKindOf "Helicopter"}) then {_isAircraft = true;};
if (_isMan && {alive _object && {(ADF_mod_ACE3 && {!isHandcuffed})}}) exitWith {["ADF_fnc_searchIntel - Cannot run on an AI which is alive and not handcuffed (ACE). Exiting!", true] call ADF_fnc_log;};
if (_isLandVehicle && {!alive _object}) exitWith {["ADF_fnc_searchIntel - Cannot run on a fully destroyed land vehicle. Exiting!", true] call ADF_fnc_log; false};
if (_isAircraft && {!alive _object}) exitWith {["ADF_fnc_searchIntel - Cannot run on a fully destroyed aircraft. Exiting!", true] call ADF_fnc_log; false};
if (random 100 < _intelChance) then {_intelFound = true};
private _arguments = [_intel, _code_1, _code_2, _addIntel, _intelFound];

// in case of a group run the function on each of the group's units
if _isGroup exitWith {{[_x, _intel, _addIntel, _intelChance, _code_1, _code_2] call  ADF_fnc_searchIntel} count units _group; true};

// Action text
call {
	if _isMan exitWith {_actionDescription = "<t align='left' color='#FFFFFF'>Search body for intel</t>";};
	if (_object isKindOf "car") exitWith {_actionDescription = "<t align='left' color='#FFFFFF'>Search car for intel</t>";};
	if (_object isKindOf "Wheeled_APC_F") exitWith {_actionDescription = "<t align='left' color='#FFFFFF'>Search APC for intel</t>";};
	if (_object isKindOf "APC") exitWith {_actionDescription = "<t align='left' color='#FFFFFF'>Search APC for intel</t>";};
	if (_object isKindOf "Tank") exitWith {_actionDescription = "<t align='left' color='#FFFFFF'>Search tank for intel</t>";};
	if (_object isKindOf "Ship") exitWith {_actionDescription = "<t align='left' color='#FFFFFF'>Search boat for intel</t>";};
	if (_object isKindOf "Helicopter") exitWith {_actionDescription = "<t align='left' color='#FFFFFF'>Search helicopter for intel</t>";};	
	if (_object isKindOf "Bag_Base") exitWith {_actionDescription = "<t align='left' color='#FFFFFF'>Search backpack for intel</t>";};
	if (_object isKindOf "Furniture_base_F") exitWith {_actionDescription = "<t align='left' color='#FFFFFF'>Search item for intel</t>";};
	if (_object isKindOf "Building") exitWith {_actionDescription = "<t align='left' color='#FFFFFF'>Search structure for intel</t>";};
	if (_object isKindOf "ReammoBox_F") exitWith {_actionDescription = "<t align='left' color='#FFFFFF'>Search box for intel</t>";};
	if _isLandVehicle exitWith {_actionDescription = "<t align='left' color='#FFFFFF'>Search vehicle for intel</t>";};
	if _isAircraft exitWith {_actionDescription = "<t align='left' color='#FFFFFF'>Search aircraft for intel</t>";};
	if (_object isKindOf "UAV") exitWith {_actionDescription = "<t align='left' color='#FFFFFF'>Search UAV for intel</t>";};
	_actionDescription = "<t align='left' color='#FFFFFF'>Search for intel</t>";
};

// Add the search intel action
_object addAction [
	_actionDescription, {
		// init
		params ["_object", "_caller", "_id", "_arguments"];
		_arguments params ["_intel", "_code_1", "_code_2", "_addIntel", "_intelFound"];
		private _message = "";
		private _messageID = -1;		
		
		// Execute custom passed code-1/function before we do anything else
		if (_code_1 != "") then {
			// Each unit in the group
			[_object, _caller, _intelFound] call (call compile format ["%1", _code_1]);
			// Debug reporting
			if ADF_debug then {[format ["ADF_fnc_searchIntel - call %1 for %2, %3 (intel found: %4)", _code_1, _object, _caller, _intelFound]] call ADF_fnc_log};
		};		
		
		// Make sure that the search intel function can only run once per object.
		_object removeAction _id;
		
		// Default search messages - NO INTEL FOUND
		_noIntelFoundMessages = [
			"You found a wallet. It contains some foreign currency, a few receipts, and a photo of a man, a woman and their two children.",
			"You found a wallet. It containers a drivers licence, a few bank and credit cards, some foreign currency and a few notes with hand writing.",
			"You found a few coins and a packet of odd looking candy.",
			"You found a tin of chewing tabacco, a paperclip and a dirty rag. You're considering trying the tabacco.",
			"You found some documents. It looks like a manual to maintain and repair some sort of unknown machinery. A coffee grinder?",
			"You found a plastic container with documents. It looks like insurance policies, statements and a few entry permits.",
			"You found a tourist map of the region. It has some markings on. They seem to have marked the best places to have coffee. Always good to know.",
			"You found a small pouch with ammunition of various calibre. None of them seem to be of use for a weapon you carry.",
			"You found a lunch box with a half-eaten sandwich. The strong smell of mutton and goats cheese makes you hurl.",
			"You found a small pouch with small precision tools. The kind of tools used breaking and entering a building.",
			"You found a packet of cigarettes. No filter and they smell a bit funny. You wonder what they added to the tobacco.",
			"You found a bunch of old photos. Different family members at different stages of their lives. Paris, Amsterdam, Cairo, they have been around. They seem happy.",
			"You found a packet of chewing gum. It has an odd smell. Orange and coriander flavour?",
			"You found a set of keys, some small coins, a disposable gas lighter, a button, and a stained handkerchief.",
			"You found a blood stained letter from a young man, his son? On the back of the latter there are some notes in a foreign language.",
			"You found a packet of Marlboro sigarettes. Upon further inspection the packet containes shag handrolled sigarettes. They have a funny smell.",
			"You found a stiletto knife. It looks very old and razor sharp. The blade has some dried blood stains on it.",
			"You found an old cell phone. A Nokia 3310, no password protection. No credit on the sim. No call history and no text messages.",
			"You found a Samsung Galaxy smart phone. An older model. The glass is broken and you cannot switch on the phone. It is beyond repair.",
			"You found an iPhone. It seems like a model 8. The Sim card has been removed and the battery is dead.",
			"You found a Huawei tablet. The on/off button is broken and the battery seems to be leaking some gooey material.",
			"You found an old revolver. A hammerless 38 S&W. It looks like it is at least 80 years old. No ammunition. A beauty none the less.",
			"You found some disposable pens, a few paper clips, a mini stapler and some 3M post-it notes with Arab scribbles on it. Seems to be accounting information.",
			"You found a few tie-wraps, some rubber bands and coins from 5 or 6 different currencies.",
			"You found a few condoms, they look really old. You also discover some gold coins. They are not from this region or country. You cannot make out the markings. You keep the coins",
			"You found some reading glasses and a pair of odd looking tweezers, the kind that watchmakers use.",
			"You found a bunch of hair tied together with a rubber band. It is blond/gray-ish hair and has a funny smell to it. Weird",
			"You found a stack of notes with unreadable scribbling on it. They seem to be reminders and shopping lists.",
			"You found a ring box with an engagement ring in it. You also found a note in a foreign language and a photo of his fianc??e.",
			"You found a pair of nail clippers. They look well used with pieces of skin and nail stuck to it.",
			"You found a passport. Since it is in a foreign language you cannot make out the country of origin. It looks like it has some water damage.",
			"You found an old newspaper. You cannot make out the language, but it looks old. People around here use newspapers to sit on in public places.",
			"You found some sort of a lottery ticket. It seems from last year. You are wondering if you can exchange it for that huge price you have been dreaming off???",
			"You found a small bag with various nick-knacks, a construction manual and some engineering permits off sorts.",
			"You found a small case of documents. They are in various languages. All you can make out is that they were drafted by a lawyer. Divorce papers?",
			"You found an iPod. It looks in great condition. You browse through the playlist and find that you know none of the songs and artist. Must be local country music.",
			"You found a walkie-talkie, Russian made by the look of it. You also find a pair of used batteries and a pair of Chinese made bino's.",
			"You found ammunition for what looks like 7.62, probably for a Dragunanov or Mosin???Nagant rifle. He could be a hunter but it could also be for a sniper rifle.",
			"You found a few plastic toys. It looks like someone chewed on them. You also find various coins, some of them US quarter dollar coins. Wonder where he got them from???",
			"You found an old pocket knife. It is marked Vorsma TR and has a USSR emblem on it. Real vintage. Must be worth a few bucks in the Western hemisphere.",
			"You found a wallet with nothing but a few photo's inside. The photo's seem from early last century. On the back it reads in German 'Endlich angekommen. Jetzt beginnt das gute Leben'",
			"You found a few packs of filter-less cigarettes, 'Gold Leaf Special'. Smoking is very common in this region and this seems to be the best-selling brand.",
			"You found two new post cards. They are from a city about 200 km's north from here. One of them has writing on it in a foreign language. I guess he was going to post them today.",
			"You found a folder containing what seems to be junior school documents. A report of his child perhaps? There are also a few garage bill in the folder.",
			"You found a nice pair of Ray-Ban Aviator glass. Gold frame of course. With expensive flash lenses. Unfortunately they don't fit.",
			"You found a used syringe. It is in a protective casing. The syringe looks like it may be 20 or so years old. Perhaps the owner is a diabetic.",
			"You found a pocket copy of the Quran. There's a few pieces of paper with notes inside. In the back there are a few currency bills. They seem to be used as a bookmark.",
			"You found bits and pieces of paper, some foreign currency, bunch of paper clips, a Parker pen, and a small note book used as a contact directory.",
			"You found a pocket camera. Sony Cybershot. The lens seems damaged. It powers on, you check the photo's, but there seems to be nothing of interest.",
			"You found a switch blade. Looks brand new. A marking says 'Schrade', must be German made. You try the blade but nearly cut off your thumb. You quickly ditch it.",
			"You found an old flashlight, no batteries inside. There's also a billfold with a stack in it. Though it seems the outer bill is a $20 bill, the rest are just newspapers strips. Poofter. You keep the twenty.",
			"You found a water bottle with a yellow-ish liquid inside. Def not going to smell that. There's also a wallet with a lot of foreign currency inside. From different countries it seems",
			"You found a small bag with seeds, they look like cannabis seeds. There must be more than a thousand here. Don't they sell them for $80 per 10 at home?",
			"You found a snickers bar. The wrapping looks a bit old. You check the best before date. 11-DEC-2017. Yuk. You also find some coins, paper clips and a few pieces of gum without their wrapper"		
		];
		
		// Default search messages - INTEL FOUND
		_intelFoundMessages = [
			[1, "You found a USB-stick. You hand it over to you CO who calls it in over the radio. Command wants the data urgently."],
			[2, "You found a briefcase with various documents and maps. Some of the maps have routing and positions indicated on it. You hand over the documents to your CO."],
			[3, "You found a Samsung smart phone. It's unlocked. You check the messages and find that there is a lot of interesting intel in the phone. You hand over the phone to the CO."],
			[4, "You found a map with various locations of what seems to be weapons caches and fuel stacks. You pass on the map to your CO who informs command immediately."],
			[5, "You found a packet of cigarettes with a sim card and a memory card inside. You stick the card in your camera and scroll through many photos of insurgency camps and locations. Better hand this over quickly."],
			[6, "You found a tablet with all kinds of documents on it. There's even a tracker app on with GPS tracks. Great intel. You hand over the tablet to your CO."],
			[7, "You found a pouch with maps and documents. The maps show our positions and possible attack vectors. You hand over the map and the documents to you CO."],
			[8, "You found an old Nokia photo. The phone is unlocked and provides access to the phonebook, messages and GPS data. You give the phone to you CO. "],
			[9, "You found a stock of credit cards with sim cards clipped in. They are probably used for burner phones. You pass on the cards to your CO."],
			[10, "You found a laptop, an ASUS, seems recent. You open the cover and boot-up the laptop. There is a logon screen. Since you don't have the password, you pass on the laptop to your CO."],
			[11, "You found a stack of photos. You recognize a few of our officers. It seems a hit list or a target list of sort. You warn the CO immediately. "],
			[12, "You found a tool that looks like a flashlight but on further study is a long distance laser pointer. Useful for laser guided weapons. You give it to your CO."],
			[13, "You found a TomTom navigation unit. You switch it on and from the history you can tell that they have been around out base several times. You give the nav unit to your CO."],
			[14, "You found an aluminium attache briefcase. It's locked. You break it open and find classified documents, photos, maps, a USB dongle, cigarettes, pens and a small GPS tracker. Great find. You quickly pass it on to your CO."],
			[15, "You found a BluFor tracker. This will allow OpFor to track our movements. How did they get their hands on this? Command needs to know urgently. All our positions are compromised."],
			[16, "You found a hand drawn map which looks like it is off this area. Various locations are market but it is unclear what the markings mean. Perhaps you CO can make something of it."],
			[17, "You found a map with several marked areas. Mine fields? Not sure but better pass it on to your CO."],
			[18, "You found a wad of dollar bills. Must be over 20 thousand dollars. You wonder how they get that kind of cash. You pass it on to your CO who call it in with Command."],
			[19, "You found a few bags of heroin. It looks pure. Must be worth a small fortune. You call over your CO, who radios Command for instructions."],
			[20, "You found a small notebook which has GPS positions, a ledger and a long list of names and numbers. You can't make heads or tails of it. Better pass it on to your CO."]
		];
		
		_foundNothingMessages = [
			"Found nothing of interest.",
			"Dust, sand, nothing worth looking into.",
			"There seems to be nothing here.",
			"Well that was a waste of time.",
			"Nothing, nada, niente.",
			"Nothing here.",
			"This one seems clean as a whistle."
		];
		
		// Select a message.
		if _intelFound then {			

			// Add custom intel messages to the default messages?
			if (_addIntel && {!(_intel isEqualTo [])}) then {
				_intelFoundMessages append _intel;
			};
			
			// Replace default intel messages with custom intel messages?
			if (!_addIntel && {!(_intel isEqualTo [])}) then {
				_intelFoundMessages = _intel;
			};
			
			// Select an intel found message
			private _intelFoundMessage = selectRandom _intelFoundMessages;
			_messageID = _intelFoundMessage # 0;
			_message = _intelFoundMessage # 1;			
		} else {
			if (random 100 < 60) then {
				_message = selectRandom _noIntelFoundMessages;
			} else {
				_message = selectRandom _foundNothingMessages;
			};			
		};

		// Display the message to the player that performed the search
		["<t size='.7' color='#FFFFFF'>Searching...</t>", 0, 0, 6, 5] remoteExec ["BIS_fnc_dynamicText", _caller];
		sleep 7;
		["<t size='.7' color='#FFFFFF'>" + _message + "</t>", 0, 0, 10, 2] remoteExec ["BIS_fnc_dynamicText", _caller];
		
		// Execute custom passed code-2/function once the seach intel function is complete.
		if (_code_2 != "") then {
			// Group
			[_object, _caller, _intelFound, _messageID] call (call compile format ["%1", _code_2]);
			// Debug reporting
			if ADF_debug then {[format ["ADF_fnc_searchIntel - call %1 for %2, %3 (intel found: %4)", _code_1, _object, _caller, _intelFound, _messageID]] call ADF_fnc_log};			
		};		
	},
	_arguments, 5, true, true, "", "speed _target < 1 && isPlayer _this", 2.5
];

true