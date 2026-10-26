if game.PlaceId ~= 914010731 then return end

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TeleportService = game:GetService("TeleportService")

local LocalPlayer = Players.LocalPlayer
local CurrentCamera = workspace.CurrentCamera

if not isfolder("Porry_RoGhoul") then makefolder("Porry_RoGhoul") end
if not isfolder("Porry_RoGhoul/SilentAimConfig") then makefolder("Porry_RoGhoul/SilentAimConfig") end

local function deepCopyTable(tbl)
	if type(tbl) ~= "table" then return tbl end
	local copy = {}
	for k, v in pairs(tbl) do
		copy[k] = type(v) == "table" and deepCopyTable(v) or v
	end
	return copy
end

local function getCache(base, override)
	local copy = deepCopyTable(base)
	if type(override) ~= "table" then return copy end
	for k, v in pairs(override) do
		if type(v) == "table" and type(copy[k]) == "table" then
			copy[k] = getCache(copy[k], v)
		else
			copy[k] = v
		end
	end
	return copy
end

local teamValue = ""
pcall(function()
	local pf = LocalPlayer:WaitForChild("PlayerFolder", 15)
	if pf then
		local cust = pf:WaitForChild("Customization", 10)
		if cust then
			local team = cust:WaitForChild("Team", 10)
			if team then teamValue = team.Value end
		end
	end
end)

pcall(function()
	ReplicatedStorage.Remotes:WaitForChild("Ally", 10):WaitForChild("AllyInfo", 10):InvokeServer()
end)

local settingsFile = "Porry_RoGhoul/" .. LocalPlayer.Name .. "." .. teamValue .. ".settings"

local defaultSettings = {
	AntiDelay = false,
	Webhook = {
		URL = "https://discord.com/api/",
		SendStats = false,
		Interval = 5,
		PingEveryone = false,
		KickNotifer = false
	}
}

local settingsSaveThread

local function scheduleSettingsSave()
	pcall(function()
		if writefile then
			if settingsSaveThread then task.cancel(settingsSaveThread); settingsSaveThread = nil end
			settingsSaveThread = task.delay(0.5, function()
				writefile(settingsFile, HttpService:JSONEncode(_G.CurrentSettings))
				settingsSaveThread = nil
			end)
		end
	end)
end

if not isfile(settingsFile) then
	writefile(settingsFile, HttpService:JSONEncode(defaultSettings))
end

local ok, result = pcall(function() return HttpService:JSONDecode(readfile(settingsFile)) end)
_G.CurrentSettings = ok and getCache(defaultSettings, result) or deepCopyTable(defaultSettings)
scheduleSettingsSave()

local SA_Config = {
	Enabled = false,
	Mode = "Blacklist",
	IgnoreAlly = true,
	PredictionMode = "Distance",
	PredictionTime = 0.15,
	SkillSpeed = 1000,
	WhitelistedPlayers = {},
	BlacklistedPlayers = {},
	Whitelist = {},
	Blacklist = {},
	NPCSupport = false,
	FOV = { Enabled = false, Radius = 300, Visible = false, Thickness = 2, Color = Color3.new(1,1,1) },
	Highlight = {
		Enabled = false,
		OutlineTransparency = 0.5,
		FillTransparency = 0.8,
		DistanceColorEnabled = false,
		CloseDistance = 10,
		FarDistance = 50,
		OutlineColor = Color3.new(0,1,0),
		FillColor = Color3.new(1,0,0),
		CloseColor = Color3.new(1,0,0),
		MidColor = Color3.new(1,1,0),
		FarColor = Color3.new(0,1,0)
	},
	PredictionSphere = {
		Enabled = false,
		Size = 5,
		Transparency = 0.4,
		TrailEffect = false,
		TrailLength = 5,
		RainbowEffect = false,
		RainbowSpeed = 1,
		Material = Enum.Material.ForceField,
		Color = Color3.new(1,0,1),
		PulseEffect = false,
		PulseSpeed = 0.8,
		PulseSize = { Min = 1, Max = 2 }
	},
	MouseSilent = false,
}

local SA_SilentAimFile = "Porry_RoGhoul/SilentAimConfig/" .. LocalPlayer.Name .. "." .. teamValue .. ".porry"
local SA_FileOk, SA_FileResult = pcall(function() return HttpService:JSONDecode(readfile(SA_SilentAimFile)) end)
_G.SilentAimSettings = SA_FileOk and getCache({ Config = SA_Config }, SA_FileResult) or { Config = SA_Config }

local SA_SaveThread

local function saveSilentAimSettings()
	pcall(function()
		if writefile then
			if SA_SaveThread then task.cancel(SA_SaveThread); SA_SaveThread = nil end
			SA_SaveThread = task.delay(0.5, function()
				writefile(SA_SilentAimFile, HttpService:JSONEncode(_G.SilentAimSettings))
				SA_SaveThread = nil
			end)
		end
	end)
end

local SA_PlayerList = {}
local SA_NPCCache = {}

local TT = {
	CurrentTarget = nil,
	NPCTarget = nil,
	PredictedPosition = nil,
	PredictedCF = nil,
	ScreenPos = nil,
	PredictionVisualization = nil,
	PredictionTrail = nil,
	TargetGetAttacked = false,
	Config = SA_Config,
	Highlights = {},
	FOVCircleFrame = nil,
	_rainbowConnection = nil,
}

local SA_ScreenGui = Instance.new("ScreenGui")
SA_ScreenGui.Name = "TargetTrackerUI"
SA_ScreenGui.ResetOnSpawn = false
SA_ScreenGui.DisplayOrder = -9999
SA_ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
pcall(function()
	local synLib = rawget(_G, "syn")
	if synLib then synLib.protect_gui(SA_ScreenGui) end
end)
SA_ScreenGui.Parent = game.CoreGui

