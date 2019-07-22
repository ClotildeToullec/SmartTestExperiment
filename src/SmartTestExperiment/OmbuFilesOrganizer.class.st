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

{ #category : #'file info' }
OmbuFilesOrganizer >> packageNamesInFile: anOmbuFile [
	| allPackages |
	allPackages := ((EpLog freshFromFile: anOmbuFile) entries
		select:
			[ :entry | entry content isCodeChange and: [ entry wasTriggered not ] ]
		thenCollect: [ :entry | entry content affectedPackageName ]) asSet.
	^ allPackages reject: [ :name | name isNil or: [ name = 'nil' ] ]
]

{ #category : #'file info' }
OmbuFilesOrganizer >> packagesInFiles: files [
	^ (files flatCollect: [ :file | self packageNamesInFile: file ])
		asSet
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

{ #category : #rename }
OmbuFilesOrganizer >> sortByDate: ombuFiles [
	^ ombuFiles asSortedCollection
		sortBlock: [ :file1 :file2 | 
			(self dateOfFirstChangeInFile: file1)
				< (self dateOfFirstChangeInFile: file2) ]
]
