Extension { #name : #MicAbstractBlock }

{ #category : #'*DocumentationSupport' }
MicAbstractBlock >> addMonospaceTextsTo: aCollection [ 

	children do: [ :each | each addMonospaceTextsTo: aCollection ]
]
