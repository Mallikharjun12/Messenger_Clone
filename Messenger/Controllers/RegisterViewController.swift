//
//  RegisterViewController.swift
//  Messenger
//
//  Created by Mallikharjun kakarla on 25/06/23.
//

import UIKit
import PhotosUI
import FirebaseAuth
import JGProgressHUD

class RegisterViewController: UIViewController {

    private let spinner = JGProgressHUD(style: .dark)
    
    private let scrollView:UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.clipsToBounds = true
        scrollView.isUserInteractionEnabled = true
        return scrollView
    }()
    
    private let imageView:UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(systemName: "person.circle")
        imageView.tintColor = .gray
        imageView.isUserInteractionEnabled = true
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 2
        imageView.layer.borderColor = UIColor.lightGray.cgColor
        return imageView
    }()
    
    private let firstNameField:UITextField = {
        let field = UITextField()
        field.autocorrectionType = .no
        field.autocapitalizationType = .none
        field.layer.borderWidth = 1
        field.layer.borderColor = UIColor.lightGray.cgColor
        field.layer.cornerRadius = 12
        field.placeholder = "First Name..."
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 12, height: 0))
        field.leftViewMode = .always
        field.returnKeyType = .continue
        field.clearButtonMode = .whileEditing
        return field
    }()
    
    private let lastNameField:UITextField = {
        let field = UITextField()
        field.autocorrectionType = .no
        field.autocapitalizationType = .none
        field.layer.borderWidth = 1
        field.layer.borderColor = UIColor.lightGray.cgColor
        field.layer.cornerRadius = 12
        field.placeholder = "Last Name..."
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 12, height: 0))
        field.leftViewMode = .always
        field.returnKeyType = .continue
        field.clearButtonMode = .whileEditing
        return field
    }()
    
    private let emailField:UITextField = {
        let field = UITextField()
        field.autocorrectionType = .no
        field.autocapitalizationType = .none
        field.layer.borderWidth = 1
        field.layer.borderColor = UIColor.lightGray.cgColor
        field.layer.cornerRadius = 12
        field.placeholder = "Email Address..."
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 12, height: 0))
        field.leftViewMode = .always
        field.returnKeyType = .continue
        field.clearButtonMode = .whileEditing
        return field
    }()
    
    private let passwordField:UITextField = {
        let field = UITextField()
        field.autocorrectionType = .no
        field.autocapitalizationType = .none
        field.layer.borderWidth = 1
        field.layer.borderColor = UIColor.lightGray.cgColor
        field.layer.cornerRadius = 12
        field.placeholder = "Password..."
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 12, height: 0))
        field.leftViewMode = .always
        field.returnKeyType = .done
        field.isSecureTextEntry = true
        field.clearButtonMode = .whileEditing
        return field
    }()
    
    private let registerButton:UIButton = {
        let btn = UIButton()
        btn.setTitle("Register", for: .normal)
        btn.backgroundColor = .systemGreen
        btn.layer.cornerRadius = 12
        btn.setTitleColor(.label, for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 20, weight: .bold)
        return btn
    }()
    
    //MARK: LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        registerButton.addTarget(self,
                              action: #selector(registerButtonTapped),
                              for: .touchUpInside)
        
        firstNameField.delegate = self
        lastNameField.delegate = self
        emailField.delegate = self
        passwordField.delegate = self
        
        //Add subviews
        view.addSubview(scrollView)
        scrollView.addSubviews(imageView,firstNameField,lastNameField,emailField,passwordField,registerButton)
        
        let gesture = UITapGestureRecognizer(target: self,
                                             action: #selector(didTapChangeProfilePic))
        imageView.addGestureRecognizer(gesture)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scrollView.frame = view.bounds
        let size = scrollView.width/3
        
        imageView.frame = CGRect(x: (scrollView.width-size)/2,
                                 y: 20,
                                 width: size,
                                 height: size)
        imageView.layer.cornerRadius = imageView.width/2
        firstNameField.frame = CGRect(x: 30,
                                      y: imageView.bottom+12,
                                      width: scrollView.width-60,
                                      height: 52)
        lastNameField.frame = CGRect(x: 30,
                                     y: firstNameField.bottom+12,
                                     width: scrollView.width-60,
                                     height: 52)
        
        emailField.frame = CGRect(x: 30,
                                  y: lastNameField.bottom+12,
                                  width: scrollView.width-60,
                                  height: 52)
        
        passwordField.frame = CGRect(x: 30,
                                     y: emailField.bottom+12,
                                     width: scrollView.width-60,
                                     height: 52)
        
        registerButton.frame = CGRect(x: 30,
                                      y: passwordField.bottom+12,
                                      width: scrollView.width-60,
                                      height: 52)
    }

    
    @objc private func didTapChangeProfilePic() {
        presentActionSheet()
    }
    
    @objc private func registerButtonTapped() {
        firstNameField.resignFirstResponder()
        lastNameField.resignFirstResponder()
        emailField.resignFirstResponder()
        passwordField.resignFirstResponder()
        
        guard let firstName = firstNameField.text,
              let lastName = lastNameField.text,
              let email = emailField.text,
              let password = passwordField.text,
              !firstName.trimmingCharacters(in: .whitespaces).isEmpty,
              !lastName.trimmingCharacters(in: .whitespaces).isEmpty,
              !email.trimmingCharacters(in: .whitespaces).isEmpty,
              !password.trimmingCharacters(in: .whitespaces).isEmpty,
              password.count >= 6   else {
            alertUserLoginError()
            return
        }
        
        spinner.show(in: view, animated: true)
        
        DatabaseManager.shared.userexists(with: email) {[weak self] exists in
            guard let self else {
                return
            }
            guard !exists else {
                self.alertUserLoginError(message: "Looks like an user exists with email:\(email)")
                return
            }
            
            //Firebase Register
            Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
                
                DispatchQueue.main.async {
                    self.spinner.dismiss(animated: true)
                }
                
                guard let result = authResult, error == nil else {
                    print("Error in creating user:\(String(describing: error?.localizedDescription))")
                    return
                }

                print("created user is:\(result.user)")
                let chatUser = ChatAppUser(firstName: firstName,
                                           lastName: lastName,
                                           emailAddress: email)
                DatabaseManager.shared.insertUser(with: chatUser) { success in
                    if success {
                        //upload Image
                        guard let image = self.imageView.image,
                              let data = image.pngData() else {
                            return
                        }
                        let fileName = chatUser.profilePictureFileName
                        StorageManager.shared.uploadProfilePicture(with: data, fileName: fileName) { result in
                            switch result {
                            case .success(let downloadUrl):
                                UserDefaults.standard.set(downloadUrl, forKey: "profile_picture_url")
                                print("url is:-  \(downloadUrl)")
                            case .failure(let error):
                                print(error.localizedDescription)
                            }
                        }
                    }
                }
                
                self.navigationController?.dismiss(animated: true)
            }
        }
    }
    
    func alertUserLoginError(message:String = "Please enter all information to create a New account") {
        let alert = UIAlertController(title: "Oops",
                                      message: message,
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .cancel))
        present(alert, animated: true)
    }
    
}

