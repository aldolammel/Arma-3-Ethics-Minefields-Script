// ETHICS MINEFIELDS v1.2
// File: your_mission\ETHICSMinefields\fn_ETHICS_globalFunctions.sqf
// by thy (@aldolammel)


// ETHICS CORE / TRY TO CHANGE NOTHING BELOW!!! --------------------------------------------------------------------


THY_fnc_ETHICS_marker_name_splitter = {
	// This function splits the marker name to check if the name has the basic structure for further validations.
	// Returns array _mfNameStructure

	params ["_markerName", "_prefix", "_spacer"];
	private ["_txtWarningHeader", "_txtWarning_1", "_mfNameStructure", "_spacerAmount"];

	// Debug txts:
	//_txtDebugHeader = "ETHICS DEBUG >";
	_txtWarningHeader = "ETHICS WARNING >";
	_txtWarning_1 = format ["If the intension is make it as minefield, its structure name must be '%1%2TagDoctrine%2TagFaction%2anynumber' or '%1%2TagDoctrine%2anynumber'.", _prefix, _spacer];
	// check if the marker name has more than one _spacer character in its string composition:
	_mfNameStructure = _markerName splitString "";
	_spacerAmount = count (_mfNameStructure select {_x find _spacer isEqualTo 0});  // counting how many times the same character appers in a string.
	// if the _spacer is been used correctly:
	if ( _spacerAmount == 2 OR _spacerAmount == 3 ) then {
		// spliting the marker name to check its structure:
		_mfNameStructure = _markerName splitString _spacer;
	// Otherwise, if the _spacer is NOT been used correctly:
	} else {
		// Warning message:
		systemChat format ["%1 Minefield '%2' > You're not using or using too much the character '%3'. %4", _txtWarningHeader, _markerName, _spacer, _txtWarning_1];
	};
	// Return:
	_mfNameStructure;
};


THY_fnc_ETHICS_minefields_scanner = {
	// This function search and append in a list all area-markers confirmed as a real minefield. The searching take place once right at the mission begins.
	// Returns _confirmedMfMarkers: array [[minefield markers of factions], [minefield markers of unknown owner]]

	params ["_prefix", "_spacer"];
	private ["_realPrefix", "_acceptableShapes", "_txtDebugHeader", "_txtWarningHeader", "_txtWarning_1", "_confirmedMfMarkers", "_confirmedMfUnknownMarkers", "_confirmedMfFactionMarkers", "_possibleMinefieldMarkers", "_mfNameStructure", "_mfDoctrine", "_mfFaction", "_isNumber"];

	// Declarations:
	_realPrefix = _prefix + _spacer;
	_acceptableShapes = ["RECTANGLE", "ELLIPSE"];
	// Debug txts:
	_txtDebugHeader = "ETHICS DEBUG >";
	_txtWarningHeader = "ETHICS WARNING >";
	_txtWarning_1 = format ["If the intension is make it as minefield, its structure name must be '%1%2TagDoctrine%2TagFaction%2anynumber' or '%1%2TagDoctrine%2anynumber'.", _prefix, _spacer];
	// Initial values:
	_confirmedMfMarkers = [];
	_confirmedMfUnknownMarkers = [];
	_confirmedMfFactionMarkers = [];
	// Step 1/2 > Creating a list with only area markers with right prefix:
	if ( !ETHICS_debug ) then {
		// Smarter and faster solution, searching and creating the list:
		_possibleMinefieldMarkers = allMapMarkers select { (_x find _realPrefix == 0) AND {(markerShape _x) in _acceptableShapes} };
		if ( (count _possibleMinefieldMarkers) == 0 ) exitWith { systemChat format ["%1 This mission still has no possible minefield(s) to be loaded. %2", _txtWarningHeader, _txtWarning_1] };
	// As the slower solution, for debugging purporses:
	} else {
		 // Selecting the relevant markers in a slightly different way. Now searching for all marker shapes:
		_possibleMinefieldMarkers = allMapMarkers select { _x find _realPrefix == 0 };
		if ( (count _possibleMinefieldMarkers) == 0 ) exitWith { systemChat format ["%1 This mission still has no possible minefield(s) to be loaded. %2", _txtWarningHeader, _txtWarning_1] };
		{ // forEach _possibleMinefieldMarkers:
			// if the marker has no the shapes acceptables, do it:
			if ( !((markerShape _x) in _acceptableShapes) ) then {
				// delete the marker from the list:
				_possibleMinefieldMarkers deleteAt (_possibleMinefieldMarkers find _x);
				// delete the marker from the map:
				//deleteMarker _x;
				// Debug message:
				systemChat format ["%1 Minefield '%2' > This minefield has NO a rectangle or ellipse shape to be considered a minefield.", _txtDebugHeader, _x];
			};
		} forEach _possibleMinefieldMarkers;
	};
	// Step 2/2 > Deleting to the list those selected markers that don't fit the name's structure rules:
	{  // forEach _possibleMinefieldMarkers:
		// check if the marker name has more than one _spacer character in its string composition:
		_mfNameStructure = [_x, _prefix, _spacer] call THY_fnc_ETHICS_marker_name_splitter;
		// Case by case, check the valid marker name's amounts of strings:
		switch ( count _mfNameStructure ) do {
			// Case example: mf_ap_1
			case 3: {
				// Check if the doctrine tag is correctly applied:
				_mfDoctrine = [_mfNameStructure, _x] call THY_fnc_ETHICS_marker_name_session_doctrine;  // So far, I'm NOT using this _mfDoctrine return 'cause I'm handling the error within.
				// Check if the last session of the area marker name is numeric:
				_isNumber = [_mfNameStructure, _x, _prefix, _spacer] call THY_fnc_ETHICS_marker_name_session_number;
				// If all validations alright:
				if ( (_mfDoctrine != "") AND _isNumber ) then { _confirmedMfUnknownMarkers append [_x] };
			};
			// Case example: mf_ap_ind_2
			case 4: { 
				// Check if the doctrine tag is correctly applied:
				_mfDoctrine = [_mfNameStructure, _x] call THY_fnc_ETHICS_marker_name_session_doctrine;  // So far, I'm NOT using this _mfDoctrine return 'cause I'm handling the error within.
				// Check if the faction tag is correctly applied:
				_mfFaction = [_mfNameStructure, _x] call THY_fnc_ETHICS_marker_name_session_faction;  // So far, I'm NOT using this _mfFaction return 'cause I'm handling the error within.
				// Check if the last session of the area marker name is numeric:
				_isNumber = [_mfNameStructure, _x, _prefix, _spacer] call THY_fnc_ETHICS_marker_name_session_number;
				// If all validations alright:
				if ( (_mfDoctrine != "") AND _isNumber ) then { _confirmedMfFactionMarkers append [_x] };
			};
		};
	} forEach _possibleMinefieldMarkers;
	// Updating the general list to return:
	_confirmedMfMarkers = [_confirmedMfFactionMarkers, _confirmedMfUnknownMarkers];
	// Debug messages:
	if ( ETHICS_debug ) then {
		if ( (count _confirmedMfFactionMarkers) > 0 ) then { systemChat format ["%1 Faction minefield(s) ready to got mines: %2", _txtDebugHeader, _confirmedMfFactionMarkers] };
		if ( (count _confirmedMfUnknownMarkers) > 0 ) then { systemChat format ["%1 Unknown minefield(s) ready to got mines: %2", _txtDebugHeader, _confirmedMfUnknownMarkers] };
	};
	// Returning:
	_confirmedMfMarkers;
};


