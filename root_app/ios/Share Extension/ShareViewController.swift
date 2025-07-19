import UIKit
import MobileCoreServices
import UniformTypeIdentifiers

struct ContentItem: Decodable {
    let thumbnail: String?
}

struct Folder: Decodable {
    let id: Int
    let title: String
    let contentReadDtos: [ContentItem]
}

class ShareViewController: UIViewController, NewFolderDelegate {

    // UI
    let containerView = UIView()
    let scrollView = UIScrollView()
    let folderStackView = UIStackView()
    let separatorLine = UIView()
    let headerStackView = UIStackView()

    let saveContainerView = UIView()

    // 공유 데이터
    var sharedTitle: String = ""
    var sharedThumbnail: String = ""
    var sharedUrl: String = ""
    var isSaving: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        // view.backgroundColor = .clear
        // view.backgroundColor = UIColor.black.withAlphaComponent(0.3)

        let token = TokenManager.shared.getAccessToken()
        // print("📦 Share Extension에서 읽은 토큰: \(token ?? "없음")")

        extractSharedURL()

        setupModalContainer()
        setupHeader()
        setupFolderScroll()
        setupSeparatorLine()
        setupSaveSection()
        fetchFolders()
    }

    // MARK: - 공유 URL 추출
    func extractSharedURL() {
        guard let extensionItem = extensionContext?.inputItems.first as? NSExtensionItem,
            let attachments = extensionItem.attachments else {
            // print("❌ 공유 항목 없음")
            return
        }
        let token = TokenManager.shared.getAccessToken()
        // print("📦 Share Extension에서 읽은 토큰: \(token ?? "없음")")

        for itemProvider in attachments {
            // ✅ kUTTypeURL 우선 시도
            if itemProvider.hasItemConformingToTypeIdentifier(kUTTypeURL as String) {
                itemProvider.loadItem(forTypeIdentifier: kUTTypeURL as String, options: nil) { (data, error) in
                    if let url = data as? URL {
                        DispatchQueue.main.async {
                            self.sharedUrl = url.absoluteString
                            // print("📦 공유된 URL: \(self.sharedUrl)")
                            self.extractMetadata(from: self.sharedUrl)
                        }
                    }
                }
                return
            }

            // ✅ kUTTypeText fallback 처리
            if itemProvider.hasItemConformingToTypeIdentifier(kUTTypeText as String) {
                itemProvider.loadItem(forTypeIdentifier: kUTTypeText as String, options: nil) { (data, error) in
                    if let text = data as? String, let url = URL(string: text) {
                        DispatchQueue.main.async {
                            self.sharedUrl = url.absoluteString
                            // print("📦 공유된 텍스트 URL: \(self.sharedUrl)")
                            self.extractMetadata(from: self.sharedUrl)
                        }
                    }
                }
                return
            }
        }
    }

    // MARK: - 메타데이터 추출
    func extractMetadata(from urlString: String) {
        if let videoId = extractYouTubeId(from: urlString) {
            fetchYouTubeMetadata(videoId: videoId)
        } else {
            fetchWebpageMetadata(from: urlString)
        }
    }

    func extractYouTubeId(from url: String) -> String? {
        let patterns = [
            "youtube\\.com/shorts/([0-9A-Za-z_-]{11})",
            "youtu\\.be/([0-9A-Za-z_-]{11})",
            "youtube\\.com/watch\\?v=([0-9A-Za-z_-]{11})"
        ]
        for pattern in patterns {
            if let regex = try? NSRegularExpression(pattern: pattern),
                let match = regex.firstMatch(in: url, range: NSRange(url.startIndex..., in: url)),
                let range = Range(match.range(at: 1), in: url) {
                return String(url[range])
            }
        }
        return nil
    }

    func fetchYouTubeMetadata(videoId: String) {
        let apiKey = Config.youtubeApiKey
        guard let url = URL(string: "https://www.googleapis.com/youtube/v3/videos?id=\(videoId)&key=\(apiKey)&part=snippet") else { return }

        URLSession.shared.dataTask(with: url) { data, _, _ in
            guard let data = data,
                let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                let items = json["items"] as? [[String: Any]],
                let snippet = items.first?["snippet"] as? [String: Any] else { return }

            let title = snippet["title"] as? String ?? "제목 없음"
            var thumbnail = ""

            if let thumbnails = snippet["thumbnails"] as? [String: Any],
            let high = thumbnails["high"] as? [String: Any],
            let thumbUrl = high["url"] as? String {
                thumbnail = thumbUrl
            }

            DispatchQueue.main.async {
                self.sharedTitle = title
                self.sharedThumbnail = thumbnail
                // print("🎥 유튜브 제목: \(title)")
                // print("🖼 유튜브 썸네일: \(thumbnail)")
            }
        }.resume()
    }

    func fetchWebpageMetadata(from urlString: String) {
        let encodedUrl = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        guard let url = URL(string: "\(Config.baseUrl)/api/v1/content/metadata?url=\(encodedUrl)") else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ 서버 요청 에러 발생: \(error.localizedDescription)")
                return
            }

            if let httpResponse = response as? HTTPURLResponse {
                print("📡 응답 상태 코드: \(httpResponse.statusCode)")
            }

            guard let data = data else {
                print("❌ 응답 데이터 없음")
                return
            }

            if let raw = String(data: data, encoding: .utf8) {
                print("📩 서버 응답 원문:\n\(raw)")
            }

            do {
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                    let title = json["title"] as? String ?? "제목 없음"
                    let thumbnail = json["thumbnail"] as? String ?? ""

                    DispatchQueue.main.async {
                        self.sharedTitle = title
                        self.sharedThumbnail = thumbnail
                        self.sharedUrl = json["linkedUrl"] as? String ?? urlString
                        print("✅ 메타데이터 저장 완료: \(title), \(thumbnail)")
                    }
                }
            } catch {
                print("❌ JSON 파싱 오류: \(error)")
            }
        }.resume()
    }

    // func fetchWebpageMetadata(from urlString: String) {
    //     guard let url = URL(string: urlString) else { return }
    //     var request = URLRequest(url: url)
    //     request.setValue("Mozilla/5.0", forHTTPHeaderField: "User-Agent")

    //     URLSession.shared.dataTask(with: request) { data, _, _ in
    //         guard let data = data, let html = String(data: data, encoding: .utf8) else { return }

    //         let title = self.extractMetaTag(from: html, property: "og:title") ?? self.extractTitleTag(from: html) ?? "제목 없음"
    //         var thumbnail = self.extractMetaTag(from: html, property: "og:image") ?? ""

    //         if !thumbnail.starts(with: "http"),
    //             let base = url.scheme.flatMap({ "\($0)://\(url.host ?? "")" }) {
    //             thumbnail = base + thumbnail
    //         }

    //         DispatchQueue.main.async {
    //             self.sharedTitle = title
    //             self.sharedThumbnail = thumbnail
    //             // print("🌐 웹 제목: \(title)")
    //             // print("🖼 웹 썸네일: \(thumbnail)")
    //         }
    //     }.resume()
    // }

    func extractMetaTag(from html: String, property: String) -> String? {
        let pattern = "<meta[^>]+property=[\"']\(property)[\"'][^>]+content=[\"']([^\"']+)[\"']"
        if let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive),
            let match = regex.firstMatch(in: html, range: NSRange(html.startIndex..., in: html)),
            let range = Range(match.range(at: 1), in: html) {
            return String(html[range])
        }
        return nil
    }

    func extractTitleTag(from html: String) -> String? {
        let pattern = "<title>(.*?)</title>"
        if let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive),
            let match = regex.firstMatch(in: html, range: NSRange(html.startIndex..., in: html)),
            let range = Range(match.range(at: 1), in: html) {
            return String(html[range])
        }
        return nil
    }

    @objc func openNewFolderModal() {
        let newFolderVC = NewFolderViewController()
        newFolderVC.modalPresentationStyle = .overFullScreen  // ✅ 핵심
        newFolderVC.delegate = self
        present(newFolderVC, animated: true)
    }

    // MARK: - NewFolderDelegate
    func didCreateFolder(id categoryId: Int) {
        // print("✅ 새 폴더 생성됨, ID: \(categoryId)")
        Task {
            await saveContentToCategoryAsync(categoryId: categoryId)
        }
    }

    func setupModalContainer() {
        containerView.backgroundColor = .white
        containerView.layer.cornerRadius = 15
        containerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(containerView)

        NSLayoutConstraint.activate([
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    func setupHeader() {
        headerStackView.axis = .horizontal
        headerStackView.distribution = .equalSpacing
        headerStackView.alignment = .center
        headerStackView.translatesAutoresizingMaskIntoConstraints = false

        let closeButton = UIButton(type: .system)
        closeButton.setImage(UIImage(named: "my_x", in: Bundle.main, compatibleWith: nil), for: .normal)
        closeButton.tintColor = .gray
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        closeButton.addTarget(self, action: #selector(closeModal), for: .touchUpInside)
        closeButton.widthAnchor.constraint(equalToConstant: 30).isActive = true
        closeButton.heightAnchor.constraint(equalToConstant: 30).isActive = true

        let titleLabel = UILabel()
        titleLabel.text = "저장할 위치 선택하기"
        titleLabel.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        titleLabel.textColor = .black

        let addButton = UIButton(type: .system)
        addButton.setTitle("추가", for: .normal)
        addButton.setTitleColor(UIColor.gray, for: .normal)
        addButton.titleLabel?.font = UIFont.systemFont(ofSize: 13, weight: .medium)
        addButton.addTarget(self, action: #selector(openNewFolderModal), for: .touchUpInside)

        headerStackView.addArrangedSubview(closeButton)
        headerStackView.addArrangedSubview(titleLabel)
        headerStackView.addArrangedSubview(addButton)

        containerView.addSubview(headerStackView)

        NSLayoutConstraint.activate([
            headerStackView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 20),
            headerStackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            headerStackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20)
        ])
    }

    @objc func closeModal() {
        if let context = self.extensionContext {
            context.completeRequest(returningItems: nil, completionHandler: nil)
        } else {
            dismiss(animated: true, completion: nil)
        }
    }

    func waitForMetadataThenCreate(folderName: String) {
        let maxWaitTime: TimeInterval = 3.0
        let interval: TimeInterval = 0.1
        var waited: TimeInterval = 0

        Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { timer in
            if !self.sharedTitle.isEmpty && !self.sharedThumbnail.isEmpty && !self.sharedUrl.isEmpty {
                timer.invalidate()
            } else {
                waited += interval
                if waited >= maxWaitTime {
                    timer.invalidate()
                    // print("⚠️ 메타데이터가 시간 내에 준비되지 않음. 기본값으로 진행.")
                }
            }
        }
    }

    func saveContentToCategoryAsync(categoryId: Int?) async {
        let baseUrl = Config.baseUrl

        var urlString = "\(baseUrl)/api/v1/content"
        if let categoryId = categoryId {
            urlString += "?category=\(categoryId)"
        }

        guard let url = URL(string: urlString) else {
            // print("❌ 잘못된 URL: \(urlString)")
            return
        }

        guard let accessToken = TokenManager.shared.getAccessToken() else {
            // print("❌ accessToken 없음 (콘텐츠 저장)")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")

        let body: [String: Any] = [
            "title": sharedTitle,
            "thumbnail": sharedThumbnail,
            "linkedUrl": sharedUrl
        ]
        let jsonData = try? JSONSerialization.data(withJSONObject: body)
        request.httpBody = jsonData

        // print("📤 콘텐츠 저장 URL: \(urlString)")
        // print("🔑 콘텐츠 저장 accessToken: \(accessToken)")
        // print("📦 저장할 JSON: \(String(data: jsonData ?? Data(), encoding: .utf8) ?? "없음")")

        do {
            let (data, response) = try await URLSession.shared.data(for: request)

            if let httpResponse = response as? HTTPURLResponse {
                // print("📬 콘텐츠 저장 응답 코드: \(httpResponse.statusCode)")
            }

            if let body = String(data: data, encoding: .utf8) {
                // print("📥 콘텐츠 저장 응답 본문: \(body)")
            }

            DispatchQueue.main.async {
                self.showToast(duration: 0.4) {
                    if let context = self.extensionContext {
                        context.completeRequest(returningItems: nil, completionHandler: nil)
                    } else {
                        self.dismiss(animated: true)
                    }
                }
            }
        } catch {
            // print("❌ 콘텐츠 저장 실패: \(error.localizedDescription)")
        }
    }

    func showToast(duration: TimeInterval = 0.4, completion: (() -> Void)? = nil) {
        let toastView = UIView()
        toastView.backgroundColor = UIColor(named: "Contents_Small") ?? UIColor(red: 57/255, green: 57/255, blue: 57/255, alpha: 1) // #393939
        toastView.layer.cornerRadius = 25
        toastView.alpha = 0.0
        toastView.translatesAutoresizingMaskIntoConstraints = false

        // 아이콘
        let iconImageView = UIImageView(image: UIImage(named: "toasticon"))
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.widthAnchor.constraint(equalToConstant: 16).isActive = true
        iconImageView.heightAnchor.constraint(equalToConstant: 16).isActive = true

        // 텍스트
        let messageLabel = UILabel()
        messageLabel.text = "콘텐츠가 저장되었습니다."
        messageLabel.textColor = UIColor(named: "Light-Gray") ?? UIColor(red: 252/255, green: 252/255, blue: 252/255, alpha: 1)
        messageLabel.textAlignment = .center
        messageLabel.font = UIFont(name: "Pretendard-Medium", size: 14) ?? UIFont.systemFont(ofSize: 14, weight: .medium)
        messageLabel.numberOfLines = 0
        messageLabel.translatesAutoresizingMaskIntoConstraints = false

        // StackView로 정렬
        let hStack = UIStackView(arrangedSubviews: [iconImageView, messageLabel])
        hStack.axis = .horizontal
        hStack.spacing = 10
        hStack.alignment = .center
        hStack.translatesAutoresizingMaskIntoConstraints = false

        toastView.addSubview(hStack)
        view.addSubview(toastView)

        NSLayoutConstraint.activate([
            hStack.topAnchor.constraint(equalTo: toastView.topAnchor, constant: 15),
            hStack.bottomAnchor.constraint(equalTo: toastView.bottomAnchor, constant: -15),
            hStack.leadingAnchor.constraint(equalTo: toastView.leadingAnchor, constant: 19),
            hStack.trailingAnchor.constraint(equalTo: toastView.trailingAnchor, constant: -19),

            toastView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            toastView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -40),
            toastView.widthAnchor.constraint(lessThanOrEqualToConstant: 320)
        ])

        UIView.animate(withDuration: 0.3, animations: {
            toastView.alpha = 1.0
        }) { _ in
            UIView.animate(withDuration: 0.3, delay: duration, options: .curveEaseOut, animations: {
                toastView.alpha = 0.0
            }) { _ in
                toastView.removeFromSuperview()
                completion?() // ✅ 토스트 사라진 뒤 콜백 실행
            }
        }
    }

    func setupFolderScroll() {
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false

        folderStackView.axis = .horizontal
        folderStackView.spacing = 21
        folderStackView.alignment = .center
        folderStackView.translatesAutoresizingMaskIntoConstraints = false

        scrollView.addSubview(folderStackView)
        containerView.addSubview(scrollView)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: headerStackView.bottomAnchor, constant: 35),
            scrollView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            scrollView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            scrollView.heightAnchor.constraint(equalToConstant: 80),

            folderStackView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            folderStackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            folderStackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            folderStackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            folderStackView.heightAnchor.constraint(equalTo: scrollView.heightAnchor)
        ])
    }

    func setupSeparatorLine() {
        separatorLine.translatesAutoresizingMaskIntoConstraints = false
        separatorLine.backgroundColor = UIColor.lightGray.withAlphaComponent(0.5)
        containerView.addSubview(separatorLine)

        NSLayoutConstraint.activate([
            separatorLine.topAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: 25),
            separatorLine.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 2),
            separatorLine.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -2),
            separatorLine.heightAnchor.constraint(equalToConstant: 0.7)
        ])
    }

    func setupSaveSection() {
        // let saveContainerView = UIView()
        saveContainerView.translatesAutoresizingMaskIntoConstraints = false
        saveContainerView.layer.cornerRadius = 10
        saveContainerView.clipsToBounds = true

        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [
            UIColor(red: 0.13, green: 0.45, blue: 0.96, alpha: 1).cgColor,
            UIColor(red: 0.20, green: 0.82, blue: 0.98, alpha: 1).cgColor
        ]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
        gradientLayer.cornerRadius = 10

        let saveLabel = UILabel()
        saveLabel.text = "전체 리스트에 저장"
        saveLabel.textColor = .white
        saveLabel.font = UIFont.boldSystemFont(ofSize: 14)
        saveLabel.translatesAutoresizingMaskIntoConstraints = false

        let saveImageView = UIImageView(image: UIImage(named: "grid", in: Bundle.main, compatibleWith: nil))
        saveImageView.translatesAutoresizingMaskIntoConstraints = false
        saveImageView.contentMode = .scaleAspectFit

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(saveToAllList))
        saveContainerView.addGestureRecognizer(tapGesture)

        saveContainerView.addSubview(saveLabel)
        saveContainerView.addSubview(saveImageView)
        containerView.addSubview(saveContainerView)

        containerView.layoutIfNeeded()
        gradientLayer.frame = CGRect(x: 0, y: 0, width: view.bounds.width - 40, height: 50)
        saveContainerView.layer.insertSublayer(gradientLayer, at: 0)

        NSLayoutConstraint.activate([
            saveContainerView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            saveContainerView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            saveContainerView.topAnchor.constraint(equalTo: separatorLine.bottomAnchor, constant: 20),
            saveContainerView.heightAnchor.constraint(equalToConstant: 50),
            saveContainerView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -40),

            saveLabel.leadingAnchor.constraint(equalTo: saveContainerView.leadingAnchor, constant: 20),
            saveLabel.centerYAnchor.constraint(equalTo: saveContainerView.centerYAnchor),

            saveImageView.trailingAnchor.constraint(equalTo: saveContainerView.trailingAnchor, constant: -20),
            saveImageView.centerYAnchor.constraint(equalTo: saveContainerView.centerYAnchor),
            saveImageView.widthAnchor.constraint(equalToConstant: 20),
            saveImageView.heightAnchor.constraint(equalToConstant: 20)
        ])
    }

    @objc func saveToAllList() {
        // ✅ 중복 방지: 제스처 제거
        guard let gestures = saveContainerView.gestureRecognizers else { return }
        for gesture in gestures {
            saveContainerView.removeGestureRecognizer(gesture)
        }

        // ✅ 저장 시작
        Task {
            await saveContentToCategoryAsync(categoryId: nil)
        }
    }

    func fetchFolders() {
        let urlString = "\(Config.baseUrl)/api/v1/category/findAll"

        guard let url = URL(string: urlString) else {
            // print("❌ 잘못된 URL: \(urlString)")
            return
        }

        guard let accessToken = TokenManager.shared.getAccessToken() else {
            // print("❌ accessToken 없음 (폴더 요청)")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")

        // print("📡 폴더 목록 요청 URL: \(urlString)")
        // print("🔑 폴더 요청 accessToken: \(accessToken)")

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                // print("❌ 네트워크 오류: \(error)")
                return
            }

            if let httpResponse = response as? HTTPURLResponse {
                // print("📬 폴더 응답 상태 코드: \(httpResponse.statusCode)")
            }

            guard let data = data else {
                // print("❌ 폴더 응답 데이터 없음")
                return
            }

            if let responseBody = String(data: data, encoding: .utf8) {
                // print("📥 폴더 응답 JSON:\n\(responseBody)")
            }

            do {
                let folders = try JSONDecoder().decode([Folder].self, from: data)
                DispatchQueue.main.async {
                    self.updateFolderUI(with: folders)
                }
            } catch {
                // print("❌ 폴더 디코딩 실패:", error)
            }
        }.resume()
    }

    func updateFolderUI(with folders: [Folder]) {
        folderStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }

        if folders.isEmpty {
            // 👉 이미지
            let placeholderImageView = UIImageView(image: UIImage(named: "shared_empty"))
            placeholderImageView.contentMode = .scaleAspectFit
            placeholderImageView.translatesAutoresizingMaskIntoConstraints = false
            placeholderImageView.widthAnchor.constraint(equalToConstant: 50).isActive = true
            placeholderImageView.heightAnchor.constraint(equalToConstant: 52.6).isActive = true

            // 👉 텍스트 스타일 적용
            let messageLabel = UILabel()
            messageLabel.text = "아직 생성된 폴더가 없어요"
            messageLabel.textColor = UIColor(red: 0xBA/255, green: 0xBC/255, blue: 0xC0/255, alpha: 1) // #BABCC0
            messageLabel.textAlignment = .center
            messageLabel.font = UIFont(name: "Pretendard-Medium", size: 13) ?? UIFont.systemFont(ofSize: 13, weight: .medium)
            messageLabel.numberOfLines = 0

            // 👉 줄 간격 조절 (line-height: 22px)
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.lineSpacing = 22 - messageLabel.font.lineHeight // 조정값
            paragraphStyle.alignment = .center

            let attributedString = NSAttributedString(
                string: messageLabel.text ?? "",
                attributes: [
                    .font: messageLabel.font!,
                    .foregroundColor: messageLabel.textColor!,
                    .paragraphStyle: paragraphStyle
                ]
            )
            messageLabel.attributedText = attributedString

            // 👉 VStack 정렬
            let vStack = UIStackView(arrangedSubviews: [placeholderImageView, messageLabel])
            vStack.axis = .vertical
            vStack.alignment = .center
            vStack.spacing = 7
            vStack.translatesAutoresizingMaskIntoConstraints = false

            let container = UIView()
            container.translatesAutoresizingMaskIntoConstraints = false
            container.addSubview(vStack)
            folderStackView.addArrangedSubview(container)

            NSLayoutConstraint.activate([
                vStack.centerXAnchor.constraint(equalTo: container.centerXAnchor),
                vStack.centerYAnchor.constraint(equalTo: container.centerYAnchor),
                container.heightAnchor.constraint(equalTo: scrollView.heightAnchor),
                container.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
            ])
            return
        }

        for folder in folders {
            let thumbnail = folder.contentReadDtos.first?.thumbnail
            let folderView = createFolderView(
                name: folder.title,
                thumbnailUrl: thumbnail,
                categoryId: folder.id // ✅ categoryId 넘겨주기
            )
            folderStackView.addArrangedSubview(folderView)
        }
    }

    @objc func handleFolderTap(_ sender: UITapGestureRecognizer) {
        guard let tappedView = sender.view else { return }
        let categoryId = tappedView.tag
        // print("📂 선택된 폴더 ID: \(categoryId)")

        Task {
            await saveContentToCategoryAsync(categoryId: categoryId)
        }
    }

    func createFolderView(name: String, thumbnailUrl: String?, categoryId: Int) -> UIView {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 8
        stack.translatesAutoresizingMaskIntoConstraints = false

        let overlayContainer = UIView()
        overlayContainer.translatesAutoresizingMaskIntoConstraints = false
        overlayContainer.widthAnchor.constraint(equalToConstant: 55).isActive = true
        overlayContainer.heightAnchor.constraint(equalToConstant: 55).isActive = true

        let folderImageView = UIImageView(image: UIImage(named: "ShareFolder"))
        folderImageView.translatesAutoresizingMaskIntoConstraints = false
        folderImageView.contentMode = .scaleAspectFit
        folderImageView.frame = CGRect(x: 0, y: 0, width: 55, height: 55)
        overlayContainer.addSubview(folderImageView)

        let thumbImageView = UIImageView()
        thumbImageView.translatesAutoresizingMaskIntoConstraints = false
        thumbImageView.contentMode = .scaleAspectFill
        thumbImageView.clipsToBounds = true
        thumbImageView.layer.cornerRadius = 5
        overlayContainer.addSubview(thumbImageView)

        if let urlStr = thumbnailUrl, let url = URL(string: urlStr) {
            loadImage(from: url) { image in
                thumbImageView.image = image
            }
        }

        NSLayoutConstraint.activate([
            folderImageView.topAnchor.constraint(equalTo: overlayContainer.topAnchor),
            folderImageView.bottomAnchor.constraint(equalTo: overlayContainer.bottomAnchor),
            folderImageView.leadingAnchor.constraint(equalTo: overlayContainer.leadingAnchor),
            folderImageView.trailingAnchor.constraint(equalTo: overlayContainer.trailingAnchor),

            thumbImageView.widthAnchor.constraint(equalToConstant: 41),
            thumbImageView.heightAnchor.constraint(equalToConstant: 41),
            thumbImageView.centerXAnchor.constraint(equalTo: overlayContainer.centerXAnchor),
            thumbImageView.bottomAnchor.constraint(equalTo: overlayContainer.bottomAnchor, constant: -6)
        ])

        // 💡 여기에 탭 제스처 추가
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleFolderTap(_:)))
        overlayContainer.isUserInteractionEnabled = true
        overlayContainer.addGestureRecognizer(tapGesture)
        overlayContainer.tag = categoryId  // 👉 폴더 ID를 tag에 저장
      
        let folderNameLabel = UILabel()

        let maxCharCount = 7
        let displayName: String
        if name.count > maxCharCount {
            let index = name.index(name.startIndex, offsetBy: maxCharCount)
            displayName = String(name[..<index]) + "…"
        } else {
            displayName = name
        }
        folderNameLabel.text = displayName

        folderNameLabel.text = displayName
        folderNameLabel.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        folderNameLabel.textColor = UIColor.black
        folderNameLabel.textAlignment = NSTextAlignment.center
        folderNameLabel.lineBreakMode = NSLineBreakMode.byTruncatingTail
        folderNameLabel.numberOfLines = 1
        folderNameLabel.translatesAutoresizingMaskIntoConstraints = false
        folderNameLabel.widthAnchor.constraint(equalToConstant: 60).isActive = true

        stack.addArrangedSubview(overlayContainer)
        stack.addArrangedSubview(folderNameLabel)

        return stack
    }

    func loadImage(from url: URL, completion: @escaping (UIImage?) -> Void) {
        URLSession.shared.dataTask(with: url) { data, _, _ in
            if let data = data {
                let image = UIImage(data: data)
                DispatchQueue.main.async {
                    completion(image)
                }
            } else {
                DispatchQueue.main.async {
                    completion(nil)
                }
            }
        }.resume()
    }
}