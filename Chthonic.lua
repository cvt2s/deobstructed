-- happy skidding

local genv = getgenv and getgenv() or _Gif genv.CTH_UNLOAD then
	pcall(genv.CTH_UNLOAD)
endlocal tbl = {
	destroyed = false,
	scheduler = task,
	connections = {},
	threads = setmetatable({}, {
		__mode = "k"
	}),
	cleanups = {}
}
local self = setmetatable({}, {
	__index = tbl.scheduler
})for _, v in ipairs({ "spawn", "defer", "delay" }) do
	self[v] = function(...) -- line: 18
		-- upvalues: tbl (copy), v (copy)
		local result = tbl.scheduler[v](...)		tbl.threads[result] = true		return result
	end
endlocal function getConnection(arg, callback) -- line: 25
	-- upvalues: tbl (copy)
	local connection = arg:Connect(callback)	for i = #tbl.connections, 1, -1 do
		if not tbl.connections[i].Connected then
			table.remove(tbl.connections, i)
		end
	end	table.insert(tbl.connections, connection)	return connection
endfunction tbl.onCleanup(arg) -- line: 38
	-- upvalues: tbl (copy)
	table.insert(tbl.cleanups, arg)
end
function tbl.destroy() -- line: 42
	-- upvalues: tbl (copy), genv (copy)
	if tbl.destroyed then
		return
	end	tbl.destroyed = true	local thread = coroutine.running()	for k in pairs(tbl.threads) do
		if k ~= thread then
			pcall(tbl.scheduler.cancel, k)
		end
	end	for _, v in ipairs(tbl.connections) do
		pcall(function() -- line: 56
			-- upvalues: v (copy)
			v:Disconnect()
		end)
	end	for i = #tbl.cleanups, 1, -1 do
		pcall(tbl.cleanups[i])
	end	if genv.CTH_UNLOAD == tbl.destroy then
		genv.CTH_UNLOAD = nil
	end
endtbl.threads[coroutine.running()] = true
genv.CTH_UNLOAD = tbl.destroylocal notifylocal function findPath(instance, ...) -- line: 75
	local v = table.pack(...)	for i = 1, select("#", ...) do
		if not instance then
			return nil
		end		instance = instance:FindFirstChild((select(i, table.unpack(v, 1, v.n))))
	end	return instance
endlocal pressClickDetector, getClickDetector, readFileSafedo
	local value = rawget(genv, "delfile") or (rawget(genv, "deletefile") or (rawget(_G, "delfile") or rawget(_G, "deletefile")))
	local cell = rawget(genv, "fireclickdetector") or (rawget(genv, "fireclick") or (rawget(_G, "fireclickdetector") or rawget(_G, "fireclick")))	function pressClickDetector(detector, delay) -- line: 95
		-- upvalues: cell (copy)
		if not cell or not detector then
			return false
		end		return pcall(cell, detector, delay or 0, "MouseClick") or pcall(cell, detector)
	end
	function getClickDetector(instance, n) -- line: 102
		-- upvalues: self (copy)
		if not instance then
			return nil
		end		local clickDetector = instance and instance:FindFirstChildOfClass("ClickDetector")		if clickDetector then
			return clickDetector
		end		local timestamp = tick()		while not clickDetector and instance.Parent and tick() - timestamp < (n or 3) do
			self.wait(0.05)
			clickDetector = instance and instance:FindFirstChildOfClass("ClickDetector")
		end		return clickDetector
	end
	function readFileSafe(text) -- line: 129
		-- upvalues: value (copy)
		if not value then
			return false
		end		return pcall(value, text)
	end
endpcall(function() -- line: 137
	game:GetService("ReplicatedStorage").Remotes.Settings.SpawnSelection:FireServer("Anteiku")
end)if not game:IsLoaded() then
	game.Loaded:Wait()
endself.spawn(function() -- line: 145
	-- upvalues: self (copy), findPath (copy)
	pcall(function() -- line: 146
		-- upvalues: self (copy), findPath (copy)
		if not isfolder("CTH") then
			makefolder("CTH")
		end		if not isfile("CTH/settings.json") then
			return
		end		local ok, result = pcall(function() -- line: 155
			return game:GetService("HttpService"):JSONDecode(readfile("CTH/settings.json"))
		end)		if not ok or not result or not result.autoTeam or result.autoTeam == "Disabled" then
			return
		end		self.wait(2)		local Chose = game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("Race"):WaitForChild("Chose")		pcall(function() -- line: 165
			-- upvalues: Chose (copy), result (copy)
			Chose:InvokeServer(result.autoTeam)
		end)		if result.autoTeam == "CCG" then
			self.wait(2)
			pcall(function() -- line: 172
				-- upvalues: findPath (copy)
				local Character = game:GetService("Players").LocalPlayer.Character
				local humanoidRootPart = Character and findPath(Character, "HumanoidRootPart")				if humanoidRootPart and humanoidRootPart.Position.Y > 100 then
					game:GetService("ReplicatedStorage").Remotes.Settings.SpawnSelection:FireServer("Anteiku")
				end
			end)
		end
	end)
end)local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local VirtualUser = game:GetService("VirtualUser")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayerwhile not LocalPlayer do
	self.wait(0.5)
	LocalPlayer = Players.LocalPlayer
