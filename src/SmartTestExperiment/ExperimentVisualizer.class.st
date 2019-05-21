Class {
	#name : #ExperimentVisualizer,
	#superclass : #Object,
	#instVars : [
		'measurements',
		'colorDictionary'
	],
	#category : #'SmartTestExperiment-reporting'
}

{ #category : #precision }
ExperimentVisualizer >> addTo: aGrapher barChart: dataPoints for: barSymbol [
	| ds |
	ds := RTData new.
	ds points: dataPoints.
	ds y: [ :dp | self valueFor: barSymbol dataPoint: dp ].
	ds interaction popup
		text: [ :dp | dp id asString , ' - ' , dp change , String cr , dp entity ];
		backgroundColor: Color white;
		alphaPopupBackground: 0.8.
	ds barShape color: (colorDictionary at: barSymbol).
	ds label: (self symbolToString: barSymbol).

	"for the legend"
	ds dotShape rectangle color: (colorDictionary at: barSymbol).
	aGrapher add: ds
]

{ #category : #'code churn' }
ExperimentVisualizer >> createBarchartData: collectionOfPoints label: aLabel color: aColor [
	| ds |
	ds := RTData new.
	ds barShape color: aColor.
	ds points: collectionOfPoints.
	ds y: [ :v | v ].
	ds label: aLabel.
	ds dotShape circle color: aColor.
	^ ds
]

{ #category : #initialization }
ExperimentVisualizer >> initialize [
	super initialize.
	colorDictionary := {(#trueNegatives -> Color blue).
	(#falseNegatives -> Color red).
	(#falsePositives -> Color lightOrange).
	(#truePositives -> Color green).
	(#sourceLinesAdded -> Color green).
	(#sourceLinesDeleted -> Color red).
	(#sourceLinesModified -> Color blue).
	(#testLinesAdded -> Color brown).
	(#testLinesDeleted -> Color magenta).
	(#testLinesModified -> Color purple).
	(#cacheSize -> Color blue).
	(#totalTestTime -> Color green).
	(#reducedTestTimeStatic -> Color magenta).
	(#reducedTestTimeDynamic -> Color blue)} asDictionary
]

{ #category : #precision }
ExperimentVisualizer >> makeDataPointsWithColumns: columns [
	"columns is a collection of { tp-column , fp-column , fn-column , tn-column }"

	^ measurements
		collect: [ :row | 
			ExperimentDataPoint new
				id: (row at: #id);
				change: (row at: #changeType);
				entity: (row at: #change);
				trueNegative: (row at: columns fourth);
				falseNegative: (row at: columns third);
				falsePositive: (row at: columns second);
				truePositive: (row at: columns first);
				yourself ]
]

{ #category : #accessing }
ExperimentVisualizer >> measurements: anObject [
	measurements := anObject
]

{ #category : #precision }
ExperimentVisualizer >> openBarGraph: aString withData: dataPoints [
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

{ #category : #utility }
ExperimentVisualizer >> symbolToString: aSymbol [
	"Utility -- Should not be here -- Twin method in logger:
	 #aSymbolToBeTransformed --> 'A Symbol To Be Transformed' "

	| stream |
	stream := WriteStream with: ''.
	stream << aSymbol asString first asUppercase.
	aSymbol asString allButFirst
		do: [ :char | 
			char isUppercase
				ifTrue: [ stream space ].
			stream << char ].
	^ stream contents
]

{ #category : #accessing }
ExperimentVisualizer >> valueFor: aSymbol dataPoint: dataPoint [
	| sumTP sumFP sumFN sumTN |
	sumTP := dataPoint truePositive.
	sumFP := sumTP + dataPoint falsePositive.
	sumFN := sumFP + dataPoint falseNegative.
	sumTN := sumFN + dataPoint trueNegative.
	^ {(#falseNegatives -> sumFN).
	(#falsePositives -> sumFP).
	(#truePositives -> sumTP).
	(#trueNegatives -> sumTN)} asDictionary at: aSymbol ifAbsent: [ -1 ]
]

{ #category : #'cache size' }
ExperimentVisualizer >> visualiseCacheSizeBarChart [
	| b |
	b := RTGrapher new.
	b
		add:
			(self
				createBarchartData: (measurements collect: [ :row | row at: #cacheSize ])
				label: 'Cache Size'
				color: (colorDictionary at: #cacheSize)).
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

{ #category : #'code churn' }
ExperimentVisualizer >> visualiseCodeChurnBarChart [
	| b |
	b := RTGrapher new.
	#(#sourceLinesAdded #sourceLinesDeleted #sourceLinesModified #testLinesAdded #testLinesDeleted #testLinesModified)
		do: [ :symbol | 
			b
				add:
					(self
						createBarchartData: (measurements collect: [ :row | row at: symbol ])
						label: (self symbolToString: symbol)
						color: (colorDictionary at: symbol)) ].
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

{ #category : #'code churn' }
ExperimentVisualizer >> visualiseCodeChurnLineChart [
	| b ds |
	b := RTGrapher new.
	#(#sourceLinesAdded #sourceLinesDeleted #sourceLinesModified #testLinesAdded #testLinesDeleted #testLinesModified)
		do: [ :symbol | 
			ds := RTData new.
			ds
				noDot;
				connectColor: (colorDictionary at: symbol);
				label: (self symbolToString: symbol);
				points: (measurements collect: [ :row | row at: symbol ]).
			b add: ds ].
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

{ #category : #'execution time' }
ExperimentVisualizer >> visualiseTestExecutionTime [
	| b |
	b := RTGrapher new.
	#(#totalTestTime #reducedTestTimeStatic #reducedTestTimeDynamic)
		do: [ :symbol | 
			b
				add:
					(self
						createBarchartData: (measurements collect: [ :row | row at: symbol ])
						label: (self symbolToString: symbol)
						color: (colorDictionary at: symbol)) ].
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

{ #category : #precision }
ExperimentVisualizer >> visualizePrecisionForFinder: aSymbol [
	| precisions |
	precisions := #(#truePositives #falsePositives #falseNegatives #trueNegatives)
		collect: [ :keyword | keyword , aSymbol capitalized ].
	self
		openBarGraph: aSymbol asString capitalized
		withData: (self makeDataPointsWithColumns: precisions)
]
