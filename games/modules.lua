local loadstring = function(...)
	local res, err = loadstring(...)
	if err and vape then
		vape:CreateNotification('Vape', 'Failed to load : '..err, 30, 'alert')
	end
	return res
end
local isfile = isfile or function(file)
	local suc, res = pcall(function()
		return readfile(file)
	end)
	return suc and res ~= nil and res ~= ''
end
local function downloadFile(path, func)
	if not isfile(path) then
		local suc, res = pcall(function()
			return game:HttpGet('https://raw.githubusercontent.com/7GrandDadPGN/VapeV4ForRoblox/'..readfile('newvape/profiles/commit.txt')..'/'..select(1, path:gsub('newvape/', '')), true)
		end)
		if not suc or res == '404: Not Found' then
			error(res)
		end
		if path:find('.lua') then
			res = '--This watermark is used to delete the file if its cached, remove it to make the file persist after vape updates.\n'..res
		end
		writefile(path, res)
	end
	return (func or readfile)(path)
end
local run = function(func)
	func()
end
local btext = function(text)
	return text..' '
end

local queue_on_teleport = queue_on_teleport or function() end
local cloneref = cloneref or function(obj)
	return obj
end

local function getPlacedBlock(pos)
	if not pos then
		return
	end
	local roundedPosition = bedwars.BlockController:getBlockPosition(pos)
	return bedwars.BlockController:getStore():getBlockAt(roundedPosition), roundedPosition
end

local vapeConnections
if shared.vapeConnections and type(shared.vapeConnections) == "table" then vapeConnections = shared.vapeConnections else vapeConnections = {}; shared.vapeConnections = vapeConnections; end

local playersService = cloneref(game:GetService('Players'))
local replicatedStorage = cloneref(game:GetService('ReplicatedStorage'))
local runService = cloneref(game:GetService('RunService'))
local inputService = cloneref(game:GetService('UserInputService'))
local tweenService = cloneref(game:GetService('TweenService'))
local lightingService = cloneref(game:GetService('Lighting'))
local marketplaceService = cloneref(game:GetService('MarketplaceService'))
local teleportService = cloneref(game:GetService('TeleportService'))
local httpService = cloneref(game:GetService('HttpService'))
local guiService = cloneref(game:GetService('GuiService'))
local groupService = cloneref(game:GetService('GroupService'))
local textChatService = cloneref(game:GetService('TextChatService'))
local contextService = cloneref(game:GetService('ContextActionService'))
local coreGui = cloneref(game:GetService('CoreGui'))
local collectionService = cloneref(game:GetService("CollectionService"))

local isnetworkowner = identifyexecutor and table.find({'AWP', 'Nihon'}, ({identifyexecutor()})[1]) and isnetworkowner or function()
	return true
end
local gameCamera = workspace.CurrentCamera or workspace:FindFirstChildWhichIsA('Camera')
local lplr = playersService.LocalPlayer
local assetfunction = getcustomasset

local GuiLibrary = shared.GuiLibrary
local vape = shared.vape
local entitylib = vape.Libraries.entity
local targetinfo = vape.Libraries.targetinfo
local sessioninfo = vape.Libraries.sessioninfo
local uipallet = vape.Libraries.uipallet
local tween = vape.Libraries.tween
local color = vape.Libraries.color
local whitelist = vape.Libraries.whitelist
local prediction = vape.Libraries.prediction
local getfontsize = vape.Libraries.getfontsize
local getcustomasset = vape.Libraries.getcustomasset

local activeTweens = {}
local activeAnimationTrack = nil
local activeModel = nil
local emoteActive = false
 

