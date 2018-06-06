//
//  LikeListViewController.swift
//  Emogo
//
//  Created by Northout on 05/06/18.
//  Copyright © 2018 Vikas Goyal. All rights reserved.
//

import UIKit

class LikeListViewController: UIViewController {
    
    //IBOutlet Connection
    
    @IBOutlet weak var tblLikeList: UITableView!
    @IBOutlet weak var lblNoResult: UILabel!
    
    var listType:FollowerType!
    var arraySearch = [FollowerDAO]()
    var arrayLikeList = [StreamDAO]()
    var isSearchEnable:Bool! = false
    var isEditingEnable:Bool! = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tblLikeList.delegate = self
        self.tblLikeList.dataSource = self
     
    }
    override func viewWillAppear(_ animated: Bool) {
        super .viewWillAppear(true)
        self.prepareNavigation()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
       
    }
    //MARK:- prepare Layout
    func prepareLayout() {
        self.tblLikeList.tableFooterView = UIView()
    }
    
    //MARK:- prepare Navigation
    
    func prepareNavigation() {
        var myAttribute2:[NSAttributedStringKey:Any]!
        if let font = UIFont(name: kFontBold, size: 20.0) {
            myAttribute2 = [ NSAttributedStringKey.foregroundColor: UIColor.black ,NSAttributedStringKey.font: font]
        }else {
            myAttribute2 = [ NSAttributedStringKey.foregroundColor: UIColor.black ,NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 20.0)]
        }
        self.navigationController?.navigationBar.titleTextAttributes = myAttribute2
        
        self.navigationController?.isNavigationBarHidden = false
        self.navigationController?.navigationBar.tintColor = UIColor.darkGray
        self.navigationController?.navigationBar.barTintColor = .white
        let img = UIImage(named: "back_icon")
        let btnClose = UIBarButtonItem(image: img, style: .plain, target: self, action: #selector(self.btnCloseAction))
        self.navigationItem.leftBarButtonItem = btnClose
        
        //self.title = "Like List"
    }
    
    //MARK: button actions
    
    @objc func btnCloseAction(){
        self.navigationController?.popViewController(animated: true)
    }
    
    //MARK:- API method for get like list
    func getLikeList(){
        
    }

    //MARK:- Action for followUser
    
    @objc func actionForFollowUser(sender:UIButton) {
        var obj:FollowerDAO!
        if self.isSearchEnable {
            obj = self.arraySearch[sender.tag]
        }else {
            obj = FollowList.sharedInstance.arrayFollowers[sender.tag]
        }
        if obj != nil {
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
        
    }
    func unFollowUser(follow:FollowerDAO,index:Int){
        var name = follow.fullName
        if !follow.displayName.trim().isEmpty {
            name = follow.displayName.trim()
        }
        let alert = UIAlertController(title: kAlert_Message, message: String(format: kAlert_UnFollow_a_User,name!), preferredStyle: .actionSheet)
        let yes = UIAlertAction(title: kAlertTitle_Unfollow, style: .default) { (action) in
            self.unFollowUser(userID: follow.userId, index: index)
        }
        let no = UIAlertAction(title: kAlert_Cancel_Title, style: .default) { (action) in
        }
        alert.addAction(yes)
        alert.addAction(no)
        self.present(alert, animated: true, completion: nil)
    }
    
    func getFollowers(type:RefreshType){
        self.lblNoResult.isHidden = true
        APIServiceManager.sharedInstance.apiForUserFollowerList(type: type) { (refreshType, errorMsg) in
            
            AppDelegate.appDelegate.window?.isUserInteractionEnabled = true
            if refreshType == .end {
                self.tblLikeList.es.noticeNoMoreData()
            }
            if type == .start {
                HUDManager.sharedInstance.hideHUD()
            }
            if type == .up {
                UIApplication.shared.endIgnoringInteractionEvents()
                self.tblLikeList.es.stopPullToRefresh()
            }else if type == .down {
                self.tblLikeList.es.stopLoadingMore()
            }
            DispatchQueue.main.async {
                self.tblLikeList.reloadData()
            }
            
            if !(errorMsg?.isEmpty)! {
                self.showToast(type: .success, strMSG: errorMsg!)
            }
            
        }
    }
    func getFollowing(type:RefreshType){
        self.lblNoResult.isHidden = true
        
        APIServiceManager.sharedInstance.apiForUserFollowingList(type: type) { (refreshType, errorMsg) in
            AppDelegate.appDelegate.window?.isUserInteractionEnabled = true
            if refreshType == .end {
                self.tblLikeList.es.noticeNoMoreData()
            }
            if type == .start {
                HUDManager.sharedInstance.hideHUD()
            }
            if type == .up {
                UIApplication.shared.endIgnoringInteractionEvents()
                self.tblLikeList.es.stopPullToRefresh()
            }else if type == .down {
                self.tblLikeList.es.stopLoadingMore()
            }
            DispatchQueue.main.async {
                self.tblLikeList.reloadData()
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
                if self.isSearchEnable {
                    let follow = self.arraySearch[index]
                    follow.isFollowing = true
                    self.arraySearch[index] = follow
                    let indexTemp = FollowList.sharedInstance.arrayFollowers.index(where: {$0.userProfileID.trim() == follow.userProfileID})
                    if indexTemp != nil {
                        FollowList.sharedInstance.arrayFollowers[indexTemp!] = follow
                    }
                }else {
                    let follow = FollowList.sharedInstance.arrayFollowers[index]
                    follow.isFollowing = true
                    FollowList.sharedInstance.arrayFollowers[index] = follow
                }
                
                self.tblLikeList.reloadData()
                NotificationCenter.default.post(name: NSNotification.Name(kProfileUpdateIdentifier ), object: nil)
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
                if self.isSearchEnable {
                    let follow =  self.arraySearch[index]
                    if self.listType == FollowerType.Follower {
                        follow.isFollowing = false
                        self.arraySearch[index] = follow
                        
                        let indexTemp = FollowList.sharedInstance.arrayFollowers.index(where: {$0.userProfileID.trim() == follow.userProfileID})
                        if indexTemp != nil {
                            FollowList.sharedInstance.arrayFollowers[indexTemp!] = follow
                        }
                    }else {
                        let indexTemp = FollowList.sharedInstance.arrayFollowers.index(where: {$0.userProfileID.trim() == follow.userProfileID})
                        if indexTemp != nil {
                            FollowList.sharedInstance.arrayFollowers.remove(at: indexTemp!)
                        }
                        
                        self.arraySearch.remove(at: index)
                    }
                }else {
                    if self.listType == FollowerType.Follower {
                        let follow =  FollowList.sharedInstance.arrayFollowers[index]
                        follow.isFollowing = false
                        FollowList.sharedInstance.arrayFollowers[index] = follow
                    }else {
                        FollowList.sharedInstance.arrayFollowers.remove(at: index)
                    }
                }
                self.tblLikeList.reloadData()
                NotificationCenter.default.post(name: NSNotification.Name(kProfileUpdateIdentifier ), object: nil)
                if FollowList.sharedInstance.arrayFollowers.count == 0 {
                    self.navigationController?.pop()
                }
            }else {
                self.showToast(strMSG: errorMSG!)
            }
        }
    }
    
}


    extension LikeListViewController : UITableViewDelegate,UITableViewDataSource {
        
        func numberOfSections(in tableView: UITableView) -> Int {
            return 1
        }
        
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return 1
        }
        
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell: LikeListCell = tableView.dequeueReusableCell(withIdentifier: kCell_likeListCell) as! LikeListCell
            
            
            cell.btnFollow.tag = indexPath.row
            cell.btnFollow.addTarget(self, action: #selector(actionForFollowUser(sender:)), for: .touchUpInside)
            return cell
        }
    }
    

