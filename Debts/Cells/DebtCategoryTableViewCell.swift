import UIKit

class DebtCategoryTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var categoryView: UIView!
    @IBOutlet weak var leftView: UIView!
    @IBOutlet weak var underlineView: UIView!
    
    let dateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "dd MMM yyyy"
        return df
    }()
    
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
    
    func setup(with debtCategory: DebtCategory) {
        titleLabel.text = debtCategory.name
        dateLabel.text = dateFormatter.string(from: debtCategory.dateCreated)
        
        detailLabel.text = String(
            format: "%@%.2f%@",
            Constants.currencyBeforeValue ? Constants.currency : "",
            debtCategory.totalDebt,
            Constants.currencyBeforeValue ? "" : Constants.currency
        )
        
        let color = UIColor(for: debtCategory)
        
        leftView.backgroundColor = color
        underlineView.backgroundColor = color
        
        let people = RealmHelper.getPersons(for: debtCategory).map { $0.person }
        
        if(people.count > 2) {
            subtitleLabel.text = "\(people.count) people"
        } else {
            var peopleString = ""
            for person in people {
                peopleString += person.name
                peopleString += ", "
            }
            peopleString.removeLast()
            peopleString.removeLast()
            subtitleLabel.text = peopleString
        }
    }

}
