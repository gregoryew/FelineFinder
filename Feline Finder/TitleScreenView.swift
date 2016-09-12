import UIKit

@IBDesignable
class TitleScreenView: UIView {
    override func drawRect(rect: CGRect) {
        super.drawRect(rect)
        TitleScreenCode.drawCanvas1()
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}