local Silencer = {}

Silencer.optionEnabled = Menu.AddOptionBool({"Hero Specific", "Silencer"}, "Enable", false)
Silencer.optionComboKey = Menu.AddKeyOption({"Hero Specific", "Silencer", "Combo"}, "Combo key", Enum.ButtonCode.BUTTON_CODE_NONE)
Silencer.optionAbilities = Menu.AddOptionMultiSelect({"Hero Specific", "Silencer", "Combo"}, "Abilities:", 
{
    {"curse", "panorama/images/spellicons/silencer_curse_of_the_silent_png.vtex_c", true},
    {"glaives", "panorama/images/spellicons/silencer_glaives_of_wisdom_png.vtex_c", true},
    {"lastword", "panorama/images/spellicons/silencer_last_word_png.vtex_c", true}
}, false)

Silencer.optionItems = Menu.AddOptionMultiSelect({"Hero Specific", "Silencer", "Combo"}, "Items:", 
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
}, false)

Silencer.optionAutoGlobal = Menu.AddOptionMultiSelect({"Hero Specific", "Silencer", "Auto global"}, "Auto global:", 
{
    {"modifier_enigma_black_hole_pull", "panorama/images/spellicons/enigma_black_hole_png.vtex_c", true},
    {"modifier_faceless_void_chronosphere_freeze", "panorama/images/spellicons/faceless_void_chronosphere_png.vtex_c", true},
    {"modifier_tidehunter_ravage", "panorama/images/spellicons/tidehunter_ravage_png.vtex_c", true},
    {"modifier_bane_fiends_grip", "panorama/images/spellicons/bane_fiends_grip_png.vtex_c", true},
}, false)

Menu.AddOptionIcon(Silencer.optionEnabled, '~/MenuIcons/Enable/enable_check_round.png')
Menu.AddMenuIcon({"Hero Specific", "Silencer"}, 'panorama/images/heroes/icons/npc_dota_hero_silencer_png.vtex_c')
Menu.AddMenuIcon({"Hero Specific", "Silencer", "Auto global"}, '~/MenuIcons/mute_guy.png')

local Timer = GameRules.GetGameTime();
local TimerUpdate = GameRules.GetGameTime() - 100;
local myHero = false
local myTeam = nil
local myPlayer = nil
local mana = nil
local nextAttackTime = nil
local target = nil
local castStep = nil
local glaive = nil
local curse = nil
local lastword = nil
local global = nil

local function isSuitableToAttack(hero)
    if not Entity.IsAlive(hero) or NPC.HasState(hero, Enum.ModifierState.MODIFIER_STATE_STUNNED) or NPC.HasState(hero, Enum.ModifierState.MODIFIER_STATE_HEXED) or NPC.HasState(hero, Enum.ModifierState.MODIFIER_STATE_NIGHTMARED) or NPC.HasModifier(hero, "modifier_teleporting") or NPC.HasModifier(hero, "modifier_pudge_swallow_hide") or NPC.HasModifier(hero, "modifier_axe_berserkers_call") or NPC.HasModifier(hero, "modifier_heavens_halberd_debuff") then
        return false
    else
        return true
    end
end

local function isSuitableUseItems(hero)
    if not Entity.IsAlive(hero) or NPC.HasState(hero, Enum.ModifierState.MODIFIER_STATE_MUTED) or NPC.HasState(hero, Enum.ModifierState.MODIFIER_STATE_STUNNED) or NPC.HasState(hero, Enum.ModifierState.MODIFIER_STATE_HEXED) or NPC.HasState(hero, Enum.ModifierState.MODIFIER_STATE_NIGHTMARED) or NPC.HasModifier(hero, "modifier_teleporting") or NPC.HasModifier(hero, "modifier_pudge_swallow_hide") or NPC.HasModifier(hero, "modifier_axe_berserkers_call") then
        return false
    else
        return true
    end
end

