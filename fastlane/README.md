fastlane documentation
================
# Installation

Make sure you have the latest version of the Xcode command line tools installed:

```
xcode-select --install
```

Install _fastlane_ using
```
[sudo] gem install fastlane -NV
```
or alternatively using `brew cask install fastlane`

# Available Actions
## iOS
### ios screenshots
```
fastlane ios screenshots
```
Get all screenshots
### ios beta
```
fastlane ios beta
```
Submit a new Beta Build to Apple TestFlight

This will also make sure the profile is up to date
### ios deploy
```
fastlane ios deploy
```
Deploy a new version to the App Store
### ios archive
```
fastlane ios archive
```
Create archive for App Store/TestFlight
### ios tests
```
fastlane ios tests
```
Runs all the tests
### ios unit_tests
```
fastlane ios unit_tests
```
Runs all unit tests
### ios ui_tests
```
fastlane ios ui_tests
```
Runs all ui tests

----

This README.md is auto-generated and will be re-generated every time [fastlane](https://fastlane.tools) is run.
More information about fastlane can be found on [fastlane.tools](https://fastlane.tools).
The documentation of fastlane can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
