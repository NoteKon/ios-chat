//
//  ImageUrls.swift
//  GZCList_Example
//
//  Created by Guo ZhongCheng on 2020/10/13.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import Foundation

struct ImageUrlsHelper {
    /// 获取数字图片
    static func getNumberImage(_ number: Int) -> String {
        return numberImages[number % numberImages.count]
    }
    
    /// 获取随机图片
    static func getRandomImage() -> String {
        let index:Int = Int(arc4random() % UInt32(otherImages.count))
        return otherImages[index]
    }
    
    /// 获取随机gif图片
    static func getRandomGif() -> String {
        let index:Int = Int(arc4random() % UInt32(gifImages.count))
        return gifImages[index]
    }
    
    /// html字符串
    static func getHtmlImage(_ index: Int) -> String {
        return htmlImages[index % htmlImages.count]
    }
    
    /// 数字图片
    static let numberImages = [
        "https://ss3.bdstatic.com/70cFv8Sh_Q1YnxGkpoWK1HF6hhy/it/u=4202271524,3384084509&fm=26&gp=0.jpg",
        "https://ss0.bdstatic.com/70cFvHSh_Q1YnxGkpoWK1HF6hhy/it/u=3647333896,3085714962&fm=26&gp=0.jpg",
        "https://ss2.bdstatic.com/70cFvnSh_Q1YnxGkpoWK1HF6hhy/it/u=270582895,1445692417&fm=26&gp=0.jpg",
        "https://ss3.bdstatic.com/70cFv8Sh_Q1YnxGkpoWK1HF6hhy/it/u=2586044819,3331697588&fm=26&gp=0.jpg",
        "https://ss0.bdstatic.com/70cFvHSh_Q1YnxGkpoWK1HF6hhy/it/u=3240955661,2650912103&fm=26&gp=0.jpg",
        "https://ss0.bdstatic.com/70cFuHSh_Q1YnxGkpoWK1HF6hhy/it/u=3833369932,2550583528&fm=26&gp=0.jpg",
        "https://ss0.bdstatic.com/70cFuHSh_Q1YnxGkpoWK1HF6hhy/it/u=2470060427,260083397&fm=26&gp=0.jpg",
        "https://ss0.bdstatic.com/70cFvHSh_Q1YnxGkpoWK1HF6hhy/it/u=885219178,2446185038&fm=26&gp=0.jpg",
        "https://ss1.bdstatic.com/70cFvXSh_Q1YnxGkpoWK1HF6hhy/it/u=3442927006,4224762595&fm=26&gp=0.jpg",
        "https://ss1.bdstatic.com/70cFvXSh_Q1YnxGkpoWK1HF6hhy/it/u=234917952,3152930737&fm=26&gp=0.jpg",
        "https://ss1.bdstatic.com/70cFuXSh_Q1YnxGkpoWK1HF6hhy/it/u=2972734370,1519433023&fm=26&gp=0.jpg",
        "https://ss2.bdstatic.com/70cFvnSh_Q1YnxGkpoWK1HF6hhy/it/u=607026504,1686920348&fm=26&gp=0.jpg",
        "https://ss0.bdstatic.com/70cFuHSh_Q1YnxGkpoWK1HF6hhy/it/u=4063662527,1575556401&fm=26&gp=0.jpg"
    ]
    
    /// gif图片
    static let gifImages = [
        "http://hbimg.huabanimg.com/3fee54d0b2e0b7a132319a8e104f5fdc2edd3d35d03ee-93Jmdq_fw658",
        "http://5b0988e595225.cdn.sohucs.com/images/20180510/c861c0e9509546f98c25ef09419f1b81.gif",
        "http://pic.17qq.com/img_biaoqing/81498827.jpeg",
        "https://cdn.duitang.com/uploads/item/201410/27/20141027205016_naAYv.thumb.700_0.gif",
        "https://img.zcool.cn/community/01b0d857b1a34d0000012e7e87f5eb.gif",
        "http://img.mp.sohu.com/upload/20170610/57fd225c09e04457a743253fa7191f85_th.png"
    ]
    
