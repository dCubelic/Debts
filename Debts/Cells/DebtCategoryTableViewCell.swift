import UIKit

protocol DebtCategoryTableViewCellDelegate: class {
    func debtCategoryTableViewCell(_ cell: DebtCategoryTableViewCell, didChangeTitleTo title: String)
}

class DebtCategoryTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var categoryView: UIView!
    @IBOutlet weak var leftView: UIView!
    @IBOutlet weak var underlineView: UIView!
    
    weak var delegate: DebtCategoryTableViewCellDelegate?
    
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
        
        titleTextField.isHidden = true
        titleTextField.delegate = self
        
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.2
        layer.shadowOffset = CGSize.zero
        layer.shadowRadius = 3
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
        
        let debts = RealmHelper.getDebts(for: debtCategory)
        
        if(debts.count > 2) {
            subtitleLabel.text = "\(debts.count) people"
        } else {
            var peopleString = ""
            for debt in debts {
                peopleString += debt.person?.name ?? ""
                peopleString += ", "
            }
            peopleString.removeLast()
            peopleString.removeLast()
            subtitleLabel.text = peopleString
        }
    }

    func editTitle() {
        titleTextField.isHidden = false
        titleLabel.isHidden = true
        titleTextField.text = titleLabel.text
        titleTextField.becomeFirstResponder()
    }
    
}

extension DebtCategoryTableViewCell: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        guard let text = textField.text else { return }
        titleLabel.text = textField.text
        
        titleTextField.isHidden = true
        titleLabel.isHidden = false
        
        delegate?.debtCategoryTableViewCell(self, didChangeTitleTo: text)
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        guard let text = textField.text else { return false }
        
        if text.count == 0 {
            return false
        }
        
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
