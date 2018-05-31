//
//  VideoEditor+Text.swift
//  Emogo
//
//  Created by Pushpendra on 28/05/18.
//  Copyright © 2018 Vikas Goyal. All rights reserved.
//

import Foundation
extension VideoEditorViewController  {

    func prepareForTextEditing(){
        isTyping = true
        self.canvasImageView.isHidden = false
        let textView = UITextView(frame: CGRect(x: 0, y: canvasImageView.center.y,
                                                width: UIScreen.main.bounds.width, height: 30))
        textView.textAlignment = .center
        textView.font = UIFont(name: "Helvetica", size: 30)
        textView.textColor = textColor
        textView.layer.shadowColor = UIColor.black.cgColor
        textView.layer.shadowOffset = CGSize(width: 1.0, height: 0.0)
        textView.layer.shadowOpacity = 0.2
        textView.layer.shadowRadius = 1.0
        textView.layer.backgroundColor = UIColor.clear.cgColor
        textView.autocorrectionType = .no
        textView.isScrollEnabled = false
        textView.keyboardAppearance = .dark
        textView.delegate = self
        self.canvasImageView.addSubview(textView)
        addGestures(view: textView)
        textView.becomeFirstResponder()
        self.player.isUserInteractionEnabled = false
        self.playerContainerView.isUserInteractionEnabled = false
        if self.player.isPlaying {
            self.player.pause()
        }
    }
    
    func keyboardSetup(){
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidShow),
                                               name: .UIKeyboardDidShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide),
                                               name: .UIKeyboardWillHide, object: nil)
        NotificationCenter.default.addObserver(self,selector: #selector(keyboardWillChangeFrame(_:)),
                                               name: .UIKeyboardWillChangeFrame, object: nil)
    }
    
    
    func addTextonvideo(){
        if self.player.isPlaying {
            self.player.pause()
        }
        self.showActivity()
        let subview = self.canvasImageView.subviews
        let view = subview[0]
        let frame = self.view.convert(view.frame, from: self.canvasImageView)
        print(frame)
        if subview.count == 0 {
            self.canvasImageView.isHidden = true
            return
        }
        let temp = UIImage.image(self.canvasImageView)
       // let frontImage = UIImage.image(view)
        
      //  let backGround = UIImage.imageWithColor(tintColor: .clear)
    //    let image = backGround.mergedImageWith(frontImage: frontImage, frame: frame)
        let imageResize = UIImageView(image: temp)
        if let videoSize = self.resolutionSizeForLocalVideo(url: self.localFileURl!) {
            imageResize.frame = CGRect(x: 0, y: 0, width: videoSize.width, height: videoSize.height)
            imageResize.backgroundColor = .clear
        }
        self.canvasImageView.isHidden = true
        self.editManager.addContentToVideo(path: self.localFileURl!, boundingSize: imageResize.bounds.size, contents: [imageResize], progress: {(progress, strProgress) in
        }) { (fileURL, error) in
            
            if let fileURL = fileURL {
                DispatchQueue.main.async {
                    self.canvasImageView.subviews.forEach({ $0.removeFromSuperview() })
                    self.hideActivity()
                    self.updatePlayerAsset(videURl: fileURL)
                }
            }
        }
    }
}
