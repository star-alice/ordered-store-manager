export type PageConfig = {
	asceding: boolean?,
	maxSize: number?,
	minValue: number?,
	maxValue: number?,
}

export type ContructorParams = {
	name: string,
	scope: string?,
	updateTime: number?,
	ascending: boolean?,
	page: PageConfig,
}

export type CachedData = {
	[number]: {
		key: string,
		value: number,
	},
}

return {}
