"
I define and parse grammar of BORM Lang.

!! Synchronization
The inverse operation (taking model and producing DSL) is provided by BormLangExporter

!! Example

Also see BormDiagramExamples for some examples.
[[[
'Person ""Customer"" {
	initial state ""wants pizza""
		go to ""order"" if ""hungry""
	
	activity ""order""
		send ""pizza choice"" to ""Operator::accepts order"" and receive ""confirmation""
		go to ""wait""
	
	state ""wait for pizza"" as ""wait""
		go to ""pay""
	
	activity ""accepts pizza and pays"" as ""pay""
		go to ""final""
	
	final state ""purchase completed"" as ""final""
}
System ""Operator"" {
	activity ""accepts order""
}
' asBorm open
]]]
"
Class {
	#name : 'OPBormLangGrammar',
	#superclass : 'PPCompositeParser',
	#instVars : [
		'participants',
		'participant',
		'participantType',
		'string',
		'stringMayBeEmpty',
		'stringEnclosed',
		'newWord',
		'space',
		'stateType',
		'idNode',
		'state',
		'stateEnd',
		'activity',
		'transition',
		'transitions',
		'communication',
		'communicationSign',
		'communications',
		'node',
		'nodes',
		'namePair',
		'namePairOpened',
		'nameOpened',
		'name',
		'constraint',
		'dataFlows',
		'dataFlow',
		'dataFlowSign',
		'diagram',
		'diagramStart',
		'diagramEnd',
		'activityStart'
	],
	#category : 'OpenPonk-BormEditor-Dsl',
	#package : 'OpenPonk-BormEditor',
	#tag : 'Dsl'
}

