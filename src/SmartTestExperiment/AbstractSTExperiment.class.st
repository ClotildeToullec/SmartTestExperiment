"
Abstract class to run smartTest experiments. It factorises the code to find and run the tests for a given change

It contains:
- the change to test
- instance variables to hold the tests to run
- instance variables to perform static/dynamic analyses
- logger and instance variables to store the results

"
Class {
	#name : #AbstractSTExperiment,
	#superclass : #Object,
	#instVars : [
		'collectionOfTestSuites',
		'logger',
		'dataSet',
		'smTResults',
		'smTFinders',
		'packages',
		'currentEntry',
		'currentChange'
	],
	#category : #'SmartTestExperiment-Analysis'
}

{ #category : #finders }
AbstractSTExperiment class >> defaultFinders [
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
AbstractSTExperiment class >> methodRefAsTestCase: aMethodReference [
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
AbstractSTExperiment class >> new [
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
AbstractSTExperiment class >> new: aSmartFindersDictionary [
	"aSmartFindersDictionary: keys should be symbols and values should be SmartFinders"

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
AbstractSTExperiment class >> ombuEntriesFromFile: ombFile [
	^ (EpLog freshFromFile: ombFile) entries
]

{ #category : #finders }
AbstractSTExperiment class >> reflectivityFinder [
	| smTFinders |
	smTFinders := OrderedDictionary new.
	smTFinders
		at: #reflectivity
		put:
			(SmartFinder new
				filter: SmTDefaultPackagesFilter new;
				cacheStrategy: SmTNoCacheStrategy new;
				smtFinder: SmTReflectivityTestFinderStrategy new).
	^ smTFinders
]

{ #category : #'instance creation' }
AbstractSTExperiment class >> resultsFormat [
	self subclassResponsibility
]

{ #category : #finders }
AbstractSTExperiment class >> ungenericFinders [
	| smTFinders |
	smTFinders := OrderedDictionary new.
	smTFinders
		at: #static
			put:
			(SmartFinder new
				filter: SmTDefaultPackagesFilter new;
				cacheStrategy: SmTNoCacheStrategy new;
				smtFinder: SmTSenderTestFinderStrategy new);
		at: #dynamicAlwaysResetCache
			put:
			(SmartFinder new
				filter: SmTDefaultClassPackagesFilter new;
				cacheStrategy: SmTBasicCacheStrategy new;
				smtFinder: SmTTestCoverageTestFinderStrategy new);
		at: #dynamicResetEveryFiveChanges
			put:
			(SmartFinder new
				filter: SmTDefaultClassPackagesFilter new;
				cacheStrategy: SmTBasicCacheResetEvery5ChangesStrategy new;
				smtFinder: SmTTestCoverageTestFinderStrategy new);
"		at: #dynamicResetEveryCommit
			put:
			(SmartFinder new
				filter: SmTDefaultClassPackagesFilter new;
				cacheStrategy: SmTBasicCacheResetEveryCommitStrategy new;
				smtFinder: SmTTestCoverageTestFinderStrategy new);"
		at: #dynamicNeverResetCache
			put:
			(SmartFinder new
				filter: SmTDefaultClassPackagesFilter new;
				cacheStrategy: SmTBasicCacheNeverResetStrategy new;
				smtFinder: SmTTestCoverageTestFinderStrategy new).
	^ smTFinders
]

{ #category : #private }
AbstractSTExperiment >> changeIsConcernedByProject: epChange [
	^  self packages includes:  epChange affectedPackageName 
]

{ #category : #private }
AbstractSTExperiment >> changeMustBePerformedAfterAnalysis [
	^ currentChange class = EpMethodRemoval
]

{ #category : #accessing }
AbstractSTExperiment >> changeNumber [
	^ (currentEntry tagAt: #self) localName
]

{ #category : #private }
AbstractSTExperiment >> createTestSuite: methodReferences [
	| testSuite testCases |
	testSuite := TestSuite named: 'Test Suite from Method names'.
	testCases := methodReferences
		collect: [ :methodReference | self class methodRefAsTestCase: methodReference ]
		thenSelect: [ :testCase | testCase notNil ].
	^ testSuite addTests: testCases
]

{ #category : #'actions-public' }
AbstractSTExperiment >> createTestcases [
	| testCaseClasses |
	testCaseClasses := self packages
		flatCollect: [ :each | 
			(each asPackageIfAbsent: [ nil ])
				ifNotNil: [ :package | package classes select: #isTestCase ]
				ifNil: [ #() ] ].
	collectionOfTestSuites := testCaseClasses collect: #buildSuite.
	logger logCreatedTestcases: testCaseClasses
]

{ #category : #initialization }
AbstractSTExperiment >> initialize [
	super initialize.
	logger := STExperimentLauncherLogger new
]

{ #category : #private }
AbstractSTExperiment >> isCollectionMethod: epChange [
	| chgClass |
	chgClass := epChange methodAffected methodClass.
	chgClass ifNil: [ ^ false ].	"sometimes the change creates a method for an unexisting class ..."
	chgClass isTrait
		ifTrue: [ ^ false ].	"not Traits in collections and would pollute the following code"
	epChange methodAffected isMetaSide
		ifTrue: [ chgClass := chgClass instanceSide ].
	^ chgClass inheritsFrom: Collection
]

{ #category : #private }
AbstractSTExperiment >> isSystemWideMethod: epChange [
	(#(#new #initialize) includes: epChange methodAffected selector)
		ifTrue: [ ^ true ].
	^ self isCollectionMethod: epChange
]

{ #category : #accessing }
AbstractSTExperiment >> logFileReference: logfileRef [
	logger logFileReference: logfileRef
]

{ #category : #analysis }
AbstractSTExperiment >> manageBuildCache [
	self subclassResponsibility
]

{ #category : #private }
AbstractSTExperiment >> ombuEntriesFromFile: ombFile [
	"conveniance method to call the class side one"
	^ self class ombuEntriesFromFile: ombFile
]

{ #category : #accessing }
AbstractSTExperiment >> packages [
	^ dataSet packages
]

{ #category : #analysis }
AbstractSTExperiment >> performAnalysis [
	smTFinders keysDo: [ :key | self performAnalysis: key ]
]

{ #category : #analysis }
AbstractSTExperiment >> performAnalysis: aSymbol [
	^ ((smTFinders at: aSymbol)
		researchTestsForMethod: currentChange methodAffected compiledMethod)
		collect: [ :method | method fullName ]
]

{ #category : #private }
AbstractSTExperiment >> processChange [
	currentChange isCodeChange
		ifTrue: [ logger logAppliedCodeChange: currentChange.
			currentChange applyCodeChange ]
		ifFalse: [ logger logIgnoreCodeChange ]
]

{ #category : #private }
AbstractSTExperiment >> runSuites [
	collectionOfTestSuites do: [ :each | each run ]
]

{ #category : #accessing }
AbstractSTExperiment >> smTFinders: anObject [
	smTFinders := anObject
]

{ #category : #accessing }
AbstractSTExperiment >> smTResults: anObject [
	smTResults := anObject
]

{ #category : #private }
AbstractSTExperiment >> smartTestInterventionNeeded: aChange [
	"Answer whether currentChange corresponds to a change which requires a SmartTest intervention
	 and this is when:
	 - the change was not the consequence of a monticello load (so really done by the developper)
	 - the change is on a method
	 - the change is in the project (in one of its packages)
	 - the change does not introduce (so not a methodRemoval) a halt
	 - th change is not just a change of protocol to 'as yet unclassified'. This occures when a protocol is deleted and so, all the methods in it.
	 - the change is not on a widely spread Pharo method (ex: #initialize) because it would end up looking for all methods in the image
		"

	| epChange |
	epChange := aChange content.
	^ aChange wasTriggered not
		and: [ epChange isEpMethodChange
				and: [ (self changeIsConcernedByProject: epChange)
						and: [ epChange isIntroducingAHalt not
								and: [ epChange isProtocolChangePriorToDeletion not
										and: [ (self isSystemWideMethod: epChange) not ] ] ] ] ]
]
