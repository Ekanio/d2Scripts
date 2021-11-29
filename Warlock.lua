local Warlock = {}

Warlock.optionEnabled = Menu.AddOptionBool({"Hero Specific", "Warlock"}, "Enable", false)
Warlock.optionComboKey = Menu.AddKeyOption({"Hero Specific", "Warlock", "Combo"}, "Combo key", Enum.ButtonCode.BUTTON_CODE_NONE)
Warlock.optionAbilities = Menu.AddOptionMultiSelect({"Hero Specific", "Warlock", "Combo"}, "Abilities:", 
{
    {"bonds", "panorama/images/spellicons/warlock_fatal_bonds_png.vtex_c", true},
    {"shadow_word", "panorama/images/spellicons/warlock_shadow_word_png.vtex_c", true},
    {"upheaval", "panorama/images/spellicons/warlock_upheaval_png.vtex_c", true},
    {"chaotic", "panorama/images/spellicons/warlock_rain_of_chaos_png.vtex_c", true}
}, false)

Warlock.optionItems = Menu.AddOptionMultiSelect({"Hero Specific", "Warlock", "Combo"}, "Items:", 
{
    {"item_orchid", "panorama/images/items/orchid_png.vtex_c", true},
    {"item_bloodthorn", "panorama/images/items/bloodthorn_png.vtex_c", true},
    {"item_rod_of_atos", "panorama/images/items/rod_of_atos_png.vtex_c", true},
    {"item_sheepstick", "panorama/images/items/sheepstick_png.vtex_c", true},
    {"item_nullifier", "panorama/images/items/nullifier_png.vtex_c", true},
    {"item_medallion_of_courage", "panorama/images/items/medallion_of_courage_png.vtex_c", true},
    {"item_solar_crest", "panorama/images/items/solar_crest_png.vtex_c", true},
    {"item_force_staff", "panorama/images/items/force_staff_png.vtex_c", true},
    {"item_hurricane_pike", "panorama/images/items/hurricane_pike_png.vtex_c", true},
    {"item_gungir", "panorama/images/items/gungir_png.vtex_c", true},
    {"item_veil_of_discord", "panorama/images/items/veil_of_discord_png.vtex_c", true},
    {"item_shivas_guard", "panorama/images/items/shivas_guard_png.vtex_c", true},
    {"item_glimmer_cape", "panorama/images/items/glimmer_cape_png.vtex_c", true},
    {"item_shadow_amulet", "panorama/images/items/shadow_amulet_png.vtex_c", true}
}, false)

Warlock.optionEnabledAutoUlti = Menu.AddOptionBool({"Hero Specific", "Warlock", "Auto ulti"}, "Enable auto ulti", false)
Warlock.optionAutoUltiPanicKey = Menu.AddKeyOption({"Hero Specific", "Warlock", "Auto ulti"}, "Panic key (hold)", Enum.ButtonCode.BUTTON_CODE_NONE)
Warlock.optionMinEnemiesForAutoulti = Menu.AddOptionSlider({"Hero Specific", "Warlock", "Auto ulti"}, "Auto ulti if can hit X enemies", 1, 5, 4)
Warlock.optionAutoUltiAOE = Menu.AddOptionSlider({"Hero Specific", "Warlock", "Auto ulti"}, "Auto ulti AOE", 0, 600, 500)
Warlock.optionAutoultiAt = Menu.AddOptionMultiSelect({"Hero Specific", "Warlock", "Auto ulti"}, "Auto ulti at", 
{
    {"cast4_black_hole_anim", "panorama/images/spellicons/enigma_black_hole_png.vtex_c", true},
    {"chronosphere_anim", "panorama/images/spellicons/faceless_void_chronosphere_png.vtex_c", true},
    {"ravage_anim", "panorama/images/spellicons/tidehunter_ravage_png.vtex_c", true},
    {"fiends_grip_cast_anim", "panorama/images/spellicons/bane_fiends_grip_png.vtex_c", true},
    {"dawnbreaker_ultimate_cast", "panorama/images/spellicons/dawnbreaker_solar_guardian_png.vtex_c", true},
    {"cast6_requiem_anim", "panorama/images/spellicons/nevermore_requiem_png.vtex_c", true},
}, false)

