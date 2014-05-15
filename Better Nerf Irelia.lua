local IRELIAVERSION = "1.05"
local IRELIAAUTOUPDATE = true
local IreliaAuthor = "si7ziTV"
local IsLoaded = "Better Nerf Irelia"
if myHero.charName ~= "Irelia" then return end

local UPDATE_FILE_PATH = SCRIPT_PATH.."Better Nerf Irelia.lua"
local UPDATE_NAME = "Better Nerf Irelia"
local UPDATE_HOST = "raw.github.com"
local UPDATE_PATH = "/si7ziTV/BoL/master/Better%20Nerf%20Irelia.lua?chunk="..math.random(1, 1000)
local UPDATE_FILE_PATH = SCRIPT_PATH.."Better Nerf Irelia.lua"
local UPDATE_URL = "https://"..UPDATE_HOST..UPDATE_PATH

function AutoupdaterMsg(msg) print("<font color=\"#73DCFF\">["..IsLoaded.."]:</font> <font color=\"#FFDFBF\">"..msg..".</font>") end
if IRELIAAUTOUPDATE then
    local ServerData = GetWebResult(UPDATE_HOST, UPDATE_PATH)
    if ServerData then
        local ServerVersion = string.match(ServerData, "IRELIAVersion = \"%d+.%d+\"")
        ServerVersion = string.match(ServerVersion and ServerVersion or "", "%d+.%d+")
        if ServerVersion then
            ServerVersion = tonumber(ServerVersion)
            if tonumber(IRELIAVERSION) < ServerVersion then
                AutoupdaterMsg("A new version is available: ["..ServerVersion.."]")
                AutoupdaterMsg("The script is updating... please don't press [F9]!")
                DelayAction(function() DownloadFile(UPDATE_URL, UPDATE_FILE_PATH, function ()
				AutoupdaterMsg("Successfully updated! ("..IRELIAVERSION.." -> "..ServerVersion.."), Please reload (double [F9]) for the updated version!") end) end, 3)
            else
                AutoupdaterMsg("Your script is already the latest version: ["..ServerVersion.."]")
            end
        end
    else
        AutoupdaterMsg("Error downloading version info!")
    end
end

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 
local Config
local ts
local IREADY = false
local MyMinionManager = nil
local EnemyMinionManager = nil

--[[Spell data]]
local QReady, WReady, EReady, RReady = false, false, false, false
local Qrange = 650
local Wrange = 125
local Erange = 325
local Rrange = 1200
local AArange = 125
local Qdamage = {20, 50, 80, 110, 140}
local Qscaling = 1
local Qmana = {60, 65, 70, 75, 80}
local Edamage = {80, 130, 180, 230, 280}
local Emana = {50, 55, 60, 65, 70}
local Rdamage = {320, 480, 640}
local Rmana = {100, 100, 100} 
 
function OnLoad()
_load_menu()
--Script load
PrintChat("<font color=\"#FE642E\"><b>" ..">>  Better nerf Irelia</b> by si7ziTV has been loaded")

EnemyMinionManager = minionManager(MINION_ENEMY,Qrange, myHero, MINION_SORT_MAXHEALTH_DEC)
MyMinionManager = minionManager(MINION_JUNGLE, Qrange, myHero, MINION_SORT_MAXHEALTH_DEC)
 
ts = TargetSelector(TARGET_LOW_HP,650,DAMAGE_PHYSICAL) -- (mode, range, damageType)
    ts.name = "Irelia"
    --Config.Combo:addTS(ts)
 
 

--Evadeee integration
if _G.Evadeee_Loaded then
 _G.Evadeee_Enabled = true
end
end

function _load_menu()
--Menu
Config = scriptConfig("Irelia", "Irelia")
Config:addParam("Author","Developer: si7ziTV",5,"")
	
--Combo Menu	
	--Config:addSubMenu("Combo", "Combo")
			--Config.Combo:addSubMenu("Teamfight", "Teamfight")
		--Config.Combo:addParam("useQ", "Use (Q)", SCRIPT_PARAM_ONOFF, true)
		--Config.Combo:addParam("useQ", "Use (W)", SCRIPT_PARAM_ONOFF, true)
		--Config.Combo:addParam("useQ", "Use (E)", SCRIPT_PARAM_ONOFF, true)
		--Config.Combo:addParam("useQ", "Use (R)", SCRIPT_PARAM_ONKEYTOGGLE, false, 68)
		--Config.Combo:addParam("useItems", "Use Items in Combo", SCRIPT_PARAM_ONOFF, true)
		--Config.Combo:addParam("ComboKey", "Combo (32)", SCRIPT_PARAM_ONKEYDOWN, false, 32)
		--Config.Combo:addParam("SmartComboKey", "SCombo (33)", SCRIPT_PARAM_ONOFF, true)
		--Config.Combo:addParam("orbwalker", "Move to Mouse", SCRIPT_PARAM_ONOFF, true)
		--Config.Combo:permaShow("ComboKey")

