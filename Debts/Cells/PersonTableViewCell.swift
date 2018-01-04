import UIKit

class PersonTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet weak var categoryView: UIView!
    @IBOutlet weak var leftView: UIView!
    @IBOutlet weak var underlineView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()

        selectionStyle = .none
        
        self.backgroundColor = .clear
        
        categoryView.layer.cornerRadius = 8
        categoryView.clipsToBounds = true
        categoryView.backgroundColor = UIColor(white: 246/255, alpha: 1)
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        if highlighted {
            categoryView.backgroundColor = UIColor(white: 220/255, alpha: 1)
        } else {
            categoryView.backgroundColor = UIColor(white: 246/255, alpha: 1)
        }
    }
    
    func setup(with person: Person) {
        titleLabel.text = person.name
        detailLabel.text = String(
            format: "%@%.2f%@",
            Constants.currencyBeforeValue ? Constants.currency : "",
            person.totalDebt,
            Constants.currencyBeforeValue ? "" : Constants.currency
        )
        
        let color = UIColor(for: person)
        
        leftView.backgroundColor = color
        underlineView.backgroundColor = color
        
        let debtCategories = RealmHelper.getDebtCategories(for: person).map { $0.debtCategory }
        
        if(debtCategories.count > 2 || debtCategories.count == 0) {
            subtitleLabel.text = "\(debtCategories.count) debts"
        } else {
            var debtsString = ""
            for debtCategory in debtCategories {
                debtsString += debtCategory.name
                debtsString += ", "
            }
            debtsString.removeLast()
            debtsString.removeLast()
            subtitleLabel.text = debtsString
        }
    }
}
