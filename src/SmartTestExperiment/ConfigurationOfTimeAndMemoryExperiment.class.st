Class {
	#name : #ConfigurationOfTimeAndMemoryExperiment,
	#superclass : #Object,
	#instVars : [
		'project'
	],
	#category : #'SmartTestExperiment-timeAndMem'
}

{ #category : #private }
ConfigurationOfTimeAndMemoryExperiment class >> baseConfigurationClassIfAbsent: aBlock [
	^ Smalltalk
		at: #MetacelloBaseConfiguration
		ifAbsent: [ self ensureMetacelloBaseConfiguration.
			Smalltalk at: #MetacelloBaseConfiguration ifAbsent: aBlock ]
]

{ #category : #loading }
ConfigurationOfTimeAndMemoryExperiment class >> loadBleedingEdge [
	"Load the latest versions of the mcz files defined for this project. It is not likely that the #bleedingEdge has been tested."

	"self loadBleedingEdge"

	<apiDocumentation>
	^ (self project version: #bleedingEdge) load
]

{ #category : #loading }
ConfigurationOfTimeAndMemoryExperiment class >> project [
	^ self new project
]

{ #category : #baselines }
ConfigurationOfTimeAndMemoryExperiment >> baseline01: spec [
	<version: '0.1-baseline'>
	spec
		for: #common
		do: [ spec blessing: #baseline.
			spec repository: 'http://smalltalkhub.com/mc/AnneEtien/SmartTestExperiment/main/'.
			spec package: 'SmartTestExperiment'
 ]
]

{ #category : #baselines }
ConfigurationOfTimeAndMemoryExperiment >> bleedingEdge: spec [
	<symbolicVersion: #bleedingEdge>
	spec for: #'pharo6.x' version: '0.1-baseline'
]

{ #category : #accessing }
ConfigurationOfTimeAndMemoryExperiment >> customProjectAttributes [
	"Edit to return a collection of any custom attributes e.g. for conditional loading: Array with: #'Condition1' with: #'Condition2.
	For more information see: http://code.google.com/p/metacello/wiki/CustomProjectAttrributes"

	^ #()
]

{ #category : #accessing }
ConfigurationOfTimeAndMemoryExperiment >> project [
	^ project
		ifNil: [ "Bootstrap Metacello if it is not already loaded"
			(self class baseConfigurationClassIfAbsent: [  ]) ensureMetacello.
			"Construct Metacello project"
			project := MetacelloMCProject new projectAttributes: self customProjectAttributes.
			(Smalltalk at: #MetacelloVersionConstructor) on: self project: project.
			project loadType: #linear.	"change to #atomic if desired"
			project ]
]
