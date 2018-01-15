

import UIKit

@IBDesignable
class CardView: UIView {

    @IBInspectable var cRadius: CGFloat = 2

    @IBInspectable var shadowOffsetWidth: Int = 0
    @IBInspectable var shadowOffsetHeight: Int = 3
    @IBInspectable var shadowColorr: UIColor? = UIColor.black
    @IBInspectable var shadowOpacityy: Float = 0.5

    override func layoutSubviews() {
        layer.cornerRadius = cRadius
        let shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: cRadius)

        layer.masksToBounds = false
        layer.shadowColor = shadowColorr?.cgColor
        layer.shadowOffset = CGSize(width: shadowOffsetWidth, height: shadowOffsetHeight);
        layer.shadowOpacity = shadowOpacityy
        layer.shadowPath = shadowPath.cgPath
    }

}