    /// 较大的图片
    static let otherImages = [
        "http://pic1.win4000.com/wallpaper/7/53a151ef7c3fe.jpg",
        "http://pic1.win4000.com/mobile/2020-09-24/5f6c35a142966.jpg",
        "http://pic1.win4000.com/wallpaper/7/53a151fd21eef.jpg",
        "http://pic1.win4000.com/mobile/2020-09-24/5f6c35a210bd6.jpg",
        "http://pic1.win4000.com/wallpaper/1/53a15a17d8121.jpg",
        "http://pic1.win4000.com/mobile/2020-09-24/5f6c35a3265d0.jpg",
        "http://pic1.win4000.com/wallpaper/1/53a15a205fe67.jpg",
        "http://pic1.win4000.com/mobile/2020-09-24/5f6c35a43c3ec.jpg",
        "http://pic1.win4000.com/wallpaper/7/53a151e019601.jpg",
        "http://pic1.win4000.com/mobile/2020-09-24/5f6c35a55d4df.jpg",
        "http://pic1.win4000.com/mobile/2020-09-24/5f6c35a65dc48.jpg",
        "http://pic1.win4000.com/mobile/2020-09-24/5f6c35a759a00.jpg",
        "http://pic1.win4000.com/wallpaper/7/53a152032ca56.jpg",
        "http://pic1.win4000.com/wallpaper/7/53a1520b2ce94.jpg",
        "http://pic1.win4000.com/wallpaper/7/53a152109624b.jpg",
        "http://pic1.win4000.com/wallpaper/7/53a152155d7d2.jpg",
        "http://pic1.win4000.com/wallpaper/0/53a13ef661239.jpg",
        "http://pic1.win4000.com/wallpaper/0/53a13ef973775.jpg",
        "http://pic1.win4000.com/wallpaper/0/53a13efcb234b.jpg",
        "http://pic1.win4000.com/wallpaper/0/53a13f002e9f0.jpg",
        "http://pic1.win4000.com/wallpaper/0/53a13f02acd1f.jpg",
        "http://pic1.win4000.com/wallpaper/0/53a13f056b296.jpg",
        "http://pic1.win4000.com/wallpaper/0/53a13f08825ad.jpg",
        "http://pic1.win4000.com/wallpaper/0/53a13f0bd8c85.jpg",
        "http://pic1.win4000.com/mobile/2020-09-24/5f6c598d4d989.jpg",
        "http://pic1.win4000.com/mobile/2020-09-24/5f6c5a4125b29.jpg",
        "http://pic1.win4000.com/mobile/2020-09-24/5f6c5a4444130.jpg",
        "http://pic1.win4000.com/mobile/2020-09-24/5f6c5a45c5ebc.jpg",
        "http://pic1.win4000.com/mobile/2020-09-24/5f6c5a473e96f.jpg",
        "http://pic1.win4000.com/mobile/2020-09-24/5f6c5a487e80e.jpg",
        "http://pic1.win4000.com/mobile/2020-09-24/5f6c5a49e463e.jpg",
        "http://pic1.win4000.com/mobile/2020-09-14/5f5f385765bd8.jpg",
        "http://pic1.win4000.com/mobile/2020-09-14/5f5f38592cc9c.jpg",
        "http://pic1.win4000.com/mobile/2020-09-14/5f5f385a38caf.jpg",
        "http://pic1.win4000.com/mobile/2020-09-14/5f5f385b3518e.jpg",
        "http://pic1.win4000.com/mobile/2020-09-14/5f5f385c3b361.jpg",
        "http://pic1.win4000.com/mobile/2020-09-14/5f5f385d435d2.jpg",
        "https://img.3dmgame.com/uploads/images2/news/20200920/1600588107_559097.jpg",
        "https://img.3dmgame.com/uploads/images2/news/20200920/1600588110_877890.jpg",
        "https://img.3dmgame.com/uploads/images2/news/20200920/1600588111_966387.jpg"
    ]

    static let htmlImages = [
        "<img src = \"http://img.alicdn.com/imgextra/i3/124158638/O1CN01AlLzW02DgFnqvcWtB_!!124158638.jpg\"/>",
        "<img src = \"http://img.alicdn.com/imgextra/i3/124158638/O1CN01UDk2nT2DgFntE75Mg_!!124158638.jpg\"/>",
        "<img src = \"http://img.alicdn.com/imgextra/i2/124158638/O1CN019BHZod2DgFnslzXhR_!!124158638.jpg\"/>",
        "<img src = \"http://img.alicdn.com/imgextra/i2/124158638/O1CN01EPcjWn2DgFnqwc1kG_!!124158638.jpg\"/>",
        "<img src = \"http://img.alicdn.com/imgextra/i1/124158638/O1CN019pgtii2DgFnwgeFxu_!!124158638.jpg\"/>"
    ]
}

