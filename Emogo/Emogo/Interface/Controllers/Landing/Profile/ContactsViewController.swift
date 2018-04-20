//
//  ContactsViewController.swift
//  Emogo
//
//  Created by Pushpendra on 19/04/18.
//  Copyright © 2018 Vikas Goyal. All rights reserved.
//

import UIKit
import Contacts

class ContactsViewController: UIViewController {
    
    @IBOutlet weak var tblUsers: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    
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
            }
        }
      
            self.tblUsers.reloadData()
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
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
