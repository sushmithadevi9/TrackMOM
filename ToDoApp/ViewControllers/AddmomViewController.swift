//
//  AddTodoViewController.swift
//  ToDoApp
//
//  Created by Sushmitha Devi on 6/25/19.
//  Copyright © 2018 Sushmitha Devi. All rights reserved.
//

import UIKit
import CoreData
import Speech

class AddMomViewController: UIViewController,SFSpeechRecognizerDelegate {
    
    var managedContext:NSManagedObjectContext!
    var todo:Todos?
    
    var date = Date()
    let formatter = DateFormatter()
  
    var notificationbody=""
  
   
    
    @IBOutlet weak var momTitle: UITextView!
    @IBOutlet weak var momAuthor: UITextView!
    @IBOutlet weak var textview: UITextView!
    @IBOutlet weak var donebutton: UIButton!
    
    @IBOutlet weak var reminderbutoon: UIButton!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var microphoneButton: UIButton!
    
    
    private let speechRecognizer=SFSpeechRecognizer(locale: Locale.init(identifier: "en-US"))
    
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillShow(with:)),
                                               name: .UIKeyboardWillShow,
                                               object: nil)
        momTitle.becomeFirstResponder()
        self.navigationItem.setHidesBackButton(true, animated:true)
        if let todo=todo{
            momTitle.text = todo.momtitle
            momTitle.text = todo.momtitle
            momAuthor.text = todo.momauthor
            momAuthor.text = todo.momauthor
            textview.text = todo.momdescription
            textview.text = todo.momdescription
            todo.date = date
            
        }
        microphoneButton.isEnabled = false
        speechRecognizer?.delegate = self
        SFSpeechRecognizer.requestAuthorization { (authStatus) in
            var isButtonEnabled = false
            switch authStatus {
            case .authorized:
                isButtonEnabled = true
                
            case .denied:
                isButtonEnabled = false
                print("User denied access to speech recognition")
                
            case .restricted:
                isButtonEnabled = false
                print("Speech recognition restricted on this device")
                
            case .notDetermined:
                isButtonEnabled = false
                print("Speech recognition not yet authorized")
            }
            OperationQueue.main.addOperation() {
                self.microphoneButton.isEnabled = isButtonEnabled
            }
        }
        // Do any additional setup after loading the view.
        
    }
    
    
    func startRecording() {
        
        if recognitionTask != nil {
            recognitionTask?.cancel()
            recognitionTask = nil
        }
        
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(AVAudioSessionCategoryRecord)
            try audioSession.setMode(AVAudioSessionModeMeasurement)
            try audioSession.setActive(true, with: .notifyOthersOnDeactivation)
        } catch {
            print("audioSession properties weren't set because of an error.")
        }
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
            let inputNode = audioEngine.inputNode

        guard let recognitionRequest = recognitionRequest else {
            fatalError("Unable to create an SFSpeechAudioBufferRecognitionRequest object")
        }
        recognitionRequest.shouldReportPartialResults = true
        
        recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest, resultHandler: { (result, error) in
            var isFinal = false
            if result != nil {
                self.textview.text = result?.bestTranscription.formattedString
                isFinal = (result?.isFinal)!
            }
            if error != nil || isFinal {
                self.audioEngine.stop()
                inputNode.removeTap(onBus: 0)
                
                self.recognitionRequest = nil
                self.recognitionTask = nil
                
                self.microphoneButton.isEnabled = true
            }
        })
        let recordingFormat = inputNode.outputFormat(forBus: 0) 
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer, when) in
            self.recognitionRequest?.append(buffer)
        }
        audioEngine.prepare()
        do {
            try audioEngine.start()
        } catch {
            print("audioEngine couldn't start because of an error.")
        }
        textview.text = "Say something, I'm listening!"
    }
    
    func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
        if available {
            microphoneButton.isEnabled = true
        } else {
            microphoneButton.isEnabled = false
        }
    }
    
    @objc func keyboardWillShow(with notification: Notification){
        let key = "UIKeyboardFrameBeginUserInfoKey"
        guard  let keyboardFrame=notification.userInfo?[key] as? NSValue else {return}
        
        let keyboardHeight=keyboardFrame.cgRectValue.height
        bottomConstraint.constant=keyboardHeight+16
        
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
        
    }
    @IBAction func doneTapped(_ sender: UIButton) {
        guard let momDescription=textview.text, let momtitle = momTitle.text, let momauthor = momAuthor.text, !momDescription.isEmpty else{return}
        
        if let todo=self.todo{
            todo.momtitle = momtitle
            todo.momauthor = momauthor
            todo.momdescription = momDescription
            todo.date=date
           
        }else{
            let todo=Todos(context: managedContext)
            todo.momtitle = momtitle
            todo.momauthor = momauthor
            todo.momdescription=momDescription
            todo.date=date
        }
        do{
            try managedContext.save()
            dismissandResign()
        }catch{
            print("error: \(error.localizedDescription)")
        }
    }
    
    
    @IBAction func shareTapped(_ sender: Any) {
        let activityController=UIActivityViewController(activityItems: [textview.text!], applicationActivities: nil)
        present(activityController, animated: true, completion: nil)
    }
    
   
    @IBAction func startRecording(_ sender: Any) {
        if audioEngine.isRunning {
            audioEngine.stop()
            recognitionRequest?.endAudio()
            microphoneButton.isEnabled = false
            microphoneButton.setTitle("Start Recording", for: .normal)
        } else {
            startRecording()
            microphoneButton.setTitle("Stop Recording", for: .normal)
        }
    }

    fileprivate func dismissandResign() {
        dismiss(animated: true)
        momTitle.resignFirstResponder()
        
    }
    
    @IBAction func CancelTapped(_ sender: UIButton) {
        dismissandResign()
    }
    
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     if let vc=segue.destination as? PickerViewController{
     vc.notificationbody = textview.text
     }
     }
    
}

extension AddMomViewController:UITextViewDelegate{
    func textViewDidChangeSelection(_ textView: UITextView) {
        if donebutton.isHidden&&reminderbutoon.isHidden{
           
            momTitle.text.removeAll()
            
            momTitle.textColor = .white
            momAuthor.textColor = .white
            textview.textColor = .white
            donebutton.isHidden = false
            reminderbutoon.isHidden = false
           
            
            UIView.animate(withDuration:0.5) {
                self.view.layoutIfNeeded()
            }
        }
    }
}
