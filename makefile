CLASS = AclParser

EYP_FILE = $(CLASS).eyp
EYP_OUTPUT = $(CLASS).output
EYP_MODULE = $(CLASS).pm
EYP_MODULE_DIR = ./
EYP_GRAPH = $(CLASS).png
TEST_DIR = ./t/

EYP_GRAPH_GENERATOR = ./eypgraph.pl

.SUFFIXES: .output .eyp .pm .png
.PHONY: clean test

# rules

all: output # graph

module: $(EYP_MODULE)

output: $(EYP_OUTPUT)

graph: $(EYP_GRAPH)

test: $(EYP_MODULE)
	make -C $(TEST_DIR) test

# suffix rules

.eyp.pm:
	eyapp $<

.eyp.output:
	eyapp -v $<

.output.png:
	perl $(EYP_GRAPH_GENERATOR) $<

# cleaning

clean:
	rm -f *.output *.png *~ *.stackdump
	make -C $(TEST_DIR) clean
