//
//  ViewController.swift
//  EasyImagePicker
//
//  Created by gemgemo on 09/09/2017.
//  Copyright (c) 2017 gemgemo. All rights reserved.
//

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
        imagePicker?.onPickImage = { [weak self] (resource, picker) in
            print(#function, resource.name, resource.extension, resource.url)
            let reducedImage = picker.reduce(this: resource.image, to: 0.50) ?? .init()
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

