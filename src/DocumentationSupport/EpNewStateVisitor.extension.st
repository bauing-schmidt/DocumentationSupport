Extension { #name : #EpNewStateVisitor }

{ #category : #'*DocumentationSupport' }
EpNewStateVisitor >> visitDocChapterAddition: aDocChange [

	^ aDocChange fullStringForDisplay
]

{ #category : #'*DocumentationSupport' }
EpNewStateVisitor >> visitDocChapterModification: aDocChange [

	^ aDocChange fullStringForDisplay
]
