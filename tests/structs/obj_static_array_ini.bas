# include "fbcu.bi"

namespace fbc_tests.structs.obj_static_array_ini

const ARRAY_LB = 0
const ARRAY_UB = 4

type bar
    as integer v = any
    declare constructor( byval value as integer )
end type

constructor bar( byval value as integer )
	v = value
end constructor

sub func
	static as bar b1(ARRAY_LB to ARRAY_UB) = { bar(1), bar(2), bar(3), bar(4), bar(5) }
	
	dim as integer i
	for i = ARRAY_LB to ARRAY_UB
		CU_ASSERT_EQUAL( b1(i).v, 1 + i )
	next
	
end sub

sub test cdecl	
	
	'' run twice, the ctor should be called only once
	func
	func
	
end sub
	
private sub ctor () constructor

	fbcu.add_suite("fbc_tests.structs.obj_static_array_ini")
	fbcu.add_test( "test", @test)

end sub
	
end namespace	