local RunLoops = {RenderStepTable = {}, StepTable = {}, HeartTable = {}}
do
	function RunLoops:BindToRenderStep(name, func)
		if RunLoops.RenderStepTable[name] == nil then
			RunLoops.RenderStepTable[name] = runService.RenderStepped:Connect(func)
		end
	end

	function RunLoops:UnbindFromRenderStep(name)
		if RunLoops.RenderStepTable[name] then
			RunLoops.RenderStepTable[name]:Disconnect()
			RunLoops.RenderStepTable[name] = nil
		end
	end

	function RunLoops:BindToStepped(name, func)
		if RunLoops.StepTable[name] == nil then
			RunLoops.StepTable[name] = runService.Stepped:Connect(func)
		end
	end

	function RunLoops:UnbindFromStepped(name)
		if RunLoops.StepTable[name] then
			RunLoops.StepTable[name]:Disconnect()
			RunLoops.StepTable[name] = nil
		end
	end

	function RunLoops:BindToHeartbeat(name, func)
		if RunLoops.HeartTable[name] == nil then
			RunLoops.HeartTable[name] = runService.Heartbeat:Connect(func)
		end
	end

	function RunLoops:UnbindFromHeartbeat(name)
		if RunLoops.HeartTable[name] then
			RunLoops.HeartTable[name]:Disconnect()
			RunLoops.HeartTable[name] = nil
		end
	end
end

local XStore = {
	bedtable = {},
	Tweening = false,
	AntiHitting = false
}
XFunctions:SetGlobalData('XStore', XStore)

local function getrandomvalue(tab)
	return #tab > 0 and tab[math.random(1, #tab)] or ''
end

local function GetEnumItems(enum)
	local fonts = {}
	for i,v in next, Enum[enum]:GetEnumItems() do 
		table.insert(fonts, v.Name) 
	end
	return fonts
end

local isAlive = function(plr, healthblacklist)
	plr = plr or lplr
	local alive = false 
	if plr.Character and plr.Character.PrimaryPart and plr.Character:FindFirstChild("HumanoidRootPart") and plr.Character:FindFirstChild("Humanoid") and plr.Character:FindFirstChild("Head") then 
		alive = true
	end
	if not healthblacklist and alive and plr.Character.Humanoid.Health and plr.Character.Humanoid.Health <= 0 then 
		alive = false
	end
	return alive
end
local function GetMagnitudeOf2Objects(part, part2, bypass)
	local magnitude, partcount = 0, 0
	if not bypass then 
		local suc, res = pcall(function() return part.Position end)
		partcount = suc and partcount + 1 or partcount
		suc, res = pcall(function() return part2.Position end)
		partcount = suc and partcount + 1 or partcount
	end
	if partcount > 1 or bypass then 
		magnitude = bypass and (part - part2).magnitude or (part.Position - part2.Position).magnitude
	end
	return magnitude
end
local function createSequence(args)
    local seq =
        ColorSequence.new(
        {
            ColorSequenceKeypoint.new(args[1], args[2]),
            ColorSequenceKeypoint.new(args[3], args[4])
        }
    )
    return seq
end
local function GetTopBlock(position, smart, raycast, customvector)
	position = position or isAlive(lplr, true) and lplr.Character:WaitForChild("HumanoidRootPart").Position
	if not position then 
		return nil 
	end
	if raycast and not game.Workspace:Raycast(position, Vector3.new(0, -2000, 0), store.blockRaycast) then
	    return nil
    end
	local lastblock = nil
	for i = 1, 500 do 
		local newray = game.Workspace:Raycast(lastblock and lastblock.Position or position, customvector or Vector3.new(0.55, 999999, 0.55), store.blockRaycast)
		local smartest = newray and smart and game.Workspace:Raycast(lastblock and lastblock.Position or position, Vector3.new(0, 5.5, 0), store.blockRaycast) or not smart
		if newray and smartest then
			lastblock = newray
		else
			break
		end
	end
	return lastblock
