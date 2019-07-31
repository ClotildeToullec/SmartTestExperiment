Class {
	#name : #MooseGenerationOmbuCreator,
	#superclass : #ExperimentLauncher,
	#category : #'SmartTestExperiment-analysis'
}

{ #category : #'as yet unclassified' }
MooseGenerationOmbuCreator class >> createNewOmbuFromFamixFiles [
	<script>
	(self ombuFilesInProject: 'FamixBis')
		do: [ :file | self createNewOmbuUsing: file ]
]

{ #category : #'ombu creation' }
MooseGenerationOmbuCreator class >> createNewOmbuUsing: anOmbuFile [
	| el changes packageNames |
	self resetLastRun.
	changes := OrderedCollection new.
	anOmbuFile exists
		ifTrue: [ changes addAll: (self ombuEntriesFromFile: anOmbuFile) ].
	packageNames := (OmbuFilesOrganizer new
		packageNamesInFile: anOmbuFile) asArray
		reject: [ :pckg | 
			(pckg includesSubstring: 'Famix-MetamodelBuilder-Test')
				or: [ pckg includesSubstring: 'Iceberg' ] ].
	lastRuns
		add:
			(self new
				packages: packageNames;
				changeList: changes;
				yourself).
	el := self lastRun.
	el runToCreateNewOmbuFile.
	SmalltalkImage current snapshot: true andQuit: false
]

{ #category : #'as yet unclassified' }
MooseGenerationOmbuCreator >> changeShouldBeApplied [
	| epChange |
	epChange := currentChange content.
	^ epChange class ~= EpProtocolRemoval
		and: [ epChange isCodeChange
				and: [ self packages includes: epChange affectedPackageName ] ]
]

{ #category : #'as yet unclassified' }
MooseGenerationOmbuCreator >> changeWasInAGenerator [
	^ currentChange content isEpMethodChange
		and: [ currentChange content methodAffected className
				includesSubstring: 'Generator' ]
]

{ #category : #'as yet unclassified' }
MooseGenerationOmbuCreator >> createNeOwmbuAndIncrement: bar [
	changeList
		do: [ :anOmEntry | 
			currentChange := anOmEntry.
			self changeShouldBeApplied
				ifTrue: [ currentChange content applyCodeChange.
					self changeWasInAGenerator
						ifTrue: [ self generate ] ].
			bar increment ]
]

{ #category : #'as yet unclassified' }
MooseGenerationOmbuCreator >> generate [
	self generate: currentChange content methodAffected realClass
]

{ #category : #'as yet unclassified' }
MooseGenerationOmbuCreator >> generate: class [
	class isAbstract
		ifTrue: [ class allSubclasses do: [ :subclass | self generate: subclass ].
			^ self ].
	(class withAllSuperclasses
		includes: (SmalltalkImage current classNamed: 'FamixMetamodelGenerator'))
		ifTrue: [ [ [ self generateMetaModelWithGenerator: class new ]
				on: Halt
				do: [ :halt | halt resume ] ]
				on: Error
				do: [ self inform: 'Generation failed' ] ].
	(class withAllSuperclasses
		includes: (SmalltalkImage current classNamed: 'FamixTestGenerator'))
		ifTrue: [ [ self generateTestsWithGenerator: class new ]
				on: FmxMBEntityAlreadyExists
				do: [ self inform: 'Generation failed' ] ]
]

{ #category : #'as yet unclassified' }
MooseGenerationOmbuCreator >> generateMetaModelWithGenerator: generator [
	| subbuilders builder |
	builder := generator newBuilder.

	"Copied from initialize"
	generator adoptBuilder: builder.
	subbuilders := Dictionary
		newFrom:
			(generator class submetamodels
				collect: [ :each | 
					| subbuilder |
					subbuilder := each builderWithDefinitions.
					subbuilder parentBuilder: generator builder.
					builder environment: builder environment.
					each prefix -> subbuilder ]).

	"Copied from generate"
	generator define.
	generator defineMooseModel.
	generator cleaningStrategy
		withCleaningDo: [ generator builder generate.
			subbuilders do: #generateRemotes ]
		with: generator
]

{ #category : #'as yet unclassified' }
MooseGenerationOmbuCreator >> generateTestsWithGenerator: generator [
	generator classes do: [ :c | generator runFor: c ]
]

{ #category : #'as yet unclassified' }
MooseGenerationOmbuCreator >> runToCreateNewOmbuFile [
		| barLabel |
	barLabel := 'SmartTest Experiment: Loading project'.
	UIManager default
		displayProgress: barLabel
		from: 1
		to: changeList size
		during: [ :bar | self createNeOwmbuAndIncrement: bar ]
]
