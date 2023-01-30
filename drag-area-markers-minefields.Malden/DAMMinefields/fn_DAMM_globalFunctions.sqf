// DAMM: DRAG AREA MARKERS MINEFIELDS v1
// File: your_mission\DAMinefields\fn_DAMM_globalFunctions.sqf
// by thy (@aldolammel)


// DAMM CORE / TRY TO CHANGE NOTHING BELOW!!! --------------------------------------------------------------------


THY_fnc_DAMM_marker_name_splitter = {
	// This function splits the marker name to check if the name has the basic structure for further validations.
	// Returns array _mfNameStructure

	params ["_markerName", "_prefix", "_spacer"];
	private ["_txtWarningHeader", "_txtWarning_1", "_mfNameStructure", "_spacerAmount"];

	// Debug txts:
	//_txtDebugHeader = "DAMM DEBUG >";
	_txtWarningHeader = "DAMM WARNING >";
	_txtWarning_1 = format ["If the intension is make it as minefield, its sctructure name must be '%1%2doctrine%2faction%2anynumber' or '%1%2doctrine%2anynumber'.", _prefix, _spacer];
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


THY_fnc_DAMM_minefields_scanner = {
	// This function search and append in a list all area-markers confirmed as a real minefield. The searching take place once right at the mission begins.
	// Returns array _confirmedMfMarkers: [[minefield markers of factions], [minefield markers of unknown owner]]

	params ["_prefix", "_spacer"];
	private ["_realPrefix", "_acceptableShapes", "_txtDebugHeader", "_txtWarningHeader", "_txtWarning_1", "_confirmedMfMarkers", "_confirmedMfUnknownMarkers", "_confirmedMfFactionMarkers", "_possibleMinefieldMarkers", "_mfNameStructure", "_itShouldBeNum"];

	_realPrefix = _prefix + _spacer;
	_acceptableShapes = ["RECTANGLE", "ELLIPSE"];
	// Debug txts:
	_txtDebugHeader = "DAMM DEBUG >";
	_txtWarningHeader = "DAMM WARNING >";
	_txtWarning_1 = format ["If the intension is make it as minefield, its sctructure name must be '%1%2TagDoctrine%2TagFaction%2anynumber' or '%1%2TagDoctrine%2anynumber'.", _prefix, _spacer];
	// Initial values:
	_confirmedMfMarkers = [];
	_confirmedMfUnknownMarkers = [];
	_confirmedMfFactionMarkers = [];
	// Step 1/2 > Creating a list with only area markers with right prefix:
	if ( !DAMM_debug ) then {
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
		_mfNameStructure = [_x, _prefix, _spacer] call THY_fnc_DAMM_marker_name_splitter;
		// Case by case, check the valid marker name's amounts of strings:
		switch ( count _mfNameStructure ) do {
			// Case example: mf_ap_1
			case 3: {
				// picking up the third/last string and convert it to integer:
				_itShouldBeNum = parseNumber (_mfNameStructure select 2);  // result will be a number extracted from string OR ZERO if inside the string has no numbers.
				// if numeric, add the marker to a unknown faction marker's list:
				if ( _itShouldBeNum != 0 ) then { _confirmedMfUnknownMarkers append [_x] } else { systemChat format ["%1 '%2' is not a valid name. %3", _txtWarningHeader, _x, _txtWarning_1] };
			};
			// Case example: mf_ap_ind_2
			case 4: {
				// picking up the 4th/last string and convert it to integer:
				_itShouldBeNum = parseNumber (_mfNameStructure select 3);  // result will be a number extracted from string OR ZERO if inside the string has no numbers.
				// if numeric, add the marker to a faction marker's list:
				if ( _itShouldBeNum != 0 ) then { _confirmedMfFactionMarkers append [_x] } else { systemChat format ["%1 '%2' is not a valid name. %3", _txtWarningHeader, _x, _txtWarning_1] };
			};
		};
		
	} forEach _possibleMinefieldMarkers;
	// Updating the general list to return:
	_confirmedMfMarkers = [_confirmedMfFactionMarkers, _confirmedMfUnknownMarkers];
	// Debug messages:
	if ( DAMM_debug ) then {
		if ( (count _confirmedMfFactionMarkers) > 0 ) then { systemChat format ["%1 Faction minefield(s) ready to got mines: %2", _txtDebugHeader, _confirmedMfFactionMarkers] };
		if ( (count _confirmedMfUnknownMarkers) > 0 ) then { systemChat format ["%1 Unknown minefield(s) ready to got mines: %2", _txtDebugHeader, _confirmedMfUnknownMarkers] };
	};
	// Returning:
	_confirmedMfMarkers;
};


THY_fnc_DAMM_style = {
	// This function set the minefield stylish on mission map.
	// Returns Nothing.

	params ["_debug",  "_minefield", "_prefix", "_spacer", "_isVisible", "_color", "_brush"];
	private ["_colorToOthers", "_mfFaction", "_mfNameStructure"];

	// Declaration:
	_colorToOthers = "ColorUNKNOWN";
	// Initial values:
	_mfFaction = "";
	// Debug mode ON:
	if ( _debug ) then {
		// check if the marker name has more than one _spacer character in its string composition:
		_mfNameStructure = [_minefield, _prefix, _spacer] call THY_fnc_DAMM_marker_name_splitter;
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
	_minefield setMarkerColorLocal _color;  // https://community.bistudio.com/wiki/Arma_3:_CfgMarkerColors
	_minefield setMarkerBrushLocal _brush;  // https://community.bistudio.com/wiki/setMarkerBrush
	// Return:
	true;
};


THY_fnc_DAMM_markers_visibility = {
	// This function controls locally if the specific player might see their minefields' faction on the map.
	// Returns nothing.

	params ["_minefieldsGroups", "_prefix", "_spacer", "_isVisible", "_color", "_brush", "_alpha"];
	private ["_minefields", "_mfFaction", "_mfNameStructure"];

	{  // forEach _minefieldsGroups:
		_minefields = _x;
		{  // forEach _minefields:
			// Initial values:
			_mfFaction = "";
			// Looking for factions tag on minefield names:
			_mfNameStructure = [_x, _prefix, _spacer] call THY_fnc_DAMM_marker_name_splitter;
			// At first, hide all minefields for this player:
			_x setMarkerAlphaLocal 0;
			// Minefield stylish:
			[DAMM_debug, _x, _prefix, _spacer, _isVisible, _color, _brush] call THY_fnc_DAMM_style;
			// if the marker's name has the faction session in its name, do it:
			if ( (count _mfNameStructure) == 4 ) then { _mfFaction = toUpper (_mfNameStructure select 2) };
			// if minefield marker owner matchs with the player faction, show locally the marker on the map:
			if ( DAMM_debug OR (_isVisible AND (_mfFaction == "BLU") AND ((side player) == blufor)) ) then { _x setMarkerAlphaLocal _alpha };
			if ( DAMM_debug OR (_isVisible AND (_mfFaction == "OPF") AND ((side player) == opfor)) ) then { _x setMarkerAlphaLocal _alpha };
			if ( DAMM_debug OR (_isVisible AND (_mfFaction == "IND") AND ((side player) == independent)) ) then { _x setMarkerAlphaLocal _alpha };
		} forEach _minefields;
	} forEach _minefieldsGroups;
	// Returns:
	true;
};


THY_fnc_DAMM_shape_symmetry = {
	// This function checks the area shape symmetry of the minefield built by the Mission Editor through Eden. It's important to make the work of THY_fnc_DAMM_mine_planter easier.
	// Returns array _mfSize: [x,y].

	params ["_minefield"];
	private ["_txtWarningHeader", "_radiusMin", "_radiusMax", "_mfWidth", "_mfHeight", "_mfSize"];

	// Debug txts:
	_txtWarningHeader = "DAMM WARNING >";
	// Limiters:
	_radiusMin = 25;
	_radiusMax = 2500;
	// Minefield dimensions:
	_mfWidth = markerSize _minefield select 0;
	_mfHeight = markerSize _minefield select 1;
	// If the minefield marker shape is not symmetric, do it:
	if ( _mfWidth != _mfHeight ) then {
		// Make the minefield symmetric:
		_minefield setMarkerSize [_mfWidth, _mfWidth];
		// Alert the mission editor:
		systemChat format ["%1 Minefield '%2' > it was resized to has its shape symmetric (mandatory).", _txtWarningHeader, _minefield];
	};
	// If the minefield's radius is smaller than the minimal OR bigger than the maximum, do it:
	if ( (_mfWidth < _radiusMin) OR (_mfWidth > _radiusMax) ) then {
		// If smaller, do it:
		if (_mfWidth < _radiusMin) then { 
			// set the radius the minal value:
			_minefield setMarkerSize [_radiusMin, _radiusMin];
			// Alarm message:
			systemChat format ["%1 Minefield '%2' > the script needed to increase the minefield size to the minimum radius.", _txtWarningHeader, _minefield];
		// Otherwise, if equal or bigger:
		} else {
			// the maximum value:
			_minefield setMarkerSize [_radiusMax, _radiusMax];
			// Alarm message:
			systemChat format ["%1 Minefield '%2' > the script needed to decrease the minefield size to the maximum radius.", _txtWarningHeader, _minefield];
		};
	};
	// Update the current minefield size:
	_mfSize = markerSize _minefield;
	// Return:
	_mfSize;
};


THY_fnc_DAMM_mines_intensity = {
	// This function controls the number of mines specific for each minefield, based on its area size and general intensity level chosen, setting different amount limits to be planted through each minefield.
	// Returns array _limiterMineAmounts: [AP amount limiter, AM amount limiter]

	params ["_intensity", "_mfSize"];
	private ["_txtWarningHeader", "_mfRadius", "_mfArea", "_limiterMines", "_limiterMineAmounts"];

	// Debug txts:
	//_txtDebugHeader = "DAMM DEBUG >";
	_txtWarningHeader = "DAMM WARNING >";
	// Handling errors:
	if ( !(_intensity in ["EXTREME", "HIGH", "MID", "LOW"]) ) then {
		_intensity = "MID";
		systemChat format ["%1 fn_DAMM_management.sqf > check the INTENSITY configuration. There's no any '%2' option. To avoid this error, the intensity was changed to '%3'.", _txtWarningHeader, DAMM_minesIntensity, _intensity];
	};
	// Basic area calcs:
	_mfRadius = _mfSize select 0;  // 40.1234
	_mfArea = pi * (_mfRadius ^ 2);  // 5600.30
	// Case by case, do it:
	switch ( _intensity ) do {
		case "EXTREME": {
			_limiterMines = round ((sqrt _mfArea) * 2);
			_limiterMineAmounts = [_limiterMines, _limiterMines];
		};
		case "HIGH": {
			_limiterMines = round (sqrt _mfArea);
			_limiterMineAmounts = [_limiterMines, _limiterMines];
		};
		case "MID": {
			_limiterMines = round ((sqrt _mfArea) / 2);
			_limiterMineAmounts = [_limiterMines, _limiterMines];
		};
		case "LOW": {
			_limiterMines = round ((sqrt _mfArea) / 6);
			_limiterMineAmounts = [_limiterMines, _limiterMines];
		};
	};
	// return:
	_limiterMineAmounts;
};


/*
THY_fnc_DAMM_mine_in_water = {
	// WIP
	// Returns _isFloatMine

	params ["_mine"];
	private ["_floatVal", "_isFloatMine"];

	_floatVal = _mine getVariable ['TAG_canFloat', -1];

	if ( _floatVal isEqualTo -1 ) then 
	{
		_floatVal = getNumber (configFile >> 'CfgVehicles' >> (typeOf _mine) >> 'canFloat');
		_mine setVariable ['TAG_canFloat',_floatVal];
	};

	_isFloatMine = _floatVal > 0;
	
	_isFloatMine  // returning.
};
*/


THY_fnc_DAMM_no_mine_topography = {
	// xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
	// Returns array _noMineZonesTopography.

	params ["_minePos"];
	private ["_noMineZones"];

	_noMineZonesTopography = [];

	if (!DAMM_topographyRules) exitWith { _noMineZonesTopography; /*Returning*/ };

	// Zones:
	_noMineZonesTopography = [
		nearestLocation [_minePos, "RockArea"],    // index 0
		nearestLocation [_minePos, "Hill"],        // index 1
		nearestLocation [_minePos, "Mount"]        // index 2
	];
	// Return:
	_noMineZonesTopography
};


THY_fnc_DAMM_no_mine_ethics = {
	// This function defines all locations where a mine SHOULD avoid to be planted by the function THY_fnc_DAMM_inspection. More about locations on: https://community.bistudio.com/wiki/Location
	// Returns array _noMineZonesEthics.

	params ["_minePos"];
	private ["_noMineZones"];

	_noMineZonesEthics = [];

	if (!DAMM_ethicsRules) exitWith { _noMineZonesEthics; /*Returning*/ };

	// Zones:
	_noMineZonesEthics = [
		nearestLocation [_minePos, "NameVillage"],      // index 0
		nearestLocation [_minePos, "nameCity"],         // index 1
		nearestLocation [_minePos, "NameCityCapital"],  // index 2
		nearestLocation [_minePos, "NameLocal"]         // index 3
	];
	// Return:
	_noMineZonesEthics;
};


THY_fnc_DAMM_inspection = {
	// This function ensures that each mine planted respects the previously configured doctrine and intensity rules, deleting the mines that doesn't follow the rules, either by logic or inconsistency.
	// Returns bool _wasMineDeleted.

	params ["_mine", "_minePos", "_noMineZonesTopography", "_noMineZonesEthics"];
	private ["_wasMineDeleted"];
	// Initial values:
	_wasMineDeleted = false;
	// Check if the mine's position is below of water surface (waves and pond objects included):
	if ( ((getPosASLW _mine) select 2) < 0.2 ) then // 'select 2' = Z axis.
	{
		deleteVehicle _mine;
		_wasMineDeleted = true;
		
	} else {
		// if Topography rules true, do it:
		if ( DAMM_topographyRules ) then {
			if ( ((_minePos distance (_noMineZonesTopography select 0)) < 100) /*OR ((_minePos distance (_noMineZonesTopography select 1)) < 100)*/ OR ((_minePos distance (_noMineZonesTopography select 2)) < 100) ) then {
				// Delete the mine:
				deleteVehicle _mine;
				// And report it:
				_wasMineDeleted = true;
			};
		};
		// if Ethics rules true, do it:
		if ( DAMM_ethicsRules ) then {
			if ( ((_minePos distance (_noMineZonesEthics select 0)) < 200) OR ((_minePos distance (_noMineZonesEthics select 1)) < 200) OR ((_minePos distance (_noMineZonesEthics select 2)) < 200) OR ((_minePos distance (_noMineZonesEthics select 3)) < 100) ) then {
				// Delete the mine:
				deleteVehicle _mine;
				// And report it:
				_wasMineDeleted = true;
			};
		};
	};
	// return:
	_wasMineDeleted;
};


THY_fnc_DAMM_execution_service = {
	// This function is responsable to plant the each mine.
	// Returns bool _wasMineDeleted.

	params ["_minefield", "_faction", "_mineType", "_mfPos", "_mfRadius"];
	private ["_txtWarningHeader", "_mine", "_minePos", "_noMineZonesTopography", "_noMineZonesEthics", "_wasMineDeleted"];

	// Debug txts:
	//private _txtDebugHeader = "DAMM DEBUG >";
	_txtWarningHeader = "DAMM WARNING >";
	// Handling errors:
	if ( !(_faction in ["BLU", "OPF", "IND", ""]) ) then {
		systemChat format ["%1 Minefield '%2' > The faction tag looks wrong. There's no any '%3' option. For this minefield owner, it was changed to unknown.", _txtWarningHeader, _minefield, _faction];
		_faction = "";
	};
	// CPU breath:
	sleep 0.05;  // CAUTION: without the breath, DAMM might affect the server performance as hell.
	// Mine creation:
	_mine = createMine [_mineType, _mfPos, [], _mfRadius];  // https://community.bistudio.com/wiki/createMine
	_minePos = getPos _mine;
	// Topography rules:
	_noMineZonesTopography = [_minePos] call THY_fnc_DAMM_no_mine_topography;
	// Ethics rules:
	_noMineZonesEthics = [_minePos] call THY_fnc_DAMM_no_mine_ethics;
	// Mine inspection to check further rules:
	_wasMineDeleted = [_mine, _minePos, _noMineZonesTopography, _noMineZonesEthics] call THY_fnc_DAMM_inspection;
	// If the mine is okay, do it:
	if ( !_wasMineDeleted ) then {
		// if dynamic simulation is ON in the mission, it will save performance:
		if ( DAMM_dynamicSimulation ) then { 
			_mine enableDynamicSimulation true;  // https://community.bistudio.com/wiki/enableDynamicSimulation
			if ( isDedicated ) then {
				_mine enableSimulationGlobal true;  // https://community.bistudio.com/wiki/enableSimulationGlobal
			} else {
				_mine enableSimulation true;  // https://community.bistudio.com/wiki/enableSimulation
			};
		};
		// Case by case about the mine owners, do it:
		switch ( _faction ) do {
			case "BLU": { blufor revealMine _mine };
			case "OPF": { opfor revealMine _mine };
			case "IND": { independent revealMine _mine };
			case "": {};
		};
		// When debug ON, always will reveal the mine position to mission editor:
		if ( DAMM_debug ) then { (side player) revealMine _mine };
		// WIP:
		//if ( DAMM_minesEditableByZeus ) then { {_x addCuratorEditableObjects [[_mine], true]} forEach allCurators };
	};
	// Return:
	_wasMineDeleted;
};


THY_fnc_DAMM_mine_planter = {
	// This function organizes how each doctrine plants its mines.
	// Returns array _mineAmountsByType: [AP [planted, deleted], AM [planted, deleted]]

	params ["_mfNameStructure", "_typeAP", "_typeAM", "_minefield", "_mfSize", "_limiterMineAmounts", "_mineAmountsByType"];
	private ["_txtWarningHeader", "_doctrine", "_faction", "_mfPos", "_mfRadius", "_limiterAmountAP", "_limiterAmountAM", "_limiterMultiplier", "_allMinesPlantedAP", "_allMinesDeletedAP", "_allMinesPlantedAM", "_allMinesDeletedAM", "_minesPlantedAP", "_minesDeletedAP", "_minesPlantedAM", "_minesDeletedAM", "_wasMineDeleted", "_limiterMinesDeleted"];

	// Debug txts:
	//private _txtDebugHeader = "DAMM DEBUG >";
	_txtWarningHeader = "DAMM WARNING >";
	// Config from Minefield Name Structure:
	_doctrine = toUpper (_mfNameStructure select 1);
	_faction = "";
	if ( (count _mfNameStructure) == 4 ) then { _faction = toUpper (_mfNameStructure select 2) };
	// Handling errors:
	if ( !(_doctrine in ["AP", "AM", "HY"]) ) then {
		systemChat format ["%1 Minefield '%2' > Its name looks wrong. There's no any '%3' doctrine. To avoid this error, for this specific minefield it was changed to AP.", _txtWarningHeader, _minefield, _doctrine];
		_doctrine = "AP";
	};
	// Minefield attributes: 
	_mfPos = markerPos _minefield;            // [5800.70,3000.60,0]
	_mfRadius = _mfSize select 0;      // 40.1234
	// Limiters for this _minefield, previously based on its size:
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
	// Mines' numbers only for this _minefield:
	_minesPlantedAP = _limiterAmountAP;
	_minesDeletedAP = 0;
	_minesPlantedAM = _limiterAmountAM;
	_minesDeletedAM = 0;
	// Mine planter rules by doctrine:
	switch ( _doctrine ) do {
		// ANTI-PERSONNEL, planting all of them at once:
		case "AP": {
			// AP amount planting in a row:
			for "_i" from 1 to _limiterAmountAP do {
				// Execute the mine planting:
				_wasMineDeleted = [_minefield, _faction, _typeAP, _mfPos, _mfRadius] call THY_fnc_DAMM_execution_service;
				// If something went wrong, deleted amount of mines:
				if ( _wasMineDeleted ) then { _minesDeletedAP = _minesDeletedAP + 1 };
			};
			// Debug Minefield feedbacks:
			[_doctrine, _minefield, _minesPlantedAP, _minesDeletedAP, _limiterMinesDeletedAP, DAMM_debug] call THY_fnc_DAMM_done_feedbacks;
			// Update with total numbers to return:
			_mineAmountsByType = [[(_allMinesPlantedAP + _minesPlantedAP), (_allMinesDeletedAP + _minesDeletedAP)], [_allMinesPlantedAM, _allMinesDeletedAM]];
		};
		// ANTI-MAERIAL, planting all of them at once:
		case "AM": {
			// AM amount planting in a row:
			for "_i" from 1 to _limiterAmountAM do {
				// Execute the mine planting:
				_wasMineDeleted = [_minefield, _faction, _typeAM, _mfPos, _mfRadius] call THY_fnc_DAMM_execution_service;
				// If something went wrong, deleted amount of mines:
				if ( _wasMineDeleted ) then { _minesDeletedAM = _minesDeletedAM + 1 };
			};
			// Debug Minefield feedbacks:
			[_doctrine, _minefield, _minesPlantedAM, _minesDeletedAM, _limiterMinesDeletedAM, DAMM_debug] call THY_fnc_DAMM_done_feedbacks;
			// Update with total numbers to return:
			_mineAmountsByType = [[_allMinesPlantedAP, _allMinesDeletedAP], [(_allMinesPlantedAM + _minesPlantedAM), (_allMinesDeletedAM + _minesDeletedAM)]]; 
		};
		// HYBRID, planting all combined mines at once:
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
				_wasMineDeleted = [_minefield, _faction, _typeAP, _mfPos, _mfRadius] call THY_fnc_DAMM_execution_service;
				// If something went wrong, deleted amount of mines:
				if ( _wasMineDeleted ) then { _minesDeletedAP = _minesDeletedAP + 1 };
			};
			// AM amount planting in a row:
			for "_i" from 1 to _limiterAmountAM do {
				// Execute the mine planting:
				_wasMineDeleted = [_minefield, _faction, _typeAM, _mfPos, _mfRadius] call THY_fnc_DAMM_execution_service;
				// If something went wrong, deleted amount of mines:
				if ( _wasMineDeleted ) then { _minesDeletedAM = _minesDeletedAM + 1 };
			};
			// Debug Minefield feedbacks:
			[_doctrine, _minefield, _minesPlantedAP, _minesDeletedAP, _limiterMinesDeletedAP, DAMM_debug, "Hybrid", "AP"] call THY_fnc_DAMM_done_feedbacks;
			[_doctrine, _minefield, _minesPlantedAM, _minesDeletedAM, _limiterMinesDeletedAM, DAMM_debug, "Hybrid", "AM"] call THY_fnc_DAMM_done_feedbacks;
			// Update with total numbers to return:
			_mineAmountsByType = [[(_allMinesPlantedAP + _minesPlantedAP), (_allMinesDeletedAP + _minesDeletedAP)], [(_allMinesPlantedAM + _minesPlantedAM), (_allMinesDeletedAM + _minesDeletedAM)]];
		};
	};
	// Return:
	_mineAmountsByType;
};


