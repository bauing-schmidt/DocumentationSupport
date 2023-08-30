Class {
	#name : #DocNavigationAnnouncer,
	#superclass : #Announcer,
	#classInstVars : [
		'uniqueInstance'
	],
	#category : #'DocumentationSupport-Model'
}

{ #category : #accessing }
DocNavigationAnnouncer class >> reset [ 

	<script>

	uniqueInstance := self new
]

{ #category : #accessing }
DocNavigationAnnouncer class >> uniqueInstance [ 

	^ uniqueInstance ifNil: [ uniqueInstance := self new ]
]

{ #category : #announce }
DocNavigationAnnouncer >> announce: anAnnouncement [ 

	^ super announce: anAnnouncement 
	
]
