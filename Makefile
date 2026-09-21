SHELL := /bin/sh

PORT ?= 8000
GRADLE ?= gradle
ADB ?= adb
APK := android/app/build/outputs/apk/debug/app-debug.apk

.PHONY: help env server apk install-apk clean

help:
	@printf '%s\n' \
		'make env          Create the local Python/Node validation environment' \
		'make server       Start the LAN web server on PORT=$(PORT)' \
		'make apk          Build the Android localhost-server APK' \
		'make install-apk  Install the debug APK through adb' \
		'make clean        Remove generated Android build output'

env:
	./setup-env.sh

server:
	./serve.sh $(PORT)

apk:
	command -v $(GRADLE) >/dev/null 2>&1 || { printf '%s\n' 'Gradle not found. Install Gradle or run: make apk GRADLE=./gradlew' >&2; exit 1; }
	$(GRADLE) -p android assembleDebug

install-apk: apk
	$(ADB) get-state >/dev/null 2>&1 || { printf '%s\n' 'No adb device found. Enable USB debugging and connect the reader.' >&2; exit 1; }
	$(ADB) install -r $(APK)

clean:
	$(GRADLE) -p android clean
