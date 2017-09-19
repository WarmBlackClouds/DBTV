//
//  HttpController.swift
//  KillBallIOS
//
//  Created by 许 振辉 on 2017/9/18.
//  Copyright © 2017年 许 振辉. All rights reserved.
//

import UIKit

//定义一个协议httpProtocol，让实现了该协议的对象接收返回的数据
protocol HttpProtocol{
    //定义一个协议httpProtocol，让实现了该协议的对象接收返回的数据
    func didRecieveResults(results:NSDictionary)
}
class HttpController: NSObject {

    //定义一个可选代理
    var delegate:HttpProtocol?
    //定义一个方法运过来获取网络数据，接收参数为网址
    func onSearch(url:String)  {
        //定义NSURL
        let nsUrl:NSURL = NSURL(string: url)!
        //定义NSURLRequest
        let request:URLRequest = URLRequest(url:nsUrl as URL)
        //异步获取数据
        NSURLConnection.sendAsynchronousRequest(request, queue: OperationQueue.main) { (response, data, error) -> Void in
            let jsonResult:NSDictionary = try! JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSDictionary
            
            //将数据传回给代理
            self.delegate?.didRecieveResults(results: jsonResult)
        }
        

    }
}
