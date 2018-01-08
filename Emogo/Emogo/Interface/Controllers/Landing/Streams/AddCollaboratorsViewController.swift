//
//  AddCollaboratorsViewController.swift
//  Emogo
//
//  Created by Pushpendra on 13/12/17.
//  Copyright © 2017 Vikas Goyal. All rights reserved.
//

import UIKit
import Contacts

class AddCollaboratorsViewController: UIViewController {
    // MARK: - UI Elements
    @IBOutlet weak var contactCollection: UICollectionView!

    // Varibales
    var arrayCollaborators = [CollaboratorDAO]()
    var arraySelected:[CollaboratorDAO]?
    
    // MARK: - Override Functions

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        contactCollection.accessibilityLabel = "CollaboratorCollectionView"
        contactCollection.isAccessibilityElement = true
        self.prepareLayouts()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.contactCollection.reloadData()
    }

    // MARK: - Prepare Layouts
    func prepareLayouts(){
        if self.arraySelected != nil {
            self.arrayCollaborators = self.arraySelected!
        }
        self.getContacts()
    }
    
    // MARK: -  Action Methods And Selector
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
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
                print(phone)
            }
        
            let dict:[String:Any] = ["name":fullName,"phone_number":phone!]
            let collaborator = CollaboratorDAO(colabData: dict)
            if self.arraySelected != nil {
                if (self.arraySelected?.contains(where: {$0.phone.trim() == collaborator.phone.trim()}))! {
                    collaborator.isSelected = true
                }
            }
            self.arrayCollaborators.append(collaborator)
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
            
            self.contactCollection.reloadData()
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



extension AddCollaboratorsViewController:UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout
{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.arrayCollaborators.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // Create the cell and return the cell
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: kCell_AddCollaboratorsView, for: indexPath) as! AddCollaboratorsViewCell
        let collaborator = self.arrayCollaborators[indexPath.row]
        cell.lblTitle.text = collaborator.name
        cell.imgSelect.layer.cornerRadius = cell.imgSelect.frame.size.width/2.0
        cell.imgSelect.layer.masksToBounds = true
        cell.imgSelect.isHidden = true
        if !collaborator.imgUser.isEmpty {
            cell.imgCover.layer.cornerRadius = cell.imgCover.frame.size.width/2.0
            cell.imgCover.layer.masksToBounds = true
        }else {
            cell.imgCover.setImage(string: collaborator.name, color: UIColor.colorHash(name: collaborator.name), circular: true)
        }
        if collaborator.isSelected {
            cell.imgSelect.isHidden = false
        }
        cell.isAccessibilityElement = true
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let itemWidth = collectionView.bounds.size.width/3.0 - 12.0
        return CGSize(width: itemWidth, height: itemWidth)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let collaborator = self.arrayCollaborators[indexPath.row]
        collaborator.isSelected = !collaborator.isSelected
        self.arrayCollaborators[indexPath.row] = collaborator
        self.contactCollection.reloadData()
        
        if let obj = self.parent {
            let parentView:AddStreamViewController = obj as! AddStreamViewController
            let array = self.arrayCollaborators.filter({ (colab) -> Bool in
                if colab.isSelected == true {
                    return true
                }else {
                    return false
                }
            })
            parentView.selectedCollaborator(colabs: array)
        }
    }
    
   
}
