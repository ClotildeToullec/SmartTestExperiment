Class {
	#name : #BaselineOfSmartTestExperiment,
	#superclass : #BaselineOf,
	#category : #BaselineOfSmartTestExperiment
}

{ #category : #baselines }
BaselineOfSmartTestExperiment >> baseline: spec [
	<baseline>
	spec for: #common do: [ spec package: 'SmartTestExperiment' ]
]
