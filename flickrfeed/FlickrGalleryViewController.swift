//
//  FlickrGalleryViewController.swift
//  flickrfeed
//
//  Created by Jeong Jin Kim on 2017. 4. 24..
//  Copyright © 2017년 Jeong Jin Kim. All rights reserved.
//

import UIKit

enum VisibleImageView {
    case oneImageView, otherImageView
    mutating func toggle() {
        switch self {
        case .oneImageView :
            self = .otherImageView
        case .otherImageView :
            self = .oneImageView
        }
    }
}

typealias CompletionHandlerClosureType = () -> ()

class FlickrGalleryViewController: UIViewController {
    @IBOutlet weak var oneImageView:UIImageView?
    @IBOutlet weak var otherImageView:UIImageView?
    
    var feedArray = Array<[String:Any]>()
    weak var timer:Timer?
    var timerTick:Double? {
        didSet {
            makeTimer()
        }
    }
    
    var currentIndex = 0
    
    var visibleImageView : VisibleImageView = VisibleImageView.oneImageView
    var loading:Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.loadPublicFeed(nil)
        self.oneImageView?.alpha = 0;
        self.otherImageView?.alpha = 0;
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func makeTimer () {
        if (self.timer != nil) {
            self.timer?.invalidate()
            self.timer = nil
        }
        if let tick = self.timerTick {
            if tick > 0 {
                self.timer = Timer.scheduledTimer(timeInterval: tick, target: self, selector: #selector(showNextImage), userInfo: nil, repeats: true)
            }
        }
    }
    
    func showNextImage() {
        if self.loading == true || self.feedArray.count == 0 {
            return
        }
        
        let data = self.feedArray[currentIndex] as NSDictionary
        
        if let url = URL(string:data.value(forKeyPath: "media.m") as! String)  {
            self.loading = true
            
            let task = URLSession.shared.dataTask(with: url) { data, response, error in
                guard let data = data, error == nil else { return }
                
                DispatchQueue.main.sync() {
                    switch(self.visibleImageView)
                    {
                    case .oneImageView:
                        self.oneImageView?.image = UIImage(data: data)
                        UIView.animate(withDuration: 0.5, animations: {
                            self.oneImageView?.alpha = 1;
                            self.otherImageView?.alpha = 0;
                        })
                    case .otherImageView:
                        self.otherImageView?.image = UIImage(data: data)
                        UIView.animate(withDuration: 0.5, animations: {
                            self.oneImageView?.alpha = 0;
                            self.otherImageView?.alpha = 1;
                        })
                    }
                    self.visibleImageView.toggle()
                    self.loading = false;
                }
            }
            task.resume()
        }
        
        currentIndex += 1
        if(currentIndex == self.feedArray.count) {
            currentIndex = 0
        }
    }

    deinit {
        self.timer?.invalidate()
        self.timer = nil
    }
    
    @IBAction func closeButtonTouched(sender : UIButton) {
        self.timer?.invalidate()
        self.timer = nil
        self.dismiss(animated: true, completion: nil)
    }
    
    func loadPublicFeed(_ completetion : CompletionHandlerClosureType?) {
        if (self.feedArray.count > 10 && (self.feedArray.count - currentIndex ) > 10) {
            return
        }
        
        //get the feed
        if let flickrFeedURL:URL = URL(string: "https://api.flickr.com/services/feeds/photos_public.gne?format=json&nojsoncallback=1&lang=en-us") {
            let request:URLRequest = URLRequest(url: flickrFeedURL, cachePolicy: URLRequest.CachePolicy.reloadIgnoringCacheData, timeoutInterval: 10)
            
            let task = URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) in
                if error == nil {
                    do {
                        let json = try JSONSerialization.jsonObject(with: data!, options:[]) as? [String: Any]
                        let items = json?["items"] as! [[String:Any]]
                        self.feedArray.append(contentsOf: items)
                    } catch let exception {
                        print (exception)
                        self.loadPublicFeed(nil)
                    }
                }
                completetion?()
            })
            task.resume()
        }
    }
}
