//
//  AddCollabViewController.swift
//  Emogo
//
//  Created by Northout on 15/06/18.
//  Copyright © 2018 Vikas Goyal. All rights reserved.
//

import UIKit
import Contacts

protocol AddCollabViewControllerDelegate {
    func selectedColabs(arrayColab:[CollaboratorDAO])
}

class AddCollabViewController: UIViewController {
    
    
    //MARK:- IBOutlets Connection
    
    @IBOutlet weak var tblAddCollab: UITableView!
    @IBOutlet weak var btnAdd: UIButton!
    @IBOutlet weak var tfSearch: UITextField!
    @IBOutlet weak var viewSearch: UIView!
    @IBOutlet weak var btnCancel: UIButton!
    @IBOutlet weak var viewAddCollab: UIView!
    @IBOutlet weak var btnInviteFriends: UIButton!
    @IBOutlet weak var kConsViewTop: NSLayoutConstraint!
    
    @IBOutlet weak var imgSearchIcon: UIImageView!
    var arrIndexSection : [String] = ["A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z"]
    var arrayToShow = [Any]()
    var arraySearch = [Any]()
    
    // Varibales
    var arrayCollaborators = [CollaboratorDAO]()
    var arraySelected:[CollaboratorDAO]?
    var isChecked: Bool! = false
    let checkedImage = UIImage(named: "addCollab_check")! as UIImage
    let uncheckedImage = UIImage(named: "addCollab_uncheck")! as UIImage
    let kCell_AddCollabView = "addCollabCell"
    var selectedRows = [IndexPath]()
    var isSearchEnable: Bool! = false
    var delegate:AddCollabViewControllerDelegate?
    var arrayTempSelected = [CollaboratorDAO]()
    var objStream:StreamViewDAO?
    var kOriginalContants:CGFloat = 0.0
  // var consTopHeight = CGSize.zero
    

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tblAddCollab.delegate = self
        tfSearch.delegate = self
        self.tblAddCollab.dataSource = self
        tblAddCollab.sectionIndexColor = UIColor.lightGray
        self.viewAddCollab.isHidden = false
        self.viewAddCollab.cornerRadius = 15.0
        self.viewAddCollab.clipsToBounds = true
        // self.tblAddCollab.rowHeight = UITableViewAutomaticDimension
        //  self.tblAddCollab.estimatedRowHeight = 250
        self.prepareLayouts()
      
