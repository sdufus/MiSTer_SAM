#!/bin/bash

# https://github.com/mrchrisster/MiSTer_SAM/
# Copyright (c) 2021 by mrchrisster and Mellified

# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

## Description
# This cycles through arcade and console cores periodically
# Games are randomly pulled from their respective folders

# ======== Credits ========
# Original concept and implementation: mrchrisster
# Additional development and script layout: Mellified
#
# Thanks for the contributions and support:
# pocomane, kaloun34, redsteakraw, RetroDriven, woelper, LamerDeluxe, InquisitiveCoder, Sigismond, venice, Paradox


#!/bin/bash
export PATH=/bin:/sbin:/usr/bin:/usr/sbin:/media/fat/linux:/media/fat/Scripts:/media/fat/Scripts/.MiSTer_SAM:.

#======== INI VARIABLES ========
# Change these in the INI file

#======== GLOBAL VARIABLES =========
declare -g mrsampath="/media/fat/Scripts/.MiSTer_SAM"
declare -g misterpath="/media/fat"
# Save our PID and process
declare -g sampid="${$}"
declare -g samprocess="$(basename -- ${0})"
declare -g inmenu=0

#======== DEBUG VARIABLES ========
samquiet="Yes"
samdebug="No"
samtrace="No"

#======== LOCAL VARIABLES ========
declare -i coreretries=3
declare -i romloadfails=0
countpath="${mrsampath}/SAM_Count"
gamelistpath="${mrsampath}/SAM_Gamelists"
gamelistpathtmp="/tmp/.SAM_List/"
excludepath="${mrsampath}"
mralist="/tmp/.SAM_List/arcade_romlist"
tmpfile="/tmp/.SAM_List/tmpfile"
tmpfile2="/tmp/.SAM_List/tmpfile2"
gametimer=120
corelist="arcade,fds,gb,gbc,gba,genesis,gg,megacd,neogeo,nes,s32x,sms,snes,tgfx16,tgfx16cd,psx"
gamelist="Dynamic"
skipmessage="Yes"
usezip="Yes"
norepeat="Yes"
disablebootrom="Yes"
mute="Yes"
playcurrentgame="No"
listenmouse="Yes"
listenkeyboard="Yes"
listenjoy="Yes"
repository_url="https://github.com/mrchrisster/MiSTer_SAM"
branch="main"
counter=0
userstartup="/media/fat/linux/user-startup.sh"
userstartuptpl="/media/fat/linux/_user-startup.sh"
usedefaultpaths="No"
neogeoregion="English"
useneogeotitles="Yes"

# ======== TTY2OLED =======
ttyenable="No"
ttydevice="/dev/ttyUSB0"
ttysystemini="/media/fat/tty2oled/tty2oled-system.ini"
ttyuserini="/media/fat/tty2oled/tty2oled-user.ini"
ttyuseack="No"

#======== CORE PATHS ========
arcadepath="/media/fat/_Arcade"
fdspath="/media/fat/Games/NES"
gbpath="/media/fat/Games/Gameboy"
gbcpath="/media/fat/Games/Gameboy"
gbapath="/media/fat/Games/GBA"
genesispath="/media/fat/Games/Genesis"
ggpath="/media/fat/Games/SMS"
megacdpath="/media/fat/Games/MegaCD"
neogeopath="/media/fat/Games/NeoGeo"
nespath="/media/fat/Games/NES"
s32xpath="/media/fat/Games/S32X"
smspath="/media/fat/Games/SMS"
snespath="/media/fat/Games/SNES"
tgfx16path="/media/fat/Games/TGFX16"
tgfx16cdpath="/media/fat/Games/TGFX16-CD"
psxpath="/media/fat/Games/PSX"

#======== CORE PATHS EXTRA ========
arcadepathextra=""
fdspathextra=""
gbpathextra=""
gbcpathextra=""
gbapathextra=""
genesispathextra=""
ggpathextra=""
megacdpathextra=""
neogeopathextra=""
nespathextra=""
s32xpathextra=""
smspathextra=""
snespathextra=""
tgfx16pathextra=""
tgfx16cdpathextra=""
psxpathextra=""

#======== CORE PATHS RBF ========
arcadepathrbf="_Arcade"
fdspathrbf="_Console"
gbpathrbf="_Console"
gbcpathrbf="_Console"
gbapathrbf="_Console"
genesispathrbf="_Console"
ggpathrbf="_Console"
megacdpathrbf="_Console"
neogeopathrbf="_Console"
nespathrbf="_Console"
s32xpathrbf="_Console"
smspathrbf="_Console"
snespathrbf="_Console"
tgfx16pathrbf="_Console"
tgfx16cdpathrbf="_Console"
psxpathrbf="_Console"

#======== EXCLUDE LISTS ========
arcadeexclude="First Bad Game.mra
Second Bad Game.mra
Third Bad Game.mra"

fdsexclude="First Bad Game.fds
Second Bad Game.fds
Third Bad Game.fds"

gbexclude="First Bad Game.gb
Second Bad Game.gb
Third Bad Game.gb"

gbcexclude="First Bad Game.gbc
Second Bad Game.gbc
Third Bad Game.gbc"

gbaexclude="First Bad Game.gba
Second Bad Game.gba
Third Bad Game.gba"

genesisexclude="First Bad Game.md
Second Bad Game.md
Third Bad Game.md"

ggexclude="First Bad Game.gg
Second Bad Game.gg
Third Bad Game.gg"

megacdexclude="First Bad Game.chd
Second Bad Game.chd
Third Bad Game.chd"

neogeoexclude="First Bad Game.neo
Second Bad Game.neo
Third Bad Game.neo"

nesexclude="First Bad Game.nes
Second Bad Game.nes
Third Bad Game.nes"

s32xexclude="First Bad Game.32x
Second Bad Game.32x
Third Bad Game.32x"

smsexclude="First Bad Game.sms
Second Bad Game.sms
Third Bad Game.sms"

snesexclude="First Bad Game.sfc
Second Bad Game.sfc
Third Bad Game.sfc"

tgfx16exclude="First Bad Game.pce
Second Bad Game.pce
Third Bad Game.pce"

tgfx16cdexclude="First Bad Game.chd
Second Bad Game.chd
Third Bad Game.chd"

psxexclude="First Bad Game.chd
Second Bad Game.chd
Third Bad Game.chd"

