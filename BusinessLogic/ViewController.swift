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
        case .showLoadingIndicator:
            // Show loading indicator
            return
        case .hideLoadingIndicator:
            // Hide loading indicator
            return
        case .update(let viewState):
            // Update the view
            return
        case .showShippingInfo(let viewState):
            // Show the shipping information for a SKU
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
        case .showError(let error):
            // Display error
            return
        }
    }
}

