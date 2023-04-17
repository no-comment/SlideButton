# SlideButton

SlideButton is a SwiftUI package that provides a customizable slide button that can be swiped to unlock or perform an action. The button consists of a background color, a title, an icon, and an indicator that can be dragged horizontally to unlock or perform an action. The view provides several customizable styling options, such as the size and color of the indicator and background, the text alignment, and whether the text fades or hides behind the indicator.

https://user-images.githubusercontent.com/20423069/232328779-f6ae204b-7ef6-4e96-93b0-8b7aa57e9617.mov


## Installation

You can install SlideButton using Swift Package Manager. To add SlideButton to your Xcode project, go to `File` > `Swift Packages` > `Add Package Dependency` and enter the URL `https://github.com/no-comment/SlideButton`.

## Usage

To use SlideButton, import the module `SlideButton` in your SwiftUI view.

```swift
import SwiftUI
import SlideButton
```

Create a `SlideButton` by providing a title and a callback that will execute when the user successfully swipes the indicator. 

```swift
SlideButton("Slide to Unlock") {
    await unlockDevice()
}
.padding()
```

You can customize the appearance of the slide button by providing a `Styling` instance. For example, you can change the size and color of the indicator, the alignment of the title text, and whether the text fades or hides behind the indicator.

```swift
let styling = SlideButton.Styling(
    indicatorSize: 60,
    indicatorSpacing: 5,
    indicatorColor: .accentColor,
    backgroundColor: .accentColor.opacity(0.3),
    textColor: .secondary,
    indicatorSystemName: "chevron.right",
    indicatorDisabledSystemName: "xmark",
    textAlignment: .center,
    textFadesOpacity: true,
    textHiddenBehindIndicator: true,
    textShimmers: false
)

SlideButton("Slide to Unlock", styling: styling) {
    await unlockDevice()
}
.padding()
```

## Documentation

SlideButton comes with documentation comments to help you understand how to use the package. You can access the documentation by option-clicking on any `SlideButton` or `Styling` instance in your code.
