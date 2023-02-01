// ETHICS MINEFIELDS v1.3
// File: your_mission\ETHICSMinefields\fn_ETH_management.sqf
// by thy (@aldolammel)

// Runs only in server:
if (!isServer) exitWith {};


// PARAMETERS OF EDITOR'S OPTIONS:
ETH_debug = true;                  // true = shows crucial info only to hosted-server-player / false = turn it off. Detault: false
ETH_visibleOnMap = true;           // true = The faction minefield's area is visible on the map only by its faction player / false = invisible for everyone. Defalt: true
ETH_styleColor = "ColorRed";   // color of minefields on map in-game. Default: "ColorRed"
	ETH_styleBrush = "FDiagonal";  // texture of minefields on map in-game. Default: "FDiagonal"
	ETH_styleAlpha = 1;            // 0.5 = Minefields barely invisible on the map / 1 = quite visible. Default: 1
ETH_minesIntensity = "MID";        // Proportional number of mines through the minefield areas. Options: EXTREME, HIGH, MID, LOW.
ETH_landMinesDoctrines = true;     // true = landmines will spawn if the minefield request them / false = turn it off. Default: true
	ETH_landmineClassAP = "APERSMine";  // Default: "APERSMine" / https://community.bistudio.com/wiki/Arma_3:_CfgVehicles_Other (use the classname column's names)
	ETH_landmineClassAM = "ATMine";     // Default: "ATMine" / https://community.bistudio.com/wiki/Arma_3:_CfgVehicles_Other (use the classname column's names)
		ETH_AMonlyOnRoads = true;        // true = AM landmines will be planted only on roads / false = turn it off. Default: false
ETH_navalMinesDoctrines = true;               // true = nauticalmines will spawn if the minefield request them / false = turn it off. Default: false
	ETH_navalmineTypeAM = "UnderwaterMineAB";  // Default: "UnderwaterMineAB"
ETH_ethicsRules = true;            // true = script follows military conventions for choosing where to plant mines / false = mine has no ethics. Default: true
ETH_topographyRules = true;        // true = script follows topography for choosing better where to plant mines / false = mines every terrains. Default: true
ETH_dynamicSimulation = true;      // WIP
//ETH_minesEditableByZeus = true;    // WIP / true = ETHICS mines can be manipulated when Zeus is available / false = no editable. Detault: true


// ETHICS CORE / TRY TO CHANGE NOTHING BELOW!!! --------------------------------------------------------------------
publicVariable "ETH_debug"; publicVariable "ETH_visibleOnMap"; publicVariable "ETH_styleColor"; publicVariable "ETH_styleBrush"; publicVariable "ETH_styleAlpha"; publicVariable "ETH_minesIntensity"; publicVariable "ETH_landMinesDoctrines"; publicVariable "ETH_landmineClassAP"; publicVariable "ETH_landmineClassAM"; publicVariable "ETH_AMonlyOnRoads"; publicVariable "ETH_navalMinesDoctrines"; publicVariable "ETH_navalmineTypeAM"; publicVariable "ETH_ethicsRules"; publicVariable "ETH_topographyRules"; publicVariable "ETH_dynamicSimulation"; publicVariable "ETH_minesEditableByZeus";

