//
//  FilterViewController.swift
//  Emogo
//
//  Created by Pushpendra on 03/05/18.
//  Copyright © 2018 Vikas Goyal. All rights reserved.
//

import UIKit
import AVFoundation


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
    @IBOutlet weak var imageViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var gradientCollectionView: UICollectionView!
    @IBOutlet weak var gradientViewHeightConstraint: NSLayoutConstraint!

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
    var images = [GradientfilterDAO]()
    var filterManager :FilterManager!
    
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
        if self.images.count == 0 {
            HUDManager.sharedInstance.showHUD()
            self.perform(#selector(self.prepareFilter), with: self, afterDelay: 0.0)
        }
     
    }
    
    func prepareLayout(){
      //  filterCollectionView.register(UINib(nibName: "FilterCell", bundle: nil), forCellWithReuseIdentifier: "filterCell")
      //  filterCollectionView.register(UINib(nibName: "FilterGradientCell", bundle: nil), forCellWithReuseIdentifier: "filterGradientCell")
        filterSlider.addTarget(self, action: #selector(sliderValueChanged(_:)), for: .valueChanged)
        prepareNavigation()
        self.imageToFilter = self.image
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture))
        swipeRight.direction = UISwipeGestureRecognizerDirection.up
        self.canvasView.addGestureRecognizer(swipeRight)
        
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture))
        swipeLeft.direction = UISwipeGestureRecognizerDirection.down
        self.canvasView.addGestureRecognizer(swipeLeft)
        self.canvasView.isUserInteractionEnabled = true
    }
    
    
    func prepareNavigation() {
       
        self.navigationController?.isNavigationBarHidden = false
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.navigationBar.tintColor = .white
        self.navigationController?.navigationBar.barTintColor = UIColor.black.withAlphaComponent(0.3)
        let back = UIBarButtonItem(image: #imageLiteral(resourceName: "photo-edit-back"), style: .plain, target: self, action: #selector(self.actionforCancel))
        self.navigationItem.leftBarButtonItem = back
        let save = UIBarButtonItem(image:#imageLiteral(resourceName: "crrop_icon") , style: .plain, target: self, action: #selector(self.actionForCropButton))
        self.navigationItem.rightBarButtonItem = save
    }
    
    func setImageView(image: UIImage) {
        //imageView.image = image
        print(self.view.frame)
        self.canvasImageView.image = image
        let img = self.imageOrientation(self.canvasImageView.image!)
        let frame = AVMakeRect(aspectRatio: img.size, insideRect: self.canvasView.frame)
        self.imageViewHeightConstraint.constant = frame.size.height
    }
    
    @objc func prepareFilter(){
        if self.images.count == 0 {
            filterManager = FilterManager(image:self.imageToFilter!)
            self.images.removeAll()
            autoreleasepool {
                prepareGradientOption()
            }
        }
    }
    
    

    
    @objc func prepareGradientOption(){
        print(self.addFilterCount)
       let name = ApplyFilter.allValues[addFilterCount].rawValue
        
        self.filterManager.applyFilter(filterName: name) { (originalImage, previewImage) in
            
            let objImage = GradientfilterDAO(name: "\(ApplyFilter.allValues[self.addFilterCount])")
            objImage.imgOriginal = originalImage!
            objImage.imgPreview = previewImage!
            objImage.isFileRecieved  = true
            self.images.append(objImage)
            if self.addFilterCount != ApplyFilter.allValues.count-1 {
                self.addFilterCount += 1
                self.perform(#selector(self.prepareGradientOption), with: self, afterDelay: 0.0)
            //    self.prepareGradientOption()
            }else {
                HUDManager.sharedInstance.hideHUD()
            }
         }
    }
    
    @objc func respondToSwipeGesture(gesture: UIGestureRecognizer) {
        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
            switch swipeGesture.direction {
            case UISwipeGestureRecognizerDirection.up:
                print("Swie up")
                break
                
            case UISwipeGestureRecognizerDirection.down:
                print("Swie down")
                self.updateFilter(index: 222)
                break
            default:
                break
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

