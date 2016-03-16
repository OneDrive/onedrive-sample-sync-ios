/*
* Copyright (c) Microsoft. All rights reserved. Licensed under the MIT license.
* See LICENSE in the project root for license information.
*/

import UIKit

class SyncViewContrller: UITableViewController {
    
    let oneDriveManager: OneDriveManager = OneDriveManager()
    let persistentStore: PersistentStore = PersistentStore()
    
    var createTextField: UITextField!
    
    var appFolderId: String?  // This is not static by design
    
    
    override func viewDidLoad(){
        super.viewDidLoad()
        
        self.navigationItem.hidesBackButton = true

        self.refreshControl?.addTarget(self, action: "syncFolder:", forControlEvents: UIControlEvents.ValueChanged)
        
        retrieveAppFolder()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setToolbarHidden(false, animated: true)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.reload()
    }
    
    // MARK: Button actions
    @IBAction func disconnect(sender: AnyObject) {
        let alertController = UIAlertController(title: "Disconnect", message: "Do you want to sign out?", preferredStyle: .Alert)
        alertController.addAction(UIAlertAction(title: "No", style: .Cancel, handler: nil))
        alertController.addAction(UIAlertAction(title: "Yes", style: .Destructive, handler: {
            (action) -> Void in
            
            AuthenticationManager.sharedInstance?.clearCredentials()
            self.persistentStore.resetStorage()
            self.persistentStore.saveFileRecordChanges()
            self.navigationController!.popViewControllerAnimated(true)
        }))
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    @IBAction func addNewItem(sender: AnyObject) {
        let alertController = UIAlertController(title: "Create an item", message: "Select an item type", preferredStyle: .ActionSheet)
        alertController.addAction(UIAlertAction(title: "File", style: UIAlertActionStyle.Default, handler: { (action: UIAlertAction) -> Void in
            self.askCreateFile()
        }))
        alertController.addAction(UIAlertAction(title: "Folder", style: UIAlertActionStyle.Default, handler: { (action: UIAlertAction) -> Void in
            self.askCreateFolder()
        }))
        alertController.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil))
        
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    
    @IBAction func resetState(sender: AnyObject) {
        let alertController = UIAlertController(title: "Refresh", message: "This will reset tokens and reload folder. Do you want to continue?", preferredStyle: .Alert)
        alertController.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
        alertController.addAction(UIAlertAction(title: "Yes", style: .Default, handler: { (action: UIAlertAction) -> Void in
            self.resetState()
        }))
        presentViewController(alertController, animated: true, completion: nil)
    }
    
    
    @IBAction func refresh(sender: AnyObject) {
        self.reload()
    }
    
    // MARK: Functions

