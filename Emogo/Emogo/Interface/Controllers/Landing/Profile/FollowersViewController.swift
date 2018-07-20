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
    @IBOutlet weak var txtSearch: UITextField!
    @IBOutlet weak var lblNOResult: UILabel!

    let kHeader = "FollowHeader"
    var listType:FollowerType!
    var arraySearch = [FollowerDAO]()
    var isSearchEnable:Bool! = false
    var isEditingEnable:Bool! = true
    
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
    
   
//    lazy var popupViewController: AddCollaboratorContactsController = {
//        let popupViewController = self.storyboard?.instantiateViewController(withIdentifier: kStoryboardID_AddCollaboratorContactsView)
//        return popupViewController as! AddCollaboratorContactsController
    //}()
    
    
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
        self.configureNavigationWithTitle()
        self.title = listType.rawValue
        self.configureLoadMoreAndRefresh()
    }
    
    
    func prepareTableview(){
        self.tblFollowers.tableFooterView = UIView()
        if isSearchEnable {
            self.textFieldEditingChange(sender: txtSearch)
        }else {
            HUDManager.sharedInstance.showHUD()
            if listType == FollowerType.Follower {
                self.getFollowers(type: .start)
            }else {
                self.getFollowing(type: .start)
            }
        }
    }

    
    func configureLoadMoreAndRefresh(){
        let header:ESRefreshProtocol & ESRefreshAnimatorProtocol = RefreshHeaderAnimator(frame: .zero)
        let  footer: ESRefreshProtocol & ESRefreshAnimatorProtocol = RefreshFooterAnimator(frame: .zero)
        
        self.tblFollowers.es.addPullToRefresh(animator: header) { [weak self] in
            UIApplication.shared.beginIgnoringInteractionEvents()
            if self?.listType == FollowerType.Follower {
                self?.getFollowers(type: .up)
            }else {
                self?.getFollowing(type: .up)
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
    
   
    @objc func textFieldEditingChange(sender:UITextField) {
        if self.isSearchEnable == false {
            self.tblFollowers.es.removeRefreshFooter()
            self.tblFollowers.es.removeRefreshHeader()
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
        self.lblNOResult.isHidden = true

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
                self.tblFollowers.reloadData()
                NotificationCenter.default.post(name: NSNotification.Name(kProfileUpdateIdentifier ), object: nil)
                if FollowList.sharedInstance.arrayFollowers.count == 0 {
                    self.navigationController?.pop()
                }
            }else {
                self.showToast(strMSG: errorMSG!)
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
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}


extension FollowersViewController:UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate {
    
    
    func numberOfSections(in tableView: UITableView) -> Int  {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
         //   return 1
            return 0
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
        if section == 0 {
            return 0
        }else {
            return 50
        }
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
            let obj:ViewProfileViewController = kStoryboardStuff.instantiateViewController(withIdentifier: kStoryboardID_UserProfileView) as! ViewProfileViewController
            obj.objPeople = objPeople
            self.navigationController?.push(viewController: obj)
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
            self.configureLoadMoreAndRefresh()
            self.isSearchEnable = false
            self.tblFollowers.reloadData()
        }
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return isEditingEnable
    }
   
    
}
