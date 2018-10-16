//
//  CircleMenuControls.swift
//  Emogo
//
//  Created by Pushpendra on 13/12/17.
//  Copyright © 2017 Vikas Goyal. All rights reserved.
//

import Foundation
import UIKit
import Haptica

extension StreamListViewController:FSPagerViewDataSource,FSPagerViewDelegate,StreamSegmentHeaderDelegate {
    
    func ShowSegmentControl() {
        self.configureStreamHeader()
        self.StreamSegmentView()
    }
    
    func numberOfItems(in pagerView: FSPagerView) -> Int {
        return menu.arrayMenu.count
    }
    
    func pagerView(_ pagerView: FSPagerView, cellForItemAt index: Int) -> FSPagerViewCell {
        let cell = pagerView.dequeueReusableCell(withReuseIdentifier: "cell", at: index)
        let menu = self.menu.arrayMenu[index]
        if(index == pagerView.currentIndex){
            cell.imageView?.frame = CGRect(x: 0, y: 0, width: 75, height: 75)
            cell.imageView?.center = cell.contentView.center
            cell.imageView?.image = menu.iconSelected
            cell.addLayerInImageView(isTrue : true)
        }
        else {
            cell.imageView?.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
            cell.imageView?.center = cell.contentView.center
            cell.imageView?.image = menu.icon
        }
        cell.imageView?.tag = index
        cell.imageView?.layer.cornerRadius = (cell.imageView?.frame.size.width)!/2
        cell.imageView?.contentMode = .scaleAspectFill
        cell.imageView?.clipsToBounds = true
        cell.isExclusiveTouch = true
        cell.isHighlighted = false
        return cell
    }
    func pagerView(_ pagerView: FSPagerView, didSelectItemAt index: Int) {
        pagerView.deselectItem(at: index, animated: false)
        if(lastIndex != index){
            let last = lastIndex
            
            lastIndex = index
            
            self.navigateToSelectedItem(index:index,isSelect:true)
            UIView.animate(withDuration: 0.7, animations: {
                if last > index {
                    Animation.addLeftTransitionCollection(imgV: self.streamCollectionView)
                }
                else{
                    Animation.addRightTransitionCollection(imgV: self.streamCollectionView)
                }
                self.changeCellImageAnimationt(index, pagerView: pagerView,isSelect:true)
                
            })
        }
        pagerView.scrollToItem(at: index, animated: true)
        
    }
    
    func pagerView(_ pagerView: FSPagerView, willDisplay cell: FSPagerViewCell, forItemAt index: Int) {
        
        if pagerView.panGestureRecognizer.translation(in: pagerView.superview).x > 0 {
            print("left")
        } else {
            print("right")
        }
        
    }
    
    func pagerViewDidEndDecelerating(_ pagerView: FSPagerView) {
        if(lastIndex != pagerView.currentIndex) {
            let last = lastIndex
            UIView.animate(withDuration: 0.7, animations: {
                self.changeCellImageAnimationt(pagerView.currentIndex, pagerView: pagerView,isSelect: false)
                print(last)
                print(pagerView.currentIndex)
                if last > pagerView.currentIndex {
                    Animation.addLeftTransitionCollection(imgV: self.streamCollectionView)
                }
                else{
                    Animation.addRightTransitionCollection(imgV: self.streamCollectionView)
                }
            })
            lastIndex = pagerView.currentIndex
            self.navigateToSelectedItem(index:pagerView.currentIndex,isSelect:true)
        }
    }
    
