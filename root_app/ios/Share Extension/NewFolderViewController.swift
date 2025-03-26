import UIKit

protocol NewFolderDelegate: AnyObject {
    func didCreateFolder(id: Int)
}

class NewFolderViewController: UIViewController {

    weak var delegate: NewFolderDelegate?

    private let textField = UITextField()
    private let saveButton = UIButton(type: .system)
    private var dialogCenterYConstraint: NSLayoutConstraint?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        setupModalUI()

        // 키보드 이벤트 옵저버 등록
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    func setupModalUI() {
        let dialogView = UIView()
        dialogView.backgroundColor = UIColor(red: 0.949, green: 0.949, blue: 0.949, alpha: 1) // #F2F2F2
        dialogView.layer.cornerRadius = 14
        dialogView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(dialogView)

        NSLayoutConstraint.activate([
            dialogView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            dialogView.widthAnchor.constraint(equalToConstant: 270)
        ])
        dialogCenterYConstraint = dialogView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        dialogCenterYConstraint?.isActive = true

        // Title
        let titleLabel = UILabel()
        titleLabel.text = "새로운 폴더"
        titleLabel.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        titleLabel.textAlignment = .center
        titleLabel.textColor = .black

        let subtitleLabel = UILabel()
        subtitleLabel.text = "새로운 폴더의 제목을 입력해주세요."
        subtitleLabel.font = UIFont.systemFont(ofSize: 13)
        subtitleLabel.textAlignment = .center
        subtitleLabel.textColor = .black
        subtitleLabel.numberOfLines = 1

        textField.placeholder = "제목"
        textField.font = UIFont.systemFont(ofSize: 11)
        textField.backgroundColor = .white
        textField.layer.cornerRadius = 10
        textField.layer.borderWidth = 0.5
        textField.layer.borderColor = UIColor.lightGray.cgColor
        textField.setLeftPadding(8)
        textField.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            textField.heightAnchor.constraint(equalToConstant: 26),
            textField.widthAnchor.constraint(equalToConstant: 232)
        ])

        // Horizontal Divider
        let horizontalDivider = UIView()
        horizontalDivider.backgroundColor = UIColor.lightGray.withAlphaComponent(0.6)
        horizontalDivider.translatesAutoresizingMaskIntoConstraints = false
        dialogView.addSubview(horizontalDivider)

        // Cancel & Save buttons
        let cancelButton = UIButton(type: .system)
        cancelButton.setTitle("취소", for: .normal)
        cancelButton.setTitleColor(.systemBlue, for: .normal)
        cancelButton.titleLabel?.font = UIFont.systemFont(ofSize: 17)
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        cancelButton.addTarget(self, action: #selector(dismissModal), for: .touchUpInside)

        saveButton.setTitle("저장", for: .normal)
        saveButton.setTitleColor(UIColor(red: 0.91, green: 0.22, blue: 0.22, alpha: 1), for: .normal)
        saveButton.titleLabel?.font = UIFont.systemFont(ofSize: 17)
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        saveButton.addTarget(self, action: #selector(saveFolder), for: .touchUpInside)

        // Vertical Divider
        let verticalDivider = UIView()
        verticalDivider.backgroundColor = UIColor.lightGray.withAlphaComponent(0.6)
        verticalDivider.translatesAutoresizingMaskIntoConstraints = false

        // Button Container
        let buttonContainer = UIView()
        buttonContainer.translatesAutoresizingMaskIntoConstraints = false
        dialogView.addSubview(buttonContainer)

        let buttonStack = UIStackView(arrangedSubviews: [cancelButton, saveButton])
        buttonStack.axis = .horizontal
        buttonStack.distribution = .fillEqually
        buttonStack.translatesAutoresizingMaskIntoConstraints = false
        buttonContainer.addSubview(buttonStack)
        buttonContainer.addSubview(verticalDivider)

        NSLayoutConstraint.activate([
            buttonContainer.heightAnchor.constraint(equalToConstant: 44),
            verticalDivider.widthAnchor.constraint(equalToConstant: 0.5),
            verticalDivider.topAnchor.constraint(equalTo: buttonContainer.topAnchor),
            verticalDivider.bottomAnchor.constraint(equalTo: buttonContainer.bottomAnchor),
            verticalDivider.centerXAnchor.constraint(equalTo: buttonContainer.centerXAnchor),

            buttonStack.topAnchor.constraint(equalTo: buttonContainer.topAnchor),
            buttonStack.bottomAnchor.constraint(equalTo: buttonContainer.bottomAnchor),
            buttonStack.leadingAnchor.constraint(equalTo: buttonContainer.leadingAnchor),
            buttonStack.trailingAnchor.constraint(equalTo: buttonContainer.trailingAnchor)
        ])

        // Main Stack (title, subtitle, textField)
        let stack = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel, textField])
        stack.axis = .vertical
        stack.spacing = 8
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false

        dialogView.addSubview(stack)

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: dialogView.topAnchor, constant: 16),
            stack.leadingAnchor.constraint(equalTo: dialogView.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: dialogView.trailingAnchor),

            horizontalDivider.topAnchor.constraint(equalTo: stack.bottomAnchor, constant: 10),
            horizontalDivider.leadingAnchor.constraint(equalTo: dialogView.leadingAnchor),
            horizontalDivider.trailingAnchor.constraint(equalTo: dialogView.trailingAnchor),
            horizontalDivider.heightAnchor.constraint(equalToConstant: 0.5),

            buttonContainer.topAnchor.constraint(equalTo: horizontalDivider.bottomAnchor),
            buttonContainer.leadingAnchor.constraint(equalTo: dialogView.leadingAnchor),
            buttonContainer.trailingAnchor.constraint(equalTo: dialogView.trailingAnchor),
            buttonContainer.bottomAnchor.constraint(equalTo: dialogView.bottomAnchor)
        ])
    }

    // MARK: - Keyboard Events

    @objc func keyboardWillShow(_ notification: Notification) {
        guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }

        let keyboardHeight = keyboardFrame.height
        dialogCenterYConstraint?.constant = -keyboardHeight / 2 + 40

        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }

    @objc func keyboardWillHide(_ notification: Notification) {
        dialogCenterYConstraint?.constant = 0
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }

    @objc func dismissModal() {
        dismiss(animated: true)
    }

    @objc func saveFolder() {
        guard let name = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines), !name.isEmpty else { return }
        createFolder(named: name)
    }

    func createFolder(named name: String) {
        let userId = "8a975eeb-56d1-4832-9d2f-5da760247dda"
        let urlString = "\(Config.baseUrl)/api/v1/category"
        guard let url = URL(string: urlString) else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let body = ["userId": userId, "title": name]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        URLSession.shared.dataTask(with: request) { data, _, _ in
            guard let data = data,
                  let idString = String(data: data, encoding: .utf8),
                  let id = Int(idString.trimmingCharacters(in: .whitespacesAndNewlines)) else {
                print("❌ 폴더 생성 실패")
                return
            }

            DispatchQueue.main.async {
                self.delegate?.didCreateFolder(id: id)
                self.dismiss(animated: true)
            }
        }.resume()
    }
}

extension UITextField {
    func setLeftPadding(_ amount: CGFloat) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.height))
        self.leftView = paddingView
        self.leftViewMode = .always
    }
}
