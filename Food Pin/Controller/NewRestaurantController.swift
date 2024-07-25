//
//  NewRestaurantController.swift
//  Food Pin
//
//  Created by Dzmitry Hlushchuk on 22.07.24.
//

import UIKit
import PhotosUI
import SwiftData
import CloudKit

class NewRestaurantController: UITableViewController {
    
    var dataStore: RestaurantDataStore?
    
    // instantiate the model container
    let container = try? ModelContainer(for: Restaurant.self)
    
    @IBOutlet weak var photoImageView: UIImageView! {
        didSet {
            photoImageView.layer.cornerRadius = 10
            photoImageView.layer.masksToBounds = true
        }
    }
    
    @IBOutlet weak var nameTextField: RoundedTextField! {
        didSet {
            nameTextField.tag = 1
            nameTextField.delegate = self
        }
    }
    
    @IBOutlet weak var typeTextField: RoundedTextField! {
        didSet {
            typeTextField.tag = 2
            typeTextField.delegate = self
        }
    }
    
    @IBOutlet weak var addressTextField: RoundedTextField! {
        didSet {
            addressTextField.tag = 3
            addressTextField.delegate = self
        }
    }
    
    @IBOutlet weak var phoneTextField: RoundedTextField! {
        didSet {
            phoneTextField.tag = 4
            phoneTextField.delegate = self
        }
    }
    
    @IBOutlet weak var descriptionTextView: UITextView! {
        didSet {
            descriptionTextView.tag = 5
            descriptionTextView.layer.cornerRadius = 10
            descriptionTextView.layer.masksToBounds = true
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // hide keyboard
        let tapGesture = UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let appearance = navigationController?.navigationBar.standardAppearance {
            appearance.configureWithDefaultBackground()
            navigationController?.navigationBar.standardAppearance = appearance
            navigationController?.navigationBar.scrollEdgeAppearance = appearance
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            let photoSourceRequestController = UIAlertController(
                title: "",
                message: String(localized: "Choose your photo source"),
                preferredStyle: .actionSheet
            )
            let cameraAction = UIAlertAction(
                title: String(localized: "Camera"),
                style: .default
            ) { action in
                if UIImagePickerController.isSourceTypeAvailable(.camera) {
                    let imagePicker = UIImagePickerController()
                    imagePicker.allowsEditing = false
                    imagePicker.sourceType = .camera
                    imagePicker.delegate = self
                    self.present(imagePicker, animated: true)
                }
            }
            let photoLibraryAction = UIAlertAction(
                title: String(localized: "Photo library"),
                style: .default
            ) { action in
                var imagePickerConfiguration = PHPickerConfiguration(photoLibrary: .shared())
                imagePickerConfiguration.filter = .images
                imagePickerConfiguration.selectionLimit = 1
                imagePickerConfiguration.preferredAssetRepresentationMode = .current
                let imagePicker = PHPickerViewController(configuration: imagePickerConfiguration)
                imagePicker.delegate = self
                self.present(imagePicker, animated: true)
            }
            let cancelAction = UIAlertAction(
                title: String(localized: "Cancel"),
                style: .cancel
            )
            photoSourceRequestController.addAction(cameraAction)
            photoSourceRequestController.addAction(photoLibraryAction)
            photoSourceRequestController.addAction(cancelAction)
            if let popoverController = photoSourceRequestController.popoverPresentationController {
                if let cell = tableView.cellForRow(at: indexPath) {
                    popoverController.sourceView = cell
                    popoverController.sourceRect = cell.bounds
                }
            }
            present(photoSourceRequestController, animated: true)
        }
    }
    
    @IBAction func saveButtonPressed(_ sender: UIBarButtonItem) {
        guard let name = nameTextField.text, name != "",
              let type = typeTextField.text, type != "",
              let location = addressTextField.text, location != "",
              let phone = phoneTextField.text, phone != "",
              let description = descriptionTextView.text, description != ""
        else { return }
        let restaurant = Restaurant(
            name: name,
            type: type,
            location: location,
            phone: phone,
            description: description,
            image: photoImageView.image
        )
        container?.mainContext.insert(restaurant)
        saveRecordToCloud(restaurant: restaurant)
        dismiss(animated: true) {
            self.dataStore?.fetchRestaurantData(searchText: "")
        }
    }
    
    func saveRecordToCloud(restaurant: Restaurant) {
        
        // prepare the record to save
        let record = CKRecord(recordType: "Restaurant")
        record.setValue(restaurant.name, forKey: "name")
        record.setValue(restaurant.type, forKey: "type")
        record.setValue(restaurant.location, forKey: "location")
        record.setValue(restaurant.phone, forKey: "phone")
        record.setValue(restaurant.summary, forKey: "description")
        
        // resize the image
        var imageFileURL: URL?
        if let originalImage = restaurant.image {
            let width = originalImage.size.width
            let scalingFactor = width > 1024 ? 1024 / width : 1
            let imageFilePath = NSTemporaryDirectory() + restaurant.name
            imageFileURL = URL(filePath: imageFilePath)
            if let imageData = originalImage.pngData(),
               let scaledImage = UIImage(data: imageData, scale: scalingFactor) {
                // write the image to local file for temporary use
                try? scaledImage.jpegData(compressionQuality: 0.8)?.write(to: imageFileURL!)
                // creating image asset for upload
                let imageAsset = CKAsset(fileURL: imageFileURL!)
                record.setValue(imageAsset, forKey: "image")
            }
        }
        // get the public iCloud database
        let publicDatabase = CKContainer.default().publicCloudDatabase
        // save the record to iCloud
        publicDatabase.save(record) { record, error in
            guard error == nil else {
                print(error!.localizedDescription)
                return
            }
            // remove temp file
            if let imageFileURL {
                try? FileManager.default.removeItem(at: imageFileURL)
            }
        }
    }
    
}

// MARK: - UITextFieldDelegate
extension NewRestaurantController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let nextTextField = view.viewWithTag(textField.tag + 1) {
            nextTextField.becomeFirstResponder()
        }
        return true
    }
    
}

// MARK: - PHPickerViewControllerDelegate
extension NewRestaurantController: PHPickerViewControllerDelegate {
    
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        results.forEach { result in
            result.itemProvider.loadObject(ofClass: UIImage.self) { [weak self] reading, error in
                guard let self else { return }
                guard error == nil else {
                    print(error!.localizedDescription)
                    return
                }
                if let image = reading as? UIImage {
                    DispatchQueue.main.async {
                        self.photoImageView.image = image
                    }
                }
                
            }
        }
        dismiss(animated: true)
    }
    
}

// MARK: - UIImagePickerControllerDelegate
extension NewRestaurantController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let selectedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            photoImageView.image = selectedImage
        }
        dismiss(animated: true)
    }
    
}
