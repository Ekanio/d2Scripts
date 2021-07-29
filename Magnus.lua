local Magnus = {}
local ScreenWidth, ScreenHeight = Renderer.GetScreenSize()

--local menuLang = Menu.GetValue(Menu.GetLanguageOptionId()) не перевел потому что Menu.GetLanguageOptionId() не возвращает ничего...

Magnus.optionEnabled = Menu.AddOptionBool({"Hero Specific", "Magnus"}, "Enable", false)
Magnus.optionSwapMode = Menu.AddOptionCombo({"Hero Specific", "Magnus", "Blink + Skewer"}, "Blink + Skewer target", {'Any hero in radius', 'Hover mouse on enemy'}, 1)
Magnus.optionSwapPointMode = Menu.AddOptionCombo({"Hero Specific", "Magnus", "Blink + Skewer"}, "Blink + Skewer position", {'Hero position', 'Mouse position'}, 1)
Magnus.optionSwapShockwave = Menu.AddOptionBool({"Hero Specific", "Magnus", "Blink + Skewer"}, "Use Shockwave", false)
Magnus.optionSwapToggle = Menu.AddKeyOption({"Hero Specific", "Magnus", "Blink + Skewer"}, "Blink + Skewer key", Enum.ButtonCode.BUTTON_CODE_NONE)
Magnus.minEnemiesRP = Menu.AddOptionSlider({"Hero Specific", "Magnus", "Blink + RP + Skewer"}, "Minimum enemies", 1, 5, 3)
Magnus.optionAutoRPToMouse = Menu.AddKeyOption({"Hero Specific", "Magnus", "Blink + RP + Skewer"}, "Blink + RP + Skewer to mouse", Enum.ButtonCode.BUTTON_CODE_NONE)
Magnus.optionHornTossMode = Menu.AddOptionBool({"Hero Specific", "Magnus", "Horn Toss"}, "Use Horn Toss", true)
Magnus.optionFallenSkyAsBlink = Menu.AddOptionBool({"Hero Specific", "Magnus", "Settings"}, "Use Fallen Sky as blink", false)
Magnus.PositionX = Menu.AddOptionSlider({"Hero Specific", "Magnus", "Settings"}, "Blink + Skewer info position X", 0, ScreenWidth, 1720)
Magnus.PositionY = Menu.AddOptionSlider({"Hero Specific", "Magnus", "Settings"}, "Blink + Skewer info position Y", 0, ScreenHeight, 50)
Menu.AddMenuIcon({"Hero Specific", "Magnus", "Blink + RP + Skewer"}, "panorama/images/spellicons/magnataur_reverse_polarity_png.vtex_c")
Menu.AddOptionIcon(Magnus.optionFallenSkyAsBlink, "panorama/images/items/fallen_sky_png.vtex_c")
Menu.AddOptionIcon(Magnus.optionSwapShockwave, 'panorama/images/spellicons/magnataur_shockwave_png.vtex_c')
Menu.AddMenuIcon({"Hero Specific", "Magnus"}, 'panorama/images/heroes/icons/npc_dota_hero_magnataur_png.vtex_c')
Menu.AddMenuIcon({"Hero Specific", "Magnus", "Blink + Skewer"}, "panorama/images/spellicons/magnataur_skewer_png.vtex_c")
Menu.AddMenuIcon({"Hero Specific", "Magnus", "Horn Toss"}, 'panorama/images/spellicons/magnataur_horn_toss_png.vtex_c')
Menu.AddMenuIcon({"Hero Specific", "Magnus", "Settings"}, "~/MenuIcons/ellipsis.png")

Magnus.RPitems = Menu.AddOptionMultiSelect({"Hero Specific", "Magnus", "Blink + RP + Skewer"}, "Items:", 
{
    {"item_shivas_guard", "panorama/images/items/shivas_guard_png.vtex_c", true},
    {"item_black_king_bar", "panorama/images/items/black_king_bar_png.vtex_c", true},
    {"item_minotaur_horn", "panorama/images/items/minotaur_horn_png.vtex_c", true},
    {"item_spider_legs", "panorama/images/items/spider_legs_png.vtex_c", true},
}, false)

