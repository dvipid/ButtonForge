Button Forge
Mod for World of Warcraft

Author: Massiner of Nathrezim
Contributor: xfsbill
Past Contributors: DT85, DandierSphinx

Version: 1.2.2.3

Description: Graphically create as many Action Bars and Buttons in the game as you choose

Usage:
- From the Button Forge Toolbar click the various buttons to enter into create/destroy bar mode
- Advanced options will display additional advanced options for each Bar created (such as key bindings)
- Drag the bars where you wish them to be placed
- When you are happy with your layout close the Button Forge Toolbar to hide the configuration gui either via the Key Binding, the Addon Configuration page, or the Red X on the Toolbar
- It is also possible to drag commands from the Button Forge Toolbar onto Button Forge bars, this is advisable for the Button Forge Configuration button
- Pretty much all of the gui configuration options are available via /bufo or /buttonforge commands (type them without any parameters for a listing of options). In addition there are several advanced
	options only available via the / commands.

Restrictions:
- Most (but not all) configuration options will not function during combat


History:
09-Mar-2024		v1.2.2.3 - Updated Interface version to 100205 to match retail

20-Feb-2024		v1.2.2.2 - Small optimization of the UNIT_AURA custom macro

08-Jan-2024		v1.2.2.1 - Removed Item Range checking the function IsItemInRange() is now restricted during combat

07-Jan-2024		v1.2.2.0 - Introduced fix so that Dragon Riding abilities work for Evokers (whom also share Dragon Riding spell names such as Surge Forward)
				   This change should also allow different Hex variants to do their specific cast
				And updated to WoW Interface 100200

05-May-2023			v1.2.1.0 - Updated to WoW Interface 100100

15-April-2023		v1.2.0.0 - Updated to WoW Interface 100007
							 - Button click mechanism updated
							 - No longer toggles CVar "ActionButtonUseKeyDown"
							 - Obeys hold and release casting for empower spells
							 - Obeys checkmouseovercast option now
							 - Added Spell Subtext to spell name, allows casting Hex(Compy) etc
							 - Fix up display handling of spells when on a macro
							 - Deprecated ForceOffCastOnKeydown (read: it does nothing now)

27-January-2023		v1.1.2.0 - Added custom implementation of spell flyouts to allow them to work again
							 - Eventually this will hopefully start working again from the SecureActionButtonTemplate

13-December-2022	v1.1.1.0 - Added validation for BarSave values when BarSave is loaded to a Bar, invalid values get replaced with defaults

04-December-2022	v1.1.0.8 - Update button to have new UI style
							 - Fix to show background grid when dragging new buttons vertically
							 - New bars will gain a button gap of 2 now as per updated UI layout (was 6)
							 - Fixed Button Forge Bar Configuration Button to work when clicked on the toolbar
							 - Button Forge toolbar has been updated to accomodate updated button layout
							 - Adjust layout of toolbar title
							 - Improved visibility on toolbar for when Right-Click-Self cast is active

23-November-2022	v1.1.0.7 - Workaround to allow mouse clicks to function on the up phase, this is a temporary solution until a better option becomes available
							 - Fixes Blizzard Keybindings option

17-November-2022	v1.1.0.6 - Fixes "-" (dash) keybind text
							 - Fixes scanning bag slots

16-November-2022	v1.1.0.5 - Updated for Wow v10.0.2

7-November-2022		v1.1.0.4 - Some optimisation with Masque button reskin

5-November-2022		v1.1.0.3 - Fixes tradeskill buttons
							 - Fixes keybinding abbreviations
							 - Fixes bonus bar
							 - Fixes Masque reskin after a UI reload

28-October-2022		v1.1.0.2 - Temporary fix to try matching the behaviour of Blizzard UI in regard to ActionButtonUseKeyDown

27-October-2022		v1.1.0.1 - Fixes right-click self-cast

25-October-2022		v1.1.0   - Updated for Wow v10.0.0 Dragonflight
							 - Slash command /bufo -bar now support a list of bars (ex.: /bufo -bar 1,2,3)

27-January-2022		v1.0.11  - Fixed an issue picking up some spells

11-November-2021	v1.0.10  - Updated for Wow v9.1.5
							 - Experimental: Support custom visibility macro aura:spellID
							 - Adds slash commands to list active auras (spellID)

25-October-2021		v1.0.9  - Fixed an issue with new custom visibility macro map:mapID
							- Experimental: Support custom visibility macro quest:questID
							- Adds slash commands to list current location (mapID) and quests (questID)