local SA_FOVFrame = Instance.new("Frame")
SA_FOVFrame.AnchorPoint = Vector2.new(0.5, 0.5)
SA_FOVFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
SA_FOVFrame.Size = UDim2.new(0, TT.Config.FOV.Radius * 2, 0, TT.Config.FOV.Radius * 2)
SA_FOVFrame.BackgroundTransparency = 1
SA_FOVFrame.Parent = SA_ScreenGui

local SA_FOVCorner = Instance.new("UICorner")
SA_FOVCorner.CornerRadius = UDim.new(0, TT.Config.FOV.Radius)
SA_FOVCorner.Parent = SA_FOVFrame

local SA_FOVStroke = Instance.new("UIStroke")
SA_FOVStroke.Thickness = TT.Config.FOV.Thickness
SA_FOVStroke.Color = TT.Config.FOV.Color
SA_FOVStroke.Parent = SA_FOVFrame

TT.FOVCircleFrame = SA_FOVFrame

local function SA_CreateSphere()
	local Part = Instance.new("Part")
	Part.Name = "PredictionVisualization"
	Part.Shape = Enum.PartType.Ball
	Part.Size = Vector3.new(TT.Config.PredictionSphere.Size, TT.Config.PredictionSphere.Size, TT.Config.PredictionSphere.Size)
	Part.Material = TT.Config.PredictionSphere.Material
	Part.Color = TT.Config.PredictionSphere.Color
	Part.Transparency = 1
	Part.Anchored = true
	Part.CanCollide = false
	Part.Parent = workspace

	local Attachment = Instance.new("Attachment", Part)
	local ParticleEmitter = Instance.new("ParticleEmitter", Attachment)
	ParticleEmitter.Color = ColorSequence.new(Part.Color)
	ParticleEmitter.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.7),
		NumberSequenceKeypoint.new(0.5, 0.5),
		NumberSequenceKeypoint.new(1, 1)
	})
	ParticleEmitter.Size = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.2),
		NumberSequenceKeypoint.new(1, 0)
	})
	ParticleEmitter.Lifetime = NumberRange.new(0.5, 1)
	ParticleEmitter.Rate = 30
	ParticleEmitter.Speed = NumberRange.new(3, 5)
	ParticleEmitter.SpreadAngle = Vector2.new(180, 180)

	if TT.Config.PredictionSphere.TrailEffect then
		local a1 = Instance.new("Attachment", Part)
		a1.Position = Vector3.new(0, 0.5, 0)
		local a2 = Instance.new("Attachment", Part)
		a2.Position = Vector3.new(0, -0.5, 0)
		local Trail = Instance.new("Trail", Part)
		Trail.Color = ColorSequence.new(Part.Color)
		Trail.Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0.4),
			NumberSequenceKeypoint.new(1, 1)
		})
		Trail.Lifetime = TT.Config.PredictionSphere.TrailLength / 10
		Trail.MinLength = 0.1
		Trail.MaxLength = 5
		Trail.Attachment0 = a1
		Trail.Attachment1 = a2
		TT.PredictionTrail = Trail
	end

	TT.PredictionVisualization = Part
end

SA_CreateSphere()

function TT:CreateHighlightForPlayer(player)
	if not player.Character then return nil end
	if self.Highlights[player.Name] then return self.Highlights[player.Name] end
	local h = Instance.new("Highlight")
	h.OutlineColor = self.Config.Highlight.OutlineColor
	h.OutlineTransparency = self.Config.Highlight.OutlineTransparency
	h.FillColor = self.Config.Highlight.FillColor
	h.FillTransparency = self.Config.Highlight.FillTransparency
	h.Adornee = player.Character
	h.Enabled = true
	h.Parent = workspace
	self.Highlights[player.Name] = h
	return h
end

function TT:RemoveHighlight(name)
	if self.Highlights[name] then
		self.Highlights[name]:Destroy()
		self.Highlights[name] = nil
	end
end

function TT:RemoveAllHighlights()
	for _, h in pairs(self.Highlights) do h:Destroy() end
	self.Highlights = {}
end

local SA_LastHLUpdate = 0
function TT:UpdateHighlightColors(player, dist)
	local h = self.Highlights[player.Name]
	if not h or not self.Config.Highlight.DistanceColorEnabled then return end
	local now = tick()
	if now - SA_LastHLUpdate < 0.1 then return end
	SA_LastHLUpdate = now
	local t = math.clamp((dist - self.Config.Highlight.CloseDistance) / (self.Config.Highlight.FarDistance - self.Config.Highlight.CloseDistance), 0, 1)
	local c
	if t < 0.5 then
		local n = t / 0.5
		c = Color3.new(
			self.Config.Highlight.CloseColor.R + (self.Config.Highlight.MidColor.R - self.Config.Highlight.CloseColor.R) * n,
			self.Config.Highlight.CloseColor.G + (self.Config.Highlight.MidColor.G - self.Config.Highlight.CloseColor.G) * n,
			self.Config.Highlight.CloseColor.B + (self.Config.Highlight.MidColor.B - self.Config.Highlight.CloseColor.B) * n
		)
	else
		local n = (t - 0.5) / 0.5
		c = Color3.new(
			self.Config.Highlight.MidColor.R + (self.Config.Highlight.FarColor.R - self.Config.Highlight.MidColor.R) * n,
			self.Config.Highlight.MidColor.G + (self.Config.Highlight.FarColor.G - self.Config.Highlight.MidColor.G) * n,
			self.Config.Highlight.MidColor.B + (self.Config.Highlight.FarColor.B - self.Config.Highlight.MidColor.B) * n
		)
	end
	h.OutlineColor = c
