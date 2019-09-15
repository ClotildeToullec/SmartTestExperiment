"
I represent the unit tests for ExperimentLauncherMeasurements.
I test only default finders usage and should be extended to modular analyses
"
Class {
	#name : #TestExperimentLauncherMeasurements,
	#superclass : #TestCase,
	#instVars : [
		'measurements'
	],
	#category : #'SmartTestExperiment-Tests'
}

{ #category : #'initialize-release' }
TestExperimentLauncherMeasurements >> setUp [
	measurements := STEMeasurements new: STExperimentLauncher defaultFinders keys.
]

{ #category : #running }
TestExperimentLauncherMeasurements >> testAlphaOmegaTestTimes [
	self assert: (measurements lastRow at: #totalTestTime) equals: 0.
	measurements at: #totalTestTime increment: 99.
	self
		assert: (measurements lastRow at: #totalTestTime) equals: 99;
		assert: (measurements lastRow at: #reducedTestTimeStatic) equals: 0.
	measurements at: #reducedTestTimeStatic increment: 88.
	self
		assert: (measurements lastRow at: #reducedTestTimeStatic)
			equals: 88;
		assert: (measurements lastRow at: #reducedTestTimeDynamic)
			equals: 0.
	measurements at: #reducedTestTimeDynamic increment: 44.
	self
		assert: (measurements lastRow at: #reducedTestTimeDynamic)
		equals: 44
]

{ #category : #running }
TestExperimentLauncherMeasurements >> testCacheSize [
	"self run: #testAlphaOmegaCachesize"

	self flag: 'Invalid: cacheSize:'.
	self assert: (measurements lastRow at: #cacheSize) equals: 0.
"	measurements cacheSize: 3."
	self assert: (measurements lastRow at: #cacheSize) equals: 3
]

{ #category : #tests }
TestExperimentLauncherMeasurements >> testIncrementResults [
	| lastRow |
	"First row"
	measurements
		at: #truePositivesStatic increment: 8;
		at: #falsePositivesStatic increment: 7;
		at: #falseNegativesStatic increment: 6;
		at: #trueNegativesStatic increment: 5;
		at: #truePositivesDynamic increment: 4;
		at: #falsePositivesDynamic increment: 3;
		at: #falseNegativesDynamic increment: 2;
		at: #trueNegativesDynamic increment: 1.
	lastRow := measurements lastRow.
	self
		assert: (lastRow at: #truePositivesStatic) equals: 8;
		assert: (lastRow at: #falsePositivesStatic) equals: 7;
		assert: (lastRow at: #falseNegativesStatic) equals: 6;
		assert: (lastRow at: #trueNegativesStatic) equals: 5;
		assert: (lastRow at: #truePositivesDynamic) equals: 4;
		assert: (lastRow at: #falsePositivesDynamic) equals: 3;
		assert: (lastRow at: #falseNegativesDynamic) equals: 2;
		assert: (lastRow at: #trueNegativesDynamic) equals: 1.

	"Second row"
	measurements newRow.
	measurements
		at: #truePositivesStatic increment: 1;
		at: #falsePositivesStatic increment: 2;
		at: #falseNegativesStatic increment: 3;
		at: #trueNegativesStatic increment: 4;
		at: #truePositivesDynamic increment: 5;
		at: #falsePositivesDynamic increment: 6;
		at: #falseNegativesDynamic increment: 7;
		at: #trueNegativesDynamic increment: 8.
	lastRow := measurements lastRow.
	self
		assert: (lastRow at: #truePositivesStatic) equals: 1;
		assert: (lastRow at: #falsePositivesStatic) equals: 2;
		assert: (lastRow at: #falseNegativesStatic) equals: 3;
		assert: (lastRow at: #trueNegativesStatic) equals: 4;
		assert: (lastRow at: #truePositivesDynamic) equals: 5;
		assert: (lastRow at: #falsePositivesDynamic) equals: 6;
		assert: (lastRow at: #falseNegativesDynamic) equals: 7;
		assert: (lastRow at: #trueNegativesDynamic) equals: 8
]

{ #category : #running }
TestExperimentLauncherMeasurements >> testInitializeRow [
	"self run: #testAlphaOmegaCachesize"

	measurements
		initializeRow: 1
		change: 'Class1>>method1'
		type: MethodAddition.
	self
		assert: (measurements lastRow at: #id) equals: 1;
		assert: (measurements lastRow at: #change)
			equals: 'Class1>>method1';
		assert: (measurements lastRow at: #changeType)
			equals: MethodAddition
]

{ #category : #running }
TestExperimentLauncherMeasurements >> testSourceCodeChurn [
	| lastRow total |
	"First row"
	measurements
		incrementChange: #linesAdded withAmount: 6 inTest: false;
		incrementChange: #linesModified withAmount: 5 inTest: false;
		incrementChange: #linesDeleted withAmount: 4 inTest: false.
	lastRow := measurements lastRow.
	self
		assert: (lastRow at: #sourceLinesAdded) equals: 6;
		assert: (lastRow at: #sourceLinesModified) equals: 5;
		assert: (lastRow at: #sourceLinesDeleted) equals: 4.

	"Second row"
	measurements newRow.
	measurements
		incrementChange: #linesAdded withAmount: 3 inTest: false;
		incrementChange: #linesModified withAmount: 2 inTest: false;
		incrementChange: #linesDeleted withAmount: 1 inTest: false.
	lastRow := measurements lastRow.
	self
		assert: (lastRow at: #sourceLinesAdded) equals: 3;
		assert: (lastRow at: #sourceLinesModified) equals: 2;
		assert: (lastRow at: #sourceLinesDeleted) equals: 1.

	"Total"
	total := measurements totalCodeChurn: #source.
	self
		assert: (total at: #linesAdded) equals: 9;
		assert: (total at: #linesModified) equals: 7;
		assert: (total at: #linesDeleted) equals: 5;
		assert: (total at: #totalCodeChurn) equals: 21
]

{ #category : #running }
TestExperimentLauncherMeasurements >> testTestCodeChurn [
	| lastRow total |
	"First row"
	measurements
		incrementChange: #linesAdded withAmount: 6 inTest: true;
		incrementChange: #linesModified withAmount: 5 inTest: true;
		incrementChange: #linesDeleted withAmount: 4 inTest: true.
	lastRow := measurements lastRow.
	self
		assert: (lastRow at: #testLinesAdded) equals: 6;
		assert: (lastRow at: #testLinesModified) equals: 5;
		assert: (lastRow at: #testLinesDeleted) equals: 4.

	"Second row"
	measurements newRow.
	measurements
		incrementChange: #linesAdded withAmount: 3 inTest: true;
		incrementChange: #linesModified withAmount: 2 inTest: true;
		incrementChange: #linesDeleted withAmount: 1 inTest: true.
	lastRow := measurements lastRow.
	self
		assert: (lastRow at: #testLinesAdded) equals: 3;
		assert: (lastRow at: #testLinesModified) equals: 2;
		assert: (lastRow at: #testLinesDeleted) equals: 1.

	"Total"
	total := measurements totalCodeChurn: #test.
	self
		assert: (total at: #linesAdded) equals: 9;
		assert: (total at: #linesModified) equals: 7;
		assert: (total at: #linesDeleted) equals: 5;
		assert: (total at: #totalCodeChurn) equals: 21
]

{ #category : #tests }
TestExperimentLauncherMeasurements >> testUnknownColumns [
	self
		should: [ measurements lastRow at: #unexistingSymbol ]
		raise: KeyNotFound.
	self
		should: [ measurements
				incrementChange: #unexistingSymbol
				withAmount: 1
				inTest: true ]
		raise: KeyNotFound.
	self
		should: [ measurements at: #unexistingSymbol increment: 1 ]
		raise: KeyNotFound
]
