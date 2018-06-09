# StoreKit

- Handle One time purchase
- Subscriptions
- Subscription Retry (for failed transactions)
- Status Update (server to server notification)
- Offer Introductory pricing
- Restoring purchased products
- Upgrades/downgrades and Plan Changes
- Handle product price increases
- Handle cancellations
- Test your prices for your products

[Receipt Fields](https://developer.apple.com/library/archive/releasenotes/General/ValidateAppStoreReceipt/Chapters/ReceiptFields.html#//apple_ref/doc/uid/TP40010573-CH106-SW25)
[About Receipt Validation](https://developer.apple.com/library/archive/releasenotes/General/ValidateAppStoreReceipt/Introduction.html#//apple_ref/doc/uid/TP40010573-CH105-SW1)

[Offering Introductory Pricing in Your App | Apple Developer Documentation](https://developer.apple.com/documentation/storekit/in_app_purchase/offering_introductory_pricing_in_your_app)
[About In-App Purchase](https://developer.apple.com/library/archive/documentation/NetworkingInternet/Conceptual/StoreKitGuide/Introduction.html#//apple_ref/doc/uid/TP40008267)


Pricing Model (per month per user*)
==========================================
0 - 100 users free     User will earning @ $1 purchase price $100
101 - 1000 : 0.01 per user ($9) 
1001 - 10,000: 0.02 per user ($180)
10,001 and above: 0.03 per user ()

 *only for users who made a purchase
					             (per month)
| Number of Users   | $ developer makes @ $1 purchase price | $ we make |
| —————————————   | ——————————————————————————————-| ———————-—|
|  0 - 100                     |                           $100                                      |         $0        |
|  101 - 1000              |                           $900                                      |          $9       |
| 1001 - 10,000         |                          $9000                                     |      $180      |
| 10,001 - 50,000      |                          $40,000                                 |      $1200    |         
|
|



API                          												
			-
```
POST /uploadReceipt

Request:

Headers:
UserAgent: iPhone
APIKey: WECEEWE345FRXCDE123FGTR
Body:
{
  "user-id": "iercq1234cfewewdgrd", //optional
  "data": receipt-as-binary-data
}


Respose:
Set-Cookie: "uid: iercq1234cfewewdgrd expiryTime=<toBeDetermined>"

2xx - Success
4xx - Bad Request
5xx - Server Error
```

```
GET /productsStatus

Request:

Headers:
UserAgent: iPhone
APIKey: WECEEWE345FRXCDE123FGTR


Respose:
{
  "_embedded": { //mandatory
     "products": { // mandatory, [] if the products array is empty
			[
				{
					"id": "prod-123",
					"status": "active"
				},
				{
					"id": "prod-234",
					"status": "inactive"
				},
				{
					"id": "prod-345",
					"status": "active"
				}
			]
     }
  }
}


2xx - Success
4xx - Bad Request
5xx - Server Error

```

User App in their AppDelegate hold an Instance of PurchaseManager
```
let purchaseManager = PurchaseManager.sharedInstance().configure(userId: “iercq1234cfewewdgrd”)
```


iOS SDK API

// Initial configuration and receipt upload
	-  `func static sharedInstance()` // Call uploadReceipt
	- `func configure(with userId: String?)`  // Upload receipt
	- `private uploadReceipt()` // Reads the receipt from StoreKit and upload to server. On the server checks if this copy of the receipt is latest to the server copy and then discards or replaces accordingly

// Fetching all products	
	- `func productsStatus()` // Calls fetchProducts. Developers should rely on didUpdateProductsStatus delegate method.
	-` private fetchProducts() -> [Products]`  // On completion calls the delegate method didUpdateProductsStatus(products: [Products])

// One time purchase or subscription purchase
	- `func purchase(product: Product)` // purchaseProductUsingStoreKit
	- `private func purchaseProductUsingStoreKit(product: SKProduct)`

extension PurchaseManager: SKTransactionObserver {
     `func updateTransaction` // delegate method. Calls didUpdateProductsStatus 
}

Products
	- Download content


PurchaseManagerDelegate Protocol
// Update the developer about any changes to user products
	- func didUpdateProductsStatus(products: [Products])  // Websocket
	- 




iOS plist file
=========
API Key



Different Scenarios
==============
1. One time purchase
2. Subscriptions
3. Cancellations/ Upgrades/Downgrades through App Store Customer Care
4. Expiring soon
5. Restore purchases/subscriptions
6. Grace periods.

Decisions
========
- Is the interactions between developer’s app and our SDK is through SKProduct ?
- How do we implement Websockts to update the developer about the server notifications ?

