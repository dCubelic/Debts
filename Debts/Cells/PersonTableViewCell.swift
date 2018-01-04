import UIKit

protocol PersonTableViewCellDelegate: class {
    func personTableViewCell(_ cell: PersonTableViewCell, didChangeNameTo name: String)
}

class PersonTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet weak var personView: UIView!
    @IBOutlet weak var leftView: UIView!
    @IBOutlet weak var underlineView: UIView!
    @IBOutlet weak var nameTextField: UITextField!
    
    weak var delegate: PersonTableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()

        selectionStyle = .none
        
        self.backgroundColor = .clear
        
        personView.layer.cornerRadius = 8
        personView.clipsToBounds = true
        personView.backgroundColor = UIColor(white: 246/255, alpha: 1)
        
        nameTextField.isHidden = true
        nameTextField.delegate = self
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
    
    func editName() {
        nameTextField.text = titleLabel.text
        nameTextField.isHidden = false
        titleLabel.isHidden = true
        nameTextField.becomeFirstResponder()
    }
}

extension PersonTableViewCell: UITextFieldDelegate {
    
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextFieldDidEndEditingReason) {
        guard let text = textField.text else { return }
        titleLabel.text = textField.text
        
        titleLabel.isHidden = false
        nameTextField.isHidden = true
        
        delegate?.personTableViewCell(self, didChangeNameTo: text)
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
