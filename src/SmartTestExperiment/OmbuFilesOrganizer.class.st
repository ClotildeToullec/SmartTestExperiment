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
	#category : #'SmartTestExperiment-analysis'
}

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
OmbuFilesOrganizer >> loadProject: aProjectName branch: aBranchName untilFile: anOmbuFile [
	| repository commits dateOfFirstChange |
	self
		flag:
			'This does not work if the repository does not exist. TODO: automatically create the repository'.
	repository := IceLibgitRepository allInstances
		detect: [ :repo | repo name = aProjectName ].
	dateOfFirstChange := self dateOfFirstChangeInFile: anOmbuFile.
	commits := (repository branchNamed: aBranchName) commits.
	commits := commits
		reject: [ :commit | commit datetime > dateOfFirstChange ].
	commits
		sort: [ :commit1 :commit2 | commit1 datetime < commit2 datetime ].
	commits last checkout
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

{ #category : #'working session reset' }
OmbuFilesOrganizer >> startNewOmbuFile [
	"This method will reset the image WorkingSession. The OmSessionStore detects this reset and thus starts a new Ombu file."

	[ SessionManager default currentSession uninstall ]
		ensure: [ SessionManager default installNewSession ]
]
