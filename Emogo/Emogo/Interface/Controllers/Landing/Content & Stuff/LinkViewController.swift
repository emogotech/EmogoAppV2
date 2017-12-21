//
//  LinkViewController.swift
//  Emogo
//
//  Created by Pushpendra on 13/12/17.
//  Copyright © 2017 Vikas Goyal. All rights reserved.
//

import UIKit
import ReadabilityKit

class LinkViewController: UIViewController {

    @IBOutlet weak var txtLink: UITextField!
    @IBOutlet weak var linkCollectionView: UICollectionView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func btnConfirmActiion(_ sender: Any) {
        if Validator.verifyUrl(urlString: txtLink.text!) {
            let articleUrl = URL(string: txtLink.text!)
            Readability.parse(url: articleUrl!, completion: { data in
                print(data)
                let title = data?.title
                let description = data?.description
                let keywords = data?.keywords
                let imageUrl = data?.topImage
                let videoUrl = data?.topVideo
                print(title)
                print(description)
                print(keywords)
                print(imageUrl)
                print(videoUrl)

            })
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

extension LinkViewController:UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
