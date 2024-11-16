// ETHICS MINEFIELDS v1.9
// File: your_mission\ETHICSMinefields\fn_ETH_playerLocal.sqf
// by thy (@aldolammel)


// ETHICS CORE / TRY TO CHANGE NOTHING BELOW!!! --------------------------------------------------------------------
// Escape:
if ( !ETH_isOn || !hasInterface) exitWith {};  // all players clients and player host can read this file.
// Check if the main script file is okay to keep going:
if ( ETH_doctrinesLandMinefield || ETH_doctrinesNavalMinefield || ETH_doctrinesOXU || ETH_doctrinesTraps ) then {
	// Local object declarations:
	params ["_playerSide"];
	private ["_eachConfirmedList", "_kzNameStructure", "_kzDoctrine", "_kzSide", "_kzBrush"];
	{  // forEach ETH_confirmedKzMarkers:
		_eachConfirmedList = _x;
		{  // forEach _eachConfirmedList:
			// Basic validations:
			_kzNameStructure = [_x, ETH_prefix, ETH_spacer] call THY_fnc_ETH_marker_name_splitter;
			_kzDoctrine      = [_kzNameStructure, _x, false] call THY_fnc_ETH_marker_name_section_doctrine;
			_kzSide          = [_kzNameStructure, _x, false] call THY_fnc_ETH_marker_name_section_side;
			// Initial values:
			_kzBrush = ETH_killzoneStyleBrush;  // Assuming all minefield areas, if it known, has the a pattern texture on the map.
			// Execute the style configuration, regardless the player can see it or not:
			if ( ETH_doctrinesLandMinefield && (_kzDoctrine == "LAM") ) then { _kzBrush = "Border" };  // style for doctrines where only roads are mined.
			if ( ETH_doctrinesTraps && (_kzDoctrine == "BT") ) then          { _kzBrush = "Border" };  // style for doctrines where only roads are mined.
			if ( ETH_doctrinesOXU && (_kzDoctrine == "UXO") ) then           { _kzBrush = "Cross" };   // https://community.bistudio.com/wiki/setMarkerBrush
			_x setMarkerBrushLocal _kzBrush;  // Be smart and leave all minefield areas with the correct brush.
			if !ETH_isOnDebug then {
				_x setMarkerAlphaLocal 0;  // if not debugging, assumes all minefield areas are unknown and should be hidden.
			// If debugging:
			} else {
				// For debug purposes, regardless the side, make all minefield areas visible and colorful by side:
				_x setMarkerAlphaLocal ETH_killzoneStyleAlpha;  // When not debugging, all side kz will get the same color!
				switch _kzSide do {
					// Makes the editor life easier across debugging:
					case "BLU": { _x setMarkerColorLocal "ColorWEST" };
					case "OPF": { _x setMarkerColorLocal "ColorEAST" };
					case "IND": { _x setMarkerColorLocal "ColorGUER" };
					default     { _x setMarkerColorLocal "ColorUNKNOWN" };
				};
			};
			// Editor wants all side minefield areas visible on the player map;
			if ETH_killzoneVisibleOnMap then {
				// Each minefield planted by the player's side, make that area visible on the player's map:
				switch _kzSide do {
					// If debugging false, it makes sure the player can see their side minefield areas at least if the editor allows them (ETH_killzoneVisibleOnMap):
					case "BLU": { if ( _playerSide == BLUFOR ) then      { _x setMarkerAlphaLocal ETH_killzoneStyleAlpha } };
					case "OPF": { if ( _playerSide == OPFOR ) then       { _x setMarkerAlphaLocal ETH_killzoneStyleAlpha } };
					case "IND": { if ( _playerSide == INDEPENDENT ) then { _x setMarkerAlphaLocal ETH_killzoneStyleAlpha } };
				};
				if !ETH_isOnDebug then { _x setMarkerColorLocal ETH_killzoneStyleColor };
			};
		} forEach _eachConfirmedList;
	} forEach ETH_confirmedKzMarkers;
};
// Return:
true;
