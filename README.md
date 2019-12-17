# Promo-home-assignment

With this home assignment I decided to give Apple's SwiftUI and Combine a try.  
The app takes advantage of MVVM pattern with majority of app's logic tested. 

Unfortunately, SwiftUI still contains many bugs, so I would strongly recommend testing the app on a real device rather than simulator (especially when using latest Xcode 11.3, there are some [NavigationLink issues (link)](https://stackoverflow.com/questions/59075206/simulator-vs-physical-device-navigationlink-broken-after-one-use)).

With bigger app I would probably add some navigation layer (like coordinators), but with this one, simple MVVM works for me.

Exchange rate (for other currencies than USD) is refreshed every 5 seconds.
Primary error handling is done, but with production app I would definately pay more attention to it.

I’m looking forward to code review and comments!

# Minimum requirements
⋅⋅* Xcode 11.0
⋅⋅* iOS 13.0