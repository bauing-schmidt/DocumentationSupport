Class {
	#name : #EpDocLogger,
	#superclass : #Object,
	#classInstVars : [
		'changes',
		'mutex',
		'loggingProcess'
	],
	#category : #'DocumentationSupport-Model'
}

{ #category : #accessing }
EpDocLogger class >> addChange: aChange [ 

	self critical: [ 

		self changes add: aChange.
		
		aChange immediateStoring ifTrue: [ 
			^ self storeChangesImmediately.
		].
		
		self ensureLoggingProcess.
	]
]

{ #category : #accessing }
EpDocLogger class >> changes [ 

	^ changes ifNil: [ changes := OrderedCollection new ].
]

{ #category : #accessing }
EpDocLogger class >> critical: aBlock [

	mutex ifNil: [ mutex := Mutex new ].
	
	mutex critical: aBlock
]

{ #category : #accessing }
EpDocLogger class >> ensureLoggingProcess [

	loggingProcess ifNotNil: [ ^ loggingProcess ].
	
	loggingProcess := [ 
		self loggingProcessAction
	] forkNamed: 'EpDocLogger logging process'
]

{ #category : #accessing }
EpDocLogger class >> has: aChange newerVersionIn: changesCollection starting: anIndex [ 

	anIndex to: changesCollection size do: [ :i |
		| otherChange |
		otherChange := self changes at: i.
		(aChange isOlderVersionOf: otherChange) ifTrue: [ ^ true ]
	].
	^ false
]

{ #category : #accessing }
EpDocLogger class >> initialize [
	SessionManager default registerUserClassNamed: self name
]

{ #category : #accessing }
EpDocLogger class >> loggingProcessAction [ 

	self waitInterval wait.
	self critical: [ 
		self storeChanges.
		loggingProcess := nil.
	].
]

{ #category : #accessing }
EpDocLogger class >> shutDown: quitting [

	self critical: [ 
		self storeChangesImmediately. ]
]

{ #category : #accessing }
EpDocLogger class >> storeChanges [ 

	| filteredChanges |
	
	self changes ifEmpty: [ ^ self ].
	
	filteredChanges := OrderedCollection new.
	
	self changes withIndexDo: [ :change :index | 
		(self has: change newerVersionIn: self changes starting: index+1) 
			ifFalse: [ filteredChanges add: change ]
	].

	filteredChanges do: [ :change |
		EpMonitor current addEvent: change ].
	
	changes := OrderedCollection new.
]

{ #category : #accessing }
EpDocLogger class >> storeChangesImmediately [ 

	self storeChanges.
	loggingProcess ifNotNil: [ :p | p terminate ].
	loggingProcess := nil.
]

{ #category : #accessing }
EpDocLogger class >> waitInterval [ 

	^ 10 seconds
]
