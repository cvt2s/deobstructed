local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local CurrentCamera = workspace.CurrentCamera

local scriptKilled = false

local TargetTracker = {
	CurrentTarget = nil,
	PredictedCFrame = nil,
	TargetScreenPosition = nil,
	SphereVisualization = nil,
	SphereTrail = nil,
	TargetIsStunned = false,
	FieldOfViewFrame = nil,
	RainbowConnection = nil,
	PulseConnection = nil,
	Highlights = {},
	Config = {
		Enabled = false,
		Mode = "Blacklist",
		IgnoreAlly = false,
		LongerHit = false,
		UseRosterCFrame = false,
		MouseSilent = false,
		Whitelist = {},
		Blacklist = {},
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
		Sphere = {
			Enabled = false,
			Color = Color3.fromRGB(255, 0, 0),
			Transparency = 0.5,
			Size = 3,
			Trail = false,
			Rainbow = false,
			Pulse = false,
		},
	},
}

local FakePing = {
	Enabled = false,
	Amount = 0,
}

function TargetTracker:clearTarget()
	self.CurrentTarget = nil
	self.PredictedCFrame = nil
	self.TargetScreenPosition = nil
	self:removeAllHighlights()
	if self.SphereVisualization then self.SphereVisualization.Transparency = 1 end
	if self.SphereTrail then self.SphereTrail.Enabled = false end
end

function TargetTracker:removeAllHighlights()
	for _, highlight in pairs(self.Highlights) do
		if highlight and highlight.Parent then highlight:Destroy() end
	end
	self.Highlights = {}
end

function TargetTracker:applyHighlight(character)
	if not self.Config.Highlight.Enabled or not character or self.Highlights[character] then return end
	local highlight = Instance.new("Highlight")
	highlight.FillColor = self.Config.Highlight.FillColor
	highlight.OutlineColor = self.Config.Highlight.OutlineColor
	highlight.FillTransparency = self.Config.Highlight.FillTransparency
	highlight.OutlineTransparency = self.Config.Highlight.OutlineTransparency
	highlight.Adornee = character
	highlight.Parent = character
	self.Highlights[character] = highlight
end

function TargetTracker:isValidTarget(player)
	if player == LocalPlayer then return false end
	local character = player.Character
	if not character then return false end
	local humanoid = character:FindFirstChild("Humanoid")
	if not humanoid or humanoid.Health <= 0 then return false end
	if self.Config.IgnoreAlly then
		local playerFolder = LocalPlayer:FindFirstChild("PlayerFolder")
		local allied = playerFolder and playerFolder:FindFirstChild("Allied")
		if allied and allied.Value == true then return false end
	end
	if self.Config.Mode == "Whitelist" and not self.Config.Whitelist[player.Name] then return false end
	if self.Config.Mode == "Blacklist" and self.Config.Blacklist[player.Name] then return false end
	return true
end

function TargetTracker:findNearestTarget(screenCenter)
	local character = LocalPlayer.Character
	local rootPart = character and character:FindFirstChild("HumanoidRootPart")
	if not rootPart then return nil end
	local bestPlayer = nil
	local bestDistance = math.huge
	for _, player in pairs(Players:GetPlayers()) do
		if not self:isValidTarget(player) then continue end
		local targetRoot = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
		if not targetRoot then continue end
		local screenPosition, onScreen = CurrentCamera:WorldToViewportPoint(targetRoot.Position)
		if not onScreen then continue end
		if self.Config.FieldOfView.Enabled then
			if (Vector2.new(screenPosition.X, screenPosition.Y) - screenCenter).Magnitude > self.Config.FieldOfView.Radius then continue end
		end
		local distance = (targetRoot.Position - rootPart.Position).Magnitude
		if distance < bestDistance then
			bestPlayer = player
			bestDistance = distance
		end
	end
	return bestPlayer
end

