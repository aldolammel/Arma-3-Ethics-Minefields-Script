# Arma 3 / ETHICS Minefields v1.5.3
>*Dependencies: none.*

ETHICS  is a full solution script for ARMA 3 that provides wide creation and management over statics kill zones like minefields, UXO zones, and trap zones. Built for single-player and multiplayer, ETHICS include kill zone doctrines such as land anti-personnel, land anti-materiel, naval anti-materiel, unexploded ordnance, and booby-trap.

## HOW TO INSTALL / DOCUMENTATION

video demo: soon!

Doc: https://github.com/aldolammel/Arma-3-Ethics-Minefields-Script/blob/main/ethics-minefields.Altis/ETHICSMinefields/_ETH_Script_Documentation.pdf

__

## SCRIPT DETAILS

- Drag and drop a marker on Eden to create a full and unique static kill zone such as minefields;
- Also easy to build naval minefields, Unexploded ordnance zones (UXO), and Trap zones;
- Ethics control (ON/OFF) to avoid planting explosive devices through civilian zones;
- Topography control (ON/OFF) to avoid planting over rock clusters and mountains;
- UXO doesn't respect Ethics or topography controls, and can be dropped under the water;
- Boobs-trap doesn't respect topography controls and they are always hidden, never in the open;
- Anti-personnel (AP) landmines avoid roads and streets;
- Anti-materiel (AM) landmines are planted (ON/OFF) only on roads and streets;
- Classic minefields can be also hybrid, bringing AP + AM mines;
- Set (or not) for each kill zone has a faction owner;
- Easy explosive devices amount management through the global intensity presets: lowest, low, mid, high, or extreme;
- Debugging: friendly error handling;
- Debugging: a hint monitor, and systemChat feedbacks for the mission editor;
- Debugging: full documentation available.

__

## IDEA AND FIX?

Discussion and known issues: https://forums.bohemia.net/forums/topic/241257-release-ethics-minefields/

__

## CHANGELONG

**Feb, 5th 2023 | v1.5.3**

- Added > Explosive device preset's intensity: "lowest";
- Improvement > Limited Anti-Material is a specific doctrine called "LAM";
- Improvement > Debug monitor now is saying when a kill zone starts to plant its explosives, and when the whole script execution is done;
- Documentation has been updated.

**Feb, 4th 2023 | v1.5**

- Added > New killzone doctrine: UXO, Unexploded Ordnance zone, absolutely through unique features;
- Added > New killzone doctrine: BT,  Booby-trap, also a great option totally different logic;
- Improvements > The new doctrines requested lot of hours of reviewing code; 
- Fixed > fixed a markerColor inconsistency when debug mode activated, and an invalid faction tag was applied;

**Feb, 1st 2023 | v1.3**

- Added the option to make AM doctrine plants its mines only on roads and streets;
- Some functions improvements;
- Documentation has been completely updated (with images).

**Jan, 31st 2023 | v1.2**

- Now naval minefields are available;
- Some functions improvements;
- Demo map changed from Malden to Altis;
- Documentation has been updated.

**Jan, 30th 2023 | v1.0**

- Hello world.
