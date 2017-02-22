local Cooldown = {}
local SniperOrigin = {}

function Initialize(Plugin)
	Plugin:SetName(g_PluginInfo.Name)

	cPluginManager:AddHook(cPluginManager.HOOK_PLAYER_RIGHT_CLICK, OnPlayerRightClick)
	cPluginManager:AddHook(cPluginManager.HOOK_PLAYER_ANIMATION, OnPlayerAnimation)
	cPluginManager:AddHook(cPluginManager.HOOK_PROJECTILE_HIT_ENTITY, OnProjectileHitEntity)

	dofile(cPluginManager:GetPluginsPath() .. "/InfoReg.lua")
	RegisterPluginInfoCommands()

	LOG("Initialised " .. Plugin:GetName())
	return true
end

function HandleWeaponsCommand(Split, Player)
	if Split[2] == nil then
		Player:SendMessageInfo("Usage: " .. Split[1] .. " <name>")
		Player:SendMessageInfo("Available weapons: anvildropper, lightning, nuker, sniper")
	elseif Split[2] == "anvildropper" then
		Player:GetInventory():AddItem(cItem(E_BLOCK_ANVIL, 1, 0, "", "§8Anvil Dropper"))
		Player:SendMessageSuccess("You have received the anvil dropper!")
	elseif Split[2] == "lightning" then
		Player:GetInventory():AddItem(cItem(E_ITEM_STICK, 1, 0, "", "§fLightning Stick"))
		Player:SendMessageSuccess("You have received the lightning stick!")
	elseif Split[2] == "nuker" then
		Player:GetInventory():AddItem(cItem(E_ITEM_BLAZE_ROD, 1, 0, "", "§6Nuker"))
		Player:SendMessageSuccess("You have received the nuke!")
	elseif Split[2] == "sniper" then
		Player:GetInventory():AddItem(cItem(E_ITEM_IRON_HORSE_ARMOR, 1, 0, "", "§7Sniper"))
		Player:SendMessageSuccess("You have received the sniper!")
	else
		Player:SendMessageFailure("Invaild weapon")
	end
	return true
end

function GetPlayerLookPos(Player)
	local Tracer = cTracer(Player:GetWorld())
	local EyePos = Vector3f(Player:GetEyePosition().x, Player:GetEyePosition().y, Player:GetEyePosition().z)
	local EyeVector = Vector3f(Player:GetLookVector().x, Player:GetLookVector().y, Player:GetLookVector().z)
	Tracer:Trace(EyePos, EyeVector, 100)
	return Tracer.BlockHitPosition
end

function OnPlayerAnimation(Player, Animation)
	local PX = Player:GetPosX()
	local PY = Player:GetPosY()
	local PZ = Player:GetPosZ()
	local Weapon = Player:GetEquippedItem()
	local World = Player:GetWorld()
	if Weapon.m_ItemType == E_ITEM_IRON_HORSE_ARMOR and Weapon.m_CustomName == "§7Sniper" then
		World:CreateProjectile(PX, PY + 1.5, PZ, cProjectileEntity.pkSnowball, Player, Weapon, Player:GetLookVector() * 80)
		World:BroadcastSoundEffect("block.piston.contract", PX, PY, PZ, 1.0, 63)
		SniperOrigin[Player:GetUniqueID()] = true
	end
end

function OnPlayerRightClick(Player, BlockX, BlockY, BlockZ, BlockFace, CursorX, CursorY, CursorZ)
	local LookPos = GetPlayerLookPos(Player)
	local PX = Player:GetPosX()
	local PY = Player:GetPosY()
	local PZ = Player:GetPosZ()
	local Weapon = Player:GetEquippedItem()
	local World = Player:GetWorld()
	if Cooldown[Player:GetUUID()] then
		Cooldown[Player:GetUUID()] = nil
		return true
	end
	if Weapon.m_ItemType == E_BLOCK_ANVIL and Weapon.m_CustomName == "§8Anvil Dropper" then
		for x = -1, 4, 1 do
			for z = -1, 4, 1 do
				World:SpawnFallingBlock(PX - x, PY, PZ - z, E_BLOCK_ANVIL, 0)
			end
		end
		return true
	elseif Weapon.m_ItemType == E_ITEM_BLAZE_ROD and Weapon.m_CustomName == "§6Nuker" then
		World:CreateProjectile(PX, PY + 0.9, PZ + 0.5, cProjectileEntity.pkGhastFireball, Player, Weapon, Player:GetLookVector() * 60)
		World:DoExplosionAt(4, LookPos.x, LookPos.y, LookPos.z, true, 4)
		World:BroadcastSoundEffect("entity.ghast.shoot", PX, PY, PZ, 0.9, 1.5) 
		World:BroadcastSoundEffect("entity.bat.takeoff", PX, PY, PZ, 0.8, 2)
		Cooldown[Player:GetUUID()] = true
		return true
	elseif Weapon.m_ItemType == E_ITEM_IRON_HORSE_ARMOR and Weapon.m_CustomName == "§7Sniper" then
		if not Player:HasEntityEffect(2) then
			Player:AddEntityEffect(2, 90000, 7)
		else
			Player:RemoveEntityEffect(2)
		end
		return true
	elseif Weapon.m_ItemType == E_ITEM_STICK and Weapon.m_CustomName == "§fLightning Stick" then
		if LookPos.x == 0 and LookPos.y == 0 and LookPos.z == 0 then
			World:CastThunderbolt(PX, PY, PZ)
		else
			World:CastThunderbolt(LookPos.x, LookPos.y, LookPos.z)
		end
		return true
	end
end

function OnProjectileHitEntity(ProjectileEntity, Entity)
	if SniperOrigin[ProjectileEntity:GetCreatorName()] then
		Entity:TakeDamage(dtArrow, Player, 18, 4)
		SniperOrigin[ProjectileEntity:GetCreatorUniqueID()] = nil
	end
end

function OnDisable()
	LOG("Disabled " .. cPluginManager:GetCurrentPlugin():GetName() .. "!")
end
