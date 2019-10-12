# Emakina Self Test

Recruitment task from Emakina.

## Installing

- Clone repository using `git clone` or download zip file and unpack in convienient location.
- Run `pod update`.
- Open file Emakina-SelfTest.xcworkspace e.g. `open Emakina-SelfTest.xcworkspace`
- Change bundle identifier to whatever you get used to use in your organisation, preferably starting with reverse domain.
- If running on physical device make sure to download matching provisioning profile or set `Automatically Manage Signing`

## Notes

Let me apologise for misspelling your company name - some directories are called Emikana, not Emakina. :-(

I did not have time to write unit tests, this app is small and simple but providing significant testing coverage may take lot of time. It was not a requirement as per task description.

I used Xcode 11 instead of Xcode 10 as per task description. It should not make any difference, the app is compatible with iOS 11.0 and newer.

The app has been testen on iPhone X running iOS 13.1.2 and iPhone 6s running iOS 13.0 as well as iPhone 11 Pro simulator running iOS 13.0.
