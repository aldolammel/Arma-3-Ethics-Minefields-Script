// DAMM: DRAG AREA MARKERS MINEFIELDS v1
// File: your_mission\DAMinefields\fn_DAMM_management.sqf
// by thy (@aldolammel)

// Runs only in server:
if (!isServer) exitWith {};


// PARAMETERS OF EDITOR'S OPTIONS:
DAMM_debug = true;                  // true = shows crucial info only to hosted-server-player / false = turn it off. Detault: false
DAMM_visibleOnMap = true;           // true = The faction minefield's area is visible on the map only by its faction player / false = invisible for everyone. Defalt: true
	DAMM_styleColor = "ColorRed";   // color of minefields on map in-game. Default: "ColorRed"
	DAMM_styleBrush = "FDiagonal";  // texture of minefields on map in-game. Default: "FDiagonal"
	DAMM_styleAlpha = 1;            // 0.5 = Minefields barely invisible on the map / 1 = quite visible. Default: 1
DAMM_minesIntensity = "LOW";        // Proportional number of mines through the minefield areas. Options: EXTREME, HIGH, MID, LOW.
DAMM_mineTypeAP = "APERSMine";      // Default: "APERSMine" / https://community.bistudio.com/wiki/Arma_3:_CfgVehicles_Other (use the classname column's names)
DAMM_mineTypeAM = "ATMine";         // Default: "ATMine" / https://community.bistudio.com/wiki/Arma_3:_CfgVehicles_Other (use the classname column's names)
DAMM_ethicsRules = true;            // true = script follows military conventions for choosing where to plant mines / false = mine has no ethics. Default: true
DAMM_topographyRules = true;        // true = script follows topography for choosing better where to plant mines / false = mines every terrains. Default: true
DAMM_dynamicSimulation = true;      // WIP
//DAMM_minesEditableByZeus = true;    // WIP / true = DAMM mines can be manipulated when Zeus is available / false = no editable. Detault: true


// DAMM CORE / TRY TO CHANGE NOTHING BELOW!!! --------------------------------------------------------------------
[] spawn {

	private ["_txtWarningHeader", "_mineAmountsByType", "_mfAmountFaction", "_mfAmountUnknown", "_confirmedMfMarkersLists", "_mfSize", "_limiterMineAmounts", "_allMinesPlantedAP", "_allMinesDeletedAP", "_allMinesPlantedAM", "_allMinesDeletedAM", "_totalMinesDeleted", "_totalMinesPlanted", "_balanceMinesAP", "_balanceMinesAM", "_balanceMinesTotal"];
	
	// Debug txts:
	_txtWarningHeader = "DAMM WARNING >";
	// Some important validations:
	if ( DAMM_visibleOnMap AND (DAMM_styleAlpha < 0.1) ) then { systemChat format ["%1 the mission has 'DAMM_visibleOnMap' configured as TRUE, but the 'DAMM_styleAlpha' was configured as invisible. Because of that, the script changed the 'DAMM_styleAlpha' value to 1 (quite visible).", _txtWarningHeader]; DAMM_styleAlpha = 1 };
	// Minefield name structure:
	DAMM_prefix = "mf";  // CAUTION: NEVER include/isert the DAMM_spacer character as part of the DAMM_prefix too.
	DAMM_spacer = "_";  // CAUTION: try do not change it!
	// Initial values:      AP      AM
	_mineAmountsByType = [[0, 0], [0, 0]];  // [planted, deleted]
	_limiterByMinefield = [];
	// Search for all minefield markers set by mission editor on Eden:
	DAMM_confirmedMfMarkers = [DAMM_prefix, DAMM_spacer] call THY_fnc_DAMM_minefields_scanner;
	// Debug purposes:
	if ( DAMM_debug ) then { _mfAmountFaction = count (DAMM_confirmedMfMarkers select 0); _mfAmountUnknown = count (DAMM_confirmedMfMarkers select 1) };
	
	
	// IT HAPPENS BEFORE THE BRIEFING SCREEN:
	// Converting specific area markers to minefields:
	{  // forEach DAMM_confirmedMfMarkers (part 1/2):
		_confirmedMfMarkersLists = _x;
		{  // forEach _confirmedMfMarkersLists:
			// Minefield shape symmetry's validation:
			_mfSize = [_x] call THY_fnc_DAMM_shape_symmetry;
			// Defining the mines' amount needed for each minefield's size:
			_limiterMineAmounts = [DAMM_minesIntensity, _mfSize] call THY_fnc_DAMM_mines_intensity;  // returns the mine amounts' limiters specific for minefield.
			// Saving the limiter's data by minefield:
			_limiterByMinefield append [_limiterMineAmounts];
		} forEach _confirmedMfMarkersLists;
	} forEach DAMM_confirmedMfMarkers;

	// CAUTION: Never remove this sleep break!
	sleep 1;

	 // IT HAPPENS AFTER THE MISSON STARTS:
	// Planting mines through the available minefields:
	{  // forEach DAMM_confirmedMfMarkers (part 2/2):
		_confirmedMfMarkersLists = _x;
		{  // forEach _confirmedMfMarkersLists:
			// Loading the limiter data:
			_limiterMineAmounts = _limiterByMinefield select (_confirmedMfMarkersLists find _x);
			// Check shape after symmetry function:
			_mfSize = markerSize _x;
			// Looking for factions tag on minefield names:
			_mfNameStructure = [_x, DAMM_prefix, DAMM_spacer] call THY_fnc_DAMM_marker_name_splitter;
			// Mine planter (slow process)
			_mineAmountsByType = [_mfNameStructure, DAMM_mineTypeAP, DAMM_mineTypeAM, _x, _mfSize, _limiterMineAmounts, _mineAmountsByType] call THY_fnc_DAMM_mine_planter;  // returns the mines' numbers updated.
		} forEach _confirmedMfMarkersLists;
	} forEach DAMM_confirmedMfMarkers;

	
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
	while { DAMM_debug } do {
		// CPU breath:
		sleep 5;
		// Debug monitor:
		[_mfAmountFaction, _mfAmountUnknown, _balanceMinesAP, _balanceMinesAM, _balanceMinesTotal] call THY_fnc_DAMM_debug;
	};  // while ends.
};  // spawn ends.
