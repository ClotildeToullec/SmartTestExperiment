"
Utility to run child images from a main image

Adapted from the launcher
"
Class {
	#name : #ImageRunner,
	#superclass : #Object,
	#category : #'SmartTestExperiment-timeAndMem'
}

{ #category : #'as yet unclassified' }
ImageRunner class >> platformRunner [
	"should test other platforms"
	^UnixImageRunner new
]

{ #category : #accessing }
ImageRunner class >> vmCommand [
	^ "'/home/anquetil/Pharo/vms/70-x86/pharo'"
	'/home/clotilde/Pharo/vms/70-x86/pharo'
]

{ #category : #'launching images' }
ImageRunner >> cleanLDLibraryPath [
	^ (self currentLDLibraryPathes
		reject: [ :path | path asByteArray utf8Decoded = Smalltalk vmDirectory ])

]

{ #category : #'launching images' }
ImageRunner >> createLaunchCommandForImage: imageFileReference withParameters: aCollection [
	| imagePath vmDirectoryPath command |
	imagePath := imageFileReference pathString.
	vmDirectoryPath := self class vmCommand asFileReference parent fullName.
	command := String
		streamContents: [ :cmd | 
			cmd << 'cd ' << (self surroundByDoubleQuotes: imageFileReference parent pathString ) << ' && '.
			cmd << (self exportLDLibraryPathCommandWith: vmDirectoryPath).
			cmd << ' && export SQUEAK_PLUGINS="" && '.
			cmd << (self surroundByDoubleQuotes: self class vmCommand).
			cmd << ' ' << (self surroundByDoubleQuotes: imagePath).
			aCollection do: [ :param | cmd << ' ' << (self surroundByDoubleQuotes: param) ]
	 ].
	^  'bash -l -c ''' , command , ''''
]

{ #category : #'launching images' }
ImageRunner >> currentLDLibraryPathes [
	^ ((OSEnvironment current at: 'LD_LIBRARY_PATH' ifAbsent: [ nil ])
		ifNil: [ '' ]) substrings: ':'
]

{ #category : #'launching images' }
ImageRunner >> exportLDLibraryPathCommandWith: vmDirectoryPath [
	^ 'export LD_LIBRARY_PATH=' ,
		($: join: ((self cleanLDLibraryPath copyWithFirst: vmDirectoryPath) collect: #surroundedBySingleQuotes))

]

{ #category : #'launching images' }
ImageRunner >> runImage: imageFileReference withParameters: aCollection [
	self flag: 'Old OSProcess way of doing thing. Not working in Pharo7. overloaded in subclass'.
	OSProcess command: (self createLaunchCommandForImage: imageFileReference withParameters: aCollection)
]

{ #category : #strings }
ImageRunner >> surroundByDoubleQuotes: aString [
	^ aString surroundedBy: ($" asString)
]