THY_fnc_ETHICS_available_doctrines = {
	// This function just checks and returns which doctrines are available for the mission.
	// Returns _allDoctrinesAvailable: array [list of strings]

	params ["_isOnDoctrinesLand", "_isOnDoctrinesNaval"];
	private ["_doctrinesLand", "_doctrinesNaval", "_allDoctrinesAvailable"];

	// Debug txts:
	//private _txtDebugHeader = "ETHICS DEBUG >";
	//private _txtWarningHeader = "ETHICS WARNING >";
	// Initial values:
	_doctrinesLand = [];
	_doctrinesNaval = [];
	// Checking the available doctrines:
	if ( _isOnDoctrinesLand ) then { _doctrinesLand = ["AP", "AM", "HY"] };
	if ( _isOnDoctrinesNaval ) then { _doctrinesNaval = ["NAM"] };
	// Merging all available doctrines to return:
	_allDoctrinesAvailable = _doctrinesLand + _doctrinesNaval;
	// Return:
	_allDoctrinesAvailable;
};



THY_fnc_ETHICS_marker_name_session_doctrine = {
	// This function checks the second session (mandatory) of the area marker's name, validating if the session is a valid ammunition doctrine;
	// Returns _mfDoctrine: string.

	params ["_mfNameStructure", "_mf"];
	private ["_txtWarningHeader", "_allDoctrinesAvailable", "_mfDoctrine"];

	// Debug txts:
	//private _txtDebugHeader = "ETHICS DEBUG >";
	_txtWarningHeader = "ETHICS WARNING >";
	// Checking the available doctrines:
	_allDoctrinesAvailable = [ETHICS_landMinesDoctrines, ETHICS_navalMinesDoctrines] call THY_fnc_ETHICS_available_doctrines;
	_mfDoctrine = toUpper (_mfNameStructure select 1);  // if mission editor doesn't typed uppercase, this fixes it.
	if ( !(_mfDoctrine in _allDoctrinesAvailable) ) then {
		systemChat format ["%1 Minefield '%2' > The doctrine tag looks wrong. There's no any '%3' doctrine available. Fix the marker variable name or check the available doctrines on fn_ETHICS_management.sqf.", _txtWarningHeader, _mf, _mfDoctrine];
		_mfDoctrine = "";
	}; 
	// Return:
	_mfDoctrine;
};


