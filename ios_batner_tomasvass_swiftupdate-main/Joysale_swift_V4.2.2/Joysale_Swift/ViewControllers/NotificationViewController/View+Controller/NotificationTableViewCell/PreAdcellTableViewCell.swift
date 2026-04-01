import UIKit

class PreAdcellTableViewCell: UITableViewCell {

    @IBOutlet weak var CornerView: UIView!
    @IBOutlet weak var Plandays: UILabel!
    @IBOutlet weak var Planname: UILabel!
    @IBOutlet weak var price: UILabel!
    
    private let shadowContainer = UIView()

    override func awakeFromNib() {
        super.awakeFromNib()
        setupShadowView()
    }

    private func setupShadowView() {
        CornerView.layer.cornerRadius = 10
        CornerView.layer.masksToBounds = true
        CornerView.backgroundColor = UIColor(named: "BlackColorad")
        price.config(color: UIColor(named: "AppThemeColorNew"),
                              font: UIFont(name: APP_FONT_REGULAR, size: 16),
                              align: .right,
                              text: "")
        Planname.config(color: UIColor(named: "whitecolorfir"),
                              font: UIFont(name: APP_FONT_REGULAR, size: 15),
                              align: .right,
                              text: "")
        Plandays.config(color: UIColor(named: "whitecolorfir"),
                              font: UIFont(name: APP_FONT_REGULAR, size: 15),
                              align: .left,
                              text: "")
    }

}

