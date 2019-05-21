"
I collect the various measurements for the ExperimentLauncher

My instvar measurements is a collection of 'rows'. Each row but the first one contains the results for 1 code change.
The first row stores the total for every changes.

I am called by an ExperimentLauncher to build a .csv file.
"
Class {
	#name : #ExperimentLauncherMeasurements,
	#superclass : #Object,
	#instVars : [
		'columnNames',
		'rows'
	],
	#category : #'SmartTestExperiment-reporting'
}

{ #category : #utilities }
ExperimentLauncherMeasurements class >> convertCamelcaseToTitle: aString [
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
ExperimentLauncherMeasurements class >> new: nrOfElements [
	"self new: 10"
	
	^ self new initialize: nrOfElements ; yourself
]

{ #category : #accessing }
ExperimentLauncherMeasurements >> cacheSize: anAmount [
	rows last at: #cacheSize put: anAmount.
	^ anAmount
]

{ #category : #accessing }
ExperimentLauncherMeasurements >> columnNames [
	^ columnNames
]

{ #category : #private }
ExperimentLauncherMeasurements >> createNewRow [
	^ OrderedDictionary
		newFromKeys: columnNames
		andValues: (Array new: columnNames size withAll: 0)
]

{ #category : #exportToCSV }
ExperimentLauncherMeasurements >> exportToCSV: fileName [
	| stream fileReference |
	fileReference := fileName asFileReference.
	fileReference exists
		ifTrue: [ fileReference delete ].
	stream := fileName asFileReference writeStream.
	[ self exportToCSVStream: stream withHeader: true ]
		ensure: [ stream close ]
]

{ #category : #exportToCSV }
ExperimentLauncherMeasurements >> exportToCSVStream: stream withHeader: aBoolean [
	| writer |
	writer := (NeoCSVWriter on: stream)
		separator: $;;
		yourself.
	aBoolean
		ifTrue: [ writer
				nextPut:
					(columnNames
						collect:
							[ :colName | ExperimentLauncherMeasurements convertCamelcaseToTitle: colName ]) ].
	writer nextPutAll: (rows collect: [ :row | row values ])
]

{ #category : #incrementation }
ExperimentLauncherMeasurements >> incrementChange: aSymbol withAmount: anAmount inTest: aBoolean [
	self
		incrementResult:
			(aBoolean
				ifTrue: [ #test ]
				ifFalse: [ #source ]) , aSymbol capitalized
		withAmount: anAmount
]

{ #category : #incrementation }
ExperimentLauncherMeasurements >> incrementResult: aSymbol withAmount: anAmount [
	| row |
	"Increment current row"
	row := rows last.
	row at: aSymbol put: (row at: aSymbol) + anAmount.
	^ row at: aSymbol
]

{ #category : #'initalize-release' }
ExperimentLauncherMeasurements >> initialize [
	super initialize.
	columnNames := {#id . #truePositivesStatic . #falsePositivesStatic.
	#falseNegativesStatic . #trueNegativesStatic . #truePositivesDynamic.
	#falsePositivesDynamic . #falseNegativesDynamic . #trueNegativesDynamic.
	#change . #changeType . #sourceLinesAdded . #sourceLinesDeleted.
	#sourceLinesModified . #testLinesAdded . #testLinesDeleted.
	#testLinesModified . #cacheSize . #totalTestTime . #reducedTestTimeStatic.
	#reducedTestTimeDynamic}.
	rows := OrderedCollection new.
	rows add: self createNewRow
]

{ #category : #public }
ExperimentLauncherMeasurements >> initializeRow: anId change: aMethodName type: aChangeType [
	rows last
		at: #id put: anId;
		at: #change put: aMethodName;
		at: #changeType put: aChangeType
]

{ #category : #accessing }
ExperimentLauncherMeasurements >> lastRow [
	^ rows last
]

{ #category : #printing }
ExperimentLauncherMeasurements >> printOn: aStream [
	"To be improved"

	super printOn: aStream.
	aStream cr.
	aStream
		<< 'Static: ';
		cr.
	self printResult: (columnNames copyFrom: 2 to: 5) on: aStream.
	aStream
		<< 'Dynamic ';
		cr.
	self printResult: (columnNames copyFrom: 6 to: 9) on: aStream.
	aStream
		<< 'Source Code: ';
		cr.
	self printResult: (columnNames copyFrom: 12 to: 14) on: aStream.
	aStream
		<< 'Tests: ';
		cr.
	self printResult: (columnNames copyFrom: 15 to: 17) on: aStream.
	aStream
		<< 'Total Code Churn: ';
		<< self totalSourceCodeChurn;
		cr.
	aStream
		<< 'Total Test Code Churn: ';
		<< self totalTestCodeChurn;
		cr.
	(columnNames notNil and: [ columnNames isSequenceable ])
		ifTrue: [ aStream cr.
			columnNames
				do: [ :columnName | 
					columnName printOn: aStream.
					aStream tab ] ].
	(rows notNil and: [ rows isSequenceable ])
		ifTrue: [ rows
				do: [ :row | 
					aStream cr.
					row
						valuesDo: [ :cell | 
							cell printOn: aStream.
							aStream tab ] ] ]
]

{ #category : #printing }
ExperimentLauncherMeasurements >> printResult: aSymbolCollection on: aStream [
	aSymbolCollection
		do: [ :symbol | 
			symbol cutCamelCase
				do: [ :word | 
					aStream
						<< word capitalized;
						space ];
				<< ': ';
				<< (rows totalAt: symbol);
				<< ' - ' ].
	aStream cr
]

{ #category : #deprecated }
ExperimentLauncherMeasurements >> reducedTestTimeDynamic [
	^ self valueAtColumn: #reducedTestTimeDynamic
]

{ #category : #deprecated }
ExperimentLauncherMeasurements >> reducedTestTimeStatic [
	^ self valueAtColumn: #reducedTestTimeStatic
]

{ #category : #public }
ExperimentLauncherMeasurements >> removeLastRowIfEmpty [
	| lastRow empty |
	empty := true.
	lastRow := rows last.
	"Previous implementation did only check for the first 4 values."
	lastRow valuesDo: [ :value | empty := empty and: [ value ~~ 0 ] ].
	empty
		ifTrue: [ rows removeLast ]
]

{ #category : #accessing }
ExperimentLauncherMeasurements >> rows [
	^ rows
]

{ #category : #queries }
ExperimentLauncherMeasurements >> selectValuesLargerThan: aThreshold [
	"ExperimentLauncher lastRun measurements selectValuesLargerThan: 100"

	<script>
	^ rows
		select: [ :row | 
			row values allButFirst
				anySatisfy: [ :item | item isNumber and: [ item >= aThreshold ] ] ]
]

{ #category : #public }
ExperimentLauncherMeasurements >> setReducedTestTime: aDuration forFinder: aSymbol [
	rows
		at: #reducedTestTime , aSymbol capitalized
		put: aDuration.
	^ aDuration
]

{ #category : #public }
ExperimentLauncherMeasurements >> startNewRow [

	rows add: self createNewRow.

]

{ #category : #accessing }
ExperimentLauncherMeasurements >> totalAt: aSymbol [
	^ (rows collect: [ :row | row at: aSymbol ]) sum
]

{ #category : #accessing }
ExperimentLauncherMeasurements >> totalDynamicResults [
	^ OrderedDictionary new
		addAll:
			(#(#truePositivesDynamic #falsePositivesDynamic #falseNegativesDynamic #trueNegativesDynamic)
				collect: [ :keyword | keyword -> (self totalAt: keyword) ]);
		yourself
]

{ #category : #accessing }
ExperimentLauncherMeasurements >> totalSourceCodeChurn [
	| totalDict |
	totalDict := OrderedDictionary new
		addAll:
			(#(#sourceLinesAdded #sourceLinesDeleted #sourceLinesModified)
				collect: [ :keyword | keyword -> (self totalAt: keyword) ]);
		yourself.
	totalDict add: #totalSourceCodeChurn -> totalDict values sum.
	^ totalDict
]

{ #category : #accessing }
ExperimentLauncherMeasurements >> totalStaticResults [
	^ OrderedDictionary new
		addAll:
			(#(#truePositivesStatic #falsePositivesStatic #falseNegativesStatic #trueNegativesStatic)
				collect: [ :keyword | keyword -> (self totalAt: keyword) ]);
		yourself
]

{ #category : #accessing }
ExperimentLauncherMeasurements >> totalTestCodeChurn [
	| totalDict |
	totalDict := OrderedDictionary new
		addAll:
			(#(#testLinesAdded #testLinesDeleted #testLinesModified)
				collect: [ :keyword | keyword -> (self totalAt: keyword) ]);
		yourself.
	totalDict add: #totalTestCodeChurn -> totalDict values sum.
	^ totalDict
]

{ #category : #deprecated }
ExperimentLauncherMeasurements >> totalTestTime [
	^ self valueAtColumn: #totalTestTime
]

{ #category : #deprecated }
ExperimentLauncherMeasurements >> totalTestTime: anAmount [
	rows last at: #totalTestTime put: anAmount.
	^ anAmount
]

{ #category : #deprecated }
ExperimentLauncherMeasurements >> valueAtColumn: aColumnName [
	^ rows last at: aColumnName
]
