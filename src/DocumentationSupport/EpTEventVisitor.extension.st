Extension { #name : #EpTEventVisitor }

{ #category : #'*DocumentationSupport' }
EpTEventVisitor >> visitDocChapterAddition: aDocChange [
	^ self visitEvent: aDocChange
]

{ #category : #'*DocumentationSupport' }
EpTEventVisitor >> visitDocChapterModification: aDocChange [
	^ self visitEvent: aDocChange
]
