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
        return cell
    }
    func pagerView(_ pagerView: FSPagerView, didSelectItemAt index: Int) {
        pagerView.deselectItem(at: index, animated: false)
        pagerView.scrollToItem(at: index, animated: true)
        changeCellImageAnimationt(index, pagerView: pagerView,isSelect:true)
    }
    
    func pagerViewDidEndDecelerating(_ pagerView: FSPagerView) {
        changeCellImageAnimationt(pagerView.currentIndex, pagerView: pagerView,isSelect: false)
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
         pagerView.lblCurrentType.text = menu.iconName!
        let when = DispatchTime.now() + 0.3
        DispatchQueue.main.asyncAfter(deadline: when) {
            self.navigateToSelectedItem(index:sender,isSelect:isSelect)
        }
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
            self.currentStreamType = StreamType.populer
            break
        case 1:
            self.currentStreamType = StreamType.myStream
            break
        case 2:
            self.currentStreamType = StreamType.featured
            break
        case 3:
            self.currentStreamType = StreamType.emogoStreams
            break
        case 4:
            self.actionForPeopleList()
            break
        default:
            break
        }
        print("currrent index--->\(index)")
        if  index != 4 {
            isPeopleList = false
            HUDManager.sharedInstance.showHUD()
            self.getStreamList(type:.start,filter: self.currentStreamType)
        }
    }
    
    func actionForAddStream(){
        let obj = kStoryboardMain.instantiateViewController(withIdentifier: kStoryboardID_AddStreamView)
        self.navigationController?.push(viewController: obj)
    }
    func actionForPeopleList(){
        isPeopleList = true
        StreamList.sharedInstance.arrayStream.removeAll()
        PeopleList.sharedInstance.arrayPeople.removeAll()
        HUDManager.sharedInstance.showHUD()
        self.getUsersList(type:.start)
    }
}