endlocal getRemotes, clickShopIndicator, list, options, isCachedTrue, cache, currentValue, currentValue2, n, x, y, random, wait, getSpinWinCondition, flag, found, flag2, flag3, flag4, flag5, seen, primary, secondary, same, anyTwoSame, found2, found3, flag6, flag7, value, res, flag8, flag9, found4, flag10, flag11, flag12, tbl2, flag13, found5, found6, bossPosition, str, flag14, found7, found8, found9, n2, team, str2, remotes, str3, found10, tween2, hasKaguneOrQuinque, findActiveStageName, isRangeModeReady, autoSpinTick, handleEnabled, hasPlayerFolder, hasEnoughRC, isCharacterAlive, getHumanoidRootPart, getReputationTarget, cashOutReputationIfReady, statsFunction, connection, getLevelValue, items, getNearbyTargets, pickBossTarget, getPlayerStatValue, lib, tbl3, cache2, cache3, loadSettings, formatWithCommas, formatCompactNumber, handleName, lib2, lib3, cthLoading, tbl4, createMenuBuilder, getTopTargets, stopAutoFarm, setAutoFarmWhenIdle, setAutoFarmActive, resetAutoFarmState, scheduleAutoFarmAction, flag15, statusParagraph, createToggle, cthWindowdo
	local found11, n3, n4, result3_2, pressMaskKey, cycleAuraAndMask, flag16, canPlayerAct, clickOrVirtualMouse, list2, pressEachKey, updateCFrame
	local getRemotes2, list3, cache4, pickRandomItem, noRareItemsOwned, icon	do
		local function getPlayerFolder(arg) -- line: 198
			-- upvalues: findPath (copy), LocalPlayer (ref)
			return findPath(LocalPlayer, "PlayerFolder", "Stats", arg)
		end		function getRemotes2() -- line: 202
			-- upvalues: findPath (copy), LocalPlayer (ref)
			return findPath(LocalPlayer.Character, "Remotes", "KeyEvent")
		end
		function getRemotes(...) -- line: 206
			-- upvalues: findPath (copy), ReplicatedStorage (copy)
			return findPath(ReplicatedStorage, "Remotes", ...)
		end
		function clickShopIndicator(arg) -- line: 210
			-- upvalues: pressClickDetector (ref), findPath (copy)
			return pressClickDetector(if arg ~= "CCG" then findPath(workspace, "KakuhouSurgeonWarehouse", "Kakuhou Surgeon", "SurgeonIndicator", "ClickDetector") else findPath(workspace, "CCGLab", "Drawer", "ShopIndicator", "ClickDetector"))
		end		list3 = { "High Rank Aogiri Member", "Mid Rank Aogiri Member", "Low Rank Aogiri Member" }
		list = {
			{
				name = "CEO",
				minLevel = 50
			},
			{
				name = "Fighter",
				minLevel = 50
			},
			{
				name = "Touka Kirishima",
				minLevel = 250
			},
			{
				name = "Nishiki Nishio",
				minLevel = 250
			},
			{
				name = "Koutarou Amon",
				minLevel = 750
			},
			{
				name = "Young Eto Yoshimura",
				minLevel = 250
			},
			{
				name = "Kishou Arima",
				minLevel = 1250
			},
			{
				name = "Eto Yoshimura",
				minLevel = 1250
			},
			{
				name = "Gyakusatsu",
				minLevel = 1250
			}
		}		do
			local cache5 = {}			options = {}			for _, v in ipairs(list) do
				cache5[v.name] = true
				options[#options + 1] = v.name
			end			function isCachedTrue(arg) -- line: 236
				-- upvalues: cache5 (copy)
				return cache5[arg] == true
			end			cache = {
				MOUSE1 = true,
				E = false,
				R = false,
				F = false,
				C = false
			}
			currentValue = 7
			currentValue2 = 300
			n = 7
			x = 0.1
			y = 6.28
			random = Random.new()			function wait(n5, n6) -- line: 248
				-- upvalues: self (copy), random (copy)
				local n7 = n6 or 0				return self.wait(math.max(0, n5 + random:NextNumber(-n7, n7)))
			end
			function getSpinWinCondition(arg) -- line: 253
				return type(arg) == "table" and arg[1] or arg
			end			flag = false
			found = false
			flag2 = false
			flag3 = false
			flag4 = false
			flag5 = false
			seen = false
			primary = { "Really black" }
			secondary = { "Really black" }
			same = "Really black"
			anyTwoSame = false
			found2 = false
			found3 = false
			flag6 = false
			flag7 = false
			value = 0
			res = 0
			flag8 = false
			flag9 = false
			found4 = false
			flag10 = false
			flag11 = false
			flag12 = false
			tbl2 = {}
			cache4 = {}
			flag13 = false
			found5 = false
			found6 = false
			found11 = false
			n3 = 0
			n4 = 0
			bossPosition = "Orbit"
			str = "Orbit"
			flag14 = false
			found7 = false
			found8 = false
			found9 = false
			n2 = 0
			team = nil
			str2 = "Disabled"
			remotes = nil
			self.spawn(function() -- line: 299
				-- upvalues: self (copy), LocalPlayer (ref), team (ref), remotes (ref), ReplicatedStorage (copy), flag (ref)
				repeat
					self.wait(0.5)
				until LocalPlayer:FindFirstChild("PlayerFolder")				local Team = LocalPlayer.PlayerFolder.Customization.Team				repeat
					self.wait(0.5)
				until Team.Value ~= ""				team = Team.Value
				remotes = ReplicatedStorage:WaitForChild("Remotes")				if flag then
					print("-> equipe : " .. tostring(team))
				end
			end)
			str3 = "1"
			found10 = true
			tween2 = nil
			result3_2 = nil
			self.spawn(function() -- line: 323
				-- upvalues: result3_2 (ref), flag (ref), self (copy)
				local n5 = 69293053
				local n6 = 2614183822				if not getgc then
					warn("-> getgc non supporte, executeur de merde")					return
				end				local deadline = tick() + 15				repeat
					local _getgc = getgc
					local n7 = n6 % 4294967296					n6 = bit32.bxor(if n7 == n7 then n7 - n7 % 1 else 0, 3822352955)					for _, v in pairs(_getgc(true)) do
						if not result3_2 and type(v) == "function" then
							local ok, result = pcall(getinfo, v)							if ok and result and result.source and result.source:find(".ClientControl") then
								local ok2, result2 = pcall(getconstants, v)								if ok2 then
									for k, v2 in pairs(result2) do
										if v2 ~= "KeyEvent" then
											continue
										end										local ok3, result3 = pcall(getconstant, v, k + 1)										if ok3 and result3 and #tostring(result3) >= 100 then
											result3_2 = result3											if not flag then
												break
											end											print("-> KeyEvent estla")											break
										end
									end
								end
							end
						end
					end					self.wait(0.5)					local result3_2_2					if result3_2 then
						result3_2_2 = result3_2
					else
						result3_2_2 = deadline < tick()						local n8 = n5 % 4294967296						n5 = bit32.bxor(if n8 == n8 then n8 - n8 % 1 else 0, 2687198739)
					end
				until result3_2_2
			end)			local timestamp = tick()			repeat
				self.wait(0.5)
			until result3_2 or tick() - timestamp > 10
		end		if not result3_2 and flag then
			warn("-> Cle introuvable, utilisation de VirtualInputManager.")
		end		do
			local fireRemoteAction			do
				local tbl5 = {
					["1"] = "One",
					["2"] = "Two",
					["3"] = "Three",
					["4"] = "Four",
					["5"] = "Five",
					["6"] = "Six",
					["7"] = "Seven"
				}
				local tbl6 = {
					["1"] = Enum.KeyCode.One,
					["2"] = Enum.KeyCode.Two,
					["3"] = Enum.KeyCode.Three,
					["4"] = Enum.KeyCode.Four,
					["5"] = Enum.KeyCode.Five,
					["6"] = Enum.KeyCode.Six,
					["7"] = Enum.KeyCode.Seven
				}				function hasKaguneOrQuinque() -- line: 414
					-- upvalues: LocalPlayer (ref), findPath (copy)
					local Character = LocalPlayer.Character					if not Character then
						return false
					end					return findPath(Character, "Kagune") ~= nil or findPath(Character, "Quinque") ~= nil
				end				local list4 = { "Owl1", "Narukami1", "IXA1" }
				local list5 = { "Narukami1", "IXA1" }				local n5 = 0				function findActiveStageName() -- line: 426
					-- upvalues: findPath (copy), LocalPlayer (ref), list4 (copy)
					local hud = findPath(LocalPlayer.PlayerGui, "HUD", "StagesFrame", "InfoScroll")					if not hud then
						return nil
					end					for _, v in ipairs(list4) do
						if findPath(hud, v) then
							return v
						end
					end					return nil
				end				local function getPlayerFolder2() -- line: 441
					-- upvalues: getPlayerFolder (copy)
					local playerFolder = getPlayerFolder("RC")					return tonumber(playerFolder and playerFolder.Value) or 0
				end				function isRangeModeReady(arg) -- line: 447
					-- upvalues: list5 (copy), getPlayerFolder2 (copy)
					if arg and table.find(list5, arg) then
						return getPlayerFolder2() < 7500000
					end					return false
				end				local function wait2(arg) -- line: 454
					-- upvalues: VirtualInputManager (copy), self (copy), random (copy)
					VirtualInputManager:SendKeyEvent(true, arg, false, game)
					self.wait(random:NextNumber(0.04, 0.08))
					VirtualInputManager:SendKeyEvent(false, arg, false, game)
				end				function autoSpinTick() -- line: 460
					-- upvalues: str3 (ref), hasKaguneOrQuinque (ref), flag (ref), found5 (ref), LocalPlayer (ref), getRemotes2 (copy), tbl5 (copy), result3_2 (ref), tbl6 (copy), wait2 (copy), flag13 (ref), found6 (ref), self (copy), findActiveStageName (ref), isRangeModeReady (ref), n5 (ref), notify (ref)
					if not str3 then
						return
					end					if hasKaguneOrQuinque() then
						if flag then
							print("-> l'arme est dj là")
						end
					else
						found5 = false						local _ = LocalPlayer.Character
						local remotes2 = getRemotes2()
						local item = tbl5[str3]						if result3_2 and remotes2 and item then
							remotes2:FireServer(result3_2, item, "Down", LocalPlayer:GetMouse().Hit, nil, workspace.CurrentCamera.CFrame)
						else
							local entry = tbl6[str3]							if entry then
								wait2(entry)
							end
						end						if flag then
							print("-> Stage " .. str3 .. " fait")
						end
					end					if flag13 then
						found6 = true
						self.spawn(function() -- line: 494
							-- upvalues: self (copy), findActiveStageName (ref), isRangeModeReady (ref), n5 (ref), notify (ref), flag (ref), found5 (ref), LocalPlayer (ref), getRemotes2 (copy), result3_2 (ref), wait2 (copy), found6 (ref)
							self.wait(1.5)							local str4 = findActiveStageName()							if str4 and isRangeModeReady(str4) then
								if tick() - n5 > 10 then
									n5 = tick()
									notify({
										Title = "Range Mode",
										Content = "Not enough RC for Range Mode! Need 7.5M RC.",
										Duration = 4
									})
								end								if flag then
									print("-> Mode distance : tu es pauvre (" .. str4 .. "), mdr")
								end
							elseif str4 and found5 then
								if flag then
									print("-> Mode distance : deja actif")
								end
							elseif str4 then
								if flag then
									print("-> Mode distance : arme detectee (" .. str4 .. "), C")
								end								local _ = LocalPlayer.Character
								local remotes2 = getRemotes2()								if result3_2 and remotes2 then
									remotes2:FireServer(result3_2, "C", "Down", LocalPlayer:GetMouse().Hit, nil, workspace.CurrentCamera.CFrame)
								else
									wait2(Enum.KeyCode.C)
								end								found5 = true
							end							found6 = false
						end)
					end
				end
				function fireRemoteAction(arg) -- line: 539
					-- upvalues: getRemotes2 (copy), result3_2 (ref), LocalPlayer (ref), wait2 (copy)
					local remotes2 = getRemotes2()					if result3_2 and remotes2 then
						remotes2:FireServer(result3_2, arg, "Down", LocalPlayer:GetMouse().Hit, nil, workspace.CurrentCamera.CFrame)						return
					end					local item = Enum.KeyCode[arg]					if item then
						wait2(item)
					end
				end
				function pressMaskKey() -- line: 555
					-- upvalues: wait2 (copy), flag (ref), self (copy)
					wait2(Enum.KeyCode.M)					if flag then
						print("-> Masque auto :  M ")
					end					self.wait(2)
				end
			end			function cycleAuraAndMask() -- line: 565
				-- upvalues: flag9 (ref), fireRemoteAction (copy), flag (ref), self (copy), flag10 (ref), pressMaskKey (ref)
				if flag9 then
					fireRemoteAction("Zero")					if flag then
						print("-> Arata auto :  0 ")
					end					self.wait(3)
				end				if flag10 then
					pressMaskKey()
				end
			end			getConnection(LocalPlayer.CharacterAdded, function(character) -- line: 581
				-- upvalues: found5 (ref), flag9 (ref), flag10 (ref), found (ref), flag3 (ref), flag8 (ref), found4 (ref), getConnection (copy), str2 (ref), self (copy), cycleAuraAndMask (ref), autoSpinTick (ref), pressMaskKey (ref)
				found5 = false				if (flag9 or flag10) and (found or flag3 or flag8) then
					found4 = true
				end				getConnection(character:WaitForChild("Humanoid").Died, function() -- line: 588
					-- upvalues: flag9 (ref), flag10 (ref), found (ref), flag3 (ref), flag8 (ref), found4 (ref)
					if (flag9 or flag10) and (found or flag3 or flag8) then
						found4 = true
					end
				end)				if str2 == "CCG" then
					self.spawn(function() -- line: 595
						-- upvalues: self (copy)
						self.wait(1)
						pcall(function() -- line: 598
							game:GetService("ReplicatedStorage").Remotes.Settings.SpawnSelection:FireServer("Anteiku")
						end)
					end)
				end				self.wait(1.5)				local flag9_2 = flag9				if flag9 then
					flag9_2 = ((if not found then flag3 else found)) or flag8
				end				if flag9_2 then
					self.spawn(function() -- line: 612
						-- upvalues: cycleAuraAndMask (ref), found (ref), flag3 (ref), flag8 (ref), autoSpinTick (ref), found4 (ref)
						cycleAuraAndMask()						if found or (flag3 or flag8) then
							autoSpinTick()
						end						found4 = false
					end)					return
				end				if flag10 then
					found4 = true
					self.spawn(function() -- line: 624
						-- upvalues: self (copy), pressMaskKey (ref), found4 (ref), found (ref), flag3 (ref), flag8 (ref), autoSpinTick (ref)
						self.wait(0.5)
						pressMaskKey()
						found4 = false						if found or (flag3 or flag8) then
							autoSpinTick()
						end
					end)					return
				end				found4 = false				if found or flag3 or flag8 then
					autoSpinTick()
				end
			end)
			flag16 = false			local connection2			function handleEnabled(enabled) -- line: 645
				-- upvalues: flag16 (ref), connection2 (ref), getConnection (copy), RunService (copy), LocalPlayer (ref), flag (ref), self (copy)
				flag16 = enabled				if enabled then
					if connection2 then
						connection2:Disconnect()
						connection2 = nil
					end					connection2 = getConnection(RunService.Stepped, function() -- line: 654
						-- upvalues: LocalPlayer (ref)
						local Character = LocalPlayer.Character						if not Character then
							return
						end						for _, descendant in pairs(Character:GetDescendants()) do
							if descendant:IsA("BasePart") then
								descendant.CanCollide = false
							end
						end
					end)					if flag then
						print("-> noclip actif")						return
					end
				else
					if connection2 then
						connection2:Disconnect()
						connection2 = nil
					end					self.spawn(function() -- line: 676
						-- upvalues: LocalPlayer (ref), self (copy)
						for _ = 1, 10 do
							local Character = LocalPlayer.Character							if Character then
								for _, descendant in pairs(Character:GetDescendants()) do
									if descendant:IsA("BasePart") then
										descendant.CanCollide = true
									end
								end
							end							self.wait()
						end
					end)					if flag then
						print("-> noclip desactive")
					end
				end
			end			local function getPlayerFolder2() -- line: 698
				-- upvalues: findPath (copy), LocalPlayer (ref)
				local playerFolder = findPath(LocalPlayer, "PlayerFolder", "CurrentQuest", "Complete", "Aogiri Member")				if not playerFolder then
					return nil, nil
				end				return playerFolder, findPath(playerFolder, "Max")
			end			function hasPlayerFolder() -- line: 706
				-- upvalues: getPlayerFolder2 (copy)
				return getPlayerFolder2() ~= nil
			end
			function hasEnoughRC() -- line: 710
				-- upvalues: getPlayerFolder2 (copy)
				local playerFolder2, v = getPlayerFolder2()				if not playerFolder2 or not v then
					return false
				end				return (tonumber(playerFolder2.Value) or 0) >= (tonumber(v.Value) or 1)
			end
			function isCharacterAlive() -- line: 718
				-- upvalues: LocalPlayer (ref), findPath (copy)
				local Character = LocalPlayer.Character				if not Character then
					return false
				end				local humanoid = Character and Character:FindFirstChildOfClass("Humanoid")
				local humanoidRootPart = findPath(Character, "HumanoidRootPart")				return humanoid and (humanoid.Health > 0 and humanoidRootPart ~= nil)
			end
			function getHumanoidRootPart() -- line: 728
				-- upvalues: LocalPlayer (ref), findPath (copy)
				local Character = LocalPlayer.Character				return Character and findPath(Character, "HumanoidRootPart")
			end
			function canPlayerAct() -- line: 733
				-- upvalues: LocalPlayer (ref), findPath (copy)
				local PlayerFolder = LocalPlayer:FindFirstChild("PlayerFolder")				return PlayerFolder and (findPath(PlayerFolder, "CanAct") and PlayerFolder.CanAct.Value == true)
			end
			function clickOrVirtualMouse() -- line: 738
				-- upvalues: LocalPlayer (ref), getRemotes2 (copy), result3_2 (ref), VirtualInputManager (copy), self (copy), random (copy)
				local _ = LocalPlayer.Character
				local remotes2 = getRemotes2()				if result3_2 and remotes2 then
					remotes2:FireServer(result3_2, "Mouse1", "Down", LocalPlayer:GetMouse().Hit, nil, workspace.CurrentCamera.CFrame)					return
				end				VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 1)
				self.wait(random:NextNumber(0.04, 0.08))
				VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 1)
			end			list2 = { "E", "R", "F", "C" }			function pressEachKey() -- line: 754
				-- upvalues: list2 (ref), cache (copy), fireRemoteAction (copy), self (copy)
				for _, v in ipairs(list2) do
					if cache[v] then
						fireRemoteAction(v)
						self.wait(0.02)
					end
				end
			end			local function tweenToPosition(target, lookAt, speed) -- line: 767
				-- upvalues: getHumanoidRootPart (ref), tween2 (ref), TweenService (copy)
				local humanoidRootPart = getHumanoidRootPart()				if not humanoidRootPart then
					return
				end				local Magnitude = (target - humanoidRootPart.Position).Magnitude				if Magnitude <= 2 then
					return
				end				local n7 = math.max(Magnitude / speed, 0.05)
				local cframe = lookAt and CFrame.new(target, lookAt) or CFrame.new(target) * humanoidRootPart.CFrame.Rotation				if tween2 then
					tween2:Cancel()
				end				local tween = TweenService:Create(humanoidRootPart, TweenInfo.new(n7, Enum.EasingStyle.Linear), {
					CFrame = cframe
				})				tween2 = tween
				tween:Play()
				tween.Completed:Wait()				if tween == tween2 then
					tween2 = nil
				end
			end			function updateCFrame(n5) -- line: 793
				-- upvalues: getHumanoidRootPart (ref)
				local humanoidRootPart = getHumanoidRootPart()				if not humanoidRootPart then
					return
				end				if (n5 - humanoidRootPart.Position).Magnitude <= 2 then
					return
				end				humanoidRootPart.CFrame = CFrame.new(n5) * humanoidRootPart.CFrame.Rotation
			end			local function findTeamFolder() -- line: 805
				-- upvalues: team (ref), findPath (copy)
				if not team then
					return nil
				end				local list4 = team == "Ghoul" and {
					"Anteiku",
					"Yoshimura"
				} or {
					"CCGBuilding",
					"Yoshitoki"
				}				return findPath(workspace, table.unpack(list4))
			end			function getReputationTarget() -- line: 813
				-- upvalues: remotes (ref), team (ref), findTeamFolder (copy), findPath (copy), flag (ref), tweenToPosition (copy), currentValue2 (ref), getHumanoidRootPart (ref), self (copy)
				if not remotes or not team then
					return false
				end				local result = findTeamFolder()				if not result then
					return false
				end				local humanoidRootPart = findPath(result, "HumanoidRootPart")				if not humanoidRootPart then
					return false
				end				if flag then
					print("-> auto rep : trjet vers " .. result.Name)
				end				tweenToPosition(humanoidRootPart.Position, nil, currentValue2)				local humanoidRootPart2 = getHumanoidRootPart()				if not humanoidRootPart2 then
					return false
				end				local Magnitude = (humanoidRootPart2.Position - humanoidRootPart.Position).Magnitude				if Magnitude > 20 then
					if flag then
						warn("-> rep auto : teleportation ratee (distance : " .. math.floor(Magnitude) .. "), c con.")
					end					return false
				end				self.wait(0.3)				return true, result
			end			local function claimQuestReward() -- line: 853
				-- upvalues: getReputationTarget (ref), flag (ref), findPath (copy), ReplicatedStorage (copy), self (copy)
				local v, v2 = getReputationTarget()				if not v or not v2 then
					return
				end				if flag then
					print("-> rep auto : quete")
				end				local v3 = findPath(ReplicatedStorage.Remotes, v2.Name)
				local task2 = v3 and findPath(v3, "Task")				if task2 then
					task2:InvokeServer()
					self.wait(0.2)
					task2:InvokeServer()
				end				self.wait(0.5)
			end
			local function invokeReputationCashOut() -- line: 875
				-- upvalues: getReputationTarget (ref), flag (ref), remotes (ref), n2 (ref), self (copy)
				if not getReputationTarget() then
					return
				end				if flag then
					print("-> rep auto : recup rep")
				end				if remotes and remotes.ReputationCashOut then
					remotes.ReputationCashOut:InvokeServer()
				end				n2 = tick()
				self.wait(0.5)
			end			function cashOutReputationIfReady() -- line: 892
				-- upvalues: hasEnoughRC (ref), invokeReputationCashOut (copy), self (copy), claimQuestReward (copy), hasPlayerFolder (ref)
				if hasEnoughRC() then
					invokeReputationCashOut()
					self.wait(0.5)
					claimQuestReward()					return
				end				if not hasPlayerFolder() then
					claimQuestReward()
				end
			end
		end		statsFunction = nil
		connection = nil		local function isPlayerInSafeZone(position) -- line: 906
			-- upvalues: findPath (copy)
			local safeZones = findPath(workspace, "SafeZones")			if not safeZones then
				return false
			end			for _, child in pairs(safeZones:GetChildren()) do
				local part = child:IsA("BasePart") and child or child:FindFirstChildOfClass("BasePart")				if not part then
					continue
				end				local n5 = part.Size / 2
				local localPoint = part.CFrame:PointToObjectSpace(position)				if math.abs(localPoint.X) <= n5.X and math.abs(localPoint.Z) <= n5.Z then
					return true
				end
			end			return false
		end		function getLevelValue() -- line: 927
			-- upvalues: getPlayerFolder (copy)
			local playerFolder = getPlayerFolder("Level")			return tonumber(playerFolder and playerFolder.Value) or 0
		end		items = { "BL", "FL", "BR", "FR" }
		local huge = math.huge		for _, v in ipairs(list) do
			if v.name == "Gyakusatsu" then
				huge = v.minLevel
			end
		end		local cache5 = {}		local function markCached(name) -- line: 943
			-- upvalues: cache5 (copy)
			cache5[name] = true
		end		for _, v in ipairs(list3) do
			markCached(v, 504130396, 487805769)
		end		for _, v in ipairs(list) do
			markCached(v.name, 410184135, 487805769)
		end		for _, v in ipairs(items) do
			markCached(v, 127059151, 487805769)
		end		for _, v in ipairs({
			"Human",
			"Athlete",
			"Ghoul",
			"Weak Ghoul",
			"Rank 2 Investigator",
			"Rank 1 Investigator",
			"First Class Investigator"
		}) do
			markCached(v, 366058011, 487805769)
		end		local list4 = {}		local function isCachedName(instance) -- line: 973
			-- upvalues: cache5 (copy)
			return cache5[instance.Name] == true
		end		self.spawn(function() -- line: 977
			-- upvalues: getConnection (copy), isCachedName (copy), list4 (copy)
			local NPCSpawns = workspace:WaitForChild("NPCSpawns")			getConnection(NPCSpawns.DescendantAdded, function(arg) -- line: 980
				-- upvalues: isCachedName (copy), list4 (copy)
				if isCachedName(arg) then
					list4[#list4 + 1] = arg
				end
			end)
			getConnection(NPCSpawns.DescendantRemoving, function(arg) -- line: 986
				-- upvalues: isCachedName (copy), list4 (copy)
				if isCachedName(arg) then
					local index = table.find(list4, arg)					if index then
						table.remove(list4, index)
					end
				end
			end)
			table.clear(list4)			for _, descendant in ipairs(NPCSpawns:GetDescendants()) do
				if isCachedName(descendant) then
					list4[#list4 + 1] = descendant
				end
			end
		end)		local function getHumanoidInfo(...) -- line: 1005
			-- upvalues: findPath (copy)
			local item = ({ ... })[1]
			local humanoid = item and item:FindFirstChildOfClass("Humanoid")
			local humanoidRootPart = findPath(item, "HumanoidRootPart") or (findPath(item, "Torso") or findPath(item, "UpperTorso"))			if not humanoid or (humanoid.Health <= 0 or not humanoidRootPart) then
				return nil
			end			return {
				humanoid = humanoid,
				root = humanoidRootPart,
				model = item,
				name = item.Name
			}
		end		function getNearbyTargets(...) -- line: 1015
			-- upvalues: getHumanoidRootPart (ref), list4 (copy), getHumanoidInfo (copy), isPlayerInSafeZone (copy)
			local tbl5 = { ... }
			local item = tbl5[1]
			local entry = tbl5[2]
			local item2 = tbl5[3]
			local humanoidRootPart = getHumanoidRootPart()			if not humanoidRootPart then
				return {}
			end			local list5 = {}			for _, v in ipairs(list4) do
				if table.find(item, v.Name) then
					local v2 = getHumanoidInfo(v)					if v2 and (not item2 or not isPlayerInSafeZone(v2.root.Position)) then
						v2.dist = (v2.root.Position - humanoidRootPart.Position).Magnitude
						list5[#list5 + 1] = v2
					end
				end
			end			table.sort(list5, function(a, b) -- line: 1037
				return a.dist < b.dist
			end)			while entry and entry < #list5 do
				table.remove(list5)
			end			return list5
		end
		function pickRandomItem() -- line: 1048
			-- upvalues: tbl2 (ref), getNearbyTargets (copy), items (copy)
			if table.find(tbl2, "Gyakusatsu") then
				return nil
			end			return getNearbyTargets(items, 1, false)[1]
		end
		function noRareItemsOwned() -- line: 1055
			-- upvalues: list4 (copy), items (copy), getHumanoidInfo (copy)
			for _, v in ipairs(list4) do
				if table.find(items, v.Name) and getHumanoidInfo(v) then
					return false
				end
			end			return true
		end
		function pickBossTarget() -- line: 1065
			-- upvalues: getHumanoidRootPart (ref), getLevelValue (copy), list4 (copy), getHumanoidInfo (copy), huge (ref), noRareItemsOwned (copy), pickRandomItem (copy), list (copy), n3 (ref), n4 (ref), tbl2 (ref), isPlayerInSafeZone (copy), flag (ref), cache4 (copy)
			local humanoidRootPart = getHumanoidRootPart()			if not humanoidRootPart then
				return nil
			end			local n5 = getLevelValue()
			local found12 = false			for _, v in ipairs(list4) do
				if v.Name == "Gyakusatsu" and getHumanoidInfo(v) then
					found12 = true					break
				end
			end			if found12 and n5 >= huge and not noRareItemsOwned() then
				local result = pickRandomItem()				if result then
					return result
				end
			end			local huge2 = math.huge
			local result			for _, v in ipairs(list) do
				local flag17 = v.name == "Kishou Arima" and tick() - n3 < 30 or v.name == "Koutarou Amon" and tick() - n4 < 12
				local flag18 = table.find(tbl2, v.name) ~= nil				if n5 >= v.minLevel and not flag17 and not flag18 then
					for _, v2 in ipairs(list4) do
						if v2.Name == v.name then
							local v3 = getHumanoidInfo(v2)							if v3 then
								if isPlayerInSafeZone(v3.root.Position) then
									if flag then
										print("-> Boss " .. v2.Name .. " en sz, fait chié.")
									end
								else
									local cached = cache4[v2]									if cached and (not cached.humanoid or cached.humanoid.Health <= 0 or tick() >= cached.until_) then
										cache4[v2] = nil
										cached = nil
									end									if not cached then
										local Magnitude = (v3.root.Position - humanoidRootPart.Position).Magnitude										if Magnitude < huge2 then
											huge2 = Magnitude
											result = v3
										end
									end
								end
							end
						end
					end
				end
			end			return result
		end		repeat
			self.wait(0.1)
		until LocalPlayer:FindFirstChild("PlayerFolder")		function getPlayerStatValue(playerName) -- line: 1134
			-- upvalues: getPlayerFolder (copy)
			local playerFolder = getPlayerFolder(playerName)			return tonumber(playerFolder and playerFolder.Value) or 0
		end		lib = nil
		tbl3 = {
			BackgroundColor = "0b0b0b",
			MainColor = "161210",
			AccentColor = "ff7a1a",
			OutlineColor = "2e1e12",
			FontColor = "f5eee8",
			FontFace = "Gotham"
		}
		cache2 = {}
		cache3 = {}		function loadSettings() -- line: 1154
			-- upvalues: HttpService (copy)
			local ok, result = pcall(function() -- line: 1155
				-- upvalues: HttpService (copy)
				return HttpService:JSONDecode(readfile("CTH/settings.json"))
			end)			return ok and (type(result) == "table" and result) or {}
		end
		function formatWithCommas(amount) -- line: 1162
			return (tostring(math.floor(amount)):reverse():gsub("(%d%d%d)", "%1,"):reverse():gsub("^,", ""))
		end
		function formatCompactNumber(amount) -- line: 1167
			for _, v in ipairs({
				{ 1000000000000, "t" },
				{ 1000000000, "b" },
				{ 1000000, "m" },
				{ 1000, "k" }
			}) do
				if amount >= v[1] then
					return string.format("%.2f", amount / v[1]):gsub("%.?0+$", "") .. v[2]
				end
			end			return tostring(amount)
		end
		function handleName(name, arg) -- line: 1177
			-- upvalues: loadSettings (copy), HttpService (copy)
			pcall(function() -- line: 1178
				-- upvalues: loadSettings (copy), name (copy), arg (copy), HttpService (copy)
				if not isfolder("CTH") then
					makefolder("CTH")
				end				local cache6 = loadSettings()				cache6[name] = arg
				writefile("CTH/settings.json", HttpService:JSONEncode(cache6))
			end)
		end
		function notify(arg) -- line: 1189
			-- upvalues: lib (ref)
			local lib4 = lib			lib.Notify(lib4, {
				Title = arg.Title,
				Description = arg.Content,
				Time = arg.Duration or 3
			})
		end		local function base64Decode(str4) -- line: 1194
			local base64decode = crypt and (crypt.base64decode or crypt.base64 and crypt.base64.decode) or base64_decode			if base64decode then
				local ok, result = pcall(base64decode, str4)				if ok and type(result) == "string" and #result > 0 then
					return result
				end
			end			local cache6 = {}			for i = 1, 64 do
				cache6[string.byte("ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/", i)] = i - 1
			end			local list5 = {}
			local n5 = 0
			local total = 0			for i = 1, #str4 do
				local cached = cache6[str4:byte(i)]				if cached then
					n5 = n5 * 64 + cached
					total += 6					if total >= 8 then
						total -= 8						local n6 = 2 ^ total						list5[#list5 + 1] = string.char(math.floor(n5 / n6) % 256)
						n5 %= n6
					end
				end
			end			return table.concat(list5)
		end		icon = (function() -- line: 1248
			-- upvalues: base64Decode (copy)
			local ok, result = pcall(function() -- line: 1249
				-- upvalues: base64Decode (copy)
				if not isfolder("CTH") then
					makefolder("CTH")
				end				if not isfile("CTH/cth_logo_128.png") then
					writefile("CTH/cth_logo_128.png", base64Decode("iVBORw0KGgoAAAANSUhEUgAAAIAAAACACAMAAAD04JH5AAABgFBMVEXUXSFdIx1bMiVgLx35oSGjTinXcSEiESa4WijNZChgMCMoGh2UOhTwX1FaWgAkHSOSTjejWSkxIB6mWE6fMAejMyEAAFXaOAC+cEWrOhgAVQDUVSpVAFUAAAAyJSQYFBgmGxtHKyVRMyskHSExIR0QDRFpOCgdHCBOJxsYFBUYExUXFBQPCw0ZFBUYExWPORRwNB0UExGORCUXExQlGRkRDA7yZhQkGRoSDA9/AADrWRFpKRPTSA1TAAElGhquRxkyJSZ4Qi8QDBHQVRP/AAAxJCUnGhsmGxmmSiJVVVWEPSP4dRjMWCL3eCcqGhmyUySTQhv4iBAzJSQRDBAxIR7//wA0JSYvAwNMGw1/fwAPDA49MC09PT0lHiErHiEqKSknGBivOQrvaSDvgypFKydvJg/plC9/f3+NNAUsHiEzKCfERBL/f3//VQDjTA5wODT/fwCMLQuVNRCqVQi3QRLIYxavOwfKZy2nOw2IQiLMaSy5Uhu1Xjf/qlWsVCzKaTEf/581AAAAgHRSTlOlHJ9K+JzrGV5n1NWvCgNgHe2kCOweA/92aAMGAwD+/f7+/v7+/v7+/lCwbSzRjv3+F/0w0U39rG4C/f37BG/90/7L+wGvk1H/A/7+/v0x//7/krCMAXcK/gKP/wSKrwoZ+/j/air/AolQU8sCA/4NAv8qCc//zUmQrXH/KwOyxswYxXEAAA4DSURBVHja7VtnWxvHFhbgbqcnt8/sbNGuVloVUANJVNG7cY3tuKfYTrnp7Sb56/eUmdUKiCC2Fr54HxstAvS+c/o5M5sRp3xlXhN4TeDEkJqT5i4MT4NAyTUECuo0CERK1TUTWTsNFeTVZbN+VTgFAgC7TDd1pWqnYISgANYA3pQ0p/AECeTNuptAoKqN8gQJhAB7TUwDKtw0tU5qJ6iCIuBG4paYhFf2wYJlNJEegbCUsECVF/cA37LghvHVeNoESlbCAnHdsH6LLaBgxQJIkUDNqsYWiAqvWxbhPhAh3oynTWBcWWFsgSCAiPCLvH7LBKOp9AiEymIQxC+OiyISQE6EXxtPPRCVtARQAbDevEL8EuNbcToqFTLpmQDZQIiWlxeTtP68wdcWOFmTK2kRqMOKTQiwxskAraLBL5ICorzymqmp4I4igyuh54XC4Jf4ZtzEArWdGoEixh7MfShvNkBxPs/4ES3f4ryUSU8D4AQEGF3jF83DinQoUrKZnhdMkgmQxBcWCLY+XrSyuP4qLR8IeLUU3TCPGqDYk80S/jW2Q3QEbQk6FqREoIZhiETO+NkFpgJKZ4+0dFpOiQDkH4tdLovA2WyW8SfFJCvE8pbF4oP0CEAczhsFMD59qUca3lL30w3F4P71PBPoXdbCnazBxwo1KlTTIhAVreKdA/gGnaqSsFTk+jwNAoWiMf4kvhVTUNYCu0FKKuB4l92PHy9fmZswFQLjjM/mb+0DJ3wjh1I6RpiPfd9isWf74Q2+m1IcKPTwWQv9y/eUtgKIQ4tpEAjZ92M99y9e6veVctVkOnGgSItWhxAAeFp+EBATKQtQkQ6dQEHxUpFBsE/4HuAr13WV8hBfXhdrwydQJHyA8tS+5cN7iO4qadse4stqCiqINJbnsbhJGIaABMV7BK+k68qP0rABbAIRHxdI2Epf+Aa8axM8SkLKVDqjZSYgmYB06VvC9wjeY+uwlHT2xIcpEGhq+ePl6uWD6FEhfRdQqaeSjvNIIOeRvF0MNxaqnaVgkSJckD8oQvV6s8xwa3HAzyG+y8bnuvHq8Tv4ie34pAkZpkFAOwAavPE/bY5oeoRO8OCMzTQkEBIB8Hhp/N/1YgLkA7ZN5qHkXCrdcRHEjfiJIIQS8FTCNpEQyGI7jTlhySWcJD5IwJb7L5BDLUqBQBi4tFIVBKYfCSj8cBwiYAcu8EHPNoF4iASqFhNQbpyFAgON8kd4MMFcjlXxDMeGQyVQpDyLYTYm0JM6xiO2Qo7JCSPIDK8S0/4eEyC3l54yckheQzfCGD9hgrxmdkOPDYA90ZZ1o4BhEchj0OVwYwgEKADHliYzypwdX70wNBwC0PkDnsv4mgBkXHRBYMApIE7R4AI2lkNTQyRQtBIEEFuv30aZ99yQzA/jEfxrDpFASGOAIHD1RTQMvmNqA/YAj0lKGQ5NBfV8HPWIA8jY1StGo0sGQI5CmCzlnnhlAlGhlM8vLBRjm8f4x6FAsasjnsNOTzw8cgUSxE3xigSgtz5Q9wfAIIDgr6SnC0DHJwkoWr3UWQnpzYhXIhAV+tETzVcgXen1ZO6zD7isD47JyGBm7fxLEoBuLmy6bhK9r/fU9m5LDrwkAXgLfdCztUG4Ly8BCF4rS1Ru9l89EkTANhnY4dAPHuBRXazLESmjlyMAjrsk8TMg2Pf1fr0RgNIMjBfYxv5tKkwlMyi83MbllHg2Rx9Jzh70G0AsA1cl6g6tAeTi57A5RUnEe9h/WQI3IZ1DSem5WFofVIPRgpsofMgdbGbgQCnGJthLRMcmENXr9WXbmXhUbufsfhEcZKB6DHRDJMkGfUzNcLssPv0rBKKwlF+gVJvzy0+efM34QbCfQM8bXSMD22OfJMV5FAltMoF/HZvAZL7Ii8rlcnalMrvxfdkQ6Pm+tY9MQLU4GIDteCYGkxR0GKwe0waiUI/bsup2u9yuVMrl3fIuqBJCPsY8zH940/PLeBZpluuwHvgbW39TEMcgMF7gpZOLq9vlztfl8mz33PdlHz+TgBWnPtCFJMdMKgIDD+LbOgQCvu/oIBCK4xCol0pFPeGG9Zcbf3/U6TTOnOmWnURmxw4QsQM3wYBtUbEKbM8kZccGB0IFFHguc7QKogUz3b1d/qTRanVaV6+2OjEBO45qUnL16fJMiGMSVWO+jsi4esfOUTbudWSDCUxeiyOcuv3OmasbiN/oPKo4CSfXeiVNoDRQCmYuqetBbMUxJ/ich52lqjgOgXoy26n2J2fOda6eudp41G4zoE74xq0oLrkyJkAtUS8YOJyV8LosjnGQKSrk+6arQOCT97fObHS/zuWw7WDrp8wq2bip8XbBEtykFSisPzglkQywOJmBMwSDCUSTC/syrFLtc93G1S6EwBzCB1x3cazxbM2AC17XTSRH+hWHA4K2mT0xWAJhybIOTLchBpVnvwf42x4CkKi1cOE1xzWHklT7anwjQFdXIdod3xWDzpI9oKiTr7LxJ/sbYNDG1fOYMdZsbInYbsLUiawz0H1xNu4MyUps4rEkRgYQKBSLeUiT0bWsGbUmZHC7H910N3iby6GFQ44hj9BJks2QIpR05hG8OTNzPTz6NB3B02BNJtMt97y6tKM0T2GWOOSIQc5TIAmq/1AG2hMDLQNgUBfHOM4XlQgrZ7MwTaVtUbGbyLAQVn2HoxtYIdj3vI805n1KeeyM14qYFKk7kjPXIf5P31obSGBKb6Z7ELB0cFEIjXEu4ITD8ZeWD/i+DkPIYN6vAIN5YqCDcklU60VW2hJ8/Mr4YAkAfFijtrHGPST8JcwVMcyz4N0eAQrtPkdXm0SQ89d9/1LOn1j3yQxIdnewY3ZpHHZvTRx5onK7ibVzbebhpEWTbMJnr3NlgkBsgxSBHG2H7fX1SgUITBAByQER98irH12enFnmcnoQgYd7sJTaDPzFHd7WkAbfci0jAFhLbISY7W3DAByhMlGuVNqrq8Qgtt98QRzzTOnM3LvXVygBUgTVM23PJQeI50zJYpMnTuzeQKC9vlsu+xM7E+gJcbUItpMvRH/hUGudC0ocJNOmDm9ucTxxTXkdRyFmwARy7YnZ2YnKxCpbQdArDuEQQaF6DAKfPpiiXX30AjNXNXucfQMmEwClbnQcTPsQJyurm6vl9Z1VNsMYnSNaPjyOBDAPQPK+XlRcWOuNFh72HkIA9MAOC1EBrWDn19Xy5ua6HVeIgWt6UThOU4qOIBBh4JBzN8f1pk+MH+yDxuROHQd5IRiDgkhUqVT88uzO6uYmO0KvOMeaiOVQGEgAdxvd+ys87enhw4tn0Lm7RsN3uBZyHCiyoE/yHGawu7q6A2aInhFYejrPMxKPNtFqA3IB4jerWhEJfAnLMMW0JuA7VO76DiZiSAM5GwMAxIHy7m55VROgWRl7D4VNm1VR+nMCfL71FjuC0b9H1aajh306r/rz8D/Hep+vIAPHX53Fq9vtzk7MY+rB/jTeKrM5dZAgZ47Mhiz3GveYNm76kKERAZ8UD9kVJ87QpbYr67vtig/tyuxmY6MBV3e2wlO5eBoj5V2HcifRX6oeRYAMoMmHjBSX2zYr3jWxz4GU409gBvRB9OD7OzuA34Ky/cqVS21Tqd+lgZwXj8ogxeXs5pH1QAkM93JIx6+gxJHoAiwAh7XPBOYdIOCg4kd/fqdc/nWz1f2y03rxMbRT55eSkwkzrjGjmXir9M8IhCB9ZDlJ+HYTAjOPejUB7nD8+Uv+xPzK2OjEFbCa0XL3cafV6bQy4gt9etXj+Ry6Y2KjglLpXHUggYcrKxFaYh5imO3cx8ykNSDn4OullZujM6O2PyrGRkfh10c+uCGmr2y2Oi8aj374MoP7oFOiphtjKoMkp7JeWXqgMT68L3Ax8i/jJiQMNGfgj+eeiZtzerT47Cm/vvkbfLlwbvO7nz7IbH33Waf1DeXc+72qzTZNG+6XO9oPmgMJTFPaDo3DWPgyPiefmp+vrb3Jv/cefv3mlzNPGt+B6jNbP411H18EHUzBEEs6ZijhSY8bCBobaQpHtmZ/g8cP5FyIy8kvV+FlvEoVk5ltT6/pceHFxxsbjR8+Fv9e/GV2ZOSzLn7Mmtgji2EGunN19ayUGDhL/eOZw1RQ2J+8PjxkXjmd2QLHb30mxLfifz8LcX43Iz4HAjdR+Ni0ebqBh7CMjavSlJy9oTzk8oW48HgLbL/R+P0rcUOMfSzGfn8Dbu6Jp9iHEnSvgrDifSu5HA3nKZsb5zOtrY3Z8ovWxh/TN6bEV2LkK3z/nhijVhytUEseXwLtC8n92lciAFJvfNndAAX8s7H1D/EbHQe6QbXnGNWrnk5dUnEjGZjvqUZ/dQJviIsbndlG9xvx5oWzZ/VxJL62sVl0cC5tKy0CrmoNg+owCPxX/LjVef8JNRQj/QRu8e6o1OUiigDjabxhAOH4P69OYFG8fa714sK5s2Mjb4yMkPBjh1mmWUS8WePRSQ52SRLCcWdER4kgs5ER314Ye3jgRw9JB2QJrp6NY3OD2HcR/6MhEfhx6+ytwyfqT7lpohpEWwIdXsLS4G5zeA+7Xfzj7MjnHx7GYNReWtGFWG/XEksT0MHc0AgsivfeHvmzs0QrYpQ3zKStCegW05HR0CTw+cCtjW1ThWnnM9MV5/khY7KX3DdcXBz00+e8aeppBgxfq8nnYu1EHnj8VIAZXH/OCSgeMLwlqif2xOWU2N57IM7PaWynFt533bdO+pHPNbENBUpIlSq4f3TCz5yyj+KA5C2gsHLKD71WT+2pW6zkphdfP3f8msDA6/9j1glLUXqLYAAAAABJRU5ErkJggg=="))
				end				return getcustomasset("CTH/cth_logo_128.png")
			end)			return ok and result or nil
		end)()
	end	lib = loadstring(game:HttpGet("https://raw.githubusercontent.com/deividcomsono/Obsidian/fb0b7b22604664ab94bea7c67e2a14ab1a47ec27/Library.lua"))()
	lib2 = loadstring(game:HttpGet("https://raw.githubusercontent.com/deividcomsono/Obsidian/fb0b7b22604664ab94bea7c67e2a14ab1a47ec27/addons/ThemeManager.lua"))()
	lib3 = loadstring(game:HttpGet("https://raw.githubusercontent.com/deividcomsono/Obsidian/fb0b7b22604664ab94bea7c67e2a14ab1a47ec27/addons/SaveManager.lua"))()
	tbl.onCleanup(function() -- line: 1269
		-- upvalues: lib (ref)
		if not lib.Unloaded then
			lib:Unload()
		end
	end)	for k, v in pairs(tbl3) do
		if k ~= "FontFace" then
			lib.Scheme[k] = Color3.fromHex(v)
		end
	end	lib:SetFont(Enum.Font[tbl3.FontFace])
	cthLoading = lib:CreateLoading({
		Title = "CTH",
		TotalSteps = 4,
		WindowWidth = 420,
		WindowHeight = 250,
		Icon = icon
	})
	cthLoading:SetMessage("Loading CTH...")
	cthLoading:SetDescription("Building the interface...")
	cthLoading:SetCurrentStep(1)
	tbl4 = {
		emberSequence = function() -- line: 1287
			-- upvalues: lib (ref)
			local n5, v, n6 = lib.Scheme.AccentColor:ToHSV()			return ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.fromHSV((n5 + 0.04) % 1, v, n6)),
				ColorSequenceKeypoint.new(0.5, lib.Scheme.AccentColor),
				ColorSequenceKeypoint.new(1, Color3.fromHSV((n5 - 0.04) % 1, v, n6 * 0.95))
			})
		end
	}	function tbl4.ember(parent, rotation, transparency) -- line: 1297
		-- upvalues: tbl4 (copy), lib (ref)
		local UIGradient = Instance.new("UIGradient")		UIGradient.Rotation = rotation
		UIGradient.Transparency = transparency or NumberSequence.new(0)
		UIGradient.Color = tbl4.emberSequence()
		UIGradient.Parent = parent
		lib:AddToRegistry(UIGradient, {
			Color = tbl4.emberSequence
		})		return UIGradient
	end
	function tbl4.styleWindow() -- line: 1307
		-- upvalues: lib (ref), tbl4 (copy)
		local Main = lib.ScreenGui.Main
		local Frame = Instance.new("Frame")		Frame.BackgroundTransparency = 1
		Frame.Size = UDim2.new(1, 0, 1, 0)
		Frame.ZIndex = 50
		Main:FindFirstChildOfClass("UICorner"):Clone().Parent = Frame		local UIStroke = Instance.new("UIStroke")		UIStroke.Color = Color3.new(1, 1, 1)
		UIStroke.Thickness = 1.5
		UIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		UIStroke.Parent = Frame
		tbl4.ember(UIStroke, 35, NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0),
			NumberSequenceKeypoint.new(0.4, 0.8),
			NumberSequenceKeypoint.new(0.7, 1),
			NumberSequenceKeypoint.new(1, 0.4)
		}))
		Frame.Parent = Main		local Frame2 = Instance.new("Frame")		Frame2.BorderSizePixel = 0
		Frame2.BackgroundColor3 = Color3.new(1, 1, 1)
		Frame2.Position = UDim2.new(0, 0, 0, 47)
		Frame2.Size = UDim2.new(1, 0, 0, 2)
		Frame2.ZIndex = 20
		tbl4.ember(Frame2, 0, NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0),
			NumberSequenceKeypoint.new(0.5, 0.6),
			NumberSequenceKeypoint.new(1, 1)
		}))
		Frame2.Parent = Main		for _, descendant in ipairs(Main:GetDescendants()) do
			if descendant:IsA("TextLabel") and descendant.Text == "CTH" then
				descendant.TextSize = 20
				lib:AddToRegistry(descendant, {
					TextColor3 = "WhiteColor",
					FontFace = function() -- line: 1349
						-- upvalues: lib (ref)
						return Font.new(lib.Scheme.Font.Family, Enum.FontWeight.Heavy)
					end
				})
				tbl4.ember(descendant, 0)
			end
		end		lib:UpdateColorsUsingRegistry()
	end
	function tbl4.clock(n5) -- line: 1361
		return string.format("%02d:%02d:%02d", n5 // 3600, n5 % 3600 // 60, n5 % 60)
	end	local function normalizeSelection(value2) -- line: 1365
		if type(value2) ~= "table" then
			return value2 == nil and {} or { value2 }
		end		local list4 = {}		for k, v in pairs(value2) do
			if v then
				list4[#list4 + 1] = k
			end
		end		table.sort(list4)		return list4
	end
	local function getCache(arg) -- line: 1381
		local cache5 = {}
		local tbl5 = type(arg) == "table" and arg or { arg }		for _, v in ipairs(tbl5) do
			cache5[v] = true
		end		return cache5
	end	function createMenuBuilder(window, tabName) -- line: 1392
		-- upvalues: normalizeSelection (copy), getCache (copy)
		local tbl5 = {
			nextSide = "Left",
			CreateSection = function(arg2, name, arg3, iconName) -- line: 1395
				-- upvalues: window (copy)
				local nextSide = arg3 or arg2.nextSide				arg2.nextSide = nextSide ~= "Left" and "Left" or "Right"
				arg2.box = window:AddGroupbox({
					Side = nextSide,
					Name = name,
					IconName = iconName
				})				return arg2.box
			end
		}		local function getBox(arg2) -- line: 1403
			-- upvalues: tabName (copy)
			return arg2.box or arg2:CreateSection(tabName)
		end
		local function flagName(option) -- line: 1407
			-- upvalues: tabName (copy)
			return option.Flag or tabName .. "_" .. option.Name
		end		function tbl5.CreateToggle(arg2, arg3) -- line: 1411
			-- upvalues: getBox (copy), flagName (copy)
			local toggle = getBox(arg2):AddToggle(flagName(arg3), {
				Text = arg3.Name,
				Default = arg3.CurrentValue or false,
				Tooltip = arg3.Tooltip,
				Risky = arg3.Risky,
				Callback = arg3.Callback
			})			return {
				Raw = toggle,
				Set = function(_, arg4) -- line: 1424
					-- upvalues: toggle (copy)
					toggle:SetValue(arg4)
				end
			}
		end
		function tbl5.CreateDropdown(arg2, arg3) -- line: 1430
			-- upvalues: getBox (copy), flagName (copy), normalizeSelection (copy), getCache (copy)
			local multi = arg3.MultipleOptions == true
			local CurrentOption = arg3.CurrentOption
			local dropdown = getBox(arg2):AddDropdown(flagName(arg3), {
				Text = arg3.Name,
				Values = arg3.Options,
				Default = not multi and (type(CurrentOption) == "table" and CurrentOption[1] or CurrentOption) or nil,
				Multi = multi,
				Searchable = #arg3.Options > 10,
				Callback = function(arg4) -- line: 1441
					-- upvalues: arg3 (copy), normalizeSelection (copy)
					if arg3.Callback then
						arg3.Callback(normalizeSelection(arg4))
					end
				end
			})			if multi and CurrentOption and #CurrentOption > 0 then
				dropdown:SetValue(getCache(CurrentOption))
			end			return {
				Raw = dropdown,
				Set = function(_, arg4) -- line: 1454
					-- upvalues: multi (copy), dropdown (copy), getCache (copy)
					if multi then
						dropdown:SetValue(getCache(arg4))						return
					end					dropdown:SetValue(type(arg4) == "table" and arg4[1] or arg4)
				end,
				Refresh = function(_, arg4) -- line: 1461
					-- upvalues: dropdown (copy)
					dropdown:SetValues(arg4)
				end
			}
		end
		function tbl5.CreateSlider(arg2, arg3) -- line: 1467
			-- upvalues: getBox (copy), flagName (copy)
			local slider = getBox(arg2):AddSlider(flagName(arg3), {
				Rounding = 0,
				Text = arg3.Name,
				Default = arg3.CurrentValue,
				Min = arg3.Range[1],
				Max = arg3.Range[2],
				Suffix = arg3.Suffix,
				Callback = arg3.Callback
			})			return {
				Raw = slider,
				Set = function(_, arg4) -- line: 1480
					-- upvalues: slider (copy)
					slider:SetValue(arg4)
				end
			}
		end
		function tbl5.CreateInput(arg2, arg3) -- line: 1486
			-- upvalues: getBox (copy), flagName (copy)
			local input = getBox(arg2):AddInput(flagName(arg3), {
				Finished = true,
				ClearTextOnFocus = false,
				Text = arg3.Name,
				Placeholder = arg3.PlaceholderText,
				Default = arg3.CurrentValue or "",
				Callback = arg3.Callback
			})			return {
				Raw = input,
				Set = function(_, arg4) -- line: 1500
					-- upvalues: input (copy)
					input:SetValue(arg4)
				end
			}
		end
		function tbl5.CreateButton(arg2, arg3) -- line: 1506
			-- upvalues: getBox (copy)
			return getBox(arg2):AddButton({
				Text = arg3.Name,
				Func = arg3.Callback,
				Risky = arg3.Risky
			})
		end
		function tbl5.CreateParagraph(arg2, arg3) -- line: 1510
			-- upvalues: getBox (copy)
			local label = getBox(arg2):AddLabel({
				Text = "",
				DoesWrap = true
			})
			local tbl6 = {
				Set = function(_, arg4) -- line: 1513
					-- upvalues: label (copy)
					local str5 = arg4.Title and (arg4.Title ~= "" and string.format("<font color=\"#ff7a1a\"><b>%s</b></font>\n", arg4.Title)) or ""					label:SetText(str5 .. (arg4.Content or ""))
				end
			}			tbl6:Set(arg3)			return tbl6
		end		return tbl5
	end
	function getTopTargets(count) -- line: 1525
		-- upvalues: getNearbyTargets (copy), list3 (copy)
		return getNearbyTargets(list3, count or 4, true)
	end	local function waitWhileFarming(...) -- line: 1529
		-- upvalues: isCharacterAlive (ref), found7 (ref), found (ref), flag3 (ref), flag8 (ref), canPlayerAct (ref), result3_2 (ref), pressEachKey (ref), clickOrVirtualMouse (ref), wait (copy), x (ref), self (copy)
		local tbl5 = { ... }
		local item = tbl5[1]
		local entry = tbl5[2]
		local item2 = tbl5[3]
		local item3 = tbl5[4]
		local timestamp = tick()		while item and item.Parent and item.Health > 0 and isCharacterAlive() and not found7 and (found or flag3 or flag8) and (not entry or item2 or flag8) and (not item3 or not (item3 < tick() - timestamp)) do
			if canPlayerAct() or not result3_2 then
				pressEachKey()
				clickOrVirtualMouse()
				wait(x, 0.025)
			end			self.wait()
		end
	end
	local function disconnect(instance) -- line: 1557
		-- upvalues: connection (ref), getConnection (copy), RunService (copy), getHumanoidRootPart (ref)
		if connection then
			connection:Disconnect()
			connection = nil
		end		connection = getConnection(RunService.RenderStepped, function() -- line: 1563
			-- upvalues: getHumanoidRootPart (ref), instance (copy)
			local humanoidRootPart = getHumanoidRootPart()			if humanoidRootPart and instance and instance.Parent then
				local Unit = (humanoidRootPart.Position - instance.Position).Unit				humanoidRootPart.CFrame = CFrame.new(instance.Position + Unit * 3, instance.Position)
			end
		end)
	end	function stopAutoFarm(found102, arg2) -- line: 1588
		-- upvalues: found9 (ref), isCachedTrue (copy), noRareItemsOwned (copy), isCharacterAlive (ref), found (ref), flag3 (ref), pickRandomItem (copy), getHumanoidRootPart (ref), disconnect (copy), waitWhileFarming (copy), connection (ref), flag (ref), self (copy), items (copy), LocalPlayer (ref), findPath (copy), getConnection (copy), found11 (ref), random (copy), RunService (copy), bossPosition (ref), str (ref), currentValue (ref), n (ref), y (ref), n3 (ref), n4 (ref), found7 (ref), flag8 (ref), cache4 (copy), hasKaguneOrQuinque (ref), autoSpinTick (ref), canPlayerAct (ref), result3_2 (ref), pressEachKey (ref), clickOrVirtualMouse (ref), wait (copy), x (ref)
		found9 = true		local v = isCachedTrue(found102.name)		if found102.name == "Gyakusatsu" then
			while not noRareItemsOwned() and isCharacterAlive() and (found or flag3) do
				local v2 = pickRandomItem()				if not v2 then
					break
				end				local humanoidRootPart = getHumanoidRootPart()				if humanoidRootPart then
					local Unit = (v2.root.Position - humanoidRootPart.Position).Unit					humanoidRootPart.CFrame = CFrame.new(v2.root.Position - Unit * 3, v2.root.Position)
				end				disconnect(v2.root)
				waitWhileFarming(v2.humanoid, v, arg2)				if connection then
					connection:Disconnect()
					connection = nil
				end				if flag then
					print("-> Cœur " .. v2.name .. " ez")
				end				self.wait(0.3)
			end			disconnect(found102.root)
			waitWhileFarming(found102.humanoid, v, arg2, 300)			if connection then
				connection:Disconnect()
				connection = nil
			end			found9 = false			return
		end		local connection2		if table.find(items, found102.name) then
			disconnect(found102.root)
			waitWhileFarming(found102.humanoid, v, arg2)			if connection then
				connection:Disconnect()
				connection = nil
			end			found9 = false			return
		end		if found102.name == "Kishou Arima" or found102.name == "Koutarou Amon" then
			local yen = LocalPlayer.PlayerFolder and (findPath(LocalPlayer.PlayerFolder, "Stats") and findPath(LocalPlayer.PlayerFolder.Stats, "Yen"))			if yen then
				local n5 = tonumber(yen.Value) or 0				connection2 = getConnection(yen.Changed, function(arg3) -- line: 1653
					-- upvalues: n5 (copy), flag (ref), found102 (copy), found11 (ref), connection2 (ref), connection (ref)
					if (tonumber(arg3) or 0) >= n5 + 2000000 then
						if flag then
							print("-> " .. found102.name .. " récup (2M Yen), stop pauvre fou")
						end						found11 = true						if connection2 then
							connection2:Disconnect()
							connection2 = nil
						end						if connection then
							connection:Disconnect()
							connection = nil
						end
					end
				end)
			end
		end		local total = random:NextNumber(0, 6.283185307179586)
		local timestamp = tick()
		local timestamp2 = tick()
		local timestamp3		if connection then
			connection:Disconnect()
			connection = nil
		end		connection = getConnection(RunService.RenderStepped, function() -- line: 1685
			-- upvalues: getHumanoidRootPart (ref), found102 (copy), v (copy), bossPosition (ref), str (ref), currentValue (ref), n (ref), timestamp3 (ref), timestamp (ref), total (ref), y (ref)
			local humanoidRootPart = getHumanoidRootPart()			if humanoidRootPart and found102.root and found102.root.Parent then
				local rootPosition = found102.root.Position
				local bossPosition2 = v and bossPosition or str
				local flag17 = found102.name == "Kishou Arima"
				local currentValue3 = v and currentValue or n				if bossPosition2 == "Below" and not flag17 then
					local vector3 = Vector3.new(rootPosition.X, rootPosition.Y - currentValue3, rootPosition.Z)					humanoidRootPart.CFrame = CFrame.new(vector3) * CFrame.Angles(1.5707963267948966, 0, 0)					return
				end				if bossPosition2 == "Above" then
					local vector3 = Vector3.new(rootPosition.X, rootPosition.Y + currentValue3, rootPosition.Z)					humanoidRootPart.CFrame = CFrame.new(vector3) * CFrame.Angles(-1.5707963267948966, 0, 0)					return
				end				if bossPosition2 == "Behind" then
					local LookVector = found102.root.CFrame.LookVector
					local vector3 = Vector3.new(LookVector.X, 0, LookVector.Z)
					local unit					if vector3.Magnitude < 0.05 then
						local vector3_2 = Vector3.new(rootPosition.X - humanoidRootPart.Position.X, 0, rootPosition.Z - humanoidRootPart.Position.Z)						unit = vector3_2.Magnitude > 0.05 and vector3_2.Unit or Vector3.new(0, 0, 1)
					else
						unit = vector3.Unit
					end					if not timestamp3 then
						timestamp3 = tick()
					end					local elapsed = tick() - timestamp3
					local n5 = not (elapsed < 0.3) and 0 or math.sin(elapsed * 40) * 1
					local vector3_3 = Vector3.new(-unit.Z, 0, unit.X)
					local n6 = rootPosition - unit * currentValue3 + vector3_3 * n5
					local vector3_4 = Vector3.new(n6.X, rootPosition.Y, n6.Z)
					local vector3_5 = Vector3.new(rootPosition.X, rootPosition.Y, rootPosition.Z)					humanoidRootPart.CFrame = CFrame.new(vector3_4, vector3_5)					local CurrentCamera = workspace.CurrentCamera					if CurrentCamera then
						CurrentCamera.CFrame = CFrame.new(CurrentCamera.CFrame.Position, vector3_5)						return
					end
				else
					local timestamp4 = tick()
					local n5 = timestamp4 - timestamp					timestamp = timestamp4
					total += y * n5					local n6 = rootPosition.X + math.cos(total) * currentValue3
					local n7 = rootPosition.Z + math.sin(total) * currentValue3
					local vector3 = Vector3.new(n6, rootPosition.Y, n7)
					local vector3_6 = Vector3.new(rootPosition.X, rootPosition.Y, rootPosition.Z)					humanoidRootPart.CFrame = CFrame.new(vector3, vector3_6)					local CurrentCamera = workspace.CurrentCamera					if CurrentCamera then
						CurrentCamera.CFrame = CFrame.new(CurrentCamera.CFrame.Position, vector3_6)
					end
				end
			end
		end)		while found102.humanoid and found102.humanoid.Parent ~= nil and found102.humanoid.Health > 0 do
			if (found102.name == "Kishou Arima" or found102.name == "Koutarou Amon") and (found102.humanoid.Health <= 0 or found11) then
				found11 = false				if found102.name == "Kishou Arima" then
					n3 = tick()
				end				if found102.name == "Koutarou Amon" then
					n4 = tick()
				end				break
			end			if not isCharacterAlive() or found7 or not found and not flag3 and not flag8 or v and not arg2 and not flag8 then
				break
			end			if tick() - timestamp2 > 300 then
				if flag then
					print("-> Temps limite atteint un bug?")
				end				if found102.model then
					cache4[found102.model] = {
						until_ = tick() + 300,
						humanoid = found102.humanoid
					}
				end				break
			end			if not hasKaguneOrQuinque() then
				autoSpinTick()
				self.wait(0.5)
			end			if canPlayerAct() or not result3_2 then
				pressEachKey()
				clickOrVirtualMouse()
				wait(x, 0.025)
			end			self.wait()
		end		if connection then
			connection:Disconnect()
			connection = nil
		end		if connection2 then
			connection2:Disconnect()
			connection2 = nil
		end		local bossPosition2 = v and bossPosition or str
		local flag17 = found102.name == "Kishou Arima"		if bossPosition2 == "Below" and not flag17 then
			local currentValue3 = v and currentValue or n
			local humanoidRootPart = getHumanoidRootPart()			if humanoidRootPart and found102.root then
				local vector3 = Vector3.new(found102.root.Position.X, found102.root.Position.Y + currentValue3, found102.root.Position.Z)				humanoidRootPart.CFrame = CFrame.new(vector3)
			end
		end		found9 = false
	end	local function isCollectAnimPlaying() -- line: 1853
		-- upvalues: LocalPlayer (ref), findPath (copy)
		local Character = LocalPlayer.Character
		local humanoid = Character and Character:FindFirstChildOfClass("Humanoid")
		local animator = humanoid and humanoid:FindFirstChildOfClass("Animator")		if not animator then
			return false
		end		local PlayerFolder = LocalPlayer:FindFirstChild("PlayerFolder")
		local collectAnim = PlayerFolder and findPath(PlayerFolder, "CollectAnim")
		local cell = collectAnim and collectAnim.Value		if not cell then
			return false
		end		for _, v in ipairs(animator:GetPlayingAnimationTracks()) do
			if v.Animation and cell == v.Animation.AnimationId then
				return true
			end
		end		return false
	end
	local function waitForAutoFarmIdle() -- line: 1876
		-- upvalues: self (copy), isCollectAnimPlaying (copy)
		local timestamp = tick()		repeat
			self.wait()
		until isCollectAnimPlaying() or tick() - timestamp > 0.8		local timestamp5 = tick()		while isCollectAnimPlaying() and tick() - timestamp5 < 3 do
			self.wait()
		end
	end
	local function sendKeyEvent() -- line: 1890
		-- upvalues: list2 (ref), LocalPlayer (ref), getRemotes2 (copy), result3_2 (ref), VirtualInputManager (copy)
		for _, v in ipairs(list2) do
			pcall(function() -- line: 1892
				-- upvalues: LocalPlayer (ref), getRemotes2 (copy), result3_2 (ref), v (copy), VirtualInputManager (copy)
				local _ = LocalPlayer.Character
				local remotes2 = getRemotes2()				if result3_2 and remotes2 then
					remotes2:FireServer(result3_2, v, "Up", LocalPlayer:GetMouse().Hit, nil, workspace.CurrentCamera.CFrame)					return
				end				local item = Enum.KeyCode[v]				if item then
					VirtualInputManager:SendKeyEvent(false, item, false, game)
				end
			end)
		end
	end	tbl.onCleanup(function() -- line: 1910
		-- upvalues: found10 (ref), found (ref), flag3 (ref), flag8 (ref), seen (ref), found2 (ref), flag6 (ref), flag7 (ref), found6 (ref), found7 (ref), tween2 (ref), connection (ref), flag16 (ref), handleEnabled (ref), sendKeyEvent (copy), genv (copy)
		found10 = false
		found = false
		flag3 = false
		flag8 = false
		trainerRunning = false
		seen = false
		found2 = false
		flag6 = false
		flag7 = false
		found6 = false
		found7 = false		if tween2 then
			tween2:Cancel()
		end		if connection then
			connection:Disconnect()
			connection = nil
		end		if flag16 then
			handleEnabled(false)
		end		sendKeyEvent()
		genv._cthInfiniteSpinStatus = nil
		genv._cthDatalossStatus = nil
	end)	local function clickCorpseUntilDone(arg, callback, enabled) -- line: 1941
		-- upvalues: sendKeyEvent (copy), getClickDetector (ref), found8 (ref), isCharacterAlive (ref), updateCFrame (ref), pressClickDetector (ref), flag2 (ref), hasEnoughRC (ref), flag (ref), wait (copy), waitForAutoFarmIdle (copy)
		if not arg.model then
			return
		end		sendKeyEvent()		local child = arg.model:WaitForChild(arg.name .. " Corpse", 3)
		local clickPart = child and child:WaitForChild("ClickPart", 3)
		local clickDetector = clickPart and getClickDetector(clickPart, 3)		if not clickPart or not clickDetector then
			return
		end		local timestamp = tick()		found8 = true		local found12 = false
		local flag17 = false		while isCharacterAlive() and callback() do
			if clickPart.Parent then
				updateCFrame(clickPart.Position)
			end			if clickDetector.Parent then
				pressClickDetector(clickDetector, 1)
			else
				found12 = true
			end			if enabled and flag2 and not flag17 then
				local ok, result = pcall(hasEnoughRC)				flag17 = not not ok and (result or false)				if flag17 and flag then
					print("-> Quête finie")
				end
			end			wait(0.15, 0.035)			if found12 or tick() - timestamp > 5 then
				break
			end
		end		if found12 then
			waitForAutoFarmIdle()
		end		found8 = false
	end	function setAutoFarmWhenIdle(arg) -- line: 1990
		-- upvalues: clickCorpseUntilDone (copy), found7 (ref), found (ref), flag3 (ref), flag8 (ref)
		clickCorpseUntilDone(arg, function() -- line: 1991
			-- upvalues: found7 (ref), found (ref), flag3 (ref), flag8 (ref)
			return not found7 and (((if not found then flag3 else found)) or flag8)
		end, true)
	end
	function setAutoFarmActive(arg) -- line: 2002
		-- upvalues: clickCorpseUntilDone (copy), flag3 (ref)
		clickCorpseUntilDone(arg, function() -- line: 2003
			-- upvalues: flag3 (ref)
			return flag3
		end, false)
	end	local function isAutoFarmActive() -- line: 2008
		-- upvalues: cache2 (copy), flag3 (ref), flag8 (ref)
		return cache2.AutoFarmMobs == true or (flag3 or flag8)
	end	function resetAutoFarmState() -- line: 2012
		-- upvalues: isAutoFarmActive (copy), handleEnabled (ref), tween2 (ref), connection (ref)
		if isAutoFarmActive() then
			handleEnabled(true)			return
		end		if tween2 then
			tween2:Cancel()
		end		if connection then
			connection:Disconnect()
			connection = nil
		end		handleEnabled(false)
	end
	function scheduleAutoFarmAction(callback, callback2, enabled) -- line: 2030
		-- upvalues: flag9 (ref), found4 (ref), self (copy), cycleAuraAndMask (ref), autoSpinTick (ref), flag10 (ref), flag13 (ref), found6 (ref), pressMaskKey (ref)
		if flag9 then
			found4 = true
			self.spawn(function() -- line: 2034
				-- upvalues: cycleAuraAndMask (ref), callback (copy), autoSpinTick (ref), callback2 (copy), found4 (ref)
				cycleAuraAndMask()				if callback() then
					autoSpinTick()					if callback2 then
						callback2()
					end
				end				found4 = false
			end)			return
		end		if flag10 then
			found4 = true
		end		if enabled and flag13 then
			found6 = true
		end		self.spawn(function() -- line: 2059
			-- upvalues: self (copy), flag10 (ref), pressMaskKey (ref), found4 (ref), callback (copy), autoSpinTick (ref), callback2 (copy), enabled (copy), found6 (ref)
			self.wait(0.5)			if flag10 then
				pressMaskKey()
			end			found4 = false			if callback() then
				autoSpinTick()				if callback2 then
					callback2()					return
				end
			elseif enabled then
				found6 = false
			end
		end)
	end	flag15 = false
	statusParagraph = nil	function createToggle(n5, arg, flag17, name, callback, _, currentValue3) -- line: 2083
		-- upvalues: cache3 (copy), cache2 (copy)
		local _ = (n5 + 379398034) % 4294967296		cache3[flag17] = arg:CreateToggle({
			Name = name,
			CurrentValue = currentValue3 or false,
			Flag = flag17,
			Callback = function(arg2) -- line: 2090
				-- upvalues: cache2 (copy), flag17 (copy), callback (copy)
				cache2[flag17] = arg2
				callback(arg2)
			end
		})
	end	cthWindow = lib:CreateWindow({
		Title = "CTH",
		Footer = "v1.5  ·  Ro-Ghoul",
		NotifySide = "Right",
		ShowCustomCursor = false,
		ShowMobileButtons = false,
		Center = true,
		AutoShow = true,
		Resizable = true,
		GlobalSearch = true,
		CornerRadius = 10,
		Icon = icon,
		IconSize = UDim2.new(0, 28, 0, 28),
		Size = UDim2.new(0, 760, 0, 560),
		Font = Enum.Font.Gotham,
		Animations = {
			ToggleWindow = true,
			TabSwitch = true,
			Groupbox = true,
			Dropdown = true,
			KeyPicker = true
		},
		TabButtonsStyle = {
			Gap = 4,
			Padding = 6,
			CornerRadius = 8,
			Indicator = true,
			IndicatorWidth = 3,
			IndicatorHeight = 18
		}
	})
	tbl4.styleWindow()
	cthLoading:SetDescription("Loading features...")
	cthLoading:SetCurrentStep(2)	if lib.IsMobile then
		local draggableImageButton = lib:AddDraggableImageButton({
			IconSize = 38,
			Icon = icon or "menu",
			Func = function() -- line: 2137
				-- upvalues: lib (ref)
				lib:Toggle()
			end
		})		lib:AddDraggableButton("Lock", function(arg) -- line: 2142
			-- upvalues: lib (ref)
			lib.CantDragForced = not lib.CantDragForced
			arg:SetText(not lib.CantDragForced and "Lock" or "Unlock")
		end, true, true).Button.Position = UDim2.fromOffset(draggableImageButton.Button.Size.X.Offset + 12, 6)
	end
endlocal tbl5 = {
	Raw = cthWindow,
	CreateTab = function(_, arg, arg2) -- line: 2150
		-- upvalues: createMenuBuilder (copy), cthWindow (copy)
		return createMenuBuilder(cthWindow:AddTab(arg, arg2), arg)
	end
};(function() -- line: 2155
	-- upvalues: tbl5 (copy), LocalPlayer (ref), seen (ref), found2 (ref), flag15 (ref), flag8 (ref), flag3 (ref), found (ref), lib (ref), getConnection (copy), RunService (copy), formatCompactNumber (copy), getPlayerStatValue (copy), self (copy), found10 (ref), team (ref), tbl4 (copy)
	local tab = tbl5.Raw:AddTab("Home", "house")
	local leftGroupbox = tab:AddLeftGroupbox("Profile", "user")	leftGroupbox:AddLabel(LocalPlayer.DisplayName .. "  (@" .. LocalPlayer.Name .. ")")	local label = leftGroupbox:AddLabel("Team: -")
	local label2 = leftGroupbox:AddLabel("Level: -")
	local label3 = leftGroupbox:AddLabel("RC: -")
	local label4 = leftGroupbox:AddLabel("Yen: -")
	local label5 = leftGroupbox:AddLabel("Reputation: -")
	local leftGroupbox2 = tab:AddLeftGroupbox("Build", "sword")
	local label6 = leftGroupbox2:AddLabel("Weapon: -")
	local label7 = leftGroupbox2:AddLabel("Focus: -")
	local label8 = leftGroupbox2:AddLabel("Kag / Quin: -")
	local label9 = leftGroupbox2:AddLabel("Durability: -")
	local rightGroupbox = tab:AddRightGroupbox("Session", "timer")
	local label10 = rightGroupbox:AddLabel("Uptime: 00:00:00")
	local label11 = rightGroupbox:AddLabel("Status: Idle")
	local label12 = rightGroupbox:AddLabel("Yen: 0")
	local label13 = rightGroupbox:AddLabel("RC: 0")
	local label14 = rightGroupbox:AddLabel("Reputation: 0")
	local label15 = rightGroupbox:AddLabel("Level: 0")	local function getActivityStatus() -- line: 2177
		-- upvalues: seen (ref), found2 (ref), flag15 (ref), flag8 (ref), flag3 (ref), found (ref)
		if seen or found2 then
			return "Spinning"
		end		if flag15 then
			return "Training"
		end		if flag8 then
			return "Boss farm"
		end		if flag3 then
			return "Objectives"
		end		if found then
			return "Farming"
		end		return "Idle"
	end	local draggableLabel = lib:AddDraggableLabel("CTH")	tab:AddRightGroupbox("Interface", "monitor"):AddToggle("ShowWatermark", {
		Text = "Show Watermark",
		Default = true,
		Callback = function(arg) -- line: 2205
			-- upvalues: draggableLabel (copy)
			draggableLabel:SetVisible(arg)
		end
	})	local count = 0
	local total = 0	getConnection(RunService.PreRender, function(arg) -- line: 2213
		-- upvalues: count (ref), total (ref)
		count += 1
		total += arg
	end)	local elapsed = os.clock()
	local cache4 = {}	local function formatStatDelta(name) -- line: 2221
		-- upvalues: formatCompactNumber (copy), getPlayerStatValue (copy), cache4 (copy)
		return "+" .. formatCompactNumber(math.max(getPlayerStatValue(name) - cache4[name], 0))
	end	self.spawn(function() -- line: 2225
		-- upvalues: found10 (ref), elapsed (copy), count (ref), total (ref), LocalPlayer (ref), getActivityStatus (copy), cache4 (copy), getPlayerStatValue (copy), label (copy), team (ref), label2 (copy), label3 (copy), formatCompactNumber (copy), label4 (copy), label5 (copy), label6 (copy), label7 (copy), label8 (copy), label9 (copy), label10 (copy), tbl4 (copy), label11 (copy), label12 (copy), formatStatDelta (copy), label13 (copy), label14 (copy), label15 (copy), draggableLabel (copy), self (copy)
		while found10 do
			local n3 = math.floor(os.clock() - elapsed)
			local n4 = math.floor(count / math.max(total, 0.001))
			local n5 = math.floor(LocalPlayer:GetNetworkPing() * 1000)
			local status = getActivityStatus()			count = 0
			total = 0			for _, v in ipairs({ "RC", "Yen", "Reputation", "Level" }) do
				cache4[v] = cache4[v] or getPlayerStatValue(v)
			end			label:SetText("Team: " .. (team or "-"))
			label2:SetText("Level: " .. getPlayerStatValue("Level"))
			label3:SetText("RC: " .. formatCompactNumber(getPlayerStatValue("RC")))
			label4:SetText("Yen: " .. formatCompactNumber(getPlayerStatValue("Yen")))
			label5:SetText("Reputation: " .. formatCompactNumber(getPlayerStatValue("Reputation")))
			label6:SetText("Weapon: " .. tostring(LocalPlayer.PlayerFolder.CurrentWep.Value))
			label7:SetText("Focus: " .. getPlayerStatValue("Focus"))
			label8:SetText("Kag / Quin: " .. getPlayerStatValue("Weapon"))
			label9:SetText("Durability: " .. getPlayerStatValue("Durability"))
			label10:SetText("Uptime: " .. tbl4.clock(n3))
			label11:SetText("Status: " .. status)
			label12:SetText("Yen: " .. formatStatDelta("Yen"))
			label13:SetText("RC: " .. formatStatDelta("RC"))
			label14:SetText("Reputation: " .. formatStatDelta("Reputation"))
			label15:SetText("Level: " .. formatStatDelta("Level"))
			draggableLabel:SetText("CTH  ·  " .. n4 .. " fps  ·  " .. n5 .. " ms  ·  " .. status .. "  ·  " .. tbl4.clock(n3))
			self.wait(1)
		end
	end)
end)();
(function(n3, n4) -- line: 2261
	-- upvalues: tbl5 (copy), cache3 (copy), cache2 (copy), flag3 (ref), flag8 (ref), found (ref), flag2 (ref), found7 (ref), self (copy), autoSpinTick (ref), remotes (ref), team (ref), hasPlayerFolder (ref), flag (ref), found9 (ref), found8 (ref), cashOutReputationIfReady (ref), scheduleAutoFarmAction (copy), resetAutoFarmState (copy), notify (ref), createToggle (copy), flag11 (ref), flag4 (ref), flag5 (ref), bossPosition (ref), getSpinWinCondition (copy), currentValue (ref), options (copy), tbl2 (ref), str3 (ref), cache (copy), findActiveStageName (ref), isRangeModeReady (ref), flag13 (ref), found5 (ref), flag9 (ref), flag12 (ref), flag10 (ref), findPath (copy), LocalPlayer (ref), getRemotes (copy), Players (copy), getConnection (copy), flag14 (ref), str (ref), y (ref), currentValue2 (ref), n (ref), x (ref), statsFunction (ref), getPlayerStatValue (copy), flag6 (ref), value (ref), flag7 (ref), res (ref)
	if type(n3) ~= "boolean" then
	end	local tab = tbl5:CreateTab("Farm", "swords")	tab:CreateSection("Auto Farm", "Left", "crosshair")
	cache3.AutoFarmMobs = tab:CreateToggle({
		Name = "Auto Farm Mobs",
		CurrentValue = false,
		Flag = "AutoFarmMobs",
		Callback = function(autoFarmMobs) -- line: 2272
			-- upvalues: cache2 (copy), flag3 (ref), flag8 (ref), found (ref), flag2 (ref), found7 (ref), self (copy), autoSpinTick (ref), remotes (ref), team (ref), hasPlayerFolder (ref), flag (ref), found9 (ref), found8 (ref), cashOutReputationIfReady (ref), scheduleAutoFarmAction (copy), resetAutoFarmState (copy), notify (ref)
			cache2.AutoFarmMobs = autoFarmMobs			if autoFarmMobs then
				if flag3 or flag8 then
					found = true
				elseif flag2 then
					found7 = true
					self.spawn(function() -- line: 2281
						-- upvalues: self (copy), autoSpinTick (ref), remotes (ref), team (ref), found7 (ref), found (ref), hasPlayerFolder (ref), flag (ref), found9 (ref), found8 (ref), cashOutReputationIfReady (ref)
						self.wait(0.5)
						autoSpinTick()						local timestamp = tick()						repeat
							self.wait(0.5)
						until remotes and team or tick() - timestamp > 10						if not remotes or not team then
							found7 = false
							found = true							return
						end						if not hasPlayerFolder() then
							if flag then
								print("-> récup quete")
							end							repeat
								self.wait(0.3)
							until not found9 and not found8							found = true
							cashOutReputationIfReady()
							found7 = false							return
						end						found = true
						found7 = false
					end)
				else
					scheduleAutoFarmAction(function() -- line: 2314
						-- upvalues: cache2 (copy)
						return cache2.AutoFarmMobs == true
					end, function() -- line: 2316
						-- upvalues: found (ref)
						found = true
					end, false)
				end				resetAutoFarmState()
				notify({
					Title = "Farm",
					Content = "Auto Farm started!",
					Duration = 2
				})				return
			end			found = false
			resetAutoFarmState()
			notify({
				Title = "Farm",
				Content = "Auto Farm stopped.",
				Duration = 2
			})
		end
	})
	createToggle(424710779, tab, "DisableEatCorpses", "Disable Eat Corpses", function(arg) -- line: 2331
		-- upvalues: flag11 (ref)
		flag11 = arg
	end, n4)
	tab:CreateSection("Auto Objectives", "Left", "list-checks")
	cache3.AutoObjectives = tab:CreateToggle({
		Name = "Auto Objectives",
		CurrentValue = false,
		Flag = "AutoObjectives",
		Callback = function(autoObjectives) -- line: 2341
			-- upvalues: flag3 (ref), cache2 (copy), flag8 (ref), scheduleAutoFarmAction (copy), found (ref), resetAutoFarmState (copy), notify (ref)
			flag3 = autoObjectives
			cache2.AutoObjectives = autoObjectives			if autoObjectives then
				if not cache2.AutoFarmMobs and not flag8 then
					scheduleAutoFarmAction(function() -- line: 2347
						-- upvalues: flag3 (ref), found (ref)
						return flag3 or found
					end, nil, false)
				end				resetAutoFarmState()
				notify({
					Title = "Auto Objectives",
					Content = "Auto Objectives enabled!",
					Duration = 2
				})				return
			end			resetAutoFarmState()
		end
	})
	createToggle(424710779, tab, "OptimizedObjectives", "Optimized Objectives", function(arg) -- line: 2360
		-- upvalues: flag4 (ref)
		flag4 = arg
	end, n4)
	tab:CreateSection("Auto Reputation", "Left", "award")
	cache3.AutoRep = tab:CreateToggle({
		Name = "Auto Rep",
		CurrentValue = false,
		Flag = "AutoRep",
		Callback = function(autoRep) -- line: 2370
			-- upvalues: flag2 (ref), cache2 (copy), notify (ref), found (ref), self (copy), remotes (ref), team (ref), hasPlayerFolder (ref), flag (ref), found7 (ref), cashOutReputationIfReady (ref)
			flag2 = autoRep
			cache2.AutoRep = autoRep			if autoRep then
				notify({
					Title = "Auto Rep",
					Content = "Auto Rep enabled!",
					Duration = 2
				})				if found then
					self.spawn(function() -- line: 2378
						-- upvalues: self (copy), remotes (ref), team (ref), hasPlayerFolder (ref), flag (ref), found7 (ref), found (ref), cashOutReputationIfReady (ref), cache2 (copy)
						local timestamp = tick()						repeat
							self.wait(0.5)
						until remotes and team or tick() - timestamp > 10						if not remotes or not team then
							return
						end						if not hasPlayerFolder() then
							if flag then
								print("-> rep auto : récup quetes")
							end							found7 = true
							found = false
							cashOutReputationIfReady()
							found7 = false							if cache2.AutoFarmMobs then
								found = true
							end
						end
					end)
				end
			end
		end
	})
	createToggle(424710779, tab, "AutoCashout", "Auto Cashout", function(arg) -- line: 2409
		-- upvalues: flag5 (ref)
		flag5 = arg
	end, n4)
	tab:CreateSection("Boss Farm", "Right", "skull")
	cache3.AutoBoss = tab:CreateToggle({
		Name = "Auto Boss Farm",
		CurrentValue = false,
		Flag = "AutoBoss",
		Callback = function(autoBoss) -- line: 2419
			-- upvalues: flag8 (ref), cache2 (copy), flag3 (ref), scheduleAutoFarmAction (copy), resetAutoFarmState (copy)
			flag8 = autoBoss
			cache2.AutoBoss = autoBoss			if autoBoss then
				if not cache2.AutoFarmMobs and not flag3 then
					scheduleAutoFarmAction(function() -- line: 2425
						-- upvalues: flag8 (ref)
						return flag8
					end, nil, true)
				end				resetAutoFarmState()				return
			end			resetAutoFarmState()
		end
	})
	cache3.BossPosition = tab:CreateDropdown({
		Name = "Boss Position",
		MultipleOptions = false,
		Flag = "BossPosition",
		Options = { "Orbit", "Below", "Behind", "Above" },
		CurrentOption = { "Orbit" },
		Callback = function(arg) -- line: 2443
			-- upvalues: bossPosition (ref), getSpinWinCondition (copy), cache2 (copy)
			bossPosition = getSpinWinCondition(arg)
			cache2.BossPosition = bossPosition
		end
	})
	cache3.BossRange = tab:CreateSlider({
		Name = "Boss Stop Distance",
		Increment = 1,
		Suffix = " studs",
		Flag = "BossRange",
		Range = { 0, 60 },
		CurrentValue = currentValue,
		Callback = function(bossRange) -- line: 2456
			-- upvalues: currentValue (ref), cache2 (copy)
			currentValue = bossRange
			cache2.BossRange = bossRange
		end
	})
	cache3.BossBlacklist = tab:CreateDropdown({
		Name = "Boss Blacklist",
		MultipleOptions = true,
		Flag = "BossBlacklist",
		Options = options,
		CurrentOption = {},
		Callback = function(arg) -- line: 2468
			-- upvalues: tbl2 (ref), cache2 (copy)
			local bossBlacklist = type(arg) == "table" and arg or { arg }			tbl2 = bossBlacklist
			cache2.BossBlacklist = bossBlacklist
		end
	})
	tab:CreateSection("Weapon Stage", "Right", "sword")
	cache3.StageSelect = tab:CreateDropdown({
		Name = "Stage",
		MultipleOptions = false,
		Flag = "StageSelect",
		Options = { "1", "2", "3", "4", "5", "6", "7" },
		CurrentOption = { "1" },
		Callback = function(arg) -- line: 2483
			-- upvalues: getSpinWinCondition (copy), str3 (ref), cache2 (copy)
			local spinWinCondition = getSpinWinCondition(arg)			str3 = spinWinCondition
			cache2.StageSelect = spinWinCondition
		end
	})
	tab:CreateSection("Attacks (Mouse1 always active)", "Right", "zap")	for _, v in ipairs({ "E", "R", "F", "C" }) do
		local flag16 = "Attack_" .. v		cache3[flag16] = tab:CreateToggle({
			CurrentValue = false,
			Name = "Attack " .. v,
			Flag = flag16,
			Callback = function(arg) -- line: 2499
				-- upvalues: cache2 (copy), flag16 (copy), cache (copy), v (copy)
				cache2[flag16] = arg
				cache[v] = arg
			end
		})
	end	cache3.RangeMode = tab:CreateToggle({
		Name = "Range Mode",
		CurrentValue = false,
		Flag = "RangeMode",
		Callback = function(rangeMode) -- line: 2510
			-- upvalues: findActiveStageName (ref), notify (ref), cache3 (copy), cache2 (copy), isRangeModeReady (ref), flag13 (ref), found5 (ref)
			if rangeMode then
				local v = findActiveStageName()				if not v then
					notify({
						Title = "Range Mode",
						Content = "Weapon not supported! Supported weapons: Owl1, Narukami1, IXA1",
						Duration = 4
					})
					cache3.RangeMode:Set(false)
					cache2.RangeMode = false					return
				end				if isRangeModeReady(v) then
					notify({
						Title = "Range Mode",
						Content = "Not enough RC for Range Mode! Need 7.5M RC.",
						Duration = 4
					})
					cache3.RangeMode:Set(false)
					cache2.RangeMode = false					return
				end
			end			flag13 = rangeMode
			found5 = false
			cache2.RangeMode = rangeMode
		end
	})
	createToggle(424710779, tab, "AutoArata", "Auto Arata", function(arg) -- line: 2545
		-- upvalues: flag9 (ref)
		flag9 = arg
	end, n4)
	createToggle(424710779, tab, "AutoArataRefill", "Auto Arata Refill", function(arg) -- line: 2549
		-- upvalues: flag12 (ref)
		flag12 = arg
	end, n4)
	createToggle(424710779, tab, "AutoMask", "Auto Mask", function(arg) -- line: 2553
		-- upvalues: flag10 (ref)
		flag10 = arg
	end, n4)
	tab:CreateSection("Settings", "Left", "sliders-horizontal")	local flag16 = false
	local connection2	local function isPlayerAllied(arg) -- line: 2561
		-- upvalues: findPath (copy), LocalPlayer (ref)
		local allied = findPath(LocalPlayer, "PlayerFolder") and findPath(LocalPlayer.PlayerFolder, "Allied")		return allied ~= nil and findPath(allied, arg) ~= nil
	end
	local function toggleAllyWith(arg) -- line: 2566
		-- upvalues: LocalPlayer (ref), isPlayerAllied (copy), getRemotes (copy), findPath (copy)
		if not arg or arg == LocalPlayer then
			return
		end		if isPlayerAllied(arg.Name) then
			return
		end		pcall(function() -- line: 2575
			-- upvalues: getRemotes (copy), findPath (copy), arg (copy)
			local remotes2 = getRemotes()
			local ally = remotes2 and findPath(remotes2, "Ally")
			local toggleAlly = ally and findPath(ally, "ToggleAlly")			if toggleAlly then
				toggleAlly:InvokeServer(arg.Name)
			end
		end)
	end
	local function disconnectAll() -- line: 2586
		-- upvalues: Players (copy), toggleAllyWith (copy), connection2 (ref), getConnection (copy), self (copy), flag16 (ref)
		for _, player in ipairs(Players:GetPlayers()) do
			toggleAllyWith(player)
		end		if connection2 then
			connection2:Disconnect()
		end		connection2 = getConnection(Players.PlayerAdded, function(arg) -- line: 2595
			-- upvalues: self (copy), flag16 (ref), toggleAllyWith (copy)
			self.spawn(function() -- line: 2596
				-- upvalues: self (copy), flag16 (ref), toggleAllyWith (copy), arg (copy)
				self.wait(1)				if flag16 then
					toggleAllyWith(arg)
				end
			end)
		end)
	end
	local function disconnect() -- line: 2606
		-- upvalues: connection2 (ref)
		if connection2 then
			connection2:Disconnect()
			connection2 = nil
		end
	end	cache3.AutoAlly = tab:CreateToggle({
		Name = "Auto Ally",
		CurrentValue = false,
		Flag = "AutoAlly",
		Callback = function(autoAlly) -- line: 2617
			-- upvalues: flag16 (ref), cache2 (copy), disconnectAll (copy), notify (ref), disconnect (copy)
			flag16 = autoAlly
			cache2.AutoAlly = autoAlly			if autoAlly then
				disconnectAll()
				notify({
					Title = "Auto Ally",
					Content = "Allying everyone in the server!",
					Duration = 3
				})				return
			end			disconnect()
			notify({
				Title = "Auto Ally",
				Content = "Auto Ally disabled.",
				Duration = 2
			})
		end
	})
	createToggle(424710779, tab, "UndergroundTP", "Underground Traveling", function(arg) -- line: 2631
		-- upvalues: flag14 (ref)
		flag14 = arg
	end, n4)
	cache3.FarmPosition = tab:CreateDropdown({
		Name = "Farm Position",
		MultipleOptions = false,
		Flag = "FarmPosition",
		Options = { "Orbit", "Below", "Behind", "Above" },
		CurrentOption = { "Orbit" },
		Callback = function(arg) -- line: 2641
			-- upvalues: getSpinWinCondition (copy), cache2 (copy), str (ref)
			local spinWinCondition = getSpinWinCondition(arg)			cache2.FarmPosition = spinWinCondition
			str = spinWinCondition
		end
	})
	cache3.OrbitSpeed = tab:CreateSlider({
		Name = "Orbit Speed",
		Increment = 1,
		Suffix = "",
		CurrentValue = 3,
		Flag = "OrbitSpeed",
		Range = { 1, 3 },
		Callback = function(orbitSpeed) -- line: 2655
			-- upvalues: y (ref), cache2 (copy)
			y = ({ 2.09, 3.14, 6.28 })[orbitSpeed]
			cache2.OrbitSpeed = orbitSpeed
		end
	})
	cache3.TPSpeed = tab:CreateSlider({
		Name = "TP Speed (studs/sec)",
		Increment = 10,
		Flag = "TPSpeed",
		Range = { 200, 350 },
		CurrentValue = currentValue2,
		Callback = function(tpSpeed) -- line: 2667
			-- upvalues: cache2 (copy), currentValue2 (ref)
			cache2.TPSpeed = tpSpeed
			currentValue2 = tpSpeed
		end
	})
	cache3.AttackRange = tab:CreateSlider({
		Name = "Mob Stop Distance",
		Increment = 1,
		Suffix = " studs",
		CurrentValue = 7,
		Flag = "AttackRange",
		Range = { 0, 60 },
		Callback = function(attackRange) -- line: 2680
			-- upvalues: cache2 (copy), n (ref)
			cache2.AttackRange = attackRange
			n = attackRange
		end
	})
	cache3.AttackDelay = tab:CreateSlider({
		Name = "Attack Delay (ms)",
		Increment = 10,
		Suffix = "ms",
		Flag = "AttackDelay",
		Range = { 20, 1000 },
		CurrentValue = math.floor(x * 1000),
		Callback = function(attackDelay) -- line: 2693
			-- upvalues: cache2 (copy), x (ref)
			cache2.AttackDelay = attackDelay
			x = attackDelay / 1000
		end
	})	local function spawn(name, name2, callback, callback2) -- line: 2699
		-- upvalues: self (copy), statsFunction (ref), findPath (copy), LocalPlayer (ref), getPlayerStatValue (copy)
		self.spawn(function() -- line: 2700
			-- upvalues: self (copy), statsFunction (ref), findPath (copy), LocalPlayer (ref), callback (copy), callback2 (copy), getPlayerStatValue (copy), name (copy), name2 (copy)
			local timestamp = tick()			repeat
				self.wait(0.1)
			until statsFunction or tick() - timestamp > 5			if not statsFunction then
				return
			end			local focus = findPath(LocalPlayer.PlayerFolder.Stats, "Focus")			if not focus then
				return
			end			while callback() and (tonumber(focus.Value) or 0) > 0 do
				local n5 = callback2()				if n5 > 0 and n5 <= getPlayerStatValue(name) then
					return
				end				pcall(function() -- line: 2727
					-- upvalues: statsFunction (ref), name2 (copy)
					if statsFunction then
						statsFunction:InvokeServer("Focus", name2, 1)
					end
				end)
				self.wait()
			end
		end)
	end	local tab2 = tbl5:CreateTab("Stats", "chart-bar")	tab2:CreateSection("Kag / Quin Stats", "Left", "flame")
	createToggle(424710779, tab2, "AutoWeapon", "Auto Kag/Quin Stats", function(arg) -- line: 2746
		-- upvalues: flag6 (ref), spawn (copy), value (ref)
		flag6 = arg		if arg then
			spawn("Weapon", "WeaponAddButton", function() -- line: 2750
				-- upvalues: flag6 (ref)
				return flag6
			end, function() -- line: 2752
				-- upvalues: value (ref)
				return value
			end)
		end
	end, n4)
	tab2:CreateInput({
		Name = "Max Kag/Quin Stats (0 = unlimited)",
		PlaceholderText = "Ex: 500",
		RemoveTextAfterFocusLost = false,
		Flag = "MaxWeaponStats",
		Callback = function(maxWeaponStats) -- line: 2763
			-- upvalues: value (ref), cache2 (copy)
			local num = tonumber(maxWeaponStats)			if num then
				value = num
				cache2.MaxWeaponStats = maxWeaponStats
			end
		end
	})
	tab2:CreateSection("Durability Stats", "Right", "shield")
	createToggle(424710779, tab2, "AutoDur", "Auto Durability Stats", function(arg) -- line: 2775
		-- upvalues: flag7 (ref), spawn (copy), res (ref)
		flag7 = arg		if arg then
			spawn("Durability", "DurabilityAddButton", function() -- line: 2779
				-- upvalues: flag7 (ref)
				return flag7
			end, function() -- line: 2781
				-- upvalues: res (ref)
				return res
			end)
		end
	end, n4)
	tab2:CreateInput({
		Name = "Max Durability Stats (0 = unlimited)",
		PlaceholderText = "Ex: 500",
		RemoveTextAfterFocusLost = false,
		Flag = "MaxDurStats",
		Callback = function(maxDurStats) -- line: 2792
			-- upvalues: res (ref), cache2 (copy)
			local num = tonumber(maxDurStats)			if num then
				res = num
				cache2.MaxDurStats = maxDurStats
			end
		end
	})
end)(530427334, 186295009);
(function() -- line: 2805
	-- upvalues: tbl5 (copy), statusParagraph (ref), flag15 (ref), notify (ref), LocalPlayer (ref), formatCompactNumber (copy), formatWithCommas (copy), self (copy), ReplicatedStorage (copy), getConnection (copy), lib (ref)
	local tab = tbl5:CreateTab("Trainer", "dumbbell")	tab:CreateSection("Auto Trainer", "Left", "dumbbell")
	statusParagraph = tab:CreateParagraph({
		Title = "Status",
		Content = "Waiting..."
	})
	tab:CreateButton({
		Name = "Start",
		Callback = function() -- line: 2812
			-- upvalues: flag15 (ref), notify (ref)
			flag15 = not flag15			if flag15 then
				notify({
					Title = "Trainer",
					Content = "Auto Trainer started!",
					Duration = 2
				})				return
			end			notify({
				Title = "Trainer",
				Content = "Auto Trainer stopped.",
				Duration = 2
			})
		end
	})	local tab2 = tbl5:CreateTab("Buy", "shopping-cart")
	local list2 = {
		{
			key = "Yen",
			product = "Yen",
			label = "Yen",
			cost = 4,
			gamepass = "Yen2",
			perLevel = 500
		},
		{
			key = "RC",
			product = "RC",
			label = "RC",
			cost = 8,
			gamepass = "RC2",
			perLevel = 100
		},
		{
			key = "Rep",
			product = "Rep",
			label = "Rep",
			cost = 8,
			gamepass = "Rep2",
			flat = 10000
		},
		{
			key = "Color",
			product = "Color Credits",
			label = "Color Credits",
			cost = 8,
			flat = 10
		}
	}
	local tbl6 = {
		k = 1000,
		m = 1000000,
		b = 1000000000,
		t = 1000000000000
	}
	local PlayerFolder = LocalPlayer:WaitForChild("PlayerFolder")
	local Hearts = PlayerFolder:WaitForChild("Inventory"):WaitForChild("Hearts")
	local Level = PlayerFolder:WaitForChild("Stats"):WaitForChild("Level")
	local Gamepass = PlayerFolder:WaitForChild("Gamepass")
	local cache4 = {
		Yen = 0,
		RC = 0,
		Rep = 0,
		Color = 0
	}
	local found11 = false
	local refreshInventoryPanel	local function parseDurationText(arg) -- line: 2841
		-- upvalues: tbl6 (copy)
		local str4 = tostring(arg or ""):lower():gsub("[%s,_]", "")		if str4 == "" then
			return 0
		end		local match, v = str4:match("^(%d*%.?%d+)(%a?)$")
		local n3 = if v ~= "" then tbl6[v] else 1		if not match or not n3 then
			return nil
		end		return math.floor(tonumber(match) * n3)
	end
	local function checkName(name) -- line: 2854
		-- upvalues: Gamepass (copy)
		local child = name and Gamepass:FindFirstChild(name)		return child ~= nil and (child.Value == true or child.Value == "true")
	end
	local function checkName2(arg) -- line: 2859
		-- upvalues: Level (copy), checkName (copy)
		return (arg.flat or arg.perLevel * (tonumber(Level.Value) or 1)) * (not checkName(arg.gamepass) and 1 or 2)
	end
	local function countAffordableColors() -- line: 2869
		-- upvalues: list2 (copy), cache4 (copy), checkName2 (copy)
		local list3 = {}
		local total = 0		for _, v in ipairs(list2) do
			local cached = cache4[v.key]
			local n3 = checkName2(v)			if n3 <= cached then
				local count = math.ceil(cached / n3)				list3[#list3 + 1] = {
					entry = v,
					count = count,
					receive = count * n3,
					hearts = count * v.cost
				}
				total += count * v.cost
			end
		end		return list3, total
	end	local section = tab2:CreateSection("Heart Exchange", "Left", "heart")
	local invParagraph = tab2:CreateParagraph({
		Title = "Inv",
		Content = ""
	})
	local cache5 = {}	for _, v in ipairs(list2) do
		local v2
		local CreateInput = tab2.CreateInput
		local tbl7 = {
			Name = v.label
		}
		local v3 = checkName2(v)		tbl7.PlaceholderText = "min " .. formatCompactNumber(v3)
		tbl7.Flag = "Heart" .. v.key		function tbl7.Callback(arg) -- line: 2899
			-- upvalues: parseDurationText (copy), notify (ref), v (copy), checkName2 (copy), formatWithCommas (copy), cache4 (copy), self (copy), v2 (ref), refreshInventoryPanel (ref)
			local n3 = parseDurationText(arg)			if not n3 then
				notify({
					Title = "Heart Exchange",
					Duration = 3,
					Content = "Invalid amount for " .. v.label .. "."
				})				return
			end			local n4 = checkName2(v)			if n3 > 0 and n3 < n4 then
				notify({
					Title = "Heart Exchange",
					Duration = 4,
					Content = string.format("Minimum for %s is %s (1 exchange).", v.label, formatWithCommas(n4))
				})
				cache4[v.key] = 0
				self.defer(v2.Set, v2, "")
				refreshInventoryPanel()				return
			end			cache4[v.key] = n3
			refreshInventoryPanel()
		end		v2 = CreateInput(tab2, tbl7)
		cache5[v] = v2.Raw.Holder:FindFirstChildOfClass("TextBox")
	end	local section2 = tab2:CreateSection("Summary", "Right", "receipt")
	local paragraph = tab2:CreateParagraph({
		Content = ""
	})
	local Frame = Instance.new("Frame")	Frame.BackgroundTransparency = 1
	Frame.Size = UDim2.new(1, 0, 0, 0)
	Frame.Parent = section2.Container	local paragraph2 = tab2:CreateParagraph({
		Content = ""
	})	function refreshInventoryPanel() -- line: 2936
		-- upvalues: Hearts (copy), list2 (copy), cache5 (copy), formatCompactNumber (copy), checkName2 (copy), checkName (copy), invParagraph (copy), formatWithCommas (copy), Level (copy), countAffordableColors (copy), paragraph (copy), paragraph2 (copy)
		local n3 = tonumber(Hearts.Value) or 0
		local list3 = {}		for _, v in ipairs(list2) do
			if cache5[v] then
				cache5[v].PlaceholderText = "min " .. formatCompactNumber(checkName2(v))
			end			if v.gamepass then
				list3[#list3 + 1] = v.label .. (not checkName(v.gamepass) and " <font color=\"#ED4245\">X</font>" or " <font color=\"#3BA55D\">✓</font>")
			end
		end		invParagraph:Set({
			Title = "Inv",
			Content = table.concat({
				("<font color=\"#8c8580\">%s</font>"):format("Hearts") .. "   " .. ("<font color=\"#ff7a1a\"><b>%s</b></font>"):format(formatWithCommas(n3)),
				("<font color=\"#8c8580\">%s</font>"):format("Level") .. "     <b>" .. tostring(Level.Value) .. "</b>",
				("<font color=\"#8c8580\">%s</font>"):format("2x") .. "        " .. table.concat(list3, ("<font color=\"#8c8580\">%s</font>"):format("  •  "))
			}, "\n")
		})		local v2, n4 = countAffordableColors()		if #v2 == 0 then
			paragraph:Set({
				Content = ("<font color=\"#8c8580\">%s</font>"):format("Enter the amounts you want on the left.")
			})
			paragraph2:Set({
				Content = ("<font color=\"#8c8580\">%s</font>"):format("Total cost") .. "   <b>0 hearts</b>"
			})			return
		end		local list4 = {}		for i, v in ipairs(v2) do
			if i > 1 then
				list4[#list4 + 1] = ""
			end			list4[#list4 + 1] = string.format("<b>%s</b>   %s", v.entry.label, ("<font color=\"#ff7a1a\"><b>%s</b></font>"):format(formatCompactNumber(v.receive)))
			list4[#list4 + 1] = ("<font color=\"#8c8580\">%s</font>"):format(string.format("%d× exchange  •  %s hearts", v.count, formatWithCommas(v.hearts)))
		end		paragraph:Set({
			Content = table.concat(list4, "\n")
		})		local str4 = n3 < n4 and string.format("<font color=\"#ED4245\">Missing %s hearts</font>", formatWithCommas(n4 - n3)) or string.format("<font color=\"#3BA55D\">%s hearts left after</font>", formatWithCommas(n3 - n4))		paragraph2:Set({
			Content = ("<font color=\"#8c8580\">%s</font>"):format("Total cost") .. "   " .. ("<font color=\"#ff7a1a\"><b>%s</b></font>"):format(formatWithCommas(n4) .. " hearts") .. "\n" .. str4
		})
	end	tab2:CreateButton({
		Name = "Exchange",
		Callback = function() -- line: 2993
			-- upvalues: found11 (ref), notify (ref), countAffordableColors (copy), Hearts (copy), formatWithCommas (copy), self (copy), ReplicatedStorage (copy)
			if found11 then
				notify({
					Title = "Heart Exchange",
					Content = "An exchange is already running.",
					Duration = 3
				})				return
			end			local v2, n3 = countAffordableColors()
			local n4 = tonumber(Hearts.Value) or 0			if #v2 == 0 then
				notify({
					Title = "Heart Exchange",
					Content = "Nothing to exchange.",
					Duration = 3
				})				return
			end			if n4 < n3 then
				notify({
					Title = "Heart Exchange",
					Duration = 4,
					Content = "Insufficient hearts: missing " .. formatWithCommas(n3 - n4) .. "."
				})				return
			end			found11 = true
			self.spawn(function() -- line: 3017
				-- upvalues: ReplicatedStorage (copy), v2 (copy), self (copy), n4 (copy), Hearts (copy), found11 (ref), notify (ref), formatWithCommas (copy)
				local HeartExchange = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("HeartExchange")
				local count = 0
				local counter = 0				for _, v in ipairs(v2) do
					for _ = 1, v.count do
						if type(counter) == "table" then
						end						counter += 1
						self.spawn(function() -- line: 3029
							-- upvalues: HeartExchange (copy), v (copy), count (ref)
							pcall(function() -- line: 3030
								-- upvalues: HeartExchange (copy), v (copy)
								HeartExchange:InvokeServer(v.entry.product)
							end)
							count += 1
						end)
					end
				end				repeat
					self.wait()
				until counter <= count				self.wait(0.5)				local n5 = n4 - (tonumber(Hearts.Value) or 0)				found11 = false
				notify({
					Title = "Heart Exchange",
					Duration = 4,
					Content = "Done! " .. formatWithCommas(n5) .. " hearts spent."
				})
			end)
		end
	})
	getConnection(Hearts.Changed, refreshInventoryPanel)
	getConnection(Level.Changed, refreshInventoryPanel)	for _, child in ipairs(Gamepass:GetChildren()) do
		if child:IsA("ValueBase") then
			getConnection(child.Changed, refreshInventoryPanel)
		end
	end	refreshInventoryPanel()	local UIListLayout = section.Container:FindFirstChildOfClass("UIListLayout")
	local UIListLayout2 = section2.Container:FindFirstChildOfClass("UIListLayout")	local function onAbsoluteContentSizeChanged() -- line: 3064
		-- upvalues: Frame (copy), UIListLayout (copy), UIListLayout2 (copy), lib (ref), section2 (copy)
		local AbsoluteSizeY = Frame.AbsoluteSize.Y
		local n3 = math.max(0, UIListLayout.AbsoluteContentSize.Y - (UIListLayout2.AbsoluteContentSize.Y - AbsoluteSizeY))		if math.abs(n3 - AbsoluteSizeY) > 0.5 then
			local dpiScale = lib.DPIScale or 1			Frame.Size = UDim2.new(1, 0, 0, n3 / dpiScale)
			section2:Resize()
		end
	end	UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(onAbsoluteContentSizeChanged)
	UIListLayout2:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(onAbsoluteContentSizeChanged)
	self.defer(onAbsoluteContentSizeChanged)
end)();
(function(_, n3) -- line: 3082
	-- upvalues: loadSettings (copy), readFileSafe (ref), HttpService (copy), LocalPlayer (ref), flag (ref), found2 (ref), genv (copy), self (copy), clickShopIndicator (copy), found3 (ref), cache3 (copy), notify (ref), primary (ref), secondary (ref), same (ref), cache2 (copy), anyTwoSame (ref), formatWithCommas (copy), tbl5 (copy), getSpinWinCondition (copy), createToggle (copy), seen (ref), ReplicatedStorage (copy), str2 (ref), team (ref), handleName (copy)
	local v2 = loadSettings()
	local spinWebhookUrl = v2.spinWebhookUrl or ""
	local currentValue3 = v2.spinWebhookEnabled == true
	local currentValue4 = v2.spinWebhookMisses ~= false
	local buildWinConditionConfig
	local found11 = false
	local notifySpinResult
	local scheduleSpinRetry	local function saveInfiniteSpinState(arg) -- line: 3100
		-- upvalues: readFileSafe (ref), HttpService (copy)
		pcall(function() -- line: 3101
			-- upvalues: arg (copy), readFileSafe (ref), HttpService (copy)
			if not isfolder("CTH") then
				makefolder("CTH")
			end			if not arg then
				if isfile("CTH/infiniteSpin.json") then
					readFileSafe("CTH/infiniteSpin.json")
				end				return
			end			writefile("CTH/infiniteSpin.json", HttpService:JSONEncode(arg))
		end)
	end
	local function isColorPairMatch(arg, arg2, arg3, arg4, arg5, arg6, arg7) -- line: 3118
		local flag16 = arg == arg2		if arg7 and flag16 then
			return true
		end		local flag17 = type(arg4) == "table" and table.find(arg4, arg) ~= nil
		local flag18 = type(arg5) == "table" and table.find(arg5, arg2) ~= nil		if arg3 == "Primary AND Secondary" then
			return flag17 and flag18
		end		if arg3 == "Primary OR Secondary" then
			return flag17 or flag18
		end		if arg3 == "Both same color" then
			return flag16 and arg == arg6
		end		if arg3 == "Primary AND Secondary OR Both same" then
			return flag17 and flag18 or flag16 and arg == arg6
		end		return arg3 == "Any two same" and flag16
	end
	local function runInfiniteSpin(arg) -- line: 3146
		-- upvalues: found11 (ref), LocalPlayer (ref), flag (ref), found2 (ref), genv (copy), saveInfiniteSpinState (ref), notifySpinResult (ref), buildWinConditionConfig (ref), self (copy), clickShopIndicator (copy), isColorPairMatch (ref), found3 (ref), cache3 (copy), notify (ref), scheduleSpinRetry (ref)
		found11 = true		local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
		local PlayerFolder = LocalPlayer:WaitForChild("PlayerFolder")
		local WeaponPrimaryColor = PlayerFolder:WaitForChild("Customization"):WaitForChild("WeaponPrimaryColor")
		local WeaponSecondaryColor = PlayerFolder:WaitForChild("Customization"):WaitForChild("WeaponSecondaryColor")
		local ColorCredits = PlayerFolder:WaitForChild("Settings"):WaitForChild("ColorCredits")
		local Value = PlayerFolder:WaitForChild("Customization"):WaitForChild("Team").Value		if not Value or Value == "" then
			Value = arg.team or "CCG"
		end		if flag then
			print("-> Spin infini : equipe = " .. Value)
		end		local randomizeColor = Value == "CCG" and ReplicatedStorage2.Remotes:WaitForChild("CCGLab"):WaitForChild("RandomizeColor") or ReplicatedStorage2.Remotes:WaitForChild("KakuhouSurgeon"):WaitForChild("RandomizeColor")
		local attempts = arg.attempts or 0		arg.startedAt = arg.startedAt or os.time()
		arg.rejoins = arg.rejoins or 0		while found2 do
			local n4 = tonumber(ColorCredits.Value) or 0			if n4 < 15 then
				pcall(function() -- line: 3172
					-- upvalues: genv (copy)
					local _cthInfiniteSpinStatus = genv._cthInfiniteSpinStatus					if _cthInfiniteSpinStatus then
						_cthInfiniteSpinStatus:Set({
							Title = "Infinite Spin",
							Content = "Not enough credits → Rejoining..."
						})
					end
				end)
				arg.attempts = attempts
				arg.rejoins += 1
				saveInfiniteSpinState(arg)
				notifySpinResult({
					kind = "notfound",
					reason = "out of color credits, rejoining",
					infinite = true,
					primary = WeaponPrimaryColor.Value,
					secondary = WeaponSecondaryColor.Value,
					attempts = attempts,
					rejoins = arg.rejoins,
					startedAt = arg.startedAt,
					target = buildWinConditionConfig(arg)
				})
				self.wait(1)
				pcall(function() -- line: 3198
					-- upvalues: genv (copy)
					local queueOnTeleport = rawget(genv, "queue_on_teleport") or (rawget(genv, "queueonteleport") or syn and syn.queue_on_teleport)					if queueOnTeleport then
						queueOnTeleport("loadstring(game:HttpGet(\"https://raw.githubusercontent.com/Lethilas/CTHv1_Ro-Ghoul_AutoFarm/main/CTH_AutoFarm.lua\"))()")
					end
				end)
				pcall(function() -- line: 3206
					-- upvalues: LocalPlayer (ref)
					game:GetService("TeleportService"):Teleport(game.PlaceId, LocalPlayer)
				end)
				found11 = false				return
			end			clickShopIndicator(Value)
			self.wait(0.3)			local WeaponPrimaryColorValue = WeaponPrimaryColor.Value
			local WeaponSecondaryColorValue = WeaponSecondaryColor.Value
			local winCondition = arg.winCondition or "Primary AND Secondary"			if isColorPairMatch(WeaponPrimaryColorValue, WeaponSecondaryColorValue, winCondition, arg.targetPrimary or {}, arg.targetSecondary or {}, arg.targetSame, arg.anyTwoSame) then
				saveInfiniteSpinState(nil)
				found2 = false
				found11 = false
				notifySpinResult({
					kind = "found",
					infinite = true,
					primary = WeaponPrimaryColorValue,
					secondary = WeaponSecondaryColorValue,
					attempts = attempts,
					rejoins = arg.rejoins,
					startedAt = arg.startedAt,
					target = buildWinConditionConfig(arg)
				})
				pcall(function() -- line: 3236
					-- upvalues: found3 (ref), genv (copy)
					game:GetService("ReplicatedStorage").Remotes.Settings.SpawnSelection:FireServer("")
					found3 = false					local _cthDatalossStatus = genv._cthDatalossStatus					if _cthDatalossStatus then
						_cthDatalossStatus:Set({
							Title = "DataLoss Status",
							Content = "Disable"
						})
					end
				end)				local str4 = "Found in " .. attempts .. " attempts!\nP: " .. WeaponPrimaryColorValue .. " | S: " .. WeaponSecondaryColorValue				pcall(function() -- line: 3248
					-- upvalues: genv (copy), str4 (copy), cache3 (copy)
					local _cthInfiniteSpinStatus = genv._cthInfiniteSpinStatus					if _cthInfiniteSpinStatus then
						_cthInfiniteSpinStatus:Set({
							Title = "Infinite Spin",
							Content = str4 .. "\nColor saved (UnDataLoss)"
						})
					end					if cache3.InfiniteSpinToggle then
						cache3.InfiniteSpinToggle:Set(false)
					end
				end)
				notify({
					Title = "Infinite Spin ✓",
					Duration = 15,
					Content = str4 .. "\nColor saved automatically."
				})				return
			end			local WeaponPrimaryColorValue2 = WeaponPrimaryColor.Value
			local WeaponSecondaryColorValue2 = WeaponSecondaryColor.Value			randomizeColor:InvokeServer("Standard")
			self.wait(0.5)			local WeaponPrimaryColorValue3 = WeaponPrimaryColor.Value
			local WeaponSecondaryColorValue3 = WeaponSecondaryColor.Value			if WeaponPrimaryColorValue3 ~= WeaponPrimaryColorValue2 or WeaponSecondaryColorValue3 ~= WeaponSecondaryColorValue2 then
				attempts += 1
				arg.attempts = attempts
				saveInfiniteSpinState(arg)				if not isColorPairMatch(WeaponPrimaryColorValue3, WeaponSecondaryColorValue3, winCondition, arg.targetPrimary or {}, arg.targetSecondary or {}, arg.targetSame, arg.anyTwoSame) then
					scheduleSpinRetry({
						kind = "notfound",
						infinite = true,
						primary = WeaponPrimaryColorValue3,
						secondary = WeaponSecondaryColorValue3,
						attempts = attempts,
						rejoins = arg.rejoins,
						startedAt = arg.startedAt,
						target = buildWinConditionConfig(arg)
					})
				end				pcall(function() -- line: 3295
					-- upvalues: genv (copy), attempts (ref), n4 (copy), WeaponPrimaryColorValue3 (copy), WeaponSecondaryColorValue3 (copy)
					local _cthInfiniteSpinStatus = genv._cthInfiniteSpinStatus					if _cthInfiniteSpinStatus then
						_cthInfiniteSpinStatus:Set({
							Title = "Infinite Spin",
							Content = string.format("Attempt %d | Credits: %d\nP: %s\nS: %s", attempts, n4, WeaponPrimaryColorValue3, WeaponSecondaryColorValue3)
						})
					end
				end)
			end
		end		found11 = false
		saveInfiniteSpinState(nil)
		notifySpinResult({
			kind = "notfound",
			reason = "stopped manually",
			infinite = true,
			primary = WeaponPrimaryColor.Value,
			secondary = WeaponSecondaryColor.Value,
			attempts = attempts,
			rejoins = arg.rejoins,
			startedAt = arg.startedAt,
			target = buildWinConditionConfig(arg)
		})
		pcall(function() -- line: 3323
			-- upvalues: genv (copy)
			local _cthInfiniteSpinStatus = genv._cthInfiniteSpinStatus			if _cthInfiniteSpinStatus then
				_cthInfiniteSpinStatus:Set({
					Title = "Infinite Spin",
					Content = "Disabled"
				})
			end
		end)
	end	self.spawn(function() -- line: 3332
		-- upvalues: HttpService (copy), found2 (ref), primary (ref), secondary (ref), same (ref), LocalPlayer (ref), self (copy), flag (ref), found3 (ref), genv (copy), found11 (ref), cache3 (copy), runInfiniteSpin (ref)
		pcall(function() -- line: 3333
			-- upvalues: HttpService (copy), found2 (ref), primary (ref), secondary (ref), same (ref), LocalPlayer (ref), self (copy), flag (ref), found3 (ref), genv (copy), found11 (ref), cache3 (copy), runInfiniteSpin (ref)
			if not isfile("CTH/infiniteSpin.json") then
				return
			end			local ok, result = pcall(function() -- line: 3338
				-- upvalues: HttpService (copy)
				return HttpService:JSONDecode(readfile("CTH/infiniteSpin.json"))
			end)			if not ok or not result or not result.enabled then
				return
			end			found2 = true
			primary = result.targetPrimary or { "Really black" }
			secondary = result.targetSecondary or { "Really black" }
			same = result.targetSame or "Really black";
			(LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()):WaitForChild("Humanoid")
			self.wait(5)			local Team = LocalPlayer:WaitForChild("PlayerFolder"):WaitForChild("Customization"):WaitForChild("Team")
			local n4 = 10			while (Team.Value == "" or Team.Value == nil) and n4 > 0 do
				self.wait(1)
				n4 -= 1
			end			if flag then
				print("-> Spin infini : equipe = " .. tostring(Team.Value))
			end			pcall(function() -- line: 3364
				-- upvalues: found3 (ref), flag (ref), genv (copy)
				local SpawnSelection = game:GetService("ReplicatedStorage"):WaitForChild("Remotes", 10):WaitForChild("Settings", 10):WaitForChild("SpawnSelection", 10)				if SpawnSelection then
					SpawnSelection:FireServer("\128\129\200\201")
					found3 = true					if flag then
						print("-> Spin infini : DataLoss reactive")
					end					local _cthInfiniteSpinStatus = genv._cthInfiniteSpinStatus					if _cthInfiniteSpinStatus then
						_cthInfiniteSpinStatus:Set({
							Title = "Infinite Spin",
							Content = "DataLoss re-activated, spinning..."
						})
					end					local _cthDatalossStatus = genv._cthDatalossStatus					if _cthDatalossStatus then
						_cthDatalossStatus:Set({
							Title = "DataLoss Status",
							Content = "Enable"
						})
					end
				end
			end)
			found11 = true
			pcall(function() -- line: 3391
				-- upvalues: cache3 (copy)
				if cache3.InfiniteSpinToggle then
					cache3.InfiniteSpinToggle:Set(true)
				end
			end)
			pcall(function() -- line: 3397
				-- upvalues: cache3 (copy), primary (ref), secondary (ref), same (ref)
				if cache3.SpinPrimary then
					cache3.SpinPrimary:Set(primary)
				end				if cache3.SpinSecondary then
					cache3.SpinSecondary:Set(secondary)
				end				if cache3.SpinSameColor then
					cache3.SpinSameColor:Set(same)
				end
			end)
			runInfiniteSpin(result)
		end)
	end)	local tbl6 = {
		["Hot pink"] = { 255, 0, 191 },
		White = { 242, 243, 243 },
		Grey = { 161, 165, 162 },
		["Light yellow"] = { 249, 233, 153 },
		["Medium stone grey"] = { 163, 162, 165 },
		["Brick yellow"] = { 215, 197, 154 },
		["Light green (Mint)"] = { 194, 218, 184 },
		["Light reddish violet"] = { 232, 186, 200 },
		["Pastel Blue"] = { 128, 187, 219 },
		["Light orange brown"] = { 203, 132, 66 },
		Nougat = { 204, 142, 105 },
		["Bright red"] = { 196, 40, 28 },
		["Med. reddish violet"] = { 196, 112, 160 },
		["Bright blue"] = { 13, 105, 172 },
		["Bright yellow"] = { 245, 205, 48 },
		["Earth orange"] = { 98, 71, 50 },
		Black = { 27, 42, 53 },
		["Dark grey"] = { 109, 110, 108 },
		["Dark green"] = { 40, 127, 71 },
		["Medium green"] = { 161, 196, 140 },
		["Lig. Yellowich orange"] = { 243, 207, 155 },
		["Bright green"] = { 75, 151, 75 },
		["Dark orange"] = { 160, 95, 53 },
		["Light bluish violet"] = { 193, 202, 222 },
		Transparent = { 236, 236, 236 },
		["Tr. Red"] = { 205, 84, 75 },
		["Tr. Lg blue"] = { 193, 223, 240 },
		["Tr. Blue"] = { 123, 182, 232 },
		["Tr. Yellow"] = { 247, 241, 141 },
		["Light blue"] = { 180, 210, 228 },
		["Tr. Flu. Reddish orange"] = { 217, 133, 108 },
		["Tr. Green"] = { 132, 182, 141 },
		["Tr. Flu. Green"] = { 248, 241, 132 },
		["Phosph. White"] = { 236, 232, 222 },
		["Light red"] = { 238, 196, 182 },
		["Medium red"] = { 218, 134, 122 },
		["Medium blue"] = { 110, 153, 202 },
		["Light grey"] = { 199, 193, 183 },
		["Bright violet"] = { 107, 50, 124 },
		["Br. yellowish orange"] = { 226, 155, 64 },
		["Bright orange"] = { 218, 133, 65 },
		["Bright bluish green"] = { 0, 143, 156 },
		["Earth yellow"] = { 104, 92, 67 },
		["Bright bluish violet"] = { 67, 84, 147 },
		["Tr. Brown"] = { 191, 183, 177 },
		["Medium bluish violet"] = { 104, 116, 172 },
		["Tr. Medi. reddish violet"] = { 229, 173, 200 },
		["Med. yellowish green"] = { 199, 210, 60 },
		["Med. bluish green"] = { 85, 165, 175 },
		["Light bluish green"] = { 183, 215, 213 },
		["Br. yellowish green"] = { 164, 189, 71 },
		["Lig. yellowish green"] = { 217, 228, 167 },
		["Med. yellowish orange"] = { 231, 172, 88 },
		["Br. reddish orange"] = { 211, 111, 76 },
		["Bright reddish violet"] = { 146, 57, 120 },
		["Light orange"] = { 234, 184, 146 },
		["Tr. Bright bluish violet"] = { 165, 165, 203 },
		Gold = { 220, 188, 129 },
		["Dark nougat"] = { 174, 122, 89 },
		Silver = { 156, 163, 168 },
		["Neon orange"] = { 213, 115, 61 },
		["Neon green"] = { 216, 221, 86 },
		["Sand blue"] = { 116, 134, 157 },
		["Sand violet"] = { 135, 124, 144 },
		["Medium orange"] = { 224, 152, 100 },
		["Sand yellow"] = { 149, 138, 115 },
		["Earth blue"] = { 32, 58, 86 },
		["Earth green"] = { 39, 70, 45 },
		["Tr. Flu. Blue"] = { 207, 226, 247 },
		["Sand blue metallic"] = { 121, 136, 161 },
		["Sand violet metallic"] = { 149, 142, 163 },
		["Sand yellow metallic"] = { 147, 135, 103 },
		["Dark grey metallic"] = { 87, 88, 87 },
		["Black metallic"] = { 22, 29, 50 },
		["Light grey metallic"] = { 171, 173, 172 },
		["Sand green"] = { 120, 144, 130 },
		["Sand red"] = { 149, 121, 119 },
		["Dark red"] = { 123, 46, 47 },
		["Tr. Flu. Yellow"] = { 255, 246, 123 },
		["Tr. Flu. Red"] = { 225, 164, 194 },
		["Gun metallic"] = { 117, 108, 98 },
		["Red flip/flop"] = { 151, 105, 91 },
		["Yellow flip/flop"] = { 180, 132, 85 },
		["Silver flip/flop"] = { 137, 135, 136 },
		Curry = { 215, 169, 75 },
		["Fire Yellow"] = { 249, 214, 46 },
		["Flame yellowish orange"] = { 232, 171, 45 },
		["Reddish brown"] = { 105, 64, 40 },
		["Flame reddish orange"] = { 207, 96, 36 },
		["Royal blue"] = { 70, 103, 164 },
		["Dark Royal blue"] = { 35, 71, 139 },
		["Bright reddish lilac"] = { 142, 66, 133 },
		["Dark stone grey"] = { 99, 95, 98 },
		["Lemon metalic"] = { 130, 138, 93 },
		["Light stone grey"] = { 229, 228, 223 },
		["Dark Curry"] = { 176, 142, 68 },
		["Faded green"] = { 112, 149, 120 },
		Turquoise = { 121, 181, 181 },
		["Light Royal blue"] = { 159, 195, 233 },
		["Medium Royal blue"] = { 108, 129, 183 },
		Rust = { 143, 76, 42 },
		Brown = { 124, 92, 70 },
		["Reddish lilac"] = { 150, 112, 159 },
		Lilac = { 107, 98, 155 },
		["Light lilac"] = { 167, 169, 206 },
		["Bright purple"] = { 205, 98, 152 },
		["Light purple"] = { 228, 173, 200 },
		["Light pink"] = { 220, 144, 149 },
		["Light brick yellow"] = { 240, 213, 160 },
		["Warm yellowish orange"] = { 235, 184, 127 },
		["Cool yellow"] = { 253, 234, 141 },
		["Dove blue"] = { 125, 187, 221 },
		["Medium lilac"] = { 52, 43, 117 },
		["Slime green"] = { 80, 109, 84 },
		["Smoky grey"] = { 91, 93, 105 },
		["Dark blue"] = { 0, 16, 176 },
		["Parsley green"] = { 44, 101, 29 },
		["Steel blue"] = { 82, 124, 174 },
		["Storm blue"] = { 51, 88, 130 },
		Lapis = { 16, 42, 220 },
		["Dark indigo"] = { 61, 21, 133 },
		["Sea green"] = { 52, 142, 64 },
		Shamrock = { 91, 154, 76 },
		Fossil = { 159, 161, 172 },
		Mulberry = { 89, 34, 89 },
		["Forest green"] = { 31, 128, 29 },
		["Cadet blue"] = { 159, 173, 192 },
		["Electric blue"] = { 9, 137, 207 },
		Eggplant = { 123, 0, 123 },
		Moss = { 124, 156, 107 },
		Artichoke = { 138, 171, 133 },
		["Sage green"] = { 185, 196, 177 },
		["Ghost grey"] = { 202, 203, 209 },
		Plum = { 123, 47, 123 },
		Olivine = { 148, 190, 129 },
		["Laurel green"] = { 168, 189, 153 },
		["Quill grey"] = { 223, 223, 222 },
		Crimson = { 151, 0, 0 },
		Mint = { 177, 229, 166 },
		["Baby blue"] = { 152, 194, 219 },
		["Carnation pink"] = { 255, 152, 220 },
		Persimmon = { 255, 89, 89 },
		Maroon = { 117, 0, 0 },
		["Daisy orange"] = { 248, 217, 109 },
		Pearl = { 231, 231, 236 },
		Fog = { 199, 212, 228 },
		Salmon = { 255, 148, 148 },
		["Terra Cotta"] = { 190, 104, 98 },
		Cocoa = { 86, 36, 36 },
		Wheat = { 241, 231, 199 },
		Buttermilk = { 254, 243, 187 },
		Mauve = { 224, 178, 208 },
		Sunrise = { 212, 144, 189 },
		Tawny = { 150, 85, 85 },
		Cashmere = { 211, 190, 150 },
		Khaki = { 226, 220, 188 },
		["Lily white"] = { 237, 234, 234 },
		Seashell = { 233, 218, 218 },
		Burgundy = { 136, 62, 62 },
		Cork = { 188, 155, 93 },
		Burlap = { 199, 172, 120 },
		Beige = { 202, 191, 163 },
		Oyster = { 187, 179, 178 },
		["Pine Cone"] = { 108, 88, 75 },
		["Fawn brown"] = { 160, 132, 79 },
		["Hurricane grey"] = { 149, 137, 136 },
		["Cloudy grey"] = { 171, 168, 158 },
		Linen = { 175, 148, 131 },
		Copper = { 150, 103, 102 },
		["Medium brown"] = { 86, 66, 54 },
		Bronze = { 126, 104, 63 },
		Flint = { 105, 102, 92 },
		["Dark taupe"] = { 90, 76, 66 },
		["Burnt Sienna"] = { 106, 57, 9 },
		["Institutional white"] = { 248, 248, 248 },
		["Mid gray"] = { 205, 205, 205 },
		["Really black"] = { 17, 17, 17 },
		["Really red"] = { 255, 0, 0 },
		["Deep orange"] = { 255, 176, 0 },
		Alder = { 180, 128, 255 },
		["Dusty Rose"] = { 163, 75, 75 },
		Olive = { 193, 190, 66 },
		["New Yeller"] = { 255, 255, 0 },
		["Really blue"] = { 0, 0, 255 },
		["Navy blue"] = { 0, 32, 96 },
		["Deep blue"] = { 33, 84, 185 },
		Cyan = { 4, 175, 236 },
		["CGA brown"] = { 170, 85, 0 },
		Magenta = { 170, 0, 170 },
		Pink = { 255, 102, 204 },
		Teal = { 18, 238, 212 },
		Toothpaste = { 0, 255, 255 },
		["Lime green"] = { 0, 255, 0 },
		Camo = { 58, 125, 21 },
		Grime = { 127, 142, 100 },
		Lavender = { 140, 91, 159 },
		["Pastel light blue"] = { 175, 221, 255 },
		["Pastel orange"] = { 255, 201, 201 },
		["Pastel violet"] = { 177, 167, 255 },
		["Pastel blue-green"] = { 159, 243, 233 },
		["Pastel green"] = { 204, 255, 204 },
		["Pastel yellow"] = { 255, 255, 204 },
		["Pastel brown"] = { 255, 204, 153 },
		["Royal purple"] = { 98, 37, 209 },
		["Dirt brown"] = { 86, 66, 54 }
	}
	local request2 = request or (http_request or (syn and syn.request or fluxus and fluxus.request)) or http and http.request
	local list2 = {
		{ "🟥", 221, 46, 68 },
		{ "🟧", 244, 144, 12 },
		{ "🟨", 253, 203, 88 },
		{ "🟩", 120, 177, 89 },
		{ "🟦", 85, 172, 238 },
		{ "🟪", 170, 142, 214 },
		{ "🟫", 193, 105, 79 },
		{ "⬛", 30, 30, 30 },
		{ "⬜", 235, 235, 235 }
	}	local function getTeamColorRgb(arg) -- line: 3767
		-- upvalues: tbl6 (ref)
		return tbl6[arg] or { 255, 122, 26 }
	end
	local function formatColorHex(arg) -- line: 3771
		-- upvalues: getTeamColorRgb (copy)
		local v = getTeamColorRgb(arg)		return string.format("%02X%02X%02X", v[1], v[2], v[3])
	end
	local function nearestColorName(arg) -- line: 3776
		-- upvalues: getTeamColorRgb (copy), list2 (copy)
		local v3 = getTeamColorRgb(arg)
		local huge3 = math.huge
		local str4 = "⬛"		for _, v in ipairs(list2) do
			local n4 = (v3[1] - v[2]) ^ 2 + (v3[2] - v[3]) ^ 2 + (v3[3] - v[4]) ^ 2			if n4 < huge3 then
				str4 = v[1]
				huge3 = n4
			end
		end		return str4
	end
	local function formatDuration(n4) -- line: 3793
		local n5 = math.max(0, math.floor(n4))
		local n6 = n5 // 3600
		local n7 = n5 % 3600 // 60		if n6 > 0 then
			return string.format("%dh %02dm", n6, n7)
		end		if n7 > 0 then
			return string.format("%dm %02ds", n7, n5 % 60)
		end		return n5 .. "s"
	end
	local function getText(arg) -- line: 3807
		return type(arg) == "string" and (arg:match("^https://discord%.com/api/webhooks/") or (arg:match("^https://%a+%.discord%.com/api/webhooks/") or arg:match("^https://discordapp%.com/api/webhooks/"))) ~= nil
	end
	local function formatParticipantList(entries, sameColorFlag) -- line: 3817
		-- upvalues: nearestColorName (copy), formatColorHex (copy)
		local list3 = {}
		local tbl7 = entries or {}		for i, v in ipairs(tbl7) do
			if i > 12 then
				list3[#list3 + 1] = string.format("*…and %d more*", #entries - 12)				return #list3 > 0 and table.concat(list3, "\n") or "—"
			end			list3[#list3 + 1] = string.format("%s %s `#%s`%s", nearestColorName(v), v, formatColorHex(v), v ~= sameColorFlag and "" or "  ✅")
		end		return #list3 > 0 and table.concat(list3, "\n") or "—"
	end
	local function buildConditionFields(condition2, primaryEntries, secondaryEntries) -- line: 3832
		-- upvalues: formatParticipantList (copy)
		local condition = condition2.condition or "Primary AND Secondary"
		local list3 = {{
			name = "Condition",
			inline = false,
			value = condition
		}}
		local flag16 = condition == "Primary AND Secondary" or (condition == "Primary OR Secondary" or condition == "Primary AND Secondary OR Both same")
		local flag17 = condition == "Both same color" or condition == "Primary AND Secondary OR Both same"		if flag16 then
			list3[#list3 + 1] = {
				name = "Primary",
				inline = true,
				value = formatParticipantList(condition2.primary, primaryEntries)
			}
			list3[#list3 + 1] = {
				name = "Secondary",
				inline = true,
				value = formatParticipantList(condition2.secondary, secondaryEntries)
			}
		end		if flag17 and condition2.same then
			local flag18 = primaryEntries == secondaryEntries and primaryEntries == condition2.same			list3[#list3 + 1] = {
				name = "Both same",
				inline = false,
				value = formatParticipantList({ condition2.same }, flag18 and condition2.same or nil)
			}
		end		if condition == "Any two same" or condition2.anyTwoSame then
			list3[#list3 + 1] = {
				value = "\226\128\139",
				inline = false,
				name = "Any pair" .. (primaryEntries ~= secondaryEntries and "" or "  ✅")
			}
		end		return list3
	end	local list3 = {}	for i = 0, 255 do
		local j = i		for _ = 1, 8 do
			j = bit32.band(j, 1) == 1 and bit32.bxor(3988292384, bit32.rshift(j, 1)) or bit32.rshift(j, 1)
		end		list3[i] = j
	end	local function crc32Checksum(str4) -- line: 3867
		-- upvalues: list3 (copy)
		local n4 = 4294967295		for i = 1, #str4 do
			n4 = bit32.bxor(list3[bit32.band(bit32.bxor(n4, str4:byte(i)), 255)], bit32.rshift(n4, 8))
		end		return bit32.bxor(n4, 4294967295)
	end
	local function adler32Checksum(str4) -- line: 3877
		local n4 = 1
		local n5 = 0		for i = 1, #str4 do
			n4 = (n4 + str4:byte(i)) % 65521
			n5 = (n5 + n4) % 65521
		end		return n5 * 65536 + n4
	end
	local function buildPngChunk(chunkType, chunkData) -- line: 3889
		-- upvalues: crc32Checksum (copy)
		return string.pack(">I4", #chunkData) .. chunkType .. chunkData .. string.pack(">I4", crc32Checksum(chunkType .. chunkData))
	end
	local function buildSwatchPng(primaryColor, secondaryColor) -- line: 3893
		-- upvalues: getTeamColorRgb (copy), adler32Checksum (copy), buildPngChunk (copy)
		local v = getTeamColorRgb(primaryColor)
		local v3 = getTeamColorRgb(secondaryColor)
		local str4 = string.rep("\000" .. string.rep(string.char(v[1], v[2], v[3]), 32) .. string.rep(string.char(v3[1], v3[2], v3[3]), 32), 64)
		local str5 = "x\001\001" .. string.pack("<I2I2", #str4, bit32.bxor(#str4, 65535)) .. str4 .. string.pack(">I4", adler32Checksum(str4))		return "\137PNG\r\n\026\n" .. buildPngChunk("IHDR", string.pack(">I4I4", 64, 64) .. "\b\002\000\000\000") .. buildPngChunk("IDAT", str5) .. buildPngChunk("IEND", "")
	end
	local function buildSpinTarget() -- line: 3901
		-- upvalues: cache2 (copy), primary (ref), secondary (ref), same (ref), anyTwoSame (ref)
		return {
			condition = cache2.SpinWinCondition or "Primary AND Secondary",
			primary = primary,
			secondary = secondary,
			same = same,
			anyTwoSame = anyTwoSame
		}
	end	function buildWinConditionConfig(arg) -- line: 3911
		return {
			condition = arg.winCondition or "Primary AND Secondary",
			primary = arg.targetPrimary,
			secondary = arg.targetSecondary,
			same = arg.targetSame,
			anyTwoSame = arg.anyTwoSame
		}
	end
	function notifySpinResult(arg) -- line: 3921
		-- upvalues: currentValue3 (ref), currentValue4 (ref), request2 (ref), getText (copy), spinWebhookUrl (ref), formatWithCommas (copy), formatDuration (copy), formatColorHex (copy), buildSpinTarget (copy), buildConditionFields (copy), HttpService (copy), buildSwatchPng (copy), self (copy)
		if not currentValue3 then
			return false, "disabled"
		end		if arg.kind == "notfound" and not currentValue4 then
			return false, "misses disabled"
		end		if not request2 then
			return false, "no request function"
		end		if not getText(spinWebhookUrl) then
			return false, "invalid URL"
		end		local str4 = "🎲 **" .. formatWithCommas(arg.attempts or 0) .. "** spins"		if arg.infinite then
			str4 ..= "  •  🔁 **" .. tostring(arg.rejoins or 0) .. "** rejoins  •  ⏱\239\184\143 **" .. formatDuration(os.time() - (arg.startedAt or os.time())) .. "**"
		end		local str5 = not arg.infinite and "Spin" or "Infinite Spin"
		local flag16 = arg.kind == "found"
		local title = not flag16 and "❌  COLOR NOT FOUND" or "✅  COLOR FOUND"
		local color = not flag16 and 15548997 or 3908957
		local str6 = not flag16 and "Last roll" or "Obtained"
		local description = "**" .. str5 .. "**" .. (arg.reason and " — " .. arg.reason or "") .. "\n" .. str4
		local list4 = {
			{
				inline = true,
				name = str6 .. " · Primary",
				value = string.format("**%s** `#%s`", tostring(arg.primary), formatColorHex(arg.primary))
			},
			{
				inline = true,
				name = formatColorHex .. " · Secondary",
				value = string.format("**%s** `#%s`", tostring(arg.secondary), formatColorHex(arg.secondary))
			},
			{
				name = "\226\128\139",
				value = "━━━━━━━━━━━━  🎯 **Target**  ━━━━━━━━━━━━",
				inline = false
			}
		}
		local target = arg.target or buildSpinTarget()		for _, v in ipairs(buildConditionFields(target, arg.primary, arg.secondary)) do
			list4[#list4 + 1] = v
		end		local tbl7 = {
			username = "CTH",
			embeds = {{
				author = {
					icon_url = "attachment://swatch.png",
					name = string.format("%s  /  %s", tostring(arg.primary), tostring(arg.secondary))
				},
				title = title,
				color = color,
				description = description,
				fields = list4,
				footer = {
					text = "CTHv1.5"
				}
			}}
		}
		local str7 = "CTHBoundary" .. tostring(math.random(100000000, 999999999))
		local body = table.concat({
			"--",
			str7,
			"\r\n",
			"Content-Disposition: form-data; name=\"payload_json\"\r\n",
			"Content-Type: application/json\r\n\r\n",
			HttpService:JSONEncode(tbl7),
			"\r\n",
			"--",
			str7,
			"\r\n",
			"Content-Disposition: form-data; name=\"files[0]\"; filename=\"swatch.png\"\r\n",
			"Content-Type: image/png\r\n\r\n",
			buildSwatchPng(arg.primary, arg.secondary),
			"\r\n",
			"--",
			str7,
			"--\r\n"
		})		for _ = 1, 3 do
			local ok, result = pcall(request2, {
				Method = "POST",
				Url = spinWebhookUrl,
				Headers = {
					["Content-Type"] = "multipart/form-data; boundary=" .. str7
				},
				Body = body
			})			if not ok then
				return false, tostring(result)
			end			local statusCode = result and result.StatusCode			if statusCode ~= 429 then
				return statusCode == 200 or statusCode == 204, "HTTP " .. tostring(statusCode)
			end			local ok4, result4 = pcall(function() -- line: 4026
				-- upvalues: HttpService (copy), result (copy)
				return HttpService:JSONDecode(result.Body)
			end)			self.wait((ok4 and tonumber(result4.retry_after) or 1) + 0.1)
		end		return false, "rate limited"
	end	local n4 = 0	function scheduleSpinRetry(arg) -- line: 4038
		-- upvalues: currentValue3 (ref), currentValue4 (ref), n4 (ref), self (copy), notifySpinResult (ref)
		if not currentValue3 or not currentValue4 then
			return
		end		local n5 = 2 - (tick() - n4)		if n5 > 0 then
			self.wait(n5)
		end		n4 = tick()
		notifySpinResult(arg)
	end	local tab = tbl5:CreateTab("Spin", "palette")	tab:CreateSection("Weapon Color Spin", "Left", "palette")	local options2 = {}	for k in pairs(tbl6) do
		options2[#options2 + 1] = k
	end	table.sort(options2)
	tab:CreateDropdown({
		Name = "Win Condition",
		MultipleOptions = false,
		Flag = "SpinWinCondition",
		Options = {
			"Primary AND Secondary",
			"Primary OR Secondary",
			"Both same color",
			"Any two same"
		},
		CurrentOption = { "Primary AND Secondary" },
		Callback = function(arg) -- line: 4068
			-- upvalues: cache2 (copy), getSpinWinCondition (copy)
			cache2.SpinWinCondition = getSpinWinCondition(arg)
		end
	})
	createToggle(424710779, tab, "SpinAnyTwoSame", "Also stop if any two same", function(arg) -- line: 4073
		-- upvalues: anyTwoSame (ref)
		anyTwoSame = arg
	end, n3)
	cache3.SpinSameColor = tab:CreateDropdown({
		Name = "Same Color Target",
		MultipleOptions = false,
		Flag = "SpinSameColor",
		Options = options2,
		CurrentOption = { "Really black" },
		Callback = function(arg) -- line: 4083
			-- upvalues: getSpinWinCondition (copy), tbl6 (ref), same (ref)
			local spinWinCondition = getSpinWinCondition(arg)			if tbl6[spinWinCondition] then
				same = spinWinCondition
			end
		end
	})
	cache3.SpinPrimary = tab:CreateDropdown({
		Name = "Primary Color Target (multi)",
		MultipleOptions = true,
		Flag = "SpinPrimary",
		Options = options2,
		CurrentOption = { "Really black" },
		Callback = function(arg) -- line: 4098
			-- upvalues: primary (ref), tbl6 (ref)
			local tbl7 = type(arg) == "table" and arg or { arg }			primary = {}			for _, v in ipairs(tbl7) do
				if tbl6[v] then
					table.insert(primary, v)
				end
			end			if #primary == 0 then
				primary = { "Really black" }
			end
		end
	})
	cache3.SpinSecondary = tab:CreateDropdown({
		Name = "Secondary Color Target (multi)",
		MultipleOptions = true,
		Flag = "SpinSecondary",
		Options = options2,
		CurrentOption = { "Really black" },
		Callback = function(arg) -- line: 4120
			-- upvalues: secondary (ref), tbl6 (ref)
			local tbl7 = type(arg) == "table" and arg or { arg }			secondary = {}			for _, v in ipairs(tbl7) do
				if tbl6[v] then
					table.insert(secondary, v)
				end
			end			if #secondary == 0 then
				secondary = { "Really black" }
			end
		end
	})	local statusParagraph2 = tab:CreateParagraph({
		Title = "Status",
		Content = "Waiting..."
	})	tab:CreateButton({
		Name = "Start Spin",
		Callback = function() -- line: 4140
			-- upvalues: seen (ref), self (copy), LocalPlayer (ref), ReplicatedStorage (copy), isColorPairMatch (ref), cache2 (copy), primary (ref), secondary (ref), same (ref), anyTwoSame (ref), statusParagraph2 (copy), clickShopIndicator (copy), scheduleSpinRetry (ref), notify (ref), notifySpinResult (ref)
			if seen then
				return
			end			seen = true
			self.spawn(function() -- line: 4146
				-- upvalues: LocalPlayer (ref), ReplicatedStorage (copy), isColorPairMatch (ref), cache2 (copy), primary (ref), secondary (ref), same (ref), anyTwoSame (ref), statusParagraph2 (copy), clickShopIndicator (copy), self (copy), seen (ref), scheduleSpinRetry (ref), notify (ref), notifySpinResult (ref)
				local Customization = LocalPlayer:WaitForChild("PlayerFolder"):WaitForChild("Customization")
				local WeaponPrimaryColor = Customization:WaitForChild("WeaponPrimaryColor")
				local WeaponSecondaryColor = Customization:WaitForChild("WeaponSecondaryColor")
				local Remotes = ReplicatedStorage:WaitForChild("Remotes")
				local TeamValue = LocalPlayer.PlayerFolder.Customization.Team.Value
				local randomizeColor = TeamValue == "CCG" and Remotes:WaitForChild("CCGLab"):WaitForChild("RandomizeColor") or Remotes:WaitForChild("KakuhouSurgeon"):WaitForChild("RandomizeColor")				local function buildCurrentSwatch() -- line: 4154
					-- upvalues: isColorPairMatch (ref), WeaponPrimaryColor (copy), WeaponSecondaryColor (copy), cache2 (copy), primary (ref), secondary (ref), same (ref), anyTwoSame (ref)
					return isColorPairMatch(WeaponPrimaryColor.Value, WeaponSecondaryColor.Value, cache2.SpinWinCondition or "Primary AND Secondary", primary, secondary, same, anyTwoSame)
				end				if statusParagraph2 then
					pcall(statusParagraph2.Set, statusParagraph2, {
						Title = "Status",
						Content = "Spinning..."
					})
				end				clickShopIndicator(TeamValue)
				self.wait(0.5)				local attempts = 0				while seen and not buildCurrentSwatch() do
					local WeaponPrimaryColorValue = WeaponPrimaryColor.Value
					local WeaponSecondaryColorValue = WeaponSecondaryColor.Value					randomizeColor:InvokeServer("Standard")
					self.wait(0.5)					local WeaponPrimaryColorValue4 = WeaponPrimaryColor.Value
					local WeaponSecondaryColorValue4 = WeaponSecondaryColor.Value					if WeaponPrimaryColorValue4 ~= WeaponPrimaryColorValue or WeaponSecondaryColorValue4 ~= WeaponSecondaryColorValue then
						attempts += 1						if statusParagraph2 then
							pcall(statusParagraph2.Set, statusParagraph2, {
								Title = "Status",
								Content = string.format("Attempt %d\nP: %s\nS: %s", attempts, WeaponPrimaryColorValue4, WeaponSecondaryColorValue4)
							})
						end						if not buildCurrentSwatch() then
							scheduleSpinRetry({
								kind = "notfound",
								primary = WeaponPrimaryColorValue4,
								secondary = WeaponSecondaryColorValue4,
								attempts = attempts
							})
						end
					end
				end				seen = false				if buildCurrentSwatch() then
					if statusParagraph2 then
						pcall(statusParagraph2.Set, statusParagraph2, {
							Title = "Status",
							Content = "Found in " .. attempts .. " attempts!"
						})
					end					notify({
						Title = "Spin",
						Duration = 5,
						Content = "Color found in " .. attempts .. " attempts!"
					})
					notifySpinResult({
						kind = "found",
						primary = WeaponPrimaryColor.Value,
						secondary = WeaponSecondaryColor.Value,
						attempts = attempts
					})					return
				end				if statusParagraph2 then
					pcall(statusParagraph2.Set, statusParagraph2, {
						Title = "Status",
						Content = "Stopped."
					})
				end				notifySpinResult({
					kind = "notfound",
					reason = "stopped manually",
					primary = WeaponPrimaryColor.Value,
					secondary = WeaponSecondaryColor.Value,
					attempts = attempts
				})
			end)
		end
	})
	tab:CreateButton({
		Name = "Stop Spin",
		Callback = function() -- line: 4218
			-- upvalues: seen (ref), statusParagraph2 (copy)
			seen = false			if statusParagraph2 then
				pcall(statusParagraph2.Set, statusParagraph2, {
					Title = "Status",
					Content = "Stopped."
				})
			end
		end
	})
	tab:CreateSection("Infinite Spin", "Right", "refresh-cw")	local infiniteSpinParagraph = tab:CreateParagraph({
		Title = "Infinite Spin",
		Content = "Disabled"
	})	genv._cthInfiniteSpinStatus = infiniteSpinParagraph
	cache3.InfiniteSpinToggle = tab:CreateToggle({
		Name = "Infinite Spin",
		CurrentValue = false,
		Flag = "InfiniteSpinToggle",
		Callback = function(arg) -- line: 4235
			-- upvalues: found2 (ref), found3 (ref), notify (ref), cache3 (copy), str2 (ref), found11 (ref), infiniteSpinParagraph (copy), team (ref), primary (ref), secondary (ref), same (ref), cache2 (copy), anyTwoSame (ref), saveInfiniteSpinState (ref), self (copy), runInfiniteSpin (ref)
			found2 = arg			if arg then
				if not found3 then
					notify({
						Title = "Infinite Spin",
						Content = "Enable DataLoss first!",
						Duration = 5
					})
					found2 = false
					cache3.InfiniteSpinToggle:Set(false)					return
				end				if not str2 or str2 == "Disabled" then
					notify({
						Title = "Infinite Spin",
						Content = "Select a team in Auto Team first!",
						Duration = 5
					})
					found2 = false
					cache3.InfiniteSpinToggle:Set(false)					return
				end				if found11 then
					return
				end				infiniteSpinParagraph:Set({
					Title = "Infinite Spin",
					Content = "Starting..."
				})				local tbl7 = {
					enabled = true,
					attempts = 0,
					rejoins = 0,
					team = team or "CCG",
					targetPrimary = primary,
					targetSecondary = secondary,
					targetSame = same,
					winCondition = cache2.SpinWinCondition or "Primary AND Secondary",
					anyTwoSame = anyTwoSame or false,
					startedAt = os.time()
				}				saveInfiniteSpinState(tbl7)
				self.spawn(function() -- line: 4273
					-- upvalues: runInfiniteSpin (ref), tbl7 (copy)
					runInfiniteSpin(tbl7)
				end)				return
			end			saveInfiniteSpinState(nil)
			infiniteSpinParagraph:Set({
				Title = "Infinite Spin",
				Content = "Disabled"
			})
		end
	})
	tab:CreateSection("DataLoss", "Right", "database")	local dataLossStatusParagraph = tab:CreateParagraph({
		Title = "DataLoss Status",
		Content = "Disabled"
	})	genv._cthDatalossStatus = dataLossStatusParagraph	local SpawnSelection = game:GetService("ReplicatedStorage").Remotes.Settings:WaitForChild("SpawnSelection")	tab:CreateButton({
		Name = "DataLoss",
		Callback = function() -- line: 4290
			-- upvalues: SpawnSelection (copy), found3 (ref), dataLossStatusParagraph (copy), notify (ref)
			pcall(function() -- line: 4291
				-- upvalues: SpawnSelection (copy), found3 (ref), dataLossStatusParagraph (copy), notify (ref)
				SpawnSelection:FireServer("\128\129\200\201")
				found3 = true
				dataLossStatusParagraph:Set({
					Title = "DataLoss Status",
					Content = "Enable"
				})
				notify({
					Title = "DataLoss",
					Content = "Enabled! Buy what you want then rejoin.",
					Duration = 5
				})
			end)
		end
	})
	tab:CreateButton({
		Name = "UnDataLoss",
		Callback = function() -- line: 4302
			-- upvalues: SpawnSelection (copy), found3 (ref), dataLossStatusParagraph (copy), notify (ref)
			pcall(function() -- line: 4303
				-- upvalues: SpawnSelection (copy), found3 (ref), dataLossStatusParagraph (copy), notify (ref)
				SpawnSelection:FireServer("")
				found3 = false
				dataLossStatusParagraph:Set({
					Title = "DataLoss Status",
					Content = "Disable"
				})
				notify({
					Title = "DataLoss",
					Content = "Disabled. Purchases will be saved.",
					Duration = 5
				})
			end)
		end
	})
	tab:CreateSection("Webhook", "Right", "webhook")	local TextBox	local function updateText() -- line: 4315
		-- upvalues: TextBox (ref), getText (copy), spinWebhookUrl (ref)
		if not TextBox then
			return
		end		TextBox.Text = getText(spinWebhookUrl) and "✓ Webhook linked  (…" .. spinWebhookUrl:sub(-5) .. ")" or ""
	end	local discordWebhookUrlInput = tab:CreateInput({
		Name = "Discord Webhook URL",
		PlaceholderText = "Paste your webhook URL",
		Flag = "SpinWebhookURL",
		CurrentValue = spinWebhookUrl,
		Callback = function(arg) -- line: 4327
			-- upvalues: spinWebhookUrl (ref), self (copy), updateText (copy), getText (copy), notify (ref), handleName (copy)
			local match = (arg or ""):match("^%s*(.-)%s*$")			if match == spinWebhookUrl then
				self.defer(updateText)				return
			end			if match ~= "" and not getText(match) then
				notify({
					Title = "Webhook",
					Content = "Invalid Discord webhook URL.",
					Duration = 4
				})
			else
				spinWebhookUrl = match
				handleName("spinWebhookUrl", match)
				notify({
					Title = "Webhook",
					Duration = 3,
					Content = match ~= "" and "Webhook linked!" or "Webhook removed."
				})
			end			self.defer(updateText)
		end
	})	TextBox = discordWebhookUrlInput.Raw.Holder:FindFirstChildOfClass("TextBox")
	TextBox.TextScaled = false
	TextBox.TextSize = 14
	TextBox.TextTruncate = Enum.TextTruncate.AtEnd
	TextBox.ClearTextOnFocus = true
	TextBox.FocusLost:Connect(function(enterPressed) -- line: 4357
		-- upvalues: TextBox (ref), getText (copy), discordWebhookUrlInput (copy), self (copy), updateText (copy)
		local match = TextBox.Text:match("^%s*(.-)%s*$")		if not enterPressed and getText(match) then
			discordWebhookUrlInput.Raw:SetValue(match)
		end		self.defer(updateText)
	end)
	updateText()
	tab:CreateToggle({
		Name = "Send webhook",
		Flag = "SpinWebhookEnabled",
		CurrentValue = currentValue3,
		Callback = function(arg) -- line: 4373
			-- upvalues: currentValue3 (ref), handleName (copy)
			currentValue3 = arg
			handleName("spinWebhookEnabled", arg)
		end
	})
	tab:CreateToggle({
		Name = "Send when not found",
		Flag = "SpinWebhookMisses",
		CurrentValue = currentValue4,
		Callback = function(arg) -- line: 4383
			-- upvalues: currentValue4 (ref), handleName (copy)
			currentValue4 = arg
			handleName("spinWebhookMisses", arg)
		end
	})
end)(41493407, 73320084);
(function() -- line: 4392
	-- upvalues: tbl5 (copy), HttpService (copy), str2 (ref), cache2 (copy), handleName (copy), self (copy), team (ref), pressClickDetector (ref), findPath (copy), notify (ref), getRemotes (copy), flag (ref)
	local tab = tbl5:CreateTab("Misc", "layers")	tab:CreateSection("Auto Team", "Left", "users")
	pcall(function() -- line: 4396
		-- upvalues: HttpService (copy), str2 (ref)
		if isfile("CTH/settings.json") then
			local ok, result = pcall(function() -- line: 4398
				-- upvalues: HttpService (copy)
				return HttpService:JSONDecode(readfile("CTH/settings.json"))
			end)			if ok and result and result.autoTeam then
				str2 = result.autoTeam
			end
		end
	end)
	tab:CreateDropdown({
		Name = "Team",
		Flag = "AutoTeam",
		Options = { "Disabled", "CCG", "Ghoul" },
		CurrentOption = { str2 },
		Callback = function(arg) -- line: 4413
			-- upvalues: str2 (ref), cache2 (copy), handleName (copy)
			local item = arg[1] or "Disabled"			str2 = item
			cache2.AutoTeam = item
			handleName("autoTeam", item)
		end
	})
	self.spawn(function() -- line: 4421
		-- upvalues: self (copy), team (ref), tab (copy), pressClickDetector (ref), findPath (copy)
		repeat
			self.wait(0.5)
		until team		if team == "CCG" then
			tab:CreateSection("CCG Menus", "Right", "store")
			tab:CreateButton({
				Name = "Weapon Shop",
				Callback = function() -- line: 4431
					-- upvalues: pressClickDetector (ref), findPath (copy)
					pressClickDetector(findPath(workspace, "CCGLab", "Drawer", "ShopIndicator", "ClickDetector"))
				end
			})
			tab:CreateButton({
				Name = "Quinx Shop",
				Callback = function() -- line: 4438
					-- upvalues: pressClickDetector (ref), findPath (copy)
					pressClickDetector(findPath(workspace, "CCGLab", "UpperFloor", "Joint", "Model", "Indicator", "ClickDetector"))
				end
			})
			tab:CreateButton({
				Name = "Arata Shop",
				Callback = function() -- line: 4445
					-- upvalues: pressClickDetector (ref), findPath (copy)
					pressClickDetector(findPath(workspace, "CCGLab", "Chigyou", "Indicator", "ClickDetector"))
				end
			})
		else
			tab:CreateSection("Ghoul Menus", "Right", "store")
			tab:CreateButton({
				Name = "Kagune Shop",
				Callback = function() -- line: 4454
					-- upvalues: pressClickDetector (ref), findPath (copy)
					pressClickDetector(findPath(workspace, "KakuhouSurgeonWarehouse", "Kakuhou Surgeon", "SurgeonIndicator", "ClickDetector"))
				end
			})
			tab:CreateButton({
				Name = "Specials Shop",
				Callback = function() -- line: 4461
					-- upvalues: pressClickDetector (ref), findPath (copy)
					pressClickDetector(findPath(workspace, "MisterBuilding", "Mister", "MisterIndicator", "ClickDetector"))
				end
			})
		end		tab:CreateButton({
			Name = "Mask Shop",
			Callback = function() -- line: 4469
				-- upvalues: pressClickDetector (ref), findPath (copy)
				pressClickDetector(findPath(workspace, "UtaMaskShop", "ShopIndicator", "ClickDetector"))
			end
		})
		tab:CreateSection("Weapon", "Left", "sword")
		tab:CreateButton({
			Name = "Switch Weapon",
			Callback = function() -- line: 4478
				-- upvalues: pressClickDetector (ref), findPath (copy)
				pressClickDetector(findPath(workspace, "WepStorage", "ShopIndicator", "ClickDetector"))
			end
		})
		tab:CreateSection("Arena", "Left", "trophy")
		tab:CreateButton({
			Name = "Go to Arena",
			Callback = function() -- line: 4487
				-- upvalues: pressClickDetector (ref), findPath (copy)
				pressClickDetector(findPath(workspace, "YamoriTowerOutside", "Door", "ClickDetector"))
			end
		})
	end)
	self.spawn(function() -- line: 4493
		-- upvalues: self (copy), team (ref), tab (copy), notify (ref), getRemotes (copy), findPath (copy)
		repeat
			self.wait(0.5)
		until team		tab:CreateSection("Codes", "Left", "ticket")
		tab:CreateButton({
			Name = "Redeem All Codes",
			Callback = function() -- line: 4502
				-- upvalues: self (copy), notify (ref), getRemotes (copy), findPath (copy)
				self.spawn(function() -- line: 4503
					-- upvalues: notify (ref), getRemotes (copy), findPath (copy), self (copy)
					local ok, result = pcall(function() -- line: 4504
						return game:HttpGet("https://pastebin.com/raw/ZUpJcpAG", true)
					end)					if not ok or (not result or result == "") then
						notify({
							Title = "Codes",
							Content = "Failed to fetch codes!",
							Duration = 3
						})						return
					end					local list2 = {}					for match in result:gmatch("[^\n\r]+") do
						local match2 = match:match("^%s*(.-)%s*$")						if match2 and match2 ~= "" then
							table.insert(list2, match2)
						end
					end					local count = 0					for _, v in ipairs(list2) do
						pcall(function() -- line: 4525
							-- upvalues: getRemotes (copy), findPath (copy), v (copy)
							local remotes2 = getRemotes()
							local code = remotes2 and findPath(remotes2, "Code")							if code then
								code:InvokeServer("Submit Code", v)
							end
						end)
						count += 1
						self.wait(0.5)
					end					notify({
						Title = "Codes",
						Duration = 3,
						Content = "Redeemed " .. count .. " code(s)!"
					})
				end)
			end
		})
	end)
	self.spawn(function() -- line: 4544
		-- upvalues: self (copy), team (ref), tab (copy), flag (ref), cache2 (copy)
		repeat
			self.wait(0.5)
		until team		tab:CreateSection("Debug", "Right", "bug")
		tab:CreateToggle({
			Name = "Debug Mode",
			CurrentValue = false,
			Flag = "DebugMode",
			Callback = function(debugMode) -- line: 4555
				-- upvalues: flag (ref), cache2 (copy)
				flag = debugMode
				cache2.DebugMode = debugMode
			end
		})
	end)
end)();
(function() -- line: 4565
	-- upvalues: cthLoading (copy), tbl5 (copy), lib (ref), tbl (copy), lib2 (copy), lib3 (copy), tbl3 (copy), self (copy), team (ref), LocalPlayer (ref), statsFunction (ref), flag (ref), findPath (copy), getConnection (copy), flag6 (ref), flag7 (ref), getPlayerStatValue (copy), found10 (ref), flag5 (ref), remotes (ref), n2 (ref), found9 (ref), found8 (ref), found (ref), found7 (ref), tween2 (ref), connection (ref), getReputationTarget (ref), cache2 (copy), ReplicatedStorage (copy), flag15 (ref), statusParagraph (ref), getHumanoidRootPart (ref), isCharacterAlive (ref)
	cthLoading:SetDescription("Loading configs...")
	cthLoading:SetCurrentStep(3)	local tab = tbl5.Raw:AddTab("Settings", "settings")	tab:AddGroupbox({
		Side = "Left",
		Name = "Menu",
		IconName = "wrench"
	}):AddLabel("Menu keybind"):AddKeyPicker("MenuKeybind", {
		Default = "RightShift",
		NoUI = true,
		Text = "Menu keybind"
	});
	(nil):AddButton({
		Text = "Unload",
		Risky = true,
		Func = function() -- line: 4575
			-- upvalues: lib (ref)
			lib:Unload()
		end
	})
	lib.ToggleKeybind = lib.Options.MenuKeybind
	lib:OnUnload(tbl.destroy)
	lib2:SetLibrary(lib)
	lib3:SetLibrary(lib)
	lib3:IgnoreThemeSettings()
	lib3:SetIgnoreIndexes({ "MenuKeybind" })
	lib2:SetFolder("CTH")
	lib3:SetFolder("CTH/Ro-Ghoul")
	lib2:SetDefaultTheme(tbl3)
	lib3:BuildConfigSection(tab)
	lib2:ApplyToTab(tab)
	cthLoading:SetDescription("Ready")
	cthLoading:SetCurrentStep(4)
	self.delay(0.4, function() -- line: 4594
		-- upvalues: cthLoading (copy)
		cthLoading:Destroy()
	end)
	self.spawn(function() -- line: 4598
		-- upvalues: self (copy), team (ref), lib3 (copy)
		repeat
			self.wait(0.5)
		until team		self.wait(1)
		lib3:LoadAutoloadConfig()
	end)
	self.spawn(function() -- line: 4607
		-- upvalues: self (copy), LocalPlayer (ref), statsFunction (ref), flag (ref), findPath (copy), getConnection (copy), flag6 (ref), flag7 (ref), getPlayerStatValue (copy)
		repeat
			self.wait(0.5)
		until LocalPlayer:FindFirstChild("PlayerFolder")		statsFunction = LocalPlayer.PlayerFolder:WaitForChild("StatsFunction", 10)		if flag then
			print("-> StatFunc : " .. tostring(statsFunction))
		end		local focus = findPath(LocalPlayer.PlayerFolder.Stats, "Focus")		if not focus then
			return
		end		getConnection(focus.Changed, function(arg) -- line: 4623
			-- upvalues: statsFunction (ref), findPath (copy), LocalPlayer (ref), flag6 (ref), flag7 (ref), focus (copy), getPlayerStatValue (copy), self (copy)
			if (tonumber(arg) or 0) <= 0 then
				return
			end			if not statsFunction then
				statsFunction = findPath(LocalPlayer.PlayerFolder, "StatsFunction")				if not statsFunction then
					return
				end
			end			while ((if not flag6 then flag7 else flag6)) and (tonumber(focus.Value) or 0) > 0 do
				local found11 = false				if flag6 then
					getPlayerStatValue("Weapon")
					pcall(function() -- line: 4648
						-- upvalues: statsFunction (ref)
						if statsFunction then
							statsFunction:InvokeServer("Focus", "WeaponAddButton", 1)
						end
					end)
					found11 = true
				end				if flag7 then
					getPlayerStatValue("Durability")
					pcall(function() -- line: 4660
						-- upvalues: statsFunction (ref)
						if statsFunction then
							statsFunction:InvokeServer("Focus", "DurabilityAddButton", 1)
						end
					end)
					found11 = true
				end				if not found11 then
					return
				end				self.wait()
			end
		end)
	end)
	self.spawn(function() -- line: 4680
		-- upvalues: found10 (ref), self (copy), flag5 (ref), remotes (ref), team (ref), n2 (ref), flag (ref), found9 (ref), found8 (ref), found (ref), found7 (ref), tween2 (ref), connection (ref), getReputationTarget (ref), cache2 (copy)
		while found10 do
			self.wait(60)			if flag5 and remotes and team and not (tick() - n2 < 7200) then
				if flag then
					print("-> rep auto : recup apres 2h")
				end				repeat
					self.wait(0.5)
				until not found9 and not found8				local found11 = found				found7 = true
				found = false				if tween2 then
					tween2:Cancel()
				end				if connection then
					connection:Disconnect()
					connection = nil
				end				self.wait(0.5)				if getReputationTarget() and remotes and remotes.ReputationCashOut then
					remotes.ReputationCashOut:InvokeServer()
					n2 = tick()					if flag then
						print("-> recup fini")
					end
				end				found7 = false				if found11 and cache2.AutoFarmMobs then
					found = true
				end
			end
		end
	end)
	self.spawn(function() -- line: 4728
		-- upvalues: ReplicatedStorage (copy), LocalPlayer (ref), self (copy), flag15 (ref), getConnection (copy), flag6 (ref), flag7 (ref), statusParagraph (ref), getHumanoidRootPart (ref), isCharacterAlive (ref), findPath (copy)
		local InvokeServer = Instance.new("RemoteFunction").InvokeServer
		local FireServer = Instance.new("RemoteEvent").FireServer
		local Remotes = ReplicatedStorage:WaitForChild("Remotes")
		local TeamValue = LocalPlayer.PlayerFolder.Customization.Team.Value
		local connection2		while true do
			self.wait(1)			if flag15 then
				if connection2 and connection2.Connected then
					connection2:Disconnect()
				end				local cell				connection2 = getConnection(LocalPlayer.Backpack.DescendantAdded, function(stringValue) -- line: 4745
					-- upvalues: cell (ref)
					if tostring(stringValue) == "TSCodeVal" and stringValue:IsA("StringValue") then
						cell = stringValue.Value
					end
				end)				local v2 = InvokeServer(Remotes.Trainers.RequestTraining)				if v2 == "TRAINING" then
					local flag6_2 = flag6
					local flag7_2 = flag7					flag6 = false
					flag7 = false					local PlayerFolder = LocalPlayer.PlayerFolder
					local Value = PlayerFolder.Trainers[TeamValue .. "Trainer"].Value
					local n3 = tonumber(PlayerFolder.Trainers[Value].Progress.Value) or 0					if statusParagraph then
						local statusParagraph2 = statusParagraph						pcall(statusParagraph.Set, statusParagraph2, {
							Title = "Status",
							Content = Value .. " — " .. n3 .. "%"
						})
					end					for _, child in pairs(workspace.TrainingSessions:GetChildren()) do
						if child:WaitForChild("Player").Value == LocalPlayer then
							FireServer(child:WaitForChild("Comm"), "Finished", cell, false)							break
						end
					end					self.wait(0.3)
					pcall(function() -- line: 4776
						-- upvalues: getHumanoidRootPart (ref)
						local humanoidRootPart = getHumanoidRootPart()						if humanoidRootPart then
							humanoidRootPart.CFrame = CFrame.new(0, 100, 0)
						end
					end)
					self.spawn(function() -- line: 4784
						-- upvalues: self (copy), LocalPlayer (ref)
						local deadline = tick() + 5						repeat
							self.wait(0.3)
							pcall(function() -- line: 4790
								-- upvalues: LocalPlayer (ref)
								for _, child in pairs(LocalPlayer.PlayerGui:GetChildren()) do
									if child.Name == "TrainersGui" or child.Name == "TrainingGui" then
										child:Destroy()
									end
								end
							end)
						until deadline < tick()
					end)
					self.spawn(function() -- line: 4800
						-- upvalues: self (copy), isCharacterAlive (ref), flag6 (ref), flag6_2 (copy), flag7 (ref), flag7_2 (copy)
						repeat
							self.wait(0.5)
						until isCharacterAlive()						self.wait(1)
						flag6 = flag6_2
						flag7 = flag7_2
					end)
				elseif v2 == "TRAINING COMPLETE" then
					if statusParagraph then
						local statusParagraph2 = statusParagraph						pcall(statusParagraph.Set, statusParagraph2, {
							Title = "Status",
							Content = "Trainer complete, switching..."
						})
					end					self.wait(3)					local PlayerFolder = LocalPlayer.PlayerFolder
					local Value = PlayerFolder.Trainers[TeamValue .. "Trainer"].Value
					local list2 = TeamValue == "CCG" and {
						"(S1) Koutarou Amon",
						"(S1) Kureo Mado",
						"(Suit) Yukinori Shinohara",
						"(Battle) Yukinori Shinohara",
						"(Arata) Yukinori Shinohara",
						"(S1) Hideyoshi Nagachika",
						"(S1) Juuzou Suzuya",
						"(Battle) Koutarou Amon",
						"(Battle) Juuzou Suzuya"
					} or {
						"(S1) Renji Yomo",
						"(S1) Ken Kaneki",
						"(S1) Touka Kirishima",
						"(S1) Nishiki Nishio",
						"(Battle) Yukinori Shinohara",
						"(S1) Shuu Tsukiyama",
						"(S1) Kuzen Yoshimura",
						"(Arata) Yukinori Shinohara",
						"(S1) Rize Kamishiro",
						"(S1) Yakumo Oomori",
						"(Tortured) Ken Kaneki"
					}					for _, v in ipairs(list2) do
						if v == Value then
							continue
						end						local v3 = findPath(PlayerFolder.Trainers, v)						if v3 and findPath(v3, "Progress") and (tonumber(v3.Progress.Value) or 0) < 100 then
							InvokeServer(Remotes.Trainers.ChangeTrainer, v)
							self.wait(1.5)							break
						end
					end
				elseif statusParagraph then
					local statusParagraph2 = statusParagraph					pcall(statusParagraph.Set, statusParagraph2, {
						Title = "Status",
						Content = "Next training: " .. tostring(v2)
					})
				end
			end
		end
	end)
end)()local function findObjectiveButton(arg) -- line: 4872
	-- upvalues: findPath (copy), LocalPlayer (ref)
	local hud = findPath(LocalPlayer.PlayerGui, "HUD", "ObjectivesButton", "Frame", "SF")	if not hud then
		return nil
	end	local button = findPath(hud, tostring(arg))	return button and (not not button:IsA("TextButton") and button) or nil
end
local function getText(arg) -- line: 4881
	-- upvalues: findObjectiveButton (copy)
	local v = findObjectiveButton(arg)	return v and v.Text or nil
end
local function isObjectiveComplete(arg) -- line: 4886
	-- upvalues: getText (copy)
	local text = getText(arg)	if not text then
		return false
	end	local match, v = text:match("(%d+)/(%d+)")	if match and v then
		return tonumber(match) >= tonumber(v)
	end	return false
end
local function isObjectiveIncomplete(arg) -- line: 4898
	-- upvalues: getText (copy)
	local text = getText(arg)	if not text then
		return false
	end	local match, v = text:match("(%d+)/(%d+)")	if match and v then
		return tonumber(match) < tonumber(v)
	end	return false
endlocal list2 = { 7, 8, 14, 15 }local function getOk(arg) -- line: 4912
	-- upvalues: getRemotes (copy)
	return pcall(function() -- line: 4913
		-- upvalues: getRemotes (copy), arg (copy)
		local remotes2 = getRemotes("Objectives")		if remotes2 then
			remotes2:InvokeServer("Claim", arg)
		end
	end)
end
local function getTeamAllowedRanks(arg) -- line: 4922
	-- upvalues: team (ref), list2 (copy), isObjectiveIncomplete (copy)
	local flag16 = team == "CCG"
	local list3 = if not flag16 then not (arg ~= 8 and arg ~= 15) and { "Athlete" } or { "Human" } else {
		"Ghoul",
		"Weak Ghoul"
	}	for _, v in ipairs(list2) do
		if v ~= arg and isObjectiveIncomplete(v) then
			if flag16 then
				table.insert(list3, "Human")
				table.insert(list3, "Athlete")				return list3
			end			table.insert(list3, "Ghoul")
			table.insert(list3, "Weak Ghoul")			return list3
		end
	end	return list3
end
local function hasAnyPlayerInStage(arg) -- line: 4943
	-- upvalues: findObjectiveButton (copy)
	return findObjectiveButton(arg) ~= nil
end
local function scanAndRecoverObjects() -- line: 4947
	-- upvalues: getLevelValue (copy), flag4 (ref), isObjectiveComplete (copy), hasAnyPlayerInStage (copy), isObjectiveIncomplete (copy), flag (ref), getOk (copy), self (copy)
	local n3 = getLevelValue()	for i = 1, 23 do
		if (not flag4 or not (n3 < 830)) and (isObjectiveComplete(i) or hasAnyPlayerInStage(i) and not isObjectiveIncomplete(i)) then
			if flag then
				print("-> recup obj " .. i .. "...")
			end			getOk(i)			if flag then
				print("-> obj " .. i .. " recupere !")
			end			self.wait(0.3)
		end
	end
end
local function buildRankNameList(arg, arg2) -- line: 4969
	-- upvalues: getHumanoidRootPart (ref), getLevelValue (copy), list (copy), isObjectiveIncomplete (copy), team (ref), getNearbyTargets (copy)
	if not getHumanoidRootPart() then
		return nil
	end	if not workspace:FindFirstChild("NPCSpawns") then
		return nil
	end	local list3	if arg2 then
		local n3 = getLevelValue()
		local cache4 = {}		for _, v in ipairs(list) do
			cache4[v.name] = v.minLevel
		end		list3 = {}		for _, v in ipairs(arg) do
			if not cache4[v] or n3 >= cache4[v] then
				table.insert(list3, v)
			end
		end		if #list3 == 0 then
			return nil
		end
	else
		list3 = arg
	end	local flag16 = not isObjectiveIncomplete(7) and (not isObjectiveIncomplete(8) and (not isObjectiveIncomplete(14) and not isObjectiveIncomplete(15)))
	local v2 = if team ~= "CCG" then if not flag16 then {
		"Ghoul",
		"Weak Ghoul",
		"Rank 2 Investigator",
		"Rank 1 Investigator",
		"First Class Investigator"
	} else {
		"Rank 2 Investigator",
		"Rank 1 Investigator",
		"First Class Investigator"
	} else if not flag16 then {
		"Human",
		"Athlete",
		"Low Rank Aogiri Member",
		"Mid Rank Aogiri Member",
		"High Rank Aogiri Member"
	} else {
		"Low Rank Aogiri Member",
		"Mid Rank Aogiri Member",
		"High Rank Aogiri Member"
	}
	local list4 = {}
	local found11 = false	for _, v in ipairs(list3) do
		if table.find(v2, v) then
			found11 = true
		else
			table.insert(list4, v)
		end
	end	local function pickFirstMatch(_, _, arg3) -- line: 5023
		-- upvalues: getNearbyTargets (copy)
		return getNearbyTargets(arg3, 1, true)[1]
	end	if #list4 > 0 then
		local result = pickFirstMatch(374234210, 236510909, list4)		if result then
			return result
		end
	end	if found11 then
		return (pickFirstMatch(27517408, 236510909, v2))
	end	return nil
endlocal list3 = { "Low Rank Aogiri Member", "Mid Rank Aogiri Member", "High Rank Aogiri Member" }
local list4 = { "Rank 2 Investigator", "Rank 1 Investigator", "First Class Investigator" }
local tbl6 = {
	[9] = 1,
	[10] = 2,
	[11] = 3,
	[16] = 1,
	[17] = 2,
	[18] = 3
}
local tbl7 = {
	[12] = { "Fighter", "CEO" },
	[13] = { "Fighter", "CEO" },
	[19] = { "Touka Kirishima" },
	[20] = { "Nishiki Nishio" },
	[21] = { "Fighter", "CEO" },
	[22] = { "Koutarou Amon" }
}local function getStageGroupByIndex(n3, arg) -- line: 5053
	-- upvalues: list3 (copy), list4 (copy), tbl6 (copy), isObjectiveIncomplete (copy)
	local list3_2 = arg and list3 or list4
	local item = tbl6[n3]	if not item then
		return nil
	end	local list5 = { list3_2[item] }
	local flag16 = n3 <= 11	for k, v in pairs(tbl6) do
		if (flag16 and k <= 11 or not flag16 and k >= 16) and (k ~= n3 and isObjectiveIncomplete(k)) then
			table.insert(list5, list3_2[v])
		end
	end	return list5
end
local function getRecoveryTargets(arg, arg2) -- line: 5071
	-- upvalues: getTeamAllowedRanks (copy), tbl6 (copy), getStageGroupByIndex (copy), tbl7 (copy), getLevelValue (copy)
	if arg == 7 or (arg == 8 or arg == 14 or arg == 15) then
		return getTeamAllowedRanks(arg), false
	end	if tbl6[arg] then
		return getStageGroupByIndex(arg, arg2), false
	end	local item = tbl7[arg]	if item then
		return item, true
	end	if arg == 23 then
		local n3 = getLevelValue()		if n3 >= 1250 then
			return { "Young Eto Yoshimura", "Eto Yoshimura" }, true
		end		if n3 >= 750 then
			return { "Young Eto Yoshimura" }, true
		end
	end	return nil, false
endself.spawn(function() -- line: 5098
	-- upvalues: found10 (ref), wait (copy), found (ref), flag3 (ref), flag8 (ref), isCharacterAlive (ref), tween2 (ref), self (copy), flag13 (ref), found7 (ref), found4 (ref), found6 (ref), team (ref), isObjectiveIncomplete (copy), getRecoveryTargets (copy), buildRankNameList (copy), pickBossTarget (copy), getTopTargets (copy), hasKaguneOrQuinque (ref), autoSpinTick (ref), getHumanoidRootPart (ref), isCachedTrue (copy), currentValue (ref), n (ref), items (copy), flag14 (ref), currentValue2 (ref), TweenService (copy), flag (ref), stopAutoFarm (copy), handleEnabled (ref), flag11 (ref), setAutoFarmActive (copy), setAutoFarmWhenIdle (copy), isObjectiveComplete (copy), getLevelValue (copy), flag4 (ref), getOk (copy), hasEnoughRC (ref), flag2 (ref), connection (ref), cashOutReputationIfReady (ref), cache2 (copy)
	local found11	while found10 do
		wait(0.5, 0.1)		if found or flag3 or flag8 then
			if not isCharacterAlive() then
				if tween2 then
					tween2:Cancel()
				end				while not isCharacterAlive() do
					self.wait(1)
				end				if flag13 then
					self.wait(2)
				end
			end			if not found7 and not found4 then
				while found6 do
					self.wait(0.5)
				end				local v
				local found12 = false
				local j				if flag3 then
					local flag16 = team == "CCG"					j = nil					for i = 7, 23 do
						if isObjectiveIncomplete(i) then
							local v2, v3 = getRecoveryTargets(i, flag16)							if not v2 then
								j = nil								continue
							end							local v4 = buildRankNameList(v2, v3)							if v4 then
								v = v4
								found12 = true
								j = i								break
							end							j = nil							continue
						end						j = nil
					end
				end				local tbl8 = {}				if not v and (found or flag8) then
					if flag8 then
						v = pickBossTarget()
					end					if not v and found then
						tbl8 = getTopTargets(4)
						v = table.remove(tbl8, 1)
					end
				end				if v then
					self.spawn(function() -- line: 5170
						-- upvalues: hasKaguneOrQuinque (ref), found4 (ref), autoSpinTick (ref)
						if not hasKaguneOrQuinque() and not found4 then
							autoSpinTick()
						end
					end)					while true do
						found11 = false						if not v then
							break
						end						local rootPosition = v.root.Position
						local humanoidRootPart = getHumanoidRootPart()						if not humanoidRootPart then
							found11 = true							break
						end						local Unit = (rootPosition - humanoidRootPart.Position).Unit
						local currentValue3 = isCachedTrue(v.name) and currentValue or n
						local n3 = rootPosition - Unit * if v.name ~= "Gyakusatsu" and not table.find(items, v.name) then currentValue3 else 3
						local vector = n3						if flag14 then
							vector = Vector3.new(n3.X, n3.Y - 50, n3.Z)
							humanoidRootPart.CFrame = CFrame.new(humanoidRootPart.Position.X, vector.Y, humanoidRootPart.Position.Z) * humanoidRootPart.CFrame.Rotation
						end						local vector3 = Vector3.new(rootPosition.X, vector.Y, rootPosition.Z)
						local Magnitude = (vector - humanoidRootPart.Position).Magnitude
						local found13 = false						if Magnitude > 2 then
							local n4 = math.max(Magnitude / currentValue2, 0.05)							if tween2 then
								tween2:Cancel()
							end							local tween = TweenService:Create(humanoidRootPart, TweenInfo.new(n4, Enum.EasingStyle.Linear), {
								CFrame = CFrame.new(vector, vector3)
							})							tween2 = tween
							tween:Play()							local flag16 = true							self.spawn(function() -- line: 5213
								-- upvalues: flag16 (ref), tween (ref), v (ref), flag (ref), found13 (ref), getHumanoidRootPart (ref), vector (ref), currentValue2 (ref), TweenService (copy), vector3 (copy), tween2 (ref), self (copy)
								local Position2
								local now								while flag16 and tween.PlaybackState == Enum.PlaybackState.Playing do
									if not v.humanoid or not v.humanoid.Parent or v.humanoid.Health <= 0 then
										if flag then
											print("-> Ennemi mort pendant le trajet, on change")
										end										tween:Cancel()
										found13 = true										return
									end									local humanoidRootPart2 = getHumanoidRootPart()									if humanoidRootPart2 then
										local Position = humanoidRootPart2.Position										if Position2 and (Position - Position2).Magnitude < 0.5 then
											now = now or tick()											if tick() - now >= 2 then
												if flag then
													print("-> bloquee 2s on reprends?")
												end												tween:Cancel()												local n5 = math.max((humanoidRootPart2.Position - vector).Magnitude / currentValue2, 0.05)												tween = TweenService:Create(humanoidRootPart2, TweenInfo.new(n5, Enum.EasingStyle.Linear), {
													CFrame = CFrame.new(vector, vector3)
												})
												tween2 = tween
												tween:Play()
												now = nil
												Position2 = Position
											else
												Position2 = Position
											end
										else
											now = nil
											Position2 = Position
										end
									end									self.wait(0.1)
								end
							end)							repeat
								self.wait()
							until found13 or tween.PlaybackState ~= Enum.PlaybackState.Playing							flag16 = false							if tween2 == tween then
								tween2 = nil
							end
						end						if not found13 then
							break
						end						local v2						repeat
							v2 = nil							if not (#tbl8 > 0) then
								break
							end							v2 = table.remove(tbl8, 1)
						until v2.humanoid and v2.humanoid.Parent and v2.humanoid.Health > 0						if not v2 then
							found11 = true							break
						end						v = v2
					end					if not found11 and (found or flag3 or flag8) then
						local flag16 = not v.humanoid or (not v.humanoid.Parent or v.humanoid.Health <= 0)						if not flag16 then
							local y2 = v.root and v.root.Position.Y or nil							stopAutoFarm(v, found12)							if flag14 and y2 then
								local humanoidRootPart = getHumanoidRootPart()								if humanoidRootPart then
									humanoidRootPart.CFrame = CFrame.new(humanoidRootPart.Position.X, y2, humanoidRootPart.Position.Z) * humanoidRootPart.CFrame.Rotation
								end
							end							handleEnabled(false)							if (not v.humanoid or (not v.humanoid.Parent or v.humanoid.Health <= 0)) and not flag11 and not table.find({
								"Eto Yoshimura",
								"Young Eto Yoshimura",
								"Gyakusatsu"
							}, v.name) then
								if found12 then
									setAutoFarmActive(v)
								else
									setAutoFarmWhenIdle(v)
								end
							end							if if not found then flag3 else found then
								handleEnabled(true)
							end							if found12 and j and isObjectiveComplete(j) then
								if flag then
									print("-> obj " .. j .. " termine recup de tout")
								end								local spawn = self.spawn								if type(flag16) == "userdata" then
								end								spawn(function() -- line: 5333
									-- upvalues: getLevelValue (copy), flag4 (ref), isObjectiveComplete (copy), getOk (copy), flag (ref), self (copy)
									local n3 = getLevelValue()									for i = 1, 23 do
										if (not flag4 or not (n3 < 830)) and isObjectiveComplete(i) then
											getOk(i)											if flag then
												print("-> obj " .. i .. " recup")
											end											self.wait(0.1)
										end
									end
								end)
							end							if not found12 then
								local ok, result = pcall(hasEnoughRC)								if not flag2 then
									ok = flag2
								end								if ok and result then
									if flag then
										print("-> debut de la rep auto apres le ramassage")
									end									found = false
									found7 = true									if connection then
										connection:Disconnect()
										connection = nil
									end									self.wait(0.3)
									cashOutReputationIfReady()
									self.wait(0.5)
									cashOutReputationIfReady()
									found7 = false									if cache2.AutoFarmMobs then
										found = true
									end
								end
							end
						end
					end
				end
			end
		end
	end
end)
self.spawn(function() -- line: 5394
	-- upvalues: found10 (ref), self (copy), flag3 (ref), scanAndRecoverObjects (copy), flag (ref), isObjectiveIncomplete (copy), getText (copy), cache3 (copy), cache2 (copy), tween2 (ref), connection (ref), handleEnabled (ref), notify (ref), team (ref), VirtualInputManager (copy), random (copy), remotes (ref), findPath (copy), clickShopIndicator (copy), pressClickDetector (ref), isObjectiveComplete (copy), getLevelValue (copy), flag4 (ref), getOk (copy)
	local flag16 = true
	local n3 = 0	while found10 do
		self.wait(1)		if not flag3 then
			flag16 = true
		else
			if flag16 then
				scanAndRecoverObjects()
				flag16 = false
			end			if tick() - n3 >= 600 then
				if flag then
					print("-> recup auto toutes 10min")
				end				scanAndRecoverObjects()
				n3 = tick()
			end			local flag17 = true			for i = 1, 23 do
				if isObjectiveIncomplete(i) then
					flag17 = false					break
				end
			end			if flag17 then
				local found11 = false				for i = 1, 23 do
					if getText(i) ~= nil then
						found11 = true						break
					end
				end				if found11 then
					if flag then
						print("-> tout obj fini")
					end					flag3 = false					if cache3.AutoObjectives then
						pcall(cache3.AutoObjectives.Set, cache3.AutoObjectives, false)
					end					cache2.AutoObjectives = false					if not cache2.AutoFarmMobs then
						if tween2 then
							tween2:Cancel()
						end						if connection then
							connection:Disconnect()
							connection = nil
						end						handleEnabled(false)
					end					notify({
						Title = "Auto Objectives",
						Content = "All objectives complete!",
						Duration = 4
					})
				end
			else
				local flag18 = team == "CCG"				for i = 1, 6 do
					if not flag3 then
						break
					end					if isObjectiveIncomplete(i) then
						if flag then
							print("-> obj instante " .. i .. "...")
						end						if i == 1 then
							VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.M, false, game)
							self.wait(random:NextNumber(0.04, 0.08))
							VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.M, false, game)
							self.wait(1)
						elseif i == 2 then
							VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.X, false, game)
							self.wait(random:NextNumber(0.04, 0.08))
							VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.X, false, game)
							self.wait(1)
						elseif i == 3 then
							VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.LeftControl, false, game)
							self.wait(random:NextNumber(0.04, 0.08))
							VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.LeftControl, false, game)
							pcall(function() -- line: 5490
								-- upvalues: remotes (ref), findPath (copy)
								local mouseCamLock = remotes and findPath(remotes, "MouseCamLock")								if mouseCamLock then
									mouseCamLock:FireServer()
								end
							end)
							self.wait(1)
						elseif i == 4 then
							clickShopIndicator(not flag18 and "Ghoul" or "CCG")
							self.wait(1)
						elseif i == 5 then
							if flag18 then
								pressClickDetector(findPath(workspace, "CCGBuilding", "Yoshitoki", "TaskIndicator", "ClickDetector"))
							else
								pressClickDetector(findPath(workspace, "Anteiku", "Yoshimura", "TaskIndicator", "ClickDetector"))
							end							self.wait(1)
						elseif i == 6 then
							pressClickDetector(findPath(workspace, "GyaSacTable", "GyaSacIndicator", "ClickDetector"))
							self.wait(1)
						end						if isObjectiveComplete(i) then
							local n4 = getLevelValue()							if not flag4 or n4 >= 830 then
								getOk(i)								if flag then
									print("-> obj " .. i .. " recup")
								end
							end
						end
					end
				end
			end
		end
	end
end)
self.spawn(function() -- line: 5539
	-- upvalues: findPath (copy), LocalPlayer (ref), self (copy), found10 (ref), flag12 (ref), flag9 (ref), found (ref), flag3 (ref), flag8 (ref), found4 (ref), found8 (ref), flag (ref), found9 (ref)
	local function isArataStaminaPresent() -- line: 5540
		-- upvalues: findPath (copy), LocalPlayer (ref)
		return findPath(LocalPlayer.PlayerGui, "ArataStamina") ~= nil
	end
	local function checkEnabled(enabled, _, _) -- line: 5544
		-- upvalues: isArataStaminaPresent (copy), self (copy)
		for _ = 1, 6 do
			if enabled == isArataStaminaPresent() then
				return true
			end			pcall(pressGameKey, "Zero")			local timestamp = tick()			repeat
				self.wait()
			until enabled == isArataStaminaPresent() or tick() - timestamp > 2.5
		end		return enabled == isArataStaminaPresent()
	end	local n3 = 0	while found10 do
		self.wait(0.5)		if flag12 and flag9 and ((found or flag3 or flag8) and not found4 and not found8 and not (tick() - n3 < 5)) then
			local arataStamina = findPath(LocalPlayer.PlayerGui, "ArataStamina")			if arataStamina then
				local back = findPath(arataStamina, "Back", "Main", "Bar")
				local scale = back and back.Size.X.Scale or nil				if scale ~= nil and scale <= 0.05 then
					if flag then
						print("-> Recharge : endurance pas la (" .. tostring(scale) .. "), recharge")
					end					repeat
						self.wait(0.3)
					until not found9 and not found8 and not found4					found4 = true
					checkEnabled(false, 509186844, 296729858)
					self.wait(2.5)					local v = checkEnabled(true, 509186844, 39825597)					self.wait(1)
					found4 = false
					n3 = tick()					if flag then
						print("-> Recharge : " .. (not v and "echec pour equiper Arata?????" or "Arata equipe de nouveau"))
					end
				end
			end
		end
	end
end)
getConnection(LocalPlayer.Idled, function() -- line: 5602
	-- upvalues: VirtualUser (copy)
	VirtualUser:CaptureController()
	VirtualUser:ClickButton2(Vector2.new())
end)
notify({
	Title = "CTHv1.5",
	Content = "Script loaded successfully!",
	Duration = 3
})if flag then
	print("--- CTHv1.5 | Combat auto charge ---")
end
