# E-Reader MTG Life Counter

An e-paper-friendly MTG life counter for 2-6 players, optimized for the Tolino Vision 4 HD browser. It is a standalone HTML app and can run either from a LAN server or from the Android localhost-server APK.

## Install the APK

Download the latest APK from the project's GitHub Releases page. No build tools are needed if you use a released APK.

### Enable USB debugging on Tolino firmware 16.2.0

On the reader:

1. Open **Settings**.
2. Open **Device information** or **About device**.
3. Tap **Build number** seven times in quick succession.
4. Return to Settings and open **Developer options**.
5. Enable **USB debugging** and confirm the warning.
6. Connect the reader by USB and accept the debugging confirmation if it appears.

On Ubuntu, install `adb` if needed:

```sh
sudo apt update
sudo apt install adb
adb devices
```

The reader should appear in `adb devices`. Install the downloaded release APK with:

```sh
adb install -r MTG-Life-Counter-v1.0.0.apk
```

Start the local server without opening the browser:

```sh
adb shell am start -n com.example.mtglifecounter/.MainActivity
```

Open the reader browser manually at:

```text
http://127.0.0.1:8080/
```

The APK also starts the localhost service after `BOOT_COMPLETED` where the Tolino permits boot receivers. The browser still needs to be opened manually.

## Use Over Wi-Fi

On the computer, run:

```sh
./serve.sh
```

Find the computer's Wi-Fi address with `hostname -I`, then open this URL on the reader:

```text
http://<computer-ip>:8000/
```

Both devices must be connected to the same Wi-Fi network. Use `./serve.sh 8081` or `make server PORT=8081` to select another port.

## Build the APK

The Android project packages the current `index.html` into a debug APK. The APK starts a localhost-only HTTP server on port `8080`; it does not automatically open the browser.

The app targets API 19 for the Tolino while compiling against Platform 33. On Ubuntu Noble, install the Android SDK components and Java with:

```sh
sudo apt install openjdk-21-jdk google-android-platform-33-installer google-android-build-tools-34-installer adb
```

The project uses the SDK at `/usr/lib/android-sdk` through the ignored file `android/local.properties`. If the SDK is installed elsewhere, change that file locally without committing it.

The repository uses Python to create a virtual environment and download Gradle locally into ignored `.tools/`; it does not require `/opt` or a system Gradle installation:

```sh
make apk
```

The APK is created at:

```text
android/app/build/outputs/apk/debug/MTG-Life-Counter-v1.0.0.apk
```

The version is controlled by the Makefile and can be changed when building:

```sh
make apk VERSION=1.0.1
```

## Make Targets

```text
make help         Show available targets
make setup        Create Python/Node/Gradle tools locally
make env          Alias for make setup
make server       Start the LAN server
make apk          Build the debug APK
make install-apk  Build and install through adb
make clean        Clean Android build output
```

`make install-apk` installs the locally built debug APK. It does not install a GitHub release APK; install that directly with `adb install -r <release-apk>` as shown above.

Useful overrides:

```sh
make server PORT=8081
make apk GRADLE=./.tools/gradle-8.5/bin/gradle
make install-apk ADB=/path/to/adb
make apk VERSION=1.0.1
```
