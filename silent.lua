local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local CurrentCamera = workspace.CurrentCamera

local scriptKilled = false

local SilentAim = {
	Config = {
		Enabled = false,
		IgnoreAlly = false,
		MouseSilent = false,
		DirectionThreshold = 0.6,
		FieldOfView = {
			Enabled = false,
			Radius = 300,
			Visible = false,
			Thickness = 2,
			Color = Color3.new(1, 1, 1),
		},
		Highlight = {
			Enabled = false,
			FillColor = Color3.fromRGB(255, 255, 255),
			OutlineColor = Color3.fromRGB(255, 255, 255),
			FillTransparency = 0.5,
			OutlineTransparency = 0,
		},
	},
	State = {
		CurrentTarget = nil,
		PredictedCFrame = nil,
		PredictedPosition = nil,
		TargetIsStunned = false,
		Highlights = {},
	},
}

local Sphere = {
	Config = {
		Enabled = false,
		Color = Color3.fromRGB(255, 0, 0),
		Transparency = 0.5,
		Size = 3,
		Trail = false,
		Rainbow = false,
		Pulse = false,
	},
	Part = nil,
	Trail = nil,
	RainbowConnection = nil,
	PulseConnection = nil,
}

local FakePing = {
	Config = {
		Enabled = false,
		Amount = 0,
	},
}

local FieldOfView = {
	Circle = nil,
}

local Menu = {
	Screen = nil,
}

local function isFieldOfViewVisible()
	return SilentAim.Config.FieldOfView.Visible and (Menu.Screen == nil or Menu.Screen.Enabled)
end

local function removeAllHighlights()
	for _, highlight in pairs(SilentAim.State.Highlights) do
		if highlight and highlight.Parent then highlight:Destroy() end
	end
	SilentAim.State.Highlights = {}
end

local function applyHighlight(character)
	local config = SilentAim.Config.Highlight
	if not config.Enabled or not character or SilentAim.State.Highlights[character] then return end
	local highlight = Instance.new("Highlight")
	highlight.FillColor = config.FillColor
	highlight.OutlineColor = config.OutlineColor
	highlight.FillTransparency = config.FillTransparency
	highlight.OutlineTransparency = config.OutlineTransparency
	highlight.Adornee = character
	highlight.Parent = character
	SilentAim.State.Highlights[character] = highlight
end

local function clearTarget()
	SilentAim.State.CurrentTarget = nil
	SilentAim.State.PredictedCFrame = nil
	SilentAim.State.PredictedPosition = nil
	removeAllHighlights()
	if Sphere.Part then Sphere.Part.Transparency = 1 end
	if Sphere.Trail then Sphere.Trail.Enabled = false end
	if FieldOfView.Circle then FieldOfView.Circle.Visible = isFieldOfViewVisible() end
end

local function isValidTarget(player)
	if player == LocalPlayer then return false end
	local character = player.Character
	if not character then return false end
	local humanoid = character:FindFirstChild("Humanoid")
	if not humanoid or humanoid.Health <= 0 then return false end
	if SilentAim.Config.IgnoreAlly then
		local playerFolder = LocalPlayer:FindFirstChild("PlayerFolder")
		local allied = playerFolder and playerFolder:FindFirstChild("Allied")
		if allied and allied:FindFirstChild(player.Name) then return false end
	end
	return true
end

local function findNearestTarget(screenCenter)
	local character = LocalPlayer.Character
	local localRoot = character and character:FindFirstChild("HumanoidRootPart")
	if not localRoot then return nil end
	local bestPlayer = nil
	local bestDistance = math.huge
	for _, player in pairs(Players:GetPlayers()) do
		if not isValidTarget(player) then continue end
		local targetRoot = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
		if not targetRoot then continue end
		local screenPosition, onScreen = CurrentCamera:WorldToViewportPoint(targetRoot.Position)
		if not onScreen then continue end
		if SilentAim.Config.FieldOfView.Enabled then
			if (Vector2.new(screenPosition.X, screenPosition.Y) - screenCenter).Magnitude > SilentAim.Config.FieldOfView.Radius then continue end
		end
		local distance = (targetRoot.Position - localRoot.Position).Magnitude
		if distance < bestDistance then
			bestPlayer = player
			bestDistance = distance
		end
	end
	return bestPlayer
end

local function updateSphere()
	local part = Sphere.Part
	if not part then return end
	local config = Sphere.Config
	if not config.Enabled or not SilentAim.State.PredictedPosition then
		part.Transparency = 1
		if Sphere.Trail then Sphere.Trail.Enabled = false end
		return
	end
	part.CFrame = CFrame.new(SilentAim.State.PredictedPosition)
	if not config.Pulse then part.Size = Vector3.new(config.Size, config.Size, config.Size) end
	part.Transparency = config.Transparency
	if not config.Rainbow then part.Color = config.Color end
	if Sphere.Trail then Sphere.Trail.Enabled = config.Trail end
