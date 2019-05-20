Class {
	#name : #ExperimentLogger,
	#superclass : #Object,
	#instVars : [
		'logstream',
		'logFileReference'
	],
	#category : #'SmartTestExperiment-reporting'
}

{ #category : #logging }
ExperimentLogger >> closelog [
	self
		log: '-- Terminating Smarttest experiment at '
		crBefore: true
		indentation: 0.
	self log: Time now printString crBefore: false indentation: 0.
	(logstream notNil and: [ logstream isStream ])
		ifTrue: [ logstream close ]
]

{ #category : #initialization }
ExperimentLogger >> initialize [
	super initialize.
	logstream := nil.
	logFileReference := self logFileName asFileReference.
	
]

{ #category : #logging }
ExperimentLogger >> log: aLogEntry crBefore: crBefore indentation: indentLevel [
	(logstream notNil and: [ logstream isStream ])
		ifFalse: [ ^ self ].
	crBefore
		ifTrue: [ logstream cr.
			1 to: indentLevel do: [:inx | logstream nextPut: Character tab]].
	logstream
		nextPutAll: aLogEntry;
		flush
]

{ #category : #logging }
ExperimentLogger >> logAppliedCodeChange: aChange [
	self log: 'Applied code change ' , aChange printString crBefore: true indentation: 1
]

{ #category : #logging }
ExperimentLogger >> logCollection: aCollection [
	"Log the contents of the collection but make sure that the print representations is sorted"

	(logstream notNil and: [ logstream isStream ])
		ifFalse: [ ^ self ].
	(aCollection collect: [:elem | elem printString]) asSortedCollection printOn: logstream
]

{ #category : #logging }
ExperimentLogger >> logCreatedOracle: mapMethodUnderTestToTestcase forChange: aChange [
	| currentOracle |
	self log: 'Oracle Methodundertest -> Testcase: --- ' crBefore: true indentation: 2.
	aChange isNil
		ifTrue: [ mapMethodUnderTestToTestcase keysSortedSafely
				do: [ :key | 
					self log: key asString crBefore: true indentation: 3.
					self log: (mapMethodUnderTestToTestcase at: key) printString crBefore: true indentation: 4 ] ]
		ifFalse: [ currentOracle := mapMethodUnderTestToTestcase at: aChange methodAffected fullName ifAbsent: [ {'No test case found'} ].
			self log: aChange methodAffected fullName asString crBefore: true indentation: 3.
			self log: '' crBefore: true indentation: 4.
				self logCollection: currentOracle]
]

{ #category : #logging }
ExperimentLogger >> logCreatedTestcases: testCaseClasses [
	self log: '** created testCases >> ' crBefore: true indentation: 1.
	self log: 'Testcases: ' crBefore: true indentation: 2.
	self logCollection: testCaseClasses.

]

{ #category : #logging }
ExperimentLogger >> logCreatedTestcases: testCaseClasses forClasses: classesUnderTest withResources: testResources [
	self log: '** created testCases >> ' crBefore: true indentation: 1.
	self log: 'Classes under test: ' crBefore: true indentation: 2.
	self logCollection: classesUnderTest.
	self log: 'Testcases: ' crBefore: true indentation: 2.
	self logCollection: testCaseClasses.
	self log: 'TestResources: ' crBefore: true indentation: 2.
		self logCollection: testResources.

]

{ #category : #accessing }
ExperimentLogger >> logFileName [
	^ 'SmartTestLogFile.txt'
]

{ #category : #accessing }
ExperimentLogger >> logFileReference [
	^ logFileReference
]

{ #category : #accessing }
ExperimentLogger >> logFileReference: aFileReference [
	aFileReference assert: aFileReference class == FileReference  description: 'Expected a FileReference for #logFileReference:'.
	logFileReference := aFileReference
]

{ #category : #logging }
ExperimentLogger >> logIgnoreCodeChange [
	self log: 'Ignored code change' crBefore: true indentation: 1
]

{ #category : #logging }
ExperimentLogger >> logNoSmarttestAnalysis [
	self log: 'No smarttest analysis needed' crBefore: true indentation: 1
]

{ #category : #logging }
ExperimentLogger >> logSeparationLine: changeNumber [
	
	self log: '------------------------- change ', changeNumber asString, '-------------------------'  crBefore: true indentation: 0
]

{ #category : #logging }
ExperimentLogger >> logStartOfCodeChange: aChange [
	self log: '-------------------------------------------------------------------' crBefore: true indentation: 0.
	self log: aChange printString crBefore: true indentation: 0.
	aChange isEpMethodChange
		ifTrue: [ self log: aChange methodAffected sourceCode crBefore: true indentation: 0.
			self log: '...................................................................' crBefore: true indentation: 0 ]
]

{ #category : #logging }
ExperimentLogger >> logStartOfCodeChange: aChange number: changeNumber [
	self logSeparationLine: changeNumber.
"	self log: '-------------------------------------------------------------------' crBefore: true indentation: 0."
	self log: aChange printString crBefore: true indentation: 0.
	aChange isEpMethodChange
		ifTrue: [ self log: aChange methodAffected sourceCode crBefore: true indentation: 0.
			self log: '..........................' crBefore: true indentation: 0 ]
]

{ #category : #logging }
ExperimentLogger >> openlog [
	logFileReference exists
		ifTrue: [ logFileReference delete ].
	logstream := logFileReference writeStream.
	self
		log: '-- Launching Smarttest experiment at '
		crBefore: false
		indentation: 0.
	self log: Time now printString crBefore: false indentation: 0
]
