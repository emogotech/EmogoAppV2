//
//  TextEditorView.swift
//  RichTextEditor
//
//  Created by Pushpendra on 04/06/18.
//  Copyright © 2018 Pushpendra. All rights reserved.
//

import UIKit
import DropDown

enum NoteTextAlignment {
    case left
    case right
    case center
}

struct TextEditorViewConstants {
    static var kDefaultFontType = ""
    static var kSelectedTag:Int = 103

}


protocol TextEditorViewDelegate {
    func selectHeader(tag:Int)
    func selectBody()
    func selectBold()
    func selectItalic()
    func selectUnderline()
    func selectAlignment(alignment:NoteTextAlignment)
    func selectFontFamily(family:String)
}

class TextEditorView: UIView {
    
    @IBOutlet var btnSelectFont: UIButton!

    let dropDown = DropDown()
    var delegate:TextEditorViewDelegate?

    class func instanceFromNib() -> TextEditorView {
        return  UINib(nibName: "TextEditorView", bundle: nil).instantiate(withOwner: nil, options: nil).first  as! TextEditorView
    }

    
    @IBAction func btnActionForTextOptions(_ sender: UIButton) {
        switch sender.tag {
        case 101:
            if delegate != nil {
                self.delegate?.selectHeader(tag: 1)
            }
            break
        case 102:
            if delegate != nil {
                self.delegate?.selectHeader(tag: 2)
            }
            break
        case 103:
            if delegate != nil {
                self.delegate?.selectBody()
            }
            break
        case 201:
            if delegate != nil {
                self.delegate?.selectBold()
            }
            break
        case 202:
            if delegate != nil {
                self.delegate?.selectItalic()
            }
            break
        case 203:
            if delegate != nil {
                self.delegate?.selectUnderline()
            }
            break
        case 301:
            if delegate != nil {
                self.delegate?.selectAlignment(alignment: .left)
            }
            break
        case 302:
            if delegate != nil {
                self.delegate?.selectAlignment(alignment: .center)
            }
            break
        case 303:
            if delegate != nil {
                self.delegate?.selectAlignment(alignment: .right)
            }
            break
        default:
            break
        }
    }
    
    @IBAction func btnActionForSelectFont(_ sender: Any) {
        self.dropDownAction()
    }
    
    func dropDownAction() {
        var fontName = [String]()
        for fontfamilyname: String in UIFont.familyNames {
            fontName.append(fontfamilyname)
        }
        dropDown.anchorView = btnSelectFont
        dropDown.dataSource = fontName
        dropDown.selectionAction = { [unowned self] (index: Int, item: String) in
            print("Selected item: \(item) at index: \(index)")
            self.btnSelectFont.setTitle(item, for: .normal)
            self.setupFamilyName(fontfamilyname: item)
            if self.delegate != nil {
                self.delegate?.selectFontFamily(family: item)
            }
        }
        dropDown.direction = .bottom
        dropDown.show()
    }
    
    func setupFamilyName(fontfamilyname:String){
        var arrayName = [String]()
        //  tagCollection.removeAllTags()
        for fontName: String in UIFont.fontNames(forFamilyName: fontfamilyname) {
            arrayName.append(fontName)
        }
        // tagCollection.addTags(arrayName)
    }
    
}
