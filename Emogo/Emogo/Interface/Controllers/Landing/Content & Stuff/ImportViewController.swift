//
//  ImportViewController.swift
//  Emogo
//
//  Created by Pushpendra on 13/12/17.
//  Copyright © 2017 Vikas Goyal. All rights reserved.
//

import UIKit
import Photos
import PhotosUI
import Lightbox

private extension UICollectionView {
    func indexPathsForElements(in rect: CGRect) -> [IndexPath] {
        let allLayoutAttributes = collectionViewLayout.layoutAttributesForElements(in: rect)!
        return allLayoutAttributes.map { $0.indexPath }
    }
}

class ImportViewController: UICollectionViewController , UICollectionViewDelegateFlowLayout{
    
    var fetchResult: PHFetchResult<PHAsset>!
    
    fileprivate let imageManager = PHCachingImageManager()
    fileprivate var thumbnailSize: CGSize!
    fileprivate var previousPreheatRect = CGRect.zero
    
    var arraySelected = [ImportDAO]()
    
    // MARK: UIViewController / Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        resetCachedAssets()
        PHPhotoLibrary.shared().register(self)
        
        // If we get here without a segue, it's because we're visible at app launch,
        // so match the behavior of segue from the default "All Photos" view.
        if fetchResult == nil {
            let allPhotosOptions = PHFetchOptions()
            let options = PHFetchOptions()
            options.sortDescriptors = [ NSSortDescriptor(key: "creationDate", ascending: false) ]
            options.predicate = NSPredicate(format: "mediaType == %d || mediaType == %d",
                                            PHAssetMediaType.image.rawValue,
                                            PHAssetMediaType.video.rawValue)
            
            fetchResult = PHAsset.fetchAssets(with: allPhotosOptions)
           
                let array = arrayAssests
                for i in 0..<fetchResult.count {
                    let asset = fetchResult.object(at: i)
                    let obj = ImportDAO(id:asset.localIdentifier,isSelected:false)
                    obj.assest = asset
                    if let file =  asset.value(forKey: "filename"){
                        obj.name = file as! String
                    }
                    if array?.count != 0 {
                        if let index =  array?.index(where: {$0.assest.localIdentifier == obj.assest.localIdentifier}) {
                            if array![index].isSelected == true {
                                obj.isSelected = true
                            }
                        }
                    }
                    arraySelected.append(obj)
                }
            
        }
    }
    
    deinit {
        PHPhotoLibrary.shared().unregisterChangeObserver(self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Determine the size of the thumbnails to request from the PHCachingImageManager
        let scale = UIScreen.main.scale
        let cellSize = (collectionViewLayout as! UICollectionViewFlowLayout).itemSize
        thumbnailSize = CGSize(width: cellSize.width * scale, height: cellSize.height * scale)
       
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        updateCachedAssets()
    }
    
    
    @objc func btnPlayAction(sender:UIButton){
        self.openFullView(index: sender.tag)
    }
    
    // MARK: - Class Methods
    func openFullView(index:Int){
        let asset = fetchResult.object(at: index)
        asset.getURL { (url) in
            if let url = url {
                    let obj = LightboxImage(image: #imageLiteral(resourceName: "stream-card-placeholder"), text: "", videoURL: url)
                DispatchQueue.main.async {
                    self.presentPlayer(array: [obj])
                }
            }
        }
    }
    
    func presentPlayer(array:[LightboxImage]){
        let controller = LightboxController(images: array, startIndex: 0)
        controller.dynamicBackground = true
        if array.count != 0 {
            self.parent?.present(controller, animated: true, completion: nil)
        }
    }
    
    // MARK: UICollectionView
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return fetchResult.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let asset = fetchResult.object(at: indexPath.item)
         let imp = arraySelected[indexPath.item]
        // Dequeue a GridViewCell.
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: GridViewCell.self), for: indexPath) as? GridViewCell
            else { fatalError("unexpected cell in collection view") }
        // Request an image for the asset from the PHCachingImageManager.
        cell.representedAssetIdentifier = asset.localIdentifier
        cell.btnPlay.tag = indexPath.row
        cell.btnPlay.addTarget(self, action: #selector(self.btnPlayAction(sender:)), for: .touchUpInside)

        imageManager.requestImage(for: asset, targetSize: thumbnailSize, contentMode: .aspectFill, options: nil, resultHandler: { image, _ in
            // The cell may have been recycled by the time this handler gets called;
            // set the cell's thumbnail image only if it's still showing the same asset.
            if cell.representedAssetIdentifier == asset.localIdentifier {
                if asset.mediaType == .video {
                    cell.btnPlay.isHidden = false
                }else {
                    cell.btnPlay.isHidden = true
                }
                
                if imp.strID == asset.localIdentifier {
                    if imp.isSelected {
                        cell.imgSelect.image = #imageLiteral(resourceName: "select_active_icon")
                    }else {
                        cell.imgSelect.image = #imageLiteral(resourceName: "select_unactive_icon")
                    }
                }
                cell.thumbnailImage = image
            }
        })
        
        return cell
        
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let cell = self.collectionView?.cellForItem(at: indexPath) {
            let imp = arraySelected[indexPath.item]
            imp.isSelected = !imp.isSelected
            arraySelected[indexPath.item] = imp
            if imp.isSelected {
                (cell as! GridViewCell).imgSelect.image = #imageLiteral(resourceName: "select_active_icon")
            }else {
                (cell as! GridViewCell).imgSelect.image = #imageLiteral(resourceName: "select_unactive_icon")
            }
            self.updateAssest(obj: imp)
        }
    }
    
    
    func updateAssest(obj:ImportDAO){
        
        if arrayAssests!.contains(where: {$0.assest.localIdentifier == obj.assest.localIdentifier}) {
            // it exists, do something
            if let index =  arrayAssests?.index(where: {$0.assest.localIdentifier == obj.assest.localIdentifier}) {
                arrayAssests?.remove(at: index)
            }
            if let index =  arraySelectedContent?.index(where: {$0.fileName.trim() == obj.name.trim()}) {
                arraySelectedContent?.remove(at: index)
            }
            
        } else {
            if obj.isSelected {
                arrayAssests?.insert(obj, at: 0)
            }else {
                if let index =  arrayAssests?.index(where: {$0.assest.localIdentifier == obj.assest.localIdentifier}) {
                    arrayAssests?.remove(at: index)
                }
                if let index =  arraySelectedContent?.index(where: {$0.fileName.trim() == obj.name.trim()}) {
                    arraySelectedContent?.remove(at: index)
                }
            }
            
        }
       
        
      
//                if let index =  arrayAssests?.index(where: {$0.assest.localIdentifier == obj.assest.localIdentifier}) {
//                    arrayAssests?.remove(at: index)
//                }else {
//
//               }
    }
    
    //MARK:- CollectionView Layout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(8, 8, 8, 8)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 8
    }
    
    // MARK: UIScrollView
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
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
        let visibleRect = CGRect(origin: collectionView!.contentOffset, size: collectionView!.bounds.size)
        let preheatRect = visibleRect.insetBy(dx: 0, dy: -0.5 * visibleRect.height)
        
        // Update only if the visible area is significantly different from the last preheated area.
        let delta = abs(preheatRect.midY - previousPreheatRect.midY)
        guard delta > view.bounds.height / 3 else { return }
        
        // Compute the assets to start caching and to stop caching.
        let (addedRects, removedRects) = differencesBetweenRects(previousPreheatRect, preheatRect)
        let addedAssets = addedRects
            .flatMap { rect in collectionView!.indexPathsForElements(in: rect) }
            .map { indexPath in fetchResult.object(at: indexPath.item) }
        let removedAssets = removedRects
            .flatMap { rect in collectionView!.indexPathsForElements(in: rect) }
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
                guard let collectionView = self.collectionView else { fatalError() }
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
                collectionView!.reloadData()
            }
            resetCachedAssets()
        }
    }
}

