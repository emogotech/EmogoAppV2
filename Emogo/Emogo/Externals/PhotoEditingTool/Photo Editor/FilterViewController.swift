//
//  FilterViewController.swift
//  Emogo
//
//  Created by Pushpendra on 03/05/18.
//  Copyright © 2018 Vikas Goyal. All rights reserved.
//

import UIKit
import AVFoundation

protocol FilterViewControllerDelegate {
    func doneWithImage(resultImage:UIImage?)
}
class FilterViewController: UIViewController {
    
    @IBOutlet weak var filterCollectionView: UICollectionView!
    @IBOutlet weak var bottomGradient: GradientView!
    @IBOutlet weak var filterView: UIView!
    @IBOutlet weak var filterSliderView: UIView!
    @IBOutlet weak var filterViewButton: UIStackView!
    @IBOutlet weak var filterSlider: UISlider!
    @IBOutlet weak var gradientButton: UIButton!
    @IBOutlet weak var btnMLEffects: UIButton!
    @IBOutlet weak var filterButton: UIButton!
    @IBOutlet weak var clearButton: UIButton!
    @IBOutlet weak var canvasView: UIView!
    @IBOutlet weak var gradientImageView: UIImageView!
    @IBOutlet weak var canvasImageView: UIImageView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var gradientViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var gradientCollectionView: UICollectionView!
    @IBOutlet weak var gradientView: UIView!
    var addFilterCount = 0
    
    
    var selectedItem : PMEditingModel? = nil
    
