//
//  CollaboratorViewController.swift
//  iMessageExt
//
//  Created by Sushobhit on 05/12/17.
//  Copyright © 2017 Vikas Goyal. All rights reserved.
//

import UIKit
import Messages

class CollaboratorViewController: MSMessagesAppViewController {

    //MARK: - UI Elements
    @IBOutlet weak var collectionCollaborator   : UICollectionView!
    @IBOutlet weak var btnBack                  : UIButton!
    @IBOutlet weak var lblTitle                 : UILabel!
    
    //MARK: - Variables
    var arrCollaborator                         : [CollaboratorDAO]!
    var strTitle                                : String!
    
    //MARK: - Life-Cycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        self.prepareLayout()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        setupCollectionProperties()
    }
    //MARK: - Life-Cycle methods
    func prepareLayout() {
        self.btnBack.transform = self.btnBack.transform.rotated(by: -CGFloat(Double.pi / 2))
       lblTitle.text = "\(strTitle!)"
    }
    
    //MARK: - Setup collection Properties
    func setupCollectionProperties() {
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 20, left: 10, bottom: 20, right: 10)
               layout.itemSize = CGSize(width: self.collectionCollaborator.frame.size.width/3 - 12.0, height: self.collectionCollaborator.frame.size.width/3 )
//        layout.itemSize = CGSize(width: self.collectionCollaborator.frame.size.width/3 - 1, height: 100)
        layout.minimumInteritemSpacing = 1
        layout.minimumLineSpacing = 10
        collectionCollaborator!.collectionViewLayout = layout
        
        collectionCollaborator.delegate = self
        collectionCollaborator.dataSource = self
    }
    
    //MARK: - Action Methods
    @IBAction func btnClose(_ sender:UIButton){
     self.dismiss(animated: true, completion: nil)
    }
    
}

//MARK: - Extension Collection Delegate
extension CollaboratorViewController : UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.arrCollaborator.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell : CollaboratorCollectionViewCell = self.collectionCollaborator.dequeueReusableCell(withReuseIdentifier: iMgsSegue_CollaboratorCollectionCell, for: indexPath) as! CollaboratorCollectionViewCell
       
        cell.prepareLayout(content: self.arrCollaborator[indexPath.row])
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let collaborator = self.arrCollaborator[indexPath.row]
        //  print(collaborator.userID)
        //  print(UserDAO.sharedInstance.user.userId)
        //  print(UserDAO.sharedInstance.user.userProfileID)
        
        if collaborator.userID != "" {
            if collaborator.userID.trim() == UserDAO.sharedInstance.user.userProfileID.trim() {
                let obj : ProfileViewController = self.storyboard!.instantiateViewController(withIdentifier: kStoryboardID_ProfileView) as! ProfileViewController
               obj.strBackFromColab = "backFromColab" 
               self.present(obj, animated: false, completion: nil)
                
            }else {
                let people = PeopleDAO(peopleData:[:])
                people.fullName = collaborator.name
                people.userProfileID = collaborator.userID
                //  people.userProfileID =
                let obj:ViewProfileViewController = self.storyboard!.instantiateViewController(withIdentifier: kStoryboardID_UserProfileView) as! ViewProfileViewController
                obj.objPeople = people
               self.present(obj, animated: false, completion: nil)
            }
            
        }else{
            self.showToastIMsg(type: AlertType.error,strMSG: "Seems user is not registered with Emogo yet!")
        }
        
   
//        let userInfo = self.arrCollaborator[indexPath.row]
//        if userInfo.userID.isEmpty {
//            self.showToastIMsg(type: AlertType.error, strMSG: "User not found.")
//            return
//        }else if userInfo.userID.trim() == UserDAO.sharedInstance.user.userProfileID.trim() {
//                let obj : ProfileViewController = self.storyboard!.instantiateViewController(withIdentifier: kStoryboardID_ProfileView) as! ProfileViewController
//                self.present(obj, animated: false, completion: nil)
//        }
//
//        else{
//        let people = PeopleDAO(peopleData:[:])
//        people.fullName = userInfo.name
//        people.userProfileID = userInfo.userID
//         let obj:ViewProfileViewController = self.storyboard!.instantiateViewController(withIdentifier: kStoryboardID_UserProfileView) as! ViewProfileViewController
//        obj.objPeople = people
//        self.present(obj, animated: false, completion: nil)
//        }
     
//        let alert = UIAlertController(title: kAlert_Title_Confirmation, message: kAlert_Confirmation_Description_For_People , preferredStyle: .alert)
//        let yes = UIAlertAction(title: kAlert_Confirmation_Button_Title, style: .default) { (action) in
//            let str = self.createURLWithComponents(userInfo: userInfo, urlString: "")
//            SharedData.sharedInstance.presentAppViewWithDeepLink(strURL: str!)
//        }
//        let no = UIAlertAction(title: kAlert_Cancel_Title, style: .default) { (action) in
//            alert.dismiss(animated: true, completion: nil)
//        }
//        alert.addAction(yes)
//        alert.addAction(no)
//        present(alert, animated: true, completion: nil)
    }
    
    func createURLWithComponents(userInfo: CollaboratorDAO, urlString:String) -> String? {
        // create "https://api.nasa.gov/planetary/apod" URL using NSURLComponents
        let urlComponents = NSURLComponents()
        urlComponents.scheme = "Emogo";
        urlComponents.host = "emogo"
        
        // add params
        let fullName = URLQueryItem(name: "fullName", value: userInfo.name!)
        let phoneNumber = URLQueryItem(name: "phoneNumber", value: userInfo.phone!)
        let userId = URLQueryItem(name: "userId", value: userInfo.userID!)
        let userProfileId = URLQueryItem(name: "user_profile_id", value: userInfo.userID!)
        let userImage = URLQueryItem(name: "userImage", value: userInfo.imgUser!)
        urlComponents.queryItems = [fullName, phoneNumber, userId, userImage,userProfileId]
        let strURl = "\(urlComponents.url!)/\(kDeepLinkTypePeople)"
        print(strURl)
        return strURl
    }
}