    func changeCellImageAnimationt(_ sender : Int, pagerView: FSPagerView, isSelect:Bool){
        var menu:Menu!
        for section in 0 ..< pagerView.numberOfSections {
            for row in 0 ..< pagerView.numberOfItems{
                let indexPath = NSIndexPath(row: row, section: section)
                if let sel = pagerView.collectionView.cellForItem(at: indexPath as IndexPath){
                    if(sender == (sel as! FSPagerViewCell).imageView?.tag){
                        (sel as! FSPagerViewCell).imageView?.frame = CGRect(x: 0, y: 0, width: 75, height: 75)
                        (sel as! FSPagerViewCell).imageView?.center = (sel as! FSPagerViewCell).contentView.center
                        menu = self.menu.arrayMenu[indexPath.row]
                        (sel as! FSPagerViewCell).imageView?.image =  menu.iconSelected
                        (sel as! FSPagerViewCell).addLayerInImageView(isTrue : true)
                    } else {
                        (sel as! FSPagerViewCell).imageView?.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
                        (sel as! FSPagerViewCell).imageView?.center = (sel as! FSPagerViewCell).contentView.center
                        menu = self.menu.arrayMenu[indexPath.row]
                        (sel as! FSPagerViewCell).imageView?.image =  menu.icon
                    }
                    (sel as! FSPagerViewCell).imageView?.layer.cornerRadius = ((sel as! FSPagerViewCell).imageView?.frame.size.width)!/2
                }
            }
        }
        menu  = self.menu.arrayMenu[sender]
        pagerView.lblCurrentType.text = menu.iconName
        
       
    }
    
    func navigateToSelectedItem(index:Int, isSelect:Bool){
   
        self.segmentContainerView.isHidden = true
        self.kSegmentHeight.constant = 0.0
        if self.segmentheader != nil {
            if self.segmentheader.superview != nil {
            self.segmentheader.removeFromSuperview()
            }
        }

        switch index {
        case 0:
            ShowSegmentControl()
            currentStreamType = StreamType.Public
            self.segmentheader.segmentControl.selectedSegmentIndex = 0
            break
        case 1:
            currentStreamType  =  StreamType.populer
            break
        case 2:
            currentStreamType =  StreamType.featured
            break
        case 3:
            currentStreamType = StreamType.emogoStreams
            break
        case 4:
            currentStreamType   =   StreamType.Liked
         
            break
            
        case 5:
            currentStreamType   =   StreamType.Following
            break
        default:
            break
        }
        
        if kDefault?.bool(forKey: kHapticFeedback) == true {
            Haptic.impact(.light).generate()
        }else{
            
        }
        
        print("currrent index--->\(index)")
        StreamList.sharedInstance.updateRequestType(filter: currentStreamType)
        collectionLayout.columnCount = 2
        self.lblNoResult.text = kAlert_No_Stream_found
        isPeopleList = false
      
        self.streamCollectionView.es.resetNoMoreData()
        DispatchQueue.main.async {
            self.arrayToShow = StreamList.sharedInstance.arrayStream.filter { $0.selectionType == currentStreamType }
            if self.arrayToShow.count == 0 {
                self.lblNoResult.isHidden = false
            }else {
                self.lblNoResult.isHidden = true
            }
            self.streamCollectionView.reloadData()
        }
        
    }
    
    func StreamSegmentView(){
    
        // Segment control Configure
        self.segmentheader.segmentControl.sectionTitles = ["Public", "Private"]
        self.segmentheader.segmentControl.indexChangeBlock = {(_ index: Int) -> Void in
            print("Selected index \(index) (via block)")
             self.updateStreamSegment(index: index)
        }
        self.segmentheader.segmentControl.selectionIndicatorHeight = 1.0
        self.segmentheader.segmentControl.backgroundColor = .white
        self.segmentheader.segmentControl.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor(r: 155, g: 155, b: 155),NSAttributedStringKey.font : fontSegment ?? UIFont.systemFont(ofSize: 15.0)]
       
