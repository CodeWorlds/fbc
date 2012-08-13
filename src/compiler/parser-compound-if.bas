'' IF..ELSE..ELSEIF..END IF compound statement parsing (single and multi-line)
''
'' chng: sep/2004 written [v1ctor]


#include once "fb.bi"
#include once "fbint.bi"
#include once "parser.bi"
#include once "ast.bi"

'':::::
''SingleIfStatement=  !(COMMENT|NEWLINE|STATSEP) NUM_LIT | Statement*)
''                    (ELSE NUM_LIT | Statement*)?
''
private sub hIfSingleLine(byval stk as FB_CMPSTMTSTK ptr)
	'' NUM_LIT | Statement*
	if( lexGetClass( ) = FB_TKCLASS_NUMLITERAL ) then
		dim as FBSYMBOL ptr l = symbLookupByNameAndClass( symbGetCurrentNamespc( ), _
										  				  lexGetText( ), _
										  				  FB_SYMBCLASS_LABEL, _
										  				  FALSE, _
										  				  FALSE )
		if( l = NULL ) then
			l = symbAddLabel( lexGetText( ), FB_SYMBOPT_CREATEALIAS )
		end if

		lexSkipToken( )

		astAdd( astNewBRANCH( AST_OP_JMP, l ) )
	else
		cStatement()
	end if

	'' (ELSE Statement*)?
	if( lexGetToken( ) = FB_TK_ELSE ) then
		lexSkipToken( )

		'' exit if stmt
		astAdd( astNewBRANCH( AST_OP_JMP, stk->if.endlabel ) )

		'' emit next label
		astAdd( astNewLABEL( stk->if.nxtlabel ) )

		'' NUM_LIT | Statement*
		if( lexGetClass( ) = FB_TKCLASS_NUMLITERAL ) then
			dim as FBSYMBOL ptr l = symbLookupByNameAndClass( symbGetCurrentNamespc( ), _
										  				  	  lexGetText( ), _
										  				  	  FB_SYMBCLASS_LABEL, _
										  				  	  FALSE, _
										  				  	  FALSE )
			if( l = NULL ) then
				l = symbAddLabel( lexGetText( ), FB_SYMBOPT_CREATEALIAS )
			end if

			lexSkipToken( )

			astAdd( astNewBRANCH( AST_OP_JMP, l ) )
		else
			'' Statement
			cStatement()
		end if

		'' emit end label
		astAdd( astNewLABEL( stk->if.endlabel ) )
	else
		'' emit next label
		astAdd( astNewLABEL( stk->if.nxtlabel ) )
	end if

	'' END IF? -- added to make complex macros easier to be written
	select case lexGetToken( )
	case FB_TK_END
		if( lexGetLookAhead( 1 ) = FB_TK_IF ) then
			lexSkipToken( )
			lexSkipToken( )
		end if

	case FB_TK_ENDIF
		lexSkipToken( )
	end select

	'' pop from stmt stack
	cCompStmtPop( stk )
end sub

'':::::
''IfStmtBegin	  =   IF Expression THEN (BlockIfStatement | SingleIfStatement) .
''
sub cIfStmtBegin()
	dim as ASTNODE ptr expr = any
	dim as FBSYMBOL ptr nl = any, el = any
	dim as FB_CMPSTMTSTK ptr stk = any
	dim as integer ismultiline = any

	'' IF
	lexSkipToken( )

    '' Expression
    expr = cExpression( )
    if( expr = NULL ) then
		errReport( FB_ERRMSG_EXPECTEDEXPRESSION )
		'' error recovery: fake an expr
		expr = astNewCONSTi( 0, FB_DATATYPE_INTEGER )
    end if

	'' add end label (at ENDIF)
	el = symbAddLabel( NULL, FB_SYMBOPT_NONE )
	'' and next label (at ELSE/ELSEIF)
	nl = symbAddLabel( NULL, FB_SYMBOPT_NONE )

	'' branch
	expr = astUpdComp2Branch( expr, nl, FALSE )
	if( expr = NULL ) then
		errReport( FB_ERRMSG_INVALIDDATATYPES )
	else
		astAdd( expr )
	end if

	'' push to stmt stack
	stk = cCompStmtPush( FB_TK_IF )
	stk->if.nxtlabel = nl
	stk->if.endlabel = el
	stk->if.elsecnt = 0

	'' GOTO?
	if( lexGetToken( ) = FB_TK_GOTO ) then
		hIfSingleLine( stk )
		return
	end if

	'' THEN?
	if( lexGetToken( ) <> FB_TK_THEN ) then
		errReport( FB_ERRMSG_EXPECTEDTHEN )
	else
		lexSkipToken( )
	end if

	select case as const lexGetToken( )
	'' COMMENT|NEWLINE?
	case FB_TK_COMMENT, FB_TK_EOL, FB_TK_EOF
		ismultiline = TRUE

	'' REM | ':'?
	case FB_TK_REM, FB_TK_STMTSEP
		'' QB treats "IF...THEN [REM|:] ..." as single-line IF
		if( fbLangIsSet( FB_LANG_QB ) ) then
			ismultiline = FALSE
		else
			ismultiline = TRUE
		end if

	case else
		ismultiline = FALSE
	end select

	if( ismultiline ) then
		stk->if.issingle = FALSE
		stk->scopenode = astScopeBegin( )
	else
		stk->if.issingle = TRUE
		stk->scopenode = NULL
		hIfSingleLine( stk )
	end if
