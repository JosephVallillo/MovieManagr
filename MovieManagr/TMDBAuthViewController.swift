//
//  TMDBAuthViewController.swift
//  MovieManagr
//
//  Created by Joseph Vallillo on 2/16/16.
//  Copyright © 2016 Joseph Vallillo. All rights reserved.
//

import UIKit

// MARK: - TMDBAuthViewController: UIViewController

class TMDBAuthViewController: UIViewController {
    
    // MARK: Properties
    
    var urlRequest: NSURLRequest? = nil
    var requestToken: String? = nil
    var completionHandlerForView: ((success: Bool, errorString: String?) -> Void)? = nil
    
    // MARK: Outlets
    
    @IBOutlet weak var webView: UIWebView!
    
    // MARK: Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        webView.delegate = self
        
        navigationItem.title = "TheMovieDB Auth"
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .Plain, target: self, action: "cancelAuth")
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if let urlRequest = urlRequest {
            webView.loadRequest(urlRequest)
        }
    }
    
    // MARK: Cancel Auth Flow
    
    func cancelAuth() {
        dismissViewControllerAnimated(true, completion: nil)
    }
}

// MARK: - TMDBAuthViewController: UIWebViewDelegate

extension TMDBAuthViewController: UIWebViewDelegate {
    
    // TODO: Add implementation here
    func webViewDidFinishLoad(webView: UIWebView){
        if webView.request!.URL!.absoluteString == "\(TMDBClient.Constants.AuthorizationURL)\(requestToken!)/allow" {
            dismissViewControllerAnimated(true) {
                self.completionHandlerForView!(success: true, errorString: nil)
            }
        }
    }
}
