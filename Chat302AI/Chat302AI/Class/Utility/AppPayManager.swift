


import UIKit
import StoreKit

class AppPayManager: NSObject {
    
    var proId: String!
    
    // 沙盒验证地址
    let url_receipt_sandbox = "https://sandbox.itunes.apple.com/verifyReceipt"
    // 生产环境验证地址
    let url_receipt_itunes = "https://buy.itunes.apple.com/verifyReceipt"

    // 21008表示生产换使用  21007表示测试环境使用
    var state = 21008
    
    let verify_type = 0

    var resultBlock: (_ result: String)->Void = { (_ result: String)->Void in }
    
    static var shared: AppPayManager = AppPayManager()
    
    private override init() {
        
    }
    override class func copy() -> Any {
        return self
    }
    
}

extension AppPayManager: SKPaymentTransactionObserver {
    //MARK: 发起购买请求 实现发起购买请求，参数一商品id，参数2回调逃逸闭包(商品id，也就是在开发者网站添加商品的id，在这里可以先提供一个com.saixin.eduline6)
    func startPay(proId: String, resultBlock: @escaping ((_ result: String) -> Void)) {
        self.resultBlock = resultBlock
        if !SKPaymentQueue.canMakePayments() {
            print("不可使用苹果支付")
            return
        }
        //监听购买结果
        SKPaymentQueue.default().add(self)
        self.proId = proId
        let set = Set.init([proId])
        let requst = SKProductsRequest.init(productIdentifiers: set)
        requst.delegate = self
        requst.start()
    }
}

extension AppPayManager: SKProductsRequestDelegate {
    //MARK: 发起购买请求回调代理方法
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        let productArray = response.products
        if productArray.count == 0 {
            print("此商品id没有对应的商品")
            return
        }
        var product: SKProduct!
        for pro in productArray {
            if pro.productIdentifier == proId {
                product = pro
                break
            }
        }
        print("productsRequest didReceive:\(product.description)")
        print("productsRequest didReceive:\(product.localizedTitle)")
        print("productsRequest didReceive:\(product.localizedDescription)")
        print("productsRequest didReceive:\(product.price)")
        print("productsRequest didReceive:\(product.productIdentifier)")
        
        let payment = SKMutablePayment.init(product: product)
        payment.quantity = 1
        SKPaymentQueue.default().add(payment)
    }

    //MARK: 购买结果 监听回调
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for tran in transactions {
            switch tran.transactionState {
            case .purchased: //购买完成
                SKPaymentQueue.default().finishTransaction(tran)
                completePay(transaction: tran)
                break
            case.purchasing: //商品添加进列表
                break
            case.restored: //已经购买过该商品
                SKPaymentQueue.default().finishTransaction(tran)
                break
            case.failed: //购买失败
                //
                //SVProgressHUD.showInfo(withStatus: NSLocalizedString("购买取消", comment: ""))
                NotificationCenter.default.post(name: .rechargeCancelled , object: nil)
                
                SKPaymentQueue.default().finishTransaction(tran)
                break
            default:
                break
            }
        }
    }

    //MARK: 购买成功验证凭证
    func completePay(transaction: SKPaymentTransaction) {
        //获取交易凭证
        let recepitUrl = Bundle.main.appStoreReceiptURL
        let data = try! Data.init(contentsOf: recepitUrl!)
        if recepitUrl == nil {
            self.resultBlock("交易凭证为空")
            print("交易凭证为空")
            return
        }
        
        if verify_type == 0 {//客户端验证
            verify(data: data, transaction: transaction)
        }else{//服务器端校验
            
        }
        //注销交易
        SKPaymentQueue.default().finishTransaction(transaction)
    }

    //MARK: 客户端验证
    func verify(data: Data, transaction: SKPaymentTransaction)  { 
        let base64Str = data.base64EncodedString(options: .endLineWithLineFeed)
        let params = NSMutableDictionary()
        params["receipt-data"] = base64Str
        
        
        // 打印参数
        print("请求参数: \(params)")
        
        let body = try! JSONSerialization.data(withJSONObject: params, options: .prettyPrinted)
        
        // 打印请求体内容（可选）
        if let bodyString = String(data: body, encoding: .utf8) {
            print("请求体内容: \(bodyString)")
        }
        
        let urlString = state == 21008 ? url_receipt_itunes : url_receipt_sandbox
        print("请求URL: \(urlString)")
        
        var request = URLRequest.init(url: URL.init(string: urlString)!, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 20)
        request.httpMethod = "POST"
        request.httpBody = body
        
        // 打印请求头信息
        print("HTTP方法: \(request.httpMethod ?? "")")
        print("超时时间: \(request.timeoutInterval)秒")
        
        
        //let body = try! JSONSerialization.data(withJSONObject: params, options: .prettyPrinted)
        //var request = URLRequest.init(url: URL.init(string: state == 21008 ? url_receipt_itunes: url_receipt_sandbox)!, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 20)
        request.httpMethod = "POST"
        request.httpBody = body
        let session = URLSession.shared
        let task = session.dataTask(with: request) { (data, response, error) in
            
            if let error = error {
                print("请求错误: \(error.localizedDescription)")
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                print("响应状态码: \(httpResponse.statusCode)")
            }
            
            guard let data = data else {
                print("没有返回数据")
                return
            }
            
            
            
            let dict = try! JSONSerialization.jsonObject(with: data, options: .mutableContainers) as! NSDictionary
            print("客户端验证 verify(data: \(dict)")
            SKPaymentQueue.default().finishTransaction(transaction)
            let status = dict["status"] as! Int
            switch(status){
            case 0:
                //通知服务端
                self.checkTransaction(transactionReceiptURL: base64Str)
                self.resultBlock("购买成功")
                break
            case 21007:
                self.state = 21007
                self.verify(data: data, transaction: transaction)
                break
            default:
                //SVProgressHUD.showInfo(withStatus: "\(dict)")
                self.resultBlock("验证失败")
                break
            }
            //移除监听
            SKPaymentQueue.default().remove(self)
        }
        task.resume()
    }
    
    
    // api/apple/webhook
    func checkTransaction(transactionReceiptURL: String){
        
        
        //let url = "https://api.302.ai/v1/api/apple/webhook"
        //let params = ["data":transactionReceiptURL,"uid":AppConfiguration.shared.uid] as [String : Any]
        
        UserDefaults.standard.set(transactionReceiptURL, forKey: "transactionReceiptURL")
        UserDefaults.standard.synchronize()
        
        let uid = "\(AppConfiguration.shared.uid)"
        
        NetworkManager.shared.sendRecordRechargeRequest(data: transactionReceiptURL, uid: uid) { result in
            
            
            switch result {
            case .success(let response):
                if response.code == 0 {
                      
                    NotificationCenter.default.post(name: .rechargeSuccess , object: nil)
                    //SVProgressHUD.showSuccess(withStatus: NSLocalizedString("购买成功", comment: ""))
                    
                    //充值成功
                    UserDefaults.standard.setValue(true, forKey: "chargeSuccess")
                    UserDefaults.standard.synchronize()
                } else {
                    //充值失败
                    UserDefaults.standard.setValue(false, forKey: "chargeSuccess")
                    UserDefaults.standard.synchronize()
                    
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 5, execute: {
                        NotificationCenter.default.post(name: .rechargeFailed  , object: nil)
                        self.checkTransaction(transactionReceiptURL: transactionReceiptURL)
                    })
                    
                }
            case .failure(let error):
                print("充值失败")
            }
            
             
        }
        
         

        
    }
    
    
    
}






