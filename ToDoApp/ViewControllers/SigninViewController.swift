//
//  SigninViewController.swift
//  ToDoApp
//
//  Created by Sushmitha Devi on 6/25/19.
//  Copyright © 2019 Sushmitha Devi. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

class SigninViewController: UIViewController {

    @IBOutlet weak var mailid: UITextField!
    @IBOutlet weak var password: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func SiginTapped(_ sender: Any) {
        if mailid.text == "" {
            let alertController = UIAlertController(title: "Error", message: "Please enter your email and password", preferredStyle: .alert)
            let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertController.addAction(defaultAction)
            present(alertController, animated: true, completion: nil)
        } else {
            Auth.auth().signIn(withEmail: mailid.text!, password: password.text!) { (user, error) in
                if error == nil {
                    print("You have successfully signedin")
                    self.performSegue(withIdentifier: "SignintoTasks", sender: nil)
                } else {
                    let alertController = UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: .alert)
                    let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                    alertController.addAction(defaultAction)
                    self.present(alertController, animated: true, completion: nil)
                }
            }
        }
    }
    
    @IBAction func SignupTapped(_ sender: Any) {
       performSegue(withIdentifier: "CreateUser", sender: nil)
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
