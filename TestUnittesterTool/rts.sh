#!/bin/sh
exec 2>&1

echo "changing to $BUILT_PRODUCTS_DIR"
cd "$BUILT_PRODUCTS_DIR"

TESTER=ObjcUnit.framework/Versions/Current/unittester

$TESTER EmptyBundle.bundle
$TESTER TestSuiteTests.bundle
