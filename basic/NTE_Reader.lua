--[[
	
	NTE Corporation AXESYS READER CONTROLLER
	NTE Corporation: https://www.roblox.com/My/Groups.aspx?gid=1213856
	
	https://nte.cloud 
	
	CREATOR: OverloadDetected (6623575)
	OverloadDetected: https://www.roblox.com/users/6623575/profile
	
	Last Updated: 30/12/2018
	
	
	Axesys Controller for readers which communicates with Axesys Main Controller in ServerScriptService.
	
--]]

--script.Parent = nil 
local _M = {}

SSS = game:GetService("ServerScriptService")

_M.SCRIPT = nil
_M.MODEL = nil
_M.DoorID = nil
_M.DoorTrigger = nil
_M.DoorLocked = nil
_M.DoorTimer = 5
_M.IsSyncing = false
_M.SyncTimerStarted = false
_M.CardScan = false
_M.DoorActive = false

NTE_API = nil





function CardScan(x)
	if _M.DoorLocked and not _M.CardScan and _M.DoorActive == true then
		if _M.IsSyncing then return end
		_M.CardScan = true
		if x.Parent:FindFirstChild("CardNumber") and x.Name == "Handle" and x.Parent.ClassName == "Tool" then
			local Player = game.Players:GetPlayerFromCharacter(x.Parent.Parent)
			local UserID = tostring(Player.UserId)
			local LetMeIn = false
			_M.IndicatorChange("LEDR",0)
			_M.IndicatorChange("LEDG",0)
			_M.IndicatorChange("LEDS",0)			
			local CheckUser = NTE_API:Invoke({["READER"] = _M.ReaderID, ["REQUEST"] = "CHECKACCESS", ["USERID"] = UserID})["DATA"]
			LetMeIn = (CheckUser and true or false)



			if LetMeIn then
				_M.DoorTrigger.Value = true
				_M.AccessGranted()
				local Time = 0
				repeat 
					wait(1) 
					Time = Time + 1 
					local SyncTimed = _M.DoorTimer
				until Time > SyncTimed
				_M.AccessLock()
				_M.DoorTrigger.Value = false	
								
			else
				_M.AccessDenied()
				wait(2)
				_M.IndicatorChange("LEDR",0)
				_M.IndicatorChange("LEDG",0)
				_M.IndicatorChange("LEDS",1)		
			end
			
		end
		_M.CardScan = false
	end
	
end

function ReaderSettings()
	local NewSettings = NTE_API:Invoke({["READER"] = _M.ReaderID, ["REQUEST"] = "SETTINGS"})["DATA"]
	_M.DoorActive = (NewSettings["Active"] == "1" and true or false)
	_M.DoorLocked = (NewSettings["Locked"] == "1" and true or false)
	_M.DoorTrigger.Value = (NewSettings["Locked"] == "0" and true or false)
	_M.IndicatorChange("LEDR",(NewSettings["Active"] == "0" and 1 or 0))
	_M.IndicatorChange("LEDG",(NewSettings["Locked"] == "1" and 0 or 1))
	_M.IndicatorChange("LEDS",(NewSettings["Active"] == "1" and NewSettings["Locked"] == "1" and 1 or 0))
	_M.DoorTimer = tonumber(NewSettings["Timer"])
	wait(60)
	ReaderSettings()
end


function _M.IndicatorChange(N,S)
	for _,x in pairs(_M.MODEL:GetChildren()) do
		if x.Name == N then
			x.BrickColor = BrickColor.new(_M.Indicators[N][S])
			if S == 1 then
				x.Material = "Neon"
			else
				x.Material = "SmoothPlastic"
			end
			
		end
	end
end
function _M.StartUp(SOURCE)
	_M.SCRIPT = SOURCE
	_M.MODEL = _M.SCRIPT.Parent
	_M.DoorID = _M.MODEL.DoorID
	_M.DoorTrigger = _M.MODEL.Trigger


	if _M.Indicators == nil then
		
	_M.Indicators = {
	["LEDR"]={[0]="Really black",[1]="Really red"},
	["LEDG"]={[0]="Really black",[1]="Lime green"},
	["LEDS"]={[0]="Really black",[1]="Institutional white"},
	}
	end
	if _M.AccessGranted == nil then
	function _M.AccessGranted()
		_M.MODEL.Sound:Play()
		_M.IndicatorChange("LEDR",0)
		_M.IndicatorChange("LEDG",1)
		_M.IndicatorChange("LEDS",0)
	end
	end
	if _M.AccessDenied == nil then	
		function _M.AccessDenied()
			_M.MODEL.Sound:Play()
			_M.IndicatorChange("LEDR",1)
			_M.IndicatorChange("LEDG",0)
			_M.IndicatorChange("LEDS",0)
			wait(0.25)
			_M.MODEL.Sound:Play()
		end
	end
	if _M.AccessLock == nil then
		function _M.AccessLock()
			_M.IndicatorChange("LEDR",0)
			_M.IndicatorChange("LEDG",0)
			_M.IndicatorChange("LEDS",1)
		end
	end




	
	_M.IndicatorChange("LEDR",0)
	_M.IndicatorChange("LEDG",0)
	_M.IndicatorChange("LEDS",0)	
	
	local StartUP = true
	
	
	SSS:WaitForChild("NTE Axesys Controller")
	SSS["NTE Axesys Controller"]:WaitForChild("API")
	
	NTE_API = SSS["NTE Axesys Controller"].API


	repeat
		_M.IndicatorChange("LEDR",1)
		local WaitForPong = NTE_API:Invoke({["READER"] = _M.ReaderID, ["REQUEST"] = "PING"})
		if WaitForPong["RESPONSE"] == "PONG" then
			StartUP = false
			break
		end
		if WaitForPong["RESPONSE"] == "INVALID READER" then
			_M.IndicatorChange("LEDR",1)
			assert(false,"NTE Axesys Reader [".._M.ReaderID.."]: Invalid Reader")
		end
		
	until not StartUP
	_M.IndicatorChange("LEDR",0)	
	
	wait(0.2)
	_M.IndicatorChange("LEDR",1)
	wait(0.2)
	_M.IndicatorChange("LEDG",1)
	wait(0.2)
	_M.IndicatorChange("LEDS",1)
	wait(2.5)
	_M.IndicatorChange("LEDR",0)
	_M.IndicatorChange("LEDG",0)
	_M.IndicatorChange("LEDS",0)
	
	
	
	

	
	
	
	
	
		
	_M.MODEL.FrontCover.Touched:connect(CardScan)
	ReaderSettings()
end

return _M
