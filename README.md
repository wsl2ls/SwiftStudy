# 前言

>   &#160; &#160; 鉴于目前Swift的ABI(应用程序二进制接口)、API(应用程序编程接口) 基本稳定，对于Swift的学习有必要提上日程了，这个[Swift仿微博列表](https://github.com/wsl2ls/SwiftStudy.git)的效果是我最近一边学习《[Swift入门到精通-李明杰](https://m.ke.qq.com/m-core/distributionPoster.html?id=392094&isPackage=0&goodRatio=100&token=1693443&from=applink)》 一边练手的[Demo](https://github.com/wsl2ls/SwiftStudy.git)，Swift新手还请关照~🤝
   &#160; &#160;  这个[示例](https://github.com/wsl2ls/SwiftStudy.git)的主要内容有三个方面：
  **&#160; &#160; 一、UITextView富文本的实现**
  **&#160; &#160; 二、图片转场和浏览动画**
  **&#160; &#160; 三、界面流畅度优化**

![富文本点击效果](https://upload-images.jianshu.io/upload_images/1708447-f53ec6751e28437f.gif?imageMogr2/auto-orient/strip)
![图集浏览效果](https://upload-images.jianshu.io/upload_images/1708447-72cdb0c8cd4e9820.gif?imageMogr2/auto-orient/strip)

##  一、UITextView富文本的实现

*  *标题的富文本显示样式我是参考微博的：@用户昵称、#话题#、图标+描述、[表情]、全文：限制显示字数，点击链接跳转或查看图片*

>  **比如第一条数据的标题原始字符串为**：*@wsl2ls: 不要迷恋哥，哥只是一个传说 https://github.com/wsl2ls, 是终将要成为#海贼王#的男人！// @蜜桃君🏀: 🦆你真的太帅了[爱你] https://github.com/wsl2ls // @且行且珍惜_iOS: 发起了话题#我是一只帅哥#不信点我看看 https://www.jianshu.com/u/e15d1f644bea , 相信我，不会让你失望滴O(∩_∩)O哈!*
**——> 正则匹配后富文本显示为**：*@wsl2ls: 不要迷恋哥，哥只是一个传说 ￼查看图片, 是终将要成为#海贼王#的男人！// @蜜桃君🏀: 🦆你真的太帅了￼ ￼查看图片 // @且行且珍惜_iOS: 发起了话题#我是一只帅哥#不信点我看看 ￼查看图片 , 相信我，不会让你失望滴O(∩_∩)O哈！*

```
//正则匹配规则
let KRegularMatcheHttpUrl = "((http[s]{0,1}|ftp)://[a-zA-Z0-9\\.\\-]+\\.([a-zA-Z]{2,4})(:\\d+)?(/[a-zA-Z0-9\\.\\-~!@#$%^&*+?:_/=<>]*)?)|(www.[a-zA-Z0-9\\.\\-]+\\.([a-zA-Z]{2,4})(:\\d+)?(/[a-zA-Z0-9\\.\\-~!@#$%^&*+?:_/=<>]*)?)" // 图标+描述 替换HTTP链接
let KRegularMatcheTopic = "#[^#]+#"    // 话题匹配 #话题#
let KRegularMatcheUser = "@[\\u4e00-\\u9fa5a-zA-Z0-9_-]*"  // @用户匹配
let KRegularMatcheEmotion = "\\[[^ \\[\\]]+?\\]"   //表情匹配 [爱心]
```

* *富文本是由原始字符串经过一系列的正则匹配到目标字符串后，再经过一系列的字符串高亮、删除、替换等处理得到的*

> **注意：每一个匹配项完成字符串处理后可能会改变原有字符串的NSRange，进而导致另一个匹配项的Range在处理字符串时出现越界的崩溃问题！**

```
    //标题正则匹配结果
    func matchesResultOfTitle(title: String, expan: Bool) -> (attributedString : NSMutableAttributedString , height : CGFloat) {
        //原富文本标题
        var attributedString:NSMutableAttributedString = NSMutableAttributedString(string:title)
        //原富文本的范围
        let titleRange = NSRange(location: 0, length:attributedString.length)
        //最大字符 截取位置
        var cutoffLocation = KTitleLengthMax
        //图标+描述 替换HTTP链接
        let urlRanges:[NSRange] = getRangesFromResult(regexStr:KRegularMatcheHttpUrl, title: title)
        for range in urlRanges {
            let attchimage:NSTextAttachment = NSTextAttachment()
            attchimage.image = UIImage.init(named: "photo")
            attchimage.bounds = CGRect.init(x: 0, y: -2, width: 16, height: 16)
            let replaceStr : NSMutableAttributedString = NSMutableAttributedString(attachment: attchimage)
            replaceStr.append(NSAttributedString.init(string: "查看图片")) //添加描述
            replaceStr.addAttributes([NSAttributedString.Key.link :"http://img.wxcha.com/file/201811/21/afe8559b5e.gif"], range: NSRange(location: 0, length:replaceStr.length ))
            //注意：涉及到文本替换的 ，每替换一次，原有的富文本位置发生改变，下一轮替换的起点需要重新计算！
            let newLocation = range.location - (titleRange.length - attributedString.length)
            //图标+描述 替换HTTP链接字符
            attributedString.replaceCharacters(in: NSRange(location: newLocation, length: range.length), with: replaceStr)
            //如果最多字符个数会截断高亮字符，则舍去高亮字符
            if cutoffLocation >= newLocation && cutoffLocation <= newLocation + range.length {
                cutoffLocation = newLocation
            }
        }
        //话题匹配
        let topicRanges:[NSRange] = getRangesFromResult(regexStr: KRegularMatcheTopic, title: attributedString.string)
        for range in topicRanges {
        attributedString.addAttributes([NSAttributedString.Key.link :"https://github.com/wsl2ls"], range: range)
            //如果最多字符个数会截断高亮字符，则舍去高亮字符
            if cutoffLocation >= range.location && cutoffLocation <= range.location + range.length {
                cutoffLocation = range.location
            }
        }
        //@用户匹配
        let userRanges:[NSRange] = getRangesFromResult(regexStr: KRegularMatcheUser,title: attributedString.string)
        for range in userRanges {
   attributedString.addAttributes([NSAttributedString.Key.link :"https://www.jianshu.com/u/e15d1f644bea"], range: range)
            //如果最多字符个数会截断高亮字符，则舍去高亮字符
            if cutoffLocation >= range.location && cutoffLocation <= range.location + range.length {
                cutoffLocation = range.location
            }
        }
        //表情匹配
        let emotionRanges:[NSRange] = getRangesFromResult(regexStr: KRegularMatcheEmotion,title: attributedString.string)
        //经过上述的匹配替换后，此时富文本的范围
        let currentTitleRange = NSRange(location: 0, length:attributedString.length)
        for range in emotionRanges {
            //表情附件
            let attchimage:NSTextAttachment = NSTextAttachment()
            attchimage.image = UIImage.init(named: "爱你")
            attchimage.bounds = CGRect.init(x: 0, y: -2, width: 16, height: 16)
            let stringImage : NSAttributedString = NSAttributedString(attachment: attchimage)
            //注意：每替换一次，原有的位置发生改变，下一轮替换的起点需要重新计算！
            let newLocation = range.location - (currentTitleRange.length - attributedString.length)
            //图片替换表情文字
            attributedString.replaceCharacters(in: NSRange(location: newLocation, length: range.length), with: stringImage)
            //如果最多字符个数会截断高亮字符，则舍去高亮字符
            //字符替换之后，截取位置也要更新
            cutoffLocation -= (currentTitleRange.length - attributedString.length)
            if cutoffLocation >= newLocation && cutoffLocation <= newLocation + range.length {
                cutoffLocation = newLocation
            }
        }
        //超出字符个数限制，显示全文
        if attributedString.length > cutoffLocation {
            var fullText: NSMutableAttributedString
            if expan {
attributedString.append(NSAttributedString(string:"\n"))
                fullText = NSMutableAttributedString(string:"收起")
                fullText.addAttributes([NSAttributedString.Key.link :"FullText"], range: NSRange(location:0, length:fullText.length ))
            }else {
                attributedString = attributedString.attributedSubstring(from: NSRange(location: 0, length: cutoffLocation)) as! NSMutableAttributedString
                fullText = NSMutableAttributedString(string:"...全文")
                fullText.addAttributes([NSAttributedString.Key.link :"FullText"], range: NSRange(location:3, length:fullText.length - 3))
            }
            attributedString.append(fullText)
        }
        //段落
        let paragraphStyle : NSMutableParagraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 4 //行间距   attributedString.addAttributes([NSAttributedString.Key.paragraphStyle :paragraphStyle, NSAttributedString.Key.font : UIFont.systemFont(ofSize: 16)], range: NSRange(location:0, length:attributedString.length))
        //元组
        let attributedStringHeight = (attributedString, heightOfAttributedString(attributedString))
        return attributedStringHeight
    }
    //根据匹配规则返回所有的匹配结果
    fileprivate func getRangesFromResult(regexStr : String, title: String) -> [NSRange] {
        // 0.匹配规则
        let regex = try? NSRegularExpression(pattern:regexStr, options: [])
        // 1.匹配结果
        let results = regex?.matches(in:title, options:[], range: NSRange(location: 0, length: NSAttributedString(string: title).length))
        // 2.遍历结果 数组
        var ranges = [NSRange]()
        for res in results! {
            ranges.append(res.range)
        }
        return ranges
    }
    //计算富文本的高度
    func heightOfAttributedString(_ attributedString: NSAttributedString) -> CGFloat {
        let height : CGFloat =  attributedString.boundingRect(with: CGSize(width: UIScreen.main.bounds.size.width - 15 * 2, height: CGFloat(MAXFLOAT)), options: [.usesLineFragmentOrigin, .usesFontLeading], context: nil).height
        return ceil(height)
    }  
 }

```

## 二、图片转场和浏览动画

*  *图片的转场动画以及捏合放大缩小、触摸点双击放大缩小、拖拽过渡转场等图集浏览动画 是参考微信的效果来实现的，经过不断反复的去用和观察微信的动画，逐渐完善代码逻辑和动画效果。*

> 自定义转场动画的实现可以看下我之前的文章[iOS 自定义转场动画](https://www.jianshu.com/p/a9b1307b305b)，这里我说一下动画视图的构造和图集浏览手势动画。

> * ###### 1、列表页cell中的imageView的大小是固定平均分配的，而每张图片的大小和比例都是不一样的，为了保证图片不变形，按比例只展示图片的中心部分，怎么做哪？ 截取image的中心部分赋给ImageView ?  给imageView包一层View，然后设置view.clipsToBounds=true? NO！！！可以通过设置imageView.layer.contentsRect 来实现，这个也是如下所示的慢放渐变动画效果的关键。

```

  if (image.size.height/image.size.width > 3) {
    //大长图 仅展示顶部部分内容
     let proportion: CGFloat = height/(width * image.size.height/image.size.width)
    imageView.layer.contentsRect = CGRect(x: 0, y: 0, width: 1, height: proportion)
    } else if image.size.width >= image.size.height {
     // 宽>高
     let proportion: CGFloat = width/(height * image.size.width/image.size.height)
    imageView.layer.contentsRect = CGRect(x: (1 - proportion)/2, y: 0, width: proportion, height: 1)
    }else if image.size.width < image.size.height {
    //宽<高
let proportion: CGFloat = height/(width * image.size.height/image.size.width)
  imageView.layer.contentsRect = CGRect(x: 0, y: (1 - proportion)/2, width: 1, height: proportion)
}

```

![转场渐变动画.gif](https://upload-images.jianshu.io/upload_images/1708447-9c802ac940eeb24b.gif?imageMogr2/auto-orient/strip)

```
       //渐变动画
        UIView.animate(withDuration: self.transitionDuration(using: transitionContext), animations: {
            if(self.toAnimatonView!.frame != CGRect.zero) {
                self.fromAnimatonView?.frame = self.toAnimatonView!.frame
                self.fromAnimatonView?.layer.contentsRect = self.toAnimatonView!.layer.contentsRect
            }else {   
            }
        }) { (finished) in
            toView.isHidden = false
            bgView.removeFromSuperview()
            self.fromAnimatonView?.removeFromSuperview()
            transitionContext.completeTransition(true)
        }
    }

```

> *  ######  2、图集浏览页面的动画包括： 捏合放大缩小、触摸点双击放大缩小、拖拽过渡转场。 捏合放大缩小动画是由继承于UIScrollView的子类SLPictureZoomView完成；触摸点双击放大是根据触摸点在图片的位置和屏幕上的位置得到放大后的触摸点相对位置来实现的；拖拽过渡转场是根据手指在屏幕上的移动距离来调整SLPictureZoomView的大小和中心点位置的，详情看代码。

注意手势冲突：

```
//解决 self.pictureZoomView 和UICollectionView 手势冲突
  self.pictureZoomView.isUserInteractionEnabled = false;  
  self.contentView.addGestureRecognizer(self.pictureZoomView.panGestureRecognizer)     
  self.contentView.addGestureRecognizer(self.pictureZoomView.pinchGestureRecognizer!)
```

## 三、界面流畅度优化

>  网上关于界面流畅度优化的好文章还是挺多的，我在这里只记录下本文示例中用到的部分优化策略，基本上FPS在60左右，  详情可以看代码：
1、cell高度异步计算和缓存
2、富文本异步正则匹配和结果缓存
3、数组缓存九宫格图片视图以复用
4、图片降采样和预加载
5、减少视图层级
6、减少不必要的数据请求

👁**代码传送门**  ——>  [Swift仿微博列表](https://github.com/wsl2ls/SwiftStudy.git)

 **推荐阅读**
 [YYKit - iOS 保持界面流畅的技巧](https://blog.ibireme.com/2015/11/12/smooth_user_interfaces_for_ios/)
[iOS 自定义转场动画](https://www.jianshu.com/p/a9b1307b305b)
[iOS 图片浏览的放大缩小](https://www.jianshu.com/p/b5a55099f4fc)
[UIScrollView视觉差动画](https://www.jianshu.com/p/3b30b9cdd274)


> 如果需要跟我交流的话：
※ Github： [https://github.com/wsl2ls](https://github.com/wsl2ls) 
※ 简书：[https://www.jianshu.com/u/e15d1f644bea](https://www.jianshu.com/u/e15d1f644bea) 
※ 微信公众号：iOS2679114653
※ QQ：1685527540
