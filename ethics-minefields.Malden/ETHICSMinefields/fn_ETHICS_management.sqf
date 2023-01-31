// ETHICS MINEFIELDS v1
// File: your_mission\ETHICSMinefields\fn_ETHICS_management.sqf
// by thy (@aldolammel)

// Runs only in server:
if (!isServer) exitWith {};


// PARAMETERS OF EDITOR'S OPTIONS:
ETHICS_debug = true;                  // true = shows crucial info only to hosted-server-player / false = turn it off. Detault: false
ETHICS_visibleOnMap = true;           // true = The faction minefield's area is visible on the map only by its faction player / false = invisible for everyone. Defalt: true
	ETHICS_styleColor = "ColorRed";   // color of minefields on map in-game. Default: "ColorRed"
	ETHICS_styleBrush = "FDiagonal";  // texture of minefields on map in-game. Default: "FDiagonal"
	ETHICS_styleAlpha = 1;            // 0.5 = Minefields barely invisible on the map / 1 = quite visible. Default: 1
ETHICS_minesIntensity = "MID";        // Proportional number of mines through the minefield areas. Options: EXTREME, HIGH, MID, LOW.
ETHICS_mineTypeAP = "APERSMine";      // Default: "APERSMine" / https://community.bistudio.com/wiki/Arma_3:_CfgVehicles_Other (use the classname column's names)
ETHICS_mineTypeAM = "ATMine";         // Default: "ATMine" / https://community.bistudio.com/wiki/Arma_3:_CfgVehicles_Other (use the classname column's names)
ETHICS_ethicsRules = true;            // true = script follows military conventions for choosing where to plant mines / false = mine has no ethics. Default: true
ETHICS_topographyRules = true;        // true = script follows topography for choosing better where to plant mines / false = mines every terrains. Default: true
ETHICS_dynamicSimulation = true;      // WIP
//ETHICS_minesEditableByZeus = true;    // WIP / true = ETHICS mines can be manipulated when Zeus is available / false = no editable. Detault: true


// ETHICS CORE / TRY TO CHANGE NOTHING BELOW!!! --------------------------------------------------------------------
[] spawn {

	private ["_txtWarningHeader", "_mineAmountsByType", "_mfAmountFaction", "_mfAmountUnknown", "_eachConfirmedList", "_mfSize", "_limiterMinefield", "_allMinesPlantedAP", "_allMinesDeletedAP", "_allMinesPlantedAM", "_allMinesDeletedAM", "_totalMinesDeleted", "_totalMinesPlanted", "_balanceMinesAP", "_balanceMinesAM", "_balanceMinesTotal"];
	
	// Debug txts:
	_txtWarningHeader = "ETHICS WARNING >";
	// Some important validations:
	if ( ETHICS_visibleOnMap AND (ETHICS_styleAlpha < 0.1) ) then { systemChat format ["%1 the mission has 'ETHICS_visibleOnMap' configured as TRUE, but the 'ETHICS_styleAlpha' was configured as invisible. Because of that, the script changed the 'ETHICS_styleAlpha' value to 1 (quite visible).", _txtWarningHeader]; ETHICS_styleAlpha = 1 };
	// Minefield name structure:
	ETHICS_prefix = "mf";  // CAUTION: NEVER include/isert the ETHICS_spacer character as part of the ETHICS_prefix too.
	ETHICS_spacer = "_";  // CAUTION: try do not change it!
	// Initial values:      AP      AM
	_mineAmountsByType = [[0, 0], [0, 0]];  // [planted, deleted]
	ETHICS_confirmedMfMarkers = [];
	_limiterMinefield = [];
	_mfAmountFaction = 0;
	_mfAmountUnknown = 0;
	// Search for all minefield markers set by mission editor on Eden:
	ETHICS_confirmedMfMarkers = [ETHICS_prefix, ETHICS_spacer] call THY_fnc_ETHICS_minefields_scanner;	
	

	// IT HAPPENS BEFORE THE BRIEFING SCREEN:
	// Converting specific area markers to minefields:
	{  // forEach ETHICS_confirmedMfMarkers (part 1/2):
		_eachConfirmedList = _x;
		{  // forEach _eachConfirmedList:
			// Minefield shape symmetry's consolidation:
			[_x] call THY_fnc_ETHICS_shape_symmetry;
		} forEach _eachConfirmedList;
	} forEach ETHICS_confirmedMfMarkers;

	// CAUTION: Never remove this sleep break!
	sleep 1;

	 // IT HAPPENS AFTER THE MISSON STARTS:
	// Planting mines through the available minefields:
	{  // forEach ETHICS_confirmedMfMarkers (part 2/2):
		_eachConfirmedList = _x;
		{  // forEach _eachConfirmedList:
			// Check minefields size after symmetry acted:
			_mfSize = markerSize _x;
			// Defining the mines' amount needed for each minefield's size:
			_limiterMinefield = [ETHICS_minesIntensity, _mfSize] call THY_fnc_ETHICS_mines_intensity;  // returns the mine amounts' limiters specific for minefield.			
			// Looking for factions tag on minefield names:
			_mfNameStructure = [_x, ETHICS_prefix, ETHICS_spacer] call THY_fnc_ETHICS_marker_name_splitter;
			// Mine planter (slow process)
			_mineAmountsByType = [_mfNameStructure, ETHICS_mineTypeAP, ETHICS_mineTypeAM, _x, _mfSize, _limiterMinefield, _mineAmountsByType] call THY_fnc_ETHICS_mine_planter;  // returns the mines' numbers updated.
		} forEach _eachConfirmedList;
	} forEach ETHICS_confirmedMfMarkers;

	
	// Debug purposes:
	if ( ETHICS_debug ) then { _mfAmountFaction = count (ETHICS_confirmedMfMarkers select 0); _mfAmountUnknown = count (ETHICS_confirmedMfMarkers select 1) };
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
	while { ETHICS_debug } do {
		// CPU breath:
		sleep 5;
		// Debug monitor:
		[_mfAmountFaction, _mfAmountUnknown, _balanceMinesAP, _balanceMinesAM, _balanceMinesTotal] call THY_fnc_ETHICS_debug;
	};  // while ends.
};  // spawn ends.
