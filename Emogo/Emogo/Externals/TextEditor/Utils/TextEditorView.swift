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
    static var kDefaultFontType = 0
    static var kSelectedTag:Int = 0
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
    @IBOutlet var btnTitle: UIButton!
    @IBOutlet var btnHeading: UIButton!
    @IBOutlet var btnBody: UIButton!
    @IBOutlet var btnBold: UIButton!
    @IBOutlet var btnItalic: UIButton!
    @IBOutlet var btnUnderline: UIButton!

    let dropDown = DropDown()
    var delegate:TextEditorViewDelegate?
    var fontName = [String]()


    class func instanceFromNib() -> TextEditorView {
        return  UINib(nibName: "TextEditorView", bundle: nil).instantiate(withOwner: nil, options: nil).first  as! TextEditorView
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        for fontfamilyname: String in UIFont.familyNames {
            fontName.append(fontfamilyname)
        }
        
        if TextEditorViewConstants.kDefaultFontType != 0 {
            let item = self.fontName[TextEditorViewConstants.kDefaultFontType]
            self.btnSelectFont.setTitle(item, for: .normal)
        }
        if TextEditorViewConstants.kSelectedTag != 0 {
            self.selected(tag: TextEditorViewConstants.kSelectedTag)
        }
    }
   
    @IBAction func btnActionForTextOptions(_ sender: UIButton) {
         TextEditorViewConstants.kSelectedTag = sender.tag
        
        switch tag {
        case 101:
            if delegate != nil {
                self.delegate?.selectHeader(tag: 1)
            }
            self.btnTitle.setImage(#imageLiteral(resourceName: "titel_active"), for: .normal)
            self.btnHeading.setImage(#imageLiteral(resourceName: "heading"), for: .normal)
            self.btnBody.setImage(#imageLiteral(resourceName: "body"), for: .normal)
            self.btnBold.setImage(#imageLiteral(resourceName: "bold"), for: .normal)
            self.btnItalic.setImage(#imageLiteral(resourceName: "italic"), for: .normal)
            self.btnUnderline.setImage(#imageLiteral(resourceName: "underline"), for: .normal)
            break
        case 102:
            if delegate != nil {
                self.delegate?.selectHeader(tag: 2)
            }
            
            self.btnTitle.setImage(#imageLiteral(resourceName: "title"), for: .normal)
            self.btnHeading.setImage(#imageLiteral(resourceName: "heading_active"), for: .normal)
            self.btnBody.setImage(#imageLiteral(resourceName: "body"), for: .normal)
            self.btnBold.setImage(#imageLiteral(resourceName: "bold"), for: .normal)
            self.btnItalic.setImage(#imageLiteral(resourceName: "italic"), for: .normal)
            self.btnUnderline.setImage(#imageLiteral(resourceName: "underline"), for: .normal)
            
            break
        case 103:
            if delegate != nil {
                self.delegate?.selectBody()
            }
            
            self.btnTitle.setImage(#imageLiteral(resourceName: "title"), for: .normal)
            self.btnHeading.setImage(#imageLiteral(resourceName: "heading"), for: .normal)
            self.btnBody.setImage(#imageLiteral(resourceName: "body_active"), for: .normal)
            self.btnBold.setImage(#imageLiteral(resourceName: "bold"), for: .normal)
            self.btnItalic.setImage(#imageLiteral(resourceName: "italic"), for: .normal)
            self.btnUnderline.setImage(#imageLiteral(resourceName: "underline"), for: .normal)
            
            break
        case 201:
            if delegate != nil {
                self.delegate?.selectBold()
            }
            self.btnTitle.setImage(#imageLiteral(resourceName: "title"), for: .normal)
            self.btnHeading.setImage(#imageLiteral(resourceName: "heading"), for: .normal)
            self.btnBody.setImage(#imageLiteral(resourceName: "body"), for: .normal)
            self.btnBold.setImage(#imageLiteral(resourceName: "bold_active"), for: .normal)
            self.btnItalic.setImage(#imageLiteral(resourceName: "italic"), for: .normal)
            self.btnUnderline.setImage(#imageLiteral(resourceName: "underline"), for: .normal)
            break
        case 202:
            if delegate != nil {
                self.delegate?.selectItalic()
            }
            self.btnTitle.setImage(#imageLiteral(resourceName: "title"), for: .normal)
            self.btnHeading.setImage(#imageLiteral(resourceName: "heading"), for: .normal)
            self.btnBody.setImage(#imageLiteral(resourceName: "body"), for: .normal)
            self.btnBold.setImage(#imageLiteral(resourceName: "bold"), for: .normal)
            self.btnItalic.setImage(#imageLiteral(resourceName: "italic_active"), for: .normal)
            self.btnUnderline.setImage(#imageLiteral(resourceName: "underline"), for: .normal)
            
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
        
         self.selected(tag: sender.tag)
    }
    
    
    func selected(tag:Int) {
        switch tag {
        case 101:
            if delegate != nil {
                self.delegate?.selectHeader(tag: 1)
            }
            self.btnTitle.setImage(#imageLiteral(resourceName: "titel_active"), for: .normal)
            self.btnHeading.setImage(#imageLiteral(resourceName: "heading"), for: .normal)
            self.btnBody.setImage(#imageLiteral(resourceName: "body"), for: .normal)
            self.btnBold.setImage(#imageLiteral(resourceName: "bold"), for: .normal)
            self.btnItalic.setImage(#imageLiteral(resourceName: "italic"), for: .normal)
            self.btnUnderline.setImage(#imageLiteral(resourceName: "underline"), for: .normal)
            break
        case 102:
            if delegate != nil {
                self.delegate?.selectHeader(tag: 2)
            }
            
            self.btnTitle.setImage(#imageLiteral(resourceName: "title"), for: .normal)
            self.btnHeading.setImage(#imageLiteral(resourceName: "heading_active"), for: .normal)
            self.btnBody.setImage(#imageLiteral(resourceName: "body"), for: .normal)
            self.btnBold.setImage(#imageLiteral(resourceName: "bold"), for: .normal)
            self.btnItalic.setImage(#imageLiteral(resourceName: "italic"), for: .normal)
            self.btnUnderline.setImage(#imageLiteral(resourceName: "underline"), for: .normal)
            
            break
        case 103:
            if delegate != nil {
                self.delegate?.selectBody()
            }
            
            self.btnTitle.setImage(#imageLiteral(resourceName: "title"), for: .normal)
            self.btnHeading.setImage(#imageLiteral(resourceName: "heading"), for: .normal)
            self.btnBody.setImage(#imageLiteral(resourceName: "body_active"), for: .normal)
            self.btnBold.setImage(#imageLiteral(resourceName: "bold"), for: .normal)
            self.btnItalic.setImage(#imageLiteral(resourceName: "italic"), for: .normal)
            self.btnUnderline.setImage(#imageLiteral(resourceName: "underline"), for: .normal)
            
            break
        case 201:
            if delegate != nil {
                self.delegate?.selectBold()
            }
            self.btnTitle.setImage(#imageLiteral(resourceName: "title"), for: .normal)
            self.btnHeading.setImage(#imageLiteral(resourceName: "heading"), for: .normal)
            self.btnBody.setImage(#imageLiteral(resourceName: "body"), for: .normal)
            self.btnBold.setImage(#imageLiteral(resourceName: "bold_active"), for: .normal)
            self.btnItalic.setImage(#imageLiteral(resourceName: "italic"), for: .normal)
            self.btnUnderline.setImage(#imageLiteral(resourceName: "underline"), for: .normal)
            break
        case 202:
            if delegate != nil {
                self.delegate?.selectItalic()
            }
            self.btnTitle.setImage(#imageLiteral(resourceName: "title"), for: .normal)
            self.btnHeading.setImage(#imageLiteral(resourceName: "heading"), for: .normal)
            self.btnBody.setImage(#imageLiteral(resourceName: "body"), for: .normal)
            self.btnBold.setImage(#imageLiteral(resourceName: "bold"), for: .normal)
            self.btnItalic.setImage(#imageLiteral(resourceName: "italic_active"), for: .normal)
            self.btnUnderline.setImage(#imageLiteral(resourceName: "underline"), for: .normal)
            
            break
        case 203:
            if delegate != nil {
                self.delegate?.selectUnderline()
            }
            
            self.btnTitle.setImage(#imageLiteral(resourceName: "title"), for: .normal)
            self.btnHeading.setImage(#imageLiteral(resourceName: "heading"), for: .normal)
            self.btnBody.setImage(#imageLiteral(resourceName: "body"), for: .normal)
            self.btnBold.setImage(#imageLiteral(resourceName: "bold"), for: .normal)
            self.btnItalic.setImage(#imageLiteral(resourceName: "italic"), for: .normal)
            self.btnUnderline.setImage(#imageLiteral(resourceName: "underline_active"), for: .normal)
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
     
        dropDown.anchorView = btnSelectFont
        dropDown.dataSource = fontName
        dropDown.selectionAction = { [unowned self] (index: Int, item: String) in
            print("Selected item: \(item) at index: \(index)")
            TextEditorViewConstants.kDefaultFontType = index
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
