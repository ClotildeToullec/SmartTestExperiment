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
		'entity',
		'tp',
		'fp',
		'tn',
		'fn'
	],
	#category : #'SmartTestExperiment-reporting'
}

{ #category : #accessing }
ExperimentDataPoint >> change [
	^ change
]

{ #category : #accessing }
ExperimentDataPoint >> change: anObject [
	change := anObject
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
	legend := visualizer pieChartLegendIn: pie view.
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
