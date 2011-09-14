#!/usr/bin/sh

dir=${0%\/*.*}
echo "cd $dir"
pushd .
cd $dir

for conf in *.conf
do
    perl testcase-generator.pl $conf
done

for dat in *.dat
do
    testscript=${dat}.t
    echo "#!/bin/sh" > $testscript
    # FIX TBD. Too ad-hoc...
    echo "perl -Ilib t/test-runner.pl t/$dat" >> $testscript
done

popd
