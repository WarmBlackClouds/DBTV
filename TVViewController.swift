//
//  TVViewController.swift
//  KillBallIOS
//
//  Created by 许 振辉 on 2017/9/17.
//  Copyright © 2017年 许 振辉. All rights reserved.
//

import UIKit
import MediaPlayer

class TVViewController: UIViewController ,UITableViewDelegate,UITableViewDataSource,ChannelProtocol,HttpProtocol{
    //imageView控件、歌曲封面
    @IBOutlet weak var iv: UIImageView!
    //TableView控件、歌曲列表
    @IBOutlet weak var tv: UITableView!
    //ProgressView控件 播放进度条
    @IBOutlet weak var progressView: UIProgressView!
    //label控件 播放时间
    @IBOutlet weak var playTime: UILabel!
    

    @IBAction func btPlay(_ sender: Any) {
        self.audioPlayer.play()
    }
    @IBAction func btStop(_ sender: Any) {
        self.audioPlayer.pause()
    }
    @IBAction func btBackOut(_ sender: Any) {
        self.audioPlayer.stop()
        self.navigationController?.popViewController(animated: true)
    }
    

    //接收歌曲列表的数组
    var tableData:NSArray = NSArray()
    //接收频道列表的数组
    var channelData:NSArray = NSArray()
    //定义一个HttpController类型的变量用于获取网络数据
    var eHttp:HttpController = HttpController()
    //声明一个字典用来缓存缩略图
    var imageCache = Dictionary<String,UIImage>()
    //定义一个MPMoviePlayerController类型的变量
    var audioPlayer:MPMoviePlayerController = MPMoviePlayerController()
    //定义一个定时器
    var timer:Timer?
    
