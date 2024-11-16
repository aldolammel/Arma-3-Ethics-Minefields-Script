// ETHICS MINEFIELDS v1.9
// File: your_mission\ETHICSMinefields\fn_ETH_management.sqf
// Documentation: https://github.com/aldolammel/Arma-3-Ethics-Minefields-Script/blob/main/_ETH_Script_Documentation.pdf
// by thy (@aldolammel)

// Runs only in server:
if !isServer exitWith {};


// PARAMETERS OF EDITOR'S OPTIONS:
// Main:
	ETH_isOn                   = true;     // true = keep the script running in your mission / false = turn it completelly off. Default: true
	ETH_isOnDebug              = true;     // true = shows crucial info only to hosted-server-player / false = turn it off. Detault: false
	ETH_killzoneStyleColor     = "ColorRed";   // color of minefields on map in-game. Default: "ColorRed"  // https://community.bistudio.com/wiki/Arma_3:_CfgMarkerColors
	ETH_killzoneStyleBrush     = "FDiagonal";  // texture of minefields on map in-game. Default: "FDiagonal"
	ETH_killzoneStyleAlpha     = 1;       // 0.5 = Minefields barely invisible on the map / 1 = quite visible. Default: 1
	ETH_killzoneVisibleOnMap   = true;    // true = The side kill zone is visible on map only by its side player / false = invisible for everyone. Defalt: true
	ETH_globalDevicesIntensity = "MID";   // Proportional number of explosives through the area-markers. Options: "EXTREME", "HIGH", "MID", "LOW", "LOWEST". Default: "MID"
	ETH_globalRulesEthics      = true;    // true = script follows military conventions for choosing where to plant mines / false = mine has no ethics. Default: true
	ETH_globalRulesTopography  = true;    // true = script follows topography for choosing better where to plant mines / false = mines every terrains. Default: true
// Minefield doctrines:
	ETH_doctrinesLandMinefield  = true;   // true = landmines will spawn if an area-marker requests them / false = turn it off. Default: true
	ETH_doctrinesNavalMinefield = true;   // true = naval mines will spawn if an area-marker requests them / false = turn it off. Default: false
	ETH_doctrinesOXU            = true;   // true = Unexploded bombs will spawn if an area-marker requests them / false = turn it off. Default: false
	ETH_doctrinesTraps          = true;   // true = Traps will spawn if an area-marker requests them / false = turn it off. Default: false
// Explosives:
	ETH_ammoLandAP  = "APERSMine";         // Default: "APERSMine". For more device options, check the Ethics Documentation.
	ETH_ammoLandAM  = "ATMine";            // Default: "ATMine". For more device options, check the Ethics Documentation.
	ETH_ammoNavalAM = "UnderwaterMineAB";  // Default: "UnderwaterMineAB". For more options, check the Ethics Documentation.
	ETH_ammoPackUXO = ["BombCluster_01_UXO2_F", "BombCluster_02_UXO4_F", "BombCluster_03_UXO1_F"];  // For more device options, check the Ethics Documentation.
	ETH_ammoTrapBT  = "APERSTripMine";     // Default: "APERSTripMine". For more device options, check the Ethics Documentation.
// Server:
	ETH_cosmeticSmokesUXO = true;       // true = adds few impact smoke sources into the UXO zones / false = turn it off. Default: true
	ETH_A3_dynamicSim     = true;       // true = devices that are too far away from players will be frozen to save server performance / false = turn it off. Default: true
	//ETH_minesEditableByZeus   = true; // WIP / true = ETHICS explosive devices can be manipulated when Zeus is available / false = no editable. Detault: true