function TargetTracker:updateSphere()
	local sphere = self.SphereVisualization
	if not sphere then return end
	local config = self.Config.Sphere
	if not config.Enabled or not self.PredictedCFrame then
		sphere.Transparency = 1
		if self.SphereTrail then self.SphereTrail.Enabled = false end
		return
	end
	sphere.CFrame = self.PredictedCFrame
	if not config.Pulse then sphere.Size = Vector3.new(config.Size, config.Size, config.Size) end
	sphere.Transparency = config.Transparency
	if not config.Rainbow then sphere.Color = config.Color end
	if self.SphereTrail then self.SphereTrail.Enabled = config.Trail end
end

function TargetTracker:updateTracking()
	local screenCenter = Vector2.new(CurrentCamera.ViewportSize.X / 2, CurrentCamera.ViewportSize.Y / 2)
	if not self.Config.Enabled then
		self:clearTarget()
		if self.FieldOfViewFrame then self.FieldOfViewFrame.Visible = false end
		return
	end
	local player = self:findNearestTarget(screenCenter)
	if not player then
		self:clearTarget()
		if self.FieldOfViewFrame then self.FieldOfViewFrame.Visible = self.Config.FieldOfView.Visible end
		return
	end
	local targetCharacter = player.Character
	local targetRoot = targetCharacter and targetCharacter:FindFirstChild("HumanoidRootPart")
	if not targetRoot then
		self:clearTarget()
		if self.FieldOfViewFrame then self.FieldOfViewFrame.Visible = self.Config.FieldOfView.Visible end
		return
	end
	local humanoid = targetCharacter:FindFirstChild("Humanoid")
	if humanoid then
		local hitByValue = humanoid:FindFirstChild("HitBy")
		local disabledByCC = humanoid:FindFirstChild("DisabledByCC")
		self.TargetIsStunned = hitByValue and tostring(hitByValue.Value) == LocalPlayer.Name and disabledByCC ~= nil
	else
		self.TargetIsStunned = false
	end
	self.CurrentTarget = player
	self.PredictedCFrame = targetRoot.CFrame
	local screenPoint, onScreen = CurrentCamera:WorldToViewportPoint(targetRoot.Position)
	if onScreen then self.TargetScreenPosition = Vector2.new(screenPoint.X, screenPoint.Y) end
	for highlightCharacter, highlight in pairs(self.Highlights) do
		if highlightCharacter ~= targetCharacter then
			if highlight and highlight.Parent then highlight:Destroy() end
			self.Highlights[highlightCharacter] = nil
		end
	end
	self:applyHighlight(targetCharacter)
	self:updateSphere()
	if self.FieldOfViewFrame then self.FieldOfViewFrame.Visible = self.Config.FieldOfView.Visible end
end

local updateCharData = game:GetService("ReplicatedStorage"):FindFirstChild("Remotes")
	and game:GetService("ReplicatedStorage").Remotes:FindFirstChild("UpdateCharData")

local puppyware = loadstring(game:HttpGet("https://raw.githubusercontent.com/imagoodpersond/puppyware/main/lib"))()
local puppywareWindow = puppyware:Window({ accent = Color3.fromRGB(0, 210, 255) })

