//
//  ViewController.swift
//  QRCodeHelper
//
//  Created by Muhammad Asad Chattha on 09/12/2023.
//

import UIKit
import SwifterSwift

class ViewController: UIViewController {

    // MARK: - Outlets
    @IBOutlet weak var qrImageView: UIImageView!

    // MARK: - Properties
    private var alertController: UIAlertController!

    // MARK: - Life Cycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
}

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
        PermissionManager.checkCameraPermission { result in
            switch result {
            case .success:
                let vc = QRScannerVC.instantiate()
                vc.modalPresentationStyle = .fullScreen
                self.present(vc, animated: true)
            case .failure:
                self.showCameraPermissionAlert()
            }
        }
    }
}

// MARK: - Selectors
extension ViewController {
}


// MARK: - Helpers
extension ViewController {

    func generateQRCode(for text: String) -> UIImage? {
        guard let data = text.data(using: .ascii), data.isNotEmpty else { return nil }
        // Core Image Filter Reference: https://developer.apple.com/library/archive/documentation/GraphicsImaging/Reference/CoreImageFilterReference/index.html
        guard let qrCIFilter = CIFilter(name: "CIQRCodeGenerator") else { return nil }
        qrCIFilter.setValue(data, forKey: "inputMessage")
        guard let qrCoreImage = qrCIFilter.outputImage else { return nil }
        let transformScale = CGAffineTransform(scaleX: 8.0, y: 8.0)
        let scaledQRCoreImage = qrCoreImage.transformed(by: transformScale)
        return UIImage(ciImage: scaledQRCoreImage)
    }
}

// MARK: - Scaning Halpers
extension ViewController {
    func showCameraPermissionAlert() {
        let alert = UIAlertController(
            title: "Camera Permission Required",
            message: "Please enable camera access in Settings to scan QR codes.",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Settings", style: .default) { _ in
            if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(settingsURL)
            }
        })
        
        present(alert, animated: true, completion: nil)
    }
}

