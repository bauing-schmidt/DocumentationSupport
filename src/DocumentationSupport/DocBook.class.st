"
A collection of chapters. Books cannot be nested.
"
Class {
	#name : #DocBook,
	#superclass : #DocModelWithKey,
	#instVars : [
		'chapters'
	],
	#classInstVars : [
		'cssDictionnary',
		'defaultStyles'
	],
	#category : #'DocumentationSupport-Model'
}

{ #category : #accessing }
DocBook class >> cssAt: aKey [
	cssDictionnary ifNil: [ ^ nil ].
	cssDictionnary at: aKey ifPresent: [ :value | ^ value ]
]

{ #category : #accessing }
DocBook class >> cssAt: aKey ifAbsent: aBlock [
	cssDictionnary ifNil: [ ^ nil ].
	^ cssDictionnary at: aKey ifPresent: [ :value | value ] ifAbsent: aBlock
]

{ #category : #accessing }
DocBook class >> cssAt: aKey put: aCSSDictionnary [
	cssDictionnary ifNil: [ cssDictionnary := Dictionary new ].
	cssDictionnary at: aKey put: aCSSDictionnary
]

{ #category : #accessing }
DocBook class >> defaultStyles [ 

	^ defaultStyles ifNil: [ defaultStyles := self defaultStylesContent ]
]

{ #category : #accessing }
DocBook class >> defaultStylesContent [
	
	| defaultSize |
	defaultSize := 12.
	
	^ Dictionary new at: #header put: OrderedCollection new;
		at: #text put: OrderedCollection new;
		at: #bold put: OrderedCollection new;
		at: #italic put: OrderedCollection new;
		at: #strike put: OrderedCollection new;
		at: #monospace put: OrderedCollection new;
		at: #link put: OrderedCollection new;
		at: #code put: OrderedCollection new;
		
		at: #headerSize put: OrderedCollection new;
		at: #textSize put: defaultSize;
		at: #boldSize put: defaultSize;
		at: #italicSize put: defaultSize;
		at: #strikeSize put: defaultSize;
		at: #monospaceSize put: defaultSize;
		at: #linkSize put: defaultSize;
		at: #codeSize put: defaultSize;
		yourself
]

{ #category : #accessing }
DocBook class >> resetDefaultStylesContent [

	<script>
	
	defaultStyles := nil
]

{ #category : #'drag and drop' }
DocBook >> acceptChapter: aChapter [ 

	aChapter library = self library ifFalse: [ ^ self ].

	(self hasSubchapter: aChapter) ifTrue: [ 
		aChapter parent: self.
		library aspectChanged: #chapters.
		^ self ].
	
	"from antother book"
	aChapter withAllSubchapters do: [ :each |
		self takeChapter: each ].
	
	aChapter parent: self.
	
	library aspectChanged: #chapters.

]

{ #category : #visiting }
DocBook >> acceptVisitor: aVisitor [ 

	aVisitor visitBook: self
]

{ #category : #'css-API' }
DocBook >> addCSS: aDictionnary in: aCSSDictionnary type: aSymbol attribute: aBlock [
	aDictionnary at: #header,aSymbol ifPresent: [ :value | (aCSSDictionnary at: #header) add: (aBlock value: value) ].
	aDictionnary at: #text,aSymbol ifPresent: [ :value | (aCSSDictionnary at: #text) add: (aBlock value: value) ].
	aDictionnary at: #bold,aSymbol ifPresent: [ :value | (aCSSDictionnary at: #bold) add: (aBlock value: value) ].
	aDictionnary at: #italic,aSymbol ifPresent: [ :value | (aCSSDictionnary at: #italic) add: (aBlock value: value) ].
	aDictionnary at: #strike,aSymbol ifPresent: [ :value | (aCSSDictionnary at: #strike) add: (aBlock value: value) ].
	aDictionnary at: #monospace,aSymbol ifPresent: [ :value | (aCSSDictionnary at: #monospace) add: (aBlock value: value) ].
	aDictionnary at: #link,aSymbol ifPresent: [ :value | (aCSSDictionnary at: #link) add: (aBlock value: value) ].
	aDictionnary at: #code,aSymbol ifPresent: [ :value | (aCSSDictionnary at: #code) add: (aBlock value: value) ].
]

{ #category : #'css-API' }
DocBook >> addCSSBackGroundColor: aDictionnary in: aCSSDictionnary [ 
	self addCSSWithOpacity: aDictionnary 
		  in: aCSSDictionnary 
		  type: #BackgroundColor
		  attribute: [ :colorString :float | self backgroundColorClass new color: ((Color fromString: colorString) alpha: float) ]
]

{ #category : #'css-API' }
DocBook >> addCSSColor: aDictionnary in: aCSSDictionnary [
	self addCSSWithOpacity: aDictionnary 
		  in: aCSSDictionnary 
		  type: #Color 
		  attribute: [ :colorString :float | self textColorClass new color: ((Color fromString: colorString) alpha: float) ]
]

{ #category : #'css-API' }
DocBook >> addCSSPoliceSize: aDictionnary in: aCSSDictionnary [
	aDictionnary at: #headerSize ifPresent: [ :value | aCSSDictionnary at: #headerSize put: (value findTokens: ' ') ].
	aDictionnary at: #textSize ifPresent: [ :value | aCSSDictionnary at: #textSize put: value asInteger ].
	aDictionnary at: #boldSize ifPresent: [ :value | aCSSDictionnary at: #boldSize put: value asInteger ].
	aDictionnary at: #italicSize ifPresent: [ :value | aCSSDictionnary at: #italicSize put: value asInteger ].
	aDictionnary at: #strikeSize ifPresent: [ :value | aCSSDictionnary at: #strikeSize put: value asInteger ].
	aDictionnary at: #monospaceSize ifPresent: [ :value | aCSSDictionnary at: #monospaceSize put: value asInteger ].
	aDictionnary at: #linkSize ifPresent: [ :value | aCSSDictionnary at: #linkSize put: value asInteger ].
	aDictionnary at: #codeSize ifPresent: [ :value | aCSSDictionnary at: #codeSize put: value asInteger ].
]

{ #category : #'css-API' }
DocBook >> addCSSWithOpacity: aDictionnary in: aCSSDictionnary type: aSymbol attribute: aBlock [
	aDictionnary at: #header,aSymbol ifPresent: [ :value | self addCSSWithOpacity: aDictionnary in: aCSSDictionnary type: aSymbol attribute: aBlock firstValue: value eltType: #header ].
	aDictionnary at: #text,aSymbol ifPresent: [ :value | self addCSSWithOpacity: aDictionnary in: aCSSDictionnary type: aSymbol attribute: aBlock firstValue: value eltType: #text ].
	aDictionnary at: #bold,aSymbol ifPresent: [ :value | self addCSSWithOpacity: aDictionnary in: aCSSDictionnary type: aSymbol attribute: aBlock firstValue: value eltType: #bold ].
	aDictionnary at: #italic,aSymbol ifPresent: [ :value | self addCSSWithOpacity: aDictionnary in: aCSSDictionnary type: aSymbol attribute: aBlock firstValue: value eltType: #italic ].
	aDictionnary at: #strike,aSymbol ifPresent: [ :value | self addCSSWithOpacity: aDictionnary in: aCSSDictionnary type: aSymbol attribute: aBlock firstValue: value eltType: #strike ].
	aDictionnary at: #monospace,aSymbol ifPresent: [ :value | self addCSSWithOpacity: aDictionnary in: aCSSDictionnary type: aSymbol attribute: aBlock firstValue: value eltType: #monospace ].
	aDictionnary at: #link,aSymbol ifPresent: [ :value | self addCSSWithOpacity: aDictionnary in: aCSSDictionnary type: aSymbol attribute: aBlock firstValue: value eltType: #link ].
	aDictionnary at: #code,aSymbol ifPresent: [ :value | self addCSSWithOpacity: aDictionnary in: aCSSDictionnary type: aSymbol attribute: aBlock firstValue: value eltType: #code ].
]

{ #category : #'css-API' }
DocBook >> addCSSWithOpacity: aDictionnary in: aCSSDictionnary type: aSymbol attribute: aBlock firstValue: aFirstvalue eltType: aSymbolElt [
	aDictionnary at: aSymbolElt,aSymbol,#Opacity 
		ifPresent: [ :value | (aCSSDictionnary at: aSymbolElt) add: (aBlock value: aFirstvalue value: (Float readFrom:  value)) ]
		ifAbsent: [ (aCSSDictionnary at: aSymbolElt) add: (aBlock value: aFirstvalue value: 1) ]
]

{ #category : #adding }
DocBook >> addChapter: aChapter [ 

	self makeDirty.
	aChapter parent: self.
	chapters add: aChapter.
	^ aChapter

]

{ #category : #'css-API' }
DocBook >> addGlobalColor: aDictionnary in: aCSSDictionnary with: anAttribute [
	aDictionnary at: #headerColor ifAbsent: [ (aCSSDictionnary at: #header) add: anAttribute ].
	aDictionnary at: #textColor ifAbsent: [ (aCSSDictionnary at: #text) add: anAttribute ].
	aDictionnary at: #boldColor ifAbsent: [ (aCSSDictionnary at: #bold) add: anAttribute ].
	aDictionnary at: #italicColor ifAbsent: [ (aCSSDictionnary at: #italic) add: anAttribute ].
	aDictionnary at: #strikeColor ifAbsent: [ (aCSSDictionnary at: #strike) add: anAttribute ].
	aDictionnary at: #monospaceColor ifAbsent: [ (aCSSDictionnary at: #monospace) add: anAttribute ].
	aDictionnary at: #linkColor ifAbsent: [ (aCSSDictionnary at: #link) add: anAttribute ].
	aDictionnary at: #codeColor ifAbsent: [ (aCSSDictionnary at: #code) add: anAttribute ].
]

{ #category : #'css-API' }
DocBook >> addGlobalColor: aDictionnary in: aCSSDictionnary with: anAttribute type: aSymbol [
	aDictionnary at: #header,aSymbol ifAbsent: [ (aCSSDictionnary at: #header) add: anAttribute ].
	aDictionnary at: #text,aSymbol ifAbsent: [ (aCSSDictionnary at: #text) add: anAttribute ].
	aDictionnary at: #bold,aSymbol ifAbsent: [ (aCSSDictionnary at: #bold) add: anAttribute ].
	aDictionnary at: #italic,aSymbol ifAbsent: [ (aCSSDictionnary at: #italic) add: anAttribute ].
	aDictionnary at: #strike,aSymbol ifAbsent: [ (aCSSDictionnary at: #strike) add: anAttribute ].
	aDictionnary at: #monospace,aSymbol ifAbsent: [ (aCSSDictionnary at: #monospace) add: anAttribute ].
	aDictionnary at: #link,aSymbol ifAbsent: [ (aCSSDictionnary at: #link) add: anAttribute ].
	aDictionnary at: #code,aSymbol ifAbsent: [ (aCSSDictionnary at: #code) add: anAttribute ].
]

{ #category : #'css-API' }
DocBook >> addGlobalColorWithOpacity: aDictionnary in: aCSSDictionnary type: aSymbol [
	| attributeClass |
	attributeClass := aSymbol = #Color 
		ifTrue:  [ self textColorClass ]
		ifFalse: [ self backgroundColorClass ].
	aDictionnary at: #global,aSymbol ifPresent: [ :colorString |
		aDictionnary at: #global,aSymbol,#Opacity
			ifPresent: [ :float | self addGlobalColor: aDictionnary in: aCSSDictionnary with: (attributeClass new color: ((Color fromString: colorString) alpha: (Float readFrom: float))) type: aSymbol ]
			ifAbsent: [ self addGlobalColor: aDictionnary in: aCSSDictionnary with: (attributeClass new color: ((Color fromString: colorString))) type: aSymbol ]
		]
]

{ #category : #adding }
DocBook >> addNewChapter [

	| newChapter |
	
	newChapter := self addNewChapterWithoutNotification.
	library aspectChanged: #chapters.
	DocChapter addDictionaryOfChapters: newChapter.
	EpMonitor current addEvent: newChapter asEpDocChapterAddition.
	^ newChapter
]

{ #category : #adding }
DocBook >> addNewChapterWithoutNotification [

	| newChapter |
	
	newChapter := DocChapter new.
	newChapter library: self library.
	self addChapter: newChapter.
	^ newChapter
]

{ #category : #'css-API' }
DocBook >> backgroundColorClass [
	^ TextBackgroundColor
]

{ #category : #accessing }
DocBook >> book [ 

	^ self
]

{ #category : #accessing }
DocBook >> chapterOfKey: aKey [ 

	^ chapters detect: [ :each | each key = aKey ] ifNone: [ nil ].
]

{ #category : #accessing }
DocBook >> chapters [ 

	^ chapters
]

{ #category : #accessing }
DocBook >> chapters: anObject [

	chapters := anObject
]

{ #category : #accessing }
DocBook >> children [ 

	^ self sortedChapters: (chapters select: [ :each | each parent = self ])
]

{ #category : #'css-API' }
DocBook >> createEmptyCSS: aDefaultPoliceSize [
	^ Dictionary new at: #header put: OrderedCollection new;
		at: #text put: OrderedCollection new;
		at: #bold put: OrderedCollection new;
		at: #italic put: OrderedCollection new;
		at: #strike put: OrderedCollection new;
		at: #monospace put: OrderedCollection new;
		at: #link put: OrderedCollection new;
		at: #code put: OrderedCollection new;
		
		at: #headerSize put: OrderedCollection new;
		at: #textSize put: aDefaultPoliceSize;
		at: #boldSize put: aDefaultPoliceSize;
		at: #italicSize put: aDefaultPoliceSize;
		at: #strikeSize put: aDefaultPoliceSize;
		at: #monospaceSize put: aDefaultPoliceSize;
		at: #linkSize put: aDefaultPoliceSize;
		at: #codeSize put: aDefaultPoliceSize;
		yourself
]

{ #category : #removing }
DocBook >> delete [ 

	self chapters do: [ :chapter | chapter ifNotNil: [ self deleteChapter: chapter ] ].
	self library deleteBook: self.
	self makeDirty.
	library aspectChanged: #chapters.


]

{ #category : #removing }
DocBook >> deleteChapter: aChapter [ 

	aChapter subchapters do: [ :each | 
		self deleteChapter: each ].

	chapters remove: aChapter.
	chapters do: [ :each | 
		each chapterRemoved: aChapter ].
	DocChapter removeDictionaryOfChapters: aChapter.
	library aspectChanged: #chapters.

	

]

{ #category : #'serialization support' }
DocBook >> fixParentReferencesUsing: aDictionary [

	self chapters do: [ :each |
		each fixParentReferencesUsing: aDictionary ].

	parent ifNil: [ ^ self ].
	parent isParentReference ifFalse: [ ^ self ].
	
	parent := parent key 
		ifNil: [ nil ]
		ifNotNil: [ aDictionary at: parent key ]
]

{ #category : #'css-API' }
DocBook >> generateCSS: aDictionary [
	| css |
	aDictionary at: #globalSize 
		ifPresent: [ :value | css := self createEmptyCSS: value asInteger ]
		ifAbsent: [ css := self createEmptyCSS: 13 ].
	self addCSSColor: aDictionary in: css;
	addCSSBackGroundColor: aDictionary in: css;
	addCSSPoliceSize: aDictionary in: css;
	addGlobalColorWithOpacity: aDictionary in: css  type: #Color;
	addGlobalColorWithOpacity: aDictionary in: css type: #BackgroundColor.
	DocBook cssAt: key put: css. 
]

{ #category : #accessing }
DocBook >> hasSubchapter: aChapter [

	^ chapters includes: aChapter
]

{ #category : #initialization }
DocBook >> initialize [ 

	super initialize.
	
	chapters := OrderedCollection new.
]

{ #category : #accessing }
DocBook >> readMetadataFrom: aDictionary [
	super readMetadataFrom: aDictionary.
	self generateCSS: aDictionary.
	
	
	
]

{ #category : #accessing }
DocBook >> setLibrary: aLibrary [ 

	super setLibrary: aLibrary.
	chapters do: [ :each | each setLibrary: aLibrary ].
]

{ #category : #adding }
DocBook >> takeChapter: aChapter [ 

	"change ownership"

	aChapter book chapters remove: aChapter.
	self chapters add: aChapter 
]

{ #category : #'css-API' }
DocBook >> textColorClass [
	^ TextColor
]

{ #category : #'css-API' }
DocBook >> textFontReference: aPoliceName size: aSize [
	^ (TextFontReference
				toFont:
					(LogicalFont 
						familyName: 'Source Sans Pro'
						pointSize: 24))
]