local function buildSilentAimPage()
	local page = puppywareWindow:Page({ name = "Silent Aim" })
	local silentSection = page:Section({ name = "Silent Aim" })
	local fieldOfViewSection = page:Section({ name = "FOV" })
	local antiDelaySection = page:Section({ name = "Anti Delay" })
	local dashBoostSection = page:Section({ name = "Dash Boost" })

	silentSection:Toggle({ name = "Enable", default = false, callback = function(value) TargetTracker.Config.Enabled = value end })
	silentSection:Dropdown({ name = "Mode", options = { "Blacklist", "Whitelist" }, default = "Blacklist", callback = function(value) TargetTracker.Config.Mode = value end })
	silentSection:Toggle({ name = "Ignore Ally", default = false, callback = function(value) TargetTracker.Config.IgnoreAlly = value end })
	silentSection:Toggle({ name = "Mouse Silent", default = false, callback = function(value) TargetTracker.Config.MouseSilent = value end })
	silentSection:Toggle({ name = "Longer Hit", default = false, callback = function(value) TargetTracker.Config.LongerHit = value end })
	silentSection:Toggle({ name = "Use Roster CFrame", default = false, callback = function(value) TargetTracker.Config.UseRosterCFrame = value end })
	silentSection:List({ name = "Blacklist", callback = function(list)
		TargetTracker.Config.Blacklist = {}
		for _, name in pairs(list) do TargetTracker.Config.Blacklist[name] = true end
	end })
	silentSection:List({ name = "Whitelist", callback = function(list)
		TargetTracker.Config.Whitelist = {}
		for _, name in pairs(list) do TargetTracker.Config.Whitelist[name] = true end
	end })

	fieldOfViewSection:Toggle({ name = "Enable FOV", default = false, callback = function(value) TargetTracker.Config.FieldOfView.Enabled = value end })
	fieldOfViewSection:Toggle({ name = "Show Circle", default = false, callback = function(value)
		TargetTracker.Config.FieldOfView.Visible = value
		if TargetTracker.FieldOfViewFrame then TargetTracker.FieldOfViewFrame.Visible = value and TargetTracker.Config.Enabled end
	end })
	fieldOfViewSection:Slider({ name = "Radius", min = 50, max = 800, default = 300, callback = function(value)
		TargetTracker.Config.FieldOfView.Radius = value
		if TargetTracker.FieldOfViewFrame then TargetTracker.FieldOfViewFrame.Radius = value end
	end })
	fieldOfViewSection:Slider({ name = "Thickness", min = 1, max = 10, default = 2, callback = function(value)
		TargetTracker.Config.FieldOfView.Thickness = value
		if TargetTracker.FieldOfViewFrame then TargetTracker.FieldOfViewFrame.Thickness = value end
	end })
	fieldOfViewSection:ColorPicker({ name = "Color", default = Color3.new(1, 1, 1), callback = function(value)
		TargetTracker.Config.FieldOfView.Color = value
		if TargetTracker.FieldOfViewFrame then TargetTracker.FieldOfViewFrame.Color3 = value end
	end })

	antiDelaySection:Toggle({ name = "Enable", default = false, callback = function(value)
		if getgenv().AntiDelayConnection then getgenv().AntiDelayConnection:Disconnect() getgenv().AntiDelayConnection = nil end
		if not value then return end
		getgenv().AntiDelayConnection = RunService.Heartbeat:Connect(function()
			if scriptKilled then getgenv().AntiDelayConnection:Disconnect() getgenv().AntiDelayConnection = nil return end
			local character = LocalPlayer.Character
			local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
			if not humanoidRootPart or not updateCharData then return end
			pcall(function() updateCharData:FireServer(humanoidRootPart.CFrame, Vector2.new(0, 0), humanoidRootPart.CFrame) end)
		end)
	end })

	_G.DashSpeed = _G.DashSpeed or 4250
	dashBoostSection:Toggle({ name = "Enable", default = false, callback = function(value)
		if getgenv().DashBoostConnection then getgenv().DashBoostConnection:Disconnect() getgenv().DashBoostConnection = nil end
		if not value then return end
		getgenv().DashBoostConnection = RunService.Heartbeat:Connect(function()
			if scriptKilled then getgenv().DashBoostConnection:Disconnect() getgenv().DashBoostConnection = nil return end
			local character = LocalPlayer.Character
			local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
			if not humanoidRootPart then return end
			local velocity = humanoidRootPart.AssemblyLinearVelocity
			local speed = velocity.Magnitude
			if speed > 50 and speed < _G.DashSpeed then humanoidRootPart.AssemblyLinearVelocity = velocity.Unit * _G.DashSpeed end
		end)
	end })
	dashBoostSection:Slider({ name = "Dash Speed", min = 1000, max = 10000, default = 4250, callback = function(value) _G.DashSpeed = value end })
end