14-October-2021		v1.0.8  - Experimental: Support custom visibility macro map:mapID. Get current mapID with /run print(C_Map.GetBestMapForUnit("player"))

28-August-2021		v1.0.7  - Fixed an issue with Priest PVP Talent spell "Inner Light and Shadow" (Thanks to techno_tpuefol)

03-August-2021		v1.0.6	- Fixed an issue with Priest PVP Talent spell "Spirit of the Redeemer"

03-July-2021		v1.0.5	- Fixed an issue displaying cooldown for Fury Warrior Condemn spell

09-March-2021		v1.0.4	- Updated for Wow v9.0.5
							- Updated help (/bufo)
							- Fixed an issue disabling/enabling button frames

28-Jan-2021			v1.0.3	- Replaced Stealth and Prowl with their proper stealth icon
							- Experimental: Configurable flyout direction through slash commands

02-Dec-2020			v1.0.2	- Removed Zone Ability frame when placed into a bar
							- Added slash commands to list bars and allow to interact with bars without a label
							- Reintroduced clamping bars to the screen (a feature that was disabled all the way back in 2015)
							- Added keybind support for gamepads
							
23-Nov-2020			v1.0.1	- Fixed an issue opening/closing some tradeskills window
							
19-Nov-2020			v1	- Updated for Wow v9.0 - This update is provided by xfsbill , jee_dae (possibly others ?) - thanks for keeping a version of the addon working all this time!
							
