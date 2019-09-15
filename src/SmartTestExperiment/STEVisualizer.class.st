"
I am the visualization tool for STEResults.
I use Roassal2 to display results.
"
Class {
	#name : #STEVisualizer,
	#superclass : #Object,
	#instVars : [
		'colorDictionary',
		'analysesSymbols',
		'results'
	],
	#classInstVars : [
		'aCollectionOfMeasurementsRows'
	],
	#category : #'SmartTestExperiment-Reporting'
}

{ #category : #'bar graph' }
STEVisualizer >> addBarChartTo: aGrapher for: barSymbol for: anAnalysisKey [
	| ds |
	ds := RTData new.
	ds points: results.
	ds y: [ :dp | self dataPoint: dp value: barSymbol of: anAnalysisKey ].
	ds interaction popup
		text: [ :dp | dp popupTextFor: anAnalysisKey ];
		backgroundColor: Color white;
		alphaPopupBackground: 0.8.
	ds barShape color: (colorDictionary at: barSymbol).
	ds label: (self symbolToString: barSymbol).
	ds interaction menu
		item: 'Details'
		action: [ :result | self pieChart: anAnalysisKey forResult: result model ].

	"for the legend"
	ds dotShape rectangle color: (colorDictionary at: barSymbol).
	aGrapher add: ds
]

{ #category : #'bar graph' }
STEVisualizer >> addDecoratorTo: aGrapher for: anAnalysisKey [
	results
		withIndexDo: [ :point :index | 
			(point at: anAnalysisKey at: #cacheReset)
				ifTrue: [ aGrapher addDecorator: (STEGraphArrow new value: index) ] ]
]

{ #category : #private }
STEVisualizer >> allPrecisionResultsOfAnalysis: anAnalysisSymbol [
	^ results
		collect: [ :result | result precisionResults at: anAnalysisSymbol ]
]

{ #category : #accessing }
STEVisualizer >> analysesSymbols: anObject [
	analysesSymbols := anObject
]

{ #category : #private }
STEVisualizer >> averagePrecisionOfAnalysis: anAnalysisSymbol [
	^ Dictionary
		newFromKeys: self precisionSymbols
		andValues:
			(self precisionSymbols
				collect: [ :precision | 
					((self allPrecisionResultsOfAnalysis: anAnalysisSymbol)
						collect: [ :dict | dict at: precision ]) average ])
]

{ #category : #'bar graph' }
STEVisualizer >> barGraph: anAnalysisKey showTrueNegatives: showTrueNegatives showCacheReset: showCacheReset [
	| b |
	b := RTGrapher new.
	(self getPrecisionToShow: showTrueNegatives)
		do:
			[ :precision | self addBarChartTo: b for: precision for: anAnalysisKey ].
	showCacheReset
		ifTrue: [ self addDecoratorTo: b for: anAnalysisKey ].
	b axisX
		title: 'System Evolution';
		noDecimal;
		noTick.
	b axisY
		title: 'Number of Tests';
		noDecimal.
	b legend right.
	^ b
]

{ #category : #'bar graph comparison' }
STEVisualizer >> compareAllPrecisionsOfAnalyses: analysesSymbolsCollection definition: aString [
	self
		comparePrecisions: self precisionSymbols
		ofAnalyses: analysesSymbolsCollection
		definition: aString
]

{ #category : #'bar graph comparison' }
STEVisualizer >> comparePrecision: precisionSymbol ofAnalyses: analysesSymbolsCollection [
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
STEVisualizer >> comparePrecisions: aPrecisionSymbolsCollection ofAnalyses: anAnalysesSymbolsCollection definition: aString [
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
		openInWindowSized: 700@500 titled: aString
]

{ #category : #accessing }
STEVisualizer >> comparisonColors [
	^ RTColorPalette qualitative colors: 12 scheme: 'Paired'
]

{ #category : #'code churn' }
STEVisualizer >> createBarChart: symbol [
	^ self
		createBarchartData: (results collect: [ :row | row at: symbol ])
		label: (self symbolToString: symbol)
		color: (colorDictionary at: symbol)
]

{ #category : #private }
STEVisualizer >> createBarchartData: collectionOfPoints label: aLabel color: aColor [
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
STEVisualizer >> createLineChart: symbol [
	| ds |
	ds := RTData new.
	ds
		noDot;
		connectColor: (colorDictionary at: symbol);
		label: (self symbolToString: symbol);
		points: (results collect: [ :row | row at: symbol ]).
	^ ds
]

{ #category : #'pie chart' }
STEVisualizer >> createPieChart: objects [
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
STEVisualizer >> createPrecisionLegendIn: aView [
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
STEVisualizer >> dataForComparison: precisionSymbols between: analysesKeys [
	| data |
	data := RTHorizontalMultipleData new.
	data colors: self comparisonColors.
	data
		points:
			(precisionSymbols
				collect: [ :precisionSymbol | 
					(self symbolToString: precisionSymbol)
						-> (self getTotal: precisionSymbol) ]).
	analysesKeys
		do:
			[ :analysisKey | data addMetric: [ :point | point value at: analysisKey ] ].
	data barChartWithBarTitle: [ :point | point key ] rotation: -30.
	^ data
]

{ #category : #'bar graph comparison' }
STEVisualizer >> dataForPrecision: precisionSymbol ofAnalyses: analysesSymbolsCollection [
	| keys d data |
	keys := analysesSymbolsCollection
		collect: [ :symbol | precisionSymbol , symbol capitalized ].
	data := self getTotal: precisionSymbol.
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

{ #category : #accessing }
STEVisualizer >> dataPoint: dataPoint value: aResultKey of: anAnalysisKey [
	| sumTP sumFP sumFN sumTN |
	sumTP := dataPoint at: anAnalysisKey at: #truePositives.
	sumFP := sumTP + (dataPoint at: anAnalysisKey at: #falsePositives).
	sumFN := sumFP + (dataPoint at: anAnalysisKey at: #falseNegatives).
	sumTN := sumFN + (dataPoint at: anAnalysisKey at: #trueNegatives).
	^ {(#falseNegatives -> sumFN).
	(#falsePositives -> sumFP).
	(#truePositives -> sumTP).
	(#trueNegatives -> sumTN)} asDictionary
		at: aResultKey
		ifAbsent: [ -1 ]
]

{ #category : #'bar graph' }
STEVisualizer >> getPrecisionToShow: showTrueNegatives [
	| resultsToShow |
	resultsToShow := #(falseNegatives falsePositives truePositives)
		asOrderedCollection.
	showTrueNegatives
		ifTrue: [ resultsToShow addFirst: #trueNegatives ].
	^ resultsToShow
]

{ #category : #private }
STEVisualizer >> getTotal: precisionSymbol [
	| arrayOfResults |
	arrayOfResults := results
		collect: [ :result | 
			result results values
				collect: [ :resultOfAnalysis | resultOfAnalysis at: precisionSymbol ] ].
	^ OrderedDictionary
		newFromKeys: results first results keys
		andValues: arrayOfResults sum
]

{ #category : #initialization }
STEVisualizer >> initialize [
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
	(#totalTestTime -> Color green).
	(#reducedTestTimeStatic -> Color magenta).
	(#reducedTestTimeDynamic -> Color blue)} asDictionary
]

{ #category : #private }
STEVisualizer >> legendIn: graph for: anAnalysesSymbolsCollection [
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

{ #category : #'pie chart' }
STEVisualizer >> legendOfPieChart: pie forResult: aResult [
	| legend context |
	context := aResult inTest
		ifTrue: [ 'Test ' ]
		ifFalse: [ 'Source ' ].
	legend := self createPrecisionLegendIn: pie view.
	legend := RTLegendBuilder new.
	legend view: pie view.
	legend
		addText:
			(String
				streamContents: [ :stream | 
					stream
						<< context;
						<< (self symbolToString: aResult changeType);
						cr;
						<< aResult change asString ]);
		top;
		build
]

{ #category : #'pie chart' }
STEVisualizer >> pieChart: anAnalysisKey forResult: aResult [
	| pie objects |
	objects := OrderedDictionary
		newFrom:
			{(#truePositives -> (aResult at: anAnalysisKey at: #truePositives)).
			(#trueNegatives -> (aResult at: anAnalysisKey at: #trueNegatives)).
			(#falsePositives -> (aResult at: anAnalysisKey at: #falsePositives)).
			(#falseNegatives -> (aResult at: anAnalysisKey at: #falseNegatives))}.
	pie := self createPieChart: objects.
	self legendOfPieChart: pie forResult: aResult.
	pie view
		@ RTZoomableView;
		@ RTDraggableView.
	pie title: 'Change' , aResult id asString.
	pie open.
	^ pie
]

{ #category : #'pie chart' }
STEVisualizer >> pieChartOfAnalysis: anAnalysisKey [
	| pie objects |
	objects := self totalPrecisionOfAnalysis: anAnalysisKey.
	pie := self createPieChart: objects.
	self createPrecisionLegendIn: pie view.
	pie view
		@ RTZoomableView;
		openTitled: 'Precision for ' , (self symbolToString: anAnalysisKey)
]

{ #category : #'pie chart' }
STEVisualizer >> pieChartsOfAnalyses: aSymbolsCollection [
	aSymbolsCollection
		do: [ :symbol | self pieChartOfAnalysis: symbol ]
]

{ #category : #'pie chart' }
STEVisualizer >> pieSliceLegendBlock: objects [
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
STEVisualizer >> precisionColors [
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

{ #category : #accessing }
STEVisualizer >> precisionSymbols [
	^ #(#truePositives #trueNegatives #falsePositives #falseNegatives)
]

{ #category : #accessing }
STEVisualizer >> results: aCollectionOfResults [
	results := aCollectionOfResults
]

{ #category : #private }
STEVisualizer >> resultsOfAnalyses: aSymbolsCollection [
	^ Dictionary
		newFrom:
			(aSymbolsCollection
				collect: [ :symbol | self resultsOfAnalysis: symbol ])
]

{ #category : #'bar graph' }
STEVisualizer >> resultsOfAnalysis: aSymbol [
	| grapher |
	grapher := self
		barGraph: aSymbol
		showTrueNegatives: true
		showCacheReset: false.
	grapher title: (self symbolToString: aSymbol) , ' SmartTest analysis'.
	grapher build.
	grapher view
		@ RTZoomableView;
		open
]

{ #category : #'bar graph' }
STEVisualizer >> resultsOfAnalysis: aSymbol withTrueNegatives: aBoolean showCacheReset: anotherBoolean [
	| grapher legend |
	grapher := self
		barGraph: aSymbol
		showTrueNegatives: aBoolean
		showCacheReset: anotherBoolean.
	grapher build.
	legend := RTLegendBuilder new.
	legend view: grapher view.
	legend
		addText: (self symbolToString: aSymbol);
		top;
		build.
	grapher view
		@ RTZoomableView;
		openInWindowSized: 900 @ 600
			titled: (self symbolToString: aSymbol) , ' SmartTest analysis'
]

{ #category : #utility }
STEVisualizer >> symbolToString: aSymbol [
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

{ #category : #private }
STEVisualizer >> totalPrecisionOfAnalysis: anAnalysisSymbol [
	^ Dictionary
		newFromKeys: self precisionSymbols
		andValues:
			(self precisionSymbols
				collect: [ :precision | 
					((self allPrecisionResultsOfAnalysis: anAnalysisSymbol)
						collect: [ :dict | dict at: precision ]) sum ])
]

{ #category : #'cache size' }
STEVisualizer >> visualiseCacheSizeOfAnalyses: analysesSymbolsCollection [
	| data graph |
	graph := RTGrapher new.
	analysesSymbolsCollection
		withIndexDo: [ :symbol :i | 
			data := RTData new.
			data connectColor: (self comparisonColors at: i).
			data noDot.
			data points: (results collect: [ :result | result at: symbol ]).
			data y: [ :point | point at: #cacheSize ].
			data interaction popupText: (self symbolToString: symbol).
			graph add: data ].
	self legendIn: graph for: analysesSymbolsCollection.
	graph build.
	graph view
		@ RTZoomableView;
		openInWindowSized: 700 @ 500 titled: 'Cache size'
]

{ #category : #'code churn' }
STEVisualizer >> visualiseCodeChurnBarChart [
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
STEVisualizer >> visualiseCodeChurnLineChart [
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
