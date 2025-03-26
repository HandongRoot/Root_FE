import UIKit

protocol NewFolderDelegate: AnyObject {
    func didCreateFolder(id: Int)
}

class NewFolderViewController: UIViewController {

    weak var delegate: NewFolderDelegate?

    private let textField = UITextField()
    private let saveButton = UIButton(type: .system)

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        setupModalUI()
    }

    func setupModalUI() {
        let dialogView = UIView()
        dialogView.backgroundColor = UIColor(red: 0.949, green: 0.949, blue: 0.949, alpha: 1) // #F2F2F2
        dialogView.layer.cornerRadius = 14
        dialogView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(dialogView)

        NSLayoutConstraint.activate([
            dialogView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            dialogView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            dialogView.widthAnchor.constraint(equalToConstant: 270)
        ])

        // Title Label
        let titleLabel = UILabel()
        titleLabel.text = "새로운 폴더"
        titleLabel.textColor = .black
        titleLabel.font = UIFont(name: "Pretendard-SemiBold", size: 17) ?? UIFont.systemFont(ofSize: 17, weight: .semibold)
        titleLabel.textAlignment = .center

        // Subtitle Label
        let subtitleLabel = UILabel()
        subtitleLabel.text = "새 폴더 이름을 입력하고 콘텐츠를 저장할게요."
        subtitleLabel.textColor = .black
        subtitleLabel.font = UIFont(name: "Pretendard-Regular", size: 13) ?? UIFont.systemFont(ofSize: 13, weight: .regular)
        subtitleLabel.textAlignment = .center
        subtitleLabel.numberOfLines = 1

        // Text Field
        textField.placeholder = "제목"
        textField.font = UIFont(name: "Pretendard-Regular", size: 11) ?? UIFont.systemFont(ofSize: 11)
        textField.textColor = UIColor(red: 0.22, green: 0.22, blue: 0.22, alpha: 1) // #393939
        textField.backgroundColor = .white
        textField.layer.cornerRadius = 10
        textField.layer.borderWidth = 0.5
        textField.layer.borderColor = UIColor(red: 0.71, green: 0.71, blue: 0.71, alpha: 1).cgColor // #B4B4B4
        textField.setLeftPadding(8)
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.addTarget(self, action: #selector(textDidChange), for: .editingChanged)

        NSLayoutConstraint.activate([
            textField.widthAnchor.constraint(equalToConstant: 232),
            textField.heightAnchor.constraint(equalToConstant: 26)
        ])

        // Buttons
        let cancelButton = UIButton(type: .system)
        cancelButton.setTitle("취소", for: .normal)
        cancelButton.setTitleColor(UIColor(red: 0, green: 0.48, blue: 1.0, alpha: 1), for: .normal) // #007AFF
        cancelButton.titleLabel?.font = UIFont(name: "Pretendard-Regular", size: 17) ?? UIFont.systemFont(ofSize: 17)
        cancelButton.addTarget(self, action: #selector(dismissModal), for: .touchUpInside)
        cancelButton.heightAnchor.constraint(equalToConstant: 42.5).isActive = true

        saveButton.setTitle("저장", for: .normal)
        saveButton.setTitleColor(UIColor(red: 0.91, green: 0.22, blue: 0.22, alpha: 1), for: .normal) // #E93838
        saveButton.titleLabel?.font = UIFont(name: "Pretendard-Regular", size: 17) ?? UIFont.systemFont(ofSize: 17)
        saveButton.addTarget(self, action: #selector(saveFolder), for: .touchUpInside)
        saveButton.heightAnchor.constraint(equalToConstant: 42.5).isActive = true

        // buttond divider
        let buttonDivider = UIView()
        buttonDivider.backgroundColor = UIColor.lightGray.withAlphaComponent(0.6)
        buttonDivider.widthAnchor.constraint(equalToConstant: 0.5).isActive = true

        let buttonStack = UIStackView(arrangedSubviews: [cancelButton, buttonDivider, saveButton])
        buttonStack.axis = .horizontal
        buttonStack.distribution = .fillEqually
        buttonStack.translatesAutoresizingMaskIntoConstraints = false

        // Main Stack
        let stack = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel, textField, buttonStack])
        stack.axis = .vertical
        stack.spacing = 10
        stack.alignment = .fill
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.isLayoutMarginsRelativeArrangement = true
        stack.layoutMargins = UIEdgeInsets(top: 16, left: 16, bottom: 12, right: 16)
        stack.setCustomSpacing(4, after: subtitleLabel)
        stack.setCustomSpacing(8, after: textField)



        dialogView.addSubview(stack)

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: dialogView.topAnchor, constant: 16),
            stack.bottomAnchor.constraint(equalTo: dialogView.bottomAnchor, constant: -10),
            stack.leadingAnchor.constraint(equalTo: dialogView.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: dialogView.trailingAnchor)
        ])
    }

    @objc func textDidChange() {
        // 저장 버튼 활성화 여부 로직 (원하면 조건 추가 가능)
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
