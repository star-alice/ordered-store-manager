local Players = game:GetService("Players")

local Store = require(script.Parent.store)
local StoreTypes = require(script.Parent.Parent.types["store-types"])
local DataConstants = require(script.Parent.Parent.constants.data)

local Manager = {}
Manager.__index = Manager

export type Props = {
	_remotesFolder: Folder,
	_stores: { [string]: Store.Self },
	_clientListeners: { [string]: { { RBXScriptConnection } } }?,
}

export type Self = Props & {
	new: () -> Self,
	createStore: (self: Self, config: StoreTypes.ContructorParams) -> Store.Self,
	_setup: (self: Self) -> (),
	_playerAdded: (self: Self, player: Player) -> (),
	_getRemote: (self: Self, name: string) -> RemoteEvent,
}

function Manager.new()
	local self = setmetatable({
		_stores = {},
	}, Manager)

	self._stores = {}
	self._remotesFolder = DataConstants.REMOTES_FOLDER.LOCATION:FindFirstChild("Remotes") :: Folder

	if not self._remotesFolder then
		self._remotesFolder = Instance.new("Folder")
		self._remotesFolder.Name = "Remotes"
		self._remotesFolder.Parent = DataConstants.REMOTES_FOLDER.LOCATION
	end

	self:_setup()
	return self
end

------------------------------------------------------------
--------------------- Public Functions ---------------------
------------------------------------------------------------

function Manager.createStore<K>(self: Self, config: StoreTypes.ContructorParams): Store.Self
	assert(not self._stores[config.name], `[OrderedStoreManager] Store with name {config.name} already exists.`)

	local newStore = Store.new(config) :: Store.Self
	self._stores[config.name] = newStore

	local remote = Instance.new("RemoteEvent")
	remote.Name = config.name
	remote.Parent = self._remotesFolder
	remote.OnServerEvent:Connect(function(player)
		local data = newStore:getData()
		remote:FireClient(player, data)
	end)

	newStore:onUpdate(function(data)
		remote:FireAllClients(data)
	end)

	return newStore
end

-------------------------------------------------------------
--------------------- Private Functions ---------------------
-------------------------------------------------------------

function Manager._playerAdded(self: Self, player: Player)
	for storeName, store in self._stores do
		local remote = self:_getRemote(storeName)
		if remote then
			local data = store:getData()
			remote:FireClient(player, data)
		end
	end
end

function Manager._setup(self: Self)
	Players.PlayerAdded:Connect(function(player)
		self:_playerAdded(player)
	end)

	for _, player in Players:GetPlayers() do
		self:_playerAdded(player)
	end
end

function Manager._getRemote(self: Self, name: string)
	return self._remotesFolder:FindFirstChild(name) :: RemoteEvent
end

return Manager
