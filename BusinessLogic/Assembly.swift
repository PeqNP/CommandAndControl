/**
 
 Copyright © 2018 Upstart Illustration LLC. All rights reserved.
 */

import Foundation
import Swinject
import SwinjectStoryboard

class Assembly {
    
    let container: Container = SwinjectStoryboard.defaultContainer
    
    init() {
        container.register(PDPCommandAndControl.self) { _ in
            let processQueue = DispatchQueue.main
            let bagService = BagService()
            let shippingService = ShippingService()
            let logicFactory = PDPBusinessLogicFactory()
            let viewStateFactory = PDPViewStateFactory()
            
            return PDPCommandAndControl(
                processQueue: processQueue,
                bagService: bagService,
                shippingService: shippingService,
                logicFactory: logicFactory,
                viewStateFactory: viewStateFactory
            )
        }
        
        container.storyboardInitCompleted(ViewController.self) { resolver, controller in
            let control = resolver.resolve(PDPCommandAndControl.self)!
            
            controller.inject(control: control)
        }
    }
}
