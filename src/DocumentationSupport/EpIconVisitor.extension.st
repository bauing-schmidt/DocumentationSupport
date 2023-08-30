Extension { #name : #EpIconVisitor }

{ #category : #'*DocumentationSupport' }
EpIconVisitor >> visitDocChange: aDocChange [
	^ self iconNamed: #workspace
]

{ #category : #'*DocumentationSupport' }
EpIconVisitor >> visitDocChapterAddition: aDocChange [
	^ self iconNamed: #add
]

{ #category : #'*DocumentationSupport' }
EpIconVisitor >> visitDocChapterModification: aDocChange [
	^ self iconNamed: #glamorousEdit 
]