Magnus.font = Renderer.LoadFont("Tahoma", 30, Enum.FontWeight.EXTRABOLD)
local swap = false

function Magnus.OnDraw()
    if not Menu.IsEnabled(Magnus.optionEnabled) then return end
    if swap then
        Renderer.SetDrawColor(0, 255, 0, 175)   
        if Menu.GetValue(Magnus.optionSwapMode) == 0 then
            Renderer.DrawText(Magnus.font, Menu.GetValue(Magnus.PositionX), Menu.GetValue(Magnus.PositionY), "swapper (table)", 1)
        end
        if Menu.GetValue(Magnus.optionSwapMode) == 1 then
            Renderer.DrawText(Magnus.font, Menu.GetValue(Magnus.PositionX), Menu.GetValue(Magnus.PositionY), "swapper (mouse)", 1)
        end
        if Menu.GetValue(Magnus.optionSwapPointMode) == 0 then
            Renderer.DrawText(Magnus.font, Menu.GetValue(Magnus.PositionX), Menu.GetValue(Magnus.PositionY) + 25, "On hero", 1)
        end
        if Menu.GetValue(Magnus.optionSwapPointMode) == 1 then
            Renderer.DrawText(Magnus.font, Menu.GetValue(Magnus.PositionX), Menu.GetValue(Magnus.PositionY) + 25, "On mouse", 1)
        end
    end
end