Warlock.optionFallenSkyAsBlink = Menu.AddOptionBool({"Hero Specific", "Warlock", "Combo", "Settings"}, "Use Fallen Sky as blink", false)
Warlock.optionMoveToCursor = Menu.AddOptionBool({"Hero Specific", "Warlock", "Combo", "Settings"}, "Move to cursor when no target", false)
Menu.AddOptionIcon(Warlock.optionFallenSkyAsBlink, "panorama/images/items/fallen_sky_png.vtex_c")
Menu.AddOptionIcon(Warlock.optionMoveToCursor, "~/MenuIcons/cursor.png")
Menu.AddOptionIcon(Warlock.optionEnabled, '~/MenuIcons/Enable/enable_check_round.png')
Menu.AddOptionIcon(Warlock.optionEnabledAutoUlti, '~/MenuIcons/Enable/enable_check_round.png')
Menu.AddMenuIcon({"Hero Specific", "Warlock"}, 'panorama/images/heroes/icons/npc_dota_hero_warlock_png.vtex_c')
Menu.AddMenuIcon({"Hero Specific", "Warlock", "Combo"}, "~/MenuIcons/ellipsis.png")
Menu.AddMenuIcon({"Hero Specific", "Warlock", "Combo", "Settings"}, "~/MenuIcons/ellipsis.png")
Menu.AddMenuIcon({"Hero Specific", "Warlock", "Auto ulti"}, '~/MenuIcons/box_drop.png')

local Timer = GameRules.GetGameTime();
local TimerUpdate = GameRules.GetGameTime() - 100;
local myHero = true
local myTeam = nil
local myPlayer = nil
local mana = nil
local target = nil
local castStep = nil
local bonds = nil
local shadow_word = nil
local upheaval = nil
local chaotic = nil

local function Blink(myHero)
    defblink = NPC.GetItem(myHero, "item_blink")
    overblink = NPC.GetItem(myHero, "item_overwhelming_blink")
    arcaneblink = NPC.GetItem(myHero, "item_arcane_blink")
    swiftblink = NPC.GetItem(myHero, "item_swift_blink")
    fallensky = NPC.GetItem(myHero, "item_fallen_sky")
    blink = false
    mana = NPC.GetMana(myHero)
    if Ability.IsCastable(defblink, mana) then
        blink = defblink
    end
    if Ability.IsCastable(overblink, mana) then
        blink = overblink
    end
    if Ability.IsCastable(arcaneblink, mana) then
        blink = arcaneblink
    end
    if Ability.IsCastable(swiftblink, mana) then
        blink = swiftblink
    end
    if Menu.IsEnabled(Warlock.optionFallenSkyAsBlink) then
        if Ability.IsCastable(fallensky, mana) then
            blink = fallensky
        end 
    end
    return blink
end

local function isSuitableToCast(hero)
    if not Entity.IsAlive(hero) or NPC.HasState(hero, Enum.ModifierState.MODIFIER_STATE_SILENCED) or NPC.HasState(hero, Enum.ModifierState.MODIFIER_STATE_MUTED) or NPC.HasState(hero, Enum.ModifierState.MODIFIER_STATE_STUNNED) or NPC.HasState(hero, Enum.ModifierState.MODIFIER_STATE_HEXED) or NPC.HasState(hero, Enum.ModifierState.MODIFIER_STATE_NIGHTMARED) or NPC.HasModifier(hero, "modifier_teleporting") or NPC.HasModifier(hero, "modifier_pudge_swallow_hide") or NPC.HasModifier(hero, "modifier_axe_berserkers_call") then
        return false
    else
        return true
    end
end

local function GetStunTimeLeft(npc)
    local mod = NPC.GetModifier(npc, "modifier_stunned")
    if not mod then return 0 end
    return math.max(Modifier.GetDieTime(mod) - GameRules.GetGameTime(), 0)
end

local function GetHexTimeLeft(npc)
    local mod
    local mod1 = NPC.GetModifier(npc, "modifier_sheepstick_debuff")
    local mod2 = NPC.GetModifier(npc, "modifier_lion_voodoo")
    local mod3 = NPC.GetModifier(npc, "modifier_shadow_shaman_voodoo")

    if mod1 then mod = mod1 end
    if mod2 then mod = mod2 end
    if mod3 then mod = mod3 end

    if not mod then return 0 end
    return math.max(Modifier.GetDieTime(mod) - GameRules.GetGameTime(), 0)