# ======== CORE CONFIG ========
function init_data() {

# Core to long name mappings
declare -gA CORE_PRETTY=( \
["arcade"]="MiSTer Arcade" \
["fds"]="Nintendo Disk System" \
["gb"]="Nintendo Game Boy" \
["gbc"]="Nintendo Game Boy Color" \
["gba"]="Nintendo Game Boy Advance" \
["genesis"]="Sega Genesis / Megadrive" \
["gg"]="Sega Game Gear" \
["megacd"]="Sega CD / Mega CD" \
["neogeo"]="SNK NeoGeo" \
["nes"]="Nintendo Entertainment System" \
["s32x"]="Sega 32x" \
["sms"]="Sega Master System" \
["snes"]="Super Nintendo Entertainment System" \
["tgfx16"]="NEC PC Engine / TurboGrafx-16 " \
["tgfx16cd"]="NEC PC Engine CD / TurboGrafx-16 CD" \
["psx"]="Sony Playstation" \
)

# Core to file extension mappings
declare -gA CORE_EXT=( \
["arcade"]="mra" \
["fds"]="fds" \
["gb"]="gb" \
["gbc"]="gbc" \
["gba"]="gba" \
["genesis"]="md" \
["gg"]="gg" \
["megacd"]="chd" \
["neogeo"]="neo" \
["nes"]="nes" \
["s32x"]="32x" \
["sms"]="sms" \
["snes"]="sfc" \
["tgfx16"]="pce" \
["tgfx16cd"]="chd" \
["psx"]="chd" \
)

# Core to path mappings
declare -gA CORE_PATH=( \
["arcade"]="${arcadepath}" \
["fds"]="${fdspath}" \
["gb"]="${gbpath}" \
["gbc"]="${gbcpath}" \
["gba"]="${gbapath}" \
["genesis"]="${genesispath}" \
["gg"]="${ggpath}" \
["megacd"]="${megacdpath}" \
["neogeo"]="${neogeopath}" \
["nes"]="${nespath}" \
["s32x"]="${s32xpath}" \
["sms"]="${smspath}" \
["snes"]="${snespath}" \
["tgfx16"]="${tgfx16path}" \
["tgfx16cd"]="${tgfx16cdpath}" \
["psx"]="${psxpath}" \
)

# Core to extra path mappings
declare -gA CORE_PATH_EXTRA=( \
["arcade"]="${arcadepathextra}" \
["fds"]="${fdspathextra}" \
["gb"]="${gbpathextra}" \
["gbc"]="${gbcpathextra}" \
["gba"]="${gbapathextra}" \
["genesis"]="${genesispathextra}" \
["gg"]="${ggpathextra}" \
["megacd"]="${megacdpathextra}" \
["neogeo"]="${neogeopathextra}" \
["nes"]="${nespathextra}" \
["s32x"]="${s32xpathextra}" \
["sms"]="${smspathextra}" \
["snes"]="${snespathextra}" \
["tgfx16"]="${tgfx16pathextra}" \
["tgfx16cd"]="${tgfx16cdpathextra}" \
["psx"]="${psxpathextra}" \
)

# Core to path mappings for rbf files
declare -gA CORE_PATH_RBF=( \
["arcade"]="${arcadepathrbf}" \
["fds"]="${fdspathrbf}" \
["gb"]="${gbpathrbf}" \
["gbc"]="${gbcpathrbf}" \
["gba"]="${gbapathrbf}" \
["genesis"]="${genesispathrbf}" \
["gg"]="${ggpathrbf}" \
["megacd"]="${megacdpathrbf}" \
["neogeo"]="${neogeopathrbf}" \
["nes"]="${nespathrbf}" \
["s32x"]="${s32xpathrbf}" \
["sms"]="${smspathrbf}" \
["snes"]="${snespathrbf}" \
["tgfx16"]="${tgfx16pathrbf}" \
["tgfx16cd"]="${tgfx16cdpathrbf}" \
["psx"]="${psxpathrbf}" \
)

# Can this core use ZIPped ROMs
declare -gA CORE_ZIPPED=( \
["arcade"]="No" \
["fds"]="Yes" \
["gb"]="Yes" \
["gbc"]="Yes" \
["gba"]="Yes" \
["genesis"]="Yes" \
["gg"]="Yes" \
["megacd"]="No" \
["neogeo"]="Yes" \
["nes"]="Yes" \
["s32x"]="Yes" \
["sms"]="Yes" \
["snes"]="Yes" \
["tgfx16"]="Yes" \
["tgfx16cd"]="No" \
["psx"]="No" \
)

# Can this core skip Bios/Safety warning messages
declare -gA CORE_SKIP=( \
["arcade"]="No" \
["fds"]="Yes" \
["gb"]="No" \
["gbc"]="No" \
["gba"]="No" \
["genesis"]="No" \
["gg"]="No" \
["megacd"]="Yes" \
["neogeo"]="No" \
["nes"]="No" \
["s32x"]="No" \
["sms"]="No" \
["snes"]="No" \
["tgfx16"]="No" \
["tgfx16cd"]="Yes" \
["psx"]="No" \
)

# Core to input maps mapping
declare -gA CORE_LAUNCH=( \
["arcade"]="arcade" \
["fds"]="nes" \
["gb"]="gameboy" \
["gbc"]="gameboy" \
["gba"]="gba" \
["genesis"]="genesis" \
["gg"]="sms" \
["megacd"]="megacd" \
["neogeo"]="neogeo" \
["nes"]="nes" \
["s32x"]="s32x" \
["sms"]="sms" \
["snes"]="snes" \
["tgfx16"]="tgfx16" \
["tgfx16cd"]="tgfx16" \
["psx"]="psx" \
)

# MGL core name settings
declare -gA MGL_CORE=( \
["arcade"]="Arcade" \
["fds"]="NES" \
["gb"]="GAMEBOY" \
["gbc"]="GAMEBOY" \
["gba"]="GBA" \
["genesis"]="Genesis" \
["gg"]="SMS" \
["megacd"]="MegaCD" \
["neogeo"]="NEOGEO" \
["nes"]="NES" \
["s32x"]="S32X" \
["sms"]="SMS" \
["snes"]="SNES" \
["tgfx16"]="TurboGrafx16" \
["tgfx16cd"]="TurboGrafx16" \
["psx"]="PSX" \
)

# MGL delay settings
declare -gA MGL_DELAY=( \
["arcade"]="2" \
["fds"]="2" \
["gb"]="2" \
["gbc"]="2" \
["gba"]="2" \
["genesis"]="1" \
["gg"]="1" \
["megacd"]="1" \
["neogeo"]="1" \
["nes"]="2" \
["s32x"]="1" \
["sms"]="1" \
["snes"]="2" \
["tgfx16"]="1" \
["tgfx16cd"]="1" \
["psx"]="1" \
)

# MGL index settings
declare -gA MGL_INDEX=( \
["arcade"]="0" \
["fds"]="0" \
["gb"]="0" \
["gbc"]="0" \
["gba"]="0" \
["genesis"]="0" \
["gg"]="2" \
["megacd"]="0" \
["neogeo"]="1" \
["nes"]="0" \
["s32x"]="0" \
["sms"]="1" \
["snes"]="0" \
["tgfx16"]="0" \
["tgfx16cd"]="0" \
["psx"]="1" \
)

# MGL type settings
declare -gA MGL_TYPE=( \
["arcade"]="f" \
["fds"]="f" \
["gb"]="f" \
["gbc"]="f" \
["gba"]="f" \
["genesis"]="f" \
["gg"]="f" \
["megacd"]="s" \
["neogeo"]="f" \
["nes"]="f" \
["s32x"]="f" \
["sms"]="f" \
["snes"]="f" \
["tgfx16"]="f" \
["tgfx16cd"]="s" \
["psx"]="s" \
)

#Everdrive Zip naming convention
declare -gA CORE_EVERDRIVE=( \
["fds"]="Famicom Disk System" \
["gb"]="Game Boy" \
["gbc"]="Game Boy Color" \
["gba"]="Game Boy Advance" \
["genesis"]="Genesis" \
["gg"]="Game Gear" \
["megacd"]="Sega CD" \
["neogeo"]="NeoGeo" \
["nes"]="NES" \
["s32x"]="32x" \
["sms"]="Master System" \
["snes"]="SNES" \
["tgfx16"]="PC-Engine" \
["tgfx16cd"]="PC-Engine CD" \
["psx"]="Playstation" \
)
		
# NEOGEO to long name mappings English
declare -gA NEOGEO_PRETTY_ENGLISH=( \
["3countb"]="3 Count Bout" \
["2020bb"]="2020 Super Baseball" \
["2020bba"]="2020 Super Baseball (set 2)" \
["2020bbh"]="2020 Super Baseball (set 3)" \
["abyssal"]="Abyssal Infants" \
["alpham2"]="Alpha Mission II" \
["alpham2p"]="Alpha Mission II (prototype)" \
["androdun"]="Andro Dunos" \
["aodk"]="Aggressors of Dark Kombat" \
["aof"]="Art of Fighting" \
["aof2"]="Art of Fighting 2" \
["aof2a"]="Art of Fighting 2 (NGH-056)" \
["aof3"]="Art of Fighting 3: The Path of the Warrior" \
["aof3k"]="Art of Fighting 3: The Path of the Warrior (Korean release)" \
["b2b"]="Bang Bang Busters" \
["badapple"]="Bad Apple Demo" \
["bakatono"]="Bakatonosama Mahjong Manyuuki" \
["bangbead"]="Bang Bead" \
["bjourney"]="Blue's Journey" \
["blazstar"]="Blazing Star" \
["breakers"]="Breakers" \
["breakrev"]="Breakers Revenge" \
["brningfh"]="Burning Fight (NGH-018, US)" \
["brningfp"]="Burning Fight (prototype, older)" \
["brnngfpa"]="Burning Fight (prototype, near final, ver 23.3, 910326)" \
["bstars"]="Baseball Stars Professional" \
["bstars2"]="Baseball Stars 2" \
["bstarsh"]="Baseball Stars Professional (NGH-002)" \
["burningf"]="Burning Fight" \
["burningfh"]="Burning Fight (NGH-018, US)" \
["burningfp"]="Burning Fight (prototype, older)" \
["burningfpa"]="Burning Fight (prototype, near final, ver 23.3, 910326)" \
["cabalng"]="Cabal" \
["columnsn"]="Columns" \
["cphd"]="Crouching Pony Hidden Dragon Demo" \
["crswd2bl"]="Crossed Swords 2 (CD conversion)" \
["crsword"]="Crossed Swords" \
["ct2k3sa"]="Crouching Tiger Hidden Dragon 2003 Super Plus (The King of Fighters 2001 bootleg)" \
["ctomaday"]="Captain Tomaday" \
["cyberlip"]="Cyber-Lip" \
["diggerma"]="Digger Man" \
["doubledr"]="Double Dragon" \
["eightman"]="Eight Man" \
["fatfursp"]="Fatal Fury Special" \
["fatfurspa"]="Fatal Fury Special (NGM-058 ~ NGH-058, set 2)" \
["fatfury1"]="Fatal Fury: King of Fighters" \
["fatfury2"]="Fatal Fury 2" \
["fatfury3"]="Fatal Fury 3: Road to the Final Victory" \
["fbfrenzy"]="Football Frenzy" \
["fghtfeva"]="Fight Fever (set 2)" \
["fightfev"]="Fight Fever" \
["fightfeva"]="Fight Fever (set 2)" \
["flipshot"]="Battle Flip Shot" \
["frogfest"]="Frog Feast" \
["froman2b"]="Idol Mahjong Final Romance 2 (CD conversion)" \
["fswords"]="Fighters Swords (Korean release of Samurai Shodown III)" \
["ftfurspa"]="Fatal Fury Special (NGM-058 ~ NGH-058, set 2)" \
["galaxyfg"]="Galaxy Fight: Universal Warriors" \
["ganryu"]="Ganryu" \
["garou"]="Garou: Mark of the Wolves" \
["garoubl"]="Garou: Mark of the Wolves (bootleg)" \
["garouh"]="Garou: Mark of the Wolves (earlier release)" \
["garoup"]="Garou: Mark of the Wolves (prototype)" \
["ghostlop"]="Ghostlop" \
["goalx3"]="Goal! Goal! Goal!" \
["gowcaizr"]="Voltage Fighter Gowcaizer" \
["gpilots"]="Ghost Pilots" \
["gpilotsh"]="Ghost Pilots (NGH-020, US)" \
["gururin"]="Gururin" \
["hyprnoid"]="Hypernoid" \
["irnclado"]="Ironclad (prototype, bootleg)" \
["ironclad"]="Ironclad" \
["ironclado"]="Ironclad (prototype, bootleg)" \
["irrmaze"]="The Irritating Maze" \
["janshin"]="Janshin Densetsu: Quest of Jongmaster" \
["joyjoy"]="Puzzled" \
["kabukikl"]="Far East of Eden: Kabuki Klash" \
["karnovr"]="Karnov's Revenge" \
["kf2k2mp"]="The King of Fighters 2002 Magic Plus (bootleg)" \
["kf2k2mp2"]="The King of Fighters 2002 Magic Plus II (bootleg)" \
["kf2k2pla"]="The King of Fighters 2002 Plus (bootleg set 2)" \
["kf2k2pls"]="The King of Fighters 2002 Plus (bootleg)" \
["kf2k5uni"]="The King of Fighters 10th Anniversary 2005 Unique (The King of Fighters 2002 bootleg)" \
["kf10thep"]="The King of Fighters 10th Anniversary Extra Plus (The King of Fighters 2002 bootleg)" \
["kizuna"]="Kizuna Encounter: Super Tag Battle" \
["kof2k4se"]="The King of Fighters Special Edition 2004 (The King of Fighters 2002 bootleg)" \
["kof94"]="The King of Fighters '94" \
["kof95"]="The King of Fighters '95" \
["kof95a"]="The King of Fighters '95 (NGM-084, alt board)" \
["kof95h"]="The King of Fighters '95 (NGH-084)" \
["kof96"]="The King of Fighters '96" \
["kof96h"]="The King of Fighters '96 (NGH-214)" \
["kof97"]="The King of Fighters '97" \
["kof97h"]="The King of Fighters '97 (NGH-2320)" \
["kof97k"]="The King of Fighters '97 (Korean release)" \
["kof97oro"]="The King of Fighters '97 Chongchu Jianghu Plus 2003 (bootleg)" \
["kof97pls"]="The King of Fighters '97 Plus (bootleg)" \
["kof98"]="The King of Fighters '98: The Slugfest" \
["kof98a"]="The King of Fighters '98: The Slugfest (NGM-2420, alt board)" \
["kof98h"]="The King of Fighters '98: The Slugfest (NGH-2420)" \
["kof98k"]="The King of Fighters '98: The Slugfest (Korean release)" \
["kof98ka"]="The King of Fighters '98: The Slugfest (Korean release, set 2)" \
["kof99"]="The King of Fighters '99: Millennium Battle" \
["kof99e"]="The King of Fighters '99: Millennium Battle (earlier release)" \
["kof99h"]="The King of Fighters '99: Millennium Battle (NGH-2510)" \
["kof99k"]="The King of Fighters '99: Millennium Battle (Korean release)" \
["kof99p"]="The King of Fighters '99: Millennium Battle (prototype)" \
["kof2000"]="The King of Fighters 2000" \
["kof2000n"]="The King of Fighters 2000" \
["kof2001"]="The King of Fighters 2001" \
["kof2001h"]="The King of Fighters 2001 (NGH-2621)" \
["kof2002"]="The King of Fighters 2002" \
["kof2002b"]="The King of Fighters 2002 (bootleg)" \
["kof2003"]="The King of Fighters 2003" \
["kof2003h"]="The King of Fighters 2003 (NGH-2710)" \
["kof2003ps2"]="The King of Fighters 2003 (PS2)" \
["kog"]="King of Gladiators (The King of Fighters '97 bootleg)" \
["kotm"]="King of the Monsters" \
["kotm2"]="King of the Monsters 2: The Next Thing" \
["kotm2p"]="King of the Monsters 2: The Next Thing (prototype)" \
["kotmh"]="King of the Monsters (set 2)" \
["lans2004"]="Lansquenet" \
["lastblad"]="The Last Blade" \
["lastbladh"]="The Last Blade (NGH-2340)" \
["lastbld2"]="The Last Blade 2" \
["lasthope"]="Last Hope" \
["lastsold"]="The Last Soldier" \
["lbowling"]="League Bowling" \
["legendos"]="Legend of Success Joe" \
["lresort"]="Last Resort" \
["lresortp"]="Last Resort (prototype)" \
["lstbladh"]="Last Blade (NGH-2340)" \
["magdrop2"]="Magical Drop II" \
["magdrop3"]="Magical Drop III" \
["maglord"]="Magician Lord" \
["maglordh"]="Magician Lord (NGH-005)" \
["mahretsu"]="Mahjong Kyo Retsuden" \
["marukodq"]="Chibi Marukochan Deluxe Quiz" \
["matrim"]="Power Instinct Matrimelee" \
["miexchng"]="Money Puzzle Exchanger" \
["minasan"]="Minasan no Okagesamadesu! Dai Sugoroku Taikai" \
["montest"]="Monitor Test ROM" \
["moshougi"]="Shougi no Tatsujin: Master of Syougi" \
["ms4plus"]="Metal Slug 4 Plus (bootleg)" \
["mslug"]="Metal Slug: Super Vehicle-001" \
["mslug2"]="Metal Slug 2: Super Vehicle-001/II" \
["mslug2t"]="Metal Slug 2 Turbo (hack)" \
["mslug3"]="Metal Slug 3" \
["mslug3b6"]="Metal Slug 6 (Metal Slug 3 bootleg)" \
["mslug3h"]="Metal Slug 3 (NGH-2560)" \
["mslug4"]="Metal Slug 4" \
["mslug4h"]="Metal Slug 4 (NGH-2630)" \
["mslug5"]="Metal Slug 5" \
["mslug5h"]="Metal Slug 5 (NGH-2680)" \
["mslug6"]="Metal Slug 6 (Metal Slug 3 bootleg)" \
["mslugx"]="Metal Slug X: Super Vehicle-001" \
["mutnat"]="Mutation Nation" \
["nam1975"]="NAM-1975" \
["nblktigr"]="Neo Black Tiger" \
["ncombat"]="Ninja Combat" \
["ncombath"]="Ninja Combat (NGH-009)" \
["ncommand"]="Ninja Commando" \
["neobombe"]="Neo Bomberman" \
["neocup98"]="Neo-Geo Cup 98: The Road to the Victory" \
["neodrift"]="Neo Drift Out: New Technology" \
["neofight"]="Neo Fight" \
["neomrdo"]="Neo Mr. Do!" \
["neothund"]="Neo Thunder" \
["neotris"]="NeoTRIS (free beta version)" \
["ninjamas"]="Ninja Master's" \
["nitd"]="Nightmare in the Dark" \
["nitdbl"]="Nightmare in the Dark (bootleg)" \
["nsmb"]="New Super Mario Bros." \
["overtop"]="OverTop" \
["panicbom"]="Panic Bomber" \
["pbbblenb"]="Puzzle Bobble (bootleg)" \
["pbobbl2n"]="Puzzle Bobble 2" \
["pbobblen"]="Puzzle Bobble" \
["pbobblenb"]="Puzzle Bobble (bootleg)" \
["pgoal"]="Pleasure Goal" \
["pnyaa"]="Pochi and Nyaa" \
["popbounc"]="Pop 'n Bounce" \
["preisle2"]="Prehistoric Isle 2" \
["pspikes2"]="Power Spikes II" \
["pulstar"]="Pulstar" \
["puzzldpr"]="Puzzle De Pon! R!" \
["puzzledp"]="Puzzle De Pon!" \
["quizdai2"]="Quiz Meitantei Neo & Geo: Quiz Daisousa Sen part 2" \
["quizdais"]="Quiz Daisousa Sen: The Last Count Down" \
["quizdask"]="Quiz Salibtamjeong: The Last Count Down (Korean localized Quiz Daisousa Sen)" \
["quizkof"]="Quiz King of Fighters" \
["quizkofk"]="Quiz King of Fighters (Korean release)" \
["ragnagrd"]="Ragnagard" \
["rbff1"]="Real Bout Fatal Fury" \
["rbff1a"]="Real Bout Fatal Fury (bug fix revision)" \
["rbff2"]="Real Bout Fatal Fury 2: The Newcomers" \
["rbff2h"]="Real Bout Fatal Fury 2: The Newcomers (NGH-2400)" \
["rbff2k"]="Real Bout Fatal Fury 2: The Newcomers (Korean release)" \
["rbffspck"]="Real Bout Fatal Fury Special (Korean release)" \
["rbffspec"]="Real Bout Fatal Fury Special" \
["rbffspeck"]="Real Bout Fatal Fury Special (Korean release)" \
["ridhero"]="Riding Hero" \
["ridheroh"]="Riding Hero (set 2)" \
["roboarma"]="Robo Army (NGM-032 ~ NGH-032)" \
["roboarmy"]="Robo Army" \
["roboarmya"]="Robo Army (NGM-032 ~ NGH-032)" \
["rotd"]="Rage of the Dragons" \
["rotdh"]="Rage of the Dragons (NGH-2640?)" \
["s1945p"]="Strikers 1945 Plus" \
["samsh5fe"]="Samurai Shodown V Special Final Edition" \
["samsh5pf"]="Samurai Shodown V Perfect" \
["samsh5sp"]="Samurai Shodown V Special" \
["samsh5sph"]="Samurai Shodown V Special (2nd release, less censored)" \
["samsh5spho"]="altname=" \
["samsho"]="Samurai Shodown" \
["samsho2"]="Samurai Shodown II" \
["samsho2k"]="Saulabi Spirits (Korean release of Samurai Shodown II)" \
["samsho2ka"]="Saulabi Spirits (Korean release of Samurai Shodown II, set 2)" \
["samsho3"]="Samurai Shodown III" \
["samsho3h"]="Samurai Shodown III (NGH-087)" \
["samsho4"]="Samurai Shodown IV: Amakusa's Revenge" \
["samsho4k"]="Pae Wang Jeon Seol: Legend of a Warrior" \
["samsho5"]="Samurai Shodown V" \
["samsho5b"]="Samurai Shodown V (bootleg)" \
["samsho5h"]="Samurai Shodown V (NGH-2700)" \
["samsho5x"]="Samurai Shodown V (XBOX version hack)" \
["samshoh"]="Samurai Shodown (NGH-045)" \
["savagere"]="Savage Reign" \
["sbp"]="Super Bubble Pop" \
["scbrawlh"]="Soccer Brawl (NGH-031)" \
["sdodgeb"]="Super Dodge Ball" \
["sengoku"]="Sengoku" \
["sengoku2"]="Sengoku 2" \
["sengoku3"]="Sengoku 3" \
["sengokuh"]="Sengoku (NGH-017, US)" \
["shcktroa"]="Shock Troopers (set 2)" \
["shocktr2"]="Shock Troopers: 2nd Squad" \
["shocktro"]="Shock Troopers" \
["shocktroa"]="Shock Troopers (set 2)" \
["smbng"]="New Super Mario Bros. Demo" \
["smsh5sph"]="Samurai Shodown V Special (2nd release, less censored)" \
["smsh5spo"]="Samurai Shodown V Special (1st release, censored)" \
["smsho2k2"]="Saulabi Spirits (Korean release of Samurai Shodown II, set 2)" \
["socbrawl"]="Soccer Brawl" \
["socbrawlh"]="Soccer Brawl (NGH-031)" \
["sonicwi2"]="Aero Fighters 2" \
["sonicwi3"]="Aero Fighters 3" \
["spinmast"]="Spinmaster" \
["ssideki"]="Super Sidekicks" \
["ssideki2"]="Super Sidekicks 2: The World Championship" \
["ssideki3"]="Super Sidekicks 3: The Next Glory" \
["ssideki4"]="The Ultimate 11: The SNK Football Championship" \
["stakwin"]="Stakes Winner" \
["stakwin2"]="Stakes Winner 2" \
["strhoop"]="Street Hoop / Street Slam" \
["superspy"]="The Super Spy" \
["svc"]="SNK vs. Capcom: SVC Chaos" \
["svccpru"]="SNK vs. Capcom Remix Ultra" \
["svcplus"]="SNK vs. Capcom Plus (bootleg)" \
["svcsplus"]="SNK vs. Capcom Super Plus (bootleg)" \
["teot"]="The Eye of Typhoon: Tsunami Edition" \
["tetrismn"]="Tetris" \
["tophuntr"]="Top Hunter: Roddy & Cathy" \
["tophuntrh"]="Top Hunter: Roddy & Cathy (NGH-046)" \
["totc"]="Treasure of the Caribbean" \
["tpgolf"]="Top Player's Golf" \
["tphuntrh"]="Top Hunter: Roddy & Cathy (NGH-046)" \
["trally"]="Thrash Rally" \
["turfmast"]="Neo Turf Masters" \
["twinspri"]="Twinkle Star Sprites" \
["tws96"]="Tecmo World Soccer '96" \
["twsoc96"]="Tecmo World Soccer '96" \
["viewpoin"]="Viewpoint" \
["wakuwak7"]="Waku Waku 7" \
["wh1"]="World Heroes" \
["wh1h"]="World Heroes (ALH-005)" \
["wh1ha"]="World Heroes (set 3)" \
["wh2"]="World Heroes 2" \
["wh2j"]="World Heroes 2 Jet" \
["whp"]="World Heroes Perfect" \
["wjammers"]="Windjammers" \
["wjammss"]="Windjammers Supersonic" \
["xenocrisis"]="Xeno Crisis" \
["zedblade"]="Zed Blade" \
["zintrckb"]="ZinTricK" \
["zintrkcd"]="ZinTricK (CD conversion)" \
["zupapa"]="Zupapa!" \
)

# NEOGEO to long name mappings Japanese
declare -gA NEOGEO_PRETTY_JAPANESE=( \
["3countb"]="Fire Suplex" \
["2020bb"]="" \
["2020bba"]="" \
["2020bbh"]="" \
["abyssal"]="" \
["alpham2"]="ASO II: Last Guardian" \
["alpham2p"]="ASO II: Last Guardian (prototype)" \
["androdun"]="" \
["aodk"]="Tsuukai GANGAN Koushinkyoku" \
["aof"]="Ryuuko no Ken" \
["aof2"]="Ryuuko no Ken 2" \
["aof2a"]="Ryuuko no Ken 2 (NGH-056)" \
["aof3"]="Art of Fighting: Ryuuko no Ken Gaiden" \
["aof3k"]="" \
["b2b"]="" \
["badapple"]="" \
["bakatono"]="" \
["bangbead"]="" \
["bjourney"]="Raguy" \
["blazstar"]="" \
["breakers"]="" \
["breakrev"]="" \
["brningfh"]="" \
["brningfp"]="" \
["brnngfpa"]="" \
["bstars"]="" \
["bstars2"]="" \
["bstarsh"]="" \
["burningf"]="" \
["burningfh"]="" \
["burningfp"]="" \
["burningfpa"]="" \
["cabalng"]="" \
["columnsn"]="" \
["cphd"]="" \
["crswd2bl"]="" \
["crsword"]="" \
["ct2k3sa"]="" \
["ctomaday"]="" \
["cyberlip"]="" \
["diggerma"]="" \
["doubledr"]="" \
["eightman"]="" \
["fatfursp"]="Garou Densetsu Special" \
["fatfurspa"]="Garou Densetsu Special (NGM-058 ~ NGH-058, set 2)" \
["fatfury1"]="Garou Densetsu: Shukumei no Tatakai" \
["fatfury2"]="Garou Densetsu 2: Arata-naru Tatakai" \
["fatfury3"]="Garou Densetsu 3: Haruka-naru Tatakai" \
["fbfrenzy"]="" \
["fghtfeva"]="Wang Jung Wang (set 2)" \
["fightfev"]="Wang Jung Wang" \
["fightfeva"]="Wang Jung Wang (set 2)" \
["flipshot"]="" \
["frogfest"]="" \
["froman2b"]="" \
["fswords"]="" \
["ftfurspa"]="Garou Densetsu Special (NGM-058 ~ NGH-058, set 2)" \
["galaxyfg"]="" \
["ganryu"]="Musashi Ganryuki" \
["garou"]="" \
["garoubl"]="" \
["garouh"]="" \
["garoup"]="" \
["ghostlop"]="" \
["goalx3"]="" \
["gowcaizr"]="Choujin Gakuen Gowcaizer" \
["gpilots"]="" \
["gpilotsh"]="" \
["gururin"]="" \
["hyprnoid"]="" \
["irnclado"]="Choutetsu Brikin'ger (prototype, bootleg)" \
["ironclad"]="Choutetsu Brikin'ger" \
["ironclado"]="Choutetsu Brikin'ger (prototype, bootleg)" \
["irrmaze"]="Ultra Denryu Iraira Bou" \
["janshin"]="" \
["joyjoy"]="Joy Joy Kid" \
["kabukikl"]="Tengai Makyou: Shin Den" \
["karnovr"]="Fighter's History Dynamite" \
["kf2k2mp"]="" \
["kf2k2mp2"]="" \
["kf2k2pla"]="" \
["kf2k2pls"]="" \
["kf2k5uni"]="" \
["kf10thep"]="" \
["kizuna"]="Fu'un Super Tag Battle" \
["kof2k4se"]="" \
["kof94"]="" \
["kof95"]="" \
["kof95a"]="" \
["kof95h"]="" \
["kof96"]="" \
["kof96h"]="" \
["kof97"]="" \
["kof97h"]="" \
["kof97k"]="" \
["kof97oro"]="" \
["kof97pls"]="" \
["kof98"]="King of Fighters '98: Dream Match Never Ends" \
["kof98a"]="King of Fighters '98: Dream Match Never Ends (NGM-2420, alt board)" \
["kof98h"]="King of Fighters '98: Dream Match Never Ends (NGH-2420)" \
["kof98k"]="" \
["kof98ka"]="" \
["kof99"]="" \
["kof99e"]="" \
["kof99h"]="" \
["kof99k"]="" \
["kof99p"]="" \
["kof2000"]="" \
["kof2000n"]="" \
["kof2001"]="" \
["kof2001h"]="" \
["kof2002"]="" \
["kof2002b"]="" \
["kof2003"]="" \
["kof2003h"]="" \
["kof2003ps2"]="" \
["kog"]="" \
["kotm"]="" \
["kotm2"]="" \
["kotm2p"]="" \
["kotmh"]="" \
["lans2004"]="" \
["lastblad"]="Bakumatsu Roman: Gekka no Kenshi" \
["lastbladh"]="Bakumatsu Roman: Gekka no Kenshi (NGH-2340)" \
["lastbld2"]="Bakumatsu Roman: Dai Ni Maku Gekka no Kenshi" \
["lasthope"]="" \
["lastsold"]="" \
["lbowling"]="" \
["legendos"]="Ashita no Joe Densetsu" \
["lresort"]="" \
["lresortp"]="" \
["lstbladh"]="Bakumatsu Roman: Gekka no Kenshi (NGH-2340)" \
["magdrop2"]="Magical Drop 2" \
["magdrop3"]="" \
["maglord"]="" \
["maglordh"]="" \
["mahretsu"]="" \
["marukodq"]="" \
["matrim"]="Shin Goketsuji Ichizoku: Tokon Matrimelee" \
["miexchng"]="Money Idol Exchanger" \
["minasan"]="" \
["montest"]="" \
["moshougi"]="" \
["ms4plus"]="" \
["mslug"]="" \
["mslug2"]="" \
["mslug2t"]="" \
["mslug3"]="" \
["mslug3b6"]="" \
["mslug3h"]="" \
["mslug4"]="" \
["mslug4h"]="" \
["mslug5"]="" \
["mslug5h"]="" \
["mslug6"]="" \
["mslugx"]="" \
["mutnat"]="" \
["nam1975"]="" \
["nblktigr"]="" \
["ncombat"]="" \
["ncombath"]="" \
["ncommand"]="" \
["neobombe"]="" \
["neocup98"]="" \
["neodrift"]="" \
["neofight"]="" \
["neomrdo"]="" \
["neothund"]="" \
["neotris"]="" \
["ninjamas"]="Haoh-ninpo-cho" \
["nitd"]="" \
["nitdbl"]="" \
["nsmb"]="" \
["overtop"]="" \
["panicbom"]="" \
["pbbblenb"]="Bust-A-Move (bootleg)" \
["pbobbl2n"]="Bust-A-Move Again" \
["pbobblen"]="Bust-A-Move" \
["pbobblenb"]="Bust-A-Move (bootleg)" \
["pgoal"]="" \
["pnyaa"]="Pochi to Nyaa" \
["popbounc"]="Gapporin" \
["preisle2"]="" \
["pspikes2"]="" \
["pulstar"]="" \
["puzzldpr"]="" \
["puzzledp"]="" \
["quizdai2"]="" \
["quizdais"]="" \
["quizdask"]="" \
["quizkof"]="" \
["quizkofk"]="" \
["ragnagrd"]="Shin-Oh-Ken" \
["rbff1"]="Real Bout Garou Densetsu" \
["rbff1a"]="Real Bout Garou Densetsu (bug fix revision)" \
["rbff2"]="Real Bout Garou Densetsu 2: The Newcomers" \
["rbff2h"]="Real Bout Garou Densetsu 2: The Newcomers (NGH-2400)" \
["rbff2k"]="" \
["rbffspck"]="" \
["rbffspec"]="Real Bout Garou Densetsu Special" \
["rbffspeck"]="" \
["ridhero"]="" \
["ridheroh"]="" \
["roboarma"]="" \
["roboarmy"]="" \
["roboarmya"]="" \
["rotd"]="" \
["rotdh"]="" \
["s1945p"]="" \
["samsh5fe"]="Samurai Shodown Zero Special Final Edition" \
["samsh5pf"]="Samurai Spirits Zero Perfect" \
["samsh5sp"]="Samurai Spirits Zero Special" \
["samsh5sph"]="Samurai Spirits Zero Special (2nd release, less censored)" \
["samsh5spho"]=" altnamej=" \
["samsho"]="Samurai Spirits" \
["samsho2"]="Shin Samurai Spirits: Haohmaru Jigokuhen" \
["samsho2k"]="" \
["samsho2ka"]="" \
["samsho3"]="Samurai Spirits: Zankurou Musouken" \
["samsho3h"]="Samurai Spirits: Zankurou Musouken (NGH-087)" \
["samsho4"]="Samurai Spirits: Amakusa Kourin" \
["samsho4k"]="" \
["samsho5"]="Samurai Spirits Zero" \
["samsho5b"]="Samurai Spirits Zero (bootleg)" \
["samsho5h"]="Samurai Spirits Zero (NGH-2700)" \
["samsho5x"]="Samurai Spirits Zero (XBOX version hack)" \
["samshoh"]="Samurai Spirits (NGH-045)" \
["savagere"]="Fu'un Mokushiroku: Kakutou Sousei" \
["sbp"]="" \
["scbrawlh"]="" \
["sdodgeb"]="Kunio no Nekketsu Toukyuu Densetsu" \
["sengoku"]="Sengoku Denshou" \
["sengoku2"]="Sengoku Denshou 2" \
["sengoku3"]="Sengoku Denshou 2001" \
["sengokuh"]="Sengoku Denshou (NGH-017, US)" \
["shcktroa"]="" \
["shocktr2"]="" \
["shocktro"]="" \
["shocktroa"]="" \
["smbng"]="" \
["smsh5sph"]="Samurai Spirits Zero Special (2nd release, less censored)" \
["smsh5spo"]="Samurai Spirits Zero Special (1st release, censored)" \
["smsho2k2"]="" \
["socbrawl"]="" \
["socbrawlh"]="" \
["sonicwi2"]="Sonic Wings 2" \
["sonicwi3"]="Sonic Wings 3" \
["spinmast"]="Miracle Adventure" \
["ssideki"]="Tokuten Ou" \
["ssideki2"]="Tokuten Ou 2: Real Fight Football" \
["ssideki3"]="Tokuten Ou 3: Eikou e no Chousen" \
["ssideki4"]="Tokuten Ou: Honoo no Libero" \
["stakwin"]="Stakes Winner: GI Kinzen Seiha e no Michi" \
["stakwin2"]="" \
["strhoop"]="Dunk Dream" \
["superspy"]="" \
["svc"]="" \
["svccpru"]="" \
["svcplus"]="" \
["svcsplus"]="" \
["teot"]="" \
["tetrismn"]="" \
["tophuntr"]="" \
["tophuntrh"]="" \
["totc"]="" \
["tpgolf"]="" \
["tphuntrh"]="" \
["trally"]="" \
["turfmast"]="Big Tournament Golf" \
["twinspri"]="" \
["tws96"]="" \
["twsoc96"]="" \
["viewpoin"]="" \
["wakuwak7"]="" \
["wh1"]="" \
["wh1h"]="" \
["wh1ha"]="" \
["wh2"]="" \
["wh2j"]="" \
["whp"]="" \
["wjammers"]="Flying Power Disc" \
["wjammss"]="" \
["xenocrisis"]="" \
["zedblade"]="Operation Ragnarok" \
["zintrckb"]="Oshidashi Zentrix" \
["zintrkcd"]="Oshidashi Zentrix (CD conversion)" \
["zupapa"]="" \
)

}

