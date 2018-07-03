//
//  ImageService.swift
//  ChoresForCoinsiOS
//
//  Created by Daniel Rivera on 7/2/18.
//  Copyright © 2018 Daniel Rivera, Andrew Harrington. All rights reserved.
//

import Foundation
import UIKit

class ImageService{
    
    static let cache = NSCache<NSString, UIImage>()
    
    static func downloadImage(withURL url: URL,  completion: @escaping (_ image: UIImage?)-> ()){
        let dataTask = URLSession.shared.dataTask(with: url) { (data, urlResponse, error) in
            
            var downloadedImage: UIImage?
            
            if let data = data {
                downloadedImage = UIImage(data: data)
            }
            
            if downloadedImage != nil {
                cache.setObject(downloadedImage!, forKey: url.absoluteString as NSString)
            }
            
            DispatchQueue.main.async {
                completion(downloadedImage)
            }
        }
        
        dataTask.resume()
    }
    
    static func getImage(withURL url: URL, completion: @escaping (_ imgate: UIImage?) -> ()){
        
        if let image = cache.object(forKey: url.absoluteString as NSString){
            completion(image)
        } else {
            
            downloadImage(withURL: url, completion: completion)
        }
        
        
    }
}
