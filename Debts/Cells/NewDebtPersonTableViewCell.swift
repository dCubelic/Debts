import UIKit

protocol NewDebtPersonTableViewCellDelegate: class {
    func newDebtPersonTableViewCell(_ cell: NewDebtPersonTableViewCell, didChangeCostTo cost: Double)
}

class NewDebtPersonTableViewCell: UITableViewCell {

    @IBOutlet weak var cellView: UIView!
    @IBOutlet weak var leftView: UIView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var costTextField: UITextField!

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
}

extension NewDebtPersonTableViewCell: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.text = costTextField.text?.replacingOccurrences(of: Constants.currency, with: "")
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        let text = (textField.text ?? "").replacingOccurrences(of: ",", with: ".")
        guard let cost = Double(text) else { return }

        costTextField.text = String(
            format: "%@%.2f%@",
            Constants.currencyBeforeValue ? Constants.currency : "",
            cost,
            Constants.currencyBeforeValue ? "" : Constants.currency
        )

        delegate?.newDebtPersonTableViewCell(self, didChangeCostTo: cost)
    }

//    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
//        let text = (textField.text ?? "").replacingOccurrences(of: ",", with: ".")
//        guard let _ = Double(text) else { return false }
//
//        return true
//    }

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
