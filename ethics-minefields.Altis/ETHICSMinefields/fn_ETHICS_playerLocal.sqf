// ETHICS MINEFIELDS v1
// File: your_mission\ETHICSMinefields\fn_ETHICS_playerLocal.sqf
// by thy (@aldolammel)


// ETHICS CORE / TRY TO CHANGE NOTHING BELOW!!! --------------------------------------------------------------------


if (!hasInterface) exitWith {};  // all players clients and player host can read this file.


[] spawn {
	// Let's see if this player should see some minefield:
	[ETHICS_confirmedMfMarkers, ETHICS_prefix, ETHICS_spacer, ETHICS_visibleOnMap, ETHICS_styleColor, ETHICS_styleBrush, ETHICS_styleAlpha] call THY_fnc_ETHICS_markers_visibility;
};
