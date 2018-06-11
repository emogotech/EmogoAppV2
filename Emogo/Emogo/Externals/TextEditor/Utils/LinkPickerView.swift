//
//  LinkPickerView.swift
//  RichTextEditor
//
//  Created by Pushpendra on 05/06/18.
//  Copyright © 2018 Pushpendra. All rights reserved.
//

import UIKit

class LinkPickerView: UIView {
    @IBOutlet var tblLink: UITableView!
var arrayLinks = [Any]()
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    class func instanceFromNib() -> LinkPickerView {
        return  UINib(nibName: "LinkPickerView", bundle: nil).instantiate(withOwner: nil, options: nil).first  as! LinkPickerView
    }
    

}

extension LinkPickerView:UITableViewDelegate,UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrayLinks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "", for: indexPath)
        return cell
    }
    
    
}
