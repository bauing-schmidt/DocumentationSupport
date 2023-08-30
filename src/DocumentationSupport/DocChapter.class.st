"
Single documentation Chapter
"
Class {
	#name : #DocChapter,
	#superclass : #DocModelWithKey,
	#instVars : [
		'source',
		'nextChapter',
		'ast',
		'monospaceTexts',
		'chapterText',
		'chapterTextString',
		'chapterTextStringLowercase',
		'monospaceSearchResults'
	],
	#classInstVars : [
		'dictionaryOfChapters'
	],
	#category : #'DocumentationSupport-Model'
}

{ #category : #adding }
DocChapter class >> addDictionaryOfChapters: aChapter [
	dictionaryOfChapters ifNil: [ dictionaryOfChapters := OrderedDictionary new ].
	dictionaryOfChapters at: aChapter key put: aChapter
]

{ #category : #accessing }
DocChapter class >> dictionnaryOfChapters [
	^ dictionaryOfChapters
]

{ #category : #accessing }
DocChapter class >> dictionnaryOfChaptersAt: aKey [
	^ dictionaryOfChapters at: aKey
]

{ #category : #adding }
DocChapter class >> removeDictionaryOfChapters: aChapter [
	dictionaryOfChapters ifNotNil: [ dictionaryOfChapters removeKey: aChapter key ].

]

{ #category : #accessing }
DocChapter >> aBookOrChapter [

	^ #()
]

{ #category : #'drag and drop' }
DocChapter >> acceptChapter: aChapter [ 
	
	| aMenu |
	
	aChapter = self ifTrue: [ ^ self ].
	
	aMenu := SpMenuPresenter new.

	aMenu addItem: [ :item | 
		item
			name: 'Set as next chapter'; 
			action: [ self setAsNextChapter: aChapter ] ].

	aMenu addItem: [ :item | 
		item 
			name: 'Move'; 
			action: [ self acceptMove: aChapter  ] ].

	aMenu openWithSpecAtPointer.

]

{ #category : #'drag and drop' }
DocChapter >> acceptMove: aChapter [
	
	aChapter library = self library ifFalse: [ ^ self ].
	(aChapter hasSubchapter: self) ifTrue: [ ^ self ].
	
	(aChapter book = self book) ifFalse: [ 
		aChapter withAllSubchapters do: [ :each |
			self book takeChapter: each ] ].
	
	aChapter parent: self.
	
	library aspectChanged: #chapters.

]

{ #category : #visiting }
DocChapter >> acceptVisitor: aVisitor [ 

	aVisitor visitChapter: self
]

{ #category : #'API - search' }
DocChapter >> addMatchingMonospaceText: aString to: aCollection [

	monospaceTexts do: [ :each | 
		each substring = aString
			ifTrue: [ aCollection add: each ] ]

	

]

{ #category : #serialization }
DocChapter >> addMetadataTo: aDictionary [ 

	super addMetadataTo: aDictionary.
	aDictionary 	at: #nextChapter put: self nextKeyOrNil.
]

{ #category : #adding }
DocChapter >> addNewChapter [ 

	| newChapter |
	
	newChapter := self book addNewChapterWithoutNotification. 
	newChapter parent: self.
	library aspectChanged: #chapters.
	DocChapter addDictionaryOfChapters: newChapter.
	EpMonitor current addEvent: newChapter asEpDocChapterAddition.
	^ newChapter
]

{ #category : #converting }
DocChapter >> asEpDocChapterAddition [

	^ EpDocChapterAddition new
		key: self key;
		title: self title;
		parentKey: self parentKeyOrNil;
		libraryKey: self libraryKeyOrNil;
		nextChapterKey: self nextChapterKeyOrNil;
		source: self source;
		yourself
]

{ #category : #converting }
DocChapter >> asEpDocChapterModification [

	^ EpDocChapterModification new
		key: self key;
		title: self title;
		parentKey: self parentKeyOrNil;
		libraryKey: self libraryKeyOrNil;
		nextChapterKey: self nextChapterKeyOrNil;
		source: self source;
		yourself
]

{ #category : #events }
DocChapter >> aspectChanged: aSymbol [ 

	super aspectChanged: aSymbol.
	EpDocLogger addChange: self asEpDocChapterModification.

]

{ #category : #accessing }
DocChapter >> ast [ 

	^ ast
]

{ #category : #removing }
DocChapter >> chapterRemoved: anotherChapter [ 

	nextChapter = anotherChapter ifTrue: [ 
		self nextChapter: nil ].
]

{ #category : #'API - search' }
DocChapter >> chapterTextString [

	^ chapterTextString
]

{ #category : #'API - search' }
DocChapter >> chapterTextStringLowercase [

	^ chapterTextStringLowercase
]

{ #category : #accessing }
DocChapter >> children [

	^ self sortedChapters: (self book chapters select: [ :each | each parent = self ])
	

]

{ #category : #accessing }
DocChapter >> css [ 
	
	^ DocBook defaultStyles

"	| rootChapter |
	rootChapter := self rootChapter.
	^ DocBook cssAt: rootChapter key ifAbsent: [ DocBook defaultStyles ].
	"
	
]

{ #category : #removing }
DocChapter >> delete [ 

	self book deleteChapter: self.
	self makeDirty.
	library aspectChanged: #chapters.


]

{ #category : #'API - search' }
DocChapter >> findMonospaceText: aString [ 

	| resultEntries |
	
	resultEntries := OrderedCollection new.

	monospaceTexts do: [ :each | 
		each substring = aString
			ifTrue: [ 
				| newEntry |
				newEntry := DocResultEntry 
					chapter: self 
					startPosition: each start 
					endPosition: each end
					scrollValue: 0.0.
				resultEntries add: newEntry ]].
		
	^ resultEntries
]

{ #category : #'API - search' }
DocChapter >> findNextString: aSearchPattern startingAt: currentSearchPosition restrictedBy: limitIndex withSensitiveCase: aBoolean [

	| foundPosition tree text lines1 lines2 |
	tree := self ast.
	
	text := aBoolean 
		ifFalse: [ chapterTextStringLowercase ] 
		ifTrue: [ chapterTextString ].
	foundPosition := aBoolean 
		ifFalse: [ text findString: aSearchPattern asLowercase startingAt: currentSearchPosition ] 
		ifTrue: [ text findString: aSearchPattern startingAt: currentSearchPosition ].
		
	(foundPosition = 0 or: [ foundPosition > text size ]) ifTrue: [ ^ nil ].
	lines1 := self numberOfLineOf: text from: 1 to: foundPosition.
	lines2 := self numberOfLineOf: text from: 1 to: text size.
	^ DocResultEntry 
			chapter: self 
			startPosition: foundPosition 
			endPosition: foundPosition + aSearchPattern size - 1
			scrollValue: (lines1 /lines2 ) asFloat
]

{ #category : #'serialization support' }
DocChapter >> fixNextReferenceUsing: aDictionary [

	nextChapter ifNil: [ ^ self ].
	nextChapter isParentReference ifFalse: [ ^ self ].
	
	nextChapter := nextChapter key 
		ifNil: [ nil ]
		ifNotNil: [ aDictionary at: nextChapter key ifAbsent: [ nil ] ].
]

{ #category : #'serialization support' }
DocChapter >> fixParentReferenceUsing: aDictionary [

	parent ifNil: [ ^ self ].
	parent isParentReference ifFalse: [ ^ self ].
	
	parent := parent key 
		ifNil: [ nil ]
		ifNotNil: [ aDictionary at: parent key ].
]

{ #category : #'serialization support' }
DocChapter >> fixParentReferencesUsing: aDictionary [

	self fixParentReferenceUsing: aDictionary.
	self fixNextReferenceUsing: aDictionary.

]

{ #category : #serialization }
DocChapter >> fromSton: stonReader [
	stonReader parseMapDo: [ :aKey :value |
		aKey = #source ifTrue: [ source := value ].
		aKey = #title ifTrue: [ title := value ].
		aKey = #key ifTrue: [ key := value ].
		aKey = #parent ifTrue: [ parent := DocParentReference key: value ].
		aKey = #nextChapter ifTrue: [ nextChapter := DocParentReference key: value ]  ]
	
]

{ #category : #accessing }
DocChapter >> hasSubchapter: aChapter [ 

	| subchapters |
	
	subchapters := self subchapters.
	(subchapters includes: aChapter) ifTrue: [ ^ true ].

	^ subchapters anySatisfy: [ :each | each hasSubchapter: aChapter ].
]

{ #category : #initialization }
DocChapter >> initialize [ 

	super initialize.
	
	source := ''.
]

{ #category : #testing }
DocChapter >> isChapter [

	^ true
]

{ #category : #accessing }
DocChapter >> lastPosition [ 

	^ source size - 1
]

{ #category : #serialization }
DocChapter >> materializeFrom: aStream [
	
	super materializeFrom: aStream.
	self readSourceFrom: aStream.
]

{ #category : #accessing }
DocChapter >> nextChapter [

	^ nextChapter
]

{ #category : #accessing }
DocChapter >> nextChapter: anObject [

	nextChapter := anObject.

	self aspectChanged: #nextChapter.
	"we changed chpaters order"
	library aspectChanged: #chapters.

]

{ #category : #accessing }
DocChapter >> nextChapterKeyOrNil [

	nextChapter ifNil: [ ^ nil ].
	
	^ nextChapter key
]

{ #category : #accessing }
DocChapter >> nextChapterText [ 

	^  nextChapter ifNil: [''] ifNotNil: [:c | c title ] 
]

{ #category : #accessing }
DocChapter >> nextKeyOrNil [

	nextChapter ifNil: [ ^ nil ].
	
	^ nextChapter key
]

{ #category : #'API - search' }
DocChapter >> numberOfLineOf: aText from: aBegin to: aEnd [
	| numberOfLine index start |
	numberOfLine := 0.
	start := aBegin.
	[ 
	index := aText findString: String cr startingAt: start.
	index > 0 and: [ index < aEnd ]
	]	
	whileTrue: 
	[ 
	numberOfLine := numberOfLine + 1.
	start := index + 1
	].
	^ numberOfLine 
]

{ #category : #parsing }
DocChapter >> parse [
	
	ast := nil.
	[ 
		| parser |
		parser := MicrodownParser new.
		ast := parser parse: source.
		monospaceTexts := ast monospaceTexts.
		chapterText := self textFor: source.
		chapterTextString := chapterText asString.
		chapterTextStringLowercase := chapterTextString asLowercase. 
		monospaceSearchResults := self prebuildMonospaceSearchResults.
	] on: MicParsingError do: [ :e | ].

]

{ #category : #accessing }
DocChapter >> path [
	"return the path to show the chapter in SpTreePresenter"
	| col |
	parent class = DocBook 
		ifTrue: [ col := OrderedCollection new.
					 col add: (parent library books indexOf: parent) ] 
		ifFalse: [ col := parent path ].
	col add: (parent children indexOf: self).
	^ col
]

{ #category : #parsing }
DocChapter >> prebuildMonospaceSearchResults [


]

{ #category : #printing }
DocChapter >> printOn: aStream [

	super printOn: aStream.
	aStream nextPutAll: '('.
	self title printOn: aStream.
	aStream nextPutAll: ')'.
	
]

{ #category : #serialization }
DocChapter >> readMetadataFrom: aDictionary [

	super readMetadataFrom: aDictionary.
	DocChapter addDictionaryOfChapters: self.
	aDictionary at: #nextChapter ifPresent: [ :value | nextChapter := DocParentReference key: value ].	
	
	
]

{ #category : #serialization }
DocChapter >> readSourceFrom: aStream [.

	source := aStream upToEnd withInternalLineEndings.
	self parse.
]

{ #category : #serialization }
DocChapter >> readStonKey: aKey value: value [

	super readStonKey: aKey value: value.
	aKey = #source ifTrue: [ 
		source := value.
		self parse ].
	aKey = #nextChapter ifTrue: [ nextChapter := DocParentReference key: value ].
	
	
]

{ #category : #accessing }
DocChapter >> rootChapter [ 

	^ self parent ifNil: [ self ] ifNotNil: [ :p | 
		p isParentReference
			ifFalse: [ p rootChapter ]
			ifTrue: [ self ] ]
]

{ #category : #serialization }
DocChapter >> serializeTo: aStream [ 

	super serializeTo: aStream.
	aStream crlf.
	self writeContentTo: aStream.

]

{ #category : #'drag and drop' }
DocChapter >> setAsNextChapter: aChapter [

	aChapter library = self library ifFalse: [ ^ self ].
	
	self nextChapter: aChapter.

]

{ #category : #accessing }
DocChapter >> source [ 
	
	^ source
]

{ #category : #accessing }
DocChapter >> source: aSource [

	aSource = source 
		ifTrue: [ ^ self ].
			
	self makeDirty.
	source := aSource.
	
	self parse.
	
	self aspectChanged: #source

]

{ #category : #serialization }
DocChapter >> stonOn: stonWriter [	
	stonWriter writeObject: self streamMap: [ :dictionary |
		dictionary
			at: #source put: source asString;
			at: #title put: title;
			at: #key put: key;
			at: #parent put: self parentKeyOrNil;
			at: #nextChapter put: self nextKeyOrNil]
]

{ #category : #accessing }
DocChapter >> subchapters [ 

	^ self book chapters select: [ :each | each parent = self ]
]

{ #category : #accessing }
DocChapter >> text [ 

	^ chapterText ifNil: [ 
		self parse.
		chapterText ]
]

{ #category : #accessing }
DocChapter >> textFor: aSource [

	|  text richTextComposer |

	text := [ 
		| tree |
		tree := self ast.
		richTextComposer := DocRichTextComposer new
			executor: self;
			css: self css.
		richTextComposer visit: tree
		] on: STONReaderError, MicParsingError, MessageNotUnderstood, SubclassResponsibility 
			do: [ :e | e asString, String lf, String lf, aSource ].
	^ text
]

{ #category : #accessing }
DocChapter >> withAllSubchapters [ 

	^ { self }, (self subchapters flatCollect: [ :each | each withAllSubchapters ]) 
]

{ #category : #serialization }
DocChapter >> writeContentTo: aStream [

	aStream nextPutAll: source asString withUnixLineEndings
]

{ #category : #serialization }
DocChapter >> writeStonKeysTo: aDictionary [ 

	super writeStonKeysTo: aDictionary.
	aDictionary
		at: #source put: source;
		at: #nextChapter put: self nextKeyOrNil
		
]
