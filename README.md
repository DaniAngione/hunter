# The Hunter
### by Daniel Angione
v1.1.1 for Stonehearth 1.1+
https://stonehearth.net/ 

## DESCRIPTION
This Mod adds a new job with its own gameplay features to the game: The Hunter.
An evolution of the Trapper, the Hunter can prove itself a valuable member of your community by providing resources from big game much more easily, rare resources from alligators or even Zillas without combat and a much greater efficiency when skilled enough to unlock their automation abilities and their companion - which provides them the amazing trait of being able to automatically teleport animal loot into your storage.

## CONTENTS

### THE HUNTER JOB
Become one with nature as you send a hearthling to perform a new but essential survivalist's job: hunting. Tired of traps - although they can still tend to them - Hunters will actively track and hunt down animals to provide your town with resources like pelts and meat. Capable of attacking marked targets, hunters are reliable professionals but not real fighters - they will behave like civilians when facing greater threats. The Hunter will unlock a series of cool new abilities as they progress through their levels.

### TRACKING WILD GAME
Similarly to how the Northern Alliance animal campaign works, having a Hunter will allow your town to occasionally spot wild game, providing a renewable source of huntable animals for your Hunter. Unlike the Northern Alliance campaign, however, animals that are tracked through a Hunter can come in larger packs or even different kinds than the usual ones from that campaign.

### THE HUNTING CAMP
On Level 3 the Hunter will gain the ability to use Hunting Camps, and the recipe will be unlocked for the Weaver. A Hunting Camp can be used as a chair or light source but its primary use is to automate the Hunter's job. Whenever new animals are tracked (spawned) near a Hunting Camp, they will be automatically marked for hunting. This provides the player with the ability to surround their borders with Hunting Camps and make sure their Hunter is constantly working!
	
### POACHING
On Level 5 the Hunter will learn how to find poaching opportunities. These are small quests outside of your town's territory that will allow your Hunter to go after more exotic resources or even a legendary headgear for themselves.
	
### DOG COMPANION
Finally, on Level 6, your Hunter will develop a beautiful friendship with a new best friend - their Hunting Dog. This animal is able to help the Hunter on their hunts by chasing down prey and keeping in the place for the Hunter to finish them. Additionally, when hunting with their hunting dog, all the loot dropped from slain animals will be automatically transported to one of your Hunting Camps, if they're available.

## REQUIREMENTS & PATCHES

The Hunter has no special requirements.

It has cross-functionality with the following mods:

- Stonehearth ACE : ACE hunting resources are added to hunts; ACE resources added to some recipes. Fully compatible with ACE monkey patches.
- Trapper+ : Fully compatible with Trapper+ raw meats and fresh pelts. If using Trapper+, the Hunter's Bow will be crafted by the Trapper and not the Carpenter.
	
## COMPATIBILITY

This mod is compatible to any mods that doesn't override or alter the following controllers:
- combat_service.lua
- node.lua
- loot_drops_component.lua
- dispatch_quest_encounter.lua
- donation_dialog_encounter.lua

The mod is adapted to work with ACE's changes to these files.

## LOCALIZATION

This mod is completely compatible with Stonehearth's localization, it is in English (en) by default and will include a Brazillian Portuguese (pt-BR) translation in the future.

If you're willing to translate this mod to any other language and would like to see the localization supported on the official mod itself, contact me on Discord:
DaniAngione#3266

## CREDITS, SUPPORT & LICENSE

Mod created by Daniel Angione (DaniAngione#3266 on Discord; daniangi@gmail.com)
Stonehearth created by Radiant Entertainment (https://stonehearth.net)
My Modding Corner (https://discourse.stonehearth.net/t/danis-modding-corner/36452)

Very special thanks to PaultheGreat for his help with some of the coding issues I've ran into!

This mod and all its contents are under a GNU GPL 3.0 license and may be used, shared, remixed and anything else as long as credit is given, linked and the same license is used! More info: https://www.gnu.org/licenses/gpl-3.0.en.html

## CHANGELOG

### August 28th, 2023 - v1.1.1
- Fixed a Loot Drops component issue when using ACE.

### June 6th, 2022 - v1.1
- Increased the minimum experience gained by the Hunter when hunting animals from 5 to 16
- Increased the maximum experience gained by the Hunter when hunting animals from 70 to 90
- Decreased the time to "clean-up" hunts from 7 to 4 days
- Fixed a long-standing combat service issue that caused turrets to not kill enemies
- Fixed another combat service issue that albeit rarer, caused all units (including enemies and lings) to not be able to harm/damage each other anymore
- Removed `node.lua` patch (not needed anymore)
- Streamlined/cleaned scripts a bit
- Fixed an issue with the Hunting Camp not properly "ordering" animals to be hunted even when spawning within its range
- Fixed an issue that made wild animal tracking permanently stop after a while.

### October 9th, 2020 - v1.0.1
- Fixed an issue with the Loot Drops Component that caused errors when using the stable release of ACE.
- Fixed an issue when sending out a citizen to a dispatch quest (i.e: Amberstone) and they don't have a pet.
- Added compatibility for customizing the "Dog Companion" per kingdom.

### October 8th, 2020 - v1.0
- Initial Release