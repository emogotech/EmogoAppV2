//
//  FilterViewController+Controls.swift
//  ImageEditing
//
//  Created by Pushpendra on 02/05/18.
//  Copyright © 2018 Pushpendra. All rights reserved.
//

import Foundation
import UIKit
import CropViewController


extension FilterViewController {
    

    @IBAction func clearButtonTapped(_ sender: AnyObject) {
        //clear drawing
        self.setImageView(image: self.imageToFilter!)
    }
    
    @IBAction func continueButtonPressed(_ sender: Any) {
        if filterDelegate != nil  {
            self.filterDelegate?.doneWithImage(resultImage: self.canvasImageView.image!)
        }
        self.navigationController?.popNormal()
    }
    
    @IBAction func btnFilterPressed(_ sender: UIButton) {
       self.updateFilter(index: sender.tag)
    }
    
    func updateFilter(index:Int) {
         self.isFilterSelected = !self.isFilterSelected
        switch index {
        case 111:
            isGradientFilter = false
            self.gradientButton.setImage(#imageLiteral(resourceName: "color_icon_inactive"), for: .normal)
            filterOptionUpdated()
            break
        case 222:
            
            isGradientFilter = true
            self.gradientButton.setImage(#imageLiteral(resourceName: "color_icon_active"), for: .normal)
            filterOptionUpdated()
            break
        case 333:
            self.btnMLEffects.isHidden = false
            let obj:MLFiltersViewController = kStoryboardPhotoEditor.instantiateViewController(withIdentifier: kStoryboardID_MLFiltersView) as! MLFiltersViewController
            obj.image = self.canvasImageView.image
            obj.delegate = self
            let nav  = UINavigationController(rootViewController: obj)
            self.present(nav, animated: false, completion: nil)
            break
        default:
            break
        }
    }
    
    @objc func actionforCancel(){
        self.navigationController?.popNormal()
    }
    
    @objc func actionForCropButton(){
        let croppingStyle = CropViewCroppingStyle.default
        let cropController = CropViewController(croppingStyle: croppingStyle, image: canvasImageView.image!)
        cropController.delegate = self
        present(cropController, animated: true, completion: nil)
    }
    
    func filterOptionUpdated(){
        if isGradientFilter{
            gradientOptionUpdated()
        }else {
            Animation.viewSlideInFromTopToBottom(views:self.filterView)
            if self.isFilterSelected  {
                self.filterCollectionView.reloadData()
                self.gradientButton.isHidden = true
                self.btnMLEffects.isHidden = true
                let img = self.imageOrientation(self.image!)
                editingService.setImage (image: img)
                self.filterView.isHidden = false
                self.filterViewButton.isHidden = false
                self.filterButton.setImage(#imageLiteral(resourceName: "image-effect-icon_selected"), for: .normal)
            }else {
                self.filterViewButton.isHidden = true
                self.gradientButton.isHidden = false
                self.btnMLEffects.isHidden = false
                self.filterView.isHidden = true
                self.filterButton.setImage(#imageLiteral(resourceName: "image-effect-icon"), for: .normal)
            }
        }
        
    }
    
    func gradientOptionUpdated(){
        
        self.gradientCollectionView.reloadData()
        Animation.viewSlideInFromTopToBottom(views:self.gradientView)
        if self.isFilterSelected  {
            self.prepareNavigationButton(isEditing: true)
            self.gradientViewHeightConstraint.constant = 170
            self.view.setNeedsUpdateConstraints()
            self.filterButton.isHidden = false
            self.btnMLEffects.isHidden = true
            self.gradientButton.isHidden = true
            let img = self.imageOrientation(self.image!)
            editingService.setImage (image: img)
            self.gradientView.isHidden = false
            self.filterViewButton.isHidden = false
            self.setImageView(image: img)
            let imgIcon = #imageLiteral(resourceName: "color_icon_active") //UIImage(named: "filterMenuItem_icon.png")
            self.filterButton.setImage(imgIcon, for: .normal)

        }else {
            self.prepareNavigationButton(isEditing: false)
            self.gradientViewHeightConstraint.constant = 0
            self.view.setNeedsUpdateConstraints()
            self.filterButton.isHidden = false
            self.gradientButton.isHidden = false
            self.filterViewButton.isHidden = true
            self.gradientImageView.isHidden = true
            self.btnMLEffects.isHidden = false
            self.gradientView.isHidden = true
            self.setImageView(image: self.image!)
            self.filterButton.setImage(#imageLiteral(resourceName: "image-effect-icon"), for: .normal)
        }
    }
    
    func btnFilterOptionSelected(index: Int) {
        self.filterButton.setImage(#imageLiteral(resourceName: "image-effect-icon"), for: .normal)
        self.isFilterSelected = false
        self.filterViewButton.isHidden = true
        self.filterSliderView.isHidden = false
        self.bottomGradient.isHidden = true
        Animation.viewSlideInFromBottomToTop(views:self.filterSliderView)
        
        if self.isGradientFilter {
            self.selectedItem = self.editingService.adjustmentItems[index]
            self.selectedItem?.reset()
            self.selectedItem?.minValue = 0
            self.updateSliderForItem(item: self.selectedItem!)
            self.gradientImageView.isHidden = false
            self.gradientImageView.alpha = 0.0
        }else {
            switch index {
            case 0:
                self.selectedItem = self.editingService.adjustmentItems[0]
                self.selectedItem?.reset()
                self.updateSliderForItem(item: self.selectedItem!)
                self.editingService.applyFilterImage(adjustmentItem:  self.selectedItem!)
                break
            case 1:
                self.selectedItem = self.editingService.adjustmentItems[1]
                self.selectedItem?.reset()
                self.updateSliderForItem(item: self.selectedItem!)
                self.editingService.applyFilterImage(adjustmentItem:self.selectedItem!)
                break
            case 2:
                self.selectedItem  = self.editingService.adjustmentItems[2]
                self.selectedItem?.reset()
                self.updateSliderForItem(item: self.selectedItem!)
                self.editingService.applyFilterImage(adjustmentItem:  self.selectedItem!)
                break
            case 3:
                self.selectedItem = self.editingService.adjustmentItems[3]
                self.selectedItem?.reset()
                self.updateSliderForItem(item: self.selectedItem!)
                self.editingService.applyFilterImage(adjustmentItem: self.selectedItem!)
                break
            case 4:
                self.selectedItem = self.editingService.adjustmentItems[4]
                self.selectedItem?.reset()
                self.updateSliderForItem(item: self.selectedItem!)
                self.editingService.applyFilterImage(adjustmentItem: self.selectedItem!)
                break
            case 5:
                self.selectedItem = self.editingService.adjustmentItems[5]
                self.selectedItem?.reset()
                self.updateSliderForItem(item: self.selectedItem!)
                self.editingService.applyFilterImage(adjustmentItem: self.selectedItem!)
                break
            case 6:
                self.selectedItem = self.editingService.adjustmentItems[6]
                self.selectedItem?.reset()
                self.updateSliderForItem(item: self.selectedItem!)
                self.editingService.applyFilterImage(adjustmentItem: self.selectedItem!)
                break
                
            default:
                break
            }
        }
        
    }
    @IBAction func btnFilterOkPressed(_ sender: UIButton) {
        self.filterView.isHidden = true
        self.gradientButton.isHidden = false
        self.bottomGradient.isHidden = false
        Animation.viewSlideInFromTopToBottom(views:self.filterSliderView)
        self.filterViewButton.isHidden = true
        self.filterSliderView.isHidden = true
        self.filterButton.setImage(#imageLiteral(resourceName: "image-effect-icon"), for: .normal)
        self.isFilterSelected = false
        if self.isGradientFilter {
            self.canvasImageView.image = self.canvasView.toImage()
            self.editingService.ciContext = nil
            self.gradientButton.setImage(#imageLiteral(resourceName: "color_icon_inactive"), for: .normal)
        }else {
            self.image  = self.editingService.posterImage()
            self.canvasImageView.image =  self.image
            /// self.canvasImageView.image = self.canvasView.toImage()
        }
        self.gradientImageView.isHidden = true
        self.editingService.setImage(image: self.image!)
        
    }
    @IBAction func btnFilterCancelPressed(_ sender: UIButton) {
        self.gradientButton.setImage(#imageLiteral(resourceName: "color_icon_inactive"), for: .normal)
        self.filterView.isHidden = true
        self.gradientButton.isHidden = false
        Animation.viewSlideInFromTopToBottom(views:self.filterSliderView)
        self.filterViewButton.isHidden = true
        self.filterSliderView.isHidden = true
        self.gradientImageView.isHidden = true
        self.filterButton.setImage(#imageLiteral(resourceName: "image-effect-icon"), for: .normal)
        self.bottomGradient.isHidden = false
        self.isFilterSelected = false
        if self.selectedItem != nil {
            self.editingService.removeAllFilters()
            self.canvasImageView.image = self.editingService.modifiedImage
        }
        
    }
    
    @objc func sliderValueChanged (_ slider : UISlider) {
        
        guard let item = self.selectedItem else { return }
        
        if (item.currentValue != slider.value)
        {
            item.currentValue = slider.value
            if self.isGradientFilter {
                self.gradientImageView.alpha = CGFloat(item.currentValue / 100.0)
            }else {
                self.canvasImageView.image =  self.editingService.applyFilterFor(adjustmentItem: item)
            }
        }
    }
    
    fileprivate func updateSliderForItem (item : PMEditingModel){
        self.filterSlider.maximumValue = item.maxValue
        self.filterSlider.minimumValue = item.minValue
        self.filterSlider.value = item.currentValue
    }
    

}

extension FilterViewController:MLFiltersViewControllerDelegate {
    func selected(image: UIImage) {
        self.image  = image
        self.canvasImageView.image =  self.image
        self.isFilterSelected = false
    }
    
}