local function isSuitableToCast(hero)
    if not Entity.IsAlive(hero) or NPC.HasState(hero, Enum.ModifierState.MODIFIER_STATE_SILENCED) or NPC.HasState(hero, Enum.ModifierState.MODIFIER_STATE_MUTED) or NPC.HasState(hero, Enum.ModifierState.MODIFIER_STATE_STUNNED) or NPC.HasState(hero, Enum.ModifierState.MODIFIER_STATE_HEXED) or NPC.HasState(hero, Enum.ModifierState.MODIFIER_STATE_NIGHTMARED) or NPC.HasModifier(hero, "modifier_teleporting") or NPC.HasModifier(hero, "modifier_pudge_swallow_hide") or NPC.HasModifier(hero, "modifier_axe_berserkers_call") then
        return false
    else
        return true
    end
end

local function bestPosition(unitsAround, radius)
    if not unitsAround or #unitsAround <= 0 then return nil end
    local enemyNum = #unitsAround

	if enemyNum == 1 then return Entity.GetAbsOrigin(unitsAround[1]) end

	local maxNum = 1
	local bestPos = Entity.GetAbsOrigin(unitsAround[1])
	for i = 1, enemyNum-1 do
		for j = i+1, enemyNum do
			if unitsAround[i] and unitsAround[j] then
				local pos1 = Entity.GetAbsOrigin(unitsAround[i])
				local pos2 = Entity.GetAbsOrigin(unitsAround[j])
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

local function SilencerUpdateInfo()
    glaive = NPC.GetAbility(myHero, "silencer_glaives_of_wisdom")
    curse = NPC.GetAbility(myHero, "silencer_curse_of_the_silent")
    lastword = NPC.GetAbility(myHero, "silencer_last_word")
    global = NPC.GetAbility(myHero, "silencer_global_silence")
end

local function SilencerInit()
    if Engine.IsInGame() then
        if NPC.GetUnitName(Heroes.GetLocal()) == "npc_dota_hero_silencer" then
            myHero = Heroes.GetLocal()
            myTeam = Entity.GetTeamNum(myHero)
            myPlayer = Players.GetLocal()
            nextAttackTime = GameRules.GetGameTime() + NPC.GetAttackTime(myHero)
            SilencerUpdateInfo()
        end;
    end;
end;

SilencerInit();
function Silencer.OnGameStart()
    SilencerInit();
end;

