local SK = {}
local ScreenWidth, ScreenHeight = Renderer.GetScreenSize()

local heroes = {  -- huge thanks to Svotin
	[1] = 'npc_dota_hero_antimage',
	[2] = 'npc_dota_hero_axe',
	[3] = 'npc_dota_hero_bane',
	[4] = 'npc_dota_hero_bloodseeker',
	[5] = 'npc_dota_hero_crystal_maiden',
	[6] = 'npc_dota_hero_drow_ranger',
	[7] = 'npc_dota_hero_earthshaker',
	[8] = 'npc_dota_hero_juggernaut',
	[9] = 'npc_dota_hero_mirana',
	[11] = 'npc_dota_hero_nevermore',
	[10] = 'npc_dota_hero_morphling',
	[12] = 'npc_dota_hero_phantom_lancer',
	[13] = 'npc_dota_hero_puck',
	[14] = 'npc_dota_hero_pudge',
	[15] = 'npc_dota_hero_razor',
	[16] = 'npc_dota_hero_sand_king',
	[17] = 'npc_dota_hero_storm_spirit',
	[18] = 'npc_dota_hero_sven',
	[19] = 'npc_dota_hero_tiny',
	[20] = 'npc_dota_hero_vengefulspirit',
	[21] = 'npc_dota_hero_windrunner',
	[22] = 'npc_dota_hero_zuus',
	[23] = 'npc_dota_hero_kunkka',
	[25] = 'npc_dota_hero_lina',
	[31] = 'npc_dota_hero_lich',
	[26] = 'npc_dota_hero_lion',
	[27] = 'npc_dota_hero_shadow_shaman',
	[28] = 'npc_dota_hero_slardar',
	[29] = 'npc_dota_hero_tidehunter',
	[30] = 'npc_dota_hero_witch_doctor',
	[32] = 'npc_dota_hero_riki',
	[33] = 'npc_dota_hero_enigma',
	[34] = 'npc_dota_hero_tinker',
	[35] = 'npc_dota_hero_sniper',
	[36] = 'npc_dota_hero_necrolyte',
	[37] = 'npc_dota_hero_warlock',
	[38] = 'npc_dota_hero_beastmaster',
	[39] = 'npc_dota_hero_queenofpain',
	[40] = 'npc_dota_hero_venomancer',
	[41] = 'npc_dota_hero_faceless_void',
	[42] = 'npc_dota_hero_skeleton_king',
	[43] = 'npc_dota_hero_death_prophet',
	[44] = 'npc_dota_hero_phantom_assassin',
	[45] = 'npc_dota_hero_pugna',
	[46] = 'npc_dota_hero_templar_assassin',
	[47] = 'npc_dota_hero_viper',
	[48] = 'npc_dota_hero_luna',
	[49] = 'npc_dota_hero_dragon_knight',
	[50] = 'npc_dota_hero_dazzle',
	[51] = 'npc_dota_hero_rattletrap',
	[52] = 'npc_dota_hero_leshrac',
	[53] = 'npc_dota_hero_furion',
	[54] = 'npc_dota_hero_life_stealer',
	[55] = 'npc_dota_hero_dark_seer',
	[56] = 'npc_dota_hero_clinkz',
	[57] = 'npc_dota_hero_omniknight',
	[58] = 'npc_dota_hero_enchantress',
	[59] = 'npc_dota_hero_huskar',
	[60] = 'npc_dota_hero_night_stalker',
	[61] = 'npc_dota_hero_broodmother',
	[62] = 'npc_dota_hero_bounty_hunter',
	[63] = 'npc_dota_hero_weaver',
	[64] = 'npc_dota_hero_jakiro',
	[65] = 'npc_dota_hero_batrider',
	[66] = 'npc_dota_hero_chen',
	[67] = 'npc_dota_hero_spectre',
	[69] = 'npc_dota_hero_doom_bringer',
	[68] = 'npc_dota_hero_ancient_apparition',
	[70] = 'npc_dota_hero_ursa',
	[71] = 'npc_dota_hero_spirit_breaker',
	[72] = 'npc_dota_hero_gyrocopter',
	[73] = 'npc_dota_hero_alchemist',
	[74] = 'npc_dota_hero_invoker',
	[75] = 'npc_dota_hero_silencer',
	[76] = 'npc_dota_hero_obsidian_destroyer',
	[77] = 'npc_dota_hero_lycan',
	[78] = 'npc_dota_hero_brewmaster',
	[79] = 'npc_dota_hero_shadow_demon',
	[80] = 'npc_dota_hero_lone_druid',
	[81] = 'npc_dota_hero_chaos_knight',
	[82] = 'npc_dota_hero_meepo',
	[83] = 'npc_dota_hero_treant',
	[84] = 'npc_dota_hero_ogre_magi',
	[85] = 'npc_dota_hero_undying',
	[86] = 'npc_dota_hero_rubick',
	[87] = 'npc_dota_hero_disruptor',
	[88] = 'npc_dota_hero_nyx_assassin',
	[89] = 'npc_dota_hero_naga_siren',
	[90] = 'npc_dota_hero_keeper_of_the_light',
	[91] = 'npc_dota_hero_wisp',
	[92] = 'npc_dota_hero_visage',
	[93] = 'npc_dota_hero_slark',
	[94] = 'npc_dota_hero_medusa',
	[95] = 'npc_dota_hero_troll_warlord',
	[96] = 'npc_dota_hero_centaur',
	[97] = 'npc_dota_hero_magnataur',
	[98] = 'npc_dota_hero_shredder',
	[99] = 'npc_dota_hero_bristleback',
	[100] = 'npc_dota_hero_tusk',
	[101] = 'npc_dota_hero_skywrath_mage',
	[102] = 'npc_dota_hero_abaddon',
	[103] = 'npc_dota_hero_elder_titan',
	[104] = 'npc_dota_hero_legion_commander',
	[106] = 'npc_dota_hero_ember_spirit',
	[107] = 'npc_dota_hero_earth_spirit',
	[109] = 'npc_dota_hero_terrorblade',
	[110] = 'npc_dota_hero_phoenix',
	[111] = 'npc_dota_hero_oracle',
	[105] = 'npc_dota_hero_techies',
	[127] = 'npc_dota_hero_target_dummy',
	[112] = 'npc_dota_hero_winter_wyvern',
	[113] = 'npc_dota_hero_arc_warden',
	[108] = 'npc_dota_hero_abyssal_underlord',
	[114] = 'npc_dota_hero_monkey_king',
	[120] = 'npc_dota_hero_pangolier',
	[119] = 'npc_dota_hero_dark_willow',
	[121] = 'npc_dota_hero_grimstroke',
	[129] = 'npc_dota_hero_mars',
	[126] = 'npc_dota_hero_void_spirit',
	[128] = 'npc_dota_hero_snapfire',
	[123] = 'npc_dota_hero_hoodwink',
	[135] = 'npc_dota_hero_dawnbreaker',
}



