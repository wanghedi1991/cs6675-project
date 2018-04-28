//
//  LoginViewController.swift
//  Location Notifier
//
//  Created by Hedi Wang on 3/24/18.
//  Copyright © 2018 Hedi Wang. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, UITextFieldDelegate, PopRegisterDelegate {
    
    

    @IBOutlet weak var loginLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var usernameText: UITextField!
    
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var passwordTextField: UITextField!
    var spinnerActivity:MBProgressHUD?
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        usernameText.delegate = self
        passwordTextField.delegate = self
        //self.navigationItem.titleView = UIImageView(image: UIImage(named: "title_small.png"))
     //   self.navigationItem.title = "Login Page"
//        let loginItem = UIBarButtonItem(title: "Login", style: UIBarButtonItemStyle.plain, target: self, action: #selector(login))
//        self.navigationItem.rightBarButtonItem = loginItem
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        
        usernameText.leftViewMode = UITextFieldViewMode.always
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        let image = UIImage(named: "user.png")
        imageView.image = image
       // usernameText.leftView = imageView
        
        passwordTextField.leftViewMode = UITextFieldViewMode.always
        let imageViewPassword = UIImageView(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        let imagePassword = UIImage(named: "password.png")
        imageViewPassword.image = imagePassword
        passwordTextField.leftView = imageViewPassword
        
        loginButton.layer.cornerRadius = 5
        loginButton.layer.borderWidth = 1
        loginButton.layer.borderColor = loginButton.layer.backgroundColor
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.endEditing(true)
        return true
    }
    

    @IBAction func login(_ sender: UIButton) {
        spinnerActivity = MBProgressHUD.showAdded(to: self.view, animated: true);
        spinnerActivity?.label.text = "Loading";
        spinnerActivity?.detailsLabel.text = "Please Wait!!";
        spinnerActivity?.isUserInteractionEnabled = false;
        
        let username:String = usernameText.text!
        let password:String = passwordTextField.text!
        let url = URL(string: "http://django-env.khjt3mdvtx.us-east-1.elasticbeanstalk.com/login/username="+username+"&password="+password)
        var statusRespone:Int = 0
        var responseString:String = ""
        
        URLSession.shared.dataTask(with:url!, completionHandler: {(data, response, error) in
            guard let data = data, error == nil else { return }
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String:Any]
                statusRespone = (json["status"] as? Int)!
                responseString = (json["reason"] as? String)!
                if(statusRespone == 1){
                    let tempArray: [Any] = (json["category"] as? [Any])!
                    var categories: [String] = []
                    for category in tempArray {
                        if let a = category as? String {
                            categories.append(a)
                        }
                    }
                    DispatchQueue.main.async {
                        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                        let newViewController = storyBoard.instantiateViewController(withIdentifier: "tableHolderController") as! TableHolderController
                        newViewController.notificationTypes = categories
                        newViewController.username = username
                        self.spinnerActivity?.hide(animated: true)
                        self.navigationController?.pushViewController(newViewController, animated: true)
                    }
                } else {
                    DispatchQueue.main.async {
                        self.spinnerActivity?.hide(animated: true)
                        self.showToast(message: responseString)
                    }
                }
            } catch let error as NSError {
                print(error)
            }
        }).resume()
    }
    
    @IBAction func register(_ sender: UIButton) {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let newViewController = storyBoard.instantiateViewController(withIdentifier: "registerViewController") as! RegisterViewController
        newViewController.loginReference = self
        self.navigationController?.pushViewController(newViewController, animated: true)
    }
    
    func popRegisterView() {
        self.showToast(message: "Successfully Registered")
        self.navigationController?.popViewController(animated: true)
    }
}

protocol PopRegisterDelegate {
    func popRegisterView() -> Void
}
