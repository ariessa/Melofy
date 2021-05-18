# About the App

A Flutter application to generate melody from audio input. It can run on Android version 7.1.2 and above. 

</br> 

## Understanding the App

The features of this app are as follows: 

● Register

● Log In

● Record Audio

● View the Recorded Audio

● Play the Recorded Audio

● Pause the Recorded Audio

● Delete the Recorded Audio

● Use the Recorded Audio

● Generate Melody

● View the Generated Melody

● Play the Generated Melody

● Pause the Generated Melody

● Favourite the Generated Melody

● Share the Generated Melody

● Close the Generated Melody

● View Generated Melodies

● View Favourited Melodies

● View In-App Tutorials

● Log Out

</br> 

## Building and Releasing the APKs

> **_NOTE:_** If flutter_ffmpeg release builds on Android fail, make sure that mavenCentral() is defined as a repository in your build.gradle and it is listed before jcenter().

1. Clear build cache

```
flutter clean
```

2. Get depenedencies listed in `pubspec.yaml`

```
flutter pub get
```

3. Build APKs by splitting them per Application Binary Interface (ABI)

```
flutter build apk --split-per-abi
```

</br> 

## Testing the App

1. Find out your device's CPU architecture.

> **_NOTE:_**  Refer to this [article](https://android.gadgethacks.com/how-to/android-basics-see-what-kind-processor-you-have-arm-arm64-x86-0168051/) to find out your device's CPU architecture.

2. In [Melofy's latest release](https://github.com/ariessa/Melofy/releases/latest), expand the Assets section.

3. Download the specific release APK based on your device's CPU architecture and install it.

+ For `ARM`, use APK ending with _armeabi-v7a.apk_
+ For `ARM64`, use APK ending with _arm64-v8a.apk_
+ For `x86_64`, use APK ending with _x86_64.apk_

Or, you can download the fat APK that can be installed on `ARM`, `ARM64`, and `x86_64`.

+ The Fat APK is the APK ending with _fat.apk_

> **_WARNING I:_** There is no apk for x86 Android. This is because Flutter does not currently support building for x86 Android. Refer to this [issue](https://github.com/flutter/flutter/issues/9253) on Github.

> **_WARNING II:_** These builds are intended for debugging purposes only. Usage outside of debugging may cause unexpected crashes and performance lags. 



