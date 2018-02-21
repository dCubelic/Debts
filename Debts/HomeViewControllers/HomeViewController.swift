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
    @IBOutlet weak var settingsView: UIView!
    @IBOutlet weak var currencyTextField: UITextField!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var deleteAllDataButton: UIButton!
    
    var currencyPickerView: UIPickerView?
    var showingSettings = false
    var currencies = Currency.currencies.sorted(by: { $0.name < $1.name })
    var selectedCurrency: Currency?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor(patternImage: #imageLiteral(resourceName: "paper_pattern"))
        
        title = "Home"

        navigationController?.navigationBar.prefersLargeTitles = true

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapAction))
        view.addGestureRecognizer(tapGesture)
        
        homeView.layer.cornerRadius = 25
        homeView.backgroundColor = UIColor(white: 246 / 255, alpha: 1)
        settingsView.layer.cornerRadius = 25
        settingsView.backgroundColor = UIColor(white: 246/255, alpha: 1)

        underlineView.backgroundColor = UIColor(for: RealmHelper.getTotalOfDebts())
        underlineView.layer.cornerRadius = 2
        underlineView2.backgroundColor = UIColor(white: 230 / 255, alpha: 1)

        newMyDebt.layer.cornerRadius = 8
        newMyDebt.backgroundColor = UIColor(white: 230 / 255, alpha: 1)
        newDebt.layer.cornerRadius = 8
        newDebt.backgroundColor = UIColor(white: 230 / 255, alpha: 1)

        myDebtsLabel.textColor = .red

        NotificationCenter.default.addObserver(self, selector: #selector(reloadData), name: Notification.Name(Constants.Notifications.updatedDatabase), object: nil)

        initializeShadows()
        initializeCurrencyPickerView()
        
        reloadData()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        UIView.transition(from: settingsView, to: homeView, duration: 0, options: [.transitionFlipFromRight, .showHideTransitionViews], completion: nil)
        showingSettings = false
    }
    
    func initializeCurrencyPickerView() {
        currencyPickerView = UIPickerView()
        currencyPickerView?.delegate = self
        currencyPickerView?.dataSource = self
//        currencyPickerView?.selectRow(<#T##row: Int##Int#>, inComponent: <#T##Int#>, animated: <#T##Bool#>)
        
        currencyTextField.inputView = currencyPickerView
    }

    func initializeShadows() {
        homeView.layer.shadowColor = UIColor.black.cgColor
        homeView.layer.shadowOpacity = 0.2
        homeView.layer.shadowOffset = CGSize.zero
        homeView.layer.shadowRadius = 3
        
        settingsView.layer.shadowColor = UIColor.black.cgColor
        settingsView.layer.shadowOpacity = 0.2
        settingsView.layer.shadowOffset = CGSize.zero
        settingsView.layer.shadowRadius = 3
    }
    
    @objc func tapAction() {
        view.endEditing(true)
    }

    @objc func reloadData() {
        let totalAllDebt = RealmHelper.getTotalOfAllDebts()
        totalDebtLabel.text = Currency.stringWithSelectedCurrency(for: totalAllDebt)

        let myTotalDebt = RealmHelper.getTotalOfMyDebts()
        let totalDebt = RealmHelper.getTotalOfDebts()

        debtsLabel.text = Currency.stringWithSelectedCurrency(for: totalDebt)
        myDebtsLabel.text = Currency.stringWithSelectedCurrency(for: myTotalDebt)

        let numberOfCategories = RealmHelper.getNumberOfDebtCategories()
        let numberOfPeople = RealmHelper.getNumberOfPeople()
        let numberOfDebts = RealmHelper.getNumberOfDebts()

        categoriesLabel.text = String(numberOfCategories)
        personsLabel.text = String(numberOfPeople)
        numberOfDebtsLabel.text = String(numberOfDebts)
    }
    
    @IBAction func settingsAction(_ sender: Any) {
        if showingSettings {
            UIView.transition(from: settingsView, to: homeView, duration: 0.8, options: [.transitionFlipFromRight, .showHideTransitionViews], completion: nil)
            showingSettings = false
        } else {
            UIView.transition(from: homeView, to: settingsView, duration: 0.8, options: [.transitionFlipFromRight, .showHideTransitionViews], completion: nil)
            currencyTextField.text = Currency.loadCurrency().name
            if let selectedCurrency = selectedCurrency, let index = currencies.index(of: selectedCurrency) {
                currencyPickerView?.selectRow(index, inComponent: 0, animated: true)
            }
            showingSettings = true
        }
    }
    
    @IBAction func saveAction(_ sender: Any) {
        if let currency = selectedCurrency {
            Currency.saveCurrency(currency: currency)
            NotificationCenter.default.post(name: Notification.Name(Constants.Notifications.updatedDatabase), object: nil)
        }
    }
    
    @IBAction func deleteAllDataAction(_ sender: Any) {
    }
}

extension HomeViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return currencies.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return currencies[row].name
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        currencyTextField.text = currencies[row].name
        selectedCurrency = currencies[row]
    }
}
