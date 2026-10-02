-- MYTHIC SEAS : one-command installer. Paste ALL of this into Studio's Command Bar (View > Command Bar) and press Enter.
do
local RS = game:GetService("ReplicatedStorage")
local SSS = game:GetService("ServerScriptService")
local SPS = game:GetService("StarterPlayer"):WaitForChild("StarterPlayerScripts")
local function fresh(parent, name)
	local o = parent:FindFirstChild(name)
	if o then o:Destroy() end
	return nil
end
local function mk(class, name, parent, src)
	local o = Instance.new(class)
	o.Name = name
	if src then o.Source = src end
	o.Parent = parent
	return o
end
fresh(RS, "Shared") fresh(RS, "Remotes") fresh(SSS, "Server") fresh(SPS, "Client")
local shared = mk("Folder", "Shared", RS)
local remotes = mk("Folder", "Remotes", RS)

for _, n in ipairs({"Notify", "Dialog", "BasicAttack", "UseAbility", "Cooldown", "Effect", "Sfx", "OpenShop", "OpenTravel", "TravelRequest", "BoatInput", "BoatState", "LevelUp"}) do mk("RemoteEvent", n, remotes) end
for _, n in ipairs({"ShopRequest"}) do mk("RemoteFunction", n, remotes) end
mk("ModuleScript", "Config", shared, [=====[
local Config = {}
Config.Start = { Level = 1, XP = 0, Coins = 250, Power = "Cinder", Weapon = "Cutlass" }
Config.MaxLevel = 100
Config.StaminaMax = 100
Config.StaminaRegen = 14
function Config.XPForLevel(level) -- XP needed to go from `level` to `level+1`
return math.floor(100 * level ^ 1.6)
end
function Config.MaxHealth(level) return 100 + (level - 1) * 8 end
function Config.ScaleDamage(base, level) return base * (1 + 0.04 * (level - 1)) end
Config.Islands = {
Haven    = { Name = "Driftwood Haven", Center = Vector3.new(0, 0, 0),     Radius = 200, Level = "1+" },
Ember    = { Name = "Emberreach",      Center = Vector3.new(780, 0, 0),   Radius = 230, Level = "5+" },
Moonveil = { Name = "Moonveil",        Center = Vector3.new(-780, 0, 0),  Radius = 230, Level = "9+" },
Frost    = { Name = "Frostmere",       Center = Vector3.new(0, 0, -780),  Radius = 230, Level = "12+" },
}
Config.IslandOrder = { "Haven", "Ember", "Moonveil", "Frost" }
Config.Weapons = {
{ Id = "Cutlass", Name = "Driftwood Cutlass", Price = 0,    Damage = 8,  Color = Color3.fromRGB(150, 150, 160) },
{ Id = "Steel",   Name = "Steel Sword",       Price = 150,  Damage = 14, Color = Color3.fromRGB(200, 205, 215) },
{ Id = "Coral",   Name = "Coral Blade",       Price = 600,  Damage = 24, Color = Color3.fromRGB(255, 120, 130) },
{ Id = "Ember",   Name = "Emberforged Saber", Price = 2000, Damage = 40, Color = Color3.fromRGB(255, 120, 30) },
{ Id = "Frost",   Name = "Frostbite Rapier",  Price = 5000, Damage = 62, Color = Color3.fromRGB(130, 220, 255) },
}
Config.MaxUpgrade = 5
function Config.GetWeapon(id)
for _, w in ipairs(Config.Weapons) do if w.Id == id then return w end end
end
function Config.UpgradeCost(w, lvl) return math.floor((w.Price * 0.35 + 100) * (lvl + 1)) end
function Config.WeaponDamage(id, upgrade)
local w = Config.GetWeapon(id) or Config.Weapons[1]
return w.Damage * (1 + 0.12 * (upgrade or 0))
end
Config.Powers = {
Cinder = {
Name = "Cinder Core", Price = 0, Color = Color3.fromRGB(255, 110, 30),
Desc = "Command embers and flame. Strong burst damage.",
Abilities = {
{ Id = "CinderPunch",  Name = "Cinder Punch",  Cooldown = 3,  Stamina = 8,  Damage = 28 },
{ Id = "FlameDash",    Name = "Flame Dash",    Cooldown = 6,  Stamina = 15, Damage = 32 },
{ Id = "BurningRing",  Name = "Burning Ring",  Cooldown = 9,  Stamina = 20, Damage = 36 },
{ Id = "MeteorBurst",  Name = "Meteor Burst",  Cooldown = 15, Stamina = 30, Damage = 80 },
{ Id = "InfernoCrown", Name = "Inferno Crown", Cooldown = 28, Stamina = 35, Damage = 10 },
},
},
Tide = {
Name = "Tide Core", Price = 1000, Color = Color3.fromRGB(60, 190, 255),
Desc = "Bend the sea itself. Control and crowd damage.",
Abilities = {
{ Id = "WaterSpear",     Name = "Water Spear",     Cooldown = 3,  Stamina = 8,  Damage = 34 },
{ Id = "WaveCrash",      Name = "Wave Crash",      Cooldown = 8,  Stamina = 18, Damage = 44 },
{ Id = "Whirlpool",      Name = "Whirlpool",       Cooldown = 14, Stamina = 25, Damage = 10 },
{ Id = "TidalPrison",    Name = "Tidal Prison",    Cooldown = 16, Stamina = 25, Damage = 14 },
{ Id = "LeviathanSurge", Name = "Leviathan Surge", Cooldown = 24, Stamina = 40, Damage = 130 },
},
},
}
Config.PowerOrder = { "Cinder", "Tide" }
Config.Enemies = {
Bandit       = { Name = "Driftwood Bandit", Level = 1,  Health = 70,   Damage = 7,  Speed = 12, Aggro = 45, Range = 5,  AttackCD = 1.4, XP = 18,  Coins = 10,  Respawn = 15 },
EmberRaider  = { Name = "Ember Raider",     Level = 5,  Health = 140,  Damage = 13, Speed = 14, Aggro = 50, Range = 6,  AttackCD = 1.3, XP = 45,  Coins = 28,  Respawn = 18 },
MoonBeast    = { Name = "Moonveil Beast",   Level = 9,  Health = 190,  Damage = 15, Speed = 17, Aggro = 55, Range = 6,  AttackCD = 1.1, XP = 60,  Coins = 36,  Respawn = 20 },
FrostGuardian= { Name = "Frost Guardian",   Level = 12, Health = 220,  Damage = 17, Speed = 12, Aggro = 60, Range = 6,  AttackCD = 1.5, XP = 75,  Coins = 44,  Respawn = 22, Ranged = true },
CinderWarden = { Name = "Cinder Warden",    Level = 20, Health = 3000, Damage = 32, Speed = 16, Aggro = 120, Range = 16, AttackCD = 2.0, XP = 1500, Coins = 1000, Respawn = 120, Boss = true, Element = "Fire" },
RimeColossus = { Name = "Rimeheart Colossus", Level = 25, Health = 4500, Damage = 38, Speed = 15, Aggro = 120, Range = 16, AttackCD = 2.0, XP = 2500, Coins = 1600, Respawn = 150, Boss = true, Element = "Ice" },
}
Config.Quests = {
bandits = { Name = "Dockside Trouble", Giver = "Captain Marlow", Target = "Bandit", Goal = 5, XP = 120, Coins = 100,
Desc = "Defeat 5 Driftwood Bandits" },
raiders = { Name = "Clear the Raiders", Giver = "Quartermaster Ash", Target = "EmberRaider", Goal = 5, XP = 400, Coins = 250,
Desc = "Defeat 5 Ember Raiders" },
warden  = { Name = "The Cinder Warden", Giver = "Quartermaster Ash", Target = "CinderWarden", Goal = 1, XP = 1200, Coins = 800,
Desc = "Defeat the Cinder Warden" },
beasts  = { Name = "Whispers in the Woods", Giver = "Warden Sylra", Target = "MoonBeast", Goal = 5, XP = 600, Coins = 350,
Desc = "Defeat 5 Moonveil Beasts" },
frost   = { Name = "Thaw the Frontier", Giver = "Ranger Isolde", Target = "FrostGuardian", Goal = 4, XP = 900, Coins = 500,
Desc = "Defeat 4 Frost Guardians" },
colossus= { Name = "Heart of Winter", Giver = "Ranger Isolde", Target = "RimeColossus", Goal = 1, XP = 2500, Coins = 1500,
Desc = "Defeat the Rimeheart Colossus" },
}
Config.Chests = {
moon_secret = { Name = "Secret Moonveil Chest", Coins = 600, XP = 250 },
moon_cache  = { Name = "Hollow Tree Cache",     Coins = 250, XP = 100 },
}
Config.Audio = {
Ocean = "", Haven = "", Ember = "", Moonveil = "", Frost = "",
BossMusic = "", Slash = "", Hit = "", Fire = "", Water = "", Meteor = "", Dash = "",
UIClick = "", LevelUp = "", Quest = "", Coin = "",
}
Config.Remotes = {
"Notify", "Dialog", "BasicAttack", "UseAbility", "Cooldown", "Effect", "Sfx",
"OpenShop", "OpenTravel", "TravelRequest", "BoatInput", "BoatState", "LevelUp",
}
Config.RemoteFunctions = { "ShopRequest" }
return Config
]=====])
mk("ModuleScript", "Utilities", shared, [=====[
local RS = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")
local TweenService = game:GetService("TweenService")
local U = {}
function U.Remote(name)
return RS:WaitForChild("Remotes"):WaitForChild(name)
end
function U.Comma(n)
local s = tostring(math.floor(n))
local out = s:reverse():gsub("(%d%d%d)", "%1,"):reverse()
return (out:gsub("^,", ""))
end
function U.IsFiniteVector(v)
return typeof(v) == "Vector3" and v.X == v.X and v.Y == v.Y and v.Z == v.Z
and math.abs(v.X) < 1e5 and math.abs(v.Y) < 1e5 and math.abs(v.Z) < 1e5
end
function U.GetRoot(model)
return model and model:FindFirstChild("HumanoidRootPart")
end
function U.GetHumanoid(model)
return model and model:FindFirstChildOfClass("Humanoid")
end
function U.FxPart(props, life)
local p = Instance.new("Part")
p.Anchored = true
p.CanCollide = false
p.CanQuery = false
p.CanTouch = false
p.CastShadow = false
p.Size = props.Size or Vector3.new(1, 1, 1)
p.CFrame = props.CFrame or CFrame.new()
p.Color = props.Color or Color3.new(1, 1, 1)
p.Material = props.Material or Enum.Material.Neon
p.Shape = props.Shape or Enum.PartType.Block
p.Transparency = props.Transparency or 0
p.Parent = workspace
Debris:AddItem(p, life or 2)
return p
end
function U.Tween(inst, t, goal, style, dir)
local tw = TweenService:Create(inst, TweenInfo.new(t, style or Enum.EasingStyle.Quad, dir or Enum.EasingDirection.Out), goal)
tw:Play()
return tw
end
return U
]=====])
local server = mk("Folder", "Server", SSS)
local services = mk("Folder", "Services", server)
mk("ModuleScript", "PlayerDataService", services, [=====[
local Players = game:GetService("Players")
local DSS = game:GetService("DataStoreService")
local HttpService = game:GetService("HttpService")
local RS = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Config = require(RS.Shared.Config)
local Remotes = RS:WaitForChild("Remotes")
local M = {}
M.Changed = Instance.new("BindableEvent") -- (player, key)
local store
pcall(function() store = DSS:GetDataStore("MythicSeas_v1") end)
local profiles = {}   -- [player] = data
local noSave = {}     -- [player] = true when load failed (never overwrite saved data)
local lastSave = {}
local function defaultData()
return {
Level = Config.Start.Level, XP = Config.Start.XP, Coins = Config.Start.Coins,
Power = Config.Start.Power, Powers = { Config.Start.Power },
Weapon = Config.Start.Weapon, Weapons = { Config.Start.Weapon }, Upgrades = {},
QuestActive = false, QuestProgress = 0, QuestDone = {}, Chests = {}, Kills = 0,
}
end
local function reconcile(data)
local d = defaultData()
for k, v in pairs(d) do
if data[k] == nil then data[k] = v end
end
data.Level = math.clamp(math.floor(tonumber(data.Level) or 1), 1, Config.MaxLevel)
data.Coins = math.max(0, math.floor(tonumber(data.Coins) or 0))
return data
end
function M.Notify(player, text, kind)
Remotes.Notify:FireClient(player, text, kind or "info")
end
function M.Get(player) return profiles[player] end
function M.Sync(player)
local d = profiles[player]
if not d then return end
player:SetAttribute("Level", d.Level)
player:SetAttribute("XP", d.XP)
player:SetAttribute("XPNeeded", Config.XPForLevel(d.Level))
player:SetAttribute("Coins", d.Coins)
player:SetAttribute("Power", d.Power)
player:SetAttribute("Weapon", d.Weapon)
player:SetAttribute("Inventory", HttpService:JSONEncode({
Weapons = d.Weapons, Upgrades = d.Upgrades, Powers = d.Powers,
}))
player:SetAttribute("DataReady", true)
end
local function applyHealth(player, heal)
local d = profiles[player]
local char = player.Character
local hum = char and char:FindFirstChildOfClass("Humanoid")
if not (d and hum) then return end
local max = Config.MaxHealth(d.Level)
hum.MaxHealth = max
if heal then hum.Health = max end
end
M.ApplyHealth = applyHealth
function M.AddXP(player, amount)
local d = profiles[player]
if not d or amount <= 0 then return end
d.XP += math.floor(amount)
local leveled = false
while d.Level < Config.MaxLevel and d.XP >= Config.XPForLevel(d.Level) do
d.XP -= Config.XPForLevel(d.Level)
d.Level += 1
leveled = true
end
if d.Level >= Config.MaxLevel then d.XP = 0 end
M.Sync(player)
if leveled then
applyHealth(player, true)
Remotes.LevelUp:FireClient(player, d.Level)
M.Notify(player, "Level Up! You reached level " .. d.Level, "levelup")
end
M.Changed:Fire(player, "XP")
end
function M.AddCoins(player, amount)
local d = profiles[player]
if not d then return end
d.Coins = math.max(0, d.Coins + math.floor(amount))
M.Sync(player)
M.Changed:Fire(player, "Coins")
end
function M.SpendCoins(player, amount)
local d = profiles[player]
if not d or amount < 0 or d.Coins < amount then return false end
d.Coins -= amount
M.Sync(player)
M.Changed:Fire(player, "Coins")
return true
end
function M.Has(list, id)
return table.find(list, id) ~= nil
end
function M.UseStamina(player, cost)
local s = player:GetAttribute("Stamina") or 0
if s < cost then return false end
player:SetAttribute("Stamina", s - cost)
return true
end
local function keyFor(player) return "P_" .. player.UserId end
local function load(player)
local data, ok, err
for attempt = 1, 3 do
ok, err = pcall(function()
data = store and store:GetAsync(keyFor(player))
end)
if ok then break end
task.wait(1.5 * attempt)
end
if not store or not ok then
warn("[PlayerData] Load failed for " .. player.Name .. ": " .. tostring(err) .. " (progress will NOT be saved this session)")
noSave[player] = true
return defaultData(), false
end
return reconcile(data or {}), true
end
function M.Save(player)
local d = profiles[player]
if not d or noSave[player] or not store then return false end
if lastSave[player] and os.clock() - lastSave[player] < 6 then return true end
lastSave[player] = os.clock()
local snapshot = HttpService:JSONDecode(HttpService:JSONEncode(d))
for attempt = 1, 3 do
local ok, err = pcall(function()
store:UpdateAsync(keyFor(player), function() return snapshot end)
end)
if ok then return true end
warn("[PlayerData] Save attempt " .. attempt .. " failed: " .. tostring(err))
task.wait(2)
end
return false
end
local function onPlayer(player)
player:SetAttribute("DataReady", false)
local d, loaded = load(player)
if not player.Parent then return end
profiles[player] = d
player:SetAttribute("Stamina", Config.StaminaMax)
player:SetAttribute("MaxStamina", Config.StaminaMax)
M.Sync(player)
M.Changed:Fire(player, "Loaded")
if not loaded then
M.Notify(player, "Could not load saved data. Progress will not save this session.", "error")
end
player.CharacterAdded:Connect(function(char)
local hum = char:WaitForChild("Humanoid", 5)
if hum then
task.defer(applyHealth, player, true)
player:SetAttribute("Stamina", Config.StaminaMax)
end
M.Changed:Fire(player, "Character")
end)
if player.Character then
applyHealth(player, true)
M.Changed:Fire(player, "Character")
end
end
function M.Start()
Players.PlayerAdded:Connect(onPlayer)
for _, p in ipairs(Players:GetPlayers()) do task.spawn(onPlayer, p) end
Players.PlayerRemoving:Connect(function(p)
lastSave[p] = nil
M.Save(p)
profiles[p] = nil
noSave[p] = nil
end)
task.spawn(function()
while true do
task.wait(60)
for _, p in ipairs(Players:GetPlayers()) do task.spawn(M.Save, p) end
end
end)
game:BindToClose(function()
for _, p in ipairs(Players:GetPlayers()) do
lastSave[p] = nil
task.spawn(M.Save, p)
end
if not RunService:IsStudio() then task.wait(3) else task.wait(1) end
end)
task.spawn(function()
while true do
task.wait(0.25)
for _, p in ipairs(Players:GetPlayers()) do
local s, m = p:GetAttribute("Stamina"), p:GetAttribute("MaxStamina")
if s and m and s < m then
p:SetAttribute("Stamina", math.min(m, s + Config.StaminaRegen * 0.25))
end
end
end
end)
end
return M
]=====])
mk("ModuleScript", "CombatService", services, [=====[
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
local Config = require(RS.Shared.Config)
local U = require(RS.Shared.Utilities)
local Data = require(script.Parent.PlayerDataService)
local Remotes = RS:WaitForChild("Remotes")
local M = {}
local attackers = {}  -- [enemyModel] = {[player] = true}
local cooldowns = {}  -- [player] = {[key] = expireClock}
local lastHurt = {}   -- [player] = clock
function M.Ready(player, key)
local t = cooldowns[player]
return not (t and t[key] and t[key] > os.clock())
end
function M.StartCooldown(player, key, duration)
cooldowns[player] = cooldowns[player] or {}
cooldowns[player][key] = os.clock() + duration
end
local function alive(model)
local hum = model:FindFirstChildOfClass("Humanoid")
return hum and hum.Health > 0 and model:FindFirstChild("HumanoidRootPart"), hum
end
function M.GetPlayerRoot(player)
local c = player.Character
local hum = c and c:FindFirstChildOfClass("Humanoid")
local root = c and c:FindFirstChild("HumanoidRootPart")
if hum and root and hum.Health > 0 then return root, hum end
end
function M.EnemiesInRadius(center, radius)
local list = {}
for _, m in ipairs(CollectionService:GetTagged("Enemy")) do
local root = alive(m)
if root then
local reach = m:GetAttribute("Reach") or 2
if (root.Position - center).Magnitude - reach <= radius then table.insert(list, m) end
end
end
return list
end
function M.EnemiesInCone(origin, dir, range, halfAngleDeg)
local list = {}
local cosLimit = math.cos(math.rad(halfAngleDeg))
for _, m in ipairs(M.EnemiesInRadius(origin, range)) do
local root = m.HumanoidRootPart
local off = root.Position - origin
off = Vector3.new(off.X, 0, off.Z)
local d = Vector3.new(dir.X, 0, dir.Z)
if off.Magnitude < (m:GetAttribute("Reach") or 2) + 1.5 or off.Unit:Dot(d.Unit) >= cosLimit then
table.insert(list, m)
end
end
return list
end
function M.DamageEnemy(model, amount, player)
local root, hum = alive(model)
if not root then return false end
if player then
attackers[model] = attackers[model] or {}
attackers[model][player] = true
Remotes.Effect:FireClient(player, "Damage", root.Position + Vector3.new(0, 4 * (model:GetScale()), 0), math.floor(amount))
end
hum.Health = hum.Health - amount
return true
end
function M.GetAttackers(model) return attackers[model] or {} end
function M.ClearAttackers(model) attackers[model] = nil end
function M.DamagePlayer(player, amount)
local root, hum = M.GetPlayerRoot(player)
if not root then return end
if lastHurt[player] and os.clock() - lastHurt[player] < 0.25 then return end
lastHurt[player] = os.clock()
hum:TakeDamage(amount)
end
function M.Knockback(model, fromPos, force)
local root = model:FindFirstChild("HumanoidRootPart")
if not root or root.Anchored then return end
local dir = root.Position - fromPos
dir = Vector3.new(dir.X, 0, dir.Z)
if dir.Magnitude < 0.1 then dir = Vector3.new(0, 0, 1) end
local mass = root.AssemblyMass
root:ApplyImpulse(dir.Unit * force * mass + Vector3.new(0, force * 0.35 * mass, 0))
end
local function basicDamage(player)
local d = Data.Get(player)
if not d then return 0 end
return Config.WeaponDamage(d.Weapon, d.Upgrades[d.Weapon]) + d.Level * 1.5
end
local function slashFx(root, color)
local cf = root.CFrame * CFrame.new(0, 0.5, -4.5)
local p = U.FxPart({ Size = Vector3.new(9, 0.3, 9), CFrame = cf * CFrame.Angles(0, 0, math.rad(25)),
Color = color, Shape = Enum.PartType.Cylinder, Transparency = 0.35 }, 0.3)
p.CFrame = cf * CFrame.Angles(0, 0, math.rad(90 + 25))
p.Size = Vector3.new(0.2, 9, 9)
U.Tween(p, 0.25, { Transparency = 1, Size = Vector3.new(0.2, 13, 13) })
end
function M.BasicAttack(player, aim)
local root = M.GetPlayerRoot(player)
if not root or not Data.Get(player) then return end
if not M.Ready(player, "Basic") then return end
M.StartCooldown(player, "Basic", 0.45)
local look = root.CFrame.LookVector
if U.IsFiniteVector(aim) then
local flat = Vector3.new(aim.X - root.Position.X, 0, aim.Z - root.Position.Z)
if flat.Magnitude > 1 then look = flat.Unit end
end
local weapon = Config.GetWeapon(Data.Get(player).Weapon) or Config.Weapons[1]
slashFx(root, weapon.Color)
Remotes.Sfx:FireAllClients("Slash", root.Position)
local dmg = basicDamage(player)
for _, m in ipairs(M.EnemiesInCone(root.Position, look, 10, 60)) do
M.DamageEnemy(m, dmg, player)
M.Knockback(m, root.Position, 8)
Remotes.Sfx:FireAllClients("Hit", m.HumanoidRootPart.Position)
end
end
local function buildSword(color, tier)
local handle = Instance.new("Part")
handle.Name = "SwordHandle"
handle.Size = Vector3.new(0.3, 1.1, 0.3)
handle.Color = Color3.fromRGB(80, 50, 30)
handle.Material = Enum.Material.Wood
handle.CanCollide = false
handle.Massless = true
local guard = Instance.new("Part")
guard.Size = Vector3.new(1.2, 0.25, 0.35)
guard.Color = Color3.fromRGB(200, 170, 60)
guard.Material = Enum.Material.Metal
guard.CanCollide = false
guard.Massless = true
guard.CFrame = handle.CFrame * CFrame.new(0, 0.65, 0)
local blade = Instance.new("Part")
blade.Size = Vector3.new(0.35, 3.2 + tier * 0.3, 0.12)
blade.Color = color
blade.Material = tier >= 3 and Enum.Material.Neon or Enum.Material.Metal
blade.CanCollide = false
blade.Massless = true
blade.CFrame = guard.CFrame * CFrame.new(0, 0.12 + blade.Size.Y / 2, 0)
for _, p in ipairs({ guard, blade }) do
local w = Instance.new("WeldConstraint")
w.Part0, w.Part1 = handle, p
w.Parent = handle
p.Parent = handle
end
return handle
end
function M.AttachWeapon(player)
local char, d = player.Character, Data.Get(player)
if not (char and d) then return end
local old = char:FindFirstChild("EquippedSword")
if old then old:Destroy() end
local hand = char:FindFirstChild("RightHand") or char:FindFirstChild("Right Arm")
if not hand then return end
local w = Config.GetWeapon(d.Weapon) or Config.Weapons[1]
local tier = table.find(Config.Weapons, w) or 1
local sword = buildSword(w.Color, tier - 1)
sword.Name = "EquippedSword"
local grip = hand.Name == "RightHand" and CFrame.new(0, -0.3, -0.2) or CFrame.new(0, -1, -0.1)
sword.CFrame = hand.CFrame * grip * CFrame.Angles(math.rad(-90), 0, 0)
sword.Parent = char
local weld = Instance.new("WeldConstraint")
weld.Part0, weld.Part1 = hand, sword
weld.Parent = sword
end
function M.Start()
Remotes.BasicAttack.OnServerEvent:Connect(function(player, aim)
M.BasicAttack(player, aim)
end)
Data.Changed.Event:Connect(function(player, key)
if key == "Character" or key == "Weapon" or key == "Loaded" then
task.delay(0.4, M.AttachWeapon, player)
end
end)
Players.PlayerRemoving:Connect(function(p) cooldowns[p] = nil; lastHurt[p] = nil end)
end
return M
]=====])
mk("ModuleScript", "PowerService", services, [=====[
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Debris = game:GetService("Debris")
local Config = require(RS.Shared.Config)
local U = require(RS.Shared.Utilities)
local Data = require(script.Parent.PlayerDataService)
local Combat = require(script.Parent.CombatService)
local Remotes = RS:WaitForChild("Remotes")
local M = {}
local ORANGE, RED = Color3.fromRGB(255, 120, 20), Color3.fromRGB(255, 60, 10)
local CYAN, DEEP = Color3.fromRGB(90, 210, 255), Color3.fromRGB(20, 110, 200)
local function flat(v) return Vector3.new(v.X, 0, v.Z) end
local function aimDir(root, aim)
local d = flat(aim - root.Position)
if d.Magnitude < 0.5 then d = flat(root.CFrame.LookVector) end
return d.Unit
end
local function groundAt(pos)
local params = RaycastParams.new()
params.FilterType = Enum.RaycastFilterType.Include
local inc = { workspace.Terrain }
for _, n in ipairs({ "Islands", "Structures" }) do
if workspace:FindFirstChild(n) then table.insert(inc, workspace[n]) end
end
params.FilterDescendantsInstances = inc
local r = workspace:Raycast(pos + Vector3.new(0, 80, 0), Vector3.new(0, -200, 0), params)
return r and r.Position or Vector3.new(pos.X, 0, pos.Z)
end
local function targetPoint(root, aim, maxDist)
local off = flat(aim - root.Position)
if off.Magnitude > maxDist then aim = root.Position + off.Unit * maxDist end
return groundAt(aim)
end
local function sfx(name, pos) Remotes.Sfx:FireAllClients(name, pos) end
local function dmgOf(player, ab)
local d = Data.Get(player)
local mult = (player:GetAttribute("InfernoUntil") or 0) > os.clock() and 1.25 or 1
return Config.ScaleDamage(ab.Damage, d.Level) * mult
end
local function burn(model, player, perTick, ticks)
local root = model:FindFirstChild("HumanoidRootPart")
if not root or model:GetAttribute("Burning") then return end
model:SetAttribute("Burning", true)
local fire = Instance.new("Fire")
fire.Size = 8 * model:GetScale()
fire.Parent = root
task.spawn(function()
for _ = 1, ticks do
task.wait(0.5)
if not Combat.DamageEnemy(model, perTick, player) then break end
end
fire:Destroy()
model:SetAttribute("Burning", nil)
end)
end
local function stun(model, secs)
model:SetAttribute("StunUntil", os.clock() + secs)
end
local function ring(center, radius, color, life)
local p = U.FxPart({ Size = Vector3.new(0.5, 2, 2), CFrame = CFrame.new(center + Vector3.new(0, 0.6, 0)) * CFrame.Angles(0, 0, math.rad(90)),
Color = color, Shape = Enum.PartType.Cylinder, Transparency = 0.2 }, life + 0.2)
U.Tween(p, life, { Size = Vector3.new(0.5, radius * 2, radius * 2), Transparency = 1 })
return p
end
local function flames(center, radius, count, life)
for i = 1, count do
local a = (i / count) * math.pi * 2
local pos = center + Vector3.new(math.cos(a) * radius, 1, math.sin(a) * radius)
local p = U.FxPart({ Size = Vector3.new(1, 1, 1), CFrame = CFrame.new(pos), Transparency = 1 }, life)
local f = Instance.new("Fire")
f.Size = 7
f.Heat = 10
f.Parent = p
end
end
local H = {} -- handlers: return false to cancel (no cooldown / stamina consumed)
function H.CinderPunch(player, root, aim, ab)
local dir = aimDir(root, aim)
local pos = root.Position + dir * 4.5
local ball = U.FxPart({ Size = Vector3.new(5, 5, 5), CFrame = CFrame.new(pos), Color = ORANGE, Shape = Enum.PartType.Ball, Transparency = 0.2 }, 0.6)
local f = Instance.new("Fire") f.Size = 10 f.Parent = ball
U.Tween(ball, 0.35, { Size = Vector3.new(11, 11, 11), Transparency = 1 })
sfx("Fire", pos)
for _, m in ipairs(Combat.EnemiesInCone(root.Position, dir, 12, 55)) do
Combat.DamageEnemy(m, dmgOf(player, ab), player)
Combat.Knockback(m, root.Position, 22)
burn(m, player, dmgOf(player, ab) * 0.1, 3)
end
end
function H.FlameDash(player, root, aim, ab)
local dir = aimDir(root, aim)
Remotes.Effect:FireClient(player, "Dash", dir, 95, 0.28)
sfx("Dash", root.Position)
local hit = {}
task.spawn(function()
for _ = 1, 8 do
local r = Combat.GetPlayerRoot(player)
if not r then return end
local p = U.FxPart({ Size = Vector3.new(4, 4, 4), CFrame = r.CFrame, Color = ORANGE, Shape = Enum.PartType.Ball, Transparency = 0.3 }, 0.6)
local f = Instance.new("Fire") f.Size = 9 f.Parent = p
U.Tween(p, 0.5, { Transparency = 1, Size = Vector3.new(1, 1, 1) })
for _, m in ipairs(Combat.EnemiesInRadius(r.Position, 7)) do
if not hit[m] then
hit[m] = true
Combat.DamageEnemy(m, dmgOf(player, ab), player)
Combat.Knockback(m, r.Position, 14)
burn(m, player, 4, 3)
end
end
task.wait(0.04)
end
end)
end
function H.BurningRing(player, root, aim, ab)
local c = root.Position
ring(c, 18, ORANGE, 0.9)
ring(c, 12, RED, 0.7)
flames(Vector3.new(c.X, c.Y - 2.5, c.Z), 14, 10, 1.6)
sfx("Fire", c)
for _, m in ipairs(Combat.EnemiesInRadius(c, 17)) do
Combat.DamageEnemy(m, dmgOf(player, ab), player)
Combat.Knockback(m, c, 18)
burn(m, player, dmgOf(player, ab) * 0.1, 4)
end
end
function H.MeteorBurst(player, root, aim, ab)
local target = targetPoint(root, aim, 70)
local marker = U.FxPart({ Size = Vector3.new(0.3, 36, 36), CFrame = CFrame.new(target + Vector3.new(0, 0.5, 0)) * CFrame.Angles(0, 0, math.rad(90)),
Color = RED, Shape = Enum.PartType.Cylinder, Transparency = 0.6 }, 1.3)
local meteor = U.FxPart({ Size = Vector3.new(10, 10, 10), CFrame = CFrame.new(target + Vector3.new(0, 110, 0)),
Color = Color3.fromRGB(70, 30, 15), Material = Enum.Material.Basalt, Shape = Enum.PartType.Ball }, 3)
local f = Instance.new("Fire") f.Size = 25 f.Heat = 20 f.Parent = meteor
local sm = Instance.new("Smoke") sm.Size = 14 sm.Opacity = 0.5 sm.Parent = meteor
U.Tween(meteor, 0.95, { Position = target + Vector3.new(0, 4, 0) }, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
sfx("Meteor", target)
task.delay(0.97, function()
meteor:Destroy()
marker:Destroy()
local boom = U.FxPart({ Size = Vector3.new(4, 4, 4), CFrame = CFrame.new(target + Vector3.new(0, 4, 0)), Color = ORANGE, Shape = Enum.PartType.Ball, Transparency = 0.1 }, 1)
U.Tween(boom, 0.6, { Size = Vector3.new(38, 38, 38), Transparency = 1 })
ring(target, 22, RED, 0.7)
flames(target, 12, 8, 2.5)
Remotes.Effect:FireAllClients("Shake", target, 1.2)
for _, m in ipairs(Combat.EnemiesInRadius(target, 18)) do
Combat.DamageEnemy(m, dmgOf(player, ab), player)
Combat.Knockback(m, target, 30)
burn(m, player, 6, 4)
end
end)
end
function H.InfernoCrown(player, root, aim, ab)
local char = player.Character
local head = char and char:FindFirstChild("Head")
if not head then return false end
local old = char:FindFirstChild("InfernoCrown")
if old then old:Destroy() end
local crown = Instance.new("Model")
crown.Name = "InfernoCrown"
for i = 1, 6 do
local a = (i / 6) * math.pi * 2
local s = Instance.new("Part")
s.Size = Vector3.new(0.35, 1.4, 0.35)
s.Color = ORANGE
s.Material = Enum.Material.Neon
s.CanCollide = false
s.Massless = true
s.CFrame = head.CFrame * CFrame.new(math.cos(a) * 0.9, 0.95, math.sin(a) * 0.9)
local w = Instance.new("WeldConstraint") w.Part0, w.Part1 = head, s w.Parent = s
local f = Instance.new("Fire") f.Size = 4 f.Parent = s
s.Parent = crown
end
crown.Parent = char
local dur = 12
player:SetAttribute("InfernoUntil", os.clock() + dur)
sfx("Fire", root.Position)
task.spawn(function()
local t0 = os.clock()
while os.clock() - t0 < dur do
local r = Combat.GetPlayerRoot(player)
if not r or not crown.Parent then break end
for _, m in ipairs(Combat.EnemiesInRadius(r.Position, 11)) do
Combat.DamageEnemy(m, dmgOf(player, ab), player)
end
task.wait(0.6)
end
crown:Destroy()
player:SetAttribute("InfernoUntil", nil)
end)
end
function H.WaterSpear(player, root, aim, ab)
local dir = aimDir(root, aim)
local pos = root.Position + dir * 3 + Vector3.new(0, 1, 0)
local spear = U.FxPart({ Size = Vector3.new(0.7, 0.7, 6), CFrame = CFrame.lookAt(pos, pos + dir), Color = CYAN, Transparency = 0.1 }, 3)
local a0, a1 = Instance.new("Attachment", spear), Instance.new("Attachment", spear)
a0.Position, a1.Position = Vector3.new(0, 0.3, 0), Vector3.new(0, -0.3, 0)
local trail = Instance.new("Trail")
trail.Attachment0, trail.Attachment1, trail.Lifetime = a0, a1, 0.4
trail.Color = ColorSequence.new(CYAN, DEEP)
trail.Transparency = NumberSequence.new(0.2, 1)
trail.Parent = spear
sfx("Water", pos)
local traveled, speed, hit = 0, 130, false
local conn
conn = RunService.Heartbeat:Connect(function(dt)
if hit or not spear.Parent then conn:Disconnect() return end
local step = speed * dt
pos = pos + dir * step
traveled += step
spear.CFrame = CFrame.lookAt(pos, pos + dir)
for _, m in ipairs(Combat.EnemiesInRadius(pos, 3.5)) do
hit = true
Combat.DamageEnemy(m, dmgOf(player, ab), player)
Combat.Knockback(m, pos - dir * 3, 12)
local splash = U.FxPart({ Size = Vector3.new(3, 3, 3), CFrame = CFrame.new(pos), Color = CYAN, Shape = Enum.PartType.Ball, Transparency = 0.3 }, 0.5)
U.Tween(splash, 0.4, { Size = Vector3.new(10, 10, 10), Transparency = 1 })
break
end
if hit or traveled > 95 then spear:Destroy() conn:Disconnect() end
end)
end
function H.WaveCrash(player, root, aim, ab)
local dir = aimDir(root, aim)
local start = root.Position + dir * 6 - Vector3.new(0, 1.5, 0)
local wave = U.FxPart({ Size = Vector3.new(20, 8, 4), CFrame = CFrame.lookAt(start, start + dir), Color = CYAN,
Material = Enum.Material.Glass, Transparency = 0.35 }, 3)
local foam = Instance.new("ParticleEmitter") foam.Rate = 120 foam.Lifetime = NumberRange.new(0.5, 1)
foam.Speed = NumberRange.new(4, 8) foam.Size = NumberSequence.new(2, 0) foam.SpreadAngle = Vector2.new(60, 60)
foam.Color = ColorSequence.new(Color3.new(1, 1, 1)) foam.Parent = wave
sfx("Water", start)
task.spawn(function()
local hit = {}
for i = 1, 22 do
local p = start + dir * (i * 2.4)
wave.CFrame = CFrame.lookAt(p, p + dir)
for _, m in ipairs(Combat.EnemiesInRadius(p, 10)) do
if not hit[m] then
hit[m] = true
Combat.DamageEnemy(m, dmgOf(player, ab), player)
Combat.Knockback(m, p - dir * 4, 28)
end
end
task.wait(0.045)
end
wave:Destroy()
end)
end
function H.Whirlpool(player, root, aim, ab)
local c = targetPoint(root, aim, 55)
local discs = {}
for i = 1, 3 do
local r = 32 - i * 7
discs[i] = U.FxPart({ Size = Vector3.new(0.4, r, r), CFrame = CFrame.new(c + Vector3.new(0, 0.5 + i * 0.3, 0)) * CFrame.Angles(0, 0, math.rad(90)),
Color = i % 2 == 0 and DEEP or CYAN, Material = Enum.Material.Glass, Shape = Enum.PartType.Cylinder, Transparency = 0.35 }, 6)
end
sfx("Water", c)
task.spawn(function()
local t0, n = os.clock(), 0
while os.clock() - t0 < 5 do
local dt = task.wait(0.1)
n += 1
for i, d in ipairs(discs) do
if d.Parent then d.CFrame = d.CFrame * CFrame.Angles(math.rad(14) * i * (i % 2 == 0 and -1 or 1), 0, 0) end
end
for _, m in ipairs(Combat.EnemiesInRadius(c, 16)) do
local r = m.HumanoidRootPart
local toward = flat(c - r.Position)
if toward.Magnitude > 2 and not r.Anchored then
r:ApplyImpulse(toward.Unit * 14 * r.AssemblyMass)
end
if n % 5 == 0 then Combat.DamageEnemy(m, dmgOf(player, ab), player) end
end
end
for _, d in ipairs(discs) do d:Destroy() end
end)
end
function H.TidalPrison(player, root, aim, ab)
local dir = aimDir(root, aim)
local best, bestD
for _, m in ipairs(Combat.EnemiesInRadius(root.Position, 55)) do
local off = flat(m.HumanoidRootPart.Position - root.Position)
if off.Magnitude < 1 or off.Unit:Dot(dir) > 0.7 then
if not bestD or off.Magnitude < bestD then best, bestD = m, off.Magnitude end
end
end
if not best then
Data.Notify(player, "No target in front of you.", "error")
return false
end
local er = best.HumanoidRootPart
local size = 9 * best:GetScale()
local bubble = U.FxPart({ Size = Vector3.new(size, size, size), CFrame = er.CFrame, Color = CYAN, Material = Enum.Material.Glass,
Shape = Enum.PartType.Ball, Transparency = 0.45 }, 5)
stun(best, 4)
sfx("Water", er.Position)
task.spawn(function()
for _ = 1, 4 do
task.wait(1)
if not best.Parent or not Combat.DamageEnemy(best, dmgOf(player, ab), player) then break end
if er.Parent then bubble.CFrame = er.CFrame end
end
bubble:Destroy()
end)
end
function H.LeviathanSurge(player, root, aim, ab)
local dir = aimDir(root, aim)
local start = root.Position + dir * 4 - Vector3.new(0, 4, 0)
local segs = {}
for i = 1, 8 do
local s = U.FxPart({ Size = Vector3.new(1, 1, 1) * (i == 1 and 11 or 9 - i * 0.5), CFrame = CFrame.new(start),
Color = i == 1 and Color3.fromRGB(10, 70, 130) or DEEP, Material = Enum.Material.Glass, Shape = Enum.PartType.Ball, Transparency = 0.15 }, 4)
segs[i] = s
end
local eyeL = U.FxPart({ Size = Vector3.new(1.4, 1.4, 1.4), CFrame = CFrame.new(start), Color = Color3.fromRGB(255, 240, 120), Shape = Enum.PartType.Ball }, 4)
sfx("Water", start)
Remotes.Effect:FireAllClients("Shake", start, 0.8)
task.spawn(function()
local hit, travel = {}, 70
local steps = 32
for s = 1, steps + 10 do
local t = s / steps
for i, seg in ipairs(segs) do
local ti = math.clamp(t - (i - 1) * 0.045, 0, 1)
local lift = math.sin(ti * math.pi) * 14
seg.Position = start + dir * (ti * travel) + Vector3.new(0, lift, 0)
end
local head = segs[1].Position
eyeL.Position = head + Vector3.new(0, 3, 0) + dir * 3.5
for _, m in ipairs(Combat.EnemiesInRadius(head, 14)) do
if not hit[m] then
hit[m] = true
Combat.DamageEnemy(m, dmgOf(player, ab), player)
Combat.Knockback(m, head - dir * 5, 36)
end
end
task.wait(0.04)
end
for _, s in ipairs(segs) do U.Tween(s, 0.4, { Transparency = 1 }) end
eyeL:Destroy()
end)
end
function M.Use(player, slot, aim)
if typeof(slot) ~= "number" or slot % 1 ~= 0 or slot < 1 or slot > 5 then return end
if not U.IsFiniteVector(aim) then return end
local d = Data.Get(player)
local root = Combat.GetPlayerRoot(player)
if not d or not root then return end
local power = Config.Powers[d.Power]
local ab = power and power.Abilities[slot]
if not ab or not H[ab.Id] then return end
if not Combat.Ready(player, ab.Id) then return end
local stam = player:GetAttribute("Stamina") or 0
if stam < ab.Stamina then
Data.Notify(player, "Not enough stamina", "error")
return
end
if H[ab.Id](player, root, aim, ab) == false then return end
player:SetAttribute("Stamina", stam - ab.Stamina)
Combat.StartCooldown(player, ab.Id, ab.Cooldown)
Remotes.Cooldown:FireClient(player, ab.Id, ab.Cooldown)
end
function M.Start()
Remotes.UseAbility.OnServerEvent:Connect(M.Use)
end
return M
]=====])
mk("ModuleScript", "QuestService", services, [=====[
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local Config = require(RS.Shared.Config)
local Data = require(script.Parent.PlayerDataService)
local Remotes = RS:WaitForChild("Remotes")
local M = {}
function M.Sync(player)
local d = Data.Get(player)
if not d then return end
local q = d.QuestActive and Config.Quests[d.QuestActive]
if q then
player:SetAttribute("QuestId", d.QuestActive)
player:SetAttribute("QuestName", q.Name)
player:SetAttribute("QuestDesc", q.Desc)
player:SetAttribute("QuestProgress", d.QuestProgress)
player:SetAttribute("QuestGoal", q.Goal)
player:SetAttribute("QuestReward", ("%d XP  •  %d Coins"):format(q.XP, q.Coins))
else
player:SetAttribute("QuestId", "")
player:SetAttribute("QuestName", "")
player:SetAttribute("QuestDesc", "")
player:SetAttribute("QuestProgress", 0)
player:SetAttribute("QuestGoal", 0)
player:SetAttribute("QuestReward", "")
end
end
local function complete(player)
local d = Data.Get(player)
local q = d and d.QuestActive and Config.Quests[d.QuestActive]
if not q then return end
d.QuestDone[d.QuestActive] = true
d.QuestActive = false
d.QuestProgress = 0
Data.AddXP(player, q.XP)
Data.AddCoins(player, q.Coins)
M.Sync(player)
Data.Notify(player, ("Quest complete: %s  (+%d XP, +%d coins)"):format(q.Name, q.XP, q.Coins), "quest")
Remotes.Sfx:FireClient(player, "Quest")
end
function M.OnKill(player, enemyType)
local d = Data.Get(player)
if not d then return end
d.Kills += 1
local q = d.QuestActive and Config.Quests[d.QuestActive]
if q and q.Target == enemyType then
d.QuestProgress = math.min(q.Goal, d.QuestProgress + 1)
M.Sync(player)
if d.QuestProgress >= q.Goal then
complete(player)
end
end
end
function M.Talk(player, npc)
local d = Data.Get(player)
if not d then return end
local giver = npc:GetAttribute("NpcName") or npc.Name
if d.QuestActive then
local cur = Config.Quests[d.QuestActive]
Remotes.Dialog:FireClient(player, giver, ("Still working on '%s'? %s (%d/%d)."):format(cur.Name, cur.Desc, d.QuestProgress, cur.Goal))
return
end
local offered
for id, q in pairs(Config.Quests) do
if q.Giver == giver and not d.QuestDone[id] then
if not offered or q.XP < Config.Quests[offered].XP then offered = id end
end
end
if not offered then
Remotes.Dialog:FireClient(player, giver, "You've done everything I needed, friend. The seas are safer thanks to you.")
return
end
local q = Config.Quests[offered]
d.QuestActive, d.QuestProgress = offered, 0
M.Sync(player)
Remotes.Dialog:FireClient(player, giver, ("New quest: %s. %s. Reward: %d XP and %d coins."):format(q.Name, q.Desc, q.XP, q.Coins))
Data.Notify(player, "Quest accepted: " .. q.Name, "quest")
end
function M.Start()
Data.Changed.Event:Connect(function(player, key)
if key == "Loaded" then M.Sync(player) end
end)
end
return M
]=====])
mk("ModuleScript", "EnemyService", services, [=====[
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local CollectionService = game:GetService("CollectionService")
local Config = require(RS.Shared.Config)
local U = require(RS.Shared.Utilities)
local Data = require(script.Parent.PlayerDataService)
local Combat = require(script.Parent.CombatService)
local Quest = require(script.Parent.QuestService)
local Remotes = RS:WaitForChild("Remotes")
local M = {}
local states = {}
local templates = {} -- [spawnKey] = {model, parent}
local FIRE = { main = Color3.fromRGB(255, 110, 20), alt = Color3.fromRGB(255, 50, 10) }
local ICE = { main = Color3.fromRGB(140, 225, 255), alt = Color3.fromRGB(220, 250, 255) }
local function flat(v) return Vector3.new(v.X, 0, v.Z) end
local function nearestPlayer(pos, range)
local best, bestRoot, bestD = nil, nil, range
for _, p in ipairs(Players:GetPlayers()) do
local root, hum = Combat.GetPlayerRoot(p)
if root then
local d = (root.Position - pos).Magnitude
if d < bestD then best, bestRoot, bestD = p, root, d end
end
end
return best, bestRoot, bestD
end
local function hurtPlayersInRadius(center, radius, dmg)
for _, p in ipairs(Players:GetPlayers()) do
local root = Combat.GetPlayerRoot(p)
if root and (root.Position - center).Magnitude <= radius then
Combat.DamagePlayer(p, dmg)
end
end
end
local function telegraph(center, radius, time, color)
local p = U.FxPart({ Size = Vector3.new(0.4, radius * 2, radius * 2), CFrame = CFrame.new(center + Vector3.new(0, 0.5, 0)) * CFrame.Angles(0, 0, math.rad(90)),
Color = color, Shape = Enum.PartType.Cylinder, Transparency = 0.7 }, time + 0.1)
U.Tween(p, time, { Transparency = 0.25 })
return p
end
local function groundPos(pos)
local params = RaycastParams.new()
params.FilterType = Enum.RaycastFilterType.Include
local inc = { workspace.Terrain }
for _, n in ipairs({ "Islands", "Structures" }) do
if workspace:FindFirstChild(n) then table.insert(inc, workspace[n]) end
end
params.FilterDescendantsInstances = inc
local r = workspace:Raycast(pos + Vector3.new(0, 150, 0), Vector3.new(0, -300, 0), params)
return r and r.Position or pos
end
local function shoot(from, dir, speed, dmg, color, size, blast, range)
local ball = U.FxPart({ Size = Vector3.new(size, size, size), CFrame = CFrame.new(from), Color = color, Shape = Enum.PartType.Ball }, 6)
local light = Instance.new("PointLight") light.Color = color light.Range = 14 light.Parent = ball
if color == FIRE.main then
local f = Instance.new("Fire") f.Size = size * 2 f.Parent = ball
else
local s = Instance.new("Sparkles") s.SparkleColor = color s.Parent = ball
end
local pos, traveled = from, 0
local conn
conn = RunService.Heartbeat:Connect(function(dt)
if not ball.Parent then conn:Disconnect() return end
local step = speed * dt
pos += dir * step
traveled += step
ball.Position = pos
local explode = traveled > (range or 120) or pos.Y <= groundPos(pos).Y + 1
if not explode then
for _, p in ipairs(Players:GetPlayers()) do
local r = Combat.GetPlayerRoot(p)
if r and (r.Position - pos).Magnitude < size / 2 + 3 then explode = true break end
end
end
if explode then
conn:Disconnect()
ball:Destroy()
local boom = U.FxPart({ Size = Vector3.new(2, 2, 2), CFrame = CFrame.new(pos), Color = color, Shape = Enum.PartType.Ball, Transparency = 0.2 }, 0.7)
U.Tween(boom, 0.4, { Size = Vector3.new(blast * 2, blast * 2, blast * 2), Transparency = 1 })
Remotes.Sfx:FireAllClients("Hit", pos)
hurtPlayersInRadius(pos, blast, dmg)
end
end)
end
local function addNameplate(model, cfg)
local head = model:FindFirstChild("Head")
local hum = model:FindFirstChildOfClass("Humanoid")
if not head then return end
local old = head:FindFirstChild("Nameplate")
if old then old:Destroy() end
local scale = model:GetScale()
local bb = Instance.new("BillboardGui")
bb.Name = "Nameplate"
bb.Adornee = head
bb.Size = UDim2.fromOffset(cfg.Boss and 240 or 150, cfg.Boss and 46 or 34)
bb.StudsOffsetWorldSpace = Vector3.new(0, 1.6 * scale + 1.5, 0)
bb.AlwaysOnTop = false
bb.MaxDistance = cfg.Boss and 400 or 110
local name = Instance.new("TextLabel")
name.BackgroundTransparency = 1
name.Size = UDim2.new(1, 0, 0.55, 0)
name.Font = Enum.Font.GothamBold
name.TextScaled = true
name.TextColor3 = cfg.Boss and Color3.fromRGB(255, 200, 90) or Color3.new(1, 1, 1)
name.TextStrokeTransparency = 0.4
name.Text = ("%s  Lv.%d"):format(cfg.Name, cfg.Level)
name.Parent = bb
local back = Instance.new("Frame")
back.Position = UDim2.new(0.05, 0, 0.62, 0)
back.Size = UDim2.new(0.9, 0, 0.26, 0)
back.BackgroundColor3 = Color3.fromRGB(20, 20, 24)
back.BorderSizePixel = 0
back.Parent = bb
Instance.new("UICorner", back).CornerRadius = UDim.new(1, 0)
local fill = Instance.new("Frame")
fill.Size = UDim2.new(1, 0, 1, 0)
fill.BackgroundColor3 = Color3.fromRGB(225, 60, 60)
fill.BorderSizePixel = 0
fill.Parent = back
Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)
bb.Parent = head
hum.HealthChanged:Connect(function(h)
fill.Size = UDim2.new(math.clamp(h / hum.MaxHealth, 0, 1), 0, 1, 0)
end)
end
local function onDeath(model, st)
states[model] = nil
local cfg = st.cfg
local root = model:FindFirstChild("HumanoidRootPart")
local pos = root and root.Position or st.home
for player in pairs(Combat.GetAttackers(model)) do
if player.Parent then
Data.AddXP(player, cfg.XP)
Data.AddCoins(player, cfg.Coins)
Data.Notify(player, ("Defeated %s  +%d XP  +%d coins"):format(cfg.Name, cfg.XP, cfg.Coins), "reward")
Remotes.Sfx:FireClient(player, "Coin")
Quest.OnKill(player, st.type)
end
end
Combat.ClearAttackers(model)
CollectionService:RemoveTag(model, "Enemy")
local col = (cfg.Element == "Ice") and ICE.main or FIRE.main
if cfg.Boss then
local boom = U.FxPart({ Size = Vector3.new(6, 6, 6), CFrame = CFrame.new(pos), Color = col, Shape = Enum.PartType.Ball }, 2)
U.Tween(boom, 1.4, { Size = Vector3.new(90, 90, 90), Transparency = 1 })
Remotes.Effect:FireAllClients("Shake", pos, 2)
Remotes.Sfx:FireAllClients("Meteor", pos)
for i = 1, 14 do
local a = i / 14 * math.pi * 2
local s = U.FxPart({ Size = Vector3.new(3, 3, 3), CFrame = CFrame.new(pos + Vector3.new(math.cos(a) * 6, 4, math.sin(a) * 6)), Color = col, Shape = Enum.PartType.Ball }, 1.6)
U.Tween(s, 1.4, { Position = pos + Vector3.new(math.cos(a) * 45, 28 + (i % 3) * 8, math.sin(a) * 45), Transparency = 1 })
end
else
local pf = U.FxPart({ Size = Vector3.new(2, 2, 2), CFrame = CFrame.new(pos), Color = col, Shape = Enum.PartType.Ball }, 0.6)
U.Tween(pf, 0.5, { Size = Vector3.new(9, 9, 9), Transparency = 1 })
end
task.delay(3, function()
for _, d in ipairs(model:GetDescendants()) do
if d:IsA("BasePart") then U.Tween(d, 1, { Transparency = 1 }) end
end
task.wait(1.1)
model:Destroy()
end)
task.delay(cfg.Respawn, function()
local clone = st.template:Clone()
clone.Parent = st.parent
M.Register(clone, st.template)
end)
end
function M.Register(model, template)
local etype = model:GetAttribute("EnemyType")
local cfg = Config.Enemies[etype]
local hum = model:FindFirstChildOfClass("Humanoid")
local root = model:FindFirstChild("HumanoidRootPart")
local torso = model:FindFirstChild("Torso")
if not (cfg and hum and root and torso) then
warn("[EnemyService] invalid enemy model " .. model:GetFullName())
return
end
if not template then
template = model:Clone()
end
CollectionService:AddTag(model, "Enemy")
model:SetAttribute("Reach", (model:GetAttribute("Reach") or 2) )
if cfg.Boss then
model:SetAttribute("Boss", true)
model:SetAttribute("BossName", cfg.Name)
end
hum.MaxHealth, hum.Health = cfg.Health, cfg.Health
hum.WalkSpeed = cfg.Speed
hum.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
hum.BreakJointsOnDeath = true
pcall(function() root:SetNetworkOwner(nil) end)
addNameplate(model, cfg)
local st = {
model = model, cfg = cfg, type = etype, hum = hum, root = root, template = template, parent = model.Parent,
home = root.Position, nextAttack = 0, nextSpecial = os.clock() + 4, attackAnim = -10, busy = false,
lastTarget = os.clock(), nextShot = 0,
joints = {
RH = torso:FindFirstChild("Right Hip"), LH = torso:FindFirstChild("Left Hip"),
RS = torso:FindFirstChild("Right Shoulder"), LS = torso:FindFirstChild("Left Shoulder"),
},
}
states[model] = st
local dead = false
hum.Died:Connect(function()
if dead then return end
dead = true
onDeath(model, st)
end)
end
local function animate(st, t)
local j = st.joints
if not (j.RH and j.LH and j.RS and j.LS) then return end
local speed = flat(st.root.AssemblyLinearVelocity).Magnitude
local swing = speed > 1.5 and math.sin(t * math.clamp(speed * 0.55, 4, 11)) * 0.9 or 0
j.RH.Transform = CFrame.Angles(0, 0, swing)
j.LH.Transform = CFrame.Angles(0, 0, -swing)
j.LS.Transform = CFrame.Angles(0, 0, -swing)
local at = t - st.attackAnim
if at >= 0 and at < 0.5 then
local k = at < 0.2 and at / 0.2 or 1 - (at - 0.2) / 0.3
j.RS.Transform = CFrame.Angles(0, 0, 2.4 * k)
else
j.RS.Transform = CFrame.Angles(0, 0, swing)
end
end
local function bossPattern(st, target, tRoot, dist)
local cfg = st.cfg
local pal = cfg.Element == "Ice" and ICE or FIRE
local scale = st.model:GetScale()
local hum, root = st.hum, st.root
local phase2 = hum.Health < hum.MaxHealth * 0.5
local options = { "Slam", "Volley", "Charge" }
if phase2 then table.insert(options, "Rain") table.insert(options, "Rain") end
local pick = options[math.random(#options)]
st.busy = true
st.model:SetAttribute("Telegraph", pick)
task.spawn(function()
local baseSpeed = cfg.Speed
if pick == "Slam" then
hum.WalkSpeed = 0
local radius = 7 * scale
local c = groundPos(root.Position)
telegraph(c, radius, 1.1, pal.alt)
st.attackAnim = os.clock()
task.wait(1.1)
if hum.Health > 0 then
local ring = U.FxPart({ Size = Vector3.new(0.5, 2, 2), CFrame = CFrame.new(c + Vector3.new(0, 1, 0)) * CFrame.Angles(0, 0, math.rad(90)), Color = pal.main, Shape = Enum.PartType.Cylinder }, 0.8)
U.Tween(ring, 0.5, { Size = Vector3.new(0.5, radius * 2.4, radius * 2.4), Transparency = 1 })
Remotes.Effect:FireAllClients("Shake", c, 1.2)
Remotes.Sfx:FireAllClients("Meteor", c)
hurtPlayersInRadius(c, radius, cfg.Damage * 1.3)
end
task.wait(0.5)
elseif pick == "Volley" then
hum.WalkSpeed = 0
st.attackAnim = os.clock()
for i = 1, 5 do
if hum.Health <= 0 then break end
local tr = Combat.GetPlayerRoot(target)
if tr then
local from = root.Position + Vector3.new(0, 2.5 * scale, 0)
local dir = (tr.Position + Vector3.new(0, 1, 0) - from).Unit
dir = (CFrame.Angles(0, (i - 3) * 0.14, 0) * CFrame.new(Vector3.zero, dir)).LookVector
shoot(from, dir, 65, cfg.Damage * 0.8, pal.main, 3.2, 9)
Remotes.Sfx:FireAllClients("Fire", from)
end
task.wait(0.35)
end
task.wait(0.4)
elseif pick == "Charge" then
hum.WalkSpeed = 0
local tr = Combat.GetPlayerRoot(target)
if tr then
local goal = tr.Position
local dir = flat(goal - root.Position).Unit
local line = U.FxPart({ Size = Vector3.new(6, 0.3, 70), CFrame = CFrame.lookAt(root.Position - Vector3.new(0, 2.5 * scale, 0) + dir * 35, root.Position + dir * 70 - Vector3.new(0, 2.5 * scale, 0)), Color = pal.alt, Transparency = 0.6 }, 0.9)
task.wait(0.9)
hum.WalkSpeed = 58
local hit = false
local t0 = os.clock()
while os.clock() - t0 < 1.1 and hum.Health > 0 do
hum:Move(dir)
hum:MoveTo(root.Position + dir * 30)
if not hit then
for _, p in ipairs(Players:GetPlayers()) do
local pr = Combat.GetPlayerRoot(p)
if pr and (pr.Position - root.Position).Magnitude < 6 * scale / 2 + 6 then
hit = true
Combat.DamagePlayer(p, cfg.Damage * 1.4)
pr:ApplyImpulse(dir * 90 * pr.AssemblyMass + Vector3.new(0, 40 * pr.AssemblyMass, 0))
end
end
end
task.wait(0.05)
end
hum:MoveTo(root.Position)
end
elseif pick == "Rain" then
hum.WalkSpeed = 0
st.attackAnim = os.clock()
local center = tRoot.Position
for i = 1, 7 do
local off = Vector3.new(math.random(-30, 30), 0, math.random(-30, 30))
if i <= 3 then local tr = Combat.GetPlayerRoot(target) if tr then center = tr.Position end end
local c = groundPos(center + off)
telegraph(c, 9, 1, pal.alt)
local m = U.FxPart({ Size = Vector3.new(6, 6, 6), CFrame = CFrame.new(c + Vector3.new(0, 90, 0)), Color = pal.main, Shape = Enum.PartType.Ball }, 2)
U.Tween(m, 1, { Position = c + Vector3.new(0, 2, 0) }, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
task.delay(1, function()
m:Destroy()
local b = U.FxPart({ Size = Vector3.new(3, 3, 3), CFrame = CFrame.new(c + Vector3.new(0, 3, 0)), Color = pal.main, Shape = Enum.PartType.Ball }, 0.7)
U.Tween(b, 0.5, { Size = Vector3.new(22, 22, 22), Transparency = 1 })
Remotes.Sfx:FireAllClients("Meteor", c)
hurtPlayersInRadius(c, 10, cfg.Damage * 0.9)
end)
task.wait(0.35)
end
task.wait(1)
end
if hum.Health > 0 then hum.WalkSpeed = baseSpeed end
st.model:SetAttribute("Telegraph", nil)
st.busy = false
st.nextSpecial = os.clock() + (phase2 and 3 or 4.5)
end)
end
local function think(st)
local model, cfg, hum, root = st.model, st.cfg, st.hum, st.root
if hum.Health <= 0 or not root.Parent then return end
local now = os.clock()
if (model:GetAttribute("StunUntil") or 0) > now then
hum:MoveTo(root.Position)
return
end
if st.busy then return end
local target, tRoot, dist = nearestPlayer(root.Position, cfg.Aggro)
local homeDist = (flat(root.Position - st.home)).Magnitude
if target and homeDist > (cfg.Boss and 160 or 110) then target = nil end
if not target then
if now - st.lastTarget > 6 and hum.Health < hum.MaxHealth then
hum.Health = math.min(hum.MaxHealth, hum.Health + hum.MaxHealth * 0.1)
end
if homeDist > 8 then hum:MoveTo(st.home) end
return
end
st.lastTarget = now
local scale = model:GetScale()
local reach = cfg.Range
if cfg.Boss then
if now >= st.nextSpecial then
bossPattern(st, target, tRoot, dist)
return
end
end
if cfg.Ranged and dist > reach + 4 and dist < cfg.Aggro - 5 then
hum:MoveTo(root.Position) -- hold position and shoot
if now >= st.nextShot then
st.nextShot = now + 2.2
st.attackAnim = now
local from = root.Position + Vector3.new(0, 2, 0)
local dir = (tRoot.Position + Vector3.new(0, 1, 0) - from).Unit
shoot(from, dir, 70, cfg.Damage * 0.9, ICE.main, 2.2, 5, 90)
end
root.CFrame = CFrame.lookAt(root.Position, root.Position + flat(tRoot.Position - root.Position) + Vector3.new(0, 0.001, 0))
return
end
if dist > reach + (cfg.Boss and 4 or 1.5) then
hum:MoveTo(tRoot.Position)
if tRoot.Position.Y - root.Position.Y > 3.5 and dist < 25 then hum.Jump = true end
else
hum:MoveTo(root.Position)
root.CFrame = CFrame.lookAt(root.Position, root.Position + flat(tRoot.Position - root.Position) + Vector3.new(0, 0.001, 0))
if now >= st.nextAttack then
st.nextAttack = now + cfg.AttackCD
st.attackAnim = now
task.delay(0.3, function()
if hum.Health <= 0 then return end
local r2 = Combat.GetPlayerRoot(target)
if r2 and (r2.Position - root.Position).Magnitude <= reach + 3 + scale then
Combat.DamagePlayer(target, cfg.Damage)
Remotes.Sfx:FireAllClients("Hit", r2.Position)
end
end)
end
end
end
function M.Start()
for _, folderName in ipairs({ "Enemies", "Bosses" }) do
local folder = workspace:FindFirstChild(folderName)
if folder then
for _, model in ipairs(folder:GetChildren()) do
if model:IsA("Model") and model:GetAttribute("EnemyType") then
M.Register(model)
end
end
end
end
local acc = 0
RunService.Heartbeat:Connect(function(dt)
local t = os.clock()
for _, st in pairs(states) do animate(st, t) end
acc += dt
if acc >= 0.15 then
acc = 0
for _, st in pairs(states) do
local ok, err = pcall(think, st)
if not ok then warn("[EnemyService] " .. tostring(err)) end
end
end
end)
end
return M
]=====])
mk("ModuleScript", "ShopService", services, [=====[
local RS = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
local Config = require(RS.Shared.Config)
local Data = require(script.Parent.PlayerDataService)
local Combat = require(script.Parent.CombatService)
local Remotes = RS:WaitForChild("Remotes")
local M = {}
local function nearRole(player, role)
local root = Combat.GetPlayerRoot(player)
if not root then return false end
for _, npc in ipairs(CollectionService:GetTagged("NPC")) do
if npc:GetAttribute("Role") == role then
local r = npc:FindFirstChild("HumanoidRootPart")
if r and (r.Position - root.Position).Magnitude <= 35 then return true end
end
end
return false
end
local function weaponAction(player, d, action, id)
local w = Config.GetWeapon(id)
if not w then return false, "Unknown weapon" end
local owned = Data.Has(d.Weapons, id)
if action == "Buy" then
if owned then return false, "Already owned" end
if not Data.SpendCoins(player, w.Price) then return false, "Not enough coins" end
table.insert(d.Weapons, id)
d.Weapon = id
Data.Sync(player)
Data.Changed:Fire(player, "Weapon")
return true, "Purchased " .. w.Name
elseif action == "Equip" then
if not owned then return false, "You don't own this weapon" end
d.Weapon = id
Data.Sync(player)
Data.Changed:Fire(player, "Weapon")
return true, "Equipped " .. w.Name
elseif action == "Upgrade" then
if not owned then return false, "You don't own this weapon" end
local lvl = d.Upgrades[id] or 0
if lvl >= Config.MaxUpgrade then return false, "Fully upgraded" end
if not Data.SpendCoins(player, Config.UpgradeCost(w, lvl)) then return false, "Not enough coins" end
d.Upgrades[id] = lvl + 1
Data.Sync(player)
return true, ("%s upgraded to +%d"):format(w.Name, lvl + 1)
end
return false, "Invalid action"
end
local function powerAction(player, d, action, id)
local p = Config.Powers[id]
if not p then return false, "Unknown power" end
local owned = Data.Has(d.Powers, id)
if action == "BuyPower" then
if owned then return false, "Already owned" end
if not Data.SpendCoins(player, p.Price) then return false, "Not enough coins" end
table.insert(d.Powers, id)
d.Power = id
Data.Sync(player)
return true, "Awakened " .. p.Name
elseif action == "EquipPower" then
if not owned then return false, "You don't own this power" end
d.Power = id
Data.Sync(player)
return true, "Equipped " .. p.Name
end
return false, "Invalid action"
end
function M.Start()
Remotes.ShopRequest.OnServerInvoke = function(player, action, id)
if typeof(action) ~= "string" or typeof(id) ~= "string" then return false, "Bad request" end
local d = Data.Get(player)
if not d then return false, "Data not loaded" end
if action == "Buy" or action == "Equip" or action == "Upgrade" then
if action ~= "Equip" and not nearRole(player, "WeaponShop") then return false, "Too far from the shop" end
return weaponAction(player, d, action, id)
elseif action == "BuyPower" or action == "EquipPower" then
if action == "BuyPower" and not nearRole(player, "PowerShop") then return false, "Too far from the shop" end
return powerAction(player, d, action, id)
end
return false, "Invalid action"
end
end
return M
]=====])
mk("ModuleScript", "NPCService", services, [=====[
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
local Config = require(RS.Shared.Config)
local Data = require(script.Parent.PlayerDataService)
local Combat = require(script.Parent.CombatService)
local Quest = require(script.Parent.QuestService)
local Remotes = RS:WaitForChild("Remotes")
local M = {}
local function bind(npc)
local role = npc:GetAttribute("Role")
local prompt = npc:FindFirstChildWhichIsA("ProximityPrompt", true)
if not prompt then return end
prompt.Triggered:Connect(function(player)
local d = Data.Get(player)
if not d then return end
local name = npc:GetAttribute("NpcName") or npc.Name
if role == "Quest" then
Quest.Talk(player, npc)
elseif role == "WeaponShop" then
Remotes.Dialog:FireClient(player, name, "Fine steel for fine sailors. Take a look.")
Remotes.OpenShop:FireClient(player, "Weapons")
elseif role == "PowerShop" then
Remotes.Dialog:FireClient(player, name, "Every sailor hears the Cores whisper. Which will you answer?")
Remotes.OpenShop:FireClient(player, "Powers")
elseif role == "Travel" then
Remotes.Dialog:FireClient(player, name, "Where to? My ferry never sinks. Mostly.")
Remotes.OpenTravel:FireClient(player)
elseif role == "Healer" then
Data.ApplyHealth(player, true)
player:SetAttribute("Stamina", player:GetAttribute("MaxStamina"))
Remotes.Dialog:FireClient(player, name, "Sit, drink, rest. You're good as new.")
elseif role == "Villager" then
Remotes.Dialog:FireClient(player, name, npc:GetAttribute("Lines") or "Fair winds, traveler.")
elseif role == "Chest" then
local id = npc:GetAttribute("ChestId")
local c = Config.Chests[id]
if not c then return end
if d.Chests[id] then
Data.Notify(player, "This chest is already empty.", "info")
return
end
d.Chests[id] = true
Data.AddCoins(player, c.Coins)
Data.AddXP(player, c.XP)
Data.Notify(player, ("%s opened: +%d coins, +%d XP"):format(c.Name, c.Coins, c.XP), "reward")
Remotes.Sfx:FireClient(player, "Coin")
end
end)
end
function M.Start()
for _, npc in ipairs(CollectionService:GetTagged("NPC")) do bind(npc) end
CollectionService:GetInstanceAddedSignal("NPC"):Connect(bind)
Remotes.TravelRequest.OnServerEvent:Connect(function(player, id)
if typeof(id) ~= "string" or not Config.Islands[id] then return end
local root = Combat.GetPlayerRoot(player)
if not root then return end
local nearTravel = false
for _, npc in ipairs(CollectionService:GetTagged("NPC")) do
local r = npc:FindFirstChild("HumanoidRootPart")
if npc:GetAttribute("Role") == "Travel" and r and (r.Position - root.Position).Magnitude < 35 then nearTravel = true end
end
if not nearTravel then return end
local point = workspace.SpawnLocations:FindFirstChild("Travel_" .. id)
if not point then return end
root.CFrame = point.CFrame + Vector3.new(0, 5, 0)
Data.Notify(player, "Welcome to " .. Config.Islands[id].Name, "info")
end)
end
return M
]=====])
mk("ModuleScript", "BoatService", services, [=====[
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local CollectionService = game:GetService("CollectionService")
local Remotes = RS:WaitForChild("Remotes")
local M = {}
local boats = {} -- [model] = state
local WORLD_LIMIT = 1100
local rayParams = RaycastParams.new()
rayParams.FilterType = Enum.RaycastFilterType.Include
rayParams.FilterDescendantsInstances = { workspace.Terrain }
local function setup(model)
local hull = model.PrimaryPart
local helm = model:FindFirstChild("HelmSeat")
if not (hull and helm) then return end
local st = {
model = model, speed = 0, throttle = 0, steer = 0, driver = nil,
max = model:GetAttribute("MaxSpeed") or 42, turn = model:GetAttribute("TurnRate") or 0.9,
pos = model:GetPivot().Position, heading = math.atan2(-model:GetPivot().LookVector.X, -model:GetPivot().LookVector.Z),
t = math.random() * 10, roll = 0,
}
st.y = model:GetPivot().Position.Y
boats[model] = st
local function seatChanged(seat)
local occ = seat.Occupant
if seat == helm then
if occ then
local player = Players:GetPlayerFromCharacter(occ.Parent)
if player then
st.driver = player
seat:SetAttribute("Driver", player.UserId)
Remotes.BoatState:FireClient(player, true, model)
else
occ.Sit = false
end
elseif st.driver then
Remotes.BoatState:FireClient(st.driver, false, model)
st.driver = nil
st.throttle, st.steer = 0, 0
end
end
end
for _, s in ipairs(model:GetDescendants()) do
if s:IsA("Seat") then
s:GetPropertyChangedSignal("Occupant"):Connect(function() seatChanged(s) end)
end
if s:IsA("ProximityPrompt") then
s.Triggered:Connect(function(player)
local hum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
if not hum or hum.Health <= 0 then return end
if not helm.Occupant then helm:Sit(hum)
else
for _, seat in ipairs(model:GetDescendants()) do
if seat:IsA("Seat") and not seat.Occupant then seat:Sit(hum) break end
end
end
end)
end
end
end
function M.Start()
for _, m in ipairs(CollectionService:GetTagged("Boat")) do setup(m) end
Remotes.BoatInput.OnServerEvent:Connect(function(player, throttle, steer)
if typeof(throttle) ~= "number" or typeof(steer) ~= "number" then return end
for _, st in pairs(boats) do
if st.driver == player then
st.throttle = math.clamp(throttle, -1, 1)
st.steer = math.clamp(steer, -1, 1)
end
end
end)
RunService.Heartbeat:Connect(function(dt)
for model, st in pairs(boats) do
if not model.Parent then boats[model] = nil continue end
local target = st.throttle * (st.throttle < 0 and st.max * 0.35 or st.max)
st.speed += (target - st.speed) * math.min(1, dt * 0.9)
if math.abs(st.speed) < 0.05 then st.speed = 0 end
local turnScale = math.clamp(math.abs(st.speed) / 12, 0.15, 1)
st.heading -= st.steer * st.turn * dt * turnScale * (st.speed >= 0 and 1 or -1)
local fwd = Vector3.new(-math.sin(st.heading), 0, -math.cos(st.heading))
local move = fwd * st.speed * dt
if move.Magnitude > 0 then
local origin = Vector3.new(st.pos.X, 1.5, st.pos.Z)
local ahead = fwd * math.sign(st.speed) * (12 + math.abs(move.Magnitude))
local hit = workspace:Raycast(origin, ahead, rayParams)
local np = st.pos + move
if hit or math.abs(np.X) > WORLD_LIMIT or math.abs(np.Z) > WORLD_LIMIT then
st.speed = 0
else
st.pos = np
end
end
st.t += dt
st.roll += ((-st.steer * math.abs(st.speed) / st.max * 0.12) - st.roll) * math.min(1, dt * 3)
local bob = math.sin(st.t * 1.6) * 0.25
local cf = CFrame.new(st.pos.X, st.y + bob, st.pos.Z) * CFrame.Angles(0, st.heading, 0)
* CFrame.Angles(math.sin(st.t * 1.2) * 0.015, 0, st.roll)
model:PivotTo(cf)
if st.driver then model:SetAttribute("Speed", math.floor(math.abs(st.speed))) end
end
end)
end
return M
]=====])
mk("Script", "ServerMain", server, [=====[
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local CollectionService = game:GetService("CollectionService")
local Workspace = game:GetService("Workspace")
local Services = script.Parent:WaitForChild("Services")
local Data = require(Services.PlayerDataService)
local Combat = require(Services.CombatService)
local Power = require(Services.PowerService)
local Quest = require(Services.QuestService)
local Enemy = require(Services.EnemyService)
local Shop = require(Services.ShopService)
local NPC = require(Services.NPCService)
local Boat = require(Services.BoatService)
Players.RespawnTime = 5
Data.Start()
Combat.Start()
Power.Start()
Quest.Start()
Shop.Start()
NPC.Start()
Boat.Start()
Enemy.Start()
task.spawn(function()
while true do
task.wait(0.5)
local lava = CollectionService:GetTagged("Lava")
for _, p in ipairs(Players:GetPlayers()) do
local root, hum = Combat.GetPlayerRoot(p)
if root then
if root.Position.Y < -45 then hum.Health = 0 end
for _, l in ipairs(lava) do
local rel = l.CFrame:PointToObjectSpace(root.Position)
local h = l.Size / 2
if math.abs(rel.X) < h.X + 1 and math.abs(rel.Z) < h.Z + 1 and rel.Y > -6 and rel.Y < h.Y + 6 then
hum:TakeDamage(14)
break
end
end
end
end
end
end)
local beams = CollectionService:GetTagged("LighthouseBeam")
RunService.Heartbeat:Connect(function(dt)
for _, beam in ipairs(beams) do
if beam.Parent then
beam.CFrame = beam.CFrame * CFrame.Angles(0, dt * 0.8, 0)
end
end
end)
print("[Mythic Seas] Server ready")
]=====])
local client = mk("Folder", "Client", SPS)
local controllers = mk("Folder", "Controllers", client)
mk("ModuleScript", "AudioController", controllers, [=====[
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")
local CollectionService = game:GetService("CollectionService")
local RunService = game:GetService("RunService")
local Config = require(RS.Shared.Config)
local Remotes = RS:WaitForChild("Remotes")
local player = Players.LocalPlayer
local M = {}
local loops = {}
local function makeLoop(name, volume)
local s = Instance.new("Sound")
s.Name = name
s.Looped = true
s.Volume = 0
s.SoundId = Config.Audio[name] or ""
s.Parent = SoundService
loops[name] = { sound = s, target = 0, max = volume }
if s.SoundId ~= "" then s:Play() end
end
local function setTarget(name, on)
if loops[name] then loops[name].target = on and loops[name].max or 0 end
end
function M.Play(name, pos)
local id = Config.Audio[name]
if not id or id == "" then return end
local s = Instance.new("Sound")
s.SoundId = id
s.Volume = 0.7
if pos then
local a = Instance.new("Part")
a.Anchored, a.CanCollide, a.CanQuery, a.Transparency, a.Size, a.Position = true, false, false, 1, Vector3.one, pos
a.Parent = workspace
s.Parent = a
s.Ended:Connect(function() a:Destroy() end)
else
s.Parent = SoundService
s.Ended:Connect(function() s:Destroy() end)
end
s:Play()
end
function M.Click() M.Play("UIClick") end
function M.Start()
makeLoop("Ocean", 0.35)
for _, k in ipairs(Config.IslandOrder) do makeLoop(k, 0.45) end
makeLoop("BossMusic", 0.6)
setTarget("Ocean", true)
Remotes.Sfx.OnClientEvent:Connect(function(name, pos) M.Play(name, pos) end)
Remotes.LevelUp.OnClientEvent:Connect(function() M.Play("LevelUp") end)
local acc = 0
RunService.Heartbeat:Connect(function(dt)
acc += dt
if acc > 0.5 then
acc = 0
local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
if root then
for _, k in ipairs(Config.IslandOrder) do
local isl = Config.Islands[k]
local d = (Vector3.new(root.Position.X, 0, root.Position.Z) - isl.Center).Magnitude
setTarget(k, d < isl.Radius + 40)
end
local boss = false
for _, m in ipairs(CollectionService:GetTagged("Enemy")) do
local r = m:FindFirstChild("HumanoidRootPart")
if m:GetAttribute("Boss") and r and (r.Position - root.Position).Magnitude < 130 then boss = true break end
end
setTarget("BossMusic", boss)
end
end
for _, l in pairs(loops) do
l.sound.Volume += (l.target - l.sound.Volume) * math.min(1, dt * 2)
end
end)
end
return M
]=====])
mk("ModuleScript", "CombatController", controllers, [=====[
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local Debris = game:GetService("Debris")
local Config = require(RS.Shared.Config)
local U = require(RS.Shared.Utilities)
local Remotes = RS:WaitForChild("Remotes")
local player = Players.LocalPlayer
local M = {}
M.Cooldowns = {} -- [abilityId] = {start, duration}
local basicReady = 0
local function root() return player.Character and player.Character:FindFirstChild("HumanoidRootPart") end
function M.GetAimPoint()
local r = root()
local cam = workspace.CurrentCamera
if not r or not cam then return Vector3.zero end
if UIS.TouchEnabled and not UIS.MouseEnabled then
return r.Position + r.CFrame.LookVector * 40
end
local loc = UIS:GetMouseLocation()
local ray = cam:ViewportPointToRay(loc.X, loc.Y)
local params = RaycastParams.new()
params.FilterType = Enum.RaycastFilterType.Exclude
params.FilterDescendantsInstances = { player.Character }
local hit = workspace:Raycast(ray.Origin, ray.Direction * 600, params)
return hit and hit.Position or (ray.Origin + ray.Direction * 120)
end
local function faceAim(aim)
local r = root()
if not r then return end
local d = Vector3.new(aim.X - r.Position.X, 0, aim.Z - r.Position.Z)
if d.Magnitude > 1 then r.CFrame = CFrame.lookAt(r.Position, r.Position + d) end
end
function M.GetAbilities()
local p = Config.Powers[player:GetAttribute("Power") or "Cinder"]
return p and p.Abilities or {}
end
function M.CooldownLeft(id)
local c = M.Cooldowns[id]
if not c then return 0 end
return math.max(0, c.start + c.duration - os.clock())
end
function M.UseAbility(slot)
local ab = M.GetAbilities()[slot]
local hum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
if not ab or not hum or hum.Health <= 0 then return end
if M.CooldownLeft(ab.Id) > 0 then return end
local aim = M.GetAimPoint()
faceAim(aim)
Remotes.UseAbility:FireServer(slot, aim)
end
function M.BasicAttack()
local hum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
if not hum or hum.Health <= 0 or os.clock() < basicReady then return end
basicReady = os.clock() + 0.45
local aim = M.GetAimPoint()
faceAim(aim)
Remotes.BasicAttack:FireServer(aim)
end
local function damageNumber(pos, amount)
local p = Instance.new("Part")
p.Anchored, p.CanCollide, p.CanQuery, p.Transparency = true, false, false, 1
p.Size = Vector3.one
p.Position = pos
p.Parent = workspace
local bb = Instance.new("BillboardGui")
bb.Size = UDim2.fromOffset(100, 40)
bb.AlwaysOnTop = true
bb.Adornee = p
local t = Instance.new("TextLabel")
t.Size = UDim2.fromScale(1, 1)
t.BackgroundTransparency = 1
t.Font = Enum.Font.GothamBlack
t.TextSize = 26
t.Text = tostring(amount)
t.TextColor3 = Color3.fromRGB(255, 225, 120)
t.TextStrokeTransparency = 0.2
t.Parent = bb
bb.Parent = p
U.Tween(p, 0.8, { Position = pos + Vector3.new(math.random(-2, 2), 6, math.random(-2, 2)) })
U.Tween(t, 0.8, { TextTransparency = 1, TextStrokeTransparency = 1 })
Debris:AddItem(p, 1)
end
local function shake(pos, mag)
local r = root()
local hum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
if not r or not hum or (r.Position - pos).Magnitude > 160 then return end
task.spawn(function()
local t0 = os.clock()
local dur = 0.45 * mag
while os.clock() - t0 < dur do
local k = (1 - (os.clock() - t0) / dur) * mag
hum.CameraOffset = Vector3.new((math.random() - 0.5) * k, (math.random() - 0.5) * k, 0)
RunService.RenderStepped:Wait()
end
hum.CameraOffset = Vector3.zero
end)
end
function M.Start()
Remotes.Cooldown.OnClientEvent:Connect(function(id, dur)
M.Cooldowns[id] = { start = os.clock(), duration = dur }
end)
Remotes.Effect.OnClientEvent:Connect(function(kind, a, b, c)
if kind == "Damage" then
damageNumber(a, b)
elseif kind == "Dash" then
local r = root()
if not r then return end
local t0 = os.clock()
local conn
conn = RunService.Heartbeat:Connect(function()
local r2 = root()
if not r2 or os.clock() - t0 > c then conn:Disconnect() return end
r2.AssemblyLinearVelocity = Vector3.new(a.X * b, math.max(r2.AssemblyLinearVelocity.Y, 4), a.Z * b)
end)
elseif kind == "Shake" then
shake(a, b)
end
end)
end
return M
]=====])
mk("ModuleScript", "BoatController", controllers, [=====[
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local Remotes = RS:WaitForChild("Remotes")
local player = Players.LocalPlayer
local M = {}
local conn, gui, speedLabel
local currentBoat
local function buildHud()
gui = Instance.new("ScreenGui")
gui.Name = "BoatHUD"
gui.ResetOnSpawn = false
gui.Enabled = false
gui.Parent = player:WaitForChild("PlayerGui")
local f = Instance.new("Frame")
f.AnchorPoint = Vector2.new(0.5, 1)
f.Position = UDim2.new(0.5, 0, 1, -170)
f.Size = UDim2.fromOffset(280, 64)
f.BackgroundColor3 = Color3.fromRGB(12, 24, 42)
f.BackgroundTransparency = 0.15
f.Parent = gui
Instance.new("UICorner", f).CornerRadius = UDim.new(0, 14)
local st = Instance.new("UIStroke", f) st.Color = Color3.fromRGB(90, 190, 255) st.Thickness = 1.5
speedLabel = Instance.new("TextLabel")
speedLabel.BackgroundTransparency = 1
speedLabel.Size = UDim2.new(1, 0, 0.55, 0)
speedLabel.Font = Enum.Font.GothamBold
speedLabel.TextSize = 22
speedLabel.TextColor3 = Color3.new(1, 1, 1)
speedLabel.Text = "Speed 0"
speedLabel.Parent = f
local hint = Instance.new("TextLabel")
hint.BackgroundTransparency = 1
hint.Position = UDim2.fromScale(0, 0.55)
hint.Size = UDim2.fromScale(1, 0.4)
hint.Font = Enum.Font.Gotham
hint.TextSize = 13
hint.TextColor3 = Color3.fromRGB(170, 200, 230)
hint.Text = "W/S throttle  •  A/D steer  •  Space to leave"
hint.Parent = f
end
local function stop()
if conn then conn:Disconnect() conn = nil end
if gui then gui.Enabled = false end
currentBoat = nil
end
function M.Start()
buildHud()
Remotes.BoatState.OnClientEvent:Connect(function(on, boat)
stop()
if not on then return end
currentBoat = boat
gui.Enabled = true
local acc = 0
conn = RunService.RenderStepped:Connect(function(dt)
local hull = boat.PrimaryPart
local char = player.Character
local hum = char and char:FindFirstChildOfClass("Humanoid")
if not hull or not hum then return end
local throttle = (UIS:IsKeyDown(Enum.KeyCode.W) and 1 or 0) - (UIS:IsKeyDown(Enum.KeyCode.S) and 1 or 0)
local steer = (UIS:IsKeyDown(Enum.KeyCode.D) and 1 or 0) - (UIS:IsKeyDown(Enum.KeyCode.A) and 1 or 0)
if UIS.TouchEnabled and throttle == 0 and steer == 0 and hum.MoveDirection.Magnitude > 0.1 then
local look = hull.CFrame.LookVector
throttle = math.clamp(hum.MoveDirection:Dot(look), -1, 1)
steer = math.clamp(-look:Cross(hum.MoveDirection).Y, -1, 1)
end
acc += dt
if acc > 0.05 then
acc = 0
Remotes.BoatInput:FireServer(throttle, steer)
end
speedLabel.Text = "Speed  " .. tostring(boat:GetAttribute("Speed") or 0)
end)
end)
end
return M
]=====])
mk("ModuleScript", "InputController", controllers, [=====[
local RS = game:GetService("ReplicatedStorage")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local script_ = script.Parent
local Combat = require(script_.CombatController)
local UI = require(script_.UIController)
local M = {}
local keys = {
[Enum.KeyCode.One] = 1, [Enum.KeyCode.Two] = 2, [Enum.KeyCode.Three] = 3,
[Enum.KeyCode.Four] = 4, [Enum.KeyCode.Five] = 5,
}
local holding = false
function M.Start()
UIS.InputBegan:Connect(function(input, processed)
if processed then return end
if keys[input.KeyCode] then
Combat.UseAbility(keys[input.KeyCode])
elseif input.KeyCode == Enum.KeyCode.I then
UI.ToggleInventory()
elseif input.UserInputType == Enum.UserInputType.MouseButton1 then
holding = true
Combat.BasicAttack()
end
end)
UIS.InputEnded:Connect(function(input)
if input.UserInputType == Enum.UserInputType.MouseButton1 then holding = false end
end)
RunService.Heartbeat:Connect(function()
if holding then Combat.BasicAttack() end
end)
end
return M
]=====])
mk("ModuleScript", "UIController", controllers, [=====[
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UIS = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local CollectionService = game:GetService("CollectionService")
local Config = require(RS.Shared.Config)
local U = require(RS.Shared.Utilities)
local Remotes = RS:WaitForChild("Remotes")
local Combat = require(script.Parent.CombatController)
local Audio = require(script.Parent.AudioController)
local player = Players.LocalPlayer
local M = {}
local NAVY = Color3.fromRGB(12, 22, 40)
local PANEL = Color3.fromRGB(20, 34, 58)
local GOLD = Color3.fromRGB(255, 205, 100)
local TEXT = Color3.fromRGB(235, 242, 255)
local MUTED = Color3.fromRGB(150, 172, 205)
local GREEN = Color3.fromRGB(90, 210, 130)
local RED = Color3.fromRGB(230, 70, 80)
local function new(class, props, children)
local o = Instance.new(class)
for k, v in pairs(props or {}) do o[k] = v end
for _, c in ipairs(children or {}) do c.Parent = o end
return o
end
local function corner(r) return new("UICorner", { CornerRadius = UDim.new(0, r) }) end
local function stroke(color, th, tr) return new("UIStroke", { Color = color, Thickness = th or 1, Transparency = tr or 0 }) end
local function label(props)
local p = { BackgroundTransparency = 1, Font = Enum.Font.GothamMedium, TextColor3 = TEXT, TextSize = 16, Text = "" }
for k, v in pairs(props) do p[k] = v end
return new("TextLabel", p)
end
local function button(props)
local p = { AutoButtonColor = true, Font = Enum.Font.GothamBold, TextColor3 = TEXT, TextSize = 14, BackgroundColor3 = Color3.fromRGB(50, 90, 150), BorderSizePixel = 0 }
for k, v in pairs(props) do p[k] = v end
local b = new("TextButton", p, { corner(8) })
b.Activated:Connect(Audio.Click)
return b
end
local function bar(parent, color, pos, size, anchor)
local back = new("Frame", { BackgroundColor3 = Color3.fromRGB(8, 12, 22), BorderSizePixel = 0, Position = pos, Size = size, AnchorPoint = anchor or Vector2.zero, Parent = parent }, { corner(99), stroke(Color3.fromRGB(70, 90, 130), 1, 0.4) })
local fill = new("Frame", { BackgroundColor3 = color, BorderSizePixel = 0, Size = UDim2.fromScale(1, 1), Parent = back }, { corner(99) })
return back, fill
end
local function screen(name, order)
return new("ScreenGui", { Name = name, ResetOnSpawn = false, DisplayOrder = order or 1, IgnoreGuiInset = false, Parent = player:WaitForChild("PlayerGui") })
end
local hud, questGui, invGui, panelGui
local ui = {}
local slots = {}
local invFrame, shopFrame, travelFrame
local function getInv()
local ok, inv = pcall(function() return HttpService:JSONDecode(player:GetAttribute("Inventory") or "{}") end)
if ok and typeof(inv) == "table" then
inv.Weapons, inv.Powers, inv.Upgrades = inv.Weapons or {}, inv.Powers or {}, inv.Upgrades or {}
return inv
end
return { Weapons = {}, Powers = {}, Upgrades = {} }
end
local function has(list, id) return table.find(list, id) ~= nil end
local function buildHud()
hud = screen("MainHUD", 2)
local top = new("Frame", { AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.new(0.5, 0, 0, 10), Size = UDim2.fromOffset(440, 54), BackgroundColor3 = NAVY, BackgroundTransparency = 0.12, Parent = hud }, { corner(14), stroke(GOLD, 1.5, 0.35) })
ui.levelBadge = label({ Parent = top, Position = UDim2.fromOffset(8, 7), Size = UDim2.fromOffset(40, 40), BackgroundTransparency = 0, BackgroundColor3 = GOLD, TextColor3 = NAVY, Font = Enum.Font.GothamBlack, TextSize = 22, Text = "1" })
new("UICorner", { CornerRadius = UDim.new(1, 0), Parent = ui.levelBadge })
label({ Parent = top, Position = UDim2.fromOffset(58, 5), Size = UDim2.fromOffset(120, 18), Text = "LEVEL", Font = Enum.Font.GothamBold, TextSize = 12, TextColor3 = MUTED, TextXAlignment = Enum.TextXAlignment.Left })
ui.xpText = label({ Parent = top, Position = UDim2.new(1, -190, 0, 5), Size = UDim2.fromOffset(180, 18), Text = "0 / 100 XP", Font = Enum.Font.GothamBold, TextSize = 12, TextColor3 = TEXT, TextXAlignment = Enum.TextXAlignment.Right })
local back, fill = bar(top, Color3.fromRGB(110, 170, 255), UDim2.fromOffset(58, 28), UDim2.new(1, -72, 0, 14))
ui.xpFill = fill
new("UIGradient", { Color = ColorSequence.new(Color3.fromRGB(90, 150, 255), Color3.fromRGB(150, 110, 255)), Parent = fill })
local coins = new("Frame", { AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -16, 0, 12), Size = UDim2.fromOffset(170, 40), BackgroundColor3 = NAVY, BackgroundTransparency = 0.12, Parent = hud }, { corner(20), stroke(GOLD, 1.5, 0.35) })
local coin = label({ Parent = coins, Position = UDim2.fromOffset(6, 5), Size = UDim2.fromOffset(30, 30), BackgroundTransparency = 0, BackgroundColor3 = GOLD, Text = "$", TextColor3 = Color3.fromRGB(120, 80, 10), Font = Enum.Font.GothamBlack, TextSize = 20 })
new("UICorner", { CornerRadius = UDim.new(1, 0), Parent = coin })
ui.coins = label({ Parent = coins, Position = UDim2.fromOffset(44, 0), Size = UDim2.new(1, -54, 1, 0), Text = "250", Font = Enum.Font.GothamBold, TextSize = 20, TextColor3 = GOLD, TextXAlignment = Enum.TextXAlignment.Right })
local invBtn = button({ Parent = hud, Position = UDim2.fromOffset(16, 12), Size = UDim2.fromOffset(120, 40), BackgroundColor3 = NAVY, Text = "Inventory  [I]", BackgroundTransparency = 0.12 })
new("UIStroke", { Color = GOLD, Thickness = 1.5, Transparency = 0.35, Parent = invBtn })
invBtn.Activated:Connect(function() M.ToggleInventory() end)
local bottom = new("Frame", { AnchorPoint = Vector2.new(0.5, 1), Position = UDim2.new(0.5, 0, 1, -14), Size = UDim2.fromOffset(470, 150), BackgroundTransparency = 1, Parent = hud })
local hb, hf = bar(bottom, RED, UDim2.fromOffset(0, 0), UDim2.fromOffset(470, 16))
ui.hpFill = hf
ui.hpText = label({ Parent = hb, Size = UDim2.fromScale(1, 1), Font = Enum.Font.GothamBold, TextSize = 11, Text = "100 / 100", ZIndex = 3 })
local sb, sf = bar(bottom, Color3.fromRGB(255, 200, 60), UDim2.fromOffset(0, 22), UDim2.fromOffset(470, 10))
ui.stFill = sf
local row = new("Frame", { Position = UDim2.fromOffset(0, 40), Size = UDim2.fromOffset(470, 104), BackgroundTransparency = 1, Parent = bottom }, {
new("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 10), HorizontalAlignment = Enum.HorizontalAlignment.Center }),
})
for i = 1, 5 do
local b = new("TextButton", { Text = "", AutoButtonColor = false, Size = UDim2.fromOffset(84, 104), BackgroundColor3 = NAVY, BackgroundTransparency = 0.1, BorderSizePixel = 0, LayoutOrder = i, Parent = row }, { corner(12) })
local st = stroke(GOLD, 2, 0.2)
st.Parent = b
local icon = new("Frame", { Position = UDim2.fromOffset(8, 8), Size = UDim2.fromOffset(68, 58), BackgroundColor3 = GOLD, BorderSizePixel = 0, Parent = b }, { corner(9) })
local grad = new("UIGradient", { Rotation = 90, Parent = icon })
local glyph = label({ Parent = icon, Size = UDim2.fromScale(1, 1), Text = "", Font = Enum.Font.GothamBlack, TextSize = 28, TextColor3 = Color3.new(1, 1, 1), TextStrokeTransparency = 0.5 })
label({ Parent = b, Position = UDim2.fromOffset(5, 3), Size = UDim2.fromOffset(18, 18), Text = tostring(i), Font = Enum.Font.GothamBlack, TextSize = 14, ZIndex = 4, TextStrokeTransparency = 0.3 })
local name = label({ Parent = b, Position = UDim2.fromOffset(2, 68), Size = UDim2.new(1, -4, 0, 34), Text = "", Font = Enum.Font.GothamBold, TextSize = 11, TextWrapped = true, TextColor3 = TEXT })
local cd = new("Frame", { Position = UDim2.fromOffset(8, 8), Size = UDim2.fromOffset(68, 58), BackgroundColor3 = Color3.new(0, 0, 0), BackgroundTransparency = 0.35, BorderSizePixel = 0, Visible = false, ZIndex = 5, Parent = b }, { corner(9) })
local cdText = label({ Parent = cd, Size = UDim2.fromScale(1, 1), Text = "", Font = Enum.Font.GothamBlack, TextSize = 24, ZIndex = 6 })
b.Activated:Connect(function() Combat.UseAbility(i) end)
slots[i] = { btn = b, icon = icon, grad = grad, glyph = glyph, name = name, cd = cd, cdText = cdText, stroke = st }
end
if UIS.TouchEnabled then
local atk = button({ Parent = hud, AnchorPoint = Vector2.new(1, 1), Position = UDim2.new(1, -30, 1, -170), Size = UDim2.fromOffset(90, 90), Text = "ATTACK", TextSize = 16, BackgroundColor3 = Color3.fromRGB(200, 60, 60) })
new("UICorner", { CornerRadius = UDim.new(1, 0), Parent = atk })
atk.Activated:Connect(function() Combat.BasicAttack() end)
end
ui.toasts = new("Frame", { AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.new(0.5, 0, 0, 78), Size = UDim2.fromOffset(460, 200), BackgroundTransparency = 1, Parent = hud }, {
new("UIListLayout", { Padding = UDim.new(0, 6), HorizontalAlignment = Enum.HorizontalAlignment.Center }),
})
ui.dialog = new("Frame", { AnchorPoint = Vector2.new(0.5, 1), Position = UDim2.new(0.5, 0, 1, -178), Size = UDim2.fromOffset(520, 92), BackgroundColor3 = NAVY, BackgroundTransparency = 0.05, Visible = false, Parent = hud }, { corner(14), stroke(GOLD, 1.5, 0.2) })
ui.dialogName = label({ Parent = ui.dialog, Position = UDim2.fromOffset(16, 8), Size = UDim2.new(1, -32, 0, 22), Font = Enum.Font.GothamBlack, TextSize = 17, TextColor3 = GOLD, TextXAlignment = Enum.TextXAlignment.Left })
ui.dialogText = label({ Parent = ui.dialog, Position = UDim2.fromOffset(16, 32), Size = UDim2.new(1, -32, 0, 54), TextSize = 15, TextWrapped = true, TextXAlignment = Enum.TextXAlignment.Left, TextYAlignment = Enum.TextYAlignment.Top })
ui.boss = new("Frame", { AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.new(0.5, 0, 0, 74), Size = UDim2.fromOffset(560, 44), BackgroundTransparency = 1, Visible = false, Parent = hud })
ui.bossName = label({ Parent = ui.boss, Size = UDim2.new(1, 0, 0, 22), Font = Enum.Font.GothamBlack, TextSize = 20, TextColor3 = Color3.fromRGB(255, 190, 90), TextStrokeTransparency = 0.3 })
local bb, bf = bar(ui.boss, Color3.fromRGB(210, 40, 50), UDim2.fromOffset(0, 26), UDim2.new(1, 0, 0, 16))
ui.bossFill = bf
end
local function buildQuest()
questGui = screen("QuestUI", 2)
local f = new("Frame", { AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -14, 0.38, 0), Size = UDim2.fromOffset(270, 150), BackgroundColor3 = NAVY, BackgroundTransparency = 0.12, Parent = questGui }, { corner(14), stroke(GOLD, 1.5, 0.35) })
label({ Parent = f, Position = UDim2.fromOffset(14, 8), Size = UDim2.new(1, -28, 0, 16), Text = "ACTIVE QUEST", Font = Enum.Font.GothamBold, TextSize = 12, TextColor3 = GOLD, TextXAlignment = Enum.TextXAlignment.Left })
ui.qName = label({ Parent = f, Position = UDim2.fromOffset(14, 26), Size = UDim2.new(1, -28, 0, 24), Font = Enum.Font.GothamBlack, TextSize = 18, TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd })
ui.qDesc = label({ Parent = f, Position = UDim2.fromOffset(14, 52), Size = UDim2.new(1, -28, 0, 40), TextSize = 14, TextColor3 = MUTED, TextWrapped = true, TextXAlignment = Enum.TextXAlignment.Left, TextYAlignment = Enum.TextYAlignment.Top })
local b, fl = bar(f, GREEN, UDim2.fromOffset(14, 96), UDim2.new(1, -28, 0, 14))
ui.qFill = fl
ui.qCount = label({ Parent = b, Size = UDim2.fromScale(1, 1), Font = Enum.Font.GothamBold, TextSize = 11, ZIndex = 3 })
ui.qReward = label({ Parent = f, Position = UDim2.fromOffset(14, 118), Size = UDim2.new(1, -28, 0, 22), TextSize = 13, TextColor3 = GOLD, TextXAlignment = Enum.TextXAlignment.Left })
end
local function modal(title, width, height)
local overlay = new("Frame", { Size = UDim2.fromScale(1, 1), BackgroundColor3 = Color3.new(0, 0, 0), BackgroundTransparency = 0.55, Visible = false, Active = true, Parent = panelGui })
local f = new("Frame", { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromOffset(width, height), BackgroundColor3 = NAVY, Parent = overlay }, { corner(16), stroke(GOLD, 2, 0.2) })
local titleL = label({ Parent = f, Position = UDim2.fromOffset(20, 12), Size = UDim2.new(1, -80, 0, 32), Text = title, Font = Enum.Font.GothamBlack, TextSize = 24, TextColor3 = GOLD, TextXAlignment = Enum.TextXAlignment.Left })
local close = button({ Parent = f, AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -14, 0, 12), Size = UDim2.fromOffset(34, 34), Text = "X", BackgroundColor3 = Color3.fromRGB(170, 50, 60) })
close.Activated:Connect(function() overlay.Visible = false end)
local body = new("ScrollingFrame", { Position = UDim2.fromOffset(16, 56), Size = UDim2.new(1, -32, 1, -72), BackgroundTransparency = 1, BorderSizePixel = 0, ScrollBarThickness = 5, AutomaticCanvasSize = Enum.AutomaticSize.Y, CanvasSize = UDim2.new(), Parent = f }, {
new("UIListLayout", { Padding = UDim.new(0, 8) }),
})
return { overlay = overlay, frame = f, body = body, title = titleL }
end
local function clear(body)
for _, c in ipairs(body:GetChildren()) do
if c:IsA("GuiObject") then c:Destroy() end
end
end
local function row(body, order, height)
return new("Frame", { Size = UDim2.new(1, -8, 0, height or 72), BackgroundColor3 = PANEL, BorderSizePixel = 0, LayoutOrder = order, Parent = body }, { corner(10) })
end
local function request(action, id)
local ok, success, msg = pcall(function() return Remotes.ShopRequest:InvokeServer(action, id) end)
if ok and msg then M.Toast(msg, success and "reward" or "error") end
end
local function refreshWeapons()
local m = shopFrame
clear(m.body)
local inv = getInv()
local coins = player:GetAttribute("Coins") or 0
local equipped = player:GetAttribute("Weapon")
for i, w in ipairs(Config.Weapons) do
local r = row(m.body, i, 76)
local swatch = new("Frame", { Position = UDim2.fromOffset(10, 12), Size = UDim2.fromOffset(10, 52), BackgroundColor3 = w.Color, BorderSizePixel = 0, Parent = r }, { corner(5) })
local up = inv.Upgrades[w.Id] or 0
label({ Parent = r, Position = UDim2.fromOffset(32, 8), Size = UDim2.new(0.5, 0, 0, 24), Text = w.Name .. (up > 0 and ("  +" .. up) or ""), Font = Enum.Font.GothamBold, TextSize = 18, TextXAlignment = Enum.TextXAlignment.Left })
label({ Parent = r, Position = UDim2.fromOffset(32, 34), Size = UDim2.new(0.5, 0, 0, 20), Text = ("Damage %d"):format(math.floor(Config.WeaponDamage(w.Id, up))), TextSize = 14, TextColor3 = MUTED, TextXAlignment = Enum.TextXAlignment.Left })
local owned = has(inv.Weapons, w.Id)
local bx = 0
local function add(text, color, cb, enabled)
local b = button({ Parent = r, AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -10 - bx, 0.5, 0), Size = UDim2.fromOffset(112, 38), Text = text, BackgroundColor3 = enabled and color or Color3.fromRGB(60, 66, 80), TextSize = 13 })
b.Activated:Connect(cb)
bx += 120
end
if not owned then
add(w.Price == 0 and "Free" or ("Buy  $" .. U.Comma(w.Price)), GREEN, function() request("Buy", w.Id) end, coins >= w.Price)
else
if up < Config.MaxUpgrade then
add(("Upgrade $%s"):format(U.Comma(Config.UpgradeCost(w, up))), Color3.fromRGB(150, 100, 230), function() request("Upgrade", w.Id) end, coins >= Config.UpgradeCost(w, up))
else
add("MAX", Color3.fromRGB(60, 66, 80), function() end, false)
end
add(equipped == w.Id and "Equipped" or "Equip", Color3.fromRGB(60, 130, 220), function() request("Equip", w.Id) end, equipped ~= w.Id)
end
end
end
local function refreshPowers()
local m = shopFrame
clear(m.body)
local inv = getInv()
local coins = player:GetAttribute("Coins") or 0
local equipped = player:GetAttribute("Power")
for i, id in ipairs(Config.PowerOrder) do
local p = Config.Powers[id]
local r = row(m.body, i, 128)
new("Frame", { Position = UDim2.fromOffset(10, 12), Size = UDim2.fromOffset(10, 104), BackgroundColor3 = p.Color, BorderSizePixel = 0, Parent = r }, { corner(5) })
label({ Parent = r, Position = UDim2.fromOffset(32, 8), Size = UDim2.new(0.6, 0, 0, 26), Text = p.Name, Font = Enum.Font.GothamBlack, TextSize = 21, TextColor3 = p.Color, TextXAlignment = Enum.TextXAlignment.Left })
label({ Parent = r, Position = UDim2.fromOffset(32, 36), Size = UDim2.new(0.6, 0, 0, 20), Text = p.Desc, TextSize = 13, TextColor3 = MUTED, TextXAlignment = Enum.TextXAlignment.Left })
local names = {}
for _, a in ipairs(p.Abilities) do table.insert(names, a.Name) end
label({ Parent = r, Position = UDim2.fromOffset(32, 60), Size = UDim2.new(0.62, 0, 0, 56), Text = table.concat(names, "  •  "), TextSize = 13, TextWrapped = true, TextYAlignment = Enum.TextYAlignment.Top, TextXAlignment = Enum.TextXAlignment.Left })
local owned = has(inv.Powers, id)
local b
if owned then
b = button({ Parent = r, AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -12, 0.5, 0), Size = UDim2.fromOffset(130, 42), Text = equipped == id and "Equipped" or "Equip", BackgroundColor3 = equipped == id and Color3.fromRGB(60, 66, 80) or Color3.fromRGB(60, 130, 220) })
b.Activated:Connect(function() request("EquipPower", id) end)
else
b = button({ Parent = r, AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -12, 0.5, 0), Size = UDim2.fromOffset(130, 42), Text = "Buy  $" .. U.Comma(p.Price), BackgroundColor3 = coins >= p.Price and GREEN or Color3.fromRGB(60, 66, 80) })
b.Activated:Connect(function() request("BuyPower", id) end)
end
end
end
local shopKind
local function refreshShop()
if not shopFrame.overlay.Visible then return end
if shopKind == "Weapons" then refreshWeapons() else refreshPowers() end
end
function M.OpenShop(kind)
shopKind = kind
shopFrame.title.Text = kind == "Weapons" and "Cutlass & Cannon — Weapon Shop" or "Coral's Curios — Power Shop"
shopFrame.overlay.Visible = true
refreshShop()
end
local function buildTravel()
travelFrame = modal("Ferry — Choose a Destination", 460, 380)
end
function M.OpenTravel()
clear(travelFrame.body)
for i, id in ipairs(Config.IslandOrder) do
local isl = Config.Islands[id]
local r = row(travelFrame.body, i, 68)
label({ Parent = r, Position = UDim2.fromOffset(16, 8), Size = UDim2.new(0.6, 0, 0, 26), Text = isl.Name, Font = Enum.Font.GothamBold, TextSize = 20, TextXAlignment = Enum.TextXAlignment.Left })
label({ Parent = r, Position = UDim2.fromOffset(16, 36), Size = UDim2.new(0.6, 0, 0, 20), Text = "Recommended level " .. isl.Level, TextSize = 13, TextColor3 = MUTED, TextXAlignment = Enum.TextXAlignment.Left })
local b = button({ Parent = r, AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -12, 0.5, 0), Size = UDim2.fromOffset(110, 38), Text = "Sail", BackgroundColor3 = Color3.fromRGB(60, 130, 220) })
b.Activated:Connect(function()
Remotes.TravelRequest:FireServer(id)
travelFrame.overlay.Visible = false
end)
end
travelFrame.overlay.Visible = true
end
local function refreshInventory()
if not invFrame.overlay.Visible then return end
local m = invFrame
clear(m.body)
local inv = getInv()
local lvl = player:GetAttribute("Level") or 1
local order = 0
local function header(text)
order += 1
label({ Parent = m.body, Size = UDim2.new(1, -8, 0, 26), Text = text, Font = Enum.Font.GothamBlack, TextSize = 16, TextColor3 = GOLD, TextXAlignment = Enum.TextXAlignment.Left, LayoutOrder = order })
end
header(("Level %d   •   %s coins"):format(lvl, U.Comma(player:GetAttribute("Coins") or 0)))
header("Weapons")
for _, w in ipairs(Config.Weapons) do
if has(inv.Weapons, w.Id) then
order += 1
local r = row(m.body, order, 52)
local up = inv.Upgrades[w.Id] or 0
label({ Parent = r, Position = UDim2.fromOffset(16, 0), Size = UDim2.new(0.6, 0, 1, 0), Text = ("%s%s   (dmg %d)"):format(w.Name, up > 0 and (" +" .. up) or "", math.floor(Config.WeaponDamage(w.Id, up))), Font = Enum.Font.GothamBold, TextXAlignment = Enum.TextXAlignment.Left })
local eq = player:GetAttribute("Weapon") == w.Id
local b = button({ Parent = r, AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -10, 0.5, 0), Size = UDim2.fromOffset(100, 34), Text = eq and "Equipped" or "Equip", BackgroundColor3 = eq and Color3.fromRGB(60, 66, 80) or Color3.fromRGB(60, 130, 220) })
b.Activated:Connect(function() request("Equip", w.Id) end)
end
end
header("Powers")
for _, id in ipairs(Config.PowerOrder) do
if has(inv.Powers, id) then
order += 1
local p = Config.Powers[id]
local r = row(m.body, order, 52)
label({ Parent = r, Position = UDim2.fromOffset(16, 0), Size = UDim2.new(0.6, 0, 1, 0), Text = p.Name, Font = Enum.Font.GothamBold, TextColor3 = p.Color, TextXAlignment = Enum.TextXAlignment.Left })
local eq = player:GetAttribute("Power") == id
local b = button({ Parent = r, AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -10, 0.5, 0), Size = UDim2.fromOffset(100, 34), Text = eq and "Equipped" or "Equip", BackgroundColor3 = eq and Color3.fromRGB(60, 66, 80) or Color3.fromRGB(60, 130, 220) })
b.Activated:Connect(function() request("EquipPower", id) end)
end
end
end
function M.ToggleInventory()
invFrame.overlay.Visible = not invFrame.overlay.Visible
refreshInventory()
end
local toastColors = { info = Color3.fromRGB(110, 170, 255), reward = GREEN, quest = GOLD, error = RED, levelup = Color3.fromRGB(190, 130, 255) }
function M.Toast(text, kind)
local c = toastColors[kind] or toastColors.info
local t = new("Frame", { Size = UDim2.fromOffset(440, 36), BackgroundColor3 = NAVY, BackgroundTransparency = 1, Parent = ui.toasts }, { corner(10), stroke(c, 1.5, 1) })
local l = label({ Parent = t, Size = UDim2.new(1, -16, 1, 0), Position = UDim2.fromOffset(8, 0), Text = text, TextSize = 14, Font = Enum.Font.GothamBold, TextColor3 = c, TextTransparency = 1, TextTruncate = Enum.TextTruncate.AtEnd })
TweenService:Create(t, TweenInfo.new(0.25), { BackgroundTransparency = 0.1 }):Play()
TweenService:Create(t.UIStroke, TweenInfo.new(0.25), { Transparency = 0.2 }):Play()
TweenService:Create(l, TweenInfo.new(0.25), { TextTransparency = 0 }):Play()
task.delay(4, function()
TweenService:Create(t, TweenInfo.new(0.4), { BackgroundTransparency = 1 }):Play()
TweenService:Create(t.UIStroke, TweenInfo.new(0.4), { Transparency = 1 }):Play()
TweenService:Create(l, TweenInfo.new(0.4), { TextTransparency = 1 }):Play()
task.wait(0.45)
t:Destroy()
end)
end
local dialogToken = 0
function M.Dialog(name, text)
dialogToken += 1
local my = dialogToken
ui.dialogName.Text = name
ui.dialogText.Text = text
ui.dialog.Visible = true
task.delay(7, function() if my == dialogToken then ui.dialog.Visible = false end end)
end
local function refreshStats()
local lvl = player:GetAttribute("Level") or 1
local xp, need = player:GetAttribute("XP") or 0, player:GetAttribute("XPNeeded") or 100
ui.levelBadge.Text = tostring(lvl)
ui.xpText.Text = ("%s / %s XP"):format(U.Comma(xp), U.Comma(need))
TweenService:Create(ui.xpFill, TweenInfo.new(0.3), { Size = UDim2.fromScale(math.clamp(xp / need, 0, 1), 1) }):Play()
ui.coins.Text = U.Comma(player:GetAttribute("Coins") or 0)
end
local function refreshQuest()
local id = player:GetAttribute("QuestId")
if id and id ~= "" then
local goal, prog = player:GetAttribute("QuestGoal") or 1, player:GetAttribute("QuestProgress") or 0
ui.qName.Text = player:GetAttribute("QuestName") or ""
ui.qDesc.Text = player:GetAttribute("QuestDesc") or ""
ui.qCount.Text = ("%d / %d"):format(prog, goal)
ui.qReward.Text = "Reward: " .. (player:GetAttribute("QuestReward") or "")
TweenService:Create(ui.qFill, TweenInfo.new(0.3), { Size = UDim2.fromScale(math.clamp(prog / goal, 0, 1), 1) }):Play()
else
ui.qName.Text = "No active quest"
ui.qDesc.Text = "Speak with a quest giver (Captain Marlow at the Haven plaza)."
ui.qCount.Text = ""
ui.qReward.Text = ""
ui.qFill.Size = UDim2.fromScale(0, 1)
end
end
local function refreshHotbar()
local power = Config.Powers[player:GetAttribute("Power") or "Cinder"]
if not power then return end
for i, s in ipairs(slots) do
local ab = power.Abilities[i]
if ab then
s.name.Text = ab.Name
s.glyph.Text = ab.Name:sub(1, 1)
s.grad.Color = ColorSequence.new(power.Color, power.Color:Lerp(Color3.new(0, 0, 0), 0.55))
s.stroke.Color = power.Color
end
end
end
local function bindHealth(char)
local hum = char:WaitForChild("Humanoid", 10)
if not hum then return end
local function upd()
ui.hpFill.Size = UDim2.fromScale(math.clamp(hum.Health / hum.MaxHealth, 0, 1), 1)
ui.hpText.Text = ("%d / %d"):format(math.ceil(hum.Health), hum.MaxHealth)
end
hum.HealthChanged:Connect(upd)
hum:GetPropertyChangedSignal("MaxHealth"):Connect(upd)
upd()
end
function M.Start()
panelGui = screen("InventoryUI", 5)
buildHud()
buildQuest()
invFrame = modal("Inventory", 520, 480)
shopFrame = modal("Shop", 640, 520)
buildTravel()
player:GetAttributeChangedSignal("Level"):Connect(refreshStats)
player:GetAttributeChangedSignal("XP"):Connect(refreshStats)
player:GetAttributeChangedSignal("XPNeeded"):Connect(refreshStats)
player:GetAttributeChangedSignal("Coins"):Connect(function() refreshStats() refreshShop() refreshInventory() end)
player:GetAttributeChangedSignal("Inventory"):Connect(function() refreshShop() refreshInventory() end)
player:GetAttributeChangedSignal("Weapon"):Connect(function() refreshShop() refreshInventory() end)
player:GetAttributeChangedSignal("Power"):Connect(function() refreshHotbar() refreshShop() refreshInventory() end)
for _, a in ipairs({ "QuestId", "QuestProgress", "QuestGoal", "QuestName" }) do
player:GetAttributeChangedSignal(a):Connect(refreshQuest)
end
refreshStats() refreshQuest() refreshHotbar()
if player.Character then task.spawn(bindHealth, player.Character) end
player.CharacterAdded:Connect(bindHealth)
Remotes.Notify.OnClientEvent:Connect(M.Toast)
Remotes.Dialog.OnClientEvent:Connect(M.Dialog)
Remotes.OpenShop.OnClientEvent:Connect(M.OpenShop)
Remotes.OpenTravel.OnClientEvent:Connect(M.OpenTravel)
Remotes.LevelUp.OnClientEvent:Connect(function(lvl) M.Toast("LEVEL UP!  You are now level " .. lvl, "levelup") end)
RunService.RenderStepped:Connect(function()
local abilities = Combat.GetAbilities()
for i, s in ipairs(slots) do
local ab = abilities[i]
local left = ab and Combat.CooldownLeft(ab.Id) or 0
s.cd.Visible = left > 0
if left > 0 then s.cdText.Text = left >= 10 and tostring(math.ceil(left)) or string.format("%.1f", left) end
end
local st, mx = player:GetAttribute("Stamina") or 0, player:GetAttribute("MaxStamina") or 100
ui.stFill.Size = UDim2.fromScale(math.clamp(st / mx, 0, 1), 1)
local char = player.Character
local root = char and char:FindFirstChild("HumanoidRootPart")
local shown = false
if root then
for _, m in ipairs(CollectionService:GetTagged("Enemy")) do
local r, h = m:FindFirstChild("HumanoidRootPart"), m:FindFirstChildOfClass("Humanoid")
if m:GetAttribute("Boss") and r and h and h.Health > 0 and (r.Position - root.Position).Magnitude < 140 then
shown = true
ui.bossName.Text = (m:GetAttribute("BossName") or "Boss"):upper()
ui.bossFill.Size = UDim2.fromScale(math.clamp(h.Health / h.MaxHealth, 0, 1), 1)
break
end
end
end
ui.boss.Visible = shown
end)
end
return M
]=====])
mk("LocalScript", "ClientMain", client, [=====[
local Controllers = script.Parent:WaitForChild("Controllers")
local Audio = require(Controllers.AudioController)
local Combat = require(Controllers.CombatController)
local UI = require(Controllers.UIController)
local Input = require(Controllers.InputController)
local Boat = require(Controllers.BoatController)
Audio.Start()
Combat.Start()
UI.Start()
Input.Start()
Boat.Start()
]=====])
print("[Mythic Seas] scripts installed")
end
do
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local CS = game:GetService("CollectionService")
local Terrain = Workspace.Terrain
local V, CF, ANG = Vector3.new, CFrame.new, CFrame.Angles
local PI = math.pi
local M = Enum.Material
local R = Random.new(1337)
local function rr(a, b) return R:NextNumber(a, b) end
local function ri(a, b) return R:NextInteger(a, b) end
local W = {}          -- builder functions
local WORLD = {}      -- world state (folders, island params)
local C = {
plank = Color3.fromRGB(150, 105, 65), darkwood = Color3.fromRGB(88, 58, 36), wood = Color3.fromRGB(125, 85, 52),
floor = Color3.fromRGB(120, 85, 55), stone = Color3.fromRGB(125, 125, 130), darkstone = Color3.fromRGB(70, 70, 78),
roof = Color3.fromRGB(150, 60, 45), thatch = Color3.fromRGB(190, 160, 85), sail = Color3.fromRGB(235, 228, 205),
rope = Color3.fromRGB(190, 165, 110), shipwood = Color3.fromRGB(110, 72, 44), deck = Color3.fromRGB(170, 125, 80),
leaf = Color3.fromRGB(70, 140, 60), leaf2 = Color3.fromRGB(95, 160, 65), palm = Color3.fromRGB(80, 160, 70),
trunk = Color3.fromRGB(105, 72, 45), gold = Color3.fromRGB(235, 190, 70), iron = Color3.fromRGB(60, 62, 70),
glass = Color3.fromRGB(170, 215, 240), lava = Color3.fromRGB(255, 110, 20), ice = Color3.fromRGB(170, 225, 255),
snow = Color3.fromRGB(240, 246, 255), basalt = Color3.fromRGB(45, 40, 42), white = Color3.fromRGB(240, 240, 240),
}
local function P(parent, size, cf, color, mat, o)
local p = Instance.new("Part")
p.Anchored = true
p.TopSurface = Enum.SurfaceType.Smooth
p.BottomSurface = Enum.SurfaceType.Smooth
p.Size = size
p.CFrame = cf
p.Color = color
p.Material = mat or M.Plastic
if o then for k, v in pairs(o) do p[k] = v end end
p.Parent = parent
return p
end
local function Cyl(parent, cf, height, dia, color, mat, o) -- vertical cylinder (axis = cf's Y)
local p = P(parent, V(height, dia, dia), cf * ANG(0, 0, PI / 2), color, mat, o)
p.Shape = Enum.PartType.Cylinder
return p
end
local function Ball(parent, cf, dia, color, mat, o)
local p = P(parent, V(dia, dia, dia), cf, color, mat, o)
p.Shape = Enum.PartType.Ball
return p
end
local function Model(parent, name)
local m = Instance.new("Model")
m.Name = name
m.Parent = parent
return m
end
local function Light(part, color, range, brightness)
local l = Instance.new("PointLight")
l.Color, l.Range, l.Brightness = color, range or 16, brightness or 1.5
l.Shadows = false
l.Parent = part
return l
end
local function Fire(part, size, heat)
local f = Instance.new("Fire")
f.Size, f.Heat = size or 6, heat or 8
f.Parent = part
return f
end
local function Emitter(part, props)
local e = Instance.new("ParticleEmitter")
for k, v in pairs(props) do e[k] = v end
e.Parent = part
return e
end
local function tag(inst, name) CS:AddTag(inst, name) end
local function smooth(t) t = math.clamp(t, 0, 1) return t * t * (3 - 2 * t) end
local function deco(o) o = o or {} o.CanCollide = false o.CanQuery = false return o end
local groundParams = RaycastParams.new()
groundParams.FilterType = Enum.RaycastFilterType.Include
groundParams.FilterDescendantsInstances = { Terrain }
groundParams.IgnoreWater = true
local function groundY(x, z, fallback)
local r = Workspace:Raycast(V(x, 400, z), V(0, -800, 0), groundParams)
return r and r.Position.Y or (fallback or 0)
end
local function gpos(x, z, up) return V(x, groundY(x, z) + (up or 0), z) end
local function sign(parent, cf, text, size, bg, fg)
local p = P(parent, size or V(6, 2, 0.4), cf, bg or C.darkwood, M.Wood)
local g = Instance.new("SurfaceGui")
g.Face = Enum.NormalId.Front
g.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
g.PixelsPerStud = 40
g.Parent = p
local t = Instance.new("TextLabel")
t.Size = UDim2.fromScale(1, 1)
t.BackgroundTransparency = 1
t.Font = Enum.Font.GothamBold
t.TextScaled = true
t.Text = text
t.TextColor3 = fg or Color3.fromRGB(245, 215, 140)
t.Parent = g
local g2 = g:Clone()
g2.Face = Enum.NormalId.Back
g2.Parent = p
return p
end
local ISL = {
Haven = { c = V(0, 0, 0), R = 200, peak = 16, amp = 6, seed = 0.31 },
Ember = { c = V(780, 0, 0), R = 230, peak = 14, amp = 7, seed = 0.57 },
Moonveil = { c = V(-780, 0, 0), R = 230, peak = 22, amp = 10, seed = 0.83 },
Frost = { c = V(0, 0, -780), R = 230, peak = 22, amp = 6, seed = 0.19 },
}
ISL.Haven.flats = {
{ 0, 0, 75, 8 }, { -110, 45, 30, 9 }, { 120, -95, 22, 12 }, { -75, -80, 24, -3, 10 },
}
ISL.Ember.flats = {
{ -120, 60, 32, 12 }, { -90, -110, 58, 16 }, { 140, 10, 26, 10 }, { -100, -25, 22, 10 }, { -45, 115, 22, 10 }, { -165, 15, 20, 6 },
}
ISL.Ember.rivers = {
{ { { 20, 25 }, { 45, 60 }, { 75, 95 }, { 95, 135 }, { 105, 175 }, { 115, 215 } }, 7, 3.5 },
{ { { 22, -22 }, { 55, -50 }, { 85, -70 }, { 125, -100 }, { 150, -140 }, { 165, -180 } }, 7, 3.5 },
}
ISL.Moonveil.flats = {
{ 0, -70, 38, 26 }, { 170, 10, 18, 8 }, { -90, 50, 24, -3, 10 }, { 95, 50, 28, 56, 6 }, { 48, 50, 16, -3, 8 },
}
ISL.Moonveil.ramps = { { 140, 50, 100, 50, 5, 10, 56 } }
ISL.Frost.flats = {
{ 0, -95, 62, 28, 14 }, { 0, 70, 48, 12 }, { -105, 25, 46, 1.4, 12 },
}
ISL.Frost.rivers = { { { { -90, -46 }, { -40, -46 }, { 0, -46 }, { 40, -46 }, { 90, -46 } }, 4, 9 } }
local function segDist(px, pz, ax, az, bx, bz)
local dx, dz = bx - ax, bz - az
local l2 = dx * dx + dz * dz
local t = l2 > 0 and math.clamp(((px - ax) * dx + (pz - az) * dz) / l2, 0, 1) or 0
local cx, cz = ax + dx * t, az + dz * t
return math.sqrt((px - cx) ^ 2 + (pz - cz) ^ 2), t
end
local function emberExtra(lx, lz, h)
local vd = math.sqrt(lx * lx + lz * lz)
local vr, vh, cr = 115, 80, 26
if vd < vr then
local cone = vh * (1 - vd / vr) ^ 0.9
if vd < cr then
local rim = vh * (1 - cr / vr) ^ 0.9
cone = rim - 14 * smooth((cr - vd) / 9)
end
h = math.max(h, cone)
end
return h
end
local function H(isl, lx, lz)
local d = math.sqrt(lx * lx + lz * lz) / isl.R
if d >= 1.3 then return -40 end
local base = d < 1 and isl.peak * (1 - d ^ 2.2) or -(d - 1) * 90
local fall = math.clamp(1 - d, 0, 1) ^ 0.5
local h = base + math.noise(lx / 60, lz / 60, isl.seed) * isl.amp * fall
+ math.noise(lx / 17, lz / 17, isl.seed + 5) * isl.amp * 0.18 * fall
for _, f in ipairs(isl.flats or {}) do
local dist = math.sqrt((lx - f[1]) ^ 2 + (lz - f[2]) ^ 2)
local bw = f[5] or 18
local w = smooth((f[3] + bw - dist) / bw)
h = h * (1 - w) + f[4] * w
end
for _, rp in ipairs(isl.ramps or {}) do
local dist, t = segDist(lx, lz, rp[1], rp[2], rp[3], rp[4])
local w = smooth((rp[5] + 4 - dist) / 4)
if w > 0 then h = math.max(h, h * (1 - w) + (rp[6] + (rp[7] - rp[6]) * t) * w) end
end
if isl.extra then h = isl.extra(lx, lz, h) end
for _, rv in ipairs(isl.rivers or {}) do
local best = 1e9
for i = 1, #rv[1] - 1 do
local a, b = rv[1][i], rv[1][i + 1]
best = math.min(best, (segDist(lx, lz, a[1], a[2], b[1], b[2])))
end
local w = smooth((rv[2] + 6 - best) / 6)
h = h - w * rv[3]
end
return h
end
ISL.Ember.extra = emberExtra
local function Hw(name, x, z) local i = ISL[name] return H(i, x - i.c.X, z - i.c.Z) end
local MATF = {}
MATF.Haven = function(lx, lz, h, steep)
if h < 3.2 then return M.Sand end
if steep > 7 then return M.Rock end
local dd = math.sqrt(lx * lx + lz * lz)
if dd < 28 then return M.Cobblestone end
if math.noise(lx / 25, lz / 25, 9.1) > 0.35 then return M.Ground end
return M.Grass
end
MATF.Ember = function(lx, lz, h, steep)
local vd = math.sqrt(lx * lx + lz * lz)
if vd < 44 and h > 40 then return M.CrackedLava end
if steep > 7 then return M.Slate end
if h < 3 then return M.Ground end
if math.noise(lx / 20, lz / 20, 3.3) > 0.3 then return M.Rock end
return M.Basalt
end
MATF.Moonveil = function(lx, lz, h, steep)
if h < 3 then return M.Sand end
if steep > 6.5 then return M.Rock end
if math.noise(lx / 30, lz / 30, 7.7) > 0.4 then return M.Mud end
return M.LeafyGrass
end
MATF.Frost = function(lx, lz, h, steep)
local ld = math.sqrt((lx + 105) ^ 2 + (lz - 25) ^ 2)
if ld < 50 and h < 3 then return M.Ice end
if h < 3 then return M.Glacier end
if steep > 6.5 then return M.Ice end
return M.Snow
end
local fillCount = 0
local function buildIsland(name)
local isl = ISL[name]
local step = 4
local ext = math.floor(isl.R * 1.3 / step)
local cx, cz = isl.c.X, isl.c.Z
for xi = -ext, ext do
local lx = xi * step
local runStart, runKey, runH, runMat
local function flush(zEndIndex)
if not runKey then return end
local n = zEndIndex - runStart
local sy = runH + 26
Terrain:FillBlock(CF(cx + lx, (runH - 26) / 2, cz + (runStart + n / 2 - 0.5) * step), V(step, sy, n * step), runMat)
fillCount += 1
if fillCount % 250 == 0 then task.wait() end
runKey = nil
end
for zi = -ext, ext + 1 do
local lz = zi * step
local key
local hq, mat
if zi <= ext then
local h = H(isl, lx, lz)
if h > -20 then
hq = math.floor(h * 2 + 0.5) / 2
local steep = math.abs(H(isl, lx + step, lz) - h) + math.abs(H(isl, lx, lz + step) - h)
mat = MATF[name](lx, lz, h, steep)
key = hq .. "_" .. mat.Value
end
end
if key ~= runKey then
flush(zi)
if key then runStart, runKey, runH, runMat = zi, key, hq, mat end
end
end
end
end
local function scatter(name, count, rmin, rmax, hmin, fn, avoid, maxSteep)
local isl = ISL[name]
local placed, tries = 0, 0
while placed < count and tries < count * 40 do
tries += 1
local a, r = rr(0, PI * 2), rr(rmin, rmax)
local lx, lz = math.cos(a) * r, math.sin(a) * r
local ok = true
local h = H(isl, lx, lz)
if h < hmin then ok = false end
if ok and avoid then
for _, z in ipairs(avoid) do
if (lx - z[1]) ^ 2 + (lz - z[2]) ^ 2 < z[3] * z[3] then ok = false break end
end
end
if ok then
local s = math.abs(H(isl, lx + 4, lz) - h) + math.abs(H(isl, lx, lz + 4) - h)
if s > (maxSteep or 5) then ok = false end
end
if ok then
placed += 1
fn(V(isl.c.X + lx, groundY(isl.c.X + lx, isl.c.Z + lz, h), isl.c.Z + lz), lx, lz)
end
end
end
local function leafBall(m, cf, dia, color, mat)
return Ball(m, cf, dia, color, mat or M.Grass, deco())
end
function W.tree(parent, pos, s, kind)
s = s or 1
local m = Model(parent, kind .. "Tree")
local yaw = rr(0, PI * 2)
local base = CF(pos) * ANG(0, yaw, 0)
if kind == "palm" then
local lean = rr(-0.22, 0.22)
local h, segs = 15 * s, 5
local cur = base * CF(0, -1, 0)
for i = 1, segs do
Cyl(m, cur * CF(0, h / segs / 2, 0), h / segs + 0.4, (2.1 - i * 0.22) * s, Color3.fromRGB(135, 100, 65), M.Wood)
cur = cur * CF(0, h / segs, 0) * ANG(lean, 0, 0)
end
for i = 1, 8 do
P(m, V(1.6 * s, 0.25, 10 * s), cur * ANG(0, i * PI / 4, 0) * ANG(-0.5, 0, 0) * CF(0, 0, -5 * s), C.palm:Lerp(Color3.fromRGB(40, 110, 50), (i % 2) * 0.3), M.Grass, deco())
end
for i = 1, 3 do Ball(m, cur * CF(math.cos(i * 2) * 0.8, -0.8, math.sin(i * 2) * 0.8), 1.3 * s, Color3.fromRGB(80, 55, 30), M.Wood, deco()) end
elseif kind == "oak" then
local h = 10 * s
Cyl(m, base * CF(0, h / 2 - 1, 0), h, 2.6 * s, C.trunk, M.Wood)
for i = 1, 3 do
local a = i * 2.1 + yaw
Cyl(m, base * CF(0, h * 0.7, 0) * ANG(0, a, 0) * ANG(0.9, 0, 0) * CF(0, 2.5 * s, 0), 5.5 * s, 0.9 * s, C.trunk, M.Wood)
end
local top = base * CF(0, h, 0)
leafBall(m, top * CF(0, 3 * s, 0), 11 * s, C.leaf)
for i = 1, 4 do
local a = i * PI / 2 + 0.6
leafBall(m, top * CF(math.cos(a) * 5 * s, 0.5 * s, math.sin(a) * 5 * s), 8 * s, i % 2 == 0 and C.leaf2 or C.leaf)
end
elseif kind == "pine" or kind == "snowpine" then
local h = 18 * s
Cyl(m, base * CF(0, h / 2 - 1, 0), h, 1.8 * s, C.trunk, M.Wood)
local green = kind == "snowpine" and Color3.fromRGB(40, 90, 70) or Color3.fromRGB(35, 100, 60)
for i = 0, 4 do
local rad = (9 - i * 1.7) * s
local y = (4 + i * 3.3) * s
Cyl(m, base * CF(0, y, 0), 2.2 * s, rad, green, M.Grass, deco())
if kind == "snowpine" then Cyl(m, base * CF(0, y + 1.1 * s, 0), 0.5 * s, rad * 0.88, C.snow, M.Snow, deco()) end
end
elseif kind == "dead" then
local h = 11 * s
Cyl(m, base * CF(0, h / 2 - 1, 0) * ANG(rr(-0.08, 0.08), 0, rr(-0.08, 0.08)), h, 1.8 * s, Color3.fromRGB(30, 26, 26), M.Slate)
for i = 1, 4 do
local a = i * 1.7 + yaw
Cyl(m, base * CF(0, h * (0.55 + i * 0.1), 0) * ANG(0, a, 0) * ANG(0.8 + i * 0.1, 0, 0) * CF(0, 2.3 * s, 0), 5 * s, 0.7 * s, Color3.fromRGB(34, 28, 28), M.Slate)
end
elseif kind == "giant" then
local h = 75 * s
Cyl(m, base * CF(0, h / 2 - 2, 0), h, 9 * s, Color3.fromRGB(70, 52, 48), M.Wood)
for i = 1, 6 do
local a = i * PI / 3 + yaw
Cyl(m, base * ANG(0, a, 0) * CF(0, 4 * s, 7 * s) * ANG(0.45, 0, 0), 15 * s, 3 * s, Color3.fromRGB(70, 52, 48), M.Wood)
end
local top = base * CF(0, h, 0)
for i = 1, 5 do
local a = i * PI * 0.4 + yaw
Cyl(m, top * CF(0, -8 * s, 0) * ANG(0, a, 0) * ANG(1.1, 0, 0) * CF(0, 12 * s, 0), 26 * s, 3 * s, Color3.fromRGB(70, 52, 48), M.Wood, deco())
leafBall(m, top * CF(math.cos(a) * 22 * s, -3 * s + (i % 2) * 5 * s, math.sin(a) * 22 * s), 34 * s, Color3.fromRGB(40, 120, 100):Lerp(Color3.fromRGB(70, 90, 160), (i % 3) / 4), M.Grass)
end
leafBall(m, top * CF(0, 8 * s, 0), 46 * s, Color3.fromRGB(45, 130, 105), M.Grass)
for i = 1, 10 do
local a, rad = rr(0, PI * 2), rr(10, 30) * s
local orb = Ball(m, top * CF(math.cos(a) * rad, rr(-8, 8) * s, math.sin(a) * rad), 2.2 * s, Color3.fromRGB(120, 255, 220), M.Neon, deco())
if i % 3 == 0 then Light(orb, Color3.fromRGB(120, 255, 220), 26, 1) end
end
end
return m
end
function W.rock(parent, pos, s, color, mat)
local m = Model(parent, "Rock")
s = s or 1
for i = 1, ri(2, 4) do
local col = (color or C.stone):Lerp(Color3.new(0, 0, 0), rr(0, 0.25))
P(m, V(rr(3, 6) * s, rr(2, 5) * s, rr(3, 6) * s), CF(pos + V(rr(-2, 2) * s, rr(0.2, 1.1) * s, rr(-2, 2) * s)) * ANG(rr(-0.5, 0.5), rr(0, 6.28), rr(-0.5, 0.5)), col, mat or M.Slate)
end
return m
end
function W.bush(parent, pos, s, color)
local m = Model(parent, "Bush")
for i = 1, 3 do
leafBall(m, CF(pos + V(rr(-1.5, 1.5), 1.2 * s, rr(-1.5, 1.5))), rr(3, 4.5) * s, color or C.leaf2)
end
return m
end
function W.crate(parent, cf, s)
s = s or 1
local m = Model(parent, "Crate")
P(m, V(3 * s, 3 * s, 3 * s), cf * CF(0, 1.5 * s, 0), C.plank, M.WoodPlanks)
for _, off in ipairs({ -1.4, 1.4 }) do
P(m, V(3.1 * s, 0.3 * s, 3.1 * s), cf * CF(0, 1.5 * s + off * s, 0), C.darkwood, M.Wood)
P(m, V(0.3 * s, 3.1 * s, 3.1 * s), cf * CF(off * s, 1.5 * s, 0), C.darkwood, M.Wood)
end
return m
end
function W.barrel(parent, cf, s)
s = s or 1
local m = Model(parent, "Barrel")
Cyl(m, cf * CF(0, 1.6 * s, 0), 3.2 * s, 2.6 * s, C.plank, M.Wood)
for _, y in ipairs({ 0.5, 2.7 }) do Cyl(m, cf * CF(0, y * s, 0), 0.3 * s, 2.75 * s, C.iron, M.Metal) end
return m
end
function W.lamp(parent, pos, h)
h = h or 9
local m = Model(parent, "LampPost")
Cyl(m, CF(pos + V(0, h / 2, 0)), h, 0.7, C.iron, M.Metal)
local b = Ball(m, CF(pos + V(0, h + 0.5, 0)), 1.6, Color3.fromRGB(255, 220, 130), M.Neon, deco())
Light(b, Color3.fromRGB(255, 210, 130), 28, 1.8)
P(m, V(1.8, 0.3, 1.8), CF(pos + V(0, h + 1.5, 0)), C.iron, M.Metal, deco())
return m
end
function W.campfire(parent, pos)
local m = Model(parent, "Campfire")
for i = 1, 8 do
local a = i * PI / 4
P(m, V(1.2, 1, 1.2), CF(pos + V(math.cos(a) * 2.2, 0.4, math.sin(a) * 2.2)) * ANG(0, a, 0), C.darkstone, M.Slate)
end
for i = 1, 3 do P(m, V(0.8, 0.8, 3.2), CF(pos + V(0, 0.8, 0)) * ANG(0.3, i * 2.1, 0), C.darkwood, M.Wood, deco()) end
local f = P(m, V(1, 1, 1), CF(pos + V(0, 1.5, 0)), Color3.new(1, 1, 1), M.Neon, deco({ Transparency = 1 }))
Fire(f, 7, 9)
Light(f, Color3.fromRGB(255, 160, 70), 30, 2)
return m
end
function W.tent(parent, cf, color)
local m = Model(parent, "Tent")
local th = math.rad(37)
P(m, V(7, 0.4, 7), cf * CF(0, 0.2, 0), C.darkwood, M.Wood)
for _, sx in ipairs({ -1, 1 }) do
P(m, V(0.3, 5.9, 7.2), cf * CF(sx * 1.75, 2.6, 0) * ANG(0, 0, sx * th), color, M.Fabric)
end
P(m, V(0.3, 4.6, 7.2), cf * CF(0, 2.5, 3.5) * ANG(0, PI / 2, 0), color, M.Fabric, { Size = V(7, 4.6, 0.3) })
P(m, V(0.3, 0.3, 7.4), cf * CF(0, 4.9, 0), C.darkwood, M.Wood)
return m
end
function W.fountain(parent, pos)
local m = Model(parent, "Fountain")
Cyl(m, CF(pos + V(0, 0.9, 0)), 1.8, 15, C.stone, M.Cobblestone)
local w = Cyl(m, CF(pos + V(0, 1.5, 0)), 1.4, 13, Color3.fromRGB(60, 160, 220), M.Glass, { Transparency = 0.35 })
Cyl(m, CF(pos + V(0, 3.5, 0)), 4, 2.2, C.stone, M.Cobblestone)
Cyl(m, CF(pos + V(0, 5.6, 0)), 0.8, 6, C.stone, M.Cobblestone)
local jet = P(m, V(1, 1, 1), CF(pos + V(0, 6.2, 0)), Color3.new(1, 1, 1), M.Neon, deco({ Transparency = 1 }))
Emitter(jet, { Rate = 60, Lifetime = NumberRange.new(1, 1.6), Speed = NumberRange.new(10, 14), SpreadAngle = Vector2.new(25, 25),
Acceleration = V(0, -28, 0), Size = NumberSequence.new(0.6, 0.2), Color = ColorSequence.new(Color3.fromRGB(190, 230, 255)), Transparency = NumberSequence.new(0.2, 1),
EmissionDirection = Enum.NormalId.Top })
return m
end
function W.chest(parent, cf, id, glowColor)
local m = Model(parent, "Chest_" .. id)
local base = P(m, V(4, 2.2, 2.6), cf * CF(0, 1.1, 0), C.plank, M.Wood)
local lid = P(m, V(4, 1.2, 2.6), cf * CF(0, 2.8, 0), C.wood, M.Wood)
P(m, V(4.1, 0.35, 2.7), cf * CF(0, 2.2, 0), C.gold, M.Metal)
for _, x in ipairs({ -1.4, 1.4 }) do P(m, V(0.4, 3.5, 2.75), cf * CF(x, 1.9, 0), C.gold, M.Metal) end
local lock = P(m, V(0.7, 0.9, 0.3), cf * CF(0, 2.2, -1.4), C.gold, M.Metal)
local orb = Ball(m, cf * CF(0, 4.8, 0), 1.2, glowColor or Color3.fromRGB(255, 220, 120), M.Neon, deco())
Light(orb, glowColor or Color3.fromRGB(255, 220, 120), 22, 2)
m.PrimaryPart = base
local pp = Instance.new("ProximityPrompt")
pp.ActionText, pp.ObjectText, pp.MaxActivationDistance = "Open", "Chest", 10
pp.RequiresLineOfSight = false
pp.Parent = base
m:SetAttribute("Role", "Chest")
m:SetAttribute("ChestId", id)
tag(m, "NPC")
return m
end
local function weldTo(part, parentPart)
part.Anchored = false
part.CanCollide = false
part.Massless = true
local w = Instance.new("WeldConstraint")
w.Part0, w.Part1 = parentPart, part
w.Parent = part
end
local function acc(m, onPart, size, off, color, mat, o)
local p = P(m, size, onPart.CFrame * off, color, mat, o)
if o and o.Shape == Enum.PartType.Ball then p.Shape = Enum.PartType.Ball end
weldTo(p, onPart)
return p
end
local function motor(name, p0, p1, c0, c1)
local mo = Instance.new("Motor6D")
mo.Name, mo.Part0, mo.Part1, mo.C0, mo.C1 = name, p0, p1, c0, c1
mo.Parent = p0
return mo
end
function W.rig(parent, name, feetPos, o)
o = o or {}
local cf = CF(feetPos + V(0, 3, 0))
local m = Model(parent, name)
local function limb(n, size, off, color, mat, collide)
local p = Instance.new("Part")
p.Name, p.Size, p.Color = n, size, color
p.Material = mat or M.SmoothPlastic
p.CFrame = cf * CF(off)
p.TopSurface, p.BottomSurface = Enum.SurfaceType.Smooth, Enum.SurfaceType.Smooth
p.CanCollide = collide
p.Parent = m
return p
end
local skin, shirt, pants = o.skin or Color3.fromRGB(235, 190, 150), o.shirt or Color3.fromRGB(70, 90, 140), o.pants or Color3.fromRGB(60, 50, 45)
local hrp = limb("HumanoidRootPart", V(2, 2, 1), V(0, 0, 0), skin, nil, false)
hrp.Transparency = 1
local torso = limb("Torso", V(2, 2, 1), V(0, 0, 0), shirt, o.shirtMat, true)
local head = limb("Head", V(2, 1, 1), V(0, 1.5, 0), o.headColor or skin, nil, true)
local mesh = Instance.new("SpecialMesh")
mesh.MeshType, mesh.Scale = Enum.MeshType.Head, Vector3.new(1.25, 1.25, 1.25)
mesh.Parent = head
if not o.noFace then
local face = Instance.new("Decal")
face.Name, face.Face, face.Texture = "face", Enum.NormalId.Front, "rbxasset://textures/face.png"
face.Parent = head
end
local la = limb("Left Arm", V(1, 2, 1), V(-1.5, 0, 0), o.sleeve or shirt, o.shirtMat, false)
local ra = limb("Right Arm", V(1, 2, 1), V(1.5, 0, 0), o.sleeve or shirt, o.shirtMat, false)
local ll = limb("Left Leg", V(1, 2, 1), V(-0.5, -2, 0), pants, o.pantsMat, true)
local rl = limb("Right Leg", V(1, 2, 1), V(0.5, -2, 0), pants, o.pantsMat, true)
local rootRot = CFrame.new(0, 0, 0, -1, 0, 0, 0, 0, 1, 0, 1, 0)
motor("RootJoint", hrp, torso, rootRot, rootRot)
motor("Neck", torso, head, CFrame.new(0, 1, 0, -1, 0, 0, 0, 0, 1, 0, 1, 0), CFrame.new(0, -0.5, 0, -1, 0, 0, 0, 0, 1, 0, 1, 0))
motor("Right Shoulder", torso, ra, CFrame.new(1, 0.5, 0, 0, 0, 1, 0, 1, 0, -1, 0, 0), CFrame.new(-0.5, 0.5, 0, 0, 0, 1, 0, 1, 0, -1, 0, 0))
motor("Left Shoulder", torso, la, CFrame.new(-1, 0.5, 0, 0, 0, -1, 0, 1, 0, 1, 0, 0), CFrame.new(0.5, 0.5, 0, 0, 0, -1, 0, 1, 0, 1, 0, 0))
motor("Right Hip", torso, rl, CFrame.new(1, -1, 0, 0, 0, 1, 0, 1, 0, -1, 0, 0), CFrame.new(0.5, 1, 0, 0, 0, 1, 0, 1, 0, -1, 0, 0))
motor("Left Hip", torso, ll, CFrame.new(-1, -1, 0, 0, 0, -1, 0, 1, 0, 1, 0, 0), CFrame.new(-0.5, 1, 0, 0, 0, -1, 0, 1, 0, 1, 0, 0))
local hum = Instance.new("Humanoid")
hum.RigType = Enum.HumanoidRigType.R6
hum.DisplayName = name
hum.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
hum.Parent = m
m.PrimaryPart = hrp
m:SetAttribute("Parts", true)
return m, { torso = torso, head = head, ra = ra, la = la, ll = ll, rl = rl, hrp = hrp }
end
local function finishRig(m, parts, o)
o = o or {}
local s = o.scale or 1
if s ~= 1 then
m:ScaleTo(s)
m:PivotTo(m:GetPivot() + V(0, 3 * (s - 1), 0))
end
local yaw = o.yaw or 0
m:PivotTo(CF(m:GetPivot().Position) * ANG(0, yaw, 0))
end
function W.npc(parent, name, feetPos, yaw, o)
local m, p = W.rig(parent, name, feetPos, o)
local torso, head, ra = p.torso, p.head, p.ra
local hat, hc = o.hat, o.hatColor or Color3.fromRGB(40, 40, 50)
if hat == "tricorn" then
acc(m, head, V(2.8, 0.3, 2.8), CF(0, 0.8, 0), hc, M.Fabric)
acc(m, head, V(1.8, 0.8, 1.8), CF(0, 1.2, 0), hc, M.Fabric)
acc(m, head, V(0.4, 0.4, 2.8), CF(1.3, 0.95, 0) , C.gold, M.Metal)
elseif hat == "cap" then
acc(m, head, V(2.2, 0.7, 2.2), CF(0, 0.75, 0), hc, M.Fabric)
acc(m, head, V(2.2, 0.2, 1), CF(0, 0.55, -1.2), hc, M.Fabric)
elseif hat == "hood" then
acc(m, head, V(2.5, 1.9, 2.4), CF(0, 0.25, 0.15), hc, M.Fabric)
acc(m, torso, V(2.8, 0.7, 1.7), CF(0, 1.1, 0), hc, M.Fabric)
elseif hat == "straw" then
acc(m, head, V(0.2, 3.4, 3.4), CF(0, 0.75, 0) * ANG(0, 0, PI / 2), hc, M.Fabric, { Shape = Enum.PartType.Cylinder })
acc(m, head, V(1.8, 0.8, 1.8), CF(0, 1.1, 0), hc, M.Fabric)
elseif hat == "wizard" then
acc(m, head, V(3, 0.2, 3), CF(0, 0.7, 0), hc, M.Fabric)
acc(m, head, V(2, 1.4, 2), CF(0, 1.4, 0), hc, M.Fabric)
acc(m, head, V(1.2, 1.4, 1.2), CF(0, 2.5, 0), hc, M.Fabric)
acc(m, head, V(0.5, 0.9, 0.5), CF(0, 3.5, 0.2), hc, M.Neon, { Shape = Enum.PartType.Ball })
elseif hat == "fur" then
acc(m, head, V(2.5, 0.9, 2.5), CF(0, 0.7, 0), Color3.fromRGB(230, 235, 240), M.Fabric)
end
if o.beard then acc(m, head, V(1.5, 1, 0.6), CF(0, -0.55, -0.55), o.beard, M.Fabric) end
if o.eyepatch then acc(m, head, V(0.55, 0.45, 0.1), CF(0.3, 0.1, -0.64), Color3.new(0.05, 0.05, 0.05), M.Fabric) end
if o.apron then acc(m, torso, V(1.6, 2.1, 0.2), CF(0, -0.2, -0.6), o.apron, M.Fabric) end
if o.robe then
acc(m, torso, V(2.2, 2.4, 1.25), CF(0, -0.9, 0), o.robe, M.Fabric)
acc(m, p.ll, V(1.2, 2.2, 1.2), CF(0, -0.1, 0), o.robe, M.Fabric)
acc(m, p.rl, V(1.2, 2.2, 1.2), CF(0, -0.1, 0), o.robe, M.Fabric)
end
if o.coat then acc(m, torso, V(2.2, 2.4, 1.2), CF(0, 0, 0), o.coat, M.Fabric) end
if o.prop == "sword" then
acc(m, ra, V(0.3, 0.3, 4), CF(0, -1, -2), Color3.fromRGB(200, 205, 215), M.Metal)
elseif o.prop == "hammer" then
acc(m, ra, V(0.4, 0.4, 3), CF(0, -1, -1.4), C.darkwood, M.Wood)
acc(m, ra, V(1.4, 1, 1), CF(0, -1, -3), C.iron, M.Metal)
elseif o.prop == "staff" then
acc(m, ra, V(0.4, 6, 0.4), CF(0, -0.4, -0.4), C.darkwood, M.Wood)
acc(m, ra, V(1, 1, 1), CF(0, 2.8, -0.4), o.orb or Color3.fromRGB(120, 200, 255), M.Neon, { Shape = Enum.PartType.Ball })
elseif o.prop == "mug" then
acc(m, ra, V(0.8, 1, 0.8), CF(0, -1, -0.8), C.gold, M.Metal)
end
finishRig(m, p, { yaw = yaw })
local hrp = p.hrp
hrp.Anchored = true
for _, d in ipairs(m:GetDescendants()) do
if d:IsA("BasePart") then d.Anchored = true end
end
local pr = Instance.new("ProximityPrompt")
pr.ActionText = o.action or "Talk"
pr.ObjectText = name
pr.MaxActivationDistance = 12
pr.RequiresLineOfSight = false
pr.HoldDuration = 0
pr.Parent = hrp
m:SetAttribute("Role", o.role or "Villager")
m:SetAttribute("NpcName", name)
if o.lines then m:SetAttribute("Lines", o.lines) end
tag(m, "NPC")
local bb = Instance.new("BillboardGui")
bb.Adornee = head
bb.Size = UDim2.fromOffset(220, 44)
bb.StudsOffsetWorldSpace = V(0, 3, 0)
bb.MaxDistance = 80
local t1 = Instance.new("TextLabel")
t1.BackgroundTransparency, t1.Size, t1.Font, t1.TextScaled = 1, UDim2.fromScale(1, 0.58), Enum.Font.GothamBold, true
t1.Text, t1.TextColor3, t1.TextStrokeTransparency = name, Color3.new(1, 1, 1), 0.4
t1.Parent = bb
local t2 = t1:Clone()
t2.Position, t2.Size, t2.Text, t2.TextColor3 = UDim2.fromScale(0, 0.58), UDim2.fromScale(1, 0.4), o.title or "", Color3.fromRGB(255, 205, 100)
t2.Parent = bb
bb.Parent = head
return m
end
local function enemyBase(parent, folderName, displayName, etype, feetPos, yaw, o)
local m, p = W.rig(parent, displayName, feetPos, o)
m:SetAttribute("EnemyType", etype)
return m, p
end
function W.bandit(parent, feetPos, yaw)
local m, p = enemyBase(parent, "Enemies", "Driftwood Bandit", "Bandit", feetPos, yaw, {
skin = Color3.fromRGB(205, 155, 115), shirt = Color3.fromRGB(120, 40, 40), pants = Color3.fromRGB(70, 55, 40), shirtMat = M.Fabric,
})
acc(m, p.head, V(2.2, 0.55, 1.15), CF(0, 0.5, 0), Color3.fromRGB(190, 30, 30), M.Fabric)
acc(m, p.head, V(0.5, 0.5, 0.9), CF(1.1, 0.45, 0.55), Color3.fromRGB(190, 30, 30), M.Fabric)
acc(m, p.head, V(0.55, 0.45, 0.1), CF(0.3, 0.1, -0.64), Color3.new(0.05, 0.05, 0.05), M.Fabric)
acc(m, p.torso, V(2.1, 0.35, 1.1), CF(0, -0.8, 0), Color3.fromRGB(40, 30, 25), M.Leather)
acc(m, p.ra, V(0.3, 0.3, 4.2), CF(0, -1, -2.2), Color3.fromRGB(205, 208, 215), M.Metal)
acc(m, p.ra, V(0.35, 1.2, 0.4), CF(0, -1, -0.2), C.gold, M.Metal)
finishRig(m, p, { yaw = yaw, scale = 1.05 })
return m
end
function W.raider(parent, feetPos, yaw)
local m, p = enemyBase(parent, "Enemies", "Ember Raider", "EmberRaider", feetPos, yaw, {
skin = Color3.fromRGB(170, 120, 95), shirt = Color3.fromRGB(45, 38, 38), pants = Color3.fromRGB(35, 30, 30), shirtMat = M.Slate,
})
acc(m, p.head, V(2.3, 1.2, 1.3), CF(0, 0.45, 0), Color3.fromRGB(55, 50, 52), M.Metal)
for _, sx in ipairs({ -1, 1 }) do
acc(m, p.head, V(0.4, 1.6, 0.4), CF(sx * 1.2, 1.2, 0) * ANG(0, 0, sx * -0.5), Color3.fromRGB(230, 220, 200), M.Slate)
acc(m, p.head, V(0.35, 0.2, 0.1), CF(sx * 0.4, 0.15, -0.64), Color3.fromRGB(255, 120, 20), M.Neon)
end
acc(m, p.torso, V(2.2, 0.35, 1.2), CF(0, 0.3, 0), Color3.fromRGB(255, 100, 20), M.Neon)
acc(m, p.torso, V(2.2, 0.35, 1.2), CF(0, -0.4, 0), Color3.fromRGB(255, 100, 20), M.Neon)
for _, sx in ipairs({ -1, 1 }) do acc(m, p.torso, V(1.4, 0.8, 1.5), CF(sx * 1.4, 1, 0), Color3.fromRGB(60, 55, 58), M.Metal) end
acc(m, p.ra, V(0.5, 0.5, 5), CF(0, -1, -2.4), C.darkwood, M.Wood)
acc(m, p.ra, V(0.3, 2.4, 1.8), CF(0, -1, -4.4), Color3.fromRGB(75, 75, 82), M.Metal)
acc(m, p.ra, V(0.35, 1.9, 0.3), CF(0, -1, -4.9), Color3.fromRGB(255, 110, 25), M.Neon)
finishRig(m, p, { yaw = yaw, scale = 1.15 })
return m
end
function W.guardian(parent, feetPos, yaw)
local m, p = enemyBase(parent, "Enemies", "Frost Guardian", "FrostGuardian", feetPos, yaw, {
skin = Color3.fromRGB(190, 225, 245), shirt = Color3.fromRGB(150, 205, 240), pants = Color3.fromRGB(110, 160, 205), shirtMat = M.Ice, pantsMat = M.Ice,
})
acc(m, p.head, V(2.3, 1.3, 1.3), CF(0, 0.4, 0), Color3.fromRGB(200, 235, 255), M.Ice)
for i = -1, 1 do acc(m, p.head, V(0.35, 1.5 - math.abs(i) * 0.4, 0.35), CF(i * 0.7, 1.3, 0), Color3.fromRGB(190, 245, 255), M.Neon) end
acc(m, p.head, V(0.9, 0.18, 0.1), CF(0, 0.15, -0.64), Color3.fromRGB(120, 230, 255), M.Neon)
for _, sx in ipairs({ -1, 1 }) do
acc(m, p.torso, V(1.4, 0.9, 1.6), CF(sx * 1.4, 1, 0), Color3.fromRGB(200, 235, 255), M.Ice)
acc(m, p.torso, V(0.5, 1.8, 0.5), CF(sx * 1.6, 2, 0) * ANG(0, 0, sx * -0.4), Color3.fromRGB(150, 235, 255), M.Neon)
end
acc(m, p.torso, V(1.2, 1.2, 0.3), CF(0, 0.3, -0.62), Color3.fromRGB(150, 235, 255), M.Neon)
acc(m, p.ra, V(0.4, 0.4, 7), CF(0, -1, -2.5), Color3.fromRGB(180, 230, 255), M.Ice)
acc(m, p.ra, V(0.9, 0.5, 1.8), CF(0, -1, -6.4), Color3.fromRGB(150, 240, 255), M.Neon)
finishRig(m, p, { yaw = yaw, scale = 1.3 })
return m
end
function W.beast(parent, feetPos, yaw)
local fur = Color3.fromRGB(38, 62, 52)
local m, p = enemyBase(parent, "Enemies", "Moonveil Beast", "MoonBeast", feetPos, yaw, {
skin = fur, shirt = Color3.fromRGB(32, 52, 46), pants = fur, noFace = true, shirtMat = M.Fabric, pantsMat = M.Fabric,
})
for _, sx in ipairs({ -1, 1 }) do
acc(m, p.head, V(0.45, 0.3, 0.1), CF(sx * 0.45, 0.15, -0.64), Color3.fromRGB(120, 255, 220), M.Neon)
acc(m, p.head, V(0.3, 2, 0.3), CF(sx * 0.8, 1.4, 0) * ANG(0.2, 0, sx * -0.35), Color3.fromRGB(215, 205, 180), M.Slate)
acc(m, p.head, V(0.3, 1, 0.3), CF(sx * 1.2, 2.2, 0) * ANG(0.2, 0, sx * 0.4), Color3.fromRGB(215, 205, 180), M.Slate)
for k = -1, 1 do acc(m, p.ra and (sx > 0 and p.ra or p.la), V(0.18, 0.18, 0.9), CF(k * 0.28, -1.05, -0.5), Color3.fromRGB(235, 235, 220), M.Slate) end
end
acc(m, p.head, V(1, 0.5, 1), CF(0, -0.45, -0.7), fur, M.Fabric)
acc(m, p.torso, V(2.2, 1, 1.4), CF(0, 1.1, 0.2), Color3.fromRGB(30, 80, 70), M.Fabric)
for i = 1, 4 do
acc(m, p.torso, V(0.6 - i * 0.1, 0.6 - i * 0.1, 1.4), CF(0, 0.2 - i * 0.2, 1.1 + i * 0.9) , Color3.fromRGB(30, 60, 50), M.Fabric)
end
acc(m, p.torso, V(0.4, 0.4, 0.4), CF(0, -0.8, 4.9), Color3.fromRGB(120, 255, 220), M.Neon, { Shape = Enum.PartType.Ball })
finishRig(m, p, { yaw = yaw, scale = 1.35 })
return m
end
function W.boss(parent, feetPos, yaw, element)
local fire = element ~= "Ice"
local main = fire and Color3.fromRGB(40, 34, 36) or Color3.fromRGB(150, 205, 240)
local glow = fire and Color3.fromRGB(255, 100, 20) or Color3.fromRGB(150, 240, 255)
local mat = fire and M.Basalt or M.Ice
local name = fire and "Cinder Warden" or "Rimeheart Colossus"
local m, p = enemyBase(parent, "Bosses", name, fire and "CinderWarden" or "RimeColossus", feetPos, yaw, {
skin = main, shirt = main, pants = main, shirtMat = mat, pantsMat = mat, noFace = true,
})
for _, sx in ipairs({ -1, 1 }) do
acc(m, p.head, V(0.55, 0.3, 0.1), CF(sx * 0.45, 0.15, -0.64), glow, M.Neon)
acc(m, p.torso, V(2, 1.3, 2.1), CF(sx * 1.6, 1.2, 0), fire and Color3.fromRGB(55, 48, 50) or Color3.fromRGB(190, 230, 250), mat)
acc(m, p.torso, V(0.6, 2.2, 0.6), CF(sx * 1.9, 2.5, 0) * ANG(0, 0, sx * -0.35), glow, M.Neon)
acc(m, p.head, V(0.4, 2.2, 0.4), CF(sx * 0.9, 1.7, 0) * ANG(0, 0, sx * -0.4), fire and Color3.fromRGB(30, 26, 28) or glow, fire and M.Basalt or M.Neon)
acc(m, sx > 0 and p.ra or p.la, V(1.2, 0.35, 1.2), CF(0, 0.2, 0), glow, M.Neon)
acc(m, sx > 0 and p.rl or p.ll, V(1.15, 0.3, 1.15), CF(0, -0.2, 0), glow, M.Neon)
end
acc(m, p.head, V(2.4, 0.5, 1.4), CF(0, 0.6, 0), main, mat)
local crown = acc(m, p.head, V(1.6, 0.4, 0.8), CF(0, 1.1, 0), glow, M.Neon)
if fire then Fire(crown, 9, 12) else
Emitter(crown, { Rate = 25, Lifetime = NumberRange.new(1, 2), Speed = NumberRange.new(2, 5), Size = NumberSequence.new(0.5, 0), Color = ColorSequence.new(glow),
Transparency = NumberSequence.new(0, 1), LightEmission = 1 })
end
for i = -1, 1 do
acc(m, p.torso, V(0.3, 1.8 - math.abs(i) * 0.4, 0.15), CF(i * 0.6, 0.2, -0.56), glow, M.Neon)
end
acc(m, p.torso, V(2.2, 0.35, 1.15), CF(0, -0.85, 0), glow, M.Neon)
acc(m, p.ra, V(0.55, 0.55, 3), CF(0, -1, -1.3), C.darkwood, M.Wood)
acc(m, p.ra, V(2.4, 0.4, 0.5), CF(0, -1, -3), C.gold, M.Metal)
acc(m, p.ra, V(0.35, 1.3, 9), CF(0, -1, -8), fire and Color3.fromRGB(70, 66, 70) or Color3.fromRGB(190, 235, 255), fire and M.Metal or M.Ice)
local edge = acc(m, p.ra, V(0.4, 0.3, 9), CF(0, -1.65, -8), glow, M.Neon)
if fire then Fire(edge, 8, 10) end
local aura = acc(m, p.torso, V(1, 1, 1), CF(0, 0, 0), glow, M.Neon, deco({ Transparency = 1 }))
Light(aura, glow, 40, 2.5)
finishRig(m, p, { yaw = yaw, scale = 3.6 })
m:SetAttribute("Reach", 6)
return m
end
local function wall(m, cf, L, h, t, color, mat, ops)
local cursor = -L / 2
local function block(x0, x1, y0, y1)
if x1 - x0 < 0.05 or y1 - y0 < 0.05 then return end
P(m, V(x1 - x0, y1 - y0, t), cf * CF((x0 + x1) / 2, (y0 + y1) / 2, 0), color, mat)
end
for _, op in ipairs(ops or {}) do
local l, r = op.x - op.w / 2, op.x + op.w / 2
block(cursor, l, 0, h)
block(l, r, 0, op.y0)
block(l, r, op.y1, h)
if op.glass then
P(m, V(op.w, op.y1 - op.y0, 0.2), cf * CF(op.x, (op.y0 + op.y1) / 2, 0), C.glass, M.Glass, { Transparency = 0.5 })
P(m, V(op.w + 0.8, 0.4, t + 0.6), cf * CF(op.x, op.y0 - 0.2, 0), C.darkwood, M.Wood)
P(m, V(0.3, op.y1 - op.y0, 0.3), cf * CF(op.x, (op.y0 + op.y1) / 2, 0), C.darkwood, M.Wood)
end
cursor = r
end
block(cursor, L / 2, 0, h)
end
local function interior(m, cf, kind, w, d)
local lampP = P(m, V(1, 1, 1), cf * CF(0, 7, 0), Color3.fromRGB(255, 220, 150), M.Neon, deco({ Transparency = 0.2 }))
Light(lampP, Color3.fromRGB(255, 205, 140), math.max(w, d) * 1.3, 1.4)
P(m, V(0.2, 2, 0.2), cf * CF(0, 8, 0), C.iron, M.Metal, deco())
local bz = -d / 2 + 0.4
if kind == "house" then
P(m, V(5, 1.4, 7), cf * CF(-w / 2 + 3.2, 0.7, bz + 4.2), C.darkwood, M.Wood)
P(m, V(4.6, 0.9, 5), cf * CF(-w / 2 + 3.2, 1.7, bz + 3.6), Color3.fromRGB(200, 70, 70), M.Fabric)
P(m, V(4.6, 0.5, 1.5), cf * CF(-w / 2 + 3.2, 2.1, bz + 1.4), C.white, M.Fabric)
P(m, V(5, 0.4, 3), cf * CF(w / 2 - 4, 2.8, bz + 3), C.plank, M.WoodPlanks)
for _, sx in ipairs({ -1.9, 1.9 }) do P(m, V(0.4, 2.8, 0.4), cf * CF(w / 2 - 4 + sx, 1.4, bz + 3 + 1.2), C.darkwood, M.Wood) end
for _, sx in ipairs({ -1.9, 1.9 }) do P(m, V(0.4, 2.8, 0.4), cf * CF(w / 2 - 4 + sx, 1.4, bz + 3 - 1.2), C.darkwood, M.Wood) end
P(m, V(1.6, 0.3, 1.6), cf * CF(w / 2 - 4, 1.7, bz + 6.2), C.darkwood, M.Wood)
P(m, V(1.6, 1.6, 1.6), cf * CF(w / 2 - 4, 0.8, bz + 6.2), C.plank, M.Wood)
P(m, V(4, 0.4, 2), cf * CF(w / 2 - 3, 0.2, bz + 12), Color3.fromRGB(150, 50, 50), M.Fabric, deco())
elseif kind == "tavern" then
P(m, V(w - 8, 3.4, 1.8), cf * CF(0, 1.7, bz + 5), C.darkwood, M.Wood)
P(m, V(w - 8, 0.4, 2.4), cf * CF(0, 3.5, bz + 5), C.plank, M.WoodPlanks)
for i = -2, 2 do
Cyl(m, cf * CF(i * 4.2, 1.2, bz + 8), 2.4, 1.4, C.darkwood, M.Wood)
Cyl(m, cf * CF(i * 4.2, 2.5, bz + 8), 0.3, 1.8, C.plank, M.Wood)
end
for i = -1, 1 do
local mug = Cyl(m, cf * CF(i * 5, 3.95, bz + 5), 0.8, 0.7, C.gold, M.Metal, deco())
end
for _, x in ipairs({ -w / 2 + 3, w / 2 - 3 }) do
W.barrel(m, cf * CF(x, 0, bz + 1.5), 1.2)
W.barrel(m, cf * CF(x, 0, bz + 4.2), 1.2)
end
for _, p in ipairs({ { -w / 4, d / 4 }, { w / 4, d / 4 } }) do
Cyl(m, cf * CF(p[1], 1.4, p[2]), 0.4, 6, C.plank, M.WoodPlanks)
Cyl(m, cf * CF(p[1], 0.7, p[2]), 1.4, 1, C.darkwood, M.Wood)
for k = 0, 3 do
local a = k * PI / 2
P(m, V(1.4, 0.3, 1.4), cf * CF(p[1] + math.cos(a) * 4, 1.2, p[2] + math.sin(a) * 4), C.wood, M.Wood)
end
end
P(m, V(w - 10, 0.3, 1), cf * CF(0, 5.2, -d / 2 + 0.7), C.darkwood, M.Wood)
for i = -3, 3 do Cyl(m, cf * CF(i * 2.2, 5.9, -d / 2 + 0.7), 1.2, 0.6, Color3.fromRGB(60 + i * 20, 150, 90), M.Glass, deco()) end
elseif kind == "weapon" then
P(m, V(w - 6, 3.2, 2), cf * CF(0, 1.6, d / 2 - 6), C.darkwood, M.Wood)
P(m, V(w - 6, 0.4, 2.6), cf * CF(0, 3.3, d / 2 - 6), C.plank, M.WoodPlanks)
for i = -2, 2 do
local x = i * 3.6
P(m, V(1.4, 0.3, 0.3), cf * CF(x, 6.6, bz + 0.2), C.gold, M.Metal, deco())
end
for i = -2, 2 do
P(m, V(0.35, 4, 0.2), cf * CF(i * 3.6, 6, bz + 0.1), Color3.fromRGB(205, 210, 220), M.Metal, deco())
end
P(m, V(2.2, 1.6, 4), cf * CF(w / 2 - 4, 0.8, bz + 3), C.iron, M.Metal)
P(m, V(1.6, 0.8, 2.4), cf * CF(w / 2 - 4, 2, bz + 3), C.iron, M.Metal)
local f = P(m, V(2, 1, 2), cf * CF(-w / 2 + 3, 0.5, bz + 3), C.darkstone, M.Slate)
local fp = P(m, V(1, 1, 1), cf * CF(-w / 2 + 3, 1.6, bz + 3), Color3.new(1, 1, 1), M.Neon, deco({ Transparency = 1 }))
Fire(fp, 5, 6)
Light(fp, Color3.fromRGB(255, 140, 60), 20, 1.5)
P(m, V(0.6, 2, 3), cf * CF(-w / 2 + 3, 1.6, bz + 5.2), C.darkstone, M.Slate)
elseif kind == "power" then
Cyl(m, cf * CF(0, 0.1, 0), 0.2, math.min(w, d) - 4, Color3.fromRGB(70, 40, 110), M.Fabric, deco())
for i, col in ipairs({ Color3.fromRGB(255, 120, 40), Color3.fromRGB(70, 170, 255) }) do
local x = (i == 1 and -1 or 1) * 6
Cyl(m, cf * CF(x, 1.4, 0), 2.8, 2.4, C.stone, M.Marble)
local orb = Ball(m, cf * CF(x, 4.2, 0), 2.4, col, M.Neon, deco())
Light(orb, col, 20, 2)
Emitter(orb, { Rate = 12, Lifetime = NumberRange.new(1, 2), Speed = NumberRange.new(1, 3), Size = NumberSequence.new(0.4, 0), Color = ColorSequence.new(col), LightEmission = 1, Transparency = NumberSequence.new(0, 1) })
end
for _, sx in ipairs({ -1, 1 }) do
P(m, V(1.2, 9, w * 0.3), cf * CF(sx * (w / 2 - 1.2), 4.5, bz + 6), C.darkwood, M.Wood)
for k = 1, 3 do
for j = 1, 6 do
P(m, V(0.6, 0.9, 0.5), cf * CF(sx * (w / 2 - 1.9), k * 2.6 + 0.4, bz + 2 + j * 0.85), Color3.fromHSV((j * 0.13 + k * 0.2) % 1, 0.5, 0.6), M.Fabric, deco())
end
end
end
end
end
function W.house(parent, cf, o)
o = o or {}
local w, d, h = o.w or 18, o.d or 14, o.h or 9
local kind = o.kind or "house"
local wc = o.wall or Color3.fromRGB(200, 180, 150)
local rc = o.roof or C.roof
local wmat = o.wmat or M.WoodPlanks
local m = Model(parent, o.name or "House")
local t = 0.8
P(m, V(w + 2, 1.2, d + 2), cf * CF(0, -0.2, 0), C.stone, M.Cobblestone)
P(m, V(w, 0.4, d), cf * CF(0, 0.6, 0), C.floor, M.WoodPlanks)
local fcf = cf * CF(0, 0.8, 0)
local frontOps = { { x = 0, w = 4.2, y0 = 0, y1 = 7.2 } }
local nw = o.windows == false and 0 or 1
if nw > 0 then
table.insert(frontOps, 1, { x = -w / 4 - 1, w = 3, y0 = 3, y1 = 6.2, glass = true })
table.insert(frontOps, { x = w / 4 + 1, w = 3, y0 = 3, y1 = 6.2, glass = true })
end
wall(m, fcf * CF(0, 0, d / 2), w, h, t, wc, wmat, frontOps)
wall(m, fcf * CF(0, 0, -d / 2) * ANG(0, PI, 0), w, h, t, wc, wmat, { { x = 0, w = 3, y0 = 3, y1 = 6.2, glass = true } })
local sideOps = { { x = 0, w = 3, y0 = 3, y1 = 6.2, glass = true } }
wall(m, fcf * CF(w / 2, 0, 0) * ANG(0, PI / 2, 0), d, h, t, wc, wmat, sideOps)
wall(m, fcf * CF(-w / 2, 0, 0) * ANG(0, -PI / 2, 0), d, h, t, wc, wmat, sideOps)
for _, sx in ipairs({ -1, 1 }) do for _, sz in ipairs({ -1, 1 }) do
P(m, V(1.2, h + 0.4, 1.2), fcf * CF(sx * w / 2, h / 2, sz * d / 2), C.darkwood, M.Wood)
end end
P(m, V(0.3, 7, 3.9), fcf * CF(-2.2, 3.5, d / 2 + 2) * ANG(0, 0.25, 0), C.wood, M.WoodPlanks)
local rise = o.rise or 5
local half = d / 2 + 1.4
local slope = math.sqrt(half * half + rise * rise)
local ang = math.atan2(rise, half)
for _, sz in ipairs({ -1, 1 }) do
P(m, V(w + 3, 0.7, slope), fcf * CF(0, h + rise / 2 + 0.3, sz * half / 2) * ANG(-sz * ang * -1, 0, 0), rc, o.roofMat or M.Slate)
end
P(m, V(w + 3.2, 0.6, 0.9), fcf * CF(0, h + rise + 0.5, 0), C.darkwood, M.Wood)
for k = 0, 3 do
local frac = 1 - (k + 0.5) / 4
for _, sx in ipairs({ -1, 1 }) do
P(m, V(0.8, rise / 4 + 0.05, d * frac), fcf * CF(sx * (w / 2), h + (k + 0.5) * rise / 4, 0), wc, wmat)
end
end
if o.chimney ~= false then
P(m, V(2.4, h + rise + 2, 2.4), fcf * CF(w / 2 - 3, (h + rise + 2) / 2 + 1, -d / 4), C.stone, M.Brick)
local sm = P(m, V(1, 1, 1), fcf * CF(w / 2 - 3, h + rise + 3.5, -d / 4), Color3.new(1, 1, 1), M.Neon, deco({ Transparency = 1 }))
Emitter(sm, { Rate = 6, Lifetime = NumberRange.new(3, 5), Speed = NumberRange.new(2, 4), Size = NumberSequence.new(1, 4), Color = ColorSequence.new(Color3.fromRGB(190, 190, 195)),
Transparency = NumberSequence.new(0.6, 1), EmissionDirection = Enum.NormalId.Top })
end
P(m, V(5, 0.5, 2.4), fcf * CF(0, 0.1, d / 2 + 1.6), C.stone, M.Cobblestone)
local lan = Ball(m, fcf * CF(3.2, 7.6, d / 2 + 0.6), 1, Color3.fromRGB(255, 215, 130), M.Neon, deco())
Light(lan, Color3.fromRGB(255, 205, 130), 20, 1.4)
interior(m, fcf, kind, w, d)
if o.sign then
sign(m, fcf * CF(0, 10.4, d / 2 + 2.6) * ANG(0, PI, 0), o.sign, V(11, 2, 0.4))
for _, sx in ipairs({ -1, 1 }) do P(m, V(0.5, 10.6, 0.5), fcf * CF(sx * 5.2, 5.3, d / 2 + 2.6), C.darkwood, M.Wood) end
end
return m
end
function W.pier(parent, p0, yaw, len, width)
width = width or 8
local m = Model(parent, "Pier")
local cf = CF(p0) * ANG(0, yaw, 0)
for i = 0, math.floor(len / 2) - 1 do
P(m, V(width, 0.6, 1.94), cf * CF(0, -0.3, i * 2 + 1), (i % 2 == 0) and C.plank or C.wood, M.WoodPlanks)
end
for z = 2, len, 8 do
for _, sx in ipairs({ -1, 1 }) do
Cyl(m, cf * CF(sx * (width / 2 + 0.3), -5, z), 14, 1.3, C.darkwood, M.Wood)
Cyl(m, cf * CF(sx * (width / 2 + 0.3), 1.6, z), 2.6, 1.1, C.darkwood, M.Wood)
if z % 16 == 2 then
local b = Ball(m, cf * CF(sx * (width / 2 + 0.3), 3.4, z), 0.9, Color3.fromRGB(255, 215, 130), M.Neon, deco())
Light(b, Color3.fromRGB(255, 205, 130), 22, 1.3)
end
end
end
for _, sx in ipairs({ -1, 1 }) do
P(m, V(0.3, 0.3, len), cf * CF(sx * (width / 2 + 0.3), 2.3, len / 2), C.rope, M.Fabric, deco())
end
P(m, V(width + 2, 0.7, 2), cf * CF(0, -0.3, len + 0.5), C.darkwood, M.Wood)
W.barrel(m, cf * CF(width / 2 - 1.5, 0, 5), 0.9)
W.crate(m, cf * CF(-width / 2 + 1.8, 0, 9) * ANG(0, 0.3, 0), 0.9)
return m
end
function W.bridge(parent, a, b, width, o)
o = o or {}
local m = Model(parent, "Bridge")
local len = (b - a).Magnitude
local cf = CFrame.lookAt(a, b)
local n = math.floor(len / 2)
local step = len / n
for i = 0, n - 1 do
P(m, V(width, 0.5, step - 0.08), cf * CF(0, -0.25, -(i + 0.5) * step), (i % 2 == 0) and (o.c1 or C.plank) or (o.c2 or C.wood), o.mat or M.WoodPlanks)
end
for _, sx in ipairs({ -1, 1 }) do
P(m, V(0.5, 0.5, len), cf * CF(sx * width / 2, -0.6, -len / 2), C.darkwood, M.Wood)
P(m, V(0.35, 0.35, len), cf * CF(sx * width / 2, 3.1, -len / 2), o.rail or C.rope, M.Wood)
for i = 0, n, 2 do
P(m, V(0.5, 3.6, 0.5), cf * CF(sx * width / 2, 1.3, -i * step), C.darkwood, M.Wood)
end
end
for _, e in ipairs({ 0, len }) do
for _, sx in ipairs({ -1, 1 }) do
local lp = Ball(m, cf * CF(sx * width / 2, 4.1, -e), 0.9, o.lamp or Color3.fromRGB(255, 215, 130), M.Neon, deco())
Light(lp, o.lamp or Color3.fromRGB(255, 205, 130), 18, 1.2)
end
end
return m
end
function W.lighthouse(parent, pos)
local m = Model(parent, "Lighthouse")
local base = pos
Cyl(m, CF(base + V(0, 1, 0)), 3, 20, C.stone, M.Cobblestone)
local segs = 8
for i = 0, segs - 1 do
local dia = 14 - i * 1.1
Cyl(m, CF(base + V(0, 3 + i * 6 + 3, 0)), 6.1, dia, (i % 2 == 0) and C.white or Color3.fromRGB(190, 45, 45), M.Concrete)
end
local top = 3 + segs * 6
Cyl(m, CF(base + V(0, top + 0.5, 0)), 1, 13, C.iron, M.Metal)
for i = 0, 11 do
local a = i * PI / 6
P(m, V(0.4, 3, 0.4), CF(base + V(math.cos(a) * 6, top + 2.5, math.sin(a) * 6)), C.iron, M.Metal)
end
P(m, V(0.4, 0.4, 0.4), CF(base + V(0, top + 4, 0)), C.iron, M.Metal, deco())
Cyl(m, CF(base + V(0, top + 3, 0)), 4, 7, C.glass, M.Glass, { Transparency = 0.55, CanCollide = false })
local core = Cyl(m, CF(base + V(0, top + 3, 0)), 3, 3, Color3.fromRGB(255, 240, 180), M.Neon, deco())
Light(core, Color3.fromRGB(255, 240, 190), 60, 3)
Cyl(m, CF(base + V(0, top + 5.8, 0)), 1.6, 9, Color3.fromRGB(190, 45, 45), M.Metal)
Cyl(m, CF(base + V(0, top + 7.3, 0)), 2, 4, Color3.fromRGB(190, 45, 45), M.Metal)
local beam = P(m, V(2.5, 2.5, 160), CF(base + V(0, top + 3, 0)), Color3.fromRGB(255, 240, 180), M.Neon, deco({ Transparency = 0.82 }))
tag(beam, "LighthouseBeam")
P(m, V(4.5, 8, 0.6), CF(base + V(0, 4.5, 9.6)), C.wood, M.WoodPlanks, deco())
return m
end
function W.ship(parent, cf, o)
o = o or {}
local len, beam, nm = o.len or 28, o.beam or 9, o.masts or 1
local m = Model(parent, o.name or "Ship")
local N = 12
local function widthAt(t) -- t: 0 stern .. 1 bow
local w = beam * (1 - t ^ 2.6) * (0.78 + 0.22 * math.sin(math.min(t * 3.2, 1) * PI / 2))
return math.max(w, 0.3)
end
local pts = {}
for i = 0, N do
local t = i / N
pts[i] = { x = widthAt(t) / 2, z = len / 2 - t * len, t = t }
end
local hullC = o.hull or C.shipwood
local keel = P(m, V(beam * 0.45, 0.7, len * 0.9), cf * CF(0, -1.9, 0), C.darkwood, M.Wood)
keel.Name = "Hull"
m.PrimaryPart = keel
for i = 0, N - 1 do
local a, b = pts[i], pts[i + 1]
local zc, seg = (a.z + b.z) / 2, math.abs(a.z - b.z) + 0.15
local wd = (a.x + b.x)
P(m, V(wd * 0.78, 0.7, seg), cf * CF(0, -1.5, zc), hullC, M.WoodPlanks)
P(m, V(wd - 0.9, 0.5, seg), cf * CF(0, 1.1 + (i % 2) * 0.02, zc), C.deck, M.WoodPlanks)
for _, sx in ipairs({ -1, 1 }) do
local x0, x1 = sx * a.x, sx * b.x
local dx, dz = x1 - x0, b.z - a.z
local l = math.sqrt(dx * dx + dz * dz) + 0.25
local yaw = math.atan2(-dx, -dz)
local cx, cz = (x0 + x1) / 2, (a.z + b.z) / 2
P(m, V(0.8, 3.2, l), cf * CF(cx, -0.2, cz) * ANG(0, yaw, 0) * ANG(0, 0, 0), hullC, M.WoodPlanks)
P(m, V(0.9, 0.5, l), cf * CF(cx, 2.55, cz) * ANG(0, yaw, 0), C.darkwood, M.Wood)
P(m, V(0.9, 0.3, l), cf * CF(cx, 0.4, cz) * ANG(0, yaw, 0), C.darkwood, M.Wood, deco())
if i % 3 == 1 then
P(m, V(0.5, 2.4, 0.5), cf * CF(cx, 3.5, cz) * ANG(0, yaw, 0), C.darkwood, M.Wood)
end
end
end
P(m, V(0.9, 0.9, 3.4), cf * CF(0, 1.8, -len / 2 - 1.2) * ANG(0.35, 0, 0), C.darkwood, M.Wood)
Ball(m, cf * CF(0, 2.8, -len / 2 - 2.4), 1.4, C.gold, M.Metal, deco())
local cl = len * 0.26
local cz0 = len / 2 - cl / 2 - 0.4
local cw = widthAt(0.08) - 1.4
P(m, V(cw, 4.2, cl), cf * CF(0, 3.4, cz0), C.plank, M.WoodPlanks)
P(m, V(cw + 1, 0.5, cl + 1), cf * CF(0, 5.7, cz0), C.darkwood, M.Wood)
for _, sx in ipairs({ -1, 1 }) do
P(m, V(0.2, 1.2, 1.4), cf * CF(sx * (cw / 2 + 0.05), 3.8, cz0 - cl * 0.2), C.glass, M.Glass, { Transparency = 0.4 })
P(m, V(0.2, 1.2, 1.4), cf * CF(sx * (cw / 2 + 0.05), 3.8, cz0 + cl * 0.2), C.glass, M.Glass, { Transparency = 0.4 })
end
P(m, V(cw - 1, 1.2, 0.2), cf * CF(0, 3.8, cz0 + cl / 2 + 0.05), C.glass, M.Glass, { Transparency = 0.4 })
local sl = Ball(m, cf * CF(0, 6.4, cz0), 0.9, Color3.fromRGB(255, 215, 130), M.Neon, deco())
Light(sl, Color3.fromRGB(255, 205, 130), 24, 1.5)
for k = 1, nm do
local mz = len / 2 - len * (k / (nm + 1)) * 1.05 - (nm == 1 and 0 or 0) + (nm == 1 and -len * 0.02 or 0)
local mh = (o.mastH or 17) * (k == 1 and 1 or 0.9)
Cyl(m, cf * CF(0, 1 + mh / 2, mz), mh, 0.9, C.darkwood, M.Wood)
local sw = math.max(beam * 0.9, 6) * (k == 1 and 1 or 0.9)
local sh = mh * 0.62
for r = 0, (o.square and 1 or 0) do
local yoff = 1 + mh * (0.34 + r * 0.04) + r * sh * 0.45
P(m, V(sw, 0.35, 0.35), cf * CF(0, yoff + sh, mz - 0.6), C.darkwood, M.Wood, deco())
local sail = P(m, V(sw * 0.94, sh * (r == 1 and 0.6 or 1), 0.25), cf * CF(0, yoff + sh * (r == 1 and 0.7 or 0.5), mz - 0.6), C.sail, M.Fabric, { CanCollide = false })
if o.sailColor then sail.Color = o.sailColor end
end
P(m, V(0.2, 2.2, 3.2), cf * CF(0, 1 + mh + 1.2, mz - 1.4), o.flag or Color3.fromRGB(30, 30, 35), M.Fabric, deco())
end
local wz = cz0 - cl / 2 - 1.6
Cyl(m, cf * CF(0, 2.2, wz) * ANG(PI / 2, 0, 0), 0.4, 3, C.darkwood, M.Wood, deco())
P(m, V(0.5, 2.2, 0.5), cf * CF(0, 1.6, wz), C.darkwood, M.Wood)
local cn = o.cannons or 2
for i = 1, cn do
for _, sx in ipairs({ -1, 1 }) do
local z = -len * 0.22 + (i - 1) * 3.2 - (cn - 1) * 1.2
local x = sx * (widthAt(0.5) / 2 - 1.2)
P(m, V(1.2, 0.5, 2.2), cf * CF(x, 1.6, z), C.darkwood, M.Wood)
P(m, V(0.9, 0.9, 3), cf * CF(x, 2.2, z), C.iron, M.Metal)
end
end
W.barrel(m, cf * CF(beam * 0.18, 1.3, -len * 0.05), 0.8)
W.crate(m, cf * CF(-beam * 0.2, 1.3, len * 0.05), 0.8)
if o.functional then
local hz = wz - 2.4
local helm = Instance.new("Seat")
helm.Name = "HelmSeat"
helm.Size, helm.CFrame = V(2.4, 0.6, 2.4), cf * CF(0, 1.7, cz0 - cl / 2 - 3.2)
helm.Anchored, helm.Color, helm.Material = true, C.wood, M.Wood
helm.TopSurface, helm.BottomSurface = Enum.SurfaceType.Smooth, Enum.SurfaceType.Smooth
helm.Parent = m
for i, sx in ipairs({ -1, 1 }) do
local s = Instance.new("Seat")
s.Name = "PassengerSeat" .. i
s.Size, s.CFrame = V(2, 0.6, 2), cf * CF(sx * (beam * 0.22), 1.6, len * 0.12)
s.Anchored, s.Color, s.Material = true, C.wood, M.Wood
s.Parent = m
end
local pr = Instance.new("ProximityPrompt")
pr.ActionText, pr.ObjectText, pr.MaxActivationDistance = "Board", o.name or "Boat", 14
pr.RequiresLineOfSight = false
pr.Parent = keel
m:SetAttribute("MaxSpeed", o.maxSpeed or 44)
m:SetAttribute("TurnRate", o.turn or 0.9)
tag(m, "Boat")
end
return m
end
function W.tower(parent, cf, rad, h, color, mat, roofColor)
local m = Model(parent, "Tower")
Cyl(m, cf * CF(0, h / 2, 0), h, rad * 2, color, mat)
Cyl(m, cf * CF(0, h + 0.6, 0), 1.2, rad * 2 + 2, color, mat)
for i = 0, 9 do
local a = i * PI / 5
P(m, V(2, 2, 2), cf * CF(math.cos(a) * (rad + 0.7), h + 2.2, math.sin(a) * (rad + 0.7)) * ANG(0, -a, 0), color, mat)
end
for i = 1, 3 do
local a = i * 2.1
P(m, V(0.8, 3, 1.2), cf * CF(math.cos(a) * rad, h * 0.65, math.sin(a) * rad) * ANG(0, -a, 0), Color3.fromRGB(20, 20, 30), M.Slate, deco())
end
if roofColor then
local cone = Cyl(m, cf * CF(0, h + 4.5, 0), 5, rad * 1.5, roofColor, M.Slate, deco())
Cyl(m, cf * CF(0, h + 7.5, 0), 3, rad * 0.8, roofColor, M.Slate, deco())
end
return m
end
function W.temple(parent, cf)
local m = Model(parent, "MoonTemple")
local stone, glow = Color3.fromRGB(205, 210, 225), Color3.fromRGB(130, 255, 230)
for i = 0, 3 do P(m, V(48 - i * 4, 1.2, 36 - i * 3), cf * CF(0, 0.6 + i * 1.2, 0), stone, M.Marble) end
local fy = 5.2
P(m, V(32, 1, 24), cf * CF(0, fy + 0.5, 0), Color3.fromRGB(70, 80, 105), M.Slate)
for ix = -2, 2 do
for _, sz in ipairs({ -1, 1 }) do
local x, z = ix * 7, sz * 10.5
Cyl(m, cf * CF(x, fy + 8.5, z), 15, 2.4, stone, M.Marble)
Cyl(m, cf * CF(x, fy + 1, z), 1.2, 3.4, stone, M.Marble)
Cyl(m, cf * CF(x, fy + 16.4, z), 1.2, 3.4, stone, M.Marble)
end
end
for _, sx in ipairs({ -1, 1 }) do for ix = -2, 2 do
if math.abs(ix) == 2 and false then end
end end
P(m, V(38, 1.6, 28), cf * CF(0, fy + 17.7, 0), stone, M.Marble)
P(m, V(30, 1.4, 22), cf * CF(0, fy + 19.2, 0), stone, M.Marble)
P(m, V(20, 1.4, 16), cf * CF(0, fy + 20.6, 0), stone, M.Marble)
P(m, V(10, 1.4, 10), cf * CF(0, fy + 22, 0), glow, M.Neon, { Transparency = 0.2 })
Cyl(m, cf * CF(0, fy + 2, -4), 2.6, 6, stone, M.Marble)
local orb = Ball(m, cf * CF(0, fy + 6.5, -4), 3.4, glow, M.Neon, deco())
Light(orb, glow, 50, 2.5)
Emitter(orb, { Rate = 20, Lifetime = NumberRange.new(2, 3), Speed = NumberRange.new(2, 5), Size = NumberSequence.new(0.5, 0), Color = ColorSequence.new(glow), LightEmission = 1, Transparency = NumberSequence.new(0, 1) })
local ring = Cyl(m, cf * CF(0, fy + 6.5, -4) * ANG(PI / 2, 0, 0), 0.4, 7, glow, M.Neon, deco({ Transparency = 0.5 }))
for _, sx in ipairs({ -1, 1 }) do
local b = Ball(m, cf * CF(sx * 14, fy + 4, 16), 1.2, glow, M.Neon, deco())
Light(b, glow, 24, 1.5)
Cyl(m, cf * CF(sx * 14, fy + 1.5, 16), 3, 1, C.darkstone, M.Slate)
end
return m
end
function W.ruin(parent, cf, s)
local m = Model(parent, "Ruin")
s = s or 1
local st = Color3.fromRGB(110, 112, 118)
for i = 0, 5 do
local a = i * PI / 3
local broken = (i == 2 or i == 4)
local h = (broken and rr(3, 6) or rr(9, 13)) * s
Cyl(m, cf * CF(math.cos(a) * 9 * s, h / 2, math.sin(a) * 9 * s), h, 2.4 * s, st, M.Cobblestone)
if not broken then Cyl(m, cf * CF(math.cos(a) * 9 * s, h + 0.4, math.sin(a) * 9 * s), 0.8, 3.2 * s, st, M.Cobblestone) end
end
P(m, V(8 * s, 1.2, 2 * s), cf * CF(-9 * s, 11 * s, 0) * ANG(0, PI / 2, 0.15), st, M.Cobblestone)
for i = 1, 4 do
P(m, V(rr(2, 4) * s, rr(1, 2) * s, rr(2, 4) * s), cf * CF(rr(-8, 8) * s, 0.8, rr(-8, 8) * s) * ANG(rr(-0.4, 0.4), rr(0, 6), rr(-0.4, 0.4)), st:Lerp(Color3.new(0, 0, 0), 0.2), M.Slate)
end
return m
end
function W.mineEntrance(parent, cf)
local m = Model(parent, "Mine")
local wood = C.darkwood
P(m, V(16, 14, 3), cf * CF(-9, 7, 0), C.darkstone, M.Slate)
P(m, V(16, 14, 3), cf * CF(9, 7, 0), C.darkstone, M.Slate)
P(m, V(34, 6, 3), cf * CF(0, 11, 0), C.darkstone, M.Slate)
P(m, V(10, 9, 0.5), cf * CF(0, 4.5, -1), Color3.new(0.02, 0.02, 0.02), M.Slate, deco())
for _, sx in ipairs({ -1, 1 }) do P(m, V(1.2, 9.4, 1.2), cf * CF(sx * 5.2, 4.7, 2), wood, M.Wood) end
P(m, V(12, 1.2, 1.2), cf * CF(0, 9.4, 2), wood, M.Wood)
local l = Ball(m, cf * CF(0, 8, 3), 1, Color3.fromRGB(255, 190, 90), M.Neon, deco())
Light(l, Color3.fromRGB(255, 170, 80), 26, 1.6)
for i = -1, 1, 2 do
P(m, V(0.5, 0.4, 24), cf * CF(i * 1.4, 0.2, 14), C.iron, M.Metal, deco())
end
for i = 0, 8 do P(m, V(4, 0.3, 0.6), cf * CF(0, 0.1, 4 + i * 2.6), wood, M.Wood, deco()) end
P(m, V(4, 2, 5), cf * CF(0, 1.8, 18), C.iron, M.Metal)
for k = 1, 4 do Ball(m, cf * CF(rr(-1, 1), 3.1, 18 + rr(-1.5, 1.5)), rr(1.2, 2), Color3.fromRGB(255, 130, 50), M.Neon, deco()) end
return m
end
function W.crystal(parent, pos, s, color, mat)
local m = Model(parent, "Crystal")
s = s or 1
for i = 1, ri(3, 5) do
local h = rr(4, 10) * s
local p = P(m, V(1.6 * s, h, 1.6 * s), CF(pos + V(rr(-2, 2) * s, h / 2 - 0.5, rr(-2, 2) * s)) * ANG(rr(-0.35, 0.35), rr(0, 6), rr(-0.35, 0.35)), color or C.ice, mat or M.Ice, { Transparency = 0.15 })
if i == 1 then Light(p, color or C.ice, 16, 1) end
end
return m
end
function W.waterfall(parent, topPos, h, width, dirYaw)
local m = Model(parent, "Waterfall")
local cf = CF(topPos) * ANG(0, dirYaw, 0)
P(m, V(width, h, 1.2), cf * CF(0, -h / 2, 0), Color3.fromRGB(150, 210, 245), M.Glass, deco({ Transparency = 0.45 }))
P(m, V(width * 0.7, h, 0.8), cf * CF(0, -h / 2, -0.1), Color3.fromRGB(235, 248, 255), M.Neon, deco({ Transparency = 0.7 }))
local mist = P(m, V(width, 1, 3), cf * CF(0, -h + 1, -1), Color3.new(1, 1, 1), M.Neon, deco({ Transparency = 1 }))
Emitter(mist, { Rate = 35, Lifetime = NumberRange.new(1.5, 2.5), Speed = NumberRange.new(3, 6), SpreadAngle = Vector2.new(60, 60), Size = NumberSequence.new(2, 7),
Color = ColorSequence.new(Color3.fromRGB(230, 245, 255)), Transparency = NumberSequence.new(0.5, 1), EmissionDirection = Enum.NormalId.Top })
return m
end
function W.lavaPool(parent, cf, sx, sz)
local v = P(parent, V(sx, 2, sz), cf, C.lava, M.Neon, { CanCollide = false, Name = "LavaPool" })
tag(v, "Lava")
Light(v, Color3.fromRGB(255, 120, 30), 40, 2)
Emitter(v, { Rate = 8, Lifetime = NumberRange.new(2, 3), Speed = NumberRange.new(4, 9), Size = NumberSequence.new(0.5, 0), Color = ColorSequence.new(Color3.fromRGB(255, 150, 40)),
LightEmission = 1, Transparency = NumberSequence.new(0, 1), EmissionDirection = Enum.NormalId.Top, Acceleration = V(0, -4, 0) })
return v
end
function W.brazier(parent, pos, color)
local m = Model(parent, "Brazier")
Cyl(m, CF(pos + V(0, 1.5, 0)), 3, 0.9, C.iron, M.Metal)
Cyl(m, CF(pos + V(0, 3.2, 0)), 0.8, 3, C.iron, M.Metal)
local f = P(m, V(1, 1, 1), CF(pos + V(0, 4, 0)), Color3.new(1, 1, 1), M.Neon, deco({ Transparency = 1 }))
local fire = Fire(f, 7, 9)
if color then fire.Color, fire.SecondaryColor = color, color end
Light(f, color or Color3.fromRGB(255, 160, 70), 30, 2)
return m
end
local function A(isl, lx, lz, up)
local c = ISL[isl].c
local x, z = c.X + lx, c.Z + lz
return V(x, groundY(x, z, math.max(Hw(isl, x, z), 0)) + (up or 0), z)
end
local function yawToward(fx, fz, tx, tz) return math.atan2(tx - fx, tz - fz) end   -- houses/piers: front = +Z
local function yawRig(fx, fz, tx, tz) return math.atan2(-(tx - fx), -(tz - fz)) end -- rigs/boats: front = -Z
local function newFolder(parent, name)
local f = Instance.new("Folder")
f.Name = name
f.Parent = parent
return f
end
local ENV = {}
local function cleanup()
for _, n in ipairs({ "MythicWorld", "Enemies", "Bosses", "NPCs", "Boats", "SpawnLocations", "Baseplate", "SpawnLocation" }) do
local o = Workspace:FindFirstChild(n)
if o then o:Destroy() end
end
for _, c in ipairs(Workspace:GetChildren()) do
if c:IsA("SpawnLocation") then c:Destroy() end
end
Terrain:Clear()
ENV.world = newFolder(Workspace, "MythicWorld")
ENV.enemies = newFolder(Workspace, "Enemies")
ENV.bosses = newFolder(Workspace, "Bosses")
ENV.npcs = newFolder(Workspace, "NPCs")
ENV.boats = newFolder(Workspace, "Boats")
ENV.spawns = newFolder(Workspace, "SpawnLocations")
ENV.isl = {}
for name in pairs(ISL) do ENV.isl[name] = newFolder(ENV.world, name) end
ENV.sea = newFolder(ENV.world, "Sea")
end
local function setupEnvironment()
for _, c in ipairs(Lighting:GetChildren()) do
if c:IsA("Sky") or c:IsA("Atmosphere") or c:IsA("BloomEffect") or c:IsA("SunRaysEffect") or c:IsA("ColorCorrectionEffect") or c:IsA("DepthOfFieldEffect") then c:Destroy() end
end
Lighting.ClockTime = 16.2
Lighting.GeographicLatitude = 20
Lighting.Brightness = 3
Lighting.Ambient = Color3.fromRGB(80, 85, 105)
Lighting.OutdoorAmbient = Color3.fromRGB(105, 115, 140)
Lighting.ColorShift_Top = Color3.fromRGB(255, 220, 170)
Lighting.EnvironmentDiffuseScale = 1
Lighting.EnvironmentSpecularScale = 1
Lighting.GlobalShadows = true
Lighting.ShadowSoftness = 0.3
local at = Instance.new("Atmosphere")
at.Density, at.Offset, at.Color, at.Decay, at.Glare, at.Haze = 0.33, 0.25, Color3.fromRGB(199, 190, 175), Color3.fromRGB(255, 190, 140), 0.4, 1.6
at.Parent = Lighting
local sky = Instance.new("Sky")
sky.SunAngularSize = 14
sky.Parent = Lighting
local bl = Instance.new("BloomEffect")
bl.Intensity, bl.Size, bl.Threshold = 0.5, 30, 1.8
bl.Parent = Lighting
local sr = Instance.new("SunRaysEffect")
sr.Intensity, sr.Spread = 0.12, 0.8
sr.Parent = Lighting
local cc = Instance.new("ColorCorrectionEffect")
cc.Saturation, cc.Contrast, cc.Brightness = 0.18, 0.08, 0
cc.TintColor = Color3.fromRGB(255, 244, 232)
cc.Parent = Lighting
local old = Terrain:FindFirstChildOfClass("Clouds")
if old then old:Destroy() end
local cl = Instance.new("Clouds")
cl.Cover, cl.Density, cl.Color = 0.55, 0.6, Color3.fromRGB(255, 240, 225)
cl.Parent = Terrain
Terrain.WaterColor = Color3.fromRGB(40, 125, 160)
Terrain.WaterTransparency = 0.82
Terrain.WaterReflectance = 0.85
Terrain.WaterWaveSize = 0.45
Terrain.WaterWaveSpeed = 14
local cols = {
[M.Grass] = Color3.fromRGB(96, 150, 66), [M.LeafyGrass] = Color3.fromRGB(70, 135, 95), [M.Sand] = Color3.fromRGB(226, 205, 150),
[M.Rock] = Color3.fromRGB(118, 118, 124), [M.Slate] = Color3.fromRGB(70, 66, 72), [M.Basalt] = Color3.fromRGB(46, 42, 45),
[M.CrackedLava] = Color3.fromRGB(190, 70, 20), [M.Ground] = Color3.fromRGB(120, 95, 68), [M.Mud] = Color3.fromRGB(80, 70, 70),
[M.Snow] = Color3.fromRGB(240, 246, 255), [M.Ice] = Color3.fromRGB(150, 210, 245), [M.Glacier] = Color3.fromRGB(185, 225, 245),
[M.Cobblestone] = Color3.fromRGB(150, 145, 138),
}
for mat, col in pairs(cols) do Terrain:SetMaterialColor(mat, col) end
end
local function buildOcean()
local x0, z0, x1, z1, T = -1300, -1300, 1300, 500, 325
for x = x0, x1 - 1, T do
for z = z0, z1 - 1, T do
Terrain:FillBlock(CF(x + T / 2, -26, z + T / 2), V(T, 8, T), M.Sand)
Terrain:FillBlock(CF(x + T / 2, -11, z + T / 2), V(T, 22, T), M.Water)
end
task.wait()
end
end
local function house(isl, lx, lz, tx, tz, o)
local pos = A(isl, lx, lz)
local yaw = yawToward(lx, lz, tx or 0, tz or 0)
local cf = CF(pos) * ANG(0, yaw, 0)
W.house(ENV.isl[isl], cf, o)
return cf, yaw
end
local function npcAt(feet, yaw, name, o)
return W.npc(ENV.npcs, name, feet, yaw, o)
end
local function npc(isl, name, lx, lz, tx, tz, o)
return npcAt(A(isl, lx, lz), yawRig(lx, lz, tx, tz), name, o)
end
local enemyFn = { Bandit = W.bandit, EmberRaider = W.raider, FrostGuardian = W.guardian, MoonBeast = W.beast }
local function enemy(kind, isl, lx, lz)
local pos = A(isl, lx, lz)
local m = enemyFn[kind](ENV.enemies, pos, rr(0, 6.28))
m:SetAttribute("Island", isl)
return m
end
local function ring(kind, isl, cx, cz, rad, n)
for i = 1, n do
local a = i / n * PI * 2 + rr(-0.3, 0.3)
enemy(kind, isl, cx + math.cos(a) * rad * rr(0.6, 1), cz + math.sin(a) * rad * rr(0.6, 1))
end
end
local function shoreOf(isl, sx, sz, dx, dz)
local r = 0
while r < 400 and H(ISL[isl], sx + dx * r, sz + dz * r) > 1.0 do r += 1 end
return sx + dx * r, sz + dz * r
end
local function dock(isl, sx, sz, dx, dz, o)
o = o or {}
local ex, ez = shoreOf(isl, sx, sz, dx, dz)
local len = 48
local startLX, startLZ = ex - dx * 8, ez - dz * 8
local base = A(isl, startLX, startLZ)
local p0 = V(base.X, 3, base.Z)
local yaw = math.atan2(dx, dz)
local F = ENV.isl[isl]
W.pier(F, p0, yaw, len, 8)
local perp = V(-dz, 0, dx)
local dir = V(dx, 0, dz)
local tip = p0 + dir * (len - 14)
local bpos = V(tip.X, 0, tip.Z) + perp * 11
local boat = W.ship(ENV.boats, CF(bpos) * ANG(0, math.atan2(-dx, -dz), 0), { name = o.boatName or (isl .. " Sloop"), len = 26, beam = 9, masts = 1, functional = true, sailColor = o.sail, maxSpeed = 46 })
boat:SetAttribute("Island", isl)
if o.galleon then
local gpos = V(tip.X, 0, tip.Z) - perp * 16 + dir * 6
W.ship(ENV.boats, CF(gpos) * ANG(0, math.atan2(-dx, -dz), 0), { name = "Galleon", len = 58, beam = 15, masts = 3, square = true, mastH = 24, cannons = 4, static = true })
end
local fl = V(startLX - dx * 4, 0, startLZ - dz * 4) + perp * 8
local ferryman = npc(isl, "Ferryman " .. (o.ferry or "Pike"), fl.X, fl.Z, ex, ez, { role = "Travel", title = "Ferry", action = "Travel", hat = "cap", hatColor = Color3.fromRGB(40, 70, 110), shirt = Color3.fromRGB(60, 90, 130), beard = Color3.fromRGB(190, 190, 195) })
local padPos = A(isl, startLX - dx * 14, startLZ - dz * 14, 1)
local pad = P(ENV.spawns, V(6, 1, 6), CF(padPos), Color3.new(1, 1, 1), M.SmoothPlastic, { Transparency = 1, CanCollide = false, Name = "Travel_" .. isl })
local lamp = A(isl, startLX - dx * 6, startLZ - dz * 6 + 0)
W.lamp(F, lamp + perp * -6, 9)
W.lamp(F, lamp + perp * 6, 9)
return { sx = startLX, sz = startLZ, dx = dx, dz = dz, ex = ex, ez = ez }
end
local function lampsOnRing(isl, cx, cz, rad, n, h)
for i = 1, n do
local a = i / n * PI * 2
W.lamp(ENV.isl[isl], A(isl, cx + math.cos(a) * rad, cz + math.sin(a) * rad), h)
end
end
local function mushroom(parent, pos, s)
local col = Color3.fromRGB(100, 255, 220):Lerp(Color3.fromRGB(150, 130, 255), rr(0, 1))
Cyl(parent, CF(pos + V(0, 1.2 * s, 0)), 2.4 * s, 0.7 * s, Color3.fromRGB(225, 225, 235), M.SmoothPlastic, deco())
local cap = Ball(parent, CF(pos + V(0, 2.5 * s, 0)), 3 * s, col, M.Neon, deco())
if ri(1, 3) == 1 then Light(cap, col, 14, 1) end
end
local function buildHaven()
local I = "Haven"
local F = ENV.isl[I]
W.fountain(F, A(I, 0, 0))
house(I, -44, -24, 0, 0, { name = "Tavern", kind = "tavern", w = 28, d = 20, h = 10, wall = Color3.fromRGB(190, 150, 110), roof = Color3.fromRGB(110, 55, 45), sign = "THE SALTY MERMAID" })
house(I, 44, -24, 0, 0, { name = "WeaponShop", kind = "weapon", w = 22, d = 18, h = 9, wall = Color3.fromRGB(150, 150, 160), wmat = M.Cobblestone, roof = Color3.fromRGB(60, 65, 85), sign = "IRONHAND ARMS" })
house(I, 0, -56, 0, 0, { name = "PowerShop", kind = "power", w = 24, d = 20, h = 11, wall = Color3.fromRGB(110, 95, 150), wmat = M.Marble, roof = Color3.fromRGB(70, 50, 120), sign = "CORE SANCTUM", rise = 6 })
local hcols = { Color3.fromRGB(205, 185, 150), Color3.fromRGB(180, 205, 200), Color3.fromRGB(215, 175, 165), Color3.fromRGB(190, 195, 215) }
local hp = { { -62, 8 }, { -48, 40 }, { -22, 56 }, { 22, 56 }, { 48, 40 }, { 62, 8 } }
for i, p in ipairs(hp) do
house(I, p[1], p[2], 0, 0, { name = "House" .. i, kind = "house", w = 16, d = 13, h = 8.5, wall = hcols[(i - 1) % 4 + 1], roof = (i % 2 == 0) and C.roof or Color3.fromRGB(80, 105, 130) })
end
npc(I, "Captain Marlow", -14, 10, 0, 0, { role = "Quest", title = "Quest Giver", hat = "tricorn", shirt = Color3.fromRGB(150, 40, 40), coat = Color3.fromRGB(110, 30, 35), beard = Color3.fromRGB(70, 50, 40), prop = "sword", action = "Quest" })
npc(I, "Dockhand Tilly", 18, 14, 0, 0, { role = "Villager", title = "Villager", hat = "cap", shirt = Color3.fromRGB(90, 130, 90), lines = "Bandits have been raiding the west beach. Captain Marlow pays well for anyone brave enough." })
npc(I, "Old Maren", -30, 36, 0, 0, { role = "Villager", title = "Villager", hat = "straw", hatColor = C.thatch, apron = Color3.fromRGB(235, 230, 215), lines = "Four islands out there, dear. Emberreach burns, Moonveil whispers, Frostmere bites. Pack accordingly." })
npc(I, "Young Pip", 30, 30, 0, 0, { role = "Villager", title = "Villager", shirt = Color3.fromRGB(200, 170, 80), lines = "I'm going to be a Cinder Wielder one day. Or a Tide Caller. Maybe both!" })
local function inside(lx, lz, tx, tz, name, o, ix, iz)
local pos = A(I, lx, lz)
local yaw = yawToward(lx, lz, tx, tz)
local cf = CF(pos) * ANG(0, yaw, 0)
local feet = cf:PointToWorldSpace(V(ix, 0.8, iz))
return npcAt(feet, yaw + PI, name, o)
end
inside(-44, -24, 0, 0, "Barkeep Odell", { role = "Healer", title = "Rest & Heal", action = "Rest", apron = Color3.fromRGB(240, 240, 235), shirt = Color3.fromRGB(160, 110, 70), beard = Color3.fromRGB(140, 90, 50) }, 0, -7.4)
inside(44, -24, 0, 0, "Brynn Ironhand", { role = "WeaponShop", title = "Weaponsmith", action = "Shop", apron = Color3.fromRGB(70, 55, 45), shirt = Color3.fromRGB(150, 70, 50), prop = "hammer", beard = Color3.fromRGB(110, 60, 30) }, 0, -1.4)
inside(0, -56, 0, 0, "Seer Oriel", { role = "PowerShop", title = "Core Keeper", action = "Shop", robe = Color3.fromRGB(80, 55, 140), shirt = Color3.fromRGB(110, 75, 180), hat = "wizard", hatColor = Color3.fromRGB(70, 45, 130), prop = "staff", beard = Color3.fromRGB(225, 225, 230) }, 0, -5)
lampsOnRing(I, 0, 0, 24, 8, 8)
for i = 1, 4 do
local a = i * PI / 2 + PI / 4
W.crate(F, CF(A(I, math.cos(a) * 34, math.sin(a) * 34)) * ANG(0, a, 0), 1)
W.barrel(F, CF(A(I, math.cos(a) * 34 + 3, math.sin(a) * 34 + 3)), 1)
end
local pa, pb = A(I, -105, -80), A(I, -45, -80)
local py = math.max(pa.Y, pb.Y) + 1.2
W.bridge(F, V(pa.X, py, pa.Z), V(pb.X, py, pb.Z), 6)
local cx, cz = -110, 45
for i = 1, 3 do
local a = i * 2.1
local px, pz = cx + math.cos(a) * 17, cz + math.sin(a) * 17
W.tent(F, CF(A(I, px, pz)) * ANG(0, yawToward(px, pz, cx, cz), 0), Color3.fromRGB(150 - i * 20, 55, 50))
end
W.campfire(F, A(I, cx, cz))
for i = 1, 5 do
local a = i * 1.3
W.crate(F, CF(A(I, cx + math.cos(a) * 9, cz + math.sin(a) * 9)) * ANG(0, a, 0), rr(0.8, 1.1))
end
W.barrel(F, CF(A(I, cx + 6, cz - 7)), 1)
W.barrel(F, CF(A(I, cx - 7, cz + 5)), 1)
ring("Bandit", I, cx, cz, 13, 4)
enemy("Bandit", I, cx + 20, cz - 14)
enemy("Bandit", I, cx - 18, cz - 18)
W.lighthouse(F, A(I, 120, -95))
dock(I, 0, 150, 0, 1, { galleon = true, ferry = "Pike", boatName = "Haven Sloop" })
local avoid = { { 0, 0, 86 }, { -110, 45, 38 }, { 120, -95, 30 }, { -75, -80, 34 }, { 0, 185, 28 } }
scatter(I, 40, 120, 196, 1.8, function(p) W.tree(F, p, rr(0.85, 1.2), "palm") end, avoid, 6)
scatter(I, 34, 90, 170, 3, function(p) W.tree(F, p, rr(0.8, 1.3), "oak") end, avoid, 5)
scatter(I, 50, 20, 190, 2.5, function(p) W.bush(F, p, rr(0.8, 1.3)) end, { { 0, 0, 70 }, { -110, 45, 30 }, { 0, 185, 28 } }, 6)
scatter(I, 18, 40, 195, 1.5, function(p) W.rock(F, p, rr(0.8, 1.8)) end, { { 0, 0, 70 }, { 0, 185, 28 } }, 8)
end
local function lavaStream(isl, pts, width)
local F = ENV.isl[isl]
for i = 1, #pts - 1 do
local a, b = pts[i], pts[i + 1]
local len = math.sqrt((b[1] - a[1]) ^ 2 + (b[2] - a[2]) ^ 2)
local n = math.max(1, math.floor(len / 9))
for k = 0, n - 1 do
local t = (k + 0.5) / n
local lx, lz = a[1] + (b[1] - a[1]) * t, a[2] + (b[2] - a[2]) * t
local pos = A(isl, lx, lz)
local yaw = math.atan2(-(b[1] - a[1]), -(b[2] - a[2]))
local v = P(F, V(width, 1.2, len / n + 1.5), CF(pos + V(0, 0.2, 0)) * ANG(0, yaw, 0), C.lava, M.Neon, { CanCollide = false, Name = "LavaStream" })
tag(v, "Lava")
if k % 3 == 0 then Light(v, Color3.fromRGB(255, 120, 30), 24, 1.5) end
end
end
end
local function buildEmber()
local I = "Ember"
local F = ENV.isl[I]
local floorP = A(I, 0, 0)
W.lavaPool(F, CF(floorP + V(0, 0.3, 0)), 28, 28)
local smoke = P(F, V(10, 1, 10), CF(floorP + V(0, 10, 0)), Color3.new(1, 1, 1), M.Neon, deco({ Transparency = 1 }))
Emitter(smoke, { Rate = 30, Lifetime = NumberRange.new(8, 12), Speed = NumberRange.new(10, 18), Size = NumberSequence.new(8, 30), Color = ColorSequence.new(Color3.fromRGB(70, 62, 62)),
Transparency = NumberSequence.new(0.4, 1), EmissionDirection = Enum.NormalId.Top, SpreadAngle = Vector2.new(15, 15) })
Emitter(smoke, { Rate = 12, Lifetime = NumberRange.new(3, 5), Speed = NumberRange.new(30, 55), Size = NumberSequence.new(1.5, 0.3), Color = ColorSequence.new(Color3.fromRGB(255, 140, 40)),
LightEmission = 1, Transparency = NumberSequence.new(0, 1), EmissionDirection = Enum.NormalId.Top, SpreadAngle = Vector2.new(25, 25), Acceleration = V(0, -35, 0) })
for _, rv in ipairs(ISL.Ember.rivers) do lavaStream(I, rv[1], 11) end
local function bridgeAcross(mx, mz, dxr, dzr)
local l = math.sqrt(dxr * dxr + dzr * dzr)
local px, pz = -dzr / l, dxr / l
local a, b = A(I, mx - px * 17, mz - pz * 17), A(I, mx + px * 17, mz + pz * 17)
local y = math.max(a.Y, b.Y) + 1.2
W.bridge(F, V(a.X, y, a.Z), V(b.X, y, b.Z), 8, { c1 = C.darkstone, c2 = C.basalt, mat = M.Slate, rail = C.iron, lamp = Color3.fromRGB(255, 130, 40) })
end
bridgeAcross(60, 77.5, 30, 35)
bridgeAcross(70, -60, 30, -20)
local d = dock(I, -165, 15, -1, 0, { ferry = "Cinder", sail = Color3.fromRGB(190, 70, 50), boatName = "Ember Sloop" })
local sp = { { -150, -12 }, { -150, 42 }, { -125, 15 } }
for i, p in ipairs(sp) do
house(I, p[1], p[2], -165, 15, { name = "EmberHouse" .. i, w = 16, d = 13, h = 8, wall = Color3.fromRGB(95, 80, 78), wmat = M.Slate, roof = Color3.fromRGB(60, 30, 28), roofMat = M.Slate })
end
npc(I, "Quartermaster Ash", -138, 22, -150, 15, { role = "Quest", title = "Quest Giver", action = "Quest", hat = "tricorn", hatColor = Color3.fromRGB(70, 35, 30), shirt = Color3.fromRGB(110, 45, 30), coat = Color3.fromRGB(80, 35, 28), skin = Color3.fromRGB(170, 120, 95), eyepatch = true, prop = "sword" })
npc(I, "Smith Kael", -128, -2, -150, 15, { role = "Villager", title = "Villager", apron = Color3.fromRGB(60, 50, 45), prop = "hammer", lines = "The Raiders have taken the east camp. And the Warden sleeps in the old arena. Watch the lava!" })
W.brazier(F, A(I, -140, 30), Color3.fromRGB(255, 120, 40))
W.brazier(F, A(I, -140, 0), Color3.fromRGB(255, 120, 40))
local function camp(cx, cz, n)
for i = 1, 3 do
local a = i * 2.1 + 0.5
local px, pz = cx + math.cos(a) * 15, cz + math.sin(a) * 15
W.tent(F, CF(A(I, px, pz)) * ANG(0, yawToward(px, pz, cx, cz), 0), Color3.fromRGB(70 + i * 10, 35, 30))
end
W.campfire(F, A(I, cx, cz))
for i = 1, 4 do
local a = i * 1.57
local sx, sz = cx + math.cos(a) * 22, cz + math.sin(a) * 22
W.brazier(F, A(I, sx, sz), Color3.fromRGB(255, 110, 30))
end
ring("EmberRaider", I, cx, cz, 12, n)
end
camp(-120, 60, 4)
camp(140, 10, 3)
local mp = A(I, -100, -42)
W.mineEntrance(F, CF(mp))
for i = 1, 4 do W.crate(F, CF(A(I, -112 + i * 6, -22)) * ANG(0, i, 0), 1) end
W.lamp(F, A(I, -88, -30), 8)
W.lamp(F, A(I, -112, -30), 8)
for i = 1, 5 do W.crystal(F, A(I, -100 + rr(-20, 20), -25 + rr(-10, 15)), rr(0.8, 1.4), Color3.fromRGB(255, 140, 60), M.Neon) end
W.ruin(F, CF(A(I, -45, 115)), 1.2)
W.ruin(F, CF(A(I, -20, 130)) * ANG(0, 1, 0), 0.9)
W.ruin(F, CF(A(I, -65, 100)) * ANG(0, 2, 0), 0.8)
enemy("EmberRaider", I, -40, 105)
enemy("EmberRaider", I, -60, 125)
local ax, az = -90, -110
local ap = A(I, ax, az)
Cyl(F, CF(ap + V(0, 0.2, 0)), 0.5, 80, Color3.fromRGB(32, 28, 32), M.Basalt, { Name = "ArenaFloor" })
Cyl(F, CF(ap + V(0, 0.5, 0)), 0.1, 60, Color3.fromRGB(255, 110, 25), M.Neon, deco({ Transparency = 0.2 }))
Cyl(F, CF(ap + V(0, 0.55, 0)), 0.1, 56, Color3.fromRGB(32, 28, 32), M.Basalt, deco())
Cyl(F, CF(ap + V(0, 0.6, 0)), 0.1, 28, Color3.fromRGB(255, 110, 25), M.Neon, deco({ Transparency = 0.3 }))
Cyl(F, CF(ap + V(0, 0.65, 0)), 0.1, 24, Color3.fromRGB(32, 28, 32), M.Basalt, deco())
for i = 0, 11 do
local a = i / 12 * PI * 2
local pp = ap + V(math.cos(a) * 40, 0, math.sin(a) * 40)
Cyl(F, CF(pp + V(0, 8, 0)), 16, 4, Color3.fromRGB(45, 40, 44), M.Basalt)
Cyl(F, CF(pp + V(0, 16.4, 0)), 1, 5.4, Color3.fromRGB(70, 62, 66), M.Basalt)
local f = P(F, V(1, 1, 1), CF(pp + V(0, 18, 0)), Color3.new(1, 1, 1), M.Neon, deco({ Transparency = 1 }))
Fire(f, 10, 12)
Light(f, Color3.fromRGB(255, 130, 40), 36, 2)
end
local ar = P(F, V(1, 1, 1), CF(ap + V(0, 40, 0)), Color3.new(1, 1, 1), M.Neon, deco({ Transparency = 1 }))
Emitter(ar, { Rate = 40, Lifetime = NumberRange.new(5, 8), Speed = NumberRange.new(4, 9), Size = NumberSequence.new(0.5, 0.1), Color = ColorSequence.new(Color3.fromRGB(255, 150, 50)), LightEmission = 1,
Transparency = NumberSequence.new(0, 1), Acceleration = V(0, 3, 0), SpreadAngle = Vector2.new(180, 180) })
sign(F, CF(ap + V(40 * 0.0, 11, 46)), "CINDER WARDEN'S ARENA", V(16, 3, 0.5), Color3.fromRGB(40, 35, 38), Color3.fromRGB(255, 150, 50))
P(F, V(0.8, 9, 0.8), CF(ap + V(-7, 4.5, 46)), C.iron, M.Metal)
P(F, V(0.8, 9, 0.8), CF(ap + V(7, 4.5, 46)), C.iron, M.Metal)
local boss = W.boss(ENV.bosses, ap + V(0, 0.7, 0), 0, "Fire")
boss:SetAttribute("Island", I)
local avoid = { { 0, 0, 120 }, { -90, -110, 70 }, { -120, 60, 40 }, { 140, 10, 36 }, { -100, -25, 34 }, { -45, 115, 34 }, { -165, 15, 40 } }
scatter(I, 36, 50, 215, 3, function(p) W.tree(F, p, rr(0.8, 1.3), "dead") end, avoid, 7)
scatter(I, 28, 40, 215, 2.5, function(p) W.rock(F, p, rr(1, 2.4), Color3.fromRGB(55, 50, 54), M.Basalt) end, avoid, 9)
scatter(I, 4, 60, 190, 4, function(p) W.lavaPool(F, CF(p + V(0, 0.2, 0)), rr(7, 12), rr(7, 12)) end, avoid, 3)
scatter(I, 10, 60, 200, 3, function(p) W.crystal(F, p, rr(0.8, 1.6), Color3.fromRGB(255, 120, 50), M.Neon) end, avoid, 8)
scatter(I, 5, 130, 200, 3, function(p, lx, lz) enemy("EmberRaider", I, lx, lz) end, avoid, 3)
for _, off in ipairs({ { 0, 0 }, { -90, -110 }, { 140, 10 }, { -120, 60 } }) do
local ep = A(I, off[1], off[2], 14)
local e = P(F, V(70, 1, 70), CF(ep), Color3.new(1, 1, 1), M.Neon, deco({ Transparency = 1 }))
Emitter(e, { Rate = 22, Lifetime = NumberRange.new(6, 9), Speed = NumberRange.new(2, 5), Size = NumberSequence.new(0.35, 0.1), Color = ColorSequence.new(Color3.fromRGB(255, 140, 40)),
LightEmission = 1, Transparency = NumberSequence.new(0.1, 1), EmissionDirection = Enum.NormalId.Top, Acceleration = V(1, 2, 0), SpreadAngle = Vector2.new(40, 40) })
end
end
local function buildMoon()
local I = "Moonveil"
local F = ENV.isl[I]
local d = dock(I, 170, 10, 1, 0, { ferry = "Lumen", sail = Color3.fromRGB(150, 200, 230), boatName = "Moon Sloop" })
local tc = CF(A(I, 0, -70))
W.temple(F, tc)
npc(I, "Warden Sylra", 0, -40, 0, -70, { role = "Quest", title = "Quest Giver", action = "Quest", robe = Color3.fromRGB(40, 100, 90), shirt = Color3.fromRGB(60, 140, 120), hat = "hood", hatColor = Color3.fromRGB(35, 85, 80), prop = "staff", orb = Color3.fromRGB(120, 255, 220) })
npc(I, "Fern the Hermit", 150, 22, 170, 10, { role = "Villager", title = "Villager", hat = "straw", hatColor = Color3.fromRGB(120, 150, 90), shirt = Color3.fromRGB(80, 120, 90), lines = "The beasts howl when the moon is high. Climb the mesa east of here... if you can find the way." })
house(I, 150, -18, 170, 10, { name = "MoonHouse1", w = 16, d = 13, h = 8, wall = Color3.fromRGB(120, 140, 150), roof = Color3.fromRGB(50, 90, 100) })
house(I, 150, 42, 170, 10, { name = "MoonHouse2", w = 16, d = 13, h = 8, wall = Color3.fromRGB(150, 140, 170), roof = Color3.fromRGB(70, 60, 110) })
local ba, bb = A(I, 20, 50), A(I, 76, 50)
local by = math.max(ba.Y, bb.Y) + 1.4
W.bridge(F, V(ba.X, by, ba.Z), V(bb.X, by, bb.Z), 6, { lamp = Color3.fromRGB(130, 255, 230) })
W.chest(F, CF(A(I, 95, 50)) * ANG(0, -PI / 2, 0), "moon_secret", Color3.fromRGB(130, 255, 230))
for _, p in ipairs({ { 80, 38 }, { 80, 62 }, { 110, 38 }, { 110, 62 } }) do W.brazier(F, A(I, p[1], p[2]), Color3.fromRGB(110, 255, 220)) end
local wp = A(I, 64.5, 50)
W.waterfall(F, V(wp.X, 56, wp.Z), 56, 8, PI / 2)
for i = 0, 5 do W.lamp(F, A(I, 138 - i * 7.5, 54 + (i % 2) * -8), 7) end
local tp = A(I, -60, -10)
W.tree(F, tp, 1, "giant")
W.chest(F, CF(tp + V(7.5, 0, 0)) * ANG(0, -PI / 2, 0), "moon_cache", Color3.fromRGB(130, 255, 230))
W.ruin(F, CF(A(I, -120, -40)), 1.2)
W.ruin(F, CF(A(I, -140, 20)) * ANG(0, 2, 0), 1)
W.ruin(F, CF(A(I, 100, -110)), 1)
local avoid = { { 0, -70, 56 }, { 170, 10, 40 }, { 95, 50, 44 }, { 48, 50, 30 }, { -90, 50, 36 }, { -60, -10, 14 }, { 140, 50, 20 }, { 150, 10, 34 } }
scatter(I, 14, 30, 205, 2.5, function(p) W.tree(F, p, rr(0.75, 1.15), "giant") end, avoid, 5)
scatter(I, 30, 30, 210, 2.5, function(p) W.tree(F, p, rr(0.9, 1.4), "oak") end, avoid, 5)
scatter(I, 40, 20, 210, 2.5, function(p) W.bush(F, p, rr(0.8, 1.4), Color3.fromRGB(60, 150, 125)) end, avoid, 6)
scatter(I, 40, 20, 210, 2.5, function(p) mushroom(F, p, rr(0.8, 2)) end, avoid, 6)
scatter(I, 16, 20, 210, 2.5, function(p) W.rock(F, p, rr(1, 2.2), Color3.fromRGB(90, 105, 110)) end, avoid, 9)
scatter(I, 9, 40, 200, 3, function(p, lx, lz) enemy("MoonBeast", I, lx, lz) end, avoid, 4)
ring("MoonBeast", I, -125, -10, 25, 3)
for _, off in ipairs({ { 0, 0 }, { -90, 50 }, { 50, -100 }, { -120, -60 }, { 100, 100 } }) do
local ep = A(I, off[1], off[2], 10)
local e = P(F, V(80, 1, 80), CF(ep), Color3.new(1, 1, 1), M.Neon, deco({ Transparency = 1 }))
Emitter(e, { Rate = 14, Lifetime = NumberRange.new(5, 8), Speed = NumberRange.new(1, 3), Size = NumberSequence.new(0.5, 0.3), Color = ColorSequence.new(Color3.fromRGB(150, 255, 220)),
LightEmission = 1, Transparency = NumberSequence.new(0.2, 1), EmissionDirection = Enum.NormalId.Top, SpreadAngle = Vector2.new(180, 180) })
end
end
local function buildFrost()
local I = "Frost"
local F = ENV.isl[I]
local d = dock(I, 0, 150, 0, 1, { ferry = "Floe", sail = Color3.fromRGB(200, 225, 245), boatName = "Frost Sloop" })
local snowRoof = Color3.fromRGB(235, 242, 250)
local vh = { { -34, 62 }, { 34, 62 }, { -40, 96 }, { 40, 96 } }
for i, p in ipairs(vh) do
house(I, p[1], p[2], 0, 80, { name = "FrostHouse" .. i, w = 15, d = 12, h = 8, wall = Color3.fromRGB(150, 175, 205), roof = snowRoof, roofMat = M.Snow })
end
npc(I, "Ranger Isolde", 0, 50, 0, 75, { role = "Quest", title = "Quest Giver", action = "Quest", hat = "fur", shirt = Color3.fromRGB(60, 95, 140), coat = Color3.fromRGB(70, 110, 160), prop = "staff", orb = Color3.fromRGB(150, 230, 255) })
npc(I, "Trader Brisk", 14, 86, 0, 75, { role = "Villager", title = "Villager", hat = "fur", shirt = Color3.fromRGB(130, 80, 70), lines = "Guardians patrol the ice. Past the crevasse, the castle holds something colder than the wind." })
for _, p in ipairs({ { -14, 70 }, { 14, 70 }, { 0, 100 } }) do W.brazier(F, A(I, p[1], p[2]), Color3.fromRGB(130, 230, 255)) end
lampsOnRing(I, 0, 78, 30, 6, 8)
local a, b = A(I, 0, -33), A(I, 0, -60)
local y = math.max(a.Y, b.Y) + 1.4
W.bridge(F, V(a.X, y, a.Z), V(b.X, y, b.Z), 10, { c1 = C.ice, c2 = C.glass, mat = M.Ice, rail = C.ice, lamp = Color3.fromRGB(150, 230, 255) })
local cx, cz, half, wh = 0, -95, 38, 15
local cpos = A(I, cx, cz)
local gy = cpos.Y
local function icewall(cf, L, ops)
wall(F, cf, L, wh, 4, Color3.fromRGB(175, 215, 240), M.Ice, ops)
for i = 0, math.floor(L / 6) do
P(F, V(3, 2, 4), cf * CF(-L / 2 + 1.5 + i * 6, wh + 1, 0), Color3.fromRGB(190, 230, 250), M.Ice)
end
end
local base = CF(cpos)
icewall(base * CF(0, 0, half), 2 * half, nil)
icewall(base * CF(half, 0, 0) * ANG(0, PI / 2, 0), 2 * half, nil)
icewall(base * CF(-half, 0, 0) * ANG(0, -PI / 2, 0), 2 * half, nil)
icewall(base * CF(0, 0, -half) * ANG(0, PI, 0), 2 * half, { { x = 0, w = 14, y0 = 0, y1 = 11 } })
for _, sx in ipairs({ -1, 1 }) do for _, sz in ipairs({ -1, 1 }) do
W.tower(F, base * CF(sx * half, 0, sz * half), 6, 22, Color3.fromRGB(165, 210, 238), M.Ice, Color3.fromRGB(110, 170, 230))
end end
local kz = -half + 16
P(F, V(30, 26, 20), base * CF(0, 13, kz), Color3.fromRGB(165, 210, 238), M.Ice)
P(F, V(34, 2, 24), base * CF(0, 27, kz), Color3.fromRGB(235, 245, 255), M.Snow)
P(F, V(8, 12, 0.6), base * CF(0, 6, kz + 10.2), Color3.fromRGB(20, 40, 70), M.Glass, deco({ Transparency = 0.2 }))
for i = -1, 1 do
local cr = Ball(F, base * CF(i * 9, 22, kz + 10.3), 1.4, Color3.fromRGB(150, 235, 255), M.Neon, deco())
Light(cr, Color3.fromRGB(150, 235, 255), 30, 2)
end
for _, p in ipairs({ { -20, 8 }, { 20, 8 }, { -20, -4 }, { 20, -4 } }) do W.brazier(F, base.Position + V(p[1], 0, p[2]), Color3.fromRGB(130, 230, 255)) end
for i = 0, 7 do
local a2 = i / 8 * PI * 2
W.crystal(F, base.Position + V(math.cos(a2) * 24, 0, math.sin(a2) * 24 + 4), 1.8, Color3.fromRGB(150, 225, 255), M.Ice)
end
local boss = W.boss(ENV.bosses, base.Position + V(0, 0.5, 4), 0, "Ice")
boss:SetAttribute("Island", I)
sign(F, base * CF(0, 14, half + 3), "RIMEHEART CITADEL", V(16, 3, 0.5), Color3.fromRGB(70, 110, 160), Color3.fromRGB(220, 245, 255))
for i = 1, 8 do
local lx, lz = -105 + rr(-30, 30), 25 + rr(-30, 30)
if (lx + 105) ^ 2 + (lz - 25) ^ 2 < 38 * 38 then W.crystal(F, A(I, lx, lz), rr(0.6, 1.3), C.ice, M.Ice) end
end
local cvp = A(I, -170, -70)
local cvc = CF(cvp) * ANG(0, 0.9, 0)
for _, sx in ipairs({ -1, 1 }) do
P(F, V(5, 18, 8), cvc * CF(sx * 9, 8, 0) * ANG(0, 0, sx * -0.12), Color3.fromRGB(150, 205, 238), M.Ice)
P(F, V(4, 14, 6), cvc * CF(sx * 13, 6, 3) * ANG(0, 0.3, sx * 0.2), Color3.fromRGB(135, 190, 230), M.Ice)
end
P(F, V(24, 5, 8), cvc * CF(0, 18, 0), Color3.fromRGB(160, 215, 242), M.Ice)
P(F, V(16, 12, 12), cvc * CF(0, 6, -6), Color3.fromRGB(10, 20, 40), M.Slate, deco())
local cl = Ball(F, cvc * CF(0, 6, -2), 1.5, Color3.fromRGB(130, 220, 255), M.Neon, deco())
Light(cl, Color3.fromRGB(130, 220, 255), 34, 2)
for i = 1, 6 do W.crystal(F, cvp + V(rr(-18, 18), 0, rr(-4, 12)), rr(1, 2), C.ice, M.Ice) end
local avoid = { { 0, 78, 56 }, { 0, -95, 70 }, { 0, -46, 20 }, { -105, 25, 54 }, { -170, -70, 30 }, { 0, 190, 30 } }
scatter(I, 55, 50, 215, 2, function(p) W.tree(F, p, rr(0.8, 1.4), "snowpine") end, avoid, 6)
scatter(I, 28, 40, 215, 2, function(p) W.crystal(F, p, rr(1, 2.2), C.ice, M.Ice) end, avoid, 8)
scatter(I, 22, 40, 215, 2, function(p) W.rock(F, p, rr(1, 2.4), Color3.fromRGB(190, 205, 220), M.Glacier) end, avoid, 9)
scatter(I, 7, 60, 200, 2.5, function(p, lx, lz) enemy("FrostGuardian", I, lx, lz) end, avoid, 4)
ring("FrostGuardian", I, -105, 25, 38, 2)
for _, off in ipairs({ { 0, 0 }, { -110, -60 }, { 110, -60 }, { -110, 90 }, { 110, 90 }, { 0, -120 } }) do
local c = ISL.Frost.c
local s = P(F, V(150, 1, 150), CF(c.X + off[1], 75, c.Z + off[2]), Color3.new(1, 1, 1), M.Neon, deco({ Transparency = 1 }))
Emitter(s, { Rate = 220, Lifetime = NumberRange.new(9, 11), Speed = NumberRange.new(7, 10), Size = NumberSequence.new(0.35, 0.25), Color = ColorSequence.new(Color3.new(1, 1, 1)),
Transparency = NumberSequence.new(0.1, 0.4), EmissionDirection = Enum.NormalId.Bottom, SpreadAngle = Vector2.new(20, 20), Acceleration = V(2, 0, 1) })
end
end
local function buildSea()
local F = ENV.sea
local function inIsland(x, z, pad)
for _, isl in pairs(ISL) do
if (x - isl.c.X) ^ 2 + (z - isl.c.Z) ^ 2 < (isl.R * pad) ^ 2 then return true end
end
return false
end
local cc = { Color3.fromRGB(255, 110, 140), Color3.fromRGB(255, 170, 70), Color3.fromRGB(190, 90, 230), Color3.fromRGB(90, 220, 200) }
local function coral(pos)
local col = cc[ri(1, #cc)]
local m = Model(F, "Coral")
for i = 1, ri(3, 5) do
local h = rr(2, 6)
local p = pos + V(rr(-2.5, 2.5), 0, rr(-2.5, 2.5))
if ri(1, 2) == 1 then
Cyl(m, CF(p + V(0, h / 2, 0)) * ANG(rr(-0.3, 0.3), 0, rr(-0.3, 0.3)), h, rr(0.7, 1.4), col, M.Slate, deco())
else
Ball(m, CF(p + V(0, h / 3, 0)), rr(2, 4), col:Lerp(Color3.new(1, 1, 1), 0.15), M.Slate, deco())
end
end
end
local function kelp(pos)
local m = Model(F, "Kelp")
local h = rr(8, 17)
for i = 0, 3 do
Cyl(m, CF(pos + V(math.sin(i) * 0.5, h / 8 + i * h / 4, math.cos(i) * 0.5)), h / 4 + 0.3, 0.5, Color3.fromRGB(40, 130 + i * 10, 70), M.Grass, deco())
end
end
local placed, tries = 0, 0
while placed < 130 and tries < 1500 do
tries += 1
local x, z = rr(-1150, 1150), rr(-1150, 350)
if not inIsland(x, z, 1.5) then
placed += 1
local y = groundY(x, z, -22)
if placed % 2 == 0 then coral(V(x, y, z)) else kelp(V(x, y, z)) end
end
end
for _, nm in ipairs({ "Haven", "Ember", "Moonveil", "Frost" }) do
local isl = ISL[nm]
for i = 1, 26 do
local a, r = rr(0, PI * 2), isl.R * rr(1.04, 1.22)
local x, z = isl.c.X + math.cos(a) * r, isl.c.Z + math.sin(a) * r
local y = groundY(x, z, -20)
if y < -2 and y > -22 then if i % 3 == 0 then kelp(V(x, y, z)) else coral(V(x, y, z)) end end
end
end
local wp = V(-400, groundY(-400, 150, -22) + 2, 150)
W.ship(F, CF(wp) * ANG(0.12, 0.7, 0.35), { name = "Wreck", len = 40, beam = 12, masts = 2, mastH = 11, hull = Color3.fromRGB(70, 55, 45), sailColor = Color3.fromRGB(110, 120, 100), cannons = 2 })
local gl = Ball(F, CF(wp + V(0, 4, 0)), 2, Color3.fromRGB(255, 220, 120), M.Neon, deco())
Light(gl, Color3.fromRGB(255, 220, 120), 30, 1.5)
for _, p in ipairs({ { -400, -400 }, { 420, -420 }, { -420, 220 }, { 420, 220 }, { -240, -320 }, { 250, -320 }, { 1000, -320 }, { -1000, -320 }, { 130, -450 }, { -170, -430 }, { 650, 190 }, { -650, 190 } }) do
local y = groundY(p[1], p[2], -22)
local h = rr(34, 46)
local rad = rr(10, 15)
Cyl(F, CF(V(p[1], y + h / 2, p[2])), h, rad, Color3.fromRGB(95, 92, 98), M.Slate)
Cyl(F, CF(V(p[1] + 1, y + h + 2, p[2])), 6, rad * 0.6, Color3.fromRGB(110, 108, 112), M.Slate)
Cyl(F, CF(V(p[1] - 2, y + h * 0.5, p[2] + 3)), h * 0.7, rad * 0.8, Color3.fromRGB(80, 78, 84), M.Slate)
end
end
local function buildSpawns()
local sp = Instance.new("SpawnLocation")
sp.Name = "Spawn_Haven"
sp.Size = V(10, 1, 10)
sp.Anchored = true
sp.CFrame = CF(A("Haven", 0, 32, 0.5)) * ANG(0, PI, 0)
sp.Neutral = true
sp.Duration = 0
sp.Transparency = 1
sp.CanCollide = false
sp.Parent = ENV.spawns
end
print("[Mythic Seas] Building world - this takes a minute...")
cleanup()
setupEnvironment()
buildOcean()
task.wait()
for _, n in ipairs({ "Haven", "Ember", "Moonveil", "Frost" }) do
buildIsland(n)
print("[Mythic Seas] terrain: " .. n)
task.wait()
end
task.wait(1)
for _, step in ipairs({ { "Haven", buildHaven }, { "Emberreach", buildEmber }, { "Moonveil", buildMoon }, { "Frostmere", buildFrost }, { "Sea", buildSea }, { "Spawns", buildSpawns } }) do
local ok, err = pcall(step[2])
if not ok then warn("[Mythic Seas] step '" .. step[1] .. "' failed: " .. tostring(err)) end
print("[Mythic Seas] built " .. step[1])
task.wait()
end
print("[Mythic Seas] DONE. Save the place (File > Save), then press Play.")
end
