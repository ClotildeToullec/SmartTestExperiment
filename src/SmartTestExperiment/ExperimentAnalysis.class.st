"
This class adds:
- static / dynamic precision and recall as columns in the CSV file.
- average of each number data as a line at the end of the CSV file

A new CSV file is generated.
Example: 

ExperimentAnalysis computeAnalysisForACSVFile: 'lanSimulation.csv'
"
Class {
	#name : #ExperimentAnalysis,
	#superclass : #Object,
	#instVars : [
		'rawValues',
		'enrichedValues',
		'columnNames'
	],
	#category : #'SmartTestExperiment-analysis'
}

{ #category : #'as yet unclassified' }
ExperimentAnalysis class >> computeAnalysisForACSVFile: aFileName [
|ea fileNameWithoutCsv |
ea := self new.
fileNameWithoutCsv := aFileName withoutPeriodSuffix.
ea input:aFileName asFileReference contents usingDelimiter:';'.
ea extendWithPrecisionAndRecall.
ea extendWithAverage.
ea exportToCSV: (fileNameWithoutCsv , 'Enriched.csv') .
]

{ #category : #compute }
ExperimentAnalysis >> computeAverage [
	| average |
	average := OrderedCollection new.
	(1 to: 25)
		do: [ :i | 
			({1 . 10 . 11} includes: i)
				ifTrue: [ average add: '' ]
				ifFalse: [ average add: ((enrichedValues collect: [ :a | (a at: i) isNumber ifFalse: [ (a at: i) asInteger ] ifTrue: [ (a at: i) ] ]) reject: [ :cell | cell = nil ])average asFloat ] ].
	^ average
]

{ #category : #compute }
ExperimentAnalysis >> computeDynamicPrecisionFor: anArray [
	^ (anArray at: 6) asInteger + (anArray at: 7) asInteger = 0
		ifFalse: [ ((anArray at: 6) asInteger / ((anArray at: 6) asInteger + (anArray at: 7) asInteger))
				asFloat ]
		ifTrue: [ '' ]
]

{ #category : #compute }
ExperimentAnalysis >> computeDynamicRecallFor: anArray [
	^ (anArray at: 6) asInteger + (anArray at: 8) asInteger = 0
		ifFalse: [ ((anArray at: 6) asInteger / ((anArray at: 6) asInteger + (anArray at: 8) asInteger))
				asFloat ]
		ifTrue: [ '' ]
]

{ #category : #compute }
ExperimentAnalysis >> computeStaticPrecisionFor: anArray [
	^ (anArray at: 2) asInteger + (anArray at: 3) asInteger = 0
		ifFalse: [ ((anArray at: 2) asInteger / ((anArray at: 2) asInteger + (anArray at: 3) asInteger))
				asFloat ]
		ifTrue: [ '' ]
]

{ #category : #compute }
ExperimentAnalysis >> computeStaticRecallFor: anArray [
	^ (anArray at: 2) asInteger  + (anArray at: 4) asInteger = 0
		ifFalse: [ ((anArray at: 2) asInteger / ((anArray at: 2) asInteger + (anArray at: 4) asInteger)) asFloat ]
		ifTrue: [ '' ]
]

{ #category : #exportToCSV }
ExperimentAnalysis >> exportToCSV: fileName [
	| stream fileReference |
	fileReference := fileName asFileReference.
	fileReference exists
		ifTrue: [ fileReference delete ].
	stream := fileName asFileReference writeStream.
	[ self exportToCSVStream: stream withHeader: true ]
		ensure: [ stream close ]
]

{ #category : #exportToCSV }
ExperimentAnalysis >> exportToCSVStream: stream withHeader: aBoolean [
	| writer |
	writer := (NeoCSVWriter on: stream)
		separator: $;;
		yourself.
	aBoolean ifTrue: [
		writer nextPut: (columnNames collect: [ :colName | ExperimentLauncherMeasurements convertCamelcaseToTitle: colName ])
	].
	writer nextPutAll: enrichedValues 
]

{ #category : #compute }
ExperimentAnalysis >> extendWithAverage [
	| values | 
	values := enrichedValues asOrderedCollection .
	enrichedValues := (values addLast:  self computeAverage ; yourself ) asArray .

]

{ #category : #compute }
ExperimentAnalysis >> extendWithPrecisionAndRecall [
	| values |
	"enrichedValues := self computeHeader."
	values := (rawValues allButFirst collect: [ :line | self extendWithPrecisionAndRecallFor: line ]).
	enrichedValues := values .

]

{ #category : #compute }
ExperimentAnalysis >> extendWithPrecisionAndRecallFor: anArray [
self flag:'Use a generic method'.
	^ (anArray
		,
			{(self computeStaticPrecisionFor: anArray).
			(self computeStaticRecallFor: anArray).
			(self computeDynamicPrecisionFor: anArray).
			(self computeDynamicRecallFor: anArray)})
]

{ #category : #initialization }
ExperimentAnalysis >> initialize [

self flag: 'make a generic method that uses the Set'.
	columnNames := {#id . #truePositivesStatic . #falsePositivesStatic . #falseNegativesStatic . #trueNegativesStatic.
	#truePositivesDynamic . #falsePositivesDynamic . #falseNegativesDynamic . #trueNegativesDynamic . #change . #changeType.
	#sourceLinesAdded . #sourceLinesDeleted . #sourceLinesModified . #testLinesAdded . #testLinesDeleted . #testLinesModified . #cacheSize . #totalTestTime.
	#reducedTestTimeStatic . #reducedTestTimeDynamic . #staticPrecision . #staticRecall . #dynamicPrecision . #dynamicRecall}.
]

{ #category : #collectData }
ExperimentAnalysis >> input: txt usingDelimiter: delimitersAsCharacter [
	rawValues := (NeoCSVReader on: txt readStream)
		separator: $;;
		skipHeader;
		upToEnd
]