end

local function GetMoveSpeed(npc)
    local base_speed = NPC.GetBaseSpeed(npc)
    local bonus_speed = NPC.GetMoveSpeed(npc) - NPC.GetBaseSpeed(npc)

    if NPC.HasModifier(npc, "modifier_invoker_ice_wall_slow_debuff") then return 100 end

    if NPC.HasModifier(npc, "modifier_item_diffusal_blade_slow") then return 100 end

    if GetHexTimeLeft(npc) > 0 then return 140 + bonus_speed end

    return base_speed + bonus_speed
end

local function CantMove(npc)
    if not npc then return false end

    if GetStunTimeLeft(npc) >= 1 then return true end
    if NPC.HasModifier(npc, "modifier_axe_berserkers_call") then return true end
    if NPC.HasModifier(npc, "modifier_legion_commander_duel") then return true end

    return false
end




local function PredictedPosition(npc, delay)
    local pos = Entity.GetAbsOrigin(npc)
    if CantMove(npc) then return pos end
    if not NPC.IsRunning(npc) or not delay then return pos end

    local dir = Entity.GetRotation(npc):GetForward():Normalized()
    local speed = GetMoveSpeed(npc)

    return pos + dir:Scaled(speed * delay)
end

local function bestPosition(unitsAround, radius, predictTime)
    if not unitsAround or #unitsAround <= 0 then return nil end
    local enemyNum = #unitsAround

	if enemyNum == 1 then return PredictedPosition(unitsAround[1], predictTime) end

	local maxNum = 1
	local bestPos = Entity.GetAbsOrigin(unitsAround[1])
	for i = 1, enemyNum-1 do
		for j = i+1, enemyNum do
			if unitsAround[i] and unitsAround[j] then
				local pos1 = PredictedPosition(unitsAround[i], predictTime)
				local pos2 = PredictedPosition(unitsAround[j], predictTime)
				local mid = pos1:__add(pos2):Scaled(0.5)

				local heroesNum = 0
				for k = 1, enemyNum do
					if NPC.IsPositionInRange(unitsAround[k], mid, radius, 0) then
						heroesNum = heroesNum + 1
					end
				end

				if heroesNum > maxNum then
					maxNum = heroesNum
					bestPos = mid
				end

			end
		end
	end

	return bestPos
end

local function WarlockUpdateInfo()
    bonds = NPC.GetAbility(myHero, "warlock_fatal_bonds")
    shadow_word = NPC.GetAbility(myHero, "warlock_shadow_word")
    upheaval = NPC.GetAbility(myHero, "warlock_upheaval")
    chaotic = NPC.GetAbility(myHero, "warlock_rain_of_chaos")
end

local function WarlockInit()
    if Engine.IsInGame() then
        if NPC.GetUnitName(Heroes.GetLocal()) == "npc_dota_hero_warlock" then
            myHero = Heroes.GetLocal()
            myTeam = Entity.GetTeamNum(myHero)
            myPlayer = Players.GetLocal()
            WarlockUpdateInfo()
        end;
    end;
end;

WarlockInit();
function Warlock.OnGameStart()
    WarlockInit();
end;

