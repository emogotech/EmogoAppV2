//
//  ViewProfileViewController.swift
//  Emogo
//
//  Created by Pushpendra on 13/12/18.
//  Copyright © 2018 Vikas Goyal. All rights reserved.
//

import UIKit

class ViewProfileViewController: UIViewController {
    
    @IBOutlet weak var profileCollectionView: UICollectionView!
    
    var objPeople:PeopleDAO!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        prepareLayouts()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func prepareLayouts(){
        self.title = objPeople.fullName
        self.configureNavigationWithTitle()
        let btnFlag = UIBarButtonItem(image: #imageLiteral(resourceName: "user_flag"), style: .plain, target: self, action: #selector(self.showReportList))
        self.navigationItem.rightBarButtonItem = btnFlag
        self.profileCollectionView.dataSource  = self
        self.profileCollectionView.delegate = self
        profileCollectionView.alwaysBounceVertical = true
        HUDManager.sharedInstance.showHUD()
        self.getStreamList(type:.start)
    }
    
    

    @objc func showReportList(){
        let optionMenu = UIAlertController(title: kAlert_Title_ActionSheet, message: "", preferredStyle: .actionSheet)
        
        let saveAction = UIAlertAction(title: kAlertSheet_Spam, style: .destructive, handler:
        {
            (alert: UIAlertAction!) -> Void in
            
            APIServiceManager.sharedInstance.apiForSendReport(type: kName_Report_Spam, user: self.objPeople.userId!, stream: "", content: "", completionHandler: { (isSuccess, error) in
                self.showToast(type: AlertType.success, strMSG: kAlert_Success_Report_User)
            })
            
        })
        
        let deleteAction = UIAlertAction(title: kAlertSheet_Inappropiate, style: .destructive, handler:
        {
            (alert: UIAlertAction!) -> Void in
            APIServiceManager.sharedInstance.apiForSendReport(type: kName_Report_Inappropriate, user: self.objPeople.userId!, stream: "", content: "", completionHandler: { (isSuccess, error) in
                self.showToast(type: AlertType.success, strMSG: kAlert_Success_Report_User)
            })
        })
        
        let cancelAction = UIAlertAction(title: kAlert_Cancel_Title, style: .cancel, handler:
        {
            (alert: UIAlertAction!) -> Void in
            
        })
        optionMenu.addAction(deleteAction)
        optionMenu.addAction(saveAction)
        optionMenu.addAction(cancelAction)
        self.present(optionMenu, animated: true, completion: nil)
    }
    
    func getStreamList(type:RefreshType){
        if type == .start || type == .up {
            StreamList.sharedInstance.arrayStream.removeAll()
            self.profileCollectionView.reloadData()
        }
        APIServiceManager.sharedInstance.apiForGetUserStream(userID: objPeople.userId,type: type) { (refreshType, errorMsg) in
            if type == .start {
                HUDManager.sharedInstance.hideHUD()
            }
            if refreshType == .end {
                self.profileCollectionView.es.noticeNoMoreData()
            }
            if type == .up {
                UIApplication.shared.endIgnoringInteractionEvents()
                self.profileCollectionView.es.stopPullToRefresh()
            }else if type == .down {
                self.profileCollectionView.es.stopLoadingMore()
            }
            if StreamList.sharedInstance.arrayStream.count == 0 {
            }
            self.profileCollectionView.reloadData()
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



extension ViewProfileViewController:UICollectionViewDelegate,UICollectionViewDataSource,UIScrollViewDelegate,UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            return StreamList.sharedInstance.arrayStream.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // Create the cell and return the cell
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: kCell_ProfileStreamCell, for: indexPath) as! ProfileStreamCell
            cell.layer.cornerRadius = 5.0
            cell.layer.masksToBounds = true
            cell.isExclusiveTouch = true
            let stream = StreamList.sharedInstance.arrayStream[indexPath.row]
            cell.prepareLayouts(stream: stream)
            return cell
            
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let itemWidth = collectionView.bounds.size.width/2.0 - 12.0
        return CGSize(width: itemWidth, height: itemWidth)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let obj:ViewStreamController = kStoryboardMain.instantiateViewController(withIdentifier: kStoryboardID_viewStream) as! ViewStreamController
        obj.currentIndex = indexPath.row
        ContentList.sharedInstance.objStream = nil
        self.navigationController?.push(viewController: obj)
    }
}

