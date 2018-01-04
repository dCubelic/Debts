import UIKit

class PersonTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet weak var personView: UIView!
    @IBOutlet weak var leftView: UIView!
    @IBOutlet weak var underlineView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()

        selectionStyle = .none
        
        self.backgroundColor = .clear
        
        personView.layer.cornerRadius = 8
        personView.clipsToBounds = true
        personView.backgroundColor = UIColor(white: 246/255, alpha: 1)
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        if highlighted {
            personView.backgroundColor = UIColor(white: 220/255, alpha: 1)
        } else {
            personView.backgroundColor = UIColor(white: 246/255, alpha: 1)
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
        
        if debtCategories.count == 1 {
            subtitleLabel.text = debtCategories.first?.name
        } else {
            subtitleLabel.text = "\(debtCategories.count) debts"
        }
        
    }
}