THY_fnc_ETHICS_marker_name_session_faction = {
	// This function checks the optional session of the area marker's name, validating if the session is a valid faction;
	// Returns _mfFaction: string.

	params ["_mfNameStructure", "_mf"];
	private ["_txtWarningHeader", "_mfFaction"];

	// Debug txts:
	//private _txtDebugHeader = "ETHICS DEBUG >";
	_txtWarningHeader = "ETHICS WARNING >";
	// Faction validation:
	_mfFaction = toUpper (_mfNameStructure select 2);
	if ( !(_mfFaction in ["BLU", "OPF", "IND"]) ) then {
		systemChat format ["%1 Minefield '%2' > The faction tag looks wrong. There's no '%3' option. For this minefield owner, it was changed to unknown.", _txtWarningHeader, _mf, _mfFaction];
		_mfFaction = "";
	};
	// Return:
	_mfFaction;
};


THY_fnc_ETHICS_marker_name_session_number = {
	// This function checks the last session (mandatory) of the area marker's name, validating if the session is numeric;
	// Returns _isNumber: bool.

	params ["_mfNameStructure", "_mf", "_prefix", "_spacer"];
	private ["_txtWarningHeader", "_txtWarning_1", "_isNumber", "_index", "_itShouldBeNumeric"];

	// Debug txts:
	//private _txtDebugHeader = "ETHICS DEBUG >";
	_txtWarningHeader = "ETHICS WARNING >";
	_txtWarning_1 = format ["If the intension is make it as minefield, its structure name must be '%1%2TagDoctrine%2TagFaction%2anynumber' or '%1%2TagDoctrine%2anynumber'.", _prefix, _spacer];
	// Initial values:
	_isNumber = false;
	_index = nil;
	// Number validation:
	if ( (count _mfNameStructure) == 3 ) then { _index = 2 } else { _index = 3 }; // it's needed because marker names can have 3 or 4 sessions, depends if the faction tag is been used.
	_itShouldBeNumeric = parseNumber (_mfNameStructure select _index);  // result will be a number extracted from string OR ZERO if inside the string has no numbers.
	if ( _itShouldBeNumeric != 0 ) then { _isNumber = true } else { systemChat format ["%1 Minefield '%2' > It has no a valid name. %3", _txtWarningHeader, _mf, _txtWarning_1] };
	// Return:
	_isNumber;
};


THY_fnc_ETHICS_style = {
	// This function set the minefield stylish on mission map.
	// Returns Nothing.

	params ["_debug",  "_mf", "_prefix", "_spacer", "_isVisible", "_color", "_brush"];
	private ["_colorToOthers", "_mfFaction", "_mfNameStructure"];

	// Declaration:
	_colorToOthers = "ColorUNKNOWN";
	// Initial values:
	_mfFaction = "";
	// Debug mode ON:
	if ( _debug ) then {
		// check if the marker name has more than one _spacer character in its string composition:
		_mfNameStructure = [_mf, _prefix, _spacer] call THY_fnc_ETHICS_marker_name_splitter;
		// Case by case, check the valid marker name's amounts of strings:
		switch ( count _mfNameStructure ) do {
			// Case example: mf_ap_1
			case 3: {
				// If the minefield owns is unknown, do it:
				if ( _color != _colorToOthers ) then { _color = _colorToOthers };
			};
			// Case example: mf_ap_ind_2
			case 4: {
				_mfFaction = toUpper (_mfNameStructure select 2);
				
				switch ( _mfFaction ) do {
					case "BLU": { if ( (_mfFaction == "BLU") AND ((side player) == blufor) ) then { _color = "colorRed" } else { _color = _colorToOthers } };
					case "OPF": { if ( (_mfFaction == "OPF") AND ((side player) == opfor) ) then { _color = "colorRed" } else { _color = _colorToOthers } };
					case "IND": { if ( (_mfFaction == "IND") AND ((side player) == independent) ) then { _color = "colorRed" } else { _color = _colorToOthers } };
				};
			};
		};
	};
	// Debug mode OFF:
	_mf setMarkerColorLocal _color;  // https://community.bistudio.com/wiki/Arma_3:_CfgMarkerColors
	_mf setMarkerBrushLocal _brush;  // https://community.bistudio.com/wiki/setMarkerBrush
	// Return:
	true;
};


