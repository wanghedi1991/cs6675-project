//
//  FirstViewController.swift
//  Location Notifier
//
//  Created by Hedi Wang on 3/14/18.
//  Copyright © 2018 Hedi Wang. All rights reserved.
//

import UIKit

class FirstViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIPickerViewDataSource, UIPickerViewDelegate {

    @IBOutlet weak var typePicker: UIPickerView!
    @IBOutlet weak var notificationTypeTable: UITableView!
    var addList:[String] = ["atm", "supermarket", "postoffice", "shoppingmall", "gasstation","coffee"]
    var tempType:Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let parentController = self.tabBarController as! TableHolderController
        
        self.notificationTypeTable.delegate = self
        self.notificationTypeTable.dataSource = self
        self.notificationTypeTable.tableFooterView = UIView()
        
        self.typePicker.dataSource = self
        self.typePicker.delegate = self
        setNavigationBar()
    }
    
    
    func setNavigationBar(){
        (self.tabBarController as! TableHolderController).navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Add", style: UIBarButtonItemStyle.plain, target: self, action: #selector(addNotificationType))
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (self.tabBarController as! TableHolderController).notificationTypes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "notificationTypeCell", for: indexPath) as! NotificationTypeCell
        cell.nameLabel.text =  (self.tabBarController as! TableHolderController).notificationTypes[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {

        let deleteAction = UITableViewRowAction(style: .destructive, title: "Delete", handler: { (action, indexPath) in
            let categoryToDelete:String = (self.tabBarController as! TableHolderController).notificationTypes[indexPath.row]
            let url = URL(string: "http://django-env.khjt3mdvtx.us-east-1.elasticbeanstalk.com/delete/username="+(self.tabBarController as! TableHolderController).username+"&category="+categoryToDelete)
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
                            (self.tabBarController as! TableHolderController).notificationTypes.remove(at: indexPath.row)
                            self.notificationTypeTable.reloadData()
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
        })
        deleteAction.backgroundColor = UIColor.red
        
        return [deleteAction]
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return addList.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return addList[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.tempType = row
    }
    
    
    @IBAction func addNotificationType(_ sender: UIBarButtonItem) {
     //   self.doneButton.isHidden = false
        if self.typePicker.isHidden {
            self.typePicker.isHidden = false
            self.notificationTypeTable.isHidden = true
            sender.title = "Done"
        } else {
            
            self.typePicker.isHidden = true
            self.notificationTypeTable.isHidden = false
            if (self.tabBarController as! TableHolderController).notificationTypes.contains(addList[tempType]) {
                showToast(message: "It is already added")
            } else {
                let categoryToAdd:String = addList[tempType]
                let url = URL(string: "http://django-env.khjt3mdvtx.us-east-1.elasticbeanstalk.com/add/username="+(self.tabBarController as! TableHolderController).username+"&category="+categoryToAdd)
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
                                (self.tabBarController as! TableHolderController).notificationTypes.append(self.addList[self.tempType])
                                self.notificationTypeTable.reloadData()
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
            }
            sender.title = "Add"
        }
    }
    
}

extension UIViewController {
    
    func showToast(message : String) {
        
        let toastLabel = UILabel(frame: CGRect(x: self.view.frame.size.width/2 - 75, y: self.view.frame.size.height-100, width: 150, height: 35))
        toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        toastLabel.textColor = UIColor.white
        toastLabel.textAlignment = .center;
        toastLabel.font = UIFont(name: "Montserrat-Light", size: 12.0)
        toastLabel.text = " " + message + "  "
        toastLabel.alpha = 1.0
        toastLabel.layer.cornerRadius = 5;
        toastLabel.clipsToBounds  =  true
        toastLabel.sizeToFit()
        toastLabel.center.x = self.view.center.x
        self.view.addSubview(toastLabel)
        UIView.animate(withDuration: 4.0, delay: 0.1, options: .curveEaseOut, animations: {
            toastLabel.alpha = 0.0
        }, completion: {(isCompleted) in
            toastLabel.removeFromSuperview()
        })
    }
}