26-July-2018		v0.9.50 - Updated for Wow v8.0 - this update is provided by DT85 (Zaranias - Aman'thul) & DandierSphinx... A big thanks for this!!!
							- The below issues all prevented Button Forge functioning correctly or in some cases at all
								- Corrected issue with removed UPDATE_WORLD_STATES event
								- Corrected audio from Button Forge specific actions (e.g. opening/closing BF BUI)
								- Corrected handling of Spells
								- Corrected detection of when the Wisp Spell Icon should display
28-November-2016	v0.9.47	- Updated for WoW v7.1
04-October-2016		v0.9.46 - Fixed Icon display for Equipment Sets... Again! (also some corrections for talents etc which were actually added in .45 I believe?!, my book keeping on this one has been a bit iffy :S)
09-August-2016		v0.9.45 - Fixed Icon display for Equipment Sets on Button Forge
01-August-2016		v0.9.44	- Fixed problem causing talent abilities to show up as '?'
							- Fixed BF load error affecting some players that utilise the profiles functionality
							- Effectively eliminated the few cases that Button Forge uses the /Run command removing the need to enable scripts to run (see notes below)
								- Summon Mounts, switched back to using a spell cast
								- Summon battlepets, now uses the /summonpet macro command
								- Exit vehicle, now uses /leavevehicle macro command
								- Cancel Possession, this button has been removed (the BF bonus bar typically does not appear for possession anyway, unless specifically setup to by the player)
								- Summon Favorite mount, this is coded to force load the Blizzard Collections addon, and /click the Favorite Mount button
							- Added a new global setting for Button Forge "-usecollectionsfavoritemountbutton" with the following behaviour
								- set False: Uses a /run command and will need scripts enabled by the player (advantage is it doesn't rely on the Blizzard Collections module so wont force load it)
								- set True: Uses a /click of the Favorite Button in the Collections Module, and forces it to load
								- On introduction of the setting
									- Defaults to False if allow dangerous scripts is already enabled by the player
									- Defaults to True if allow dangerous scripts is not enabled by the player
								- NOTE: Basically don't worry about this setting unless there is a very specific reason to alter it
								
25-July-2016		v0.9.43	- Added safety check for the mount to clear it if it's not properly detected
							- Fixed macrocheckdelay so that it doesn't cause an error (note this setting is not recommended to alter)
							
24-July-2016		v0.9.42	- Added support for toggling all specialisations on and off

24-July-2016		v0.9.41 - Updated for WoW v7.0
							- Updated how Mounts are handled (Bliz keep tinkering with the API in this area)
							
01-July-2015		v0.9.40	- Updated for WoW v6.2
							- Fixed issue with mounts - as the previous hack is no longer needed, and due to a slight change
								with GetCursorInfo became incompatible
							- Toys should now show up more correctly on BF bars
							- Battlepets should now have Tooltips
							- Added zhTW locale that was supplied by Moripi
28-February-2015	v0.9.39	- Updated for WoW v6.1
							- Bars will not be clamped to screen in this version; due to clamp offsets becoming broken
								this will be reveresed at a later date when the clamp offsets work again
22-October-2014		v0.9.38	- Character settings are backed up to the Global Save for Button Forge
								this is to get around a WoW Mac issue preventing some char settings from loading
								This change is temporary and will likely be removed once Blizzard correct the issue
							- Paladin Mounts can now be triggered from BF Buttons
							- The Edge Cooldown effect will now also hide if visibility for BF Bars is off
							- A problem was causing Button Forge to often lose Character specific macros from its Buttons
								when new macros were created or deleted - this should behave a lot better now
18-October-2014		v0.9.37	- Corrected Cooldown Swipe/Bling when Buttons are partially or fully hidden
							- Corrected Priest Holy Word not being addable to Button Forge
							- For some people, Button Forge was erroring on login, this should be resolved
16-October-2014		v0.9.36	- Corrected issue preventing ButtonForge loading when Battlepets were present (Battlepets use a new ID system and needed to be cleared)
							- Added migration code to also update data stored in ButtonForge profiles
15-October-2014		v0.9.35	- Corrected issue with Macros that would prevent Button Forge working properly
15-October-2014		v0.9.34 - Another Quick Update to get Button Forge working against v6.0.2 which just went live.
							- Mounts will now work
25-August-2014		v0.9.33 - Quick and ROUGH update to get Button Forge functioning against Warlords of Draenor BETA
							- Adjusted SetChecked code
							- Adjusted Initialization of mount info (note that mounts and probably pets will not work correctly on BF at the moment)


20-November-2013	v0.9.32 - Fixed unrecognised Flyout actions causing an error on when on BF bars (either from loading a profile, or from inherited settings from a prior same named character)
							- Also corrected issue that caused flyout actions to not correctly be put on the cursor when removed from BF bars
20-September-2013	v0.9.31 - Added Profile support to Button Forge, only available via Slash commands
								* -saveprofile			(saves the current setup as a profile for later use)
								* -loadprofile			(loads a profile, along with all actions on the buttons - this can even be done for diff classes, the actions simply wont be recognised in some cases)
								* -loadprofiletemplate	(loads a profile but all buttons are blanked, treating the profile as a template for other chars)
								* -undoprofile			(reverts back to the setup prior to the last loadprofile, even if that was a previous session... note this itself can not be undone, so beware)
								* -deleteprofile		(simply deletes a previously saved profile)
								* -listprofiles
							- Also updated to be WoW v5.4 compatible
04-June-2013	v0.9.30 - Button Forge will now cast keybindings on the key down phase in the same manner the standard action buttons do, this behaviour is also toggled using the standard Interface-Combat option "Cast action keybinds on key down"*
						- * Added a new global setting for Button Forge "ForceOffCastOnKeyDown" that will override the above feature so that it is always off if desired, you must log back in for this setting to take effect
							(When ForceOffCastOnKeyDown is set, it will actually cause the original ButtonForge click handling pre v0.9.30 to apply)
24-May-2013		v0.9.29 - Fixed issue in previous version preventing non-masque users from running Button Forge
23-May-2013			v0.9.28	- Update to work against wow v5.3
							- Improved support of Masque skinning
							- Slightly update look of Buttons to match with the current style of the standard buttons in wow
06-March-2013		v0.9.27	- Updated to work against wow v5.2 (no code changes)
12-December-2012	v0.9.26	- More support for spell charges (particularly for the warlock demonology spells)
							- slash options that accept a yes/no will now also accept toggle
09-December-2012	v0.9.25	- Button Forge will now display spell charges on its buttons when appropriate (this also applies if the spell is from a macro)
							- a new slash command -hidepetbattle allows making it so that Button Forge bars can stay visible during a pet battle (by turning that option for the bar off, by default it's on)
							
02-December-2012	v0.9.24 - Buttonf Forge has been updated for WoW v5.1
							- BattlePets have been updated to work with WoW v5.1
							
17-October-2012		v0.9.23 - BattlePets can now be added to Button Forge bars (tooltips are not yet available for them)
							- All Button Forge bars will hide during Pet Battles
							
09-September-2012	v0.9.22 - Fixed the bonus bar (now the override/vehicle bar) to function again
							- Dragging Button Forge custom icons will now no longer show a black box over the icon.
							
03-September-2012	v0.9.21 - Fixed bars to hide by default when the Override Bar becomes enabled (this used to be BonusBar:5)

28-August-2012		v0.9.20 - 	Updated for WoW v5.0.4
								Issues that were resolved for the updated WoW API:
								- Lua errors prevening Button Forge even working
								- Cooldown error for mounts and companion pets
								- Picking up spells wasn't working
								- Handling of dynamic spells was largely unusable
								
								Still outstanding:
								- Now that pets are battle pets they can't be set or activated from Button Forge (your existing pets still show up and can be picked up and moved, but that's it)
								- Flyout spells (the one with the little arrow) is dropped rather than put on the cursor when removing from Button Forge
								- Also a minor graphic glitch that the little arrow sometimes doesn't show for the flyouts
								- dragging Button Forge specific actions (e.g. the open Button Forge config button) has a black square
								- Some code tidy up to remove redundant code (there are now better options to achieving some functionality)
								- Others???
								

06-February-2012	v0.9.17	- Localisation Support for 
								deDE 	Translation provided by Rumorix/PUNK2018

							  Fixed: Button Forge will now only show the action tooltip for a macro if the macro has the #showtooltip tag in it

							  Features:
								* New bar option 'GUI' available via /bufo commands, defaults to 'on'. Turning the gui off for a bar will cause it to be hidden and to no longer interact with the mouse
								  but its keybindings will be unaffected (think of it as Key Bind only mode)
								  The GUI will be temporarily forced 'on' provided you're not in combat, and are in Button Forge config mode, or are holding the Shift key while also have an item on the cursor (this is to ease setting the bar up how you want it)
								  
								* New bar option 'Alpha' available via /bufo commands, defaults to 1. This will simply change the opacity of the bar, the mouse will still interact with the bar, even if
								  it's fully transparent (unlike the new 'GUI' option, the alpha will not be forced up when in config mode etc...)
								  
11-December-2011	v0.9.16	- Updated toc to make Buttonf Forge Compatible with v4.3 of WoW
							  Fixed:
								* Bars would bounce out a little when pushing right up against the left or bottom of the screen if the buttongap had been adjusted; this should no longer happen
								* Macros are still causing trouble for some users (hopefully only a small few), this occurs because the WoW API sometimes lags at loging with making the macro info available and simply reports the player has none (with seemingly no way to know if this has occurred; I had thought in the last update I found a reliable event to use). The following two changes have been added in an attempt to provide a lasting solution
										a) A 3second delay has now been introduced before ButtonForge prunes missing macros, the setting can be adjusted using /bufo -macrocheckdelay # (where # is the number of seconds), this will delay all macro checks so do not set this value extremely high or it will have unintended consequences (next version I will probably put an upper limit on it!)
										b) If a reliable delay time cant be found, use /bufo -removemissingmacros no. That will disable automatic pruning of missing macros, if you delete a macro, you will need to manually remove it from the bar in this scenerio - but it will be preferable to having them possibly dissappear at login
							  
							  The following change has been made to allow some users familiar with how widgets in the WoW gui work to perform some external specialised customisations
								* The frame that controls visibility (not position) of the buttonforge bars buttons will now be given a frame name (relevant for some highly technical players). It works as follows:
									- Each bar will have a frame named something like ButtonForgeBar_<BarLabel>_ButtonFrame; where <BarLabel> is the label applied to the bar
									- If the full frame name is non unique, a number will be applied after the <BarLabel> to make it unique
									- The frame will almost definitely have a visibility macro (Button Forge utilises them quite a bit to avoid possible taint issues), Button Forge (currently) does not parent the ButtonFrame, so it will probably be ok to set this in order to have an external api/addon hide Button Forge bars with its own rules. 
									- IMPORTANT; You will need to log out and back into the game world for the name of the Frame to be updated (the frame names cant be changed while playing the game)
									- For best results, give the bar a unique label if you wish to use the frame
									- to get the frame names use /bufo -technicalinfo (the ButtonFrame currently isn't given a size, so you wont have much luck with identifying it spatially)
									- Any given usage of the frame is unsupported
										
19-September-2011	v0.9.15	- Fixed: Macros were sometimes disappearing from Button Forge bars
							  Feature: Localisation support for zhCN has been added - Translation provided by s.F
								
23-July-2011		v0.9.14 - Updated toc to make Button Forge compatible with v4.2 of WoW

28-April-2011		v0.9.13 - Features:
								* Many more of the configuration options are now available via slash commands
								* Added slash command to change the gap between buttons
								* Added slash command to disable and enable bars
								* Improved the feedback when slash commands are not correctly supplied
								* Added a basic API to allow other addons to query information from Button Forge
							Fixed:
								* Buttons weren't being properly deallocated when a bar was destroyed
								* In rare situations item caching in Button Forge was causing an error
								
16-January-2011		v0.9.12 - Features:
								* Slash commands are now available (/buttonforge or /bufo)
								* Slash commands include abiltity to turn off keybind and macro name plates
								* Holding shift will override button locks (same as the default UI)
								* Holding shift will bring Button Forge bars to the top if holding an item with the cursor
							Fixed:
								* Macros can now have the same name (although this is still not advised!)
								* Macro tracking will be a little more resilient (this affects when macros are changed). NB, this can never be perfect with the way the game currently works
								* Auto-alignement could sometimes have a lua error if other mods changed the default bars, this should not happen now
								* Spells with the same name would sometimes display as though they were the other spell, this should now be resolved

03-January-2011		v0.9.11 - Features: 
								* Button Forge Buttons will come to the foreground when the mouse
									has a placeable action (except items) to make placing spells easier
								* Key-binding has been tweaked to be more streamlined
								* While dragging bars, auto-alignment will now work off all sides of the bar
									and also provide guide lines
							- Fixed:
								* Better detection of shapeshift has been added (this allows icons for
									macros with forms rules to visually update a bit more quickly in some cases)
								* Archaeology Buttons will now check and uncheck correctly
										
22-Decembet-2010	v0.9.10	- Feature:
								Localisation support for
									koKR	Translation provided by chkid (주시자의눈 of Elune)
									ruRU	Translation provided by Another
							- Fixed: 
								ButtonFacade keybindings will not dissappear now
								Improved how wisp spell detection works (made it independant of localisation)
									
13-December-2010	v0.9.9	- Fixed: Corrected issue preventing binding of mouse buttons (note that the left and right button cannot be bound ever).
							- Feature: Button Facade support
							
18-October-2010		v0.9.8	- Fixed:
								Putting Companions and Mounts on the Bar was bugged, this has been fixed (any companions or mounts that are permanently highlighted should be removed and readded)
								
17-October-2010		v0.9.7	- Fixed:
								Work around the issue of some spells causing an issue when dragged onto the bar (issue was observed with hunter traps)
							- Feature:
								Support for Flyouts
								Support for Glow effect on certain spells
								
13-October-2010		v0.9.6	- Fixed:
								Macros that use items are having a problem with the cooldown display, this has been fixed.
								Picking up most items wasn't causing hidden button grids to show (while out of combat), this has also been fixed
								
12-October-2010		v0.9.5	- Fixed:
								Item counts will now show counts for items that use a consumable reagent
								Spells will no longer inadvertently change rank (a non issue now that v4 is available anyway)
							- Features:
								Updated to be compatible with v4.0.1
								
02-September-2010	v0.9.4	- Fixed:
								Creating a macro with an empty body or deleting a macro could sometimes cause visual errors in Button Forge, this has been resolved
								Tooltips for companions were dissappearing very quickly after displaying, this has been resolved
								
26-August-2010		v0.9.3	- Fixed:
								Tooltips now refresh while being displayed
								In some cases (particularly macros) item display was not updating, this has been resolved
							- Features:
								Bonus Bars are now supported
								A Right Click Self Casting option is now available

10-August-2010		v0.9.2	- Fixed:
								Scale - The Double Click default sometimes wouldn't detect the settings of a bar if one was in the same position, this has been resolved
								Dragging Custom Actions (Button Forge Configuration options) - These would sometimes drop straight off the cursor, this has been resolved
								Key Bind dialog has been shifted to appear above other UI elements (it is also possible to drag this dialog)
							- Features:
								Updated the GUI appearance
								Bar labels will now organise themselves for so they can be clicked to allow tabbing between bars if bars are in the same position
								Bar controls will now rearrange themselves to better use the space around the Action buttons
							
05-August-2010		v0.9.1	- Fixed:
								Equipment Sets will now be placed on the cursor when picked up off a Button Forge Bar
								Resolved stack overflow when creating excessively large bars (e.g. over 1000 buttons)
								Resolved issues causing some newly allocated buttons to be hidden and the bar to sometimes dissappear when allocating buttons
							- Features:
								Set a limit of 1500 buttons per bar and 5000 buttons total
								Added button for configuration mode
								Added ability to drag Button Forge Toolbar buttons to Button Forge bars
								Updated tooltip information
							
31-July-2010		v0.9.0	- Beta version of Button Forge