         self.segmentheader.segmentControl.selectionIndicatorColor = UIColor(r: 74, g: 74, b: 74)
        self.segmentheader.segmentControl.selectedTitleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor(r: 74, g: 74, b: 74),NSAttributedStringKey.font : fontSegment ?? UIFont.systemFont(ofSize: 15.0)]
        self.segmentheader.segmentControl.selectionStyle = .textWidthStripe
        self.segmentheader.segmentControl.selectedSegmentIndex = 0
        self.segmentheader.segmentControl.selectionIndicatorLocation = .down
        self.segmentheader.segmentControl.shouldAnimateUserSelection = false
        self.segmentheader.segmentControl.isUserDraggable = true
        
    }
    
    
    func actionForPeopleList(){
        isPeopleList = true
        collectionLayout.columnCount = 3
        StreamList.sharedInstance.arrayStream.removeAll()
        PeopleList.sharedInstance.arrayPeople.removeAll()
        self.streamCollectionView.reloadData()
        HUDManager.sharedInstance.showHUD()
        self.getUsersList(type:.start)
    }
    
    func actionForAddStream(){
        let createVC : CreateStreamController = kStoryboardMain.instantiateViewController(withIdentifier: kStoryboardID_CreateStreamView) as! CreateStreamController
         createVC.exestingNavigation = self.navigationController
         let nav = UINavigationController(rootViewController: createVC)
         customPresentViewController(PresenterNew.CreateStreamPresenter, viewController: nav, animated: true, completion: nil)

    }
    
    func actionForCamera(){
        let obj:CustomCameraViewController = kStoryboardMain.instantiateViewController(withIdentifier: kStoryboardID_CameraView) as! CustomCameraViewController
        ContentList.sharedInstance.arrayContent.removeAll()
        ContentList.sharedInstance.objStream = nil
        kContainerNav = ""
        self.navigationController?.pushNormal(viewController: obj)
    }
    
}

extension StreamListViewController {
    
    
    func btnActionForLink(){
        ContentList.sharedInstance.objStream = nil
        let controller = kStoryboardStuff.instantiateViewController(withIdentifier: kStoryboardID_LinkView)
        self.navigationController?.push(viewController: controller)
    }
    
    func btnActionForGiphy(){
        ContentList.sharedInstance.objStream = nil
        let controller = kStoryboardStuff.instantiateViewController(withIdentifier: kStoryboardID_GiphyView)
        self.navigationController?.push(viewController: controller)
    }
    
    
    func btnActionForMyStuff(){
        ContentList.sharedInstance.objStream = nil
        let controller = kStoryboardStuff.instantiateViewController(withIdentifier: kStoryboardID_MyStuffView)
        self.navigationController?.push(viewController: controller)
    }
    
    func btnActionForNotes(){
        ContentList.sharedInstance.objStream = nil
        ContentList.sharedInstance.arrayContent.removeAll()
        let controller:CreateNotesViewController = kStoryboardPhotoEditor.instantiateViewController(withIdentifier: kStoryboardID_CreateNotesView) as! CreateNotesViewController
        controller.isOpenFrom = "Stream"
        self.navigationController?.push(viewController: controller)
    }
    

    func btnImportAction(){
        let viewController = TLPhotosPickerViewController(withTLPHAssets: { [weak self] (assets) in // TLAssets
            //     self?.selectedAssets = assets
            self?.preparePreview(assets: assets)
            }, didCancel: nil)
        viewController.didExceedMaximumNumberOfSelection = { (picker) in
            //exceed max selection
        }
        viewController.selectedAssets = [TLPHAsset]()
        var configure = TLPhotosPickerConfigure()
        configure.numberOfColumn = 3
        configure.maxSelectedAssets = 10
        configure.muteAudio = false
        configure.usedCameraButton = false
        configure.usedPrefetch = false
        viewController.configure = configure
        self.present(viewController, animated: true, completion: nil)
    }
    
