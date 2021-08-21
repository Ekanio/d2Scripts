local Magnus = {}
local ScreenWidth, ScreenHeight = Renderer.GetScreenSize()

--local menuLang = Menu.GetValue(Menu.GetLanguageOptionId()) не перевел потому что Menu.GetLanguageOptionId() не возвращает ничего...

Magnus.optionEnabled = Menu.AddOptionBool({"Hero Specific", "Magnus"}, "Enable", false)
Magnus.optionBlinkSkewerMode = Menu.AddOptionCombo({"Hero Specific", "Magnus", "Blink + Skewer"}, "Blink + Skewer target", {'Any hero in radius', 'Hover mouse on enemy'}, 1)
Magnus.optionBlinkSkewerPointMode = Menu.AddOptionCombo({"Hero Specific", "Magnus", "Blink + Skewer"}, "Blink + Skewer position", {'Hero position', 'Mouse position'}, 1)
Magnus.optionBlinkSkewerShockwave = Menu.AddOptionBool({"Hero Specific", "Magnus", "Blink + Skewer"}, "Use Shockwave", false)
Magnus.optionBlinkSkewerToggle = Menu.AddKeyOption({"Hero Specific", "Magnus", "Blink + Skewer"}, "Blink + Skewer key", Enum.ButtonCode.BUTTON_CODE_NONE)
Magnus.optionDrawPosRP = Menu.AddOptionBool({"Hero Specific", "Magnus", "Blink + RP + Skewer"}, "Draw RP position", false)
Magnus.minEnemiesRP = Menu.AddOptionSlider({"Hero Specific", "Magnus", "Blink + RP + Skewer"}, "Minimum enemies", 1, 5, 3)
Magnus.optionAutoRPToMouse = Menu.AddKeyOption({"Hero Specific", "Magnus", "Blink + RP + Skewer"}, "Blink + RP + Skewer to mouse", Enum.ButtonCode.BUTTON_CODE_NONE)
Magnus.RPitems = Menu.AddOptionMultiSelect({"Hero Specific", "Magnus", "Blink + RP + Skewer"}, "Items:", 
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
}, false)
Magnus.optionTurnBeforeRP = Menu.AddOptionBool({"Hero Specific", "Magnus", "Blink + RP + Skewer"}, "Turn before RP", true)
Magnus.optionSkewerAfterRP = Menu.AddOptionBool({"Hero Specific", "Magnus", "Blink + RP + Skewer"}, "Use Skewer after RP", true)
Magnus.optionToggleSkewerAfterRP= Menu.AddKeyOption({"Hero Specific", "Magnus", "Blink + RP + Skewer"}, "On/Off Skewer after RP", Enum.ButtonCode.BUTTON_CODE_NONE)
Magnus.optionHornTossMode = Menu.AddOptionBool({"Hero Specific", "Magnus", "Horn Toss"}, "Use Horn Toss", true)
Magnus.optionRPFailSwitch = Menu.AddOptionBool({"Hero Specific", "Magnus", "Settings"}, "RP failswitch", false)
Magnus.optionFallenSkyAsBlink = Menu.AddOptionBool({"Hero Specific", "Magnus", "Settings"}, "Use Fallen Sky as blink", false)
Magnus.optionPositionX = Menu.AddOptionSlider({"Hero Specific", "Magnus", "Settings"}, "info position X", 0, ScreenWidth, 1680)
Magnus.optionPositionY = Menu.AddOptionSlider({"Hero Specific", "Magnus", "Settings"}, "info position Y", 0, ScreenHeight, 50)
Magnus.optionOpacity = Menu.AddOptionSlider({"Hero Specific", "Magnus", "Settings"}, "info opacity", 0, 255, 175)
Menu.AddMenuIcon({"Hero Specific", "Magnus", "Blink + RP + Skewer"}, "panorama/images/spellicons/magnataur_reverse_polarity_png.vtex_c")
Menu.AddOptionIcon(Magnus.optionFallenSkyAsBlink, "panorama/images/items/fallen_sky_png.vtex_c")
Menu.AddOptionIcon(Magnus.optionSkewerAfterRP, "panorama/images/spellicons/magnataur_skewer_png.vtex_c")
Menu.AddOptionIcon(Magnus.optionToggleSkewerAfterRP, "panorama/images/spellicons/magnataur_skewer_png.vtex_c")
Menu.AddOptionIcon(Magnus.optionRPFailSwitch, 'panorama/images/spellicons/magnataur_reverse_polarity_png.vtex_c')
Menu.AddOptionIcon(Magnus.optionBlinkSkewerShockwave, 'panorama/images/spellicons/magnataur_shockwave_png.vtex_c')
Menu.AddOptionIcon(Magnus.optionDrawPosRP, '~/MenuIcons/map_points.png')
Menu.AddOptionIcon(Magnus.optionTurnBeforeRP, '~/MenuIcons/return.png')
Menu.AddMenuIcon({"Hero Specific", "Magnus"}, 'panorama/images/heroes/icons/npc_dota_hero_magnataur_png.vtex_c')
Menu.AddMenuIcon({"Hero Specific", "Magnus", "Blink + Skewer"}, "panorama/images/spellicons/magnataur_skewer_png.vtex_c")
Menu.AddMenuIcon({"Hero Specific", "Magnus", "Horn Toss"}, 'panorama/images/spellicons/magnataur_horn_toss_png.vtex_c')
Menu.AddMenuIcon({"Hero Specific", "Magnus", "Settings"}, "~/MenuIcons/ellipsis.png")


