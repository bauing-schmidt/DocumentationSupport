Extension { #name : #EpMorphVisitor }

{ #category : #'*DocumentationSupport' }
EpMorphVisitor >> visitDocChapterAddition: aDocChange [

	^ (self displayOperation: 'Doc Chapter Add:')
]

{ #category : #'*DocumentationSupport' }
EpMorphVisitor >> visitDocChapterModification: aDocChange [

	^ (self displayOperation: 'Doc Chapter Modify:')
]