function Magnus.OnUpdate()
    if not Menu.IsEnabled(Magnus.optionEnabled) then return end
    local myHero = Heroes.GetLocal()
    local Mana = NPC.GetMana(myHero)
    if not myHero or NPC.GetUnitName(myHero) ~= "npc_dota_hero_magnataur" then return end
    local blink = MagnusBlink(myHero)
    local shockwave = NPC.GetAbility(myHero, "magnataur_shockwave")
    local skewer = NPC.GetAbility(myHero, "magnataur_skewer")
    local RP = NPC.GetAbility(myHero, "magnataur_reverse_polarity")
    local HornToss = NPC.GetAbility(myHero, "magnataur_horn_toss")
    local talent425 = NPC.GetAbility(myHero, "special_bonus_unique_magnus_3")
    local skewer_castrange = Ability.GetLevelSpecialValueFor(skewer, "range") + Ability.GetCastRange(skewer)
    if talent425 and Ability.GetLevel(talent425) > 0 then
        skewer_castrange = Ability.GetLevelSpecialValueFor(skewer, "range") + Ability.GetCastRange(skewer) + 425
    end
    if Menu.IsKeyDownOnce(Magnus.optionSwapToggle) then
        swap = not swap
        if Menu.GetValue(Magnus.optionSwapPointMode) == 1 then
            prevPos = Input.GetWorldCursorPos()
        end
        if swap then
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
    if swap then
        if Menu.GetValue(Magnus.optionSwapPointMode) == 0 then
            prevPos = Entity.GetAbsOrigin(myHero)
        end
        if Ability.IsReady(blink) then
            if Ability.IsReady(skewer) then
                if Mana > Ability.GetManaCost(skewer) then
                    if Menu.GetValue(Magnus.optionSwapMode) == 0 then
                        local enemyTable = Entity.GetHeroesInRadius(myHero, 1100 + Ability.GetCastRange(blink), Enum.TeamType.TEAM_ENEMY)
                        for i, enemy in ipairs(enemyTable) do
                            if enemy then
                                if NPC.IsPositionInRange(enemy, prevPos, skewer_castrange, 0) then
                                    local distance = (Magnus.PredictedPosition(enemy, 0.35) - Entity.GetAbsOrigin(myHero)):Length2D()
                                    Ability.CastPosition(blink, Entity.GetAbsOrigin(myHero) + (Magnus.PredictedPosition(enemy, 0.35) - Entity.GetAbsOrigin(myHero)):Normalized():Scaled(distance + 55))
                                    if Menu.IsEnabled(Magnus.optionSwapShockwave) then
                                        if Mana > Ability.GetManaCost(shockwave) + Ability.GetManaCost(skewer) then
                                            for i=5,1,-1 do 
                                                Ability.CastTarget(shockwave, enemy)
                                            end
                                            for i=20,1,-1 do 
                                                Ability.CastPosition(skewer, prevPos)
                                            end
                                        else
                                            Ability.CastPosition(skewer, prevPos)
                                        end
                                    else
                                        Ability.CastPosition(skewer, prevPos)
                                    end
                                    swap = not swap
                                    Particle.Destroy(skewerParticle)
                                    Particle.Destroy(circle1)
                                end
                            end
                        end
                    end
                    if Menu.GetValue(Magnus.optionSwapMode) == 1 then
                        enemy = Input.GetNearestHeroToCursor(Entity.GetTeamNum(myHero), Enum.TeamType.TEAM_ENEMY)
                        if enemy then
                            if NPC.IsPositionInRange(enemy, Input.GetWorldCursorPos(), 150, 0) then
                                if NPC.IsPositionInRange(myHero, Magnus.PredictedPosition(enemy, 0.4), 1100 + Ability.GetCastRange(blink), 0) then
                                    if NPC.IsPositionInRange(enemy, prevPos, skewer_castrange, 0) then
                                        local distance = (Magnus.PredictedPosition(enemy, 0.4) - Entity.GetAbsOrigin(myHero)):Length2D()
                                        Ability.CastPosition(blink, Entity.GetAbsOrigin(myHero) + (Magnus.PredictedPosition(enemy, 0.4) - Entity.GetAbsOrigin(myHero)):Normalized():Scaled(distance + 55))
                                        if Menu.IsEnabled(Magnus.optionSwapShockwave) then
                                            if Mana > Ability.GetManaCost(shockwave) + Ability.GetManaCost(skewer) then
                                                for i=5,1,-1 do 
                                                    Ability.CastTarget(shockwave, enemy)
                                                end
                                                for i=20,1,-1 do 
                                                    Ability.CastPosition(skewer, prevPos)
                                                end
                                            else
                                                Ability.CastPosition(skewer, prevPos)
                                            end
                                        else
                                            Ability.CastPosition(skewer, prevPos)
                                        end
                                        swap = not swap
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
        local dir = Input.GetWorldCursorPos()
        if Ability.IsReady(blink) then
            if Ability.IsReady(RP) then
                local RP_radius = 380
                local blink_radius = 1150 + Ability.GetCastRange(blink)
                if Ability.GetName(blink) == "item_fallen_sky" then
                    blink_radius = Ability.GetCastRange(blink)
                end
                local enemyHeroes = Entity.GetHeroesInRadius(myHero, blink_radius, Enum.TeamType.TEAM_ENEMY)
                local pos = Magnus.BestBlinkPosition(enemyHeroes, RP_radius)
                local immune = false
                local minMana = Ability.GetManaCost(RP) + Ability.GetManaCost(shockwave) + Ability.GetManaCost(skewer)
                if pos then 
                    if Mana > minMana then
                        local count = 0
                        local enemiesUnderRP = Heroes.InRadius(pos, RP_radius, Entity.GetTeamNum(myHero), Enum.TeamType.TEAM_ENEMY)
                        for i,enemy in pairs(enemiesUnderRP) do
                            if enemy ~= nil and Entity.IsHero(enemy) and not Entity.IsSameTeam(myHero, enemy) and Entity.IsAlive(enemy) and not Entity.IsDormant(enemy) and not NPC.IsIllusion(enemy) then
                                count = count + 1
                            end
                        end
                        if count >= Menu.GetValue(Magnus.minEnemiesRP) then
                            for i, item in ipairs(Menu.GetItems(Magnus.RPitems)) do
                                if Ability.IsReady(NPC.GetItem(myHero, tostring(item))) then
                                    if item == "item_minotaur_horn" then
                                        if immune == false then
                                            if not NPC.HasModifier(myHero, "modifier_black_king_bar_immune") then
                                                Ability.CastNoTarget(NPC.GetItem(myHero, tostring(item)))
                                                immune = true
                                            end
                                        end
                                    end
                                    if item == "item_black_king_bar" then
                                        if immune == false then
                                            if not NPC.HasModifier(myHero, "modifier_minotaur_horn_immune") then
                                                Ability.CastNoTarget(NPC.GetItem(myHero, tostring(item)))
                                                immune = true
                                            end
                                        end
                                    end
                                    if item == "item_spider_legs" then
                                        Ability.CastNoTarget(NPC.GetItem(myHero, tostring(item)))
                                    end
                                    if Mana > minMana + Ability.GetManaCost(HornToss) + 100 then
                                        if item ~= "item_minotaur_horn" and item ~= "item_black_king_bar" then
                                            Ability.CastNoTarget(NPC.GetItem(myHero, tostring(item)))
                                        end
                                    end
                                end
                            end
                            Ability.CastPosition(blink, pos)
                            --спам ордерами =) ( не умею сбивать анимки =( )
                            if Ability.GetName(blink) == "item_fallen_sky" then
                                for i=20,1,-1 do 
                                    Ability.CastNoTarget(RP)
                                end
                            else
                                for i=5,1,-1 do 
                                    Ability.CastNoTarget(RP)
                                end
                            end
                            if Menu.IsEnabled(Magnus.optionHornTossMode) then
                                if Mana > minMana + Ability.GetManaCost(HornToss) then
                                    for i=15,1,-1 do 
                                        Ability.CastNoTarget(HornToss)
                                    end
                                end
                            end
                            for i=10,1,-1 do 
                                Ability.CastTarget(shockwave, enemiesUnderRP[1])
                            end
                            for i=10,1,-1 do 
                                Ability.CastPosition(skewer, dir)
                            end
                        end
                    end
                end 
            end
        end
    end
end

function MagnusBlink(myHero)
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
-- libs =)