[] spawn {
	
	private ["_txtWarningHeader", "_txtWarning_3", "_mineAmountsByType", "_mfAmountFaction", "_mfAmountUnknown", "_eachConfirmedList", "_mfSize", "_limiterMinefield", "_allMinesPlantedAP", "_allMinesDeletedAP", "_allMinesPlantedAM", "_allMinesDeletedAM", "_totalMinesDeleted", "_totalMinesPlanted", "_balanceMinesAP", "_balanceMinesAM", "_balanceMinesTotal"];
	
	// Debug txts:
	_txtWarningHeader = "ETHICS WARNING >";
	_txtWarning_3 = "ammunition is empty at fn_ETH_management.sqf file. To fix the error, the script set automatically an ammunition to be used.";
	// Handling errors:
	if ( ETH_visibleOnMap AND (ETH_styleAlpha < 0.1) ) then { systemChat format ["%1 the mission has 'ETH_visibleOnMap' configured as TRUE, but the 'ETH_styleAlpha' was configured as invisible. Because of that, the script changed the 'ETH_styleAlpha' value to 1 (quite visible).", _txtWarningHeader]; ETH_styleAlpha = 1 };
	if ( ETH_landMinesDoctrines AND (ETH_landmineClassAP == "") ) then { ETH_landmineClassAP = "APERSMine"; systemChat format ["%1 The AP %2", _txtWarningHeader, _txtWarning_3]};
	if ( ETH_landMinesDoctrines AND (ETH_landmineClassAM == "") ) then { ETH_landmineClassAM = "ATMine"; systemChat format ["%1 The AM %2", _txtWarningHeader, _txtWarning_3]};
	if ( ETH_navalMinesDoctrines AND (ETH_navalmineTypeAM == "") ) then { ETH_navalmineTypeAM = "UnderwaterMineAB"; systemChat format ["%1 The NAM %2", _txtWarningHeader, _txtWarning_3]};
	if ( !ETH_landMinesDoctrines AND !ETH_navalMinesDoctrines ) then { 
		systemChat format ["%1 There's no any minefield's doctrine available at fn_ETH_management.sqf file. Turn Landmines or Navalmines 'TRUE' to use Ethics Minefields script.", _txtWarningHeader];
	// If the basic is fine, the script starts:
	} else {
		// Minefield name structure:
		ETH_prefix = "mf";  // CAUTION: NEVER include/isert the ETH_spacer character as part of the ETH_prefix too.
		ETH_spacer = "_";  // CAUTION: try do not change it!
		publicVariable "ETH_prefix";
		publicVariable "ETH_spacer";
		// Initial values:      AP      AM
		_mineAmountsByType = [[0, 0], [0, 0]];  // [planted, deleted]
		ETH_confirmedMfMarkers = [];
		_limiterMinefield = [];
		_mfAmountFaction = 0;
		_mfAmountUnknown = 0;
		// Search for all minefield markers set by mission editor on Eden:
		ETH_confirmedMfMarkers = [ETH_prefix, ETH_spacer] call THY_fnc_ETH_minefields_scanner;
		publicVariable "ETH_confirmedMfMarkers";  // after collecting the confirmed minefields, finally declaring the public variable.
		

		// IT HAPPENS BEFORE THE BRIEFING SCREEN:
		// Converting specific area markers to minefields:
		{  // forEach ETH_confirmedMfMarkers (part 1/2):
			_eachConfirmedList = _x;
			{  // forEach _eachConfirmedList:
				// Minefield shape symmetry's consolidation:
				[_x] call THY_fnc_ETH_shape_symmetry;
			} forEach _eachConfirmedList;
		} forEach ETH_confirmedMfMarkers;

		// CAUTION: Never remove this sleep break!
		sleep 1;

		// IT HAPPENS AFTER THE MISSON STARTS:
		// Planting mines through the available minefields:
		{  // forEach ETH_confirmedMfMarkers (part 2/2):
			_eachConfirmedList = _x;
			{  // forEach _eachConfirmedList:
				// Check minefields size after symmetry acted:
				_mfSize = markerSize _x;
				// Defining the mines' amount needed for each minefield's size:
				_limiterMinefield = [ETH_minesIntensity, _mfSize] call THY_fnc_ETH_mines_intensity;  // returns the mine amounts' limiters specific for minefield.			
				// Looking for factions tag on minefield names:
				_mfNameStructure = [_x, ETH_prefix, ETH_spacer] call THY_fnc_ETH_marker_name_splitter;
				// Mine planter (slow process)
				_mineAmountsByType = [_mfNameStructure, ETH_landmineClassAP, ETH_landmineClassAM, ETH_navalmineTypeAM, _x, _mfSize, _limiterMinefield, _mineAmountsByType] call THY_fnc_ETH_mine_planter;  // returns the mines' numbers updated.
			} forEach _eachConfirmedList;
		} forEach ETH_confirmedMfMarkers;

		
		// Debug purposes:
		if ( ETH_debug ) then { _mfAmountFaction = count (ETH_confirmedMfMarkers select 0); _mfAmountUnknown = count (ETH_confirmedMfMarkers select 1) };
		// Final balance:
		_allMinesPlantedAP = (_mineAmountsByType select 0) select 0;
		_allMinesDeletedAP = (_mineAmountsByType select 0) select 1;
		_allMinesPlantedAM = (_mineAmountsByType select 1) select 0;
		_allMinesDeletedAM = (_mineAmountsByType select 1) select 1;
		_totalMinesDeleted = _allMinesDeletedAP + _allMinesDeletedAM;
		_totalMinesPlanted = _allMinesPlantedAP + _allMinesPlantedAM;
		_balanceMinesAP = abs (_allMinesPlantedAP - _allMinesDeletedAP);
		_balanceMinesAM = abs (_allMinesPlantedAM - _allMinesDeletedAM);
		_balanceMinesTotal = abs (_totalMinesPlanted - _totalMinesDeleted);
		// Debug looping:
		while { ETH_debug } do {
			// CPU breath:
			sleep 5;
			// Debug monitor:
			[_mfAmountFaction, _mfAmountUnknown, _balanceMinesAP, _balanceMinesAM, _balanceMinesTotal] call THY_fnc_ETH_debug;
		};  // while ends.
	};
};  // spawn ends.
