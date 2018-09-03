//
//  ShowPreviewViewController.swift
//  Emogo
//
//  Created by Pushpendra on 13/12/18.
//  Copyright © 2018 Vikas Goyal. All rights reserved.
//

import UIKit

protocol ShowPreviewViewControllerDelegate {
    func dismissTapped()
}

class ShowPreviewViewController: UIViewController {
    
    var objContent:ContentDAO!
    
    @IBOutlet weak var imgView: FLAnimatedImageView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblDescription: UILabel!
    @IBOutlet weak var btnClose: UIButton!
    var delegate:ShowPreviewViewControllerDelegate?
    var isProfile:String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
         self.prepreLayout()
    }

    func prepreLayout(){
        
        
        self.btnClose.isHidden = true
        self.imgView.isUserInteractionEnabled = true
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.btnDismiss))
        self.imgView.addGestureRecognizer(tap)
        
        let edgePan = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture))
        edgePan.edges = .right
        view.addGestureRecognizer(edgePan)
        
        let swipeUp = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture))
        swipeUp.direction = UISwipeGestureRecognizerDirection.up
        self.imgView.addGestureRecognizer(swipeUp)
        
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture))
        swipeDown.direction = UISwipeGestureRecognizerDirection.down
        self.imgView.addGestureRecognizer(swipeDown)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.hideStatusBar()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.showStatusBar()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.prepareLayoutData()
    }
    
    func prepareLayoutData(){
        self.lblName.text = objContent.name
        self.lblDescription.text = objContent.description
        let url = URL(string: objContent.coverImageVideo)
        self.imgView.setImageUrl(url)
        self.imgView.contentMode = .scaleAspectFit
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
   @objc func btnDismiss() {
    
    self.navigationController?.popViewController(animated: false)
        //self.dismissViewController()
    }
    
    @IBAction func btnCloseAction(_ sender: Any) {
        self.dismissViewController()
    }
    
    @objc func respondToSwipeGesture(gesture: UIGestureRecognizer) {
        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
            switch swipeGesture.direction {
                
            case UISwipeGestureRecognizerDirection.up:                self.dismissViewController()
                break
                
            case UISwipeGestureRecognizerDirection.down:
                self.dismissViewController()
                break
              
                
            default:
                break
            }
        }
    }
    
    
    func dismissViewController(){
//        let transition: CATransition = CATransition()
//        transition.duration = 0.5
//        transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
//        transition.type = kCATransitionReveal
//        transition.subtype = kCATransitionFromRight
//        self.view.window!.layer.add(transition, forKey: nil)
        self.dismiss(animated: false) {
            if self.delegate != nil {
                self.delegate?.dismissTapped()
            }
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
