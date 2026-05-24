Class {
	#name : 'OPBormLangGrammarTest',
	#superclass : 'PPCompositeParserTest',
	#category : 'OpenPonk-BormEditor-Dsl',
	#package : 'OpenPonk-BormEditor',
	#tag : 'Dsl'
}

{ #category : 'accessing' }
OPBormLangGrammarTest >> parserClass [
	^ OPBormLangGrammar
]

{ #category : 'tests' }
OPBormLangGrammarTest >> testActivity [
	self parse: '(name+)' rule: #activity
]

{ #category : 'tests' }
OPBormLangGrammarTest >> testActivity1 [
	self parse: '(id:name)' rule: #activity
]

{ #category : 'tests' }
OPBormLangGrammarTest >> testActivity2 [
	self parse: '()' rule: #activity
]

{ #category : 'tests' }
OPBormLangGrammarTest >> testCommunication1 [
	self parse: 'send "x" to "Org::a"' rule: #communication
]

{ #category : 'tests' }
OPBormLangGrammarTest >> testCommunication2 [
	self parse: 'send "x" to "Org::a" and receive "y"' rule: #communication
]

{ #category : 'tests' }
OPBormLangGrammarTest >> testConstraint [
	self parse: '' rule: #constraint
]

{ #category : 'tests' }
OPBormLangGrammarTest >> testConstraint1 [
	self parse: '-condition-' rule: #constraint
]

{ #category : 'tests' }
OPBormLangGrammarTest >> testDiagram [
	self
		parse:
			'System "Src" {
	activity "a"
		talk to "Dst::a"
}
Organization "Dst" {
	activity "a"
}'
		rule: #diagram
]

{ #category : 'tests' }
OPBormLangGrammarTest >> testDiagram1 [
	self
		parse:
			'@startModel
			@endModel'
		rule: #diagram
]

{ #category : 'tests' }
OPBormLangGrammarTest >> testDiagram2 [
	self
		parse:
			'System "Src" {
	activity "a"
		talk to "Dst::a"
}
Organization "Dst" {
	activity "a"
		send "x" to "Src::a" and receive "y"
}'
		rule: #diagram
]

{ #category : 'tests' }
OPBormLangGrammarTest >> testNode [
	self parse: 'state "hello"' rule: #node
]

{ #category : 'tests' }
OPBormLangGrammarTest >> testNode1 [
	self
		parse:
			'state "hello"
	go to "x"'
		rule: #node
]

{ #category : 'tests' }
OPBormLangGrammarTest >> testNode2 [
	self
		parse:
			'state "hello"
	go to "x"
	go to "y"'
		rule: #node
]

{ #category : 'tests' }
OPBormLangGrammarTest >> testParticipant [
	self
		parse:
			'Person "m":"m" {
}'
		rule: #participant
]

{ #category : 'tests' }
OPBormLangGrammarTest >> testParticipant1 [
	self parse: 'System "Sys" {
	state "x"
}' rule: #participant
]

{ #category : 'tests' }
OPBormLangGrammarTest >> testParticipant2 [
	self parse: 'Organization "Org" {
	state "x"
	activity "y"
}' rule: #participant
]

{ #category : 'tests' }
OPBormLangGrammarTest >> testParticipant3 [
	self
		parse:
			'Organization "Org" {
	state "x x" as "x"
		go to "y"
	activity "y y" as "y"
}'
		rule: #participant
]

{ #category : 'tests' }
OPBormLangGrammarTest >> testParticipantType [
	self parse: 'Person' rule: #participantType
]

{ #category : 'tests' }
OPBormLangGrammarTest >> testParticipantType1 [
	self parse: 'Organization' rule: #participantType
]

{ #category : 'tests' }
OPBormLangGrammarTest >> testParticipantType2 [
	self fail: 'Whatever' rule: #participantType
]

{ #category : 'tests' }
OPBormLangGrammarTest >> testParticipants [
	self parse: '' rule: #participants
]

{ #category : 'tests' }
OPBormLangGrammarTest >> testParticipants1 [
	self
		parse:
			'System "Sys" {
	state "x"
}'
		rule: #participants
]

{ #category : 'tests' }
OPBormLangGrammarTest >> testParticipants2 [
	self
		parse:
			'System "Sys" {
	activity "x"
}
Organization "Org" {
	activity "x"
}'
		rule: #participants
]

{ #category : 'tests' }
OPBormLangGrammarTest >> testParticipants3 [
	self
		parse:
			'System "Sys" {
	activity "a1"
		go to "s1"
	state "s1"
}
Organization "Org" {
	activity "a2"
		go to "s2"
	state "s2"
}'
		rule: #participants
]

{ #category : 'tests' }
OPBormLangGrammarTest >> testQuotedString [
	self parse: '"quoted string"' rule: #name.
	self assert: result equals: 'quoted string'.
	self fail: '''quoted string''' rule: #name.
	self fail: '""' rule: #name
]

{ #category : 'tests' }
OPBormLangGrammarTest >> testState [
	self parse: '[hello]' rule: #state
]

{ #category : 'tests' }
OPBormLangGrammarTest >> testState1 [
	self parse: '[*hello]' rule: #state
]

{ #category : 'tests' }
OPBormLangGrammarTest >> testState2 [
	self parse: '[[hello]' rule: #state
]

{ #category : 'tests' }
OPBormLangGrammarTest >> testState3 [
	self parse: '[[*hello]' rule: #state
]

{ #category : 'tests' }
OPBormLangGrammarTest >> testStateType [
	self parse: 'initial' rule: #stateType.
	self assert: result equals: 'initial'.
	
	self parse: 'final' rule: #stateType.
	self assert: result equals: 'final'.

	self fail: 'nothing' rule: #stateType
]

{ #category : 'tests' }
OPBormLangGrammarTest >> testString [
	self parse: 'some string' rule: #string.
	self assert: result equals: 'some string'.
	self fail: '' rule: #string
]

{ #category : 'tests' }
OPBormLangGrammarTest >> testTransition [
	self parse: 'go to "vertex"' rule: #transition
]

{ #category : 'tests' }
OPBormLangGrammarTest >> testTransition1 [
	self parse: 'go to "vertex" if "condition"' rule: #transition
]

{ #category : 'tests' }
OPBormLangGrammarTest >> testTransitions [
	self parse: '' rule: #transitions.
	self assert: result equals: #().

	self parse: 'go to "activity"' rule: #transitions.
	self assert: result equals: #(#('activity' nil)).

	self parse: 'go to "activity" if "x" go to "state" if "y"' rule: #transitions.
	self assert: result equals: #(#('activity' 'x') #('state' 'y'))
]
