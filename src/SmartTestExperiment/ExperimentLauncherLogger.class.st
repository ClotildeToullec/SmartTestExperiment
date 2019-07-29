"
Utility class for logging results
"
Class {
	#name : #ExperimentLauncherLogger,
	#superclass : #ExperimentLogger,
	#instVars : [
		'measurements'
	],
	#category : #'SmartTestExperiment-reporting'
}

{ #category : #accessing }
ExperimentLauncherLogger >> launcherMeasurements: aLauncherMeasurements [
	measurements := aLauncherMeasurements
]

{ #category : #'analysis logging' }
ExperimentLauncherLogger >> logAnalysis: smartTestResults [
	self log: '** smarttest analysis >> ' crBefore: true indentation: 1.
	smartTestResults
		keysAndValuesDo: [ :keyword :result | 
			self
				log: 'smarttestResults' , keyword asString capitalized , ': ---'
				crBefore: true
				indentation: 2.
			result
				keysAndValuesDo: [ :anEpChange :aCollectionOfMethodReferences | 
					self
						log: anEpChange methodAffected fullName
						crBefore: true
						indentation: 3.
					self log: '' crBefore: true indentation: 4.
					self logCollection: aCollectionOfMethodReferences ] ].
	smartTestResults size == 2
		ifTrue: [ self logDifferenceBetween: smartTestResults ]
]

{ #category : #csv }
ExperimentLauncherLogger >> logCSVHeader: columnNames [
	self log: '"CSV"' crBefore: true indentation: 0.
	columnNames do: [ :colName |
		logstream
			nextPut: $; ;
			nextPutAll: (ExperimentLauncherMeasurements convertCamelcaseToTitle: colName)
	]
]

{ #category : #csv }
ExperimentLauncherLogger >> logCSVRow: values [
	self log: '"CSV"' crBefore: true indentation: 0.
	values
		do: [ :value | 
			logstream
				nextPut: $;;
				nextPutAll: value asString ]
]

{ #category : #'results logging' }
ExperimentLauncherLogger >> logCacheResetForFinder: aSymbol [
	self
		log: 'Cache Reset: ' , (self symbolToString: aSymbol)
		crBefore: true
		indentation: 1.
	measurements
		incrementResult: #cacheReset , aSymbol capitalized
		withAmount: 1
]

{ #category : #logging }
ExperimentLauncherLogger >> logCacheSize: anInt [
	self log: 'smarttestResults cacheSize = ' , anInt printString, ' kilobytes' crBefore: true indentation: 2
]

{ #category : #'results logging' }
ExperimentLauncherLogger >> logCollectingMeasurementsPrecision: aSymbol [
	self
		log: 'Measure precision ' , aSymbol asString , ' --- '
		crBefore: true
		indentation: 2
]

{ #category : #'analysis logging' }
ExperimentLauncherLogger >> logDifferenceBetween: smartTestResults [
	| difference |
	difference := (smartTestResults values first) values
		difference: (smartTestResults values second) values.
	difference isEmpty
		ifTrue: [ self
				log: 'smarttestResults No Difference'
				crBefore: true
				indentation: 2 ]
		ifFalse: [ self
				log: 'smarttestResults Difference: ---'
				crBefore: true
				indentation: 2.
			self logCollection: difference asSet flattened]
]

{ #category : #'results logging' }
ExperimentLauncherLogger >> logFalseNegatives: aSetOfMethodSelectors forFinder: aSymbol [
	aSetOfMethodSelectors isEmpty
		ifTrue: [ self log: 'No false negatives' crBefore: true indentation: 3 ]
		ifFalse: [ measurements
				incrementResult: #falseNegatives , aSymbol capitalized
				withAmount: aSetOfMethodSelectors size.
			self
				log: '!! false negatives >> ' , aSetOfMethodSelectors size printString
				crBefore: true
				indentation: 3.
			self log: '' crBefore: true indentation: 4.
			self logCollection: aSetOfMethodSelectors ]
]

{ #category : #'results logging' }
ExperimentLauncherLogger >> logFalsePositives: aSetOfMethodSelectors forFinder: aSymbol [
	aSetOfMethodSelectors isEmpty
		ifTrue: [ self log: 'No false positives' crBefore: true indentation: 3 ]
		ifFalse: [ measurements
				incrementResult: #falsePositives , aSymbol capitalized
				withAmount: aSetOfMethodSelectors size.
			self
				log: '?? false positives >> ' , aSetOfMethodSelectors size printString
				crBefore: true
				indentation: 3.
			self log: '' crBefore: true indentation: 4.
			self logCollection: aSetOfMethodSelectors ]
]

{ #category : #'final logging' }
ExperimentLauncherLogger >> logFinalResult: aSymbol forFinder: aFinderSymbol [
	self
		log: (self symbolToString: aSymbol , aFinderSymbol capitalized) , ': '
		crBefore: true
		indentation: 0.
	(measurements totalResultsForFinder: aFinderSymbol)
		keysAndValuesDo: [ :key :value | 
			self
				log: (self symbolToString: key) , ' = ' , value printString
				crBefore: true
				indentation: 1 ]
]

{ #category : #'final logging' }
ExperimentLauncherLogger >> logFinalResultsForFinders: aSymbolCollection [
	self
		log: '-------------------------------------------------------------------'
		crBefore: true
		indentation: 0.
	aSymbolCollection
		do: [ :symbol | self logFinalResult: #totalResults forFinder: symbol ].
	self
		logTotalSourceCodeChurn;
		logTotalTestCodeChurn
]

{ #category : #'execution time' }
ExperimentLauncherLogger >> logTime: aDuration forFinder: aSymbol [
	self
		log:
			(self symbolToString: aSymbol) , ' test time = '
				, aDuration printString , ' milliseconds'
		crBefore: true
		indentation: 2
]

{ #category : #'final logging' }
ExperimentLauncherLogger >> logTotalSourceCodeChurn [
	self log: 'Total Source Code Churn : ' crBefore: true indentation: 0.
	measurements totalSourceCodeChurn
		keysAndValuesDo: [ :key :value | 
			self
				log: (self symbolToString: key) , ' = ' , value printString
				crBefore: true
				indentation: 1 ]
]

{ #category : #'final logging' }
ExperimentLauncherLogger >> logTotalTestCodeChurn [
	self log: 'Total Test Code Churn : ' crBefore: true indentation: 0.
	measurements totalTestCodeChurn
		keysAndValuesDo: [ :key :value | 
			self
				log: (self symbolToString: key) , ' = ' , value printString
				crBefore: true
				indentation: 1 ]
]

{ #category : #'results logging' }
ExperimentLauncherLogger >> logTrueNegatives: aSetOfMethodSelectors forFinder: aSymbol [
	aSetOfMethodSelectors isEmpty
		ifTrue: [ self log: 'No true negatives' crBefore: true indentation: 3 ]
		ifFalse: [ measurements
				incrementResult: #trueNegatives , aSymbol capitalized
				withAmount: aSetOfMethodSelectors size.
			self
				log: '++ true negatives >> ' , aSetOfMethodSelectors size printString
				crBefore: true
				indentation: 3.
			self log: '' crBefore: true indentation: 4.
			self logCollection: aSetOfMethodSelectors ]
]

{ #category : #'results logging' }
ExperimentLauncherLogger >> logTruePositives: aSetOfMethodSelectors forFinder: aSymbol [
	aSetOfMethodSelectors isEmpty
		ifTrue: [ self log: 'No true positives' crBefore: true indentation: 3 ]
		ifFalse: [ measurements
				incrementResult: #truePositives , aSymbol capitalized
				withAmount: aSetOfMethodSelectors size.
			self
				log: '## true positives >> ' , aSetOfMethodSelectors size printString
				crBefore: true
				indentation: 3.
			self log: '' crBefore: true indentation: 4.
			self logCollection: aSetOfMethodSelectors ]
]

{ #category : #'final logging' }
ExperimentLauncherLogger >> symbolToString: aSymbol [
	"Utility -- Should not be here -- Twin method in Visualizer:
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
