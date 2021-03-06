//
//  ViewController.swift
//  OtoSehatFixed
//
//  Created by Jevier Izza Maulana on 11/04/22.
//

import UIKit
import UserNotifications

class ToDoListViewController: UIViewController {
    
    @IBOutlet weak var addBarButton: UIBarButtonItem!
    @IBOutlet weak var tableView: UITableView!
    
    var toDoItems: [ToDoItem] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        
        loadData()
        autherizeLocalNotification()
    }
    
    func autherizeLocalNotification() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) {(granted, error) in
            guard error == nil else {
                print("Error: \(error!.localizedDescription)")
                return
            }
            if granted {
                print("Notification Authorization Granted")
            }else {
                print("User denied notification")
                
                //TODO: Put alert in here telling user what to do
            }
        }
    }
    
    func setNotifications() {
        guard toDoItems.count > 0 else {
            return
        }
        
        //remove all notification
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        
        //re-create notification with the updated data that has just saved
        for index in 0..<toDoItems.count {
            if toDoItems[index].reminderSet {
                
                let toDoItem = toDoItems[index]
                
                toDoItems[index].notificationID = setCalendarNotification(title: toDoItem.name, subtitle: "", body: toDoItem.notes, badgeNumber: nil, sound: .default, date: toDoItem.date)
            }
        }
    }
    
    func setCalendarNotification(title: String, subtitle: String, body: String, badgeNumber: NSNumber?, sound: UNNotificationSound, date: Date) -> String {
        //create content:
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.subtitle = subtitle
        content.sound = sound
        content.badge = badgeNumber
        
        //create trigger
        var dateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: date)
        dateComponents.second = 00
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        
        //create request
        let notificationID = UUID().uuidString
        let request = UNNotificationRequest(identifier: notificationID, content: content, trigger: trigger)
        
        //register request with notification center
        UNUserNotificationCenter.current().add(request) { (error) in
            if let error = error {
                print("Error: \(error.localizedDescription) in adding notification request")
            } else {
                print("Notification scheduler \(notificationID), title: \(content.title)")
            }
        }
        return notificationID
    }
    
    func loadData() {
        let directoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let documentURL = directoryURL.appendingPathComponent("todos").appendingPathExtension("json")
        
        guard let data = try? Data(contentsOf: documentURL) else {
            return
        }
        
        let jsonDecoder = JSONDecoder()
        do {
            toDoItems = try jsonDecoder.decode(Array<ToDoItem>.self, from: data)
            tableView.reloadData()
        } catch {
            print("somting not good about load data")
        }
    }
    
    func saveData() {
        let directoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let documentURL = directoryURL.appendingPathComponent("todos").appendingPathExtension("json")
        
        let jsonEncoder = JSONEncoder()
        let data = try? jsonEncoder.encode(toDoItems)
        do {
            try data?.write(to: documentURL, options: .noFileProtection)
        } catch {
            print("somting not good about save data : \(error.localizedDescription)")
        }
        setNotifications()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowDetail" {
            let destination = segue.destination as! ToDoDetailTableViewController
            let selectedIndexPath = tableView.indexPathForSelectedRow!
            destination.toDoItem = toDoItems[selectedIndexPath.row]
        } else {
            if let selectedIndexPath = tableView.indexPathForSelectedRow {
                tableView.deselectRow(at: selectedIndexPath, animated: true)
            }
        }
    }
    
    @IBAction func unwindFromDetail(segue: UIStoryboardSegue) {
        let source = segue.source as! ToDoDetailTableViewController
        
        if let selectedIndexPath = tableView.indexPathForSelectedRow {
            toDoItems[selectedIndexPath.row] = source.toDoItem
            tableView.reloadRows(at: [selectedIndexPath], with: .automatic)
        } else {
            let newIndexPath = IndexPath(row: toDoItems.count, section: 0)
            toDoItems.append(source.toDoItem)
            tableView.insertRows(at: [newIndexPath], with: .bottom)
            tableView.scrollToRow(at: newIndexPath, at: .bottom, animated: true)
        }
        saveData()
    }
    
    @IBAction func editButtonPress(_ sender: UIBarButtonItem) {
        if tableView.isEditing {
            tableView.setEditing(false, animated: true)
            sender.title = "Edit"
            addBarButton.isEnabled = true
        } else {
            tableView.setEditing(true, animated: true)
            sender.title = "Done"
            addBarButton.isEnabled = false
        }
    }
    
}

extension ToDoListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("numberOfRowsInSection was just call")
        
        return toDoItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        print("cellForRowAt was just called for indePath.row = \(indexPath.row)")
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = toDoItems[indexPath.row].name
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            toDoItems.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            saveData()
        }
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let itemToMove = toDoItems[sourceIndexPath.row]
        toDoItems.remove(at: sourceIndexPath.row)
        toDoItems.insert(itemToMove, at: destinationIndexPath.row)
        saveData()
    }
}

