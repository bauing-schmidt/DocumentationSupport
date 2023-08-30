Class {
	#name : #EpDocChapterAddition,
	#superclass : #EpDocChapterChange,
	#category : #'DocumentationSupport-Model'
}

{ #category : #visitor }
EpDocChapterAddition >> accept: aVisitor [

	^ aVisitor visitDocChapterAddition: self
]
