UNITTESTER=$(BUILT_PRODUCTS_DIR)/unittester
EMPTY_BUNDLE=$(BUILT_PRODUCTS_DIR)/EmptyBundle.bundle


default: test_empty_bundle

test_empty_bundle:
	@echo "testing EmptyBundle"
	DYLD_FRAMEWORK_PATH=$(BUILT_PRODUCTS_DIR) $(UNITTESTER) $(EMPTY_BUNDLE)
