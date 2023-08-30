Extension { #name : #MicInlineElement }

{ #category : #'*DocumentationSupport' }
MicInlineElement >> addMonospaceTextsTo: aCollection [ 

	children do: [ :each | each addMonospaceTextsTo: aCollection ]
]
