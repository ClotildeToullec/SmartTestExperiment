"
Abstract class to run smartTest experiments. It factorises the code to find and run the tests for a given change

It contains:
- the change to test
- instance variables to hold the tests to run
- instance variables to perform static/dynamic analyses
- logger and instance variables to store the results

"
Class {
	#name : #AbstractSmartTestExperiment,
	#superclass : #Object,
	#instVars : [
		'currentChange',
		'collectionOfTestSuites',
		'logger',
		'dataSet',
		'smTResults',
		'smTFinders',
		'packages',
		'oracleFinder'
	],
	#category : #'SmartTestExperiment-analysis'
}

{ #category : #finders }
AbstractSmartTestExperiment class >> defaultFinders [
	| smTFinders |
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
	^ smTFinders
]

{ #category : #utilities }
AbstractSmartTestExperiment class >> methodRefAsTestCase: aMethodReference [
	"self methodRefAsTestCase: #'TestNetwork>>testHTMLPrint'"

	"self methodRefAsTestCase: #'TestNetwork class>>testHTMLPrint'"

	"self methodRefAsTestCase: #'Unexisting>>testHTMLPrint'"

	| splitted testClass testSelector |
	splitted := aMethodReference splitOn: '>>'.
	splitted size ~= 2
		ifTrue: [ ^ nil ].
	testClass := Smalltalk classNamed: (splitted at: 1) asSymbol.
	testClass isNil
		ifTrue: [ ^ nil ].
	testClass isTestCase
		ifFalse: [ ^ nil ].
	testSelector := (splitted at: 2) asSymbol.
	^ testClass selector: testSelector
]

{ #category : #'instance creation' }
AbstractSmartTestExperiment class >> new [
	^ self basicNew
		smTFinders: self defaultFinders;
		smTResults:
			(Dictionary new
				at: #static put: self resultsFormat;
				at: #dynamic put: self resultsFormat);
		initialize;
		yourself
]

{ #category : #'instance creation' }
AbstractSmartTestExperiment class >> new: aSmartFindersDictionary [
	"aSmartFindersDictionary should have symbols for keys and SmartFinders for values"

	aSmartFindersDictionary ifEmpty: [ ^ self new ].
	^ self basicNew
		smTFinders: aSmartFindersDictionary;
		smTResults:
			(OrderedDictionary
				newFromKeys: aSmartFindersDictionary keys
				andValues:
					(Array
						new: aSmartFindersDictionary size
						withAll: self resultsFormat));
		initialize;
		yourself
]

{ #category : #running }
AbstractSmartTestExperiment class >> ombuEntriesFromFile: ombFile [
	^ (EpLog freshFromFile: ombFile) entries
]

{ #category : #'instance creation' }
AbstractSmartTestExperiment class >> resultsFormat [
	self subclassResponsibility
]

{ #category : #finders }
AbstractSmartTestExperiment class >> ungenericFinders [
	| smTFinders |
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
	^ smTFinders
]

{ #category : #private }
AbstractSmartTestExperiment >> changeMustBePerformedAfterAnalysis [
	^ currentChange content class = EpMethodRemoval
]

{ #category : #accessing }
AbstractSmartTestExperiment >> changeNumber [
	^ (currentChange tagAt: #self) localName
]

{ #category : #private }
AbstractSmartTestExperiment >> createTestSuite: aCollectionOfMethodReferences [
	| reducedTestSuite aCollectionOfTestCases |
	reducedTestSuite := TestSuite named: 'Test Suite from Method names'.
	aCollectionOfTestCases := aCollectionOfMethodReferences
		collect: [ :aMethodReference | self class methodRefAsTestCase: aMethodReference ].
	aCollectionOfTestCases := aCollectionOfTestCases select: [ :tc | tc notNil ].
	^ reducedTestSuite addTests: aCollectionOfTestCases
]

{ #category : #'actions-public' }
AbstractSmartTestExperiment >> createTestcases [
	| testCaseClasses |
	testCaseClasses := self packages flatCollect: [ :each | 
		(each asPackageIfAbsent: [ nil ])
			ifNotNil: [ :package | package classes select: #isTestCase ]
			ifNil: [ #() ]
	].
	collectionOfTestSuites := testCaseClasses collect: #buildSuite.

	logger logCreatedTestcases: testCaseClasses
]

{ #category : #accessing }
AbstractSmartTestExperiment >> currentChange [
	^ currentChange
]

{ #category : #initialization }
AbstractSmartTestExperiment >> initialize [
	super initialize.
	currentChange := nil.
	logger := ExperimentLauncherLogger new.
	"oracleFinder is a test finder (dynamic strategy) used to build the oracle.
	It has been created to replace the use of the dynamic SmartFinder's finder in ExperimentLauncher>>addToOracle:"
	oracleFinder := SmTTestCoverageTestFinderStrategy new
]

{ #category : #private }
AbstractSmartTestExperiment >> isSystemWideMethod: epChange [
	| chgClass |
	(#(#new #initialize) includes: epChange methodAffected selector)
		ifTrue: [ ^ true ].

	"not a Collection method either ..."
	chgClass := epChange methodAffected methodClass.
	chgClass ifNil: [ ^ false ].	"sometimes the change creates a method for an unexisting class ..."
	chgClass isTrait
		ifTrue: [ ^ false ].	"not Traits in collections and would polluate following code"
	epChange methodAffected isMetaSide
		ifTrue: [ chgClass := chgClass instanceSide ].
	^ chgClass inheritsFrom: Collection
]

{ #category : #accessing }
AbstractSmartTestExperiment >> logFileReference: logfileRef [
	logger logFileReference: logfileRef
]

{ #category : #analysis }
AbstractSmartTestExperiment >> manageBuildCache [
	| ts |
	self createTestcases.
	ts := TestSuite new.
	ts addTests: collectionOfTestSuites.
	smTFinders
		valuesDo: [ :finder | 
			finder resetCache.
			finder buildCacheFromTestSuite: ts ].
	oracleFinder
		cache: (SmTBasicCacheStrategy new cache: Dictionary new);
		buildCacheFromTestSuite: ts
]

{ #category : #private }
AbstractSmartTestExperiment >> ombuEntriesFromFile: ombFile [
	"conveniance method to call the class side one"
	^ self class ombuEntriesFromFile: ombFile
]

{ #category : #accessing }
AbstractSmartTestExperiment >> packages [
	^ dataSet packages
]

{ #category : #analysis }
AbstractSmartTestExperiment >> performAnalysis [
	smTFinders keysDo: [ :key | self performAnalysis: key ]
]

{ #category : #analysis }
AbstractSmartTestExperiment >> performAnalysis: aSymbol [
	^ ((smTFinders at: aSymbol)
		researchTestsForMethod: currentChange content methodAffected compiledMethod)
		collect: [ :method | method fullName ]
]

{ #category : #private }
AbstractSmartTestExperiment >> processChange [
	currentChange content isCodeChange
		ifTrue: [
			logger logAppliedCodeChange: currentChange content.
			currentChange content applyCodeChange ]
		ifFalse: [ logger logIgnoreCodeChange ].


]

{ #category : #private }
AbstractSmartTestExperiment >> runSuites [
	collectionOfTestSuites do: [ :each | each run ]
]

{ #category : #accessing }
AbstractSmartTestExperiment >> smTFinders: anObject [
	smTFinders := anObject
]

{ #category : #accessing }
AbstractSmartTestExperiment >> smTResults: anObject [
	smTResults := anObject
]

{ #category : #private }
AbstractSmartTestExperiment >> smarttestInterventionNeeded: aChange [
	"Answer whether currentChange corresponds to a change which requires a Smarttest intervention
	 and this is when:
	 - the change is on a method
	 - but it does not _introduce_ (so not a methodRemoval) a self halt
	 - the change is not on a widely spread Pharo method (ex: #initialize) because it would end up looking for all methods in the image
		"
	| epChange |
	epChange := aChange content.
	(epChange isEpMethodChange)
		ifFalse: [ ^ false ].

	(epChange class = EpMethodRemoval)
		ifTrue: [  ^ (self isSystemWideMethod: epChange) not ].

	(epChange newSourceCode includesSubstring: 'self halt')
		ifTrue: [ ^ false ].

	^ (self isSystemWideMethod: epChange) not
]
