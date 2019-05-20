"
abstract class for each possible application to run through TimeAndMemoryExperiment.

A data set resides in a directory, has a list of ombu files (in baseDirectory/ombu-sessions), a base image pre-configured to load the ombu changes
"
Class {
	#name : #ApplicationDataSet,
	#superclass : #Object,
	#instVars : [
		'name',
		'baseDirectory',
		'baseImage',
		'ombuFiles',
		'ombuEntries',
		'packages'
	],
	#category : #'SmartTestExperiment-timeAndMem'
}

{ #category : #'instance creation' }
ApplicationDataSet class >> ForwardChainer [
	^ self new
			name: 'ForwardChainer' ;  "dataset name must match this method's name"
			baseDirectory: 'ForwardChainerData' ;
			baseImage: 'smarttestForwardChainer_base.image' ;
			ombuFiles: ( OrderedCollection withAll: #('ForwardChainer2' 'ForwardChainer3' 'ForwardChainer4' 'ForwardChainer5') ) ;
			packages: {'IABasic'} ;
			yourself. 
]

{ #category : #'instance creation' }
ApplicationDataSet class >> LANSimulation [
	^ self new
			name: 'LANSimulation' ;  "dataset name must match this method's name, see TimeAndMemoryExperiment>>prepareExperiment:withChange:"
			baseDirectory: 'LANSimulationData' ;
			baseImage: 'LANSimulation_base.image' ;
			ombuFiles: ( OrderedCollection with: 'LANSimulation_01' with: 'LANSimulation_02' ) ;
			packages: {'LANSimulation'} ;
			yourself
]

{ #category : #'instance creation' }
ApplicationDataSet class >> MooseQuery [
	^ self new
			name: 'MooseQuery' ;  "dataset name must match this method's name, see TimeAndMemoryExperiment>>prepareExperiment:withChange:"
			baseDirectory: 'MooseQueryData' ;
			baseImage: 'smartTest_MooseQuery_base.image' ;
			ombuFiles: ( OrderedCollection withAll: #('MooseQuery1' 'MooseQuery2' 'MooseQuery3') ) ;
			packages: {
			#'Moose-Core' . #'Moose-Query' . #'Moose-Query-Test' . #'Moose-Query-Extensions'.
			#'Famix-Core' . #'Famix-Extensions' . #'Famix-Implementation' . #'Fame-Core'.
			#'Moose-SmalltalkImporter' . #'Moose-Tests-Core' . #'Fame-SmalltalkBinding'.
			#'Moose-TestResources-KGB-P4FullInteracted' . #'Moose-TestResources-KGB-P5FullReferee'.
			#'Moose-TestResources-KGB-P7ReferencerReferee'.
			#'Fame-Tests-Core' . #'Moose-Tests-SmalltalkImporter-KGB'} ;
			yourself
]

{ #category : #'instance creation' }
ApplicationDataSet class >> Pheme [
	^ self new
			name: 'Pheme' ;  "dataset name must match this method's name, see TimeAndMemoryExperiment>>prepareExperiment:withChange:"
			baseDirectory: 'PhemeData' ;
			baseImage: 'pheme_base.image' ;
			ombuFiles: ( OrderedCollection withAll: #('Pheme1' 'Pheme2' 'Pheme3' 'Pheme4') ) ;
			packages: {('Phe' , 'me') asSymbol} ; "So that Pheme class is not considered referenced by SmartTest"
			yourself
]

{ #category : #'instance creation' }
ApplicationDataSet class >> Pillar [
	^ self new
			name: 'Pillar' ;  "dataset name must match this method's name, see TimeAndMemoryExperiment>>prepareExperiment:withChange:"
			baseDirectory: 'PillarData' ;
			baseImage: 'testExperimentPillar_base.image' ;
			ombuFiles: ( OrderedCollection withAll: #('pharo3' 'pharo4' 'pharo5' 'pharo6' 'pharo7' 'pharo8' 'pharo9' 'pharo10' 'pharo11' 'pharo12' 'pharo13' 'pharo14' 'pharo15' 'pharo16' 'pharo17' 'pharo18' 'pharo19' ) ) ;
			packages: {#'Pillar-Tests-Cli' . #'Pillar-PetitPillar' . #'Pillar-ExporterDeckJS' . #'Pillar-Tests-ExporterLaTeX' . #'Pillar-Pharo-Tools' . #'Pillar-Tests-Model'.
			#'Pillar-ExporterBeamer' . #'Pillar-GitBook' . #'Pillar-ExporterHTML' . #'Pillar-Tests-ExporterEPub' . #'Pillar-Tests-ExporterBeamer'.
			#'Pillar-Cli-PillarVersion' . #'Pillar-Tests-ExporterAsciiDoc' . #'Pillar-ExporterEPub' . #'Pillar-ExporterMarkdown' . #'Pillar-ExporterLaTeX'.
			#'Pillar-ExporterPillar' . #'Pillar-Project' . #'Pillar-Tests-ExporterCore' . #'Pillar-Tests-ExporterText' . #'Pillar-Tests-BuildPipeline'.
			#'Pillar-Tests-PetitPillar' . #'Pillar-Tests-ExporterDeckJS' . #'Pillar-Tests-ExporterPillar' . #'Pillar-ExporterAsciiDoc' . #'Pillar-Tests-ExporterMarkdown'.
			#'Pillar-Tests-ExporterHTML' . #'Pillar-BuildPipeline' . #'Pillar-ExporterCore' . #'Pillar-ExporterText' . #'Pillar-Model' . #'Pillar-Cli'} ;
			yourself
]

{ #category : #'instance creation' }
ApplicationDataSet class >> PostgreSQL [
	^ self new
			name: 'PostgreSQL' ;  "dataset name must match this method's name, see TimeAndMemoryExperiment>>prepareExperiment:withChange:"
			baseDirectory: 'PostgresData' ;
			baseImage: 'smartTest_Postgres_base.image' ;
			ombuFiles: ( OrderedCollection withAll: #('postgresql1' 'postgresql2' 'postgresql3' 'postgresql4') ) ;
			packages: { #'PostgreSQL-AST' . #'PostgreSQL-Parser-Core' . #'PostgreSQL-Parser-Errors' . #'PostgreSQL-Parser-Others' . #'PostgreSQL-Parser-Tests' } ;
			yourself
]

{ #category : #accessing }
ApplicationDataSet class >> rootDir [
	"^ '/home/anquetil/Documents/RMod/Rech/SmartTest3/'"
	^ '/home/clotilde/Documents/Stage/'
]

{ #category : #accessing }
ApplicationDataSet >> baseDirectory [
	"name of the directory where the data set is found"
	^ baseDirectory 
]

{ #category : #accessing }
ApplicationDataSet >> baseDirectory: aDirName [
	baseDirectory := aDirName
]

{ #category : #accessing }
ApplicationDataSet >> baseImage [
	"name of the base image file within baseDirectory"
	^ baseImage 
]

{ #category : #accessing }
ApplicationDataSet >> baseImage: aString [
	baseImage := aString 
]

{ #category : #initialization }
ApplicationDataSet >> cacheOmbuEntries [
	ombuEntries := 
		(self ombuFiles collect: [ :ombName || ombFile |
			ombFile := self directoryReference / 'ombu-sessions' / ombName.
			ombName -> (self ombuEntriesFromFile: ombFile) size
		]).
]

{ #category : #computedGetters }
ApplicationDataSet >> changeAtPos: globalPos [
	| filePos |
	filePos := globalPos.
	ombuEntries do: [ :assoc |
		(assoc value >= filePos)
			ifTrue: [ ^ self changeAtPos: filePos inFile: assoc key ]
			ifFalse: [ filePos := filePos - assoc value ]
	]
]

{ #category : #computedGetters }
ApplicationDataSet >> changeAtPos: anInt inFile: aString [
	| ombFile |
	ombFile := self directoryReference / 'ombu-sessions' / aString.
	^ ((self ombuEntriesFromFile: ombFile) at: anInt)
	
]

{ #category : #computedGetters }
ApplicationDataSet >> changeNumber: ombuChange [
	^ (ombuChange tagAt: #self) localName
]

{ #category : #computedGetters }
ApplicationDataSet >> changeWithNumber: anInteger [
	ombuFiles do: [ :filename || ombFile |
	ombFile := self directoryReference / 'ombu-sessions' / filename.
	(self ombuEntriesFromFile: ombFile) do: [ :ombuChg |
		(self changeNumber: ombuChg) = anInteger
			ifTrue: [ ^ ombuChg ]
		]
	].
	^ nil
]

{ #category : #accessing }
ApplicationDataSet >> directoryReference [
	^ self class rootDir asFileReference / self baseDirectory
]

{ #category : #computedGetters }
ApplicationDataSet >> entriesCount [
	^ (ombuEntries collect: #value) sum
]

{ #category : #accessing }
ApplicationDataSet >> imageReference [
	^ self directoryReference / self baseImage 
]

{ #category : #accessing }
ApplicationDataSet >> name [
	^ name
]

{ #category : #accessing }
ApplicationDataSet >> name: anObject [
	name := anObject
]

{ #category : #private }
ApplicationDataSet >> ombuEntriesFromFile: ombFile [
	"conveniance method to call the AbstractStaticDynamicExperiment one"
	^ AbstractStaticDynamicExperiment ombuEntriesFromFile: ombFile
]

{ #category : #accessing }
ApplicationDataSet >> ombuFiles [
	"Ordered collection of ombu file names (strings)
	The order is important to load all the changes preceding a given change"
	^ ombuFiles 
]

{ #category : #accessing }
ApplicationDataSet >> ombuFiles: aCollection [
	ombuFiles := aCollection.
	self cacheOmbuEntries 
]

{ #category : #accessing }
ApplicationDataSet >> packages [
	^ packages
]

{ #category : #accessing }
ApplicationDataSet >> packages: anObject [
	packages := anObject
]

{ #category : #printing }
ApplicationDataSet >> printOn: aStream [
	super printOn: aStream.
	aStream << '(' << self name << ')'
]
