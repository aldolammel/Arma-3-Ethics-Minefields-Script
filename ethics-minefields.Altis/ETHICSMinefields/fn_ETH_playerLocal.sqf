// ETHICS MINEFIELDS v1.7
// File: your_mission\ETHICSMinefields\fn_ETH_playerLocal.sqf
// by thy (@aldolammel)


// ETHICS CORE / TRY TO CHANGE NOTHING BELOW!!! --------------------------------------------------------------------


if (!hasInterface) exitWith {};  // all players clients and player host can read this file.


[] spawn {
	// Check if the main script file is okay to keep going:
	if ( ETH_doctrinesLandMinefield OR ETH_doctrinesNavalMinefield OR ETH_doctrinesOXU OR ETH_doctrinesTraps ) then {
		// Let's see if this player should see some minefield:
		[ETH_confirmedKzMarkers, ETH_prefix, ETH_spacer, ETH_killzoneVisibleOnMap, ETH_killzoneStyleColor, ETH_killzoneStyleBrush, ETH_killzoneStyleAlpha] call THY_fnc_ETH_markers_visibility;
	};
};