#========= PARSE INI =========

#Make all cores available
corelistall="${corelist}"

# Read INI
if [ -f "${misterpath}/Scripts/MiSTer_SAM.ini" ]; then
	source "${misterpath}/Scripts/MiSTer_SAM.ini"
	# Remove trailing slash from paths
	for var in $(grep "^[^#;]" "${misterpath}/Scripts/MiSTer_SAM.ini" | grep "path=" | cut -f1 -d"="); do
		declare -g ${var}="${!var%/}"
	done
	for var in $(grep "^[^#;]" "${misterpath}/Scripts/MiSTer_SAM.ini" | grep "pathextra=" | cut -f1 -d"="); do
		declare -g ${var}="${!var%/}"
	done
	for var in $(grep "^[^#;]" "${misterpath}/Scripts/MiSTer_SAM.ini" | grep "pathrbf=" | cut -f1 -d"="); do
		declare -g ${var}="${!var%/}"
	done
fi

#Create folders if they don't exist
mkdir -p "${mrsampath}"/SAM_Count
mkdir -p "${mrsampath}"/SAM_Gamelists
mkdir -p /tmp/.SAM_List
touch ${tmpfile}
touch ${tmpfile2}


# Setup corelist
corelist="$(echo ${corelist} | tr ',' ' ')"
corelistall="$(echo ${corelistall} | tr ',' ' ')"

