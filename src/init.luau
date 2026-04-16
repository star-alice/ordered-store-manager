local StoreTypes = require(script.types["store-types"])
local Store = require(script.classes.store)
local Globals = require(script.constants.globals)
local ManagerClient = require(script.classes["manager-client"])
local ManagerServer = require(script.classes["manager-server"])

export type Store = Store.Self
export type Data = StoreTypes.CachedData

return {
	client = Globals.IS_CLIENT and ManagerClient.new(),
	server = Globals.IS_SERVER and ManagerServer.new(),
} :: {
	client: ManagerClient.Self?,
	server: ManagerServer.Self?,
}
