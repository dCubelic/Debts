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
    @IBOutlet weak var currencyUnderlineView: UIView!
    
    var currencyPickerView: UIPickerView?
    var currencies = Currency.currencies.sorted(by: { $0.name < $1.name })
    var selectedCurrency = Currency.loadCurrency()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = NSLocalizedString("overview", comment: "")
        
        view.backgroundColor = UIColor(patternImage: #imageLiteral(resourceName: "paper_pattern"))
        
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "Settings"), style: .plain, target: self, action: #selector(settingsAction))
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapAction))
        view.addGestureRecognizer(tapGesture)
        
        NotificationCenter.default.addObserver(self, selector: #selector(reloadData), name: Notification.Name(Constants.Notifications.updatedDatabase), object: nil)
        
        setupViews()
        reloadData()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        UIView.transition(from: settingsView, to: homeView, duration: 0, options: [.transitionFlipFromRight, .showHideTransitionViews], completion: nil)
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "Settings"), style: .plain, target: self, action: #selector(settingsAction))
    }
    
    @objc func doneAction() {
        UIView.transition(from: settingsView, to: homeView, duration: 0.8, options: [.transitionFlipFromLeft, .showHideTransitionViews], completion: nil)
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "Settings"), style: .plain, target: self, action: #selector(settingsAction))
    }
    
    @objc func settingsAction() {
        UIView.transition(from: homeView, to: settingsView, duration: 0.8, options: [.transitionFlipFromRight, .showHideTransitionViews], completion: nil)
        
        currencyTextField.text = Currency.loadCurrency().name
        
        if let index = currencies.index(where: { (currency) -> Bool in
            currency == Currency.loadCurrency()
        }) {
            currencyPickerView?.selectRow(index, inComponent: 0, animated: true)
        }
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneAction))
    }
    
    func setupViews() {
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
        
        saveButton.layer.cornerRadius = 8
        saveButton.backgroundColor = UIColor(white: 246/255, alpha: 1)
        deleteAllDataButton.layer.cornerRadius = 8
        deleteAllDataButton.backgroundColor = UIColor(white: 246/255, alpha: 1)
        
        currencyUnderlineView.backgroundColor = UIColor(for: RealmHelper.getTotalOfDebts())
        currencyUnderlineView.layer.cornerRadius = 2
        
        initializeShadows()
        initializeCurrencyPickerView()
    }
    
    func initializeCurrencyPickerView() {
        currencyPickerView = UIPickerView()
        currencyPickerView?.delegate = self
        currencyPickerView?.dataSource = self
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
        
        saveButton.layer.shadowColor = UIColor.black.cgColor
        saveButton.layer.shadowOpacity = 0.2
        saveButton.layer.shadowOffset = CGSize.zero
        saveButton.layer.shadowRadius = 3
        
        deleteAllDataButton.layer.shadowColor = UIColor.black.cgColor
        deleteAllDataButton.layer.shadowOpacity = 0.2
        deleteAllDataButton.layer.shadowOffset = CGSize.zero
        deleteAllDataButton.layer.shadowRadius = 3
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
    
    @IBAction func saveAction(_ sender: Any) {
        Currency.saveCurrency(currency: selectedCurrency)
        NotificationCenter.default.post(name: Notification.Name(Constants.Notifications.updatedDatabase), object: nil)
        
        currencyTextField.resignFirstResponder()
    }
    
    @IBAction func deleteAllDataAction(_ sender: Any) {
        let alert = UIAlertController(title: NSLocalizedString("delete_all_data?", comment: ""), message: NSLocalizedString("are_you_sure_delete_all_data", comment: ""), preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("yes", comment: ""), style: .destructive, handler: { (_) in
            RealmHelper.deleteAllData()
            NotificationCenter.default.post(name: Notification.Name(Constants.Notifications.updatedDatabase), object: nil)
        }))
        alert.addAction(UIAlertAction(title: NSLocalizedString("no", comment: ""), style: .cancel, handler: nil))
        
        present(alert, animated: true, completion: nil)
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
