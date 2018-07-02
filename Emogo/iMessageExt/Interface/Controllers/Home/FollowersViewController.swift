//
//  FollowersViewController.swift
//  Emogo
//
//  Created by Pushpendra on 18/04/18.
//  Copyright © 2018 Vikas Goyal. All rights reserved.
//

import UIKit
//import Presentr

class FollowersViewController: UIViewController {

    @IBOutlet weak var tblFollowers: UITableView!
    @IBOutlet weak var txtSearch: UITextField!
    @IBOutlet weak var lblNOResult: UILabel!
    @IBOutlet weak var btnClose: UIButton!
    
    let kHeader = "FollowHeader"
    var listType:FollowerType!
    var arraySearch = [FollowerDAO]()
    var isSearchEnable:Bool! = false
    var isEditingEnable:Bool! = true
    var hudView  : LoadingView!
    var hudRefreshView : LoadingView!
    var refresher: UIRefreshControl?
  
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        prepareLayout()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        prepareTableview()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func prepareLayout(){
        self.lblNOResult.isHidden = true
        self.lblNOResult.text = "No Record Found."
        txtSearch.addTarget(self, action: #selector(self.textFieldEditingChange(sender:)), for: UIControlEvents.editingChanged)
        self.title = listType.rawValue
        self.setupRefreshLoader()
     
    }
    // MARK:- LoaderSetup
    
    func setupLoader() {
        hudView  = LoadingView.init(frame: view.frame)
        view.addSubview(hudView)
        hudView.translatesAutoresizingMaskIntoConstraints = false
        hudView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        hudView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        hudView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        hudView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        hudView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        hudView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        DispatchQueue.main.async {
            self.hudView.startLoaderWithAnimation()
        }
    }
    // MARK:- pull to refresh LoaderSetup
    
    func setupRefreshLoader() {
        if self.refresher == nil {
            self.refresher = UIRefreshControl.init(frame: CGRect(x: 0, y: 0, width: self.tblFollowers.frame.size.width, height: 100))
            
            hudRefreshView  = LoadingView.init(frame: (self.refresher?.frame)!)
            hudRefreshView.load?.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0)
            hudRefreshView.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0)
            hudRefreshView.loaderImage?.isHidden = true
            hudRefreshView.load?.frame = CGRect(x: 0, y: (self.refresher?.frame.width)!/2-30, width: 30, height: 30)
            hudRefreshView.load?.translatesAutoresizingMaskIntoConstraints = false
            hudRefreshView.load?.widthAnchor.constraint(equalToConstant: 30).isActive = true
            hudRefreshView.load?.heightAnchor.constraint(equalToConstant: 30).isActive = true
            hudRefreshView.load?.lineWidth = 3.0
            hudRefreshView.load?.duration = 2.0
            self.refresher?.addSubview(hudRefreshView)
            
            self.tblFollowers!.alwaysBounceVertical = true
            self.refresher?.tintColor = UIColor.clear
            self.refresher?.addTarget(self, action: #selector(pullToDownAction), for: .valueChanged)
            self.tblFollowers!.addSubview(refresher!)
            
        }
    }
    @objc func pullToDownAction() {
        
        self.refresher?.frame = CGRect(x: 0, y: 0, width: self.tblFollowers.frame.size.width, height: 100)
        SharedData.sharedInstance.nextStreamString = ""
        self.hudRefreshView.startLoaderWithAnimation()
        self.tblFollowers.isUserInteractionEnabled = false
        if listType == FollowerType.Follower {
            self.getFollowers(type: .start)
        }else {
            self.getFollowing(type: .start)
        }
        
    }
    
    @objc func resignRefreshLoader(){
        self.refresher?.endRefreshing()
        if hudRefreshView != nil {
            hudRefreshView.stopLoaderWithAnimation()
        }
        self.refresher?.frame = CGRect.zero
    }
    
    func streaminputDataType(type:RefreshType) {
        if(type == .start){
            if hudView != nil {
                self.hudView.stopLoaderWithAnimation()
            }
            self.resignRefreshLoader()
        }
        else{
            self.resignRefreshLoader()
        }
    }
    func prepareTableview(){
        if isSearchEnable {
            self.textFieldEditingChange(sender: txtSearch)
        }else {
         
            if listType == FollowerType.Follower {
                self.getFollowers(type: .start)
            }else {
                self.getFollowing(type: .start)
            }
        }
    }

  
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
    
    @IBAction func btnCloseAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func textFieldEditingChange(sender:UITextField) {
        if self.isSearchEnable == false {

        }
        self.isSearchEnable = true
        self.arraySearch.removeAll()
        self.tblFollowers.reloadData()
        
      
        isEditingEnable = true
        if listType == .Follower {
            self.searchFollowerUser(text: (sender.text?.trim())!)
        }else {
            self.searchFollowingUser(text: (sender.text?.trim())!)
        }
    }
    
    func getFollowers(type:RefreshType){
        self.lblNOResult.isHidden = true
        APIServiceManager.sharedInstance.apiForUserFollowerList(type: type) { (refreshType, errorMsg) in
            
            if self.hudView != nil {
                self.hudView.stopLoaderWithAnimation()
            }
            
            if self.hudRefreshView != nil {
                self.hudRefreshView.stopLoaderWithAnimation()
            }
            self.streaminputDataType(type: type)
            DispatchQueue.main.async {
                self.tblFollowers.reloadData()
            }

            if !(errorMsg?.isEmpty)! {
              self.showToastIMsg(type: .success, strMSG: errorMsg!)
            }
            
        }
    }
    func getFollowing(type:RefreshType){
        self.lblNOResult.isHidden = true
        APIServiceManager.sharedInstance.apiForUserFollowingList(type: type) { (refreshType, errorMsg) in
            if self.hudView != nil {
                self.hudView.stopLoaderWithAnimation()
            }
            
            if self.hudRefreshView != nil {
                self.hudRefreshView.stopLoaderWithAnimation()
            }
            self.streaminputDataType(type: type)
            DispatchQueue.main.async {
                self.tblFollowers.reloadData()
            }
            if !(errorMsg?.isEmpty)! {
              self.showToastIMsg(type: .success, strMSG: errorMsg!)
            }
        }
    }
    
