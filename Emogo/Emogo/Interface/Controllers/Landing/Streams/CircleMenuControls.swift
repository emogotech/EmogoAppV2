//
//  CircleMenuControls.swift
//  Emogo
//
//  Created by Pushpendra on 13/12/17.
//  Copyright © 2017 Vikas Goyal. All rights reserved.
//

import Foundation
import UIKit



extension StreamListViewController:FSPagerViewDataSource,FSPagerViewDelegate {
    func numberOfItems(in pagerView: FSPagerView) -> Int {
        return menu.arrayMenu.count
    }
    
    func pagerView(_ pagerView: FSPagerView, cellForItemAt index: Int) -> FSPagerViewCell {
        let cell = pagerView.dequeueReusableCell(withReuseIdentifier: "cell", at: index)
        let menu = self.menu.arrayMenu[index]
        if(index == pagerView.currentIndex){
            cell.imageView?.frame = CGRect(x: 0, y: 0, width: 90, height: 90)
            cell.imageView?.center = cell.contentView.center
            cell.imageView?.image = menu.iconSelected
            cell.addLayerInImageView(isTrue : true)
        }
        else {
            cell.imageView?.frame = CGRect(x: 0, y: 0, width: 65, height: 65)
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
            lastIndex = index
            self.navigateToSelectedItem(index:index,isSelect:true)
            UIView.animate(withDuration: 0.7, animations: {
                self.changeCellImageAnimationt(index, pagerView: pagerView,isSelect:true)
            })
        }
        pagerView.scrollToItem(at: index, animated: true)
    }
    
    func pagerViewDidEndDecelerating(_ pagerView: FSPagerView) {
        if(lastIndex != pagerView.currentIndex) {
            lastIndex = pagerView.currentIndex
            self.navigateToSelectedItem(index:pagerView.currentIndex,isSelect:true)
            UIView.animate(withDuration: 0.7, animations: {
                self.changeCellImageAnimationt(pagerView.currentIndex, pagerView: pagerView,isSelect: false)
            })
        }
    }
    
    func changeCellImageAnimationt(_ sender : Int, pagerView: FSPagerView, isSelect:Bool){
        var menu:Menu!
        for section in 0 ..< pagerView.numberOfSections {
            for row in 0 ..< pagerView.numberOfItems{
                let indexPath = NSIndexPath(row: row, section: section)
                if let sel = pagerView.collectionView.cellForItem(at: indexPath as IndexPath){
                    if(sender == (sel as! FSPagerViewCell).imageView?.tag){
                        (sel as! FSPagerViewCell).imageView?.frame = CGRect(x: 0, y: 0, width: 90, height: 90)
                        (sel as! FSPagerViewCell).imageView?.center = (sel as! FSPagerViewCell).contentView.center
                         menu = self.menu.arrayMenu[indexPath.row]
                        (sel as! FSPagerViewCell).imageView?.image =  menu.iconSelected
                        (sel as! FSPagerViewCell).addLayerInImageView(isTrue : true)
                    } else {
                        (sel as! FSPagerViewCell).imageView?.frame = CGRect(x: 0, y: 0, width: 65, height: 65)
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
//        let when = DispatchTime.now() + 0.3
//        DispatchQueue.main.asyncAfter(deadline: when) {
//            self.navigateToSelectedItem(index:sender,isSelect:isSelect)
//        }
    }
    
    func navigateToSelectedItem(index:Int, isSelect:Bool){
//        self.menuView.isHidden = true
//        self.viewMenu.isHidden = false
//       if isSelect == true {
//            Animation.viewSlideInFromTopToBottom(views: self.viewMenu)
//        }
//        isMenuOpen = false
        switch index {
        case 0:
            currentStreamType  =  StreamType.populer
            break
        case 1:
            currentStreamType =  StreamType.myStream
            break
        case 2:
            currentStreamType =  StreamType.featured
            break
        case 3:
            currentStreamType = StreamType.emogoStreams
            break
        case 4:
            currentStreamType = StreamType.People
            collectionLayout.columnCount = 3
            self.lblNoResult.text = kAlert_No_User_Record_Found
         //   self.actionForPeopleList()
            break
        default:
            break
        }
        
        print("currrent index--->\(index)")
        if  index != 4 {
            StreamList.sharedInstance.updateRequestType(filter: currentStreamType)
            collectionLayout.columnCount = 2
            self.lblNoResult.text = kAlert_No_Stream_found
            isPeopleList = false
          //  HUDManager.sharedInstance.showHUD()
          //  self.getStreamList(type:.start,filter: currentStreamType)
        }
        
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
        let obj = kStoryboardMain.instantiateViewController(withIdentifier: kStoryboardID_AddStreamView)
        self.navigationController?.push(viewController: obj)
    }
    
    func actionForCamera(){
        let obj:CustomCameraViewController = kStoryboardMain.instantiateViewController(withIdentifier: kStoryboardID_CameraView) as! CustomCameraViewController
        ContentList.sharedInstance.arrayContent.removeAll()
        ContentList.sharedInstance.objStream = nil
        kContainerNav = ""
        self.navigationController?.pushNormal(viewController: obj)
    }
    
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
    
    func btnImportAction(){
        let viewController = TLPhotosPickerViewController(withTLPHAssets: { [weak self] (assets) in // TLAssets
            //     self?.selectedAssets = assets
            self?.preparePreview(assets: assets)
            }, didCancel: nil)
        viewController.didExceedMaximumNumberOfSelection = { (picker) in
            //exceed max selection
        }
        viewController.selectedAssets.removeAll()
        var configure = TLPhotosPickerConfigure()
        configure.numberOfColumn = 3
        configure.maxSelectedAssets = 10
        configure.muteAudio = true
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
            camera.fileName = obj.originalFileName
            if obj.type == .photo {
                camera.type = .image
                if obj.fullResolutionImage != nil {
                    camera.imgPreview = obj.fullResolutionImage
                    self.updateData(content: camera)
                    group.leave()
                }else {

                    obj.phAsset?.getOrigianlImage(handler: { (image) in
                        if let img = image {
                            camera.imgPreview = img
                            self.updateData(content: camera)
                        }
                        group.leave()
                    })
                   
                }
                
            }else if obj.type == .video {
                camera.type = .video
                obj.phAsset?.getURL(completionHandler: { (url) in
                    camera.fileUrl = url
                    if let image = SharedData.sharedInstance.videoPreviewImage(moviePath:url!) {
                        camera.imgPreview = image
                        self.updateData(content: camera)
                    }
                    group.leave()
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

}
