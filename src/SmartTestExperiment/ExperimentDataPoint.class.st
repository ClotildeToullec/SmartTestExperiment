"
an intermediary representation of the results to simplify understanding the bar graphs of ExperiementLauncherMeasurement>>visualisePrecision.

Each ExperimentDataPoint represent one point in the bargraphs
"
Class {
	#name : #ExperimentDataPoint,
	#superclass : #Object,
	#instVars : [
		'id',
		'change',
		'changeInTest',
		'entity',
		'tp',
		'fp',
		'tn',
		'fn',
		'cacheReset'
	],
	#category : #'SmartTestExperiment-reporting'
}

{ #category : #accessing }
ExperimentDataPoint >> cacheReset [
	^ cacheReset
]

{ #category : #accessing }
ExperimentDataPoint >> cacheReset: anObject [
	cacheReset := anObject
]

{ #category : #accessing }
ExperimentDataPoint >> change [
	^ change
]

{ #category : #accessing }
ExperimentDataPoint >> change: anObject [
	change := anObject
]

{ #category : #accessing }
ExperimentDataPoint >> changeInTest [
	^ changeInTest
]

{ #category : #accessing }
ExperimentDataPoint >> changeInTest: anObject [
	changeInTest := anObject
]

{ #category : #accessing }
ExperimentDataPoint >> entity [
	^ entity
]

{ #category : #accessing }
ExperimentDataPoint >> entity: anObject [
	entity := anObject
]

{ #category : #accessing }
ExperimentDataPoint >> falseNegative [
		^ fn
]

{ #category : #accessing }
ExperimentDataPoint >> falseNegative: anInt [
	fn := anInt
]

{ #category : #accessing }
ExperimentDataPoint >> falsePositive [
		^ fp
]

{ #category : #accessing }
ExperimentDataPoint >> falsePositive: anInt [
	fp := anInt
]

{ #category : #'as yet unclassified' }
ExperimentDataPoint >> gtInspectorExperimentDataPointIn: composite [
	<gtInspectorPresentationOrder: 0>
	composite roassal2
		title: 'Change' , id asString , ': ' , entity asString;
		initializeView: [ self pieChart view ]
]

{ #category : #accessing }
ExperimentDataPoint >> id [
	^ id
]

{ #category : #accessing }
ExperimentDataPoint >> id: anObject [
	id := anObject
]

{ #category : #'as yet unclassified' }
ExperimentDataPoint >> pieChart [
	| visualizer pie objects legend |
	visualizer := ExperimentVisualizer new.
	objects := OrderedDictionary
		newFrom:
			{(#truePositives -> self truePositive).
			(#trueNegative -> self trueNegative).
			(#falsePositive -> self falsePositive).
			(#falseNegative -> self falseNegative)}.
	pie := visualizer createPieChart: objects.
	legend := visualizer createPrecisionLegendIn: pie view.
	legend := RTLegendBuilder new.
	legend view: pie view.
	legend
		addText:
			(changeInTest
				ifTrue: [ 'Test ' ]
				ifFalse: [ 'Source ' ]) , (visualizer symbolToString: change);
		top;
		build.
	pie view @ RTZoomableView.
	pie build.
	^ pie
]

{ #category : #accessing }
ExperimentDataPoint >> popupText [
	^ String
		streamContents: [ :stream | 
			stream
				<< self id asString;
				<< ' - ';
				<< self change;
				cr;
				<< self entity;
				cr;
				<< 'True Positives: ';
				<< self truePositive asString;
				cr;
				<< 'True Negatives: ';
				<< self trueNegative asString;
				cr;
				<< 'False Positives: ';
				<< self falsePositive asString;
				cr;
				<< 'False Negatives: ';
				<< self falseNegative asString ]
]

{ #category : #accessing }
ExperimentDataPoint >> trueNegative [
		^ tn
]

{ #category : #accessing }
ExperimentDataPoint >> trueNegative: anInt [
	tn := anInt
]

{ #category : #accessing }
ExperimentDataPoint >> truePositive [
		^ tp
]

{ #category : #accessing }
ExperimentDataPoint >> truePositive: anInt [
	tp := anInt
]
