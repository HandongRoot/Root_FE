import UIKit

import Foundation
// 환경 변수 가져오는 함수 추가
func getEnvVariable(key: String) -> String? {
    return ProcessInfo.processInfo.environment[key]
}

class CustomModalViewController: UIViewController {
    
    var sharedURL: String?
    var folders: [(id: Int, name: String)] = [] // 폴더 목록 (category ID 포함)
    var collectionView: UICollectionView! // UICollectionView 추가

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor(white: 0, alpha: 0.5) // 반투명 배경
        
        setupModalView()
        setupCollectionView()
        fetchFolders() // 백엔드에서 폴더 목록 가져오기
    }

    func setupModalView() {
        let modalView = UIView()
        modalView.backgroundColor = .white
        modalView.layer.cornerRadius = 12
        modalView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(modalView)

        let titleLabel = UILabel()
        titleLabel.text = "저장할 위치 선택하기"
        titleLabel.font = UIFont.boldSystemFont(ofSize: 18)
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        modalView.addSubview(titleLabel)

        let saveAllButton = UIButton(type: .system)
        saveAllButton.setTitle("전체 리스트에 저장", for: .normal)
        saveAllButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        saveAllButton.backgroundColor = UIColor.systemBlue
        saveAllButton.layer.cornerRadius = 10
        saveAllButton.setTitleColor(.white, for: .normal)
        saveAllButton.addTarget(self, action: #selector(handleSaveAll), for: .touchUpInside)
        saveAllButton.translatesAutoresizingMaskIntoConstraints = false
        modalView.addSubview(saveAllButton)

        // 레이아웃 설정
        NSLayoutConstraint.activate([
            modalView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            modalView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            modalView.widthAnchor.constraint(equalToConstant: 350),
            modalView.heightAnchor.constraint(equalToConstant: 300),

            titleLabel.topAnchor.constraint(equalTo: modalView.topAnchor, constant: 15),
            titleLabel.centerXAnchor.constraint(equalTo: modalView.centerXAnchor),

            saveAllButton.bottomAnchor.constraint(equalTo: modalView.bottomAnchor, constant: -15),
            saveAllButton.centerXAnchor.constraint(equalTo: modalView.centerXAnchor),
            saveAllButton.widthAnchor.constraint(equalTo: modalView.widthAnchor, multiplier: 0.8),
            saveAllButton.heightAnchor.constraint(equalToConstant: 40)
        ])
    }

    @objc func handleSaveAll() {
        sendContentToBackend(category: nil, title: "테스트 제목", thumbnail: "https://example.com/thumb.jpg", linkedUrl: sharedURL ?? "")
    }

    func setupCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 80, height: 100) // 각 폴더 셀 크기

        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(FolderCell.self, forCellWithReuseIdentifier: "FolderCell")
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .clear
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(collectionView)

        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.topAnchor, constant: 150),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 15),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -15),
            collectionView.heightAnchor.constraint(equalToConstant: 100)
        ])
    }

    func fetchFolders() {
        guard let baseUrl = getEnvVariable(key: "BASE_URL"),
              let userId = getEnvVariable(key: "USER_ID") else {
            print("⚠️ BASE_URL 또는 USER_ID를 찾을 수 없습니다.")
            return
        }

        let urlString = "\(baseUrl)/api/v1/category/findAll/\(userId)"
        guard let url = URL(string: urlString) else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ 네트워크 오류: \(error.localizedDescription)")
                return
            }

            guard let data = data else { return }

            do {
                let jsonResponse = try JSONSerialization.jsonObject(with: data, options: [])
                if let jsonArray = jsonResponse as? [[String: Any]] {
                    self.folders = jsonArray.compactMap { dict in
                        guard let id = dict["id"] as? Int, let name = dict["name"] as? String else { return nil }
                        return (id, name)
                    }
                    DispatchQueue.main.async {
                        self.collectionView.reloadData()
                    }
                }
            } catch {
                print("❌ JSON 파싱 오류: \(error.localizedDescription)")
            }
        }
        task.resume()
    }

    func sendContentToBackend(category: Int?, title: String, thumbnail: String, linkedUrl: String) {
        guard let baseUrl = getEnvVariable(key: "BASE_URL"),
              let userId = getEnvVariable(key: "USER_ID") else {
            print("⚠️ BASE_URL 또는 USER_ID를 찾을 수 없습니다.")
            return
        }

        var urlString = "\(baseUrl)/api/v1/content/\(userId)"
        if let categoryId = category {
            urlString += "?category=\(categoryId)"
        }

        guard let url = URL(string: urlString) else {
            print("❌ URL 생성 실패")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let requestBody: [String: Any] = [
            "title": title,
            "thumbnail": thumbnail,
            "linkedUrl": linkedUrl
        ]

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: requestBody, options: [])
        } catch {
            print("❌ JSON 직렬화 오류: \(error.localizedDescription)")
            return
        }

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ 네트워크 오류: \(error.localizedDescription)")
                return
            }

            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                print("❌ 서버 오류")
                return
            }

            print("✅ 콘텐츠 저장 성공")
        }
        task.resume()
    }
}

extension CustomModalViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return folders.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FolderCell", for: indexPath) as! FolderCell
        cell.configure(folderName: folders[indexPath.row].name)
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedCategory = folders[indexPath.row].id
        sendContentToBackend(category: selectedCategory, title: "테스트 제목", thumbnail: "https://example.com/thumb.jpg", linkedUrl: sharedURL ?? "")
    }
}
