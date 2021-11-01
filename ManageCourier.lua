local ManageCourier = {}
ManageCourier.optionEnable = Menu.AddOptionBool({"Utility","Courier"}, "Enabled", false)
ManageCourier.optionMoveToBetterPos = Menu.AddOptionBool({"Utility","Courier"}, "Move courier to better position", false)
ManageCourier.optionUseSpeedBurst = Menu.AddOptionBool({"Utility","Courier"}, "Auto-use speed burst", false)
ManageCourier.optionUseShield = Menu.AddOptionBool({"Utility","Courier"}, "Auto-use shield", false)
Menu.AddMenuIcon({"Utility","Courier"}, '~/MenuIcons/Dota/Courier_Donkey.png')
Menu.AddOptionIcon(ManageCourier.optionEnable, '~/MenuIcons/Enable/enable_check_boxed.png')
Menu.AddOptionIcon(ManageCourier.optionMoveToBetterPos, '~/MenuIcons/size.png')
Menu.AddOptionIcon(ManageCourier.optionUseSpeedBurst, 'panorama/images/spellicons/courier_burst_png.vtex_c')
Menu.AddOptionIcon(ManageCourier.optionUseShield, 'panorama/images/spellicons/courier_shield_png.vtex_c')
local myCourier = false
local timer = GameRules.GetGameTime();

function ManageCourier.OnUpdate()
	if not Menu.IsEnabled(ManageCourier.optionEnable) then return end
	local myHero = Heroes.GetLocal()
	if not myHero then return end 
	if GameRules.GetGameTime() > timer then
		if GameRules.GetGameMode() == 15 or GameRules.GetGameMode() == 0 or GameRules.GetGameMode() == 23 or GameRules.GetGameMode() == 20 or GameRules.GetGameMode() == 19 or GameRules.GetGameMode() == 10 or GameRules.GetGameMode() == 9 or GameRules.GetGameMode() == 7 or GameRules.GetGameMode() == 6 then return end
		for i, courier in pairs(Couriers.GetAll()) do
			if Entity.GetOwner(courier) == Players.GetLocal() then
				if Entity.GetTeamNum(myHero) == 3 then
					myCourier = courier
					if Courier.GetCourierState(courier) == Enum.CourierState.COURIER_STATE_AT_BASE and Menu.IsEnabled(ManageCourier.optionMoveToBetterPos) and not (#Heroes.InRadius(Entity.GetAbsOrigin(courier), 3500, Entity.GetTeamNum(myHero), Enum.TeamType.TEAM_ENEMY) >= 1) then
						NPC.MoveTo(courier, Vector(6265, 5760, 256.0), false)
					end
					if #Heroes.InRadius(Entity.GetAbsOrigin(courier), 2000, Entity.GetTeamNum(myHero), Enum.TeamType.TEAM_ENEMY) >= 1 and NPC.IsPositionInRange(courier, Vector(6265, 5760, 256.0), 300, 0) and Menu.IsEnabled(ManageCourier.optionMoveToBetterPos) and Courier.GetCourierState(courier) == Enum.CourierState.COURIER_STATE_IDLE then
						NPC.MoveTo(courier, Vector(6965, 6395, 393), false)
					end
					local SpeedBurst = NPC.GetAbility(courier, "courier_burst")
					if Courier.GetCourierState(courier) == Enum.CourierState.COURIER_STATE_DELIVERING_ITEMS and Ability.IsCastable(SpeedBurst, 0) and Menu.IsEnabled(ManageCourier.optionUseSpeedBurst) and (Entity.GetAbsOrigin(myHero) - Entity.GetAbsOrigin(courier)):Length2D() > 4000 then
						Ability.CastNoTarget(SpeedBurst)
					end
				end
				if Entity.GetTeamNum(myHero) == 2 then
					myCourier = courier
					if Courier.GetCourierState(courier) == Enum.CourierState.COURIER_STATE_AT_BASE and Menu.IsEnabled(ManageCourier.optionMoveToBetterPos) and not (#Heroes.InRadius(Entity.GetAbsOrigin(courier), 3500, Entity.GetTeamNum(myHero), Enum.TeamType.TEAM_ENEMY) >= 1) then
						NPC.MoveTo(courier, Vector(-6325, -5820, 256), false)
					end
					if #Heroes.InRadius(Entity.GetAbsOrigin(courier), 2000, Entity.GetTeamNum(myHero), Enum.TeamType.TEAM_ENEMY) >= 1 and NPC.IsPositionInRange(courier, Vector(-6325, -5820, 256), 300, 0) and Menu.IsEnabled(ManageCourier.optionMoveToBetterPos) and Courier.GetCourierState(courier) == Enum.CourierState.COURIER_STATE_IDLE then
						NPC.MoveTo(courier, Vector(-7175, -6645, 393), false)
					end
					local SpeedBurst = NPC.GetAbility(courier, "courier_burst")
					if Courier.GetCourierState(courier) == Enum.CourierState.COURIER_STATE_DELIVERING_ITEMS and Ability.IsCastable(SpeedBurst, 0) and Menu.IsEnabled(ManageCourier.optionUseSpeedBurst) and (Entity.GetAbsOrigin(myHero) - Entity.GetAbsOrigin(courier)):Length2D() > 4000 then
						Ability.CastNoTarget(SpeedBurst)
					end
				end
			end
		end
		timer = GameRules.GetGameTime() + 0.3
	end
end

function ManageCourier.OnUnitAnimation(animation)
	if not Menu.IsEnabled(ManageCourier.optionEnable) then return end
	if not Menu.IsEnabled(ManageCourier.optionUseShield) then return end
	local myHero = Heroes.GetLocal()
	if not myHero then return end 
	if not myCourier then return end
    if not (Entity.GetTeamNum(animation["unit"]) == Entity.GetTeamNum(myHero)) then
		if Entity.IsHero(animation["unit"]) then
			if string.match(animation["sequenceName"], "attack") or string.match(animation["sequenceName"], "Attack") then
				if NPC.IsEntityInRange(myCourier, animation["unit"], 1000) then
					local Shield = NPC.GetAbility(myCourier, "courier_shield")
					if Ability.IsCastable(Shield, 0) then
						Ability.CastNoTarget(Shield)
					end
				end
			end
		end
    end
end

return ManageCourier
