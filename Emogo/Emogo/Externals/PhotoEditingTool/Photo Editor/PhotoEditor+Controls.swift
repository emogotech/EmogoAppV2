//
//  PhotoEditor+Controls.swift
//  Pods
//
//  Created by Pushpendra on 13/12/17.
//
//

import Foundation
import UIKit

// MARK: - Control
public enum control {
    case crop
    case sticker
    case draw
    case text
    case save
    case share
    case clear
}

extension PhotoEditorViewController {

     //MARK: Top Toolbar
    
    @IBAction func cancelButtonTapped(_ sender: Any) {
        photoEditorDelegate?.canceledEditing()
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func cropButtonTapped(_ sender: UIButton) {
        let controller = CropViewController()
        controller.delegate = self
        controller.image = image
        let navController = UINavigationController(rootViewController: controller)
        present(navController, animated: true, completion: nil)
    }

    @IBAction func stickersButtonTapped(_ sender: Any) {
        addStickersViewController()
    }

    @IBAction func drawButtonTapped(_ sender: Any) {
        colorPickerButtonsWidth.constant = 105.0
        drawViewButton.isHidden = false
        isDrawing = true
        canvasImageView.isUserInteractionEnabled = false
        doneButton.isHidden = false
        colorPickerView.isHidden = false
        self.filterButton.isHidden = true
        hideToolbar(hide: true)
    }

    @IBAction func textButtonTapped(_ sender: Any) {
        isTyping = true
        self.colorsCollectionView.isHidden = false
        drawViewButton.isHidden = true
        colorPickerButtonsWidth.constant = 0.0
        let textView = UITextView(frame: CGRect(x: 0, y: canvasImageView.center.y,
                                                width: UIScreen.main.bounds.width, height: 30))
        
        textView.textAlignment = .center
        textView.font = UIFont(name: "Helvetica", size: 30)
        textView.textColor = textColor
        textView.layer.shadowColor = UIColor.black.cgColor
        textView.layer.shadowOffset = CGSize(width: 1.0, height: 0.0)
        textView.layer.shadowOpacity = 0.2
        textView.layer.shadowRadius = 1.0
        textView.layer.backgroundColor = UIColor.clear.cgColor
        textView.autocorrectionType = .no
        textView.isScrollEnabled = false
        textView.keyboardAppearance = .dark
        textView.returnKeyType = .done
        textView.delegate = self
        self.canvasImageView.addSubview(textView)
        addGestures(view: textView)
        textView.becomeFirstResponder()
    }    
    
    @IBAction func doneButtonTapped(_ sender: Any) {
        self.filterButton.isHidden = false
       self.doneButtonAction()
    }

    //MARK: Bottom Toolbar
    
    @IBAction func saveButtonTapped(_ sender: AnyObject) {
        UIImageWriteToSavedPhotosAlbum(canvasView.toImage(),self, #selector(PhotoEditorViewController.image(_:withPotentialError:contextInfo:)), nil)
    }
    
    @IBAction func shareButtonTapped(_ sender: UIButton) {
        let activity = UIActivityViewController(activityItems: [canvasView.toImage()], applicationActivities: nil)
        present(activity, animated: true, completion: nil)
        
    }
    
    @IBAction func clearButtonTapped(_ sender: AnyObject) {
        //clear drawing
        canvasImageView.image = nil
        //clear stickers and textviews
        for subview in canvasImageView.subviews {
            subview.removeFromSuperview()
        }
    }
    
    @IBAction func continueButtonPressed(_ sender: Any) {
        let img = self.canvasView.toImage()
        photoEditorDelegate?.doneEditing(image: img)
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func pencilButtonPressed(_ sender: Any) {
        self.isPencilSelected = !self.isPencilSelected
        if self.isPencilSelected {
            self.pencilButton.setImage(#imageLiteral(resourceName: "pen_icon"), for: .normal)
            self.pencilView.isHidden = false
            Animation.viewSlideInFromBottomToTop(views:self.pencilView)
        }else {
            self.pencilButton.setImage(#imageLiteral(resourceName: "pen_icon_unactive"), for: .normal)
            self.pencilView.isHidden = true
            Animation.viewSlideInFromTopToBottom(views:self.pencilView)
        }
    }
    @IBAction func colorShowButtonPressed(_ sender: Any) {
        self.isColorSelected = !self.isColorSelected
        if self.isColorSelected {
            let image = UIImage(named: "color_bucket_icon")
            self.colorButton.setImage(image, for: .normal)
            self.colorsCollectionView.isHidden = false
            Animation.viewSlideInFromRightToLeft(view:self.colorsCollectionView)
        }else {
            let image = UIImage(named: "color_bucket_icon_unactive")
            self.colorButton.setImage(image, for: .normal)
            self.colorsCollectionView.isHidden = true
            Animation.viewSlideInFromLeftToRight(view:self.colorsCollectionView)
        }
    }
    @IBAction func btnPencilSelectedPressed(_ sender: UIButton) {
        self.pencilView.isHidden = true
        self.isPencilSelected = false
        self.pencilButton.setImage(#imageLiteral(resourceName: "pen_icon_unactive"), for: .normal)
        Animation.viewSlideInFromTopToBottom(views:self.pencilView)
        switch sender.tag {
        case 11:
            self.drawWidth = 5.0
            break
        case 22:
            self.drawWidth = 10.0
            break
        case 33:
            self.drawWidth = 15.0
            break
        default:
            break
        }
    }
    
    @IBAction func btnFilterPressed(_ sender: UIButton) {
        self.isFilterSelected = !self.isFilterSelected
        Animation.viewSlideInFromTopToBottom(views:self.filterView)
        if self.isFilterSelected  {
            hideToolbar(hide: true)
            self.filterView.isHidden = false
            self.filterViewButton.isHidden = false
            self.filterButton.setImage(#imageLiteral(resourceName: "image-effect-icon_selected"), for: .normal)
        }else {
            self.filterViewButton.isHidden = true
            hideToolbar(hide: false)
            self.filterView.isHidden = true
            self.filterButton.setImage(#imageLiteral(resourceName: "image-effect-icon"), for: .normal)
        }
    }
    @IBAction func btnFilterOptionSelected(_ sender: UIButton) {
        self.filterButton.setImage(#imageLiteral(resourceName: "image-effect-icon"), for: .normal)
        self.isFilterSelected = false
        self.filterViewButton.isHidden = true
        self.filterSliderView.isHidden = false
        self.filterButton.isHidden = true
        Animation.viewSlideInFromBottomToTop(views:self.filterSliderView)

        switch sender.tag {
        case 11:
          self.selectedItem = self.editingService.adjustmentItems[0]
          self.selectedItem?.reset()
          self.updateSliderForItem(item: self.selectedItem!)
          self.editingService.applyFilterImage(adjustmentItem:  self.selectedItem!)
            break
        case 22:
             self.selectedItem = self.editingService.adjustmentItems[1]
             self.selectedItem?.reset()
             self.updateSliderForItem(item: self.selectedItem!)
             self.editingService.applyFilterImage(adjustmentItem:self.selectedItem!)
            break
        case 33:
             self.selectedItem  = self.editingService.adjustmentItems[2]
             self.selectedItem?.reset()
             self.updateSliderForItem(item: self.selectedItem!)
             self.editingService.applyFilterImage(adjustmentItem:  self.selectedItem!)
            break
        case 44:
             self.selectedItem = self.editingService.adjustmentItems[3]
             self.selectedItem?.reset()
             self.updateSliderForItem(item: self.selectedItem!)
             self.editingService.applyFilterImage(adjustmentItem: self.selectedItem!)
            break
        default:
            break
        }
    }
    @IBAction func btnFilterOkPressed(_ sender: UIButton) {
        self.filterView.isHidden = true
        Animation.viewSlideInFromTopToBottom(views:self.filterSliderView)
        self.filterViewButton.isHidden = true
        self.filterSliderView.isHidden = true
        hideToolbar(hide: false)
        self.filterButton.setImage(#imageLiteral(resourceName: "image-effect-icon"), for: .normal)
        self.isFilterSelected = false
        self.canvasImageView.image = self.editingService.posterImage()
        self.editingService.setImage(image: self.canvasImageView.image!)
        self.filterButton.isHidden = false

    }
    @IBAction func btnFilterCancelPressed(_ sender: UIButton) {
        self.filterView.isHidden = true
        self.filterButton.isHidden = false
        Animation.viewSlideInFromTopToBottom(views:self.filterSliderView)
        self.filterViewButton.isHidden = true
        self.filterSliderView.isHidden = true
        hideToolbar(hide: false)
        self.filterButton.setImage(#imageLiteral(resourceName: "image-effect-icon"), for: .normal)
        self.isFilterSelected = false
        if self.selectedItem != nil {
            self.editingService.removeAllFilters()
            self.canvasImageView.image = self.editingService.modifiedImage
        }

    }
    
    
    //MAKR: helper methods
    
    func doneButtonAction(){
        view.endEditing(true)
        doneButton.isHidden = true
        colorPickerView.isHidden = true
        canvasImageView.isUserInteractionEnabled = true
        hideToolbar(hide: false)
        isDrawing = false
        self.colorsCollectionView.isHidden = true
        self.pencilView.isHidden = true
        self.isPencilSelected = false
        self.pencilButton.setImage(#imageLiteral(resourceName: "pen_icon_unactive"), for: .normal)
        Animation.viewSlideInFromTopToBottom(views:self.pencilView)
    }
    
  @objc func sliderValueChanged (_ slider : UISlider) {
        guard let item = self.selectedItem else { return }

        if (item.currentValue != slider.value)
        {
            item.currentValue = slider.value
            self.canvasImageView.image = self.editingService.applyFilterFor(adjustmentItem: item)
        }
    }

    @objc func image(_ image: UIImage, withPotentialError error: NSErrorPointer, contextInfo: UnsafeRawPointer) {
        self.showToast(type: .error, strMSG: "Image successfully saved to Photos library")
    }
    
    fileprivate func updateSliderForItem (item : PMEditingModel)
    {
        self.filterSlider.maximumValue = item.maxValue
        self.filterSlider.minimumValue = item.minValue
        self.filterSlider.value = item.currentValue
    }
    
    func hideControls() {
        
        for control in hiddenControls {
            switch control {
                
            case .clear:
                clearButton.isHidden = true
            case .crop:
                cropButton.isHidden = true
            case .draw:
                drawButton.isHidden = true
            case .save:
                saveButton.isHidden = true
            case .share:
                shareButton.isHidden = true
            case .sticker:
                stickerButton.isHidden = true
            case .text:
                stickerButton.isHidden = true
            }
        }
    }
    
}
