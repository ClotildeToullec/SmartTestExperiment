"
I process ombu files obtained from projects developed in Moose images. I should be used in a Moose image.

I apply the changes to create a new ombu file.
When a code change occurs in a metamodel or tests generator, I apply the generation without disabling EpMonitor. The code changes triggered by the generation are thus stored in the new ombu file. 

"
Class {
	#name : #MooseGenerationOmbuCreator,
	#superclass : #ExperimentLauncher,
	#instVars : [
		'nbOfChangesInOmbu',
		'currentOmbuName'
	],
	#category : #'SmartTestExperiment-analysis'
}

{ #category : #'as yet unclassified' }
MooseGenerationOmbuCreator class >> createNewOmbuFromFamixFiles [
	<script>
	(self ombuFilesInProject: 'FamixBis')
		do: [ :file | 
			self
				createNewOmbuUsing: file
				withPackages:
					((OmbuFilesOrganizer new packageNamesInFile: file) asArray
						reject: [ :pckg | 
							(pckg includesSubstring: 'Famix-MetamodelBuilder-Test')
								or: [ pckg includesSubstring: 'Iceberg' ] ]) ]
]

{ #category : #'ombu creation' }
MooseGenerationOmbuCreator class >> createNewOmbuUsing: anOmbuFile withPackages: packageNames [
	| el changes |
	Author
		useAuthor: 'SmTExperimentPreparation'
		during: [ self resetLastRun.
			changes := OrderedCollection new.
			anOmbuFile exists
				ifTrue: [ changes addAll: (self ombuEntriesFromFile: anOmbuFile) ].
			lastRuns
				add:
					(self new
						packages: packageNames;
						changeList: changes;
						fileName: anOmbuFile basename;
						yourself).
			el := self lastRun.
			el runToCreateNewOmbuFile.
			SmalltalkImage current snapshot: true andQuit: false ]
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

{ #category : #accessing }
MooseGenerationOmbuCreator >> checkNeedForNewOmbu [
	(nbOfChangesInOmbu >= 100 and: [ currentChange wasTriggered not ])
		ifFalse: [ ^ self ].
	nbOfChangesInOmbu := 0.
	OmbuFilesOrganizer new startNewOmbuFile
]

{ #category : #accessing }
MooseGenerationOmbuCreator >> fileName: aFileName [
	currentOmbuName := aFileName
]

{ #category : #'as yet unclassified' }
MooseGenerationOmbuCreator >> generate [
	Author
		useAuthor: 'GenerateAfterChange: ' , currentChange printString
		during: [ self generate: currentChange content methodAffected realClass ]
]

{ #category : #'as yet unclassified' }
MooseGenerationOmbuCreator >> generate: class [
	"This method is not well written and should be more precise"

	class isAbstract
		ifTrue: [ class allSubclasses
				reject: #isAbstract
				thenDo: [ :subclass | self generate: subclass ].
			^ self ].
	(class withAllSuperclasses
		includes: (SmalltalkImage current classNamed: 'FamixMetamodelGenerator'))
		ifTrue: [ [ [ self generateMetaModelWithGenerator: class new ]
				on: Halt
				do: [ :halt | halt resume ] ]
				on: Error
				do: [ self inform: 'Generation failed' ]	"FmxMBEntityAlreadyExists" ].
	(class withAllSuperclasses
		includes: (SmalltalkImage current classNamed: 'FamixTestGenerator'))
		ifTrue: [ [ self generateTestsWithGenerator: class new ]
				on: Error
				do: [ self inform: 'Generation failed' ]	"FmxMBEntityAlreadyExists" ]
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

{ #category : #accessing }
MooseGenerationOmbuCreator >> manageOmbuEntry: anOmEntry [
	currentChange := anOmEntry.
	self changeShouldBeApplied
		ifFalse: [ ^ self ].
	self checkNeedForNewOmbu.
	[ currentChange content applyCodeChange ]
		on: Error
		do: [ currentChange inspectWithLabel: 'This change was not applied' ].
	nbOfChangesInOmbu := nbOfChangesInOmbu + 1.
	self changeWasInAGenerator
		ifTrue: [ self generate ]
]

{ #category : #'as yet unclassified' }
MooseGenerationOmbuCreator >> runToCreateNewOmbuFile [
	| barLabel |
	barLabel := 'Reapplying code changes from: ' , currentOmbuName.
	UIManager default
		displayProgress: barLabel
		from: 1
		to: changeList size
		during: [ :bar | 
			changeList
				do: [ :anOmEntry | 
					self manageOmbuEntry: anOmEntry.
					bar increment ] ]
]