function Silencer.OnUpdate()
    if not Menu.IsEnabled(Silencer.optionEnabled) then return end
    if not myHero then return end
    local cursorPos = Input.GetWorldCursorPos()
    local GameTime = GameRules.GetGameTime();
    mana = NPC.GetMana(myHero)
    if TimerUpdate <= GameTime then
        TimerUpdate = GameTime + 0.5;
        SilencerUpdateInfo()
    end
    if Menu.IsKeyDown(Silencer.optionComboKey) then
        castStep = 0
        if not isSuitableToCast(myHero) and not isSuitableToAttack(myHero) then return end
        if not isSuitableUseItems(myHero) and isSuitableToAttack(myHero) and not isSuitableToCast(myHero) then castStep = 3 end
        if Timer <= GameTime then
            target = Input.GetNearestHeroToCursor(myTeam, Enum.TeamType.TEAM_ENEMY)
            if Entity.IsDormant(target) or not Entity.IsAlive(target) or NPC.IsStructure(target) or NPC.HasState(target, Enum.ModifierState.MODIFIER_STATE_INVULNERABLE) then return end
            if not NPC.IsPositionInRange(target, cursorPos, 300, 0) then
                target = nil
            end
            if target then
                if castStep == 0 then
                    for i, item in pairs(Menu.GetItems(Silencer.optionItems)) do
                        if Menu.IsSelected(Silencer.optionItems, item) then
                            if Ability.IsCastable(NPC.GetItem(myHero, tostring(item)), mana) then
                                if not (item == "item_force_staff" or item == "item_hurricane_pike") then
                                    if item ~= "item_gungir" and item ~= "item_veil_of_discord" then
                                        Ability.CastTarget(NPC.GetItem(myHero, tostring(item)), target)
                                    else
                                        Ability.CastPosition(NPC.GetItem(myHero, tostring(item)), Entity.GetAbsOrigin(target))
                                    end
                                end
                            end
                        end
                    end

                    if NPC.GetTimeToFacePosition(myHero, Entity.GetAbsOrigin(target)) < 0.01 then
                        if (Entity.GetAbsOrigin(target) - Entity.GetAbsOrigin(myHero)):Length2D() > 1100 then
                            if Ability.IsCastable(NPC.GetItem(myHero, "item_force_staff"), mana) and Menu.IsSelected(Silencer.optionItems, "item_force_staff") then
                                Ability.CastTarget(NPC.GetItem(myHero, "item_force_staff"), myHero)
                            end
                            if Ability.IsCastable(NPC.GetItem(myHero, "item_hurricane_pike"), mana) and Menu.IsSelected(Silencer.optionItems, "item_hurricane_pike") then
                                Ability.CastTarget(NPC.GetItem(myHero, "item_hurricane_pike"), myHero)
                            end
                        end
                    end
                    if (Entity.GetAbsOrigin(target) - Entity.GetAbsOrigin(myHero)):Length2D() < 300 then
                        if Ability.IsCastable(NPC.GetItem(myHero, "item_hurricane_pike"), mana) and Menu.IsSelected(Silencer.optionItems, "item_hurricane_pike") then
                            Ability.CastTarget(NPC.GetItem(myHero, "item_hurricane_pike"), target)
                        end
                    end
                    castStep = 1
                end
                if castStep == 1 then
                    if Ability.IsCastable(curse, mana) and Menu.IsSelected(Silencer.optionAbilities, "curse") then
                        if NPC.IsEntityInRange(myHero, target, Ability.GetCastRange(curse)) then
                            Timer = GameTime + 0.2
                            Ability.CastPosition(curse, bestPosition(Heroes.InRadius(Entity.GetAbsOrigin(target), 800, myTeam, Enum.TeamType.TEAM_ENEMY),400))
                        else
                            castStep = 3
                        end
                    else
                        castStep = 2
                    end
                end
                if castStep == 2 then
                    if Ability.IsCastable(lastword, mana) and Menu.IsSelected(Silencer.optionAbilities, "lastword") then
                        if NPC.IsEntityInRange(myHero, target, Ability.GetCastRange(lastword)) then
                            Timer = GameTime + 0.2
                            if NPC.HasModifier(myHero, "modifier_item_ultimate_scepter_consumed_alchemist") or NPC.HasModifier(myHero, "modifier_item_ultimate_scepter") or NPC.HasModifier(myHero, "modifier_item_ultimate_scepter_consumed") then
                                Ability.CastPosition(lastword, bestPosition(Heroes.InRadius(Entity.GetAbsOrigin(target), 950, myTeam, Enum.TeamType.TEAM_ENEMY),475))
                            else
                                Ability.CastTarget(lastword, target)
                            end
                        else
                            castStep = 3
                        end
                    else
                        castStep = 3
                    end
                end
                if castStep == 3 then
                    Timer = GameTime + 0.1
                    if Menu.IsSelected(Silencer.optionAbilities, "glaives") and NPC.IsEntityInRange(myHero, target, Ability.GetCastRange(glaive)) and Ability.IsCastable(glaive, NPC.GetMana(myHero)) and isSuitableToCast(myHero) and not NPC.HasState(target, Enum.ModifierState.MODIFIER_STATE_MAGIC_IMMUNE) then
                        Ability.CastTarget(glaive, target)
                    else
                        Player.AttackTarget(myPlayer, myHero, target)
                    end
                end
            end
        end
    else
        target = nil
    end
end

function Silencer.OnModifierCreate(entity, modifier)
    if not myHero then return end
    if not Menu.IsEnabled(Silencer.optionEnabled) then return end
    if Menu.IsSelected(Silencer.optionAutoGlobal, Modifier.GetName(modifier)) and Entity.IsSameTeam(myHero, entity) then
        if Ability.IsCastable(global, mana) and isSuitableToCast(myHero) then
            Ability.CastNoTarget(global)
        end
    end
end

function Silencer.OnModifierDestroy(entity, modifier)
    if not myHero then return end
    if not Menu.IsEnabled(Silencer.optionEnabled) then return end
    if Menu.IsSelected(Silencer.optionAutoGlobal, Modifier.GetName(modifier)) and entity == myHero then
        Player.HoldPosition(myPlayer, myHero)
    end
end


return Silencer