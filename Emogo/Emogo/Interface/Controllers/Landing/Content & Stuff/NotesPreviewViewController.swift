//
//  NotesPreviewViewController.swift
//  Emogo
//
//  Created by Pushpendra on 14/06/18.
//  Copyright © 2018 Vikas Goyal. All rights reserved.
//

import UIKit

class NotesPreviewViewController: UIViewController {

    @IBOutlet weak var webView: UIWebView!
    var contentDAO:ContentDAO?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.prepareLayout()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func prepareLayout(){
        if let content = contentDAO {
            self.webView.loadHTMLString(content.description, baseURL: nil)
            print(content.description)
            self.webView.scalesPageToFit = false
            self.webView.stringByEvaluatingJavaScript(from: "document. body.style.zoom = 8.0;")
           
        }
        self.navigationController?.isNavigationBarHidden = false
        let backButton = UIBarButtonItem(image: #imageLiteral(resourceName: "back_icon"), style: .plain, target: self, action: #selector(self.backButtonAction))
        self.navigationController?.navigationBar.tintColor = UIColor(r: 0, g: 122, b: 255)
        self.navigationController?.navigationBar.barTintColor = UIColor.white
        self.navigationItem.leftBarButtonItem = backButton
    }
    
    @objc func backButtonAction(){
        self.navigationController?.popViewController(animated: false)
        //self.navigationController?.popViewAsDismiss()
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
