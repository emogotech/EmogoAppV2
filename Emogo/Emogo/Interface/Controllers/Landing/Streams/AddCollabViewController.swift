//
//  AddCollabViewController.swift
//  Emogo
//
//  Created by Northout on 15/06/18.
//  Copyright © 2018 Vikas Goyal. All rights reserved.
//

import UIKit
import Contacts

class AddCollabViewController: UIViewController {

    
    //MARK:- IBOutlets Connection
    
    @IBOutlet weak var tblAddCollab: UITableView!
    @IBOutlet weak var btnAdd: UIButton!
    @IBOutlet weak var lblSearch: UILabel!
    @IBOutlet weak var tfSearch: UITextField!
    @IBOutlet weak var viewSearch: UIView!
    var arrIndexSection : [String] = ["A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z"]
    var arrayToShow = [Any]()

    // Varibales
    var arrayCollaborators = [CollaboratorDAO]()
    var arraySelected:[CollaboratorDAO]?
    var isChecked: Bool! = false
    var rowsWhichAreChecked = [IndexPath]()
    let checkedImage = UIImage(named: "addCollab_check")! as UIImage
    let uncheckedImage = UIImage(named: "addCollab_uncheck")! as UIImage
    let kCell_AddCollabView = "addCollabCell"
    var selectedRows = [IndexPath]()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tblAddCollab.delegate = self
        self.tblAddCollab.dataSource = self
        tblAddCollab.sectionIndexColor = UIColor.lightGray
       // self.tblAddCollab.rowHeight = UITableViewAutomaticDimension
      //  self.tblAddCollab.estimatedRowHeight = 250
        self.prepareLayouts()
       
    }

    override func viewDidAppear(_ animated: Bool) {
        super .viewDidAppear(true)
        self.tblAddCollab.reloadData()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
   
    func prepareLayouts(){
        if self.arraySelected != nil {
                self.arrayCollaborators = self.arraySelected!
        }
         self.tblAddCollab.separatorStyle = .none
         self.btnAdd.isHidden = true
         lblSearch.layer.cornerRadius = 20.0
         lblSearch.clipsToBounds = true
         self.getContacts()
        prepareNavBarButtons()
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
        
    }
    
    //MARK:- Selector Methods
    @objc func cancelButtonAction(){
        self.dismiss(animated: true, completion: nil)
    }
    @objc func inviteButtonAction(){
        if UserDAO.sharedInstance.user.shareURL.isEmpty {
            return
        }
        let url:URL = URL(string: UserDAO.sharedInstance.user.shareURL!)!
        let shareItem =  "Hey checkout \(UserDAO.sharedInstance.user.fullName.capitalized)'s profile!"
        let text = "\n via Emogo"
        
        // let shareItem = "Hey checkout the s profile,emogo"
        let activityViewController: UIActivityViewController = UIActivityViewController(activityItems: [shareItem,url,text], applicationActivities:nil)
        //  activityViewController.excludedActivityTypes = [.print, .copyToPasteboard, .assignToContact, .saveToCameraRoll, .airDrop]
        
        DispatchQueue.main.async {
            self.present(activityViewController, animated: true, completion: nil);
        }
    }
    @objc func btnCheckedClicked(sender: UIButton) {
        guard let indexPath = self.tblAddCollab.indexPath(for: sender.superview?.superview?.superview as! AddCollabCell) else {
            return
        }
        var array:[CollaboratorDAO] = (self.arrayToShow[indexPath.section] as! [String:Any])["value"] as! [CollaboratorDAO]
        let dictColabContact = array[indexPath.row]
        dictColabContact.isSelected = !dictColabContact.isSelected
        array[indexPath.row] = dictColabContact
        if let name =  (self.arrayToShow[indexPath.section] as! [String:Any])["key"] {
            let key:String! = name as! String
            self.arrayToShow[indexPath.section] = ["key":key,"value":array]
        }
        self.tblAddCollab.reloadData()
        if self.selectedRows.contains(indexPath) {
            if let index =  self.selectedRows.index(of: indexPath){
                self.selectedRows.remove(at: index)
            }
        }else {
            self.selectedRows.append(indexPath)
        }
        if self.selectedRows.count == 0 {
            self.btnAdd.isHidden = true
        }else {
            self.btnAdd.isHidden = false
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
            var img:UIImage!
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
                print("user number found")
            }else {
                let dict:[String:Any] = ["name":fullName,"phone_number":phone!]
                let collaborator = CollaboratorDAO(colabData: dict)
                if self.arraySelected != nil {
                    if (self.arraySelected?.contains(where: {$0.phone.trim() == collaborator.phone.trim() && $0.addedByMe == true }))! {
                        
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
            
            for obj in self.arrIndexSection {
            let result = self.arrayCollaborators
                    .filter { $0.name.lowercased().hasPrefix(obj.lowercased()) }
                let dict:[String:Any] = ["key":obj,"value":result]
                self.arrayToShow.append(dict)
            }
            self.checkContact()
//            self.arrayCollaborators.sort {
//                $0.name.lowercased() < $1.name.lowercased()
//            }
            self.tblAddCollab.reloadData()
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
        if self.arrayToShow.count == 0 {
            return 0
        }
        let array:[CollaboratorDAO] = (self.arrayToShow[section] as! [String:Any])["value"] as! [CollaboratorDAO]
       return array.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:AddCollabCell = tableView.dequeueReusableCell(withIdentifier: kCell_AddCollabView) as! AddCollabCell
        let array:[CollaboratorDAO] = (self.arrayToShow[indexPath.section] as! [String:Any])["value"] as! [CollaboratorDAO]
        let dictColabContact = array[indexPath.row]
        cell.lblDisplayName.text = dictColabContact.name
        cell.lbluserName.isHidden = true
        // cell.imgProfile.image = UIImage(named: "demo_images")
        if dictColabContact.imgUser.isEmpty {
            
            cell.imgProfile.setImage(string: dictColabContact.name,color:UIColor.colorHash(name: dictColabContact.name),circular: true)
        }else{
            cell.imgProfile.setImageWithResizeURL(dictColabContact.imgUser)
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
        if let cell = self.tblAddCollab.cellForRow(at: indexPath) {
            self.btnCheckedClicked(sender: (cell as! AddCollabCell).checkButton)
        }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
       
        return 70
    }
    
}