    func followUser(userID:String,index:Int){
      
        APIServiceManager.sharedInstance.apiForFollowUser(userID: userID) { (isSuccess, errorMSG) in
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
               
                self.tblFollowers.reloadData()
                NotificationCenter.default.post(name: NSNotification.Name(kProfileUpdateIdentifier ), object: nil)
            }else {
              self.showToastIMsg(type: .success, strMSG: errorMSG!)
            }
        }
    }
    func unFollowUser(userID:String,index:Int){
       
        APIServiceManager.sharedInstance.apiForUnFollowUser(userID: userID) { (isSuccess, errorMSG) in
         
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
                self.tblFollowers.reloadData()
                NotificationCenter.default.post(name: NSNotification.Name(kProfileUpdateIdentifier ), object: nil)
                if FollowList.sharedInstance.arrayFollowers.count == 0 {
                  
                }
            }else {
               self.showToastIMsg(type: .success, strMSG: errorMSG!)
            }
        }
    }
    
    func searchFollowerUser(text:String) {
        self.lblNOResult.isHidden = true
        APIServiceManager.sharedInstance.apiForFollowerUserSearch(name: text) { (results, errorMSG) in
            if (errorMSG?.isEmpty)! {
                self.arraySearch = results!
                self.tblFollowers.reloadData()
                self.isEditingEnable = true
                self.lblNOResult.isHidden = true
                if self.arraySearch.count == 0 {
                    self.lblNOResult.isHidden = false
                }
            }
        }
    }
    func searchFollowingUser(text:String) {
        self.lblNOResult.isHidden = true
        APIServiceManager.sharedInstance.apiForFollowingUserSearch(name: text) { (results, errorMSG) in
            if (errorMSG?.isEmpty)! {
                self.arraySearch = results!
                self.tblFollowers.reloadData()
                self.isEditingEnable = true
                self.lblNOResult.isHidden = true
                if self.arraySearch.count == 0 {
                    self.lblNOResult.isHidden = false
                }
            }
        }
    }
    
    
    func unFollowUser(follow:FollowerDAO,index:Int){
        var name = follow.fullName
        if !follow.displayName.trim().isEmpty {
            name = follow.displayName.trim()
        }
        let alert = UIAlertController(title: kAlert_Message, message: String(format: kAlert_UnFollow_a_User,name!), preferredStyle: .alert)
        let yes = UIAlertAction(title: kAlertTitle_Unfollow, style: .default) { (action) in
            self.unFollowUser(userID: follow.userId, index: index)
        }
        let no = UIAlertAction(title: kAlert_Cancel_Title, style: .default) { (action) in
        }
        alert.addAction(yes)
        alert.addAction(no)
        self.present(alert, animated: true, completion: nil)
    }
    
    
    func showToastIMsg(type:AlertType,strMSG:String) {
        self.view.makeToast(message: strMSG,
                            duration: TimeInterval(3.0),
                            position: .top,
                            image: nil,
                            backgroundColor: UIColor.black.withAlphaComponent(0.6),
                            titleColor: UIColor.yellow,
                            messageColor: UIColor.white,
                            font: nil)
    }
}


extension FollowersViewController:UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate {
    
    
    func numberOfSections(in tableView: UITableView) -> Int  {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        }else {
            if isSearchEnable {
                return self.arraySearch.count
            }else {
                return FollowList.sharedInstance.arrayFollowers.count
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:FollowerCell = tableView.dequeueReusableCell(withIdentifier: kCell_FollowerCell, for: indexPath) as! FollowerCell
        if indexPath.section == 0 {
            cell.viewMessage.isHidden = false
            cell.ViewUser.isHidden = true
        }else {
            if isSearchEnable {
                let follow = arraySearch[indexPath.row]
                cell.prepareData(follow:follow,type:listType)
            }else {
                let follow = FollowList.sharedInstance.arrayFollowers[indexPath.row]
                cell.prepareData(follow:follow,type:listType)
            }
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
           
    //customPresentViewController(customOrientationPresenter, viewController: popupViewController, animated: true)
        }else {
            var people:FollowerDAO!
            if isSearchEnable {
                people = self.arraySearch[indexPath.row]
            }else {
                people = FollowList.sharedInstance.arrayFollowers[indexPath.row]
            }
            let objPeople = PeopleDAO(peopleData: [:])
            objPeople.fullName = people.fullName
            objPeople.userId = people.userId
            objPeople.userProfileID = people.userProfileID
            objPeople.userImage = people.userImage
            objPeople.phoneNumber = people.phone
            let obj:ViewProfileViewController = self.storyboard!.instantiateViewController(withIdentifier: kStoryboardID_UserProfileView) as! ViewProfileViewController
            obj.objPeople = objPeople
            self.present(obj, animated: false, completion: nil)
        }
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        print("Editing Begin")
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        if !(txtSearch.text?.trim().isEmpty)! {
            self.textFieldEditingChange(sender: txtSearch)
        }
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        print("Editing ended")
        if (txtSearch.text?.trim().isEmpty)! {
           // self.configureLoadMoreAndRefresh()
            self.isSearchEnable = false
            self.tblFollowers.reloadData()
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return isEditingEnable
    }
   
    
}
