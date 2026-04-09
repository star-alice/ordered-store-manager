local StoreTypes = require(script.types["store-types"])
local Store = require(script.classes.store)

export type Store = Store.Self
export type Data = StoreTypes.CachedData

return {
	client = require(script.classes["manager-client"]),
	server = require(script.classes["manager-server"]),
}
