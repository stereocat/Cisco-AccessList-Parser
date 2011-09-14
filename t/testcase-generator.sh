#!/usr/bin/sh

for conf in *.conf
do
    perl testcase-generator.pl $conf
done

for dat in *.dat
do
    testscript=${dat}.t
    echo "#!/bin/sh" > $testscript
    echo "perl test-runner.pl" $dat >> $testscript
done

