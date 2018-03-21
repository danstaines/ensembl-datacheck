#!/bin/bash

ENSDIR="${ENSDIR:-$PWD}"

export PERL5LIB=$ENSDIR/bioperl-live:$ENSDIR/ensembl-test/modules:$PWD/lib:$ENSDIR/ensembl/modules:$ENSDIR/ensembl-variation/modules
export TEST_AUTHOR=$USER

if [ "$DB" = 'mysql' ]; then
    (cd modules/t && ln -sf MultiTestDB.conf.mysql MultiTestDB.conf)
else
    echo "Don't know about DB '$DB'"
    exit 1;
fi

echo "Running test suite"
if [ "$COVERALLS" = 'true' ]; then
  PERL5OPT='-MDevel::Cover=+ignore,bioperl,+ignore,ensembl-test,+ignore,ensembl' perl $ENSDIR/ensembl-test/scripts/runtests.pl -verbose lib/t $SKIP_TESTS
else
  perl $ENSDIR/ensembl-test/scripts/runtests.pl lib/t $SKIP_TESTS
fi

rt=$?
if [ $rt -eq 0 ]; then
  if [ "$COVERALLS" = 'true' ]; then
    echo "Running Devel::Cover coveralls report"
    cover --nosummary -report coveralls
  fi
  exit $?
else
  exit $rt
fi