function Magnus.BestBlinkPosition(unitsAround, radius)
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

function Magnus.PredictedPosition(npc, delay)
    local pos = Entity.GetAbsOrigin(npc)
    if Magnus.CantMove(npc) then return pos end
    if not NPC.IsRunning(npc) or not delay then return pos end

    local dir = Entity.GetRotation(npc):GetForward():Normalized()
    local speed = Magnus.GetMoveSpeed(npc)

    return pos + dir:Scaled(speed * delay)
end

function Magnus.GetMoveSpeed(npc)
    local base_speed = NPC.GetBaseSpeed(npc)
    local bonus_speed = NPC.GetMoveSpeed(npc) - NPC.GetBaseSpeed(npc)

    if NPC.HasModifier(npc, "modifier_invoker_ice_wall_slow_debuff") then return 100 end

    if NPC.HasModifier(npc, "modifier_item_diffusal_blade_slow") then return 100 end

    if Magnus.GetHexTimeLeft(npc) > 0 then return 140 + bonus_speed end

    return base_speed + bonus_speed
end

function Magnus.CantMove(npc)
    if not npc then return false end

    if Magnus.GetStunTimeLeft(npc) >= 1 then return true end
    if NPC.HasModifier(npc, "modifier_axe_berserkers_call") then return true end
    if NPC.HasModifier(npc, "modifier_legion_commander_duel") then return true end

    return false
end

function Magnus.GetHexTimeLeft(npc)
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

function Magnus.GetStunTimeLeft(npc)
    local mod = NPC.GetModifier(npc, "modifier_stunned")
    if not mod then return 0 end
    return math.max(Modifier.GetDieTime(mod) - GameRules.GetGameTime(), 0)
end

return Magnus