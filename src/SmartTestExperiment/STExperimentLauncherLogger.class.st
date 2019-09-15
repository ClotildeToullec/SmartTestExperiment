"
Utility class for logging results of STExperimentLauncher
"
Class {
	#name : #STExperimentLauncherLogger,
	#superclass : #STELogger,
	#category : #'SmartTestExperiment-Reporting'
}

{ #category : #'logging-final' }
STExperimentLauncherLogger >> log: aSymbol totalCodeChurn: aDictionary [
	self
		log: aSymbol asString capitalized , ' code : '
		crBefore: true
		indentation: 0.
	aDictionary
		keysAndValuesDo: [ :key :value | 
			self
				log: (self symbolToString: key) , ' = ' , value printString
				crBefore: true
				indentation: 1 ]
]

{ #category : #'logging-analysis ' }
STExperimentLauncherLogger >> logAnalysis: smartTestResults [
	self
		blankLine;
		log: '----- SmartTest analysis -----' crBefore: true indentation: 0.
	smartTestResults
		keysAndValuesDo: [ :keyword :result | 
			self
				log: 'SmartTest selection: ' , (self symbolToString: keyword) , ':'
				crBefore: true
				indentation: 1.
			self log: '' crBefore: true indentation: 2.
			self logCollection: result ].
	smartTestResults size == 2
		ifTrue: [ self logDifferenceBetween: smartTestResults ]
]

{ #category : #csv }
STExperimentLauncherLogger >> logCSVHeader: columnNames [
	self log: '"CSV"' crBefore: true indentation: 0.
	columnNames do: [ :colName |
		logstream
			nextPut: $; ;
			nextPutAll: (STEMeasurements convertCamelcaseToTitle: colName)
	]
]

{ #category : #csv }
STExperimentLauncherLogger >> logCSVRow: values [
	self
		blankLine;
		log: '"CSV"' crBefore: true indentation: 0.
	values
		do: [ :value | 
			logstream
				nextPut: $;;
				nextPutAll: value asString ]
]

{ #category : #'logging-results' }
STExperimentLauncherLogger >> logCacheResetForFinder: aSymbol [
	self
		log: '--> Cache Reset: ' , (self symbolToString: aSymbol)
		crBefore: true
		indentation: 1
]

{ #category : #'logging-cache' }
STExperimentLauncherLogger >> logCacheSize: anInt for: aSymbol [
	self
		log:
			(self symbolToString: aSymbol) , ' cache size = ' , anInt printString
				, ' kilobytes'
		crBefore: true
		indentation: 2
]

{ #category : #'logging-cache' }
STExperimentLauncherLogger >> logCacheUpdate [
	self
		blankLine;
		log: '----- Updating cache -----' crBefore: true indentation: 0
]

{ #category : #'logging-oracle' }
STExperimentLauncherLogger >> logCreatedOracle: oracle [
	self
		log: 'Oracle:' crBefore: true indentation: 1;
		log: '' crBefore: true indentation: 2;
		logCollection: (oracle ifEmpty: [ {'No tests found'} ])
]

{ #category : #'logging-analysis ' }
STExperimentLauncherLogger >> logDifferenceBetween: smartTestResults [
	| difference |
	difference := (smartTestResults values first) values
		difference: (smartTestResults values second) values.
	difference isEmpty
		ifTrue: [ self
				log: 'No difference between strategies'
				crBefore: true
				indentation: 2 ]
		ifFalse: [ self
				log: 'Difference between strategies:'
				crBefore: true
				indentation: 2.
			self logCollection: difference asSet flattened]
]

{ #category : #'logging-final' }
STExperimentLauncherLogger >> logFinalResults: aDictionaryOfResults ofFinder: aFinderSymbol [
	self
		log: 'Total results ' , aFinderSymbol capitalized , ': '
		crBefore: true
		indentation: 0.
	aDictionaryOfResults
		keysAndValuesDo: [ :key :value | 
			self
				log: (self symbolToString: key) , ' = ' , value printString
				crBefore: true
				indentation: 1 ]
]

{ #category : #'logging-results' }
STExperimentLauncherLogger >> logPrecision: aSymbol [
	self
		blankLine;
		log: '----- ' , 'Precision ' , aSymbol asString , ' ----- '
			crBefore: true
			indentation: 0
]

{ #category : #'logging-analysis ' }
STExperimentLauncherLogger >> logStartOfOracleCreation [
	self
		blankLine;
		log: '----- Oracle Creation -----' crBefore: true indentation: 0
]

{ #category : #'logging-results' }
STExperimentLauncherLogger >> logTests: aSetOfMethodSelectors asResult: aSymbol [
	| resultString |
	resultString := self symbolToString: aSymbol.
	aSetOfMethodSelectors isEmpty
		ifTrue: [ self log: 'No ' , resultString crBefore: true indentation: 1 ]
		ifFalse: [ self
				log: aSetOfMethodSelectors size printString , resultString , ':'
				crBefore: true
				indentation: 1.
			self log: '' crBefore: true indentation: 2.
			self logCollection: aSetOfMethodSelectors ]
]

{ #category : #'logging-execution time' }
STExperimentLauncherLogger >> logTime: aDuration forFinder: aSymbol [
	self
		log:
			(self symbolToString: aSymbol) , ' test time = '
				, aDuration printString , ' milliseconds'
		crBefore: true
		indentation: 2
]

{ #category : #'logging-final' }
STExperimentLauncherLogger >> logTotalChanges: changesAmount affectedLines: linesAmount inTests: aBoolean [
	| title |
	title := aBoolean
		ifTrue: [ 'Test code' ]
		ifFalse: [ 'Source code' ].
	self
		log: title crBefore: true indentation: 0;
		log: changesAmount printString , ' changes'
			crBefore: true
			indentation: 1;
		log: linesAmount printString , ' lines affected'
			crBefore: true
			indentation: 1
]
