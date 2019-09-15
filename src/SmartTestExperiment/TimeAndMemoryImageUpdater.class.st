"
A special class that updates all the datasets specific images to the latest version of the code (TimeAndMemoryExperiment and its subclasses)

This class serves both as master (launches each dataset base image to update it) and as slave (in a dataset base image, load the new code from the repository)
"
Class {
	#name : #TimeAndMemoryImageUpdater,
	#superclass : #TimeAndMemoryExperiment,
	#category : #'SmartTestExperiment-Time-Memory'
}

{ #category : #operations }
TimeAndMemoryImageUpdater class >> updateAll [
	"run:

		TimeAndMemoryImageUpdater updateAll.
	"
	self updateAllOf: #( ForwardChainer LANSimulation MooseQuery Pheme Pillar PostgreSQL ).

	
]

{ #category : #operations }
TimeAndMemoryImageUpdater class >> updateAllOf: datasetsSymbols [
	self new updateAllOf: datasetsSymbols
]

{ #category : #analysis }
TimeAndMemoryImageUpdater >> manageBuildCache [
	self subclassResponsibility
]

{ #category : #'running slave' }
TimeAndMemoryImageUpdater >> runUpdate [
	ConfigurationOfTimeAndMemoryExperiment loadBleedingEdge.
	self saveAndQuitImage
]

{ #category : #'running slave' }
TimeAndMemoryImageUpdater >> saveAndQuitImage [
	self signalEndOfProcess: self updateImageSignal.
	Smalltalk snapshot: true andQuit: true.
]

{ #category : #processes }
TimeAndMemoryImageUpdater >> signalEndOfProcess [
	self signalEndOfProcess: self updateImageSignal
]

{ #category : #'running master' }
TimeAndMemoryImageUpdater >> updateAllOf: datasetsSymbols [
	datasetsSymbols do: [ :ds | self updateImageOf: ds ]
]

{ #category : #'running master' }
TimeAndMemoryImageUpdater >> updateImageOf: aSymbol [
	
	dataSet := ApplicationDataSet perform: aSymbol.
	ImageRunner platformRunner
		runImage: dataSet imageReference withParameters: #( doUpdateBaseImage ).
	
	self waitForSignal: self updateImageSignal.
]
