if getgenv().ScriptAlreadyLoaded then
	warn("[RG] already loaded")
	return
end
getgenv().ScriptAlreadyLoaded = true

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Lighting = game:GetService("Lighting")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local SETTINGS_FILE = "rg_settings.json"
local SILENTAIM_FILE = "rg_aim.json"

local scriptIsKilled = false

local Remotes = ReplicatedStorage:WaitForChild("Remotes", 10)
local UpdateCharData = Remotes and Remotes:FindFirstChild("UpdateCharData")

getgenv().SilentAim = getgenv().SilentAim or {}
local SilentAim = getgenv().SilentAim

SilentAim.Enabled = SilentAim.Enabled or false
SilentAim.Mode = SilentAim.Mode or "Blacklist"
SilentAim.IgnoreAlly = SilentAim.IgnoreAlly or false
SilentAim.LongerHit = SilentAim.LongerHit or false
SilentAim.UseRosterCF = SilentAim.UseRosterCF or false
SilentAim.MouseSilent = SilentAim.MouseSilent or false
SilentAim.TargetPart = SilentAim.TargetPart or "HumanoidRootPart"

SilentAim.Physics = SilentAim.Physics or {
	SkillSpeed = 1000,
	PredictionTime = 0.15,
	Interval = 1/30,
	PingMultiplier = 0.75,
	DashThreshold = 80,
	DashLeadTime = 0.08,
}

SilentAim.FakePing = SilentAim.FakePing or {
	Enabled = false,
	Amount = 0,
}

SilentAim.FOV = SilentAim.FOV or {
	Enabled = false,
	Radius = 300,
	Visible = false,
	Thickness = 2,
	Color = Color3.new(1, 1, 1),
}

SilentAim.Highlight = SilentAim.Highlight or {
	Enabled = false,
	OutlineColor = Color3.new(0, 1, 0),
	OutlineTransparency = 0.5,
	FillColor = Color3.new(1, 0, 0),
	FillTransparency = 0.8,
}

SilentAim.DirectionLine = SilentAim.DirectionLine or {
	Enabled = false,
	Color = Color3.new(1, 1, 1),
	Thickness = 2,
}

SilentAim.Humanize = SilentAim.Humanize or {
	Enabled = false,
	Spread = 0.5,
}

SilentAim.Whitelist = SilentAim.Whitelist or {}
SilentAim.Blacklist = SilentAim.Blacklist or {}
SilentAim.CurrentTarget = nil
SilentAim.PredictedCF = nil
SilentAim.ScreenPos = nil
SilentAim.TargetGetAttacked = false
SilentAim.PlayerList = {}
SilentAim.Highlights = {}

_G.CurrentSettings = _G.CurrentSettings or {
	AntiDelay = false,
	Webhook = {
		Enabled = false,
		URL = "",
		SendStats = false,
		Interval = 60,
		PingEveryone = false,
		KickNotifier = false,
	},
}

_G.NoDelay = _G.NoDelay or false
_G.AntiDelayConnection = nil

local LightingState = {
	Active = false,
	FullBrightActive = false,
	SavedProperties = {},
	SavedSky = nil,
	LocalTransparencyConnection = nil,
}

local CameraState = {
	FieldOfView = 90,
	FieldOfViewConnection = nil,
}

local historyByPlayer = {}
local predictionError = Vector3.zero
local previousSmoothedVelocity = nil
local lastPredictedPosition = nil
local trackingConnection = nil

local warnedErrors = {}
local function warnOnce(key, message)
	if warnedErrors[key] then return end
	warnedErrors[key] = true
	warn("[RG] " .. message)
end

local function recordSample(player, root)
	if not historyByPlayer[player] then
		historyByPlayer[player] = {}
	end
	local historyBuffer = historyByPlayer[player]
	table.insert(historyBuffer, {
		time = tick(),
		position = root.Position,
		velocity = root.AssemblyLinearVelocity or root.Velocity,
	})
	while #historyBuffer > 8 do
		table.remove(historyBuffer, 1)
	end
end

local function smoothedVelocity(player, root)
	local historyBuffer = historyByPlayer[player]
	if not historyBuffer or #historyBuffer < 2 then
		return root.AssemblyLinearVelocity or root.Velocity
	end
	local weightedSum = Vector3.zero
	local weightedTotal = 0
	for i = 2, #historyBuffer do
		local dt = historyBuffer[i].time - historyBuffer[i-1].time
		if dt > 0 then
			local frameVelocity = (historyBuffer[i].position - historyBuffer[i-1].position) / dt
			weightedSum = weightedSum + frameVelocity * i
			weightedTotal = weightedTotal + i
		end
	end
	if weightedTotal <= 0 then return root.AssemblyLinearVelocity or root.Velocity end
	return weightedSum / weightedTotal
