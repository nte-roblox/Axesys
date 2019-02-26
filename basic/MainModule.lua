--[[
	
	NTE Corporation AXESYS MAINLOADER
	NTE Corporation: https://www.roblox.com/My/Groups.aspx?gid=1213856
	
	https://nte.cloud 
	
	CREATOR: OverloadDetected (6623575)
	OverloadDetected: https://www.roblox.com/users/6623575/profile
	
	Last Updated: 30/12/2018
	
	
	Main Controller to distribute correct scripts to Controller and Readers
	
	
--]]


--script.Parent = nil
--script.Archivable = false
local SSS = game.ServerScriptService
local Controller = script.NTE_Controller
local Reader = script.NTE_Reader
local HttpMessage = script.NTE_HttpMessage


--local children = script:GetChildren()
--script = Instance.new("ModuleScript")
--for _, child in pairs(children) do
--	child.Parent = script
--end


return function(t)
	if t == "READER" then
		local ReaderClone = Reader:Clone()
		ReaderClone.Parent = nil
		ReaderClone.Name = math.random(9*100,10*200)
		return ReaderClone
	end	
	if t == "AXESYS" then
		local ControllerClone = Controller:Clone()
		ControllerClone.Parent = nil
		ControllerClone.Name = math.random(9*100,10*200)
		return ControllerClone
	end	
	
	-- Legacy Private Module, When it breaks it old controllers will cease to function till upgraded
	if t == "CONTROLLER" then
		return 2694395600
	end	
	if t == "HTTPMESSAGE" then
		local HttpMessageClone = HttpMessage:Clone()
		HttpMessageClone.Parent = nil
		HttpMessageClone.Name = math.random(9*100,10*200)
		HttpMessage.Parent = SSS
		HttpMessage.Disabled = false
		return
	end
		
end

