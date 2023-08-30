Extension { #name : #ClyMethodCodeEditorToolMorph }

{ #category : #'*DocumentationSupport' }
ClyMethodCodeEditorToolMorph >> documentationObjectOrNil [

	^ self editingMethod ifNotNil: [ :m | m name ]
]
