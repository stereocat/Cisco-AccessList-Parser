TEST_CASE_CONF = $(wildcard *.conf)
TEST_CASE_DATA = $(TEST_CASE_CONF:%.conf=%.dat)
TEST_RUNNER = $(TEST_CASE_CONF:%.conf=%.sh)

.SUFFIXES: .conf .dat .sh
.PHONY: clean test scripts

test: $(TEST_CASE_CONF) $(TEST_CASE_DATA) $(TEST_RUNNER)
	prove -I.. *.t *.sh

scripts: $(TEST_CASE_CONF) $(TEST_CASE_DATA) $(TEST_RUNNER)

.conf.dat:
	perl testcase-generator.pl $<

.dat.sh:
	@echo "#!/bin/sh" > $(<:%.dat=%.sh)
	@echo "perl -I.. test-runner.pl 2>/dev/null" $< >> $(<:%.dat=%.sh)

clean:
	rm -f *~ $(TEST_CASE_DATA) $(TEST_RUNNER) *.stackdump