end
local function FindEnemyBed(maxdistance, highest)
	local target = nil
	local distance = maxdistance or math.huge
	local whitelistuserteams = {}
	local badbeds = {}
	if not lplr:GetAttribute("Team") then return nil end
	for i,v in pairs(playersService:GetPlayers()) do
		if v ~= lplr then
			local type, attackable = vape.Libraries.whitelist:get(v)
			if not attackable then
				whitelistuserteams[v:GetAttribute("Team")] = true
			end
		end
	end
	for i,v in pairs(collectionService:GetTagged("bed")) do
			local bedteamstring = string.split(v:GetAttribute("id"), "_")[1]
			if whitelistuserteams[bedteamstring] ~= nil then
			   badbeds[v] = true
		    end
	    end
	for i,v in pairs(collectionService:GetTagged("bed")) do
		if v:GetAttribute("id") and v:GetAttribute("id") ~= lplr:GetAttribute("Team").."_bed" and badbeds[v] == nil and lplr.Character and lplr.Character.PrimaryPart then
			if v:GetAttribute("NoBreak") or v:GetAttribute("PlacedByUserId") and v:GetAttribute("PlacedByUserId") ~= 0 then continue end
			local magdist = GetMagnitudeOf2Objects(lplr.Character.PrimaryPart, v)
			if magdist < distance then
				target = v
				distance = magdist
			end
		end
	end
	local coveredblock = highest and target and GetTopBlock(target.Position, true)
	if coveredblock then
		target = coveredblock.Instance
	end
	for i,v in pairs(game:GetService("Teams"):GetTeams()) do
		if target and v.TeamColor == target.Bed.BrickColor then
			XStore.bedtable[target] = v.Name
		end
	end
	return target
end
local function FindTeamBed()
	local bedstate, res = pcall(function()
		return lplr.leaderstats.Bed.Value
	end)
	return bedstate and res and res ~= nil and res == "✅"
end
local function FindItemDrop(item)
	local itemdist = nil
	local dist = math.huge
	local function abletocalculate() return lplr.Character and lplr.Character:FindFirstChild("HumanoidRootPart") end
    for i,v in pairs(collectionService:GetTagged("ItemDrop")) do
		if v and v.Name == item and abletocalculate() then
			local itemdistance = GetMagnitudeOf2Objects(lplr.Character:WaitForChild("HumanoidRootPart"), v)
			if itemdistance < dist then
			itemdist = v
			dist = itemdistance
		end
		end
	end
	return itemdist
end

local function getItem(itemName, inv)
	for slot, item in (inv or store.inventory.inventory.items) do
		if item.itemType == itemName then
			return item, slot
		end
	end
	return nil
end

local vapeAssert = function(argument, title, text, duration, hault, moduledisable, module) 
	if not argument then
    local suc, res = pcall(function()
    local notification = GuiLibrary:CreateNotification(title or "QP Vape", text or "Failed to call function.", duration or 20, "assets/WarningNotification.png")
    notification.IconLabel.ImageColor3 = Color3.new(220, 0, 0)
    notification.Frame.Frame.ImageColor3 = Color3.new(220, 0, 0)
    if moduledisable and (module and vape.Modules[module].Enabled) then vape.Modules[module]:Toggle(false) end
    end)
    if hault then while true do task.wait() end end end
end

local function spinParts(model)
    for _, part in ipairs(model:GetDescendants()) do
        if part:IsA("BasePart") and (part.Name == "Middle" or part.Name == "Outer") then
            local tweenInfo, goal
            if part.Name == "Middle" then
                tweenInfo = TweenInfo.new(12.5, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, -1, false, 0)
                goal = { Orientation = part.Orientation + Vector3.new(0, -360, 0) }
            elseif part.Name == "Outer" then
                tweenInfo = TweenInfo.new(1.5, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, -1, false, 0)
                goal = { Orientation = part.Orientation + Vector3.new(0, 360, 0) }
            end
 
            local tween = tweenService:Create(part, tweenInfo, goal)
            tween:Play()
            table.insert(activeTweens, tween)
        end
    end
end
 
