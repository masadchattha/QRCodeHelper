//
//  ViewController.swift
//  QRCodeHelper
//
//  Created by Muhammad Asad Chattha on 09/12/2023.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }


}

<<<<<<< Updated upstream
=======
// MARK: - Actions
extension ViewController {
    @IBAction func onGenerateQR(_ sender: UIButton) {
        alertController = UIAlertController( title: "Enter Text", message: "Please enter some text to save in QR Code", preferredStyle: .alert)
        alertController.addTextField(text: nil, placeholder: "Type here", editingChangedTarget: nil, editingChangedSelector: nil)
        alertController.addAction(title: "Generate", handler: handleAlertButtonAction)
        present(alertController, animated: true, completion: nil)
    }

    func handleAlertButtonAction(_ action: UIAlertAction) {
        guard let text = alertController.textFields?.first?.text else { return }
        guard let qrCode = generateQRCode(for: text) else { fatalError() }
        qrImageView.image = qrCode
    }
    
    @IBAction func onScanQR(_ sender: UIButton) {
        let vc = QRScannerVC.instantiate()
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
    }
}

// MARK: - Selectors
extension ViewController {
}


// MARK: - Helpers
extension ViewController {

    func generateQRCode(for text: String) -> UIImage? {
        guard let data = text.data(using: .ascii) else { return nil }
        // Core Image Filter Reference: https://developer.apple.com/library/archive/documentation/GraphicsImaging/Reference/CoreImageFilterReference/index.html
        guard let qrCIFilter = CIFilter(name: "CIQRCodeGenerator") else { return nil }
        qrCIFilter.setValue(data, forKey: "inputMessage")
        guard let qrCoreImage = qrCIFilter.outputImage else { return nil }
        let transformScale = CGAffineTransform(scaleX: 8.0, y: 8.0)
        let scaledQRCoreImage = qrCoreImage.transformed(by: transformScale)
        return UIImage(ciImage: scaledQRCoreImage)
    }
}



>>>>>>> Stashed changes
