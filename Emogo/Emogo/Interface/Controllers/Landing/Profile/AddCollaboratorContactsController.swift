//
//  AddCollaboratorController.swift
//  Emogo
//
//  Created by Northout on 23/04/18.
//  Copyright © 2018 Vikas Goyal. All rights reserved.
//

import UIKit
import Contacts

class AddCollaboratorContactsController: UIViewController,UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate{
    
        var sectionHeading :  Array<String>  = ["contacts"]
        var isChecked: Bool! = false
        var rowsWhichAreChecked = [IndexPath]()
        // Varibales
        var arrayContacts = [CollaboratorDAO]()
        var arraySelected:[CollaboratorDAO]?
    
        //MARK:- outlet Connections
    
        @IBOutlet weak var tblContacts: UITableView!
        @IBOutlet weak var tfSearch: UITextField!
    
        @IBOutlet weak var imgCheckonDone: UIImageView!
        @IBOutlet weak var btnDone: UIButton!
        @IBOutlet weak var btnClose: UIButton!
    
        //MARK:- set Images
        let checkedImage = UIImage(named: "check-box-filled")! as UIImage
        let uncheckedImage = UIImage(named: "check-box-empty")! as UIImage
        let kCell_ContactsCell = "contactscell"
        let kCell_EmogoContactsCell = "emogocontactCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
      
        self.tblContacts.delegate = self
        self.tblContacts.dataSource = self
        
        tblContacts.separatorStyle = .none
        tblContacts.backgroundColor = UIColor.white
        tblContacts.tableFooterView = nil
        
        self.tblContacts.register(ContactsViewCell.self, forCellReuseIdentifier: kCell_ContactsCell)
      //  self.tblContacts.register(EmogoContactViewCell.self, forCellReuseIdentifier: kCell_EmogoContactsCell)
        
        self.prepareLayout()
      

    }
    override func viewDidAppear(_ animated: Bool) {
        super .viewDidAppear(true)
        self.tblContacts.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK:- prepare Layout
    
    func prepareLayout() {
        imgCheckonDone.image = UIImage(named: "unchecked_checkbox" )
        self.navigationController?.navigationBar.isHidden = true
        self.getContacts()
       
    }
    
    //MARK:- get contacts
    
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
                
                print(dict)
                
                let collaborator = CollaboratorDAO(colabData: dict)
                if self.arraySelected != nil {
                    if (self.arraySelected?.contains(where: {$0.phone.trim() == collaborator.phone.trim() && $0.addedByMe == true }))! {
                        
                        collaborator.isSelected = true
                    }
                }
                self.arrayContacts.append(collaborator)
            }
            }
        
        DispatchQueue.main.async {
            
            var seen = Set<String>()
            var unique = [CollaboratorDAO]()
            for obj in  self.arrayContacts {
                
                if !seen.contains(obj.phone) {
                    unique.append(obj)
                    seen.insert(obj.phone)
                }
            }
            self.arrayContacts = unique
            self.arrayContacts.sort {
                $0.name.lowercased() < $1.name.lowercased()
            }
            self.tblContacts.reloadData()
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
    
  
    //MARK:- close button Action
    @IBAction func btnCloseAction(_ sender: Any) {
        
        self.dismiss(animated: true, completion: nil)
        
    }
    
    //MARK:- done button Action
    @IBAction func btnDoneAction(_ sender: UIButton) {
        
    }
    
    //MARK:- textfield delegates
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
         textField.resignFirstResponder()
         return true
    }
    
    //MARK:- tableview delegate and datasource
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.sectionHeading.count
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.sectionHeading[section]
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        }else{
            return self.arrayContacts.count
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
    
            let cell:ContactsViewCell = tblContacts.dequeueReusableCell(withIdentifier: kCell_ContactsCell) as! ContactsViewCell
            let dictContact = self.arrayContacts[indexPath.row]
            cell.lblContact.text = dictContact.name
            cell.imgProfile.image = UIImage(named: "demo_images")
        
             return cell
       
   
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell:ContactsViewCell = tblContacts.cellForRow(at: indexPath) as! ContactsViewCell
        // cross checking for checked rows
        if(rowsWhichAreChecked.contains(indexPath as IndexPath) == false){
            isChecked = true
            cell.btnCheck.setImage(checkedImage, for: .normal)
            cell.contentView.backgroundColor = UIColor.white
            imgCheckonDone.image = UIImage(named: "check_checkbox")
            rowsWhichAreChecked.append(indexPath as IndexPath)
        }else{
            isChecked = false
            cell.btnCheck.setImage(uncheckedImage, for: .normal)
            cell.contentView.backgroundColor = UIColor.white
            imgCheckonDone.image = UIImage(named: "unchecked_checkbox")
            // remove the indexPath from rowsWhichAreCheckedArray
            if let checkedItemIndex = rowsWhichAreChecked.index(of: indexPath){
                rowsWhichAreChecked.remove(at: checkedItemIndex)
            }
        }
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        
        //For HeaderView
        let viewHeader = UIView.init(frame: CGRect(x: 0, y: 0, width: self.tblContacts.frame.size.width, height: 40))
        viewHeader.backgroundColor = UIColor.white
        
        let lblTitle : UILabel = UILabel.init(frame: CGRect(x: 15, y: 0, width: self.tblContacts.frame.size.width-16, height: 40))
        lblTitle.backgroundColor = .clear
        lblTitle.textColor =   UIColor.init(r: 74.0, g: 74.0, b: 74.0)
        lblTitle.text = self.sectionHeading[section]
        
        
        let lblSepratorTop : UILabel = UILabel.init(frame: CGRect(x: 0, y: 0, width: self.tblContacts.frame.size.width, height: 1))
        lblSepratorTop.backgroundColor = UIColor.init(r: 229.0 , g: 229.0, b: 229.0)
        
        
        let lblSepratorBottom : UILabel = UILabel.init(frame: CGRect(x: 0, y: viewHeader.frame.size.height-1, width: self.tblContacts.frame.size.width, height: 1))
        lblSepratorBottom.backgroundColor = UIColor.init(r: 229.0 , g: 229.0, b: 229.0)
        
        viewHeader.addSubview(lblSepratorTop)
        viewHeader.addSubview(lblSepratorBottom)
        viewHeader.addSubview(lblTitle)
        
        return viewHeader
    }

}