--Harras Menu
	--Config:addSubMenu("Harras", "Harras")
		--Config.Harras:addParam("useQ", "Use (Q)", SCRIPT_PARAM_ONOFF, true)
		--Config.Harras:addParam("useW", "Use (W)", SCRIPT_PARAM_ONOFF, true)
		--Config.Harras:addParam("useE", "Use (E)", SCRIPT_PARAM_ONOFF, true)
		--Config.Harras:addParam("HarrasKey", "Harras (T)", SCRIPT_PARAM_ONKEYDOWN, false, 84)
		--Config.Harras:addParam("orbwalker", "Move to Mouse", SCRIPT_PARAM_ONOFF, true)
		--Config.Harras:permaShow("HarrasKey")

--Farming Menu
	Config:addSubMenu("Farming", "Fa")
		--farm freezing
		--Config.Fa:addSubMenu("Freeze", "freeze")
			--Config.Fa.freeze:addParam("freeze", "Freeze it! (C)", SCRIPT_PARAM_ONKEYDOWN, false, 67)
			--Config.Fa.freeze:addParam("orbwalker", "Move to Mouse", SCRIPT_PARAM_ONOFF, true)
			--Config.Fa.freeze:permaShow("freeze")
		--farm clearing
		Config.Fa:addSubMenu("Clear", "clear")
			Config.Fa.clear:addParam("clearQ", "Clear with (Q)", SCRIPT_PARAM_ONOFF, true)
			Config.Fa.clear:addParam("clearW", "Clear with (W)", SCRIPT_PARAM_ONOFF, false)
			--Config.Fa.clear:addParam("UseItems", "Use Items to Clear", SCRIPT_PARAM_ONOFF, true)
			Config.Fa.clear:addParam("clear", "Clear it!", SCRIPT_PARAM_ONKEYDOWN, false, 86)
			Config.Fa.clear:addParam("Qdraw", "Draw killable Minions using (Q)", SCRIPT_PARAM_ONOFF, true)
			--Config.Fa.clear:addParam("orbwalker", "Move to Mouse", SCRIPT_PARAM_ONOFF, true)
			Config.Fa.clear:permaShow("clear")
	
	--Jungle Menu
	--Config:addSubMenu("Jungle Clear", "JungCl")
		--Config.JungCl:addParam("clearQ", "Clear with Q", SCRIPT_PARAM_ONOFF, true)
		--Config.JungCl:addParam("clearW", "Clear with W", SCRIPT_PARAM_ONOFF, true)
		--Config.JungCl:addParam("clearE", "Clear with E", SCRIPT_PARAM_ONOFF, true)
		--Config.JungCl:addParam("JungleKey", "Jungle Clear (B)", SCRIPT_PARAM_ONKEYDOWN, false, 66)
		--Config.JungCl:addParam("owbwalker", "Move to Mouse", SCRIPT_PARAM_ONOFF, true)
		--Config.JungCl:permaShow("JungleKey")
	
	--Killsteal Menu
	Config:addSubMenu("killsteal", "killsteal")
		Config.killsteal:addParam("killsteal", "Use smart Killsteal", SCRIPT_PARAM_ONOFF, true)
		--Config.killsteal:addParam("useItems", "Use Items", SCRIPT_PARAM_ONOFF, true)
		--Config.killsteal:addParam("ignite", "Auto Ignite", SCRIPT_PARAM_ONOFF, true)
	
	--Misc Menu
	Config:addSubMenu("Misc", "Misc")
		Config.Misc:addParam("Evadeee", "Use Evadeee Integration", SCRIPT_PARAM_ONOFF, true)
		--ManaManagementMenu
		Config.Misc:addSubMenu("Mana Management", "mana")
			Config.Misc.mana:addParam("manafarm", "Minimum mana to farm", SCRIPT_PARAM_SLICE, 35, 0, 100, 0)
			--Config.Misc.mana:addParam("manaharras", "Minimum mana to harras", SCRIPT_PARAM_SLICE, 30, 0, 100, 0)
		--Drawing Menu
		Config.Misc:addSubMenu("Drawings", "draw")
			Config.Misc.draw:addParam("drawAA", "Draw Auto Attack", SCRIPT_PARAM_ONOFF, true)
			Config.Misc.draw:addParam("drawQ", "Draw (Q)", SCRIPT_PARAM_ONOFF, true)
			Config.Misc.draw:addParam("drawE", "Draw (E)", SCRIPT_PARAM_ONOFF, false)
			Config.Misc.draw:addParam("drawR", "Draw (R)", SCRIPT_PARAM_ONOFF, false) 
			Config.Misc.draw:addParam("drawadvanced", "Use advanced drawings", SCRIPT_PARAM_ONOFF, true)
			Config.Misc.draw:addParam("lagfree", "use lagfree circles", SCRIPT_PARAM_ONOFF, true)
 end
 
