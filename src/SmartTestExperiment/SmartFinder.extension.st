Extension { #name : #SmartFinder }

{ #category : #'*SmartTestExperiment' }
SmartFinder >> hasAdaptiveCache [
	"Ths method is used by ExperimentLauncher.
	It returns false if the cache has always the same behavior (Never or Always reset)
	It returns true if the cache reset is adaptive (Every 5 change or Every commit) "

	^ cacheStrategy isAdaptive
]