# Create array of coreexclude list names
declare -a coreexcludelist
for core in ${corelist}; do
	coreexcludelist+=( "${core}exclude" )
done

# Iterate through coreexclude lists and make list into array
for excludelist in ${coreexcludelist[@]}; do
	readarray -t ${excludelist} <<<${!excludelist}
done

# Create folder and file exclusion list
folderex=$(for f in "${exclude[@]}"; do echo "-o -iname *$f*" ; done)
fileex=$(for f in "${exclude[@]}"; do echo "-and -not -iname *$f*" ; done)

# Create file and folder exclusion list for zips. Always exclude BIOS files as a default
zipex=$(printf "%s," "${exclude[@]}" && echo "bios")


# Default rom path search directories
declare -ga GAMESDIR_FOLDERS=( \
/media/usb0/games \
/media/usb1/games \
/media/usb2/games \
/media/usb3/games \
/media/usb4/games \
/media/usb5/games \
/media/fat/cifs/games \
/media/fat/games \
/media/usb0 \
/media/usb1 \
/media/usb2 \
/media/usb3 \
/media/usb4 \
/media/usb5 \
/media/fat/cifs \
/media/fat \
)

function defaultpath() {
	local SYSTEM="${1}"
	local SYSTEM_ORG="${SYSTEM}"
	if [ ${SYSTEM} == "arcade" ]; then
		SYSTEM="_arcade"
	fi
	if [ ${SYSTEM} == "fds" ]; then
		SYSTEM="nes"
	fi
	
	if [ ${SYSTEM} == "gb" ]; then
		SYSTEM="gameboy"
	fi

	if [ ${SYSTEM} == "gbc" ]; then
		SYSTEM="gameboy"
	fi

	if [ ${SYSTEM} == "gg" ]; then
		SYSTEM="sms"
	fi

	if [ ${SYSTEM} == "tgfx16cd" ]; then
		SYSTEM="tgfx16-cd"
	fi

	shift
	
	GET_SYSTEM_FOLDER "${SYSTEM}"
	local SYSTEM_FOLDER="${GET_SYSTEM_FOLDER_RESULT}"
	local GAMESDIR="${GET_SYSTEM_FOLDER_GAMESDIR}"
	
	if [[ "${SYSTEM_FOLDER}" != "" ]]
	then
	   eval ${SYSTEM_ORG}"path"="${GAMESDIR}/${GET_SYSTEM_FOLDER_RESULT}"
	fi
}

GET_SYSTEM_FOLDER_GAMESDIR=
GET_SYSTEM_FOLDER_RESULT=
GET_SYSTEM_FOLDER() {
	GET_SYSTEM_FOLDER_GAMESDIR="/media/fat/games"
	GET_SYSTEM_FOLDER_RESULT=
	local SYSTEM="${1}"
	for folder in ${GAMESDIR_FOLDERS[@]}
	do
	local RESULT=$(find "${folder}" -maxdepth 1 -iname "${SYSTEM}" -printf "%P\n" -quit 2> /dev/null)
	if [[ "${RESULT}" != "" ]] ; then
	    GET_SYSTEM_FOLDER_GAMESDIR="${folder}"
	    GET_SYSTEM_FOLDER_RESULT="${RESULT}"
	    break
	fi
	done
}

if [ ${usedefaultpaths,,} == "yes" ]; then
	for core in ${corelist}; do
		defaultpath "${core}"
	done
fi




#======== SAM MENU ========
function sam_premenu() {
	echo "+---------------------------+"
	echo "| MiSTer Super Attract Mode |"
	echo "+---------------------------+"
	echo " SAM Configuration:"
	if [ $(grep -ic "mister_sam" ${userstartup}) != "0" ]; then
		echo " -SAM autoplay ENABLED"
	else
		echo " -SAM autoplay DISABLED"
	fi
	echo " -Start after ${samtimeout} sec. idle"
	echo " -Start only on the menu: ${menuonly^}"
	echo " -Show each game for ${gametimer} sec."
	echo ""
	echo " Press UP to open menu"
	echo " Press DOWN to start SAM"
	echo ""
	echo " Or wait for"
	echo " auto-configuration"
	echo ""

	for i in {5..1}; do
		echo -ne " Updating SAM in ${i}...\033[0K\r"
		premenu="Default"
		read -r -s -N 1 -t 1 key
		if [[ "${key}" == "A" ]]; then
			premenu="Menu"
			break
		elif [[ "${key}" == "B" ]]; then
			premenu="Start"
			break
		elif [[ "${key}" == "C" ]]; then
			premenu="Default"
			break
		fi
	done
	parse_cmd ${premenu}
}

function sam_menu() {
	inmenu=1
	dialog --clear --no-cancel --ascii-lines --no-tags \
	--backtitle "Super Attract Mode" --title "[ Main Menu ]" \
	--menu "Use the arrow keys and enter \nor the d-pad and A button" 0 0 0 \
	Start "Start SAM now" \
	Skip "Skip game" \
	Stop "Stop SAM" \
	Single "Games from only one core" \
	Favorite "Favorite Game. Copy current game to _Favorites folder" \
	Utility "Update and Monitor" \
	Config "Configure INI Settings" \
	Reset "Reset or uninstall SAM" \
	Autoplay "Autoplay Configuration" \
	Cancel "Exit now" 2>"/tmp/.SAMmenu"
	menuresponse=$(<"/tmp/.SAMmenu")
	clear

	if [ "${samquiet,,}" == "no" ]; then echo " menuresponse: ${menuresponse}"; fi
	parse_cmd ${menuresponse}
}

function sam_singlemenu() {
	declare -a menulist=()
	for core in ${corelistall}; do
		menulist+=( "${core^^}" )
		menulist+=( "${CORE_PRETTY[${core,,}]} games only" )
	done

	dialog --clear --no-cancel --ascii-lines --no-tags \
	--backtitle "Super Attract Mode" --title "[ Single System Select ]" \
	--menu "Which system?" 0 0 0 \
	"${menulist[@]}" \
	Back 'Previous menu' 2>"/tmp/.SAMmenu"
	menuresponse=$(<"/tmp/.SAMmenu")
	clear

	if [ "${samquiet,,}" == "no" ]; then echo " menuresponse: ${menuresponse}"; fi
	parse_cmd ${menuresponse}
}

function sam_utilitymenu() {
	dialog --clear --no-cancel --ascii-lines --no-tags \
	--backtitle "Super Attract Mode" --title "[ Utilities ]" \
	--menu "Select an option" 0 0 0 \
	Update "Update SAM to latest" \
	Monitor "Display messages (ssh only)" \
	Back 'Previous menu' 2>"/tmp/.SAMmenu"
	menuresponse=$(<"/tmp/.SAMmenu")
	clear

	if [ "${samquiet,,}" == "no" ]; then echo " menuresponse: ${menuresponse}"; fi
	parse_cmd ${menuresponse}
}

function sam_resetmenu() {
	inmenu=1
	dialog --clear --no-cancel --ascii-lines --no-tags \
	--backtitle "Super Attract Mode" --title "[ Reset ]" \
	--menu "Select an option" 0 0 0 \
	Deleteall "Reset/Delete all files" \
	DeleteGL "Delete Gamelists only" \
	Default "Reinstall SAM and enable Autostart" \
	Back 'Previous menu' 2>"/tmp/.SAMmenu"
	menuresponse=$(<"/tmp/.SAMmenu")
	clear

	if [ "${samquiet,,}" == "no" ]; then echo " menuresponse: ${menuresponse}"; fi
	parse_cmd ${menuresponse}
}

