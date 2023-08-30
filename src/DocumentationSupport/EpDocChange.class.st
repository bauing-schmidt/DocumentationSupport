"
Announce Calypso changed focus to another method, class or similar object
"
Class {
	#name : #EpDocChange,
	#superclass : #EpEvent,
	#category : #'DocumentationSupport-Model'
}

{ #category : #visitor }
EpDocChange >> accept: aVisitor [

	^ aVisitor visitDocChange: self
]

{ #category : #visitor }
EpDocChange >> immediateStoring [ 

	"want to immediate store to Epicea?"
	
	^ true
]

{ #category : #testing }
EpDocChange >> isOlderVersionOf: anotherChange [ 

	^ false
]
