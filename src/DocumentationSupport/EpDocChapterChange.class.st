Class {
	#name : #EpDocChapterChange,
	#superclass : #EpDocChange,
	#instVars : [
		'key',
		'title',
		'parentKey',
		'libraryKey',
		'nextChapterKey',
		'source'
	],
	#category : #'DocumentationSupport-Model'
}

{ #category : #accessing }
EpDocChapterChange >> fullStringForDisplay [

	^ 'Title: “{1}”
Key: {2}, Parent: {3}, Library: {4}
----------------------------------
{5}
' format: { self title asString. self key asString. self parentKey asString. self libraryKey asString.. self source asString }
]

{ #category : #testing }
EpDocChapterChange >> isCodeChange [

	^ true
]

{ #category : #accessing }
EpDocChapterChange >> key [

	^ key
]

{ #category : #accessing }
EpDocChapterChange >> key: anObject [

	key := anObject
]

{ #category : #accessing }
EpDocChapterChange >> libraryKey [

	^ libraryKey
]

{ #category : #accessing }
EpDocChapterChange >> libraryKey: anObject [

	libraryKey := anObject
]

{ #category : #accessing }
EpDocChapterChange >> nextChapterKey [

	^ nextChapterKey
]

{ #category : #accessing }
EpDocChapterChange >> nextChapterKey: anObject [

	nextChapterKey := anObject
]

{ #category : #accessing }
EpDocChapterChange >> parentKey [

	^ parentKey
]

{ #category : #accessing }
EpDocChapterChange >> parentKey: anObject [

	parentKey := anObject
]

{ #category : #accessing }
EpDocChapterChange >> source [

	^ source
]

{ #category : #accessing }
EpDocChapterChange >> source: anObject [

	source := anObject
]

{ #category : #accessing }
EpDocChapterChange >> title [

	^ title
]

{ #category : #accessing }
EpDocChapterChange >> title: anObject [

	title := anObject
]
