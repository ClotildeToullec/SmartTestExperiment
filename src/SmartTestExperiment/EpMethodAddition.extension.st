Extension { #name : #EpMethodAddition }

{ #category : #'*SmartTestExperiment' }
EpMethodAddition >> isIntroducingAHalt [
	^ (Object allSelectorsInProtocol: #halting)
		anySatisfy:
			[ :selector | self newSourceCode includesSubstring: selector caseSensitive: false ]
]

{ #category : #'*SmartTestExperiment' }
EpMethodAddition >> newSourceCode [
	^ self sourceCode
]
