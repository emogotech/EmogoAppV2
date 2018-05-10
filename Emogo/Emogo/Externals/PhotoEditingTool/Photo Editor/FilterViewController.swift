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
    func doneWithImage(resultImage:UIImage)
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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.prepareLayout()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.setImageView(image: image!)
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
        
        DispatchQueue.global(qos: .background).async {
            self.prepareGradientFilter()
        }
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
            prepareGradientImages(image: self.image!)
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
    
    func updateImageView(dict:[String:String]) {
        if let value = dict["value"] {
            
            let numbersRange = value.rangeOfCharacter(from: .decimalDigits)
            let hasNumbers = (numbersRange != nil)
            if value.contains(".png") {
                let frontImage = UIImage(named: value)
                imageGradientFilter = self.image?.mergedImageWith(frontImage: frontImage!)
                
            }else if hasNumbers {
                guard let imageBuffer = imageBuffer else {
                    return
                }
                imageGradientFilter = UIImage(imageBuffer: imageBuffer)
            }else {
                imageGradientFilter = self.image?.createFilteredImage(filterName: value)
            }
            if let image = imageGradientFilter {
                canvasImageView.image = image.resizeImage(targetSize:  CGSize(width: canvasView.frame.size.width, height: canvasImageView.frame.size.height))
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

        self.image = self.imageGradientFilter?.resize(targetSize: (self.imageToFilter?.size)!)
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
            self.prepareGradientImages(image: self.image!)
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
        DispatchQueue.global(qos: .background).async {
            self.prepareGradientImages(image: self.image!)
        }
    }
    
    
    func prepareGradientImages(image:UIImage){
        self.images.removeAll()
        for (index,obj) in self.filter.arrayFilters.enumerated() {
            if let value = (obj as! [String:String])["value"], let name = (obj as! [String:String])["name"] {
                
                    let numbersRange = value.rangeOfCharacter(from: .decimalDigits)
                    let hasNumbers = (numbersRange != nil)
                    if value.contains(".png") {
                        let frontImage = UIImage(named: value)
                        let filterImage = image.mergedImageWith(frontImage: frontImage!)
                        let filter = Filter(icon: filterImage, name: name)
                        self.images.append(filter)
                        
                    }else if hasNumbers {
                      
                        let filter = filters[index]
                        if let buffer = renderedFilterBuffer[filter.name] {
                            imageBuffer = buffer
                        }
                        if imageBuffer != nil {
                            let filterImage = UIImage(imageBuffer: imageBuffer!)
                            let filter = Filter(icon: filterImage!, name: name)
                            self.images.append(filter)
                        }
                       
                    }else {
                        let filterImage  = image.createFilteredImage(filterName: value)
                        let filter = Filter(icon: filterImage, name: name)
                        self.images.append(filter)
                }
            }
            print(self.images.count)
        }
        DispatchQueue.main.async {
            self.gradientCollectionView.reloadData()
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


