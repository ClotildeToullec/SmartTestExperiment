Extension { #name : #EpMethodModification }

{ #category : #'*SmartTestExperiment' }
EpMethodModification >> isIntroducingAHalt [
	^ (Object allSelectorsInProtocol: #halting)
		anySatisfy:
			[ :selector | self newSourceCode includesSubstring: selector caseSensitive: false ]
]