local function buildVisualPage()
	local page = puppywareWindow:Page({ name = "Visual" })
	local fakePingSection = page:Section({ name = "Fake Ping" })
	local sphereSection = page:Section({ name = "Target Sphere" })

	fakePingSection:Toggle({ name = "Enable", default = false, callback = function(value) FakePing.Enabled = value end })
	fakePingSection:Slider({ name = "Amount (ms)", min = 0, max = 500, default = 0, callback = function(value) FakePing.Amount = value end })

	sphereSection:Toggle({ name = "Enable", default = false, callback = function(value)
		TargetTracker.Config.Sphere.Enabled = value
		if not value and TargetTracker.SphereVisualization then TargetTracker.SphereVisualization.Transparency = 1 end
	end })
	sphereSection:ColorPicker({ name = "Color", default = Color3.fromRGB(255, 0, 0), callback = function(value)
		TargetTracker.Config.Sphere.Color = value
		if TargetTracker.SphereVisualization and not TargetTracker.Config.Sphere.Rainbow then TargetTracker.SphereVisualization.Color = value end
	end })
	sphereSection:Slider({ name = "Transparency", min = 0, max = 1, default = 0.5, callback = function(value) TargetTracker.Config.Sphere.Transparency = value end })
	sphereSection:Slider({ name = "Size", min = 1, max = 20, default = 3, callback = function(value) TargetTracker.Config.Sphere.Size = value end })
	sphereSection:Toggle({ name = "Trail", default = false, callback = function(value)
		TargetTracker.Config.Sphere.Trail = value
		if TargetTracker.SphereTrail then TargetTracker.SphereTrail.Enabled = value and TargetTracker.Config.Sphere.Enabled end
	end })
	sphereSection:Toggle({ name = "Rainbow", default = false, callback = function(value)
		TargetTracker.Config.Sphere.Rainbow = value
		if TargetTracker.RainbowConnection then TargetTracker.RainbowConnection:Disconnect() TargetTracker.RainbowConnection = nil end
		if not value then return end
		TargetTracker.RainbowConnection = RunService.Heartbeat:Connect(function()
			if scriptKilled then TargetTracker.RainbowConnection:Disconnect() TargetTracker.RainbowConnection = nil return end
			if TargetTracker.SphereVisualization and TargetTracker.Config.Sphere.Rainbow then
				TargetTracker.SphereVisualization.Color = Color3.fromHSV((tick() % 5) / 5, 1, 1)
			end
		end)
	end })
	sphereSection:Toggle({ name = "Pulse", default = false, callback = function(value)
		TargetTracker.Config.Sphere.Pulse = value
		if TargetTracker.PulseConnection then TargetTracker.PulseConnection:Disconnect() TargetTracker.PulseConnection = nil end
		if not value then return end
		TargetTracker.PulseConnection = RunService.Heartbeat:Connect(function()
			if scriptKilled then TargetTracker.PulseConnection:Disconnect() TargetTracker.PulseConnection = nil return end
			if TargetTracker.SphereVisualization and TargetTracker.Config.Sphere.Pulse then
				local pulse = (math.sin(tick() * 4) + 1) / 2
				local baseSize = TargetTracker.Config.Sphere.Size
				TargetTracker.SphereVisualization.Size = Vector3.new(baseSize + pulse * 2, baseSize + pulse * 2, baseSize + pulse * 2)
			end
		end)
	end })
end

local function buildMiscPage()
	local page = puppywareWindow:Page({ name = "Misc" })
	local serverSection = page:Section({ name = "Server" })
	local scriptSection = page:Section({ name = "Script" })

	serverSection:Button({ name = "Rejoin", callback = function()
		game:GetService("TeleportService"):Teleport(game.PlaceId, LocalPlayer)
	end })
	serverSection:Button({ name = "Leave", callback = function() game:Shutdown() end })

	scriptSection:Button({ name = "Kill Script", callback = function()
		scriptKilled = true
		TargetTracker:removeAllHighlights()
		if TargetTracker.RainbowConnection then TargetTracker.RainbowConnection:Disconnect() end
		if TargetTracker.PulseConnection then TargetTracker.PulseConnection:Disconnect() end
		if getgenv().AntiDelayConnection then getgenv().AntiDelayConnection:Disconnect() end
		if getgenv().DashBoostConnection then getgenv().DashBoostConnection:Disconnect() end
		if TargetTracker.SphereVisualization then TargetTracker.SphereVisualization:Destroy() end
		if TargetTracker.FieldOfViewFrame then TargetTracker.FieldOfViewFrame:Remove() end
		pcall(function() puppywareWindow.screen:Destroy() end)
	end })
