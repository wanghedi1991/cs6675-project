//
//  RegisterViewController.swift
//  Location Notifier
//
//  Created by Hedi Wang on 4/2/18.
//  Copyright © 2018 Hedi Wang. All rights reserved.
//

import UIKit

class RegisterViewController: UIViewController, UITextFieldDelegate {


    @IBOutlet weak var usernameText: UITextField!
    @IBOutlet weak var passwordText: UITextField!
    @IBOutlet weak var confirmText: UITextField!
    @IBOutlet weak var registerButton: UIButton!
    var loginReference:PopRegisterDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        usernameText.delegate = self
        passwordText.delegate = self
        confirmText.delegate = self
        
        self.navigationItem.title = "Register"
  //      let registerItem = UIBarButtonItem(title: "Register", style: UIBarButtonItemStyle.plain, target: self, action: #selector(registerButtonPressed))
  //      registerItem.tintColor = UIColor.white
        
    //self.navigationItem.rightBarButtonItem = registerItem
  //      self.navigationController?.navigationBar.tintColor = UIColor.white
        
        usernameText.leftViewMode = UITextFieldViewMode.always
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        let image = UIImage(named: "user.png")
        imageView.image = image
        usernameText.leftView = imageView

        passwordText.leftViewMode = UITextFieldViewMode.always
        let passwordImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        let passwordImage = UIImage(named: "password.png")
        passwordImageView.image = passwordImage
        passwordText.leftView = passwordImageView
//
        confirmText.leftViewMode = UITextFieldViewMode.always
        let confirmImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        let confirmImage = UIImage(named: "password.png")
        confirmImageView.image = confirmImage
        confirmText.leftView = confirmImageView
        
        registerButton.layer.cornerRadius = 5
        registerButton.layer.borderWidth = 1
        registerButton.layer.borderColor = registerButton.layer.backgroundColor
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.endEditing(true)
        return true
    }
    
    @IBAction func registerPressed(_ sender: UIButton) {
        let username:String = usernameText.text!
        let password:String = passwordText.text!
        let confirmPassword:String = confirmText.text!
        if(password == confirmPassword) {
            let url = URL(string: "http://django-env.khjt3mdvtx.us-east-1.elasticbeanstalk.com/register/username="+username+"&password="+password)
            var statusRespone:Int = 0
            var responseString:String = ""
            URLSession.shared.dataTask(with:url!, completionHandler: {(data, response, error) in
                guard let data = data, error == nil else { return }
                do {
                    let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String:Any]
                    statusRespone = (json["status"] as? Int)!
                    responseString = (json["reason"] as? String)!
                    if(statusRespone == 1){
                        DispatchQueue.main.async {
                            self.loginReference?.popRegisterView()
                        }
                    } else {
                        DispatchQueue.main.async {
                            self.showToast(message: responseString)
                        }
                    }
                } catch let error as NSError {
                    print(error)
                }
            }).resume()
        } else {
            self.showToast(message: "Password does not match")
        }
    }
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
