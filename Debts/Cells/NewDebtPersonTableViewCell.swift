import UIKit

class NewDebtPersonTableViewCell: UITableViewCell {

    @IBOutlet weak var cellView: UIView!
    @IBOutlet weak var leftView: UIView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var costTextField: UITextField!
    
    var personColor: UIColor?
    var isCellSelected: Bool = true {
        didSet {
            if isCellSelected {
                leftView.backgroundColor = personColor
                contentView.alpha = 1
            } else {
                contentView.alpha = 0.3
                leftView.backgroundColor = UIColor.gray
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        selectionStyle = .none
        
        self.backgroundColor = .clear
        
        cellView.layer.cornerRadius = 8
        cellView.clipsToBounds = true
        cellView.backgroundColor = UIColor(white: 246/255, alpha: 1)
        
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.2
        layer.shadowOffset = CGSize.zero
        layer.shadowRadius = 3
        
        switchSelection()
    }
    
    func switchSelection() {
        isCellSelected = !isCellSelected
    }
    
//    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
//        if highlighted {
//            cellView.backgroundColor = UIColor(white: 220/255, alpha: 1)
//        } else {
//            cellView.backgroundColor = UIColor(white: 246/255, alpha: 1)
//        }
//    }
    
    func setup(with person: Person, selected: Bool) {
        personColor = UIColor(for: person)
        nameLabel.text = person.name
        
        if selected {
            isCellSelected = true
        } else {
            isCellSelected = false
        }
    }
}
