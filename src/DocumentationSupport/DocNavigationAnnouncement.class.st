"
an announcement about changed target of the Calypso browser
"
Class {
	#name : #DocNavigationAnnouncement,
	#superclass : #SystemAnnouncement,
	#instVars : [
		'target'
	],
	#category : #'DocumentationSupport-Model'
}

{ #category : #accessing }
DocNavigationAnnouncement class >> target: aTarget [ 

	^ self new 
		target: aTarget;
		yourself
]

{ #category : #accessing }
DocNavigationAnnouncement >> target [

	^ target
]

{ #category : #accessing }
DocNavigationAnnouncement >> target: anObject [

	target := anObject
]