end

local function updateTracking()
	local screenCenter = Vector2.new(CurrentCamera.ViewportSize.X / 2, CurrentCamera.ViewportSize.Y / 2)
	if not SilentAim.Config.Enabled then
		clearTarget()
		return
	end
	local player = findNearestTarget(screenCenter)
	if not player then
		clearTarget()
		return
	end
	local targetCharacter = player.Character
	local targetRoot = targetCharacter and targetCharacter:FindFirstChild("HumanoidRootPart")
	if not targetRoot then
		clearTarget()
		return
	end
	local humanoid = targetCharacter:FindFirstChild("Humanoid")
	if humanoid then
		local hitByValue = humanoid:FindFirstChild("HitBy")
		local disabledByCC = humanoid:FindFirstChild("DisabledByCC")
		SilentAim.State.TargetIsStunned = hitByValue and tostring(hitByValue.Value) == LocalPlayer.Name and disabledByCC ~= nil
	else
		SilentAim.State.TargetIsStunned = false
	end
	SilentAim.State.CurrentTarget = player
	local targetPosition = targetRoot.Position
	local toTarget = (targetPosition - CurrentCamera.CFrame.Position).Unit
	local dotProduct = CurrentCamera.CFrame.LookVector:Dot(toTarget)
	if dotProduct < SilentAim.Config.DirectionThreshold then
		clearTarget()
		return
	end
	local localCharacter = LocalPlayer.Character
	local localRoot = localCharacter and localCharacter:FindFirstChild("HumanoidRootPart")
	if localRoot then
		SilentAim.State.PredictedCFrame = CFrame.lookAt(
			Vector3.new(localRoot.Position.X, targetPosition.Y, localRoot.Position.Z),
			targetPosition
		)
	else
		SilentAim.State.PredictedCFrame = CFrame.new(targetPosition)
	end
	SilentAim.State.PredictedPosition = targetPosition
	for highlightCharacter, highlight in pairs(SilentAim.State.Highlights) do
		if highlightCharacter ~= targetCharacter then
			if highlight and highlight.Parent then highlight:Destroy() end
			SilentAim.State.Highlights[highlightCharacter] = nil
		end
	end
	applyHighlight(targetCharacter)
	updateSphere()
	if FieldOfView.Circle then FieldOfView.Circle.Visible = isFieldOfViewVisible() end
end

local updateCharData = game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("UpdateCharData")

local puppyware = loadstring(game:HttpGet("https://raw.githubusercontent.com/imagoodpersond/puppyware/main/lib"))()
local puppywareWindow = puppyware:new({ accent = Color3.fromRGB(0, 210, 255) })
Menu.Screen = puppywareWindow.screen

local function buildSilentAimPage()
	local page = puppywareWindow:page({ name = "Silent Aim" })
	local silentSection = page:section({ name = "Silent Aim", side = "left", size = 220 })
	local fieldOfViewSection = page:section({ name = "FOV", side = "right", size = 220 })
	local pvpAssistSection = page:section({ name = "PVP Assist", side = "left", size = 90 })

	silentSection:toggle({ name = "Enable", default = false, callback = function(value)
		SilentAim.Config.Enabled = value
	end })
	silentSection:toggle({ name = "Ignore Ally", default = false, callback = function(value)
		SilentAim.Config.IgnoreAlly = value
	end })
	silentSection:toggle({ name = "Mouse Silent", default = false, callback = function(value)
		SilentAim.Config.MouseSilent = value
	end })
	silentSection:slider({ name = "Direction Threshold", min = 0, max = 1, default = 0.7, callback = function(value)
		SilentAim.Config.DirectionThreshold = value
	end })

	fieldOfViewSection:toggle({ name = "Enable FOV", default = false, callback = function(value)
		SilentAim.Config.FieldOfView.Enabled = value
	end })
	fieldOfViewSection:toggle({ name = "Show Circle", default = false, callback = function(value)
		SilentAim.Config.FieldOfView.Visible = value
		if FieldOfView.Circle then
			FieldOfView.Circle.Visible = isFieldOfViewVisible()
		end
	end })
	fieldOfViewSection:slider({ name = "Radius", min = 50, max = 800, default = 300, callback = function(value)
		SilentAim.Config.FieldOfView.Radius = value
		if FieldOfView.Circle then
			FieldOfView.Circle.Radius = value
		end
	end })
	fieldOfViewSection:slider({ name = "Thickness", min = 1, max = 10, default = 2, callback = function(value)
		SilentAim.Config.FieldOfView.Thickness = value
		if FieldOfView.Circle then
			FieldOfView.Circle.Thickness = value
		end
	end })
	fieldOfViewSection:colorpicker({ name = "Color", default = Color3.new(1, 1, 1), callback = function(value)
		SilentAim.Config.FieldOfView.Color = value
		if FieldOfView.Circle then
			FieldOfView.Circle.Color = value
		end
	end })

	_G.DashSpeed = _G.DashSpeed or 4250
	pvpAssistSection:toggle({ name = "Dash Boost", default = false, callback = function(value)
		if getgenv().DashBoostConnection then
			getgenv().DashBoostConnection:Disconnect()
			getgenv().DashBoostConnection = nil
		end
		if not value then return end
		getgenv().DashBoostConnection = RunService.Heartbeat:Connect(function()
			if scriptKilled then
				getgenv().DashBoostConnection:Disconnect()
				getgenv().DashBoostConnection = nil
				return
			end
			local character = LocalPlayer.Character
			local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
			if not humanoidRootPart then return end
			local velocity = humanoidRootPart.AssemblyLinearVelocity
			local speed = velocity.Magnitude
			if speed > 50 and speed < _G.DashSpeed then
				humanoidRootPart.AssemblyLinearVelocity = velocity.Unit * _G.DashSpeed
			end
		end)
	end })
	pvpAssistSection:slider({ name = "Dash Speed", min = 1000, max = 10000, default = 4250, callback = function(value)
		_G.DashSpeed = value
	end })