{ #category : 'accessing' }
OPBormLangGrammar >> activity [
	^ ($( asParser ,nameOpened,(($+ asParser, stringMayBeEmpty )==>[:n| n second ])optional ,$)asParser) ==> [ :arr | {arr second.arr third} ]
	"^ (activityStart , space , namePair) ==> [ :arr | arr last ]"
]

{ #category : 'accessing' }
OPBormLangGrammar >> activityEnd [
	^ ')' asParser
	
]

{ #category : 'accessing' }
OPBormLangGrammar >> activityStart [
	"activityStart
	^ '(' asParser"
	^ 'activity' asParser
]

{ #category : 'accessing' }
OPBormLangGrammar >> communication [

	^ (space,(stringEnclosed /newWord ), space,(stringEnclosed /newWord ),space,communicationSign ,space,(stringEnclosed /newWord ),space ,(stringEnclosed /newWord ),space, (dataFlows)optional ,space ) map: [ :sp1 :np :sp2 :ns :sp3 :c :sp4 :np2 :sp5 :nr :sp6 :f :sp7 | {(np->ns).(np2->nr).c.f}]
		"
	^ (('talk to ' asParser , name) ==> [ :arr | { arr second . nil . nil } ])
		/ (('send ' asParser , name , ' to ' asParser , name , (' and receive ' asParser , name) optional) ==> [ :arr | { arr fourth . arr second . arr fifth ifNotNil: [ arr fifth second ] } ])"
]

{ #category : 'accessing' }
OPBormLangGrammar >> communicationSign [
	^ '->'asParser /constraint 
]

{ #category : 'accessing' }
OPBormLangGrammar >> communications [
	^ communication trim star
]

{ #category : 'accessing' }
OPBormLangGrammar >> constraint [

	^ (($- asParser ,nameOpened ,$>asParser )/($- asParser ,nameOpened ,$-asParser )/((('-"condition"-'asParser) /('-"condition">'asParser))==>[:e|{''.{''.'i'}}])) map: [ :n|n . n  second]
]

{ #category : 'accessing' }
OPBormLangGrammar >> dataFlow [
	^ (dataFlowSign ,space, name,space ) map: [ :dfs :sp1 :n :sp2| { dfs.n } ]
]

{ #category : 'accessing' }
OPBormLangGrammar >> dataFlowSign [
	^ 'o->' asParser /'<-o'asParser 
]

{ #category : 'accessing' }
OPBormLangGrammar >> dataFlows [
	^ dataFlow plus trim
]

{ #category : 'accessing' }
OPBormLangGrammar >> diagram [
	^diagramStart, participants,communications ,diagramEnd 
]

{ #category : 'accessing' }
OPBormLangGrammar >> diagramEnd [
	^ (space,'@endModel' asParser ,space, ( 'as' asParser ,space, (stringEnclosed/newWord) )optional,space )==>[:n|  n fourth ifNil: ['New Diagram']ifNotNil: [ n fourth third ]]
]

{ #category : 'accessing' }
OPBormLangGrammar >> diagramStart [
	^ space,'@startModel' asParser,space 
]

{ #category : 'accessing' }
OPBormLangGrammar >> idNode [

	^  stringEnclosed/newWord 
	"^ activity / state , communications , transitions"
]

{ #category : 'accessing' }
OPBormLangGrammar >> name [

		^  (namePair/((stringEnclosed/ newWord) ==> [:w | {w.w}]))
		"	^ 
			($' asParser , string , $' asParser) ==> [ :arr | arr second ]
				^ ($"" asParser , string , $"" asParser) ==> [ :arr | arr second ]"
]

{ #category : 'accessing' }
OPBormLangGrammar >> nameOpened [

	^  (namePairOpened /(stringMayBeEmpty ==> [:w | {w.w}]))
	"	^ ($' asParser , string , $' asParser) ==> [ :arr | arr second ]""
	^ ($"" asParser , string , $"" asParser) ==> [ :arr | arr second ]"
]

{ #category : 'accessing' }
OPBormLangGrammar >> namePair [
	^ ( ((  stringEnclosed /newWord ), space, $: asParser,space,(  stringEnclosed /newWord ) ))
		map: [ :i :sp1 :c :sp2 :nm | { i.nm }]
		"^ (name , ((space , 'as' asParser , space , name) ==> [ :arr | arr fourth ]) optional)
		==> [ :arr | arr first -> (arr second ifNil: [ arr first ]) ]"
]

{ #category : 'accessing' }
OPBormLangGrammar >> namePairOpened [
	^  (stringMayBeEmpty, $: asParser,stringMayBeEmpty )
		map: [ :i  :c  :nm | { i.nm }]
		"	^ (name , ((space , 'as' asParser , space , name) ==> [ :arr | arr fourth ]) optional)
		==> [ :arr | arr first -> (arr second ifNil: [ arr first ]) ]"
]

{ #category : 'accessing' }
OPBormLangGrammar >> newLine [
	^ Character cr asParser plus
]

{ #category : 'accessing' }
OPBormLangGrammar >> newWord [

	^ #word asParser  plus flatten
]

{ #category : 'accessing' }
OPBormLangGrammar >> node [

	^  activity / state /idNode
	"^ activity / state , communications , transitions"
]

{ #category : 'accessing' }
OPBormLangGrammar >> nodes [
	^ (${ asParser, ((space, node,space) map:[:sp1 :nd :sp2| nd]) trim star,$} asParser )map:[
		:br1 :n :br2| n]
]

{ #category : 'accessing' }
OPBormLangGrammar >> participant [

	^ (   space, participantType, space,name,space, ${ asParser ,space,transitions, space , $} asParser ,space) map: [ :sp1 :tp :sp2 :n :sp3 :br :sp  :t :sp4 :br2 :sp5 |{  tp.n.t } 
			  ]
		"participant
	^ (participantType , space , namePair , space , ${ asParser , space , nodes
		, space , $} asParser) map: [ :type :sp :pair :sp2 :bra :sp3 :vertices :sp4 :ket
 | { type . pair . vertices }
			  ]
	^ (participantType , space , namePair , space , ${ asParser , #newline asParser , nodes
		, #newline asParser optional , $} asParser) map: [ :type :sp :pair :sp2 :bra :nl :vertices :nl2 :ket
 | { type . pair . vertices }
			  ]"

]

{ #category : 'accessing' }
OPBormLangGrammar >> participantType [
	^ 'Person' asParser / 'Organization' asParser / 'System' asParser
]

{ #category : 'accessing' }
OPBormLangGrammar >> participants [
	^ participant trim star
]

{ #category : 'accessing' }
OPBormLangGrammar >> space [
	^#space asParser star
	"^ Character space asParser plus"
]

{ #category : 'accessing' }
OPBormLangGrammar >> start [

	^ diagram end
]

{ #category : 'accessing' }
OPBormLangGrammar >> state [
	
	^ (stateType ,  nameOpened , (($+ asParser, stringMayBeEmpty )==>[:n| n second ])optional, stateEnd)
		map: [ :type :n :m :end | 
			{type . n.m} ]"
	^ (stateType , space) optional , 'state' asParser , space , namePair
		map: [ :type :smb :sp :pair | 
			{(type ifNotNil: [ type first ]).
			pair} ]"
]

{ #category : 'accessing' }
OPBormLangGrammar >> stateEnd [
	"^ ('final' asParser / 'initial and final' asParser / 'initial' asParser) flatten"
	^ (']]' asParser / ']' asParser ) flatten

]

{ #category : 'accessing' }
OPBormLangGrammar >> stateType [
	^ ('[[*' asParser / '[*' asParser / '[[' asParser/ '[' asParser) flatten"
	^ ('final' asParser / 'initial and final' asParser / 'initial' asParser) flatten"
]

{ #category : 'accessing' }
OPBormLangGrammar >> string [
	^ (space,newWord ,space ) plus flatten"
	^ (#word asParser / Character space asParser / '::' asParser) plus flatten"
]

{ #category : 'accessing' }
OPBormLangGrammar >> stringEnclosed [
		"^ (#word asParser / Character space asParser / '::' asParser) plus flatten"
	"^ ($"" asParser, (string/space)optional ,$"" asParser ) map: [ :u1 :st :u2 | st ]"
^ ($" asParser, stringMayBeEmpty ,$" asParser ) map: [ :u1 :st :u2 | st ]
]

{ #category : 'accessing' }
OPBormLangGrammar >> stringMayBeEmpty [
	^ (#space asParser/newWord ) star flatten"
	^ (#word asParser / Character space asParser / '::' asParser) plus flatten"
]

{ #category : 'accessing' }
OPBormLangGrammar >> transition [
	^ (${ asParser,space, ((constraint optional,space, node,space) map:[:c :sp1 :nd :sp2 | {c.nd}]) trim star,$} asParser )map:[
		:br1 :sp1 :n :br2| n]
]

{ #category : 'accessing' }
OPBormLangGrammar >> transitions [
	^ transition trim star
]
