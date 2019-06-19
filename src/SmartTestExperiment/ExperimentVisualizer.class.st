Class {
	#name : #ExperimentVisualizer,
	#superclass : #Object,
	#instVars : [
		'measurements',
		'colorDictionary',
		'measurementsKeys'
	],
	#classInstVars : [
		'aCollectionOfMeasurementsRows'
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

{ #category : #'average PieChart' }
ExperimentVisualizer >> averagePrecision [
	| precision objects |
	objects := Dictionary new.
	precision := #(#truePositives #trueNegatives #falsePositives #falseNegatives).
	precision
		do: [ :symbol | 
			| results |
			results := measurementsKeys
				select: [ :name | name includesSubstring: symbol ]
				thenCollect: [ :name | (measurements collect: [ :row | row at: name ]) sum ].
			objects at: symbol put: results average ].
	^ objects
]

{ #category : #accessing }
ExperimentVisualizer >> colorsPrecisionComparison [
	^ RTColorPalette qualitative colors: 12 scheme: 'Paired'
]

{ #category : #accessing }
ExperimentVisualizer >> colorsPrecisionPie [
	^ {(Color
		r: 0.1
		g: 0.8
		b: 0.2
		alpha: 1.0).
	(Color
		r: 0.0
		g: 0.6
		b: 1.0
		alpha: 1.0).
	Color red.
	Color lightOrange}
]

{ #category : #'results analysis' }
ExperimentVisualizer >> compareAllPrecisionsOfAnalyses: analysesSymbolsCollection [
	self
		comparePrecisions: self precisionSymbols
		ofAnalyses: analysesSymbolsCollection
]

{ #category : #'results analysis' }
ExperimentVisualizer >> comparePrecision: precisionSymbol ofAnalyses: analysesSymbols [
	| data graph |
	data := self
		dataForPrecision: precisionSymbol
		ofAnalyses: analysesSymbols.
	graph := RTGrapher new.
	graph add: data.
	graph legend.
	graph axisX
		noDecimal;
		noTick.
	^ graph
]

{ #category : #'results analysis' }
ExperimentVisualizer >> comparePrecisions: aPrecisionSymbolsCollection ofAnalyses: anAnalysesSymbolsCollection [
	| data graph |
	data := self
		dataForComparison: aPrecisionSymbolsCollection
		between: anAnalysesSymbolsCollection.
	graph := RTGrapher new.
	graph add: data.
	self legendIn: graph for: anAnalysesSymbolsCollection.
	^ graph
]

{ #category : #utility }
ExperimentVisualizer >> createBarChart: symbol [
	^ self
		createBarchartData: (measurements collect: [ :row | row at: symbol ])
		label: (self symbolToString: symbol)
		color: (colorDictionary at: symbol)
]

{ #category : #utility }
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

{ #category : #utility }
ExperimentVisualizer >> createLineChart: symbol [
	| ds |
	ds := RTData new.
	ds
		noDot;
		connectColor: (colorDictionary at: symbol);
		label: (self symbolToString: symbol);
		points: (measurements collect: [ :row | row at: symbol ]).
	^ ds
]

{ #category : #'results analysis' }
ExperimentVisualizer >> dataForComparison: precisionSymbols between: analysesSymbols [
	| data |
	data := RTHorizontalMultipleData new.
	data colors: self colorsPrecisionComparison.
	data
		points:
			(precisionSymbols
				collect: [ :precisionSymbol | self getTotal: precisionSymbol ]).
	analysesSymbols size
		do: [ :i | data addMetric: [ :point | point at: i + 1 ] ].
	data
		barChartWithBarTitle: [ :point | self symbolToString: point first ]
		rotation: 0.
	^ data
]

{ #category : #'results analysis' }
ExperimentVisualizer >> dataForPrecision: precisionSymbol ofAnalyses: analysesSymbols [
	| keys d data |
	keys := analysesSymbols
		collect: [ :symbol | precisionSymbol , symbol capitalized ].
	data := OrderedDictionary
		newFromKeys: keys
		andValues:
			(keys
				collect: [ :symbol | (measurements collect: [ :row | row at: symbol ]) sum ]).
	d := self
		createBarchartData: data values
		label: (self symbolToString: precisionSymbol)
		color: self colorsPrecisionComparison second.
	d
		barChartWithBarTitle: [ :value | 
			self
				symbolToString: ((data keyAtValue: value) withoutPrefix: precisionSymbol) ].
	^ d
]

{ #category : #'results analysis' }
ExperimentVisualizer >> getTotal: precisionSymbol [
	| keys total |
	keys := measurementsKeys
		select: [ :key | key includesSubstring: precisionSymbol ].
	total := keys
		collect: [ :key | (measurements collect: [ :row | row at: key ]) sum ].
	^ {precisionSymbol.
	total}
]

{ #category : #initialization }
ExperimentVisualizer >> initialize [
	super initialize.
	colorDictionary := {(#trueNegatives -> Color blue).
	(#falseNegatives -> Color red).
	(#falsePositives -> Color lightOrange).
	(#truePositives -> Color green).
	(#sourceLinesAdded -> Color cyan).
	(#sourceLinesDeleted -> Color green).
	(#sourceLinesModified -> Color blue).
	(#testLinesAdded -> Color red).
	(#testLinesDeleted -> Color magenta).
	(#testLinesModified -> Color orange).
	(#cacheSize -> Color blue).
	(#totalTestTime -> Color green).
	(#reducedTestTimeStatic -> Color magenta).
	(#reducedTestTimeDynamic -> Color blue)} asDictionary
]

{ #category : #'results analysis' }
ExperimentVisualizer >> legendIn: graph for: anAnalysesSymbolsCollection [
	| legend |
	legend := RTLegendBuilder new.
	legend view: graph view.
	anAnalysesSymbolsCollection
		doWithIndex: [ :symbol :index | 
			legend
				addColor: (self colorsPrecisionComparison at: index)
				text: (self symbolToString: symbol) ].
	legend build
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
ExperimentVisualizer >> measurements: aCollectionOfMeasurementsRows [
	measurements := aCollectionOfMeasurementsRows.
	measurementsKeys := aCollectionOfMeasurementsRows first keys
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

{ #category : #'average PieChart' }
ExperimentVisualizer >> pieChartAveragePrecision: objects [
	| pie |
	pie := RTPieBuilder new.
	pie interaction popup.
	pie shape
		color:
			(RTNExplicitIdentityNormalizer new
				colors: self colorsPrecisionPie).
	pie objects: objects keys.
	pie slice: [ :symbol | objects at: symbol ].
	pie labeledIf: true withBlock: [ :key | (objects at: key) asString ].
	^ pie
]

{ #category : #'average PieChart' }
ExperimentVisualizer >> pieChartLegend: pie objects: objects [
	| legend |
	legend := RTLegendBuilder new.
	legend view: pie view.
	objects
		keysDo: [ :aResult | 
			| aColor |
			aColor := (pie view elementFromModel: aResult) trachelShape color.
			legend addColor: aColor text: (self symbolToString: aResult) ].
	legend build
]

{ #category : #accessing }
ExperimentVisualizer >> precisionSymbols [
	^ #(#truePositives #trueNegatives #falsePositives #falseNegatives)
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
		do:
			[ :symbol | b add: (self createBarChart: symbol) ].
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
			ds := self createLineChart: symbol.
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
		do: [ :symbol | b add: (self createBarChart: symbol) ].
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

{ #category : #'average PieChart' }
ExperimentVisualizer >> visualizeAveragePrecision [
	| pie objects |
	objects := self averagePrecision.
	pie := self pieChartAveragePrecision: objects.
	self pieChartLegend: pie objects: objects.
	^ pie view
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
