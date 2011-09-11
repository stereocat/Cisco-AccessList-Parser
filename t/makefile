TEST_SCRIPTS = $(wildcard *.pl)
TEST_CASE_CONF = $(wildcard *.conf)

.SUFFIXES: .conf .dat
.PHONY: clean test

test: $(TEST_CASE_CONF) $(TEST_SCRIPTS)
	sh testcase-generator.sh
	prove -I.. *.t 2>STDERR.dat

clean:
	rm -f *~ *.stackdump *.dat *.dat.t
