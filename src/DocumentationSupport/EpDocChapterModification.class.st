Class {
	#name : #EpDocChapterModification,
	#superclass : #EpDocChapterChange,
	#category : #'DocumentationSupport-Model'
}

{ #category : #visitor }
EpDocChapterModification >> accept: aVisitor [

	^ aVisitor visitDocChapterModification: self
]

{ #category : #visitor }
EpDocChapterModification >> immediateStoring [ 

	^ false
]

{ #category : #visitor }
EpDocChapterModification >> isOlderVersionOf: anotherChange [ 

	(self class = anotherChange class) ifFalse: [ ^ false ].
	
	key = anotherChange key ifFalse: [ ^ false ].
	libraryKey = anotherChange libraryKey ifFalse: [ ^ false ].	
	nextChapterKey = anotherChange nextChapterKey ifFalse: [ ^ false ].		
	parentKey = anotherChange parentKey ifFalse: [ ^ false ].
	"title and source can be different"
		
	^ true
]
