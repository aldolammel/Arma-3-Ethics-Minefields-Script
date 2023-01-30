// DAMM: DRAG AREA MARKERS MINEFIELDS v1
// File: your_mission\DAMinefields\fn_DAMM_playerLocal.sqf
// by thy (@aldolammel)


// DAMM CORE / TRY TO CHANGE NOTHING BELOW!!! --------------------------------------------------------------------


if (!hasInterface) exitWith {};  // all players clients and player host can read this file.


[] spawn {
	// Let's see if this player should see some minefield:
	[DAMM_confirmedMfMarkers, DAMM_prefix, DAMM_spacer, DAMM_visibleOnMap, DAMM_styleColor, DAMM_styleBrush, DAMM_styleAlpha] call THY_fnc_DAMM_markers_visibility;
};