local magnusFont = Renderer.LoadFont("Tahoma", 30, Enum.FontWeight.EXTRABOLD)
local blink = nil
local shockwave = nil
local skewer = nil
local RP = nil
local HornToss = nil
local talent425 = nil
local skewer_castrange = nil
local skewerManaCost = nil
local shockwaveManaCost = nil
local RPManaCost = nil
local HornTossManaCost = nil
local wispHasShard = false

local countDraw = 0
local drawParticleCreateFlag = false
local CastingRP = false
local RPstep = 0
local Skewerstep = 0
local BlinkSkewerToggle = false
local myHero = nil
local myTeam = nil
local drawParticle = nil
local updateHeroPos = false
local TimerRP = GameRules.GetGameTime();
local TimerUpdate = GameRules.GetGameTime() - 100;
local TimerSkewer = GameRules.GetGameTime();

--LIBS

local function MagnusGetStunTimeLeft(npc)
    local mod = NPC.GetModifier(npc, "modifier_stunned")
    if not mod then return 0 end
    return math.max(Modifier.GetDieTime(mod) - GameRules.GetGameTime(), 0)
end

local function MagnusGetHexTimeLeft(npc)
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

local function MagnusGetMoveSpeed(npc)
    local base_speed = NPC.GetBaseSpeed(npc)
    local bonus_speed = NPC.GetMoveSpeed(npc) - NPC.GetBaseSpeed(npc)

    if NPC.HasModifier(npc, "modifier_invoker_ice_wall_slow_debuff") then return 100 end

    if NPC.HasModifier(npc, "modifier_item_diffusal_blade_slow") then return 100 end

    if MagnusGetHexTimeLeft(npc) > 0 then return 140 + bonus_speed end

    return base_speed + bonus_speed
end

local function MagnusCantMove(npc)
    if not npc then return false end

    if MagnusGetStunTimeLeft(npc) >= 1 then return true end
    if NPC.HasModifier(npc, "modifier_axe_berserkers_call") then return true end
    if NPC.HasModifier(npc, "modifier_legion_commander_duel") then return true end

    return false
end

local function MagnusBlink(myHero)
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
    if Menu.IsEnabled(Magnus.optionFallenSkyAsBlink) then
        if Ability.IsReady(fallensky) then
            blink = fallensky
        end 
    end
    return blink
end

local function MagnusBestBlinkPosition(unitsAround, radius)
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

local function MagnusPredictedPosition(npc, delay)
    local pos = Entity.GetAbsOrigin(npc)
    if MagnusCantMove(npc) then return pos end
    if not NPC.IsRunning(npc) or not delay then return pos end

    local dir = Entity.GetRotation(npc):GetForward():Normalized()
    local speed = MagnusGetMoveSpeed(npc)

    return pos + dir:Scaled(speed * delay)
end

--LIBS END

local function MagnusUpdateInfo()
    blink = MagnusBlink(myHero)
    shockwave = NPC.GetAbility(myHero, "magnataur_shockwave")
    skewer = NPC.GetAbility(myHero, "magnataur_skewer")
    RP = NPC.GetAbility(myHero, "magnataur_reverse_polarity")
    HornToss = NPC.GetAbility(myHero, "magnataur_horn_toss")
    talent425 = NPC.GetAbility(myHero, "special_bonus_unique_magnus_3")
    skewer_castrange = Ability.GetLevelSpecialValueFor(skewer, "range") + Ability.GetCastRange(skewer) + 200
    skewerManaCost = Ability.GetManaCost(skewer)
    shockwaveManaCost = Ability.GetManaCost(shockwave)
    RPManaCost = Ability.GetManaCost(RP)
    HornTossManaCost = Ability.GetManaCost(HornToss)
    if wispHasShard == false then
        for i, enemy in pairs(Heroes.GetAll()) do
            if NPC.GetUnitName(enemy) == "npc_dota_hero_wisp" then
                local wisp = enemy
                if NPC.HasModifier(enemy, "modifier_item_aghanims_shard") then
                    wispHasShard = true
                end
            end
        end
    end
end

