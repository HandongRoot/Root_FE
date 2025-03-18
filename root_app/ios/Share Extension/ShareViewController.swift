import receive_sharing_intent
import UIKit

class ShareViewController: RSIShareViewController {
    
    var sharedURL: String?

    override func shouldAutoRedirect() -> Bool {
        return false  // 자동 이동 X
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if presentedViewController == nil {
            showCustomModal()
        }
    }

    func showCustomModal() {
        let modalVC = CustomModalViewController()
        
        // URL을 공유했는지 확인 후 전달
        if let content = self.contentText {
            modalVC.sharedURL = content
        }
        
        modalVC.modalPresentationStyle = .overFullScreen
        present(modalVC, animated: true, completion: nil)
    }
}
