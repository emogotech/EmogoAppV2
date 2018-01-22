//
//  PhotoEditor+Crop.swift
//  Pods
//
//  Created by Pushpendra on 13/12/17.
//
//

import Foundation
import UIKit
import CropViewController

// MARK: - CropView
extension PhotoEditorViewController: CropViewControllerDelegate {
    
    func cropViewController(_ cropViewController: CropViewController, didCropToImage image: UIImage, withRect cropRect: CGRect, angle: Int) {
        cropViewController.dismiss(animated: true, completion: nil)
        self.canvasImageView.image = image
        self.canvasImageView.contentMode = .scaleAspectFill
    }

}