THY_fnc_ETHICS_markers_visibility = {
	// This function controls locally if the specific player might see their minefields' faction on the map.
	// Returns nothing.

	params ["_confirmedMfMarkers", "_prefix", "_spacer", "_isVisible", "_color", "_brush", "_alpha"];
	private ["_eachConfirmedList", "_mfFaction", "_mfNameStructure"];

	{  // forEach _confirmedMfMarkers:
		_eachConfirmedList = _x;
		{  // forEach _eachConfirmedList:
			// Initial values:
			_mfFaction = "";
			// Looking for factions tag on minefield names:
			_mfNameStructure = [_x, _prefix, _spacer] call THY_fnc_ETHICS_marker_name_splitter;
			// At first, hide all minefields for this player:
			_x setMarkerAlphaLocal 0;
			// Minefield stylish:
			[ETHICS_debug, _x, _prefix, _spacer, _isVisible, _color, _brush] call THY_fnc_ETHICS_style;
			// if the marker's name has the faction session in its name, do it:
			if ( (count _mfNameStructure) == 4 ) then { _mfFaction = toUpper (_mfNameStructure select 2) };
			// if minefield marker owner matchs with the player faction, show locally the marker on the map:
			if ( ETHICS_debug OR (_isVisible AND (_mfFaction == "BLU") AND ((side player) == blufor)) ) then { _x setMarkerAlphaLocal _alpha };
			if ( ETHICS_debug OR (_isVisible AND (_mfFaction == "OPF") AND ((side player) == opfor)) ) then { _x setMarkerAlphaLocal _alpha };
			if ( ETHICS_debug OR (_isVisible AND (_mfFaction == "IND") AND ((side player) == independent)) ) then { _x setMarkerAlphaLocal _alpha };
		} forEach _eachConfirmedList;
	} forEach _confirmedMfMarkers;
	// Returns:
	true;
};


THY_fnc_ETHICS_shape_symmetry = {
	// This function checks the area shape symmetry of the minefield built by the Mission Editor through Eden. It's important to make the work of THY_fnc_ETHICS_mine_planter easier.
	// Returns nothing.

	params ["_mf"];
	private ["_txtWarningHeader", "_radiusMin", "_radiusMax", "_mfWidth", "_mfHeight"];

	// Debug txts:
	_txtWarningHeader = "ETHICS WARNING >";
	// Limiters:
	_radiusMin = 25;
	_radiusMax = 2500;
	// Minefield dimensions:
	_mfWidth = markerSize _mf select 0;
	_mfHeight = markerSize _mf select 1;
	// If the minefield marker shape is not symmetric, do it:
	if ( _mfWidth != _mfHeight ) then {
		// Make the minefield symmetric:
		_mf setMarkerSize [_mfWidth, _mfWidth];
		// Alert the mission editor:
		systemChat format ["%1 Minefield '%2' > it was resized to has its shape symmetric (mandatory).", _txtWarningHeader, _mf];
	};
	// If the minefield's radius is smaller than the minimal OR bigger than the maximum, do it:
	if ( (_mfWidth < _radiusMin) OR (_mfWidth > _radiusMax) ) then {
		// If smaller, do it:
		if (_mfWidth < _radiusMin) then { 
			// set the radius the minal value:
			_mf setMarkerSize [_radiusMin, _radiusMin];
			// Alarm message:
			systemChat format ["%1 Minefield '%2' > the script needed to increase the minefield size to the minimum radius.", _txtWarningHeader, _mf];
		// Otherwise, if equal or bigger:
		} else {
			// the maximum value:
			_mf setMarkerSize [_radiusMax, _radiusMax];
			// Alarm message:
			systemChat format ["%1 Minefield '%2' > the script needed to decrease the minefield size to the maximum radius.", _txtWarningHeader, _mf];
		};
	};
	// Return:
	true;
};


THY_fnc_ETHICS_mines_intensity = {
	// This function controls the number of mines specific for each minefield, based on its area size and general intensity level chosen, setting different amount limits to be planted through each minefield.
	// Returns _limitersByMineType: array [AP amount limiter, AM amount limiter]

	params ["_intensity", "_mfSize"];
	private ["_txtWarningHeader", "_limitersByMineType", "_mfRadius", "_mfArea", "_limiterMines"];

	// Debug txts:
	//private _txtDebugHeader = "ETHICS DEBUG >";
	_txtWarningHeader = "ETHICS WARNING >";
	// Handling errors:
	_intensity = toUpper _intensity;
	if ( !(_intensity in ["EXTREME", "HIGH", "MID", "LOW"]) ) then {
		systemChat format ["%1 fn_ETHICS_management.sqf > check the INTENSITY configuration. There's no any '%2' option. To avoid this error, the intensity was changed to 'MID'.", _txtWarningHeader, _intensity];
		_intensity = "MID";
	};
	// Initial values:
	_limitersByMineType = [];
	// Basic area calcs:
	_mfRadius = _mfSize select 0;  // 40.1234
	_mfArea = pi * (_mfRadius ^ 2);  // 5600.30
	// Case by case, do it:
	switch ( _intensity ) do {
		case "EXTREME": {
			_limiterMines = round ((sqrt _mfArea) * 2);
			_limitersByMineType = [_limiterMines, _limiterMines];  // Types of doctrine. There is no relation with hybrid concept here where would have proportions, etc. No!
		};
		case "HIGH": {
			_limiterMines = round (sqrt _mfArea);
			_limitersByMineType = [_limiterMines, _limiterMines];  // Types of doctrine. There is no relation with hybrid concept here where would have proportions, etc. No!
		};
		case "MID": {
			_limiterMines = round ((sqrt _mfArea) / 2);
			_limitersByMineType = [_limiterMines, _limiterMines];  // Types of doctrine. There is no relation with hybrid concept here where would have proportions, etc. No!
		};
		case "LOW": {
			_limiterMines = round ((sqrt _mfArea) / 6);
			_limitersByMineType = [_limiterMines, _limiterMines];  // Types of doctrine. There is no relation with hybrid concept here where would have proportions, etc. No!
		};
	};
	// return:
	_limitersByMineType;
};


