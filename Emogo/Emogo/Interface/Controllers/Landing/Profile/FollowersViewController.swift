//
//  FollowersViewController.swift
//  Emogo
//
//  Created by Pushpendra on 18/04/18.
//  Copyright © 2018 Vikas Goyal. All rights reserved.
//

import UIKit

class FollowersViewController: UIViewController {

    @IBOutlet weak var tblFollowers: UITableView!
    
    let kHeader = "FollowHeader"
    var listType:FollowerType!
    
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
            cell.prepareData(follow:follow)
            cell.viewMessage.isHidden = true
            cell.ViewUser.isHidden = false
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

}
