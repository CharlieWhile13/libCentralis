//
//  EduLink_Catering.swift
//  Centralis
//
//  Created by [redacted] on 02/12/2020.
//

import Foundation

public class EduLink_Catering {
    class public func catering(_ rootCompletion: @escaping completionHandler) {
        let url = URL(string: "\(EduLinkAPI.shared.authorisedSchool.server!)?method=EduLink.Catering")!
        let headers: [String : String] = ["Content-Type" : "application/json;charset=utf-8"]
        let body = "{\"jsonrpc\":\"2.0\",\"method\":\"EduLink.Catering\",\"params\":{\"last_visible\":0,\"authtoken\":\"\(EduLinkAPI.shared.authorisedUser.authToken!)\"},\"uuid\":\"\(UUID.shared.uuid)\",\"id\":\"1\"}"
        NetworkManager.requestWithDict(url: url, method: "POST", headers: headers, jsonbody: body, completion: { (success, dict) -> Void in
            if !success { return rootCompletion(false, "Network Error") }
            guard let result = dict["result"] as? [String : Any] else { return rootCompletion(false, "Unknown Error") }
            if !(result["success"] as? Bool ?? false) { return rootCompletion(false, (result["error"] as? String ?? "Unknown Error")) }
            EduLinkAPI.shared.catering.balance = result["balance"] as? Double ?? 0.0
            EduLinkAPI.shared.catering.transactions.removeAll()
            if let transactions = result["transactions"] as? [[String : Any]] {
                for transaction in transactions {
                    var cateringTransaction = CateringTransaction()
                    cateringTransaction.id = "\(transaction["id"] ?? "Not Given")"
                    cateringTransaction.date = transaction["date"] as? String ?? "Not Given"
                    let items = transaction["items"] as? [[String : Any]] ?? [[String : Any]]()
                    for item in items {
                        var cateringItem = CateringItem()
                        cateringItem.item = item["item"] as? String ?? "Not Given"
                        cateringItem.price = item["price"] as? Double ?? 0.0
                        cateringTransaction.items.append(cateringItem)
                    }
                    EduLinkAPI.shared.catering.transactions.append(cateringTransaction)
                }
            }
            return rootCompletion(true, nil)
        })
    }
}

public struct CateringTransaction {
    public var id: String!
    public var date: String!
    public var items = [CateringItem]()
}

public struct CateringItem {
    public var item: String!
    public var price: Double!
}

public struct Catering {
    public var balance: Double!
    public var transactions = [CateringTransaction]()
}
