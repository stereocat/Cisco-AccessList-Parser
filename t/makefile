TEST_SCRIPTS = $(wildcard *.pl)
TEST_CASE_CONF = $(wildcard *.conf)

.SUFFIXES: .conf .dat .sh
.PHONY: clean test scripts

test: $(TEST_CASE_CONF) testscript
	prove -I.. *.t

testscript: $(TEST_CASE_CONF) $(TEST_SCRIPTS)
	sh testcase-generator.sh

clean:
	rm -f *~ *.stackdump *.dat *.dat.t
