Class {
	#name : 'OPTextWindow',
	#superclass : 'Object',
	#category : 'OpenPonk-BormTextEditor',
	#package : 'OpenPonk-BormTextEditor'
}

{ #category : 'toolbar' }
OPTextWindow class >> toolbarMenu: aBuilder [

	<opEditorToolbarMenu: #OPBormPlugin>
	(aBuilder item: 'Open Text Editor ')
		icon: OPBormEditorIcons oRModel16Icon;
		action: [ 			
				 aBuilder model diagramController model inspect]
]
