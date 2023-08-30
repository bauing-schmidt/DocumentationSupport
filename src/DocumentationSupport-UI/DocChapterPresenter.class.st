"
A documentation chapter presenter with editor and preview
"
Class {
	#name : #DocChapterPresenter,
	#superclass : #DocModelPresenter,
	#instVars : [
		'chapter',
		'srcInput',
		'preview',
		'previewUpdateMutex',
		'updateProcess',
		'titleInput',
		'keyInput',
		'copyRefButton',
		'copyIncludeButton',
		'parent',
		'nextInput',
		'clearNext',
		'goToNext',
		'splitButton',
		'showEditor',
		'headerEnable',
		'editEnable'
	],
	#category : #'DocumentationSupport-UI-Presenters'
}

{ #category : #'instance creation' }
DocChapterPresenter class >> on: aChapter [ 

	^ self basicNew 
		chapter: aChapter;
		initialize
]

{ #category : #'instance creation' }
DocChapterPresenter class >> on: aChapter application: anApplication [

	^ self basicNew 
		application: anApplication;
		chapter: aChapter;
		initialize
]

{ #category : #events }
DocChapterPresenter >> aspect: anAspect changedFrom: anOrigin [

	anOrigin = self ifTrue: [ ^ self ].
	
	anAspect = #source ifTrue: [ srcInput text: chapter source. ].
	anAspect = #title ifTrue: [ titleInput text: chapter title. ].
	anAspect = #key ifTrue: [ keyInput text: chapter key. ].
	anAspect = #nextChapter ifTrue: [ nextInput text: chapter nextChapterText. ].

]

{ #category : #layout }
DocChapterPresenter >> buttonLayout [
	^ SpBoxLayout newHorizontal 
		beNotHomogeneous;
		add: self setShowHeaderButton;
		add: self setEditButton;
		add: self setOpenButton
]

{ #category : #buttons }
DocChapterPresenter >> changeEditView [
	editEnable := editEnable not.
	layout := self layoutShowingEditor: showEditor
]

{ #category : #buttons }
DocChapterPresenter >> changeHeaderView [
	headerEnable := headerEnable not.
	layout := self layoutShowingEditor: showEditor
]

{ #category : #accessing }
DocChapterPresenter >> chapter [

	^ chapter
]

{ #category : #accessing }
DocChapterPresenter >> chapter: aChapter [

	chapter := aChapter.

]

{ #category : #layout }
DocChapterPresenter >> chapterLayout: aLayout [
	headerEnable 
		ifTrue:  [ 
			^ SpBoxLayout newVertical
			add: self headerLayout height:120;
			add: self buttonLayout height: 24;
			add: aLayout expand: true ]
		ifFalse: [ 
			^ SpBoxLayout newVertical 
			add: self buttonLayout height: 24;
			add: aLayout expand: true ]
	
]

{ #category : #layout }
DocChapterPresenter >> editOrPreviewLayout: aBoolean [
	| tmplayout |

	tmplayout := SpBoxLayout newHorizontal spacing: 5.
	editEnable 
		ifTrue:  [ 
			aBoolean ifTrue: [ tmplayout  add: #preview expand: true ].
			tmplayout 
				add: #splitButton withConstraints: [ :con | con expand: false; width: 24];
				add: #srcInput expand: true ]
		ifFalse: [ 
			aBoolean ifTrue: [ tmplayout  add: #srcInput expand: true ].
			tmplayout 
				add: #splitButton withConstraints: [ :con | con expand: false; width: 24];
				add: #preview expand: true ].
	^ tmplayout
	
]

{ #category : #shortcuts }
DocChapterPresenter >> editShortcut: aCategory [
	aCategory
			addKeymapEntry:
				(KMKeymap named: #EditShortcut shortcut: $e meta shift mac | $e alt shift win | $e alt shift unix  action: [ 
					editEnable := editEnable not.
					layout := self layoutShowingEditor: showEditor ])
]

{ #category : #preview }
DocChapterPresenter >> getPreviewPresenter [ 

	| textMorph presenter |
	
	textMorph := self previewMorphFor: chapter text.

	presenter := SpMorphPresenter new.
	presenter morph: textMorph.

	^ presenter.
]

{ #category : #layout }
DocChapterPresenter >> headerLayout [
	^ SpBoxLayout newVertical
		beNotHomogeneous;
		add: (SpGridLayout new
			add: 'Title:' at: 1@1;
			add: #titleInput at: 2@1 span: 4@1;
			add: 'Key:' at: 1@2;
			add: (
				SpBoxLayout newHorizontal
					spacing: 5;
					add: #keyInput expand: true fill: true;
					add: #copyRefButton expand: false;
					add: #copyIncludeButton expand: false;
					yourself
			) at: 2@2 span: 4@1;
			add: 'Next:' at: 1@3;
			add: (
				SpBoxLayout newHorizontal
					spacing: 5;
					add: #nextInput expand: true fill: true;
					add: #clearNext expand: false;
					add: #goToNext expand: false;
					yourself
			) at: 2@3 span: 4@1;
			
			yourself) height: 120
]

{ #category : #shortcuts }
DocChapterPresenter >> headerShortcut: aCategory [
	aCategory
			addKeymapEntry:
				(KMKeymap named: #HeaderShortcut shortcut: $h meta shift mac | $h alt shift win | $h alt shift unix action: [ 
					headerEnable := headerEnable not.
					layout := self layoutShowingEditor: showEditor ])
]

{ #category : #initialization }
DocChapterPresenter >> initialize [ 

	super initialize.
]

{ #category : #initialization }
DocChapterPresenter >> initializePresenters [

	super initializePresenters.
	previewUpdateMutex := Mutex new.

	titleInput := self newTextInput.
	titleInput text: self chapter title.
	titleInput whenTextChangedDo: [ :aText | self chapter title: aText ].

	keyInput := self newTextInput.
	keyInput enabled: false.
	keyInput text: self chapter key.

	copyRefButton := self newButton
		                 label: 'ref://';
		                 action: [ 
			                 Clipboard clipboardText:
					                 '[' , chapter title , '](ref://'
					                 , self chapter key , ')' ].

	copyIncludeButton := self newButton
		                     label: 'include://';
		                     action: [ 
			                     Clipboard clipboardText:
					                     '[' , chapter title , '](include://'
					                     , self chapter key , ')' ].

	srcInput := self newText.
	preview := self getPreviewPresenter.

	preview morph setText: '' asText.

	srcInput text: self chapter source.

	srcInput whenTextChangedDo: [ :newText | 
		self chapter source: newText.
		self updatePreview: newText ].

	chapter whenAspectChangedNotify: self.

	nextInput := self newTextInput.
	nextInput text: self chapter nextChapterText.
	nextInput
		enabled: false;
		dropEnabled: true;
		wantsDrop: [ :transfer | 
			transfer passenger allSatisfy: [ :each | each isKindOf: DocChapter ] ];
		acceptDrop: [ :transfer | 
			| aChapter |
			aChapter := transfer passenger anyOne.
			self chapter nextChapter: aChapter.
			nextInput text: aChapter title ].

	clearNext := self newButton
		             icon: (self iconNamed: #changeRemove);
		             action: [ self chapter nextChapter: nil ].

	goToNext := self newButton
		            icon: (self iconNamed: #glamorousGo);
		            action: [ 
			            self chapter nextChapter ifNotNil: [ 
					            self openReference:
							            (ZnUrl fromString:
									             'ref://' , self chapter nextChapter key) ] ].

	showEditor := false.
	splitButton := self newButton
		               icon: (self iconNamed: #edit);
		               action: [ self splitLayoutOrNot ].

	headerEnable := false.
	editEnable := false.

	layout := self layoutShowingEditor: showEditor.
	self updatePreview: self chapter source
]

{ #category : #initialization }
DocChapterPresenter >> initializeWindow: aWindowPresenter [
	aWindowPresenter
		title: self chapter title;
		initialExtent: 1100@850;
		windowIcon: (self iconNamed: #book)
]

{ #category : #layout }
DocChapterPresenter >> layoutShowingEditor: aBoolean [

	^ self chapterLayout: (self editOrPreviewLayout: aBoolean)
]

{ #category : #shortcuts }
DocChapterPresenter >> openChapterAction [

	| morph presenter category |
	presenter := self chapter asPresenter open.
	morph := presenter window submorphs last.
	category := KMCategory named: #DocChapterShortcut.
	KMRepository default addCategory: category.
	morph attachKeymapCategory: #DocChapterShortcut.
	
	presenter presenter headerShortcut: category;
	editShortcut: category;
	openShortcut: category;
	showChapterShortcut: category
]

{ #category : #actions }
DocChapterPresenter >> openReference: aRef [ 

	| aKey | 
	
	aKey := aRef host.
	
	parent 
		ifNotNil: [ 
			parent openChapter: aKey. ]
		ifNil: [ 
			(self class on: (self chapter library chapterOfKey: aKey) application: self application) open
			 ]
	

	
]

{ #category : #shortcuts }
DocChapterPresenter >> openShortcut: aCategory [
	aCategory
			addKeymapEntry:
				(KMKeymap named: #OpenShortcut shortcut: $o meta shift mac | $o alt shift win | $o ctrl shift unix | $o alt  action: [ self openChapterAction ])
]

{ #category : #accessing }
DocChapterPresenter >> parent [

	^ parent
]

{ #category : #accessing }
DocChapterPresenter >> parent: anObject [
	parent := anObject.
	headerEnable := parent showHeaderModeEnable.
	editEnable := parent editModeEnable.
	showEditor := parent showModeEnable.
	layout := self layoutShowingEditor: showEditor.
	self updatePreview: self chapter source
]

{ #category : #accessing }
DocChapterPresenter >> path [
	^ chapter path
]

{ #category : #preview }
DocChapterPresenter >> previewMorphFor: aSource [

	|  text textModel textMorph |

	text := self textFor: aSource.

	textModel := RubScrolledTextModel new.
	textMorph := textModel newScrolledText.
	textMorph
		beReadOnly;
		beWrapped.
	textModel setInitialText: text.
	
	 ^ textMorph
]

{ #category : #tests }
DocChapterPresenter >> scrollAt: aScrollValue [
	| morph scroll |
	morph := preview morph.
	scroll := morph scrollPane.
	scroll vScrollbarValue: aScrollValue.
]

{ #category : #accessing }
DocChapterPresenter >> scrollValue [ 
	^ preview morph scrollPane vScrollbarValue
]

{ #category : #accessing }
DocChapterPresenter >> scrollValue: aScrollValue [
	| scrollpane |
	scrollpane := preview morph scrollPane vScrollbarValue: aScrollValue.
]

{ #category : #buttons }
DocChapterPresenter >> setEditButton [
	^ SpButtonPresenter new
		label: 'Edit/Preview';
		action: [ self changeEditView ]
]

{ #category : #buttons }
DocChapterPresenter >> setOpenButton [
	^ SpButtonPresenter new
		label: 'Open';
		action: [ self chapter asPresenter open ]
]

{ #category : #shortcuts }
DocChapterPresenter >> setShortcuts [
	| category morph |
	"preview ifNotNil: [ 
		morph := preview morph.
		category := KMCategory named: #DocChapterShortcut.
		KMRepository default addCategory: category.
		morph attachKeymapCategory: #DocChapterShortcut.
		self openShortcut: category.
		self headerShortcut: category.
		self editShortcut: category ]"
	
]

{ #category : #buttons }
DocChapterPresenter >> setShowHeaderButton [
	^ SpButtonPresenter new
		label: 'Header hide/show';
		action: [ self changeHeaderView ]
]

{ #category : #shortcuts }
DocChapterPresenter >> showChapterShortcut: aCategory [
	aCategory
			addKeymapEntry:
				(KMKeymap named: #ShowChapterShortcut shortcut: $p meta shift mac | $p alt shift win | $p alt shift unix  action: [ 
					 self splitLayoutOrNot. ])
]

{ #category : #initialization }
DocChapterPresenter >> splitLayoutOrNot [

	showEditor := showEditor not.
	^ layout := self layoutShowingEditor: showEditor
]

{ #category : #accessing }
DocChapterPresenter >> text [

	^ preview morph textArea text 
]

{ #category : #preview }
DocChapterPresenter >> textFor: aSource [

	"we cannot use the standard chapter generated text because the rich text composer needs to 
	know the library presenter for generating links, search environment for highlights etc."

	|  text richTextComposer |

	text := [ 
		| tree |
		tree := chapter ast.
		richTextComposer := DocRichTextComposer new
			executor: self;
			css: self chapter css.
		self parent 
			ifNotNil: [ 
				richTextComposer libraryPresenter: self parent.
				self parent actualChapterPresenter: self.
				self parent searchEnv 
					ifNotNil: [ 
						richTextComposer resultEntries: (self parent searchEnv resultEntriesOf: self chapter key).
						richTextComposer currentResultEntry: self parent searchEnv currentResultEntry ] ].
		richTextComposer visit: tree
		]
		on: STONReaderError, MicParsingError, MessageNotUnderstood, SubclassResponsibility 
			do: [ :e | aSource ].
	^ text
]

{ #category : #preview }
DocChapterPresenter >> updatePreview: newSource [ 

	previewUpdateMutex critical: [ 
		updateProcess ifNotNil: [ 
			updateProcess terminate.
			updateProcess := nil ] ].

	"updateProcess := [ 
		newText := self textFor: newSource.
	
		previewUpdateMutex critical: [ 
			self defer: [ 
				preview morph setText: newText ] ]
	] fork."

		previewUpdateMutex critical: [ 
			self defer: [preview morph setText: (self textFor: newSource) ] ].
		
	
]

{ #category : #tests }
DocChapterPresenter >> updateText: aText scrollAt: aScrollValue [
	| morph scroll |
	morph := preview morph.
	morph  textArea  paragraphReplacedTextFrom: 1 to: aText size with: aText.
	scroll := morph scrollPane.
	scroll vScrollbarValue: aScrollValue.
]
