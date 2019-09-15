"
The ImageRunner subclass used by TimeAndMemoryExperiment
"
Class {
	#name : #UnixImageRunner,
	#superclass : #ImageRunner,
	#category : #'SmartTestExperiment-Time-Memory'
}

{ #category : #'launching images' }
UnixImageRunner >> createLaunchCommandForImage: imageFileReference withParameters: aCollection [
	| imagePath vmDirectoryPath |
	imagePath := imageFileReference pathString.
	vmDirectoryPath := self class vmCommand asFileReference parent fullName.
	^ String
		streamContents: [ :cmd | 
			cmd << 'cd ' << (self surroundByDoubleQuotes: imageFileReference parent pathString ) << ' && '.
			cmd << (self exportLDLibraryPathCommandWith: vmDirectoryPath).
			cmd << ' && export SQUEAK_PLUGINS="" && '.
			cmd << (self surroundByDoubleQuotes: self class vmCommand).
			cmd << ' ' << (self surroundByDoubleQuotes: imagePath).
			aCollection do: [ :param | cmd << ' ' << (self surroundByDoubleQuotes: param) ]
	 ]
]

{ #category : #'launching images' }
UnixImageRunner >> runImage: imageFileReference withParameters: aCollection [
	OSSUnixSubprocess new	
		command: 'bash';
		arguments: { '-l' . '-c' . self createLaunchCommandForImage: imageFileReference withParameters: aCollection } ;
		run.
]
