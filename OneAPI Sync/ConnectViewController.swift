/*
* Copyright (c) Microsoft. All rights reserved. Licensed under the MIT license.
* See LICENSE in the project root for license information.
*/

import UIKit

/**
 ConnectViewController is responsible for authenticating the user.
 Upon success, open SendMailViewController using predefined segue.
 Otherwise, show an error.
 
 In this sample a user-invoked cancellation is considered an error.
 */
class ConnectViewController: UIViewController {
    
    // Outlets
    @IBOutlet var connectButton: UIButton!
    
    // Actions
    @IBAction func connect(sender: AnyObject) {
            
        AuthenticationManager.sharedInstance?.acquireAuthToken ({
            (result: AuthenticationResult) -> Void in
            
            switch result {
            case .Success:
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    print(AuthenticationManager.sharedInstance?.accessToken)
                    
                    self.performSegueWithIdentifier("loadAppFolder", sender: self)
                })
                
            case .Failure(let error):
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    let alertController = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .Alert)
                    alertController.addAction(UIAlertAction(title: "Close", style: .Cancel, handler: nil))
                    self.presentViewController(alertController, animated: true, completion: nil)
                })
            }
        })
    }
    
    // Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "loadAppFolder" {
            // place holder for extra stuff
        }
    }
    
}