THY_fnc_ETHICS_no_mine_topography = {
	// This function defines all topography features where a mine SHOULD avoid to be planted by the function THY_fnc_ETHICS_inspection. More about topography features on: https://community.bistudio.com/wiki/Location
	// Returns _noMineZonesTopography: array

	params ["_minePos"];
	private ["_noMineZones"];

	// Initial values:
	_noMineZonesTopography = [];
	// If topography rules off, just leave this function:
	if (!ETHICS_topographyRules) exitWith { _noMineZonesTopography; /*Returning*/ };
	// Topography features:
	_noMineZonesTopography = [
		nearestLocation [_minePos, "RockArea"],    // index 0
		nearestLocation [_minePos, "Hill"],        // index 1
		nearestLocation [_minePos, "Mount"]        // index 2
	];
	// Return:
	_noMineZonesTopography;
};


THY_fnc_ETHICS_no_mine_ethics = {
	// This function defines all civilian locations where a mine SHOULD avoid to be planted by the function THY_fnc_ETHICS_inspection. More about locations on: https://community.bistudio.com/wiki/Location
	// Returns _noMineZonesEthics: array

	params ["_minePos"];
	private ["_noMineZones"];

	// Initial values:
	_noMineZonesEthics = [];
	// If ethics rules off, just leave this function:
	if (!ETHICS_ethicsRules) exitWith { _noMineZonesEthics; /*Returning*/ };
	// Civilian zones:
	_noMineZonesEthics = [
		nearestLocation [_minePos, "NameVillage"],      // index 0
		nearestLocation [_minePos, "nameCity"],         // index 1
		nearestLocation [_minePos, "NameCityCapital"],  // index 2
		nearestLocation [_minePos, "NameLocal"]         // index 3
	];
	// Return:
	_noMineZonesEthics;
};


THY_fnc_ETHICS_inspection = {
	// This function ensures that each mine planted respects the previously configured doctrine and intensity rules, deleting the mines that doesn't follow the rules, nor logic or consistency.
	// Returns _wasMineDeleted: bool

	params ["_mine", "_minePos", "_noMineZonesTopography", "_noMineZonesEthics", "_isNaval"];
	private ["_wasMineDeleted"];
	// Initial values:
	_wasMineDeleted = false;
	// If landmine:
	if ( !_isNaval ) then {
		// Check if the landmine's position is below of water surface (waves and pond objects included):
		if ( ((getPosASLW _mine) select 2) < 0.2 ) then {  // 'select 2' = Z axis.
			deleteVehicle _mine;
			_wasMineDeleted = true;
			
		} else {
			// if Topography rules true, do it:
			if ( ETHICS_topographyRules ) then {
				if ( ((_minePos distance (_noMineZonesTopography select 0)) < 100) /*OR ((_minePos distance (_noMineZonesTopography select 1)) < 100)*/ OR ((_minePos distance (_noMineZonesTopography select 2)) < 100) ) then {
					// Delete the mine:
					deleteVehicle _mine;
					// And report it:
					_wasMineDeleted = true;
				};
			};
			// if Ethics rules true, do it:
			if ( ETHICS_ethicsRules ) then {
				if ( ((_minePos distance (_noMineZonesEthics select 0)) < 200) OR ((_minePos distance (_noMineZonesEthics select 1)) < 200) OR ((_minePos distance (_noMineZonesEthics select 2)) < 200) OR ((_minePos distance (_noMineZonesEthics select 3)) < 100) ) then {
					// Delete the mine:
					deleteVehicle _mine;
					// And report it:
					_wasMineDeleted = true;
				};
			};
		};
	// If naval mine:
	} else {
		// Check if the naval mine's position is a water surface:
		if ( !(surfaceIsWater _minePos) ) then {
			deleteVehicle _mine;
			_wasMineDeleted = true;
		};
	};
	// return:
	_wasMineDeleted;
};


