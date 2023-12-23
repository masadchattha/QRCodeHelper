# Comprehensive Guide for Generating and Scanning QR Codes in Swift

![QR codes in Swift](https://github.com/masadchattha/QRCodeHelper/assets/38839059/f8e734d9-a71d-465b-bcdc-2d35d535fa31)

Let's demystify the world of QR codes and guide you through their implementation in Swift. I’ll take you on a journey through Swift, equipping you with the skills to effortlessly integrate QR code functionality into your app.

## Generating QR Codes in Swift
Generating a QR code in Swift involves utilizing the capabilities of the Core Image framework, specifically the `CIFilter` class named `CIQRCodeGenerator` All available CIFilters [Core Image Filter Reference](https://developer.apple.com/library/archive/documentation/GraphicsImaging/Reference/CoreImageFilterReference/index.html). Let's break down the code snippet to understand the key components.
Create an `action` of UIButton, `outlet` of ImageView in a ViewController. For alerts, I’m using a very helpful [`SwifterSwift`](https://github.com/SwifterSwift/SwifterSwift) library which includes 500+ useful swift extensions. Tapping generate QR button, an alert with a text field will be presented.

```swift
import SwifterSwift

// MARK: - Outlets
@IBOutlet weak var qrImageView: UIImageView!

// MARK: - Properties
private var alertController: UIAlertController!

// MARK: - Actions
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
```
Tapping to `Generate` alert action button will generate and set QR to UIImageView.

```swift
func generateQRCode(for text: String) -> UIImage? {
    guard let data = text.data(using: .ascii) else { return nil }
    guard let qrCIFilter = CIFilter(name: "CIQRCodeGenerator") else { return nil }
    qrCIFilter.setValue(data, forKey: "inputMessage")
    guard let qrCoreImage = qrCIFilter.outputImage else { return nil }
    let transformScale = CGAffineTransform(scaleX: 8.0, y: 8.0)
    let scaledQRCoreImage = qrCoreImage.transformed(by: transformScale)
    return UIImage(ciImage: scaledQRCoreImage)
}
```

## Scanning QR Codes in Swift
Now that we’ve mastered QR code generation, let’s explore the other side of the coin — scanning. Swift provides a built-in framework called `AVFoundation` with a focus on `AVCaptureSession` and the `AVCaptureMetadataOutputObjectsDelegate` protocol. Let's dissect the code snippet to understand the essential components that we can leverage to scan QR codes.
Create a new ViewController and import `AVFundation`.

```swift
import AVFoundation
```
Create properties of `AVCaptureSession` and `AVCaptureVideoPreviewLayer`
```swift
// MARK: - Properties
private var captureSession: AVCaptureSession!
private var previewLayer: AVCaptureVideoPreviewLayer!
```

`viewWillAppear` will set up the QR Scanner. I'll async/await approach but you could find another way in the codebase.
```swift
override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    Task {
        await setupQRScanner()
    }
}
```

Now let’s code our setup function along with async `startCaptureSession()` to counter Xcode’s main-thread warning.
``` swift
// MARK: - Scaning QR Code
extension QRScannerVC {
    
  private func setupQRScanner() async  {
      captureSession = AVCaptureSession()
      guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else { return }
      
      do {
          let videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
          captureSession.addInput(videoInput)
      } catch { return }
      
      let metadataOutput = AVCaptureMetadataOutput()
      captureSession.addOutput(metadataOutput)
      metadataOutput.setMetadataObjectsDelegate(self, queue: .main)
      metadataOutput.metadataObjectTypes = [.qr]
      
      previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
      previewLayer.frame = view.layer.bounds
      previewLayer.videoGravity = .resizeAspectFill
      view.layer.insertSublayer(previewLayer, at: 0)
      await startCaptureSession()
  }

  func startCaptureSession() async {
      let localCaptureSession = self.captureSession ?? AVCaptureSession()
      DispatchQueue.global(qos: .background).async {
          localCaptureSession.startRunning()
      }
  }
}
```

Next, implement [`AVCaptureMetadataOutputObjectsDelegate`](https://developer.apple.com/documentation/avfoundation/avcapturemetadataoutputobjectsdelegate) protocol for receiving metadata produced by a metadata capture output [`AVCaptureMetadataOutput`](https://developer.apple.com/documentation/avfoundation/avcapturemetadataoutput). On receiving metadata we’ll strop captureSession, vibrate the device, and present an alert with the scanned result, and on tapping the OK button, captureSession will again start.
```swift
// MARK: - AVCaptureMetadataOutputObjectsDelegate
extension QRScannerVC: AVCaptureMetadataOutputObjectsDelegate {

  func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
      captureSession.stopRunning()

      guard let metadataObject = metadataObjects.first else { return }
      guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
      guard let stringValue = readableObject.stringValue else { return }
      AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
      showQRCodeScannedAlert(stringValue)
  }
}
```
Add alert method to present in fail or success cases.
```swift
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
          Task { await self.startCaptureSession() }
      })
      present(alert, animated: true)
  }
}
```
Add a button to allow the user to dismiss the controller.
```swift
// MARK: - Actions
extension QRScannerVC {

  @IBAction func onClose(_ sender: UIButton) {
      self.dismiss(animated: true)
  }
}
```
We need to navigate the user from the main ViewController to the Scanner Controller. For that implement an [`Instantiable`](https://github.com/masadchattha/QRCodeHelper/blob/main/QRCodeHelper/Utilities/Instantiable.swift) protocol along with [`UIStoryboary+Extension`](https://github.com/masadchattha/QRCodeHelper/blob/main/QRCodeHelper/Extensinos/UIStoryboard%2BExtension.swift) to make Scanner ViewController’s initialization code easy and generic.
```swift
// MARK: - Instantiable
extension QRScannerVC: Instantiable {

  static var storyboard: UIStoryboard {
      UIStoryboard.main
  }
}
```
Next in the `Scan QR Code button`’s action method check if the user has granted permission otherwise show the alert with which to navigate to app settings. I’ve created a separate [`PermissionManager`](https://github.com/masadchattha/QRCodeHelper/blob/main/QRCodeHelper/Utilities/PermissionManager.swift) struct which provides static `checkCameraPermission` methods with both async/await approach and @escaping completion handlers.
```swift
// MARK: - Actions
extension ViewController {

  @IBAction func onScanQR(_ sender: UIButton) {
      Task {
          do {
              try await PermissionManager.checkCameraPermission()
              let vc = QRScannerVC.instantiate()
              vc.modalPresentationStyle = .fullScreen
              self.present(vc, animated: true)
          } catch {
              showCameraPermissionAlert()
          }
      }
  }
}

// MARK: - Camera Permission Setting Alert
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
```
> [!Note]
> Ensure to include the `Camera Usage Description` permission in the Info.plist file

---
I hope this guide helps elevate your experience. If you’d like to connect and further discuss iOS development, please feel free to [visit my LinkedIn profile](https://www.linkedin.com/in/masadchattha/).
Feel free to leave any questions or comments below.
Happy coding!


[!["Buy Me A Coffee"](https://www.buymeacoffee.com/assets/img/custom_images/orange_img.png)](https://www.buymeacoffee.com/asadchattha)