function Warlock.OnUpdate()
    if not Menu.IsEnabled(Warlock.optionEnabled) then return end
    if not myHero then return end
    local cursorPos = Input.GetWorldCursorPos()
    local GameTime = GameRules.GetGameTime();
    mana = NPC.GetMana(myHero)
    if TimerUpdate <= GameTime then
        TimerUpdate = GameTime + 0.5;
        WarlockUpdateInfo()
    end
    if Menu.IsEnabled(Warlock.optionEnabledAutoUlti) and not Menu.IsKeyDown(Warlock.optionAutoUltiPanicKey) then
        if not Menu.IsKeyDown(Warlock.optionComboKey) then
            if Timer <= GameTime then
                local bestPos = bestPosition(Heroes.InRadius(Entity.GetAbsOrigin(myHero), Ability.GetCastRange(chaotic) + 250, myTeam, Enum.TeamType.TEAM_ENEMY), Menu.GetValue(Warlock.optionAutoUltiAOE), 0.3)
                if #Heroes.InRadius(bestPos, 600, myTeam, Enum.TeamType.TEAM_ENEMY) >= Menu.GetValue(Warlock.optionMinEnemiesForAutoulti) and Ability.IsCastable(chaotic, mana) then
                    Ability.CastPosition(chaotic, bestPos)
                    Timer = GameTime + 0.1
                end
            end
        end
    end
    if Menu.IsKeyDown(Warlock.optionComboKey) then
        castStep = 0
        if not isSuitableToCast(myHero) then return end
        if Timer <= GameTime then
            target = Input.GetNearestHeroToCursor(myTeam, Enum.TeamType.TEAM_ENEMY)
            local blink = Blink(myHero)
            local blink_radius = 0
            if blink then
                blink_radius = 1150 + Ability.GetCastRange(blink)
                if Ability.GetName(blink) == "item_fallen_sky" then
                    blink_radius = Ability.GetCastRange(blink)
                end
            end
            local range = blink_radius + Ability.GetCastRange(chaotic)
            if range < Ability.GetCastRange(bonds) then
                range = Ability.GetCastRange(bonds)
            end
            if range < Ability.GetCastRange(shadow_word) then
                range = Ability.GetCastRange(shadow_word)
            end
            if range < Ability.GetCastRange(upheaval) then
                range = Ability.GetCastRange(upheaval)
            end
            if not NPC.IsPositionInRange(target, cursorPos, 400, 0) or not NPC.IsEntityInRange(myHero, target, range) then
                Timer = GameTime + 0.1
                if Menu.IsEnabled(Warlock.optionMoveToCursor) then
                    if not NPC.IsChannellingAbility(myHero) then
                        NPC.MoveTo(myHero, cursorPos)
                    end
                end
                target = nil
            end
            if Entity.IsDormant(target) or not Entity.IsAlive(target) or NPC.IsStructure(target) or NPC.HasState(target, Enum.ModifierState.MODIFIER_STATE_INVULNERABLE) then return end
            if target then
                if castStep == 0 then
                    local distance = (Entity.GetAbsOrigin(target) - Entity.GetAbsOrigin(myHero)):Length2D()
                    if Ability.IsCastable(blink, mana) and distance > Ability.GetCastRange(chaotic) then
                        Ability.CastPosition(blink, Entity.GetAbsOrigin(myHero) + (Entity.GetAbsOrigin(target) - Entity.GetAbsOrigin(myHero)):Normalized():Scaled(distance - Ability.GetCastRange(chaotic) + 50))
                    else
                        castStep = 1
                    end
                end
                if castStep == 1 then
                    for i, item in pairs(Menu.GetItems(Warlock.optionItems)) do
                        if Menu.IsSelected(Warlock.optionItems, item) then
                            if Ability.IsCastable(NPC.GetItem(myHero, tostring(item)), mana) then
                                if not (item == "item_force_staff" or item == "item_hurricane_pike" or item == "item_glimmer_cape" or item == "item_shadow_amulet") then
                                    if item == "item_shivas_guard" then
                                        Ability.CastNoTarget(NPC.GetItem(myHero, tostring(item)))
                                    else
                                        if item ~= "item_gungir" and item ~= "item_veil_of_discord" then
                                            Ability.CastTarget(NPC.GetItem(myHero, tostring(item)), target)
                                        else
                                            Ability.CastPosition(NPC.GetItem(myHero, tostring(item)), bestPosition(Heroes.InRadius(Entity.GetAbsOrigin(target), 1000, myTeam, Enum.TeamType.TEAM_ENEMY),500, 0.3))
                                        end
                                    end
                                end
                            end
                        end
                    end

                    if NPC.GetTimeToFacePosition(myHero, Entity.GetAbsOrigin(target)) < 0.01 then
                        if (Entity.GetAbsOrigin(target) - Entity.GetAbsOrigin(myHero)):Length2D() > 1100 then
                            if Ability.IsCastable(NPC.GetItem(myHero, "item_force_staff"), mana) and Menu.IsSelected(Warlock.optionItems, "item_force_staff") then
                                Ability.CastTarget(NPC.GetItem(myHero, "item_force_staff"), myHero)
                            end
                            if Ability.IsCastable(NPC.GetItem(myHero, "item_hurricane_pike"), mana) and Menu.IsSelected(Warlock.optionItems, "item_hurricane_pike") then
                                Ability.CastTarget(NPC.GetItem(myHero, "item_hurricane_pike"), myHero)
                            end
                        end
                    end
                    if (Entity.GetAbsOrigin(target) - Entity.GetAbsOrigin(myHero)):Length2D() < 400 then
                        if Ability.IsCastable(NPC.GetItem(myHero, "item_hurricane_pike"), mana) and Menu.IsSelected(Warlock.optionItems, "item_hurricane_pike") then
                            Ability.CastTarget(NPC.GetItem(myHero, "item_hurricane_pike"), target)
                        end
                    end
                    castStep = 2
                end
                if castStep == 2 then
                    if Ability.IsCastable(chaotic, mana) and Menu.IsSelected(Warlock.optionAbilities, "chaotic") then
                        Timer = GameTime + 0.1
                        Ability.CastPosition(chaotic, bestPosition(Heroes.InRadius(Entity.GetAbsOrigin(target), 1200, myTeam, Enum.TeamType.TEAM_ENEMY),575, 0.3))
                    else
                        castStep = 3
                    end
                end
                if castStep == 3 then
                    if Ability.IsCastable(bonds, mana) and Menu.IsSelected(Warlock.optionAbilities, "bonds") then
                        Timer = GameTime + 0.1
                        Ability.CastTarget(bonds, target)
                    else
                        castStep = 4
                    end
                end
                if castStep == 4 then
                    if Ability.IsCastable(shadow_word, mana) and Menu.IsSelected(Warlock.optionAbilities, "shadow_word") then
                        Timer = GameTime + 0.1
                        if NPC.HasModifier(enemy, "modifier_item_aghanims_shard") then
                            Ability.CastPosition(shadow_word, bestPosition(Heroes.InRadius(Entity.GetAbsOrigin(target), 800, myTeam, Enum.TeamType.TEAM_ENEMY),400, 0.2))
                        else
                            Ability.CastTarget(shadow_word, target)
                        end
                    else
                        castStep = 5
                    end
                end
                if castStep == 5 then
                    if Ability.IsCastable(NPC.GetItem(myHero, "item_refresher"), mana) then
                        Ability.CastNoTarget(NPC.GetItem(myHero, "item_refresher"))
                        castStep = 0
                    else
                        if Ability.IsCastable(upheaval, mana) and Menu.IsSelected(Warlock.optionAbilities, "upheaval") then
                            Timer = GameTime + 0.1
                            Ability.CastPosition(upheaval, bestPosition(Heroes.InRadius(Entity.GetAbsOrigin(target), 1200, myTeam, Enum.TeamType.TEAM_ENEMY),600, 0.3))
                            if Menu.IsSelected(Warlock.optionItems, "item_glimmer_cape") or Menu.IsSelected(Warlock.optionItems, "item_shadow_amulet") then
                                local glimmer = NPC.GetItem(myHero, "item_glimmer_cape")
                                local amulet = NPC.GetItem(myHero, "item_shadow_amulet")
                                if Ability.IsCastable(glimmer, mana) then
                                    Ability.CastTarget(glimmer, myHero)
                                end
                                if Ability.IsCastable(amulet, mana) then
                                    Ability.CastTarget(amulet, myHero)
                                end
                            end
                        end
                    end
                end
            end
        end
    else
        target = nil
    end
end

function Warlock.OnUnitAnimation(animation)
    if not Menu.IsEnabled(Warlock.optionEnabledAutoUlti) then return end
    if not Menu.IsEnabled(Warlock.optionEnabled) then return end
    if not myHero then return end
    if not Entity.IsSameTeam(myHero, animation["unit"]) and not Entity.IsDormant(animation["unit"]) and not Menu.IsKeyDown(Warlock.optionAutoUltiPanicKey) then
        if Menu.IsSelected(Warlock.optionAutoultiAt, animation["sequenceName"]) then
            if NPC.IsEntityInRange(myHero, animation["unit"], Ability.GetCastRange(chaotic)) and Ability.IsCastable(chaotic, mana) then
                Ability.CastPosition(chaotic, Entity.GetAbsOrigin(animation["unit"]))
            end
        end
    end
end

return Warlock
