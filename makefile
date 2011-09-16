CLASS = Parser
CLASS_NAME = "Cisco::AccessList::${CLASS}"

TEST_DIR = ./t
TEST_CONF = ${wildcard ${TEST_DIR}/*.conf}
LIB_DIR = ./lib/Cisco/AccessList
EYP_FILE = ${LIB_DIR}/$(CLASS).eyp
EYP_OUTPUT = ${LIB_DIR}/$(CLASS).output
EYP_MODULE = ${LIB_DIR}/$(CLASS).pm
EYP_GRAPH = ${LIB_DIR}/$(CLASS).png

EYP_GRAPH_GENERATOR = ./eypgraph.pl
EYAPP = eyapp -m ${CLASS_NAME} -o ${EYP_MODULE}

.SUFFIXES: .output .eyp .pm .png
.PHONY: clean test

# rules

all: output # graph

module: $(EYP_MODULE)

output: $(EYP_OUTPUT)

graph: $(EYP_GRAPH)

test: $(EYP_MODULE) clean
	perl ${TEST_DIR}/testcase-generator.pl ${TEST_CONF}
	prove -l ${TEST_DIR}/*.t

# suffix rules

.eyp.pm:
	${EYAPP} $<

.eyp.output:
	${EYAPP} -v $<

.output.png:
	perl $(EYP_GRAPH_GENERATOR) $<

# cleaning

clean:
	rm -f ${EYP_GRAPH} ${EYP_OUTPUT}
	rm -f ${TEST_DIR}/*.dat ${TEST_DIR}/*.dat.t
	rm -f  *.stackdump *~ ${LIB_DIR}/*~ ${TEST_DIR}/*~