function sam_autoplaymenu() {
	dialog --clear --no-cancel --ascii-lines --no-tags \
	--backtitle "Super Attract Mode" --title "[ Configure Autoplay ]" \
	--menu "Select an option" 0 0 0 \
	Enable "Enable Autoplay" \
	Disable "Disable Autoplay" \
	Back 'Previous menu' 2>"/tmp/.SAMmenu"
	menuresponse=$(<"/tmp/.SAMmenu")

	clear
	if [ "${samquiet,,}" == "no" ]; then echo " menuresponse: ${menuresponse}"; fi
	parse_cmd ${menuresponse}
}

function sam_configmenu() {
	dialog --clear --ascii-lines --no-cancel \
	--backtitle "Super Attract Mode" --title "[ INI Settings ]" \
	--msgbox "Here you can configure the INI settings for SAM.\n\nUse TAB to switch between editing, the OK and Cancel buttons." 0 0

	dialog --clear --ascii-lines \
	--backtitle "Super Attract Mode" --title "[ INI Settings ]" \
	--editbox "${misterpath}/Scripts/MiSTer_SAM.ini" 0 0 2>"/tmp/.SAMmenu"

	if [ -s "/tmp/.SAMmenu" ] && [ "$(diff -wq "/tmp/.SAMmenu" "${misterpath}/Scripts/MiSTer_SAM.ini")" ]; then
		cp -f "/tmp/.SAMmenu" "${misterpath}/Scripts/MiSTer_SAM.ini"
		dialog --clear --ascii-lines --no-cancel \
		--backtitle "Super Attract Mode" --title "[ INI Settings ]" \
		--msgbox "Changes saved!" 0 0
	fi

	parse_cmd menu
}

function parse_cmd() {
	if [ ${#} -gt 2 ]; then # We don't accept more than 2 parameters
		sam_help
	elif [ ${#} -eq 0 ]; then # No options - show the pre-menu
		sam_premenu
	else
		# If we're given a core name then we need to set it first
		nextcore=""
		for arg in ${@}; do
			case ${arg,,} in
				arcade | fds | gb | gbc | gba | genesis | gg | megacd | neogeo | nes | s32x | sms | snes | tgfx16 | tgfx16cd | psx)
				echo " ${CORE_PRETTY[${arg,,}]} selected!"
				nextcore="${arg,,}"
				;;
			esac
		done

		# If the one command was a core then we need to call in again with "start" specified
		if [ ${nextcore,,} ] && [ ${#} -eq 1 ]; then
			# Move cursor up a line to avoid duplicate message
			echo -n -e "\033[A"
			# Re-enter this function with start added
			parse_cmd ${nextcore,,} start
			return
		fi

		while [ ${#} -gt 0 ]; do
			case ${1,,} in
				default) # Default is split because sam_update relaunches itself
					sam_update autoconfig
					break
					;;
				autoconfig)
					tmux kill-session -t MCP &>/dev/null
					there_can_be_only_one
					sam_update
					mcp_start
					sam_enable
					break
					;;
				bootstart) # Start as from init
					env_check ${1,,}
					mcp_start
					echo " Starting SAM in the background."
					#tmux new-session -x 180 -y 40 -n "-= SAM Monitor -- Detach with ctrl-b d  =-" -s SAM -d ${misterpath}/Scripts/MiSTer_SAM_on.sh bootstart_real
					break
					;;
				start | restart) # Start as a detached tmux session for monitoring
					env_check ${1,,}
					# Terminate any other running SAM processes
					there_can_be_only_one
					mcp_start
					echo " Starting SAM in the background."
					tmux new-session -x 180 -y 40 -n "-= SAM Monitor -- Detach with ctrl-b d  =-" -s SAM -d  ${misterpath}/Scripts/MiSTer_SAM_on.sh start_real ${nextcore,,}
					break
					;;
				start_real) # Start SAM immediately
					env_check ${1,,}
                    tty_init
					loop_core ${nextcore,,}
					break
					;;
				skip | next) # Load next game - stops monitor
					echo " Skipping to next game..."
					tmux send-keys -t SAM C-c ENTER
					#break
					;;
				stop) # Stop SAM immediately
					sam_stop
					tty_exit
					if [ "${mute,,}" == "yes" ]; then echo -e "\0000\c" > /media/fat/config/Volume.dat; fi
					echo " Thanks for playing!"
					if [ "${mute,,}" == "yes" ]; then echo "load_core /media/fat/menu.rbf" > /dev/MiSTer_cmd; fi
					exit
					break
					;;
				update) # Update SAM
					sam_update
					break
					;;
				enable) # Enable SAM autoplay mode
					env_check ${1,,}
					sam_enable
					break
					;;
				disable) # Disable SAM autoplay
					sam_disable
					break
					;;
				monitor) # Warn user of changes
					sam_monitor_new
					break
					;;
				arcade | fds | gb | gbc | gba | genesis | gg | megacd | neogeo | nes | s32x | sms | snes | tgfx16 | tgfx16cd | psx)
					: # Placeholder since we parsed these above
					;;
				single)
					sam_singlemenu
					break
					;;
				utility)
					sam_utilitymenu
					break
					;;
				autoplay)
					sam_autoplaymenu
					break
					;;
				favorite)
					mglfavorite
					break
					;;
				reset)
					sam_resetmenu
					break
					;;
				config)
					sam_configmenu
					break
					;;
				back)
					sam_menu
					break
					;;
				menu)			
					sam_menu
					break
					;;
				cancel) # Exit
					echo " It's pitch dark; You are likely to be eaten by a Grue."
					inmenu=0
					break
					;;
				deleteall)
					deleteall
					break
					;;
				deletegl)
					deletegl
					break
					;;
				help)
					sam_help
					break
					;;
				*)
					echo " ERROR! ${1} is unknown."
					echo " Try $(basename -- ${0}) help"
					echo " Or check the Github readme."
					break
					;;
			esac
			shift
		done
	fi
}


#======== SAM COMMANDS ========
function mcp_start() {

	# If the MCP isn't running we need to start it in monitoring only mode
	if [ -z "$(pidof MiSTer_SAM_MCP)" ]; then
		#${mrsampath}/MiSTer_SAM_MCP monitoronly &
		tmux new-session -s MCP -d ${mrsampath}/MiSTer_SAM_MCP 
	fi

}

function sam_update() { # sam_update (next command)
	# Ensure the MiSTer SAM data directory exists
	mkdir --parents "${mrsampath}" &>/dev/null


	if [ ! "$(dirname -- ${0})" == "/tmp" ]; then
		# Warn if using non-default branch for updates
		if [ ! "${branch}" == "main" ]; then
			echo ""
			echo "*******************************"
			echo " Updating from ${branch}"
			echo "*******************************"
			echo ""
		fi

		# Download the newest MiSTer_SAM_on.sh to /tmp
		get_samstuff MiSTer_SAM_on.sh /tmp
		if [ -f /tmp/MiSTer_SAM_on.sh ]; then
			if [ ${1} ]; then
				echo " Continuing setup with latest MiSTer_SAM_on.sh..."
				/tmp/MiSTer_SAM_on.sh ${1}
				exit 0
			else
				echo " Launching latest"
				echo " MiSTer_SAM_on.sh..."
				/tmp/MiSTer_SAM_on.sh update
			exit 0
			fi
		else
			# /tmp/MiSTer_SAM_on.sh isn't there!
	  	echo " SAM update FAILED"
	  	echo " No Internet?"
	  	exit 1
		fi
	else # We're running from /tmp - download dependencies and proceed
		cp --force "/tmp/MiSTer_SAM_on.sh" "/media/fat/Scripts/MiSTer_SAM_on.sh"

		get_partun
		get_mbc
		get_inputmap
		get_samstuff .MiSTer_SAM/MiSTer_SAM_init
		get_samstuff .MiSTer_SAM/MiSTer_SAM_MCP
		get_samstuff .MiSTer_SAM/MiSTer_SAM_joy.py
		get_samstuff .MiSTer_SAM/MiSTer_SAM_keyboard.py
		get_samstuff .MiSTer_SAM/MiSTer_SAM_mouse.py
		get_samstuff MiSTer_SAM_off.sh /media/fat/Scripts

		if [ -f /media/fat/Scripts/MiSTer_SAM.ini ]; then
			echo " MiSTer SAM INI already exists... Merging with new ini."
			get_samstuff MiSTer_SAM.ini /tmp
			echo " Backing up MiSTer_SAM.ini to MiSTer_SAM.ini.bak"
			cp /media/fat/Scripts/MiSTer_SAM.ini /media/fat/Scripts/MiSTer_SAM.ini.bak 
			echo -n " Merging ini values.."
			# In order for the following awk script to replace variable values, we need to change our ASCII art from "=" to "-"
			sed -i 's/==/--/g' /media/fat/Scripts/MiSTer_SAM.ini
			sed -i 's/-=/--/g' /media/fat/Scripts/MiSTer_SAM.ini
			awk -F= 'NR==FNR{a[$1]=$0;next}($1 in a){$0=a[$1]}1' /media/fat/Scripts/MiSTer_SAM.ini /tmp/MiSTer_SAM.ini > ${tmpfile} && mv --force ${tmpfile} /media/fat/Scripts/MiSTer_SAM.ini
			echo "Done."
			
		else
			get_samstuff MiSTer_SAM.ini /media/fat/Scripts
		fi
		
	fi

	echo " Update complete!"
	return
}

function sam_enable() { # Enable autoplay
	echo -n " Enabling MiSTer SAM Autoplay..."

	# Awaken daemon
	# Check for and delete old fashioned scripts to prefer /media/fat/linux/user-startup.sh
	# (https://misterfpga.org/viewtopic.php?p=32159#p32159)

	if [ -f /etc/init.d/S93mistersam ] || [ -f /etc/init.d/_S93mistersam ]; then
		mount | grep "on / .*[(,]ro[,$]" -q && RO_ROOT="true"
		[ "$RO_ROOT" == "true" ] && mount / -o remount,rw
		sync
		rm /etc/init.d/S93mistersam &>/dev/null
		rm /etc/init.d/_S93mistersam &>/dev/null
		sync
		[ "$RO_ROOT" == "true" ] && mount / -o remount,ro
	fi


	# Add new startup way
	if [ ! -e ${userstartup} ] && [ -e /etc/init.d/S99user ]; then
	  if [ -e ${userstartuptpl} ]; then
		echo "Copying ${userstartuptpl} to ${userstartup}"
		cp ${userstartuptpl} ${userstartup}
	  else
		echo "Building ${userstartup}"
	  fi
	fi
	if [ $(grep -ic "mister_sam" ${userstartup}) = "0" ]; then
	  echo -e "Add MiSTer SAM to ${userstartup}\n"
	  echo -e "\n# Startup Super Attract Mode" >> ${userstartup}
	  echo -e "[[ -e ${mrsampath}/MiSTer_SAM_init ]] && ${mrsampath}/MiSTer_SAM_init \$1" >> ${userstartup}
	fi

	echo -e " \n\n SAM install complete."
        echo -ne " \n SAM will start after ${samtimeout} sec. idle"
        if [ ${menuonly,,} == "yes" ]; then
                echo -n " in the main menu"
        else
                echo -n " whenever controller is not in use"
        fi
        echo " and show each game for ${gametimer} sec."
        echo -e " \n SAM will begin shuffle now..."
	sleep 5
	echo -e " \n SAM will begin shuffle now... please wait."


		${misterpath}/Scripts/MiSTer_SAM_on.sh start

	exit
}

function sam_disable() { # Disable autoplay

	echo -n " Disabling SAM autoplay..."
	# Clean out existing processes to ensure we can update

	if [ -f /etc/init.d/S93mistersam ] || [ -f /etc/init.d/_S93mistersam ]; then
		mount | grep "on / .*[(,]ro[,$]" -q && RO_ROOT="true"
		[ "$RO_ROOT" == "true" ] && mount / -o remount,rw
		sync
		rm /etc/init.d/S93mistersam &>/dev/null
		rm /etc/init.d/_S93mistersam &>/dev/null
		sync
		[ "$RO_ROOT" == "true" ] && mount / -o remount,ro
	fi

	there_can_be_only_one
	sed -i '/MiSTer_SAM/d' ${userstartup}
	sync
	unmute
	echo " Done!"
}

function sam_help() { # sam_help
	echo " start - start immediately"
	echo " skip - skip to the next game"
	echo " stop - stop immediately"
	echo ""
	echo " update - self-update"
	echo " monitor - monitor SAM output"
	echo ""
	echo " enable - enable autoplay"
	echo " disable - disable autoplay"
	echo ""
	echo " menu - load to menu"
	echo ""
	echo " arcade, genesis, gba..."
	echo " games from one system only"
	exit 2
}

