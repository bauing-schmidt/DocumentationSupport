Extension { #name : #MicMonospaceFormatBlock }

{ #category : #'*DocumentationSupport' }
MicMonospaceFormatBlock >> addMonospaceTextsTo: aCollection [ 

	| aText |

	(self children size = 1 and: [ (aText := children first) isMicTextBlock ]) 
		ifTrue: [ aCollection add: aText ].
]
