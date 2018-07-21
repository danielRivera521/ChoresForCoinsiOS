//
//  Extensions.swift
//  ChoresForCoinsiOS
//
//  Created by Daniel Rivera on 6/28/18.
//  Copyright © 2018 Daniel Rivera, Andrew Harrington. All rights reserved.


import UIKit

let imageCache = NSCache<AnyObject, AnyObject>()

extension UIButton {
    
    func loadImagesUsingCacheWithUrlString(urlString: String, inViewController: UIViewController){
        
        //check if the image is in the cache
        if let cachedImage = imageCache.object(forKey: urlString as AnyObject) as? UIImage{
            
            self.setBackgroundImage(cachedImage, for: .normal)
            return
        }
        
        //creates the session
        let session = URLSession.shared
        
        //create URL variable from string value
        let url: URL  = URL(string: urlString)!
        
        //runs a task to get the image from the URL
        let getImageFromURL = session.dataTask(with: url, completionHandler: { (data, response, error) in
            
            //if there is an error
            if error != nil {
                //print(error.localizedDescription)
                AlertController.showAlert(inViewController, title: "Download Image Error", message: "Unable to download the image.")
                return
            } else {
                //if there isn't a respons the image value is set from the data to the imageView within the custom cell
                if (response as? HTTPURLResponse) != nil {
                    
                    DispatchQueue.main.async {
                        if let imageData = data {
                            if let downloadedImage = UIImage(data: imageData){
                                imageCache.setObject(downloadedImage, forKey: urlString as AnyObject)
                                
                                self.setBackgroundImage(downloadedImage, for: .normal)
                            }
                        }
                    }
                }
            }
        })
        getImageFromURL.resume()
    }
}

extension UIImageView {
    func loadImagesUsingCacheWithUrlString(urlString: String, inViewController: UIViewController?){
        
        //check if the image is in the cache
        if let cachedImage = imageCache.object(forKey: urlString as AnyObject) as? UIImage{
            
            self.image = cachedImage
            return
        }
        
        //creates the session
        let session = URLSession.shared
        
        //create URL variable from string value
        let url: URL  = URL(string: urlString)!
        
        //runs a task to get the image from the URL
        let getImageFromURL = session.dataTask(with: url, completionHandler: { (data, response, error) in
            
            //if there is an error
            if error != nil {
               // print(error.localizedDescription)
                if let vcInfo = inViewController{
                AlertController.showAlert(vcInfo, title: "Download Image Error", message: "Unable to download image.")
                }
                return
            } else {
                //if there isn't a respons the image value is set from the data to the imageView within the custom cell
                if (response as? HTTPURLResponse) != nil {
                    
                    DispatchQueue.main.async {
                        if let imageData = data {
                            if let downloadedImage = UIImage(data: imageData){
                                imageCache.setObject(downloadedImage, forKey: urlString as AnyObject)
                                
                                self.image = downloadedImage
                            }
                        }
                    }
                }
            }
        })
        getImageFromURL.resume()
    }
}

extension UIImage {
    func fixOrientation() -> UIImage {
        if self.imageOrientation == UIImageOrientation.up {
            return self
        }
        UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale)
        self.draw(in: CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height))
        if let normalizedImage: UIImage = UIGraphicsGetImageFromCurrentImageContext() {
            UIGraphicsEndImageContext()
            return normalizedImage
        } else {
            return self
        }
    }
    
    func resize() -> UIImage {
        var actualHeight = Float(self.size.height)
        var actualWidth = Float(self.size.width)
        let maxHeight: Float = 300.0
        let maxWidth: Float = 400.0
        var imgRatio: Float = actualWidth / actualHeight
        let maxRatio: Float = maxWidth / maxHeight
        let compressionQuality: Float = 0.5
        //50 percent compression
        if actualHeight > maxHeight || actualWidth > maxWidth {
            if imgRatio < maxRatio {
                //adjust width according to maxHeight
                imgRatio = maxHeight / actualHeight
                actualWidth = imgRatio * actualWidth
                actualHeight = maxHeight
            }
            else if imgRatio > maxRatio {
                //adjust height according to maxWidth
                imgRatio = maxWidth / actualWidth
                actualHeight = imgRatio * actualHeight
                actualWidth = maxWidth
            }
            else {
                actualHeight = maxHeight
                actualWidth = maxWidth
            }
        }
        let rect = CGRect(x: 0.0, y: 0.0, width: CGFloat(actualWidth), height: CGFloat(actualHeight))
        UIGraphicsBeginImageContext(rect.size)
        self.draw(in: rect)
        let img = UIGraphicsGetImageFromCurrentImageContext()
        let imageData = UIImageJPEGRepresentation(img!, CGFloat(compressionQuality))
        UIGraphicsEndImageContext()
        return UIImage(data: imageData!) ?? UIImage()
    }
}
