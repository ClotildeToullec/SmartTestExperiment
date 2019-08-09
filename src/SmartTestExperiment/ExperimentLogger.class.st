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
ExperimentLogger >> blankLine [
	self log: '' crBefore: true indentation: 0
]

{ #category : #logging }
ExperimentLogger >> closelog [
	self separationLine.
	self
		log: 'Terminating Smarttest experiment at '
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
	logstream closed
		ifTrue: [ self reopenLog ].
	crBefore
		ifTrue: [ logstream cr.
			1 to: indentLevel do: [ :inx | logstream nextPut: Character tab ] ].
	logstream
		nextPutAll: aLogEntry;
		flush
]

{ #category : #logging }
ExperimentLogger >> logAppliedCodeChange: aChange [
	self
		blankLine;
		log: '** Code change applied: ' , aChange printString
			crBefore: true
			indentation: 0
]

{ #category : #logging }
ExperimentLogger >> logCollection: aCollection [
	"Log the contents of the collection but make sure that the print representations is sorted"

	(logstream notNil and: [ logstream isStream ])
		ifFalse: [ ^ self ].
	logstream closed
		ifTrue: [ self reopenLog ].
	(aCollection collect: [ :elem | elem printString ])
		asSortedCollection printElementsOn: logstream
]

{ #category : #logging }
ExperimentLogger >> logCreatedTestcases: testCaseClasses [
	self log: '** Created testCases >> ' crBefore: true indentation: 1.
	self log: 'Testcases: ' crBefore: true indentation: 3.
	self logCollection: testCaseClasses
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
	self log: 'Ignored code change' crBefore: true indentation: 0
]

{ #category : #logging }
ExperimentLogger >> logNoSmarttestAnalysis [
	self
		log: 'No smarttest analysis needed'
		crBefore: true
		indentation: 0
]

{ #category : #logging }
ExperimentLogger >> logStartOfCodeChange: aChange number: changeNumber [
	self
		blankLine;
		log:
			'------------------------- change ' , changeNumber asString
				, ' -------------------------'
			crBefore: true
			indentation: 0;
		log: aChange printString crBefore: true indentation: 0;
		blankLine.
	aChange isEpMethodChange
		ifFalse: [ ^ self ].
	self
		log: aChange methodAffected sourceCode
			crBefore: true
			indentation: 0;
		separationLine
]

{ #category : #logging }
ExperimentLogger >> openlog [
	logFileReference exists
		ifTrue: [ logFileReference delete ].
	logstream := logFileReference writeStream.
	self
		log: 'Launching Smarttest experiment at '
		crBefore: false
		indentation: 0.
	self log: Time now printString crBefore: false indentation: 0.
	self separationLine
]

{ #category : #logging }
ExperimentLogger >> reopenLog [
	logstream := logFileReference writeStream.
	logstream setToEnd.
	self
		separationLine;
		log: 'Log reopenning' crBefore: true indentation: 0;
		separationLine
]

{ #category : #'final logging' }
ExperimentLogger >> separationLine [
	self
		log: '-------------------------------------------------------------------'
		crBefore: true
		indentation: 0
]