end

local function getAcceleration(player)
	local historyBuffer = historyByPlayer[player]
	if not historyBuffer or #historyBuffer < 3 then return Vector3.zero end
	local velocitySamples = {}
	for i = 2, #historyBuffer do
		local dt = historyBuffer[i].time - historyBuffer[i-1].time
		if dt > 0 then
			table.insert(velocitySamples, (historyBuffer[i].position - historyBuffer[i-1].position) / dt)
		end
	end
	if #velocitySamples < 2 then return Vector3.zero end
	local totalTime = historyBuffer[#historyBuffer].time - historyBuffer[2].time
	if totalTime <= 0 then return Vector3.zero end
	return (velocitySamples[#velocitySamples] - velocitySamples[1]) / totalTime
end

local function getConfidence(player, vel)
	local historyBuffer = historyByPlayer[player]
	if not historyBuffer or #historyBuffer < 3 then return 0.5 end
	local deviationSum = 0
	local count = 0
	for i = 2, #historyBuffer do
		local dt = historyBuffer[i].time - historyBuffer[i-1].time
		if dt > 0 then
			deviationSum = deviationSum + ((historyBuffer[i].position - historyBuffer[i-1].position) / dt - vel).Magnitude
			count = count + 1
		end
	end
	if count == 0 then return 0.5 end
	return math.clamp(1 - (deviationSum / count) / 30, 0.2, 1)
end

local function detectMovementState(vel, previousVelocity)
	if previousVelocity then
		if (vel - previousVelocity).Magnitude > SilentAim.Physics.DashThreshold then
			return "dash"
		end
	end
	local verticalSpeed = math.abs(vel.Y)
	local horizontalSpeed = Vector3.new(vel.X, 0, vel.Z).Magnitude
	if verticalSpeed > 8 then return vel.Y > 0 and "jumping" or "falling" end
	if horizontalSpeed < 2 then return "stationary" end
	return "walking"
end

local function getPing()
	local stats = game:GetService("Stats")
	if stats then
		local net = stats:FindFirstChild("Network")
		if net then
			local item = net:FindFirstChild("ServerStatsItem")
			if item then return item.Value end
		end
	end
	if LocalPlayer and LocalPlayer:GetAttribute("Ping") then
		return LocalPlayer:GetAttribute("Ping")
	end
	return 80
end

local function updateErrorFeedback(target)
	if not lastPredictedPosition then return end
	local char = target and target.Character
	local root = char and char:FindFirstChild("HumanoidRootPart")
	if not root then return end
	predictionError = (predictionError + (root.Position - lastPredictedPosition) * 0.05) * 0.95
end

function SilentAim:PredictPosition(target)
	local char = target.Character
	if not char then return nil end
	local root = char:FindFirstChild("HumanoidRootPart")
	if not root then return nil end
	local myChar = LocalPlayer.Character
	local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")

	recordSample(target, root)

	local vel = smoothedVelocity(target, root)
	local accel = getAcceleration(target)
	local confidenceScore = getConfidence(target, vel)
	local state = detectMovementState(vel, previousSmoothedVelocity)
	previousSmoothedVelocity = vel

	local pingSeconds = getPing() / 1000
	local distance = myRoot and (root.Position - myRoot.Position).Magnitude or 0
	local travelTime = SilentAim.Physics.SkillSpeed > 0 and distance / SilentAim.Physics.SkillSpeed or 0
	local baseTime = pingSeconds * SilentAim.Physics.PingMultiplier + travelTime + SilentAim.Physics.PredictionTime
	local time = baseTime * confidenceScore
	local gravity = Vector3.new(0, -workspace.Gravity * 0.5, 0)

	local predicted
	if state == "stationary" then
		predicted = root.Position + vel * (time * 0.2)
	elseif state == "dash" then
		local direction = Vector3.new(vel.X, 0, vel.Z).Unit
		predicted = root.Position + direction * (vel.Magnitude * (time + SilentAim.Physics.DashLeadTime))
	elseif state == "jumping" or state == "falling" then
		local effectiveAcceleration = accel + gravity
		predicted = root.Position + vel * time + effectiveAcceleration * (time * time * 0.5)
	else
		predicted = root.Position + vel * time + accel * (time * time * 0.5)
	end

	predicted = predicted + predictionError * 0.3

	if SilentAim.Humanize.Enabled and SilentAim.Humanize.Spread > 0 then
		predicted = predicted + Vector3.new(
			(math.random() - 0.5) * SilentAim.Humanize.Spread * 2,
			(math.random() - 0.5) * SilentAim.Humanize.Spread * 2,
			(math.random() - 0.5) * SilentAim.Humanize.Spread * 2
		)
	end

	lastPredictedPosition = predicted
	return predicted, root
end

local function isValidTarget(player)
	if player == LocalPlayer then return false end
	if not player.Character then return false end
	if not player.Character:FindFirstChild("HumanoidRootPart") then return false end
	local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
	if not humanoid or humanoid.Health <= 0 then return false end
	if SilentAim.Mode == "Whitelist" then
		if not SilentAim.Whitelist[player.UserId] then return false end
	else
		if SilentAim.Blacklist[player.UserId] then return false end
	end
	return true
end

local function findBestTarget()
	local mousePosition = UserInputService:GetMouseLocation()
	local bestTarget = nil
	local bestDistance = SilentAim.FOV.Enabled and SilentAim.FOV.Radius or math.huge
	for _, player in ipairs(Players:GetPlayers()) do
		if isValidTarget(player) then
			local root = player.Character:FindFirstChild(SilentAim.TargetPart)
				or player.Character:FindFirstChild("HumanoidRootPart")
			if root then
				local screenPosition, onScreen = Camera:WorldToViewportPoint(root.Position)
				if onScreen then
					local distance = (Vector2.new(screenPosition.X, screenPosition.Y) - mousePosition).Magnitude
					if distance < bestDistance then
						bestDistance = distance
						bestTarget = player
					end
				end
			end
		end
	end
	return bestTarget
end

local fieldOfViewGui = Instance.new("ScreenGui")
fieldOfViewGui.Name = "RGFieldOfView"
fieldOfViewGui.ResetOnSpawn = false
fieldOfViewGui.DisplayOrder = -9999
fieldOfViewGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
local syn = rawget(_G, "syn")
if syn and syn.protect_gui then
	local ok, err = pcall(syn.protect_gui, fieldOfViewGui)
	if not ok then warnOnce("protectGui", "syn.protect_gui failed: " .. tostring(err)) end
end
fieldOfViewGui.Parent = game:GetService("CoreGui")

local fieldOfViewFrame = Instance.new("Frame")
fieldOfViewFrame.AnchorPoint = Vector2.new(0.5, 0.5)
fieldOfViewFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
fieldOfViewFrame.Size = UDim2.new(0, SilentAim.FOV.Radius * 2, 0, SilentAim.FOV.Radius * 2)
fieldOfViewFrame.BackgroundTransparency = 1
fieldOfViewFrame.Visible = false
fieldOfViewFrame.Parent = fieldOfViewGui

local fieldOfViewCorner = Instance.new("UICorner")
fieldOfViewCorner.CornerRadius = UDim.new(1, 0)
fieldOfViewCorner.Parent = fieldOfViewFrame

local fieldOfViewStroke = Instance.new("UIStroke")
fieldOfViewStroke.Thickness = SilentAim.FOV.Thickness
fieldOfViewStroke.Color = SilentAim.FOV.Color
fieldOfViewStroke.Parent = fieldOfViewFrame

local function setFieldOfViewRadius(radius)
	SilentAim.FOV.Radius = radius
	fieldOfViewFrame.Size = UDim2.new(0, radius * 2, 0, radius * 2)
end

local directionLine = Drawing.new("Line")
directionLine.Visible = false
directionLine.Color = SilentAim.DirectionLine.Color
directionLine.Thickness = SilentAim.DirectionLine.Thickness
directionLine.Transparency = 1

local function updateDrawings(root, predicted)
	fieldOfViewFrame.Visible = SilentAim.FOV.Enabled and SilentAim.FOV.Visible
	if SilentAim.DirectionLine.Enabled and root and predicted then
		local fromScreenPosition, fromVisible = Camera:WorldToViewportPoint(root.Position)
		local toScreenPosition, toVisible = Camera:WorldToViewportPoint(predicted)
		if fromVisible and toVisible then
			directionLine.From = Vector2.new(fromScreenPosition.X, fromScreenPosition.Y)
			directionLine.To = Vector2.new(toScreenPosition.X, toScreenPosition.Y)
			directionLine.Color = SilentAim.DirectionLine.Color
			directionLine.Thickness = SilentAim.DirectionLine.Thickness
			directionLine.Visible = true
		else
			directionLine.Visible = false
		end
	else
		directionLine.Visible = false
	end
end

local function applyHighlight(player)
	if not SilentAim.Highlight.Enabled then return end
	if SilentAim.Highlights[player] then return end
	local existing = player.Character and player.Character:FindFirstChildOfClass("Highlight")
	local highlight = existing or Instance.new("Highlight")
	highlight.OutlineColor = SilentAim.Highlight.OutlineColor
	highlight.OutlineTransparency = SilentAim.Highlight.OutlineTransparency
	highlight.FillColor = SilentAim.Highlight.FillColor
	highlight.FillTransparency = SilentAim.Highlight.FillTransparency
	if not existing and player.Character then highlight.Parent = player.Character end
	SilentAim.Highlights[player] = highlight
end

local function removeHighlight(player)
	local highlight = SilentAim.Highlights[player]
	if highlight then
		highlight:Destroy()
		SilentAim.Highlights[player] = nil
	end
end

local function clearHighlights()
	for player in pairs(SilentAim.Highlights) do
		removeHighlight(player)
	end
end

local function enableAntiDelay()
	if _G.NoDelay then return end
	_G.NoDelay = true
	_G.AntiDelayConnection = RunService.Heartbeat:Connect(function()
		local char = LocalPlayer.Character
		if not char then return end
		local humanoid = char:FindFirstChildOfClass("Humanoid")
		if humanoid then humanoid:SetAttribute("Attacking", false) end
	end)
end

local function disableAntiDelay()
	_G.NoDelay = false
	if _G.AntiDelayConnection then
		_G.AntiDelayConnection:Disconnect()
		_G.AntiDelayConnection = nil
	end
end

_G.ToggleAntiDelay = function(enabled)
	if enabled then enableAntiDelay() else disableAntiDelay() end
end

local function restoreLighting()
	if not LightingState.Active then return end
	LightingState.Active = false
	LightingState.FullBrightActive = false
	for key, value in pairs(LightingState.SavedProperties) do
		Lighting[key] = value
	end
	if LightingState.SavedSky then
		LightingState.SavedSky.Parent = Lighting
		LightingState.SavedSky = nil
	end
	if LightingState.LocalTransparencyConnection then
		LightingState.LocalTransparencyConnection:Disconnect()
		LightingState.LocalTransparencyConnection = nil
	end
end

local function applyBrightness(val)
	if not LightingState.Active then
		LightingState.Active = true
		LightingState.SavedProperties = {
			Brightness = Lighting.Brightness,
			ClockTime = Lighting.ClockTime,
			FogEnd = Lighting.FogEnd,
			FogStart = Lighting.FogStart,
			GlobalShadows = Lighting.GlobalShadows,
			Ambient = Lighting.Ambient,
			OutdoorAmbient = Lighting.OutdoorAmbient,
		}
		local sky = Lighting:FindFirstChildOfClass("Sky")
		if sky then
			LightingState.SavedSky = sky
			sky.Parent = nil
		end
	end
	local brightness = val / 10
	Lighting.Brightness = brightness * 5
	Lighting.Ambient = Color3.new(brightness, brightness, brightness)
	Lighting.OutdoorAmbient = Color3.new(brightness, brightness, brightness)
	Lighting.ShadowSoftness = 0
	Lighting.GlobalShadows = false
	Lighting.FogEnd = 100000
	Lighting.FogStart = 100000
	for _, child in pairs(Lighting:GetChildren()) do
		if child:IsA("Sky") then child:Destroy() end
	end
	if not LightingState.LocalTransparencyConnection then
		local function fixTransparency(part)
			if part:IsA("BasePart") and part.Transparency < 1 then
				part.LocalTransparencyModifier = 0
			end
		end
		for _, descendant in pairs(workspace:GetDescendants()) do
			fixTransparency(descendant)
		end
		LightingState.LocalTransparencyConnection = workspace.DescendantAdded:Connect(fixTransparency)
	end
end

local function setCameraFieldOfView(fov)
	CameraState.FieldOfView = fov
	local ok, err = pcall(function() workspace.CurrentCamera.FieldOfView = fov end)
	if not ok then warnOnce("setCameraFOV", "failed to set camera FOV: " .. tostring(err)) end
	if not CameraState.FieldOfViewConnection then
		CameraState.FieldOfViewConnection = workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
			task.defer(function()
				local ok2, err2 = pcall(function() workspace.CurrentCamera.FieldOfView = CameraState.FieldOfView end)
				if not ok2 then warnOnce("setCameraFOVDefer", "camera FOV restore failed: " .. tostring(err2)) end
			end)
		end)
	end
end

_G.HopServer = function()
	game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, game.JobId)
end

_G.RejoinServer = function()
	game:GetService("TeleportService"):Teleport(game.PlaceId, LocalPlayer)
end

local function loadSettings()
	if not (readfile and isfile(SETTINGS_FILE)) then return end
	local ok, data = pcall(function()
		return game:GetService("HttpService"):JSONDecode(readfile(SETTINGS_FILE))
	end)
	if not ok or not data then
		warnOnce("loadSettings", "failed to load settings file")
		return
	end
	for key, value in pairs(data) do
		_G.CurrentSettings[key] = value
	end
end

local function saveSettings()
	if not writefile then return end
	local ok, encoded = pcall(function()
		return game:GetService("HttpService"):JSONEncode(_G.CurrentSettings)
	end)
	if ok then
		writefile(SETTINGS_FILE, encoded)
	else
		warnOnce("saveSettings", "failed to encode settings")
	end
end

local function loadSilentAimSettings()
	if not (readfile and isfile(SILENTAIM_FILE)) then return end
	local ok, data = pcall(function()
		return game:GetService("HttpService"):JSONDecode(readfile(SILENTAIM_FILE))
	end)
	if not ok or not data then
		warnOnce("loadSilentAimSettings", "failed to load silent aim settings file")
		return
	end
	for _, key in ipairs({"Enabled","Mode","IgnoreAlly","LongerHit","UseRosterCF","MouseSilent","TargetPart"}) do
		if data[key] ~= nil then SilentAim[key] = data[key] end
	end
	if data.Physics then
		for key, value in pairs(data.Physics) do
			if SilentAim.Physics[key] ~= nil and type(value) ~= "table" then
				SilentAim.Physics[key] = value
			end
		end
	end
	if data.FOV then
		for key, value in pairs(data.FOV) do
			if key ~= "Color" and SilentAim.FOV[key] ~= nil then SilentAim.FOV[key] = value end
		end
	end
	if data.FakePing then
		for key, value in pairs(data.FakePing) do
			if SilentAim.FakePing[key] ~= nil then SilentAim.FakePing[key] = value end
		end
	end
	if data.Humanize then
		for key, value in pairs(data.Humanize) do
			if SilentAim.Humanize[key] ~= nil then SilentAim.Humanize[key] = value end
		end
	end
	if data.DirectionLine then
		for key, value in pairs(data.DirectionLine) do
			if key ~= "Color" and SilentAim.DirectionLine[key] ~= nil then SilentAim.DirectionLine[key] = value end
		end
	end
end

local function saveSilentAimSettings()
	if not writefile then return end
	local snapshot = {
		Enabled = SilentAim.Enabled,
		Mode = SilentAim.Mode,
		IgnoreAlly = SilentAim.IgnoreAlly,
		LongerHit = SilentAim.LongerHit,
		UseRosterCF = SilentAim.UseRosterCF,
		MouseSilent = SilentAim.MouseSilent,
		TargetPart = SilentAim.TargetPart,
		Physics = {
			SkillSpeed = SilentAim.Physics.SkillSpeed,
			PredictionTime = SilentAim.Physics.PredictionTime,
			Interval = SilentAim.Physics.Interval,
			PingMultiplier = SilentAim.Physics.PingMultiplier,
			DashThreshold = SilentAim.Physics.DashThreshold,
			DashLeadTime = SilentAim.Physics.DashLeadTime,
		},
		FOV = {
			Enabled = SilentAim.FOV.Enabled,
			Radius = SilentAim.FOV.Radius,
			Visible = SilentAim.FOV.Visible,
			Thickness = SilentAim.FOV.Thickness,
		},
		FakePing = {
			Enabled = SilentAim.FakePing.Enabled,
			Amount = SilentAim.FakePing.Amount,
		},
		Humanize = {
			Enabled = SilentAim.Humanize.Enabled,
			Spread = SilentAim.Humanize.Spread,
		},
		DirectionLine = {
			Enabled = SilentAim.DirectionLine.Enabled,
			Thickness = SilentAim.DirectionLine.Thickness,
		},
	}
	local ok, encoded = pcall(function()
		return game:GetService("HttpService"):JSONEncode(snapshot)
	end)
	if ok then
		writefile(SILENTAIM_FILE, encoded)
	else
		warnOnce("saveSilentAimSettings", "failed to encode silent aim settings")
	end
end

local function setupFakePing()
	if not SilentAim.FakePing.Enabled or SilentAim.FakePing.Amount <= 0 then return end
	local remote = Remotes and Remotes:FindFirstChild("GetPing")
	if not remote then
		warnOnce("fakePingRemote", "GetPing remote not found — fake ping disabled")
		return
	end
	remote.OnClientInvoke = function(...)
		task.wait(SilentAim.FakePing.Amount / 1000)
		return ...
	end
end

local function startTracking()
	if trackingConnection then return end
	trackingConnection = RunService.Heartbeat:Connect(function()
		if scriptIsKilled or not SilentAim.Enabled then
			SilentAim.CurrentTarget = nil
			SilentAim.PredictedCF = nil
			SilentAim.ScreenPos = nil
			updateDrawings(nil, nil)
			clearHighlights()
			return
		end
		if SilentAim.CurrentTarget then
			updateErrorFeedback(SilentAim.CurrentTarget)
		end
		local target = findBestTarget()
		SilentAim.CurrentTarget = target
		if not target then
			SilentAim.PredictedCF = nil
			SilentAim.ScreenPos = nil
			updateDrawings(nil, nil)
			return
		end
		if SilentAim.Highlight.Enabled then
			applyHighlight(target)
		end
		local predicted, root = SilentAim:PredictPosition(target)
		if not predicted or not root then
			SilentAim.PredictedCF = nil
			updateDrawings(nil, nil)
			return
		end
		local myChar = LocalPlayer.Character
		local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
		if myRoot then
			SilentAim.PredictedCF = CFrame.lookAt(
				Vector3.new(myRoot.Position.X, predicted.Y, myRoot.Position.Z),
				Vector3.new(predicted.X, predicted.Y, predicted.Z)
			)
		end
		local screenPosition, onScreen = Camera:WorldToViewportPoint(predicted)
		if onScreen then
			SilentAim.ScreenPos = Vector2.new(screenPosition.X, screenPosition.Y)
		end
		updateDrawings(root, predicted)
	end)
end

if not getgenv().OriginalNamecallHook then
	getgenv().OriginalNamecallHook = hookmetamethod(game, "__namecall", function(...)
		local args = table.pack(...)
		local self = args[1]
		if scriptIsKilled
			or not SilentAim.Enabled
			or self ~= UpdateCharData
			or getnamecallmethod() ~= "FireServer"
		then
			return getgenv().OriginalNamecallHook(table.unpack(args, 1, args.n))
		end
		if not SilentAim.PredictedCF or SilentAim.TargetGetAttacked then
			return getgenv().OriginalNamecallHook(table.unpack(args, 1, args.n))
		end
		local modifiedArgs = table.pack(table.unpack(args, 1, args.n))
		modifiedArgs[2] = SilentAim.PredictedCF
		if (SilentAim.LongerHit or SilentAim.MouseSilent) and SilentAim.ScreenPos then
			modifiedArgs[3] = SilentAim.ScreenPos
		end
		if SilentAim.UseRosterCF and SilentAim.CurrentTarget then
			local targetChar = SilentAim.CurrentTarget.Character
			local targetRoot = targetChar and targetChar:FindFirstChild("HumanoidRootPart")
			if targetRoot then modifiedArgs[4] = targetRoot.CFrame end
		end
		return getgenv().OriginalNamecallHook(table.unpack(modifiedArgs, 1, modifiedArgs.n))
	end)
end

local puppywareWindow = loadstring(game:HttpGet("https://raw.githubusercontent.com/imagoodpersond/puppyware/main/lib"))()
	:new({ name = "", color = Color3.fromRGB(0, 210, 255) })

local silentAimPage = puppywareWindow:page({ name = "Silent Aim" })
local predictionPage = puppywareWindow:page({ name = "Prediction" })
local miscellaneousPage = puppywareWindow:page({ name = "Misc" })

local ok, err = pcall(silentAimPage.openpage, silentAimPage)
if not ok then warnOnce("openPage", "failed to open silent aim page: " .. tostring(err)) end

local silentAimSection = silentAimPage:section({ name = "Silent Aim", side = "left", size = 180 })

silentAimSection:toggle({
	name = "Enable",
	def = SilentAim.Enabled,
	callback = function(v)
		SilentAim.Enabled = v
		if not v then clearHighlights() end
	end,
})

silentAimSection:dropdown({
	name = "Mode",
	def = SilentAim.Mode,
	options = {"Blacklist", "Whitelist"},
	callback = function(v)
		SilentAim.Mode = v
	end,
})

silentAimSection:toggle({
	name = "Ignore Allies",
	def = SilentAim.IgnoreAlly,
	callback = function(v)
		SilentAim.IgnoreAlly = v
	end,
})

silentAimSection:toggle({
	name = "Silent Mouse",
	def = SilentAim.MouseSilent,
	callback = function(v)
		SilentAim.MouseSilent = v
	end,
})

silentAimSection:toggle({
	name = "Longer Hit",
	def = SilentAim.LongerHit,
	callback = function(v)
		SilentAim.LongerHit = v
	end,
})

silentAimSection:toggle({
	name = "Use Roster CF",
	def = SilentAim.UseRosterCF,
	callback = function(v)
		SilentAim.UseRosterCF = v
	end,
})

silentAimSection:toggle({
	name = "Humanize",
	def = SilentAim.Humanize.Enabled,
	callback = function(v)
		SilentAim.Humanize.Enabled = v
	end,
})

silentAimSection:slider({
	name = "Humanize Spread",
	def = SilentAim.Humanize.Spread,
	min = 0,
	max = 5,
	rounding = false,
	callback = function(v)
		SilentAim.Humanize.Spread = v
	end,
})

local fieldOfViewSection = silentAimPage:section({ name = "FOV", side = "right", size = 130 })

fieldOfViewSection:toggle({
	name = "Enable FOV",
	def = SilentAim.FOV.Enabled,
	callback = function(v)
		SilentAim.FOV.Enabled = v
		if not v then fieldOfViewFrame.Visible = false end
	end,
})

fieldOfViewSection:toggle({
	name = "FOV Visible",
	def = SilentAim.FOV.Visible,
	callback = function(v)
		SilentAim.FOV.Visible = v
		fieldOfViewFrame.Visible = SilentAim.FOV.Enabled and v
	end,
})

fieldOfViewSection:slider({
	name = "Radius",
	def = SilentAim.FOV.Radius,
	min = 50,
	max = 800,
	rounding = true,
	callback = function(v)
		setFieldOfViewRadius(v)
	end,
})

fieldOfViewSection:slider({
	name = "Thickness",
	def = SilentAim.FOV.Thickness,
	min = 1,
	max = 6,
	rounding = true,
	callback = function(v)
		SilentAim.FOV.Thickness = v
		fieldOfViewStroke.Thickness = v
	end,
})

local highlightSection = silentAimPage:section({ name = "Highlight", side = "right", size = 55 })

highlightSection:toggle({
	name = "Highlight Target",
	def = SilentAim.Highlight.Enabled,
	callback = function(v)
		SilentAim.Highlight.Enabled = v
		if not v then clearHighlights() end
	end,
})

local directionLineSection = silentAimPage:section({ name = "Direction Line", side = "right", size = 75 })

directionLineSection:toggle({
	name = "Show Direction Line",
	def = SilentAim.DirectionLine.Enabled,
	callback = function(v)
		SilentAim.DirectionLine.Enabled = v
		if not v then directionLine.Visible = false end
	end,
})

directionLineSection:slider({
	name = "Thickness",
	def = SilentAim.DirectionLine.Thickness,
	min = 1,
	max = 5,
	rounding = true,
	callback = function(v)
		SilentAim.DirectionLine.Thickness = v
		directionLine.Thickness = v
	end,
})

local antiDelaySection = silentAimPage:section({ name = "Anti Delay", side = "left", size = 45 })

antiDelaySection:toggle({
	name = "Enable Anti Delay",
	def = _G.NoDelay,
	callback = function(v)
		_G.ToggleAntiDelay(v)
	end,
})

local physicsSection = predictionPage:section({ name = "Physics", side = "left", size = 220 })

physicsSection:slider({
	name = "Skill Speed (studs/s)",
	desc = "Speed your skill projectile travels — higher = less lead time needed",
	def = SilentAim.Physics.SkillSpeed,
	min = 100,
	max = 5000,
	rounding = true,
	callback = function(v)
		SilentAim.Physics.SkillSpeed = v
	end,
})

physicsSection:slider({
	name = "Prediction Time (ms)",
	desc = "Flat extra lead time added on top of calculated travel time",
	def = math.floor(SilentAim.Physics.PredictionTime * 1000),
	min = 0,
	max = 500,
	rounding = true,
	callback = function(v)
		SilentAim.Physics.PredictionTime = v / 1000
	end,
})

physicsSection:slider({
	name = "Ping Multiplier (%)",
	desc = "How much of your real ping is factored into prediction — 100% = full ping, 0% = ignore it",
	def = math.floor(SilentAim.Physics.PingMultiplier * 100),
	min = 0,
	max = 200,
	rounding = true,
	callback = function(v)
		SilentAim.Physics.PingMultiplier = v / 100
	end,
})

physicsSection:slider({
	name = "Dash Lead (ms)",
	desc = "Extra lead time applied specifically when a dash is detected",
	def = math.floor(SilentAim.Physics.DashLeadTime * 1000),
	min = 0,
	max = 300,
	rounding = true,
	callback = function(v)
		SilentAim.Physics.DashLeadTime = v / 1000
	end,
})

physicsSection:slider({
	name = "Dash Threshold (studs/s)",
	desc = "Velocity spike size that counts as a dash — lower = more sensitive",
	def = SilentAim.Physics.DashThreshold,
	min = 10,
	max = 300,
	rounding = true,
	callback = function(v)
		SilentAim.Physics.DashThreshold = v
	end,
})

local fakePingSection = predictionPage:section({ name = "Fake Ping", side = "right", size = 95 })

fakePingSection:toggle({
	name = "Enable Fake Ping",
	desc = "Delays your response to the server's ping check by the set amount",
	def = SilentAim.FakePing.Enabled,
	callback = function(v)
		SilentAim.FakePing.Enabled = v
		setupFakePing()
	end,
})

fakePingSection:slider({
	name = "Ping (ms)",
	desc = "How many milliseconds of artificial delay to add",
	def = SilentAim.FakePing.Amount,
	min = 0,
	max = 500,
	rounding = true,
	callback = function(v)
		SilentAim.FakePing.Amount = v
	end,
})

local serverSection = miscellaneousPage:section({ name = "Server", side = "left", size = 75 })

serverSection:button({
	name = "Hop Server",
	callback = function()
		coroutine.wrap(_G.HopServer)()
	end,
})

serverSection:button({
	name = "Rejoin",
	callback = function()
		_G.RejoinServer()
	end,
})

local scriptSection = miscellaneousPage:section({ name = "Script", side = "left", size = 50 })

scriptSection:button({
	name = "Kill Script",
	callback = function()
		scriptIsKilled = true
		getgenv().ScriptAlreadyLoaded = nil

		SilentAim.Enabled = false
		SilentAim.CurrentTarget = nil
		SilentAim.PredictedCF = nil
		SilentAim.ScreenPos = nil

		if trackingConnection then
			trackingConnection:Disconnect()
			trackingConnection = nil
		end

		pcall(directionLine.Remove, directionLine)
		pcall(fieldOfViewGui.Destroy, fieldOfViewGui)
		clearHighlights()

		if CameraState.FieldOfViewConnection then
			CameraState.FieldOfViewConnection:Disconnect()
			CameraState.FieldOfViewConnection = nil
		end
		pcall(function() workspace.CurrentCamera.FieldOfView = 70 end)

		disableAntiDelay()
		restoreLighting()
		saveSilentAimSettings()
		saveSettings()
	end,
})

local performanceSection = miscellaneousPage:section({ name = "Performance", side = "right", size = 130 })

performanceSection:button({
	name = "FPS Boost",
	callback = function()
		local ok2, err2 = pcall(function()
			settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
		end)
		if not ok2 then warnOnce("fpsBoostQuality", "quality level change failed: " .. tostring(err2)) end
		for _, child in pairs(Lighting:GetChildren()) do
			if child:IsA("BlurEffect") or child:IsA("DepthOfFieldEffect") or child:IsA("SunRaysEffect")
			or child:IsA("ColorCorrectionEffect") or child:IsA("BloomEffect") or child:IsA("AtmosphereEffect") then
				child.Enabled = false
			end
		end
		for _, descendant in pairs(workspace:GetDescendants()) do
			if descendant:IsA("ParticleEmitter") then descendant.Enabled = false end
		end
	end,
})

performanceSection:toggle({
	name = "Full Bright",
	def = false,
	callback = function(v)
		LightingState.FullBrightActive = v
		if v then applyBrightness(5) else restoreLighting() end
	end,
})

performanceSection:slider({
	name = "Brightness",
	def = 5,
	min = 1,
	max = 10,
	rounding = true,
	callback = function(v)
		if LightingState.FullBrightActive then applyBrightness(v) end
	end,
})

performanceSection:slider({
	name = "Camera FOV",
	def = 90,
	min = 70,
	max = 120,
	rounding = true,
	callback = function(v)
		setCameraFieldOfView(v)
	end,
})

local webhookSection = miscellaneousPage:section({ name = "Webhook", side = "right", size = 185 })

webhookSection:textbox({
	name = "URL",
	def = _G.CurrentSettings.Webhook.URL,
	placeholder = "https://discord.com/api/webhooks/...",
	callback = function(v)
		_G.CurrentSettings.Webhook.URL = v
	end,
})

webhookSection:toggle({
	name = "Send Stats",
	def = _G.CurrentSettings.Webhook.SendStats,
	callback = function(v)
		_G.CurrentSettings.Webhook.SendStats = v
	end,
})

webhookSection:slider({
	name = "Interval (min)",
	def = _G.CurrentSettings.Webhook.Interval,
	min = 1,
	max = 60,
	rounding = true,
	callback = function(v)
		_G.CurrentSettings.Webhook.Interval = v
	end,
})

webhookSection:toggle({
	name = "Ping Everyone",
	def = _G.CurrentSettings.Webhook.PingEveryone,
	callback = function(v)
		_G.CurrentSettings.Webhook.PingEveryone = v
	end,
})

webhookSection:toggle({
	name = "Kick Notifier",
	def = _G.CurrentSettings.Webhook.KickNotifier,
	callback = function(v)
		_G.CurrentSettings.Webhook.KickNotifier = v
	end,
})

loadSettings()
loadSilentAimSettings()
setupFakePing()
startTracking()

Players.PlayerRemoving:Connect(function(player)
	historyByPlayer[player] = nil
	removeHighlight(player)
	if player == LocalPlayer then
		saveSilentAimSettings()
		saveSettings()
	end
end)