    func retrieveAppFolder() {
        AuthenticationManager.sharedInstance!.acquireAuthToken {
            (result: AuthenticationResult) -> Void in
            
            switch result {
                
            case .Success:
                self.oneDriveManager.getAppFolderId({ (result: OneDriveManagerResult, appFolderId) -> Void in
                    switch(result) {
                    case .Success:
                        self.appFolderId = appFolderId
                        
                    case .Failure(let error):
                        print("\(error)")
                        let alertController = UIAlertController(title: "Error", message: "Error retrieving app folder. Check log for more details", preferredStyle: .Alert)
                        alertController.addAction(UIAlertAction(title: "Close", style: .Destructive, handler:nil))
                        self.presentViewController(alertController, animated: true, completion: nil)
                    }
                })
                
            case .Failure(let error):
                // Upon failure, alert and go back.
                print(error)
                
                let alertController = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .Alert)
                alertController.addAction(UIAlertAction(title: "Close", style: .Destructive, handler: {
                    (action) -> Void in
                    AuthenticationManager.sharedInstance?.clearCredentials()
                    self.navigationController!.popViewControllerAnimated(true)
                }))
                self.presentViewController(alertController, animated: true, completion: nil)
            }
        }
    }
    
    
    func reload() {
        self.setIsInProgress(true)
        
        let refreshControlHeight: CGFloat = (self.refreshControl?.frame.size.height)!
        
        self.tableView.setContentOffset(CGPointMake(0, -self.topLayoutGuide.length - refreshControlHeight), animated: true)

        let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(1 * Double(NSEC_PER_SEC)))
            dispatch_after(delayTime, dispatch_get_main_queue()) {
            self.refreshControl?.sendActionsForControlEvents(.ValueChanged)
        }
    }
    

    func resetState() {
        self.persistentStore.resetStorage()
        self.persistentStore.saveFileRecordChanges()

        self.tableView.reloadData()
        
        self.reload()
    }
    
    func syncFolder(refreshControl: UIRefreshControl) {
        // Do some reloading of data and update the table view's data source
        // Fetch more objects from a web service, for example...
        
        self.setIsInProgress(true)
        
        AuthenticationManager.sharedInstance!.acquireAuthToken {
            (result: AuthenticationResult) -> Void in
            
            switch result {
                
            case .Success:
                
                self.oneDriveManager.syncUsingViewDelta(syncToken: self.persistentStore.syncToken) {
                    (result: OneDriveManagerResult, newToken:String?, deltaItems: [DeltaItem]?) -> Void in
                    
                    switch(result) {
                    case .Success:
                        self.persistentStore.processDeltaArrayForFoldeWithId(self.appFolderId!, items: deltaItems)
                        self.persistentStore.saveFileRecordChanges()
                        
                        self.persistentStore.syncToken = newToken
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            refreshControl.attributedTitle = NSAttributedString(string: "Synced")
                            self.setIsInProgress(false)
                            self.tableView.reloadData()
                        })
                        
                    case .Failure(let error):
                        print("Error \(error)")
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            refreshControl.attributedTitle = NSAttributedString(string: "Sync Failed")
                            self.setIsInProgress(false)
                            self.tableView.reloadData()
                        })
                    }
                    print("DONE")
                }
                
                
                
            case .Failure(let error):
                // Upon failure, alert and go back.
                print(error)
                
                let alertController = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .Alert)
                alertController.addAction(UIAlertAction(title: "Close", style: .Destructive, handler: {
                    (action) -> Void in

                    refreshControl.attributedTitle = NSAttributedString(string: "Sync Failed")
                    self.setIsInProgress(false)
                    
                    //                    AuthenticationManager.sharedInstance?.clearCredentials()
                    //                    self.navigationController!.popViewControllerAnimated(true)
                }))
                
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.presentViewController(alertController, animated: true, completion: nil)
                })
            }
        }
    }
    
 
    func askCreateFile() {
        let alertController = UIAlertController(title: "Create text file", message: "This file will be created in the app folder.", preferredStyle: .Alert)
        alertController.addTextFieldWithConfigurationHandler({ (textField) -> Void in
            textField.placeholder = "Enter a file name"
        })
        alertController.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
        alertController.addAction(UIAlertAction(title: "Enter", style: .Default, handler: { (action) -> Void in
            
            if let textField = alertController.textFields {
                if let text = textField[0].text {
                        self.createTextFile(text)
                }
            }
        }))
        
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    func askCreateFolder() {
        let alertController = UIAlertController(title: "Create folder", message: "This folder will be created in the app folder.", preferredStyle: .Alert)
        alertController.addTextFieldWithConfigurationHandler({ (textField) -> Void in
            textField.placeholder = "Enter a folder name"
        })
        alertController.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
        alertController.addAction(UIAlertAction(title: "Enter", style: .Default, handler: { (action) -> Void in
            
            if let textField = alertController.textFields {
                if let text = textField[0].text {
                    self.createFolder(text)
                }
            }
        }))
        
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    func createTextFile(fileName: String) {
        
        setIsInProgress(true)
        
        self.oneDriveManager.createTextFile(fileName, folderId: self.appFolderId!) {
            (result: OneDriveManagerResult) -> Void in
            
            self.syncFolder(self.refreshControl!)
        }
    }
    
    func createFolder(folderName: String) {
        setIsInProgress(true)
        
        self.oneDriveManager.createFolder(folderName, folderId: self.appFolderId!) { (result) -> Void in
            self.syncFolder(self.refreshControl!)
        }
    }
    
    
    // MARK: Helper functions
    func setIsInProgress(inProgress: Bool) {
        if inProgress == true {
            self.navigationItem.prompt = "In Progress"
            self.refreshControl?.attributedTitle = NSAttributedString(string: "Syncing")
            self.refreshControl?.beginRefreshing()
        }
        else {
            self.navigationItem.prompt = "Sync Complete"
            self.refreshControl?.attributedTitle = NSAttributedString(string: "Sync Complete")
            self.refreshControl?.endRefreshing()
        }
    }
    
    
    // MARK: TableView related
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.persistentStore.fileRecords.count;
    }
    
 
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell:UITableViewCell = tableView.dequeueReusableCellWithIdentifier("contentCell", forIndexPath: indexPath)
        
        let fileRecord = self.persistentStore.fileRecords[indexPath.row]
        
        let fileType: String
        if fileRecord.isFolder == true {
            fileType = "(folder)"
        }
        else {
            fileType = "(file)"
        }
        
        cell.textLabel!.text = "\(fileRecord.fileName)  \(fileType)"
        cell.detailTextLabel!.text = "Last modified: \(fileRecord.dateModified)"
        
        if fileRecord.isNew {
            cell.accessoryType = .Checkmark
        }
        else {
            cell.accessoryType = .None
        }
        
        return cell
    }
    

}
