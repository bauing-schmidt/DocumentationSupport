Extension { #name : #ClyNotebookManager }

{ #category : #'*DocumentationSupport' }
ClyNotebookManager >> basicUpdateTools [
		| needsNewSelection selectedTools currentTools |

		needsNewSelection := self requiresNewDesiredSelection.
		selectedTools := self selectedTools.
		currentTools := tools copy.

		self updateTabs.
		(needsNewSelection or: [ tools ~= currentTools ])
			ifTrue: [ self restoreSelectedTools: selectedTools].
			 
		tools do: [ :tool |
			((tool respondsTo: #window ) and: [ tool window notNil and: [ tool window isTopWindow ] ]) ifTrue: [ 
				| target |
				target := tool documentationObjectOrNil.
				target ifNotNil: [ 
					DocNavigationAnnouncer uniqueInstance announce: (DocNavigationAnnouncement target: target)
				] ] ]
]
