//
//  ViewStreamController.swift
//  Emogo
//
//  Created by Pushpendra on 13/12/17.
//  Copyright © 2017 Vikas Goyal. All rights reserved.
//

import UIKit

class ViewStreamController: UIViewController {
    
    // MARK: - UI Elements
    @IBOutlet weak var viewStreamCollectionView: UICollectionView!
    
    // Varibales
    private let headerNib = UINib(nibName: "StreamViewHeader", bundle: Bundle.main)
    var stream:StreamDAO!
    var objStream:StreamViewDAO?
    // MARK: - Override Functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.prepareLayouts()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.title = self.stream.Title.trim().capitalized
        self.configureNavigationWithTitle()
        
    }
    // MARK: - Prepare Layouts
    func prepareLayouts(){
       
        // Attach datasource and delegate
        
        self.viewStreamCollectionView.dataSource  = self
        self.viewStreamCollectionView.delegate = self

        if let layout: IOStickyHeaderFlowLayout = self.viewStreamCollectionView.collectionViewLayout as? IOStickyHeaderFlowLayout {
            layout.parallaxHeaderReferenceSize = CGSize(width: UIScreen.main.bounds.size.width, height: 200.0)
            layout.parallaxHeaderMinimumReferenceSize = CGSize(width: UIScreen.main.bounds.size.width, height: 0)
            layout.itemSize = CGSize(width: UIScreen.main.bounds.size.width, height: layout.itemSize.height)
            layout.parallaxHeaderAlwaysOnTop = false
            layout.disableStickyHeaders = true
            self.viewStreamCollectionView.collectionViewLayout = layout
        }
        viewStreamCollectionView.alwaysBounceVertical = true
        self.viewStreamCollectionView.register(self.headerNib, forSupplementaryViewOfKind: IOStickyHeaderParallaxHeader, withReuseIdentifier: kHeader_ViewStreamHeaderView)
            self.getStream()
    }
    
    // MARK: -  Action Methods And Selector
    @objc func deleteStreamAction(sender:UIButton){
        
        APIServiceManager.sharedInstance.apiForDeleteStream(streamID: (objStream?.streamID)!) { (isSuccess, errorMsg) in
            if (errorMsg?.isEmpty)! {
                
                if let i = StreamList.sharedInstance.arrayStream.index(where: { $0.ID.trim() == self.stream.ID.trim() }) {
                    StreamList.sharedInstance.arrayStream.remove(at: i)
                }
                self.navigationController?.pop()
            }else {
                self.showToast(type: .success, strMSG: errorMsg!)
            }
        }
    }
    
   @objc func editStreamAction(sender:UIButton){
        
    }

    // MARK: - Class Methods

    
    // MARK: - API Methods

    func getStream(){
        HUDManager.sharedInstance.showHUD()
        APIServiceManager.sharedInstance.apiForViewStream(streamID: self.stream.ID) { (stream, errorMsg) in
            HUDManager.sharedInstance.hideHUD()
            if (errorMsg?.isEmpty)! {
                self.objStream = stream
                self.viewStreamCollectionView.reloadData()
            }else {
                self.showToast(type: .success, strMSG: errorMsg!)
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



extension ViewStreamController:UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if objStream != nil {
            return objStream!.arrayContent.count
        }else {
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // Create the cell and return the cell
         let content = objStream?.arrayContent[indexPath.row]
         let cell = collectionView.dequeueReusableCell(withReuseIdentifier: kCell_StreamContentCell, for: indexPath) as! StreamContentCell
        // for Add Content
        cell.layer.cornerRadius = 5.0
        cell.layer.masksToBounds = true
        cell.isExclusiveTouch = true
        cell.prepareLayout(content:content!)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let content = objStream?.arrayContent[indexPath.row]
         let itemWidth = collectionView.bounds.size.width/2.0 - 12.0
        if content?.isAdd == true {
            return CGSize(width: itemWidth, height: 110)
        }else{
            return CGSize(width: itemWidth, height: itemWidth)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let cell = UICollectionReusableView()
        switch kind {
        case IOStickyHeaderParallaxHeader:
            let  view:StreamViewHeader = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: kHeader_ViewStreamHeaderView, for: indexPath) as! StreamViewHeader
            view.btnDelete.addTarget(self, action: #selector(self.deleteStreamAction(sender:)), for: .touchUpInside)
            view.btnEdit.addTarget(self, action: #selector(self.editStreamAction(sender:)), for: .touchUpInside)
            view.prepareLayout(stream:self.objStream)
            return view
        default:
            assert(false, "Unexpected element kind")
        }
        return cell
    }
   
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let content = objStream?.arrayContent[indexPath.row]
        if content?.isAdd == true {
            let obj:CameraViewController = self.storyboard?.instantiateViewController(withIdentifier: kStoryboardID_CameraView) as! CameraViewController
            self.navigationController?.push(viewController: obj)
        }else {
            SharedData.sharedInstance.downloadFile(strURl: (content?.coverImage)!, handler: { (image, type) in
                
            })
            /*
            var image = UIImage(named: "")
            if content?.type == "Picture" {
            }else {
                
            }
            GalleryDAO.sharedInstance.streamID = objStream?.streamID
            let objImage = ImageDAO(type: .image, image: image!)
            objImage.title = content?.name
            objImage.description = content?.description
            objImage.fileName = content?.coverImage.getName()
            GalleryDAO.sharedInstance.Images.removeAll()
            GalleryDAO.sharedInstance.Images.append(objImage)
            let objPreview:PreviewController = self.storyboard?.instantiateViewController(withIdentifier: kStoryboardID_PreView) as! PreviewController
            self.navigationController?.pushNormal(viewController: objPreview)
 */
         
        }
    }
    
}