local function MagnusInit()
    if Engine.IsInGame() then
        if NPC.GetUnitName(Heroes.GetLocal()) == "npc_dota_hero_magnataur" then
            myHero = Heroes.GetLocal()
            myTeam = Entity.GetTeamNum(myHero)
            MagnusUpdateInfo()
        end;
    end;
end;

MagnusInit();
function Magnus.OnGameStart()
    MagnusInit();
end;

function Magnus.OnDraw()
    if not Menu.IsEnabled(Magnus.optionEnabled) then return end
    if not myHero then return end
    local opacity = Menu.GetValue(Magnus.optionOpacity)
    local posX = Menu.GetValue(Magnus.optionPositionX)
    local posY = Menu.GetValue(Magnus.optionPositionY)
    if BlinkSkewerToggle then
        Renderer.SetDrawColor(0, 255, 0, opacity)   
        if Menu.GetValue(Magnus.optionBlinkSkewerMode) == 0 then
            Renderer.DrawText(magnusFont, posX, posY, "BlinkSkewer (table)", 1)
        end
        if Menu.GetValue(Magnus.optionBlinkSkewerMode) == 1 then
            Renderer.DrawText(magnusFont, posX, posY, "BlinkSkewer (mouse)", 1)
        end
        if Menu.GetValue(Magnus.optionBlinkSkewerPointMode) == 0 then
            Renderer.DrawText(magnusFont, posX, posY + 25, "On hero", 1)
        end
        if Menu.GetValue(Magnus.optionBlinkSkewerPointMode) == 1 then
            Renderer.DrawText(magnusFont, posX, posY + 25, "On mouse", 1)
        end
        posY = Menu.GetValue(Magnus.optionPositionY) + 50
    end
    if Menu.IsEnabled(Magnus.optionSkewerAfterRP) then
        Renderer.SetDrawColor(0, 255, 0, opacity)   
        Renderer.DrawText(magnusFont, posX, posY, "Use skewer after RP", 1)
    else
        Renderer.SetDrawColor(255, 0, 0, opacity)
        Renderer.DrawText(magnusFont, posX, posY, "Use skewer after RP", 1)
    end
end

