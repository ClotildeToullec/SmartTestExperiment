"
I process ombu files obtained from projects developed in Moose images. I should be used in a Moose image.

I apply the changes to create a new ombu file.
When a code change occurs in a metamodel or tests generator, I apply the generation without disabling EpMonitor. The code changes triggered by the generation are thus stored in the new ombu file. 

"
Class {
	#name : #MooseGenerationOmbuCreator,
	#superclass : #STExperimentLauncher,
	#instVars : [
		'nbOfChangesInOmbu',
		'currentOmbuName'
	],
	#category : #'SmartTestExperiment-Ombu'
}

{ #category : #running }
MooseGenerationOmbuCreator class >> createNewOmbuFromFamixFiles [
	<script>
	| packages |
	packages := #('Famix-MetamodelBuilder-Test' 'Iceberg').
	(self ombuFilesInProject: 'FamixBis')
		do: [ :file | 
			self
				createNewOmbuUsing: file
				withPackages: (self packagesInFile: file excludingPrefixes: packages) ]
]

{ #category : #'ombu creation' }
MooseGenerationOmbuCreator class >> createNewOmbuUsing: anOmbuFile withPackages: packageNames [
	| el changes |
	self recompileGenerationMethod.
	Author
		useAuthor: self defaultAuthor
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

{ #category : #utility }
MooseGenerationOmbuCreator class >> defaultAuthor [
	^ 'SmTExperimentPreparation'
]

{ #category : #utility }
MooseGenerationOmbuCreator class >> packagesInFile: anOmbuFile excludingPrefixes: aPrefxesCollection [
	| allPackages |
	allPackages := (OmbuFilesOrganizer new packageNamesInFile: anOmbuFile)
		asArray.
	aPrefxesCollection
		do: [ :pckgString | 
			allPackages := allPackages
				reject: [ :pckg | pckg includesSubstring: pckgString ] ].
	^ allPackages
]

{ #category : #'ombu creation' }
MooseGenerationOmbuCreator class >> recompileGenerationMethod [
	EpMonitor current disableDuring: 
		[ FamixMetamodelGenerator compile: 

'generate
	"This method has been recompiled to avoid disabling EpMonitor"

	self define.
	self defineMooseModel.
	self cleaningStrategy
		withCleaningDo: [ self builder generate.
			subbuilders do: #generateRemotes ]
		with: self.
	self class resetMetamodel'

				classified: 'generation' ]
]

{ #category : #generation }
MooseGenerationOmbuCreator >> applyChangeInGenerator [
	self startNewOmbuFile.
	self applyCodeChange.
	self generate.
	self startNewOmbuFile
]

{ #category : #accessing }
MooseGenerationOmbuCreator >> applyCodeChange [
	[ currentEntry content applyCodeChange.
	nbOfChangesInOmbu := nbOfChangesInOmbu + 1 ]
		on: Error
		do: [ currentEntry inspectWithLabel: 'This change was not applied' ]
]

{ #category : #generation }
MooseGenerationOmbuCreator >> changeWasInAGenerator [
	"Change in a subclass of FamixMetamodelGenerator or in FamixGenerator"

	| changeClass |
	changeClass := self currentChangeClass.
	changeClass ifNil: [ ^ false ].
	^ {FamixMetamodelGenerator.
	FamixGenerator}
		anySatisfy:
			[ :class | changeClass = class or: [ changeClass inheritsFrom: class ] ]
]

{ #category : #accessing }
MooseGenerationOmbuCreator >> checkNeedForNewOmbu [
	(nbOfChangesInOmbu >= 100 and: [ currentEntry wasTriggered not ])
		ifFalse: [ ^ self ].
	nbOfChangesInOmbu := 0.
	OmbuFilesOrganizer new startNewOmbuFile
]

{ #category : #generation }
MooseGenerationOmbuCreator >> currentChangeClass [
	currentEntry content isEpBehaviorChange
		ifTrue: [ ^ currentEntry content behaviorAffected realClass ].
	currentEntry content isEpMethodChange
		ifTrue: [ ^ currentEntry content methodAffected compiledMethod realClass ]
]

{ #category : #accessing }
MooseGenerationOmbuCreator >> fileName: aFileName [
	currentOmbuName := aFileName
]

{ #category : #generation }
MooseGenerationOmbuCreator >> generate [
	Author
		useAuthor: 'GenerateAfterChange: ' , currentEntry printString
		during: [ [ [ FamixMetamodelGenerator generateAllMetamodels ]
				on: Halt
				do: [ :halt | halt resume ] ]
				on: FmxMBEntityAlreadyExists
				do: [ :error | self inform: 'Generation failed' ] ]
]

{ #category : #initialization }
MooseGenerationOmbuCreator >> initialize [
	super initialize.
	nbOfChangesInOmbu := 0
]

{ #category : #running }
MooseGenerationOmbuCreator >> manageOmbuEntry: anOmEntry [
	| currentChange |
	currentEntry := anOmEntry.
	currentChange := currentEntry content.

	"Triggers -> Rename Author as trigger"
	currentChange isMonticelloVersionsLoad
		ifTrue: [ self renameAuthor: 'Triggered: '.
			^ self ].
	currentChange isEpRefactoring
		ifTrue: [ self renameAuthor: 'Refactoring: '.
			^ self ].

	"Exclude non interesting changes"
	(currentChange isCodeChange not
		or: [ currentChange class = EpProtocolRemoval
				or: [ (self packages includes: currentChange affectedPackageName) not ] ])
		ifTrue: [ ^ self ].

	"Generator -> Start new ombu file. Change name. Apply. Generate"
	self changeWasInAGenerator
		ifTrue: [ self applyChangeInGenerator.
			^ self ].

	"Triggered -> Apply whithout changing name: will be the name definied by trigger"
	currentEntry wasTriggered
		ifTrue: [ self applyCodeChange.
			^ self ].

	"Class/Trait modification -> Change name so the 2 changes applied will have the same author. Apply."
	self renameAuthorFromChangeClass: currentChange class.

	"Other code change -> Change the name to default"
	self checkNeedForNewOmbu.
	self applyCodeChange
]

{ #category : #renaming }
MooseGenerationOmbuCreator >> renameAuthor: aString [
	Author uniqueInstance
		fullName:
			aString , (currentEntry tagAt: #self) shortName , ' - '
				, currentEntry content printString
]

{ #category : #renaming }
MooseGenerationOmbuCreator >> renameAuthorAsDefault [
	Author fullName: self class defaultAuthor
]

{ #category : #renaming }
MooseGenerationOmbuCreator >> renameAuthorFromChangeClass: classs [
	({EpClassModification.
	EpClassAddition.
	EpTraitModification.
	EpTraitAddition} includes: classs)
		ifTrue: [ self renameAuthor: classs printString ]
		ifFalse: [ self renameAuthorAsDefault ]
]

{ #category : #running }
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

{ #category : #accessing }
MooseGenerationOmbuCreator >> startNewOmbuFile [
	nbOfChangesInOmbu := 0.
	OmbuFilesOrganizer new startNewOmbuFile
]
