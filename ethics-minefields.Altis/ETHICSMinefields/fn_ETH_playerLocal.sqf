// ETHICS MINEFIELDS v1.3
// File: your_mission\ETHICSMinefields\fn_ETH_playerLocal.sqf
// by thy (@aldolammel)


// ETHICS CORE / TRY TO CHANGE NOTHING BELOW!!! --------------------------------------------------------------------


if (!hasInterface) exitWith {};  // all players clients and player host can read this file.


[] spawn {
	// Check if the main script file is okay to keep going:
	if ( ETH_landMinesDoctrines OR ETH_navalMinesDoctrines ) then {
		// Let's see if this player should see some minefield:
		[ETH_confirmedMfMarkers, ETH_prefix, ETH_spacer, ETH_visibleOnMap, ETH_styleColor, ETH_styleBrush, ETH_styleAlpha] call THY_fnc_ETH_markers_visibility;
	};
};
