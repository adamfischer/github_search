import UIKit
import RxSwift

class RepositoryTableViewCell: UITableViewCell {
    private(set) var disposeBag = DisposeBag()
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    @IBOutlet weak var ownerLabel: UILabel!
    @IBOutlet weak var avatarImageView: UIImageView!
    
    @IBOutlet weak var starsLabel: UILabel!
    @IBOutlet weak var starsCountLabel: UILabel!
    
    @IBOutlet weak var languageLabel: UILabel!
    @IBOutlet weak var languagesListLabel: UILabel!
    
    @IBOutlet var debugBackgroundViews: [UIView]!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        for view in debugBackgroundViews {
            view.backgroundColor = .clear
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
    }
}
