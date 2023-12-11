//
//  QRScannerVC.swift
//  QRCodeHelper
//
//  Created by Muhammad Asad Chattha on 10/12/2023.
//

import UIKit
import AVFoundation

// MARK: - Typealias
typealias QRCodeScannedHandler = (String) -> Void

class QRScannerVC: UIViewController {

    // MARK: - Properties
    var qrCodeScannedHandler: QRCodeScannedHandler?
    private var captureSession: AVCaptureSession!
    private var previewLayer: AVCaptureVideoPreviewLayer!

    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        setupQRScanner()
    }

}

// MARK: - Instantiable
extension QRScannerVC: Instantiable {

    static var storyboard: UIStoryboard {
        UIStoryboard.main
    }
}

// MARK: - Actions
extension QRScannerVC {

    @IBAction func onClose(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
}

// MARK: - Scaning QR Code
extension QRScannerVC {

    private func setupQRScanner() {
        captureSession = AVCaptureSession()
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else { return }

        do {
            let videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
            if captureSession.canAddInput(videoInput) {
                captureSession.addInput(videoInput)
            } else { failed(); return }
        } catch {
            return
        }

        let metadataOutput = AVCaptureMetadataOutput()
        if captureSession.canAddOutput(metadataOutput) {
            captureSession.addOutput(metadataOutput)
            metadataOutput.setMetadataObjectsDelegate(self, queue: .main)
            metadataOutput.metadataObjectTypes = [.qr]
        } else {
            failed()
            return
        }

        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = view.layer.bounds
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)
        captureSession.startRunning()
    }
}

// MARK: - AVCaptureMetadataOutputObjectsDelegate
extension QRScannerVC: AVCaptureMetadataOutputObjectsDelegate {

    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        captureSession.stopRunning()

        guard let metadataObject = metadataObjects.first else { return }
        guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
        guard let stringValue = readableObject.stringValue else { return }
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
        showQRCodeScannedAlert(stringValue)
        dismiss(animated: true)
    }
}

// MARK: - Helper Methods
extension QRScannerVC {

    private func failed() {
        let alert = UIAlertController(title: "Scanning not supported", message: "Your device does not support scanning a code from an item. Please use a device with a camera.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
        captureSession = nil
    }

    private func showQRCodeScannedAlert(_ code: String) {
        let alert = UIAlertController(title: "QR Code Scanned", message: code, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            self.captureSession.startRunning()
        })
        present(alert, animated: true)
    }
}