local SKFont = Renderer.LoadFont("Tahoma", 30, Enum.FontWeight.EXTRABOLD)
local blink = nil
local burrowstrike = nil
local sandstorm = nil
local epicenter = nil
local target = nil
local burrowstrikecastrange = nil
local burrowstrikeManaCost = nil
local sandstormManaCost = nil
local epicenterManaCost = nil
local comboing = false

local flagMenuUpdate = false
local countDraw = 0
local combostep = 0
local Skewerstep = 0
local BlinkSkewerToggle = false
local myHero = nil
local myTeam = nil
local Timer = GameRules.GetGameTime();
local TimerUpdate = GameRules.GetGameTime() - 100;
local tableTest = {}

SK.optionEnabled = Menu.AddOptionBool({"Hero Specific", "Sand King"}, "Enable", false)
SK.optionBind = Menu.AddKeyOption({"Hero Specific", "Sand King"}, "Combo key", Enum.ButtonCode.BUTTON_CODE_NONE)
SK.optionEpicenterDormant = Menu.AddOptionCombo({"Hero Specific", "Sand King", "Epicenter"}, "If target becomes dormant while casting", {'Blink to mouse pos', 'Stop casting epicenter'}, 0)
SK.minEnemiesEpicenter = Menu.AddOptionSlider({"Hero Specific", "Sand King", "Epicenter"}, "Minimum enemies", 1, 5, 3)
SK.comboItems = Menu.AddOptionMultiSelect({"Hero Specific", "Sand King"}, "Items:", 
{
    {"item_seer_stone", "panorama/images/items/seer_stone_png.vtex_c", true},
    {"item_shivas_guard", "panorama/images/items/shivas_guard_png.vtex_c", true},
    {"item_black_king_bar", "panorama/images/items/black_king_bar_png.vtex_c", true},
    {"item_spider_legs", "panorama/images/items/spider_legs_png.vtex_c", true},
    {"item_pipe", "panorama/images/items/pipe_png.vtex_c", true},
    {"item_eternal_shroud", "panorama/images/items/eternal_shroud_png.vtex_c", true},
    {"item_blade_mail", "panorama/images/items/blade_mail_png.vtex_c", true},
    {"item_crimson_guard", "panorama/images/items/crimson_guard_png.vtex_c", true},
    {"item_hood_of_defiance", "panorama/images/items/hood_of_defiance_png.vtex_c", true},
    {"item_orchid", "panorama/images/items/orchid_png.vtex_c", true},
    {"item_bloodthorn", "panorama/images/items/bloodthorn_png.vtex_c", true},
    {"item_lotus_orb", "panorama/images/items/lotus_orb_png.vtex_c", true},
    {"item_rod_of_atos", "panorama/images/items/rod_of_atos_png.vtex_c", true},
    {"item_sheepstick", "panorama/images/items/sheepstick_png.vtex_c", true},
    {"item_gungir", "panorama/images/items/gungir_png.vtex_c", true},
}, false)
Menu.AddMenuIcon({"Hero Specific", "Sand King", "Epicenter"}, "panorama/images/spellicons/sandking_epicenter_png.vtex_c")
Menu.AddMenuIcon({"Hero Specific", "Sand King"}, 'panorama/images/heroes/icons/npc_dota_hero_sand_king_png.vtex_c')

