CLASS = Parser
CLASSNAME = 'Cisco::AccessList::'${CLASS}

TEST_DIR = ./t
LIB_DIR = ./lib/Cisco/AccessList
EYP_FILE = ${LIB_DIR}/$(CLASS).eyp
EYP_OUTPUT = ${LIB_DIR}/$(CLASS).output
EYP_MODULE = ${LIB_DIR}/$(CLASS).pm
EYP_GRAPH = $(CLASS).png

EYP_GRAPH_GENERATOR = ./eypgraph.pl

.SUFFIXES: .output .eyp .pm .png
.PHONY: clean test

# rules

all: output # graph

module: $(EYP_MODULE)

output: $(EYP_OUTPUT)

graph: $(EYP_GRAPH)

test: $(EYP_MODULE)
	sh testcase-generator.sh
	prove t/*.t

# suffix rules

.eyp.pm:
	eyapp -m ${CLASSNAME} $<

.eyp.output:
	eyapp -v $<

.output.png:
	perl $(EYP_GRAPH_GENERATOR) $<

# cleaning

clean:
	rm -f *~ *.stackdump *.png ${EYP_OUTPUT}
	rm -f *~ *.stackdump ${TEST_DIR}/*.dat ${TEST_DIR}/*.dat.t