end

function TT:IsValidTarget(player)
	if player and player ~= LocalPlayer then
		if self.Config.IgnoreAlly then
			local allied = LocalPlayer.PlayerFolder and LocalPlayer.PlayerFolder:FindFirstChild("Allied")
			if allied and allied:FindFirstChild(player.Name) then return false end
		end
		if self.Config.Mode == "Whitelist" then return self.Config.WhitelistedPlayers[player.Name] == true end
		if self.Config.Mode == "Blacklist" then return self.Config.BlacklistedPlayers[player.Name] ~= true end
		return false
	end
	return false
end

function TT:PredictPosition(player, time)
	local char = player.Character
	if char then
		local hrp = char:FindFirstChild("HumanoidRootPart")
		if hrp then return hrp.Position + hrp.Velocity * time end
	end
	return nil
end

function TT:PredictPositionByDistance(player, origin, speed)
	local char = player.Character
	if char then
		local hrp = char:FindFirstChild("HumanoidRootPart")
		if hrp then return hrp.Position + hrp.Velocity * ((hrp.Position - origin).Magnitude / speed) end
	end
	return nil
end

local SA_CachedPing, SA_PingCacheTime = 0, 0
local function getPing()
	local now = tick()
	if now - SA_PingCacheTime >= 1 then
		SA_PingCacheTime = now
		pcall(function()
			local s = (game:GetService("Stats") :: any).Network.ServerStatsItem["Data Ping"]
			SA_CachedPing = s and s.Value or 0
		end)
	end
	return SA_CachedPing
end

function TT:FindNearestNPC()
	local char = LocalPlayer.Character
	if not char then return nil end
	local hrp = char:FindFirstChild("HumanoidRootPart")
	if not hrp or not CurrentCamera then return nil end
	local vpSize = CurrentCamera.ViewportSize
	local center = Vector2.new(vpSize.X / 2, vpSize.Y / 2)
	local bestChar, bestDist = nil, math.huge
	for npcChar, humanoid in pairs(SA_NPCCache) do
		if humanoid and humanoid.Parent and humanoid.Health > 0 then
			local npcHrp = npcChar:FindFirstChild("HumanoidRootPart") or npcChar:FindFirstChildWhichIsA("BasePart")
			if npcHrp then
				local dist = (npcHrp.Position - hrp.Position).Magnitude
				if self.Config.FOV.Enabled then
					local sp, onScreen = CurrentCamera:WorldToViewportPoint(npcHrp.Position)
					if onScreen and (Vector2.new(sp.X, sp.Y) - center).Magnitude <= self.Config.FOV.Radius then
						if dist < bestDist then bestChar = npcChar; bestDist = dist end
					end
				else
					if dist < bestDist then bestChar = npcChar; bestDist = dist end
				end
			end
		end
	end
	return bestChar, bestDist
end

function TT:PredictNPCPosition(npcChar, time)
	local hrp = npcChar:FindFirstChild("HumanoidRootPart")
	if hrp then return hrp.Position + hrp.Velocity * time end
	return nil
end

function TT:PredictNPCPositionByDistance(npcChar, origin, speed)
	local hrp = npcChar:FindFirstChild("HumanoidRootPart")
	if hrp then return hrp.Position + hrp.Velocity * ((hrp.Position - origin).Magnitude / speed) end
	return nil
end

function TT:FindNearestTarget()
	local char = LocalPlayer.Character
	if not char then return nil end
	local hrp = char:FindFirstChild("HumanoidRootPart")
	if not hrp or not CurrentCamera then return nil end

	local vpSize = CurrentCamera.ViewportSize
	local center = Vector2.new(vpSize.X / 2, vpSize.Y / 2)
	local bestPlayer, bestDist = nil, math.huge

	for _, player in pairs(SA_PlayerList) do
		if self:IsValidTarget(player) then
			local pChar = player.Character
			if pChar then
				local pHrp = pChar:FindFirstChild("HumanoidRootPart")
				if pHrp then
					local screenPos, onScreen = CurrentCamera:WorldToViewportPoint(pHrp.Position)
					if self.Config.FOV.Enabled then
						if onScreen and (Vector2.new(screenPos.X, screenPos.Y) - center).Magnitude <= self.Config.FOV.Radius then
							local dist = (pHrp.Position - hrp.Position).Magnitude
							if dist < bestDist then bestPlayer = player; bestDist = dist end
						end
					else
						local dist = (pHrp.Position - hrp.Position).Magnitude
						if dist < bestDist then bestPlayer = player; bestDist = dist end
					end
				end
			end
		end
	end

	return bestPlayer, bestDist
end

