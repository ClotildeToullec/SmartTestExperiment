"
This class is a subclass of RTMarkerOnX.
The superclass creates arrows pointing the X axis of graphs.
This class only overrides the #render method to adapt the arrows position and appearance.
"
Class {
	#name : #STEGraphArrow,
	#superclass : #RTMarkerOnX,
	#category : #'SmartTestExperiment-Reporting'
}

{ #category : #hooks }
STEGraphArrow >> render [
	| fromPosition toPosition e1 e2 l lineShape |
	fromPosition := builder getPixelPositionOf: value @ 0.
	toPosition := fromPosition + (0 @ 12).
	e1 := (RTBox new size: 1) element.
	e2 := (RTBox new size: 1) element.
	e1 translateTo: fromPosition.
	e2 translateTo: toPosition.
	lineShape := RTArrowedLine new.
	lineShape head width: 1.
	lineShape head
		size: 5;
		baseSize: 5.
	lineShape width: 1.
	lineShape color: Color gray.
	l := lineShape edgeFrom: e2 to: e1.
	builder view
		add: e1;
		add: e2;
		add: l
]