end

local function buildVisualPage()
	local page = puppywareWindow:page({ name = "Visual" })
	local fakePingSection = page:section({ name = "Fake Ping" })
	local sphereSection = page:section({ name = "Target Sphere" })

	fakePingSection:toggle({ name = "Enable", default = false, callback = function(value)
		FakePing.Config.Enabled = value
	end })
	fakePingSection:slider({ name = "Amount (ms)", min = 0, max = 500, default = 0, callback = function(value)
		FakePing.Config.Amount = value
	end })

	sphereSection:toggle({ name = "Enable", default = false, callback = function(value)
		Sphere.Config.Enabled = value
		if not value and Sphere.Part then
			Sphere.Part.Transparency = 1
		end
	end })
	sphereSection:colorpicker({ name = "Color", default = Color3.fromRGB(255, 0, 0), callback = function(value)
		Sphere.Config.Color = value
		if Sphere.Part and not Sphere.Config.Rainbow then
			Sphere.Part.Color = value
		end
	end })
	sphereSection:slider({ name = "Transparency", min = 0, max = 1, default = 0.5, callback = function(value)
		Sphere.Config.Transparency = value
	end })
	sphereSection:slider({ name = "Size", min = 1, max = 20, default = 3, callback = function(value)
		Sphere.Config.Size = value
	end })
	sphereSection:toggle({ name = "Trail", default = false, callback = function(value)
		Sphere.Config.Trail = value
		if Sphere.Trail then
			Sphere.Trail.Enabled = value and Sphere.Config.Enabled
		end
	end })
	sphereSection:toggle({ name = "Rainbow", default = false, callback = function(value)
		Sphere.Config.Rainbow = value
		if Sphere.RainbowConnection then
			Sphere.RainbowConnection:Disconnect()
			Sphere.RainbowConnection = nil
		end
		if not value then return end
		Sphere.RainbowConnection = RunService.Heartbeat:Connect(function()
			if scriptKilled then
				Sphere.RainbowConnection:Disconnect()
				Sphere.RainbowConnection = nil
				return
			end
			if Sphere.Part and Sphere.Config.Rainbow then
				Sphere.Part.Color = Color3.fromHSV((tick() % 5) / 5, 1, 1)
			end
		end)
	end })
	sphereSection:toggle({ name = "Pulse", default = false, callback = function(value)
		Sphere.Config.Pulse = value
		if Sphere.PulseConnection then
			Sphere.PulseConnection:Disconnect()
			Sphere.PulseConnection = nil
		end
		if not value then return end
		Sphere.PulseConnection = RunService.Heartbeat:Connect(function()
			if scriptKilled then
				Sphere.PulseConnection:Disconnect()
				Sphere.PulseConnection = nil
				return
			end
			if Sphere.Part and Sphere.Config.Pulse then
				local pulse = (math.sin(tick() * 4) + 1) / 2
				local baseSize = Sphere.Config.Size
				Sphere.Part.Size = Vector3.new(baseSize + pulse * 2, baseSize + pulse * 2, baseSize + pulse * 2)
			end
		end)
	end })
end

