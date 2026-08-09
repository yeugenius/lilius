//
//  PurchasableProducts.swift
//  Lilius
//
//  Created by Satendra Singh on 26/01/25.
//


/*
 satendra.lillius@gmail.com Sattu123#
 satendra.four@gmail.com Sattu123*
 satendra.techmac+one@gmail.com Sattu123*
 */
struct PurchasableProducts {
    static let monthly = "ca.overmorrow.lilius.premium.subscription1"
    static let yearly = "ca.overmorrow.lilius.premium.yearly"
    static let test = "ca.overmorrow.lilius.premium.subscription.test"
    static var allProducts = Set(arrayLiteral: PurchasableProducts.monthly, PurchasableProducts.yearly)
}