THY_fnc_ETHICS_execution_service = {
	// This function is responsable to plant the each mine.
	// Returns _wasMineDeleted: bool.

	params ["_mfFaction", "_mineType", "_mfPos", "_mfRadius", ["_isNaval", false]];
	private ["_txtWarningHeader", "_mine", "_minePos", "_noMineZonesTopography", "_noMineZonesEthics", "_wasMineDeleted"];
	
	// CPU breath:
	sleep 0.05;  // CAUTION: without the breath, ETHICS might affect the server performance as hell.
	// Debug txts:
	//private _txtDebugHeader = "ETHICS DEBUG >";
	_txtWarningHeader = "ETHICS WARNING >";
	// Initial values:
	_noMineZonesTopography = [];
	_noMineZonesEthics = [];
	// Mine creation:
	_mine = createMine [_mineType, _mfPos, [], _mfRadius];  // https://community.bistudio.com/wiki/createMine
	// Preparing and checking the land planting:
	if ( !_isNaval ) then {
		// Mine position releated by terrain level:
		_minePos = getPosATL _mine;
		// Topography rules:
		_noMineZonesTopography = [_minePos] call THY_fnc_ETHICS_no_mine_topography;
		// Ethics rules:
		_noMineZonesEthics = [_minePos] call THY_fnc_ETHICS_no_mine_ethics;
	// Preparing the naval planting:
	} else {
		// Mine position releated by sea level:
		_minePos = getPosASL _mine;
	};
	// Mine inspection to check further rules:
	_wasMineDeleted = [_mine, _minePos, _noMineZonesTopography, _noMineZonesEthics, _isNaval] call THY_fnc_ETHICS_inspection;
	// If the mine is okay, do it:
	if ( !_wasMineDeleted ) then {
		// WIP / if dynamic simulation is ON in the mission, it will save performance:
		if ( ETHICS_dynamicSimulation ) then { 
			_mine enableDynamicSimulation true;  // https://community.bistudio.com/wiki/enableDynamicSimulation
			if ( isDedicated ) then {
				_mine enableSimulationGlobal true;  // https://community.bistudio.com/wiki/enableSimulationGlobal
			} else {
				_mine enableSimulation true;  // https://community.bistudio.com/wiki/enableSimulation
			};
		};
		// Case by case about the mine owners, do it:
		switch ( _mfFaction ) do {
			case "BLU": { blufor revealMine _mine };
			case "OPF": { opfor revealMine _mine };
			case "IND": { independent revealMine _mine };
			case "": {};
		};
		// When debug ON, always will reveal the mine position to mission editor:
		if ( ETHICS_debug ) then { (side player) revealMine _mine };
		// WIP:
		//if ( ETHICS_minesEditableByZeus ) then { {_x addCuratorEditableObjects [[_mine], true]} forEach allCurators };
	};
	// Return:
	_wasMineDeleted;
};


