//
//  ProfileViewController.swift
//  Emogo
//
//  Created by Pushpendra on 13/12/17.
//  Copyright © 2017 Vikas Goyal. All rights reserved.
//

import UIKit


enum ProfileMenu:String{
    case stream = "1"
    case colabs = "2"
    case stuff = "3"
}


class ProfileViewController: UIViewController {

    
    // MARK: - UI Elements
    
    @IBOutlet weak var profileCollectionView: UICollectionView!
    @IBOutlet weak var lblUserName: UILabel!
    @IBOutlet weak var imgUser: UIImageView!
    @IBOutlet weak var btnStream: UIButton!
    @IBOutlet weak var btnColab: UIButton!
    @IBOutlet weak var btnStuff: UIButton!

    
    var currentMenu:ProfileMenu! = .stream
    var objProfile:ProfileDAO!
    
    // MARK: - Override Functions

    override func viewDidLoad() {
        super.viewDidLoad()
            self.prepareLayouts()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: - Prepare Layouts
    
    func prepareLayouts(){
        self.title = "Profile"
        self.configureProfileNavigation()
    //    self.userProfile()
    }
    
    
     // MARK: -  Action Methods And Selector
    
    @IBAction func btnActionMenuSelected(_ sender: UIButton) {
       self.updateSegment(selected: sender.tag)
    }
    

    
  private func updateSegment(selected:Int){
        switch selected {
        case 101:
            self.btnStream.setImage(#imageLiteral(resourceName: "strems_active_icon"), for: .normal)
            self.btnColab.setImage(#imageLiteral(resourceName: "collabs_icon"), for: .normal)
            self.btnStuff.setImage(#imageLiteral(resourceName: "stuff_icon"), for: .normal)
            self.currentMenu = .stream
            break
        case 102:
            self.btnStream.setImage(#imageLiteral(resourceName: "strems_icon"), for: .normal)
            self.btnColab.setImage(#imageLiteral(resourceName: "collabs_active_icon"), for: .normal)
            self.btnStuff.setImage(#imageLiteral(resourceName: "stuff_icon"), for: .normal)
            self.currentMenu = .colabs
            break
        case 103:
            self.btnStream.setImage(#imageLiteral(resourceName: "strems_icon"), for: .normal)
            self.btnColab.setImage(#imageLiteral(resourceName: "collabs_icon"), for: .normal)
            self.btnStuff.setImage(#imageLiteral(resourceName: "stuff_active_icon"), for: .normal)
            self.currentMenu = .stuff
            break
        default:
            break
        }
    self.profileCollectionView.reloadData()
    }
    
    
    override func btnLogoutAction() {
         let alert = UIAlertController(title: "Confirmation!", message: "Are you sure, You want to logout?", preferredStyle: .alert)
         let yes = UIAlertAction(title: "YES", style: .default) { (action) in
         alert.dismiss(animated: true, completion: nil)
         kDefault?.set(false, forKey: kUserLogggedIn)
         let obj = kStoryboardMain.instantiateViewController(withIdentifier: kStoryboardID_InitialView)
         self.navigationController?.reverseFlipPush(viewController: obj)
         }
         let no = UIAlertAction(title: "NO", style: .default) { (action) in
         alert.dismiss(animated: true, completion: nil)
         }
         alert.addAction(yes)
         alert.addAction(no)
         present(alert, animated: true, completion: nil)
    }
    
    // MARK: - API

    
    func userProfile(){
       // HUDManager.sharedInstance.showHUD()
        APIServiceManager.sharedInstance.apiForGetUserInfo(user: UserDAO.sharedInstance.user.userId!) { (profile, errorMsg) in
            HUDManager.sharedInstance.hideHUD()
            if (errorMsg?.isEmpty)! {
                self.objProfile = profile
            }else {
                self.showToast(strMSG: errorMsg!)
            }
            self.profileCollectionView.reloadData()
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




extension ProfileViewController:UICollectionViewDelegate,UICollectionViewDataSource,UIScrollViewDelegate,UICollectionViewDelegateFlowLayout {
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if objProfile == nil {
            return 0
        }else {
            if currentMenu == .stream {
                return self.objProfile.arrayStream.count
            }else if currentMenu == .colabs {
                return self.objProfile.arrayColabs.count
            }else {
                return self.objProfile.arrayContents.count
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // Create the cell and return the cell
        if currentMenu == .colabs {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: kCell_PeopleCell, for: indexPath) as! PeopleCell
            let people =
               self.objProfile.arrayColabs[indexPath.row]
            cell.prepareData(people:people)
            return cell
            
        }else  if currentMenu == .stream {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: kCell_ProfileStreamCell, for: indexPath) as! ProfileStreamCell
            cell.layer.cornerRadius = 5.0
            cell.layer.masksToBounds = true
            cell.isExclusiveTouch = true
            let stream = self.objProfile.arrayStream[indexPath.row]
            cell.prepareLayouts(stream: stream)
            return cell
        }else {
          //  let content = self.objProfile.arrayContents[indexPath.row]
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: kCell_StreamContentCell, for: indexPath) as! StreamContentCell
            // for Add Content
            cell.layer.cornerRadius = 5.0
            cell.layer.masksToBounds = true
            cell.isExclusiveTouch = true
           // cell.prepareLayout(content:content)
            return cell
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if currentMenu == .colabs  {
            let itemWidth = collectionView.bounds.size.width/3.0 - 12.0
            return CGSize(width: itemWidth, height: 100)
        }else {
            let itemWidth = collectionView.bounds.size.width/2.0 - 12.0
            return CGSize(width: itemWidth, height: itemWidth)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
       
         }
}
