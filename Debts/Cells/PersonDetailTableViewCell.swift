import UIKit

class PersonDetailTableViewCell: UITableViewCell {

    @IBOutlet weak var personView: UIView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var leftView: UIView!
    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    let dateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "dd MMM yyyy"
        return df
    }()
    
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
    
    func setup(with debtCategoryByPerson: DebtCategoryByPerson) {
        nameLabel.text = debtCategoryByPerson.debtCategory.name
        leftView.backgroundColor = UIColor(for: debtCategoryByPerson.debtCategory)
        dateLabel.text = dateFormatter.string(from: debtCategoryByPerson.dateAdded)
        
        detailLabel.text = String(
            format: "%@%.2f%@",
            Constants.currencyBeforeValue ? Constants.currency : "",
            debtCategoryByPerson.debtCategory.totalDebt,
            Constants.currencyBeforeValue ? "" : Constants.currency
        )
        
       
    }
    
}
