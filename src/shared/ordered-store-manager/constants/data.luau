return {
	STORE = {
		MAX_PAGE_SIZE = 100, -- Maximum number of entries to fetch from the data store page
		DEFAULT_UPDATE_TIME = 60 * 5, -- 5 Minutes per fetch update
		DEFAULT_MAX_PAGE_SIZE = 10, -- 10 Registers fetched from the store
		DEFAULT_ASCENDING = true, -- Fetch data in ascending order by default
		FETCH_RETRY_TIME = 20, -- Time to wait before retrying a failed fetch
		MAX_FETCH_RETRIES = 5, -- Maximum number of fetch retries before giving up
	},
	REMOTES_FOLDER = {
		NAME = "remotes",
		LOCATION = script.Parent.Parent,
	},
}