//MARK: TextField
extension RegisterViewController:UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == firstNameField {
            lastNameField.becomeFirstResponder()
        } else if textField == lastNameField {
            emailField.becomeFirstResponder()
        } else if textField == emailField {
            passwordField.becomeFirstResponder()
        } else if textField == passwordField {
            registerButtonTapped()
        }
        return true
    }
}

//MARK: Setting Up profile picture
extension RegisterViewController:UIImagePickerControllerDelegate,UINavigationControllerDelegate,PHPickerViewControllerDelegate {
    
    
    private func presentActionSheet() {
        let sheet = UIAlertController(title: "Profile Picture",
                                      message: "How would you like to set your profile picture?",
                                      preferredStyle: .actionSheet)
        
        sheet.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        sheet.addAction(UIAlertAction(title: "Take Photo",
                                      style: .default,
                                      handler: {[weak self] _ in
            self?.presentCamera()
        }))
        sheet.addAction(UIAlertAction(title: "Choose Photo",
                                      style: .default,
                                      handler: {[weak self] _ in
            self?.presentPhotoPicker()
        }))
        
        present(sheet, animated: true)
    }
    
    private func presentCamera() {
        let vc = UIImagePickerController()
        vc.delegate = self
        vc.sourceType = .camera
        vc.allowsEditing = true
        present(vc, animated: true)
    }
    
    private func presentPhotoPicker() {
        let vc = UIImagePickerController()
        vc.delegate = self
        vc.sourceType = .photoLibrary
        vc.allowsEditing = true
        present(vc, animated: true)
        
//        if #available(iOS 14.0, *) {
//            var config = PHPickerConfiguration()
//            config.selectionLimit = 1
//
//            let photoPickerVC = PHPickerViewController(configuration: config)
//            photoPickerVC.delegate = self
//            present(photoPickerVC, animated: true)
//        } else {
//            // Fallback on earlier versions
//        }
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
       // print(info)
        guard let selectedImage = info[.editedImage] as? UIImage else {
            return
        }
        self.imageView.image = selectedImage
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
    
    // PHPicker for iOS > 14.0 version
    @available(iOS 14.0, *)
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        if let result = results.first {
            if result.itemProvider.canLoadObject(ofClass: UIImage.self) {
                result.itemProvider.loadObject(ofClass: UIImage.self) { providerReading, error in
                    if let image = providerReading as? UIImage {
                        DispatchQueue.main.async {
                            self.imageView.image = image
                        }
                    }
                }
            }
        }
    }

}


