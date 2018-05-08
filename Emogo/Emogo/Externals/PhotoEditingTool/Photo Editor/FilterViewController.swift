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
    @IBOutlet weak var gradientView: UIView!

    
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
    var filterManager = FilterManager()
    
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
        for name in  ApplyFilter.allValues {
            let obj = GradientfilterDAO(name: "\(name)")
            images.append(obj)
        }
        
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
        self.canvasImageView.image = image
        let img = self.imageOrientation(self.canvasImageView.image!)
        self.canvasView.frame = AVMakeRect(aspectRatio: img.size, insideRect: self.canvasImageView.frame)
        self.canvasView.center = self.view.center
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