    func onChangeChannel(channel_id:String){
        //拼凑频道歌曲数据网络地址
        let url:String = "http://douban.fm/j/mine/playlist?type=n&\(channel_id)&from=mainsite"
        //获取数据
        print(url)
        eHttp.onSearch(url: url)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //为Httpcontroller实例设置代理
        eHttp.delegate = self
        //获取评到0的歌曲数据
        eHttp.onSearch(url: "http://douban.fm/j/mine/playlist?type=n&channel=0&from=mainsite")

        //获取频道数据
        eHttp.onSearch(url: "https://www.douban.com/j/app/radio/channels")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
    //播放歌曲
    func onSetAudio(url:String){
        //暂停
        self.audioPlayer.stop()
        //获取歌曲文件
        self.audioPlayer.contentURL = NSURL(string: url) as! URL
        //播放
        self.audioPlayer.play()
        
        //先停掉计时器
        timer?.invalidate()
        //归零
        playTime!.text = "00:00"
        //开启
        timer = Timer.scheduledTimer(timeInterval: 0.4, target: self, selector: #selector(TVViewController.onUpdate), userInfo: nil, repeats: true)
    }
    //计时器更新方法
    func onUpdate(){
        //返回当前播放时间
        let c = audioPlayer.currentPlaybackTime
        if c > 0.0{
            //歌曲的总时间
            let t = audioPlayer.duration
            //歌曲播放的百分比
            let p:CFloat = CFloat(c/t)
            //通过百分比设置进度条
            progressView!.setProgress(p, animated: true)
            
            //算法，实现00：00格式的播放时间
            let all:Int = Int(c)
            let m:Int = all % 60
            let f:Int = Int(all/60)
            var time:String = ""
            if f < 10{
                time = "0\(f):"
            }else{
                time = "\(f)"
            }
            if m < 10{
                time += "0\(m)"
            }else{
                time += "\(m)"
            }
            //更新播放时间
            playTime!.text = time
        }
    }
    //添加tableView的numberOfRowsInSecion方法来返回TableView的数据行数
    func tableView(_ tableView:UITableView,numberOfRowsInSection section:Int) -> Int{
//        return 10
        return tableData.count
    }
    
    //实现tableView的cellForRowAtIndexPath方法
    func tableView(_ tableView:UITableView,cellForRowAt indexPath:IndexPath) -> UITableViewCell{
        //获取标识为 douban 的cell
        let cell = UITableViewCell(style: UITableViewCellStyle.subtitle, reuseIdentifier: "douban")
        cell.imageView?.image = UIImage(named: "detail")
        //获取cell数据
        let rowData:NSDictionary = self.tableData[indexPath.row] as! NSDictionary
        //设置标题
        cell.textLabel?.text = rowData["title"] as? String
        //设置详情
        cell.detailTextLabel?.text = rowData["artist"] as? String
        //获取图片地址
        let url = rowData["picture"] as! String
        //通过图片地址去缓存中取图片
        let image = self.imageCache[url] as UIImage?
        if image == nil {//如果缓存中没有
            //定义NSURL
            let imgURL:NSURL = NSURL(string:url)!
            //定义NSURLRequest
            let request:URLRequest = URLRequest(url:imgURL as URL)
            //异步获取图片
            NSURLConnection.sendAsynchronousRequest(request, queue: OperationQueue.main) { (response, data, error) -> Void in
                //把图片数据赋予UIImage
                let img = UIImage(data: data!)
                //设置缩略图
                cell.imageView?.image = img
                //将该图片缓存
                self.imageCache[url] = img
            }
        }else{
            //缓存中有，直接获取
            cell.imageView?.image = image
        }
        //返回cell
        return cell
    }
    
    //设置响应选中cell的方法， didSelectRowAtIndexPath
    func tableView(_ tableView:UITableView,didSelectRowAt indexPath:IndexPath) {
        print("选择了第\(indexPath.row)行")
        //获取选中行的数据
        var rowData: NSDictionary = self.tableData[indexPath.row] as! NSDictionary
        //获取该行的图片地址
        let imgUrl:String = rowData["picture"] as! String
        //设置成封面
        onSetImage(url: imgUrl)
        //获取歌曲文件地址
        var audioUrl:String = rowData["url"] as! String
        //播放音乐
        onSetAudio(url: audioUrl)
    }
    
    //实现httpprotocol协议中的方法
    func didRecieveResults(results: NSDictionary) {
        
        //如果数据的song关键字不为nil
        if(results["song"] != nil){
            //填充tabledata
            self.tableData = results["song"] as! NSArray
            //刷新tv数据
            self.tv.reloadData()
            
            //获取第一首歌曲地址和缩略图的地址
            let firDict:NSDictionary = self.tableData[0] as! NSDictionary
            let audioUrl:String = firDict["url"] as! String
            print("音乐地址：\(audioUrl)")
            //播放歌曲
            onSetAudio(url: audioUrl)
            let imgUrl:String = firDict["picture"] as! String
            print("图片地址：\(imgUrl)")
            onSetImage(url: imgUrl)
        }else if (results["channels"] != nil ){
            //如果channels关键字value不为nil，获取的就是频道数据
            self.channelData = results["channels"] as! NSArray
        }
    }
    
    //视图跳转时执行的方法
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //跳转的对象为ChannelController
        var channelC:ChannelViewController = segue.destination as! ChannelViewController
        //设置跳转对象的代理
        channelC.delegate = self
        //为跳转对象填充频道列表数据
        channelC.channelData = self.channelData
    }
    //设置歌曲封面
    func onSetImage(url:String){
        let image = self.imageCache[url] as UIImage?
        self.iv.image = UIImage(named: "detail")
        if image == nil {
            let imgURL:NSURL = NSURL(string:url)!
            let request:URLRequest = URLRequest(url:imgURL as URL)
            NSURLConnection.sendAsynchronousRequest(request, queue: OperationQueue.main) { (response, data, error) -> Void in
                let img = UIImage(data: data!)
                self.iv.image = img
                self.imageCache[url] = img
            }
        }else{
            self.iv.image = image
        }
        
    }
    

}
