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
    @IBOutlet weak var btnClose: UIButton!
    
    var listType:FollowerType!
    var arraySearch = [FollowerDAO]()
    var arraylikeUser = [LikedUser]()
    var objStream : StreamViewDAO?
    var isSearchEnable:Bool! = false
    var isEditingEnable:Bool! = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tblLikeList.delegate = self
        self.tblLikeList.dataSource = self
        self.prepareLayout()
     
    }
    override func viewWillAppear(_ animated: Bool) {
        super .viewWillAppear(true)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
       
    }
    //MARK:- prepare Layout
    func prepareLayout() {
        
        self.tblLikeList.tableFooterView = UIView()
        
        if objStream?.arrayLikedUsers == nil {
            
            self.lblNoResult.isHidden = false
            self.lblNoResult.text = "No User Found"
            
        }else{
            self.lblNoResult.isHidden = true
        }
    }
    
   
    @IBAction func btnCloseAction(_ sender: Any) {
       self.dismiss(animated: true, completion: nil)
    }
    
   
    
    //MARK:- Action for followUser
    
    @objc func actionForFollowUser(sender:UIButton) {
       let obj  = objStream?.arrayLikedUsers[sender.tag]
        if (obj?.isFollowing)! {
            self.unFollowUser(follow: obj!, index: sender.tag)
        }else {
            self.followUser(userID: (obj?.userID)!, index: sender.tag)
        }

    }
    func unFollowUser(follow:LikedUser,index:Int){
        var name = follow.name
        if !follow.userDisplayName.trim().isEmpty {
            name = follow.userDisplayName.trim()
        }
        let alert = UIAlertController(title: kAlert_Message, message: String(format: kAlert_UnFollow_a_User,name!), preferredStyle: .alert)
        let yes = UIAlertAction(title: kAlertTitle_Unfollow, style: .default) { (action) in
            self.unFollowUser(userID: follow.userID, index: index)
        }
        let no = UIAlertAction(title: kAlert_Cancel_Title, style: .default) { (action) in
        }
        alert.addAction(yes)
        alert.addAction(no)
        self.present(alert, animated: true, completion: nil)
    }
    

    
    func followUser(userID:String,index:Int){
        
        APIServiceManager.sharedInstance.apiForFollowUser(userID: userID) { (isSuccess, errorMSG) in
           
            if (errorMSG?.isEmpty)! {
                let follow = self.objStream?.arrayLikedUsers[index]
                follow?.isFollowing = true
                self.objStream?.arrayLikedUsers[index] = follow!
                self.tblLikeList.reloadData()
            }else {
              
            }
        }
    }
    func unFollowUser(userID:String,index:Int){
       
        APIServiceManager.sharedInstance.apiForUnFollowUser(userID: userID) { (isSuccess, errorMSG) in
         
            if (errorMSG?.isEmpty)! {
                let follow = self.objStream?.arrayLikedUsers[index]
                follow?.isFollowing = false
                self.objStream?.arrayLikedUsers[index] = follow!
                self.tblLikeList.reloadData()
                
            }else {
              
            }
        }
    }
    
}


    extension LikeListViewController : UITableViewDelegate,UITableViewDataSource {
        
        func numberOfSections(in tableView: UITableView) -> Int {
            return 1
        }
        
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
             if objStream != nil {
                return (objStream?.arrayLikedUsers.count)!
             }else{
                return 0
            }
    }
        
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
            let cell: LikeStreamListCell = tableView.dequeueReusableCell(withIdentifier: kLikeStreamList_Cell) as! LikeStreamListCell
            let dict = objStream!.arrayLikedUsers[indexPath.row]
            cell.prepareLayout(like:dict)
            cell.btnFollow.tag = indexPath.row
            cell.btnFollow.addTarget(self, action: #selector(self.actionForFollowUser(sender:)), for: .touchUpInside)
             cell.btnFollow.isHidden = false
            if  dict.userProfileID.trim() == UserDAO.sharedInstance.user.userProfileID {
                cell.lblDisplayname.text = "You"
                cell.lblUserName.text = dict.name
                cell.btnFollow.isHidden = true
            }
            return cell
        }
    }
    

