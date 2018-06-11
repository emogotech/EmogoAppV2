//
//  ColorPickerView.swift
//  RichTextEditor
//
//  Created by Pushpendra on 04/06/18.
//  Copyright © 2018 Pushpendra. All rights reserved.
//

import UIKit


protocol ColorPickerViewDelegate {
    func selectedBackgroundColor(color:UIColor)
    func selectedTextColor(color:UIColor)
}
class ColorPickerView: UIView {

    @IBOutlet var pickerText: PMColorPickerView!
    @IBOutlet var pickerBackground: PMColorPickerView!
    
    
    var delegate:ColorPickerViewDelegate?
    
    class func instanceFromNib() -> ColorPickerView {
        return  UINib(nibName: "ColorPickerView", bundle: nil).instantiate(withOwner: nil, options: nil).first  as! ColorPickerView
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        print("Called")
    }
    
    func prepareView(){
        pickerText.delegate = self
        pickerText.elementSize = 10
        pickerBackground.delegate = self
        pickerBackground.elementSize = 10
    }
    
}

extension ColorPickerView:PMColorPickerDelegate {
    
    func colorPickerTouched(sender: PMColorPickerView, color: UIColor, point: CGPoint, state: UIGestureRecognizerState) {
        if sender.tag == 787822 {
            
            if delegate != nil {
                self.delegate?.selectedTextColor(color: color)
            }
           }else{
            if delegate != nil {
                self.delegate?.selectedBackgroundColor(color: color)
            }
        }
    }
    
    
}
