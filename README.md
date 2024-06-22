# TFLiteMovement Pose Estimation SwiftUI
TensorFlow Lite Movement model iOS SwiftUI

### Overview

Demonstration on how to use TFLite Pose Estimation models as a Canvas overlay using SwiftUI.
The app demonstrates how to use 3 models:
* Posenet
* Movenet Lightning
* Movenet Thunder

## Build the demo using Xcode

### Prerequisites

*   [XCode](https://developer.apple.com/xcode/) 15.0 or later
*   A valid Apple Developer ID (XCode connected)
*   Real iOS device with camera
*   iOS version 17.0 or above
*   Xcode command line tools (to install, run `xcode-select --install`)
*   CocoaPods (to install, run `sudo gem install cocoapods`)

### Build and run the app

1.  Clone repository to your computer to get the demo application:

    ```
    git clone https://github.com//NazarKozak/TFLiteMovement.git
    ```

1. Pull git-lfs files:

    ```
    git-lfs pull
    ```

1.  Install the pod to generate the workspace file:

    ```
    pod install
    ```

    Note: If you have installed this pod before and that command doesn't work,
    try `pod update`. At the end of this step you should have a directory called
    `TFLiteMovement.xcworkspace`.

1.  Open the project in Xcode with the following command:

    ```
    open TFLiteMovement.xcworkspace
    ```

    This launches Xcode and opens the `TFLiteMovement` project.

1.  In Menu bar, select `Product` &rarr; `Destination` and choose your physical
    device.

1.  In Menu bar, select `Product` &rarr; `Run` to install the app on your
    device.