function OnTick() 

	Qready = (myHero:CanUseSpell(_Q) == READY)
	Wready = (myHero:CanUseSpell(_W) == READY)
	Eready = (myHero:CanUseSpell(_E) == READY)
	Rready = (myHero:CanUseSpell(_R) == READY)

ts:update()
MyMinionManager:update()
EnemyMinionManager:update()
 
if myHero.dead then return end

if Config.Misc.Evadeee then
			_EvadeeeIntegration()
		end

if Config.killsteal.killsteal then
				_killsteal()
end
			

if Config.Fa.clear.clear then
				_wclear() 
			end
	
end

function _EvadeeeIntegration()
	local minion = EnemyMinionManager.objects[1]
		if minion then
		if _G.Evadeee_impossibleToEvade then
				CastSpell(_Q, minion)
		end
	end
 end

function _wclear()
  EnemyMinionManager:update()
		local Minions = EnemyMinionManager.objects[1]
			if Minions and GetDistance(Minions) < 160 and Config.Fa.clear.clearW and _ManaFarm() then
				CastSpell(_W)
			end
		for i, minion in pairs(EnemyMinionManager.objects) do
			if minion ~= nil and 
			minion.valid and 
			minion.team ~= myHero.team and not 
			minion.dead and 
			minion.visible and 
			minion.health < (getDmg("Q",minion,myHero)+getDmg("AD",minion,myHero)) and
			Config.Fa.clear.clear and 
			Config.Fa.clear.clearQ and 
			_ManaFarm() then
				CastSpell(_Q, minion)
		end
	end
end 

--[Auto Killsteal]--
function _killsteal()
	local Enemies = GetEnemyHeroes()
		for i, enemy in pairs(Enemies) do
				if ValidTarget(enemy, 650) and not enemy.dead and GetDistance(enemy) < 650 then
				if (getDmg("Q",enemy,myHero)+getDmg("AD",enemy,myHero)) > enemy.health and 							Config.killsteal.killsteal then 
				CastSpell(_Q, ts.target)
			end
		end
	end
end

--[Mana Management]--
function _ManaHarras()
  if myHero.mana >= myHero.maxMana * (Config.Misc.mana.manaharras / 100) then
    return true
  else
    return false
  end
end

function _ManaFarm()
  if myHero.mana >= myHero.maxMana * (Config.Misc.mana.manafarm / 100) then
    return true
  else
    return false
  end
end

--[OnDraw]]-- 
 function OnDraw()
	if myHero.dead then return end
			_draw_ranges()
			_draw_ranges_advanced()
			_draw_minion_Qkillable()
			_draw_ranges_lagfree()
			_draw_ranges_lagfree_advanced()
			_killsteal_information()
end

function _killsteal_information()
	if Qready then
		local Enemies = GetEnemyHeroes()
		for i, enemy in pairs(Enemies) do
			if ValidTarget(enemy, 2000) and not enemy.dead and GetDistance(enemy) < 3000 then
				if (getDmg("Q",enemy,myHero)+getDmg("AD",enemy,myHero)) > enemy.health then
				DrawText3D("Press Q to kill!", enemy.x, enemy.y, enemy.z, 15, RGB(255, 150, 0), 0)
        DrawCircle3D(enemy.x, enemy.y, enemy.z, 130, 1, RGB(255, 150, 0))
        DrawCircle3D(enemy.x, enemy.y, enemy.z, 150, 1, RGB(255, 150, 0))
        DrawCircle3D(enemy.x, enemy.y, enemy.z, 170, 1, RGB(255, 150, 0))
				end
			end
		end
	end
end

