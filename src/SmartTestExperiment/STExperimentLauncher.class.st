"
I represent a launcher for excersising SmartTest using an Epicea change-list and collecting various metrics

Responsabilities:
* dry-run: this loads the changes and runs the tests (to verify that the whole expermental run will not cause major havoc like infinite loops, ...)
* run: this runs a complete change-list and collects the measurements.
* oracle creation: creates an  mapping for each class which tests excercise it. Used as an oracle for calculating false positives, false negatives, ...
* fixing: some epice files contain problematic constructs. At the class level there are a few utilities to clean them up
* logging: I have a class level switch to enable/disable logging

Collaborators Part:
* Epicea: I rely heavily on the class hierarchy and the protocol to know which type of changes are under analysis and the way to apply them
* I rely on the SmartTest finder and the annunce protocol (SmTListener) , to see which changes actually mapped onto tests
* I rely on SUnit and TestSuite to calculate the test coverage while creating the oracle
* I (partially) rely on CVS exporter to export my results to .csv files  (only when invoking #measurements exportToCSV:)
* I (partially) rely on Roassal to show results (only when invoking measurements exportToCSV: visualise*)

Public API and Key Messages
* See #runCreationOfOracle for a typical scenario

Internal Representation and Key Implementation Points.
... to be done
"
Class {
	#name : #STExperimentLauncher,
	#superclass : #AbstractSTExperiment,
	#instVars : [
		'changeList',
		'oracle',
		'measurements',
		'visualizer'
	],
	#classInstVars : [
		'lastRuns',
		'intermediateSave',
		'packagesInSystem'
	],
	#category : #'SmartTestExperiment-Analysis'
}

