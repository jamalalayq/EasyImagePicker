//  ImagePicker.swift
//  ImagePicker
//  Created by GeMoOo on 9/8/17.
//  Copyright © 2017 GeMoOo. All rights reserved.


import UIKit
import MobileCoreServices

public typealias ImagePickerDelegate = UIImagePickerControllerDelegate & UINavigationControllerDelegate


public final class ImagePicker: NSObject {
    
    private var picker: UIImagePickerController?
    
    public var onPickImage: ((UIImage, ImagePicker)->())?, onCancel: (()->())?, placeholderImage = UIImage(), alertTitle, alertMessage: String?, tintColor = UIColor.darkGray, cameraTitle = "Camera", libraryTitle = "Library", cancelTitle = "Cancel", onError: (()->())?
    
    /// TODO:- picking image
    public func pickeImage() -> Void {
        picker = UIImagePickerController()
        picker?.delegate = self
        picker?.allowsEditing = true
        picker?.mediaTypes = [kUTTypeImage as String]
        let alert = UIAlertController(title: alertTitle ?? "", message: alertMessage ?? "", preferredStyle: .alert)
        alert.view.layer.cornerRadius = 4.0
        alert.view.tintColor = tintColor
        alert.addAction(UIAlertAction(title: cancelTitle, style: .cancel, handler: { [weak self] (action) in
            NSLog("tell user something in `onCancel` block because he cancel picking")
            self?.onCancel?()
        }))
        alert.addAction(UIAlertAction(title: cameraTitle, style: .default, handler: { [weak self] (action) in
            guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
                NSLog("tell user something in `onError` block because camera not available")
                self?.onError?()
                return
            }
            self?.picker?.sourceType = .camera
            guard let picker = self?.picker else {
                NSLog("use `onError` block because ImagePicker is null")
                self?.onError?()
                return
            }
            UIApplication.shared.keyWindow?.rootViewController?.present(picker, animated: true)
        }))
        alert.addAction(UIAlertAction(title: libraryTitle, style: .default, handler: { [weak self] (action) in
            guard UIImagePickerController.isSourceTypeAvailable(.photoLibrary) else {
                NSLog("tell user something in `onError` block because photoLibrary not available")
                self?.onError?()
                return
            }
            self?.picker?.sourceType = .photoLibrary
            guard let picker = self?.picker else {
                NSLog("use `onError` block because ImagePicker is null")
                self?.onError?()
                return
            }
            UIApplication.shared.keyWindow?.rootViewController?.present(picker, animated: true)
        }))        
        UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true)
    }
    
    
    // TODO:- resize image dimensions
    public func resize(this image: UIImage, by size: CGSize, _ isOpaque: Bool = false) -> UIImage? {
        debugPrint("old size: \(image.size)")
        let horizontalRatio = size.width / image.size.width
        let verticalRatio = size.height / image.size.height
        let ratio = max(horizontalRatio, verticalRatio)
        let newSize = CGSize(width: image.size.width * ratio, height: image.size.height * ratio)
        debugPrint("new size: \(newSize)")
        var newImage: UIImage?
        if #available(iOS 10.0, *) {
            let renderFormat = UIGraphicsImageRendererFormat.default()
            renderFormat.opaque = isOpaque
            let renderer = UIGraphicsImageRenderer(size: newSize, format: renderFormat)
            newImage = renderer.image { (context) in
                image.draw(in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
            }
        } else {
            UIGraphicsBeginImageContextWithOptions(newSize, isOpaque, UIScreen.main.scale)
            image.draw(in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
            newImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
        }
        return newImage
    }
    
    
    // TODO:- reduce image quality
    public func reduce(this image: UIImage, to quality: CGFloat, _ scale: CGFloat = UIScreen.main.scale) -> UIImage? {
        debugPrint("size before reduce image: \(UIImagePNGRepresentation(image) ?? Data())")
        guard let imageData = UIImageJPEGRepresentation(image, quality) else {
            return nil
        }
        debugPrint("size after reduce image: \(imageData)")
        return UIImage(data: imageData, scale: scale)
    }
    

}


extension ImagePicker: ImagePickerDelegate  {
    
    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        NSLog("tell user something in `onCancel` block because he cancel picking")
        picker.dismiss(animated: true, completion: onCancel)
    }
    
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        var pickedImage: UIImage
        if let originalPhoto = info[UIImagePickerControllerOriginalImage] as? UIImage {
            pickedImage = originalPhoto
        } else if let editedImage = info[UIImagePickerControllerEditedImage] as? UIImage {
            pickedImage = editedImage
        } else {
            pickedImage = placeholderImage
        }
        NSLog("user picking image you can find it in `onPickImage` block")
        onPickImage?(pickedImage, self)
        picker.dismiss(animated: true)
    }
    
}





























