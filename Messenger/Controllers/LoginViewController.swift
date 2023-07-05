//
//  LoginViewController.swift
//  Messenger
//
//  Created by Mallikharjun kakarla on 25/06/23.
//

import UIKit
import FirebaseAuth
import GoogleSignIn
import Firebase
import JGProgressHUD

class LoginViewController: UIViewController {

    private let spinner = JGProgressHUD(style: .dark)
    
    private let scrollView:UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.clipsToBounds = true
        return scrollView
    }()
    
    private let imageView:UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(systemName: "paperplane.circle.fill")
        imageView.tintColor = .link
        return imageView
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
    
    private let loginButton:UIButton = {
        let btn = UIButton()
        btn.setTitle("Log In", for: .normal)
        btn.backgroundColor = .link
        btn.layer.cornerRadius = 12
        btn.setTitleColor(.label, for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 20, weight: .bold)
        return btn
    }()
    
    private let googleSignInButton:GIDSignInButton = {
        let btn = GIDSignInButton()
        btn.layer.cornerRadius = 12
        return btn
    }()
    
    //MARK: LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        loginButton.addTarget(self,
                              action: #selector(loginButtonTapped),
                              for: .touchUpInside)
        
        emailField.delegate = self
        passwordField.delegate = self
        
        //Add subviews
        view.addSubview(scrollView)
        scrollView.addSubviews(imageView,emailField,passwordField,loginButton,googleSignInButton)
        googleSignInButton.addTarget(self, action: #selector(didTapGoogleSignIn), for: .touchUpInside)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scrollView.frame = view.bounds
        let size = scrollView.width/3
        imageView.frame = CGRect(x: (scrollView.width-size)/2,
                                 y: 20,
                                 width: size,
                                 height: size)
        emailField.frame = CGRect(x: 30,
                                  y: imageView.bottom+12,
                                  width: scrollView.width-60,
                                  height: 52)
        passwordField.frame = CGRect(x: 30,
                                     y: emailField.bottom+12,
                                     width: scrollView.width-60,
                                     height: 52)
        loginButton.frame = CGRect(x: 30,
                                   y: passwordField.bottom+12,
                                   width: scrollView.width-60,
                                   height: 52)
        googleSignInButton.frame = CGRect(x: 30,
                                   y: loginButton.bottom+12,
                                   width: scrollView.width-60,
                                   height: 52)
    }

    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        title = "Log In"
        self.navigationController?.navigationBar.backgroundColor = .systemGray6
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Register",
                                                            style: .done,
                                                            target: self,
                                                            action: #selector(didTapRegister))
    }
    
    @objc private func loginButtonTapped() {
        emailField.resignFirstResponder()
        passwordField.resignFirstResponder()
        guard let email = emailField.text,
              let password = passwordField.text,
              !email.trimmingCharacters(in: .whitespaces).isEmpty,
              !password.trimmingCharacters(in: .whitespaces).isEmpty,
              password.count >= 6   else {
            alertUserLoginError()
            return
        }
        
        spinner.show(in: view, animated: true)
        
        //Firebase Login
        Auth.auth().signIn(withEmail: email, password: password) {[weak self] authResult, error in
            guard let self else {
                return
            }
            
            DispatchQueue.main.async {
                self.spinner.dismiss(animated: true)
            }
            
            guard let result = authResult,error == nil else {
                print("Error in signing the user in:\(String(describing: error?.localizedDescription))")
                return
            }
            print("Logged in user:\(result.user)")
            UserDefaults.standard.set(email, forKey: "email")
            self.navigationController?.dismiss(animated: true)
        }
    }
    
    func alertUserLoginError() {
        let alert = UIAlertController(title: "Oops",
                                      message: "Please enter all information to Login",
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .cancel))
        present(alert, animated: true)
    }
    
    @objc private func didTapRegister() {
        let vc = RegisterViewController()
        vc.title = "Create Account"
        navigationController?.pushViewController(vc, animated: true)
    }
    
}


//MARK: TextField
extension LoginViewController:UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == emailField {
            passwordField.becomeFirstResponder()
        } else if textField == passwordField {
            loginButtonTapped()
        }
        return true
    }
}

//MARK: Google Signin
extension LoginViewController {
    
     @objc private func didTapGoogleSignIn() {
         
         guard let clientID = FirebaseApp.app()?.options.clientID else {
             return
         }
         
         //Google signin configuration object
         let config = GIDConfiguration(clientID: clientID)
         GIDSignIn.sharedInstance.configuration = config
         
         GIDSignIn.sharedInstance.signIn(withPresenting: self) { result, error in
             guard let result = result,error == nil else {
                 print("Error in signing in with google:\(String(describing: error?.localizedDescription))")
                 return
             }
             print("Signed in user with Google:\(result.user)")
             
             
             guard let email = result.user.profile?.email,
                   let firstName = result.user.profile?.givenName,
                   let lastName = result.user.profile?.familyName else {
                 return
             }
             
             DatabaseManager.shared.userexists(with: email ) { exists in
                 if !exists {
                     //insert user to database
                     let chatUser = ChatAppUser(firstName: firstName,
                                                lastName: lastName,
                                                emailAddress: email)
                     DatabaseManager.shared.insertUser(with: chatUser) { success in
                         if success {
                             
                             guard let hasImage = result.user.profile?.hasImage else {
                                 return
                             }
                             
                             if hasImage {
                                 guard let profileImageUrl = result.user.profile?.imageURL(withDimension: 200) else {
                                     print("Failed to get google profile image url")
                                     return
                                 }
                                 
                                 print("Downloading data from google")
                                 
                                 URLSession.shared.dataTask(with: profileImageUrl) { data, _, error in
                                     guard let data = data else {
                                         print("Failed to get data from google-\(error?.localizedDescription)")
                                         return
                                     }
                                     //upload Image
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
                                 }.resume()
                             }
                         }
                     }
                 }
             }
             
             guard let idToken = result.user.idToken?.tokenString else {
                 return
             }
             
             let credential = GoogleAuthProvider.credential(withIDToken: idToken,
                                                            accessToken: result.user.accessToken.tokenString)
             
             Auth.auth().signIn(with: credential) { authResult, error in
                 guard authResult != nil, error == nil else {
                     print("Failed to Login with google credential-\(error)")
                     return
                 }
                 print("successfully signed in with Google Credential-\(result.user.profile?.email ?? "")")
                 UserDefaults.standard.set(email, forKey: "email")
                 self.navigationController?.dismiss(animated: true)
             }
         }
    }
}