THY_fnc_ETHICS_mine_planter = {
	// This function organizes how each doctrine plants its mines.
	// Returns _mineAmountsByType: array [AP [planted, deleted], AM [planted, deleted]]

	params ["_mfNameStructure", "_landTypeAP", "_landTypeAM", "_navalTypeAM", "_mf", "_mfSize", "_limiterMineAmounts", "_mineAmountsByType"];
	private ["_mfDoctrine", "_mfFaction", "_mfPos", "_mfRadius", "_limiterAmountAP", "_limiterAmountAM", "_limiterMultiplier", "_allMinesPlantedAP", "_allMinesDeletedAP", "_allMinesPlantedAM", "_allMinesDeletedAM", "_minesPlantedAP", "_minesDeletedAP", "_minesPlantedAM", "_minesDeletedAM", "_wasMineDeleted"];

	// Debug txts:
	//private _txtDebugHeader = "ETHICS DEBUG >";
	//private _txtWarningHeader = "ETHICS WARNING >";
	// Config from Minefield Name Structure:
	_mfDoctrine = toUpper (_mfNameStructure select 1);
	_mfFaction = "";
	if ( (count _mfNameStructure) == 4 ) then { _mfFaction = toUpper (_mfNameStructure select 2) };
	// Minefield attributes: 
	_mfPos = markerPos _mf;            // [5800.70,3000.60,0]
	_mfRadius = _mfSize select 0;      // 40.1234
	// Limiters for this _mf, previously based on its size:
	_limiterAmountAP = _limiterMineAmounts select 0;
	_limiterAmountAM = _limiterMineAmounts select 1;
	_limiterMultiplier = 0.6;  // 60% is the minimal amount to be planted.
	_limiterMinesDeletedAP = _limiterAmountAP * _limiterMultiplier;
	_limiterMinesDeletedAM = _limiterAmountAM * _limiterMultiplier;
	// Mines' numbers of the sum of the other minefields priviously loaded by this function:
	_allMinesPlantedAP = (_mineAmountsByType select 0) select 0;
	_allMinesDeletedAP = (_mineAmountsByType select 0) select 1;
	_allMinesPlantedAM = (_mineAmountsByType select 1) select 0;
	_allMinesDeletedAM = (_mineAmountsByType select 1) select 1;
	// Mines' numbers only for this _mf:
	_minesPlantedAP = _limiterAmountAP;
	_minesDeletedAP = 0;
	_minesPlantedAM = _limiterAmountAM;
	_minesDeletedAM = 0;
	// Mine planter rules by doctrine:
	switch ( _mfDoctrine ) do {
		// LAND ANTI-PERSONNEL, planting all of them at once:
		case "AP": {
			// AP amount planting in a row:
			for "_i" from 1 to _limiterAmountAP do {
				// Execute the mine planting:
				_wasMineDeleted = [_mfFaction, _landTypeAP, _mfPos, _mfRadius] call THY_fnc_ETHICS_execution_service;
				// If something went wrong, deleted amount of mines:
				if ( _wasMineDeleted ) then { _minesDeletedAP = _minesDeletedAP + 1 };
			};
			// Debug Minefield feedbacks:
			[_mfDoctrine, _mf, _minesPlantedAP, _minesDeletedAP, _limiterMinesDeletedAP, ETHICS_debug] call THY_fnc_ETHICS_done_feedbacks;
			// Update with total numbers to return:
			_mineAmountsByType = [[(_allMinesPlantedAP + _minesPlantedAP), (_allMinesDeletedAP + _minesDeletedAP)], [_allMinesPlantedAM, _allMinesDeletedAM]];
		};
		// LAND ANTI-MAERIAL, planting all of them at once:
		case "AM": {
			// AM amount planting in a row:
			for "_i" from 1 to _limiterAmountAM do {
				// Execute the mine planting:
				_wasMineDeleted = [_mfFaction, _landTypeAM, _mfPos, _mfRadius] call THY_fnc_ETHICS_execution_service;
				// If something went wrong, deleted amount of mines:
				if ( _wasMineDeleted ) then { _minesDeletedAM = _minesDeletedAM + 1 };
			};
			// Debug Minefield feedbacks:
			[_mfDoctrine, _mf, _minesPlantedAM, _minesDeletedAM, _limiterMinesDeletedAM, ETHICS_debug] call THY_fnc_ETHICS_done_feedbacks;
			// Update with total numbers to return:
			_mineAmountsByType = [[_allMinesPlantedAP, _allMinesDeletedAP], [(_allMinesPlantedAM + _minesPlantedAM), (_allMinesDeletedAM + _minesDeletedAM)]]; 
		};
		// LAND HYBRID, planting all combined mines at once:
		case "HY": {
			// Reducing a each mine type for the combination amount doesn't except too much the limits:
			_limiterAmountAP = round (_limiterAmountAP / 1.3);  // Makes AP proporsion bigger than AM.
			_limiterAmountAM = round (_limiterAmountAM / 3);  // keep in mind it's heavy and expensive ammo for big targets.
			// Combined doctrines need recalculate the mine types' limeters:
			_limiterMinesDeletedAP = _limiterAmountAP * _limiterMultiplier;
			_limiterMinesDeletedAM = _limiterAmountAM * _limiterMultiplier;
			// Needed to include Hybrid solution correctly in final mines balance:
			_minesPlantedAP = _limiterAmountAP;
			_minesPlantedAM = _limiterAmountAM;
			// AP amount planting in a row:
			for "_i" from 1 to _limiterAmountAP do {
				// Execute the mine planting:
				_wasMineDeleted = [_mfFaction, _landTypeAP, _mfPos, _mfRadius] call THY_fnc_ETHICS_execution_service;
				// If something went wrong, deleted amount of mines:
				if ( _wasMineDeleted ) then { _minesDeletedAP = _minesDeletedAP + 1 };
			};
			// AM amount planting in a row:
			for "_i" from 1 to _limiterAmountAM do {
				// Execute the mine planting:
				_wasMineDeleted = [_mfFaction, _landTypeAM, _mfPos, _mfRadius] call THY_fnc_ETHICS_execution_service;
				// If something went wrong, deleted amount of mines:
				if ( _wasMineDeleted ) then { _minesDeletedAM = _minesDeletedAM + 1 };
			};
			// Debug Minefield feedbacks:
			[_mfDoctrine, _mf, _minesPlantedAP, _minesDeletedAP, _limiterMinesDeletedAP, ETHICS_debug, "Hybrid", "AP"] call THY_fnc_ETHICS_done_feedbacks;
			[_mfDoctrine, _mf, _minesPlantedAM, _minesDeletedAM, _limiterMinesDeletedAM, ETHICS_debug, "Hybrid", "AM"] call THY_fnc_ETHICS_done_feedbacks;
			// Update with total numbers to return:
			_mineAmountsByType = [[(_allMinesPlantedAP + _minesPlantedAP), (_allMinesDeletedAP + _minesDeletedAP)], [(_allMinesPlantedAM + _minesPlantedAM), (_allMinesDeletedAM + _minesDeletedAM)]];
		};
		// NAVAL ANTI-MAERIAL, planting all of them at once:
		case "NAM": {
			// AM amount planting in a row:
			for "_i" from 1 to _limiterAmountAM do {
				// Execute the mine planting:
				_wasMineDeleted = [_mfFaction, _navalTypeAM, _mfPos, _mfRadius, true] call THY_fnc_ETHICS_execution_service;
				// If something went wrong, deleted amount of mines:
				if ( _wasMineDeleted ) then { _minesDeletedAM = _minesDeletedAM + 1 };
			};
			// Debug Minefield feedbacks:
			[_mfDoctrine, _mf, _minesPlantedAM, _minesDeletedAM, _limiterMinesDeletedAM, ETHICS_debug] call THY_fnc_ETHICS_done_feedbacks;
			// Update with total numbers to return:
			_mineAmountsByType = [[_allMinesPlantedAP, _allMinesDeletedAP], [(_allMinesPlantedAM + _minesPlantedAM), (_allMinesDeletedAM + _minesDeletedAM)]]; 
		};
	};
	// Return:
	_mineAmountsByType;
};


