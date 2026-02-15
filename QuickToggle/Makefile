XCODE = DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer
PROJECT = QuickToggle.xcodeproj
SCHEME = QuickToggle
DEVICE_UDID = F46443B3-8823-5599-9128-15A02CEC133F
DEVICE_XCODE_ID = 00008130-000959AE22E2001C
TEAM = W3JZD79A92
DERIVED = $(shell $(XCODE) xcodebuild -project $(PROJECT) -showBuildSettings 2>/dev/null | grep -m1 'BUILD_DIR' | awk '{print $$3}')
BUILD_DIR = /Users/Ale/Library/Developer/Xcode/DerivedData/QuickToggle-dbavvkaooqzehafhmpiyrpbfcajh/Build/Products

# Common build flags
SIGN_FLAGS = DEVELOPMENT_TEAM=$(TEAM) CODE_SIGN_STYLE=Automatic -allowProvisioningUpdates -allowProvisioningDeviceRegistration

# ============================================================
# IControlIt Full (Premium - $1 USD)
# Bundle ID: com.icontrolit.full
# Features: All features including custom shortcuts catalog
# ============================================================

.PHONY: build-full
build-full:
	$(XCODE) xcodebuild \
		-project $(PROJECT) \
		-scheme $(SCHEME) \
		-destination "id=$(DEVICE_XCODE_ID)" \
		-configuration Debug \
		APP_VARIANT=full \
		$(SIGN_FLAGS) \
		build

.PHONY: install-full
install-full: build-full
	$(XCODE) xcrun devicectl device install app \
		--device $(DEVICE_UDID) \
		$(BUILD_DIR)/Debug-iphoneos/QuickToggle.app

.PHONY: archive-full
archive-full:
	$(XCODE) xcodebuild \
		-project $(PROJECT) \
		-scheme $(SCHEME) \
		-destination 'generic/platform=iOS' \
		-configuration Release \
		APP_VARIANT=full \
		$(SIGN_FLAGS) \
		-archivePath ~/IControlItFull.xcarchive \
		archive

# ============================================================
# IControlIt Free (Gratuito)
# Bundle ID: com.icontrolit.free
# Features: Basic features without custom shortcuts catalog
# ============================================================

.PHONY: build-free
build-free:
	$(XCODE) xcodebuild \
		-project $(PROJECT) \
		-scheme $(SCHEME) \
		-destination "id=$(DEVICE_XCODE_ID)" \
		-configuration Debug \
		APP_VARIANT=free \
		SWIFT_ACTIVE_COMPILATION_CONDITIONS=DEBUG \
		$(SIGN_FLAGS) \
		build

.PHONY: install-free
install-free: build-free
	$(XCODE) xcrun devicectl device install app \
		--device $(DEVICE_UDID) \
		$(BUILD_DIR)/Debug-iphoneos/QuickToggle.app

.PHONY: archive-free
archive-free:
	$(XCODE) xcodebuild \
		-project $(PROJECT) \
		-scheme $(SCHEME) \
		-destination 'generic/platform=iOS' \
		-configuration Release \
		APP_VARIANT=free \
		'SWIFT_ACTIVE_COMPILATION_CONDITIONS= ' \
		$(SIGN_FLAGS) \
		-archivePath ~/IControlItFree.xcarchive \
		archive

# ============================================================
# Convenience
# ============================================================

.PHONY: clean
clean:
	$(XCODE) xcodebuild -project $(PROJECT) -scheme $(SCHEME) clean
	rm -rf build/

.PHONY: help
help:
	@echo "IControlIt Build System"
	@echo ""
	@echo "  make build-full     - Build Full version (with PREMIUM features)"
	@echo "  make install-full   - Build and install Full on iPhone"
	@echo "  make archive-full   - Create Release archive for Full version"
	@echo ""
	@echo "  make build-free     - Build Free version (without PREMIUM features)"
	@echo "  make install-free   - Build and install Free on iPhone"
	@echo "  make archive-free   - Create Release archive for Free version"
	@echo ""
	@echo "  make clean          - Clean build artifacts"
