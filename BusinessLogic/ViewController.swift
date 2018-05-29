/**
 Copyright © 2018 Upstart Illustration LLC. All rights reserved.
 */

import UIKit

class ViewController: UIViewController {

    private var control: PDPCommandAndControl!
    
    func inject(control: PDPCommandAndControl) {
        self.control = control
        
        control.delegate = self
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

extension ViewController: PDPCommandAndControlDelegate {
    
    func command(_ action: PDPCommand) {
        switch action {
        case .updated(let viewState):
            // Update the view
            return
        case .showMoreInfo:
            // Show the 'More Information' dialog
            return
        case .showImageGallery:
            // Show the 'Image Gallery'
            return
        case .routeToPDPFor(let productID):
            // Route to the PDP for `productID`
            return
        }
    }
}

