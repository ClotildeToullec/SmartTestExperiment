"
I store metadata for this package. These meta data are used by other tools such as the SmalllintManifestChecker and the critics Browser
"
Class {
	#name : #ManifestSmartTestExperiment,
	#superclass : #PackageManifest,
	#category : #SmartTestExperiment
}

{ #category : #'code-critics' }
ManifestSmartTestExperiment class >> ruleGRGuradGuardClauseRuleV1FalsePositive [
	^ #(#(#(#RGMethodDefinition #(#ExperimentLauncher #collectMeasurementsPrecision #false)) #'2017-10-30T14:20:54.440485+01:00') #(#(#RGMethodDefinition #(#ExperimentLauncher #logStartOfCodeChange #false)) #'2017-10-30T19:37:41.910412+01:00') #(#(#RGMethodDefinition #(#ExperimentLauncherMeasurements #printOn: #false)) #'2017-11-06T20:42:00.195676+01:00') )
]

{ #category : #'code-critics' }
ManifestSmartTestExperiment class >> ruleRBClassNotReferencedRuleV1FalsePositive [
	^ #(#(#(#RGClassDefinition #(#ExperimentLauncher)) #'2017-10-28T21:54:17.764174+02:00') )
]

{ #category : #'code-critics' }
ManifestSmartTestExperiment class >> ruleRBCodeCruftLeftInMethodsRuleV1FalsePositive [
	^ #(#(#(#RGMethodDefinition #(#'ExperimentLauncher class' #sortOmbuFilesIn: #true)) #'2017-12-24T10:10:39.466373+01:00') )
]

{ #category : #'code-critics' }
ManifestSmartTestExperiment class >> ruleRBCollectionMessagesToExternalObjectRuleV1FalsePositive [
	^ #(#(#(#RGMethodDefinition #(#ExperimentLauncher #createOracle #false)) #'2017-10-28T21:54:05.843324+02:00') #(#(#RGMethodDefinition #(#ExperimentLauncher #addToTestResultCovered:byTestcase:selector: #false)) #'2017-10-30T15:05:55.070025+01:00') )
]

{ #category : #'code-critics' }
ManifestSmartTestExperiment class >> ruleRBCollectionProtocolRuleV1FalsePositive [
	^ #(#(#(#RGMethodDefinition #(#ExperimentLauncher #collectMeasurementsPrecision #false)) #'2017-11-03T09:33:47.37329+01:00') )
]

{ #category : #'code-critics' }
ManifestSmartTestExperiment class >> ruleRBExcessiveVariablesRuleV1FalsePositive [
	^ #(#(#(#RGClassDefinition #(#ExperimentLauncher)) #'2017-10-28T15:57:41.325995+02:00') )
]

{ #category : #'code-critics' }
ManifestSmartTestExperiment class >> ruleRBFileBlocksRuleV1FalsePositive [
	^ #(#(#(#RGMethodDefinition #(#ExperimentLauncherMeasurements #exportToCSV: #false)) #'2017-12-15T11:22:11.289063+01:00') )
]

{ #category : #'code-critics' }
ManifestSmartTestExperiment class >> ruleRBGuardingClauseRuleV1FalsePositive [
	^ #(#(#(#RGMethodDefinition #(#ExperimentLauncher #collectMeasurementsPrecision #false)) #'2017-10-30T14:20:51.148449+01:00') #(#(#RGMethodDefinition #(#ExperimentLauncher #logStartOfCodeChange #false)) #'2017-10-30T19:37:45.855698+01:00') #(#(#RGMethodDefinition #(#ExperimentLauncherMeasurements #printOn: #false)) #'2017-11-06T20:42:02.76988+01:00') )
]

{ #category : #'code-critics' }
ManifestSmartTestExperiment class >> ruleRBInconsistentMethodClassificationRuleV1FalsePositive [
	^ #(#(#(#RGMethodDefinition #(#ExperimentLauncherMeasurements #initialize #false)) #'2017-11-01T08:50:50.959879+01:00') #(#(#RGMethodDefinition #(#ExperimentLauncher #initialize #false)) #'2017-11-01T08:51:54.090849+01:00') )
]

{ #category : #'code-critics' }
ManifestSmartTestExperiment class >> ruleRBLongMethodsRuleV1FalsePositive [
	^ #(#(#(#RGMethodDefinition #(#ExperimentLauncher #collectMeasurementsPrecision #false)) #'2017-11-01T09:09:10.584533+01:00') #(#(#RGMethodDefinition #(#TestExperimentLauncherMeasurements #testAlphaOmega #false)) #'2017-11-02T15:54:31.953442+01:00') #(#(#RGMethodDefinition #(#ExperimentLauncher #createOracle #false)) #'2017-11-03T09:53:30.296189+01:00') #(#(#RGMethodDefinition #(#ExperimentLauncher #collectMeasurementsCodechurn #false)) #'2017-11-21T21:15:57.387624+01:00') #(#(#RGMethodDefinition #(#ExperimentLauncherMeasurements #printOn: #false)) #'2017-11-22T14:22:25.900204+01:00') )
]

{ #category : #'code-critics' }
ManifestSmartTestExperiment class >> ruleRBMissingTranslationsInMenusRuleV1FalsePositive [
	^ #(#(#(#RGMethodDefinition #(#ExperimentLauncherMeasurements #visualisePrecisionBarChart #false)) #'2017-11-08T08:20:47.891248+01:00') #(#(#RGMethodDefinition #(#ExperimentLauncherMeasurements #visualisePrecisionAreaChart #false)) #'2017-11-21T14:23:58.899845+01:00') #(#(#RGMethodDefinition #(#ExperimentLauncherMeasurements #visualiseCodeChurnBarChart #false)) #'2017-11-21T21:22:41.855579+01:00') )
]

{ #category : #'code-critics' }
ManifestSmartTestExperiment class >> ruleRBSendsDifferentSuperRuleV1FalsePositive [
	^ #(#(#(#RGMethodDefinition #(#ExperimentLauncherMeasurements #initialize: #false)) #'2017-11-06T19:47:54.041654+01:00') )
]

{ #category : #'code-critics' }
ManifestSmartTestExperiment class >> ruleRBStringConcatenationRuleV1FalsePositive [
	^ #(#(#(#RGMethodDefinition #(#ExperimentLauncher #run #false)) #'2017-12-08T16:05:39.932518+01:00') #(#(#RGMethodDefinition #(#ExperimentLauncher #dryrun #false)) #'2018-01-11T19:29:25.239617+01:00') )
]

{ #category : #'code-critics' }
ManifestSmartTestExperiment class >> ruleRBUtilityMethodsRuleV1FalsePositive [
	^ #(#(#(#RGMethodDefinition #(#ExperimentLauncher #calculateDiffBetween:and: #false)) #'2017-11-21T22:10:54.937522+01:00') )
]
