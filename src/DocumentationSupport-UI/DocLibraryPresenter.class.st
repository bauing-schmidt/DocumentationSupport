"
A presenter of the documentaion library.

Currently the top-most UI. 

## Usage

```
DocLibraryPresenter open: #LibraryName.
```
"
Class {
	#name : #DocLibraryPresenter,
	#superclass : #DocModelPresenter,
	#instVars : [
		'library',
		'tree',
		'editor',
		'toolbar',
		'treeMenu',
		'docSearchObject',
		'searchInput',
		'searchPattern',
		'searchEnv',
		'chapterDropList',
		'occurenceDisplay',
		'actualChapter',
		'lastChapterPresenter',
		'actualChapterPresenter',
		'hasNextChapterChange',
		'hasPrevChapterChange',
		'editCheckBox',
		'showCheckBox',
		'showHeaderCheckBox',
		'sensitiveCaseCheckBox',
		'regexCheckBox'
	],
	#classInstVars : [
		'searchInput'
	],
	#category : #'DocumentationSupport-UI-Presenters'
}

{ #category : #layout }
DocLibraryPresenter class >> defaultLayout [
	^ SpBoxLayout newVertical
		spacing: 3.
]

{ #category : #'instance creation' }
DocLibraryPresenter class >> on: aLibrary [ 

	^ self basicNew 
		library: aLibrary;
		initialize
]

{ #category : #opening }
DocLibraryPresenter class >> open: libraryName [

	<script>
	DocLibrary libraries ifEmpty: [ DocLibrary loadFromRepositories ].
	^ (self on: (DocLibrary named: libraryName)) open
]

{ #category : #accessing }
DocLibraryPresenter >> actualChapterPresenter [

	^ actualChapterPresenter
]

{ #category : #accessing }
DocLibraryPresenter >> actualChapterPresenter: anObject [

	actualChapterPresenter := anObject
]

{ #category : #actions }
DocLibraryPresenter >> addNewBook [

	| newBook |
	
	newBook := library addNewBook.
		
	self updateTree.
	tree selectItem: newBook
]

{ #category : #actions }
DocLibraryPresenter >> addNewChapter [

	| newChapter |
	tree selectedItem ifNil: [ 
		self inform: 'No book or chapter selected'.
		^ self ].
	
	newChapter := tree selectedItem addNewChapter.
		
	self updateTree.
	tree selectItem: newChapter
]

{ #category : #events }
DocLibraryPresenter >> aspect: anAspect changedFrom: anOrigin [

	anOrigin = self ifTrue: [ ^ self ].
	
	anAspect = #books ifTrue: [ self updateTree ].	
	anAspect = #chapters ifTrue: [ self updateTree ].
	anAspect = #hierarchyNames ifTrue: [ self refreshTree ].
]

{ #category : #actions }
DocLibraryPresenter >> clickAt [
	actualChapter ifNotNil: [ 
		lastChapterPresenter := actualChapterPresenter.
		tree clickAtPath: actualChapter path ]
	
]

{ #category : #actions }
DocLibraryPresenter >> clickAt: path [
	tree clickAtPath: path
]

{ #category : #actions }
DocLibraryPresenter >> delete: anObject [

	((self confirm: 'Really delete ', anObject name, '?') = true)
		ifFalse: [ ^ self ].
	
	anObject delete.

	tree roots: tree roots.
	tree expandAll.
	

]

{ #category : #accessing }
DocLibraryPresenter >> docSearchObject [
	^ docSearchObject
]

{ #category : #accessing }
DocLibraryPresenter >> docSearchObject: aDocSearchObject [
	docSearchObject := aDocSearchObject
]

{ #category : #'shortcuts-chapter' }
DocLibraryPresenter >> editChapterShortcut: aCategory [
	aCategory
			addKeymapEntry:
				(KMKeymap named: #EditChapterShortcut shortcut: $e meta shift mac | $e alt shift win | $e alt shift unix "| $e alt"  action: [ actualChapterPresenter changeEditView ])
]

{ #category : #'parameters-bar' }
DocLibraryPresenter >> editModeEnable [
	^ editCheckBox state
]

{ #category : #shortcuts }
DocLibraryPresenter >> editShortcut: aCategory [
	aCategory
			addKeymapEntry:
				(KMKeymap named: #EditShortcut shortcut: $e ctrl shift mac | $e ctrl shift win | $e ctrl shift unix  action: [ 
					editCheckBox state: editCheckBox state not ])
]

{ #category : #actions }
DocLibraryPresenter >> export [ 

	library repository export: library.
	library makeClean

]

{ #category : #'shortcuts-chapter' }
DocLibraryPresenter >> headerChapterShortcut: aCategory [
	aCategory
			addKeymapEntry:
				(KMKeymap named: #HeaderChapterShortcut shortcut: $h meta shift mac | $h alt shift win | $h alt shift unix "| $h alt"  action: [ actualChapterPresenter changeHeaderView ])
]

{ #category : #shortcuts }
DocLibraryPresenter >> headerShortcut: aCategory [
	aCategory
			addKeymapEntry:
				(KMKeymap named: #HeaderShortcut shortcut: $h ctrl shift mac | $h ctrl shift win | $h ctrl shift unix | $h alt  action: [ 
					showHeaderCheckBox state: showHeaderCheckBox state not ])
]

{ #category : #initialization }
DocLibraryPresenter >> initializePresenters [ 

	super initializePresenters.
	hasPrevChapterChange := false.
	hasNextChapterChange := false.
	
	showHeaderCheckBox := SpCheckBoxPresenter new label: 'Show header'.
	editCheckBox := SpCheckBoxPresenter new label: 'Edit mode'.
	showCheckBox := SpCheckBoxPresenter new label: 'Show preview/edit mode'.
	sensitiveCaseCheckBox := SpCheckBoxPresenter new label: 'Sensitive Case'.
	regexCheckBox := SpCheckBoxPresenter new label: 'Regex mode'.
	
	docSearchObject := DocSearchEnvironment new.
	tree := self newTree.
	editor := self instantiate: DocPanePresenter.
	editor parent: self.
	
	tree 
		roots: library books;
 		children: [ :aBookOrChapter | aBookOrChapter children ];
		displayIcon: [ :aBookOrChapter | aBookOrChapter icon ];
		display: [ :aBookOrChapter | aBookOrChapter title ];
		dragEnabled: true;
		dropEnabled: true;
		wantsDrop: [ :transfer | transfer passenger allSatisfy: [ :each | each isKindOf: DocChapter ] ];
		acceptDrop: [ :transfer | 		
			transfer target ifNotNil: [
				transfer target acceptDrop: transfer passenger ] ];
		expandAll.
		

		
	tree transmitTo: editor.
	
	self setupTreeMenu.
	
	self initializeToolbar.
	
	library whenAspectChangedNotify: self 

]

{ #category : #initialization }
DocLibraryPresenter >> initializeToolbar [

	toolbar := self newToolbar
		addStyle: 'stToolbar';
		fillWith: self toolbarActions;
		yourself
]

{ #category : #initialization }
DocLibraryPresenter >> initializeWindow: aWindowPresenter [
	aWindowPresenter
		title: self library name;
		initialExtent: 1100@850;
		windowIcon: (self iconNamed: #book)
]

{ #category : #accessing }
DocLibraryPresenter >> library [

	^ library
]

{ #category : #accessing }
DocLibraryPresenter >> library: anObject [

	library := anObject
]

{ #category : #'search-actions' }
DocLibraryPresenter >> next [

	| oldEntry |
	oldEntry := searchEnv currentResultEntry.
	searchEnv nextResultEntry.
	actualChapter key = searchEnv currentResultEntry chapter key
		ifTrue: [ self updateText: oldEntry ]
		ifFalse: [ 
			actualChapter := searchEnv currentResultEntry chapter.
			searchInput owner clickAt.
			hasNextChapterChange := true.
			self updateText: searchEnv currentResultEntry ].
	self updateOccurenceDisplay
]

{ #category : #'search-actions' }
DocLibraryPresenter >> nextAction [
	self next.
	hasNextChapterChange 
		ifTrue: [ 			
			actualChapterPresenter scrollValue: searchEnv currentResultEntry scrollValue. 
			hasNextChapterChange := false ] 
]

{ #category : #'search-actions' }
DocLibraryPresenter >> nextChapter [

	^ searchEnv ifNotNil: [ [ 
		  searchEnv nextChapterInResultEntries.
		  actualChapter := searchEnv currentResultEntry chapter.
		  searchInput owner clickAt.
		  self updateOccurenceDisplay ]
			  on: SubscriptOutOfBounds , MessageNotUnderstood
			  do: [ "nothing" ] ]
]

{ #category : #shortcuts }
DocLibraryPresenter >> nextChapterShortcut: aCategory [
	aCategory
			addKeymapEntry:
				(KMKeymap named: #NextChapterShortcut shortcut: Character arrowUp ctrl shift mac | Character arrowUp ctrl shift win | Character arrowUp ctrl shift unix  action: [ 
					 self nextChapter ])
]

{ #category : #shortcuts }
DocLibraryPresenter >> nextShortcut: aCategory [
	aCategory
			addKeymapEntry:
				(KMKeymap named: #NextShortcut shortcut: Character arrowRight ctrl shift mac | Character arrowRight ctrl shift win | Character arrowRight ctrl shift unix  action: [ 
					 searchEnv 
						ifNotNil: [ [ self nextAction ] on: SubscriptOutOfBounds,MessageNotUnderstood  do: [ "nothing" ] ] ])
]

{ #category : #'instance creation' }
DocLibraryPresenter >> open [
	self layout 
		add: #toolbar expand: false;
		add: self searchBar withConstraints: [  :constraints | constraints height: 20 ];
		add: self parametersBar height: 20;	
		add: (SpBoxLayout newHorizontal
			spacing: 10;
			add: #tree withConstraints: [  :constraints | constraints width: 300 ];
			add: #editor expand: true fill: true  ;
			yourself) expand: true.
		super open.
		self setShortcuts.
]

{ #category : #actions }
DocLibraryPresenter >> openChapter: aKey [

	| aChapter | 
	aChapter := library chapterOfKey: aKey.
	tree selectItem: aChapter.
		
	
	

]

{ #category : #'shortcuts-chapter' }
DocLibraryPresenter >> openChapterAction [

	| morph presenter category |
	presenter := actualChapterPresenter chapter asPresenter open.
	morph := presenter window submorphs last.
	category := KMCategory named: #DocChapterShortcut.
	KMRepository default addCategory: category.
	morph attachKeymapCategory: #DocChapterShortcut.
	
	presenter presenter headerShortcut: category;
	editShortcut: category;
	openShortcut: category;
	showChapterShortcut: category
]

{ #category : #'shortcuts-chapter' }
DocLibraryPresenter >> openChapterShortcut: aCategory [

	aCategory addKeymapEntry: (KMKeymap
			 named: #OpenChapterShortcut
			 shortcut: $o meta shift mac | $o alt shift win | $o alt shift unix
			 action: [ self openChapterAction ])
]

{ #category : #actions }
DocLibraryPresenter >> openInWindow: item [

	item openIn: self application
]

{ #category : #'parameters-bar' }
DocLibraryPresenter >> parametersBar [
	showHeaderCheckBox whenChangedDo: [ self refreshChapter ].
	editCheckBox whenChangedDo: [ self refreshChapter ].
	showCheckBox whenChangedDo: [ self refreshChapter ].
	sensitiveCaseCheckBox whenChangedDo: [ self refreshChapter ].
	regexCheckBox whenChangedDo: [ self refreshChapter ].
	^ SpBoxLayout newHorizontal
		  add: showHeaderCheckBox height: 20;
		  add: editCheckBox height: 20;
		  add: showCheckBox height: 20;
		  add: sensitiveCaseCheckBox height: 20;
		  add: regexCheckBox height: 20
]

{ #category : #'search-actions' }
DocLibraryPresenter >> prev [
	| oldEntry |
	oldEntry := searchEnv currentResultEntry.
	searchEnv prevResultEntry.
	actualChapter key = searchEnv currentResultEntry chapter key 
		ifTrue: [ self updateText: oldEntry ]
		ifFalse: [ 
			actualChapter := searchEnv currentResultEntry chapter.
			searchInput owner clickAt.
			hasPrevChapterChange := true.
			self updateText: searchEnv currentResultEntry ].
	self updateOccurenceDisplay
]

{ #category : #'search-actions' }
DocLibraryPresenter >> prevAction [
	self prev.
	^ hasPrevChapterChange
		  ifTrue: [ 
			  actualChapterPresenter scrollValue: searchEnv currentResultEntry scrollValue.
			  hasPrevChapterChange := false ]
]

{ #category : #'search-actions' }
DocLibraryPresenter >> prevChapter [

	^ searchEnv ifNotNil: [ 
		  [ 
		  searchEnv prevChapterInResultEntries.
		  actualChapter := searchEnv currentResultEntry chapter.
		  searchInput owner clickAt.
		  self updateOccurenceDisplay ]
			  on: SubscriptOutOfBounds , MessageNotUnderstood
			  do: [ "nothing" ] ]
]

{ #category : #shortcuts }
DocLibraryPresenter >> prevChapterShortcut: aCategory [
	aCategory
			addKeymapEntry:
				(KMKeymap named: #PrevChapterShortcut shortcut: Character arrowDown ctrl shift mac | Character arrowDown ctrl shift win | Character arrowDown ctrl shift unix  action: [ 
					 self prevChapter ])
]

{ #category : #shortcuts }
DocLibraryPresenter >> prevShortcut: aCategory [
	aCategory
			addKeymapEntry:
				(KMKeymap named: #PrevShortcut shortcut: Character arrowLeft ctrl shift mac | Character arrowLeft ctrl shift win | Character arrowLeft ctrl shift unix  action: [ 
					 searchEnv 
						ifNotNil: [ [ self prevAction ] on: SubscriptOutOfBounds,MessageNotUnderstood  do: [ "nothing" ] ] ])
]

{ #category : #'parameters-bar' }
DocLibraryPresenter >> refreshChapter [
	[tree clickAtPath: actualChapterPresenter path] 
		on: MessageNotUnderstood 
		do: [ "nothing" ] 
]

{ #category : #tree }
DocLibraryPresenter >> refreshTree [ 

	tree refresh

]

{ #category : #'parameters-bar' }
DocLibraryPresenter >> regexModeEnable [
	^ regexCheckBox state
]

{ #category : #'search-bar' }
DocLibraryPresenter >> resetSearchEnv [
	searchEnv := nil.
	searchPattern := ''
]

{ #category : #'search-actions' }
DocLibraryPresenter >> searchAction [
	| chapters env |
	"Create collection with all chapters of the library"
	chapters := OrderedCollection new.
	searchInput owner library books do: [ :book | 
		chapters addAll: book chapters].
	"Execute the search"
	env:= DocSearchEnvironment on: (DocSearchRange chapters: chapters posInterval: (1 to: chapters first lastPosition)).
	env search: searchPattern  withSensitiveCase: self sensitiveCaseEnable isRegex: self regexModeEnable.
	"Display the number of occurence"
	^ env

]

{ #category : #'search-bar' }
DocLibraryPresenter >> searchBar [
	searchInput := SpTextInputFieldPresenter new placeholder: 'Enter you search'.
	occurenceDisplay := SpTextInputFieldPresenter new beNotEditable.
	self setSearchAction;
	setChapterDropList.

	^ SpBoxLayout newHorizontal
		  add: searchInput;
		  add: self setSearchButton
		  height: 20;
		  add: self setPreviousButton
		  height: 20;
		  add: self setNextButton
		  height: 20;
		  add: self setPreviousChapterButton
		  height: 20;
		  add: self setNextChapterButton
		  height: 20;
		  add: chapterDropList;
		  add: occurenceDisplay
]

{ #category : #accessing }
DocLibraryPresenter >> searchEnv [

	^ searchEnv
]

{ #category : #shortcuts }
DocLibraryPresenter >> searchShortcut: aCategory [
	aCategory
			addKeymapEntry:
				(KMKeymap named: #SearchShortcut shortcut: $l ctrl shift mac | $l ctrl shift win | $l ctrl shift unix  action: [ 
					 searchInput takeKeyboardFocus ])
]

{ #category : #'parameters-bar' }
DocLibraryPresenter >> sensitiveCaseEnable [
	^ sensitiveCaseCheckBox state
]

{ #category : #'search-buttons' }
DocLibraryPresenter >> setChapterDropList [
	chapterDropList := SpDropListPresenter new 
		help: 'Select the chapter.';
		display: [ :resultEntry | resultEntry chapter title ];
		whenSelectedItemChangedDo: [ :resultEntry | 
			resultEntry ifNotNil: [ 
				searchEnv firstOccurrenceOf: resultEntry chapter.
				actualChapter := resultEntry chapter.
				searchInput owner clickAt.
				hasNextChapterChange := true.
				self updateOccurenceDisplay ]
			 ];
		extent: 400@20;
		yourself
]

{ #category : #'search-bar' }
DocLibraryPresenter >> setLastOccurenceByChapter: occurenceCollection [
	| lastChapterOccurence lastOccurenceByChapter |
	lastOccurenceByChapter := OrderedCollection new.
	lastChapterOccurence := 0.
	occurenceCollection doWithIndex: [ :o :i |  lastChapterOccurence := lastChapterOccurence + o. lastOccurenceByChapter add: lastChapterOccurence ].
	^ lastOccurenceByChapter
]

{ #category : #'search-buttons' }
DocLibraryPresenter >> setNextButton [
	^ SpButtonPresenter new
		label: 'Next';
		action: [ 	searchEnv 
			ifNotNil: [ [ self nextAction ] on: SubscriptOutOfBounds,MessageNotUnderstood  do: [ "nothing" ] ]  ]
]

{ #category : #'search-buttons' }
DocLibraryPresenter >> setNextChapterButton [

	^ SpButtonPresenter new
		  label: 'Next chapter';
		  action: [ self nextChapter ]
]

{ #category : #'search-buttons' }
DocLibraryPresenter >> setPreviousButton [

	^ SpButtonPresenter new
		  label: 'Previous';
		  action: [ searchEnv ifNotNil: [ [ self prevAction ]  on: SubscriptOutOfBounds , MessageNotUnderstood do: [ "nothing" ] ] ]
]

{ #category : #'search-buttons' }
DocLibraryPresenter >> setPreviousChapterButton [

	^ SpButtonPresenter new
		  label: 'Previous chapter';
		  action: [ self prevChapter ]
]

{ #category : #'search-bar' }
DocLibraryPresenter >> setSearchAction [
	searchInput whenSubmitDo: [ :null |
		searchPattern = searchInput text 
				ifTrue: [ 
					searchEnv ifNotNil: [ [ self nextAction	] on: SubscriptOutOfBounds,MessageNotUnderstood  do: [ "nothing" ] ]
			   ] 
				ifFalse: [ 
					[ searchPattern := searchInput text.
					searchEnv := self searchAction.
					"Display in presenter the first occurence"
					self updateOccurenceDisplay.
					chapterDropList items: searchEnv firstResultEntriesForEachChapters.
					actualChapter := searchEnv currentResultEntry chapter.
					searchInput owner clickAt.
					 ] on: SubscriptOutOfBounds,MessageNotUnderstood  do: [ self clickAt ].		
				]	].
			
]

{ #category : #'search-buttons' }
DocLibraryPresenter >> setSearchButton [
	^ SpButtonPresenter new
					   label: 'Search';
					   action: [ [
							searchPattern := searchInput text.
							searchEnv := self searchAction.
							"Display in presenter the first occurence"
							self updateOccurenceDisplay.
							chapterDropList items: searchEnv firstResultEntriesForEachChapters.
							actualChapter := searchEnv currentResultEntry chapter.
							searchInput owner clickAt.
							] on: SubscriptOutOfBounds,MessageNotUnderstood  do: [ self clickAt ]  ]
]

{ #category : #'search-bar' }
DocLibraryPresenter >> setSearchEnvironment: aSearchEnvironment [ 

	| oldEntry |
	searchEnv := aSearchEnvironment.
	
	oldEntry := searchEnv currentResultEntry.
				
	self updateOccurenceDisplay.
	chapterDropList items: searchEnv firstResultEntriesForEachChapters.
	actualChapter := searchEnv currentResultEntry chapter.
	searchInput owner clickAt.
	
	actualChapterPresenter scrollAt: searchEnv currentResultEntry scrollValue
]

{ #category : #shortcuts }
DocLibraryPresenter >> setShortcuts [
	| category morph |
		morph := self owner window submorphs last.
		category := KMCategory named: #DocLibraryShortcut.
		KMRepository default addCategory: category.
		morph attachKeymapCategory: #DocLibraryShortcut.
		
		"Set chapter shortcuts"
		self openChapterShortcut: category;
		headerChapterShortcut: category;
		editChapterShortcut: category;
		showChapterShortcut: category.
		
		
		"Set library shortcuts"
		self headerShortcut: category;
		editShortcut: category;
		showShortcut: category;
		nextShortcut: category;
		prevShortcut: category;
		nextChapterShortcut: category;
		prevChapterShortcut: category;
		searchShortcut: category
]

{ #category : #tree }
DocLibraryPresenter >> setupTreeMenu [
	
	treeMenu := SpMenuPresenter new.
	treeMenu 
		addItem: [ :item | item
			icon: (self iconNamed: #open);
			name: 'Open in a new window';
			action: [ self openInWindow: tree selectedItem ] ].

	treeMenu 
		addItem: [ :item | item
			icon: (self iconNamed: #delete);
			name: 'Delete';
			action: [ self delete: tree selectedItem ] ].

	treeMenu 
		addItem: [ :item | item
			icon: (self iconNamed: #glamorousInspect);
			name: 'Inspect';
			action: [ tree selectedItem inspect ] ].

	tree contextMenu: treeMenu.

]

{ #category : #'shortcuts-chapter' }
DocLibraryPresenter >> showChapterShortcut: aCategory [
	aCategory
			addKeymapEntry:
				(KMKeymap named: #ShowChapterShortcut shortcut: $p meta shift mac | $p alt shift win | $p alt shift unix  action: [ 
					 actualChapterPresenter splitLayoutOrNot. ])
]

{ #category : #'parameters-bar' }
DocLibraryPresenter >> showHeaderModeEnable [
	^ showHeaderCheckBox state
]

{ #category : #'parameters-bar' }
DocLibraryPresenter >> showModeEnable [
	^ showCheckBox state
]

{ #category : #shortcuts }
DocLibraryPresenter >> showShortcut: aCategory [
	aCategory
			addKeymapEntry:
				(KMKeymap named: #ShowShortcut shortcut: $p ctrl shift mac | $p ctrl shift win | $p ctrl shift unix  action: [ 
					 showCheckBox state: showCheckBox state not ])
]

{ #category : #actions }
DocLibraryPresenter >> toolbarActions [

	| aGroup commandClasses |
	
	aGroup := CmCommandGroup forSpec.
	commandClasses := DocStCommand allSubclasses sorted: [ :a :b | a priority <= b priority ].
	commandClasses do: [ :aCommandClass | 
		aGroup register: (aCommandClass forSpecContext: self) ].

	^ CmCommandGroup forSpec
		  register: aGroup;
		  yourself
]

{ #category : #'search-bar' }
DocLibraryPresenter >> updateOccurenceDisplay [
	[occurenceDisplay text: searchEnv currentEntryIndex asString , '/' , searchEnv resultEntries size asString , ' in ', searchEnv currentResultEntry chapter title] on: MessageNotUnderstood do: [ occurenceDisplay text: '0/0' ] 
]

{ #category : #'search-bar' }
DocLibraryPresenter >> updateText: previousEntry [
	| text tmpPresenter |
	tmpPresenter := actualChapter asPresenter.
	text := actualChapterPresenter text.
	actualChapterPresenter chapter key = actualChapter key ifFalse: [ text := tmpPresenter text ].
	text addAttribute: (TextBackgroundColor new color: Color lightGray) from: previousEntry startPosition to: previousEntry endPosition.
	text addAttribute: (TextBackgroundColor new color: Color green) from: searchEnv currentResultEntry startPosition to: searchEnv currentResultEntry endPosition.
	actualChapterPresenter updateText: text	scrollAt: searchEnv currentResultEntry scrollValue
]

{ #category : #tree }
DocLibraryPresenter >> updateTree [

	tree roots: tree roots.
	tree expandAll.
	

]
