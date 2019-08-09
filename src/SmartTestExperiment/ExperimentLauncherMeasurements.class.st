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
ExperimentLauncherMeasurements class >> new: aFindersSymbolCollection [
	| names |
	names := OrderedCollection with: #id.
	aFindersSymbolCollection
		do: [ :symbol | 
			names
				addAll:
					{(#truePositives , symbol capitalized).
					(#falsePositives , symbol capitalized).
					(#falseNegatives , symbol capitalized).
					(#trueNegatives , symbol capitalized).
					(#cacheReset , symbol capitalized)} ].
	names
		addAll:
			{#change . #changeType . #sourceLinesAdded . #sourceLinesDeleted.
			#sourceLinesModified . #testLinesAdded . #testLinesDeleted.
			#testLinesModified . #cacheSize . #totalTestTime . #reducedTestTimeStatic.
			#reducedTestTimeDynamic}.
	^ self new
		columnNames: names asArray;
		rows: OrderedCollection new;
		startNewRow;
		yourself
]

{ #category : #incrementation }
ExperimentLauncherMeasurements >> addCodeChange: anAmount inTest: aBoolean atKey: aSymbol [
	self
		incrementResult:
			(aBoolean
				ifTrue: [ #test ]
				ifFalse: [ #source ]) , aSymbol capitalized
		withAmount: anAmount
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

{ #category : #accessing }
ExperimentLauncherMeasurements >> columnNames: anObject [
	columnNames := anObject
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

{ #category : #'execution time' }
ExperimentLauncherMeasurements >> reducedTestTimeDynamic [
	^ rows last at: #reducedTestTimeDynamic
]

{ #category : #'execution time' }
ExperimentLauncherMeasurements >> reducedTestTimeStatic [
	^ rows last at: #reducedTestTimeStatic
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

{ #category : #accessing }
ExperimentLauncherMeasurements >> rows: anObject [
	rows := anObject
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

{ #category : #'execution time' }
ExperimentLauncherMeasurements >> setTestTime: aDuration forFinder: aSymbol [
	rows last at: #reducedTestTime , aSymbol capitalized put: aDuration.
	^ aDuration
]

{ #category : #public }
ExperimentLauncherMeasurements >> startNewRow [
	rows
		add:
			(OrderedDictionary
				newFromKeys: columnNames
				andValues: (Array new: columnNames size withAll: 0))
]

{ #category : #accessing }
ExperimentLauncherMeasurements >> total: aSymbol [
	^ (rows collect: [ :row | row at: aSymbol ]) sum
]

{ #category : #accessing }
ExperimentLauncherMeasurements >> totalCodeChurn: aSymbol [
	| totalDict |
	totalDict := OrderedDictionary new
		addAll:
			(#(#linesAdded #linesDeleted #linesModified)
				collect: [ :keyword | keyword -> (self total: aSymbol , keyword capitalized) ]);
		yourself.
	totalDict add: #totalCodeChurn -> totalDict values sum.
	^ totalDict
]

{ #category : #accessing }
ExperimentLauncherMeasurements >> totalResultsForFinder: aSymbol [
	^ OrderedDictionary new
		addAll:
			(#(#truePositives #falsePositives #falseNegatives #trueNegatives)
				collect: [ :key | key -> (self total: key , aSymbol capitalized) ]);
		yourself
]

{ #category : #'execution time' }
ExperimentLauncherMeasurements >> totalTestTime [
	^ rows last at: #totalTestTime
]

{ #category : #'execution time' }
ExperimentLauncherMeasurements >> totalTestTime: anAmount [
	rows last at: #totalTestTime put: anAmount.
	^ anAmount
]
