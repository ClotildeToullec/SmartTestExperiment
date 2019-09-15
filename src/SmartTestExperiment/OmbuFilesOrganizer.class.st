"
I am a utility class to prepare ombu files for ExperimentLauncher.


I sort ombu files from the older to the more recent and name them using this order and a project name.

OmbuFilesOrganizer>>renameFiles:inProject: 


I give access to all the packages affected in the ombu file. 

OmbuFilesOrganizer>>packageNamesInFile:
"
Class {
	#name : #OmbuFilesOrganizer,
	#superclass : #Object,
	#category : #'SmartTestExperiment-Ombu'
}

{ #category : #'ombu creation' }
OmbuFilesOrganizer >> applyAllComitsFromGitProject: aProjectName author: anAuthor branch: aBranchName [
	| repository branch commits |
	self recompilePackageLoadingMethod.
	self startNewOmbuFileNamed: aProjectName.

	"Repository"
	repository := self
		createRepositoryFromAuthor: anAuthor
		projectName: aProjectName.

	"Branch"
	branch := repository branchNamed: aBranchName.

	"Commits from newer to older"
	commits := branch newCommitWalk commits.

	"Checkout"
	self checkoutCommits: commits
]

{ #category : #'ombu creation' }
OmbuFilesOrganizer >> checkoutCommits: commits [
	UIManager default
		displayProgress: 'Checking out commits'
		from: 1
		to: commits size
		during: [ :bar | 
			commits
				reverseDo: [ :commit | 
					[ commit packages
						ifNotEmpty: [ commit
								checkout:
									(IceCheckoutAllPackages new
										committish: commit;
										yourself) ] ]
						on: Warning
						do: [ :warn | warn crLog ].
					bar increment ] ]
]

{ #category : #'ombu creation' }
OmbuFilesOrganizer >> createRepositoryFromAuthor: anAuthor projectName: aProjectName [
	| repository |
	repository := IceRepositoryCreator new
		remote:
			(IceGitRemote
				url: 'https://github.com/' , anAuthor , '/' , aProjectName , '.git');
		location: FileLocator localDirectory / 'iceberg/ombu-creation' / aProjectName;
		createRepository.
	^ repository
]

{ #category : #'file info' }
OmbuFilesOrganizer >> dateOfFirstChangeInFile: anOmbuFile [
	^ (EpLog freshFromFile: anOmbuFile) entries first tagAt: #time
]

{ #category : #entries }
OmbuFilesOrganizer >> entriesInDirectory: aDirectory [
	^ (self ombuFilesInDirectory: aDirectory)
		flatCollect: [ :file | self entriesInFile: file ]
]

{ #category : #entries }
OmbuFilesOrganizer >> entriesInFile: anOmbuFile [
	^ (EpLog freshFromFile: anOmbuFile) entries
]

{ #category : #private }
OmbuFilesOrganizer >> loadProject: aProjectName author: anAuthor branch: aBranchName untilFile: anOmbuFile [
	| repository branch commits dateOfFirstChange |
	repository := self
		createRepositoryFromAuthor: anAuthor
		projectName: aProjectName.
	branch := repository branchNamed: aBranchName.
	commits := branch newCommitWalk commits.
	
	"Reject commits after anOmbuFile"
	dateOfFirstChange := self dateOfFirstChangeInFile: anOmbuFile.
	commits := commits
		reject: [ :commit | commit datetime > dateOfFirstChange ].

	"Apply commit"
	commits first checkout
]

{ #category : #directory }
OmbuFilesOrganizer >> ombuFilesInDirectory: aDirectory [
	^ aDirectory files select: [ :file | file extension = 'ombu' ]
]

{ #category : #'file info' }
OmbuFilesOrganizer >> packageLoadedInFile: anOmbuFile [
	| packages |
	packages := ((self entriesInFile: anOmbuFile)
		select:
			[ :entry | entry wasTriggered ]
		thenCollect: [ :entry | entry content affectedPackageName ]) asSet.
	^ packages reject: [ :name | name isNil or: [ name = 'nil' ] ]
]

{ #category : #'file info' }
OmbuFilesOrganizer >> packageNamesInFile: anOmbuFile [
	| packages |
	packages := ((self entriesInFile: anOmbuFile)
		select:
			[ :entry | entry content isCodeChange and: [ entry wasTriggered not ] ]
		thenCollect: [ :entry | entry content affectedPackageName ]) asSet.
	^ packages reject: [ :name | name isNil or: [ name = 'nil' ] ]
]

{ #category : #directory }
OmbuFilesOrganizer >> packagesInDirectory: aDirectory [
	^ self packagesInFiles: (self ombuFilesInDirectory: aDirectory)
]

{ #category : #entries }
OmbuFilesOrganizer >> packagesInEntries: entries [
	^ (entries
		collect: [ :entry | 
			| event |
			event := entry content.
			(event isCodeChange and: [ (entry tags includesKey: #trigger) not ])
				ifTrue: [ event affectedPackageName ]
				ifFalse: [ nil ] ]
		thenSelect: [ :name | name isNotNil ]) asSet
]

{ #category : #private }
OmbuFilesOrganizer >> packagesInFile: aFile ifIncludePrefix: aPrefix copyTo: aDirectory [
	| packageNames |
	packageNames := self packageNamesInFile: aFile.
	(packageNames anySatisfy: [ :name | name includesSubstring: aPrefix ])
		ifTrue: [ aFile copyTo: aDirectory ]
]

{ #category : #'file info' }
OmbuFilesOrganizer >> packagesInFiles: files [
	^ (files flatCollect: [ :file | self packageNamesInFile: file ])
		asSet
]

{ #category : #directory }
OmbuFilesOrganizer >> packagesLoadedInDirectory: aDirectory [
	^ self packagesLoadedInFiles: (self ombuFilesInDirectory: aDirectory)
]

{ #category : #'file info' }
OmbuFilesOrganizer >> packagesLoadedInFiles: files [
	^ (files flatCollect: [ :file | self packageLoadedInFile: file ])
		asSet
]

{ #category : #private }
OmbuFilesOrganizer >> recompilePackageLoadingMethod [
	EpMonitor current disable.
	IceWorkingCopy
		compile:
			'loadPackagesNamed: aCollection fromCommit: aCommit
	"This method has been recompiled to take into account the packages of the commit and not thoses of the repository "
	packages := (aCommit packages collect: [ :e | e name -> e ])
		asDictionary.
	self
		ignoreNotificationsDuring: [ | loader |
			loader := MCVersionLoader new.
			aCollection
				do: [ :name | 
					| package packageVersion |
					package := self packageNamed: name.
					packageVersion := (IceSavedPackageVersion
						fromCommit: aCommit
						package: package) mcVersion.
					loader addVersion: packageVersion.
					package beClean ].
			loader load ]'.
	EpMonitor current disable
]

{ #category : #entries }
OmbuFilesOrganizer >> rejectEntries: omEntries tagged: aTag value: anObject [
	^ omEntries
		reject:
			[ :entry | (entry tags includesKey: aTag) and: [ (entry tagAt: aTag) = anObject ] ]
]

{ #category : #entries }
OmbuFilesOrganizer >> rejectMCLoadedAndTriggeredEntries: omEntries [
	^ omEntries
		reject: [ :entry | 
			(entry tags includesKey: #trigger)
				or: [ entry content isMonticelloVersionsLoad
						or: [ entry content isMonticelloVersionSave ] ] ]
]

{ #category : #entries }
OmbuFilesOrganizer >> rejectTriggeredEntries: omEntries [
	^ omEntries reject: [ :entry | entry tags includesKey: #trigger ]
]

{ #category : #rename }
OmbuFilesOrganizer >> renameFiles: ombuFiles inProject: aProjectName [
	| sortedFiles |
	sortedFiles := self sortByDate: ombuFiles.
	sortedFiles
		withIndexDo: [ :file :index | 
			file
				renameTo: aProjectName , '_' , index asTwoCharacterString , '.ombu' ]
]

{ #category : #entries }
OmbuFilesOrganizer >> selectEntries: omEntries contentBlock: aBlock [
	^ omEntries select: [ :entry | aBlock value: entry content ]
]

{ #category : #entries }
OmbuFilesOrganizer >> selectEntries: omEntries tagValues: tagsAndValuesDictionary [
	^ omEntries
		select: [ :entry | 
			tagsAndValuesDictionary associations
				anySatisfy: [ :assoc | entry tags includesAssociation: assoc ] ]
]

{ #category : #entries }
OmbuFilesOrganizer >> selectEntries: omEntries tagged: aTag value: anObject [
	^ omEntries
		select:
			[ :entry | (entry tags includesKey: aTag) and: [ (entry tagAt: aTag) = anObject ] ]
]

{ #category : #entries }
OmbuFilesOrganizer >> selectMCLoadedAndTriggeredEntries: omEntries [
	^ omEntries
		select: [ :entry | 
			(entry tags includesKey: #trigger)
				or: [ entry content isMonticelloVersionsLoad
						or: [ entry content isMonticelloVersionSave ] ] ]
]

{ #category : #'file info' }
OmbuFilesOrganizer >> selectMatchingFiles: ombuFiles contentBlock: anEntryContentBlock [
	^ ombuFiles
		select: [ :file | 
			| entries |
			entries := self entriesInFile: file.
			(self selectEntries: entries contentBlock: anEntryContentBlock)
				isNotEmpty ]
]

{ #category : #'file info' }
OmbuFilesOrganizer >> selectMatchingFiles: ombuFiles tagValues: tagsAndValuesDictionary contentBlock: anEntryContentBlock [
	^ ombuFiles
		select: [ :file | 
			| entries |
			entries := self entriesInFile: file.
			(self selectEntries: entries tagValues: tagsAndValuesDictionary)
				isNotEmpty
				or: [ (self selectEntries: entries contentBlock: anEntryContentBlock)
						isNotEmpty ] ]
]

{ #category : #entries }
OmbuFilesOrganizer >> selectTriggeredEntries: omEntries [
	^ omEntries select: [ :entry | entry tags includesKey: #trigger ]
]

{ #category : #rename }
OmbuFilesOrganizer >> sortByDate: ombuFiles [
	^ ombuFiles asSortedCollection
		sortBlock: [ :file1 :file2 | 
			(self dateOfFirstChangeInFile: file1)
				< (self dateOfFirstChangeInFile: file2) ]
]

{ #category : #'ombu creation' }
OmbuFilesOrganizer >> startNewOmbuFile [
	| store |
	store := EpMonitor current sessionStore.
	store resetWithNextStoreName
]

{ #category : #'ombu creation' }
OmbuFilesOrganizer >> startNewOmbuFileNamed: aName [
	| store |
	store := EpMonitor current sessionStore.
	self
		assert: [ (store existsStoreNamed: aName) not ]
		description: 'Ombu file already exists'.
	store resetWithStoreNamed: aName
]
