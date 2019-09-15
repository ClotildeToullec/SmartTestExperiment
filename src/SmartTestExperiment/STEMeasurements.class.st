"
I collect the various measurements for the STExperimentLauncher

My instvar results is a collection of STEResult. Each result contains the results for 1 code change.

I am created by an STExperimentLauncher.
My results are used:
	- To create a .csv file. See #exportToCSV: 
	- To be visualized in Roassal views. See STEVisualizer
"
Class {
	#name : #STEMeasurements,
	#superclass : #Object,
	#instVars : [
		'analysesKeys',
		'firstColumns',
		'resultsKeys',
		'results'
	],
	#category : #'SmartTestExperiment-Reporting'
}

{ #category : #utilities }
STEMeasurements class >> convertCamelcaseToTitle: aString [
	"Replaces all uppercase character in aString with a space followed by the lowercase equivalent. If I encounter underscores replace them with a space as well"

	"Array with: (self convertCamelcaseToTitle: #truePositives)
		with: (self convertCamelcaseToTitle: #true_Positives)
		with: (self convertCamelcaseToTitle: '')
		with: (self convertCamelcaseToTitle: 'AAAA')"
	"(self convertCamelcaseToTitle: 3)"

	| str |
	self assert: aString isString description: 'Expected a string'.
	str := WriteStream on: (String new: aString size * 2).
	aString
		do: [ :char | 
			char isUppercase
				ifTrue: [ str
						nextPut: Character space;
						nextPut: char asLowercase ]
				ifFalse: [ char = $_
						ifTrue: [ str nextPut: Character space ]
						ifFalse: [ str nextPut: char ] ] ].
	^ str contents
]

{ #category : #'instance creation' }
STEMeasurements class >> new: aFindersSymbolCollection [
	^ self new
		analysesKeys: aFindersSymbolCollection;
		yourself
]

{ #category : #accessing }
STEMeasurements >> affectedLines: anInt [
	self lastResult affectedLines: anInt
]

{ #category : #accessing }
STEMeasurements >> analysesKeys: aCollectionOfSymbols [
	analysesKeys := aCollectionOfSymbols
]

{ #category : #accessing }
STEMeasurements >> at: anAnalysisKey at: aResultKey put: aValue [
	self
		assert: [ (analysesKeys includes: anAnalysisKey)
				and: [ resultsKeys includes: aResultKey ] ]
		description: 'Impossible to keep this result'.
	self lastResult at: anAnalysisKey at: aResultKey put: aValue.
	^ aValue
]

{ #category : #accessing }
STEMeasurements >> at: aKey put: aValue [
	self lastResult at: aKey put: aValue.
	^ aValue
]

{ #category : #accessing }
STEMeasurements >> columnNames [
	^ firstColumns,
			(analysesKeys
				flatCollect:
					[ :key | resultsKeys collect: [ :resultKey | key , resultKey capitalized ] ])
]

{ #category : #exportToCSV }
STEMeasurements >> exportToCSV: fileName [
	| stream fileReference |
	fileReference := fileName asFileReference.
	fileReference exists
		ifTrue: [ fileReference delete ].
	stream := fileName asFileReference writeStream.
	[ self exportToCSVStream: stream withHeader: true ]
		ensure: [ stream close ]
]

{ #category : #exportToCSV }
STEMeasurements >> exportToCSVStream: stream withHeader: aBoolean [
	| writer |
	writer := (NeoCSVWriter on: stream)
		separator: $;;
		yourself.
	aBoolean
		ifTrue: [ writer
				nextPut:
					(self columnNames
						collect:
							[ :colName | STEMeasurements convertCamelcaseToTitle: colName ]) ].
	writer
		nextPutAll: (results collect: [ :result | result flattenedValues ])
]

{ #category : #initialization }
STEMeasurements >> initialize [
	super initialize.
	firstColumns := #(id change changeType inTest affectedLines).	"totalTestTime reducedTestTimeStatic reducedTestTimeDynamic"
	resultsKeys := #(truePositives falsePositives falseNegatives trueNegatives cacheSize cacheReset).
	results := OrderedCollection new
]

{ #category : #accessing }
STEMeasurements >> lastResult [
	^ results last
]

{ #category : #public }
STEMeasurements >> newResult [
	results addLast: (STEResult new: analysesKeys).
	^ self lastResult
]

{ #category : #accessing }
STEMeasurements >> results [
	^ results
]

{ #category : #accessing }
STEMeasurements >> total: aResultKey for: anAnalysisKey [
	^ (results
		collect: [ :result | result at: anAnalysisKey at: aResultKey ]) sum
]

{ #category : #accessing }
STEMeasurements >> totalAffectedLinesInTests: inTests [
	^ (results
		select: [ :result | result inTest = inTests ]
		thenCollect: [ :result | result affectedLines ]) sum
]

{ #category : #accessing }
STEMeasurements >> totalChangesInTests: inTests [
	^ (results select: [ :result | result inTest = inTests ]) size
]

{ #category : #accessing }
STEMeasurements >> totalResultsForFinder: aSymbol [
	^ OrderedDictionary new
		addAll:
			(#(#truePositives #falsePositives #falseNegatives #trueNegatives)
				collect: [ :key | key -> (self total: key for: aSymbol) ]);
		yourself
]