end sub

'':::::
''IfStmtNext	=     ELSEIF Expression THEN
''              |     ELSE .
''
function cIfStmtNext(  ) as integer
	dim as ASTNODE ptr expr = any
	dim as FB_CMPSTMTSTK ptr stk = any

	function = FALSE

	stk = cCompStmtGetTOS( FB_TK_IF, FALSE )
	if( stk = NULL ) then
		if( lexGetToken( ) = FB_TK_ELSEIF ) then
			errReport( FB_ERRMSG_ELSEIFWITHOUTIF )
		else
			errReport( FB_ERRMSG_ELSEWITHOUTIF )
		end if
		exit function
	end if

	'' single line? don't process
	if( stk->if.issingle ) then
		return TRUE
	end if

    '' ELSE already parsed?
    if( stk->if.elsecnt <> 0 ) then
		errReport( FB_ERRMSG_EXPECTEDENDIF )
    end if

	'' end scope
	if( stk->scopenode <> NULL ) then
		astScopeEnd( stk->scopenode )
		stk->scopenode = NULL
	end if

	'' ELSEIF Expression THEN ?
    if( lexGetToken( ) = FB_TK_ELSEIF ) then
    	lexSkipToken( )

		'' exit last if stmt
		astAdd( astNewBRANCH( AST_OP_JMP, stk->if.endlabel ) )

		'' emit next label
		astAdd( astNewLABEL( stk->if.nxtlabel ) )

		'' add next label (at ELSE/ELSEIF)
		stk->if.nxtlabel = symbAddLabel( NULL, FB_SYMBOPT_NONE )

	    '' Expression
    	expr = cExpression( )
    	if( expr = NULL ) then
			errReport( FB_ERRMSG_EXPECTEDEXPRESSION )
			'' error recovery: fake an expr
			expr = astNewCONSTi( 0, FB_DATATYPE_INTEGER )
    	end if

		'' THEN
		if( hMatch( FB_TK_THEN ) = FALSE ) then
			errReport( FB_ERRMSG_EXPECTEDTHEN )
		end if

		'' branch
		expr = astUpdComp2Branch( expr, stk->if.nxtlabel, FALSE )
		if( expr = NULL ) then
			errReport( FB_ERRMSG_INVALIDDATATYPES )
		else
			astAdd( expr )
		end if

    '' ELSE..
    else
    	stk->if.elsecnt += 1

    	lexSkipToken( )

		'' warn about IF statements immediately following ELSE, due to confusion with 'ELSEIF'
		if( lexGetToken( ) = FB_TK_IF ) then
			errReportWarn( FB_WARNINGMSG_IFFOUNDAFTERELSE )
		end if

		'' exit last if stmt
		astAdd( astNewBRANCH( AST_OP_JMP, stk->if.endlabel ) )

		'' emit next label
		if( stk->if.nxtlabel <> NULL ) then
			astAdd( astNewLABEL( stk->if.nxtlabel ) )
			stk->if.nxtlabel = NULL
		end if

	end if

	'' begin scope
	stk->scopenode = astScopeBegin( )

	cStatement( )

	function = TRUE

end function

'':::::
''IfStmtEnd	  =   END IF | ENDIF .
''
function cIfStmtEnd as integer
	dim as FB_CMPSTMTSTK ptr stk = any

	function = FALSE

	stk = cCompStmtGetTOS( FB_TK_IF )
	if( stk = NULL ) then
		exit function
	end if

	'' single line? don't process
	if( stk->if.issingle ) then
		return TRUE
	end if

	'' ENDIF or END IF
	if( lexGetToken() = FB_TK_END ) then
		lexSkipToken( )
	end if
	lexSkipToken( )

	'' end scope
	if( stk->scopenode <> NULL ) then
		astScopeEnd( stk->scopenode )
	end if

	'' emit next label
	if( stk->if.nxtlabel <> NULL ) then
		astAdd( astNewLABEL( stk->if.nxtlabel ) )
	end if

	'' emit end label
	astAdd( astNewLABEL( stk->if.endlabel ) )

	'' pop from stmt stack
	cCompStmtPop( stk )

end function