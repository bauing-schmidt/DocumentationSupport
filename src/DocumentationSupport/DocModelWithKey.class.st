"
A model with unique key and title.

key			- unique key, should not be modified 
title  	- chapter or book title
parent   - parent library or book
library  - owning library
"
Class {
	#name : #DocModelWithKey,
	#superclass : #DocModel,
	#instVars : [
		'title',
		'key',
		'parent',
		'library'
	],
	#category : #'DocumentationSupport-Model'
}

{ #category : #'drag and drop' }
DocModelWithKey >> acceptChapter: aChapter [ 

	self subclassResponsibility 
]

{ #category : #'drag and drop' }
DocModelWithKey >> acceptDrop: chapters [

	chapters do: [ :each | self acceptChapter: each ] 
]

{ #category : #visiting }
DocModelWithKey >> acceptVisitor: arg1 [ 
	^ self subclassResponsibility
]

{ #category : #serialization }
DocModelWithKey >> addMetadataTo: aDictionary [ 

	aDictionary
		at: #title put: title;
		at: #key put: key;
		at: #parent put: self parentKeyOrNil
]

{ #category : #adding }
DocModelWithKey >> addNewChapter [
	^ self subclassResponsibility

]

{ #category : #accessing }
DocModelWithKey >> book [

	^ self parent 
		ifNil: [ self ]
		ifNotNil: [ :aParent | aParent book ]
		
]

{ #category : #accessing }
DocModelWithKey >> children [
	^ self subclassResponsibility

]

{ #category : #dirty }
DocModelWithKey >> dirty [ 

	^ self library dirty 
]

{ #category : #serialization }
DocModelWithKey >> fromSton: stonReader [
	stonReader parseMapDo: [ :aKey :value |
		self readStonKey: aKey value: value ]
	
]

{ #category : #initialization }
DocModelWithKey >> initialize [ 

	super initialize.
	
	title := '<no title>'.
	key := UUID new asString36.
]

{ #category : #testing }
DocModelWithKey >> isBook [ 

	^ false
]

{ #category : #testing }
DocModelWithKey >> isChapter [

	^ false
]

{ #category : #testing }
DocModelWithKey >> isParentReference [ 

	^ false
]

{ #category : #accessing }
DocModelWithKey >> key [

	^ key
]

{ #category : #accessing }
DocModelWithKey >> key: anObject [

	key := anObject.
	self makeDirty.
	self aspectChanged: #title

]

{ #category : #accessing }
DocModelWithKey >> library [

	^ library
]

{ #category : #accessing }
DocModelWithKey >> library: anObject [

	library := anObject
]

{ #category : #accessing }
DocModelWithKey >> libraryKeyOrNil [

	library ifNil: [ ^ nil ].
	
	^ library key
]

{ #category : #dirty }
DocModelWithKey >> makeDirty [ 

	^ self library ifNotNil: [ :lib | lib makeDirty ]
]

{ #category : #accessing }
DocModelWithKey >> name [ 

	^ self title
]

{ #category : #accessing }
DocModelWithKey >> parent [

	^ parent
]

{ #category : #accessing }
DocModelWithKey >> parent: anObject [

	parent := anObject
]

{ #category : #accessing }
DocModelWithKey >> parentKeyOrNil [

	parent ifNil: [ ^ nil ].
	
	^ parent key
]

{ #category : #serialization }
DocModelWithKey >> readMetadataFrom: aDictionary [
	aDictionary at: #title ifPresent: [ :value | title := value ].
	aDictionary at: #key ifPresent: [ :value | key := value ].
	aDictionary at: #parent ifPresent: [ :value | parent := DocParentReference key: value ].
	
	
	
]

{ #category : #serialization }
DocModelWithKey >> readStonKey: aKey value: value [

	aKey = #title ifTrue: [ title := value ].
	aKey = #key ifTrue: [ key := value ].
	aKey = #parent ifTrue: [ parent := DocParentReference key: value ] 
	
]

{ #category : #accessing }
DocModelWithKey >> setLibrary: aLibrary [ 

	library := aLibrary.
]

{ #category : #sorting }
DocModelWithKey >> sortedChapters: chaptersCollection [

	| sorted chain |
	
	chaptersCollection ifEmpty: [ ^ chaptersCollection ].
	
	sorted := chaptersCollection sorted: [ :a :b | 
		a title <= b title ].
	
	sorted size timesRepeat: [ 
		chain := OrderedCollection new.
		chain add: sorted first.		
		sorted do: [ :each | 
			each nextChapter isNil
				ifTrue: [ 
					(chain includes: each)
						ifFalse: [
							(chaptersCollection includes: each)
								ifTrue: [chain add: each ]]]
				ifFalse: [ 
					(chain includes: each nextChapter)
						ifTrue: [ 
							(chain includes: each)
								ifFalse: [ 
									(chaptersCollection includes: each)
										ifTrue: [
											chain add: each before: each nextChapter ]] ]
						ifFalse: [ 
							(chain includes: each)
								ifTrue: [ 
									(chaptersCollection includes: each nextChapter)
										ifTrue: [
											chain add: each nextChapter after: each ] ]
								ifFalse: [
									(chaptersCollection includes: each)
										ifTrue: [ chain add: each ].
									((chaptersCollection includes: each nextChapter)
										and: [ each ~= each nextChapter ])
										ifTrue: [ chain add: each nextChapter ] ] ]]].
		sorted := chain copy ].
				
	^ chain
]

{ #category : #serialization }
DocModelWithKey >> stonOn: stonWriter [	
	stonWriter writeObject: self streamMap: [ :dictionary |
		self writeStonKeysTo: dictionary ]
]

{ #category : #accessing }
DocModelWithKey >> title [

	^ title
]

{ #category : #accessing }
DocModelWithKey >> title: anObject [

	title := anObject.
	self makeDirty.

	self aspectChanged: #title.
	self library aspectChanged: #hierarchyNames.


]

{ #category : #serialization }
DocModelWithKey >> writeStonKeysTo: aDictionary [ 
	aDictionary
		at: #title put: title;
		at: #key put: key;
		at: #parent put: self parentKeyOrNil
]