function TT:Track()
	if self.Config.Enabled then
		local player, dist = self:FindNearestTarget()
		local pingComp = getPing() / 1000 / 2

		if player then
			local predicted
			local char = LocalPlayer.Character
			local hrp = char and char:FindFirstChild("HumanoidRootPart")
			local humanoid = player.Character and player.Character:FindFirstChild("Humanoid")

			if humanoid and humanoid:FindFirstChild("HitBy")
				and tostring(humanoid.HitBy.Value) == LocalPlayer.Name
				and humanoid:FindFirstChild("DisabledByCC")
			then
				self.TargetGetAttacked = true
			else
				self.TargetGetAttacked = false
			end

			if self.Config.PredictionMode == "Time" then
				predicted = self:PredictPosition(player, self.Config.PredictionTime + pingComp)
			elseif self.Config.PredictionMode == "Distance" and hrp then
				predicted = self:PredictPositionByDistance(player, hrp.Position, self.Config.SkillSpeed)
			end

			if predicted and hrp then
				self.CurrentTarget = player
				self.NPCTarget = nil
				self.PredictedPosition = predicted
				self.ScreenPos = CFrame.new(predicted)
				self.PredictedCF = CFrame.lookAt(
					Vector3.new(hrp.Position.X, predicted.Y, hrp.Position.Z),
					Vector3.new(predicted.X, predicted.Y, predicted.Z)
				)

				if self.Config.PredictionSphere.Enabled then
					if not self.PredictionVisualization then SA_CreateSphere() end
					self.PredictionVisualization.Position = predicted
					self.PredictionVisualization.Transparency = self.Config.PredictionSphere.Transparency
				elseif self.PredictionVisualization then
					self.PredictionVisualization.Transparency = 1
				end

				if self.Config.Highlight.Enabled then
					self:CreateHighlightForPlayer(player)
					self:UpdateHighlightColors(player, dist)
					for k in pairs(self.Highlights) do
						if k ~= player.Name then self:RemoveHighlight(k) end
					end
				else
					self:RemoveAllHighlights()
				end
			else
				self.CurrentTarget = nil
				self.NPCTarget = nil
				self.PredictedPosition = nil
				self.PredictedCF = nil
				self:RemoveAllHighlights()
				if self.PredictionVisualization then self.PredictionVisualization.Transparency = 1 end
			end
		elseif self.Config.NPCSupport then
			local npcChar = self:FindNearestNPC()
			if npcChar then
				local predicted
				local char = LocalPlayer.Character
				local hrp = char and char:FindFirstChild("HumanoidRootPart")
				self.TargetGetAttacked = false
				if self.Config.PredictionMode == "Time" then
					predicted = self:PredictNPCPosition(npcChar, self.Config.PredictionTime + pingComp)
				elseif self.Config.PredictionMode == "Distance" and hrp then
					predicted = self:PredictNPCPositionByDistance(npcChar, hrp.Position, self.Config.SkillSpeed)
				end
				if predicted and hrp then
					self.CurrentTarget = nil
					self.NPCTarget = npcChar
					self.PredictedPosition = predicted
					self.ScreenPos = CFrame.new(predicted)
					self.PredictedCF = CFrame.lookAt(
						Vector3.new(hrp.Position.X, predicted.Y, hrp.Position.Z),
						Vector3.new(predicted.X, predicted.Y, predicted.Z)
					)
					if self.Config.PredictionSphere.Enabled then
						if not self.PredictionVisualization then SA_CreateSphere() end
						self.PredictionVisualization.Position = predicted
						self.PredictionVisualization.Transparency = self.Config.PredictionSphere.Transparency
					elseif self.PredictionVisualization then
						self.PredictionVisualization.Transparency = 1
					end
				else
					self.CurrentTarget = nil
					self.NPCTarget = nil
					self.PredictedPosition = nil
					self.PredictedCF = nil
					if self.PredictionVisualization then self.PredictionVisualization.Transparency = 1 end
				end
				self:RemoveAllHighlights()
			else
				self.CurrentTarget = nil
				self.NPCTarget = nil
				self.PredictedPosition = nil
				self.PredictedCF = nil
				self:RemoveAllHighlights()
				if self.PredictionVisualization then self.PredictionVisualization.Transparency = 1 end
			end
		else
			self.CurrentTarget = nil
			self.NPCTarget = nil
			self.PredictedPosition = nil
			self.PredictedCF = nil
			self:RemoveAllHighlights()
			if self.PredictionVisualization then self.PredictionVisualization.Transparency = 1 end
		end

		self.FOVCircleFrame.Visible = self.Config.FOV.Visible

		return
	end

	self.CurrentTarget = nil
	self.NPCTarget = nil
	self.PredictedPosition = nil
	self.PredictedCF = nil
	self.FOVCircleFrame.Visible = false
	self:RemoveAllHighlights()
	if self.PredictionVisualization then self.PredictionVisualization.Transparency = 1 end
end

function TT:SetFOVRadius(radius)
	self.Config.FOV.Radius = radius
	self.FOVCircleFrame.Size = UDim2.new(0, radius * 2, 0, radius * 2)
	local corner = self.FOVCircleFrame:FindFirstChildOfClass("UICorner")
	if corner then corner.CornerRadius = UDim.new(0, radius) end
end

getgenv().TargetTracker = TT

SA_PlayerList = Players:GetPlayers()
Players.PlayerAdded:Connect(function() SA_PlayerList = Players:GetPlayers() end)
Players.PlayerRemoving:Connect(function() task.defer(function() SA_PlayerList = Players:GetPlayers() end) end)

local function SA_CacheNPC(desc)
	if not desc:IsA("Humanoid") then return end
	local char = desc.Parent
	if not char or char == workspace then return end
	for _, p in pairs(SA_PlayerList) do if p.Character == char then return end end
	SA_NPCCache[char] = desc
end
workspace.DescendantAdded:Connect(SA_CacheNPC)
workspace.DescendantRemoving:Connect(function(desc)
	if desc:IsA("Humanoid") then SA_NPCCache[desc.Parent] = nil end
end)
for _, v in pairs(workspace:GetDescendants()) do SA_CacheNPC(v) end

local SA_TrackInterval = 1 / 30
local SA_LastTrack = 0
RunService.Heartbeat:Connect(function()
	local now = tick()
	if now - SA_LastTrack < SA_TrackInterval then return end
	SA_LastTrack = now
	TT:Track()
end)

local SA_LongerHit = false
local SA_UseRosterCF = false
local SA_MouseSilent = false

local SA_UpdateCharData = ReplicatedStorage.Remotes.UpdateCharData
local SA_OrigHook