    lazy var editingService : PMPhotoEditingManager = { [unowned self] in
        return PMPhotoEditingManager.create()
        } ()
    
    
    var filter = FilterDAO()
    var isGradientFilter:Bool! = false
    var isFilterSelected: Bool = false
    public var image: UIImage?
    var imageToFilter:UIImage?
    var imageGradientFilter:UIImage?
    var filterDelegate:FilterViewControllerDelegate?
    var images = [Filter]()
    
  
    var isLoaded:String? = nil
    let deviceName = UIDevice.current.modelName
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.prepareDummyDataForFilter()
        self.prepareLayout()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.hideStatusBar()
        self.navigationController?.navigationBar.isTranslucent = false
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.setImageView(image: image!)
    
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.navigationBar.setBackgroundImage(nil, for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = nil
    }
    func prepareLayout(){
        //  filterCollectionView.register(UINib(nibName: "FilterCell", bundle: nil), forCellWithReuseIdentifier: "filterCell")
        //  filterCollectionView.register(UINib(nibName: "FilterGradientCell", bundle: nil), forCellWithReuseIdentifier: "filterGradientCell")
        filterSlider.addTarget(self, action: #selector(sliderValueChanged(_:)), for: .valueChanged)
        prepareNavigation()
        self.imageToFilter = self.image
        self.imageViewHeightConstraint.constant = 0
        //        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture))
        //        swipeDown.direction = UISwipeGestureRecognizerDirection.down
        //        self.canvasView.addGestureRecognizer(swipeDown)
        
        
    }
    
    
    func prepareNavigation() {
        if self.navigationController?.isNavigationBarHidden == true {
            self.navigationController?.isNavigationBarHidden = false
            self.navigationController?.navigationBar.tintColor = .white
        }
      
    self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.barTintColor = .clear
        self.prepareNavigationButton(isEditing: false)
    }
    
    func prepareNavigationButton(isEditing:Bool) {
        self.navigationItem.rightBarButtonItem = nil
        self.navigationItem.leftBarButtonItem = nil
        navigationItem.hidesBackButton = true
        if isEditing {
            let btnSave = UIBarButtonItem(title: "Save", style: .plain, target: self, action: #selector(self.actionForSaveButton))
            let btnCancel = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(self.actionForCancelButton))
            self.navigationItem.leftBarButtonItem = btnCancel
            self.navigationItem.rightBarButtonItem = btnSave
        }else {
            let back = UIBarButtonItem(image: #imageLiteral(resourceName: "photo-edit-back"), style: .plain, target: self, action: #selector(self.actionforCancel))
            self.navigationItem.leftBarButtonItem = back
            let save = UIBarButtonItem(image:#imageLiteral(resourceName: "crrop_icon") , style: .plain, target: self, action: #selector(self.actionForCropButton))
            self.navigationItem.rightBarButtonItem = save
            
        }
        
    }
    
    func setImageView(image: UIImage) {
        //imageView.image = image
        self.canvasImageView.image = image
        let img = self.imageOrientation(self.canvasImageView.image!)
        let frame = AVMakeRect(aspectRatio: img.size, insideRect: self.canvasView.frame)
        self.imageViewHeightConstraint.constant = frame.size.height
        print(self.canvasView.frame)
    }
    
  
    func updateImageView(image:UIImage?, index:Int? = nil) {
        if let index = index {
            DispatchQueue.global(qos: .default).async {
                // Get Image
                let obj = self.images[index]
              
                let value:String = obj.key
                if value.contains(".png") {
                    if let frontImage = UIImage(named: value) {
                        let filterImage = self.image?.mergedImageWith(frontImage: frontImage)
                        obj.icon = filterImage
                        self.imageGradientFilter = filterImage
                        DispatchQueue.main.async(execute: {() -> Void in
                            self.images[index] = obj
                            if let image = self.imageGradientFilter {
                                self.canvasImageView.image = image
                            }
                        })
                    }
                } else {
                    let filterImage  = self.image?.createFilteredImage(filterName: value)
                    obj.icon = filterImage
                    self.imageGradientFilter = filterImage
                    DispatchQueue.main.async(execute: {() -> Void in
                            self.images[index] = obj
                        if let image = self.imageGradientFilter {
                            self.canvasImageView.image = image
                        }
                    })
                }
            }
        }
       
    }
    
    @objc func respondToSwipeGesture(gesture: UIGestureRecognizer) {
        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
            switch swipeGesture.direction {
            case UISwipeGestureRecognizerDirection.down:
                if self.isFilterSelected {
                    self.updateFilter(index: 222)
                }
                break
            default:
                break
            }
        }
        
    }
    
    @objc func actionForSaveButton() {
        if self.imageGradientFilter != nil {
            self.image = self.imageGradientFilter?.resize(targetSize: (self.imageToFilter?.size)!)
        }
        self.isFilterSelected = false
        self.prepareNavigationButton(isEditing: false)
        self.gradientViewHeightConstraint.constant = 0
        self.view.setNeedsUpdateConstraints()
        self.filterButton.isHidden = false
        self.gradientButton.isHidden = false
        self.btnMLEffects.isHidden = false
        self.filterViewButton.isHidden = true
        self.gradientImageView.isHidden = true
        self.gradientView.isHidden = true
        self.setImageView(image: self.image!)
        self.filterButton.setImage(#imageLiteral(resourceName: "image-effect-icon"), for: .normal)
        self.gradientButton.setImage(#imageLiteral(resourceName: "color_icon_inactive"), for: .normal)
        self.btnMLEffects.setImage(#imageLiteral(resourceName: "effect_icon_inactive"), for: .normal)
        self.imageGradientFilter = nil
        self.prepareDummyDataForFilter()
    }
    @objc func actionForCancelButton() {
        self.isFilterSelected = false
        self.prepareNavigationButton(isEditing: false)
        self.gradientViewHeightConstraint.constant = 0
        self.view.setNeedsUpdateConstraints()
        self.filterButton.isHidden = false
        self.gradientButton.isHidden = false
        self.filterViewButton.isHidden = true
        self.gradientImageView.isHidden = true
        self.gradientView.isHidden = true
        self.setImageView(image: self.image!)
        self.filterButton.setImage(#imageLiteral(resourceName: "image-effect-icon"), for: .normal)
        self.gradientButton.setImage(#imageLiteral(resourceName: "color_icon_inactive"), for: .normal)
        self.btnMLEffects.setImage(#imageLiteral(resourceName: "effect_icon_inactive"), for: .normal)
        self.imageGradientFilter = nil
        //        DispatchQueue.global(qos: .background).async {
        //            self.prepareGradientImages(image: self.image!)
        //        }
    }
    
    
    @objc func prepareDummyDataForFilter(){
                   self.images.removeAll()
                    DispatchQueue.global(qos: .background).async {
                        for obj in self.filter.arrayFilters {
                            if let value = obj["value"], let name = obj["name"] {
                                let filter = Filter(icon: nil, name: name)
                                filter.key = value
                                if value.contains(".png") {
                                    if let frontImage = UIImage(named: value) {
                                        let filterImage = self.image?.mergedImageWith(frontImage: frontImage)
                                        filter.icon = filterImage
                                    }
                                } else {
                                    let filterImage  = self.imageOrientation(self.image!).createFilteredImage(filterName: value)
                                    filter.icon = filterImage
                                }
                                
                                self.images.append(filter)
                            }
                        }
                        DispatchQueue.main.async {
                            self.gradientCollectionView.reloadData()
                        }
                    }
        
    }
    
    
    func prepareImageFor(obj: Filter,index:Int, completionHandler:@escaping (_ image: Filter?) -> ()) {
        
        DispatchQueue.global(qos: .background).async {
            // Get Image
            var objFilter:Filter?
            let value:String = obj.key
            if value.contains(".png") {
                if let frontImage = UIImage(named: value) {
                    let filterImage = self.image?.mergedImageWith(frontImage: frontImage)
                      objFilter = Filter(icon: filterImage, name: obj.iconName)
                      objFilter?.key = value
                    completionHandler(objFilter)
                }
            } else {
                let filterImage  = self.image?.createFilteredImage(filterName: value)
                 objFilter = Filter(icon: filterImage, name: obj.iconName)
                 objFilter?.key = value
                 completionHandler(objFilter)
            }
    }
 }
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}


