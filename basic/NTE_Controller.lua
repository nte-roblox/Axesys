--[[
	Object Type: ModuleScript
	NTE Corporation AXESYS CONTROLLER
	NTE Corporation: https://www.roblox.com/My/Groups.aspx?gid=1213856
	
	https://nte.cloud 
	
	CREATOR: OverloadDetected (6623575)
	OverloadDetected: https://www.roblox.com/users/6623575/profile
	
	Last Updatde: 30/12/2018
	
	
	Axesys Main Controller for communication to Readers and NTE.Cloud
	
--]]



--script.Parent = nil 
local _M = {}
_M.SCRIPT = nil
_M.MODEL = nil

HTTP = game:GetService("HttpService")
DATA = game:GetService("DataStoreService")

AxesysStore = DATA:GetDataStore("NTE_AXESYS")

AssetID = 518621890
SystemBase = "https://nte.cloud/AxesysAPI"
CurrentData = nil
Readers = {}

API = nil
APIReady = false
BackupSolution = false

function Runtime()
	
	-- PULL DATA FROM SERVER --
	APIReady = false
	BackupSolution = false
	local PlaceData = nil
	local PullData = nil
	local Status, ErrorMessage = pcall(
	function()
		PullData = HTTP:GetAsync(SystemBase.."/syncdoors/".._M.APIKey.."/".._M.PlaceID)
	end)
	
	
	if Status then
		
		print("NTE Axesys Controller: Successfully pulled fresh data from NTE Service")		
		PlaceData = HTTP:JSONDecode(PullData)
   		CurrentData = PlaceData["data"]
		APIReady = true
	else 
    	print("NTE Axesys Controller: Error while pulling data from to NTE Service / "..ErrorMessage)
    	print("NTE Axesys Controller: Will try again next sync in ".._M.SyncInterval)
    	print("NTE Axesys Controller: Using local datastore cache")
		APIReady = true
		BackupSolution = true
	end	


	--[[ AXESYS DATASTORE BACKUP SYSTEM ]]--
	if not BackupSolution then
		
		local S,M = pcall(function()
			for DOORID,DOORDATA in pairs(CurrentData) do
				AxesysStore:SetAsync(DOORID, DOORDATA)
			end
		end)
		if S then
		
			print("NTE Axesys Controller: Successfully updated local datastore with fresh data from NTE Service")		

		else 
	    	print("NTE Axesys Controller: Failed to save door data locally. / "..M)

		end		
		
	end
			
		
		
	wait(_M.SyncInterval)
	Runtime()
end


function _M.StartUp(SOURCE)
	_M.SCRIPT = SOURCE
	_M.MODEL = _M.SCRIPT.Parent
	
	API = _M.SCRIPT.API
	
	assert(_M.PlaceID,"NTE Axesys Controller: PlaceID not set")
	assert(_M.APIKey,"NTE Axesys Controller: APIKey not set")
	assert(_M.SyncInterval,"NTE Axesys Controller: SyncInterval not set")
	local Status, ErrorMessage = pcall(
	function()
		local PingTest = HTTP:GetAsync(SystemBase.."/Ping")
		if PingTest == "Pong!" then
			print("NTE Axesys Controller: Successfull HTTPSERVICE check")
		else
			assert(false, PingTest)
		end
	end)
	
	if not Status then
		if ErrorMessage == "Http requests are not enabled. Enable via game settings" then
			require(AssetID)("HTTPMESSAGE")
			return
		end
	end
	
	
	--if Status then
		-- SET UP API --
		
		function API.OnInvoke(DATA)
			if not APIReady then repeat wait() until APIReady end
			local DataTable = nil

			if type(DATA) == "table" then
				
		
				
				if (not BackupSolution and CurrentData[DATA["READER"]] ~= nil or AxesysStore:GetAsync(DATA["READER"]) ~= nil ) then
					if DATA["REQUEST"] == "PING" then
						return {["RESPONSE"] = "PONG"}
					end				
					
					if DATA["REQUEST"] == "SETTINGS" then
						if not BackupSolution then
							return {["RESPONSE"] = "SETTINGS", ["DATA"] = CurrentData[DATA["READER"]]["DoorSettings"]}
						else
							return {["RESPONSE"] = "SETTINGS", ["DATA"] = AxesysStore:GetAsync(DATA["READER"])["DoorSettings"]}
						end
					end
				
					if DATA["REQUEST"] == "CHECKACCESS" then
						
						local UserID = tostring(DATA["USERID"])
						local DoorData = nil
						if not BackupSolution then
							DoorData = CurrentData[DATA["READER"]]
						else
							DoorData = AxesysStore:GetAsync(DATA["READER"])
						end
						coroutine.resume(coroutine.create(function() HTTP:GetAsync(SystemBase.."/addlog/".._M.APIKey.."/".._M.PlaceID.."/"..DATA["READER"].."/"..DATA["USERID"])	end))
						
						for UID,USERNAME in pairs(DoorData["AuthorizedUsers"]) do
							if UID == UserID then
								
								
								return {["RESPONSE"] = "ACCESS", ["DATA"] = true}
							end
						end
						return {["RESPONSE"] = "ACCESS", ["DATA"] = false}
					end
				
				
				
				else
					return {["RESPONSE"] = "INVALID READER"}
				end
			else
				assert(false,"NTE Axesys Controller: Invalid data sent to API")
			end
		end
		
   		Runtime()

    print("NTE Axesys Controller: Error while trying to connect to NTE Service / "..ErrorMessage)
	print("NTE Axesys Controller: Trying again in 60 seconds but will use backup database")
	--wait(5)
	--_M.StartUp(_M.SCRIPT)
	--end


end

return _M