SA_OrigHook = hookmetamethod(game, "__namecall", function(...)
	local args = table.pack(...)
	local self = args[1]

	if self ~= SA_UpdateCharData or getnamecallmethod() ~= "FireServer" then
		return SA_OrigHook(table.unpack(args, 1, args.n))
	end

	if not TT.Config.Enabled or not TT.PredictedCF or TT.TargetGetAttacked then
		return SA_OrigHook(table.unpack(args, 1, args.n))
	end

	local out = table.pack(table.unpack(args, 1, args.n))
	out[2] = TT.PredictedCF
	if SA_LongerHit or SA_MouseSilent then out[3] = TT.ScreenPos end
	if SA_UseRosterCF and TT.CurrentTarget then out[4] = TT.CurrentTarget.Character.HumanoidRootPart.CFrame end
	return SA_OrigHook(table.unpack(out, 1, out.n))
end)

local SA_PingRemote = ReplicatedStorage:FindFirstChild("Ping")
local SA_PingHook
local SA_LockPing = false
local SA_FakePingEnabled = false
local SA_FakePingAmount = 0

if SA_PingRemote then
	SA_PingHook = hookmetamethod(game, "__newindex", function(obj, key, val)
		if obj == SA_PingRemote and key == "OnClientInvoke" then
			return SA_PingHook(obj, key, function(...)
				val(...)
				return false
			end)
		end
		return SA_PingHook(obj, key, val)
	end)

	SA_PingRemote.OnClientInvoke = function()
		if SA_LockPing then wait(9000000000) end
		if SA_FakePingEnabled then
			SA_LockPing = true
			wait(SA_FakePingAmount / 1000 + math.random(1, 100) / 1000)
			SA_LockPing = false
			return true
		end
		return true
	end
end

local bossStates = {
	Gyakusatsu = false,
	["Eto Yoshimura"] = false,
	["Koutarou Amon"] = false,
	["Nishiki Nishio"] = false,
	["Touka Kirishima"] = false,
	Fighter = false
}

for _, desc in pairs(workspace.NPCSpawns:GetDescendants()) do
	if bossStates[desc.Name] ~= nil then bossStates[desc.Name] = true end
end

_G.BossStates = bossStates
_G.OnBossSpawn = nil
_G.OnBossDead = nil

workspace.NPCSpawns.DescendantAdded:Connect(function(descendant)
	if descendant.Parent.Name == "BossSpawn" or descendant.Parent.Name == "GyakusatsuSpawn" then
		local name = descendant.Name
		if bossStates[name] ~= nil then
			bossStates[name] = true
			if _G.OnBossSpawn then pcall(_G.OnBossSpawn, name, bossStates) end
		end
	end
end)

workspace.NPCSpawns.DescendantRemoving:Connect(function(descendant)
	local ok, parentName = pcall(function() return descendant.Parent.Name end)
	if ok and (parentName == "BossSpawn" or parentName == "GyakusatsuSpawn") then
		local name = descendant.Name
		if bossStates[name] ~= nil then
			bossStates[name] = false
			if _G.OnBossDead then pcall(_G.OnBossDead, name, bossStates) end
		end
	end
end)

local function TPReturner()
	local PlaceId = game.PlaceId
	local visited = {}
	local ts = os.time()

	if not pcall(function()
		visited = HttpService:JSONDecode(readfile("PorryHopperServers.porry"))
	end) then
		table.insert(visited, { timestamp = ts })
		writefile("PorryHopperServers.porry", HttpService:JSONEncode(visited))
	end

	if ts - tonumber(visited[1].timestamp) >= 1800 then
		pcall(function()
			delfile("PorryHopperServers.porry")
			visited = {}
			table.insert(visited, { timestamp = ts })
		end)
	end

	local data = HttpService:JSONDecode(
		game:HttpGet("https://games.roblox.com/v1/games/" .. PlaceId .. "/servers/Public?sortOrder=Asc&limit=100")
	)

	for _, server in pairs(data.data) do
		local jobId = tostring(server.id)
		if server.playing == nil or server.playing == "null" then server.playing = 0 end

		if tonumber(server.maxPlayers) > tonumber(server.playing) then
			local alreadyVisited = false
			for _, entry in pairs(visited) do
				if jobId == tostring(entry) then alreadyVisited = true; break end
			end

			if not alreadyVisited then
				table.insert(visited, jobId)
				wait()
				pcall(function()
					writefile("PorryHopperServers.porry", HttpService:JSONEncode(visited))
					wait()
					TeleportService:TeleportToPlaceInstance(PlaceId, jobId, LocalPlayer)
				end)
				wait(4)
			end
		end
	end
end

local function HopServer()
	TeleportService:SetTeleportSetting("PorryHopper", true)
	while wait() do pcall(TPReturner) end
end

_G.HopServer = HopServer

local function RejoinServer()
	TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
end

_G.RejoinServer = RejoinServer

_G.ToggleAntiDelay = function(state)
	_G.NoDelay = state
	_G.CurrentSettings.AntiDelay = state
	if _G.ADConnect then _G.ADConnect:Disconnect(); _G.ADConnect = nil end
	if state then
		_G.ADConnect = LocalPlayer.PlayerFolder.CanAct.Changed:Connect(function()
			LocalPlayer.PlayerFolder.CanAct.Value = true
		end)
	end
end

_G.DashSpeed    = _G.DashSpeed    or 4250
_G.DashDistance = _G.DashDistance or 50
_G.BoostSpeed    = false
_G.BoostDistance = false

