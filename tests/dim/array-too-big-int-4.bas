' TEST_MODE : COMPILE_ONLY_FAIL

'' check triggered in UDT field singledecl parser
const LIMIT = &h7FFFFFFF
type Container
	test(0 to LIMIT \ 4) as integer
end type
