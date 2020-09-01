# Sample Media Player

Sample media player implementation in flutter. As media player implementation in iOS and android are different, here I tried to implement AVPlayer for iOS and ExoPlayer for android platform by writing platform specific code.

#### Features
- Play and pause media
- Media controller in status bar and lock screen

## How to run
Run following commands after cloning this repository:
```sh
$ flutter pub get
$ flutter run
```
# Screens
<img src="https://raw.githubusercontent.com/shafayathossain/Media-Player-Flutter/master/screen/screen.gif" width="185" height="400">

# Motivation
Special thanks to [Flutter Playout](https://pub.dev/packages/flutter_playout) library because most of the native code is taken from here.

# Third party libraries used
- [Flutter Neumorphic](https://pub.dev/packages/flutter_neumorphic)
- [RxDart](https://pub.dev/packages/rxdart)
- [Flutter Bloc](https://pub.dev/packages/flutter_bloc)
- [Parcent Indicator](https://pub.dev/packages/percent_indicator)
- [Build Runner](https://pub.dev/packages/build_runner)
- [Dio](https://pub.dev/packages/dio)


# Contribution
1. Fork it
2. Create your feature branch (git checkout -b new_branch)
3. Commit your changes (git commit -m 'New feature')
4. Push to the branch (git push origin new_branch)
5. Create new Pull Request