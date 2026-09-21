SHELL := /bin/sh

PORT ?= 8000
VERSION ?= 1.0.0
GRADLE_VERSION ?= 8.5
GRADLE ?= ./.tools/gradle-$(GRADLE_VERSION)/bin/gradle
ADB ?= adb
APK := android/app/build/outputs/apk/debug/MTG-Life-Counter-v$(VERSION).apk
DEBUG_APK := android/app/build/outputs/apk/debug/app-debug.apk

.PHONY: help setup env server apk install-apk clean

help:
	@printf '%s\n' \
		'make setup        Create Python/Node/Gradle tools locally' \
		'make env          Alias for make setup' \
		'make server       Start the LAN web server on PORT=$(PORT)' \
		'make apk          Build the Android localhost-server APK' \
		'make install-apk  Install the debug APK through adb' \
		'make clean        Remove generated Android build output'

setup:
	./setup-env.sh

env: setup

server:
	./serve.sh $(PORT)

apk: setup
	[ -x "$(GRADLE)" ] || { printf '%s\n' 'Gradle setup failed or Android SDK is missing.' >&2; exit 1; }
	$(GRADLE) -p android -PappVersion=$(VERSION) assembleDebug
	cp "$(DEBUG_APK)" "$(APK)"
	printf 'APK: %s\n' "$(APK)"

install-apk: apk
	$(ADB) get-state >/dev/null 2>&1 || { printf '%s\n' 'No adb device found. Enable USB debugging and connect the reader.' >&2; exit 1; }
	$(ADB) install -r $(APK)

clean:
	$(GRADLE) -p android clean
