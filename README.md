# 🏆 Ordered Store Manager

A Luau module for managing **OrderedDataStores** in Roblox with automatic server-to-client synchronization. Perfect for leaderboards, rankings, and anything that needs real-time ordered data!

## 📦 What is this?

`ordered-store-manager` is a wrapper around Roblox's `OrderedDataStore` that handles everything for you:

- **Automatic updates** at configurable intervals
- **Real-time replication** to all clients via `RemoteEvent`
- **Automatic retry** on fetch failures
- **Flexible configuration** for pagination, sorting, and intervals
- **Full typing** with Luau strict types


## ⚙️ How to use
### Server

```lua
local StoreManager = require(ReplicatedStorage.Shared["ordered-store-manager"]).server

-- Creates a store named "leaderboard" that updates every 60 seconds
local store = StoreManager:createStore({
    name = "leaderboard",
    updateTime = 60,
})

-- Listen for data updates on the server
store:onUpdate(function(data)
    print("Leaderboard updated!", data)
end)

-- Start the auto-update loop
store:startAutoUpdate()
```

### Client

```lua
local StoreManager = require(ReplicatedStorage.Shared["ordered-store-manager"]).client

-- Listen for updates to the "leaderboard" store pushed by the server
StoreManager:onUpdate("leaderboard", function(data)
    print("Data received from server:", data)
end)
```

## 📘 API — Manager (Server)

`ManagerServer` is accessed via `.server` on the main module and is only available **on the server**.

### `manager:createStore(config)` → `Store`

Creates and registers a new `OrderedDataStore`, and sets up the `RemoteEvent` required for client synchronization.

| Parameter | Type | Description |
|---|---|---|
| `config.name` | `string` | Store name (required) |
| `config.scope` | `string?` | DataStore scope (optional) |
| `config.updateTime` | `number?` | Seconds between updates (default: `300`) |
| `config.ascending` | `boolean?` | Sort in ascending order? (default: `true`) |
| `config.page.maxSize` | `number?` | Maximum number of entries (default: `10`, max: `100`) |
| `config.page.minValue` | `number?` | Minimum value filter (optional) |
| `config.page.maxValue` | `number?` | Maximum value filter (optional) |

> ⚠️ Each store name must be **unique**. Attempting to create two stores with the same name will throw an error.

## 📘 API — Store

The `Store` object is returned by `createStore` and holds all methods to interact with the data.

### `store:startAutoUpdate()`

Starts a loop that automatically fetches and syncs data according to the configured `updateTime`.

```lua
store:startAutoUpdate()
```

### `store:stopAutoUpdate()`

Stops the auto-update loop.

```lua
store:stopAutoUpdate()
```

### `store:updateData(key, value)`

Queues a value update to be sent to the DataStore on the next fetch.

```lua
store:updateData("12345678", 500) -- UserId → score
```

| Parameter | Type | Description |
|---|---|---|
| `key` | `string` | Record key |
| `value` | `number` | New numeric value |

### `store:getData()` → `CachedData`

Returns the currently cached data without making a new request.

```lua
local data = store:getData()
for _, entry in data do
    print(entry.key, entry.value)
end
```

### `store:forceUpdate()` → `CachedData?`

Forces an immediate update, flushing queued writes and fetching fresh data from the DataStore. Includes **automatic retry** logic on failure.

```lua
local data = store:forceUpdate()
```

> 🔁 On error, retries after `20` seconds, up to a maximum of `5` attempts.

### `store:onUpdate(callback)`

Registers a listener that is called every time the data is updated.

```lua
store:onUpdate(function(data)
    -- data: { [number]: { key: string, value: number } }
end)
```

## 📘 API — Manager (Client)

`ManagerClient` is accessed via `.client` on the main module and is only available **on the client**.

### `manager:onUpdate(storeName, callback)` → `RBXScriptConnection?`

Listens for updates to a specific store pushed by the server and runs the callback with the new data.

```lua
local connection = StoreManager:onUpdate("leaderboard", function(data)
    updateUI(data)
end)
```

> ⏳ Waits up to `120` seconds for the store's `RemoteEvent` before giving up.

### `manager:destroyAll()`

Disconnects all registered listeners. Useful for cleanup when destroying a UI component.

```lua
StoreManager:destroyAll()
```

## ⚙️ Default Constants

| Constant | Value | Description |
|---|---|---|
| `DEFAULT_UPDATE_TIME` | `300` seconds | Default interval between updates |
| `DEFAULT_MAX_PAGE_SIZE` | `10` | Default number of records fetched |
| `MAX_PAGE_SIZE` | `100` | Maximum records per page |
| `DEFAULT_ASCENDING` | `true` | Default sort order |
| `FETCH_RETRY_TIME` | `20` seconds | Wait time before retrying a failed fetch |
| `MAX_FETCH_RETRIES` | `5` | Maximum number of retry attempts |