THY_fnc_DAMM_done_feedbacks = {
	// This function just gives some feedback about minefields numbers, sometimes for debugging purposes, sometimes for warning the mission editor. 
	// Returns nothing.

	params ["_doctrine", "_minefield", "_minesPlanted", "_minesDeleted", "_limiterMinesDeleted", "_debug", ["_combinedTitle", ""], ["_combinedTypes", ""]];

	// Debug txts:
	_txtDebugHeader = "DAMM DEBUG >";
	_txtWarningHeader = "DAMM WARNING >";
	// If the doctrine is just one mine type, do it:
	if ( _combinedTitle == "" ) then {
		// Debug Minefield feedbacks > Everything looks fine:
		if ( _debug AND (_minesDeleted < _limiterMinesDeleted) ) then { 
			// If no mines deleted:
			if ( _minesDeleted == 0 ) then {
				systemChat format ["%1 Minefield '%2' > Got all %3 %4 mines planted successfully.", _txtDebugHeader, _minefield, _minesPlanted, _doctrine];
			// Otherwise, just a few mines deleted:
			} else {
				systemChat format ["%1 Minefield '%2' > From %3 %4 mines planted, %5 were deleted (balance: %6).", _txtDebugHeader, _minefield, _minesPlanted, _doctrine, _minesDeleted, (_minesPlanted - _minesDeleted)];
			};
		// Debug Minefield feedbacks > Probably some mission editor's action is required:
		} else {
			// Lot of mines were deleted:
			if ( _minesDeleted > _limiterMinesDeleted ) then {
				systemChat format ["%1 Minefield '%2' > Too much %3 mines deleted (%4 of %5) for simulation reasons or editor's choices. Try to change the minefield position or turn to 'false' the DAMM ETHICS config (current is '%6').", _txtWarningHeader, _minefield, _doctrine, _minesDeleted, _minesPlanted, DAMM_ethicsRules];
			};
		};
	// Otherwise, if the doctrine has mine types combined, do it:
	} else {
		// Debug Minefield feedbacks > Everything looks fine:
		if ( _debug AND (_minesDeleted < _limiterMinesDeleted) ) then { 
			// If no mines deleted:
			if ( _minesDeleted == 0 ) then {
				systemChat format ["%1 Minefield '%2' > %3 > Got all %4 %5 mines planted successfully.", _txtDebugHeader, _minefield, _combinedTitle, _minesPlanted, _combinedTypes];
			// Otherwise, just a few mines deleted:
			} else {
				systemChat format ["%1 Minefield '%2' > %3 > From %4 %5 mines planted, %6 were deleted (balance: %7).", _txtDebugHeader, _minefield, _combinedTitle, _minesPlanted, _combinedTypes, _minesDeleted, (_minesPlanted - _minesDeleted)];
			};
		// Debug Minefield feedbacks > Probably some mission editor's action is required:
		} else {
			// Lot of mines were deleted:
			if ( _minesDeleted > _limiterMinesDeleted ) then {
				systemChat format ["%1 Minefield '%2' > %3 > Too much %4 mines deleted (%5 of %6) for simulation reasons or editor's choices. Try to change the minefield position. Not recommended, you might also turn off the ETHICS and TOPOGRAPHY rules.", _txtWarningHeader, _minefield, _combinedTitle, _combinedTypes, _minesDeleted, _minesPlanted];
			};
		};
	};
	// Returning:
	true;
};


