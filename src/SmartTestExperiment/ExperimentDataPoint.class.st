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
ExperimentDataPoint >> falseePositive [
		^ fp
]

{ #category : #accessing }
ExperimentDataPoint >> id [
	^ id
]

{ #category : #accessing }
ExperimentDataPoint >> id: anObject [
	id := anObject
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

{ #category : #accessing }
ExperimentDataPoint >> trueeNegative [
		^ tn
]
