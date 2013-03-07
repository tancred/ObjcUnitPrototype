UNITTESTER=$(BUILT_PRODUCTS_DIR)/unittester


default: run_empty_bundle run_test_suite_tests

clean:

run_empty_bundle:
	@echo "testing EmptyBundle"
	- DYLD_FRAMEWORK_PATH=$(BUILT_PRODUCTS_DIR) $(UNITTESTER) $(BUILT_PRODUCTS_DIR)/EmptyBundle.bundle

run_test_suite_tests:
	@echo "testing TestSuiteTests"
	- DYLD_FRAMEWORK_PATH=$(BUILT_PRODUCTS_DIR) $(UNITTESTER) $(BUILT_PRODUCTS_DIR)/TestSuiteTests.bundle
