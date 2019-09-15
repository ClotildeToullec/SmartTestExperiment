Class {
	#name : #BaselineOfSmartTestExperiment,
	#superclass : #BaselineOf,
	#category : #BaselineOfSmartTestExperiment
}

{ #category : #baselines }
BaselineOfSmartTestExperiment >> baseline: spec [
	<baseline>
	spec
		baseline: 'NeoCSV'
		with: [ spec repository: 'github://svenvc/NeoCSV/repository' ].
	spec
		baseline: 'OSSubprocess'
		with: [ spec
				repository: 'github://pharo-contributions/OSSubprocess:master/repository' ].
	spec
		baseline: 'SmartTest'
		with: [ spec
				repository: 'github://badetitou/SmartTest:development/repository' ].
	spec
		baseline: 'Roassal2'
		with: [ spec repository: 'github://ObjectProfile/Roassal2/src' ].
	spec for: #common do: [ spec package: 'SmartTestExperiment' ]
]
