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
    
    // Varibales
    var arrayCollaborators = [CollaboratorDAO]()
    var arraySelected:[CollaboratorDAO]?
    var isChecked: Bool! = false
    var rowsWhichAreChecked = [IndexPath]()
    let checkedImage = UIImage(named: "addCollab_check")! as UIImage
    let uncheckedImage = UIImage(named: "addCollab_uncheck")! as UIImage
    let kCell_AddCollabView = "addCollabCell"
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tblAddCollab.delegate = self
        self.tblAddCollab.dataSource = self
       
       // self.tblAddCollab.rowHeight = UITableViewAutomaticDimension
      //  self.tblAddCollab.estimatedRowHeight = 250
         self.tblAddCollab.register(AddCollabCell.self, forCellReuseIdentifier: kCell_AddCollabView)
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
    }
    
    @IBAction func btnActionAdd(_ sender: Any) {
        
    }
    //MARK:- Selector Methods
    
    @objc func btnCheckedClicked(sender: UIButton) {
        
        if let cell = sender.superview as? AddCollabCell {
            sender.isSelected = !sender.isSelected
            if sender.isSelected {
                isChecked = true
                cell.btnCheck.isSelected = true
                cell.btnCheck.setImage(checkedImage, for: .selected)
              
                
            }else{
                isChecked = false
                cell.btnCheck.isSelected = false
                cell.btnCheck.setImage(uncheckedImage, for: .normal)
               
            }
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
            self.arrayCollaborators.sort {
                $0.name.lowercased() < $1.name.lowercased()
            }
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
    
}
extension AddCollabViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       return self.arrayCollaborators.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:AddCollabCell = tblAddCollab.dequeueReusableCell(withIdentifier: kCell_AddCollabView) as! AddCollabCell
        
        let dictColabContact = self.arrayCollaborators[indexPath.row]
        
        cell.lblContact.text = dictColabContact.name
        // cell.imgProfile.image = UIImage(named: "demo_images")
        if dictColabContact.imgUser.isEmpty {
            cell.imgProfile.setImage(string: dictColabContact.name,color:UIColor.colorHash(name: dictColabContact.name),circular: true)
        }else{
            cell.imgProfile.setImage(string: dictColabContact.name,color:UIColor.colorHash(name: dictColabContact.name),circular: true)
        }
        cell.btnCheck.tag = indexPath.row
        cell.btnCheck .addTarget(self, action:#selector(btnCheckedClicked(sender:)) , for: .touchUpInside )
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell:AddCollabCell = tblAddCollab.cellForRow(at: indexPath) as! AddCollabCell
        // cross checking for checked rows
        if(rowsWhichAreChecked.contains(indexPath as IndexPath) == false){
            isChecked = true
            cell.btnCheck.setImage(checkedImage, for: .normal)
            cell.contentView.backgroundColor = UIColor.white
             btnAdd.isHidden = false
            rowsWhichAreChecked.append(indexPath as IndexPath)
        }else{
            isChecked = false
            cell.btnCheck.setImage(uncheckedImage, for: .normal)
            cell.contentView.backgroundColor = UIColor.white
            btnAdd.isHidden = true
            // remove the indexPath from rowsWhichAreCheckedArray
            if let checkedItemIndex = rowsWhichAreChecked.index(of: indexPath){
                rowsWhichAreChecked.remove(at: checkedItemIndex)
            }
        }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
       
        return 70
    }
    
}
