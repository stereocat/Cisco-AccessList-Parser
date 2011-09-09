#!/usr/bin/perl

use strict;
use warnings;
use GraphViz::Parse::Yapp;

my $outputfile = $ARGV[0] or die "usage: $0 'class.output'";
my $graph = GraphViz::Parse::Yapp->new($outputfile);
# print $graph->as_text;
$outputfile =~ s/.output$//g;
$graph->as_png($outputfile . ".png");