--LIBS

local function SKBlink(myHero)
    defblink = NPC.GetItem(myHero, "item_blink")
    overblink = NPC.GetItem(myHero, "item_overwhelming_blink")
    arcaneblink = NPC.GetItem(myHero, "item_arcane_blink")
    swiftblink = NPC.GetItem(myHero, "item_swift_blink")
    fallensky = NPC.GetItem(myHero, "item_fallen_sky")
    if Ability.IsReady(defblink) then
        blink = defblink
    end
    if Ability.IsReady(overblink) then
        blink = overblink
    end
    if Ability.IsReady(arcaneblink) then
        blink = arcaneblink
    end
    if Ability.IsReady(swiftblink) then
        blink = swiftblink
    end
    return blink
end

--LIBS END

local function has_value (tab, val)
    for index, value in ipairs(tab) do
        if value == val then
            return true
        end
    end

    return false
end

local function SKUpdateInfo()
    blink = SKBlink(myHero)
    burrowstrike = NPC.GetAbility(myHero, "sandking_burrowstrike")
    sandstorm = NPC.GetAbility(myHero, "sandking_sand_storm")
    epicenter = NPC.GetAbility(myHero, "sandking_epicenter")
    burrowstrikecastrange = Ability.GetCastRange(burrowstrike)
    burrowstrikeManaCost = Ability.GetManaCost(burrowstrike)
    sandstormManaCost = Ability.GetManaCost(skewer)
    epicenterManaCost = Ability.GetManaCost(epicenter)
    if flagMenuUpdate == false then
        local teammates = {}
        for i, hero in pairs(Heroes.GetAll()) do
            if Entity.IsSameTeam(myHero, hero) and not has_value(teammates, Player.GetPlayerID(Entity.GetOwner(hero))) then
                table.insert(teammates, Player.GetPlayerID(Entity.GetOwner(hero)))
            end
        end
        if(#teammates == 5) then
            for i,enemy in pairs(Players.GetAll()) do
                if not has_value(teammates, Player.GetPlayerID(enemy)) then
                    table.insert(tableTest, {heroes[Player.GetTeamData(enemy).selected_hero_id], "panorama/images/heroes/icons/" .. heroes[Player.GetTeamData(enemy).selected_hero_id] .. "_png.vtex_c", false})
                end
            end
            SK.epicenterPriority = Menu.AddOptionMultiSelect({"Hero Specific", "Sand King", "Epicenter"}, "Cast epicenter anyway:", tableTest, false)
            flagMenuUpdate = true
        end
    end
end

local function SKInit()
    if Engine.IsInGame() then
        if NPC.GetUnitName(Heroes.GetLocal()) == "npc_dota_hero_sand_king" then
            myHero = Heroes.GetLocal()
            myTeam = Entity.GetTeamNum(myHero)
            flagMenuUpdate = false
            SKUpdateInfo()
        end;
    end;
end;

SKInit();
function SK.OnGameStart()
    SKInit();
end;

function SK.OnUpdate()
    if not Menu.IsEnabled(SK.optionEnabled) then return end
    if not myHero then return end
    
    local gameTime = GameRules.GetGameTime()
    if TimerUpdate <= gameTime then
        TimerUpdate = gameTime + 0.4;
        SKUpdateInfo()
    end
    local mousePos = Input.GetWorldCursorPos()
    if Timer <= gameTime then
        if Menu.IsKeyDown(SK.optionBind) then
            if not Entity.IsAlive(myHero) or NPC.HasState(myHero, Enum.ModifierState.MODIFIER_STATE_ROOTED) or NPC.HasState(myHero, Enum.ModifierState.MODIFIER_STATE_SILENCED) or NPC.HasState(myHero, Enum.ModifierState.MODIFIER_STATE_MUTED) or NPC.HasState(myHero, Enum.ModifierState.MODIFIER_STATE_STUNNED) or NPC.HasState(myHero, Enum.ModifierState.MODIFIER_STATE_HEXED) or NPC.HasState(myHero, Enum.ModifierState.MODIFIER_STATE_NIGHTMARED) or NPC.HasModifier(myHero, "modifier_teleporting") or NPC.HasModifier(myHero, "modifier_pudge_swallow_hide") or NPC.HasModifier(myHero, "modifier_axe_berserkers_call") then return end
            comboing = true
            if target == nil then
                local nearest = Input.GetNearestHeroToCursor(myTeam, Enum.TeamType.TEAM_ENEMY)
                local Range = 0
                if Ability.IsCastable(blink, 400) then
                    Range = 600 + Ability.GetCastRange(blink)
                end
                if Ability.IsReady(burrowstrike) then
                    Range = Range + burrowstrikecastrange
                end
                if NPC.IsPositionInRange(nearest, mousePos, 400, 0) then
                    if NPC.IsEntityInRange(nearest, myHero, Range) then
                        target = nearest
                    end
                end
            else
                if combostep == 0 then
                    if Ability.IsReady(epicenter) then
                        if (#Heroes.InRadius(Entity.GetAbsOrigin(target), 525, myTeam, Enum.TeamType.TEAM_ENEMY) >= 2) or Menu.IsSelected(SK.epicenterPriority, NPC.GetUnitName(target)) then
                            Ability.CastNoTarget(epicenter)
                            Timer = gameTime + 0.2;
                            local Range = 0
                            if Ability.IsCastable(blink, 400) then
                                Range = 600 + Ability.GetCastRange(blink)
                            end
                            if Ability.IsReady(burrowstrike) then
                                Range = Range + burrowstrikecastrange
                            end
                            if not NPC.IsEntityInRange(target, myHero, Range) then
                                Player.HoldPosition(Players.GetLocal(), myHero)
                                target = nil
                            end
                            if Entity.IsDormant(target) then
                                if Menu.GetValue(SK.optionEpicenterDormant) == 1 then
                                    Player.HoldPosition(Players.GetLocal(), myHero)
                                    target = nil
                                end
                            end
                        else
                            combostep = 1
                        end
                    else
                        combostep = 1
                    end
                end
                if combostep == 1 then
                    if Ability.IsReady(blink) then
                        if Entity.IsDormant(target) then
                            if Menu.GetValue(SK.optionEpicenterDormant) == 0 then
                                Ability.CastPosition(blink, mousePos)
                                Timer = gameTime + 0.2;
                            end
                        else
                            if Ability.IsReady(burrowstrike) then castrangeBlink = burrowstrikecastrange else castrangeBlink = 0 end
                            if not NPC.IsPositionInRange(myHero, Entity.GetAbsOrigin(target), castrangeBlink, 0) then
                                Ability.CastPosition(blink, Entity.GetAbsOrigin(target), false, true)
                            else
                                combostep = 2
                            end
                        end
                    else
                        combostep = 2
                    end
                end
                if combostep == 2 then
                    for i, item in pairs(Menu.GetItems(SK.comboItems)) do
                        if Ability.IsReady(NPC.GetItem(myHero, tostring(item))) then
                            if item == "item_black_king_bar" then
                                if not NPC.HasModifier(myHero, "modifier_black_king_bar_immune") then
                                    Ability.CastNoTarget(NPC.GetItem(myHero, tostring(item)))
                                end
                            end
                            if item == "item_spider_legs" then
                                Ability.CastNoTarget(NPC.GetItem(myHero, tostring(item)))
                            end
                            if item == "item_seer_stone" then
                                Ability.CastPosition(NPC.GetItem(myHero, tostring(item)), Entity.GetAbsOrigin(target))
                            end
                            if item == "item_lotus_orb" then
                                Ability.CastTarget(NPC.GetItem(myHero, tostring(item)), myHero)
                            end
                            if NPC.GetMana(myHero) > burrowstrikeManaCost + sandstormManaCost + 250 then
                                if item ~= "item_black_king_bar" then
                                    Ability.CastNoTarget(NPC.GetItem(myHero, tostring(item)))
                                end
                            end
                        end
                    end
                    Timer = gameTime + 0.4;
                    combostep = 3
                end
                if combostep == 3 then
                    if Ability.IsReady(burrowstrike) then
                        if not Entity.IsDormant(target) then
                            if NPC.IsPositionInRange(myHero, Entity.GetAbsOrigin(target), burrowstrikecastrange + 100, 0) then
                                Ability.CastPosition(burrowstrike, Entity.GetAbsOrigin(target))
                            end
                        end
                    else
                        combostep = 4
                    end
                end
                if combostep == 4 then
                    if Ability.IsReady(sandstorm) then
                        if NPC.IsPositionInRange(myHero, Entity.GetAbsOrigin(target), 500, 0) then
                            Ability.CastNoTarget(sandstorm, Entity.GetAbsOrigin(target))
                            for i, item in pairs(Menu.GetItems(SK.comboItems)) do
                                if Ability.IsReady(NPC.GetItem(myHero, tostring(item))) then
                                    if item == "item_gungir" then
                                        Ability.CastPosition(NPC.GetItem(myHero, tostring(item)), Entity.GetAbsOrigin(target))
                                    end
                                    if item == "item_orchid" or item == "item_bloodthorn" or item == "item_rod_of_atos" or item == "item_sheepstick" then
                                        Ability.CastTarget(NPC.GetItem(myHero, tostring(item)), target)
                                    end
                                end
                            end
                        end
                    else
                        combostep = 0
                    end
                end
            end
        else
            if comboing == true then
                if NPC.GetActivity(myHero) == Enum.GameActivity.ACT_DOTA_CAST_ABILITY_4 then
                    Player.HoldPosition(Players.GetLocal(), myHero)
                end
                combostep = 0
                target = nil
                comboing = false
            end
        end
    end
end

return SK