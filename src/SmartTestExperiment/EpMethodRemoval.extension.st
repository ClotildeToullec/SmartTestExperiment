Extension { #name : #EpMethodRemoval }

{ #category : #'*SmartTestExperiment' }
EpMethodRemoval >> numberOfAffectedLines [
	^ self sourceCode lineCount
]
