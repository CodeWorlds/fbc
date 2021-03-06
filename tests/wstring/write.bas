#include "fbcunit.bi"

#define PRINT_IF_UNEQUAL

#define BUFFER_SIZE 50

#define QT(s) wstr("""" & wstr(s) & """")

#define WWRITE( value, cmp ) _
	write #(1), value, cmp

#macro OPEN_FILE( fn )
	const TESTFILE = ("./wstring/" & fn)

	open TESTFILE for output encoding "utf-16" as #1
#endmacro

#macro CLOSE_AND_TEST_FILE()
	close #1

	dim as wstring * BUFFER_SIZE sResult, sExpected
	dim as integer errcount = 0
	open TESTFILE for input encoding "utf-16" as #1
		do until eof(1)
			input #1, sResult, sExpected
			if( sResult <> sExpected ) then
#ifdef PRINT_IF_UNEQUAL
				print QT(sResult) & " <> " & QT(sExpected)
				errcount += 1
#endif
			end if
			CU_ASSERT_EQUAL( sResult, sExpected )
		loop
	close #1

	if errcount = 0 then
		kill TESTFILE
	end if
#endmacro


SUITE( fbc_tests.wstring_.write_ )

	TEST( numbers )

		#macro check( dtype, value )
			scope
				dim x as dtype = value
				dim cmp as wstring * BUFFER_SIZE = wstr( value )
				WWRITE( x, cmp )
			end scope		
		#endmacro

		OPEN_FILE( "write_numbers.txt" )

		check( boolean, false )
		check( boolean, true )

		check( byte, -128 )
		check( byte, -0 )
		check( byte, 127 )

		check( ubyte, 0 )
		check( ubyte, 128 )
		check( ubyte, 255 )

		check( short, -32768 )
		check( short, 0 )
		check( short, 32767 )

		check( ushort, 0 )
		check( ushort, 32768 )
		check( ushort, 65535 )

		check( long, -2147483648ll )
		check( long, 0 )
		check( long, 2147483647ull )

		check( ulong, 0 )
		check( ulong, 2147483648ull )
		check( ulong, 4294967295ull )

		check( longint, (-9223372036854775807ll-1ll) )
		check( longint, 0 )
		check( longint, 9223372036854775807ull )

		check( ulongint, 0 )
		check( ulongint, 9223372036854775808ull )
		check( ulongint, 18446744073709551615ull )

		check( single, -1.5 )
		check( single, -1.0 )
		check( single, -1.0 )
		check( single, -0.5 )
		check( single,  0.0 )
		check( single,  0.5 )
		check( single,  1.0)
		check( single,  1.5 )
		check( single,  2.0 )
		check( single,  2.5 )

		check( double, -1.5 )
		check( double, -1.0 )
		check( double, -1.0 )
		check( double, -0.5 )
		check( double,  0.0 )
		check( double,  0.5 )
		check( double,  1.0)
		check( double,  1.5 )
		check( double,  2.0 )
		check( double,  2.5 )

		CLOSE_AND_TEST_FILE()

	END_TEST

	TEST( strings )

		#macro check( literal )
			scope
				dim x as wstring * BUFFER_SIZE = literal
				WWRITE( x, literal )
			end scope		
		#endmacro

		OPEN_FILE( "write_strings.txt" )

		check( "" )
		check( " " )
		check( "0123456789" )
		check( "ABCDEFGHIJKLMNOP" )
		check( !"\u3041\u3043\u3045\u3047\u3049" )

		CLOSE_AND_TEST_FILE()

	END_TEST

END_SUITE
