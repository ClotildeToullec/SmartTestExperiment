Extension { #name : #BlockClosure }

{ #category : #'*SmartTestExperiment' }
BlockClosure >> timeToRunInMicroSeconds [
	"similar to #timeToRun, but uses normal division instead of integer division"
	^ Duration milliSeconds: ((Time microsecondsToRun: self)) / 1000.
]
