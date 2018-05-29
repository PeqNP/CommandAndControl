/**
 Copyright © 2018 Upstart Illustration LLC. All rights reserved.
 */

import Foundation

enum Price {
    case regular(Double)
    case sale(was: Double, now: Double)
}

enum NormalPrice {
    case single(Price)
    case range(from: Price, to: Price)
}

struct Product {
    let id: ProductID
    let name: String
    let price: NormalPrice
    let skus: [SKU]
}

struct SKUColor {
    let name: String
    let imageURL: URL?
}

struct SKUSize {
    let name: String
    let metaDescription: String
}

struct SKU {
    let id: SKUID
    let color: SKUColor
    let size: SKUSize
    let price: Price
}
