import UIKit

protocol DebtDetailTableViewCellDelegate: class {
    func debtDetailTableViewCell(_ cell: DebtDetailTableViewCell, didUpdateCost cost: Double)
    func debtDetailTableViewCellDidCancel(_ cell: DebtDetailTableViewCell)
}

class DebtDetailTableViewCell: UITableViewCell {

    @IBOutlet weak var personView: UIView!
    @IBOutlet weak var leftView: UIView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var costLabel: UILabel!
    @IBOutlet weak var costTextField: UITextField!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var underlineView: UIView!

    weak var delegate: DebtDetailTableViewCellDelegate?

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
        personView.backgroundColor = .cellBackgroundColor

        costTextField.isHidden = true
        costTextField.delegate = self
        costTextField.keyboardType = .decimalPad

        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.2
        layer.shadowOffset = CGSize.zero
        layer.shadowRadius = 3

        let holdGesture = UILongPressGestureRecognizer(target: self, action: #selector(editCost))
        addGestureRecognizer(holdGesture)
    }

    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        if highlighted {
            personView.backgroundColor = .cellBackgroundColorHighlighted
        } else {
            personView.backgroundColor = .cellBackgroundColor
        }
    }

    func setupForDebtCategoryDetails(with debt: Debt) {
        guard let person = debt.person else { return }

        leftView.backgroundColor = UIColor(for: person)
        underlineView.backgroundColor = UIColor(for: person)

        nameLabel.text = debt.person?.name
        dateLabel.text = dateFormatter.string(from: debt.dateAdded)

        costLabel.text = Currency.stringWithSelectedCurrency(for: debt.cost)
    }

    func setupForPersonDetails(with debt: Debt) {
        guard let debtCategory = debt.debtCategory else { return }

        leftView.backgroundColor = UIColor(for: debtCategory)
        underlineView.backgroundColor = UIColor(for: debtCategory)

        nameLabel.text = debtCategory.name
        dateLabel.text = dateFormatter.string(from: debt.dateAdded)

        costLabel.text = Currency.stringWithSelectedCurrency(for: debt.cost)
        
        if debtCategory.isMyDebt {
            costLabel.textColor = .red
        } else {
            costLabel.textColor = .black
        }
    }

    @objc func editCost() {
        costLabel.isHidden = true
        costTextField.isHidden = false
        costTextField.becomeFirstResponder()
    }

}

extension DebtDetailTableViewCell: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.text = costLabel.text?.replacingOccurrences(of: Currency.loadCurrency().symbol, with: "")
        if textField.text == "0.00" {
            textField.text = ""
        }
        textField.text = costTextField.text?.replacingOccurrences(of: ".00", with: "")
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        costLabel.isHidden = false
        costTextField.isHidden = true
        
        let text = (textField.text ?? "").replacingOccurrences(of: ",", with: ".")
        
        guard let cost = Double(text) else {
            delegate?.debtDetailTableViewCellDidCancel(self)
            return
        }

        costLabel.text = Currency.stringWithSelectedCurrency(for: cost)

        delegate?.debtDetailTableViewCell(self, didUpdateCost: cost)
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let currentText = textField.text as NSString? else { return true }
        let updatedText = currentText.replacingCharacters(in: range, with: string)

        let text = updatedText.replacingOccurrences(of: ",", with: ".")
        if Double(text) != nil {
            return true
        } else if text.count == 0 {
            return true
        }

        return false
    }
}