function Magnus.OnUpdate()
    if not Menu.IsEnabled(Magnus.optionEnabled) then 
        if BlinkSkewerToggle then
            BlinkSkewerToggle = false
            Particle.Destroy(circle1)
            Particle.Destroy(skewerParticle)
        end
        if drawParticleCreateFlag then
            drawParticleCreateFlag = false
            Particle.Destroy(drawParticle)
        end
        return 
    end
    if not myHero then return end
    local GameTime = GameRules.GetGameTime();
    if Menu.IsKeyDownOnce(Magnus.optionToggleSkewerAfterRP) then
        if Menu.IsEnabled(Magnus.optionSkewerAfterRP) then
            Menu.SetEnabled(Magnus.optionSkewerAfterRP, false)
        else
            Menu.SetEnabled(Magnus.optionSkewerAfterRP, true)
        end
    end
    if TimerUpdate <= GameTime then
        TimerUpdate = GameTime + 0.4;
        MagnusUpdateInfo()
    end
    if Menu.IsEnabled(Magnus.optionDrawPosRP) then
        if countDraw >= 1 then
            if Ability.IsReady(RP) and Ability.GetLevel(RP) > 0 then
                if Ability.IsReady(blink) then
                    if drawParticleCreateFlag == false then
                        drawParticle = Particle.Create("particles/ui_mouseactions/range_display.vpcf")
                        drawParticleCreateFlag = true
                    end
                end
            end
        end
    end
    local Mana = NPC.GetMana(myHero)
    if Skewerstep > 0 or RPstep > 0 then
        if not Entity.IsAlive(myHero) or NPC.HasState(myHero, Enum.ModifierState.MODIFIER_STATE_ROOTED) or NPC.HasState(myHero, Enum.ModifierState.MODIFIER_STATE_SILENCED) or NPC.HasState(myHero, Enum.ModifierState.MODIFIER_STATE_MUTED) or NPC.HasState(myHero, Enum.ModifierState.MODIFIER_STATE_STUNNED) or NPC.HasState(myHero, Enum.ModifierState.MODIFIER_STATE_HEXED) or NPC.HasState(myHero, Enum.ModifierState.MODIFIER_STATE_NIGHTMARED) or NPC.HasModifier(myHero, "modifier_teleporting") or NPC.HasModifier(myHero, "modifier_pudge_swallow_hide") or NPC.HasModifier(myHero, "modifier_axe_berserkers_call") then
            Skewerstep = 0
            RPstep = 0
            continueCasting = false
            CastingRP = false
        end 
    end
    if Menu.IsEnabled(Magnus.optionDrawPosRP) then
        if Ability.IsReady(RP) and Ability.GetLevel(RP) > 0 then
            if Ability.IsReady(blink) then
                local blink_radius = 1150 + Ability.GetCastRange(blink)
                if Ability.GetName(blink) == "item_fallen_sky" then
                    blink_radius = Ability.GetCastRange(blink)
                end
                local enemyHeroes = Entity.GetHeroesInRadius(myHero, blink_radius + 190, Enum.TeamType.TEAM_ENEMY)
                posToDraw = MagnusBestBlinkPosition(enemyHeroes, 380)
                if posToDraw then
                    Particle.SetControlPoint(drawParticle, 0, posToDraw)
                    Particle.SetControlPoint(drawParticle, 1, Vector(380,0,0));
                    local xDrawPos, yDrawPos, visible = Renderer.WorldToScreen(posToDraw)
                    countDraw = 0
                    local enemiesUnderRP = Heroes.InRadius(posToDraw, 380, myTeam, Enum.TeamType.TEAM_ENEMY)
                    for i,enemy in pairs(enemiesUnderRP) do
                        if enemy ~= nil and Entity.IsHero(enemy) and not Entity.IsSameTeam(myHero, enemy) and Entity.IsAlive(enemy) and not Entity.IsDormant(enemy) and not NPC.IsIllusion(enemy) then
                            countDraw = countDraw + 1
                        end
                    end
                    Renderer.SetDrawColor(255, 255, 255, 225)
                    Renderer.DrawText(magnusFont, xDrawPos - 10, yDrawPos - 10, countDraw)
                else
                    if drawParticleCreateFlag then
                        Particle.Destroy(drawParticle)
                        drawParticleCreateFlag = false
                    end
                end
            else
                if drawParticleCreateFlag then
                    Particle.Destroy(drawParticle)
                    drawParticleCreateFlag = false
                end
            end
        else
            if drawParticleCreateFlag then
                Particle.Destroy(drawParticle)
                drawParticleCreateFlag = false
            end
        end
    else
        if drawParticleCreateFlag then
            Particle.Destroy(drawParticle)
            drawParticleCreateFlag = false
        end
    end
    if talent425 and Ability.GetLevel(talent425) > 0 then
        skewer_castrange = Ability.GetLevelSpecialValueFor(skewer, "range") + Ability.GetCastRange(skewer) + 425 + 200
    end
    if Menu.IsKeyDownOnce(Magnus.optionBlinkSkewerToggle) then
        BlinkSkewerToggle = not BlinkSkewerToggle
        Skewerstep = 0
        if Menu.GetValue(Magnus.optionBlinkSkewerPointMode) == 1 then
            prevPos = Input.GetWorldCursorPos()
        end
        if BlinkSkewerToggle then
            updateHeroPos = true
            skewerParticle = Particle.Create("particles/ui_mouseactions/range_display.vpcf")
            Particle.SetControlPoint(skewerParticle, 0, prevPos)
            Particle.SetControlPoint(skewerParticle, 1, Vector(100,0,0));
            circle1 = Particle.Create("particles/ui_mouseactions/range_display.vpcf");
            Particle.SetControlPoint(circle1, 0, prevPos)
			Particle.SetControlPoint(circle1, 1, Vector(skewer_castrange,0,0));
        else
            Particle.Destroy(circle1)
            Particle.Destroy(skewerParticle)
        end
    end
    if BlinkSkewerToggle then
        if Menu.GetValue(Magnus.optionBlinkSkewerPointMode) == 0 then
            if updateHeroPos == true then
                prevPos = Entity.GetAbsOrigin(myHero)
                Particle.SetControlPoint(skewerParticle, 0, prevPos)
                Particle.SetControlPoint(circle1, 0, prevPos)
            end
        end
        if Mana > skewerManaCost then
            if Menu.GetValue(Magnus.optionBlinkSkewerMode) == 0 then
                local enemyTable = Entity.GetHeroesInRadius(myHero, 1100 + Ability.GetCastRange(blink), Enum.TeamType.TEAM_ENEMY)
                for i, enemy in pairs(enemyTable) do
                    if enemy then
                        if not Entity.IsAlive(myHero) or NPC.HasState(myHero, Enum.ModifierState.MODIFIER_STATE_ROOTED) or NPC.HasState(myHero, Enum.ModifierState.MODIFIER_STATE_SILENCED) or NPC.HasState(myHero, Enum.ModifierState.MODIFIER_STATE_MUTED) or NPC.HasState(myHero, Enum.ModifierState.MODIFIER_STATE_STUNNED) or NPC.HasState(myHero, Enum.ModifierState.MODIFIER_STATE_HEXED) or NPC.HasState(myHero, Enum.ModifierState.MODIFIER_STATE_NIGHTMARED) or NPC.HasModifier(myHero, "modifier_teleporting") or NPC.HasModifier(myHero, "modifier_pudge_swallow_hide") or NPC.HasModifier(myHero, "modifier_axe_berserkers_call") then return end
                        if Entity.IsDormant(enemy) or not Entity.IsAlive(enemy) or NPC.IsStructure(enemy) or NPC.HasState(enemy, Enum.ModifierState.MODIFIER_STATE_MAGIC_IMMUNE) or NPC.HasState(enemy, Enum.ModifierState.MODIFIER_STATE_INVULNERABLE) then return end
                        continueCasting = false
                        if Menu.IsEnabled(Magnus.optionBlinkSkewerShockwave) then
                            if Ability.IsReady(shockwave) and Ability.GetLevel(shockwave) > 0 then
                                if NPC.IsPositionInRange(enemy, prevPos, skewer_castrange, 0) then
                                    continueCasting = true
                                end
                            else
                                if NPC.IsPositionInRange(enemy, prevPos, skewer_castrange + 200, 0) then
                                    continueCasting = true
                                end
                            end
                        else
                            if NPC.IsPositionInRange(enemy, prevPos, skewer_castrange + 50, 0) then
                                continueCasting = true
                            end
                        end
                        if continueCasting then
                            if wispHasShard and (NPC.HasModifier(enemy, "modifier_wisp_tether_haste") or NPC.HasModifier(enemy, "modifier_wisp_tether")) and not NPC.HasState(myHero, Enum.ModifierState.MODIFIER_STATE_MAGIC_IMMUNE) then
                                continueCasting = false
                            end
                        end
                        if continueCasting then
                            local distance = (MagnusPredictedPosition(enemy, 0.35) - Entity.GetAbsOrigin(myHero)):Length2D()
                            if Ability.IsReady(blink) and Ability.IsReady(skewer) then
                                if Skewerstep == 0 then
                                    updateHeroPos = false
                                    if Menu.IsEnabled(Magnus.optionBlinkSkewerShockwave) and Ability.IsReady(shockwave) and Ability.GetLevel(shockwave) > 0 then
                                        Ability.CastPosition(blink, Entity.GetAbsOrigin(myHero) + (MagnusPredictedPosition(enemy, 0.35) - Entity.GetAbsOrigin(myHero)):Normalized():Scaled(distance + 110))
                                    else
                                        Ability.CastPosition(blink, Entity.GetAbsOrigin(myHero) + (MagnusPredictedPosition(enemy, 0.35) - Entity.GetAbsOrigin(myHero)):Normalized():Scaled(distance + 55))
                                    end
                                    if Menu.IsEnabled(Magnus.optionBlinkSkewerShockwave) then
                                        Skewerstep = 1
                                    else
                                        Skewerstep = 2
                                    end
                                end
                            end
                            if Menu.IsEnabled(Magnus.optionBlinkSkewerShockwave) then
                                if not Ability.IsReady(shockwave) then Mana = Mana + shockwaveManaCost end
                                if Mana > shockwaveManaCost + skewerManaCost then
                                    if Skewerstep == 1 then
                                        if Ability.IsReady(shockwave) and Ability.GetLevel(shockwave) > 0 then
                                            if TimerSkewer <= GameTime then
                                                TimerSkewer = GameTime + 0.1;
                                                Ability.CastTarget(shockwave, enemy)
                                            end
                                        else
                                            Skewerstep = 2
                                        end
                                    end
                                    if Skewerstep == 2 then
                                        if Ability.IsReady(skewer) then
                                            if TimerSkewer <= GameTime then
                                                TimerSkewer = GameTime + 0.25;
                                                local distance = (prevPos - Entity.GetAbsOrigin(myHero)):Length2D()
                                                Ability.CastPosition(skewer, Entity.GetAbsOrigin(myHero) + (prevPos - Entity.GetAbsOrigin(myHero)):Normalized():Scaled(distance - 200))
                                            end
                                        else
                                            Skewerstep = 0
                                            BlinkSkewerToggle = false
                                            Particle.Destroy(skewerParticle)
                                            Particle.Destroy(circle1)
                                        end
                                    end
                                else
                                    if Skewerstep == 2 then
                                        if Ability.IsReady(skewer) then
                                            if TimerSkewer <= GameTime then
                                                TimerSkewer = GameTime + 0.25;
                                                local distance = (prevPos - Entity.GetAbsOrigin(myHero)):Length2D()
                                                Ability.CastPosition(skewer, Entity.GetAbsOrigin(myHero) + (prevPos - Entity.GetAbsOrigin(myHero)):Normalized():Scaled(distance - 200))
                                            end
                                        else
                                            Skewerstep = 0
                                            BlinkSkewerToggle = false
                                            Particle.Destroy(skewerParticle)
                                            Particle.Destroy(circle1)
                                        end
                                    end
                                end
                            else
                                if Skewerstep == 2 then
                                    if Ability.IsReady(skewer) then
                                        if TimerSkewer <= GameTime then
                                            TimerSkewer = GameTime + 0.25;
                                            local distance = (prevPos - Entity.GetAbsOrigin(myHero)):Length2D()
                                            Ability.CastPosition(skewer, Entity.GetAbsOrigin(myHero) + (prevPos - Entity.GetAbsOrigin(myHero)):Normalized():Scaled(distance - 200))
                                        end
                                    else
                                        Skewerstep = 0
                                        BlinkSkewerToggle = false
                                        Particle.Destroy(skewerParticle)
                                        Particle.Destroy(circle1)
                                    end
                                end
                            end
                        end
                    end
                end
            end
            if Menu.GetValue(Magnus.optionBlinkSkewerMode) == 1 then
                enemy = Input.GetNearestHeroToCursor(myTeam, Enum.TeamType.TEAM_ENEMY)
                if enemy then
                    if not Entity.IsAlive(myHero) or NPC.HasState(myHero, Enum.ModifierState.MODIFIER_STATE_ROOTED) or NPC.HasState(myHero, Enum.ModifierState.MODIFIER_STATE_SILENCED) or NPC.HasState(myHero, Enum.ModifierState.MODIFIER_STATE_MUTED) or NPC.HasState(myHero, Enum.ModifierState.MODIFIER_STATE_STUNNED) or NPC.HasState(myHero, Enum.ModifierState.MODIFIER_STATE_HEXED) or NPC.HasState(myHero, Enum.ModifierState.MODIFIER_STATE_NIGHTMARED) or NPC.HasModifier(myHero, "modifier_teleporting") or NPC.HasModifier(myHero, "modifier_pudge_swallow_hide") or NPC.HasModifier(myHero, "modifier_axe_berserkers_call") then return end                    if Entity.IsDormant(enemy) or not Entity.IsAlive(enemy) or NPC.IsStructure(enemy) or NPC.HasState(enemy, Enum.ModifierState.MODIFIER_STATE_MAGIC_IMMUNE) or NPC.HasState(enemy, Enum.ModifierState.MODIFIER_STATE_INVULNERABLE) then return end
                    if NPC.IsPositionInRange(myHero, MagnusPredictedPosition(enemy, 0.4), 1100 + Ability.GetCastRange(blink), 0) then
                        continueCasting = false
                        if Menu.IsEnabled(Magnus.optionBlinkSkewerShockwave) then
                            if Ability.IsReady(shockwave) then
                                if NPC.IsPositionInRange(enemy, prevPos, skewer_castrange, 0) then
                                    continueCasting = true
                                end
                            else
                                if NPC.IsPositionInRange(enemy, prevPos, skewer_castrange + 200, 0) then
                                    continueCasting = true
                                end
                            end
                        else
                            if NPC.IsPositionInRange(enemy, prevPos, skewer_castrange + 50, 0) then
                                continueCasting = true
                            end
                        end
                        if continueCasting then
                            if wispHasShard and (NPC.HasModifier(enemy, "modifier_wisp_tether_haste") or NPC.HasModifier(enemy, "modifier_wisp_tether")) and not NPC.HasState(myHero, Enum.ModifierState.MODIFIER_STATE_MAGIC_IMMUNE) then
                                continueCasting = false
                            end
                        end
                        if continueCasting then
                            local distance = (MagnusPredictedPosition(enemy, 0.4) - Entity.GetAbsOrigin(myHero)):Length2D()
                            if Ability.IsReady(blink) and Ability.IsReady(skewer) then
                                if Skewerstep == 0 then
                                    if NPC.IsPositionInRange(enemy, Input.GetWorldCursorPos(), 250, 0) then
                                        updateHeroPos = false
                                        if Menu.IsEnabled(Magnus.optionBlinkSkewerShockwave) and Ability.IsReady(shockwave) and Ability.GetLevel(shockwave) > 0 then
                                            Ability.CastPosition(blink, Entity.GetAbsOrigin(myHero) + (MagnusPredictedPosition(enemy, 0.35) - Entity.GetAbsOrigin(myHero)):Normalized():Scaled(distance + 110))
                                        else
                                            Ability.CastPosition(blink, Entity.GetAbsOrigin(myHero) + (MagnusPredictedPosition(enemy, 0.35) - Entity.GetAbsOrigin(myHero)):Normalized():Scaled(distance + 55))
                                        end
                                        if Menu.IsEnabled(Magnus.optionBlinkSkewerShockwave) then
                                            Skewerstep = 1
                                        else
                                            Skewerstep = 2
                                        end
                                    end
                                end
                            end
                            if Menu.IsEnabled(Magnus.optionBlinkSkewerShockwave) then
                                if not Ability.IsReady(shockwave) then Mana = Mana + shockwaveManaCost end
                                if Mana > shockwaveManaCost + skewerManaCost then
                                    if Skewerstep == 1 then
                                        if Ability.IsReady(shockwave) and Ability.GetLevel(shockwave) > 0 then
                                            if TimerSkewer <= GameTime then
                                                TimerSkewer = GameTime + 0.1;
                                                Ability.CastTarget(shockwave, enemy)
                                            end
                                        else
                                            Skewerstep = 2
                                        end
                                    end
                                    if Skewerstep == 2 then
                                        if Ability.IsReady(skewer) then
                                            if TimerSkewer <= GameTime then
                                                TimerSkewer = GameTime + 0.25;
                                                local distance = (prevPos - Entity.GetAbsOrigin(myHero)):Length2D()
                                                Ability.CastPosition(skewer, Entity.GetAbsOrigin(myHero) + (prevPos - Entity.GetAbsOrigin(myHero)):Normalized():Scaled(distance - 200))
                                            end
                                        else
                                            Skewerstep = 0
                                            BlinkSkewerToggle = false
                                            Particle.Destroy(skewerParticle)
                                            Particle.Destroy(circle1)
                                        end
                                    end
                                else
                                    if Skewerstep == 2 then
                                        if Ability.IsReady(skewer) then
                                            if TimerSkewer <= GameTime then
                                                TimerSkewer = GameTime + 0.25;
                                                local distance = (prevPos - Entity.GetAbsOrigin(myHero)):Length2D()
                                                Ability.CastPosition(skewer, Entity.GetAbsOrigin(myHero) + (prevPos - Entity.GetAbsOrigin(myHero)):Normalized():Scaled(distance - 200))
                                            end
                                        else
                                            Skewerstep = 0
                                            BlinkSkewerToggle = false
                                            Particle.Destroy(skewerParticle)
                                            Particle.Destroy(circle1)
                                        end
                                    end
                                end
                            else
                                if Skewerstep == 2 then
                                    if Ability.IsReady(skewer) then
                                        if TimerSkewer <= GameTime then
                                            TimerSkewer = GameTime + 0.25;
                                            local distance = (prevPos - Entity.GetAbsOrigin(myHero)):Length2D()
                                            Ability.CastPosition(skewer, Entity.GetAbsOrigin(myHero) + (prevPos - Entity.GetAbsOrigin(myHero)):Normalized():Scaled(distance - 200))
                                        end
                                    else
                                        Skewerstep = 0
                                        BlinkSkewerToggle = false
                                        Particle.Destroy(skewerParticle)
                                        Particle.Destroy(circle1)
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    if Menu.IsKeyDownOnce(Magnus.optionAutoRPToMouse) then
        if Ability.IsReady(blink) then
            if Ability.IsReady(RP) and Ability.GetLevel(RP) > 0 then
                CastingRP = true
                RPstep = 0
                TimerRP2 = GameTime + 0.1;
            end
        end
    end
    if CastingRP then
        if TimerRP2 <= GameTime then
            if RPstep == 0 then
                CastingRP = false
            end
        end
    end
    if CastingRP == true then
        local mousePos = Input.GetWorldCursorPos()
        local RP_radius = 380
        local blink_radius = 1150 + Ability.GetCastRange(blink)
        if Ability.GetName(blink) == "item_fallen_sky" then
            blink_radius = Ability.GetCastRange(blink)
        end
        local enemyHeroes = Entity.GetHeroesInRadius(myHero, blink_radius + RP_radius, Enum.TeamType.TEAM_ENEMY)
        local pos = MagnusBestBlinkPosition(enemyHeroes, RP_radius)
        local minMana = 0
        if Ability.IsReady(RP) then
            minMana = minMana + RPManaCost
        end
        if Ability.IsReady(skewer) then
            minMana = minMana + skewerManaCost
        end
        if Ability.IsReady(shockwave) and Ability.GetLevel(shockwave) > 0 then
            minMana = minMana + shockwaveManaCost
        end
        if pos then 
            if Mana > minMana then
                if NPC.IsPositionInRange(myHero, pos, blink_radius, 0) then
                    if not Entity.IsAlive(myHero) or NPC.HasState(myHero, Enum.ModifierState.MODIFIER_STATE_ROOTED) or NPC.HasState(myHero, Enum.ModifierState.MODIFIER_STATE_SILENCED) or NPC.HasState(myHero, Enum.ModifierState.MODIFIER_STATE_MUTED) or NPC.HasState(myHero, Enum.ModifierState.MODIFIER_STATE_STUNNED) or NPC.HasState(myHero, Enum.ModifierState.MODIFIER_STATE_HEXED) or NPC.HasState(myHero, Enum.ModifierState.MODIFIER_STATE_NIGHTMARED) or NPC.HasModifier(myHero, "modifier_teleporting") or NPC.HasModifier(myHero, "modifier_pudge_swallow_hide") or NPC.HasModifier(myHero, "modifier_axe_berserkers_call") then return end                    local count = 0
                    local enemiesUnderRP = Heroes.InRadius(pos, RP_radius, myTeam, Enum.TeamType.TEAM_ENEMY)
                    for i,enemy in pairs(enemiesUnderRP) do
                        if enemy ~= nil and Entity.IsHero(enemy) and not Entity.IsSameTeam(myHero, enemy) and Entity.IsAlive(enemy) and not Entity.IsDormant(enemy) and not NPC.IsIllusion(enemy) then
                            count = count + 1
                        end
                    end
                    if count >= Menu.GetValue(Magnus.minEnemiesRP) then
                        if RPstep == 0 then
                            for i, item in pairs(Menu.GetItems(Magnus.RPitems)) do
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
                                        Ability.CastPosition(NPC.GetItem(myHero, tostring(item)), pos)
                                    end
                                    if Mana > minMana + HornTossManaCost + 250 then
                                        if item ~= "item_black_king_bar" then
                                            Ability.CastNoTarget(NPC.GetItem(myHero, tostring(item)))
                                        end
                                    end
                                end
                            end
                            RPstep = 1
                        end
                        if RPstep == 1 then
                            Ability.CastPosition(blink, pos)
                            RPstep = 2
                        end
                        if RPstep == 2 then
                            if Menu.IsEnabled(Magnus.optionTurnBeforeRP) then
                                if TimerRP <= GameTime then
                                    TimerRP = GameTime + 0.2;
                                    Player.PrepareUnitOrders(Players.GetLocal(), Enum.UnitOrder.DOTA_UNIT_ORDER_MOVE_TO_DIRECTION, nil, mousePos, nil, Enum.PlayerOrderIssuer.DOTA_ORDER_ISSUER_PASSED_UNIT_ONLY , myHero)
                                    RPstep = 3
                                end
                            else
                                RPstep = 3
                            end
                        end
                        if RPstep == 3 then
                            if Ability.IsReady(RP) then
                                if TimerRP <= GameTime then
                                    TimerRP = GameTime + 0.2;
                                    Ability.CastNoTarget(RP)
                                end
                            else
                                RPstep = 4
                            end
                        end
                        if RPstep == 4 then
                            if Menu.IsEnabled(Magnus.optionHornTossMode) then
                                if Ability.IsReady(HornToss) and Ability.GetLevel(HornToss) > 0 then
                                    if Mana > minMana + HornTossManaCost then
                                        if TimerRP <= GameTime then
                                            TimerRP = GameTime + 0.2;
                                            Ability.CastNoTarget(HornToss)
                                        end
                                    else
                                        RPstep = 5
                                    end
                                else
                                    RPstep = 5
                                end
                            else
                                RPstep = 5
                            end
                        end
                        if RPstep == 5 then
                            if Ability.IsReady(shockwave) and Ability.GetLevel(shockwave) > 0 then
                                if TimerRP <= GameTime then
                                    TimerRP = GameTime + 0.1;
                                    Ability.CastPosition(shockwave, Entity.GetAbsOrigin(enemiesUnderRP[1]))
                                end
                            else
                                RPstep = 6
                            end
                        end
                        if RPstep == 6 then
                            if Ability.IsReady(skewer) and Ability.GetLevel(skewer) > 0 then
                                if Menu.IsEnabled(Magnus.optionSkewerAfterRP) then
                                    if TimerRP <= GameTime then
                                        TimerRP = GameTime + 0.2;
                                        local distance = (mousePos - Entity.GetAbsOrigin(myHero)):Length2D()
                                        Ability.CastPosition(skewer, Entity.GetAbsOrigin(myHero) + (mousePos - Entity.GetAbsOrigin(myHero)):Normalized():Scaled(distance - 200))
                                        CastingRP = false
                                        RPstep = 0
                                    end
                                else
                                    CastingRP = false
                                    RPstep = 0
                                end
                            end
                        end
                    end
                end
            end
        end 
    end
end

function Magnus.OnPrepareUnitOrders(order)
    if not Menu.IsEnabled(Magnus.optionEnabled) then return end
    if not myHero then return end
    if order["order"] == Enum.UnitOrder.DOTA_UNIT_ORDER_HOLD_POSITION then
        RPstep = 0
        Skewerstep = 0
    end
    if Menu.IsEnabled(Magnus.optionRPFailSwitch) then
        if Ability.GetName(order["ability"]) == "magnataur_reverse_polarity" then
            if order["order"] == Enum.UnitOrder.DOTA_UNIT_ORDER_CAST_NO_TARGET then
                local enemiesNear = Heroes.InRadius(Entity.GetAbsOrigin(myHero), 410, myTeam, Enum.TeamType.TEAM_ENEMY)
                local count = 0
                for i,enemy in pairs(enemiesNear) do
                    if enemy ~= nil and Entity.IsHero(enemy) and not Entity.IsSameTeam(myHero, enemy) and Entity.IsAlive(enemy) and not Entity.IsDormant(enemy) and not NPC.IsIllusion(enemy) then
                        count = count + 1
                    end
                end
                if count <= 0 then
                    return false
                end
            end
        end
    end
end

return Magnus
