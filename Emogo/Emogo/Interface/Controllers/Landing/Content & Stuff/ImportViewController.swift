//
//  ImportViewController.swift
//  Emogo
//
//  Created by Pushpendra on 13/12/17.
//  Copyright © 2017 Vikas Goyal. All rights reserved.
//

import UIKit
import Photos

class ImportViewController: UIViewController {

    // MARK: - UI Elements
    @IBOutlet weak var importCollectionView: UICollectionView!

    // MARK: - Variables
    
    var arrayMedia:  PHFetchResult<PHAsset>!
    var arrayContent = [ImageDAO]()
    // MARK: - Override Functions
   
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.prepareLayouts()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func prepareLayouts(){
        self.importCollectionView.dataSource  = self
        self.importCollectionView.delegate = self
        
        // Create a waterfall layout
        let layout = CHTCollectionViewWaterfallLayout()
        
        // Change individual layout attributes for the spacing between cells
        layout.minimumColumnSpacing = 3.0
        layout.minimumInteritemSpacing = 3.0
        layout.columnCount = 4
        // Collection view attributes
        self.importCollectionView.autoresizingMask = [UIViewAutoresizing.flexibleHeight, UIViewAutoresizing.flexibleWidth]
        self.importCollectionView.alwaysBounceVertical = true
        
        // Add the waterfall layout to your collection view
        self.importCollectionView.collectionViewLayout = layout
        
         self.checkPhotoLibraryPermission()
    }
    
    @IBAction func btnActionNext(_ sender: Any) {
        
    }
    
    func checkPhotoLibraryPermission() {
        let status = PHPhotoLibrary.authorizationStatus()
        switch status {
        case .authorized:
            //handle authorized status
            self.getAssetForAll()
            break
        case .denied, .restricted :
        //handle denied status
            break
        case .notDetermined:
            // ask for permissions
            PHPhotoLibrary.requestAuthorization() { status in
                switch status {
                case .authorized:
                // as above
                    self.getAssetForAll()
                    break
                case .denied, .restricted:
                // as above
                    break
                case .notDetermined:
                    // won't happen but still
                    break
                }
            }
        }
    }
    
    
    
    func getAssetForAll() {
        let options = PHFetchOptions()
        options.sortDescriptors = [ NSSortDescriptor(key: "creationDate", ascending: false) ]
        options.predicate = NSPredicate(format: "mediaType == %d || mediaType == %d",
                                        PHAssetMediaType.image.rawValue,
                                        PHAssetMediaType.video.rawValue)
        arrayMedia = PHAsset.fetchAssets(with: options)
        print( self.arrayMedia)

        let group = DispatchGroup()
        
        let requestOptions = PHImageRequestOptions()
        requestOptions.deliveryMode = PHImageRequestOptionsDeliveryMode.fastFormat
        requestOptions.isSynchronous = false
        requestOptions.isNetworkAccessAllowed = true
        
        for i in 0 ..< self.arrayMedia.count {
            group.enter()
            let asset = arrayMedia!.object(at: i)
            let size = CGSize(
                width: asset.pixelWidth,
                height: asset.pixelHeight
            )
            PHImageManager.default().requestImage(for: asset, targetSize: size, contentMode: PHImageContentMode.aspectFill, options: requestOptions) { (image, userInfo) -> Void in
                if image != nil {
                    print (i)
                    var obj:ImageDAO!
                    if asset.mediaType == .video {
                        obj = ImageDAO(type: .video, image: image!)
                    }else if  asset.mediaType == .image {
                        obj = ImageDAO(type: .image, image: image!)
                    }
                    if obj != nil {
                        if let file =  asset.value(forKey: "filename"){
                            obj.fileName = file as! String
                        }
                        self.arrayContent.append(obj)
                    }
                }
                group.leave()
            }
        }
        
        group.notify(queue: .main, execute: {
            self.importCollectionView.reloadData()
        })
        // Image
        print( self.arrayContent.count)
    }
  
  
    func getVideoURL(){
        let options = PHVideoRequestOptions()
        options.deliveryMode = PHVideoRequestOptionsDeliveryMode.fastFormat
        options.isNetworkAccessAllowed = true
        options.progressHandler = {  (progress, error, stop, info) in
            print("progress: \(progress)")
        }
        let asset = arrayMedia!.object(at: 0)
        guard (asset.mediaType == .video) else {
            print("not valid video type")
            return
        }
        
        // Video URL
        PHCachingImageManager().requestAVAsset(forVideo: asset, options: options) { (asset, audioMix, args) in
            let asset = asset as! AVURLAsset
            
            if (asset == nil){
                print ("this gon crash")
            }
            else{
                DispatchQueue.main.async {
                    print(asset.url)
        }
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


extension ImportViewController:UICollectionViewDelegate,UICollectionViewDataSource,CHTCollectionViewDelegateWaterfallLayout {
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrayContent.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // Create the cell and return the cell
        let content = arrayContent[indexPath.row]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: kCell_ImportCell, for: indexPath) as! ImportCell
        // for Add Content
        cell.layer.cornerRadius = 5.0
        cell.layer.masksToBounds = true
        cell.isExclusiveTouch = true
        cell.prepareLayout(content:content)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: IndexPath) -> CGSize {
        let itemWidth = collectionView.bounds.size.width/2.0
        return CGSize(width: itemWidth, height: itemWidth)
    }
    
   
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let content = arrayContent[indexPath.row]
        content.isSelected = !content.isSelected
        arrayContent[indexPath.row] = content
        self.importCollectionView.reloadData()
    }
    
}



