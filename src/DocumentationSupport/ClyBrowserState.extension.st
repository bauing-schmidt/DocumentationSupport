Extension { #name : #ClyBrowserState }

{ #category : #'*DocumentationSupport' }
ClyBrowserState >> navigationChangedTo: aTool [

	| target |

	target := aTool documentationObjectOrNil.
	target ifNotNil: [ 
		DocNavigationAnnouncer uniqueInstance announce: (DocNavigationAnnouncement target: target)
	].

]

{ #category : #'*DocumentationSupport' }
ClyBrowserState >> retrieveStateFrom: aBrowser [

	systemScope :=  aBrowser systemScope.
	viewStates := aBrowser navigationViews collect: [ :each | each snapshotState ].
	selectedTabs := aBrowser tabManager selectedTools
		collect: [ :each | 
			self navigationChangedTo: each.
			each copyForBrowserStateSnapshot ]
]
