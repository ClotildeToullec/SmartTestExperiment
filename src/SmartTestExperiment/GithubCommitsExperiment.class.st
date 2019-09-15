"
I AM NOT FUNCTIONAL YET
|
| I am responsible of running SmartTest analyses using Git commits.
| I am specialized from ExperimentLauncher.
|
| My aim is to start from the first (second) commit of a Github project and load commit by commit.
| After each commit load, I create an Oracle and run SmartTest analyses. 
| I then compare SmartTest results with the Oracle, like ExperimentLauncher.
| The cache for dynamic analyses should be built before loading a commit (so new cache = the Oracle).
| 
| 
V
To be functional, I need to access the methods modified between two commits as support for a SmartTest analysis.
"
Class {
	#name : #GithubCommitsExperiment,
	#superclass : #STExperimentLauncher,
	#instVars : [
		'commitsApplier'
	],
	#category : #'SmartTestExperiment-Ombu'
}

{ #category : #accessing }
GithubCommitsExperiment >> prepareWithAuthor: anAuthor project: aProject [
	commitsApplier := GithubCommitsOmbuCreator
		newForAuthor: anAuthor
		project: aProject.
	commitsApplier
		recompilePackageLoadingMethod;
		createRepository
]

{ #category : #accessing }
GithubCommitsExperiment >> runAnalysisOnChanges: allCommitChanges [
	"This method is executed AFTER a commit checkout.
		It supposes that we can access to the code changes that occured since the last commit"

	| changes |
	"Build oracle = future cache"
	self updateOracle.

	"Analysis on all changes since the last commit.
		- Select changes that need a SmartTest analysis"
	changes := allCommitChanges
		select: [ :change | self smartTestInterventionNeeded: change ].
	self
		flag:
			'smartTestInterventionNeeded: will probably need to be modified, since we do not give it a collection of OmEntry'.

	"	- Run an analysis for each change
		- Compare to Oracle after each change"
	changes
		do: [ :change | 
			currentEntry := change.
			self runSmartTestAnalysis.
			self measurePrecision ].
	self
		flag:
			'We have to separate results by commits yet to show results for every method'.

	"Use oracle as cache for the next commit. With 'No cache' strategy, setCacheValues: has no effect . "
	smTFinders valuesDo: [ :finder | finder setCacheValues: oracle copy ]
]

{ #category : #accessing }
GithubCommitsExperiment >> runOn: aBranchName [
	commitsApplier
		applyAllComitsInBranch: aBranchName
		andRun: [ :commit | self runAnalysisOnChanges: commit ].
	self flag: 'Not the commit but the changes'
]

{ #category : #'oracle creation' }
GithubCommitsExperiment >> updateOracle [
	| ts |
	self manageBuildOracle.
	ts := TestSuite new.
	ts addTests: collectionOfTestSuites.
	self createOracle
]
