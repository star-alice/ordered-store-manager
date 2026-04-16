local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local StoreManager = require(ReplicatedStorage.Shared["ordered-store-manager"]).server
local store = StoreManager:createStore({ name = "leaderboard", updateTime = 10 })

store:onUpdate(function(data)
	print("Leaderboard updated:", data)
end)

store:startAutoUpdate()

Players.PlayerAdded:Connect(function(player: Player)
	store:updateData(`{player.UserId}`, 10)
end)
