import UIKit

class FolderCell: UICollectionViewCell {
    let folderLabel = UILabel()
    let folderImageView = UIImageView()

    override init(frame: CGRect) {
        super.init(frame: frame)

        // iOS 13 이상이면 systemName 사용, 아니면 기본 이미지 설정
        if #available(iOS 13.0, *) {
            folderImageView.image = UIImage(systemName: "folder.fill")
        } else {
            folderImageView.image = UIImage(named: "defaultFolderIcon") // 프로젝트에 기본 이미지 추가 필요
        }
        
        folderImageView.tintColor = .systemBlue
        folderImageView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(folderImageView)

        folderLabel.textAlignment = .center
        folderLabel.font = UIFont.systemFont(ofSize: 12)
        folderLabel.numberOfLines = 2
        folderLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(folderLabel)

        NSLayoutConstraint.activate([
            folderImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5),
            folderImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            folderImageView.widthAnchor.constraint(equalToConstant: 50),
            folderImageView.heightAnchor.constraint(equalToConstant: 50),

            folderLabel.topAnchor.constraint(equalTo: folderImageView.bottomAnchor, constant: 5),
            folderLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            folderLabel.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.9)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(folderName: String) {
        folderLabel.text = folderName
    }
}


// 폴더 구성 UI 띄울 부분