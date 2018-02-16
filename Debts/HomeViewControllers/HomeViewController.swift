import UIKit

class HomeViewController: UIViewController {

    @IBOutlet weak var homeView: UIView!
    @IBOutlet weak var underlineView: UIView!
    @IBOutlet weak var underlineView2: UIView!
    @IBOutlet weak var totalDebtLabel: UILabel!
    @IBOutlet weak var debtsLabel: UILabel!
    @IBOutlet weak var myDebtsLabel: UILabel!
    @IBOutlet weak var categoriesLabel: UILabel!
    @IBOutlet weak var personsLabel: UILabel!
    @IBOutlet weak var numberOfDebtsLabel: UILabel!
    @IBOutlet weak var newMyDebt: UIButton!
    @IBOutlet weak var newDebt: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor(patternImage: #imageLiteral(resourceName: "paper_pattern"))
        
        title = "Home"

        navigationController?.navigationBar.prefersLargeTitles = true

        homeView.layer.cornerRadius = 25
        homeView.backgroundColor = UIColor(white: 246 / 255, alpha: 1)

        underlineView.backgroundColor = UIColor(for: RealmHelper.getTotalOfDebts())
        underlineView.layer.cornerRadius = 2
        underlineView2.backgroundColor = UIColor(white: 230 / 255, alpha: 1)

        newMyDebt.layer.cornerRadius = 8
        newMyDebt.backgroundColor = UIColor(white: 230 / 255, alpha: 1)
        newDebt.layer.cornerRadius = 8
        newDebt.backgroundColor = UIColor(white: 230 / 255, alpha: 1)

        myDebtsLabel.textColor = .red

        NotificationCenter.default.addObserver(self, selector: #selector(reloadData), name: Notification.Name(Constants.Notifications.updatedDatabase), object: nil)

        initializeShadow()

        reloadData()
    }

    func initializeShadow() {
        homeView.layer.shadowColor = UIColor.black.cgColor
        homeView.layer.shadowOpacity = 0.2
        homeView.layer.shadowOffset = CGSize.zero
        homeView.layer.shadowRadius = 3
    }

    @IBAction func newMyDebtAction(_ sender: Any) {

    }

    @IBAction func newDebtAction(_ sender: Any) {

    }

    @objc func reloadData() {
        let totalAllDebt = RealmHelper.getTotalOfAllDebts()
        totalDebtLabel.text = formatWithCurrency(number: totalAllDebt)

        let myTotalDebt = RealmHelper.getTotalOfMyDebts()
        let totalDebt = RealmHelper.getTotalOfDebts()

        debtsLabel.text = formatWithCurrency(number: totalDebt)
        myDebtsLabel.text = formatWithCurrency(number: myTotalDebt)

        let numberOfCategories = RealmHelper.getNumberOfDebtCategories()
        let numberOfPeople = RealmHelper.getNumberOfPeople()
        let numberOfDebts = RealmHelper.getNumberOfDebts()

        categoriesLabel.text = String(numberOfCategories)
        personsLabel.text = String(numberOfPeople)
        numberOfDebtsLabel.text = String(numberOfDebts)

    }

    private func formatWithCurrency(number: Double) -> String {
        return String(
            format: "%@%.2f%@",
            Constants.currencyBeforeValue ? Constants.currency : "",
            number,
            Constants.currencyBeforeValue ? "" : Constants.currency
        )
    }

}
