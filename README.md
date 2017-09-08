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
class ViewController: UIViewController {

    private var imagePicker: ImagePicker?

    @IBOutlet private weak var imageView: UIImageView!

    internal override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker = ImagePicker()
        imagePicker?.alertMessage = "from camera or library"
        imagePicker?.alertTitle = "pick image"
        imagePicker?.onCancel = {
            debugPrint("picking canceled by user!")
        }
        imagePicker?.onError = {
            debugPrint("error occurred!")
        }
        imagePicker?.onPickImage = { [weak self] (pickedIamge, picker) in
            self?.imageView.image = picker.resize(this: pickedIamge, by: CGSize(width: 200, height: 200)) //picker.reduce(this: pickedIamge, to: 0.20)//
        }
    }


    @IBAction private func pickImageOnClick(_ sender: UIButton) {
        imagePicker?.pickeImage()
    }


}

```

## Author

Gamal, gamalal3yk@gmail.com

## License

EasyImagePicker is available under the MIT license. See the LICENSE file for more info.