local function placeModelUnderLeg()
    local player = playersService.LocalPlayer
    local character = player.Character or player.CharacterAdded:Wait()
    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
 
    if humanoidRootPart then
        local assetsFolder = replicatedStorage:FindFirstChild("Assets")
        if assetsFolder then
            local effectsFolder = assetsFolder:FindFirstChild("Effects")
            if effectsFolder then
                local modelTemplate = effectsFolder:FindFirstChild("NightmareEmote")
                if modelTemplate and modelTemplate:IsA("Model") then
                    local clonedModel = modelTemplate:Clone()
                    clonedModel.Parent = workspace
 
                    if clonedModel.PrimaryPart then
                        clonedModel:SetPrimaryPartCFrame(humanoidRootPart.CFrame - Vector3.new(0, 3, 0))
                    else
                        warn("PrimaryPart not set for NightmareEmote model!")
                        return
                    end
 
                    spinParts(clonedModel)
                    activeModel = clonedModel
                else
                    warn("NightmareEmote model not found or is not a valid model!")
                end
            else
                warn("Effects folder not found in Assets!")
            end
        else
            warn("Assets folder not found in ReplicatedStorage!")
        end
    else
        warn("HumanoidRootPart not found in character!")
    end
end
 
local function playAnimation(animationId)
    local player = playersService.LocalPlayer
    local character = player.Character or player.CharacterAdded:Wait()
    local humanoid = character:FindFirstChild("Humanoid")
 
    if humanoid then
        local animator = humanoid:FindFirstChild("Animator") or Instance.new("Animator", humanoid)
        local animation = Instance.new("Animation")
        animation.AnimationId = animationId
        activeAnimationTrack = animator:LoadAnimation(animation)
        activeAnimationTrack:Play()
    else
        warn("Humanoid not found in character!")
    end
end
 
local function stopEffects()
    for _, tween in ipairs(activeTweens) do
        tween:Cancel()
    end
    activeTweens = {}
 
    if activeAnimationTrack then
        activeAnimationTrack:Stop()
        activeAnimationTrack = nil
    end
 
    if activeModel then
        activeModel:Destroy()
        activeModel = nil
    end
 
    emoteActive = false
end
 
local function monitorWalking()
    local player = playersService.LocalPlayer
    local character = player.Character or player.CharacterAdded:Wait()
    local humanoid = character:FindFirstChild("Humanoid")
 
    if humanoid then
        humanoid.Running:Connect(function(speed)
            if speed > 0 and emoteActive then
                stopEffects()
            end
        end)
    else
        warn("Humanoid not found in character!")
    end
end
 
local function activateNightmareEmote()
    if emoteActive then
        return
    end
 
    emoteActive = true
    local success, err = pcall(function()
        monitorWalking()
        placeModelUnderLeg()
        playAnimation("rbxassetid://9191822700")
    end)
 
    if not success then
        warn("Error occurred: " .. tostring(err))
        emoteActive = false
    end
end

if game.PlaceId = 6872274481 then
run(function()
    InfJump = vape.Categories.Blatant:CreateModule({
        Name = "InfiniteJump",
        Function = function(callback)
            if callback then
                local uis = game:GetService("UserInputService")
                uis.JumpRequest:Connect(function()
                    local hum = lplr.Character and lplr.Character:FindFirstChildOfClass("Humanoid")
                    if hum then
                        hum:ChangeState(Enum.HumanoidStateType.Jumping)
                    end
                end)
            end
        end
    })
end)

run(function()
    FPSUnlock = vape.Categories.Utility:CreateModule({
        Name = "FPSUnlocker",
        Function = function(callback)
            if callback then
                setfpscap(99999999999999999999)
            else
                setfpscap(120)
            end
        end
    })
end)
		
