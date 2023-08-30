Extension { #name : #MicElement }

{ #category : #'*DocumentationSupport' }
MicElement >> addMonospaceTextsTo: aCollection [
]

{ #category : #'*DocumentationSupport' }
MicElement >> isMicTextBlock [ 

	^ false
]

{ #category : #'*DocumentationSupport' }
MicElement >> monospaceTexts [ 

	| result |
	result := OrderedCollection new.
	self addMonospaceTextsTo: result.
	^ result.
]
