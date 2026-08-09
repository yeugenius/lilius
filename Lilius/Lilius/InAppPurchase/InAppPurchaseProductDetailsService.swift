//
//  InAppPurchaseProductDetailsService.swift
//  Lilius
//
//  Created by Satendra Singh on 26/01/25.
//

import Foundation
import StoreKit
import Combine

public typealias ProductsRequestCompletionHandler = (_ success: Bool, _ products: [SKProduct]?) -> Void

final class InAppPurchaseProductDetailsService: NSObject {
        
    private var productsRequest: SKProductsRequest?
    private let productIdentifiers: Set<ProductIdentifier>
    private var productsRequestCompletionHandler: ProductsRequestCompletionHandler?

    public init(productIds: Set<ProductIdentifier>) {
      productIdentifiers = productIds
      super.init()
    }

    public func requestProducts(_ completionHandler: @escaping ProductsRequestCompletionHandler) {
      productsRequest?.cancel()
      productsRequestCompletionHandler = completionHandler

      productsRequest = SKProductsRequest(productIdentifiers: productIdentifiers)
      productsRequest!.delegate = self
      productsRequest!.start()
    }
    
    public class func canMakePayments() -> Bool {
        return SKPaymentQueue.canMakePayments()
    }
}

extension InAppPurchaseProductDetailsService: SKProductsRequestDelegate {
    
    public func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
      print("Loaded list of products...")
      let products = response.products

      productsRequestCompletionHandler?(true, products)

      for p in products {
        print("Found product: \(p.productIdentifier) \(p.localizedTitle) \(p.price.floatValue)")
      }
    }

    public func request(_ request: SKRequest, didFailWithError error: Error) {
      print("Failed to load list of products.")
      print("Error: \(error.localizedDescription)")
      productsRequestCompletionHandler?(false, nil)
//        productUpdateSubject.send(completion: .failure(error))
      clearRequestAndHandler()
    }
    
    func requestDidFinish(_ request: SKRequest) {
//        productUpdateSubject.send(completion: .finished)
        clearRequestAndHandler()
    }

    private func clearRequestAndHandler() {
        productsRequest = nil
        productsRequestCompletionHandler = nil
    }
  }
