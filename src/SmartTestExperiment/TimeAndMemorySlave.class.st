"
See comment for TimeAndMemoryExperiment for an overview of the whole process.

Here, we are running in a special image tailored for one experiment. It runs the experiment and output the results in a CSV file then quit
"
Class {
	#name : #TimeAndMemorySlave,
	#superclass : #TimeAndMemoryExperiment,
	#instVars : [
		'expNumber'
	],
	#classInstVars : [
		'runningExperiment'
	],
	#category : #'SmartTestExperiment-timeAndMem'
}

{ #category : #accessing }
TimeAndMemorySlave class >> getInstance [
	^runningExperiment ifNil: [ runningExperiment := self new ]
]

{ #category : #'instance creation' }
TimeAndMemorySlave class >> new [
	| smTFinders |
	smTFinders := CodeImporter evaluateFileNamed: 'SmartFinders.st'.
	^ self basicNew
		smTFinders: smTFinders;
		smTResults:
			(Dictionary
				newFromKeys: smTFinders keys
				andValues: (Array new: smTFinders size withAll: self resultsFormat));
		initialize;
		yourself
]

{ #category : #analyses }
TimeAndMemorySlave >> applyChangeAndRunAnalyses [
	"compute all tests and selected tests for change"

	self manageBuildCache.
	self flag: 'Nicolas: not sure why we perform analyses here ?1?!?'.
	self changeMustBePerformedAfterAnalysis
		ifTrue: [ "method removal"
			self performAnalysis.
			self processChange ]
		ifFalse: [ "method addition or modification"
			self processChange.
			self performAnalysis ]
]

{ #category : #'experiment-preparation' }
TimeAndMemorySlave >> changeImageNameAndQuit [
	(Smalltalk saveAs: self runningImageBaseName)
		ifFalse: [
			Author fullName: 'TimeAndMemoryExperimenter'.
			self signalEndOfProcess: self prepareSignal.
			Smalltalk snapshot: false andQuit: true
		]
]

{ #category : #'ombu changes' }
TimeAndMemorySlave >> loadChangesBefore: aChangeNumber [
	| remaining |
	remaining := aChangeNumber.
	dataSet ombuFiles
		do: [ :ombName | 
			| ombFile |
			ombFile := dataSet directoryReference / 'ombu-sessions' / ombName.
			(self ombuEntriesFromFile: ombFile)
				do: [ :ombEntry | 
					(remaining := remaining - 1) > 0
						ifTrue: [ ombEntry content isCodeChange
								ifTrue: [ ombEntry content applyCodeChange ] ]
						ifFalse: [ ^ true ] ] ].
	^ false
]

{ #category : #'tests stats' }
TimeAndMemorySlave >> numberOfTests: aCollectionOfTestSuites [
	^ (aCollectionOfTestSuites flatCollect: #flatCollectTests) size
]

{ #category : #analyses }
TimeAndMemorySlave >> performAnalysis: aSymbol [
	smTResults at: aSymbol put: (super performAnalysis: aSymbol)
]

{ #category : #'experiment-preparation' }
TimeAndMemorySlave >> prepareForChange: aChangeNumber myDatasetName: datasetName [
	"we are in an image specific to the data set chosen, so we should not need the datasetName
	 but it is easier to recover it from the command line parameters than to prepare each of the
	 data sets specific images individually"

	self recoverChange: aChangeNumber inDataset: datasetName.
	self resetRunningImage.

	self loadChangesBefore: aChangeNumber.
	self applyChangeAndRunAnalyses.

	self changeImageNameAndQuit
]

{ #category : #'experiment-running' }
TimeAndMemorySlave >> quitImage [
	self signalEndOfProcess: (self runningExpSignal: expNumber).
	
	Smalltalk snapshot: false andQuit: true
]

{ #category : #'experiment-preparation' }
TimeAndMemorySlave >> recoverChange: aChangeNumber inDataset: datasetName [
	dataSet := ApplicationDataSet perform: datasetName.	"recover my dataset informations"
	self packages: dataSet packages.
	currentChange := dataSet changeAtPos: aChangeNumber
]

{ #category : #'experiment-running' }
TimeAndMemorySlave >> reportAllTestsTime: allTestsTime reducedTestTimes: resultsDictionary [
	"see CSV header line in TimeAndMemoryExperiment>>eraseCSV:"

	self
		saveCSVLine:
			{dataSet name.
			self changeNumber.
			currentChange content methodAffected fullName asString.
			(self numberOfTests: collectionOfTestSuites).
			allTestsTime.
			(resultsDictionary keys
				collect: [ :key | 
					{(smTResults at: key) size.
					(resultsDictionary at: key)} ])} flattened
]

{ #category : #'experiment-preparation' }
TimeAndMemorySlave >> resetRunningImage [
	self runningImageName asFileReference deleteIfAbsent: [ "nothing" ]
]

{ #category : #'experiment-running' }
TimeAndMemorySlave >> runExperiment: anInt [
	| allTestsTime resultsTestTimes |
	expNumber := anInt.
	allTestsTime := self timeForTestSuites.
	resultsTestTimes := Dictionary new.
	smTResults
		keysAndValuesDo:
			[ :key :testsToRun | resultsTestTimes at: key put: (self timeForTests: testsToRun) ].
	self
		reportAllTestsTime: allTestsTime
		reducedTestTimes: resultsTestTimes.
	self quitImage
]

{ #category : #processes }
TimeAndMemorySlave >> signalEndOfProcess [
	self signalEndOfProcess: (self runningExpSignal: expNumber)
]

{ #category : #'tests stats' }
TimeAndMemorySlave >> timeForTestSuites [
	^ [ self runSuites ] timeToRunInMicroSeconds
]

{ #category : #'tests stats' }
TimeAndMemorySlave >> timeForTests: testCollection [
	| suite |
	suite := self createTestSuite: testCollection.
	^ [ suite run] timeToRunInMicroSeconds
]