THY_fnc_ETHICS_done_feedbacks = {
	// This function just gives some feedback about minefields numbers, sometimes for debugging purposes, sometimes for warning the mission editor. 
	// Returns nothing.

	params ["_mfDoctrine", "_mf", "_minesPlanted", "_minesDeleted", "_limiterMinesDeleted", "_debug", ["_combinedTitle", ""], ["_combinedTypes", ""]];
	private ["_txtDebugHeader", "_txtWarningHeader", "_txtWarning_2"];

	// Debug txts:
	_txtDebugHeader = "ETHICS DEBUG >";
	_txtWarningHeader = "ETHICS WARNING >";
	_txtWarning_2 = "Try to change the minefield position. Not recommended, you might also turn off the ETHICS and TOPOGRAPHY rules.";
	// If the doctrine is just one mine type, do it:
	if ( _combinedTitle == "" ) then {
		// Debug Minefield feedbacks > Everything looks fine:
		if ( _debug AND (_minesDeleted < _limiterMinesDeleted) ) then { 
			// If no mines deleted:
			if ( _minesDeleted == 0 ) then {
				systemChat format ["%1 Minefield '%2' > Got all %3 %4 mines planted successfully.", _txtDebugHeader, _mf, _minesPlanted, _mfDoctrine];
			// Otherwise, just a few mines deleted:
			} else {
				systemChat format ["%1 Minefield '%2' > From %3 %4 mines planted, %5 were deleted (balance: %6).", _txtDebugHeader, _mf, _minesPlanted, _mfDoctrine, _minesDeleted, (_minesPlanted - _minesDeleted)];
			};
		// Debug Minefield feedbacks > Probably some mission editor's action is required:
		} else {
			// Lot of mines were deleted:
			if ( _minesDeleted > _limiterMinesDeleted ) then {
				systemChat format ["%1 Minefield '%2' > Too much %3 mines deleted (%4 of %5) for simulation reasons or editor's choices. %6", _txtWarningHeader, _mf, _mfDoctrine, _minesDeleted, _minesPlanted, _txtWarning_2];
			};
		};
	// Otherwise, if the doctrine has mine types combined, do it:
	} else {
		// Debug Minefield feedbacks > Everything looks fine:
		if ( _debug AND (_minesDeleted < _limiterMinesDeleted) ) then { 
			// If no mines deleted:
			if ( _minesDeleted == 0 ) then {
				systemChat format ["%1 Minefield '%2' > %3 > Got all %4 %5 mines planted successfully.", _txtDebugHeader, _mf, _combinedTitle, _minesPlanted, _combinedTypes];
			// Otherwise, just a few mines deleted:
			} else {
				systemChat format ["%1 Minefield '%2' > %3 > %4 > From %5 mines planted, %6 were deleted (balance: %7).", _txtDebugHeader, _mf, _combinedTitle, _combinedTypes, _minesPlanted, _minesDeleted, (_minesPlanted - _minesDeleted)];
			};
		// Debug Minefield feedbacks > Probably some mission editor's action is required:
		} else {
			// Lot of mines were deleted:
			if ( _minesDeleted > _limiterMinesDeleted ) then {
				systemChat format ["%1 Minefield '%2' > %3 > Too much %4 mines deleted (%5 of %6) for simulation reasons or editor's choices. %7", _txtWarningHeader, _mf, _combinedTitle, _combinedTypes, _minesDeleted, _minesPlanted, _txtWarning_2];
			};
		};
	};
	// Returning:
	true;
};


THY_fnc_ETHICS_debug = {
	// This function shows a monitor with ETHICS script information. Only the hosted-server-player and dedicated-server-admin are able to see the feature.
	// Returns nothing.

	if ( !ETHICS_debug ) exitWith {};

	params ["_mfAmountFaction", "_mfAmountUnknown", "_balanceMinesAP", "_balanceMinesAM", "_balanceMinesTotal"];

	hintSilent format [
		"\n" +
		"--- ETHICS DEBUG MONITOR ---\n" + 
		"\n" +
		"Minefields on the map= %1\n" +
		"Minefields of factions= %2\n" +
		"Minefields of unknown= %3\n" +
		"Mines' intensity= %4\n" +
		"Initial ETHICS AP planted= %5\n" +
		"Initial ETHICS AM planted= %6\n" +
		"Initial No-ETHICS planted= %7\n" +
		"Current mines (ETHICS & others)= %8\n" +
		"\n",
		(_mfAmountFaction + _mfAmountUnknown),
		_mfAmountFaction,
		_mfAmountUnknown,
		ETHICS_minesIntensity,
		_balanceMinesAP,
		_balanceMinesAM,
		(abs ((count allMines) - _balanceMinesTotal)),
		(count allMines)
	];
	// Returning:
	true;
};