local function dashBoostTowardTarget()
	local hrp  = LocalPlayer.Character.HumanoidRootPart
	local Dash = hrp.Dash
	local Unit = (Dash.Position - hrp.Position).Unit
	if _G.BoostSpeed    then Dash.P        = _G.DashSpeed    end
	if _G.BoostDistance then Dash.Position = hrp.Position + Unit * _G.DashDistance end
end

local function connectDashBoost(character)
	local hrp = character:WaitForChild("HumanoidRootPart", 10)
	if not hrp then return end
	if _G.Boosted then _G.Boosted:Disconnect(); _G.Boosted = nil end
	_G.Boosted = hrp.ChildAdded:Connect(function(child)
		if child.Name == "Dash" then pcall(dashBoostTowardTarget) end
	end)
end

LocalPlayer.CharacterAdded:Connect(function(character)
	connectDashBoost(character)
end)

LocalPlayer.CharacterRemoving:Connect(function()
	if _G.Boosted then _G.Boosted:Disconnect(); _G.Boosted = nil end
end)

if LocalPlayer.Character then
	connectDashBoost(LocalPlayer.Character)
end

_G.SilentAimTracker     = TT
_G.SaveSilentAimSettings = saveSilentAimSettings
_G.ScheduleSettingsSave  = scheduleSettingsSave

local function SA_StartRainbow()
	if TT._rainbowConnection then return end
	TT._rainbowConnection = RunService.RenderStepped:Connect(function()
		if not TT.PredictionVisualization then return end
		local t = tick() % (TT.Config.PredictionSphere.RainbowSpeed * 10) / (TT.Config.PredictionSphere.RainbowSpeed * 10)
		local hv = t * 6; local i = math.floor(hv); local f = hv - i; local q = 1 - f
		local r, g, b
		if i == 0 then r,g,b=1,f,0 elseif i==1 then r,g,b=q,1,0 elseif i==2 then r,g,b=0,1,f
		elseif i==3 then r,g,b=0,q,1 elseif i==4 then r,g,b=f,0,1 else r,g,b=1,0,q end
		local c = Color3.new(r,g,b)
		TT.PredictionVisualization.Color = c
		if TT.PredictionTrail then TT.PredictionTrail.Color = ColorSequence.new(c) end
	end)
end
local function SA_StopRainbow()
	if TT._rainbowConnection then TT._rainbowConnection:Disconnect(); TT._rainbowConnection = nil end
end

local library        = loadstring(game:HttpGet("https://raw.githubusercontent.com/imagoodpersond/puppyware/main/lib"))()
local NotifyLibrary  = loadstring(game:HttpGet("https://raw.githubusercontent.com/imagoodpersond/puppyware/main/notify"))()

local W = library:new({ name = "[⚖️BALANCE!] Ro-Ghoul [ALPHA]", color = Color3.fromRGB(0, 210, 255) })

local SilentAimPage = W:page({ name = "Silent Aim" })
local PredPage      = W:page({ name = "Prediction" })
local MiscPage      = W:page({ name = "Misc" })

SilentAimPage:openpage()

