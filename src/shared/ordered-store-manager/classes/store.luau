local DataStoreService = game:GetService("DataStoreService")

local DataConstants = require(script.Parent.Parent.constants.data)
local StoreTypes = require(script.Parent.Parent.types["store-types"])

local Store = {}
Store.__index = Store

export type Props = {
	_cache: StoreTypes.CachedData,
	_dataUpdateCache: { [string]: number },
	_datastore: OrderedDataStore,
	_updateListeners: { (data: StoreTypes.CachedData) -> () },
	_lastUpdate: number,
	_thread: thread?,
	_retryCount: number?,
	page: StoreTypes.PageConfig,
	updateTime: number,
}

export type Self = Props & {
	new: () -> Self,
	-- Public Functions
	startAutoUpdate: (self: Self) -> (),
	stopAutoUpdate: (self: Self) -> (),
	updateData: (self: Self, key: string, value: number) -> (),
	getData: (self: Self) -> StoreTypes.CachedData,
	onUpdate: (self: Self, callback: (data: StoreTypes.CachedData) -> ()) -> (),
	forceUpdate: (self: Self) -> StoreTypes.CachedData?,
	-- Private Functions
	_notifyUpdate: (self: Self, data: StoreTypes.CachedData) -> (),
}

function Store.new(config: StoreTypes.ContructorParams): Self
	assert(
		not (config.page and config.page.maxSize and config.page.maxSize > DataConstants.STORE.MAX_PAGE_SIZE),
		`[OrderedStoreManager] maxSize for store {config.name} exceeds the maximum allowed value of {DataConstants.STORE.MAX_PAGE_SIZE}.`
	)

	local self = setmetatable({} :: Props, Store)

	self._datastore = DataStoreService:GetOrderedDataStore(config.name, config.scope)
	self._cache = {}
	self._dataUpdateCache = {}
	self._updateListeners = {}
	self._lastUpdate = 0
	self.updateTime = config.updateTime or DataConstants.STORE.DEFAULT_UPDATE_TIME
	self.page = {
		ascending = config.ascending or DataConstants.STORE.DEFAULT_ASCENDING,
		maxSize = config.page and config.page.maxSize or DataConstants.STORE.DEFAULT_MAX_PAGE_SIZE,
		minValue = config.page and config.page.minValue or nil,
		maxValue = config.page and config.page.maxValue or nil,
	}

	return self
end

------------------------------------------------------------
--------------------- Public Functions ---------------------
------------------------------------------------------------

function Store.startAutoUpdate(self: Self)
	assert(not self._thread, "[OrderedStoreManager] Auto-update is already running.")

	self._thread = task.spawn(function()
		while true do
			local data = self:forceUpdate()
			if data then
				self:_notifyUpdate(data)
			end

			task.wait(self.updateTime)
		end
	end)
end

function Store.stopAutoUpdate(self: Self)
	assert(self._thread, "[OrderedStoreManager] Auto-update is not running.")

	if self._thread then
		task.cancel(self._thread)
		self._thread = nil
	end
end

function Store.updateData(self: Self, key: string, value: number)
	assert(typeof(value) == "number", "[OrderedStoreManager] Value must be a number.")
	self._dataUpdateCache[key] = value
end

function Store.getData(self: Self): StoreTypes.CachedData
	return self._cache
end

function Store.onUpdate(self: Self, callback: (data: StoreTypes.CachedData) -> ())
	table.insert(self._updateListeners, callback)
end

function Store.forceUpdate(self: Self): StoreTypes.CachedData?
	if self._retryCount ~= nil and self._retryCount > DataConstants.STORE.MAX_FETCH_RETRIES then
		warn(`[OrderedStoreManager] Maximum fetch retries reached for store {self._datastore.Name}. Aborting fetch.`)
		self._retryCount = nil
		return nil
	end

	local config = self.page

	local success, result = pcall(function()
		-- Update the data store with cached updates before fetching new data
		for key, value in self._dataUpdateCache do
			self._datastore:UpdateAsync(key, function()
				return value
			end)
		end
		self._dataUpdateCache = {}

		-- Fetch the sorted data from the data store based on the page configuration
		local pages = self._datastore:GetSortedAsync(config.ascending, config.maxSize, config.minValue, config.maxValue)
		local data = pages:GetCurrentPage() :: StoreTypes.CachedData

		self._cache = data
		self._lastUpdate = os.time()

		return data
	end)

	-- Handle potential errors during data fetching and retry after a delay
	if not success then
		warn(
			`[OrderedStoreManager] Failed to fetch data: {result}, trying again in {DataConstants.STORE.FETCH_RETRY_TIME} seconds...`
		)
		task.wait(DataConstants.STORE.FETCH_RETRY_TIME)
		self._retryCount = (self._retryCount or 0) + 1
		return self:forceUpdate()
	end

	return result
end

-------------------------------------------------------------
--------------------- Private Functions ---------------------
-------------------------------------------------------------

function Store._notifyUpdate(self: Self, data: StoreTypes.CachedData)
	for _, listener in self._updateListeners do
		listener(data)
	end
end

return Store
