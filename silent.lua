-- Auto Block doesnt work FYI
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer
local CurrentCamera = workspace.CurrentCamera
local HttpService = game:GetService("HttpService")

local scriptKilled = false
local longerHit = false
local useRosterCFrame = false

local silentAimConfig = {
	Enabled = false,
	Mode = "Blacklist",
	IgnoreAlly = false,
	WhitelistedPlayers = {},
	BlacklistedPlayers = {},
	FOV = {
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
	PredictionSphere = {
		Enabled = false,
		Color = Color3.fromRGB(255, 0, 0),
		Transparency = 0.5,
		Size = 3,
		Trail = false,
		Rainbow = false,
		Pulse = false,
	},
	MouseSilent = false,
}

local TargetTracker = {
	CurrentTarget = nil,
	PredictedCFrame = nil,
	TargetScreenPosition = nil,
	SphereVisualization = nil,
	SphereTrail = nil,
	TargetIsStunned = false,
	Config = silentAimConfig,
	Highlights = {},
	FieldOfViewFrame = nil,
	RainbowConnection = nil,
	PulseConnection = nil,
}

local AutoBlock = {
	Enabled = false,
	Window = 0.4,
	BlockConnection = nil,
	UnblockThread = nil,
}

local FakePing = {
	Enabled = false,
	Amount = 0,
	Locked = false,
}

local savedData = {}

local function saveData()
	local config = TargetTracker.Config
	savedData = {
		Enabled = config.Enabled,
		Mode = config.Mode,
		IgnoreAlly = config.IgnoreAlly,
		WhitelistedPlayers = config.WhitelistedPlayers,
		BlacklistedPlayers = config.BlacklistedPlayers,
		FOVEnabled = config.FOV.Enabled,
		FOVRadius = config.FOV.Radius,
		FOVVisible = config.FOV.Visible,
		FOVThickness = config.FOV.Thickness,
		FOVColor = config.FOV.Color,
		HighlightEnabled = config.Highlight.Enabled,
		HighlightFillColor = config.Highlight.FillColor,
		HighlightOutlineColor = config.Highlight.OutlineColor,
		HighlightFillTransparency = config.Highlight.FillTransparency,
		HighlightOutlineTransparency = config.Highlight.OutlineTransparency,
		SphereEnabled = config.PredictionSphere.Enabled,
		SphereColor = config.PredictionSphere.Color,
		SphereTransparency = config.PredictionSphere.Transparency,
		SphereSize = config.PredictionSphere.Size,
		SphereTrail = config.PredictionSphere.Trail,
		SphereRainbow = config.PredictionSphere.Rainbow,
		SpherePulse = config.PredictionSphere.Pulse,
		MouseSilent = config.MouseSilent,
		LongerHit = longerHit,
		UseRosterCFrame = useRosterCFrame,
		FakePingEnabled = FakePing.Enabled,
		FakePingAmount = FakePing.Amount,
		AutoBlockEnabled = AutoBlock.Enabled,
		AutoBlockWindow = AutoBlock.Window,
	}
end

local function loadData()
	if not next(savedData) then return end
	local config = TargetTracker.Config
	config.Enabled = savedData.Enabled or false
	config.Mode = savedData.Mode or "Blacklist"
	config.IgnoreAlly = savedData.IgnoreAlly or false
	config.WhitelistedPlayers = savedData.WhitelistedPlayers or {}
	config.BlacklistedPlayers = savedData.BlacklistedPlayers or {}
	config.FOV.Enabled = savedData.FOVEnabled or false
	config.FOV.Radius = savedData.FOVRadius or 300
	config.FOV.Visible = savedData.FOVVisible or false
	config.FOV.Thickness = savedData.FOVThickness or 2
	config.FOV.Color = savedData.FOVColor or Color3.new(1, 1, 1)
	config.Highlight.Enabled = savedData.HighlightEnabled or false
	config.Highlight.FillColor = savedData.HighlightFillColor or Color3.fromRGB(255, 255, 255)
	config.Highlight.OutlineColor = savedData.HighlightOutlineColor or Color3.fromRGB(255, 255, 255)
	config.Highlight.FillTransparency = savedData.HighlightFillTransparency or 0.5
	config.Highlight.OutlineTransparency = savedData.HighlightOutlineTransparency or 0
	config.PredictionSphere.Enabled = savedData.SphereEnabled or false
	config.PredictionSphere.Color = savedData.SphereColor or Color3.fromRGB(255, 0, 0)
	config.PredictionSphere.Transparency = savedData.SphereTransparency or 0.5
	config.PredictionSphere.Size = savedData.SphereSize or 3
	config.PredictionSphere.Trail = savedData.SphereTrail or false
	config.PredictionSphere.Rainbow = savedData.SphereRainbow or false
	config.PredictionSphere.Pulse = savedData.SpherePulse or false
	config.MouseSilent = savedData.MouseSilent or false
	longerHit = savedData.LongerHit or false
	useRosterCFrame = savedData.UseRosterCFrame or false
	FakePing.Enabled = savedData.FakePingEnabled or false
	FakePing.Amount = savedData.FakePingAmount or 0
	AutoBlock.Enabled = savedData.AutoBlockEnabled or false
	AutoBlock.Window = savedData.AutoBlockWindow or 0.4
end

function TargetTracker:removeAllHighlights()
	for _, highlight in pairs(self.Highlights) do
		if highlight and highlight.Parent then
			highlight:Destroy()
		end
	end
	self.Highlights = {}
end

function TargetTracker:applyHighlight(character)
	if not self.Config.Highlight.Enabled then return end
	if not character then return end
	if self.Highlights[character] then return end
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
	local config = self.Config
	if config.IgnoreAlly then
		local playerFolder = LocalPlayer:FindFirstChild("PlayerFolder")
		if playerFolder then
			local allied = playerFolder:FindFirstChild("Allied")
			if allied and allied.Value == true then return false end
		end
	end
	local name = player.Name
	if config.Mode == "Whitelist" then
		local found = false
		for _, whitelisted in pairs(config.WhitelistedPlayers) do
			if whitelisted == name then found = true break end
		end
		if not found then return false end
	elseif config.Mode == "Blacklist" then
		for _, blacklisted in pairs(config.BlacklistedPlayers) do
			if blacklisted == name then return false end
		end
	end
	return true
end

function TargetTracker:findNearestTarget()
	local character = LocalPlayer.Character
	local rootPart = character and character:FindFirstChild("HumanoidRootPart")
	if not rootPart then return nil, nil end
	local screenCenter = Vector2.new(CurrentCamera.ViewportSize.X / 2, CurrentCamera.ViewportSize.Y / 2)
	local bestPlayer = nil
	local bestDistance = math.huge
	for _, player in pairs(Players:GetPlayers()) do
		if self:isValidTarget(player) then
			local targetCharacter = player.Character
			if targetCharacter then
				local targetRoot = targetCharacter:FindFirstChild("HumanoidRootPart")
				if targetRoot then
					local screenPosition, onScreen = CurrentCamera:WorldToViewportPoint(targetRoot.Position)
					if not onScreen then continue end
					if self.Config.FOV.Enabled then
						local screenVector = Vector2.new(screenPosition.X, screenPosition.Y)
						if (screenVector - screenCenter).Magnitude > self.Config.FOV.Radius then
							continue
						end
					end
					local distance = (targetRoot.Position - rootPart.Position).Magnitude
					if distance < bestDistance then
						bestPlayer = player
						bestDistance = distance
					end
				end
			end
		end
	end
	return bestPlayer, bestDistance
end

function TargetTracker:updateSphere()
	local sphere = self.SphereVisualization
	if not sphere then return end
	local config = self.Config.PredictionSphere
	if not config.Enabled or not self.PredictedCFrame then
		sphere.Transparency = 1
		if self.SphereTrail then self.SphereTrail.Enabled = false end
		return
	end
	sphere.CFrame = self.PredictedCFrame
	if not config.Pulse then
		sphere.Size = Vector3.new(config.Size, config.Size, config.Size)
	end
	sphere.Transparency = config.Transparency
	if not config.Rainbow then
		sphere.Color = config.Color
	end
	if self.SphereTrail then
		self.SphereTrail.Enabled = config.Trail
	end
end

function TargetTracker:updateTracking()
	if not self.Config.Enabled then
		self.CurrentTarget = nil
		self.PredictedCFrame = nil
		self.TargetScreenPosition = nil
		if self.FieldOfViewFrame then self.FieldOfViewFrame.Visible = false end
		self:removeAllHighlights()
		if self.SphereVisualization then self.SphereVisualization.Transparency = 1 end
		return
	end
	local character = LocalPlayer.Character
	local rootPart = character and character:FindFirstChild("HumanoidRootPart")
	if not rootPart then return end
	local player, _ = self:findNearestTarget()
	if player then
		local targetCharacter = player.Character
		local targetRoot = targetCharacter and targetCharacter:FindFirstChild("HumanoidRootPart")
		if targetRoot then
			local humanoid = targetCharacter:FindFirstChild("Humanoid")
			if humanoid then
				local hitByValue = humanoid:FindFirstChild("HitBy")
				local disabledByCC = humanoid:FindFirstChild("DisabledByCC")
				if hitByValue and tostring(hitByValue.Value) == LocalPlayer.Name and disabledByCC then
					self.TargetIsStunned = true
				else
					self.TargetIsStunned = false
				end
			else
				self.TargetIsStunned = false
			end
			self.CurrentTarget = player
			self.PredictedCFrame = targetRoot.CFrame
			local screenPoint, onScreen = CurrentCamera:WorldToViewportPoint(targetRoot.Position)
			if onScreen then
				self.TargetScreenPosition = Vector2.new(screenPoint.X, screenPoint.Y)
			end
			for highlightCharacter, highlight in pairs(self.Highlights) do
				if highlightCharacter ~= targetCharacter then
					if highlight and highlight.Parent then highlight:Destroy() end
					self.Highlights[highlightCharacter] = nil
				end
			end
			self:applyHighlight(targetCharacter)
			self:updateSphere()
		else
			self.CurrentTarget = nil
			self.PredictedCFrame = nil
			self.TargetScreenPosition = nil
			self:removeAllHighlights()
			if self.SphereVisualization then self.SphereVisualization.Transparency = 1 end
			if self.SphereTrail then self.SphereTrail.Enabled = false end
		end
	else
		self.CurrentTarget = nil
		self.PredictedCFrame = nil
		self.TargetScreenPosition = nil
		self:removeAllHighlights()
		if self.SphereVisualization then self.SphereVisualization.Transparency = 1 end
		if self.SphereTrail then self.SphereTrail.Enabled = false end
	end
	if self.FieldOfViewFrame then
		self.FieldOfViewFrame.Visible = self.Config.FOV.Visible and self.Config.Enabled
	end
end

local updateCharData = nil
local replicatedStorage = game:GetService("ReplicatedStorage")
local remoteFolder = replicatedStorage:FindFirstChild("Remotes")
if remoteFolder then
	updateCharData = remoteFolder:FindFirstChild("UpdateCharData")
end
if not updateCharData then
	for _, descendant in pairs(workspace:GetDescendants()) do
		if descendant.Name == "UpdateCharData" then
			updateCharData = descendant
			break
		end
	end
end

local puppyware = loadstring(game:HttpGet("https://raw.githubusercontent.com/r0cu3elite/PuppywareUI/main/source.lua"))()
local puppywareWindow = puppyware:Window({
	accent = Color3.fromRGB(0, 210, 255),
})

local silentAimPage = puppywareWindow:Page({ name = "Silent Aim" })
local visualPage = puppywareWindow:Page({ name = "Visual" })
local miscPage = puppywareWindow:Page({ name = "Misc" })

local silentAimSection = silentAimPage:Section({ name = "Silent Aim" })
local fovSection = silentAimPage:Section({ name = "FOV" })
local antiDelaySection = silentAimPage:Section({ name = "Anti Delay" })
local dashBoostSection = silentAimPage:Section({ name = "Dash Boost" })

local fakePingSection = visualPage:Section({ name = "Fake Ping" })
local targetSphereSection = visualPage:Section({ name = "Target Sphere" })

local serverSection = miscPage:Section({ name = "Server" })
local scriptSection = miscPage:Section({ name = "Script" })
local webhookSection = miscPage:Section({ name = "Webhook" })
local autoBlockSection = miscPage:Section({ name = "Auto Block" })
local performanceSection = miscPage:Section({ name = "Performance" })

silentAimSection:Toggle({
	name = "Enable Silent Aim",
	default = false,
	callback = function(value)
		TargetTracker.Config.Enabled = value
		saveData()
	end,
})

silentAimSection:Dropdown({
	name = "Target Mode",
	options = { "Blacklist", "Whitelist" },
	default = "Blacklist",
	callback = function(value)
		TargetTracker.Config.Mode = value
		saveData()
	end,
})

silentAimSection:Toggle({
	name = "Ignore Ally",
	default = false,
	callback = function(value)
		TargetTracker.Config.IgnoreAlly = value
		saveData()
	end,
})

silentAimSection:Toggle({
	name = "Mouse Silent",
	default = false,
	callback = function(value)
		TargetTracker.Config.MouseSilent = value
		saveData()
	end,
})

silentAimSection:Toggle({
	name = "Longer Hit",
	default = false,
	callback = function(value)
		longerHit = value
		saveData()
	end,
})

silentAimSection:Toggle({
	name = "Use Roster CFrame",
	default = false,
	callback = function(value)
		useRosterCFrame = value
		saveData()
	end,
})

silentAimSection:List({
	name = "Blacklist",
	callback = function(list)
		TargetTracker.Config.BlacklistedPlayers = list
		saveData()
	end,
})

silentAimSection:List({
	name = "Whitelist",
	callback = function(list)
		TargetTracker.Config.WhitelistedPlayers = list
		saveData()
	end,
})

fovSection:Toggle({
	name = "Enable FOV",
	default = false,
	callback = function(value)
		TargetTracker.Config.FOV.Enabled = value
		saveData()
	end,
})

fovSection:Toggle({
	name = "Show FOV Circle",
	default = false,
	callback = function(value)
		TargetTracker.Config.FOV.Visible = value
		if TargetTracker.FieldOfViewFrame then
			TargetTracker.FieldOfViewFrame.Visible = value and TargetTracker.Config.Enabled
		end
		saveData()
	end,
})

fovSection:Slider({
	name = "FOV Radius",
	min = 50,
	max = 800,
	default = 300,
	callback = function(value)
		TargetTracker.Config.FOV.Radius = value
		if TargetTracker.FieldOfViewFrame then
			TargetTracker.FieldOfViewFrame.Radius = value
		end
		saveData()
	end,
})

fovSection:Slider({
	name = "FOV Thickness",
	min = 1,
	max = 10,
	default = 2,
	callback = function(value)
		TargetTracker.Config.FOV.Thickness = value
		if TargetTracker.FieldOfViewFrame then
			TargetTracker.FieldOfViewFrame.Thickness = value
		end
		saveData()
	end,
})

fovSection:ColorPicker({
	name = "FOV Color",
	default = Color3.new(1, 1, 1),
	callback = function(value)
		TargetTracker.Config.FOV.Color = value
		if TargetTracker.FieldOfViewFrame then
			TargetTracker.FieldOfViewFrame.Color3 = value
		end
		saveData()
	end,
})

antiDelaySection:Toggle({
	name = "Enable Anti Delay",
	default = false,
	callback = function(value)
		if value then
			if getgenv().AntiDelayConnection then
				getgenv().AntiDelayConnection:Disconnect()
				getgenv().AntiDelayConnection = nil
			end
			getgenv().AntiDelayConnection = RunService.Heartbeat:Connect(function()
				if scriptKilled then
					getgenv().AntiDelayConnection:Disconnect()
					getgenv().AntiDelayConnection = nil
					return
				end
				local character = LocalPlayer.Character
				if not character then return end
				local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
				if not humanoidRootPart then return end
				if updateCharData then
					pcall(function()
						updateCharData:FireServer(humanoidRootPart.CFrame, Vector2.new(0, 0), humanoidRootPart.CFrame)
					end)
				end
			end)
		else
			if getgenv().AntiDelayConnection then
				getgenv().AntiDelayConnection:Disconnect()
				getgenv().AntiDelayConnection = nil
			end
		end
	end,
})

_G.DashSpeed = _G.DashSpeed or 4250

dashBoostSection:Toggle({
	name = "Enable Dash Boost",
	default = false,
	callback = function(value)
		if value then
			if getgenv().DashBoostConnection then
				getgenv().DashBoostConnection:Disconnect()
				getgenv().DashBoostConnection = nil
			end
			getgenv().DashBoostConnection = RunService.Heartbeat:Connect(function()
				if scriptKilled then
					getgenv().DashBoostConnection:Disconnect()
					getgenv().DashBoostConnection = nil
					return
				end
				local character = LocalPlayer.Character
				if not character then return end
				local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
				if not humanoidRootPart then return end
				local velocity = humanoidRootPart.AssemblyLinearVelocity
				local speed = velocity.Magnitude
				if speed > 50 and speed < _G.DashSpeed then
					humanoidRootPart.AssemblyLinearVelocity = velocity.Unit * _G.DashSpeed
				end
			end)
		else
			if getgenv().DashBoostConnection then
				getgenv().DashBoostConnection:Disconnect()
				getgenv().DashBoostConnection = nil
			end
		end
	end,
})

dashBoostSection:Slider({
	name = "Dash Speed",
	min = 1000,
	max = 10000,
	default = 4250,
	callback = function(value)
		_G.DashSpeed = value
	end,
})

fakePingSection:Toggle({
	name = "Enable Fake Ping",
	default = false,
	callback = function(value)
		FakePing.Enabled = value
		saveData()
	end,
})

fakePingSection:Slider({
	name = "Fake Ping Amount",
	min = 0,
	max = 500,
	default = 0,
	callback = function(value)
		FakePing.Amount = value
		saveData()
	end,
})

fakePingSection:Toggle({
	name = "Lock Fake Ping",
	default = false,
	callback = function(value)
		FakePing.Locked = value
		saveData()
	end,
})

targetSphereSection:Toggle({
	name = "Enable Target Sphere",
	default = false,
	callback = function(value)
		TargetTracker.Config.PredictionSphere.Enabled = value
		if not value and TargetTracker.SphereVisualization then
			TargetTracker.SphereVisualization.Transparency = 1
		end
		saveData()
	end,
})

targetSphereSection:ColorPicker({
	name = "Sphere Color",
	default = Color3.fromRGB(255, 0, 0),
	callback = function(value)
		TargetTracker.Config.PredictionSphere.Color = value
		if TargetTracker.SphereVisualization and not TargetTracker.Config.PredictionSphere.Rainbow then
			TargetTracker.SphereVisualization.Color = value
		end
		saveData()
	end,
})

targetSphereSection:Slider({
	name = "Sphere Transparency",
	min = 0,
	max = 1,
	default = 0.5,
	callback = function(value)
		TargetTracker.Config.PredictionSphere.Transparency = value
		saveData()
	end,
})

targetSphereSection:Slider({
	name = "Sphere Size",
	min = 1,
	max = 20,
	default = 3,
	callback = function(value)
		TargetTracker.Config.PredictionSphere.Size = value
		saveData()
	end,
})

targetSphereSection:Toggle({
	name = "Sphere Trail",
	default = false,
	callback = function(value)
		TargetTracker.Config.PredictionSphere.Trail = value
		if TargetTracker.SphereTrail then
			TargetTracker.SphereTrail.Enabled = value and TargetTracker.Config.PredictionSphere.Enabled
		end
		saveData()
	end,
})

targetSphereSection:Toggle({
	name = "Rainbow Sphere",
	default = false,
	callback = function(value)
		TargetTracker.Config.PredictionSphere.Rainbow = value
		if not value then
			if TargetTracker.RainbowConnection then
				TargetTracker.RainbowConnection:Disconnect()
				TargetTracker.RainbowConnection = nil
			end
		else
			if TargetTracker.RainbowConnection then TargetTracker.RainbowConnection:Disconnect() end
			TargetTracker.RainbowConnection = RunService.Heartbeat:Connect(function()
				if scriptKilled then
					TargetTracker.RainbowConnection:Disconnect()
					TargetTracker.RainbowConnection = nil
					return
				end
				if TargetTracker.SphereVisualization and TargetTracker.Config.PredictionSphere.Rainbow then
					local hue = (tick() % 5) / 5
					TargetTracker.SphereVisualization.Color = Color3.fromHSV(hue, 1, 1)
				end
			end)
		end
		saveData()
	end,
})

targetSphereSection:Toggle({
	name = "Pulse Sphere",
	default = false,
	callback = function(value)
		TargetTracker.Config.PredictionSphere.Pulse = value
		if not value then
			if TargetTracker.PulseConnection then
				TargetTracker.PulseConnection:Disconnect()
				TargetTracker.PulseConnection = nil
			end
		else
			if TargetTracker.PulseConnection then TargetTracker.PulseConnection:Disconnect() end
			TargetTracker.PulseConnection = RunService.Heartbeat:Connect(function()
				if scriptKilled then
					TargetTracker.PulseConnection:Disconnect()
					TargetTracker.PulseConnection = nil
					return
				end
				if TargetTracker.SphereVisualization and TargetTracker.Config.PredictionSphere.Pulse then
					local pulse = (math.sin(tick() * 4) + 1) / 2
					local baseSize = TargetTracker.Config.PredictionSphere.Size
					TargetTracker.SphereVisualization.Size = Vector3.new(
						baseSize + pulse * 2,
						baseSize + pulse * 2,
						baseSize + pulse * 2
					)
				end
			end)
		end
		saveData()
	end,
})

local webhookUrl = ""

webhookSection:TextBox({
	name = "Webhook URL",
	placeholder = "https://discord.com/api/webhooks/...",
	callback = function(value)
		webhookUrl = value
	end,
})

webhookSection:Button({
	name = "Send Test",
	callback = function()
		if webhookUrl == "" then return end
		pcall(function()
			HttpService:PostAsync(webhookUrl, HttpService:JSONEncode({
				content = "Puppyware test message from " .. LocalPlayer.Name,
			}))
		end)
	end,
})

serverSection:Button({
	name = "Rejoin Server",
	callback = function()
		local TeleportService = game:GetService("TeleportService")
		TeleportService:Teleport(game.PlaceId, LocalPlayer)
	end,
})

serverSection:Button({
	name = "Leave Server",
	callback = function()
		game:Shutdown()
	end,
})

autoBlockSection:Toggle({
	name = "Enable Auto Block",
	default = false,
	callback = function(value)
		AutoBlock.Enabled = value
		if value then
			if AutoBlock.BlockConnection then AutoBlock.BlockConnection:Disconnect() end
			AutoBlock.BlockConnection = RunService.Heartbeat:Connect(function()
				if scriptKilled then
					AutoBlock.BlockConnection:Disconnect()
					AutoBlock.BlockConnection = nil
					return
				end
				local character = LocalPlayer.Character
				if not character then return end
				local humanoid = character:FindFirstChild("Humanoid")
				if not humanoid then return end
				local hitBy = humanoid:FindFirstChild("HitBy")
				if hitBy and hitBy.Value ~= "" then
					local blockRemote = character:FindFirstChild("Block")
					if blockRemote then
						pcall(function() blockRemote:FireServer(true) end)
						if AutoBlock.UnblockThread then task.cancel(AutoBlock.UnblockThread) end
						AutoBlock.UnblockThread = task.delay(AutoBlock.Window, function()
							pcall(function() blockRemote:FireServer(false) end)
						end)
					end
				end
			end)
		else
			if AutoBlock.BlockConnection then
				AutoBlock.BlockConnection:Disconnect()
				AutoBlock.BlockConnection = nil
			end
		end
		saveData()
	end,
})

autoBlockSection:Slider({
	name = "Block Window (s)",
	min = 0.1,
	max = 2.0,
	default = 0.4,
	callback = function(value)
		AutoBlock.Window = value
		saveData()
	end,
})

performanceSection:Button({
	name = "Garbage Collect",
	callback = function()
		collectgarbage("collect")
	end,
})

scriptSection:Button({
	name = "Save Config",
	callback = function()
		saveData()
	end,
})

scriptSection:Button({
	name = "Load Config",
	callback = function()
		loadData()
	end,
})

scriptSection:Button({
	name = "Kill Script",
	callback = function()
		scriptKilled = true
		TargetTracker:removeAllHighlights()
		if TargetTracker.RainbowConnection then TargetTracker.RainbowConnection:Disconnect() end
		if TargetTracker.PulseConnection then TargetTracker.PulseConnection:Disconnect() end
		if getgenv().AntiDelayConnection then getgenv().AntiDelayConnection:Disconnect() end
		if getgenv().DashBoostConnection then getgenv().DashBoostConnection:Disconnect() end
		if AutoBlock.BlockConnection then AutoBlock.BlockConnection:Disconnect() end
		if TargetTracker.SphereVisualization then TargetTracker.SphereVisualization:Destroy() end
		if TargetTracker.FieldOfViewFrame then TargetTracker.FieldOfViewFrame:Remove() end
		pcall(function() puppywareWindow.screen:Destroy() end)
	end,
})

local fovCircle = Drawing.new("Circle")
fovCircle.Visible = false
fovCircle.Filled = false
fovCircle.Radius = silentAimConfig.FOV.Radius
fovCircle.Thickness = silentAimConfig.FOV.Thickness
fovCircle.Color3 = silentAimConfig.FOV.Color
fovCircle.Position = Vector2.new(CurrentCamera.ViewportSize.X / 2, CurrentCamera.ViewportSize.Y / 2)
TargetTracker.FieldOfViewFrame = fovCircle

local spherePart = Instance.new("Part")
spherePart.Name = "TargetSphere"
spherePart.Shape = Enum.PartType.Ball
spherePart.Material = Enum.Material.Neon
spherePart.CanCollide = false
spherePart.Anchored = true
spherePart.Transparency = 1
spherePart.Size = Vector3.new(3, 3, 3)
spherePart.Color = silentAimConfig.PredictionSphere.Color
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

		if scriptKilled then
			return getgenv().OriginalNamecallHook(table.unpack(arguments, 1, arguments.n))
		end

		if FakePing.Enabled and method == "FireServer" and FakePing.Amount > 0 then
			task.wait(FakePing.Amount / 1000)
		end

		if not TargetTracker.Config.Enabled
			or hookSelf ~= updateCharData
			or method ~= "FireServer"
		then
			return getgenv().OriginalNamecallHook(table.unpack(arguments, 1, arguments.n))
		end

		if not TargetTracker.PredictedCFrame or TargetTracker.TargetIsStunned then
			return getgenv().OriginalNamecallHook(table.unpack(arguments, 1, arguments.n))
		end

		local modified = table.pack(table.unpack(arguments, 1, arguments.n))
		modified[2] = TargetTracker.PredictedCFrame

		if longerHit or TargetTracker.Config.MouseSilent then
			if TargetTracker.TargetScreenPosition then
				modified[3] = TargetTracker.TargetScreenPosition
			end
		end

		if useRosterCFrame and TargetTracker.CurrentTarget then
			local targetCharacter = TargetTracker.CurrentTarget.Character
			local targetRoot = targetCharacter and targetCharacter:FindFirstChild("HumanoidRootPart")
			if targetRoot then
				modified[4] = targetRoot.CFrame
			end
		end

		return getgenv().OriginalNamecallHook(table.unpack(modified, 1, modified.n))
	end)
end

getgenv().SilentAimTracker = TargetTracker

RunService.Heartbeat:Connect(function()
	if scriptKilled then return end
	TargetTracker:updateTracking()
	if TargetTracker.FieldOfViewFrame then
		TargetTracker.FieldOfViewFrame.Position = Vector2.new(
			CurrentCamera.ViewportSize.X / 2,
			CurrentCamera.ViewportSize.Y / 2
		)
		TargetTracker.FieldOfViewFrame.Radius = TargetTracker.Config.FOV.Radius
	end
end)