end

buildSilentAimPage()
buildVisualPage()
buildMiscPage()

local fieldOfViewCircle = Drawing.new("Circle")
fieldOfViewCircle.Visible = false
fieldOfViewCircle.Filled = false
fieldOfViewCircle.Radius = TargetTracker.Config.FieldOfView.Radius
fieldOfViewCircle.Thickness = TargetTracker.Config.FieldOfView.Thickness
fieldOfViewCircle.Color3 = TargetTracker.Config.FieldOfView.Color
fieldOfViewCircle.Position = Vector2.new(CurrentCamera.ViewportSize.X / 2, CurrentCamera.ViewportSize.Y / 2)
TargetTracker.FieldOfViewFrame = fieldOfViewCircle

local spherePart = Instance.new("Part")
spherePart.Name = "TargetSphere"
spherePart.Shape = Enum.PartType.Ball
spherePart.Material = Enum.Material.Neon
spherePart.CanCollide = false
spherePart.Anchored = true
spherePart.Transparency = 1
spherePart.Size = Vector3.new(3, 3, 3)
spherePart.Color = TargetTracker.Config.Sphere.Color
spherePart.CastShadow = false
spherePart.Parent = workspace
TargetTracker.SphereVisualization = spherePart

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
TargetTracker.SphereTrail = sphereTrail

if not getgenv().OriginalNamecallHook then
	getgenv().OriginalNamecallHook = hookmetamethod(game, "__namecall", function(...)
		local arguments = table.pack(...)
		local hookSelf = arguments[1]
		local method = getnamecallmethod()
		if scriptKilled then return getgenv().OriginalNamecallHook(table.unpack(arguments, 1, arguments.n)) end
		if FakePing.Enabled and method == "FireServer" and FakePing.Amount > 0 then task.wait(FakePing.Amount / 1000) end
		if not TargetTracker.Config.Enabled or hookSelf ~= updateCharData or method ~= "FireServer" then
			return getgenv().OriginalNamecallHook(table.unpack(arguments, 1, arguments.n))
		end
		if not TargetTracker.PredictedCFrame or TargetTracker.TargetIsStunned then
			return getgenv().OriginalNamecallHook(table.unpack(arguments, 1, arguments.n))
		end
		local modified = table.pack(table.unpack(arguments, 1, arguments.n))
		modified[2] = TargetTracker.PredictedCFrame
		if TargetTracker.Config.LongerHit or TargetTracker.Config.MouseSilent then
			if TargetTracker.TargetScreenPosition then modified[3] = TargetTracker.TargetScreenPosition end
		end
		if TargetTracker.Config.UseRosterCFrame and TargetTracker.CurrentTarget then
			local targetCharacter = TargetTracker.CurrentTarget.Character
			local targetRoot = targetCharacter and targetCharacter:FindFirstChild("HumanoidRootPart")
			if targetRoot then modified[4] = targetRoot.CFrame end
		end
		return getgenv().OriginalNamecallHook(table.unpack(modified, 1, modified.n))
	end)
end

getgenv().SilentAimTracker = TargetTracker

RunService.Heartbeat:Connect(function()
	if scriptKilled then return end
	TargetTracker:updateTracking()
	if TargetTracker.FieldOfViewFrame then
		TargetTracker.FieldOfViewFrame.Position = Vector2.new(CurrentCamera.ViewportSize.X / 2, CurrentCamera.ViewportSize.Y / 2)
		TargetTracker.FieldOfViewFrame.Radius = TargetTracker.Config.FieldOfView.Radius
	end
end)
