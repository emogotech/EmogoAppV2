//
//  CountryPickerViewController.swift
//  Emogo
//
//  Created by Pushpendra on 18/05/18.
//  Copyright © 2018 Vikas Goyal. All rights reserved.
//

import UIKit

protocol CountryPickerViewControllerDelegate {
    func dissmissPickerWith(country:CountryDAO)
}
class CountryPickerViewController: UIViewController {
    @IBOutlet weak var tblCountry: UITableView!
    var arrayCodes = [CountryDAO]()
    let cellIdentifier = "countryCell"
    var delegate:CountryPickerViewControllerDelegate?
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        prepareLayout()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func prepareLayout(){
    self.title = "Select Your Country"
        let done = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(self.doneButtonAction))
        let cancel = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(self.cancelButtonAction))
        self.navigationItem.leftBarButtonItem = cancel
        self.navigationItem.rightBarButtonItem = done
        readJson()
    }
    
    @objc func doneButtonAction(){
     let array =  arrayCodes.filter { $0.isSelected == true }
        if array.count != 0 {
            if self.delegate != nil {
                delegate?.dissmissPickerWith(country: array[0])
            }
            self.dismiss(animated: true, completion: nil)
        }
       
    }
    
   @objc func cancelButtonAction(){
    self.dismiss(animated: true, completion: nil)
    }
    private func readJson() {
        do {
            if let file = Bundle.main.url(forResource: "countryCodes", withExtension: "json") {
                let data = try Data(contentsOf: file)
                let json = try JSONSerialization.jsonObject(with: data, options: [])
                if let object = json as? [String: Any] {
                    // json is a dictionary
                    print(object)
                } else if let object = json as? [Any] {
                    // json is an array
                    print(object)
                    
                    for obj in object {
                        let code = CountryDAO(dictCountry: obj as! [String : Any])
                        self.arrayCodes.append(code)
                    }
                    self.tblCountry.reloadData()
                    
                } else {
                    print("JSON is invalid")
                }
            } else {
                print("no file")
            }
        } catch {
            print(error.localizedDescription)
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

extension CountryPickerViewController :UITableViewDelegate,UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrayCodes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:CountryCell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! CountryCell
        cell.selectionStyle = .none
        let code = arrayCodes[indexPath.row]
        cell.lblName.text = code.name
        cell.lblPhoneCode.text = code.phoneCode
        cell.imgCountryFlag.image = UIImage(named:code.code)
        if code.isSelected {
            cell.checkMark.image = #imageLiteral(resourceName: "check-box-filled")
        }else {
            cell.checkMark.image = #imageLiteral(resourceName: "check-box-empty")
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
       
        let code = arrayCodes[indexPath.row]
        
        code.isSelected = !code.isSelected
        for (index, _) in arrayCodes.enumerated() {
            if index != indexPath.row {
                arrayCodes[index].isSelected = false
            }
        }
        tblCountry.reloadData()
    }
    
    
}
