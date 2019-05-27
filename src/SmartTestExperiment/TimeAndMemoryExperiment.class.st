"
Abstract class for the three subclasses needed in Time&Memory experiments

General idea is to:
- randomly select a change in all ombu file,
- apply it,
- select tests related to the change,
- and measure the time gain in running only this tests instead of the entire test suite.

Last step is done sevral times (tyically 10) to allow computing average values

This is done by the 3 subclasses: TimeAndMemoryMaster is the main one. It randomly selects a change, then uses TimeAndMemoryPreparer to prepare a child image that will run the experiment for this change, and after TimeAndMemorySlave repeatedly to run the experiment on for this change

"
Class {
	#name : #TimeAndMemoryExperiment,
	#superclass : #AbstractSmartTestExperiment,
	#instVars : [
		'csvFilename'
	],
	#category : #'SmartTestExperiment-timeAndMem'
}

{ #category : #accessing }
TimeAndMemoryExperiment class >> csvFile [
	^ '/home/clotilde/Documents/Stage/TimeAndMem/timeExp.csv'
]

{ #category : #'instance creation' }
TimeAndMemoryExperiment class >> resultsFormat [
	^ Dictionary new
]

{ #category : #accessing }
TimeAndMemoryExperiment class >> rootDir [
	^ '/home/clotilde/Documents/Stage/TimeAndMem/'
]

{ #category : #accessing }
TimeAndMemoryExperiment >> currentDatasetName [
	^ dataSet name
]

{ #category : #exportToCSV }
TimeAndMemoryExperiment >> eraseCSV: aBoolean [
	| file |
	file := self class csvFile asFileReference.
	file exists
		ifTrue: [ aBoolean
				ifTrue: [ file delete ]
				ifFalse: [ ^ self ] ].
	self
		saveCSVLine:
			{'Dataset'.
			'change number'.
			'changed method'.
			'#all tests'.
			'time all tests'.
			(smTFinders keys
				collect: [ :key | 
					{('selected test ' , key asString).
					('analysis time ' , key asString).
					('time selected tests ' , key asString)} ])} flattened
]

{ #category : #processes }
TimeAndMemoryExperiment >> prepareSignal [
	^ 'prepare.sig'
]

{ #category : #processes }
TimeAndMemoryExperiment >> runningExpSignal: anInt [
	^ 'running' , anInt asString , '.sig'
]

{ #category : #utilities }
TimeAndMemoryExperiment >> runningImageBaseName [
	^String streamContents: [ :str |
			str
				<< self class rootDir << '/'
				<< dataSet baseDirectory << '/'
				<< dataSet name << '_' << 'running'
		]
			
]

{ #category : #utilities }
TimeAndMemoryExperiment >> runningImageName [
	^ self runningImageBaseName , '.' , Smalltalk imageSuffix
]

{ #category : #exportToCSV }
TimeAndMemoryExperiment >> saveCSVLine: aCollection [
	self class csvFile asFileReference writeStreamDo: [ :str |
		str setToEnd.
		aCollection do: [ :each |
			each isString
				ifTrue: [ str << (self surroundByDoubleQuotes: each) ]
				ifFalse: [ str << each asString ].
			str nextPut: $; .
		].
		str cr
	]
]

{ #category : #processes }
TimeAndMemoryExperiment >> signalEndOfProcess: aString [
	(self class rootDir asFileReference / aString) ensureCreateFile
]

{ #category : #exportToCSV }
TimeAndMemoryExperiment >> surroundByDoubleQuotes: aString [
	^ aString surroundedBy: ($" asString)
]

{ #category : #processes }
TimeAndMemoryExperiment >> updateImageSignal [
	^ 'updateImage.sig'
]

{ #category : #processes }
TimeAndMemoryExperiment >> waitForSignal: aString [
	| file |
	file := self class rootDir asFileReference / aString.
	[ file exists ]
		whileFalse: [ (Delay forMilliseconds: 100) wait ].
	file delete
]
