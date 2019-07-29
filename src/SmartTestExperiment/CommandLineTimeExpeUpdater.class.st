Class {
	#name : #CommandLineTimeExpeUpdater,
	#superclass : #CommandLineHandler,
	#category : #'SmartTestExperiment-timeAndMem'
}

{ #category : #accessing }
CommandLineTimeExpeUpdater class >> commandName [
	^ #doUpdateBaseImage
]

{ #category : #activation }
CommandLineTimeExpeUpdater >> activate [
	TimeAndMemoryImageUpdater new runUpdate
]
