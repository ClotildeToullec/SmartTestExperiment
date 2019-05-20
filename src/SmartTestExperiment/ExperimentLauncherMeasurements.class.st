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
		'measurements',
		'columnNames'
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

{ #category : #'software visualization' }
ExperimentLauncherMeasurements >> addTo: aGrapher barChart: dataPoints for: barSymbol [
	| ds |
	ds := RTData new.
	ds points: dataPoints.
	ds y: [ :dp | self valueFor: barSymbol dataPoint: dp].

	ds interaction popup
		text: [:dp | dp id asString , ' - ' , dp change , String cr , dp entity] ;
		backgroundColor: Color white ;
		alphaPopupBackground: 0.8.
	ds barShape color: (self colorFor: barSymbol).
	ds label: (self labelFor: barSymbol).

	"for the legend"
	ds dotShape rectangle color: (self colorFor: barSymbol).

	aGrapher add: ds.

]

{ #category : #'software visualization' }
ExperimentLauncherMeasurements >> addTo: aGrapher barChart: columnsCollection label: aString color: aColor [
	| ds dataPoints |
	"dataPoints is a collectin of value"
	dataPoints := measurements collect: [ :row |
		"value for a given row is the sum of several columns in that row"
		columnsCollection inject: 0 into: [ :sum :col | sum + (row at: col)] ].

	ds := RTData new.
	ds barShape color: aColor.
	ds points: dataPoints.
	ds label: aString.

	ds interaction popup text: [:r ||row|
		row := (measurements at: r).
		(row at: 1) asString , ' - ' , (row at:11) , String cr , (row at: 10)].

	aGrapher add: ds.

]

{ #category : #accessing }
ExperimentLauncherMeasurements >> cacheSize: anAmount [
	measurements last at: #cacheSize put: anAmount.
	^ anAmount
]

{ #category : #'software visualization' }
ExperimentLauncherMeasurements >> colorCacheSize [
	^ Color blue
]

{ #category : #'software visualization' }
ExperimentLauncherMeasurements >> colorFalseNegatives [
	^ Color red
]

{ #category : #'software visualization' }
ExperimentLauncherMeasurements >> colorFalsePositives [
	^ Color lightOrange
]

{ #category : #'software visualization' }
ExperimentLauncherMeasurements >> colorFor: aSymbol [
	^ {
			#trueNegatives -> Color blue .
			#falseNegatives -> Color red .
	 		#falsePositives -> Color lightOrange .
	  		#truePositives -> Color green .
		} asDictionary 
			at: aSymbol ifAbsent: [ Color gray ].
]

{ #category : #'software visualization' }
ExperimentLauncherMeasurements >> colorLinesAdded [
	^ Color green
]

{ #category : #'software visualization' }
ExperimentLauncherMeasurements >> colorLinesDeleted [
	^ Color red
]

{ #category : #'software visualization' }
ExperimentLauncherMeasurements >> colorLinesModified [
	^ Color blue
]

{ #category : #'software visualization' }
ExperimentLauncherMeasurements >> colorReducedTestTimeDynamic [
	^ Color blue
]

{ #category : #'software visualization' }
ExperimentLauncherMeasurements >> colorReducedTestTimeStatic [
	^ Color magenta
]

{ #category : #'software visualization' }
ExperimentLauncherMeasurements >> colorTestLinesAdded [
	^ Color brown
]

{ #category : #'software visualization' }
ExperimentLauncherMeasurements >> colorTestLinesDeleted [
	^ Color magenta
]

{ #category : #'software visualization' }
ExperimentLauncherMeasurements >> colorTestLinesModified [
	^ Color purple
]

{ #category : #'software visualization' }
ExperimentLauncherMeasurements >> colorTotalTestTime [
	^ Color green
]

{ #category : #'software visualization' }
ExperimentLauncherMeasurements >> colorTrueNegatives [
	^ Color blue
]

{ #category : #'software visualization' }
ExperimentLauncherMeasurements >> colorTruePositives [
	^ Color green
]

{ #category : #accessing }
ExperimentLauncherMeasurements >> columnNames [
	^ columnNames
]

{ #category : #'software visualization' }
ExperimentLauncherMeasurements >> createBarchartData: collectionOfPoints label: aLabel color: aColor [
	| ds |
	ds := RTData new.
	ds barShape color: aColor.
	ds points: collectionOfPoints.
	ds y: [ :v | v ].
	ds label: aLabel. ds dotShape circle color: aColor.
	^ ds
]

{ #category : #'software visualization' }
ExperimentLauncherMeasurements >> createBarchartData: collectionOfPoints label: aLabel color: aColor withPopUpLabel: aString [
	| ds |
	ds := self createBarchartData: collectionOfPoints label: aLabel  color: aColor.
	ds interaction popup simpleText: aString.
		^ ds
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
	aBoolean ifTrue: [
		writer nextPut: (columnNames collect: [ :colName | ExperimentLauncherMeasurements convertCamelcaseToTitle: colName ])
	].
	writer nextPutAll: measurements
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
	| total row |
	"Increment total"
	total := measurements first.
	total at: aSymbol put: (total at: aSymbol) + anAmount.

	"Increment current row"
	row := measurements last.
	row at: aSymbol put: (row at: aSymbol) + anAmount.
	^ row at: aSymbol
]

{ #category : #'initalize-release' }
ExperimentLauncherMeasurements >> initialize [

	super initialize.
	measurements := OrderedCollection new.
	columnNames := {#id . #truePositivesStatic . #falsePositivesStatic.
	#falseNegativesStatic . #trueNegativesStatic . #truePositivesDynamic.
	#falsePositivesDynamic . #falseNegativesDynamic . #trueNegativesDynamic.
	#change . #changeType . #sourceLinesAdded . #sourceLinesDeleted.
	#sourceLinesModified . #testLinesAdded . #testLinesDeleted.
	#testLinesModified . #cacheSize . #totalTestTime . #reducedTestTimeStatic.
	#reducedTestTimeDynamic}.

	"First row will store the total of every result.
	Second row will store results for the first code change"
	2 timesRepeat: [ measurements add: self createNewRow ]
]

{ #category : #public }
ExperimentLauncherMeasurements >> initializeRow: anId change: aMethodName type: aChangeType [
	measurements last
		at: #id put: anId;
		at: #change put: aMethodName;
		at: #changeType put: aChangeType
]

{ #category : #private }
ExperimentLauncherMeasurements >> labelFor: aSymbol [
	^ self
		valueFor: aSymbol
		fromDict: {
			#falseNegatives -> 'False Negatives' .
	 		#falsePositives -> 'False Positives' .
	  		#truePositives -> 'True Positives' .
			#trueNegatives -> 'True Negatives'
		 }
		ifAbsent: [ '???' ].
]

{ #category : #accessing }
ExperimentLauncherMeasurements >> lastRow [
	^ measurements last
]

{ #category : #'software visualization' }
ExperimentLauncherMeasurements >> makeDataPointsWithColumns: columns [
	"columns is a collection of { tp-column , fp-column , fn-column , tn-column }"
	^ measurements collect: [ :row |
			ExperimentDataPoint new
				id: (row at: #id) ;
				change: (row at: #changeType) ;
				entity: (row at: #change) ;
				trueNegative: (row at: columns fourth) ;
				falseNegative: (row at: columns third) ;
				falsePositive: (row at: columns second) ;
				truePositive: (row at: columns first) ;
				yourself.
	].

]

{ #category : #'software visualization' }
ExperimentLauncherMeasurements >> openBarGraph: aString withColumns: columnsCollection [
	| b |
	b := RTGrapher new.
	self addTo: b barChart: columnsCollection label: 'true negatives' color: self colorTrueNegatives" withLabel: [:r ||row| row := (measurements at: r). (row at: 1) , ' - ' , (row at:11) , String cr , (row at: 10)]".
	self addTo: b barChart: (columnsCollection first: 3) label: 'false negatives' color: self colorFalseNegatives.
	self addTo: b barChart: (columnsCollection first: 2) label: 'false positives' color: self colorFalsePositives.
	self addTo: b barChart: (columnsCollection first: 1) label: 'true positives' color: self colorTruePositives.
	b axisX
		title: 'System Evolution';
		noDecimal;
		noTick.
	b axisY
		title: '# Tests for strategy: ' , aString;
		noDecimal.
	b legend right.
	b inspect


]

{ #category : #'software visualization' }
ExperimentLauncherMeasurements >> openBarGraph: aString withData: dataPoints [
	| b |
	b := RTGrapher new.
	self addTo: b barChart: dataPoints for: #trueNegatives.
	self addTo: b barChart: dataPoints for: #falseNegatives.
	self addTo: b barChart: dataPoints for: #falsePositives.
	self addTo: b barChart: dataPoints for: #truePositives.
	b axisX
		title: 'System Evolution';
		noDecimal;
		noTick.
	b axisY
		title: '# Tests for strategy: ' , aString;
		noDecimal.
	b legend right.
	b inspect


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
	(measurements notNil and: [ measurements isSequenceable ])
		ifTrue: [ measurements
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
				<< (measurements first at: symbol);
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
	lastRow := measurements last.
	"Previous implementation did only check for the first 4 values."
	lastRow valuesDo: [ :value | empty := empty and: [ value ~~ 0 ] ].
	empty
		ifTrue: [ measurements removeLast ]
]

{ #category : #queries }
ExperimentLauncherMeasurements >> selectValuesLargerThan: aThreshold [
	"ExperimentLauncher lastRun measurements selectValuesLargerThan: 100"

	<script>
	^ measurements
		select: [ :row | 
			row values allButFirst
				anySatisfy: [ :item | item isNumber and: [ item >= aThreshold ] ] ]
]

{ #category : #public }
ExperimentLauncherMeasurements >> setReducedTestTime: aDuration forFinder: aSymbol [
	measurements
		at: #reducedTestTime , aSymbol capitalized
		put: aDuration.
	^ aDuration
]

{ #category : #public }
ExperimentLauncherMeasurements >> startNewRow [

	measurements add: self createNewRow.

]

{ #category : #accessing }
ExperimentLauncherMeasurements >> totalDynamicResults [
	^ OrderedDictionary new
		add: (measurements first associationAt: #truePositivesDynamic);
		add: (measurements first associationAt: #falsePositivesDynamic);
		add: (measurements first associationAt: #falseNegativesDynamic);
		add: (measurements first associationAt: #trueNegativesDynamic);
		yourself
]

{ #category : #accessing }
ExperimentLauncherMeasurements >> totalSourceCodeChurn [
	| totalDict |
	totalDict := OrderedDictionary new
		add: (measurements first associationAt: #sourceLinesAdded);
		add: (measurements first associationAt: #sourceLinesDeleted);
		add: (measurements first associationAt: #sourceLinesModified);
		yourself.
	totalDict add: #totalSourceCodeChurn -> totalDict values sum.
	^ totalDict
]

{ #category : #accessing }
ExperimentLauncherMeasurements >> totalStaticResults [
	^ OrderedDictionary new
		add: (measurements first associationAt: #truePositivesStatic);
		add: (measurements first associationAt: #falsePositivesStatic);
		add: (measurements first associationAt: #falseNegativesStatic);
		add: (measurements first associationAt: #trueNegativesStatic);
		yourself
]

{ #category : #accessing }
ExperimentLauncherMeasurements >> totalTestCodeChurn [
	| totalDict |
	totalDict := OrderedDictionary new
		add: (measurements first associationAt: #testLinesAdded);
		add: (measurements first associationAt: #testLinesDeleted);
		add: (measurements first associationAt: #testLinesModified);
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
	measurements last at: #totalTestTime put: anAmount.
	^ anAmount
]

{ #category : #deprecated }
ExperimentLauncherMeasurements >> valueAtColumn: aColumnName [
	^ measurements last at: aColumnName
]

{ #category : #'software visualization' }
ExperimentLauncherMeasurements >> valueFor: aSymbol dataPoint: dataPoint [
	| sumTP sumFP sumFN sumTN |
	sumTP := dataPoint truePositive.
	sumFP := sumTP + dataPoint falsePositive.
	sumFN := sumFP + dataPoint falseNegative.
	sumTN := sumFN + dataPoint trueNegative.

	^ {
			#falseNegatives -> sumFN .
	 		#falsePositives -> sumFP .
	  		#truePositives -> sumTP .
			#trueNegatives -> sumTN
		} asDictionary 
			at: aSymbol ifAbsent: [ -1 ].
]

{ #category : #'software visualization' }
ExperimentLauncherMeasurements >> valueFor: aKey fromDict: associations ifAbsent: aValue [
	^ associations asDictionary at: aKey ifAbsent: aValue
]

{ #category : #'software visualization' }
ExperimentLauncherMeasurements >> visualiseCacheSizeBarChart [
	"ExperimentLauncher lastRun measurements visualiseCacheSizeBarChart"

	| b |
	b := RTGrapher new.
	b
		add:
			(self
				createBarchartData: (measurements collect: [ :row | row at: #cacheSize ])
				label: 'cache size'
				color: self colorCacheSize).
	b axisX
		title: 'System Evolution';
		noDecimal;
		noTick.
	b axisY
		title: 'Cache Size';
		noDecimal.
	b legend right.
	b inspect
]

{ #category : #'software visualization' }
ExperimentLauncherMeasurements >> visualiseCodeChurnBarChart [
	"ExperimentLauncher lastRun measurements visualiseCodeChurnBarChart"

	| b |
	b := RTGrapher new.
	b
		add:
			(self
				createBarchartData: (measurements collect: [ :row | row at: #sourceLinesAdded ])
				label: 'lines added'
				color: self colorLinesAdded).
	b
		add:
			(self
				createBarchartData: (measurements collect: [ :row | row at: #sourceLinesDeleted ])
				label: 'lines deleted'
				color: self colorLinesDeleted).
	b
		add:
			(self
				createBarchartData: (measurements collect: [ :row | row at: #sourceLinesModified ])
				label: 'lines modified'
				color: self colorLinesModified).
	b
		add:
			(self
				createBarchartData: (measurements collect: [ :row | row at: #testLinesAdded ])
				label: 'test lines added'
				color: self colorTestLinesAdded).
	b
		add:
			(self
				createBarchartData: (measurements collect: [ :row | row at: #testLinesDeleted ])
				label: 'test lines deleted'
				color: self colorTestLinesDeleted).
	b
		add:
			(self
				createBarchartData: (measurements collect: [ :row | row at: #testLinesModified ])
				label: 'test lines modified'
				color: self colorTestLinesModified).
	b axisX
		title: 'System Evolution';
		noDecimal;
		noTick.
	b axisY
		title: 'Code Churn';
		noDecimal.
	b legend right.
	b inspect
]

{ #category : #'software visualization' }
ExperimentLauncherMeasurements >> visualiseCodeChurnLineChart [
	"ExperimentLauncher lastRun measurements visualiseCodeChurnLineChart"

	| b ds |
	b := RTGrapher new.
	ds := RTData new.
	ds
		noDot;
		connectColor: self colorLinesAdded;
		label: 'lines added';
		points: (measurements collect: [ :row | row at: #sourceLinesAdded ]).
	b add: ds.
	ds := RTData new.
	ds
		noDot;
		connectColor: self colorLinesDeleted;
		label: 'lines deleted';
		points: (measurements collect: [ :row | row at: #sourceLinesDeleted ]).
	b add: ds.
	ds := RTData new.
	ds
		noDot;
		connectColor: self colorLinesModified;
		label: 'lines modified';
		points: (measurements collect: [ :row | row at: #sourceLinesModified ]).
	b add: ds.
	ds := RTData new.
	ds
		noDot;
		connectColor: self colorTestLinesAdded;
		label: 'test lines added';
		points: (measurements collect: [ :row | row at: #testLinesAdded ]).
	b add: ds.
	ds := RTData new.
	ds
		noDot;
		connectColor: self colorTestLinesDeleted;
		label: 'test lines deleted';
		points: (measurements collect: [ :row | row at: #testLinesDeleted ]).
	b add: ds.
	ds := RTData new.
	ds
		noDot;
		connectColor: self colorTestLinesModified;
		label: 'test lines modified';
		points: (measurements collect: [ :row | row at: #testLinesModified ]).
	b add: ds.
	b axisX
		title: 'System Evolution';
		noDecimal;
		noTick.
	b axisY
		title: 'Code Churn';
		noDecimal.
	b legend right.
	b inspect
]

{ #category : #'software visualization' }
ExperimentLauncherMeasurements >> visualisePrecision [
	self
		flag:
			'Generated by Eleonore: Remove use of xxDynamic and use a Set instead and a generic method'.
	self
		openBarGraph: 'Static'
		withData:
			(self
				makeDataPointsWithColumns:
					#(#truePositivesStatic #falsePositivesStatic #falseNegativesStatic #trueNegativesStatic)).
	self
		openBarGraph: 'Dynamic'
		withData:
			(self
				makeDataPointsWithColumns:
					#(#truePositivesDynamic #falsePositivesDynamic #falseNegativesDynamic #trueNegativesDynamic))
]

{ #category : #'software visualization' }
ExperimentLauncherMeasurements >> visualiseTestExecutionTime [
	"ExperimentLauncher lastRun measurements visualiseTestExecutionTime"

	| b |
	b := RTGrapher new.
	b
		add:
			(self
				createBarchartData: (measurements collect: [ :row | row at: #totaltestTime ])
				label: 'total test time'
				color: self colorTotalTestTime).
	b
		add:
			(self
				createBarchartData: (measurements collect: [ :row | row at: #reducedTestTimeStatic ])
				label: 'reduced test time (static)'
				color: self colorReducedTestTimeStatic).
	b
		add:
			(self
				createBarchartData: (measurements collect: [ :row | row at: #reducedTestTimeDynamic ])
				label: 'reduced test time (static)'
				color: self colorReducedTestTimeDynamic).
	b axisX
		title: 'System Evolution';
		noDecimal;
		noTick.
	b axisY
		title: 'Test Execution Time';
		noDecimal.
	b legend right.
	b inspect
]
