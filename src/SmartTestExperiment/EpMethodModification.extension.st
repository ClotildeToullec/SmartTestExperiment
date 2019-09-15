Extension { #name : #EpMethodModification }

{ #category : #'*SmartTestExperiment' }
EpMethodModification >> isIntroducingAHalt [
	^ (Object allSelectorsInProtocol: #halting)
		anySatisfy:
			[ :selector | self newSourceCode includesSubstring: selector caseSensitive: false ]
]

{ #category : #'*SmartTestExperiment' }
EpMethodModification >> isProtocolChangePriorToDeletion [
	^ self newProtocol = 'as yet unclassified'
]

{ #category : #'*SmartTestExperiment' }
EpMethodModification >> numberOfAffectedLines [
	"This is too simple: we do not know if the result represents lines deletion, modification or addition"

	| oldLines newLines |
	oldLines := self oldSourceCode lines.
	newLines := self newSourceCode lines.
	^ oldLines size <= newLines size
		ifTrue: [ (newLines \ oldLines) size ]
		ifFalse: [ (oldLines \ newLines) size ]
]