function _draw_ranges()
		if (Config.Misc.draw.lagfree) then return end
				if (Config.Misc.draw.drawAA) then 																	 --AA
						DrawCircle(myHero.x, myHero.y, myHero.z, 125, 0x6E6E6E) end
				if (Config.Misc.draw.drawQ and myHero:CanUseSpell(_Q) == READY) then --Q
						DrawCircle(myHero.x, myHero.y, myHero.z, 650, 0x2FFF00) end
				if (Config.Misc.draw.drawE and myHero:CanUseSpell(_E) == READY) then --E
						DrawCircle(myHero.x, myHero.y, myHero.z, 325, 0x268000) end
				if (Config.Misc.draw.drawR and myHero:CanUseSpell(_R) == READY) then --R
						DrawCircle(myHero.x, myHero.y, myHero.z, 1000, 0x0C3300) end
end

function _draw_ranges_advanced()
		if (Config.Misc.draw.lagfree) then return end
				if (Config.Misc.draw.drawQ) and (Config.Misc.draw.drawadvanced) then --Q
						DrawCircle(myHero.x, myHero.y, myHero.z, 650, 0x081A00) end
				if (Config.Misc.draw.drawE) and (Config.Misc.draw.drawadvanced) then --E
						DrawCircle(myHero.x, myHero.y, myHero.z, 325, 0x040D00) end
				if (Config.Misc.draw.drawR) and (Config.Misc.draw.drawadvanced) then --R
						DrawCircle(myHero.x, myHero.y, myHero.z, 1000, 0x040D00) end
end

function _draw_ranges_lagfree()
		if not (Config.Misc.draw.lagfree) then return end
				if (Config.Misc.draw.drawAA) then
						DrawCircle3D(myHero.x, myHero.y, myHero.z, 115, 1,  ARGB(255, 47, 255, 0)) end
				if (Config.Misc.draw.drawQ and myHero:CanUseSpell(_Q) == READY) then
						DrawCircle3D(myHero.x, myHero.y, myHero.z, 600, 1,  ARGB(255, 47, 255, 0)) end
				if (Config.Misc.draw.drawE and myHero:CanUseSpell(_E) == READY) then
						DrawCircle3D(myHero.x, myHero.y, myHero.z, 300, 1,  ARGB(255, 47, 255, 0)) end
				if (Config.Misc.draw.drawR and myHero:CanUseSpell(_R) == READY) then
						DrawCircle3D(myHero.x, myHero.y, myHero.z, 925, 1,  ARGB(255, 47, 255, 0)) end
end

function _draw_ranges_lagfree_advanced()
		if not (Config.Misc.draw.lagfree) then return end	
				if (Config.Misc.draw.drawQ) and (Config.Misc.draw.drawadvanced) then
						DrawCircle3D(myHero.x, myHero.y, myHero.z, 600, 1,  ARGB(80, 47, 255, 0)) end
				if (Config.Misc.draw.drawE) and (Config.Misc.draw.drawadvanced) then
						DrawCircle3D(myHero.x, myHero.y, myHero.z, 300, 1,  ARGB(80, 47, 255, 0)) end
				if (Config.Misc.draw.drawR) and (Config.Misc.draw.drawadvanced) then
						DrawCircle3D(myHero.x, myHero.y, myHero.z, 925, 1,  ARGB(80, 47, 255, 0)) end
end

function _draw_minion_Qkillable()
	EnemyMinionManager:update()
			if not Config.Fa.clear.Qdraw then return end
				if myHero:CanUseSpell(_Q) == READY then
					_draw_minion_visible() 
					else _draw_minion_transparence()
	end
end

function _draw_minion_visible()
			for i, minion in pairs(EnemyMinionManager.objects) do
				if minion ~= nil and 
					minion.health < (getDmg("Q",minion,myHero)+getDmg("AD",minion,myHero)) then
						DrawCircle3D(minion.x, minion.y, minion.z, 50, 1,  ARGB(255, 255, 255, 20))
						DrawCircle3D(minion.x, minion.y, minion.z, 51, 1,  ARGB(255, 255, 255, 20))
						DrawCircle3D(minion.x, minion.y, minion.z, 52, 1,  ARGB(255, 255, 255, 20))
		end
	end
end

function _draw_minion_transparence()
			for i, minion in pairs(EnemyMinionManager.objects) do
				if minion ~= nil and 
					minion.health < (getDmg("Q",minion,myHero)+getDmg("AD",minion,myHero)) then
						DrawCircle3D(minion.x, minion.y, minion.z, 50, 1,  ARGB(50, 255, 255, 20))
						DrawCircle3D(minion.x, minion.y, minion.z, 51, 1,  ARGB(50, 255, 255, 20))
						DrawCircle3D(minion.x, minion.y, minion.z, 52, 1,  ARGB(50, 255, 255, 20))
		end
	end
end
