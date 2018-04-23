//
//  FollowersViewController.swift
//  Emogo
//
//  Created by Pushpendra on 18/04/18.
//  Copyright © 2018 Vikas Goyal. All rights reserved.
//

import UIKit
import Presentr

class FollowersViewController: UIViewController {

    @IBOutlet weak var tblFollowers: UITableView!
    
    let kHeader = "FollowHeader"
    var listType:FollowerType!
    
    
    let customOrientationPresenter: Presentr = {
        let width = ModalSize.sideMargin(value: 20)
        let height = ModalSize.sideMargin(value: 20)
        let center = ModalCenterPosition.center
        let customType = PresentationType.custom(width: width, height: height, center: center)
        let customPresenter = Presentr(presentationType: customType)
        customPresenter.transitionType = .coverVerticalFromTop
        customPresenter.dismissTransitionType = .crossDissolve
        customPresenter.roundCorners = true
        customPresenter.backgroundColor = .black
        customPresenter.backgroundOpacity = 0.5
        customPresenter.cornerRadius = 5.0
        customPresenter.dismissOnSwipe = true
        return customPresenter
    }()
    
    lazy var popupViewController: TermsAndPrivacyViewController = {
        let popupViewController = self.storyboard?.instantiateViewController(withIdentifier: "termsAndPrivacyView")
        return popupViewController as! TermsAndPrivacyViewController
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        prepareLayout()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func prepareLayout(){
        self.configureNavigationWithTitle()
        self.title = listType.rawValue
        self.configureLoadMoreAndRefresh()
        if listType == FollowerType.Follower {
            self.getFollowers(type: .start)
        }else {
            self.getFollowing(type: .start)
        }
    }

    
    func configureLoadMoreAndRefresh(){
        let header:ESRefreshProtocol & ESRefreshAnimatorProtocol = RefreshHeaderAnimator(frame: .zero)
        let  footer: ESRefreshProtocol & ESRefreshAnimatorProtocol = RefreshFooterAnimator(frame: .zero)
        
        self.tblFollowers.es.addPullToRefresh(animator: header) { [weak self] in
            if self?.listType == FollowerType.Follower {
                self?.getFollowers(type: .start)
            }else {
                self?.getFollowing(type: .start)
            }
        }
        
        self.tblFollowers.es.addInfiniteScrolling(animator: footer) { [weak self] in
            
            if self?.listType == FollowerType.Follower {
                self?.getFollowers(type: .down)
            }else {
                self?.getFollowing(type: .down)
            }
        }
    }
    
    
    
   @objc func actionForFollowUser(sender:UIButton) {
        let obj = FollowList.sharedInstance.arrayFollowers[sender.tag]
    if listType == .Follower {
        if obj.isFollowing {
            self.unFollowUser(follow: obj, index: sender.tag)
        }else {
            self.followUser(userID: obj.userId, index: sender.tag)
        }
    }else {
        self.unFollowUser(follow: obj, index: sender.tag)
    }
   
    }
    
   

    
    func getFollowers(type:RefreshType){
        APIServiceManager.sharedInstance.apiForUserFollowerList(type: type) { (refreshType, errorMsg) in
            
            AppDelegate.appDelegate.window?.isUserInteractionEnabled = true
            if refreshType == .end {
                self.tblFollowers.es.noticeNoMoreData()
            }
            if type == .start {
                HUDManager.sharedInstance.hideHUD()
            }
            if type == .up {
                UIApplication.shared.endIgnoringInteractionEvents()
                self.tblFollowers.es.stopPullToRefresh()
            }else if type == .down {
                self.tblFollowers.es.stopLoadingMore()
            }
            DispatchQueue.main.async {
                self.tblFollowers.reloadData()
            }

            if !(errorMsg?.isEmpty)! {
                self.showToast(type: .success, strMSG: errorMsg!)
            }
            
        }
    }
    func getFollowing(type:RefreshType){
        APIServiceManager.sharedInstance.apiForUserFollowingList(type: type) { (refreshType, errorMsg) in
            AppDelegate.appDelegate.window?.isUserInteractionEnabled = true
            if refreshType == .end {
                self.tblFollowers.es.noticeNoMoreData()
            }
            if type == .start {
                HUDManager.sharedInstance.hideHUD()
            }
            if type == .up {
                UIApplication.shared.endIgnoringInteractionEvents()
                self.tblFollowers.es.stopPullToRefresh()
            }else if type == .down {
                self.tblFollowers.es.stopLoadingMore()
            }
            DispatchQueue.main.async {
                self.tblFollowers.reloadData()
            }
            if !(errorMsg?.isEmpty)! {
                self.showToast(type: .success, strMSG: errorMsg!)
            }
        }
    }
    
    func followUser(userID:String,index:Int){
        HUDManager.sharedInstance.showHUD()
        APIServiceManager.sharedInstance.apiForFollowUser(userID: userID) { (isSuccess, errorMSG) in
            HUDManager.sharedInstance.hideHUD()
            if (errorMSG?.isEmpty)! {
                let follow = FollowList.sharedInstance.arrayFollowers[index]
                follow.isFollowing = true
                FollowList.sharedInstance.arrayFollowers[index] = follow
                self.tblFollowers.reloadData()
            }else {
                self.showToast(strMSG: errorMSG!)
            }
        }
    }
    func unFollowUser(userID:String,index:Int){
        HUDManager.sharedInstance.showHUD()
        APIServiceManager.sharedInstance.apiForUnFollowUser(userID: userID) { (isSuccess, errorMSG) in
            HUDManager.sharedInstance.hideHUD()
            if (errorMSG?.isEmpty)! {
                let follow = FollowList.sharedInstance.arrayFollowers[index]
                follow.isFollowing = false
                FollowList.sharedInstance.arrayFollowers[index] = follow
                self.tblFollowers.reloadData()
            }else {
                self.showToast(strMSG: errorMSG!)
            }
        }
    }
    
    
    func unFollowUser(follow:FollowerDAO,index:Int){
        var name = follow.fullName
        if !follow.displayName.trim().isEmpty {
            name = follow.displayName.trim()
        }
        let alert = UIAlertController(title: kAlert_Message, message: String(format: kAlert_UnFollow_a_User,name!), preferredStyle: .alert)
        let yes = UIAlertAction(title: kAlertTitle_Yes, style: .default) { (action) in
            self.unFollowUser(userID: follow.userId, index: index)
        }
        let no = UIAlertAction(title: kAlertTitle_No, style: .default) { (action) in
        }
        alert.addAction(yes)
        alert.addAction(no)
        self.present(alert, animated: true, completion: nil)
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


extension FollowersViewController:UITableViewDelegate,UITableViewDataSource {
    
    
    func numberOfSections(in tableView: UITableView) -> Int  {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        }else {
            return FollowList.sharedInstance.arrayFollowers.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:FollowerCell = tableView.dequeueReusableCell(withIdentifier: kCell_FollowerCell, for: indexPath) as! FollowerCell
        if indexPath.section == 0 {
            cell.viewMessage.isHidden = false
            cell.ViewUser.isHidden = true
        }else {
            let follow = FollowList.sharedInstance.arrayFollowers[indexPath.row]
            cell.prepareData(follow:follow,type:listType)
            cell.viewMessage.isHidden = true
            cell.ViewUser.isHidden = false
            cell.btnFollow.tag = indexPath.row
            cell.btnFollow.addTarget(self, action: #selector(self.actionForFollowUser(sender:)), for: .touchUpInside)
        }
        
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let nibViews = Bundle.main.loadNibNamed(kHeader, owner: self, options: nil)
        let view:FollowHeader = nibViews?.first as! FollowHeader
        if section == 0 {
            view.lblTitle.text = "Invite"
        }else {
            view.lblTitle.text = self.listType.rawValue
        }
        return view
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
        customPresentViewController(customOrientationPresenter, viewController: popupViewController, animated: true)
        }else {
            let people = FollowList.sharedInstance.arrayFollowers[indexPath.row]
            let objPeople = PeopleDAO(peopleData: [:])
            objPeople.fullName = people.fullName
            objPeople.userId = people.userId
            objPeople.userProfileID = people.userProfileID
            objPeople.userImage = people.userImage
            objPeople.phoneNumber = people.phone
            let obj:ViewProfileViewController = kStoryboardStuff.instantiateViewController(withIdentifier: kStoryboardID_UserProfileView) as! ViewProfileViewController
            obj.objPeople = objPeople
            self.navigationController?.push(viewController: obj)
        }
    }

}
