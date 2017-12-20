//
//  ImportViewController.swift
//  Emogo
//
//  Created by Pushpendra on 13/12/17.
//  Copyright © 2017 Vikas Goyal. All rights reserved.
//

/*

import UIKit
import Photos
import PhotosUI

private extension UICollectionView {
    func indexPathsForElements(in rect: CGRect) -> [IndexPath] {
        let allLayoutAttributes = collectionViewLayout.layoutAttributesForElements(in: rect)!
        return allLayoutAttributes.map { $0.indexPath }
    }
}


class ImportViewController: UIViewController {
    
    // MARK: - UI Elements
    @IBOutlet weak var importCollectionView: UICollectionView!

// MARK: - Variables
    
    var fetchResult: PHFetchResult<PHAsset>!
    
    fileprivate let imageManager = PHCachingImageManager()
    fileprivate var thumbnailSize: CGSize!
    fileprivate var previousPreheatRect = CGRect.zero
    

    // MARK: UIViewController / Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        resetCachedAssets()
        PHPhotoLibrary.shared().register(self)
        
        // If we get here without a segue, it's because we're visible at app launch,
        // so match the behavior of segue from the default "All Photos" view.
        if fetchResult == nil {
            let allPhotosOptions = PHFetchOptions()
            allPhotosOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
            fetchResult = PHAsset.fetchAssets(with: allPhotosOptions)
        }
        self.importCollectionView.reloadData()
    }
    
    deinit {
        PHPhotoLibrary.shared().unregisterChangeObserver(self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Determine the size of the thumbnails to request from the PHCachingImageManager
        let scale = UIScreen.main.scale
        
        let cellSize = (importCollectionView.collectionViewLayout as! UICollectionViewFlowLayout).itemSize
        thumbnailSize = CGSize(width: cellSize.width * scale, height: cellSize.height * scale)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        updateCachedAssets()
    }
    
   
    @IBAction func btnActionNext(_ sender: Any) {
        ContentList.sharedInstance.arrayContent.removeAll()
    }
    
    
    // MARK: UICollectionView
    
     func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return fetchResult.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let asset = fetchResult.object(at: indexPath.item)
        
        // Dequeue a GridViewCell.
 //       guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: GridViewCell.self), for: indexPath) as? GridViewCell
         //   else { fatalError("unexpected cell in collection view") }
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: kCell_ImportCell, for: indexPath) as! ImportCell

        // Request an image for the asset from the PHCachingImageManager.
        cell.representedAssetIdentifier = asset.localIdentifier
        if asset.mediaType == .video {
            cell.mediaType = "2"
        }else {
            cell.mediaType = "1"
        }
        imageManager.requestImage(for: asset, targetSize: thumbnailSize, contentMode: .aspectFill, options: nil, resultHandler: { image, _ in
            // The cell may have been recycled by the time this handler gets called;
            // set the cell's thumbnail image only if it's still showing the same asset.
            if cell.representedAssetIdentifier == asset.localIdentifier {
                cell.thumbnailImage = image
            }
        })
        
        return cell
        
    }
    
   
    // MARK: UIScrollView
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        updateCachedAssets()
    }
    
    // MARK: Asset Caching
    
    fileprivate func resetCachedAssets() {
        imageManager.stopCachingImagesForAllAssets()
        previousPreheatRect = .zero
    }
    
    fileprivate func updateCachedAssets() {
        // Update only if the view is visible.
        guard isViewLoaded && view.window != nil else { return }
        
        // The preheat window is twice the height of the visible rect.
        let visibleRect = CGRect(origin: importCollectionView.contentOffset, size: importCollectionView.bounds.size)
        let preheatRect = visibleRect.insetBy(dx: 0, dy: -0.5 * visibleRect.height)
        
        // Update only if the visible area is significantly different from the last preheated area.
        let delta = abs(preheatRect.midY - previousPreheatRect.midY)
        guard delta > view.bounds.height / 3 else { return }
        
        // Compute the assets to start caching and to stop caching.
        let (addedRects, removedRects) = differencesBetweenRects(previousPreheatRect, preheatRect)
        let addedAssets = addedRects
            .flatMap { rect in importCollectionView.indexPathsForElements(in: rect) }
            .map { indexPath in fetchResult.object(at: indexPath.item) }
        let removedAssets = removedRects
            .flatMap { rect in importCollectionView.indexPathsForElements(in: rect) }
            .map { indexPath in fetchResult.object(at: indexPath.item) }
        
        // Update the assets the PHCachingImageManager is caching.
        imageManager.startCachingImages(for: addedAssets,
                                        targetSize: thumbnailSize, contentMode: .aspectFill, options: nil)
        imageManager.stopCachingImages(for: removedAssets,
                                       targetSize: thumbnailSize, contentMode: .aspectFill, options: nil)
        
        // Store the preheat rect to compare against in the future.
        previousPreheatRect = preheatRect
    }
    
    fileprivate func differencesBetweenRects(_ old: CGRect, _ new: CGRect) -> (added: [CGRect], removed: [CGRect]) {
        if old.intersects(new) {
            var added = [CGRect]()
            if new.maxY > old.maxY {
                added += [CGRect(x: new.origin.x, y: old.maxY,
                                 width: new.width, height: new.maxY - old.maxY)]
            }
            if old.minY > new.minY {
                added += [CGRect(x: new.origin.x, y: new.minY,
                                 width: new.width, height: old.minY - new.minY)]
            }
            var removed = [CGRect]()
            if new.maxY < old.maxY {
                removed += [CGRect(x: new.origin.x, y: new.maxY,
                                   width: new.width, height: old.maxY - new.maxY)]
            }
            if old.minY < new.minY {
                removed += [CGRect(x: new.origin.x, y: old.minY,
                                   width: new.width, height: new.minY - old.minY)]
            }
            return (added, removed)
        } else {
            return ([new], [old])
        }
    }

}


// MARK: PHPhotoLibraryChangeObserver
extension ImportViewController: PHPhotoLibraryChangeObserver {
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        
        guard let changes = changeInstance.changeDetails(for: fetchResult)
            else { return }
        
        // Change notifications may be made on a background queue. Re-dispatch to the
        // main queue before acting on the change as we'll be updating the UI.
        DispatchQueue.main.sync {
            // Hang on to the new fetch result.
            fetchResult = changes.fetchResultAfterChanges
            if changes.hasIncrementalChanges {
                // If we have incremental diffs, animate them in the collection view.
                guard let collectionView = self.importCollectionView else { fatalError() }
                collectionView.performBatchUpdates({
                    // For indexes to make sense, updates must be in this order:
                    // delete, insert, reload, move
                    if let removed = changes.removedIndexes, removed.count > 0 {
                        collectionView.deleteItems(at: removed.map({ IndexPath(item: $0, section: 0) }))
                    }
                    if let inserted = changes.insertedIndexes, inserted.count > 0 {
                        collectionView.insertItems(at: inserted.map({ IndexPath(item: $0, section: 0) }))
                    }
                    if let changed = changes.changedIndexes, changed.count > 0 {
                        collectionView.reloadItems(at: changed.map({ IndexPath(item: $0, section: 0) }))
                    }
                    changes.enumerateMoves { fromIndex, toIndex in
                        collectionView.moveItem(at: IndexPath(item: fromIndex, section: 0),
                                                to: IndexPath(item: toIndex, section: 0))
                    }
                })
            } else {
                // Reload the collection view if incremental diffs are not available.
                importCollectionView.reloadData()
            }
            resetCachedAssets()
        }
    }
}

 */