runfunction(function()
	local transformed = false
	local GameThemeV2 = {["Enabled"] = false}
	local themeselected = {["Value"] = "CitySky"}

	local Lighting = game:GetService("Lighting")
	local StarterGui = game:GetService("StarterGui")

	local skyboxes = {
		NebulaSky = {
			Back = "rbxassetid://13581437029",
			Down = "rbxassetid://13581439832",
			Front = "rbxassetid://13581447312",
			Left = "rbxassetid://13581443463",
			Right = "rbxassetid://13581452875",
			Up = "rbxassetid://13581450222",
			AtmosphereColor = Color3.fromRGB(179, 59, 249),
			AtmosphereDecay = Color3.fromRGB(155, 212, 255)
		},
		PinkMountainSky = {
			Back = "http://www.roblox.com/asset/?id=160188495",
			Down = "http://www.roblox.com/asset/?id=160188614",
			Front = "http://www.roblox.com/asset/?id=160188609",
			Left = "http://www.roblox.com/asset/?id=160188589",
			Right = "http://www.roblox.com/asset/?id=160188597",
			Up = "http://www.roblox.com/asset/?id=160188588"
		},
		CitySky = {
			Back = "rbxassetid://11263062161",
			Down = "rbxassetid://11263065295",
			Front = "rbxassetid://11263066644",
			Left = "rbxassetid://11263068413",
			Right = "rbxassetid://11263069782",
			Up = "rbxassetid://11263070890"
		},
		PinkSky = {
			Back = "http://www.roblox.com/asset/?id=271042516",
			Down = "http://www.roblox.com/asset/?id=271077243",
			Front = "http://www.roblox.com/asset/?id=271042556",
			Left = "http://www.roblox.com/asset/?id=271042310",
			Right = "http://www.roblox.com/asset/?id=271042467",
			Up = "http://www.roblox.com/asset/?id=271077958"
		},
		SpaceSky = {
			Back = "rbxassetid://1735468027",
			Down = "rbxassetid://1735500192",
			Front = "rbxassetid://1735467260",
			Left = "rbxassetid://1735467682",
			Right = "rbxassetid://1735466772",
			Up = "rbxassetid://1735500898"
		},
		EgirlSky = {
			Back = "rbxassetid://2128458653",
			Down = "rbxassetid://2128462480",
			Front = "rbxassetid://2128458653",
			Left = "rbxassetid://2128462027",
			Right = "rbxassetid://2128462027",
			Up = "rbxassetid://2128462236"
		},
		Infinite = {
			Back = "rbxassetid://14358449723",
			Down = "rbxassetid://14358455642",
			Front = "rbxassetid://14358452362",
			Left = "rbxassetid://14358784700",
			Right = "rbxassetid://14358454172",
			Up = "rbxassetid://14358455112"
		}
	}

	local function clearLighting()
		for _, v in pairs(Lighting:GetChildren()) do
			if v:IsA("Sky") or v:IsA("ColorCorrectionEffect") or v:IsA("SunRaysEffect") or v:IsA("Atmosphere") then
				v:Destroy()
			end
		end
	end

	local function applygametheme(themeseletced)
		local theme = skyboxes[themeseletced]
		if not theme then return end

		clearLighting()

		local sky = Instance.new("Sky", Lighting)
		sky.SkyboxBk = theme.Back
		sky.SkyboxDn = theme.Down
		sky.SkyboxFt = theme.Front
		sky.SkyboxLf = theme.Left
		sky.SkyboxRt = theme.Right
		sky.SkyboxUp = theme.Up

		if themeselected == "NebulaSky" then
			local cc = Instance.new("ColorCorrectionEffect", Lighting)
			cc.Brightness = 0.1
			cc.Contrast = 0.5
			cc.Saturation = -0.3
			cc.TintColor = Color3.fromRGB(255, 235, 203)

			local rays = Instance.new("SunRaysEffect", Lighting)
			rays.Intensity = 0.075
			rays.Spread = 0.727

			local atm = Instance.new("Atmosphere", Lighting)
			atm.Density = 0.364
			atm.Offset = 0.556
			atm.Color = theme.AtmosphereColor
			atm.Decay = theme.AtmosphereDecay
			atm.Glare = 0.36
			atm.Haze = 1.72

			Lighting.Brightness = 0.3
			Lighting.Ambient = Color3.fromRGB(2, 2, 2)
			Lighting.GlobalShadows = true
			Lighting.ClockTime = 15
			Lighting.ShadowSoftness = 0.2
			Lighting.ExposureCompensation = 0.5
		end

		if themeselected == "EgirlSky" then
			local atm = Lighting:FindFirstChildOfClass("Atmosphere") or Instance.new("Atmosphere", Lighting)
			atm.Color = Color3.fromRGB(255, 214, 172)
			atm.Decay = Color3.fromRGB(255, 202, 175)

			if sky then
				sky.MoonTextureId = "rbxassetid://8139665943"
				sky.MoonAngularSize = 11
				sky.SunAngularSize = 4
			end
		end
	end

	GameThemeV2 = vape.Categories.World:CreateModule({
		["Name"] = "GameThemesV2",
		["Function"] = function(callback)
			if callback then
				if not transformed then
					transformed = true
					applyTheme(themeselected["Value"])
				else
					GameThemeV2["ToggleButton"](false)
				end
			else
				notify("GameThemeV2", "Disabled Next Game", 10)
			end
		end,
		["ExtraText"] = function()
			return themeselector["Value"]
		end
	})

	themeselector = GameThemeV2.CreateDropdown({
		["Name"] = "Theme",
		["Function"] = function() end,
		["List"] = {
			"NebulaSky", "PinkMountainSky",
			"CitySky", "PinkSky",
			"EgirlSky", "SpaceSky",
			"Infinite"
		}
	})
end)

