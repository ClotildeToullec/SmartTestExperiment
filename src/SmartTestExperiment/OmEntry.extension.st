Extension { #name : #OmEntry }

{ #category : #'*SmartTestExperiment' }
OmEntry >> wasTriggered [
	^ tags includesKey: #trigger
]