// ETHICS CORE / TRY TO CHANGE NOTHING BELOW!!! --------------------------------------------------------------------
// Global escape:
if !ETH_isOn exitWith {if ETH_isOnDebug then {systemChat "ETHICS Script was turned off manually."}};
// When the mission starts:
[] spawn {
	// Local object declarations:
	private ["_txt3", "_deviceAmountsByDoctrine", "_kzAmountSide", "_kzAmountUnknown", "_eachConfirmedList", "_kzSize", "_limiterDevicesKz", "_allDevicesPlantedAP", "_allDevicesDeletedAP", "_allDevicesPlantedAM", "_allDevicesDeletedAM", "_allDevicesPlantedUXO", "_allDevicesDeletedUXO", "_allDevicesPlantedTP", "_allDevicesDeletedTP","_totalDevicesDeleted", "_totalDevicesPlanted", "_balanceDevicesAP", "_balanceDevicesAM", "_balanceDevicesUXO", "_balanceDevicesTP", "_balanceDevicesTotal", "_balanceDevicesNoEthTotal"];
	
	// Declarations:
	ETH_txtDebugHeader = "ETHICS DEBUG >";
	ETH_txtWarnHeader  = "ETHICS WARNING >";
	// Debug txts:
	_txt3 = "ammunition is empty at fn_ETH_management.sqf file. To fix the error, the script set automatically an ammunition to be used.";
	// Handling errors:
	if ETH_killzoneVisibleOnMap then {if ( ETH_killzoneStyleAlpha > 1 || ETH_killzoneStyleAlpha < 0.1 ) then { systemChat format ["%1 The 'ETH_killzoneStyleAlpha' has an invalid value in 'fn_ETH_management.sqf' file. For now, Ethics script will use the default value.", ETH_txtWarnHeader]; ETH_killzoneStyleAlpha=1 }};
	if ( ETH_doctrinesLandMinefield && (ETH_ammoLandAP == "") ) then { ETH_ammoLandAP = "APERSMine"; systemChat format ["%1 The AP %2", ETH_txtWarnHeader, _txt3]};
	if ( ETH_doctrinesLandMinefield && (ETH_ammoLandAM == "") ) then { ETH_ammoLandAM = "ATMine"; systemChat format ["%1 The AM %2", ETH_txtWarnHeader, _txt3]};
	if ( ETH_doctrinesNavalMinefield && (ETH_ammoNavalAM == "") ) then { ETH_ammoNavalAM = "UnderwaterMineAB"; systemChat format ["%1 The NAM %2", ETH_txtWarnHeader, _txt3]};
	if ( ETH_doctrinesOXU && ((count ETH_ammoPackUXO) == 0) ) then { ETH_ammoPackUXO = ["BombCluster_01_UXO2_F", "BombCluster_02_UXO4_F", "BombCluster_03_UXO1_F"]; systemChat format ["%1 The UXO %2", ETH_txtWarnHeader, _txt3]};
	if ( ETH_doctrinesTraps && (ETH_ammoTrapBT == "") ) then { ETH_ammoTrapBT = "APERSTripMine"; systemChat format ["%1 The BT %2", ETH_txtWarnHeader, _txt3]};
	// Escape:
	if ( !ETH_doctrinesLandMinefield && !ETH_doctrinesNavalMinefield && !ETH_doctrinesOXU && !ETH_doctrinesTraps ) exitWith {systemChat format ["%1 There's no any doctrine available at fn_ETH_management.sqf file. Turn some doctrine 'TRUE' to use Ethics Minefields script.", ETH_txtWarnHeader]};
	// Kill zone name's structure:
	ETH_prefix = "killzone";  // CAUTION: NEVER include/insert the ETH_spacer character as part of the ETH_prefix too.
	ETH_spacer = "_";  // CAUTION: try do not change it, and never use "%"!
	// Initial values:            AP      AM      UXO     TP
	_deviceAmountsByDoctrine = [[0, 0], [0, 0], [0, 0], [0, 0]];  // [planted, deleted]
	ETH_confirmedKzMarkers   = [];
	_limiterDevicesKz        = [];
	_kzNameStructure         = [];
	_kzAmountSide            = 0;
	_kzAmountUnknown         = 0;
	// Search for all kill zone area-markers set by mission editor on Eden:
	ETH_confirmedKzMarkers = [ETH_prefix, ETH_spacer] call THY_fnc_ETH_marker_scanner;

	// IT HAPPENS BEFORE THE BRIEFING SCREEN:
	// Converting specific area markers to kill zone:
	{  // forEach ETH_confirmedKzMarkers (part 1/2):
		_eachConfirmedList = _x;
		{  // forEach _eachConfirmedList:
			// Marker shape symmetry's consolidation:
			[_x, ETH_prefix, ETH_spacer] call THY_fnc_ETH_shape_symmetry;
		} forEach _eachConfirmedList;
	} forEach ETH_confirmedKzMarkers;

	// Global object declarations:
	publicVariable "ETH_isOn";
	publicVariable "ETH_isOnDebug";
	publicVariable "ETH_killzoneVisibleOnMap";
	publicVariable "ETH_killzoneStyleColor";
	publicVariable "ETH_killzoneStyleBrush";
	publicVariable "ETH_killzoneStyleAlpha";
	publicVariable "ETH_doctrinesLandMinefield";
	publicVariable "ETH_ammoLandAP";
	publicVariable "ETH_ammoLandAM";
	publicVariable "ETH_doctrinesNavalMinefield";
	publicVariable "ETH_ammoNavalAM";
	publicVariable "ETH_doctrinesOXU";
	publicVariable "ETH_ammoPackUXO";
	publicVariable "ETH_cosmeticSmokesUXO";
	publicVariable "ETH_doctrinesTraps";
	publicVariable "ETH_ammoTrapBT";
	publicVariable "ETH_globalDevicesIntensity";
	publicVariable "ETH_globalRulesEthics";
	publicVariable "ETH_globalRulesTopography";
	publicVariable "ETH_A3_dynamicSim";
	//publicVariable "ETH_minesEditableByZeus";
	publicVariable "ETH_confirmedKzMarkers";
	publicVariable "ETH_prefix";
	publicVariable "ETH_spacer";
	publicVariable "ETH_txtDebugHeader";
	publicVariable "ETH_txtWarnHeader";
	// CAUTION: Never remove this sleep break!
	sleep 1;
	// IT HAPPENS AFTER THE MISSON STARTS:
	// Planting devices through the available kill zone:
	{  // forEach ETH_confirmedKzMarkers (part 2/2):
		_eachConfirmedList = _x;
		{  // forEach _eachConfirmedList:
			// Check kill zones' size after symmetry acted:
			_kzSize = markerSize _x;
			// Defining the explosive device' amount needed for each kill zone's size:
			_limiterDevicesKz = [ETH_globalDevicesIntensity, _kzSize] call THY_fnc_ETH_devices_intensity;  // returns the device amounts' limiters specific for kill zone.
			// Looking for sides tag on kill zone names:
			_kzNameStructure = [_x, ETH_prefix, ETH_spacer] call THY_fnc_ETH_marker_name_splitter;
			// Mine planter (slow process)
			_deviceAmountsByDoctrine = [_kzNameStructure, ETH_ammoLandAP, ETH_ammoLandAM, ETH_ammoNavalAM, ETH_ammoPackUXO, ETH_ammoTrapBT, _x, _kzSize, _limiterDevicesKz, _deviceAmountsByDoctrine] call THY_fnc_ETH_device_planter;  // returns the mines' numbers updated.
		} forEach _eachConfirmedList;
	} forEach ETH_confirmedKzMarkers;
	// Debug purposes:
	if ETH_isOnDebug then {
		sleep 1;  // It fixes a bug in the final calc when too much devices;
		systemChat format ["%1 > All confirmed kill zones are ready!", ETH_txtDebugHeader];
		_kzAmountSide = count (ETH_confirmedKzMarkers # 0);
		_kzAmountUnknown = count (ETH_confirmedKzMarkers # 1);
	};
	// Final balance:
	_allDevicesPlantedAP  = (_deviceAmountsByDoctrine # 0) # 0;
	_allDevicesDeletedAP  = (_deviceAmountsByDoctrine # 0) # 1;
	_allDevicesPlantedAM  = (_deviceAmountsByDoctrine # 1) # 0;
	_allDevicesDeletedAM  = (_deviceAmountsByDoctrine # 1) # 1;
	_allDevicesPlantedUXO = (_deviceAmountsByDoctrine # 2) # 0;
	_allDevicesDeletedUXO = (_deviceAmountsByDoctrine # 2) # 1;
	_allDevicesPlantedTP  = (_deviceAmountsByDoctrine # 3) # 0;
	_allDevicesDeletedTP  = (_deviceAmountsByDoctrine # 3) # 1;
	_balanceDevicesAP     = abs (_allDevicesPlantedAP - _allDevicesDeletedAP);
	_balanceDevicesAM     = abs (_allDevicesPlantedAM - _allDevicesDeletedAM);
	_balanceDevicesUXO    = abs (_allDevicesPlantedUXO - _allDevicesDeletedUXO);
	_balanceDevicesTP     = abs (_allDevicesPlantedTP - _allDevicesDeletedTP);
	_totalDevicesPlanted  = _allDevicesPlantedAP + _allDevicesPlantedAM + _allDevicesPlantedUXO + _allDevicesPlantedTP;
	_totalDevicesDeleted  = _allDevicesDeletedAP + _allDevicesDeletedAM + _allDevicesDeletedUXO + _allDevicesDeletedTP;
	_balanceDevicesTotal  = abs (_totalDevicesPlanted - _totalDevicesDeleted);
	_balanceDevicesNoEthTotal = abs ((count allMines) - _balanceDevicesTotal);
	// Debug looping:
	while { ETH_isOnDebug } do {
		// CPU breath:
		sleep 5;
		// Debug monitor:
		[_kzAmountSide, _kzAmountUnknown, _balanceDevicesAP, _balanceDevicesAM, _balanceDevicesUXO, _balanceDevicesTP, _balanceDevicesNoEthTotal] call THY_fnc_ETH_debug;
	};  // while ends.
};  // spawn ends.