         self.navigationController?.isNavigationBarHidden = true
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super .viewDidAppear(true)
        kOriginalContants =  self.kConsViewTop.constant
        print(kOriginalContants)
        self.tblAddCollab.reloadData()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func prepareLayouts(){
      //  self.btnAdd.isHidden = true
        if self.arraySelected != nil {
            self.arrayCollaborators = self.arraySelected!
         //   self.btnAdd.isHidden = false
        }
        self.tblAddCollab.separatorStyle = .none
        self.getContacts()
        self.navigationController?.isNavigationBarHidden = false
    
        var button = UIButton(type: .system)
        button =  self.getShadowButton(Alignment: 0)
        button.frame = CGRect(x: 10, y: -12, width: 60, height: 40)
        button.setTitle("CANCEL", for: .normal)
        button.titleLabel?.font = UIFont(name: kFontRegular, size: 11.0)
        button.setTitleColor(UIColor(r: 74, g: 74, b: 74), for: .normal)
        button.addTarget(self, action: #selector(self.cancelButtonAction), for: .touchUpInside)
        self.viewAddCollab.addSubview(button)

        var button1 = UIButton(type: .system)
        button1 =  self.getShadowButton(Alignment: 1)
        button1.frame = CGRect(x: viewAddCollab.frame.size.width - 80, y: -5, width: 60, height: 40)
        button1.titleLabel?.numberOfLines = 0;
        button1.setTitle("INVITE\nFRIENDS", for: .normal)
        button1.titleLabel?.font = UIFont(name: kFontMedium, size: 11.0)
        button1.setTitleColor(UIColor(r: 0, g: 122, b: 255), for: .normal)
        button1.addTarget(self, action: #selector(self.inviteButtonAction), for: .touchUpInside)
        self.viewAddCollab.addSubview(button1)

        self.title = "Add Collaborators"

        tfSearch.addTarget(self, action: #selector(self.textFieldEditingChange(sender:)), for: UIControlEvents.editingChanged)

    }
    

    
    func prepareNavBarButtons(){
        
        self.navigationController?.isNavigationBarHidden = false
        
        let button = self.getShadowButton(Alignment: 0)
        button.setTitle("CANCEL", for: .normal)
        button.titleLabel?.font = UIFont(name: kFontRegular, size: 11.0)
        button.setTitleColor(UIColor(r: 74, g: 74, b: 74), for: .normal)
        button.addTarget(self, action: #selector(self.cancelButtonAction), for: .touchUpInside)
        let btnBack = UIBarButtonItem.init(customView: button)
        
        self.navigationItem.leftBarButtonItem = btnBack
        
        let button1 = self.getShadowButton(Alignment: 1)
        button1.frame = CGRect(x: 0, y: 0, width: 60, height: 40)
        button1.titleLabel?.numberOfLines = 0;
        button1.setTitle("INVITE\nFRIENDS", for: .normal)
        button1.titleLabel?.font = UIFont(name: kFontMedium, size: 11.0)
        button1.setTitleColor(UIColor(r: 0, g: 122, b: 255), for: .normal)
        button1.addTarget(self, action: #selector(self.inviteButtonAction), for: .touchUpInside)
        let btnInvite = UIBarButtonItem.init(customView: button1)
        
        self.navigationItem.rightBarButtonItem = btnInvite
        
        self.title = "Add Collaborators"
    }
    
  
    @IBAction func btnActionAdd(_ sender: Any) {
            print(arrayTempSelected)
        if self.arrayTempSelected.isEmpty == true {
            self.showToast(strMSG: kAlertAddCollab)
            
        }else{
           self.updateColabs()
        }
        
    }
    
    //MARK:- Selector Methods
    @objc func cancelButtonAction(){
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func btnCancelAction(_ sender: Any) {
        self.cancelButtonAction()
    }
    
    @IBAction func btnInviteAction(_ sender: Any) {
        self.inviteButtonAction()
    }
    
    @objc func inviteButtonAction(){
        
        if UserDAO.sharedInstance.user.shareURL.isEmpty {
            return
        }
        let url:URL = URL(string: UserDAO.sharedInstance.user.shareURL!)!
        
        let shareItem =  "Collaborate with me on emogo!"
        
        // let shareItem = "Hey checkout the s profile,emogo"
        let activityViewController: UIActivityViewController = UIActivityViewController(activityItems: [shareItem,url], applicationActivities:nil)
        //  activityViewController.excludedActivityTypes = [.print, .copyToPasteboard, .assignToContact, .saveToCameraRoll, .airDrop]
        
        DispatchQueue.main.async {
            self.present(activityViewController, animated: true, completion: nil);
        }
    }
    @objc func btnCheckedClicked(sender: UIButton) {
        guard let indexPath = self.tblAddCollab.indexPath(for: sender.superview?.superview?.superview as! AddCollabCell) else {
            return
        }
        
        var dictColabContact:CollaboratorDAO!
        if self.isSearchEnable {
            var array:[CollaboratorDAO] = (self.arraySearch[indexPath.section] as! [String:Any])["value"] as! [CollaboratorDAO]
            dictColabContact = array[indexPath.row]
        }else {
            var array:[CollaboratorDAO] = (self.arrayToShow[indexPath.section] as! [String:Any])["value"] as! [CollaboratorDAO]
            dictColabContact = array[indexPath.row]
        }
        
        if dictColabContact != nil {
            dictColabContact.isSelected = !dictColabContact.isSelected
            if self.arrayTempSelected.contains(where: {$0.phone.trim() == dictColabContact.phone.trim()}) {
                if let mainIndex =  self.arrayTempSelected.index(where: {$0.phone.trim() == dictColabContact.phone.trim()}) {
                    self.arrayTempSelected.remove(at: mainIndex)
                }
                if let mainIndex =  self.arrayCollaborators.index(where: {$0.phone.trim() == dictColabContact.phone.trim()}) {
                    self.arrayCollaborators[mainIndex] = dictColabContact
                }
            }else  {
                self.arrayTempSelected.append(dictColabContact)
                if let mainIndex =  self.arrayCollaborators.index(where: {$0.phone.trim() == dictColabContact.phone.trim()}) {
                    self.arrayCollaborators[mainIndex] = dictColabContact
                }
            }
            
        }
        
        var tempColabArray  = [CollaboratorDAO]()
        if self.isSearchEnable {
         for obj in self.arraySearch {
            let array = (obj as! [String:Any])["value"] as! [CollaboratorDAO]
            for colab in array {
                tempColabArray.append(colab)
            }
        }
        }else {
            tempColabArray = self.arrayCollaborators
        }
       
        self.updateList(arrayColabs: tempColabArray)
        print(self.arrayTempSelected)
//        if self.arrayTempSelected.count == 0 {
//            self.btnAdd.isHidden = true
//        }else {
//            self.btnAdd.isHidden = false
//        }
    }
    
     func btnActionForUserProfile(indexPath:IndexPath) {
        
        var collaborator:CollaboratorDAO!
        if self.isSearchEnable {
            var array:[CollaboratorDAO] = (self.arraySearch[indexPath.section] as! [String:Any])["value"] as! [CollaboratorDAO]
            collaborator = array[indexPath.row]
        }else {
            var array:[CollaboratorDAO] = (self.arrayToShow[indexPath.section] as! [String:Any])["value"] as! [CollaboratorDAO]
            collaborator = array[indexPath.row]
        }
        
        if collaborator.userID.trim() != "" {
            if collaborator.userID.trim() == UserDAO.sharedInstance.user.userProfileID.trim() {
                let obj : ProfileViewController = kStoryboardStuff.instantiateViewController(withIdentifier: kStoryboardID_ProfileView) as! ProfileViewController
                self.navigationController?.push(viewController: obj)
                
            }else {
                let people = PeopleDAO(peopleData:[:])
                people.fullName = collaborator.name
                people.userProfileID = collaborator.userID
                //  people.userProfileID =
                let obj:ViewProfileViewController = kStoryboardStuff.instantiateViewController(withIdentifier: kStoryboardID_UserProfileView) as! ViewProfileViewController
                obj.objPeople = people
                self.navigationController?.push(viewController: obj)
            }
            
        }else{
            self.showToast(strMSG: "Seems user is not registered with Emogo yet!")
        }

    }
    
    // MARK: - Class Methods
    
    func getContacts() {
        let store = CNContactStore()
        
        switch CNContactStore.authorizationStatus(for: .contacts){
        case .authorized:
            self.fetchContactList(store: store)
            break
        case .denied, .restricted :
            self.showPermissionAlert(strMessage: "contacts")
            break
        case .notDetermined:
            store.requestAccess(for: .contacts){succeeded, err in
                guard err == nil && succeeded else{
                    return
                }
                self.fetchContactList(store: store)
            }
            break
            
        }
    }
    
    
    func fetchContactList(store:CNContactStore){
        
        let keysToFetch = [CNContactFormatter.descriptorForRequiredKeys(for: .fullName), CNContactPhoneNumbersKey,CNContactImageDataKey, CNContactEmailAddressesKey] as [Any]
        let request = CNContactFetchRequest(keysToFetch: keysToFetch as! [CNKeyDescriptor])
        var cnContacts = [CNContact]()
        do {
            try store.enumerateContacts(with: request){
                (contact, cursor) -> Void in
                cnContacts.append(contact)
            }
        } catch let error {
            NSLog("Fetch contact error: \(error)")
        }
        
        for contact in cnContacts {
            let fullName = CNContactFormatter.string(from: contact, style: .fullName) ?? "No Name"
            let img:UIImage!
            if let contactImageData = contact.imageData {
                img = UIImage(data: contactImageData)
            }
            var phone:String! = ""
            if contact.phoneNumbers.count != 0 {
                let ContctNumVar = contact.phoneNumbers[0]
                let FulMobNumVar  = ContctNumVar.value
                let MccNamVar = FulMobNumVar.value(forKey: "countryCode") as? String
                let MobNumVar = FulMobNumVar.value(forKey: "digits") as? String
                phone = (MccNamVar?.trim())!  +  (MobNumVar?.trim())!
                let allowedCharactersSet = NSMutableCharacterSet.decimalDigit()
                allowedCharactersSet.addCharacters(in: "+")
                phone = phone.components(separatedBy: allowedCharactersSet.inverted).joined(separator: "")
            }
            
            if UserDAO.sharedInstance.user.phoneNumber.trim().contains(phone.trim()) || phone.trim().contains(UserDAO.sharedInstance.user.phoneNumber.trim()) {
                //print("user number found")
            }else {
                let dict:[String:Any] = ["name":fullName,"phone_number":phone!]
                let collaborator = CollaboratorDAO(colabData: dict)
                if self.arraySelected != nil {
                    if (self.arraySelected?.contains(where: { collaborator.phone.trim().contains($0.phone.trim())   && $0.addedByMe == true }))! {
                        collaborator.isSelected = true
                    }
                }
                self.arrayCollaborators.append(collaborator)
            }

        }
        DispatchQueue.main.async {
            
            var seen = Set<String>()
            var unique = [CollaboratorDAO]()
            for obj in  self.arrayCollaborators {
                
                if !seen.contains(obj.phone) {
                    unique.append(obj)
                    seen.insert(obj.phone)
                }
            }
            self.arrayCollaborators = unique
//            for obj in self.arrayCollaborators {
//                if obj.isSelected == true {
//                    self.arrayTempSelected.append(obj)
//                }
//            }
            self.checkContact()
            //            self.arrayCollaborators.sort {
            //                $0.name.lowercased() < $1.name.lowercased()
            //            }
        }
        
    }
    
    
    
    func showPermissionAlert(strMessage:String) {
        
        DispatchQueue.main.async(execute: { [unowned self] in
            let message = NSLocalizedString("Emogo doesn't have permission to use the \(strMessage), please change privacy settings", comment: "Alert message when the user has denied access to the camera")
            let alertController = UIAlertController(title: "Emogo", message: message, preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Alert OK button"), style: .cancel, handler: nil))
            alertController.addAction(UIAlertAction(title: NSLocalizedString("Settings", comment: "Alert button to open Settings"), style: .default, handler: { action in
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(URL(string: UIApplicationOpenSettingsURLString)!, options: [:], completionHandler: nil)
                } else {
                    if let appSettings = URL(string: UIApplicationOpenSettingsURLString) {
                        UIApplication.shared.openURL(appSettings)
                    }
                }
            }))
            
            AppDelegate.appDelegate.window?.rootViewController?.present(alertController, animated: true, completion: nil)
        })
    }
    
    func checkContact(){
        var arrayNumber = [String]()
        for obj in arrayCollaborators {
            arrayNumber.append(obj.phone)
        }
        APIServiceManager.sharedInstance.apiForValidate(contacts: arrayNumber) { (results, errorMSG) in
           // print(results)
            if (errorMSG?.isEmpty)! {
                let arrayKey = results?.keys
                for (index,obj) in (arrayKey?.enumerated())! {
                    let strPhone:String! = obj
                    if let mainIndex =  self.arrayCollaborators.index(where: {$0.phone.trim() == strPhone.trim() }) {
                        if let value = results![obj] {
                            if value is [String:Any] {
                                let temp = self.arrayCollaborators[mainIndex]
                                let collaborator = CollaboratorDAO(colabData: (value as! NSDictionary).replacingNullsWithEmptyStrings() as! [String : Any])
                                collaborator.isSelected = temp.isSelected
                                collaborator.addedByMe = temp.addedByMe
                                collaborator.canAddPeople = temp.canAddPeople
                                collaborator.canAddContent = temp.canAddContent
                                collaborator.phone = strPhone
                                if temp.userID.trim().isEmpty {
                                    self.arrayCollaborators[mainIndex] = collaborator
                                }
                                if temp.isSelected == true {
                                    self.arrayTempSelected.append(collaborator)
                                }
                               // print("replaced Data")

                            }else {
                                let temp = self.arrayCollaborators[mainIndex]
                                if temp.isSelected == true {
                                    self.arrayTempSelected.append(temp)
                                }
                            }
                        }
                    }
                   // print("iter \(index)")
                }
//                if self.arrayTempSelected.count != 0 {
//                    self.btnAdd.isHidden = false
//                }
                self.updateList(arrayColabs:self.arrayCollaborators)
            }
        }
    }
    
    func updateList(arrayColabs:[CollaboratorDAO]){
        if self.isSearchEnable {
            self.arraySearch.removeAll()
            for obj in self.arrIndexSection {
                let result = arrayColabs
                    .filter { $0.name.lowercased().hasPrefix(obj.lowercased()) }
                let dict:[String:Any] = ["key":obj,"value":result]
                self.arraySearch.append(dict)
            }
        }else {
            self.arrayToShow.removeAll()
            for obj in self.arrIndexSection {
                let result = arrayColabs
                    .filter { $0.name.lowercased().hasPrefix(obj.lowercased()) }
                let dict:[String:Any] = ["key":obj,"value":result]
                
                self.arrayToShow.append(dict)
            }
        }
       
        self.tblAddCollab.reloadData()
    }
   
    func performSearch(text:String) {
        
        let result = self.arrayCollaborators
            .filter { $0.name.lowercased().contains(text.lowercased()) }
       // print(result)
        
        self.updateList(arrayColabs:result)
    }
    
    func updateColabs(){
        HUDManager.sharedInstance.showHUD()

        APIServiceManager.sharedInstance.apiForEditStreamColabs(streamID: (self.objStream?.streamID)!,streamType: (self.objStream?.type)!, anyOneCanEdit: (self.objStream?.anyOneCanEdit)!, canAddContent: (self.objStream?.userCanAddContent)! , canAddPeople:(self.objStream?.userCanAddPeople)!, collaborator: arrayTempSelected) { (result, errorMSG) in
            HUDManager.sharedInstance.hideHUD()
            if (errorMSG?.isEmpty)! {
                if self.delegate != nil {
                    self.delegate?.selectedColabs(arrayColab: self.arrayTempSelected)
                }
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    
   
}
extension AddCollabViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.arrIndexSection.count
    }
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return self.arrIndexSection
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isSearchEnable == true {
            if self.arraySearch.count == 0 {
                return 0
            }
            let array:[CollaboratorDAO] = (self.arraySearch[section] as! [String:Any])["value"] as! [CollaboratorDAO]
            return array.count
        }
        if self.arrayToShow.count == 0 {
            return 0
        }
        let array:[CollaboratorDAO] = (self.arrayToShow[section] as! [String:Any])["value"] as! [CollaboratorDAO]
        return array.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:AddCollabCell = tableView.dequeueReusableCell(withIdentifier: kCell_AddCollabView) as! AddCollabCell
        var dictColabContact:CollaboratorDAO!
        if isSearchEnable == true {
            let array:[CollaboratorDAO] = (self.arraySearch[indexPath.section] as! [String:Any])["value"] as! [CollaboratorDAO]
            dictColabContact = array[indexPath.row]
        }else {
            let array:[CollaboratorDAO] = (self.arrayToShow[indexPath.section] as! [String:Any])["value"] as! [CollaboratorDAO]
            dictColabContact = array[indexPath.row]
        }
        
        let attrs1:[NSAttributedStringKey : NSObject] = [NSAttributedStringKey.font : UIFont(name: kFontMedium, size: 14.0)!, NSAttributedStringKey.foregroundColor : UIColor(r: 36, g: 36, b: 36)]
        
        let attrs2:[NSAttributedStringKey : NSObject] = [NSAttributedStringKey.font :  UIFont(name: kFontRegular, size: 14.0)!, NSAttributedStringKey.foregroundColor : UIColor(r: 74, g: 74, b: 74)]
        
        if !dictColabContact.displayName.trim().isEmpty {
            let attributedString1 = NSMutableAttributedString(string:dictColabContact.displayName, attributes:attrs1)
            let attributedString2 = NSMutableAttributedString(string:"\n\(dictColabContact.name!)", attributes:attrs2)
            attributedString1.append(attributedString2)
            cell.lblDisplayName.attributedText = attributedString1
        }else {
            let attributedString1 = NSMutableAttributedString(string:dictColabContact.name, attributes:attrs1)
            cell.lblDisplayName.attributedText = attributedString1
        }
        
       
        
        // cell.imgProfile.image = UIImage(named: "demo_images")
        if dictColabContact.userImage.isEmpty {
            cell.imgProfile.setImage(string: dictColabContact.name,color:UIColor.colorHash(name: dictColabContact.name),circular: true)
        }else{
            cell.imgProfile.setImageWithResizeURL(dictColabContact.userImage)
        }
        cell.checkButton.tag = indexPath.row
        cell.selectionStyle = .none
        cell.checkButton .addTarget(self, action:#selector(btnCheckedClicked(sender:)) , for: .touchUpInside )
        if dictColabContact.isSelected {
            cell.checkButton.setImage(#imageLiteral(resourceName: "addCollab_check"), for: .normal)
        }else {
            cell.checkButton.setImage(#imageLiteral(resourceName: "addCollab_uncheck"), for: .normal)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        if let cell = self.tblAddCollab.cellForRow(at: indexPath) {
//            self.btnCheckedClicked(sender: (cell as! AddCollabCell).checkButton)
//        }
        self.btnActionForUserProfile(indexPath: indexPath)
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    
}

extension AddCollabViewController: UITextFieldDelegate {
    
    @objc func textFieldEditingChange(sender:UITextField) {
        
        self.isSearchEnable = true
        self.arraySearch.removeAll()
        self.tblAddCollab.reloadData()
       
        if (self.tfSearch.text?.trim().isEmpty)! {
          //  self.navigationController?.isNavigationBarHidden = true
//            self.viewAddCollab.isHidden = false
//            self.kConsViewTop.constant = kOriginalContants //176
            self.tblAddCollab.reloadData()
        }else{
            self.viewAddCollab.isHidden = true
            self.prepareNavBarButtons()
            self.kConsViewTop.constant = -13
           
        }
         self.performSearch(text: (sender.text?.trim())!)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        if (textField.text?.trim().isEmpty)!  {
            self.isSearchEnable = false
            self.tblAddCollab.reloadData()
            self.navigationController?.isNavigationBarHidden = true
            self.viewAddCollab.isHidden = false
            self.kConsViewTop.constant = kOriginalContants
        }else{
            self.viewAddCollab.isHidden = true
            self.prepareNavBarButtons()
            self.kConsViewTop.constant = -13
        }
        return true
    }
    func textFieldDidBeginEditing(_ textField: UITextField) {
         self.imgSearchIcon.image = #imageLiteral(resourceName: "search_icon_iphone")
        if self.tfSearch.text == nil {
            self.viewAddCollab.isHidden = false
            self.kConsViewTop.constant =  kOriginalContants
        }else{
            self.prepareNavBarButtons()
            self.viewAddCollab.isHidden = true
            self.kConsViewTop.constant = -13
        }
    }
  
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        let startingLength = tfSearch.text?.count ?? 0
        let lengthToAdd = string.count
        let lengthToReplace = range.length
        
        let newLength = startingLength + lengthToAdd - lengthToReplace
        print(newLength)
        
        if newLength == 0 {
            self.imgSearchIcon.image = #imageLiteral(resourceName: "search_icon_iphone-1")
        }else{
            self.imgSearchIcon.image = #imageLiteral(resourceName: "search_icon_iphone")
            
        }
        
        return true
    }

}
