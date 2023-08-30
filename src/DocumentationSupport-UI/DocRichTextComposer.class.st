"
I'm a visitor that produces rich text (class `Text`) based on a microdown model.
I'm implemented using a canvas/brush pattern. The class offers multiple configurations: an offline mode, 
a not rendering mode, and a not catching exceptions (to ease debugging).

I do the same that `MicRichTextComposer` but you can choose the style of the render.
"
Class {
	#name : #DocRichTextComposer,
	#superclass : #MicrodownVisitor,
	#instVars : [
		'canvas',
		'textStyler',
		'codeStylerClass',
		'executor',
		'resultEntries',
		'currentResultEntry',
		'libraryPresenter',
		'cssDictionary'
	],
	#classInstVars : [
		'searchIndex',
		'searchSize',
		'searchHighLightEnableOn',
		'searchWord'
	],
	#category : #'DocumentationSupport-UI-Support'
}

{ #category : #accessing }
DocRichTextComposer class >> searchHighLightEnableOn [
	^ searchHighLightEnableOn ifNil: [ ^ false ]
]

{ #category : #accessing }
DocRichTextComposer class >> searchHighLightEnableOn: aBoolean [
	searchHighLightEnableOn := aBoolean
]

{ #category : #accessing }
DocRichTextComposer class >> searchIndex [
	^ searchIndex ifNil: [ ^ 1 ]
]

{ #category : #accessing }
DocRichTextComposer class >> searchIndex: anInteger [
	searchIndex := anInteger
]

{ #category : #accessing }
DocRichTextComposer class >> searchSize [
	^ searchSize ifNil: [ ^ 1 ]
]

{ #category : #accessing }
DocRichTextComposer class >> searchSize: anInteger [
	searchSize := anInteger.
]

{ #category : #accessing }
DocRichTextComposer class >> searchWord [
	^ searchWord ifNil: [ ^ '' ]
]

{ #category : #accessing }
DocRichTextComposer class >> searchWord: aString [
	searchWord := aString.
]

{ #category : #'visiting - document' }
DocRichTextComposer >> anchorFor: anImageOrMorph of: aNode [

	aNode arguments at: #width ifPresent: [ :width |
		(width endsWith: '%') 
			ifTrue: [ |scale|
				scale := width initialIntegerOrNil.
				scale ifNotNil: [ 
					^ MicScalingTextAnchor new original: anImageOrMorph; scale: scale; yourself
					 ]]
		   ifFalse:  [ 
				width initialIntegerOrNil 
					ifNotNil: [ :absWidth | |absHeight|
						absHeight := anImageOrMorph height / anImageOrMorph width *absWidth.
						anImageOrMorph isMorph 
							ifTrue: [ ^ TextAnchor new anchoredMorph: (anImageOrMorph extent: absWidth @ absHeight) ]
							ifFalse: [ ^ TextAnchor new anchoredMorph: (anImageOrMorph scaledToSize: absWidth @ absHeight) ]
						  ]
		 ]].
	^ TextAnchor new anchoredMorph: anImageOrMorph
]

{ #category : #public }
DocRichTextComposer >> asRichText: aStringOrDoc [
	
	
	^ self visit: (aStringOrDoc isString 
		ifTrue: [ Microdown parse: aStringOrDoc ]
		ifFalse: [ aStringOrDoc ])
]

{ #category : #accessing }
DocRichTextComposer >> codeStylerClass [

	^ codeStylerClass
]

{ #category : #accessing }
DocRichTextComposer >> css: aCssDict [
	cssDictionary:= aCssDict
]

{ #category : #accessing }
DocRichTextComposer >> currentResultEntry [

	^ currentResultEntry ifNil: [ ^ DocResultEntry new ]
]

{ #category : #accessing }
DocRichTextComposer >> currentResultEntry: anObject [

	currentResultEntry := anObject
]

{ #category : #accessing }
DocRichTextComposer >> executor [

	^ executor
]

{ #category : #accessing }
DocRichTextComposer >> executor: anObject [

	executor := anObject
]

{ #category : #'visiting - document' }
DocRichTextComposer >> headerLevelFont: aLevel [
	^ (cssDictionary at: #headerSize) at: (aLevel min: (cssDictionary at: #headerSize) size) asInteger
]

{ #category : #highlighting }
DocRichTextComposer >> highlightText: aText [
	[ 
	resultEntries do: [ :resultEntry |
		resultEntry = currentResultEntry 
			ifTrue: [ aText addAttribute: (TextBackgroundColor new color: Color green ) from: resultEntry startPosition to: resultEntry endPosition ] 
			ifFalse: [ aText addAttribute: (TextBackgroundColor new color: Color lightGray ) from: resultEntry startPosition to: resultEntry endPosition ]
	]] on: SubscriptOutOfBounds,MessageNotUnderstood do: [ "nothing" ]
	
	
]

{ #category : #'API-link' }
DocRichTextComposer >> include: aChapterKey [
	
	| text tree |
	text := (DocChapter dictionnaryOfChaptersAt: aChapterKey) source.
	tree := MicrodownParser parse: text.
	tree accept: self
]

{ #category : #highlighting }
DocRichTextComposer >> indexOfOccurence: aText [
	| index |
	index := 0.
	1 to: self class searchIndex do: [ :occurence |
		 index := aText findString: self class searchWord startingAt: index + 1 ].
	^ index
]

{ #category : #initialization }
DocRichTextComposer >> initialize [
	super initialize.
	codeStylerClass := MicRichTextCodeBlockStyler.
	self textStyler:  MicTextStyler new.
	cssDictionary := DocBook defaultStyles 
]

{ #category : #'visiting - list' }
DocRichTextComposer >> interBlockSpacing [

	^ (String cr) asText
]

{ #category : #testing }
DocRichTextComposer >> isInclude: aLink [
	[ ^ aLink url beginsWith: 'include://']
		on: MessageNotUnderstood do: [ ^ false ] 
]

{ #category : #testing }
DocRichTextComposer >> isRef: aLink [
	[ ^ aLink url beginsWith: 'ref://']
		on: MessageNotUnderstood do: [ ^ false ] 
]

{ #category : #testing }
DocRichTextComposer >> isWeb: aLink [
	[ ^ aLink url beginsWith: 'http']
		on: MessageNotUnderstood do: [ ^ false ] 
]

{ #category : #private }
DocRichTextComposer >> latexFor: aString onError: aBlock [

	"Return a Text containing an image with the latex formula.
	If the latex formula cannot be built because of network or syntax errors,
	use the error block to build a text"

	| ref latexUrlPrefix image anchor |
	"https://i.upmath.me/png/" "https://latex.codecogs.com/png.image?"
	latexUrlPrefix := 'https://i.upmath.me/png/'.
	ref := MicResourceReference fromUri: latexUrlPrefix , aString.
	[ 	image := ref loadImage.
		anchor := TextAnchor new anchoredMorph: image.
		^ self textWithImage: image usingAnchor: anchor ]
	on: MicResourceReferenceError 
	do: [^ aBlock value]
]

{ #category : #accessing }
DocRichTextComposer >> libraryPresenter [

	^ libraryPresenter
]

{ #category : #accessing }
DocRichTextComposer >> libraryPresenter: anObject [

	libraryPresenter := anObject
]

{ #category : #composing }
DocRichTextComposer >> parseAndCompose: aString [ 
	
	^ self visit: (Microdown parse: aString)

]

{ #category : #public }
DocRichTextComposer >> parseAndComposeStringOrDoc: aStringOrDoc [
	
	^ self visit: (aStringOrDoc isString 
			ifTrue: [ Microdown parse: aStringOrDoc ]
			ifFalse: [ aStringOrDoc ])
]

{ #category : #'API-link' }
DocRichTextComposer >> ref: aChapterKey [
	| chapter |
	chapter := (libraryPresenter library chapterOfKey: aChapterKey).
	chapter
		ifNotNil: [ libraryPresenter clickAt: chapter path ]
	 	ifNil:  [ self refInOtherLibrary: (DocChapter dictionnaryOfChaptersAt: aChapterKey) ]
]

{ #category : #'API-link' }
DocRichTextComposer >> refInOtherLibrary: aChapter [
	| libraryPresenter |
	libraryPresenter := aChapter library asPresenter.
	libraryPresenter open.
	libraryPresenter clickAt: aChapter path
]

{ #category : #'figure-resolution' }
DocRichTextComposer >> renderHttpResource: aMicHttpResource inNode: aNode [

	^ (String value: 1) asText
		addAttribute: (self anchorFor: aMicHttpResource asForm of: aNode);
		yourself
]

{ #category : #'figure-resolution' }
DocRichTextComposer >> renderNotFoundResource: aMicNotFoundResource inNode: aNode [

	^ aNode caption asText
]

{ #category : #'figure-resolution' }
DocRichTextComposer >> renderPharoClassResource: aMicPharoClassResource inNode: aNode [
	
	"Put a class as text inside the document"
	^ aMicPharoClassResource asText
]

{ #category : #private }
DocRichTextComposer >> renderTableCell: aCell [
	"a cell is an array of nodes. Each element should be rendered and concatenated"
	^ aCell inject: Text new into: [ :txt :part | 
		txt, (MicRichTextComposer new visit: part)
		 ]
]

{ #category : #'visiting - document' }
DocRichTextComposer >> resizeImage: anImage of: aFigure [

	| scaledImage |
	scaledImage := anImage.
	"aFigure arguments at: #width ifPresent: [ :s |
		hostMorph 
			ifNotNil: [
				scaledImage := anImage scaledToSize: ( s asNumber in: [ :scale | 
					(hostMorph width / 100 * scale) @ (hostMorph height / 100 * scale)]).
		 ]]."
	^ scaledImage
]

{ #category : #accessing }
DocRichTextComposer >> resultEntries [

	^ resultEntries
]

{ #category : #accessing }
DocRichTextComposer >> resultEntries: anObject [

	resultEntries := anObject
]

{ #category : #visiting }
DocRichTextComposer >> setLinkAction: aLink [

	| attribute |
	attribute := TextAction new
		             actOnClickBlock: [ 
			             WebBrowser openOn: aLink url ];
		             yourself.
	canvas includeAttribute: attribute in: [ self visitCaptionEltForTextAttributes: aLink of: #link ]
]

{ #category : #accessing }
DocRichTextComposer >> textStyler [

	^ textStyler
]

{ #category : #accessing }
DocRichTextComposer >> textStyler: aTextStyler [

	textStyler := aTextStyler.
]

{ #category : #private }
DocRichTextComposer >> textWithImage: anImage usingAnchor: anchor [
	"return a text with an image embedded"
	| text |
	text := (String value: 1) asText addAttribute: anchor; yourself.
	"Adding a zero width no-break space circumvents two errors in rubrics when
		using images as links. Adding it even if the image is not a link causes no
		harm (it is invisible), and this is the easiest place to add it."
	^ text, 16rFEFF asCharacter asString asText
]

{ #category : #initialization }
DocRichTextComposer >> theme [

	^  Smalltalk ui theme
]

{ #category : #visiting }
DocRichTextComposer >> visit: aDocument [
	| text |
	canvas := DocRichTextCanvas new
		          textStyler: self textStyler;
		          yourself.
	aDocument accept: self.
	text := canvas contents.
	self highlightText: text.
	^ text.
]

{ #category : #'visiting - document' }
DocRichTextComposer >> visitAnnotatedParagraph: anAnnotatedParagraph [
	"Do nothing - You are supposed to use specialized annotations"
	self error: 'You are not supposed to be here - did you misspell an annotation type?'
	
]

{ #category : #'visiting-format' }
DocRichTextComposer >> visitBold: anObject [
	| boldAttributes |
	boldAttributes := OrderedCollection new.
	boldAttributes add: (TextEmphasis bold).
	boldAttributes add: (TextFontReference	toFont: (LogicalFont familyName: 'Source Sans Pro' pointSize: (cssDictionary at: #boldSize ifAbsent: [10]))).
	canvas 
		includeAttributes: boldAttributes
		in: [ super visitBold: anObject ]
	
]

{ #category : #visiting }
DocRichTextComposer >> visitCaptionEltForTextAttributes: anObject of: aElementCSSName [
	| textAttributes |
	textAttributes := OrderedCollection new.
	textAttributes add: (TextFontReference	toFont: (LogicalFont familyName: 'Source Sans Pro' pointSize: (cssDictionary at: #codeSize ifAbsent: [10]))).
	anObject captionElements do: [ :child |
		child class = MicTextBlock 
			ifTrue: [ 
				canvas 
					includeAttributes: textAttributes
					in: [ child accept: self ] ] 
			ifFalse: [ child accept: self ]  ].
]

{ #category : #'visiting - document' }
DocRichTextComposer >> visitChildrenOfForTextAttributes: anObject [
	| textAttributes |
	textAttributes := OrderedCollection new.
	textAttributes add: (TextFontReference	toFont: (LogicalFont familyName: 'Source Sans Pro' pointSize: (cssDictionary at: #textSize ifAbsent: [10]))).
	anObject children do: [ :child |
		child class = MicTextBlock 
			ifTrue: [ 
				canvas 
					includeAttributes: textAttributes
					in: [ child accept: self ] ] 
			ifFalse: [ child accept: self ]  ].
]

{ #category : #visiting }
DocRichTextComposer >> visitCode: aCodeBlock [

	canvas newLineIfNotAlready.
	canvas indentIn: [ 
		canvas
			<< ((self codeStylerClass stylerFor: aCodeBlock language)
					style: aCodeBlock body );
			newLine.
		aCodeBlock hasCaption ifTrue: [ 
			canvas 
				includeAttribute: TextEmphasis bold 
				in: [ 
					canvas
						<< aCodeBlock caption asText;
					newLine ]]].
	canvas << self interBlockSpacing
]

{ #category : #'visiting-format' }
DocRichTextComposer >> visitColumn: columnBlock [
	"I do nothing - handled by columns"
	
	
]

{ #category : #'visiting-format' }
DocRichTextComposer >> visitColumns: columnsBlock [
	"I render the using MicRichTable which is dedicated to this. I insert the table as an image (form)"
	| columns columnsBlocks totalWidth|
	canvas newLineIfNotAlready.
	columnsBlocks := columnsBlock children select: [ :c | c isKindOf: MicColumnBlock].
	columns := columnsBlocks collect: [ :column | |colText|
		colText := Microdown asRichText: (MicRootBlock new children: column children;yourself).
		RubScrolledTextMorph new setText: colText].
	totalWidth := columns sum: [ :col | col textArea width].
	columns do: [ :morph |
		canvas << ((String value: 1) asText addAttribute: 
			(MicScalingTextAnchor new 
				original: morph;
				"There need to be a bit of extra space assigned (5%)"
				scale: (morph textArea width / totalWidth * 100)-5;
				"Need to add a bit of space (15) for the scrollbar to disappear"
				freezeHeight: morph textArea height+15))].
	canvas 
		newLine; 
		<< self interBlockSpacing 
	
	
]

{ #category : #'visiting - document' }
DocRichTextComposer >> visitEnvironment: anObject [
	"Environment is an abstract class, and if we end here it is because of error"
	canvas << ('>>> Environment ' , anObject name , 
						'is not supported in RichText Pillar <<<') asText
]

{ #category : #visiting }
DocRichTextComposer >> visitExternalLink: aLink [
	| attribute target url |
	target := aLink reference.
	url := target asUrl.
	attribute := nil.
	(#(http https) includes: url scheme )
		ifTrue: [ attribute := "PRExternalLinkTextAction url: target"
			 	TextAction new actOnClickBlock: [WebBrowser openOn: target]].
	url scheme = #browse
		ifTrue:
			[ attribute := TextAction new actOnClickBlock: [ self class browse: aLink urlEntry ] ].
	url scheme = #ref
		ifTrue:
			[ attribute := TextAction new actOnClickBlock: [ executor openReference: aLink urlEntry] ].
	url scheme = #include
		ifTrue:
			[ attribute := TextAction new actOnClickBlock: [ executor openReference: aLink urlEntry ] ].
	attribute
		ifNotNil:
			[ canvas includeAttribute: attribute in: [ super visitLink: aLink ] ]
		ifNil: [ self visitLink: aLink ]

]

{ #category : #'visiting - inline elements' }
DocRichTextComposer >> visitFigure: aFigure [

	| image anchor|
	[ image := aFigure reference loadImage.
		anchor := self anchorFor: image of: aFigure.
		canvas << (self textWithImage: image usingAnchor: anchor)]
	on: MicResourceReferenceError
	do: [ self visitAll: aFigure captionElements  ]
]

{ #category : #'visiting - document' }
DocRichTextComposer >> visitHeader: aHeader [
	| headerAttributes |
	headerAttributes := OrderedCollection new.
	(cssDictionary at: #headerSize) 
		ifNotEmpty: [ headerAttributes add: (TextFontReference toFont: (LogicalFont familyName: 'Source Sans Pro' pointSize: (self headerLevelFont: aHeader level)asInteger)) ] 
		ifEmpty: [ headerAttributes add: (self textStyler headerLevelFont: aHeader level) ].
	canvas newLineIfNotAlready.
	canvas
		includeAttributes: headerAttributes
		in: [ super visitHeader: aHeader ].
	canvas << (textStyler crAfterHeaderLevel: aHeader level)
]

{ #category : #'visiting - document' }
DocRichTextComposer >> visitHorizontalLine: anHorizontalLine [
	
	canvas newLineIfNotAlready.
	canvas includeAttribute: TextEmphasis underlined in: [ canvas << ('     ' repeat: 20) asText ].
	canvas newLine.	
]

{ #category : #'visiting-format' }
DocRichTextComposer >> visitItalic: anObject [
	| italicAttributes |
	italicAttributes := OrderedCollection new.
	italicAttributes add: (TextEmphasis italic ).
	italicAttributes add: (TextFontReference toFont: (LogicalFont familyName: 'Source Sans Pro' pointSize: (cssDictionary at: #italicSize ifAbsent: [10]))).
	canvas 
		includeAttributes: italicAttributes
		in: [ super visitItalic: anObject ]
]

{ #category : #visiting }
DocRichTextComposer >> visitLink: aLink [

	| attributes |
	attributes := OrderedCollection new.
	attributes add: (TextFontReference	toFont: (LogicalFont familyName: 'Source Sans Pro' pointSize: (cssDictionary at: #linkSize ifAbsent: [10 ]))).
	(self isWeb: aLink) ifTrue: [ 
		attributes add: (TextAction new
							 actOnClickBlock: [ WebBrowser openOn: aLink url printString ]).
		(DocLinkResolver isValidAddressForName: aLink url asUrl host timeout: 60) 
			ifFalse: [ attributes add: (TextBackgroundColor new color: (Color orange alpha: 0.5)) ] ].
						
	(self isRef: aLink) ifTrue: [ 
		(DocLinkResolver isValidChapterForName: aLink url asUrl host) 
			ifFalse: [ attributes add: (TextBackgroundColor new color: (Color orange alpha: 0.5))]
			ifTrue: [ attributes add: (TextAction new actOnClickBlock: [ self ref: aLink url asUrl host ]) ] ].
		
	(self isInclude: aLink) ifTrue: [ 
		(DocLinkResolver isValidChapterForName: aLink url asUrl host) 
			ifFalse: [ attributes add: (TextBackgroundColor new color: (Color orange alpha: 0.5))]
			ifTrue: [ self include: aLink url asUrl host ] ].	
	attributes
		ifNotEmpty: [ canvas includeAttributes: attributes in: [ self setLinkAction: aLink ] ]
		ifEmpty: [ self setLinkAction: aLink ]
]

{ #category : #'visiting - list' }
DocRichTextComposer >> visitListItem: anItem [
	| bullet |
	"The depth counter and bullet type in `visitOrderedList` and `visitUnorderedList`"
	bullet := (anItem propertyAt: #kind) = #ordered
		ifTrue: [ (anItem propertyAt: #counter) asString asText , String tab ]
		ifFalse: [ (anItem propertyAt: #bullet) asText , String tab ].
	bullet addAttribute: (TextIndent tabs: canvas nesting - 1).
	canvas newLineIfNotAlready.
	canvas << bullet.
	canvas indentIn: [ self visitChildrenOfForTextAttributes: anItem ].

]

{ #category : #'visiting - document' }
DocRichTextComposer >> visitMath:  aMicMathEnvironment [

	| aString |
	aString := aMicMathEnvironment body.
	aString ifEmpty: [ ^self ].
	canvas << (self latexFor: aString onError: ['& - LATEX ERROR - &' asText] )
]

{ #category : #'visiting - document' }
DocRichTextComposer >> visitMathInline: aMicMathInline [ 
	| aString  |
	aString := aMicMathInline substring .
   aString ifEmpty: [^ self].
	canvas << (self latexFor: aString onError: [ '$ - LATEX ERROR - $' asText ])
]

{ #category : #'visiting-format' }
DocRichTextComposer >> visitMonospace: anObject [
	"Notice - I add a highlight to the backgorund rather than mono-spaced."
	| backgroundColor sem monospaceAttributes |
	monospaceAttributes := OrderedCollection new.
	monospaceAttributes add: (TextFontReference	toFont: (LogicalFont familyName: 'Source Code Pro' pointSize: (cssDictionary at: #monospaceSize ifAbsent: [10]))).
	backgroundColor := self textStyler monospaceBackgroundColor.
	self flag: #fixMe.
	"Right now we stupidly emit TextAction but we should emit TextClassLink and revisit them."
	monospaceAttributes  add: (TextBackgroundColor color: backgroundColor).
	monospaceAttributes  add: (TextColor color: Color red muchDarker).
	canvas 
		includeAttributes: monospaceAttributes
		in: [ 
			sem := MicSemanticAction from: anObject text.
			sem hasEntity
				ifTrue: [ canvas 
								includeAttribute: (TextAction new actOnClickBlock: [ sem entity browse ]) 
								in: [ super visitMonospace: anObject ] ]
				ifFalse: [ super visitMonospace: anObject]].  
]

{ #category : #'visiting - list' }
DocRichTextComposer >> visitOrderedList: anObject [
	"here we annotate items with their kind and the depth"
	| counter |
	canvas newLineIfNotAlready.
	canvas indentIn: [counter := 1.
		anObject children
			do: [ :item | 
				item propertyAt: #kind put: #ordered.
				item
					propertyAt: #counter
					put: (self textStyler counterFor: counter atLevel: canvas nesting - 1).
				counter := counter + 1 ].
		super visitOrderedList: anObject ].
	canvas newLine; << self interBlockSpacing 
]

{ #category : #'visiting - document' }
DocRichTextComposer >> visitParagraph: anObject [
	canvas newLineIfNotAlready.
	self visitChildrenOfForTextAttributes: anObject.
	canvas newLine; << self interBlockSpacing
]

{ #category : #'visiting - document' }
DocRichTextComposer >> visitParameters: anObject [
	"do nothing for now"
	
	^ self
]

{ #category : #visiting }
DocRichTextComposer >> visitQuote: aQuote [
	"I should have a fancier implementation, but for now this should work and be recognized as a quote"
	canvas newLineIfNotAlready.
	canvas << ('>',String tab) asText..
	canvas indentIn: [ super visitQuote: aQuote ].
	canvas newLine
]

{ #category : #'visiting-format' }
DocRichTextComposer >> visitStrike: anObject [
	| strikeAttributes |
	strikeAttributes := OrderedCollection new.
	strikeAttributes add: (TextEmphasis struckOut ).
	strikeAttributes add: (TextFontReference	toFont: (LogicalFont familyName: 'Source Sans Pro' pointSize: (cssDictionary at: #strikeSize))).
	canvas 
		includeAttributes: strikeAttributes
		in: [ super visitStrike: anObject ]
]

{ #category : #'visiting-format' }
DocRichTextComposer >> visitTable: tableBlock [
	"I render the using MicRichTable which is dedicated to this. I insert the table as an image (form)"
	| headers rows table anchoredTable renderedRows |
	renderedRows := tableBlock rows collect: [ :oneRow | oneRow collect: [ :cell | self renderTableCell: cell ]].
	tableBlock hasHeader
		ifTrue: [ 
			headers := renderedRows first. 
			rows := renderedRows allButFirst  ]
		ifFalse: [ 
			headers := (1 to: renderedRows first size) collect: [:i | i printString asText].
			rows := renderedRows].
	"Create the Morphic Table and insert it"
	table := MicRichTextTable headers: headers rows: rows.
	tableBlock hasHeader
		ifFalse: [ 
			table extent: table extent - (0 @ '1' asTextMorph height). "not showing the headers"
			table hideColumnHeaders  ].
	anchoredTable := (String value: 1) asText addAttribute: (TextAnchor new anchoredMorph: table).
	canvas newLineIfNotAlready;newLine.
	canvas 
		<< anchoredTable;
		newLine;
		<< self interBlockSpacing 
	
]

{ #category : #'visiting-format' }
DocRichTextComposer >> visitText: anInlineBlock [
	"we should set attribute because it would override link and others."
	canvas << (textStyler postTextTreatment: (anInlineBlock substring asText) )
]

{ #category : #'visiting - list' }
DocRichTextComposer >> visitUnorderedList: anObject [
	canvas newLineIfNotAlready.
	canvas
		indentIn: [ 
			anObject children
				do: [ :item | 
					item propertyAt: #kind put: #unordered.
					item
						propertyAt: #bullet
						put: (self textStyler bulletForLevel: canvas nesting - 1) ].
			super visitUnorderedList: anObject ].
	canvas newLine; << self interBlockSpacing 
]
