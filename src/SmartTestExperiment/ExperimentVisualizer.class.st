Class {
	#name : #ExperimentVisualizer,
	#superclass : #Object,
	#instVars : [
		'measurements',
		'colorDictionary',
		'measurementsKeys',
		'analysesSymbols'
	],
	#classInstVars : [
		'aCollectionOfMeasurementsRows'
	],
	#category : #'SmartTestExperiment-reporting'
}

{ #category : #'bar graph' }
ExperimentVisualizer >> addTo: aGrapher barChart: dataPoints for: barSymbol [
	| ds |
	ds := RTData new.
	ds points: dataPoints.
	ds y: [ :dp | self valueFor: barSymbol dataPoint: dp ].
	ds interaction popup
		text: [ :dp | dp popupText ];
		backgroundColor: Color white;
		alphaPopupBackground: 0.8.
	ds barShape color: (colorDictionary at: barSymbol).
	ds label: (self symbolToString: barSymbol).

	"for the legend"
	ds dotShape rectangle color: (colorDictionary at: barSymbol).
	aGrapher add: ds
]

{ #category : #'bar graph' }
ExperimentVisualizer >> addTo: aGrapher decorator: dataPoints [
	| x |
	x := 0.
	dataPoints
		do: [ :point | 
			| hasReset |
			x := x + 1.
			hasReset := point cacheReset.
			hasReset = 1
				ifTrue:
					[ aGrapher addDecorator: (ELGraphArrow new value: x) ] ]
]

{ #category : #accessing }
ExperimentVisualizer >> analysesSymbols: anObject [
	analysesSymbols := anObject
]

{ #category : #private }
ExperimentVisualizer >> averagePrecision [
	^ self averagePrecisionOfAnalyses: analysesSymbols
]

{ #category : #private }
ExperimentVisualizer >> averagePrecisionOfAnalyses: aSymbolsCollection [
	^ OrderedDictionary
		newFromKeys: self precisionSymbols
		andValues: (self resultsOfAnalyses: aSymbolsCollection) values average
]

{ #category : #'bar graph comparison' }
ExperimentVisualizer >> compareAllPrecisionsOfAnalyses: analysesSymbolsCollection definition: aString [
	self
		comparePrecisions: self precisionSymbols
		ofAnalyses: analysesSymbolsCollection
		definition: aString
]

{ #category : #'bar graph comparison' }
ExperimentVisualizer >> comparePrecision: precisionSymbol ofAnalyses: analysesSymbolsCollection [
	| data graph |
	data := self
		dataForPrecision: precisionSymbol
		ofAnalyses: analysesSymbolsCollection.
	graph := RTGrapher new.
	graph add: data.
	graph legend.
	graph axisX
		noDecimal;
		noTick.
	graph build.
	graph view
		@ RTZoomableView;
		openTitled: (self symbolToString: precisionSymbol)
]

{ #category : #'bar graph comparison' }
ExperimentVisualizer >> comparePrecisions: aPrecisionSymbolsCollection ofAnalyses: anAnalysesSymbolsCollection definition: aString [
	| data graph |
	data := self
		dataForComparison: aPrecisionSymbolsCollection
		between: anAnalysesSymbolsCollection.
	graph := RTGrapher new.
	graph add: data.
	self legendIn: graph for: anAnalysesSymbolsCollection.
	graph build.
	graph view
		@ RTZoomableView;
		openTitled: aString
]

{ #category : #accessing }
ExperimentVisualizer >> comparisonColors [
	^ RTColorPalette qualitative colors: 12 scheme: 'Paired'
]

{ #category : #'code churn' }
ExperimentVisualizer >> createBarChart: symbol [
	^ self
		createBarchartData: (measurements collect: [ :row | row at: symbol ])
		label: (self symbolToString: symbol)
		color: (colorDictionary at: symbol)
]

{ #category : #private }
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

{ #category : #'code churn' }
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

{ #category : #'pie chart' }
ExperimentVisualizer >> createPieChart: objects [
	| pie legend |
	pie := RTPieBuilder new.
	pie interaction popup.
	pie shape
		color:
			(RTNExplicitIdentityNormalizer new colors: self precisionColors values).
	pie objects: objects keys.
	pie slice: [ :symbol | objects at: symbol ].
	pie
		labeledIf: [ :key | (objects at: key) > 0 ]
		withBlock: (self pieSliceLegendBlock: objects).
	legend := RTLegendBuilder new.
	legend view: pie view.
	legend
		addText: 'Total: ' , objects values sum asString , ' tests.';
		build.
	^ pie
]

{ #category : #'pie chart' }
ExperimentVisualizer >> createPrecisionLegendIn: aView [
	| legend |
	legend := RTLegendBuilder new.
	legend view: aView.
	self precisionSymbols
		do: [ :symbol | 
			| aColor |
			aColor := self precisionColors at: symbol.
			legend addColor: aColor text: (self symbolToString: symbol) ].
	legend build.
]

{ #category : #'bar graph comparison' }
ExperimentVisualizer >> dataForComparison: precisionSymbols between: analysesSymbols [
	| data |
	data := RTHorizontalMultipleData new.
	data colors: self comparisonColors.
	data
		points:
			(precisionSymbols
				collect: [ :precisionSymbol | self getTotal: precisionSymbol ]).
	1 to: analysesSymbols size do: [ :i | data addMetric: [ :point | point second at: i ] ].
	data barChartWithBarTitle: [ :point | point first ] rotation: -30.
	^ data
]

{ #category : #'bar graph comparison' }
ExperimentVisualizer >> dataForPrecision: precisionSymbol ofAnalyses: analysesSymbolsCollection [
	| keys d data |
	keys := analysesSymbolsCollection
		collect: [ :symbol | precisionSymbol , symbol capitalized ].
	data := OrderedDictionary
		newFromKeys: keys
		andValues:
			(keys
				collect: [ :symbol | (measurements collect: [ :row | row at: symbol ]) sum ]).
	d := self
		createBarchartData: data values
		label: (self symbolToString: precisionSymbol)
		color: (self precisionColors at: precisionSymbol).
	d
		barChartWithBarTitle: [ :value | 
			self
				symbolToString: ((data keyAtValue: value) withoutPrefix: precisionSymbol) ].
	^ d
]

{ #category : #private }
ExperimentVisualizer >> getTotal: precisionSymbol [
	| keys total |
	keys := measurementsKeys
		select: [ :key | key includesSubstring: precisionSymbol ].
	total := keys
		collect: [ :key | (measurements collect: [ :row | row at: key ]) sum ].
	^ {(self symbolToString: precisionSymbol).
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

{ #category : #private }
ExperimentVisualizer >> legendIn: graph for: anAnalysesSymbolsCollection [
	| legend |
	legend := RTLegendBuilder new.
	legend view: graph view.
	anAnalysesSymbolsCollection
		doWithIndex: [ :symbol :index | 
			legend
				addColor: (self comparisonColors at: index)
				text: (self symbolToString: symbol) ].
	legend
		offset: 100;
		left;
		build
]

{ #category : #'bar graph' }
ExperimentVisualizer >> makeDataPointsWithColumns: columns [
	"columns is a collection of { tp-column , fp-column , fn-column , tn-column , cacheReset}"

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
				cacheReset: (row at: columns fifth);
				changeInTest:
					(#(#testLinesAdded #testLinesDeleted #testLinesModified)
						anySatisfy: [ :symbol | (row at: symbol) > 0 ]);
				yourself ]
]

{ #category : #accessing }
ExperimentVisualizer >> measurements: aCollectionOfMeasurementsRows [
	measurements := aCollectionOfMeasurementsRows.
	measurementsKeys := aCollectionOfMeasurementsRows first keys
]

{ #category : #'bar graph' }
ExperimentVisualizer >> openBarGraph: aString withData: dataPoints withTrueNegatives: aBoolean showCacheReset: anotherBoolean [
	| b |
	b := RTGrapher new.
	aBoolean
		ifTrue: [ self addTo: b barChart: dataPoints for: #trueNegatives ].
	self addTo: b barChart: dataPoints for: #falseNegatives.
	self addTo: b barChart: dataPoints for: #falsePositives.
	self addTo: b barChart: dataPoints for: #truePositives.
	anotherBoolean
		ifTrue: [ self addTo: b decorator: dataPoints ].
	b axisX
		title: 'System Evolution';
		noDecimal;
		noTick.
	b axisY
		title: '# Tests for strategy: ' , aString;
		noDecimal.
	b legend right.
	^ b
]

{ #category : #'bar graph' }
ExperimentVisualizer >> openTNBarGraph: aString withData: dataPoints [
	| b |
	b := RTGrapher new.
	self addTo: b barChart: dataPoints for: #trueNegatives.
	b axisX
		title: 'System Evolution';
		noDecimal;
		noTick.
	b axisY
		title: '# Tests for strategy: ' , aString;
		noDecimal.
	b legend right.
	^ b
]

{ #category : #'pie chart' }
ExperimentVisualizer >> pieChartAverageOfAllAnalyses [
	| pie objects |
	objects := self averagePrecision.
	pie := self createPieChart: objects.
	self createPrecisionLegendIn: pie view.
	pie view
		@ RTZoomableView;
		openTitled: 'Average precision for all tested Strategies'
]

{ #category : #'pie chart' }
ExperimentVisualizer >> pieChartAverageOfAnalyses: aSymbolsCollection definition: aString [
	| pie objects |
	objects := self averagePrecisionOfAnalyses: aSymbolsCollection.
	pie := self createPieChart: objects.
	self createPrecisionLegendIn: pie view.
	pie view
		@ RTZoomableView;
		openTitled: 'Average precision for ' , aString
]

{ #category : #'pie chart' }
ExperimentVisualizer >> pieChartOfAnalysis: anAnalysisSymbol [
	| pie objects |
	objects := self precisionOfAnalysis: anAnalysisSymbol.
	pie := self createPieChart: objects.
	self createPrecisionLegendIn: pie view.
	pie view
		@ RTZoomableView;
		openTitled: 'Precision for ' , (self symbolToString: anAnalysisSymbol)
]

{ #category : #'pie chart' }
ExperimentVisualizer >> pieChartsOfAnalyses: aSymbolsCollection [
	aSymbolsCollection
		do: [ :symbol | self pieChartOfAnalysis: symbol ]
]

{ #category : #'pie chart' }
ExperimentVisualizer >> pieSliceLegendBlock: objects [
	^ [ :key | 
	| nbOfTests |
	nbOfTests := objects at: key.
	String
		streamContents: [ :stream | 
			nbOfTests isInteger
				ifTrue: [ stream
						<< nbOfTests asString;
						<< ' tests';
						cr ].
			stream
				<< ((nbOfTests / objects values sum * 100) asFloat round: 2) asString;
				<< '%' ] ]
]

{ #category : #accessing }
ExperimentVisualizer >> precisionColors [
	^ OrderedDictionary
		newFromKeys: self precisionSymbols
		andValues:
			{(Color
				r: 0.1
				g: 0.8
				b: 0.2
				alpha: 1.0).
			(Color
				r: 0.0
				g: 0.6
				b: 1.0
				alpha: 1.0).
			Color lightOrange.
			Color red}
]

{ #category : #private }
ExperimentVisualizer >> precisionOfAnalysis: anAnalysisSymbol [
	^ OrderedDictionary
		newFromKeys: self precisionSymbols
		andValues: (self resultsOfAnalysis: anAnalysisSymbol) value
]

{ #category : #accessing }
ExperimentVisualizer >> precisionSymbols [
	^ #(#truePositives #trueNegatives #falsePositives #falseNegatives)
]

{ #category : #private }
ExperimentVisualizer >> resultsOfAnalyses: aSymbolsCollection [
	^ Dictionary
		newFrom:
			(aSymbolsCollection
				collect: [ :symbol | self resultsOfAnalysis: symbol ])
]

{ #category : #'bar graph' }
ExperimentVisualizer >> resultsOfAnalysis: aSymbol [
	| columnNames grapher |
	columnNames := #(#truePositives #falsePositives #falseNegatives #trueNegatives #cacheReset)
		collect: [ :keyword | keyword , aSymbol capitalized ].
	grapher := self
		openBarGraph: (self symbolToString: aSymbol)
		withData: (self makeDataPointsWithColumns: columnNames)
		withTrueNegatives: true
		showCacheReset: false.
	grapher title: (self symbolToString: aSymbol) , ' SmartTest analysis'.
	grapher build.
	grapher view
		@ RTZoomableView;
		inspect
]

{ #category : #'bar graph' }
ExperimentVisualizer >> resultsOfAnalysis: aSymbol withTrueNegatives: aBoolean showCacheReset: anotherBoolean [
	| columnNames grapher |
	columnNames := #(#truePositives #falsePositives #falseNegatives #trueNegatives #cacheReset)
		collect: [ :keyword | keyword , aSymbol capitalized ].
	grapher := self
		openBarGraph: (self symbolToString: aSymbol)
		withData: (self makeDataPointsWithColumns: columnNames)
		withTrueNegatives: aBoolean
		showCacheReset: anotherBoolean.
	grapher title: (self symbolToString: aSymbol) , ' SmartTest analysis'.
	grapher build.
	grapher view
		@ RTZoomableView;
		inspect
]

{ #category : #'stack bar plot' }
ExperimentVisualizer >> stackBarPlotOfAllAnalyses [
	self stackBarPlotOfAnalyses: analysesSymbols definition: 'Precision of all tested strategies'
]

{ #category : #'stack bar plot' }
ExperimentVisualizer >> stackBarPlotOfAnalyses: aSymbolsCollection definition: aString [
	| b |
	b := RTStackBarPlot new.
	b colorPalette colors: self precisionColors values.
	(self resultsOfAnalyses: aSymbolsCollection)
		keysAndValuesDo: [ :key :value | b add: value title: key ].
	b interaction
		popupText: [ :assoc | 
			assoc key asString , ' '
				, (self symbolToString: (self precisionSymbols at: assoc value)) ].
	b build.
	b view
		@ RTZoomableView;
		openTitled: aString
]

{ #category : #'stack bar plot' }
ExperimentVisualizer >> stackBarPlotOfAnalysis: anAnalysisSymbol [
	| b result |
	b := RTStackBarPlot new.
	b colorPalette colors: self precisionColors values.
	result := self resultsOfAnalysis: anAnalysisSymbol.
	b add: result value title: result key.
	b interaction
		popupText: [ :assoc | 
			assoc key asString , ' '
				, (self symbolToString: (self precisionSymbols at: assoc value)) ].
	b build.
	b view
		@ RTZoomableView;
		openTitled:
			'Results of ' , (self symbolToString: anAnalysisSymbol)
				, ' strategy'
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
ExperimentVisualizer >> totalAtKey: key [
	^ (measurements collect: [ :row | row at: key ]) sum
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
	b view
		@ RTZoomableView;
		openTitled: 'Cache Size'
]

{ #category : #'code churn' }
ExperimentVisualizer >> visualiseCodeChurnBarChart [
	| b |
	b := RTGrapher new.
	#(#sourceLinesAdded #sourceLinesDeleted #sourceLinesModified #testLinesAdded #testLinesDeleted #testLinesModified)
		do: [ :symbol | b add: (self createBarChart: symbol) ].
	b interaction popup.
	b axisX
		title: 'System Evolution';
		noDecimal;
		noTick.
	b axisY
		title: 'Code Churn';
		noDecimal.
	b legend right.
	b build.
	b view
		@ RTZoomableView;
		openInWindowSized: 900 @ 500 titled: 'Code Churn'
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
	b view
		@ RTZoomableView;
		openTitled: 'Code Churn'
]
