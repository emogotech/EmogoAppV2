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
extension FilterViewController: CropViewControllerDelegate {
    
    func cropViewController(_ cropViewController: CropViewController, didCropToImage image: UIImage, withRect cropRect: CGRect, angle: Int) {
        self.image = image
        cropViewController.dismiss(animated: true, completion: nil)
    }

}