local saSec = SilentAimPage:section({ name = "Silent Aim", side = "left", size = 265 })
saSec:toggle({ name = "Enable Silent Aim",       desc = "Bends your hit CFrame toward the predicted target position each attack", def = false, callback = function(v) TT.Config.Enabled=v; _G.SilentAimSettings.Config.Enabled=v; saveSilentAimSettings() end })
saSec:toggle({ name = "NPC Support",             desc = "Extends silent aim to bosses and NPCs — scans workspace for valid humanoids. Players are always prioritised first", def = false, callback = function(v) TT.Config.NPCSupport=v; saveSilentAimSettings() end })
saSec:toggle({ name = "Silent Mouse (ClipWing)", desc = "Also moves your screen position (arg3) to the target — makes the server see you looking at them", def = false, callback = function(v) SA_MouseSilent=v; TT.Config.MouseSilent=v; _G.SilentAimSettings.Config.MouseSilent=v; saveSilentAimSettings() end })
saSec:toggle({ name = "Longer Hit",              desc = "Extends your hit range by keeping the previous hit CFrame — helps land shots at distance", def = false, callback = function(v) SA_LongerHit=v end })
saSec:toggle({ name = "Use Roster CF",           desc = "Passes the target's root CFrame as arg4 — may improve server-side hit registration", def = false, callback = function(v) SA_UseRosterCF=v end })
saSec:toggle({ name = "Ignore Ally",             desc = "Skips players in your Allied list so you never accidentally redirect hits onto teammates", def = false, callback = function(v) TT.Config.IgnoreAlly=v; saveSilentAimSettings() end })
saSec:dropdown({ name = "Mode", desc = "Whitelist = only listed players; Blacklist = everyone except listed players", def = TT.Config.Mode, options = {"Blacklist","Whitelist"}, callback = function(v) TT.Config.Mode=v; saveSilentAimSettings() end })
saSec:textbox({ name = "Whitelist", desc = "Comma-separated usernames to allow when Mode is Whitelist", def = table.concat(TT.Config.Whitelist or {}, ","), placeholder = "player1,player2", callback = function(v)
	local t = {}; local d = {}
	for s in v:gmatch("[^,]+") do local n = s:match("^%s*(.-)%s*$"); t[#t+1] = n; d[n] = true end
	TT.Config.Whitelist = t; TT.Config.WhitelistedPlayers = d; saveSilentAimSettings()
end })
saSec:textbox({ name = "Blacklist", desc = "Comma-separated usernames to skip when Mode is Blacklist", def = table.concat(TT.Config.Blacklist or {}, ","), placeholder = "player1,player2", callback = function(v)
	local t = {}; local d = {}
	for s in v:gmatch("[^,]+") do local n = s:match("^%s*(.-)%s*$"); t[#t+1] = n; d[n] = true end
	TT.Config.Blacklist = t; TT.Config.BlacklistedPlayers = d; saveSilentAimSettings()
end })

local fovSec = SilentAimPage:section({ name = "FOV", side = "left", size = 125 })
fovSec:toggle({ name = "Enable FOV",  desc = "Restricts targeting to enemies within the FOV circle — improves precision by ignoring off-screen targets", def = false, callback = function(v) TT.Config.FOV.Enabled=v; if not v then SA_FOVFrame.Visible=false end; saveSilentAimSettings() end })
fovSec:toggle({ name = "FOV Visible", desc = "Draws the FOV circle on your screen so you can see its range", def = false, callback = function(v) TT.Config.FOV.Visible=v; saveSilentAimSettings() end })
fovSec:slider({ name = "Radius",    desc = "Size of the FOV circle in pixels from screen center", def = TT.Config.FOV.Radius,    min = 50,  max = 600, rounding = true, callback = function(v) TT:SetFOVRadius(v); saveSilentAimSettings() end })
fovSec:slider({ name = "Thickness", desc = "Border thickness of the FOV circle", def = TT.Config.FOV.Thickness, min = 1, max = 6, rounding = true, callback = function(v) TT.Config.FOV.Thickness=v; SA_FOVStroke.Thickness=v; saveSilentAimSettings() end })

local adSec = SilentAimPage:section({ name = "Anti Delay", side = "left", size = 45 })
adSec:toggle({ name = "Enable Anti Delay", desc = "Forces CanAct to stay true so your character never gets stuck waiting between actions", def = false, callback = function(v) _G.ToggleAntiDelay(v); scheduleSettingsSave() end })

local hlSec = SilentAimPage:section({ name = "Highlights", side = "right", size = 125 })
hlSec:toggle({ name = "Enable Highlights", desc = "Places a visible highlight on the current silent aim target so you always know who you are locked onto", def = false, callback = function(v) TT.Config.Highlight.Enabled=v; if not v then TT:RemoveAllHighlights() end; saveSilentAimSettings() end })
hlSec:toggle({ name = "Distance Colors",   desc = "Shifts the highlight colour from red (close) to yellow to green (far) based on target distance", def = false, callback = function(v) TT.Config.Highlight.DistanceColorEnabled=v; saveSilentAimSettings() end })
hlSec:slider({ name = "Fill Transp",    desc = "Transparency of the highlight fill — 10 = invisible, 0 = solid", def = math.floor(TT.Config.Highlight.FillTransparency*10),    min = 0, max = 10, rounding = true, callback = function(v) TT.Config.Highlight.FillTransparency=v/10;    for _,h in pairs(TT.Highlights) do h.FillTransparency=v/10    end; saveSilentAimSettings() end })
hlSec:slider({ name = "Outline Transp", desc = "Transparency of the highlight outline", def = math.floor(TT.Config.Highlight.OutlineTransparency*10), min = 0, max = 10, rounding = true, callback = function(v) TT.Config.Highlight.OutlineTransparency=v/10; for _,h in pairs(TT.Highlights) do h.OutlineTransparency=v/10 end; saveSilentAimSettings() end })

local dashSec = SilentAimPage:section({ name = "Dash Boost", side = "right", size = 125 })
dashSec:toggle({ name = "Boost Speed",    desc = "Overrides the dash spring force — makes your dash reach the target faster", def = false, callback = function(v) _G.BoostSpeed=v end })
dashSec:toggle({ name = "Boost Distance", desc = "Extends how far each dash travels toward the target", def = false, callback = function(v) _G.BoostDistance=v end })
dashSec:slider({ name = "Dash Speed",    desc = "Spring force applied during a boosted dash", def = _G.DashSpeed,    min = 1000, max = 10000, rounding = true, callback = function(v) _G.DashSpeed=v end })
dashSec:slider({ name = "Dash Distance", desc = "Max stud range applied when Boost Distance is on", def = _G.DashDistance, min = 10,   max = 200,   rounding = true, callback = function(v) _G.DashDistance=v end })

local bossMon = SilentAimPage:section({ name = "Boss Monitor", side = "right", size = 50 })
bossMon:button({ name = "Refresh Bosses", callback = function()
	local t = {}
	for name, alive in pairs(bossStates) do if alive then t[#t+1] = name end end
	NotifyLibrary:notify({ message = #t > 0 and table.concat(t, ", ") or "No bosses active", color = Color3.fromRGB(0, 210, 255) })
end })
_G.OnBossSpawn = function(n) NotifyLibrary:notify({ message = n .. " spawned!",    color = Color3.fromRGB(0, 210, 255) }) end
_G.OnBossDead  = function(n) NotifyLibrary:notify({ message = n .. " eliminated.", color = Color3.fromRGB(200, 60, 60)  }) end

local predSec = PredPage:section({ name = "Prediction", side = "left", size = 125 })
predSec:dropdown({ name = "Mode",          desc = "Distance = accounts for your skill travel speed; Time = fixed offset regardless of range", def = TT.Config.PredictionMode, options = {"Distance","Time"}, callback = function(v) TT.Config.PredictionMode=v; saveSilentAimSettings() end })
predSec:slider({   name = "Skill Speed",   desc = "Studs/sec your skill travels — used by Distance mode to calculate how far ahead to aim", def = TT.Config.SkillSpeed, min = 100, max = 5000, rounding = true, callback = function(v) TT.Config.SkillSpeed=v; saveSilentAimSettings() end })
predSec:slider({   name = "Pred Time (ms)",desc = "Fixed prediction offset in ms added on top of your real ping compensation — tune until hits land", def = math.floor(TT.Config.PredictionTime * 1000), min = 0, max = 500, rounding = true, callback = function(v) TT.Config.PredictionTime=v/1000; saveSilentAimSettings() end })

local fakePingSec = PredPage:section({ name = "Fake Ping", side = "left", size = 75 })
fakePingSec:toggle({ name = "Enable Fake Ping", desc = "Artificially delays your ping response to the server — can desync timing checks", def = false, callback = function(v) SA_FakePingEnabled=v end })
fakePingSec:slider({ name = "Ping (ms)",         desc = "Amount of artificial delay added to your server ping response", def = SA_FakePingAmount, min = 0, max = 500, rounding = true, callback = function(v) SA_FakePingAmount=v end })

local sphereSec = PredPage:section({ name = "Prediction Sphere", side = "right", size = 165 })
sphereSec:toggle({ name = "Enable Sphere",  desc = "Shows a floating sphere at the predicted hit point so you can visually verify your lead", def = false, callback = function(v) TT.Config.PredictionSphere.Enabled=v; if not v and TT.PredictionVisualization then TT.PredictionVisualization.Transparency=1 end; saveSilentAimSettings() end })
sphereSec:toggle({ name = "Trail Effect",   desc = "Adds a motion trail to the sphere that follows the target's predicted path", def = false, callback = function(v) TT.Config.PredictionSphere.TrailEffect=v; saveSilentAimSettings() end })
sphereSec:toggle({ name = "Rainbow Effect", desc = "Cycles the sphere through all hue values continuously", def = false, callback = function(v) TT.Config.PredictionSphere.RainbowEffect=v; if v then SA_StartRainbow() else SA_StopRainbow() end; saveSilentAimSettings() end })
sphereSec:toggle({ name = "Pulse Effect",   desc = "Makes the sphere grow and shrink rhythmically", def = false, callback = function(v) TT.Config.PredictionSphere.PulseEffect=v; saveSilentAimSettings() end })
sphereSec:slider({ name = "Size",         desc = "Diameter of the prediction sphere in studs", def = TT.Config.PredictionSphere.Size, min = 1, max = 20, rounding = true, callback = function(v) TT.Config.PredictionSphere.Size=v; if TT.PredictionVisualization then TT.PredictionVisualization.Size=Vector3.one*v end; saveSilentAimSettings() end })
sphereSec:slider({ name = "Transparency", desc = "Opacity of the sphere — 10 = invisible, 0 = solid", def = math.floor(TT.Config.PredictionSphere.Transparency*10), min = 0, max = 10, rounding = true, callback = function(v) TT.Config.PredictionSphere.Transparency=v/10; saveSilentAimSettings() end })

local serverSec = MiscPage:section({ name = "Server", side = "left", size = 75 })
serverSec:button({ name = "Hop Server", desc = "Jumps to a different server with an open slot — skips already-visited ones for 30 minutes", callback = function() coroutine.wrap(HopServer)() end })
serverSec:button({ name = "Rejoin",     desc = "Teleports you back into this exact same server instance", callback = function() RejoinServer() end })

local scriptSec = MiscPage:section({ name = "Script", side = "left", size = 50 })
scriptSec:button({ name = "Kill Script", desc = "Cleans up all hooks, highlights, threads and GUI elements — safely unloads the script", callback = function()
	pcall(function() if _G.ADConnect then _G.ADConnect:Disconnect() end end)
	pcall(function() if _G.Boosted   then _G.Boosted:Disconnect()   end end)
	pcall(function() if TT.PredictionVisualization then TT.PredictionVisualization:Destroy() end end)
	pcall(function() if TT._rainbowConnection then TT._rainbowConnection:Disconnect() end end)
	pcall(function() TT:RemoveAllHighlights() end)
	pcall(function() SA_ScreenGui:Destroy() end)
	pcall(function() local s = game:GetService("CoreGui"):FindFirstChild(W.screen.Name); if s then s:Destroy() end end)
end })

local webhookSec = MiscPage:section({ name = "Webhook", side = "left", size = 185 })
webhookSec:textbox({ name = "URL",           desc = "Your Discord webhook URL — paste it here to enable stat posting", def = _G.CurrentSettings.Webhook.URL, placeholder = "https://discord.com/api/webhooks/...", callback = function(v) _G.CurrentSettings.Webhook.URL=v; scheduleSettingsSave() end })
webhookSec:toggle({  name = "Send Stats",    desc = "Periodically posts your in-game stats to the webhook URL above", def = false, callback = function(v) _G.CurrentSettings.Webhook.SendStats=v; scheduleSettingsSave() end })
webhookSec:slider({  name = "Interval (min)",desc = "How often stats are posted to the webhook in minutes", def = _G.CurrentSettings.Webhook.Interval, min = 1, max = 60, rounding = true, callback = function(v) _G.CurrentSettings.Webhook.Interval=v; scheduleSettingsSave() end })
webhookSec:toggle({  name = "Ping Everyone", desc = "Adds @everyone to each webhook message", def = false, callback = function(v) _G.CurrentSettings.Webhook.PingEveryone=v; scheduleSettingsSave() end })
webhookSec:toggle({  name = "Kick Notifier", desc = "Sends a webhook alert if you get kicked from the server", def = false, callback = function(v) _G.CurrentSettings.Webhook.KickNotifer=v; scheduleSettingsSave() end })

local perfSec = MiscPage:section({ name = "Performance", side = "right", size = 50 })
perfSec:button({ name = "FPS Boost", desc = "Sets graphics quality to minimum to maximise frame rate", callback = function() settings().Rendering.QualityLevel = Enum.QualityLevel.Level01 end })
