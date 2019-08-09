"
Utility class for logging results
"
Class {
	#name : #ExperimentLauncherLogger,
	#superclass : #ExperimentLogger,
	#category : #'SmartTestExperiment-reporting'
}

{ #category : #'final logging' }
ExperimentLauncherLogger >> log: aSymbol totalCodeChurn: aDictionary [
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

{ #category : #'analysis logging' }
ExperimentLauncherLogger >> logAnalysis: smartTestResults [
	self
		blankLine;
		log: '** SmartTest analysis >> ' crBefore: true indentation: 0.
	smartTestResults
		keysAndValuesDo: [ :keyword :result | 
			self
				log: 'SmartTest selection: ' , (self symbolToString: keyword) , ':'
				crBefore: true
				indentation: 2.
			self log: '' crBefore: true indentation: 4.
			self logCollection: result ].
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
	self
		blankLine;
		log: '"CSV"' crBefore: true indentation: 0.
	values
		do: [ :value | 
			logstream
				nextPut: $;;
				nextPutAll: value asString ]
]

{ #category : #'results logging' }
ExperimentLauncherLogger >> logCacheResetForFinder: aSymbol [
	self
		log: '** Cache Reset: ' , (self symbolToString: aSymbol)
		crBefore: true
		indentation: 1
]

{ #category : #logging }
ExperimentLauncherLogger >> logCacheSize: anInt for: aSymbol [
	self
		log:
			(self symbolToString: aSymbol) , ' cache size = ' , anInt printString
				, ' kilobytes'
		crBefore: true
		indentation: 2
]

{ #category : #logging }
ExperimentLauncherLogger >> logCacheUpdate [
	self
		blankLine;
		log: '** Updating cache' crBefore: true indentation: 0
]

{ #category : #logging }
ExperimentLauncherLogger >> logCreatedOracle: oracle [
	self
		log: '** Oracle:' crBefore: true indentation: 1;
		log: '' crBefore: true indentation: 3;
		logCollection: (oracle ifEmpty: [ {'No tests found'} ])
]

{ #category : #'analysis logging' }
ExperimentLauncherLogger >> logDifferenceBetween: smartTestResults [
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

{ #category : #'final logging' }
ExperimentLauncherLogger >> logFinalResults: aDictionaryOfResults ofFinder: aFinderSymbol [
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

{ #category : #'results logging' }
ExperimentLauncherLogger >> logPrecision: aSymbol [
	self
		blankLine;
		log: ' ----- ' , 'Precision ' , aSymbol asString , ' ----- '
			crBefore: true
			indentation: 2
]

{ #category : #'analysis logging' }
ExperimentLauncherLogger >> logStartOfOracleCreation [
	self
		blankLine;
		log: '** Creating Oracle ' crBefore: true indentation: 0
]

{ #category : #'results logging' }
ExperimentLauncherLogger >> logTests: aSetOfMethodSelectors asResult: aSymbol [
	| resultString |
	resultString := self symbolToString: aSymbol.
	aSetOfMethodSelectors isEmpty
		ifTrue: [ self
				log: 'No ' , resultString asLowercase
				crBefore: true
				indentation: 3 ]
		ifFalse: [ self
				log: resultString , ' >> ' , aSetOfMethodSelectors size printString
				crBefore: true
				indentation: 3.
			self log: '' crBefore: true indentation: 4.
			self logCollection: aSetOfMethodSelectors ]
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
