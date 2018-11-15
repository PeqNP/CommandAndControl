import Foundation

struct PDPState {
    let productID: ProductID
    let productName: String
    let price: NormalPrice
    let skus: [SKU]
    
    // Mutable
    let amountToAddToBag: Int
    let addToBagState: AddToBagState
    let selectedColor: SKUColor?
    let selectedSize: SKUSize?
    let selectedSKU: SKU?
    
    func make(amountToAddToBag: Int? = nil, addToBagState: AddToBagState? = nil, selectedColor: Mutable<SKUColor> = .nil, selectedSize: Mutable<SKUSize> = .nil, selectedSKU: Mutable<SKU> = .nil) -> PDPState {
        return PDPState(
            productID: productID,
            productName: productName,
            price: price,
            skus: skus,
            
            amountToAddToBag: amountToAddToBag ?? self.amountToAddToBag,
            addToBagState: addToBagState ?? self.addToBagState,
            selectedColor: selectedColor.value(from: self.selectedColor),
            selectedSize: selectedSize.value(from: self.selectedSize),
            selectedSKU: selectedSKU.value(from: self.selectedSKU)
        )
    }
}
