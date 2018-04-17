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
    
    @IBOutlet weak var lblBio: UILabel!
    @IBOutlet weak var lblFullName: UILabel!
    @IBOutlet weak var lblWebsite: UILabel!
    @IBOutlet weak var lblLocation: UILabel!
    @IBOutlet weak var imgUser: NZCircularImageView!
    @IBOutlet weak var btnStream: UIButton!
    @IBOutlet weak var btnColab: UIButton!
    @IBOutlet weak var lblNOResult: UILabel!
    @IBOutlet weak var imgLocation: UIImageView!
    @IBOutlet weak var imgLink: UIImageView!
    @IBOutlet weak var btnContainer: UIView!
    @IBOutlet weak var kHeaderHeight: NSLayoutConstraint!
    
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
        let btnFlag = UIBarButtonItem(image: #imageLiteral(resourceName: "stream_flag"), style: .plain, target: self, action: #selector(self.showReportList))
        self.navigationItem.rightBarButtonItem = btnFlag
        self.profileCollectionView.dataSource  = self
        self.profileCollectionView.delegate = self
        profileCollectionView.alwaysBounceVertical = true
        
        let layout = CHTCollectionViewWaterfallLayout()
        // Change individual layout attributes for the spacing between cells
        layout.minimumColumnSpacing = 8.0
        layout.minimumInteritemSpacing = 8.0
        layout.sectionInset = UIEdgeInsetsMake(0, 8, 0, 8)
        layout.columnCount = 2
        // Collection view attributes
        self.profileCollectionView.autoresizingMask = [UIViewAutoresizing.flexibleHeight, UIViewAutoresizing.flexibleWidth]
        // Add the waterfall layout to your collection view
        self.profileCollectionView.collectionViewLayout = layout
        self.prepareData()
    }
    
    func prepareData(){
        APIServiceManager.sharedInstance.apiForGetUserInfo(userID: objPeople.userId, isCurrentUser: false) { (people, errorMSG) in
            if (errorMSG?.isEmpty)! {
                if let people = people {
                    self.lblFullName.text =  people.fullName.trim().capitalized
                    self.lblFullName.minimumScaleFactor = 1.0
                    self.lblWebsite.text = people.website.trim()
                    self.lblWebsite.minimumScaleFactor = 1.0
                    self.lblLocation.text = people.location.trim()
                    self.lblLocation.minimumScaleFactor = 1.0
                    self.lblBio.text = people.biography.trim()
                    //self.lblBirthday.text = people.birthday.trim()
                    self.title = people.fullName.trim()
                    self.lblBio.minimumScaleFactor = 1.0
                    self.imgLink.isHidden = false
                    self.imgLocation.isHidden = false
                    
                    if people.location.trim().isEmpty {
                        self.imgLocation.isHidden = true
                    }
                    if people.website.trim().isEmpty {
                        self.imgLink.isHidden = true
                    }
                    
                    //print(people.userImage.trim())
                    if !people.userImage.trim().isEmpty {
                        self.imgUser.setImageWithResizeURL(people.userImage.trim())
                    }
                }
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        HUDManager.sharedInstance.showHUD()
        self.getStreamList(type:.start,streamType: "1")
    }
    
    
    @IBAction func btnActionMenuSelected(_ sender: UIButton) {
        self.updateSegment(selected: sender.tag)
    }
    
    
    private func updateSegment(selected:Int){
        switch selected {
        case 101:
            self.btnStream.setImage(#imageLiteral(resourceName: "strems_active_icon"), for: .normal)
            self.btnColab.setImage(#imageLiteral(resourceName: "collabs_icon"), for: .normal)
            self.getStream(type: "1")
            break
        case 102:
            self.btnStream.setImage(#imageLiteral(resourceName: "strems_icon"), for: .normal)
            self.btnColab.setImage(#imageLiteral(resourceName: "collabs_active_icon"), for: .normal)
            self.getStream(type: "2")
            break
        default:
            break
        }
    }
    
    func getStream(type:String){
         HUDManager.sharedInstance.showHUD()
         self.getStreamList(type:.start,streamType: type)
    }
    
    
    override func btnBackAction() {
        
        if  ContentList.sharedInstance.mainStreamNavigate == nil {
            let array = StreamList.sharedInstance.arrayStream.filter { $0.selectionType == currentStreamType }
            StreamList.sharedInstance.arrayViewStream = array
        }else {
            if ContentList.sharedInstance.mainStreamNavigate == "fromProfile" {
                let array = StreamList.sharedInstance.arrayProfileStream.filter { $0.isAdd == false }
                StreamList.sharedInstance.arrayViewStream = array
            }else {
                let array = StreamList.sharedInstance.arrayStream.filter { $0.selectionType == currentStreamType }
                StreamList.sharedInstance.arrayViewStream = array
            }
        }
        
        self.navigationController?.pop()
        
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
    
    func getStreamList(type:RefreshType,streamType:String){
        if type == .start || type == .up {
            StreamList.sharedInstance.arrayMyStream.removeAll()
            self.profileCollectionView.reloadData()
        }
        APIServiceManager.sharedInstance.apiForGetUserStream(userID: objPeople.userId,type: type,streamType: streamType) { (refreshType, errorMsg) in
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
            if StreamList.sharedInstance.arrayMyStream.count == 0 {
                let label = UILabel(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 30))
                label.text = "No Streams Found!"
                label.sizeToFit()
                label.center = self.profileCollectionView.center
                self.view.addSubview(label)
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



extension ViewProfileViewController:UICollectionViewDelegate,UICollectionViewDataSource,UIScrollViewDelegate,CHTCollectionViewDelegateWaterfallLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            return StreamList.sharedInstance.arrayMyStream.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // Create the cell and return the cell
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: kCell_ProfileStreamCell, for: indexPath) as! ProfileStreamCell
            cell.layer.cornerRadius = 5.0
            cell.layer.masksToBounds = true
            cell.isExclusiveTouch = true
            let stream = StreamList.sharedInstance.arrayMyStream[indexPath.row]
            cell.prepareLayouts(stream: stream)
            cell.lblName.text = ""
            cell.lblName.isHidden = true
            return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: IndexPath) -> CGSize {
        let itemWidth = collectionView.bounds.size.width/2.0
        return CGSize(width: itemWidth, height: itemWidth - 40)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        ContentList.sharedInstance.mainStreamIndex = nil
        StreamList.sharedInstance.arrayViewStream = StreamList.sharedInstance.arrayMyStream
        let obj:ViewStreamController = kStoryboardMain.instantiateViewController(withIdentifier: kStoryboardID_viewStream) as! ViewStreamController
        obj.currentIndex = indexPath.row
        obj.streamType = currentStreamType.rawValue
        obj.viewStream = "View"
        ContentList.sharedInstance.objStream = nil
        self.navigationController?.push(viewController: obj)
        
    }
}