run(function()
    TexturePacks = vape.Categories.Render:CreateModule({
        Name = "TexturePacks",
        Function = function(callback)
            if callback then
            	local TexturePacks = {["Enabled"] = false}
	            local TexturePackSelected = {["Value"] = "5x"}
	            
	            if TexturePackSelected.Value = "5x" then
	            local Players = game:GetService("Players")
                    local ReplicatedStorage = game:GetService("ReplicatedStorage")
                    local Workspace = game:GetService("Workspace")
                    local objs = game:GetObjects("rbxassetid://14313875107")
                    local import = objs[1]
                    import.Parent = game:GetService("ReplicatedStorage")
                    index = {
                        {
                            name = "wood_sword",
                            offset = CFrame.Angles(math.rad(0),math.rad(-100),math.rad(-90)),
                            model = import:WaitForChild("Wood_Sword"),
                        },
                        {
                            name = "stone_sword",
                            offset = CFrame.Angles(math.rad(0),math.rad(-100),math.rad(-90)),
                            model = import:WaitForChild("Stone_Sword"),
                        },
                        {
                            name = "iron_sword",
                            offset = CFrame.Angles(math.rad(0),math.rad(-100),math.rad(-90)),
                            model = import:WaitForChild("Iron_Sword"),
                       },
                       {
                            name = "diamond_sword",
                            offset = CFrame.Angles(math.rad(0),math.rad(-100),math.rad(-90)),
                            model = import:WaitForChild("Diamond_Sword"),
                        },
                        {
                            name = "emerald_sword",
                            offset = CFrame.Angles(math.rad(0),math.rad(-100),math.rad(-90)),
                            model = import:WaitForChild("Emerald_Sword"),
                        }
  
                    }
                    local func = Workspace:WaitForChild("Camera").Viewmodel.ChildAdded:Connect(function(tool)
                        if(not tool:IsA("Accessory")) then return end
                        for i,v in pairs(index) do
                            
                            if(v.name == tool.Name) then
                                for i,v in pairs(tool:GetDescendants()) do
                                    if(v:IsA("Part") or v:IsA("MeshPart") or v:IsA("UnionOperation")) then
                                            v.Transparency = 1
                                    end
                                end
                                local model = v.model:Clone()
                                model.CFrame = tool:WaitForChild("Handle").CFrame * v.offset
                                model.CFrame *= CFrame.Angles(math.rad(0),math.rad(-50),math.rad(0))
                                model.Parent = tool
                                local weld = Instance.new("WeldConstraint",model)
                                weld.Part0 = model
                                weld.Part1 = tool:WaitForChild("Handle")
                                local tool2 = Players.LocalPlayer.Character:WaitForChild(tool.Name)
                                for i,v in pairs(tool2:GetDescendants()) do
                                    if(v:IsA("Part") or v:IsA("MeshPart") or v:IsA("UnionOperation")) then
                                        v.Transparency = 1
                                    end
                                end
                                local model2 = v.model:Clone()
                                model2.Anchored = false
                                model2.CFrame = tool2:WaitForChild("Handle").CFrame * v.offset
                                model2.CFrame *= CFrame.Angles(math.rad(0),math.rad(-50),math.rad(0))
                                model2.CFrame *= CFrame.new(.7,0,-.8)
                                model2.Parent = tool2
                                local weld2 = Instance.new("WeldConstraint",model)
                                weld2.Part0 = model2
                                weld2.Part1 = tool2:WaitForChild("Handle")
                            end
                        end
                    end,
	                elseif TexturePackSelected.Value = "16x" then
	                local Players = game:GetService("Players")
                    local ReplicatedStorage = game:GetService("ReplicatedStorage")
                    local Workspace = game:GetService("Workspace")
                    local objs = game:GetObjects("rbxassetid://14329464322")
                    local import = objs[1]
                    import.Parent = game:GetService("ReplicatedStorage")
                    index = {
                        {
                            name = "wood_sword",
                            offset = CFrame.Angles(math.rad(0),math.rad(-100),math.rad(-90)),
                            model = import:WaitForChild("Wood_Sword"),
                        },
                        {
                            name = "stone_sword",
                            offset = CFrame.Angles(math.rad(0),math.rad(-100),math.rad(-90)),
                            model = import:WaitForChild("Stone_Sword"),
                        },
                        {
                            name = "iron_sword",
                            offset = CFrame.Angles(math.rad(0),math.rad(-100),math.rad(-90)),
                            model = import:WaitForChild("Iron_Sword"),
                       },
                       {
                            name = "diamond_sword",
                            offset = CFrame.Angles(math.rad(0),math.rad(-100),math.rad(-90)),
                            model = import:WaitForChild("Diamond_Sword"),
                        },
                        {
                            name = "emerald_sword",
                            offset = CFrame.Angles(math.rad(0),math.rad(-100),math.rad(-90)),
                            model = import:WaitForChild("Emerald_Sword"),
                        }
  
                    }
                    local func = Workspace:WaitForChild("Camera").Viewmodel.ChildAdded:Connect(function(tool)
                        if(not tool:IsA("Accessory")) then return end
                        for i,v in pairs(index) do
                            
                            if(v.name == tool.Name) then
                                for i,v in pairs(tool:GetDescendants()) do
                                    if(v:IsA("Part") or v:IsA("MeshPart") or v:IsA("UnionOperation")) then
                                            v.Transparency = 1
                                    end
                                end
                                local model = v.model:Clone()
                                model.CFrame = tool:WaitForChild("Handle").CFrame * v.offset
                                model.CFrame *= CFrame.Angles(math.rad(0),math.rad(-50),math.rad(0))
                                model.Parent = tool
                                local weld = Instance.new("WeldConstraint",model)
                                weld.Part0 = model
                                weld.Part1 = tool:WaitForChild("Handle")
                                local tool2 = Players.LocalPlayer.Character:WaitForChild(tool.Name)
                                for i,v in pairs(tool2:GetDescendants()) do
                                    if(v:IsA("Part") or v:IsA("MeshPart") or v:IsA("UnionOperation")) then
                                        v.Transparency = 1
                                    end
                                end
                                local model2 = v.model:Clone()
                                model2.Anchored = false
                                model2.CFrame = tool2:WaitForChild("Handle").CFrame * v.offset
                                model2.CFrame *= CFrame.Angles(math.rad(0),math.rad(-50),math.rad(0))
                                model2.CFrame *= CFrame.new(.7,0,-.8)
                                model2.Parent = tool2
                                local weld2 = Instance.new("WeldConstraint",model)
                                weld2.Part0 = model2
                                weld2.Part1 = tool2:WaitForChild("Handle")
                            end
                        end
                    end,
	                elseif TexturePackSelected.Value = "32x" then
	                local Players = game:GetService("Players")
                    local ReplicatedStorage = game:GetService("ReplicatedStorage")
                    local Workspace = game:GetService("Workspace")
                    local objs = game:GetObjects("rbxassetid://14336613684")
                    local import = objs[1]
                    import.Parent = game:GetService("ReplicatedStorage")
                    index = {
                        {
                            name = "wood_sword",
                            offset = CFrame.Angles(math.rad(0),math.rad(-100),math.rad(-90)),
                            model = import:WaitForChild("Wood_Sword"),
                        },
                        {
                            name = "stone_sword",
                            offset = CFrame.Angles(math.rad(0),math.rad(-100),math.rad(-90)),
                            model = import:WaitForChild("Stone_Sword"),
                        },
                        {
                            name = "iron_sword",
                            offset = CFrame.Angles(math.rad(0),math.rad(-100),math.rad(-90)),
                            model = import:WaitForChild("Iron_Sword"),
                       },
                       {
                            name = "diamond_sword",
                            offset = CFrame.Angles(math.rad(0),math.rad(-100),math.rad(-90)),
                            model = import:WaitForChild("Diamond_Sword"),
                        },
                        {
                            name = "emerald_sword",
                            offset = CFrame.Angles(math.rad(0),math.rad(-100),math.rad(-90)),
                            model = import:WaitForChild("Emerald_Sword"),
                        }
  
                    }
                    local func = Workspace:WaitForChild("Camera").Viewmodel.ChildAdded:Connect(function(tool)
                        if(not tool:IsA("Accessory")) then return end
                        for i,v in pairs(index) do
                            
                            if(v.name == tool.Name) then
                                for i,v in pairs(tool:GetDescendants()) do
                                    if(v:IsA("Part") or v:IsA("MeshPart") or v:IsA("UnionOperation")) then
                                            v.Transparency = 1
                                    end
                                end
                                local model = v.model:Clone()
                                model.CFrame = tool:WaitForChild("Handle").CFrame * v.offset
                                model.CFrame *= CFrame.Angles(math.rad(0),math.rad(-50),math.rad(0))
                                model.Parent = tool
                                local weld = Instance.new("WeldConstraint",model)
                                weld.Part0 = model
                                weld.Part1 = tool:WaitForChild("Handle")
                                local tool2 = Players.LocalPlayer.Character:WaitForChild(tool.Name)
                                for i,v in pairs(tool2:GetDescendants()) do
                                    if(v:IsA("Part") or v:IsA("MeshPart") or v:IsA("UnionOperation")) then
                                        v.Transparency = 1
                                    end
                                end
                                local model2 = v.model:Clone()
                                model2.Anchored = false
                                model2.CFrame = tool2:WaitForChild("Handle").CFrame * v.offset
                                model2.CFrame *= CFrame.Angles(math.rad(0),math.rad(-50),math.rad(0))
                                model2.CFrame *= CFrame.new(.7,0,-.8)
                                model2.Parent = tool2
                                local weld2 = Instance.new("WeldConstraint",model)
                                weld2.Part0 = model2
                                weld2.Part1 = tool2:WaitForChild("Handle")
                            end
                        end
                    end,
	                elseif TexturePackSelected = "Storm" then
                        workspace.CurrentCamera.Viewmodel.ChildAdded:Connect(function(x)
                            if x and x:FindFirstChild("Handle") then
                                if string.find(x.Name:lower(), 'sword') then
                                    x.Handle.Material = "ForceField"
                                    x.Handle.MeshId = "rbxassetid://13471207377"
                                    x.Handle.BrickColor = BrickColor.new("Hot pink")
                                end
                            end
                        end)
	                end
                end
            end
        end
    end
    )}
	TexturePackSelected = TexturePacks.CreateDropdown({
		["Name"] = "TexturePack",
		["Function"] = function() end,
		["List"] = {"16x", "5x", 
		"Storm", "32x"}
	)}
end)		