THY_fnc_DAMM_debug = {
	// This function shows a monitor with DAMM script information. Only the hosted-server-player and dedicated-server-admin are able to see the feature.
	// Returns nothing.

	if ( !DAMM_debug ) exitWith {};

	params ["_mfAmountFaction", "_mfAmountUnknown", "_balanceMinesAP", "_balanceMinesAM", "_balanceMinesTotal"];

	hint format [
		"\n" +
		"--- DAMM DEBUG MONITOR ---\n" + 
		"\n" +
		"Minefields on the map= %1\n" +
		"Minefields of factions= %2\n" +
		"Minefields of unknown= %3\n" +
		"Mines' intensity= %4\n" +
		"WIP = %5\n" +
		"Initial DAMM AP planted= %6\n" +
		"Initial DAMM AM planted= %7\n" +
		"Initial No-DAMM planted= %8\n" +
		"Current mines (DAMM & others)= %9\n" +
		"\n",
		(_mfAmountFaction + _mfAmountUnknown),
		_mfAmountFaction,
		_mfAmountUnknown,
		DAMM_minesIntensity,
		str("Soon..."),
		_balanceMinesAP,
		_balanceMinesAM,
		(abs ((count allMines) - _balanceMinesTotal)),
		(count allMines)
	];
	// Returning:
	true;
};
