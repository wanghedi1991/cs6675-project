//
//  tableHolderController.swift
//  Location Notifier
//
//  Created by Hedi Wang on 3/25/18.
//  Copyright © 2018 Hedi Wang. All rights reserved.
//

import UIKit
import CoreLocation
import UserNotifications

class TableHolderController: UITabBarController, UITabBarControllerDelegate, CLLocationManagerDelegate, UNUserNotificationCenterDelegate {

    var notificationTypes:[String] = []
    var username = ""
    var types:[NotificationType] = []
    var spinnerActivity:MBProgressHUD?
    var locationManager:CLLocationManager!
    var top:Double = 0
    var bottom:Double = 0
    var right:Double = 0
    var left:Double = 0
    var places:[Place] = []
    var mapViewController:SecondViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.navigationItem.title = "Categories"
        self.delegate = self
        
        spinnerActivity = MBProgressHUD.showAdded(to: self.view, animated: true);
        spinnerActivity?.label.text = "Loading";
        spinnerActivity?.detailsLabel.text = "Please Wait!!";
        spinnerActivity?.isUserInteractionEnabled = false;
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.showsBackgroundLocationIndicator = false
        locationManager.distanceFilter = 10
        locationManager.desiredAccuracy = 10
        if CLLocationManager.locationServicesEnabled() {
            locationManager.startUpdatingLocation()
            //locationManager.startUpdatingHeading()
        }
        
        
        UNUserNotificationCenter.current().delegate = self
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge], completionHandler: {didAllow, error in
        })
    }
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        if self.selectedIndex == 0 {
            (viewController as! FirstViewController).setNavigationBar()
        } else if self.selectedIndex == 1 {
            (viewController as! SecondViewController).setNavigationBar()
            self.mapViewController = viewController as? SecondViewController
        }
    }
   
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let userLocation:CLLocation = locations[0] as CLLocation
        
        // Call stopUpdatingLocation() to stop listening for location updates,
        // other wise this function will be called every time when user location changes.
        
        // manager.stopUpdatingLocation()
        
        let latitude = userLocation.coordinate.latitude
        let longitude = userLocation.coordinate.longitude
        let formatter = DateFormatter()
        
        formatter.timeZone = TimeZone.current
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss.sss"
        
        var dateString = formatter.string(from: Date())
        if UIApplication.shared.applicationState == .active {
            print("App is in foreground. New location is" + String(latitude) + " " + String(longitude) + " " + dateString)
            
        } else {
            print("App is backgrounded. New location is" + String(latitude) + " " + String(longitude) + " " + dateString)
        }
        
        if(latitude < bottom || latitude > top || longitude < left || longitude > right){
            places = []
        
            let url = URL(string: "http://django-env.khjt3mdvtx.us-east-1.elasticbeanstalk.com/location/username="+username+"&latitude="+String(latitude)+"&longitude="+String(longitude))
         //   let url = URL(string: "http://django-env.khjt3mdvtx.us-east-1.elasticbeanstalk.com/location/username=wx&latitude=33.780378&longitude=-84.388717")
            URLSession.shared.dataTask(with:url!, completionHandler: {(data, response, error) in
                guard let data = data, error == nil else { return }
                do {
                    let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String:Any]
                    let type:String = (json["type"] as? String)!
                    
                    if(type == "result_set"){
                        let decoder = JSONDecoder()
                        let test = try! decoder.decode(LocationResponse.self, from: data)
                        if !(self.top == test.box.top && self.bottom == test.box.bottom && self.left == test.box.left && self.right == test.box.right) {
                        
                            self.top = test.box.top
                            self.bottom = test.box.bottom
                            self.left = test.box.left
                            self.right = test.box.right
                            if test.numberOfResult > 0 {
                                let content = UNMutableNotificationContent()
                                content.title = "New Place Found"
                                content.subtitle = "Place"
                                content.body = "Tap to view places"
                                content.sound = UNNotificationSound.default()
                                content.badge = 1
                                let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.1, repeats: false)
                                let request = UNNotificationRequest(identifier: "testNotification", content: content, trigger: trigger)
                                UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
                            }
                            
                            for result in test.results {
                                self.places.append(Place(name: result.name, latitude: Double(result.latitude)!, longitude: Double(result.longitude)!, description: result.description, category: result.category))
                                print(result.name)
                            }
                        }
                        
                    }
                    DispatchQueue.main.async {
                        if !(self.spinnerActivity?.isHidden)!{
                            self.spinnerActivity?.hide(animated: true)
                            dateString = formatter.string(from: Date())
                            print("Got response!" + dateString)
                        }
                        self.mapViewController?.redrawMarkers()
                    }
                    
                } catch let error as NSError {
                    print(error)
                }
            }).resume()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error \(error)")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        print("This is called 2")
        locationManager.stopUpdatingLocation()
        
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler(UNNotificationPresentationOptions.sound)
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        UIApplication.shared.applicationIconBadgeNumber = 0
        self.selectedIndex = 1
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

struct LocationResponse : Codable {
    struct Box : Codable {
        let top: Double
        let right: Double
        let left: Double
        let bottom: Double
    }
    
    struct Result : Codable {
        let latitude: String
        let longitude: String
        let category: String
        let description: String
        let name: String
    }
    
    let box: Box
    let results: [Result]
    let numberOfResult: Int
    let type: String
}
