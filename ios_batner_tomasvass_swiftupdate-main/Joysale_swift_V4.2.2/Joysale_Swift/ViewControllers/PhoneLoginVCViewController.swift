import UIKit
import FirebaseAuth

struct Country {
    let name: String
    let code: String
    let dialCode: String
}

class PhoneLoginVCViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    let countryButton = UIButton(type: .system)
    let phoneTextField = UITextField()
    let sendButton = UIButton(type: .system)
    
    var tableView: UITableView?
    var backgroundView: UIView?
    
    var verificationID: String?
    
    let countries = [
        Country(name: "India", code: "IN", dialCode: "+91"),
        Country(name: "United States", code: "US", dialCode: "+1"),
        Country(name: "United Kingdom", code: "GB", dialCode: "+44"),
        Country(name: "Australia", code: "AU", dialCode: "+61"),
        Country(name: "Canada", code: "CA", dialCode: "+1")
    ]
    
    var selectedCountry: Country?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        selectedCountry = countries.first
        setupUI()
        updateCountryButton()
    }
    
    // MARK: UI Setup
    
    func setupUI() {
        
        countryButton.addTarget(self, action: #selector(openCountryPicker), for: .touchUpInside)
        countryButton.contentHorizontalAlignment = .center
        countryButton.layer.borderWidth = 1
        countryButton.layer.borderColor = UIColor.lightGray.cgColor
        countryButton.layer.cornerRadius = 8
        countryButton.widthAnchor.constraint(equalToConstant: 100).isActive = true
        
        phoneTextField.placeholder = "Enter phone number"
        phoneTextField.keyboardType = .numberPad
        phoneTextField.borderStyle = .roundedRect
        
        sendButton.setTitle("Send OTP", for: .normal)
        sendButton.backgroundColor = .systemBlue
        sendButton.tintColor = .white
        sendButton.layer.cornerRadius = 8
        sendButton.heightAnchor.constraint(equalToConstant: 45).isActive = true
        sendButton.addTarget(self, action: #selector(sendOTP), for: .touchUpInside)
        
        // 🔹 Horizontal stack (Country + Phone)
        let phoneStack = UIStackView(arrangedSubviews: [
            countryButton,
            phoneTextField
        ])
        
        phoneStack.axis = .horizontal
        phoneStack.spacing = 10
        phoneStack.distribution = .fill
        phoneStack.translatesAutoresizingMaskIntoConstraints = false
        
        // 🔹 Main Vertical stack
        let mainStack = UIStackView(arrangedSubviews: [
            phoneStack,
            sendButton
        ])
        
        mainStack.axis = .vertical
        mainStack.spacing = 20
        mainStack.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(mainStack)
        
        NSLayoutConstraint.activate([
            mainStack.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            mainStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            mainStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30)
        ])
    }
    
    func updateCountryButton() {
        guard let country = selectedCountry else { return }
        let flagEmoji = flag(from: country.code)
        countryButton.setTitle("\(flagEmoji) \(country.dialCode) ▼", for: .normal)
    }
    
    // MARK: Flag
    
    func flag(from countryCode: String) -> String {
        var flag = ""
        for scalar in countryCode.unicodeScalars {
            flag.unicodeScalars.append(UnicodeScalar(127397 + scalar.value)!)
        }
        return flag
    }
    
    // MARK: Picker
    
    @objc func openCountryPicker() {
        
        backgroundView = UIView(frame: view.bounds)
        backgroundView?.backgroundColor = .red
        backgroundView?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(closePicker)))
        
        tableView = UITableView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height))
        tableView?.layer.cornerRadius = 12
        tableView?.delegate = self
        tableView?.dataSource = self
        
        tableView?.register(CountryCell.self, forCellReuseIdentifier: CountryCell.identifier)
        
        if let bg = backgroundView, let tv = tableView {
            view.addSubview(bg)
            view.addSubview(tv)
        }
    }
    
    @objc func closePicker() {
        tableView?.removeFromSuperview()
        backgroundView?.removeFromSuperview()
    }
    
    // MARK: TableView
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        countries.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CountryCell.identifier, for: indexPath) as? CountryCell else {
            return UITableViewCell()
        }
        
        let country = countries[indexPath.row]
        let flagEmoji = flag(from: country.code)
        cell.configure(with: country, flag: flagEmoji)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedCountry = countries[indexPath.row]
        updateCountryButton()
        closePicker()
    }
    
    // MARK: OTP
    
    @objc func sendOTP() {
        
        guard
            let number = phoneTextField.text,
            !number.isEmpty,
            let country = selectedCountry
        else { return }
        
        let fullNumber = country.dialCode + number
        
        PhoneAuthProvider.provider().verifyPhoneNumber(fullNumber, uiDelegate: nil) { verificationID, error in
            
            if let error = error {
                print("Error:", error.localizedDescription)
                return
            }
            
            self.verificationID = verificationID
            print("OTP Sent to:", fullNumber)
        }
    }
}
