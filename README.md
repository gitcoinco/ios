<img src='https://d3vv6lp55qjaqc.cloudfront.net/items/263e3q1M2Y2r3L1X3c2y/helmet.png'/>

# Gitcoin iOS app (pre-alpha)

This is an app that allows one to explore funded issues from their iPhone.

[Star](https://github.com/gitcoinco/ios/stargazers) and [watch](https://github.com/gitcoinco/ios/watchers) this github repository to stay up to date, we're pushing new code several times per week!

# Demo

Watch the gif below, or <a href="https://TBD">check out the video</a>.

<a href="https://TBD">
<img src='img/demo.gif'/>
TBD
</a>

# Gitcoin

Gitcoin pushes Open Source Forward. Learn more at [https://gitcoin.co](https://gitcoin.co)

# Setup
1. [Install cocoapods](https://guides.cocoapods.org/using/getting-started.html), and run `pod install` from the repo
2. `cp SafeConfiguration.plist.dist SafeConfiguration.plist`
3. Edit your `SafeConfiguration.plist` file and add the following keys as strings: `gitHubOAuthToken`, `gitHubOAuthSecret` ([see here to create these values](https://github.com/settings/developers))
4. Build the app in xcode (make sure to open the `Gitcoin.xcworkspace` file, not the `Gitcoin.xcodeproj` file)

# Legal

'''

Copyright (C) 2017 Gitcoin Core 

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU Affero General Public License as published
by the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
GNU Affero General Public License for more details.

You should have received a copy of the GNU Affero General Public License
along with this program. If not, see <http://www.gnu.org/licenses/>.


'''

# Credits

Thanks to @cheneveld for the initial app build and @john-brunelle for helping get this in the app store.




<!-- Google Analytics -->
<img src='https://ga-beacon.appspot.com/UA-102304388-1/gitcoinco/ios' style='width:1px; height:1px;' >




