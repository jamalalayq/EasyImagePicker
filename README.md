# EasyImagePicker

[![CI Status](http://img.shields.io/travis/gemgemo/EasyImagePicker.svg?style=flat)](https://travis-ci.org/gemgemo/EasyImagePicker)
[![Version](https://img.shields.io/cocoapods/v/EasyImagePicker.svg?style=flat)](http://cocoapods.org/pods/EasyImagePicker)
[![License](https://img.shields.io/cocoapods/l/EasyImagePicker.svg?style=flat)](http://cocoapods.org/pods/EasyImagePicker)
[![Platform](https://img.shields.io/cocoapods/p/EasyImagePicker.svg?style=flat)](http://cocoapods.org/pods/EasyImagePicker)

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

## Installation

EasyImagePicker is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'EasyImagePicker'
```

## Usage

```swift

import UIKit
import EasyImagePicker

class ViewController: UIViewController {

private var imagePicker: ImagePicker?,
setting = Tuning.init()

@IBOutlet private weak var imageView: UIImageView!

internal override func viewDidLoad() {
super.viewDidLoad()

setting.type = .picture
setting.screen = self
imagePicker = ImagePicker.init()
imagePicker?.onCancel = {
debugPrint("picking canceled by user!")
}
imagePicker?.onError = {
debugPrint("error occurred!")
}
imagePicker?.onPickImage = { [weak self] (pickedIamge, picker) in
let reducedImage = picker.reduce(this: pickedIamge, to: 0.50) ?? .init()
let sizedImage = picker.resize(this: reducedImage, by: CGSize(width: 200, height: 200))
self?.imageView.image = sizedImage
}
}

@IBAction private func pickImageOnClick(_ sender: UIButton) {
switch sender.tag {
case 0:
setting.mode = .default
imagePicker?.pick(with: setting)
case 1:
setting.mode = .custom(.camera)
imagePicker?.pick(with: setting)
case 2:
setting.mode = .custom(.library)
imagePicker?.pick(with: setting)
default:
break
}
}


}


```

## Author

Gamal, gamalal3yk@gmail.com

## License

EasyImagePicker is available under the MIT license. See the LICENSE file for more info.
