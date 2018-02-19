import UIKit

protocol NewDebtPersonTableViewCellDelegate: class {
    func newDebtPersonTableViewCell(_ cell: NewDebtPersonTableViewCell, didChangeCostTo cost: Double)
    func newDebtPersonTableViewCell(_ cell: NewDebtPersonTableViewCell, changingCostTo cost: Double)
    func newDebtPersonTableViewCell(_ cell: NewDebtPersonTableViewCell, didChangeNameTo name: String)
}

class NewDebtPersonTableViewCell: UITableViewCell {

    @IBOutlet weak var cellView: UIView!
    @IBOutlet weak var leftView: UIView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var costTextField: UITextField!
    @IBOutlet weak var nameTextField: UITextField!
    
    weak var delegate: NewDebtPersonTableViewCellDelegate?

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

        costTextField.delegate = self
        nameTextField.delegate = self
        
        nameTextField.isUserInteractionEnabled = false

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

    func setup(with person: Person, selected: Bool, cost: Double?) {
        personColor = UIColor(for: person)
        nameLabel.text = person.name
        nameTextField.text = person.name

        if selected {
            isCellSelected = true
        } else {
            isCellSelected = false
        }

        costTextField.text = String(
            format: "%@%.2f%@",
            Constants.currencyBeforeValue ? Constants.currency : "",
            cost ?? 0,
            Constants.currencyBeforeValue ? "" : Constants.currency
        )

    }
    
    func editName() {
        nameTextField.isUserInteractionEnabled = true
        nameTextField.becomeFirstResponder()
    }
}

extension NewDebtPersonTableViewCell: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == costTextField {
            textField.text = costTextField.text?.replacingOccurrences(of: Constants.currency, with: "")
            textField.text = costTextField.text?.replacingOccurrences(of: "0.00", with: "")
            textField.text = costTextField.text?.replacingOccurrences(of: ".00", with: "")
        } else if textField == nameTextField {
            
        }
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == costTextField {
            var text = (textField.text ?? "").replacingOccurrences(of: ",", with: ".")
            if text.isEmpty { text = "0" }
            guard let cost = Double(text) else { return }
            
            costTextField.text = String(
                format: "%@%.2f%@",
                Constants.currencyBeforeValue ? Constants.currency : "",
                cost,
                Constants.currencyBeforeValue ? "" : Constants.currency
            )
            
            delegate?.newDebtPersonTableViewCell(self, didChangeCostTo: cost)
        } else if textField == nameTextField {
            delegate?.newDebtPersonTableViewCell(self, didChangeNameTo: nameTextField.text ?? "")
            costTextField.becomeFirstResponder()
        }
    }

//    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
//        let text = (textField.text ?? "").replacingOccurrences(of: ",", with: ".")
//        guard let _ = Double(text) else { return false }
//
//        return true
//    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == costTextField {
            guard let currentText = textField.text as NSString? else { return true }
            let updatedText = currentText.replacingCharacters(in: range, with: string)
            
            let text = updatedText.replacingOccurrences(of: ",", with: ".")
            if let cost = Double(text) {
                delegate?.newDebtPersonTableViewCell(self, changingCostTo: cost)
                return true
            } else if text.count == 0 {
                delegate?.newDebtPersonTableViewCell(self, changingCostTo: 0)
                return true
            }
            
            return false
        } else if textField == nameTextField {
            
        }
        
        return true
    }
}
