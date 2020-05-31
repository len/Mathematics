'From Cuis 5.0 [latest update: #4163] on 23 May 2020 at 10:21:25 am'!
'Description Please enter a description for this package'!
!provides: 'Documentation' 1 10!
SystemOrganization addCategory: #Documentation!


!classDefinition: #DocumentationGenerator category: #Documentation!
Object subclass: #DocumentationGenerator
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Documentation'!
!classDefinition: 'DocumentationGenerator class' category: #Documentation!
DocumentationGenerator class
	instanceVariableNames: ''!


!DocumentationGenerator methodsFor: 'as yet unclassified' stamp: 'len 1/5/2017 09:21:27'!
blacklist
	^ #('Etc' 'Morphic')! !

!DocumentationGenerator methodsFor: 'as yet unclassified' stamp: 'len 8/18/2016 03:30'!
copy: aString replaceAll: oldSubstring with: newSubstring
	^ aString lines
		collect: [:each| (each includesSubString: 'http') ifTrue: [each] ifFalse: [each copyReplaceTokens: oldSubstring with: newSubstring]]
		andFold: [:a :b| a, Character lf asString, b]! !

!DocumentationGenerator methodsFor: 'as yet unclassified' stamp: 'len 5/23/2020 10:19:53'!
escape: aString
	| output |
	output _ aString.
	'\[]*{}#<>' do: [:each|
"	'\[]*_{}()#<>' do: [:each|"
		(output includes: each) ifTrue: [output _ output copyReplaceAll: each asString with: '\', each asString]].
	output _ output copyReplaceAll: Character tab asString with: '&nbsp;&nbsp;&nbsp;&nbsp;'.
	output _ output copyReplaceAll: ' _ ' with: ' &larr; '.
	output _ output copyReplaceAll: '^ ' with: '&uarr; '.
	output _ output copyReplaceAll: Character arrowRight asString with: '&rarr;'.
	output _ output copyReplaceAll: Character arrowLeft asString with: '&larr;'.
	output _ output copyReplaceAll: Character arrowUp asString with: '&uarr;'.
	output _ output copyReplaceAll: Character arrowDown asString with: '&darr;'.
	output _ output copyReplaceAll: 'ë' with: '&otimes;'.
	output _ output copyReplaceAll: 'ê' with: '&oplus;'.
	output _ output copyReplaceAll: 'Ä' asString with: '&infin;'.
	output _ output copyReplaceAll: 'ÿ' with: '&empty;'.
	output _ output copyReplaceAll: 'í' with: 'o'.
	output _ output copyReplaceAll: 'Ç' with: 'N'.
	output _ output copyReplaceAll: 'É' with: 'Z'.
	output _ output copyReplaceAll: 'Ñ' with: 'Q'.
	output _ output copyReplaceAll: 'Ö' with: 'R'.
	output _ output copyReplaceAll: 'Ü' with: 'C'.
	^ output! !

!DocumentationGenerator methodsFor: 'as yet unclassified' stamp: 'len 5/23/2020 10:20:05'!
escapeCode: aString
	| output |
	output _ aString.
	output _ output copyReplaceAll: ' _ ' with: ' &larr; '.
	output _ output copyReplaceAll: '^ ' with: '&uarr; '.
	output _ output copyReplaceAll: Character arrowRight asString with: '&rarr;'.
	output _ output copyReplaceAll: Character arrowLeft asString with: '&larr;'.
	output _ output copyReplaceAll: Character arrowUp asString with: '&uarr;'.
	output _ output copyReplaceAll: Character arrowDown asString with: '&darr;'.
	output _ output copyReplaceAll: 'ë' with: '&otimes;'.
	output _ output copyReplaceAll: 'ê' asString with: '&oplus;'.
	output _ output copyReplaceAll: 'Ä' asString with: '&infin;'.
	output _ output copyReplaceAll: 'ÿ' with: '&empty;'.
	output _ output copyReplaceAll: 'í' asString with: 'o'.
	output _ output copyReplaceAll: 'Ç' with: 'N'.
	output _ output copyReplaceAll: 'É' with: 'Z'.
	output _ output copyReplaceAll: 'Ñ' with: 'Q'.
	output _ output copyReplaceAll: 'Ö' with: 'R'.
	output _ output copyReplaceAll: 'Ü' with: 'C'.
	^ output! !

!DocumentationGenerator methodsFor: 'as yet unclassified' stamp: 'len 5/23/2019 15:16:42'!
generate
	| classes |
	classes _ Object withAllSubclasses select: [:each| each class ~= Metaclass and: [(each allSuperclasses includes: Morph) not and: [(each category beginsWith: 'Domains-') and: [(self blacklist noneSatisfy: [:one| each category includesSubString: one])]]]].
	self generateForClasses: classes.
	self generateIndexByClassCategories! !

!DocumentationGenerator methodsFor: 'as yet unclassified' stamp: 'len 8/18/2016 02:57'!
generate: comment references: tokens
	^ self generate: comment references: tokens except: nil! !

!DocumentationGenerator methodsFor: 'as yet unclassified' stamp: 'len 9/3/2016 07:12'!
generate: aString references: tokens except: currentToken
	| output |
	output _ self escape: aString.
	tokens do: [:each|
		output _ self copy: output replaceAll: each with: '[',each,'](',each,')'.
		(tokens includes: each, 's') ifFalse:
			[output _ self copy: output replaceAll: each, 's' with: '[',each,'s](',each,')']]
				without: currentToken.
	output _ output copyReplaceAll: Character lf asString with: '  ', Character lf asString.
	^ output! !

!DocumentationGenerator methodsFor: 'as yet unclassified' stamp: 'len 12/18/2016 21:20:39'!
generateExampleClass: aClass selector: aSymbol
	| imageFileName source result md canvas textMorph readStream |
	source _ aClass class compiledMethodAt: aSymbol :: getSource.
	readStream _ source readStream.
	readStream nextLine.
	source _ String streamContents: [:writeStream| [readStream atEnd] whileFalse: [readStream peek = Character tab ifTrue: [readStream next]. writeStream nextPutAll: readStream nextLine; lf]].
	md _ '<pre><code>', (self escapeCode: source), '</code></pre>'.
	imageFileName _ aClass name, '-', aSymbol, '.jpg'.
	result _ aClass perform: aSymbol.
	(result isKindOf: Morph)
		ifTrue:
			[canvas _ BitBltCanvas depth: 32 over: (result morphPosition extent: result morphExtent).
			canvas fullDraw: result]
		ifFalse:
			[textMorph _ (TextModelMorph withModel: (TextModel withText: result printText)) wrapFlag: false; findA: InnerTextMorph.
			textMorph color: Color black.
			canvas _ BitBltCanvas depth: 32 over: (textMorph morphPosition extent: textMorph morphExtent).
			canvas fillRectangle: (0@0 extent: textMorph morphExtent + (10@10)) color: Color white. "yellow muchLighter."
			canvas fullDraw: textMorph].
	canvas form writeJPEGfileNamed: self path, imageFileName.
	md _ md, Character lf asString, '&nbsp;&nbsp;&nbsp;&nbsp;!![](doc/', imageFileName, ')'.
	^ md! !

!DocumentationGenerator methodsFor: 'as yet unclassified' stamp: 'len 12/18/2016 20:49:19'!
generateForClasses: classes
	| tokens |
	tokens _ classes collect: [:each| each name].
	classes do: [:class|
		| output i file examples |
		output _ '' writeStream.
		class withAllSuperclasses reversed do: [:each|
			| generated |
			generated _ each == class
				ifTrue: ['**', each name, '**']
				ifFalse: [self generate: each name references: tokens].
			output nextPutAll: generated]
			separatedBy: [output nextPutAll: ' > '].
		output lf; lf.
		class hasComment ifTrue: [output nextPutAll: (self generate: class comment references: tokens except: class name); lf; lf].
		output nextPutAll: '***'; lf.
		
		examples _ class class organization listAtCategoryNamed: #examples.
		examples _ examples select: [:each| each isUnary].
		examples notEmpty ifTrue:
			[examples do: [:exampleSelector|
				output nextPutAll: (self generateExampleClass: class selector: exampleSelector); lf; lf].
				output nextPutAll: '***'; lf].
"		class organization categories do: [:category|
			((category includesSubString: 'private') or: [category includesSubString: 'initializ'])
				ifFalse:
					[output nextPutAll: '*', category withBlanksTrimmed, '*  '; lf.
					(class organization listAtCategoryNamed: category)
						do: [:selector|
							| methodComment |
							output nextPutAll: '&nbsp;&nbsp;**',(self escape: (class sourceCodeAt: selector) lines first withBlanksTrimmed),'**  '; lf.
							(methodComment _ class firstCommentAt: selector) isEmpty
								ifFalse: [methodComment lines do: [:line| output nextPutAll: '&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;', (self escape: line withBlanksTrimmed), '  '; lf]].
							output lf]]].
		output nextPutAll: '***'; lf."
		i _ 0.
		class allSuperclasses reversed do: [:each|
			i*2 timesRepeat: [output nextPutAll: '&nbsp;'].
			output nextPutAll: (self generate: each name references: tokens).
			output nextPutAll: '  '; lf.
			i _ i + 1].
		class allSubclassesWithLevelDo: [:subclass :level|
			| generated |
			(classes includes: subclass) ifTrue:
				[(level+i)*2 timesRepeat: [output nextPutAll: '&nbsp;'].
				generated _ subclass == class
					ifTrue: ['**', subclass name, '**']
					ifFalse: [self generate: subclass name references: tokens].
				output nextPutAll: generated.
				output nextPutAll: '  '; lf]] startingLevel: 0.
		file _ self path,class name,'.md' :: asFileEntry.
		file assureExistence; fileContents: output contents]! !

!DocumentationGenerator methodsFor: 'as yet unclassified' stamp: 'len 5/23/2019 15:17:10'!
generateIndexByClassCategories
	| categories output file |
	categories _ Smalltalk organization categories select: [:each| (each beginsWith: 'Domains-') and: [self blacklist noneSatisfy: [:one| each includesSubString: one]]].
	output _ '' writeStream.
	categories do: [:category|
		output nextPutAll: '**', (category withoutPrefix: 'Domains-'), '**'; lf; lf.
		(Smalltalk organization listAtCategoryNamed: category) do: [:each|
			8 timesRepeat: [output nextPutAll: '&nbsp;'].
			output nextPutAll: '[', each asString, '](', each asString, ')'; space]]
		separatedBy: [output lf; lf].
	file _ self path, 'index.md' :: asFileEntry.
	file assureExistence; fileContents: output contents! !

!DocumentationGenerator methodsFor: 'as yet unclassified' stamp: 'len 5/23/2020 10:21:19'!
path
	^ '/home/guest/cuis/Domains.wiki/doc/'! !
