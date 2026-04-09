local ReplicatedStorage = game:GetService("ReplicatedStorage")

local StoreManager = require(ReplicatedStorage.Shared["ordered-store-manager"]).client

StoreManager:onUpdate("leaderboard", function(data)
	print("Leaderboard updated:", data)
end)
