//
//  TestDetailViewController.swift
//  Emogo
//
//  Created by Northout on 30/08/18.
//  Copyright © 2018 Vikas Goyal. All rights reserved.
//

import UIKit

class TestDetailViewController: UIViewController {
    
    var currentIndex:Int!
    var currentStream:StreamDAO!
    var stretchyHeader: StreamViewHeader!
    var image:UIImage?

    @IBOutlet weak var imgTestDetail: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = false
        self.imgTestDetail.image = selectedImageView?.image
        self.imgTestDetail.contentMode = .scaleAspectFill
        // Do any additional setup after loading the view.
    }
   
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
  
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
//        if image == nil {
//
//            self.imgTestDetail.setOriginalImage(strImage: (currentStream?.CoverImage)!, placeholder: kPlaceholderImage)
//        }else {
//
//            self.imgTestDetail.image = image
//       }



    }
}

/*
    // MARK: - ZoomTransitionDestinationDelegate
    
    extension TestDetailViewController: ZoomTransitionDestinationDelegate {
        func transitionDestinationImageViewFrame(forward: Bool) -> CGRect {
            if forward {
                let x: CGFloat = 0
                let y: CGFloat = topLayoutGuide.length
                let width: CGFloat = view.frame.width
                let height: CGFloat = width * 2 / 3
                return CGRect(x: x, y: y, width: width, height: height)
            } else {
                return imgTestDetail.convert(imgTestDetail.bounds, to: view)
            }
        }
        
        func transitionDestinationWillBegin() {
            imgTestDetail.isHidden = true
        }
        
        func transitionDestinationDidEnd(transitioningImageView imageView: UIImageView) {
            imgTestDetail.isHidden = false
            imgTestDetail.image = imageView.image
        }
        
        func transitionDestinationDidCancel() {
            imgTestDetail.isHidden = false
        }
    }
*/
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */


