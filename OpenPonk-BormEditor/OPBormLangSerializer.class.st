"
I take a BORM model and produce its BormLang string representation.

!! Synchronization
The inverse operation (taking DSL and parsing it) is provided by BormLangGrammar/BormLangParser
"
Class {
	#name : 'OPBormLangSerializer',
	#superclass : 'Object',
	#instVars : [
		'diagram',
		'transitionsList',
		'nodesList',
		'participantsList',
		'activityNodes',
		'participantCounter',
		'nodeCounter'
	],
	#category : 'OpenPonk-BormEditor-Dsl',
	#package : 'OpenPonk-BormEditor',
	#tag : 'Dsl'
}

{ #category : 'public-exporting' }
OPBormLangSerializer class >> export: aDiagram [
	^ self new diagram: aDiagram
]

{ #category : 'converting' }
OPBormLangSerializer >> activity: anActivity [
|val|
val :=(nodesList at:anActivity).
^val second ifTrue:[val third ifFalse:[val at:3 put: true. nodesList at: anActivity put: val. self tab,'(', (self fullNameOpenedWithCheckForSubmodel: anActivity),')'  ] ifTrue:[ self tab, ((  (nodesList at: anActivity )fourth)) ]] ifFalse: [ self tab, '(', (self nameOpenedWithChecksForSubmodel: anActivity),')' ]
	
]

{ #category : 'converting' }
OPBormLangSerializer >> activityNode: anActivity [
	^ (self activity: anActivity) , (self newLineIf: anActivity sent isNotEmpty), (self communications: anActivity sent)
]

{ #category : 'accessing' }
OPBormLangSerializer >> addNode: aNode [
|val id|
id:= self generateNodeId: aNode.
val:= nodesList at: aNode ifAbsentPut: [ ((aNode isKindOf: BormActivity) and: [aNode communications isNotEmpty])
		ifTrue:[{0.true.false.id}] ifFalse: [{0.false.false.id} ]].
val at:1 put: (val first +1).
val first >1 ifTrue: [ val at:2 put:true ].
nodesList at: aNode put: val.

]

{ #category : 'converting' }
OPBormLangSerializer >> collectCommunications [
	^ self newLine, ((activityNodes collect: [ :each | (self communications: (each first communications select:[ :each2 | each2 sender = each first])) ])asArray joinUsing: '')
]

{ #category : 'converting' }
OPBormLangSerializer >> communication: aCommunication [
	| from to con flows  |
	from:=aCommunication sender.
	to := aCommunication receiver.
	flows := aCommunication dataFlows.
	con:=aCommunication constraint.

	^ (participantsList at: from owner), ' ',( (activityNodes detect: [: each| each first =from]) second),(self tab) ,(self communicationConstraint: con),(self tab),(participantsList at: to owner), ' ',( (activityNodes detect: [: each| each first =to]) second), (self tab),(self dataFlows:flows),(self newLine)
]

{ #category : 'converting' }
OPBormLangSerializer >> communicationConstraint: aConstraint [
	^ aConstraint ifNil: [ '->' ] ifNotNil: [ '-' , (aConstraint name ='' ifTrue: ['"condition"'] ifFalse: [self nameOpened: aConstraint] ),'>' ]
]

{ #category : 'converting' }
OPBormLangSerializer >> communications: aCollection [
	^ (aCollection  collect: [ :each | self tab , (self communication: each) ]) joinUsing: ''
]

{ #category : 'converting' }
OPBormLangSerializer >> constraint: aConstraint [
	^ aConstraint ifNil: [ '' ] ifNotNil: [ ' if ' , (self name: aConstraint name) ]
]

{ #category : 'converting' }
OPBormLangSerializer >> dataFlow: aDataFlow [



	^ (aDataFlow isInput ifTrue:['<-o']ifFalse: [ 'o->' ]),' ',(self nameClosed: aDataFlow )
]

{ #category : 'converting' }
OPBormLangSerializer >> dataFlows: aCollection [
	
	^ (aCollection collect:[:each|(self dataFlow:each)])joinUsing: self tab
]

{ #category : 'exporting' }
OPBormLangSerializer >> export: aModel [

	^ self ormodel: aModel
]

{ #category : 'converting' }
OPBormLangSerializer >> fullNameClosed: aNode [ 
^   (self idClosed:aNode),':',(self nameClosed: aNode)
]

{ #category : 'converting' }
OPBormLangSerializer >> fullNameOpened: aNode [ 
^ ( self idOpened: aNode) ,':',(self nameOpened:aNode )
]

{ #category : 'converting' }
OPBormLangSerializer >> fullNameOpenedWithCheckForSubmodel: aNode [ 
^(aNode submodel ifNil:[(  (nodesList at: aNode)fourth) ,':',(self nameOpened:aNode )] ifNotNil: [ (  (nodesList at: aNode)fourth) ,':',(self nameOpened:aNode ),'+',aNode submodel name ])
]

{ #category : 'converting' }
OPBormLangSerializer >> fullNameParticipantClosed: aParticipant [
^   (participantsList at: aParticipant ),':',(self nameClosed: aParticipant )
]

{ #category : 'converting' }
OPBormLangSerializer >> generateNodeId: aNode [
|id|
id:= nodeCounter .
nodeCounter := nodeCounter +1.
^(aNode name = '' ifTrue:[(id asString)] ifFalse:[
	 (aNode name substrings first),(id asString)])
]

{ #category : 'converting' }
OPBormLangSerializer >> generateParticipantId: aParticipant [
|id|
id:= participantCounter.
participantCounter := participantCounter +1.
^(aParticipant name = '' ifTrue:[(id asString)] ifFalse:[
	^ (aParticipant name substrings first),(id asString)])
]

{ #category : 'converting' }
OPBormLangSerializer >> idClosed: aNode [ 
^ self nameClosed:aNode 
]

{ #category : 'converting' }
OPBormLangSerializer >> idOpened: aNode [ 
^ self nameOpened:aNode 
]

{ #category : 'converting' }
OPBormLangSerializer >> name: aString [
	^ '"' , aString , '"'
]

{ #category : 'converting' }
OPBormLangSerializer >> nameClosed: aNode [
	^  '"',aNode name,'"'
	
]

{ #category : 'converting' }
OPBormLangSerializer >> nameOpened: aNode [
	^  aNode name
]

{ #category : 'converting' }
OPBormLangSerializer >> nameOpenedWithChecksForSubmodel: aNode [
^(aNode submodel ifNil:[aNode name] ifNotNil: [ aNode name,'+',aNode submodel name ])
]

{ #category : 'converting' }
OPBormLangSerializer >> namePrint: aString [
^(aString anySatisfy: #isSeparator )ifTrue:[ '"',aString,'"'] ifFalse: [ aString ]
	
]

{ #category : 'accessing' }
OPBormLangSerializer >> newLine [
	^ Character cr asString
]

{ #category : 'accessing' }
OPBormLangSerializer >> newLineIf: aBoolean [
	^ aBoolean
		ifTrue: [ self newLine ]
		ifFalse: [ '' ]
]

{ #category : 'converting' }
OPBormLangSerializer >> node: aNode [
	^ (aNode isKindOf: BormActivity)
		ifTrue: [activityNodes add:{aNode.((nodesList at:aNode )fourth)} .self activity: aNode ]
		ifFalse: [ self state: aNode ]
]

{ #category : 'converting' }
OPBormLangSerializer >> nodes: aCollection [
	^ (aCollection collect: [ :each | self tab,self tab, (self node: each) ]) joinUsing: self newLine , self newLine
]

{ #category : 'converting' }
OPBormLangSerializer >> ormodel: aModel [
activityNodes := Set new.
participantsList := Dictionary new.
participantCounter :=1.
	^'@startModel',self newLine,( self participants: aModel participants),
	(self collectCommunications),self newLine , '@endModel as ',( self namePrint:aModel name).
]

{ #category : 'converting' }
OPBormLangSerializer >> participant: aParticipant [
nodeCounter :=1.
participantsList at:aParticipant ifAbsentPut:[ (self generateParticipantId: aParticipant) ].
	^ (self participantType: aParticipant type) , self tab, (self fullNameParticipantClosed: aParticipant ) , self tab , '{' , self newLine
		, (self transitions: aParticipant nodes) , self newLine , '}'
]

{ #category : 'converting' }
OPBormLangSerializer >> participantType: aType [
	^ aType asString
]

{ #category : 'converting' }
OPBormLangSerializer >> participants: aCollection [
	^ (self newLine),((aCollection collect: [ :each | self participant: each ])
		joinUsing: self newLine )
]

{ #category : 'converting' }
OPBormLangSerializer >> state: aState [
|val|
val :=(nodesList at:aState ).
^ val second ifTrue:[val third ifFalse:[val at:3 put: true. nodesList at: aState put: val. self tab, (self stateType: aState ), (self fullNameOpenedWithCheckForSubmodel: aState ),(self stateEnd:aState)  ] ifTrue:[ self tab, (  (nodesList at: aState)fourth) ]] ifFalse: [ self tab, (self stateType: aState ), (self nameOpenedWithChecksForSubmodel: aState ),(self stateEnd:aState) ]

	
]

{ #category : 'converting' }
OPBormLangSerializer >> stateEnd: aState [

	aState isFinal
		ifTrue: [ ^ ']]' ].

	^ ']'
]

{ #category : 'converting' }
OPBormLangSerializer >> stateType: aState [
	(aState isInitial and: [aState isFinal])
		ifTrue: [ ^ '[[*' ].

	aState isInitial
		ifTrue: [ ^ '[*' ].

	aState isFinal
		ifTrue: [ ^ '[[' ].

	^ '['
]

{ #category : 'accessing' }
OPBormLangSerializer >> tab [
	^ Character tab asString
]

{ #category : 'converting' }
OPBormLangSerializer >> transition: nodes [
	^ '{' ,( (nodes collect:[:each|(self transitionConstraint: each first),(self node:each second) ]) joinUsing: (self newLine,self tab)) ,self tab ,'}'
]

{ #category : 'converting' }
OPBormLangSerializer >> transitionConstraint: aConstraint [
	^ aConstraint ifNil: [ '' ] ifNotNil: [ '-' , (aConstraint name ='' ifTrue: ['"condition"'] ifFalse: [self nameOpened: aConstraint] ),'- ' ]
]

{ #category : 'converting' }
OPBormLangSerializer >> transitions: nodes [
|col ls|
nodesList:= Dictionary new.
transitionsList :=OrderedCollection new.

nodes do: [ :each|  each transitions ifEmpty: [ transitionsList add:(OrderedCollection new add: {nil.each};yourself). self addNode:each. ] ifNotEmpty: [each transitions do:[:transition | transition  source= each ifTrue:[|foundIndex newTransition connectTo |foundIndex:=transitionsList findFirst:[:t|t first second= transition target   ] .foundIndex =0 ifTrue: [ newTransition := ((OrderedCollection new) add:{nil. each}; add: {transition constraint.transition target};yourself ). self addNode:transition target.] ifFalse: [ (((transitionsList at:foundIndex)first )at:1 put:transition constraint). newTransition:=((transitionsList at:foundIndex)  addFirst: {nil.each};yourself).transitionsList removeAt: foundIndex .]. connectTo:= transitionsList findFirst:[:tr| tr last second =each  ]. connectTo =0  ifTrue:[ transitionsList add: newTransition.self addNode:each.] ifFalse: [ (transitionsList at:connectTo put:(((transitionsList at:connectTo)),(newTransition removeFirst;yourself )) )]]]]].
ls:=transitionsList sorted:[:a :b | a size > b size].
col:=(ls collect:[:each| self tab ,(self transition:each)])joinUsing: self newLine.
nodesList removeAll .
transitionsList removeAll.
 ^col


	"^ (aCollection collect: [ :each | self tab , self tab , (self transition: each) ]) joinUsing: self newLine"
]
