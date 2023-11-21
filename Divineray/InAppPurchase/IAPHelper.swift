
import StoreKit

public typealias ProductIdentifier = String
public typealias ProductsRequestCompletionHandler = (_ success: Bool, _ products: [SKProduct]?) -> ()

open class IAPHelper : NSObject  {
  
  static let IAPHelperPurchaseNotification = "IAPHelperPurchaseNotification"
  fileprivate let productIdentifiers: Set<ProductIdentifier>
  fileprivate var purchasedProductIdentifiers = Set<ProductIdentifier>()
  fileprivate var productsRequest: SKProductsRequest?
  fileprivate var productsRequestCompletionHandler: ProductsRequestCompletionHandler?

  public init(productIds: Set<ProductIdentifier>) {
    productIdentifiers = productIds
    for productIdentifier in productIds {
      let purchased = UserDefaults.standard.bool(forKey: productIdentifier)
      if purchased {
        purchasedProductIdentifiers.insert(productIdentifier)
        print("Previously purchased: \(productIdentifier)")
      } else {
        print("Not purchased: \(productIdentifier)")
      }
    }
    super.init()
    SKPaymentQueue.default().add(self)
  }
  
}

// MARK: - StoreKit API

extension IAPHelper {

  public func requestProducts(completionHandler: @escaping ProductsRequestCompletionHandler) {
    productsRequest?.cancel()
    productsRequestCompletionHandler = completionHandler

    productsRequest = SKProductsRequest(productIdentifiers: productIdentifiers)
    productsRequest!.delegate = self
    productsRequest!.start()
  }

  public func buyProduct(_ product: SKProduct) {
    print("Buying \(product.productIdentifier)...")
    let payment = SKPayment(product: product)
    SKPaymentQueue.default().add(payment)
  }

  public func isProductPurchased(_ productIdentifier: ProductIdentifier) -> Bool {
    return purchasedProductIdentifiers.contains(productIdentifier)
  }
  
  public class func canMakePayments() -> Bool {
    return SKPaymentQueue.canMakePayments()
  }
  
  public func restorePurchases() {
    SKPaymentQueue.default().restoreCompletedTransactions()
  }
}

// MARK: - SKProductsRequestDelegate

extension IAPHelper: SKProductsRequestDelegate {

  public func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
    let products = response.products
    print("Loaded list of products...")
    productsRequestCompletionHandler?(true, products)
    clearRequestAndHandler()

    for p in products {
      print("Found product: \(p.productIdentifier) \(p.localizedTitle) \(p.price.floatValue)")
    }
  }
  
  public func request(_ request: SKRequest, didFailWithError error: Error) {
    print("Failed to load list of products.")
    print("Error: \(error.localizedDescription)")
    productsRequestCompletionHandler?(false, nil)
    clearRequestAndHandler()
  }

  private func clearRequestAndHandler() {
    productsRequest = nil
    productsRequestCompletionHandler = nil
  }
}

// MARK: - SKPaymentTransactionObserver
 
extension IAPHelper: SKPaymentTransactionObserver {
 
  public func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
    for transaction in transactions {
      switch (transaction.transactionState) {
      case .purchased:
        complete(transaction: transaction)
        break
      case .failed:
        fail(transaction: transaction)
        break
      case .restored:
        restore(transaction: transaction)
        break
      case .deferred:
        break
      case .purchasing:
        break
      }
    }
  }
 
  private func complete(transaction: SKPaymentTransaction) {
    print("complete...")
    if ("com.signid.keyboard.basicsubscription2" == transaction.payment.productIdentifier)
    {
    SKPaymentQueue.default().finishTransaction(transaction)
     UserDefaults.standard.set(transaction.transactionDate, forKey: "BasicTransactionDate")
        print("BasicTransactionDate")
        print(transaction.transactionState)

        print(UserDefaults.standard.object(forKey: "BasicTransactionDate")!)
        deliverPurchaseNotificationFor(identifier: transaction.payment.productIdentifier)

    }
  }
 
  private func restore(transaction: SKPaymentTransaction) {
    
    guard let productIdentifier = transaction.original?.payment.productIdentifier else { return }
    if ("com.signid.keyboard.basicsubscription2" == productIdentifier)
    {
    print("restore... \(productIdentifier)")
//    deliverPurchaseNotificationFor(identifier: productIdentifier)
//    SKPaymentQueue.default().finishTransaction(transaction)
//    UserDefaults.standard.set(transaction.transactionDate, forKey: "BasicTransactionDate")

    self.complete(transaction: transaction)
    }
  }
 
  private func fail(transaction: SKPaymentTransaction) {
    print("fail...")
    print(transaction.error)

    if let transactionError = transaction.error as NSError? {
      if transactionError.code != SKError.paymentCancelled.rawValue
      {
        let errorDict:[String:String] = ["error":transactionError.localizedDescription];
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: IAPHelper.IAPHelperPurchaseNotification), object: errorDict)

      }else
      {
        let errorDict:[String:String] = ["error":"Cancel"];
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: IAPHelper.IAPHelperPurchaseNotification), object: errorDict)

        }
        
    }
 
    SKPaymentQueue.default().finishTransaction(transaction)
  }
 
  private func deliverPurchaseNotificationFor(identifier: String?) {
    guard let identifier = identifier else { return }
 
    purchasedProductIdentifiers.insert(identifier)
   
    if (UserDefaults.standard.object(forKey: "com.signid.keyboard.basicsubscription2") != nil)
    {
        let infoDict:[String:String] = ["identifier":identifier,"showPopUp":"Already"];
        UserDefaults.standard.set(true, forKey: identifier)
        let userDef = UserDefaults(suiteName: "group.keyboard.AbhishekT")!
        userDef.setValue(true, forKey: identifier)
        userDef.synchronize()
        UserDefaults.standard.synchronize()
    NotificationCenter.default.post(name: NSNotification.Name(rawValue: IAPHelper.IAPHelperPurchaseNotification), object: infoDict)
    }else
    {
        let infoDict:[String:String] = ["identifier":identifier,"showPopUp":"FirstTime"];
        UserDefaults.standard.set(true, forKey: identifier)
        let userDef = UserDefaults(suiteName: "group.keyboard.AbhishekT")!
        userDef.setValue(true, forKey: identifier)
        userDef.synchronize()
        UserDefaults.standard.synchronize()
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: IAPHelper.IAPHelperPurchaseNotification), object: infoDict)
    }
    
   
  }
}