import UIKit
import Photos
import PhotosUI

class ImportViewController: UIViewController {

    // MARK: - UI Elements
    @IBOutlet weak var importCollectionView: UICollectionView!

    // MARK: - Variables
    
    var arrayMedia:  PHFetchResult<PHAsset>!
    var arrayContent = [ContentDAO]()
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
        ContentList.sharedInstance.arrayContent.removeAll()
        
        for obj in self.arrayContent {
           if obj.isSelected {
                ContentList.sharedInstance.arrayContent.insert(obj, at: 0)
            }
        }
      
        if ContentList.sharedInstance.arrayContent.count != 0 {
            let objPreview:PreviewController = kStoryboardMain.instantiateViewController(withIdentifier: kStoryboardID_PreView) as! PreviewController
            objPreview.strPresented = "TRUE"
            let nav = UINavigationController(rootViewController: objPreview)
            self.parent?.present(nav, animated: true, completion: nil)
        }
        
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
        
        DispatchQueue.main.async { // Correct
            for i in 0 ..< self.arrayMedia.count {
                group.enter()
                let asset = self.arrayMedia!.object(at: i)
                if asset.mediaType == .video {
                    self.getVideoURL(asset: asset, handler: { (url, image) in
                        if let url = url, let img = image {
                            let obj = ContentDAO(contentData: [:])
                            obj.type = .video
                            obj.imgPreview = img
                            obj.fileUrl = url
                            if let file =  asset.value(forKey: "filename"){
                                obj.fileName = file as! String
                            }
                            self.arrayContent.append(obj)
                        }
                        
                        group.leave()
                    })
                }else {
                    self.getOrigianlImage(asset: asset, handler: { (image) in
                        if  let img = image {
                            let obj = ContentDAO(contentData: [:])
                            obj.type = .image
                            obj.imgPreview = img
                            if let file =  asset.value(forKey: "filename"){
                                obj.fileName = file as! String
                            }
                            self.arrayContent.append(obj)
                        }
                        group.leave()
                    })
                }
                
            }
            
        }
        
      
            /*
            
            PHImageManager.default().requestImage(for: asset, targetSize: size, contentMode: PHImageContentMode.aspectFill, options: requestOptions) { (image, userInfo) -> Void in
                if image != nil {
                    print (i)
                    var obj:ContentDAO!
                    if asset.mediaType == .video {
                        obj = ContentDAO(contentData: [:])
                        obj.type = .video
                        obj.imgPreview = image
                    }else if  asset.mediaType == .image {
                        obj = ContentDAO(contentData: [:])
                        obj.type = .image
                        obj.imgPreview = image
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
        */
        group.notify(queue: .main, execute: {
            self.importCollectionView.reloadData()
        })
        // Image
        print( self.arrayContent.count)
    }
  
    func getVideoURL(asset:PHAsset,handler:@escaping (_ tempURL:URL?,_ image:UIImage?)->Void){
      
        let options = PHVideoRequestOptions()
        options.version = .original
        PHImageManager.default().requestAVAsset(forVideo: asset, options: options) { (asset, _, _) in
            
            if let urlAsset = asset as? AVURLAsset {
                if let image = SharedData.sharedInstance.getThumbnailImage(url: urlAsset.url) {
                    handler(urlAsset.url,image)
                }
            } else {
                handler( nil, nil)
            }
        }
        
    }
    
    func getOrigianlImage(asset:PHAsset,handler:@escaping (_ image:UIImage?)->Void){
        let options = PHImageRequestOptions()
        options.isSynchronous = true
        options.resizeMode = .exact
        options.isNetworkAccessAllowed = true
        PHImageManager.default().requestImage(for: asset, targetSize: self.view.bounds.size, contentMode: PHImageContentMode.aspectFill, options: options) { (image, userInfo) -> Void in
            handler(image)
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


