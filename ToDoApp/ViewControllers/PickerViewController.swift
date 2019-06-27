//
//  PickerViewController.swift
//  ToDoApp
//
//  Created by Sushmitha Devi on 6/25/19.
//  Copyright © 2018 Sushmitha Devi. All rights reserved.
//

import UIKit
import UserNotifications
import UserNotificationsUI

class PickerViewController: UIViewController,UNUserNotificationCenterDelegate {
    @IBOutlet weak var backbutton: UIButton!
    @IBOutlet weak var reminderlabel: UILabel!
    @IBOutlet weak var dateTimePicker: UIDatePicker!
    var notificationbody=""
    var date=DateComponents()
    var todo:Todos?
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func backTapped(_ sender: UIButton) {
        
         self.view.window?.rootViewController?.dismiss(animated: false, completion: nil)
       
    }

    @IBAction func setreminderTapped(_ sender: UIButton) {
       let notification = UNMutableNotificationContent()
        reminderlabel.text = "Please Wait..."
        notification.title="Reminder"
        notification.body=notificationbody
        notification.sound=UNNotificationSound.default()
         print(dateTimePicker.date)
        let components = Calendar.current.dateComponents([.hour, .minute], from: dateTimePicker.date)
        let hour = components.hour!
        let minute = components.minute!
        date.hour=hour
        date.minute=minute
        let trigger = UNCalendarNotificationTrigger(dateMatching: date, repeats: true)
        let request = UNNotificationRequest(identifier: "localNotification", content: notification, trigger: trigger)
        UNUserNotificationCenter.current().delegate = self
        UNUserNotificationCenter.current().add(request){(error) in

            if (error != nil){
                print(error?.localizedDescription)
            }
            else{
                if self.backbutton.isHidden{
                    self.reminderlabel.text = "Reminder set successfully"
                    self.backbutton.isHidden = false
                }
                
            }
        }
    }
    
    @IBAction func cancelTapped(_ sender: UIButton) {
        UNUserNotificationCenter.current().getDeliveredNotifications { (notifications) in
            let isLocal = notifications.contains(where: { (notification) -> Bool in
                return notification.request.identifier == "localNotification"
                })
            if isLocal {
                UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers:  ["localNotification"])
                self.reminderlabel.text="Remainder is cancelled"
            }
            else
            {
                UNUserNotificationCenter.current().getPendingNotificationRequests(completionHandler: { (notificationRequests) in
                    let isLocal = notificationRequests.contains(where: { (request) -> Bool in
                        return request.identifier == "localNotification"
                    })
                    if isLocal {
                        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["localNotification"])
                        self.reminderlabel.text="Remainder is cancelled"
                    }
                })
            
            }
        }
        
    }
//    @IBAction func timepicker(_ sender: UIDatePicker) {
//        let dateFormatter = DateFormatter()
//
//        dateFormatter.dateStyle = DateFormatter.Style.short
//
//        dateFormatter.timeStyle = DateFormatter.Style.short
//
//        //dateLabel.text = dateFormatter.string(from: sender.date)
//
//    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
  
    


}
