"
See comment for TimeAndMemoryExperiment for an overview of the whole process.

TimeAndMemoryMaster, selects randomly a change in the list of all possible changes (given by the ombufiles of all the 'datasets'), then launches a child image for the given dataset of the chosen change which runs TimeAndMemoryPreparer to finish preparing this image for the experiment, then launches repeatedly this image running TimeAndMemorySlave
"
Class {
	#name : #TimeAndMemoryMaster,
	#superclass : #TimeAndMemoryExperiment,
	#instVars : [
		'datasetSizes',
		'posInDataset',
		'dataSets'
	],
	#classInstVars : [
		'runningExperiment'
	],
	#category : #'SmartTestExperiment-timeAndMem'
}

{ #category : #finders }
TimeAndMemoryMaster class >> defaultFindersSourceCode [
	^ '	| smTFinders |
		"Ordered dictionary to be sure that headers and results are always in the same order."
	smTFinders := OrderedDictionary new.
	smTFinders
		at: #static
			put:
			(SmartFinder new
				filter: SmTDefaultClassPackagesFilter new;
				cacheStrategy: SmTNoCacheStrategy new;
				smtFinder: SmTSenderTestFinderStrategy new);
		at: #dynamic
			put:
			(SmartFinder new
				filter: SmTDefaultClassPackagesFilter new;
				cacheStrategy: SmTBasicCacheStrategy new;
				smtFinder: SmTTestCoverageTestFinderStrategy new).
	^ smTFinders'
]

{ #category : #'instance creation' }
TimeAndMemoryMaster class >> new [
	CodeExporter
		writeSourceCodeFrom: self defaultFindersSourceCode
		baseName: 'SmTFinders'
		isSt: true.
	^ super new
]

{ #category : #'instance creation' }
TimeAndMemoryMaster class >> new: aSmTFindersDictionarySourceString [
	CodeExporter
		writeSourceCodeFrom: aSmTFindersDictionarySourceString
		toFileReference:
			'/home/clotilde/Documents/Stage/TimeAndMem/LANSimulationData/SmartFinders.st' asFileReference.
	^ super
		new: (CodeImporter evaluateString: aSmTFindersDictionarySourceString)
]

{ #category : #running }
TimeAndMemoryMaster class >> runExperiment [
	"Main entry point for master image
	 run:

		TimeAndMemoryMaster runExperiment.
	"

	<script>
	self runExperiment: true
]

{ #category : #running }
TimeAndMemoryMaster class >> runExperiment: resetCSV [
	"Main entry point for master image.
	 run:
		TimeAndMemoryExperiment runExperiment: false.
	"

	runningExperiment := self new: self ungenericFindersSourceCode.
	"runningExperiment addDataSet: ApplicationDataSet ForwardChainer."
	runningExperiment addDataSet: ApplicationDataSet LANSimulation.
	"	runningExperiment addDataSet: ApplicationDataSet MooseQuery.
	runningExperiment addDataSet: ApplicationDataSet Pheme.
	runningExperiment addDataSet: ApplicationDataSet Pillar.
	runningExperiment addDataSet: ApplicationDataSet PostgreSQL."
	runningExperiment eraseCSV: resetCSV.
	runningExperiment run
]

{ #category : #finders }
TimeAndMemoryMaster class >> ungenericFindersSourceCode [
	^ '| smTFinders |
	"Ordered dictionary to be sure that headers and results are always in the same order."
	smTFinders := OrderedDictionary new.
	smTFinders
		at: #fiveChangesCache
			put:
			(SmartFinder new
				filter: SmTDefaultClassPackagesFilter new;
				cacheStrategy: SmTBasicCacheResetEvery5ChangesStrategy new;
				smtFinder: SmTTestCoverageTestFinderStrategy new);
		at: #static
			put:
			(SmartFinder new
				filter: SmTDefaultClassPackagesFilter new;
				cacheStrategy: SmTNoCacheStrategy new;
				smtFinder: SmTSenderTestFinderStrategy new);
		at: #dynamic
			put:
			(SmartFinder new
				filter: SmTDefaultClassPackagesFilter new;
				cacheStrategy: SmTBasicCacheStrategy new;
				smtFinder: SmTTestCoverageTestFinderStrategy new).
	^ smTFinders'
]

{ #category : #accessing }
TimeAndMemoryMaster >> addDataSet: aDataSet [
	dataSets add: aDataSet.
	datasetSizes add: (aDataSet name -> aDataSet entriesCount)
]

{ #category : #'child image' }
TimeAndMemoryMaster >> createChildImageForExperiment: changePos [
	"launches a child image from the currentDataset base image and prepare for experiment"

	ImageRunner platformRunner
		runImage: dataSet imageReference
		withParameters:
			{#doPrepare.
			dataSet name.
			changePos asString}.
	self waitForSignal: self prepareSignal
]

{ #category : #accessing }
TimeAndMemoryMaster >> datasetFromName: dsName [
	^ dataSets detect: [ :ds | ds name = dsName ]
]

{ #category : #accessing }
TimeAndMemoryMaster >> findDatasetAndPos: globalPos [
	| dsPos |
	dsPos := globalPos.
	datasetSizes do: [ :assoc |"assoc <==>  dataset-name -> dataset-size"
		(assoc value >= dsPos)
			ifTrue: [^ (assoc key) -> dsPos ]
			ifFalse: [ dsPos := dsPos - assoc value ]
	]
]

{ #category : #running }
TimeAndMemoryMaster >> getRandomActionnableChange: totalEntries [
	| datasetWithPos |

	[
		datasetWithPos := self findDatasetAndPos: totalEntries atRandom.
		dataSet := self datasetFromName: datasetWithPos key.
		self
			smartTestInterventionNeeded: (dataSet changeAtPos: datasetWithPos value)
	]
		whileFalse.
	^ datasetWithPos value
]

{ #category : #initialization }
TimeAndMemoryMaster >> initialize [
	super initialize.
	dataSets := OrderedCollection new.
	datasetSizes := OrderedCollection new.
]

{ #category : #running }
TimeAndMemoryMaster >> prepareAndRunExperimentForChange: changePos [
	self createChildImageForExperiment: changePos.

	"run 10 times to compute average values"
	1 to: 10 do: [ :i |
		self runChildImageForExperiment: i.
	]
]

{ #category : #running }
TimeAndMemoryMaster >> run [
	"called by
		TimeAndMemoryMaster class>>runExperiment"

	| totalEntries |
	totalEntries := self totalEntriesInDatasets.
	5 timesRepeat: [
		self prepareAndRunExperimentForChange: (self getRandomActionnableChange: totalEntries)
	]
]

{ #category : #'child image' }
TimeAndMemoryMaster >> runChildImageForExperiment: expNumber [
	ImageRunner platformRunner
		runImage: self runningImageName asFileReference
		withParameters: {#doRun . expNumber asString}.

	self waitForSignal: (self runningExpSignal: expNumber).
]

{ #category : #accessing }
TimeAndMemoryMaster >> totalEntriesInDatasets [
	^ (datasetSizes collect: #value) sum
]
