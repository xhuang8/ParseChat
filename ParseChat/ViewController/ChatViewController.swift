//
//  ChatViewController.swift
//  ParseChat
//
//  Created by XiaoQian Huang on 9/24/18.
//  Copyright © 2018 XiaoQian Huang. All rights reserved.
//

import UIKit
import Parse

class ChatViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    
    @IBOutlet weak var tableView: UITableView!
    
    
    @IBOutlet weak var chatMessageField: UITextField!
    
    var messages: [PFObject] = []
    var currentUser = PFUser.current()
    
    var window = UIWindow()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 50
        
        fetchMessage()
        
        Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.onTimer), userInfo: nil, repeats: true)
        
        //fetchMessage()
        // Do any additional setup after loading the view.
    }
    
    @IBAction func sendButton(_ sender: Any) {
        let chatMessage = PFObject(className: "Message")
        chatMessage["user"] = PFUser.current()
        chatMessage["text"] = chatMessageField.text ?? ""
        
        chatMessage.saveInBackground { (success, error) in
            if success {
                print("The message was saved!")
            } else if let error = error {
                print("Problem saving message: \(error.localizedDescription)")
            }
        }
        
    }
 
    @IBAction func logoutButton(_ sender: Any) {
        PFUser.logOutInBackground(block: { (error) in
            if let error = error {
                print(error.localizedDescription)
            } else {
                let user = PFUser.current() ?? nil
                print("Successful logout")
                print(user as Any)
                
            }
            self.performSegue(withIdentifier: "logoutSegue", sender: nil)
            
            
        })
    }
    
    

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChatCell", for: indexPath) as! ChatCell
        let message = messages[indexPath.row]
        let chatmessages = message["text"] as? String
        cell.chatMessage.text = chatmessages
        
        
        if let user = message["user"] as? PFUser {
            // User found! update username label with username
            cell.username.text = user.username
        } else {
            // No user found, set default username
            cell.username.text = "🤖"
        }
        return cell
    }
    

    func fetchMessage(){
        // construct query
        let query = PFQuery(className: "Message")
        query.addDescendingOrder("createdAt")
        query.includeKey("user")
       // query.limit = 20
        
        // fetch data asynchronously
        query.findObjectsInBackground { (posts: [PFObject]?, error: Error?) in
            if let posts = posts {
                // do something with the array of object returned by the call
                for message in posts{
                    if (message["text"] != nil)
                    {
                        print(message["text"]!)
                    }else{
                        print("no text")
                    }
                }
                self.messages = posts
                self.tableView.reloadData()
            } else {
                print(error!.localizedDescription)
            }
        }
    }
    
    @objc func onTimer(){
        fetchMessage()
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    


}
