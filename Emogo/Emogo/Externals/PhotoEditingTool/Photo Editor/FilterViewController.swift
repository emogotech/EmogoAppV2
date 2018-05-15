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
    
    
    let filters: [PMFilter] = [
        MosaicFilter(),
        TheScreamFilter(),
        LaMuseFilter(),
        UdnieFilter(),
        CandyFilter(),
        FeathersFilter(),
        ]
    
    var renderedFilterBuffer: [String: ImageBuffer] = [:]
    var imageBuffer: ImageBuffer?
    var isLoaded:String? = nil
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.prepareLayout()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    
        self.setImageView(image: image!)
        if isLoaded != nil {
            isLoaded = nil
            self.perform(#selector(self.prepareDummyDataForFilter), with: self, afterDelay: 0.2)

        }
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
        
        self.navigationController?.isNavigationBarHidden = false
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.navigationBar.tintColor = .white
        self.navigationController?.navigationBar.barTintColor = UIColor.black.withAlphaComponent(0.3)
        self.prepareNavigationButton(isEditing: false)
    }
    
    func prepareNavigationButton(isEditing:Bool) {
        self.navigationItem.rightBarButtonItem = nil
        self.navigationItem.leftBarButtonItem = nil
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
    
    func prepareGradientFilter(){
        if let image = self.imageToFilter {
            let resizedImage = image.resize(to: CGSize(width: 720, height: 720))
            imageBuffer = resizedImage.buffer()
            loadRenderedImages()
        }
    }
    
    private func loadRenderedImages() {
        renderedFilterBuffer.removeAll()
        guard let buffer = imageBuffer else {
            return
        }
        filters.forEach { (filter) in
            if let filteredBuffer = filter.render(from: buffer) {
                renderedFilterBuffer[filter.name] = filteredBuffer
            }
        }
    }
    
    func updateImageView(image:UIImage?) {
        imageGradientFilter = image
        if let image = imageGradientFilter {
            canvasImageView.image = image
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
        self.filterViewButton.isHidden = true
        self.gradientImageView.isHidden = true
        self.gradientView.isHidden = true
        self.setImageView(image: self.image!)
        self.filterButton.setImage(#imageLiteral(resourceName: "image-effect-icon"), for: .normal)
        self.gradientButton.setImage(#imageLiteral(resourceName: "color_icon_inactive"), for: .normal)
        self.imageGradientFilter = nil
        DispatchQueue.global(qos: .background).async {
            self.prepareDummyDataForFilter()
        }
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
                                self.images.append(filter)
                            }
                        }
                        self.prepareGradientFilter()
                        DispatchQueue.main.async {
                            self.gradientCollectionView.reloadData()
                        }
                    }
    }
    
    func prepareImageFor(index:Int,cell:GradientFilterCell) {
        
        weak var weakCell: GradientFilterCell? = cell
        let obj = self.images[index]
        let value:String = obj.key
        let numbersRange = value.rangeOfCharacter(from: .decimalDigits)
        let hasNumbers = (numbersRange != nil)
        if !value.contains(".png") &&  hasNumbers {
            let filter = self.filters[index]
            print("Core Ml Images")
            if let buffer = self.renderedFilterBuffer[filter.name] {
                self.imageBuffer = buffer
            }
            FilterManager.sharedInstance.imageFor(obj: obj, buffer: self.imageBuffer, image: self.image!) { (filterResult) in
                if let filter = filterResult {
                    weakCell?.imgPreview.image = filter.icon
                }
                
            }
            
        }else {
            FilterManager.sharedInstance.imageFor(obj: obj, buffer: nil, image: self.image!) { (filterResult) in
                if let filter = filterResult {
                    weakCell?.imgPreview.image = filter.icon
                }
            }
        }
        
        
        /*
        // Async
        DispatchQueue.global(qos: .default).async {
            // Get Image
            let obj = self.images[index]
//            if obj.icon != nil  {
//                return
//            }
            let value:String = obj.key
            let numbersRange = value.rangeOfCharacter(from: .decimalDigits)
            let hasNumbers = (numbersRange != nil)
            if value.contains(".png") {
              
               
            }else if hasNumbers {
                
                let filter = self.filters[index]
                print("Core Ml Images")
                if let buffer = self.renderedFilterBuffer[filter.name] {
                    self.imageBuffer = buffer
                }
               
                
            }else {
                let filterImage  = self.image?.createFilteredImage(filterName: value)
                obj.icon = filterImage
                if  self.images[index].key == value {
                    self.images[index] = obj
                }
            }
           
        DispatchQueue.main.async(execute: {() -> Void in
            weakCell?.imgPreview.image = self.images[index].icon
           // weakCell?.setup(filter: self.images[index] )
        })
    }
 */
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


