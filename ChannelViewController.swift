//
//  ChannelViewController.swift
//  KillBallIOS
//
//  Created by 许 振辉 on 2017/9/17.
//  Copyright © 2017年 许 振辉. All rights reserved.
//

import UIKit

//写一个协议，让遵循这个协议的对象实现一个方法能够接收回传的频道id
protocol ChannelProtocol{
    func onChangeChannel(channel_id:String)
}

class ChannelViewController: UIViewController,UITableViewDelegate,UITableViewDataSource{

    //TableView控件、频道列表
    @IBOutlet weak var tv: UITableView!
    //频道列表数据
    var channelData:NSArray = NSArray()
    //遵循ChannelProtocol协议的代理
    var delegate:ChannelProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    //添加tableView的numberOfRowsInSecion方法来返回TableView的数据行数
    func tableView(_ tableView:UITableView,numberOfRowsInSection section:Int) -> Int{
        //        return 10
        return channelData.count
    }
    //设置cell
    //实现tableView的cellForRowAtIndexPath方法
    func tableView(_ tableView:UITableView,cellForRowAt indexPath:IndexPath) -> UITableViewCell{
        //获取标识为 douban 的cell
        let cell = UITableViewCell(style: UITableViewCellStyle.subtitle, reuseIdentifier: "channel")
        //获取cell数据
        let rowData:NSDictionary = self.channelData[indexPath.row] as! NSDictionary
        //设置标题
        cell.textLabel?.text = rowData["name"] as? String
        //返回cell
        return cell
    }
    //设置响应选中cell的方法， didSelectRowAtIndexPath
    func tableView(_ tableView:UITableView,didSelectRowAt indexPath:IndexPath) {
        print("选择了第\(indexPath.row)行")
        var rowData:NSDictionary = self.channelData[indexPath.row] as! NSDictionary
        //获取选择的频道id
        let channel_id:AnyObject? = rowData["channel_id"] as AnyObject?
        //将AnyObject转为string
        let channel:String! = "channel=\(String(describing: channel_id!))"
        print(channel)
        //把频道id传给主界面
        delegate?.onChangeChannel(channel_id: channel)
        
        //关闭当前界面
//        self.dismiss(animated: true,completion: nil)
        self.navigationController?.popViewController(animated: true)
        
    }
    //设置cell显示动画
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        //设置cell的显示动画为3D缩放
        //xy方向的初始值 0.1
        cell.layer.transform = CATransform3DMakeScale(0.1, 0.1, 1)
        //设置动画时间为0.25秒，xy最终为1
        UIView.animate(withDuration: 0.25) {
            cell.layer.transform = CATransform3DMakeScale(1, 1, 1)
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    

}
