"
See comment for TimeAndMemoryExperiment for an overview of the whole process.

Here, we are running in a special image tailored for one experiment. It runs the experiment and output the results in a CSV file then quit
"
Class {
	#name : #TimeAndMemorySlave,
	#superclass : #TimeAndMemoryExperiment,
	#instVars : [
		'expNumber',
		'row',
		'testSelections',
		'timeForAnalyses',
		'timeToBuildCaches'
	],
	#classInstVars : [
		'runningExperiment'
	],
	#category : #'SmartTestExperiment-timeAndMem'
}

{ #category : #accessing }
TimeAndMemorySlave class >> getInstance [
	^ runningExperiment ifNil: [ runningExperiment := self new ]
]

{ #category : #'instance creation' }
TimeAndMemorySlave class >> new [
	| smTFinders |
	smTFinders := CodeImporter evaluateFileNamed: 'SmartFinders.st'.
	^ self basicNew
		smTFinders: smTFinders;
		initialize;
		yourself
]

{ #category : #analysis }
TimeAndMemorySlave >> applyChangeAndRunAnalyses [
	self manageBuildCache.
	self changeMustBePerformedAfterAnalysis
		ifTrue: [ "method removal"
			self performAnalysis.
			self processChange ]
		ifFalse: [ "method addition or modification"
			self processChange.
			self performAnalysis ]
]

{ #category : #preparation }
TimeAndMemorySlave >> changeImageNameAndQuit [
	(Smalltalk saveAs: self runningImageBaseName)
		ifTrue: [ ^ self ].
	Author fullName: 'TimeAndMemoryExperimenter'.
	self signalEndOfProcess: self prepareSignal.
	Smalltalk snapshot: false andQuit: true
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

{ #category : #analysis }
TimeAndMemorySlave >> manageBuildCache [
	| ts |
	ts := TestSuite new.
	ts addTests: collectionOfTestSuites.
	smTFinders
		valuesDo: [ :finder | 
			timeToBuildCaches
				add:
					[ finder resetCacheUsing: ts forChange: currentChange ]
						timeToRunInMicroSeconds ]
]

{ #category : #'tests stats' }
TimeAndMemorySlave >> numberOfTests: aCollectionOfTestSuites [
	^ (aCollectionOfTestSuites flatCollect: #flatCollectTests) size
]

{ #category : #analysis }
TimeAndMemorySlave >> performAnalysis: aSymbol [
	| timeToRun testsSelection |
	timeToRun := [ testsSelection := super performAnalysis: aSymbol ]
		timeToRunInMicroSeconds.	"Considering affectation run-time to be negligible"
	testSelections add: testsSelection.
	timeForAnalyses add: timeToRun
]

{ #category : #preparation }
TimeAndMemorySlave >> prepareForChange: aChangeNumber myDatasetName: datasetName [
	"we are in an image specific to the data set chosen, so we should not need the datasetName
	 but it is easier to recover it from the command line parameters than to prepare each of the
	 data sets specific images individually"

	self recoverChange: aChangeNumber inDataset: datasetName.
	self resetRunningImage.
	self loadChangesBefore: aChangeNumber.
	self changeImageNameAndQuit
]

{ #category : #'experiment-running' }
TimeAndMemorySlave >> quitImage [
	self signalEndOfProcess: (self runningExpSignal: expNumber).
	
	Smalltalk snapshot: false andQuit: true
]

{ #category : #preparation }
TimeAndMemorySlave >> recoverChange: aChangeNumber inDataset: datasetName [
	dataSet := ApplicationDataSet perform: datasetName.	"recover my dataset informations"
	currentEntry := dataSet changeAtPos: aChangeNumber.
	currentChange := currentEntry content
]

{ #category : #'experiment-report' }
TimeAndMemorySlave >> reportAllTests [
	row
		addAll:
			{(self numberOfTests: collectionOfTestSuites).
			self timeForTestSuites}
]

{ #category : #'experiment-report' }
TimeAndMemorySlave >> reportResults [
	self
		reportAllTests;
		reportSmartTestResults;
		saveCSVLine: row
]

{ #category : #'experiment-report' }
TimeAndMemorySlave >> reportSmartTestResults [
	row addAll: timeToBuildCaches.
	row addAll: timeForAnalyses.
	row
		addAll:
			(testSelections collect: [ :selection | self timeForTests: selection ]).
	row addAll: (testSelections collect: [ :selection | selection size ])
]

{ #category : #'experiment-reset' }
TimeAndMemorySlave >> resetExperiment [
	self resetResults.
	self resetRow
]

{ #category : #'experiment-reset' }
TimeAndMemorySlave >> resetResults [
	timeToBuildCaches := OrderedCollection new.
	timeForAnalyses := OrderedCollection new.
	testSelections := OrderedCollection new
]

{ #category : #'experiment-reset' }
TimeAndMemorySlave >> resetRow [
	row := OrderedCollection new.
	row
		addAll:
			{dataSet name.
			self changeNumber.
			currentChange methodAffected fullName asString}
]

{ #category : #preparation }
TimeAndMemorySlave >> resetRunningImage [
	self runningImageName asFileReference deleteIfAbsent: [ "nothing" ]
]

{ #category : #'experiment-running' }
TimeAndMemorySlave >> runExperiment: anInt [
	expNumber := anInt.
	self
		resetExperiment;
		createTestcases;
		applyChangeAndRunAnalyses;
		reportResults;
		quitImage
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