#======== UTILITY FUNCTIONS ========
function there_can_be_only_one() { # there_can_be_only_one
	# If another attract process is running kill it
	# This can happen if the script is started multiple times
	echo -n " Stopping other running instances of ${samprocess}..."
	
	#Delete temp lists
	rm -rf /tmp/.SAM_List &> /dev/null


	kill_2=$(ps -o pid,args | grep '[M]iSTer_SAM_on.sh start_real' | awk '{print $1}' | head -1)
	kill_3=$(ps -o pid,args | grep '[M]iSTer_SAM_on.sh bootstart_real' | awk '{print $1}' | head -1)

	[[ ! -z ${kill_2} ]] && kill -9 ${kill_2} >/dev/null
	[[ ! -z ${kill_3} ]] && kill -9 ${kill_3} >/dev/null

	sleep 1

	echo " Done!"
}


function sam_stop() { # there_can_be_only_one
	# If another attract process is running kill it
	# This can happen if the script is started multiple times
	echo -n " Stopping other running instances of ${samprocess}..."
	
	#Delete temp lists
	rm -rf /tmp/.SAM_List &> /dev/null

	kill_1=$(ps -o pid,args | grep '[M]CP' | awk '{print $1}' | head -1)
	kill_2=$(ps -o pid,args | grep '[M]iSTer_SAM_on.sh start_real' | awk '{print $1}' | head -1)
	kill_3=$(ps -o pid,args | grep '[M]iSTer_SAM_on.sh bootstart_real' | awk '{print $1}' | head -1)
	kill_4=$(ps -o pid,args | grep '[i]notifywait.*SAM' | awk '{print $1}' | head -1)

	[[ ! -z ${kill_1} ]] && tmux kill-session -t MCP >/dev/null
	[[ ! -z ${kill_2} ]] && kill -9 ${kill_2} >/dev/null
	[[ ! -z ${kill_3} ]] && kill -9 ${kill_3} >/dev/null
	#[[ ! -z ${kill_4} ]] && kill -9 ${kill_4} >/dev/null

	sleep 1

	echo " Done!"
	exit
}

function env_check() {
	# Check if we've been installed
	if [ ! -f "${mrsampath}/partun" ] || [ ! -f "${mrsampath}/MiSTer_SAM_MCP" ]; then
		echo " SAM required files not found."
		echo " Surprised? Check your INI."
		sam_update ${1}
		echo " Setup complete."
	fi
}

function deleteall() {
	# In case of issues, reset SAM

	there_can_be_only_one
	if [ -d "${mrsampath}" ]; then
		echo "Deleting MiSTer_SAM folder"
		rm -rf "${mrsampath}"
	fi
	if [ -f "/media/fat/Scripts/MiSTer_SAM.ini" ]; then
		echo "Deleting MiSTer_SAM.ini"
		cp /media/fat/Scripts/MiSTer_SAM.ini /media/fat/Scripts/MiSTer_SAM.ini.bak
		rm /media/fat/Scripts/MiSTer_SAM.ini
	fi
	if [ -f "/media/fat/Scripts/MiSTer_SAM_off.sh" ]; then
		echo "Deleting MiSTer_SAM_off.sh"
		rm /media/fat/Scripts/MiSTer_SAM_off.sh
	fi

	if [ -d "/media/fat/Scripts/SAM_Gamelists" ]; then
		echo "Deleting Gamelist folder"
		rm -rf "/media/fat/Scripts/SAM_Gamelists"
	fi

	if ls /media/fat/Config/inputs/*_input_1234_5678_v3.map 1> /dev/null 2>&1; then
		echo "Deleting Keyboard mapping files"
		rm /media/fat/Config/inputs/*_input_1234_5678_v3.map
	fi
	# Remount root as read-write if read-only so we can remove daemon
	mount | grep "on / .*[(,]ro[,$]" -q && RO_ROOT="true"
	[ "$RO_ROOT" == "true" ] && mount / -o remount,rw

	# Delete daemon
	echo "Deleting Auto boot Daemon..."
	if [ -f /etc/init.d/S93mistersam ] || [ -f /etc/init.d/_S93mistersam ]; then
		mount | grep "on / .*[(,]ro[,$]" -q && RO_ROOT="true"
		[ "$RO_ROOT" == "true" ] && mount / -o remount,rw
		sync
		rm /etc/init.d/S93mistersam &>/dev/null
		rm /etc/init.d/_S93mistersam &>/dev/null
		sync
		[ "$RO_ROOT" == "true" ] && mount / -o remount,ro
	fi
	echo "Done."

	sed -i '/MiSTer_SAM/d' ${userstartup}
	sed -i '/Super Attract/d' ${userstartup}

	printf "\n\n\n\n\n\nAll files deleted except for MiSTer_SAM_on.sh\n\n\n\n\n\n"
	if [ "${inmenu}" == 1 ]; then
		sleep 1
		sam_resetmenu
	else
		printf "\n\n\n\n\n\nGamelist reset successful. Please start SAM now.\n\n\n\n\n\n"
		sleep 1
		parse_cmd stop
	fi
}

function deletegl() {
	# In case of issues, reset game lists

	there_can_be_only_one
	if [ -d "${mrsampath}/SAM_Gamelists" ]; then
		echo "Deleting MiSTer_SAM Gamelist folder"
		rm -rf "${mrsampath}/SAM_Gamelists"
	fi

	if [ -d "${mrsampath}/SAM_Count" ]; then
		rm -rf "${mrsampath}/SAM_Count"
	fi
	if [ -d /tmp/.SAM_List ]; then
		rm -rf /tmp/.SAM_List
	fi

	if [ "${inmenu}" == 1 ]; then
		sleep 1
		sam_menu
	else
		printf "\n\n\n\n\n\nGamelist reset successful. Please start SAM now.\n\n\n\n\n\n"
		sleep 1
		parse_cmd stop
	fi
}

function skipmessage() {
	#Skip past bios/safety warnings

			sleep 3 && "${mrsampath}"/mbc raw_seq :31
}

function mglfavorite() {
	#Add current game to _Favorites folder

	if [ ! -d "${misterpath}"/_Favorites ]; then
		mkdir "${misterpath}"/_Favorites
	fi
	cp /tmp/SAM_game.mgl "${misterpath}"/_Favorites/"$(cat /tmp/SAM_Game.txt)".mgl

}

#======== tty2oled FUNCTIONS ========


function tty_init() { # tty_init

	if [ "${ttyenable,,}" == "yes" ]; then
		# tty2oled initialization
		
		if [ "${samquiet,,}" == "no" ]; then echo " Init tty2oled, loading variables... "; fi
		source ${ttysystemini}
		source ${ttyuserini}
		ttydevice=${TTYDEV}
		ttypicture=${picturefolder}
		ttypicture_pri=${picturefolder_pri}

		# Clear Serial input buffer first
		if [ "${samquiet,,}" == "no" ]; then echo -n " Clear tty2oled Serial Input Buffer..."; fi
		while read -t 0 sdummy < ${ttydevice}; do continue; done
		if [ "${samquiet,,}" == "no" ]; then echo " Done!"; fi
		#sleep 2

		# Stopping ScreenSaver
		if [ "${samquiet,,}" == "no" ]; then echo -n " Stopping tty2oled ScreenSaver..."; fi
		echo "CMDSAVER,0,0,0" > ${ttydevice}
		tty_waitfor
		if [ "${samquiet,,}" == "no" ]; then echo " Done!"; fi
		#sleep 2

		# Stopping tty2oled Daemon
		if [ "${ttyuseack,,}" == "yes" ]; then
			if [ "${samquiet,,}" == "no" ]; then echo -n " Stopping tty2oled Daemon..."; fi
			/media/fat/tty2oled/S60tty2oled stop
			if [ "${samquiet,,}" == "no" ]; then echo " Done!"; fi
		fi
		#sleep 2

		# Small loop for Welcome...
		for l in {1..3}; do
			echo "CMDCLS" > ${ttydevice}
			tty_waitfor
			sleep 0.2
			echo "CMDTXT,1,15,0,0,9, Welcome to..." > ${ttydevice}
			tty_waitfor
			sleep 0.2
		done
		sleep 1
		echo "CMDTXT,3,15,0,47,27, Super" > ${ttydevice}
		tty_waitfor
		sleep 0.8
		echo "CMDTXT,3,15,0,97,45, Attract" > ${ttydevice}
		tty_waitfor
		sleep 0.8
		echo "CMDTXT,3,15,0,153,63, Mode!" > ${ttydevice}
		tty_waitfor
		sleep 1
	fi
	
}

function tty_waitfor() {
  if [ "${ttyuseack,,}" == "yes" ]; then
    read -d ";" ttyresponse < ${ttydevice}                # The "read" command at this position simulates an "do..while" loop
    while [ "${ttyresponse}" != "ttyack" ]; do
      read -d ";" ttyresponse < ${ttydevice}              # Read Serial Line until delimiter ";"
    done
    #echo -e "${fgreen}${ttyresponse}${freset}"
    ttyresponse=""
  else
    #if [ "${samquiet,,}" == "no" ]; then echo -n "Little sleep... "; fi
    #sleep 0.2
    #sleep 0.1
    sleep 0.05
  fi
}

function tty_update() { # tty_update core game
	if [ "${ttyenable,,}" == "yes" ]; then

		# Wait for tty2oled daemon to show the core logo
		if [ "${ttyuseack,,}" != "yes" ]; then
			inotifywait -q -e modify /tmp/CORENAME &>/dev/null
		fi

		# Wait for tty2oled to show the core logo
		if [ "${samdebug,,}" == "yes" ]; then
			echo "-------------------------------------------"
			echo " tty_update got Corename: ${3} "
		fi
		if [ "${ttyuseack,,}" == "yes" ]; then
			tty_senddata "${3}"
		fi
		tty_waitfor
		# Show Core-Logo for 7 Secs
		sleep 7
		# Clear Display	with Random effect
		echo "CMDCLST,-1,0" > "${ttydevice}"
		tty_waitfor
		#sleep 0.5

		# Split long lines - length is approximate since fonts are variable width!

		if [ ${#2} -gt 23 ]; then
			for l in {1..15}; do
				echo "CMDTXT,103,${l},0,0,20,${2:0:20}..." > ${ttydevice}
				tty_waitfor
				echo "CMDTXT,103,${l},0,0,40, ${2:20}" > ${ttydevice}
				tty_waitfor
				echo "CMDTXT,2,$(( ${l}/3 )),0,0,60,${1}" > ${ttydevice}
				tty_waitfor
				sleep 0.05
			done
		else
			for l in {1..15}; do
				echo "CMDTXT,103,${l},0,0,20,${2}" > ${ttydevice}
				tty_waitfor
				echo "CMDTXT,2,$(( ${l}/3 )),0,0,60,${1}" > ${ttydevice}
				tty_waitfor
				sleep 0.05
			done


		fi
	fi
}

# USB Send-Picture-Data function
function tty_senddata() {
  newcore="${1}"
  unset picfnam
  if [ -e "${ttypicture_pri}/${newcore}.gsc" ]; then			# Check for _pri pictures
	picfnam="${ttypicture_pri}/${newcore}.gsc"
  elif [ -e "${ttypicture_pri}/${newcore}.xbm" ]; then
    picfnam="${ttypicture_pri}/${newcore}.xbm"
  else
    picfolders="gsc_us xbm_us gsc xbm xbm_text"				# If no _pri picture found, try all the others
    [ "${USE_US_PICTURE}" = "no" ] && picfolders="${picfolders//gsc_us xbm_us/}"
    [ "${USE_GSC_PICTURE}" = "no" ] && picfolders="${picfolders//gsc_us/}" && picfolders="${picfolders//gsc/}"
    [ "${USE_TEXT_PICTURE}" = "no" ] && picfolders="${picfolders//xbm_text/}"
    for picfolder in ${picfolders}; do
      for (( c="${#newcore}"; c>=1; c-- )); do					# Manipulate string...
        picfnam="${ttypicture}/${picfolder^^}/${newcore:0:$c}.${picfolder:0:3}"	# ...until it matches something
	    [ -e "${picfnam}" ] && break
      done
	  [ -e "${picfnam}" ] && break
    done
  fi
  if [ -e "${picfnam}" ]; then							# Exist?
	# For testing...
	if [ "${samdebug,,}" == "yes" ]; then
		echo "-------------------------------------------"
		echo " tty2oled sending Corename: ${1} "
		echo " tty2oled found/send Picture : ${picfnam} "
		echo "-------------------------------------------"
	fi
    echo "CMDCOR,${1}" > "${ttydevice}"					# Send CORECHANGE" Command and Corename
    sleep 0.02											# sleep needed here ?!
    tail -n +4 "${picfnam}" | xxd -r -p > ${ttydevice}	# The Magic, send the Picture-Data up from Line 4 and proces
  else													# No Picture available!
    echo "${1}" > "${ttydevice}"							# Send just the CORENAME
  fi													# End if Picture check
}

function tty_exit() { # tty_exit
	if [ "${ttyenable,,}" == "yes" ]; then
		# Clear Display	with Random effect
		echo "CMDCLST,-1,0" > ${ttydevice}
		tty_waitfor
		sleep 1
		# Show GAME OVER! for 3 secs
		#echo "CMDTXT,5,15,0,15,45,GAME OVER!" > ${ttydevice}
		#tty_waitfor
		#sleep 3
		#Set CORENAME for tty2oled Daemon start
		echo "MENU" > /tmp/CORENAME
		# Starting tty2oled daemon only if needed
		if [ "${ttyuseack,,}" == "yes" ]; then
		
			echo -n " Starting tty2oled daemon..."
			/media/fat/tty2oled/S60tty2oled start
			echo " Done!"
			#sleep 2
		fi
	fi
}

#======== DOWNLOAD FUNCTIONS ========
function curl_download() { # curl_download ${filepath} ${URL}

		curl \
			--connect-timeout 15 --max-time 600 --retry 3 --retry-delay 5 --silent --show-error \
			--insecure \
			--fail \
			--location \
			-o "${1}" \
			"${2}"
}


#======== UPDATER FUNCTIONS ========
function get_samstuff() { #get_samstuff file (path)
	if [ -z "${1}" ]; then
		return 1
	fi

	filepath="${2}"
	if [ -z "${filepath}" ]; then
		filepath="${mrsampath}"
	fi

	echo -n " Downloading from ${repository_url}/blob/${branch}/${1} to ${filepath}/..."
	curl_download "/tmp/${1##*/}" "${repository_url}/blob/${branch}/${1}?raw=true"

	if [ ! "${filepath}" == "/tmp" ]; then
		mv --force "/tmp/${1##*/}" "${filepath}/${1##*/}"
	fi

	if [ "${1##*.}" == "sh" ]; then
		chmod +x "${filepath}/${1##*/}"
	fi

	echo " Done!"
}

