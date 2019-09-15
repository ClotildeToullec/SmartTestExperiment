"
A command line handler to launch time experiment in the base image of datasets

usage: doRun

"
Class {
	#name : #CommandLineTimeExperimentRun,
	#superclass : #CommandLineHandler,
	#category : #'SmartTestExperiment-Time-Memory'
}

{ #category : #accessing }
CommandLineTimeExperimentRun class >> commandName [
	^ #doRun
]

{ #category : #activation }
CommandLineTimeExperimentRun >> activate [
	TimeAndMemorySlave getInstance runExperiment: (self arguments first asInteger)
]
