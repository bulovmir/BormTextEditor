"
I take parsed Borm DSL and produce instances of Borm Model.
"
Class {
	#name : 'OPBormLangParser',
	#superclass : 'OPBormLangGrammar',
	#instVars : [
		'incompleteTransitions',
		'nodesLookup',
		'participantsLookup',
		'incompleteCommunications'
	],
	#category : 'OpenPonk-BormEditor-Dsl',
	#package : 'OpenPonk-BormEditor',
	#tag : 'Dsl'
}

{ #category : 'accessing' }
OPBormLangParser class >> ignoredNames [
	^ super ignoredNames, #(incompleteTransitions nodesLookup incompleteCommunications participantsLookup)
]

{ #category : 'accessing' }
OPBormLangParser >> activity [
	"activity
	^ super activity ==> [ :pair | nodesLookup at: pair value put: (BormActivity named: pair key) ]
	activity
	^ super activity ==> [ :pair | nodesLookup at: pair first put: (BormActivity named: pair second) ]"
	^ super activity ==> [ :pair | nodesLookup at: pair first first put: (pair second ifNil:[BormActivity named: pair first second] ifNotNil: [(BormActivity named: pair first second)submodel: (BormORModel named: pair second);yourself]) ]
 
]

{ #category : 'accessing' }
OPBormLangParser >> checkCommunicationIds: arr [

	| source target |
	"check if nodes exist, are of type BormActivity and whether they are not in the same participant"
	^ (participantsLookup includesKey: arr first key) and: [
			  ((participantsLookup at: arr first key) includesKey:
				   arr first value) and: [
					  (participantsLookup includesKey: arr second key) and: [
							  ((participantsLookup at: arr second key) includesKey:
								   arr second value) and: [
									  source := (participantsLookup at: arr first key) at:
										            arr first value.
									  (source isKindOf: BormActivity) and: [
											  target := (participantsLookup at: arr second key) at:
												            arr second value.
											  (target isKindOf: BormActivity) and: [ target owner ~= source owner] ] ] ] ] ]
]

{ #category : 'accessing' }
OPBormLangParser >> communication [
	^ super communication
		==> [ :arr | 
			| comm s r  |
			comm := BormCommunication new.
			(self checkCommunicationIds:arr)  ifFalse: [ PPFailure new ] ifTrue:[
			s :=((participantsLookup at: arr first key ) at: arr first value).
			r :=((participantsLookup at: arr second key) at: arr second value).
			comm sender: s.
			comm receiver: r.
			arr third = '->' ifFalse: [comm constraint: arr third ].
			arr fourth ifNotNil: [  arr fourth do:[:each| comm addDataFlow:each ]].
			r receive: comm.
			s send: comm.
			comm .]]
]

{ #category : 'accessing' }
OPBormLangParser >> constraint [
	^ super constraint ==> [ :condition | condition ifNotNil: [ BormConstraint named: condition second] ]
]

{ #category : 'accessing' }
OPBormLangParser >> dataFlow [
	^ super dataFlow ==> [ :df ||f| f:=BormDataFlow named: df second second .
		df first = 'o->' ifTrue: [ f beOutput ].f]

]

{ #category : 'accessing' }
OPBormLangParser >> diagram [
	^ super diagram
		==> [ :arr | 
			| d |
			d := BormORModel new.
			d addAll: arr second.
			d name: arr fourth.
			d ]"
	^ super diagram
		==> [ :arr | 
			| d |
			d := BormORModel new.
			d addAll: arr.

			incompleteCommunications
				do: [ :each | 
					| n splitName |
					splitName := (each receiver splitOn: '::').
					n := (participantsLookup at: splitName first) at: splitName second.
					n receive: each.
					each receiver: n ].

			d ]"
]

{ #category : 'accessing' }
OPBormLangParser >> idNode [
	^ super idNode ==> [ :i|  (nodesLookup includesKey: i ) ifFalse: [ PPFailure new ] ifTrue: [nodesLookup at: i ]].
	
]

{ #category : 'initialization' }
OPBormLangParser >> initialize [
	super initialize.
	self resetCache
]

{ #category : 'accessing' }
OPBormLangParser >> node [
	^ super node
	
]

{ #category : 'parsing' }
OPBormLangParser >> parseStatements: aString [
	^ self parse: aString
]

{ #category : 'accessing' }
OPBormLangParser >> participant [
	^ super participant
		==> [ :arr | 
			| p |
			
			p := BormParticipant new
				name: arr second second;
				type: arr first;
				yourself.
				nodesLookup keysAndValuesDo: [:key :value| p add: value  ].
				participantsLookup at: arr second first put: nodesLookup.
				nodesLookup := Dictionary new.
				p ]
				"
	^ super participant
		==> [ :arr | 
			| p |
			p := BormParticipant new
				name: arr second key;
				type: arr first;
				yourself.
			""insert all nodes""
			arr third do: [ :each | p add: each ].
			""finish transitions""
			incompleteTransitions
				do: [ :each | 
					| n |
					n := nodesLookup at: each target.
					n addTransition: each.
					each target: n ].
			incompleteTransitions removeAll.
			participantsLookup at: arr second value put: nodesLookup.
			nodesLookup := Dictionary new.
			p ]"
]

{ #category : 'accessing' }
OPBormLangParser >> participantType [
	^ super participantType ==> [ :str | BormParticipantType perform: str asSymbol ]
]

{ #category : 'parsing' }
OPBormLangParser >> replaceModel: aModel withStatements: parsedModel [
	aModel elements reset.
	parsedModel elements do: [ :each | aModel add: each ]

		"replaceModel: aModel withStatements: parsedModel
	aModel elements reset.
	parsedModel elements do: [ :each | aModel add: each ]"
]

{ #category : 'private' }
OPBormLangParser >> resetCache [
	nodesLookup := Dictionary new.
	participantsLookup := Dictionary new.
	incompleteTransitions := OrderedCollection new.
	incompleteCommunications := OrderedCollection new
]

{ #category : 'accessing' }
OPBormLangParser >> state [

	^ super state
		map: [ :arr | 
			| s t |
			t := arr first.
			s := BormState named: arr second second .
			arr third ifNotNil: [s submodel: (BormORModel named: arr third ) ].
			nodesLookup at: arr second first put: s.
			t
				ifNotNil: [ 
					t = '[*'
						ifTrue: [ s beInitial ].
					t = '[['
						ifTrue: [ s beFinal ].
					t = '[[*'
						ifTrue: [ 
							s
								beInitial;
								beFinal ] ].
			s ]"
	^ super state
		map: [ :arr | 
			| s t |
			t := arr first.
			s := BormState named: arr second key.
			nodesLookup at: arr second value put: s.
			t
				ifNotNil: [ 
					t = 'initial'
						ifTrue: [ s beInitial ].
					t = 'final'
						ifTrue: [ s beFinal ].
					t = 'initial and final'
						ifTrue: [ 
							s
								beInitial;
								beFinal ] ].
			s ]"
]

{ #category : 'accessing' }
OPBormLangParser >> transition [
		"transition
	^ super transition
		==> [ :arr | 
			| t |
			t := BormTransition new.
			t source: arr first.
			t target: arr second.
			t ]"
	^ super transition
		==> [ :arr | |check|
			check:= false.
			arr size>=2 ifTrue:  [ arr do:[ :each|
					|nextIndex nextElement|
				
				nextIndex:= ((arr indexOf:each)+1).
				nextElement := (arr at: nextIndex  ifAbsent: [ nil ]).
				nextElement ifNotNil: [  
					| t |
			((nextElement second ~= each second ) and:[ (((nextElement second isKindOf:BormActivity)and:[each second isKindOf:BormState  ])or:[  ((each second isKindOf:BormActivity)and:[nextElement second isKindOf:BormState  ])])]) ifFalse: [ check:=true. ] ifTrue:[
				((nextElement first isNotNil) and: [ nextElement second isKindOf: BormState])ifTrue:[check:=true. ] ifFalse:[
			t := BormTransition new.
			t target: nextElement second;
			source: each second.
			nextElement first ifNotNil: [ t constraint: nextElement first ].
			each second addTransition: t.
			nextElement second addTransition: t.			
								t 	]]]]. check ifTrue:[ PPFailure new  ]]]
			
]
