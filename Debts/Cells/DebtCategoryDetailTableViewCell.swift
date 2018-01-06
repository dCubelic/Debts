import UIKit

protocol DebtCategoryDetailTableViewCellDelegate: class {
    func debtCategoryDetailTableViewCell(_ cell: DebtCategoryDetailTableViewCell, didUpdateCost cost: Double)
}

class DebtCategoryDetailTableViewCell: UITableViewCell {
    
    @IBOutlet weak var personView: UIView!
    @IBOutlet weak var leftView: UIView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var costLabel: UILabel!
    @IBOutlet weak var costTextField: UITextField!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var underlineView: UIView!
    
    weak var delegate: DebtCategoryDetailTableViewCellDelegate?
    
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
        
        costTextField.isHidden = true
        costTextField.delegate = self
        costTextField.keyboardType = .decimalPad
        
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.2
        layer.shadowOffset = CGSize.zero
        layer.shadowRadius = 3
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        if highlighted {
            personView.backgroundColor = UIColor(white: 220/255, alpha: 1)
        } else {
            personView.backgroundColor = UIColor(white: 246/255, alpha: 1)
        }
    }
    
    func setup(with debt: Debt) {
        guard let person = debt.person else { return }
        
        leftView.backgroundColor = UIColor(for: person)
        underlineView.backgroundColor = UIColor(for: person)
        
        nameLabel.text = debt.person?.name
        dateLabel.text = dateFormatter.string(from: debt.dateAdded)
        costLabel.text = String(
            format: "%@%.2f%@",
            Constants.currencyBeforeValue ? Constants.currency : "",
            debt.cost,
            Constants.currencyBeforeValue ? "" : Constants.currency
        )
        
    }
    
    func editCost() {
        costLabel.isHidden = true
        costTextField.isHidden = false
        costTextField.becomeFirstResponder()
    }
    
}

extension DebtCategoryDetailTableViewCell: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.text = costLabel.text?.replacingOccurrences(of: Constants.currency, with: "")
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        let text = (textField.text ?? "").replacingOccurrences(of: ",", with: ".")
        guard let cost = Double(text) else { return }
        
        costLabel.text = String(
            format: "%@%.2f%@",
            Constants.currencyBeforeValue ? Constants.currency : "",
            cost,
            Constants.currencyBeforeValue ? "" : Constants.currency
        )
        
        costLabel.isHidden = false
        costTextField.isHidden = true
        
        delegate?.debtCategoryDetailTableViewCell(self, didUpdateCost: cost)
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        let text = (textField.text ?? "").replacingOccurrences(of: ",", with: ".")
        guard let _ = Double(text) else { return false }
        
        if text.count == 0 {
            return false
        }
        
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let currentText = textField.text as NSString? else { return true }
        let updatedText = currentText.replacingCharacters(in: range, with: string)
        
        let text = updatedText.replacingOccurrences(of: ",", with: ".")
        if let _ = Double(text) {
            return true
        } else if text.count == 0 {
            return true
        }
        
        return false
    }
}
