Class {
	#name : #DocContextPresenter,
	#superclass : #SpPresenter,
	#instVars : [
		'lastTarget',
		'targetTextInput',
		'resultsList',
		'libraryPresenter',
		'searchEnvironment'
	],
	#category : #'DocumentationSupport-UI-Presenters'
}

{ #category : #layout }
DocContextPresenter class >> defaultLayout [

	^ SpBoxLayout newVertical
		add: #targetTextInput withConstraints: [:c | c expand: false ];
		add: #resultsList withConstraints: [:c |  ];
		yourself
]

{ #category : #initialization }
DocContextPresenter >> initialize [ 

	super initialize.
	
	DocNavigationAnnouncer uniqueInstance
		when: DocNavigationAnnouncement 
		do: [ :ann | self navigatedTo: ann target ]
		for: self.
		
]

{ #category : #initialization }
DocContextPresenter >> initializePresenters [ 

	targetTextInput := self newTextInput
		beNotEditable;
		yourself.

	resultsList := self newTreeTable
		addColumn: (SpStringTableColumn
				          title: 'Chapter'
				          evaluated: [ :result | 
					          result chapter title  ]);
		addColumn: (SpStringTableColumn
				          title: 'Book'
				          evaluated: [ :result | 
					          result chapter book title  ]);
		whenSelectedItemChangedDo: [ :selection |
			selection ifNotNil: [ 
				self showDocumentationOf: selection ] ];
		yourself.
]

{ #category : #initialization }
DocContextPresenter >> initializeWindow: aWindowPresenter [
	aWindowPresenter
		title: 'Documentation Context';
		initialExtent: 500@850;
		windowIcon: (self iconNamed: #book).
		
	aWindowPresenter whenClosedDo: [ DocNavigationAnnouncer uniqueInstance unsubscribe: self ]
]

{ #category : #accessing }
DocContextPresenter >> libraryPresenter [

	^ libraryPresenter
]

{ #category : #accessing }
DocContextPresenter >> libraryPresenter: anObject [

	libraryPresenter := anObject
]

{ #category : #initialization }
DocContextPresenter >> navigatedTo: aTarget [

	| chapters targetString |
	
	targetString := aTarget.	
	targetTextInput text: targetString.
	
	chapters := OrderedCollection new.
	DocLibrary libraries do: [ :lib |
		lib books do: [ :book |
			chapters addAll: book chapters ]
		 ].

	searchEnvironment := DocSearchEnvironment on: (DocSearchRange chapters: chapters posInterval: (1 to: chapters last lastPosition)).

	searchEnvironment search: targetString withSensitiveCase: true isRegex: false.

	resultsList roots: searchEnvironment resultEntries
]

{ #category : #initialization }
DocContextPresenter >> showDocumentationOf: aSearchResult [ 

	searchEnvironment setCurrentResult: aSearchResult.
	libraryPresenter setSearchEnvironment: searchEnvironment.
	libraryPresenter updateOccurenceDisplay.
]
