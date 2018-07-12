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
            if let error = error {
                //print(error.localizedDescription)
                AlertController.showAlert(inViewController, title: "Download Image Error", message: error.localizedDescription)
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
    func loadImagesUsingCacheWithUrlString(urlString: String, inViewController: UIViewController){
        
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
            if let error = error {
               // print(error.localizedDescription)
                AlertController.showAlert(inViewController, title: "Download Image Error", message: error.localizedDescription)
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
}
