import UIKit
import Imaginary

open class LightboxImage {

  open fileprivate(set) var image: UIImage?
  open fileprivate(set) var imageURL: URL?
  open fileprivate(set) var videoURL: URL?
open fileprivate(set) var gifURL: URL?

  open var text: String

  // MARK: - Initialization

  public init(image: UIImage, text: String = "", videoURL: URL? = nil) {
    self.image = image
    let arrayText =  text.components(separatedBy: "\n")
    self.text = text
    if arrayText.count != 0 {
        if !arrayText[0].isEmpty  &&  !arrayText[1].isEmpty{
            self.text = text.trim()
        }else {
            if !arrayText[0].isEmpty{
                self.text = arrayText[0]
              }
            if !arrayText[1].isEmpty{
                self.text = arrayText[1]
            }
        }
    }
    self.videoURL = videoURL
  }

  public init(imageURL: URL, text: String = "", videoURL: URL? = nil) {
    self.imageURL = imageURL
    self.text = text
    let arrayText =  text.components(separatedBy: "\n")
    if arrayText.count != 0 {
        if !arrayText[0].isEmpty  &&  !arrayText[1].isEmpty{
            self.text = text.trim()
        }else {
            if !arrayText[0].isEmpty{
                self.text = arrayText[0]
            }
            if !arrayText[1].isEmpty{
                self.text = arrayText[1]
            }
        }
    }
    self.videoURL = videoURL
  }

  open func addImageTo(_ imageView: UIImageView, completion: ((UIImage?) -> Void)? = nil) {
    if let image = image {
      imageView.image = image
      completion?(image)
    } else if let imageURL = imageURL {
      LightboxConfig.loadImage(imageView, imageURL, completion)
    }
  }
   
}


extension String {
    func trim() -> String{
        return self.trimmingCharacters(in: NSCharacterSet.whitespaces)
    }
}
