"
I represent the results of every SmartTest analysis concerning 1 code change.
I store all the relevant information about the change and a results dictionary.

The results are organized as follow: 
	- results are stored as nested Dictionaries
	- The primary keys are the analysis keys (for example: #dynamicAlwaysReset)
	- The secondary keys are #(truePositives falsePositives falseNegatives trueNegatives cacheSize cacheReset)
	- The values are the results
	
I am used by STEMeasurements to store results from STExperimentLauncher and by
STEVisualizer for visualization.
"
Class {
	#name : #STEResult,
	#superclass : #Object,
	#instVars : [
		'id',
		'change',
		'changeType',
		'inTest',
		'affectedLines',
		'results'
	],
	#category : #'SmartTestExperiment-Reporting'
}

{ #category : #'instance creation' }
STEResult class >> new: analysesKeys [
	^ self new initialize: analysesKeys
]

{ #category : #accessing }
STEResult >> affectedLines [
	^ affectedLines
]

{ #category : #accessing }
STEResult >> affectedLines: anObject [
	affectedLines := anObject
]

{ #category : #accessing }
STEResult >> at: analysisKey [
	^ results at: analysisKey
]

{ #category : #accessing }
STEResult >> at: analysisKey at: resultKey [
	^ results at: analysisKey at: resultKey
]

{ #category : #accessing }
STEResult >> at: analysisKey at: resultKey put: aResult [
	^ results at: analysisKey at: resultKey put: aResult
]

{ #category : #accessing }
STEResult >> change [
	^ change
]

{ #category : #accessing }
STEResult >> changeType [
	^ changeType
]

{ #category : #exporting }
STEResult >> exportToCSVStream: aStream [
	| writer |
	writer := (NeoCSVWriter on: aStream)
		separator: $;;
		yourself.
	writer nextPutAll: self flattenedValues
]

{ #category : #exporting }
STEResult >> flattenedValues [
	^ {id.
	change.
	changeType.
	inTest.
	affectedLines} asOrderedCollection
		, (results values flatCollect: [ :resultDict | resultDict values ])
]

{ #category : #accessing }
STEResult >> id [
	^ id
]

{ #category : #accessing }
STEResult >> id: anInt change: aChange changeType: aChangeType inTest: aBoolean [
	id := anInt.
	change := aChange.
	changeType := aChangeType.
	inTest := aBoolean
]

{ #category : #accessing }
STEResult >> inTest [
	^ inTest
]

{ #category : #initialization }
STEResult >> initialize [
	results := OrderedDictionary new
]

{ #category : #initialization }
STEResult >> initialize: analysesKeys [
	analysesKeys
		do: [ :key | results at: key put: self newResultDictionary ]
]

{ #category : #initialization }
STEResult >> newResultDictionary [
	^ Dictionary
		newFromKeys:
			#(truePositives falsePositives falseNegatives trueNegatives cacheSize cacheReset)
		andValues: #(0 0 0 0 0 false)
]

{ #category : #interactions }
STEResult >> popupTextFor: anAnalysisKey [
	^ String
		streamContents: [ :stream | 
			stream
				<< 'Change ';
				<< self id printString;
				<< ' - ';
				<< self changeType;
				cr;
				<< self change;
				cr;
				<< 'True Positives: ';
				<< (self at: anAnalysisKey at: #truePositives asString);
				cr;
				<< 'True Negatives: ';
				<< (self at: anAnalysisKey at: #trueNegatives asString);
				cr;
				<< 'False Positives: ';
				<< (self at: anAnalysisKey at: #falsePositives asString);
				cr;
				<< 'False Negatives: ';
				<< (self at: anAnalysisKey at: #falseNegatives asString) ]
]

{ #category : #accessing }
STEResult >> precisionResults [
	^ OrderedDictionary
		newFromKeys: results keys
		andValues:
			(results values
				collect: [ :resultOfAnalysis | 
					resultOfAnalysis copy
						removeKey: #cacheReset;
						removeKey: #cacheSize;
						yourself ])
]

{ #category : #accessing }
STEResult >> results [
	^ results
]