function get_partun() {
  REPOSITORY_URL="https://github.com/woelper/partun"
  echo " Downloading partun - needed for unzipping roms from big archives..."
  echo " Created for MiSTer by woelper - Talk to him at this year's PartunCon"
  echo " ${REPOSITORY_URL}"
  latest=$(curl -s -L --insecure https://api.github.com/repos/woelper/partun/releases/latest | jq -r ".assets[] | select(.name | contains(\"armv7\")) | .browser_download_url")
  curl_download "/tmp/partun" "${latest}"
 	mv --force "/tmp/partun" "${mrsampath}/partun"
	echo " Done!"
}

function get_mbc() {
  echo " Downloading mbc - Control MiSTer from cmd..."
  echo " Created for MiSTer by pocomane"
  get_samstuff .MiSTer_SAM/mbc
}

function get_inputmap() {
	#Ok, this is messy. Try to download every map file and just disable errors if they don't exist.
	echo -n " Downloading input maps - needed to skip past BIOS for some systems..."
	for i in "${CORE_LAUNCH[@]}"; do
		if [ ! -f /media/fat/Config/inputs/"${CORE_LAUNCH[$i]}"_input_1234_5678_v3.map ]; then
			curl_download "/tmp/${CORE_LAUNCH[$i]^^}_input_1234_5678_v3.map" "${repository_url}/blob/${branch}/.MiSTer_SAM/inputs/${CORE_LAUNCH[$i]^^}_input_1234_5678_v3.map?raw=true" &>/dev/null
			mv --force "/tmp/${CORE_LAUNCH[$i]^^}_input_1234_5678_v3.map" "/media/fat/Config/inputs/${CORE_LAUNCH[$i]^^}_input_1234_5678_v3.map" &>/dev/null
		fi
	done
	echo " Done!"
}


#========= SAM MONITOR =========
function sam_monitor_new() {
	# We can omit -r here. Tradeoff;
	# window size size is correct, can disconnect with ctrl-C but ctrl-C kills MCP
	#tmux attach-session -t SAM
	# window size will be wrong/too small, but ctrl-c nonfunctional instead of killing/disconnecting
	tmux attach-session -r -t SAM

}


# ======== SAM OPERATIONAL FUNCTIONS ========
function loop_core() { # loop_core (core)
	echo -e " Starting Super Attract Mode...\n Let Mortal Kombat begin!\n"
	# Reset game log for this session
	echo "" |> /tmp/SAM_Games.log

	while :; do

		while [ ${counter} -gt 0 ]; do
			trap 'counter=0' INT #Break out of loop for skip & next command
			echo -ne " Next game in ${counter}...\033[0K\r"
			sleep 1
			((counter--))

			if [ -s /tmp/.SAM_Mouse_Activity ]; then
				if [ "${listenmouse,,}" == "yes" ]; then
					echo " Mouse activity detected!"
					unmute
					tty_exit
					sleep 5
					exit
				else
					echo " Mouse activity ignored!"
					echo "" |>/tmp/.SAM_Mouse_Activity
				fi
			fi

			if [ -s /tmp/.SAM_Keyboard_Activity ]; then
				if [ "${listenkeyboard,,}" == "yes" ]; then
					echo " Keyboard activity detected!"
					unmute
					tty_exit
					sleep 5
					exit

				else
					echo " Keyboard activity ignored!"
					echo "" |>/tmp/.SAM_Keyboard_Activity
				fi
			fi

			if [ -s /tmp/.SAM_Joy_Activity ]; then
				if [ "${listenjoy,,}" == "yes" ]; then
					echo " Controller activity detected!"
					unmute
					tty_exit
					sleep 5
					exit
				else
					echo " Controller activity ignored!"
					echo "" |>/tmp/.SAM_Joy_Activity
				fi
			fi

		done
		
		counter=${gametimer}
		next_core ${1}

	done
	trap - INT
	sleep 1
}


function next_core() { # next_core (core)

# This function will pick a random rom from the game list.

	if [ -z "${corelist[@]//[[:blank:]]/}" ]; then
		echo " ERROR: FATAL - List of cores is empty. Nothing to do!"
		exit 1
	fi

	# Set $nextcore from $corelist
	if [ -z "${1}" ]; then
		# Don't repeat same core twice

		if [ ! -z ${nextcore,,} ]; then

			corelisttmp=$(echo "$corelist" | awk '{print $0" "}' | sed "s/${nextcore,,} //" | tr -s ' ')

			# Choose the actual core
			nextcore="$(echo ${corelisttmp}| xargs shuf --head-count=1 --echo)"

			#if core is single core make sure we don't run out of cores
			if [ -z ${nextcore,,} ]; then
			nextcore="$(echo ${corelist}| xargs shuf --head-count=1 --echo)"
			fi

		else
			nextcore="$(echo ${corelist}| xargs shuf --head-count=1 --echo)"
		fi

	if [ "${samquiet,,}" == "no" ]; then echo -e " Selected core: \e[1m${nextcore^^}.\e[0m"; fi

	elif [ "${1,,}" == "countdown" ] && [ "$2" ]; then
		countdown="countdown"
		nextcore="${2}"
	elif [ "${2,,}" == "countdown" ]; then
		nextcore="${1}"
		countdown="countdown"
	fi

	if [ "${nextcore,,}" == "arcade" ]; then
		# If this is an arcade core we go to special code
		load_core_arcade
		return
	fi


	DIR=$(echo $(realpath -s --canonicalize-missing "${CORE_PATH[${nextcore,,}]}${CORE_PATH_EXTRA[${nextcore,,}]}"))

	### Declare functions first


	function reset_core_gl() {
		echo " Deleting old game lists for ${nextcore^^}..."
		rm "${gamelistpath}/${nextcore,,}_gamelist_zipped.txt" &>/dev/null
		rm "${countpath}/${nextcore,,}_zipcount" &>/dev/null
		rm "${countpath}/${nextcore,,}_romcount" &>/dev/null
		sync
	}
	
						  
	
	function create_romlist() {
		echo " Looking for games in  ${DIR}..."
		
		# Find all files in core's folder with core's extension
		find -L "${DIR}" \( -type l -o -type d \) \( -iname *BIOS* ${folderex} \) -prune -false -o -not -path '*/.*' -type f \( -iname "*.${CORE_EXT[${nextcore,,}]}" -not -iname *BIOS* ${fileex} \) -fprint "${tmpfile}"

		# Now find all zips in core's folder and process
		if [ "${CORE_ZIPPED[${nextcore,,}],,}" == "yes" ]; then
			find -L "${DIR}" \( -type l -o -type d \) \( -iname *BIOS* ${folderex} \) -prune -false -o -not -path '*/.*' -type f \( -iname "*.zip" -not -iname *BIOS* ${fileex} \) -fprint "${tmpfile2}"
			shopt -s nullglob
			if [ -s "${tmpfile2}" ]; then
				local IFS=$'\n'
				Lines=$(cat ${tmpfile2})
				for z in ${Lines}; do
					if [ "${samquiet,,}" == "no" ]; then echo " Processing: ${z}"; fi
					"${mrsampath}/partun" "${z}" -l -e ${zipex} --include-archive-name --skip-duplicate-filenames --ext ${CORE_EXT[${nextcore,,}]} >> "${tmpfile}"
				done
			fi
			shopt -u nullglob
		fi
		
		# Strip out all duplicate filenames with a fancy awk command
		awk -F'/' '!seen[$NF]++' "${tmpfile}" | sort > "${gamelistpath}/${nextcore,,}_gamelist.txt"
		

		cp "${gamelistpath}/${nextcore,,}_gamelist.txt" "${gamelistpathtmp}/${nextcore,,}_gamelist.txt" &>/dev/null
		echo " Done."
	}
	
	##### START ROMFINDER #####
	
		#Create list
		if [ ! -f "${gamelistpath}/${nextcore,,}_gamelist.txt" ]; then
			if [ "${samquiet,,}" == "no" ]; then echo " Creating game list at ${gamelistpath}/${nextcore,,}_gamelist.txt"; fi
			create_romlist
		fi

		#If folder changed, make new list
		if [[ ! "$(cat ${gamelistpath}/${nextcore,,}_gamelist.txt | grep "${DIR}" | head -1)" ]]; then
			if [ "${samquiet,,}" == "no" ]; then echo " Creating new game list because folder "${DIR}" changed in ini."; fi
			create_romlist
		fi

		#Check if zip still exists
		if [ "$(grep -c ".zip" ${gamelistpath}/${nextcore,,}_gamelist.txt)" != "0" ]; then
			if [ ! -f "$(grep ".zip" "${gamelistpath}/${nextcore,,}_gamelist.txt" | awk -F".zip" '{print $1}/.zip/' |head -1).zip" ]; then
				if [ "${samquiet,,}" == "no" ]; then echo " Creating new game list because zip file seems to have changed."; fi
				create_romlist
			fi
		fi

		#Delete played game from list
		if [ -s "${gamelistpathtmp}/${nextcore,,}_gamelist.txt" ]; then

			#Pick the actual game
			rompath="$(cat ${gamelistpathtmp}/${nextcore,,}_gamelist.txt | shuf --head-count=1 )"
			if [ "${samquiet,,}" == "no" ]; then echo " Selected file: ${rompath}"; fi

			#Make sure file exists since we're reading from a static list
			
			if [[ ! "${rompath}" == *.zip* ]]; then					
				if [ ! -f "${rompath}" ]; then
					if [ "${samquiet,,}" == "no" ]; then echo " Creating new game list because file not found."; fi
					create_romlist
				fi
			fi

			if [ "${norepeat,,}" == "yes" ]; then
				awk -vLine="$rompath" '!index($0,Line)' "${gamelistpathtmp}/${nextcore,,}_gamelist.txt"  > ${tmpfile} && mv ${tmpfile} "${gamelistpathtmp}/${nextcore,,}_gamelist.txt"
			fi
		else

			#Repopulate list
			cp "${gamelistpath}/${nextcore,,}_gamelist.txt" "${gamelistpathtmp}/${nextcore,,}_gamelist.txt" &>/dev/null
			rompath="$(cat ${gamelistpathtmp}/${nextcore,,}_gamelist.txt | shuf --head-count=1 )"
			if [ "${samquiet,,}" == "no" ]; then echo " Selected file: ${rompath}"; fi
		fi

		romname=$(basename "${rompath}")
	


	# Sanity check that we have a valid rom in var
	if [[ ${rompath,,} != *"${CORE_EXT[${nextcore,,}]}"* ]]; then
		next_core
		return
	fi

	# If there is an exclude list check it
	declare -n excludelist="${nextcore,,}exclude"
	if [ ${#excludelist[@]} -gt 0 ]; then
		for excluded in "${excludelist[@]}"; do
			if [ "${romname}" == "${excluded}" ]; then
				echo " ${romname} is excluded - SKIPPED"
				awk -vLine="${romname}" '!index($0,Line)' "${gamelistpathtmp}/${nextcore,,}_gamelist.txt"  > ${tmpfile} && mv ${tmpfile} "${gamelistpathtmp}/${nextcore,,}_gamelist.txt"
				next_core
				return
			fi
		done
	fi

	if [ -f "${excludepath}/${nextcore,,}_excludelist.txt" ]; then
		cat "${excludepath}/${nextcore,,}_excludelist.txt" | while IFS='\n' read line; do
		echo " Found exclusion list for core $nextcore"
		awk -vLine="$line" '!index($0,Line)' "${gamelistpathtmp}/${nextcore,,}_gamelist.txt"  > ${tmpfile} && mv ${tmpfile} "${gamelistpathtmp}/${nextcore,,}_gamelist.txt"
		done
	fi


	if [ -z "${rompath}" ]; then
		core_error "${nextcore,,}" "${rompath}"
	else
		if [ -f "${rompath}.sam" ]; then
			source "${rompath}.sam"
		fi

		declare -g romloadfails=0
		load_core "${nextcore,,}" "${rompath}" "${romname%.*}" "${countdown}"
	fi
}



function load_core() { # load_core core /path/to/rom name_of_rom (countdown)

	GAMENAME=""
	if [ ${1} == "neogeo" ] && [ ${useneogeotitles,,} == "yes" ]; then
		if [ ${neogeoregion,,} == "english" ]; then
			GAMENAME="${NEOGEO_PRETTY_ENGLISH[${3}]}"
		elif [ ${neogeoregion,,} == "japanese" ]; then
			GAMENAME="${NEOGEO_PRETTY_JAPANESE[${3}]}"
			[[ ! "${GAMENAME}" ]] && GAMENAME="${NEOGEO_PRETTY_ENGLISH[${3}]}"
		fi
	fi
	if [ ! "${GAMENAME}" ]; then
		GAMENAME="${3}"
	fi

	echo -n " Starting now on the "
	echo -ne "\e[4m${CORE_PRETTY[${1,,}]}\e[0m: "
	echo -e "\e[1m${GAMENAME}\e[0m"
	echo "$(date +%H:%M:%S) - ${1} - ${3}" $(if [ ${1} == "neogeo" ] && [ ${useneogeotitles,,} == "yes" ]; then echo "(${GAMENAME})"; fi) >> /tmp/SAM_Games.log
	echo "${3} (${1}) "$(if [ ${1} == "neogeo" ] && [ ${useneogeotitles,,} == "yes" ]; then echo "(${GAMENAME})"; fi) > /tmp/SAM_Game.txt
	tty_update "${CORE_PRETTY[${1,,}]}" "${GAMENAME}" "${CORE_LAUNCH[${1,,}]}" &  # Non blocking Version
	#tty_update "${CORE_PRETTY[${1,,}]}" "${GAMENAME}" "${CORE_LAUNCH[${1,,}]}"    # Blocking Version



	if [ "${4}" == "countdown" ]; then
		for i in {5..1}; do
			echo -ne " Loading game in ${i}...\033[0K\r"
			sleep 1
		done
	fi


	#Create mgl file and launch game
	if [ -s /tmp/SAM_game.mgl ]; then
		mv /tmp/SAM_game.mgl /tmp/SAM_game.previous.mgl
	fi
	echo "<mistergamedescription>" > /tmp/SAM_game.mgl
	echo "<rbf>${CORE_PATH_RBF[${nextcore,,}]}/${MGL_CORE[${nextcore,,}]}</rbf>" >> /tmp/SAM_game.mgl
	
	if [ ${usedefaultpaths,,} == "yes" ]; then
		corepath="${CORE_PATH[${nextcore,,}]}/"
		rompath=${rompath#"${corepath}"}
		echo "<file delay="${MGL_DELAY[${nextcore,,}]}" type="${MGL_TYPE[${nextcore,,}]}" index="${MGL_INDEX[${nextcore,,}]}" path="\"${rompath}\""/>" >> /tmp/SAM_game.mgl
	else
		echo "<file delay="${MGL_DELAY[${nextcore,,}]}" type="${MGL_TYPE[${nextcore,,}]}" index="${MGL_INDEX[${nextcore,,}]}" path="\"../../../..${rompath}\""/>" >> /tmp/SAM_game.mgl		
	fi
	
	
	
	echo "</mistergamedescription>" >> /tmp/SAM_game.mgl


	echo "load_core /tmp/SAM_game.mgl" > /dev/MiSTer_cmd

	sleep 1
	echo "" |>/tmp/.SAM_Joy_Activity
	echo "" |>/tmp/.SAM_Mouse_Activity
	echo "" |>/tmp/.SAM_Keyboard_Activity

	if [ "${skipmessage,,}" == "yes" ] && [ "${CORE_SKIP[${nextcore,,}],,}" == "yes" ]; then
		skipmessage
	fi
}

function core_error() { # core_error core /path/to/ROM
	if [ ${romloadfails} -lt ${coreretries} ]; then
		declare -g romloadfails=$((romloadfails+1))
		echo " ERROR: Failed ${romloadfails} times. No valid game found for core: ${1} rom: ${2}"
		echo " Trying to find another rom..."
		next_core ${1}
	else
		echo " ERROR: Failed ${romloadfails} times. No valid game found for core: ${1} rom: ${2}"
		echo " ERROR: Core ${1} is blacklisted!"
		declare -g corelist=("${corelist[@]/${1}}")
		echo " List of cores is now: ${corelist[@]}"
		declare -g romloadfails=0
		next_core
	fi
}

function disable_bootrom() {
	if [ "${disablebootrom}" == "Yes" ]; then
	#Make Bootrom folder inaccessible until restart
		if [ -d "${misterpath}/Bootrom" ]; then
			mount --bind /mnt "${misterpath}/Bootrom"
		fi
		#Disable Nes bootroms except for FDS Bios (boot0.rom)
		if [ -f "${misterpath}/Games/NES/boot1.rom" ]; then
			touch /tmp/brfake
			mount --bind /tmp/brfake ${misterpath}/Games/NES/boot1.rom
		fi
		if [ -f "${misterpath}/Games/NES/boot2.rom" ]; then
			touch /tmp/brfake
			mount --bind /tmp/brfake ${misterpath}/Games/NES/boot2.rom
		fi
		if [ -f "${misterpath}/Games/NES/boot3.rom" ]; then
			touch /tmp/brfake
			mount --bind /tmp/brfake ${misterpath}/Games/NES/boot3.rom
		fi
	fi
}

function mute() {
	if [ "${mute,,}" == "yes" ]; then
			#Mute Global Volume
			echo -e "\0020\c" > /media/fat/config/Volume.dat
	fi
}

function unmute() {
	if [ "${mute,,}" == "yes" ]; then
			#Unmute and reload core
			echo -e "\0000\c" > /media/fat/config/Volume.dat
			if [ "${playcurrentgame,,}" == "yes" ]; then
				echo "load_core /tmp/SAM_game.mgl" > /dev/MiSTer_cmd
			else
				echo "load_core /media/fat/menu.rbf" > /dev/MiSTer_cmd
			fi
	fi
}


# ======== ARCADE MODE ========
function build_mralist() {
	DIR=$(echo $(realpath -s --canonicalize-missing "${CORE_PATH[${nextcore,,}]}${CORE_PATH_EXTRA[${nextcore,,}]}"))

	# If no MRAs found - suicide!
	find "${DIR}" -type f \( -iname "*.mra" \) &>/dev/null
	if [ ! ${?} == 0 ]; then
		echo " The path ${DIR} contains no MRA files!"
		loop_core
	fi

	# This prints the list of MRA files in a path,
	# Cuts the string to just the file name,
	# Then saves it to the mralist file.

	# If there is an empty exclude list ignore it
	# Otherwise use it to filter the list
	if [ ${#arcadeexclude[@]} -eq 0 ]; then
		find "${DIR}" -not -path '*/.*' -type f \( -iname "*.mra" \)  | cut -c $(( $(echo ${#DIR}) + 2 ))- >"${mralist}"
	else
		find "${DIR}" -not -path '*/.*' -type f \( -iname "*.mra" \)  | cut -c $(( $(echo ${#DIR}) + 2 ))- | grep -vFf <(printf '%s\n' ${arcadeexclude[@]})>"${mralist}"
	fi
}

function load_core_arcade() {

	DIR=$(echo $(realpath -s --canonicalize-missing "${CORE_PATH[${nextcore,,}]}${CORE_PATH_EXTRA[${nextcore,,}]}"))

	# Check if the MRA list is empty or doesn't exist - if so, make a new list

	if [ ! -s ${mralist} ]; then
		build_mralist
	fi

	# Get a random game from the list
	mra="$(shuf --head-count=1 ${mralist})"
	MRAPATH=$(echo $(realpath -s --canonicalize-missing "${DIR}/${mra}"))

	# If the mra variable is valid this is skipped, but if not we try 10 times
	# Partially protects against typos from manual editing and strange character parsing problems
	for i in {1..10}; do
		if [ ! -f "${MRAPATH}" ]; then
			mra=$(shuf --head-count=1 ${mralist})
			MRAPATH=$(echo $(realpath -s --canonicalize-missing "${DIR}/${mra}"))
		fi
	done

	# If the MRA is still not valid something is wrong - suicide
	if [ ! -f "${MRAPATH}" ]; then
		echo " There is no valid file at ${MRAPATH}!"
		return
	fi

	if [ "${samquiet,,}" == "no" ]; then echo " Selected file: ${MRAPATH}"; fi

	#Delete mra from list so it doesn't repeat
	if [ "${norepeat,,}" == "yes" ]; then
		awk -vLine="$mra" '!index($0,Line)' "${mralist}"  > ${tmpfile} && mv ${tmpfile} "${mralist}"

	fi

	mraname="$(echo "$(basename "${mra}")" | sed -e 's/\.[^.]*$//')"
	echo -n " Starting now on the "
	echo -ne "\e[4m${CORE_PRETTY[${nextcore,,}]}\e[0m: "
	echo -e "\e[1m${mraname}\e[0m"
	echo "$(date +%H:%M:%S) - Arcade - ${mraname}" >> /tmp/SAM_Games.log
	echo "${mraname} (${nextcore,,})" > /tmp/SAM_Game.txt

	# Get Setname from MRA needed for tty2oled, thx to RealLarry
	mrasetname=$(grep "<setname>" "${MRAPATH}" | sed -e 's/<setname>//' -e 's/<\/setname>//' | tr -cd '[:alnum:]')
	tty_update "${CORE_PRETTY[${nextcore,,}]}" "${mraname}" "${mrasetname}" &  # Non-Blocking
	#tty_update "${CORE_PRETTY[${nextcore,,}]}" "${mraname}" "${mrasetname}"    # Blocking

	if [ "${1}" == "countdown" ]; then
		for i in {5..1}; do
			echo " Loading game in ${i}...\033[0K\r"
			sleep 1
		done
	fi

  # Tell MiSTer to load the next MRA
  echo "load_core ${MRAPATH}" > /dev/MiSTer_cmd
 	sleep 1
	echo "" |>/tmp/.SAM_Joy_Activity
	echo "" |>/tmp/.SAM_Mouse_Activity
	echo "" |>/tmp/.SAM_Keyboard_Activity
}


#========= MAIN =========
#======== DEBUG OUTPUT =========
if [ "${samtrace,,}" == "yes" ]; then
	echo " ********************************************************************************"
	#======== GLOBAL VARIABLES =========
	echo " mrsampath: ${mrsampath}"
	echo " misterpath: ${misterpath}"
	echo " sampid: ${sampid}"
	echo " samprocess: ${samprocess}"
	echo ""
	#======== LOCAL VARIABLES ========
	echo " commandline: ${@}"
	echo " repository_url: ${repository_url}"
	echo " branch: ${branch}"
						  
	echo ""
	echo " gametimer: ${gametimer}"
	echo " corelist: ${corelist}"
	echo " usezip: ${usezip}"
										  
	echo " mralist: ${mralist}"
	echo " listenmouse: ${listenmouse}"
	echo " listenkeyboard: ${listenkeyboard}"
	echo " listenjoy: ${listenjoy}"
	echo ""
	echo " arcadepath: ${arcadepath}"
	echo " gbapath: ${gbapath}"
	echo " genesispath: ${genesispath}"
	echo " megacdpath: ${megacdpath}"
	echo " neogeopath: ${neogeopath}"
	echo " nespath: ${nespath}"
	echo " snespath: ${snespath}"
	echo " tgfx16path: ${tgfx16path}"
	echo " tgfx16cdpath: ${tgfx16cdpath}"
	echo ""
	echo " gbalist: ${gbalist}"
	echo " genesislist: ${genesislist}"
	echo " megacdlist: ${megacdlist}"
	echo " neogeolist: ${neogeolist}"
	echo " neslist: ${neslist}"
	echo " sneslist: ${sneslist}"
	echo " tgfx16list: ${tgfx16list}"
	echo " tgfx16cdlist: ${tgfx16cdlist}"
	echo ""
	echo " arcadeexclude: ${arcadeexclude[@]}"
	echo " gbaexclude: ${gbaexclude[@]}"
	echo " genesisexclude: ${genesisexclude[@]}"
	echo " megacdexclude: ${megacdexclude[@]}"
	echo " neogeoexclude: ${neogeoexclude[@]}"
	echo " nesexclude: ${nesexclude[@]}"
	echo " snesexclude: ${snesexclude[@]}"
	echo " tgfx16exclude: ${tgfx16exclude[@]}"
	echo " tgfx16cdexclude: ${tgfx16cdexclude[@]}"
	echo " ********************************************************************************"
	read -p " Continuing in 5 seconds or press any key..." -n 1 -t 5 -r -s
fi	

disable_bootrom	# Disable Bootrom until Reboot
mute
init_data		# Setup data arrays
if [ "${1}" != "--source-only" ]; then
    parse_cmd ${@} # Parse command line parameters for input
fi

