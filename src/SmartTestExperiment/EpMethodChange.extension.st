Extension { #name : #EpMethodChange }

{ #category : #'*SmartTestExperiment' }
EpMethodChange >> isProtocolChangePriorToDeletion [
	^ false
]

{ #category : #'*SmartTestExperiment' }
EpMethodChange >> numberOfAffectedLines [
	^ self subclassResponsibility
]
