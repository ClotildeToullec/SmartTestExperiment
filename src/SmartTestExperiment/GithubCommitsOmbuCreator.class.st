"
I apply all commits from a GitHub project.

Instance creation: 
	GithubCommitsApplier author: theGitHubOwner project: theGitHubProjectName.
This will create the repository, located in YourImageDirectory/pharo-local/iceberg/ombu-creation/theGitHubProjectName.

You can then apply commits from a branch one by one:
	self applyAllComitsInBranch: 'master'.
The triggered code changes will be seen in YourImageDirectory/pharo-local/ombu-sessions/theGitHubProjectName.ombu
"
Class {
	#name : #GithubCommitsOmbuCreator,
	#superclass : #Object,
	#instVars : [
		'author',
		'project',
		'repository',
		'commits'
	],
	#category : #'SmartTestExperiment-Ombu'
}

{ #category : #accessing }
GithubCommitsOmbuCreator class >> newForAuthor: anAuthor project: aProjectName [
	^ self new
		author: anAuthor
		project: aProjectName;
		yourself
]

{ #category : #'ombu creation' }
GithubCommitsOmbuCreator >> applyAllComitsInBranch: aBranchName [
	self recompilePackageLoadingMethod.
	OmbuFilesOrganizer new startNewOmbuFileNamed: project.
	commits := (repository branchNamed: aBranchName) newCommitWalk
		commits.
	self checkoutCommits
]

{ #category : #'ombu creation' }
GithubCommitsOmbuCreator >> applyAllComitsInBranch: aBranchName andRun: aBlock [
	self recompilePackageLoadingMethod.
	OmbuFilesOrganizer new startNewOmbuFileNamed: project.
	commits := (repository branchNamed: aBranchName) newCommitWalk
		commits.
	self checkoutCommitsRunning: aBlock
]

{ #category : #initialization }
GithubCommitsOmbuCreator >> author: anAuthor project: aProjectName [
	author := anAuthor.
	project := aProjectName
]

{ #category : #'ombu creation' }
GithubCommitsOmbuCreator >> checkoutCommits [
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
GithubCommitsOmbuCreator >> checkoutCommitsRunning: aBlock [
	UIManager default
		displayProgress: 'Checking out commits and run analysis'
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
					aBlock value.
					bar increment ] ]
]

{ #category : #'ombu creation' }
GithubCommitsOmbuCreator >> createRepository [
	self
		flag:
			'For now, Error if the repository already exists. Todo: Get the existing repository, tu use it or to remove it.'.
	repository := IceRepositoryCreator new
		remote:
			(IceGitRemote
				url: 'https://github.com/' , author , '/' , project , '.git');
		location: FileLocator localDirectory / 'iceberg' / 'ombu-creation' / project;
		createRepository
]

{ #category : #'getting diff' }
GithubCommitsOmbuCreator >> getDiffBetweenCommits [
	commits := commits reverse.
	^ commits second changesFromCommit: commits first
	"These changes are IceGitChange."
]

{ #category : #'getting diff' }
GithubCommitsOmbuCreator >> getDiffBetweenFirstCommitsInBranch: aBranchName [
	self recompilePackageLoadingMethod.
	OmbuFilesOrganizer new startNewOmbuFileNamed: project.
	commits := (repository branchNamed: aBranchName) newCommitWalk
		commits.
	^ self getDiffBetweenCommits
]

{ #category : #private }
GithubCommitsOmbuCreator >> recompilePackageLoadingMethod [
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
