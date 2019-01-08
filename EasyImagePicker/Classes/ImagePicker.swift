//
//  ImagePicker.swift
//
//  Created by Jamal Alayq on 9/8/17.
//
//  Copyright © 2017 Jamal Alayq. All rights reserved.

import UIKit
import MobileCoreServices
import AVFoundation

public typealias ImagePickerDelegate = UIImagePickerControllerDelegate & UINavigationControllerDelegate

public final class ImagePicker: NSObject {
    
    private var picker: UIImagePickerController?
    private var tune: Tuning!
    public var onPickImage: ((UIImage, ImagePicker)->())?,
    onCancel: (()->())?,    
    onError: (()->())?,
    onPickVideoURL: ((URL, ImagePicker)->())?
    
    // MARK:- Inits
    
    public override init() {
        super.init()
        picker = UIImagePickerController()
        picker?.delegate = self
        picker?.allowsEditing = true
    }
    
    /// TODO:- picking image
    public func pick(with tuning: Tuning) -> Void {
        self.tune = tuning
        guard tune.screen != nil else { fatalError("screen must have value.") }
        picker?.mediaTypes = [tune.type == .picture ? kUTTypeImage as String : kUTTypeMovie as String]
        switch tune.mode {
        case .default:
            openFromDefaultMode()
        case .custom(let choice):
            switch choice {
            case .camera: openCamera()
            case .library: openPhotoLibrary()
            }
        }
    }
    
}

// MARK:- Private functions

private extension ImagePicker {
    
    func openFromDefaultMode() {
        let alert = UIAlertController(title: tune.alertTitle ?? "", message: tune.alertMessage ?? "", preferredStyle: .alert)
        alert.view.tintColor = tune.tintColor
        alert.addAction(UIAlertAction(title: tune.cancelTitle, style: .cancel, handler: { [weak self] _ in
            print(#function, "tell user something in `onCancel` block because he cancel picking")
            self?.onCancel?()
            self?.onCancel = .none
        }))
        alert.addAction(UIAlertAction(title: tune.cameraTitle, style: .default, handler: { [weak self] _ in
            self?.openCamera()
        }))
        alert.addAction(UIAlertAction(title: tune.libraryTitle, style: .default, handler: { [weak self] _ in
            self?.openPhotoLibrary()
        }))
        tune.screen?.present(alert, animated: true)
    }
    
    func openPhotoLibrary() {
        guard UIImagePickerController.isSourceTypeAvailable(.photoLibrary) else {
            print(#function, "tell user something in `onError` block because photoLibrary not available")
            onError?()
            onError = .none
            return
        }
        picker?.sourceType = .photoLibrary
        guard let picker = picker else {
            print(#function, "use `onError` block because ImagePicker is null")
            onError?()
            onError = .none
            return
        }
        tune.screen?.present(picker, animated: true)
    }
    
    func openCamera() {
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
            print(#function, "tell user something in `onError` block because camera not available")
            onError?()
            onError = .none
            return
        }
        picker?.sourceType = .camera
        guard let picker = picker else {
            print(#function, "use `onError` block because ImagePicker is null")
            onError?()
            onError = .none
            return
        }
        tune.screen?.present(picker, animated: true)
    }
    
}

// MARK:- Public functions

public extension ImagePicker {
    
    // TODO: resize image dimensions
    func resize(this image: UIImage,
                by size: CGSize,
                _ isOpaque: Bool = false,
                _ scale: CGFloat = UIScreen.main.scale) -> UIImage? {
        print(#function, "old size: \(image.size)")
        let horizontalRatio = size.width / image.size.width
        let verticalRatio = size.height / image.size.height
        let ratio = max(horizontalRatio, verticalRatio)
        let newSize = CGSize(width: image.size.width * ratio, height: image.size.height * ratio)
        print(#function, "new size: \(newSize)")
        if #available(iOS 10.0, *) {
            let renderFormat = UIGraphicsImageRendererFormat.default()
            renderFormat.opaque = isOpaque
            renderFormat.scale = scale
            let renderer = UIGraphicsImageRenderer(size: newSize, format: renderFormat)
            return renderer.image { _ in
                image.draw(in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
            }
        } else {
            UIGraphicsBeginImageContextWithOptions(newSize, isOpaque, scale)
            image.draw(in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
            let newImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            return newImage
        }
    }
    
    // TODO: reduce image quality
    func reduce(this image: UIImage, to quality: CGFloat, _ scale: CGFloat = UIScreen.main.scale) -> UIImage? {
        print(#function, "size before reduce image: \(image.jpegData(compressionQuality: 1) ?? .init())")
        guard let imageData = image.jpegData(compressionQuality: quality) else { return .none }
        print(#function, "size after reduce image: \(imageData)")
        return UIImage(data: imageData, scale: scale)
    }
    
    // TODO: Take cover photo
    func getThumbnailImage(for url: URL) -> UIImage? {
        let asset = AVAsset.init(url: url)
        let imageGenerator = AVAssetImageGenerator.init(asset: asset)
        imageGenerator.appliesPreferredTrackTransform = true
        guard let cgImage = try? imageGenerator.copyCGImage(at: CMTimeMakeWithSeconds(1, preferredTimescale: 1), actualTime: .none) else { return .none }
        return UIImage.init(cgImage: cgImage)
    }
    
}

// MARK:- Image Picker Delegate functions

extension ImagePicker: ImagePickerDelegate  {
    
    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        print(#function, "tell user something in `onCancel` block because he cancel picking")
        picker.dismiss(animated: true, completion: onCancel)
    }
    
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        if let videoURL = info[.mediaURL] as? URL {
            onPickVideoURL?(videoURL, self)
            onPickVideoURL = .none
        } else {
            var pickedImage = tune.placeholderImage
            if let editedImage = info[.editedImage] as? UIImage {
                pickedImage = editedImage
            } else if let originalPhoto = info[.originalImage] as? UIImage {
                pickedImage = originalPhoto
            }
            print(#function, "user picking image you can find it in `onPickImage` block")
            onPickImage?(pickedImage, self)
            onPickImage = .none
        }
        picker.dismiss(animated: true)
    }
    
}
