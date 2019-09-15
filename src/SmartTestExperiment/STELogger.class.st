"
Utility class for logging results of STExperimentLauncher
"
Class {
	#name : #STELogger,
	#superclass : #Object,
	#instVars : [
		'logstream',
		'logFileReference'
	],
	#category : #'SmartTestExperiment-Reporting'
}

{ #category : #format }
STELogger >> blankLine [
	self log: '' crBefore: true indentation: 0
]

{ #category : #'opening-closing' }
STELogger >> closelog [
	self separationLine.
	self
		log: 'Terminating Smarttest experiment at '
		crBefore: true
		indentation: 0.
	self log: Time now printString crBefore: false indentation: 0.
	(logstream notNil and: [ logstream isStream ])
		ifTrue: [ logstream close ]
]

{ #category : #accessing }
STELogger >> defaultLogFileReference [
	^ 'SmartTestLogFile.txt' asFileReference
]

{ #category : #initialization }
STELogger >> initialize [
	super initialize.
	logstream := nil.
	logFileReference := self defaultLogFileReference
]

{ #category : #format }
STELogger >> log: aLogEntry crBefore: crBefore indentation: indentLevel [
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
STELogger >> logAppliedCodeChange: aChange [
	self
		blankLine;
		log: '----- Code change applied  -----'
			crBefore: true
			indentation: 0;
		log: aChange printString crBefore: true indentation: 1
]

{ #category : #format }
STELogger >> logCollection: aCollection [
	"Log the contents of the collection but make sure that the print representations is sorted"

	(logstream notNil and: [ logstream isStream ])
		ifFalse: [ ^ self ].
	logstream closed
		ifTrue: [ self reopenLog ].
	(aCollection collect: [ :elem | elem printString ])
		asSortedCollection printElementsOn: logstream
]

{ #category : #logging }
STELogger >> logCreatedTestcases: testCaseClasses [
	self log: 'Created testCases:' crBefore: true indentation: 1.
	self log: '' crBefore: true indentation: 2.
	self logCollection: testCaseClasses
]

{ #category : #accessing }
STELogger >> logFileReference [
	^ logFileReference
]

{ #category : #accessing }
STELogger >> logFileReference: aFileReference [
	aFileReference assert: aFileReference class == FileReference  description: 'Expected a FileReference for #logFileReference:'.
	logFileReference := aFileReference
]

{ #category : #logging }
STELogger >> logIgnoreCodeChange [
	self
		log: '----- Ignored code change -----'
		crBefore: true
		indentation: 0
]

{ #category : #logging }
STELogger >> logNoSmarttestAnalysis [
	self
		log: '----- No SmartTest analysis needed -----'
		crBefore: true
		indentation: 0
]

{ #category : #logging }
STELogger >> logStartOfCodeChange: aChange number: changeNumber [
	self
		separationLine;
		separationLine;
		blankLine;
		log:
			'-------------------------- change ' , changeNumber asString
				, ' --------------------------'
			crBefore: true
			indentation: 0;
		log: aChange printString crBefore: true indentation: 0;
		blankLine.
	aChange isEpMethodChange
		ifFalse: [ ^ self ].
	self
		log: 'Source code:' crBefore: true indentation: 0;
		separationLine;
		log: aChange methodAffected sourceCode
			crBefore: true
			indentation: 0;
		separationLine
]

{ #category : #'opening-closing' }
STELogger >> openlog [
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

{ #category : #'opening-closing' }
STELogger >> reopenLog [
	logstream := logFileReference writeStream.
	logstream setToEnd.
	self
		blankLine;
		separationLine;
		log: 'Log reopenning' crBefore: true indentation: 0;
		separationLine;
		blankLine
]

{ #category : #format }
STELogger >> separationLine [
	self
		log: '--------------------------------------------------------------'
		crBefore: true
		indentation: 0
]

{ #category : #format }
STELogger >> symbolToString: aSymbol [
	"Utility -- Should not be here -- Twin method in Visualizer:
	 #aSymbolToBeTransformed --> 'A Symbol To Be Transformed' "

	| stream |
	stream := WriteStream with: ''.
	stream << aSymbol asString first asUppercase.
	aSymbol asString allButFirst
		do: [ :char | 
			char isUppercase
				ifTrue: [ stream space ].
			stream << char ].
	^ stream contents
]