{ #category : #scenarios }
STExperimentLauncher class >> dryrunTestScenarioCurrentPheme [
	"self dryrunTestScenarioCurrentPheme"

	| el |
	el := self
		onOmbuFiles: {'Pheme1.ombu'}
		logFileName: 'Pheme1_LOG'
		withPackages:
			{#'Pheme'}.
	^ el
		prepare;
		dryrun;
		terminate
]

{ #category : #exporting }
STExperimentLauncher class >> exportToCSV: fileName [
	| stream fileReference |
	fileReference := fileName asFileReference.
	fileReference exists
		ifTrue: [ fileReference delete ].
	stream := fileName asFileReference writeStream.
	[ lastRuns
		withIndexDo: [ :run :i | run exportToCSVStream: stream withHeader: i = 1 ] ]
		ensure: [ stream close ]
]

{ #category : #utilities }
STExperimentLauncher class >> fixOmbuFileNamed: aFileName [
	"Some Epicea files contain little quirks which hamper or even prevent launching a SmartTest experiment. This method goes over an epicea change file, fixes the issues and then overwrites the file so that future experimemt runs will go smoothly"

	"self fixOmbuFileNamed: 'PharoLANTest.ombu'"

	| outputLog changeList |
	changeList := (self ombuEntriesFromFile: aFileName asFileReference) asOrderedCollection.
	1 to: changeList size - 1 do: [ :inx | 
		(changeList at: inx) content class == EpBehaviorCommentChange
			ifTrue: [ (changeList at: inx + 1) content class == EpClassAddition
					ifTrue: [ | tmp |
						Transcript
							cr;
							show: 'Switched ' , (changeList at: inx) content printString , ' with ' , (changeList at: inx + 1) content printString.
						tmp := changeList at: inx.
						changeList at: inx put: (changeList at: inx + 1).
						changeList at: inx + 1 put: tmp ] ] ].
	outputLog := EpLog newWithStore: (OmStoreFactory current named: aFileName asFileReference base , '_FX' inDirectory: aFileName asFileReference absolutePath parent asFileReference).
	^ EpOmbuExporter new
		outputLog: outputLog;
		fileOut: changeList
]

{ #category : #accessing }
STExperimentLauncher class >> intermediateSave [
	"self intermediateSave"
<script>
	^ intermediateSave
]

{ #category : #accessing }
STExperimentLauncher class >> intermediateSave: anExperimentLauncher [
	"self intermediateSave: self lastRun"
	
	intermediateSave := anExperimentLauncher
]

{ #category : #accessing }
STExperimentLauncher class >> lastRun [
	lastRuns isNotEmpty
	ifTrue: [ ^ lastRuns last ]
	ifFalse: [  ^ nil ]
	
]

{ #category : #accessing }
STExperimentLauncher class >> lastRunAt: anInt [
	lastRuns size >= anInt
	ifTrue: [ ^ lastRuns at: anInt ]
	ifFalse: [  ^ nil ]
	
]

{ #category : #utilities }
STExperimentLauncher class >> loadChangesIn: ombuFilename [
	| changeList |
	changeList := (self ombuEntriesFromFile: ombuFilename asFileReference) asOrderedCollection.
	UIManager default
		displayProgress: 'loading change '
		from: 1
		to: changeList size
		during: [ :bar |
			changeList do: [ :ombChg |
				bar label: 'loading change ' , (ombChg tagAt: #self) localName.
				(ombChg content isCodeChange)
					ifTrue: [ ombChg content applyCodeChange ].
				bar increment
			].
		]
]

{ #category : #utilities }
STExperimentLauncher class >> loadChangesIn: ombuFilename from: startNumber to: endNumber [

	(self ombuEntriesFromFile: ombuFilename asFileReference) asOrderedCollection do: [ :ombChg |
		( ( (startNumber to: endNumber) includes: ((ombChg tagAt: #self) localName asInteger) )
			and: [ ombChg content isCodeChange ] )
			ifTrue: [ ombChg content applyCodeChange ]
	]
]

{ #category : #private }
STExperimentLauncher class >> logFileName: aProjectName number: i [
	^ String
		streamContents: [ :stream | 
			stream
				<< self rootDir;
				<< aProjectName;
				<< '/';
				<< aProjectName;
				<< i asString;
				<< '.log' ]
]

{ #category : #private }
STExperimentLauncher class >> ombuFileName: aProjectName number: i [
	^ String
		streamContents: [ :stream | 
			stream
				<< self rootDir;
				<< aProjectName;
				<< '/ombu-sessions/';
				<< aProjectName;
				<< '_0';
				<< i asString;
				<< '.ombu' ]
]

{ #category : #private }
STExperimentLauncher class >> ombuFilesInProject: aProjectName [
	| files |
	files := (self rootDir , aProjectName , '/ombu-sessions/')
		asFileReference files select: [ :file | file extension = 'ombu' ].
	^ files sorted: [ :file1 :file2 | file1 base < file2 base ]
	"More rigorous but very slow: 
		OmbuFilesOrganizer new sortByDate: files"
]

{ #category : #'instance creation' }
STExperimentLauncher class >> onOmbuFiles: aListOfFileNames logFileName: aLogFileName withPackages: packageNames [
	| logfileRef changes fileRef |
	changes := OrderedCollection new.
	aListOfFileNames
		do: [ :fileName | 
			fileRef := fileName asFileReference.
			fileRef exists
				ifTrue:
					[ changes addAll: (self ombuEntriesFromFile: fileName asFileReference) ] ].
	logfileRef := aLogFileName asFileReference.
	lastRuns
		add:
			(self new
				logFileReference: logfileRef;
				packages: packageNames;
				changeList: changes;
				yourself).
	^ self lastRun
]

{ #category : #'instance creation' }
STExperimentLauncher class >> onOmbuFiles: aListOfFileNames logFileName: aLogFileName withPackages: packageNames withFinders: aSmartFindersDictionary [
	| logfileRef changes fileRef |
	changes := OrderedCollection new.
	aListOfFileNames
		do: [ :fileName | 
			fileRef := fileName asFileReference.
			fileRef exists
				ifTrue:
					[ changes addAll: (self ombuEntriesFromFile: fileName asFileReference) ] ].
	logfileRef := aLogFileName asFileReference.
	lastRuns
		add:
			((self new: aSmartFindersDictionary)
				logFileReference: logfileRef;
				packages: packageNames;
				changeList: changes;
				yourself).
	^ self lastRun
]

{ #category : #private }
STExperimentLauncher class >> packagesToAnalyzeInFiles: files [
	| packagesInFiles |
	packagesInFiles := OmbuFilesOrganizer new packagesInFiles: files.
	packagesInSystem := packagesInSystem
		ifNil: [ RPackageOrganizer default packageNames ].
	^ (packagesInFiles \ packagesInSystem) asArray
]

{ #category : #visualization }
STExperimentLauncher class >> reopenLastResults [
	<script>
	self allInstances last visualizeResults
]

{ #category : #'instance creation' }
STExperimentLauncher class >> resetLastRun [
	"self resetLastRun"
	lastRuns := OrderedCollection new
]

{ #category : #private }
STExperimentLauncher class >> resetPackagesInSystem [
	packagesInSystem := RPackageOrganizer default packageNames
]

{ #category : #'instance creation' }
STExperimentLauncher class >> resultsFormat [
	^ IdentitySet new
]

{ #category : #private }
STExperimentLauncher class >> rootDir [
	^ '/home/clotilde/Documents/Stage/Projets/'
]

{ #category : #LANSimulationExp }
STExperimentLauncher class >> runEntireLANSimulationExp [
	<script>
	self runScenario: 'LANSimulation' withFinders: self ungenericFinders
]

{ #category : #FamixExp }
STExperimentLauncher class >> runFamixExpOnFile: anOmbuFileNumber [
	| files packages el ombFile logFile |
	EpMonitor current disable.
	files := self ombuFilesInProject: 'Famix'.
	packages := (OmbuFilesOrganizer new packagesInFiles: files) asArray.
	self resetLastRun.
	1 to: anOmbuFileNumber do: [ :i | 
		ombFile := self ombuFileName: 'Famix' number: i.
		logFile := self logFileName: 'Famix' number: i.
		el := self
			onOmbuFiles: {ombFile}
			logFileName: logFile
			withPackages: packages
			withFinders: self ungenericFinders.
		el
			prepare: false;
			run: i = anOmbuFileNumber;
			terminate: i = anOmbuFileNumber ].
	SmalltalkImage current snapshot: true andQuit: false.
	EpMonitor current enable
]

{ #category : #'generic experiment' }
STExperimentLauncher class >> runKeepingPackagesScenario: aProjectName [
	"Packages will not be erased before experiment"

	| files |
	files := self ombuFilesInProject: aProjectName.
	self
		runKeepingPackagesScenario: aProjectName
		ombuFiles: (1 to: files size)
		packages: (OmbuFilesOrganizer new packagesInFiles: files) asArray
		withFinders: self defaultFinders
]

{ #category : #'generic experiment' }
STExperimentLauncher class >> runKeepingPackagesScenario: aProjectName ombuFiles: fileNumbers packages: aPackagesCollection withFinders: aSmartFindersDictionary [
	"One experiment for each ombu file.	Packages will not be erased before experiment"

	| el |
	EpMonitor current disable.
	self resetLastRun.
	fileNumbers
		do: [ :i | 
			el := self
				onOmbuFiles: {(self ombuFileName: aProjectName number: i)}
				logFileName: (self logFileName: aProjectName number: i)
				withPackages: aPackagesCollection
				withFinders: aSmartFindersDictionary.
			el
				prepare: false;
				run;
				terminate.
			SmalltalkImage current snapshot: true andQuit: false ].
	EpMonitor current enable
]

{ #category : #'generic experiment' }
STExperimentLauncher class >> runKeepingPackagesScenario: aProjectName withFinders: smartFindersDictionary [
	"Packages will not be erased before experiment"

	| files |
	files := self ombuFilesInProject: aProjectName.
	self
		runKeepingPackagesScenario: aProjectName
		ombuFiles: (1 to: files size)
		packages: (OmbuFilesOrganizer new packagesInFiles: files) asArray
		withFinders: smartFindersDictionary
]

{ #category : #LANSimulationExp }
STExperimentLauncher class >> runLANSimulationExpOnSecondFile [
	<script>
	| el ombFile logFile |
	EpMonitor current disable.
	self resetLastRun.
	1 to: 2 do: [ :i | 
		ombFile := self ombuFileName: 'LANSimulation' number: i.
		logFile := self logFileName: 'LANSimulation' number: i.
		el := self
			onOmbuFiles: {ombFile}
			logFileName: logFile
			withPackages: {'LANSimulation'}
			withFinders: self ungenericFinders.
		el
			prepare: i = 1;
			run: i = 2;
			terminate: i = 2 ].
	SmalltalkImage current snapshot: true andQuit: false.
	EpMonitor current enable
]

{ #category : #'generic experiment' }
STExperimentLauncher class >> runScenario: aProjectName [
	"Erase package before the first experiment"

	| files |
	files := self ombuFilesInProject: aProjectName.
	self
		runScenario: aProjectName
		ombuFiles: (1 to: files size)
		packages: (self packagesToAnalyzeInFiles: files)
		withFinders: self defaultFinders
]

{ #category : #'generic experiment' }
STExperimentLauncher class >> runScenario: aProjectName ombuFiles: fileNumbers packages: aPackagesCollection withFinders: aSmartFindersDictionary [
	"One experiment for each ombu file. Erase package before the first experiment"

	| el firstFile |
	EpMonitor current disable.
	self resetLastRun.
	firstFile := fileNumbers first.
	fileNumbers
		do: [ :i | 
			el := self
				onOmbuFiles: {(self ombuFileName: aProjectName number: i)}
				logFileName: (self logFileName: aProjectName number: i)
				withPackages: aPackagesCollection
				withFinders: aSmartFindersDictionary.
			el
				prepare: i = firstFile;
				"if first file, erase package first, otherwise keep it"
					run;
				terminate.
			SmalltalkImage current snapshot: true andQuit: false ].
	EpMonitor current enable
]

{ #category : #'generic experiment' }
STExperimentLauncher class >> runScenario: aProjectName withFinders: smartFindersDictionary [
	"Erase package before the first experiment"

	| files |
	files := self ombuFilesInProject: aProjectName.
	self
		runScenario: aProjectName
		ombuFiles: (1 to: files size)
		packages: (OmbuFilesOrganizer new packagesInFiles: files) asArray
		withFinders: smartFindersDictionary
]

{ #category : #scenarios }
STExperimentLauncher class >> runScenarioPillar [
	"self runScenarioPillar"

	self runScenarioPillar: {  '3' . '4' . '5' . '6'. '7' . '8' . '9' . '10' . '11' . '12'. '13' . '14' . '16' . '17' . '18'. '19' . '20' . '21' . '22' . '24'. '25' . '27' . '28' . '29' . '30'  }

]

{ #category : #scenarios }
STExperimentLauncher class >> runScenarioPillar: aCollection [
	"self runScenarioPillar: (1 to: 9)"

	| el |

	self resetLastRun.
	aCollection do: [ :i |
		el := self
			onOmbuFiles: { 'ombu-sessions/pharo' , i asString , '.ombu' }
			logFileName: 'pillar' , i asString , '.log'
			withPackages: {#'Pillar-Tests-Cli' . #'Pillar-PetitPillar' . #'Pillar-ExporterDeckJS' .
				#'Pillar-Tests-ExporterLaTeX' . #'Pillar-Pharo-Tools' . #'Pillar-Tests-Model'.
				#'Pillar-ExporterBeamer' . #'Pillar-GitBook' . #'Pillar-ExporterHTML' .
				#'Pillar-Tests-ExporterEPub' . #'Pillar-Tests-ExporterBeamer'.
				#'Pillar-Cli-PillarVersion' . #'Pillar-Tests-ExporterAsciiDoc' . #'Pillar-ExporterEPub' .
				#'Pillar-ExporterMarkdown' . #'Pillar-ExporterLaTeX'.
				#'Pillar-ExporterPillar' . #'Pillar-Project' . #'Pillar-Tests-ExporterCore' .
				#'Pillar-Tests-ExporterText' . #'Pillar-Tests-BuildPipeline'.
				#'Pillar-Tests-PetitPillar' . #'Pillar-Tests-ExporterDeckJS' .
				#'Pillar-Tests-ExporterPillar' . #'Pillar-ExporterAsciiDoc' .
				#'Pillar-Tests-ExporterMarkdown'.
				#'Pillar-Tests-ExporterHTML' . #'Pillar-BuildPipeline' . #'Pillar-ExporterCore' .
				#'Pillar-ExporterText' . #'Pillar-Model' . #'Pillar-Cli'}.

			el
				prepare: false ;
				run ;
				terminate.
			self saveImage
		]
]

{ #category : #scenarios }
STExperimentLauncher class >> runScenarioPostgreSQL [
	self runScenarioPostgreSQL: (1 to: 4)
]

{ #category : #scenarios }
STExperimentLauncher class >> runScenarioPostgreSQL: aCollection [
	| el |

	self resetLastRun.
	aCollection do: [ :i |
		el := self
			onOmbuFiles: { 'ombu-sessions/postgresql' , i asString ,  '.ombu' }
			logFileName: 'postgreSQL' , i asString ,  '.log'
			withPackages: { #'PostgreSQL-AST' . #'PostgreSQL-Parser-Core' . #'PostgreSQL-Parser-Errors'
				. #'PostgreSQL-Parser-Others' . #'PostgreSQL-Parser-Tests' }.

		el
			prepare: false ;
			run;
			terminate.
		self saveImage
	]
]

{ #category : #scenarios }
STExperimentLauncher class >> runTestScenarioDataFrame [
	<script>
	| files packages |
	"Need for Roassal3-Examples for changes 17 & 18 of 2nd ombu file."
	Metacello new
		baseline: 'Roassal3';
		repository: 'github://ObjectProfile/Roassal3/src';
		load.
	
	"Experiment"
	files := self ombuFilesInProject: 'DataFrame'.
	packages := (OmbuFilesOrganizer new packagesInFiles: files) asArray.
	packages := packages
		select: [ :pckg | pckg includesSubstring: 'DataFrame' ].
	self
		runScenario: 'DataFrame'
		ombuFiles: (1 to: files size)
		packages: packages
		withFinders: self defaultFinders
]

{ #category : #scenarios }
STExperimentLauncher class >> runTestScenarioDebuggableASTInterpreter [
	<script>
	self runKeepingPackagesScenario: 'DebuggableASTInterpreter'
]

{ #category : #scenarios }
STExperimentLauncher class >> runTestScenarioDebuggableASTInterpreterExpFirstFile [
	<script>
	| el ombFile logFile |
	EpMonitor current disable.
	self resetLastRun.
	ombFile := self ombuFileName: 'DebuggableASTInterpreter' number: 1.
	logFile := self logFileName: 'DebuggableASTInterpreter' number: 1.
	el := self
		onOmbuFiles: {ombFile}
		logFileName: logFile
		withPackages: {'DebuggableASTInterpreter'}
		withFinders: self ungenericFinders.
	el
		prepare: false;
		run;
		terminate.
	SmalltalkImage current snapshot: true andQuit: false.
	EpMonitor current enable
]

{ #category : #scenarios }
STExperimentLauncher class >> runTestScenarioFamix [
	<script>
	self runKeepingPackagesScenario: 'Famix'
]

{ #category : #scenarios }
STExperimentLauncher class >> runTestScenarioFast [
	<script>
	| files packages el ombFile logFile |
	EpMonitor current disable.
	files := self ombuFilesInProject: 'FAST'.
	packages := (OmbuFilesOrganizer new packagesInFiles: files) asArray.
	self resetLastRun.
	1 to: 2 do: [ :i | 
		ombFile := self ombuFileName: 'FAST' number: i.
		logFile := self logFileName: 'FAST' number: i.
		el := self
			onOmbuFiles: {ombFile}
			logFileName: logFile
			withPackages: packages
			withFinders: self ungenericFinders.
		el
			prepare: false;
			run: i = 2;
			terminate: i = 2 ].
	SmalltalkImage current snapshot: true andQuit: false.
	EpMonitor current enable
]

{ #category : #scenarios }
STExperimentLauncher class >> runTestScenarioForwardChainerEx [
	"self runTestScenarioForwardChainerEx"

	| el |
	<script>
	self resetLastRun.
	2 to: 5 do: [ :i || ombFile logFile |
		ombFile := 'ForwardChainerEx/ombu-sessions/ForwardChainer' , i asString , '.ombu'.
		logFile := 'ForwardChainerEx' , i asString , '.log'.
		el := self
			onOmbuFiles: {ombFile}
			logFileName: logFile
			withPackages: {'IABasic'}.
		el
			prepare: (i = 2) "Remove package if loading the first ombu file";
			run ;
			terminate.
		SmalltalkImage current snapshot: true andQuit: false.
	]
]

{ #category : #scenarios }
STExperimentLauncher class >> runTestScenarioMeleeSim [
	<script>
	self runScenario: 'MeleeSim'
]

{ #category : #scenarios }
STExperimentLauncher class >> runTestScenarioMooseQuery [
	"self runTestScenarioMooseQuery"

	self runTestScenarioMooseQuery: (1 to: 3)
]

{ #category : #scenarios }
STExperimentLauncher class >> runTestScenarioMooseQuery: aCollection [
	"self runTestScenarioMooseQuery: #( 1 2 3 )"

	| el |
	self resetLastRun.
	aCollection do: [ :i |
		el := self
			onOmbuFiles: { 'ombu-sessions/MooseQuery' , i asString , '.ombu' }
			logFileName: 'MooseQuery' , i asString , '.log'
			withPackages:
				{#'Moose-Core' . #'Moose-Query' . #'Moose-Query-Test' . #'Moose-Query-Extensions'.
				#'Famix-Core' . #'Famix-Extensions' . #'Famix-Implementation' . #'Fame-Core'.
				#'Moose-SmalltalkImporter' . #'Moose-Tests-Core' . #'Fame-SmalltalkBinding'.
				#'Moose-TestResources-KGB-P4FullInteracted' . #'Moose-TestResources-KGB-P5FullReferee'.
				#'Moose-TestResources-KGB-P7ReferencerReferee'.
				#'Fame-Tests-Core' . #'Moose-Tests-SmalltalkImporter-KGB'}.
		el
			prepare: false;
			run;
			terminate.
		self saveImage
	]
]

{ #category : #scenarios }
STExperimentLauncher class >> runTestScenarioPheme [
	"self runTestScenarioPheme"
	self runTestScenarioPheme: (1 to: 4)
]

{ #category : #scenarios }
STExperimentLauncher class >> runTestScenarioPheme: aCollection [
	"self runTestScenarioPheme: (1 to: 4)"

	| el phemeName |
	
	phemeName := 'Phe' , 'me'.  "So that SmartTest does not see this method as using Pheme package"
	self resetLastRun .

	aCollection do: [ :i |
		el := self
			onOmbuFiles: { 'ombu-sessions/Pheme' , i asString , '.ombu' }
			logFileName: phemeName , i asString , '.log'
			withPackages: { phemeName asSymbol }.
		el
			prepare: (i = 1) ;  "if i=1, erase Pheme package first, otherwise keep it"
			run ;
			terminate.
		"self saveImage ."
	]
]

{ #category : #scenarios }
STExperimentLauncher class >> runTestScenarioPolyMath [
	<script>
	| files packages |
	files := self ombuFilesInProject: 'PolyMath'.
	packages := (OmbuFilesOrganizer new packagesInFiles: files) asArray.
	packages := packages
		select:
			[ :pckg | (pckg includesSubstring: 'Math') or: [ pckg beginsWith: 'PM' ] ].
	self
		runScenario: 'PolyMath'
		ombuFiles: (1 to: files size)
		packages: packages
		withFinders: self defaultFinders
]

{ #category : #scenarios }
STExperimentLauncher class >> runTestScenarioTDD [
	"Bug at change 314. Unknown classes"

	<script>
	self runScenario: 'TDD'
]

{ #category : #scenarios }
STExperimentLauncher class >> runTextScenarioTFIDF [
	<script>
	self runScenario: 'TF-IDF'
]

{ #category : #scenarios }
STExperimentLauncher class >> runTextScenarioTinyBlog [
	"Affected packages are widely used."

	<script>
	self runKeepingPackagesScenario: 'TinyBlog'
]

{ #category : #utilities }
STExperimentLauncher class >> saveImage [
	Smalltalk garbageCollect.
	(Delay forSeconds: 5) wait.  "take a break before saving image to avoid bug that could corrupt it"
	SmalltalkImage current snapshot: true andQuit: false
]

{ #category : #accessing }
STExperimentLauncher class >> saveIntermediately [
	<script>
	self intermediateSave: self lastRun.
	^intermediateSave 
]

{ #category : #visualization }
STExperimentLauncher class >> showResultsAsPieCharts [
	<script>
	self allInstances last visualizePieChartResults
]

{ #category : #utilities }
STExperimentLauncher class >> sortOmbuFilesIn: aDirectoryName [
	"Some projects store a whole suite of epicea sessions and a series of onbu files. Epicea relies on the time stamps on these files to sort them but these are not reliable when they are reconstructed from git, previous epicea sessions etc. That is why we go over all epicea files in a directory and take the first entry -- these contain reliable time stamps"

	"self sortOmbuFilesIn: 'MooseQuery'"

	"self sortOmbuFilesIn: 'Pillar'"

	| dirNamed dir changeList outputLog |
	Transcript clear.
	dirNamed := FileSystem disk workingDirectory path / aDirectoryName.
	changeList := OrderedCollection new: 200.
	dir := dirNamed asFileReference.
	dir files
		do: [ :aFile | 
			Transcript
				cr;
				show: aFile fullName.
			changeList addAll: (self ombuEntriesFromFile: aFile asFileReference) ].
	changeList := changeList sort: [ :omEntry1 :omEntry2 | (omEntry1 tagAt: #time) < (omEntry2 tagAt: #time) ].
	Transcript
		cr;
		show: 'sorted'.
	outputLog := EpLog newWithStore: (OmStoreFactory current named: aDirectoryName , ' _SORTED' inDirectory: FileSystem disk workingDirectory).
	^ EpOmbuExporter new
		outputLog: outputLog;
		fileOut: changeList
]

{ #category : #utilities }
STExperimentLauncher class >> sortPillarFiles [
	"The ombu files created during the refactoring session were generated from git and the timestamps on the files were botched. This is an attempt to recreate the sort order baed on the internal timestamps"

	"self sortPillarFiles"

	<script>
	| org |
	"	org := {{'PillarXX01.ombu' . '2017-11-07T11:15:50.450278+01:00'}.
	{'PillarXX02.ombu' . '2017-11-06T15:30:59.779584+01:00'}.
	{'PillarXX03.ombu' . '2017-11-07T11:18:51.346267+01:00'}.
	{'PillarXX04.ombu' . '2017-11-07T11:17:37.015213+01:00'}.
	{'PillarXX05.ombu' . '2017-11-07T14:03:03.372589+01:00'}.
	{'PillarXX06.ombu' . '2017-11-07T13:58:23.793493+01:00'}.
	{'PillarXX07.ombu' . '2017-11-07T11:22:24.209009+01:00'}.
	{'PillarXX08.ombu' . '2017-11-06T15:34:35.240547+01:00'}.
	{'PillarXX09.ombu' . '2017-11-06T17:17:22.581029+01:00'}.
	{'PillarXX10.ombu' . '2017-11-06T16:39:18.892635+01:00'}.
	{'PillarXX11.ombu' . '2017-11-07T11:32:49.440137+01:00'}.
	{'PillarXX12.ombu' . '2017-11-06T10:52:20.788082+01:00'}.
	{'PillarXX13.ombu' . '2017-11-06T16:58:29.886854+01:00'}.
	{'PillarXX14.ombu' . '2017-11-06T15:44:02.843297+01:00'}.
	{'PillarXX15.ombu' . '2017-11-07T11:50:33.850412+01:00'}.
	{'PillarXX16.ombu' . '2017-11-06T11:11:08.279216+01:00'}.
	{'PillarXX17.ombu' . '2017-11-06T15:09:53.611686+01:00'}.
	{'PillarXX18.ombu' . '2017-11-06T15:09:53.611686+01:00'}.
	{'PillarXX19.ombu' . '2017-11-07T09:47:06.331089+01:00'}.
	{'PillarXX20.ombu' . '2017-11-07T11:10:40.559416+01:00'}.
	{'PillarXX21.ombu' . '2017-11-06T16:36:09.377977+01:00'}.
	{'PillarXX22.ombu' . '2017-11-06T11:16:42.015388+01:00'}.
	{'PillarXX23.ombu' . '2017-11-06T11:19:11.986566+01:00'}.
	{'PillarXX24.ombu' . '2017-11-06T17:01:24.143892+01:00'}.
	{'PillarXX25.ombu' . '2017-11-07T22:55:58.474604+01:00'}.
	{'PillarXX26.ombu' . '2017-11-07T11:48:41.519522+01:00'}.
	{'PillarXX27.ombu' . '2017-11-07T12:09:47.959427+01:00'}.
	{'PillarXX28.ombu' . '2017-11-06T13:49:46.365946+01:00'}.
	{'PillarXX29.ombu' . '2017-11-06T17:52:27.413435+01:00'}.
	{'PillarXX30.ombu' . '2017-11-06T18:13:19.597156+01:00'}}."
	org := {{'Pillar_01.ombu' . '2017-11-06T10:52:20.788082+01:00'}.
	{'Pillar_02.ombu' . '2017-11-06T11:11:08.279216+01:00'}.
	{'Pillar_03.ombu' . '2017-11-06T11:16:42.015388+01:00'}.
	{'Pillar_04.ombu' . '2017-11-06T11:19:11.986566+01:00'}.
	{'Pillar_05.ombu' . '2017-11-06T13:49:46.365946+01:00'}.
	{'Pillar_06.ombu' . '2017-11-06T10:51:25.642111+01:00'}.
	{'Pillar_07.ombu' . '2017-11-06T15:09:53.611686+01:00'}.
	{'Pillar_08.ombu' . '2017-11-06T15:30:59.779584+01:00'}.
	{'Pillar_09.ombu' . '2017-11-06T15:34:35.240547+01:00'}.
	{'Pillar_10.ombu' . '2017-11-06T15:44:02.843297+01:00'}.
	{'Pillar_11.ombu' . '2017-11-06T16:36:09.377977+01:00'}.
	{'Pillar_12.ombu' . '2017-11-06T16:39:18.892635+01:00'}.
	{'Pillar_13.ombu' . '2017-11-06T16:58:29.886854+01:00'}.
	{'Pillar_14.ombu' . '2017-11-06T17:01:24.143892+01:00'}.
	{'Pillar_15.ombu' . '2017-11-06T17:17:22.581029+01:00'}.
	{'Pillar_16.ombu' . '2017-11-06T17:52:27.413435+01:00'}.
	{'Pillar_17.ombu' . '2017-11-06T18:13:19.597156+01:00'}.
	{'Pillar_18.ombu' . '2017-11-07T09:47:06.331089+01:00'}.
	{'Pillar_19.ombu' . '2017-11-07T11:10:40.559416+01:00'}.
	{'Pillar_20.ombu' . '2017-11-07T11:15:50.450278+01:00'}.
	{'Pillar_21.ombu' . '2017-11-07T11:17:37.015213+01:00'}.
	{'Pillar_22.ombu' . '2017-11-07T11:18:51.346267+01:00'}.
	{'Pillar_23.ombu' . '2017-11-07T11:22:24.209009+01:00'}.
	{'Pillar_24.ombu' . '2017-11-07T11:32:49.440137+01:00'}.
	{'Pillar_25.ombu' . '2017-11-07T11:48:41.519522+01:00'}.
	{'Pillar_26.ombu' . '2017-11-07T11:50:33.850412+01:00'}.
	{'Pillar_27.ombu' . '2017-11-07T12:09:47.959427+01:00'}.
	{'Pillar_28.ombu' . '2017-11-07T13:58:23.793493+01:00'}.
	{'Pillar_29.ombu' . '2017-11-07T14:03:03.372589+01:00'}.
	{'Pillar_30.ombu' . '2017-11-07T22:55:58.474604+01:00'}}.
	org := org collect: [ :twoElements | Array with: (twoElements at: 1) with: (DateAndTime fromString: (twoElements at: 2)) ].
	org := org sort: [ :m1 :m2 | (m1 at: 2) < (m2 at: 2) ].
	^ org collect: [ :twoElements | twoElements at: 1 ]
]

{ #category : #'oracle creation' }
STExperimentLauncher >> addToOracle: aTest [
	oracle
		add:
			(aTest class lookupSelector: aTest selector) methodReference fullName
]

{ #category : #'oracle creation' }
STExperimentLauncher >> addToOracleIfAffected: aTest [
	| proxy |
	proxy := self proxyOnCurrentMethod.
	self runTest: aTest withProxyOnCurrentMethod: proxy.
	proxy hasRun
		ifTrue: [ self addToOracle: aTest ]
]

{ #category : #accessing }
STExperimentLauncher >> allTests [
	| allTests |
	allTests := IdentitySet new.
	collectionOfTestSuites
		do: [ :aTestSuite | 
			aTestSuite flatCollectTests
				do:
					[ :aTest | allTests add: (aTest class name , '>>' , aTest selector) asSymbol ] ].
	^ allTests
]

{ #category : #accessing }
STExperimentLauncher >> cacheSizeOf: smartFinder [
	| cacheSize |
	cacheSize := smartFinder currentCache sizeInMemory.
	smartFinder currentCache
		keysAndValuesDo:
			[ :key :value | cacheSize := cacheSize + key sizeInMemory + value sizeInMemory ].
	cacheSize := (cacheSize + 511) // 1024.	"Convert to kilo-bytes rounded up"
	^ cacheSize
]

{ #category : #private }
STExperimentLauncher >> calculateDiffBetween: oldString and: newString [
	| diff diffLineCount |
	diffLineCount := 0.
	diff := TextDiffBuilder from: oldString to: newString.
	diff
		patchSequenceDoIfMatch: [ :string |  ]
		ifInsert: [ :string | 
			diffLineCount := diffLineCount + string lineCount ]
		ifRemove: [ :string | 
			diffLineCount := diffLineCount + string lineCount ].
	^ diffLineCount
]

{ #category : #accessing }
STExperimentLauncher >> changeList [
	^ changeList
]

{ #category : #accessing }
STExperimentLauncher >> changeList: aCollectionOfEpCodeChange [
	aCollectionOfEpCodeChange assert: aCollectionOfEpCodeChange isSequenceable description: 'Expected a collection for #changeList:'.
	changeList := aCollectionOfEpCodeChange
]

{ #category : #private }
STExperimentLauncher >> changeShouldBeApplied [
	"Exclude protocol removal"
	^ currentChange class ~= EpProtocolRemoval
	"Exclude Monticello"
		and: [ currentChange isMonticelloVersionsLoad not
		and: [ currentChange isMonticelloVersionSave not
	"Exclude method modification introducing an halt."
		and: [ currentChange isIntroducingAHalt not ] ] ]
]

{ #category : #'oracle creation' }
STExperimentLauncher >> createOracle [
	collectionOfTestSuites
		do: [ :aTestSuite | 
			aTestSuite flatCollectTests
				do: [ :aTest | self addToOracleIfAffected: aTest ] ]
]

{ #category : #private }
STExperimentLauncher >> currentChangeIsTestCaseChange [
	| class |
	class := currentChange isEpBehaviorChange
		ifTrue: [ currentChange behaviorAffected realClass ]
		ifFalse: [ currentChange isEpMethodChange
				ifTrue: [ currentChange methodAffected realClass ] ].
	^ class isNotNil and: [ class isTestCase ]
]

{ #category : #accessing }
STExperimentLauncher >> currentChangeType [
	"'EpMethodAddition' --> 'MethodAddition'"

	^ currentChange class name allButFirst: 2
]

{ #category : #accessing }
STExperimentLauncher >> currentMethodAffectedName [
	^ currentChange methodAffected fullName
]

{ #category : #running }
STExperimentLauncher >> decideAnalysis [
	(self smartTestInterventionNeeded: currentEntry)
		ifTrue: [ self runSmartTestAnalysis ]
		ifFalse: [ self noSmartTestAnalysis ]
]

{ #category : #exporting }
STExperimentLauncher >> exportToCSVStream: stream withHeader: aBoolean [
	measurements exportToCSVStream: stream withHeader: aBoolean
]

{ #category : #initialization }
STExperimentLauncher >> initialize [
	super initialize.
	changeList := {}.
	oracle := IdentitySet new.
	measurements := STEMeasurements new: smTFinders keys
]

{ #category : #accessing }
STExperimentLauncher >> keys [
	^ smTFinders keys
]

{ #category : #'no analysis' }
STExperimentLauncher >> loadAndIncrement: bar [
	changeList
		do: [ :anOmEntry | 
			currentEntry := anOmEntry.
			currentChange := currentEntry content.
			self changeShouldBeApplied
				ifTrue: [ self processChange ].
			bar increment ]
]

{ #category : #running }
STExperimentLauncher >> logEndOfExperiment [
	2 timesRepeat: [ logger separationLine ].
	smTFinders
		keysDo: [ :symbol | 
			logger
				logFinalResults: (measurements totalResultsForFinder: symbol)
				ofFinder: symbol ].
	logger separationLine.
	#(false true)
		do: [ :inTests | 
			logger
				logTotalChanges: (measurements totalChangesInTests: inTests)
				affectedLines: (measurements totalAffectedLinesInTests: inTests)
				inTests: inTests ]
]

{ #category : #logging }
STExperimentLauncher >> logTimeSavings [
	smTResults
		keysAndValuesDo: [ :key :tests | 
			| testSuite timeToRun |
			testSuite := self createTestSuite: tests.
			Smalltalk garbageCollect.
			timeToRun := [ testSuite run ] timeToRun.
			logger logTime: timeToRun forFinder: key.
			self measurements at: #testTime , key capitalized put: timeToRun ]
]

{ #category : #analysis }
STExperimentLauncher >> manageAnalysis [
	self performAnalysis.
	self measurePrecision
]

{ #category : #analysis }
STExperimentLauncher >> manageBuildCache [
	| ts |
	logger logCacheUpdate.
	self createTestcases.
	logger blankLine.
	ts := TestSuite new.
	ts addTests: collectionOfTestSuites.
	smTFinders
		keysAndValuesDo: [ :key :finder | 
			| previousCache |
			previousCache := finder currentCache copy.
			finder emptyCache.
			self recordCacheReset: finder currentCache = previousCache for: key.
			finder currentCache ifEmpty: [ finder buildCacheFromTestSuite: ts ].
			self recordCacheSizeOf: key ]
]

{ #category : #'oracle creation' }
STExperimentLauncher >> manageBuildOracle [
	logger logStartOfOracleCreation.
	self createTestcases.	"Because applying change may have added/removed/changed a test"
	self createOracle.
	logger logCreatedOracle: oracle
]

{ #category : #analysis }
STExperimentLauncher >> manageChange [
	self processChange.
	self measureCodeChurn.
]

{ #category : #private }
STExperimentLauncher >> measureCodeChurn [
	"This method is called only if the current change is analyzed - so is an EpMethodChange. See #smartTestInterventionNeeded:"

	self
		assert: currentChange isEpMethodChange
		description: 'Code churn is measured only for an EpMethodModification'.
	measurements affectedLines: currentChange numberOfAffectedLines
]

{ #category : #logging }
STExperimentLauncher >> measurePrecision [
	smTResults
		keysAndValuesDo: [ :key :results | 
			| smartTestSelection |
			smartTestSelection := IdentitySet new
				addAll: (results intersection: self allTests);
				yourself.
			self
				flag:
					'Why this intersection ? Previous implementation said "temporary hack".'.
			self recordResults: smartTestSelection for: key ]
]

{ #category : #accessing }
STExperimentLauncher >> measurements [
	^ measurements 
]

{ #category : #running }
STExperimentLauncher >> noSmartTestAnalysis [
	logger logNoSmarttestAnalysis.
	self changeShouldBeApplied
		ifTrue: [ self processChange ]
]

{ #category : #'no analysis' }
STExperimentLauncher >> onlyApplyChanges [
	| barLabel |
	barLabel := 'SmartTest Experiment: Loading project'.
	UIManager default
		displayProgress: barLabel
		from: 1
		to: changeList size
		during: [ :bar | self loadAndIncrement: bar ]
]

{ #category : #accessing }
STExperimentLauncher >> packages [
	^ packages
]

{ #category : #accessing }
STExperimentLauncher >> packages: aCollectionOfCategoryNames [
	aCollectionOfCategoryNames
		assert: aCollectionOfCategoryNames isSequenceable
		description: 'Expected a collection for #packages:'.
	packages := aCollectionOfCategoryNames
]

{ #category : #analysis }
STExperimentLauncher >> performAnalysis [
	super performAnalysis.
	logger logAnalysis: smTResults
]

{ #category : #analysis }
STExperimentLauncher >> performAnalysis: aSymbol [
	smTResults
		at: aSymbol
		put: (super performAnalysis: aSymbol) asIdentitySet
]

{ #category : #'actions-public' }
STExperimentLauncher >> prepare [
	self prepare: true
]

{ #category : #'actions-public' }
STExperimentLauncher >> prepare: removePackagesFirst [
	removePackagesFirst
		ifTrue: [ self packages
				do: [ :pckgName | 
					[ "if the package already exists, remove it" (RPackage organizer packageNamed: pckgName) removeFromSystem ]
						on: KeyNotFound
						do: [ "was not found so it is alright" ] ] ].
]

{ #category : #'oracle creation' }
STExperimentLauncher >> proxyOnCurrentMethod [
	| currentMethod |
	currentMethod := currentChange methodAffected compiledMethod
		methodReference.
	^ HDTestCoverage new initializeOn: currentMethod
]

{ #category : #analysis }
STExperimentLauncher >> recordCacheReset: reset for: key [
	reset
		ifFalse: [ logger logCacheResetForFinder: key.
			measurements at: key at: #cacheReset put: true ]
		ifTrue: [ measurements at: key at: #cacheReset put: false ]
]

{ #category : #analysis }
STExperimentLauncher >> recordCacheSizeOf: aSymbol [
	| cacheSize |
	cacheSize := self cacheSizeOf: (smTFinders at: aSymbol).
	logger logCacheSize: cacheSize for: aSymbol.
	^ self measurements at: aSymbol at: #cacheSize put: cacheSize
]

{ #category : #logging }
STExperimentLauncher >> recordResults: smartTestSelection for: key [
	| results |
	logger logPrecision: key.
	results := Dictionary new.
	results
		at: #truePositives put: (smartTestSelection intersection: oracle);
		at: #falsePositives put: (smartTestSelection difference: oracle);
		at: #falseNegatives put: (oracle difference: smartTestSelection);
		at: #trueNegatives
			put:
			((self allTests difference: smartTestSelection) difference: oracle).
	results
		keysAndValuesDo: [ :precision :tests | 
			logger logTests: tests asResult: precision.
			measurements at: key at: precision put: tests size ]
]

{ #category : #running }
STExperimentLauncher >> resetResults [
	smTResults keysDo: [ :key | smTResults at: key put: IdentitySet new ].
	oracle := IdentitySet new
]

{ #category : #running }
STExperimentLauncher >> resolveAnalysisOrder [
	self changeMustBePerformedAfterAnalysis
		ifTrue: [ self runAnalysisThenChange ]
		ifFalse: [ self runChangeThenAnalysis ]
]

{ #category : #running }
STExperimentLauncher >> run [
	| barLabel |
	logger openlog.
	logger logCSVHeader: measurements columnNames.
	barLabel := 'SmartTest Experiment ('
		, logger logFileReference basename , ')'.
	UIManager default
		displayProgress: barLabel
		from: 1
		to: changeList size
		during: [ :bar | self runAndIncrement: bar label: barLabel ].
	self logEndOfExperiment
]

{ #category : #'actions-public' }
STExperimentLauncher >> run: aBoolean [
	aBoolean
		ifTrue: [ self run ]
		ifFalse: [ self onlyApplyChanges ]
]

{ #category : #analysis }
STExperimentLauncher >> runAnalysisThenChange [
	self manageBuildCache.
	self manageBuildOracle.
	self manageAnalysis.
	self manageChange
]

{ #category : #running }
STExperimentLauncher >> runAndIncrement: bar label: barLabel [
	changeList
		do: [ :anOmEntry | 
			self resetResults.
			currentEntry := anOmEntry.
			currentChange := currentEntry content.
			logger
				logStartOfCodeChange: currentChange
				number: self changeNumber.
			self updateBar: bar label: barLabel.
			self decideAnalysis.
			bar increment ]
]

{ #category : #analysis }
STExperimentLauncher >> runChangeThenAnalysis [
	self manageBuildCache.
	self manageChange.
	self manageBuildOracle.
	self manageAnalysis
]

{ #category : #running }
STExperimentLauncher >> runSmartTestAnalysis [
	measurements newResult
		id: self changeNumber
		change: self currentMethodAffectedName
		changeType: self currentChangeType
		inTest: self currentChangeIsTestCaseChange.
	self resolveAnalysisOrder.
	logger logCSVRow: measurements lastResult flattenedValues
]

{ #category : #'oracle creation' }
STExperimentLauncher >> runTest: aTest withProxyOnCurrentMethod: proxyOnCurrentMethod [
	| singleTestCaseSuite |
	"Create test case"
	singleTestCaseSuite := TestSuite
		named: 'Single Test Case for ' , aTest selector.
	singleTestCaseSuite addTest: aTest.

	"Run test while proxy is installed"
	[ proxyOnCurrentMethod install.
	[ singleTestCaseSuite run ]
		ensure: [ proxyOnCurrentMethod uninstall ] ] valueUnpreemptively
]

{ #category : #'actions-public' }
STExperimentLauncher >> terminate [
	logger closelog.
	visualizer := STEVisualizer new.
	visualizer
		results: measurements results;
		analysesSymbols: smTFinders keys.
	self visualizeResults
]

{ #category : #'actions-public' }
STExperimentLauncher >> terminate: aBoolean [
	aBoolean
		ifTrue: [ self terminate ]
]

{ #category : #running }
STExperimentLauncher >> updateBar: bar label: barLabel [
	bar label: barLabel , ' change:' , self changeNumber asString
]

{ #category : #visualization }
STExperimentLauncher >> visualizeCacheSize [
	visualizer visualiseCacheSizeOfAnalyses: smTFinders keys
]

{ #category : #visualization }
STExperimentLauncher >> visualizeComparison [
	visualizer compareAllPrecisionsOfAnalyses: smTFinders keys definition: 'Comparison between analyses'
]

{ #category : #visualization }
STExperimentLauncher >> visualizeFalseNegatives [
	visualizer
		comparePrecision: #falseNegatives
		ofAnalyses: smTFinders keys
]

{ #category : #visualization }
STExperimentLauncher >> visualizeFalsePositives [
	visualizer
		comparePrecision: #falsePositives
		ofAnalyses: smTFinders keys
]

{ #category : #visualization }
STExperimentLauncher >> visualizeFalseResults [
	visualizer
		comparePrecisions: #(#falsePositives #falseNegatives)
		ofAnalyses: smTFinders keys
		definition: 'Comparison of false results between analyses'
]

{ #category : #visualization }
STExperimentLauncher >> visualizePieChartResults [
	visualizer pieChartsOfAnalyses: smTFinders keys
]

{ #category : #visualization }
STExperimentLauncher >> visualizeResults [
	smTFinders
		keysAndValuesDo: [ :key :finder | 
			visualizer
				resultsOfAnalysis: key
				withTrueNegatives: true
				showCacheReset: finder hasAdaptiveCache ]
]

{ #category : #visualization }
STExperimentLauncher >> visualizeTrueNegatives [
	visualizer
		comparePrecision: #trueNegatives
		ofAnalyses: smTFinders keys
]

{ #category : #visualization }
STExperimentLauncher >> visualizeTruePositives [
	visualizer
		comparePrecision: #truePositives
		ofAnalyses: smTFinders keys
]

{ #category : #accessing }
STExperimentLauncher >> visualizer [
	^ visualizer 
]
