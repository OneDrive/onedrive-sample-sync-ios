/*
* Copyright (c) Microsoft. All rights reserved. Licensed under the MIT license.
* See LICENSE in the project root for license information.
*/

import UIKit

class CreateCell: UITableViewCell {
    
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    @IBOutlet var label: UILabel!
 
    func setInProgress(isInProgress: Bool, labelText: String?) {
        if isInProgress == true {
            activityIndicator.startAnimating()
            label.hidden = true
        }
        else {
            activityIndicator.stopAnimating()
            label.hidden = false
            label.text = labelText
        }
    }
    
    var isInProgress: Bool {
        get {
            return activityIndicator.isAnimating()
        }
    }
    
}
