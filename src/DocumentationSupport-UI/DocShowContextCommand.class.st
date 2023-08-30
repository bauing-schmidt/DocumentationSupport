Class {
	#name : #DocShowContextCommand,
	#superclass : #DocStCommand,
	#category : #'DocumentationSupport-UI-Commands'
}

{ #category : #default }
DocShowContextCommand class >> defaultDescription [

	^ 'Show Documentation context window'
]

{ #category : #default }
DocShowContextCommand class >> defaultIconName [

	^ #announcement
]

{ #category : #default }
DocShowContextCommand class >> defaultName [

	^ 'Context window'
]

{ #category : #accessing }
DocShowContextCommand class >> priority [ 

	^ 2000
]

{ #category : #executing }
DocShowContextCommand >> execute [ 

	| contextPresenter |
	contextPresenter := DocContextPresenter new
		libraryPresenter: context;
		open.
	
]