    func preparePreview(assets:[TLPHAsset]){
        
        HUDManager.sharedInstance.showHUD()
        let group = DispatchGroup()
        for obj in assets {
            group.enter()
            let camera = ContentDAO(contentData: [:])
            camera.isUploaded = false
            
            if obj.type == .photo || obj.type == .livePhoto {
                camera.fileName = NSUUID().uuidString + ".png"
                camera.type = .image
                if obj.fullResolutionImage != nil {
                    camera.imgPreview = obj.fullResolutionImage
                    camera.color = obj.fullResolutionImage?.getColors().primary.toHexString
                    self.updateData(content: camera)
                    group.leave()
                }else {
                    
                    obj.cloudImageDownload(progressBlock: { (progress) in
                        
                    }, completionBlock: { (image) in
                        if let img = image {
                            camera.imgPreview = img
                            camera.color = img.getColors().primary.toHexString
                            self.updateData(content: camera)
                        }
                        group.leave()
                    })
                }
                
            } else if obj.type == .video {
                camera.type = .video
                obj.tempCopyMediaFile(progressBlock: { (progress) in
                    print(progress)
                }, completionBlock: { (url, mimeType) in
                    camera.fileUrl = url
                    camera.fileName = url.lastPathComponent
                    obj.phAsset?.getOrigianlImage(handler: { (img, _) in
                        if img != nil {
                            camera.imgPreview = img
                            camera.color = img?.getColors().primary.toHexString
                        }else {
                            camera.imgPreview = #imageLiteral(resourceName: "stream-card-placeholder")
                        }
                        self.updateData(content: camera)
                        group.leave()
                    })
                })
                
            }
        }
        group.notify(queue: .main, execute: {
            HUDManager.sharedInstance.hideHUD()
            if ContentList.sharedInstance.arrayContent.count == assets.count {
                self.previewScreenNavigated()
            }
        })
    }
    
    func updateData(content:ContentDAO) {
        ContentList.sharedInstance.arrayContent.insert(content, at: 0)
    }
    
    func previewScreenNavigated(){
        
        if   ContentList.sharedInstance.arrayContent.count != 0 {
            let objPreview:PreviewController = kStoryboardMain.instantiateViewController(withIdentifier: kStoryboardID_PreView) as! PreviewController
            self.navigationController?.pushNormal(viewController: objPreview)
        }
    }
    
    
    func updateStreamSegment(index:Int){
        switch index {
        case 0:
           currentStreamType = StreamType.Public
           StreamList.sharedInstance.updateRequestType(filter: currentStreamType)
            break
        case 1:
            currentStreamType = StreamType.Private
            StreamList.sharedInstance.updateRequestType(filter: currentStreamType)
            break
            
        default:
           break
        }
        self.streamCollectionView.es.resetNoMoreData()
        DispatchQueue.main.async {
            self.arrayToShow = StreamList.sharedInstance.arrayStream.filter { $0.selectionType == currentStreamType }
            if self.arrayToShow.count == 0 {
                self.lblNoResult.isHidden = false
            }else {
                self.lblNoResult.isHidden = true
            }
            self.streamCollectionView.reloadData()
        }
    
    }
    
}

extension StreamListViewController : ActionSheetViewControllerDelegate {
    func didSelectAction(type:String) {
        switch type {
        case "1":
            self.btnImportAction()
            break
        case "2":
            self.btnCameraAction()
            break
        case "3":
            self.btnActionForLink()
            break
        case "4":
            self.btnActionForNotes()
            break
        case "5":
            self.btnActionForGiphy()
            break
        case "6":
            self.btnActionForMyStuff()
            break
        case "7":
            self.actionForAddStream()
            break
        default:
            break
        }
    }
}

extension ProfileViewController : ActionSheetViewControllerDelegate {
    func didSelectAction(type:String) {
        switch type {
        case "1":
            self.btnImportAction()
            break
        case "2":
            self.actionForCamera()
            break
        case "3":
            self.btnActionForLink()
            break
        case "4":
            self.btnActionForNotes()
            break
        case "5":
            self.btnActionForGiphy()
            break
        case "6":
            self.btnActionForMyStuff()
            break
        case "7":
            self.actionForAddStream()
            break
        default:
            break
        }
    }
    func btnActionForNotes(){
        ContentList.sharedInstance.objStream = nil
        ContentList.sharedInstance.arrayContent.removeAll()
        let controller:CreateNotesViewController = kStoryboardPhotoEditor.instantiateViewController(withIdentifier: kStoryboardID_CreateNotesView) as! CreateNotesViewController
        controller.isOpenFrom = "Profile"
        self.navigationController?.push(viewController: controller)
    }
}