local function buildMiscPage()
	local page = puppywareWindow:page({ name = "Misc" })
	local serverSection = page:section({ name = "Server" })
	local scriptSection = page:section({ name = "Script" })

	serverSection:button({ name = "Rejoin", callback = function()
		game:GetService("TeleportService"):Teleport(game.PlaceId, LocalPlayer)
	end })
	serverSection:button({ name = "Leave", callback = function() game:Shutdown() end })

	scriptSection:button({ name = "Kill Script", callback = function()
		scriptKilled = true
		removeAllHighlights()
		if Sphere.RainbowConnection then Sphere.RainbowConnection:Disconnect() end
		if Sphere.PulseConnection then Sphere.PulseConnection:Disconnect() end
		if getgenv().DashBoostConnection then getgenv().DashBoostConnection:Disconnect() end
		if Sphere.Part then Sphere.Part:Destroy() end
		if FieldOfView.Circle then FieldOfView.Circle:Remove() end
		pcall(function() puppywareWindow.screen:Destroy() end)
	end })
end

buildSilentAimPage()
buildVisualPage()
buildMiscPage()

local fieldOfViewCircle = Drawing.new("Circle")
fieldOfViewCircle.Visible = false
fieldOfViewCircle.Filled = false
fieldOfViewCircle.Radius = SilentAim.Config.FieldOfView.Radius
fieldOfViewCircle.Thickness = SilentAim.Config.FieldOfView.Thickness
fieldOfViewCircle.Color = SilentAim.Config.FieldOfView.Color
fieldOfViewCircle.Position = Vector2.new(CurrentCamera.ViewportSize.X / 2, CurrentCamera.ViewportSize.Y / 2)
FieldOfView.Circle = fieldOfViewCircle

local spherePart = Instance.new("Part")
spherePart.Name = "TargetSphere"
spherePart.Shape = Enum.PartType.Ball
spherePart.Material = Enum.Material.Neon
spherePart.CanCollide = false
spherePart.Anchored = true
spherePart.Transparency = 1
spherePart.Size = Vector3.new(3, 3, 3)
spherePart.Color = Sphere.Config.Color
spherePart.CastShadow = false
spherePart.Parent = workspace
Sphere.Part = spherePart

local sphereAttachment0 = Instance.new("Attachment", spherePart)
local sphereAttachment1 = Instance.new("Attachment", spherePart)
sphereAttachment0.Position = Vector3.new(0, 0.5, 0)
sphereAttachment1.Position = Vector3.new(0, -0.5, 0)
local sphereTrail = Instance.new("Trail")
sphereTrail.Attachment0 = sphereAttachment0
sphereTrail.Attachment1 = sphereAttachment1
sphereTrail.Lifetime = 0.3
sphereTrail.Enabled = false
sphereTrail.Parent = spherePart
Sphere.Trail = sphereTrail

if getgenv().OriginalNamecallHook then
	pcall(hookmetamethod, game, "__namecall", getgenv().OriginalNamecallHook)
	getgenv().OriginalNamecallHook = nil
end

getgenv().OriginalNamecallHook = hookmetamethod(game, "__namecall", function(...)
	local arguments = table.pack(...)
	local hookSelf = arguments[1]
	local method = getnamecallmethod()
	if scriptKilled then return getgenv().OriginalNamecallHook(table.unpack(arguments, 1, arguments.n)) end
	if FakePing.Config.Enabled and method == "FireServer" and FakePing.Config.Amount > 0 then
		task.wait(FakePing.Config.Amount / 1000)
	end
	if not SilentAim.Config.Enabled or hookSelf ~= updateCharData or method ~= "FireServer" then
		return getgenv().OriginalNamecallHook(table.unpack(arguments, 1, arguments.n))
	end
	if not SilentAim.State.PredictedCFrame or SilentAim.State.TargetIsStunned then
		return getgenv().OriginalNamecallHook(table.unpack(arguments, 1, arguments.n))
	end
	local modified = table.pack(table.unpack(arguments, 1, arguments.n))
	modified[2] = SilentAim.State.PredictedCFrame
	if SilentAim.Config.MouseSilent and SilentAim.State.PredictedPosition then
		modified[3] = CFrame.new(SilentAim.State.PredictedPosition)
	end
	return getgenv().OriginalNamecallHook(table.unpack(modified, 1, modified.n))
end)

getgenv().SilentAim = SilentAim
getgenv().Sphere = Sphere
getgenv().FakePing = FakePing

RunService.Heartbeat:Connect(function()
	if scriptKilled then return end
	updateTracking()
	if FieldOfView.Circle then
		FieldOfView.Circle.Position = Vector2.new(CurrentCamera.ViewportSize.X / 2, CurrentCamera.ViewportSize.Y / 2)
		FieldOfView.Circle.Radius = SilentAim.Config.FieldOfView.Radius
	end
end)
