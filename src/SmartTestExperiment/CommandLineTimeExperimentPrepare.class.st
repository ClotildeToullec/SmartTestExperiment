"
A command line handler to prepare the base image of a dataset for experiments

usage: doPrepare <datasetName> <changeNumber>

calls TimeAndMemoryPreparer>>prepareExperiment:forChange:
"
Class {
	#name : #CommandLineTimeExperimentPrepare,
	#superclass : #CommandLineHandler,
	#category : #'SmartTestExperiment-timeAndMem'
}

{ #category : #accessing }
CommandLineTimeExperimentPrepare class >> commandName [
	^ #doPrepare
]

{ #category : #activation }
CommandLineTimeExperimentPrepare >> activate [
	"We are in an image specific to the data set chosen, so we should not need the datasetName
	 (first argument), but it is easier to recover it from these parameters than to prepare each
	 of the data sets specific images individually"
	TimeAndMemorySlave getInstance prepareForChange: (self arguments second asInteger) myDatasetName: (self arguments first asSymbol)
]
