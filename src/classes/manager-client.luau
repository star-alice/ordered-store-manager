local DataConstants = require(script.Parent.Parent.constants.data)
local StoreTypes = require(script.Parent.Parent.types["store-types"])

local ManagerClient = {}
ManagerClient.__index = ManagerClient

export type Props = {
	_remotesFolder: Folder,
	_clientListeners: { [string]: { { RBXScriptConnection } } },
}

export type Self = Props & {
	new: () -> Self,
	onUpdate: (
		self: Self,
		storeName: string,
		callback: (data: StoreTypes.CachedData) -> ()
	) -> RBXScriptConnection?,
	destroyAll: (self: Self) -> (),
}

function ManagerClient.new(): Self
	local self = setmetatable({}, ManagerClient)

	self._clientListeners = {}
	self._remotesFolder = DataConstants.REMOTES_FOLDER.LOCATION:WaitForChild("Remotes") :: Folder

	return self
end

------------------------------------------------------------
--------------------- Public Functions ---------------------
------------------------------------------------------------

function ManagerClient.onUpdate(self: Self, storeName: string, callback: (data: StoreTypes.CachedData) -> ())
	if not self._clientListeners[storeName] then
		self._clientListeners[storeName] = {}
	end

	local remote = self._remotesFolder:WaitForChild(storeName, 120) :: RemoteEvent

	if remote then
		local connection = remote.OnClientEvent:Connect(callback)
		table.insert(self._clientListeners[storeName], connection)
		return connection
	else
		warn(`[OrderedStoreManager] Remote for store {storeName} not found, onUpdate will not work for this store.`)
	end

	return nil
end

function ManagerClient.destroyAll(self: Self)
	for storeName, connections in self._clientListeners do
		for _, connection in connections do
			connection:Disconnect()
		end
		self._clientListeners[storeName] = nil
	end
end

return ManagerClient
