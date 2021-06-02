//
//  ViewController.swift
//  SimpleWebBrowser
//
//  Created by Артём on 6/2/21.
//

import UIKit
import WebKit

class ViewController: UIViewController {

    @IBOutlet weak var webSearchBar: UISearchBar!
    @IBOutlet weak var toolBar: UIToolbar!
    @IBOutlet weak var backButton: UIBarButtonItem!
    @IBOutlet weak var forwardButton: UIBarButtonItem!
    @IBOutlet weak var refreshButton: UIBarButtonItem!
    
    let webView = WKWebView()
    var progressBar: UIProgressView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupWebView()
        setupNavigationBar()
        setupButtons()
        setupProgressView()
        webView.load(URLRequest(url: URL(string: "https://www.google.com")!))
        webView.navigationDelegate = self
        title = "Loading"
        
    }
    
    
    func setupWebView(){
        view.addSubview(webView)
        webView.allowsBackForwardNavigationGestures = true
        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.topAnchor.constraint(equalTo: self.webSearchBar.bottomAnchor).isActive = true
        webView.bottomAnchor.constraint(equalTo: self.toolBar.topAnchor).isActive = true
        webView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        webView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
    }
    
    func setupButtons(){
        backButton.isEnabled = webView.canGoBack
        forwardButton.isEnabled = webView.canGoForward
        
        webView.addObserver(self, forKeyPath: #keyPath(WKWebView.canGoBack), options: .new, context: nil)
        webView.addObserver(self, forKeyPath: #keyPath(WKWebView.canGoForward), options: .new, context: nil)
    }
    
    
    func setupProgressView(){
        let progressView = UIProgressView(progressViewStyle: .default)
        progressBar = progressView
        view.addSubview(progressView)
        
        progressView.translatesAutoresizingMaskIntoConstraints = false
        progressView.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 1.0).isActive = true
        progressView.topAnchor.constraint(equalTo: self.webSearchBar.bottomAnchor, constant: 5).isActive = true
        progressView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 0).isActive = true
        progressView.setProgress(0.0, animated: true)
        progressView.transform = progressView.transform.scaledBy(x: 1, y: 4)
        progressView.backgroundColor = .gray
        progressView.tintColor = .blue
        
        webView.addObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress), options: .new, context: nil)
        
    }
    
    @IBAction func back(_ sender: Any) {
        if webView.canGoBack{
            webView.goBack()
        }
    }
    @IBAction func forward(_ sender: Any) {
        if webView.canGoForward{
            webView.goForward()
        }
    }
    @IBAction func refresh(_ sender: Any) {
        webView.reload()
    }
}


extension ViewController: UISearchBarDelegate{
    
    func setupNavigationBar(){
        navigationController?.navigationBar.barTintColor = .white
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.black]
        
        overrideUserInterfaceStyle = .light
        
        webSearchBar.placeholder = "Enter URL"
        webSearchBar.isTranslucent = false
        webSearchBar.backgroundImage = UIImage()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        webSearchBar.resignFirstResponder()
        
        if let url = URL(string: webSearchBar.text!){
            webView.load(URLRequest(url: url))
            self.navigationItem.title = self.webView.title
        } else {
            print("URLError")
        }
        
        //        if webSearchBar.text!.hasPrefix("https://") || webSearchBar.text!.hasPrefix("http://"){
        //            let myURL = URL(string: webSearchBar.text!)
        //            let myRequest = URLRequest(url: myURL!)
        //            webView.load(myRequest)
        //        }else {
        //            let correctedURL = "http://\(webSearchBar.text!)"
        //            let myURL = URL(string: correctedURL)
        //            let myRequest = URLRequest(url: myURL!)
        //            webView.load(myRequest)
        //        }
    }
}

extension ViewController: WKNavigationDelegate {
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        self.webView.evaluateJavaScript(
            "document.title"
        ) { (result, error) -> Void in
            self.navigationItem.title = result as? String
        }
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
//            if keyPath == #keyPath(WKWebView.estimatedProgress) {
//                progressBar?.progress = Float(webView.estimatedProgress)
//            }
        
        if let o = object as? WKWebView, o == self.webView {
            
            if keyPath == #keyPath(WKWebView.canGoBack) {
                self.backButton?.isEnabled = self.webView.canGoBack
            } else if keyPath == #keyPath(WKWebView.canGoForward) {
                self.forwardButton?.isEnabled = self.webView.canGoForward
            }
            
            if keyPath == #keyPath(WKWebView.estimatedProgress), let progressView = self.progressBar {
                let newProgress = self.webView.estimatedProgress
                if Float(newProgress) > progressView.progress {
                    progressView.setProgress(Float(newProgress), animated: true)
                } else {
                    progressView.setProgress(Float(newProgress), animated: false)
                }
                if newProgress >= 1 {
                    DispatchQueue.main.asyncAfter(deadline: .now()+0.3, execute: {
                        progressView.isHidden = true
                    })
                } else {
                    progressView.isHidden = false
                }
            }
        }
    }
    
//    если отсуствует интернет подключение
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error:  Error) {
        if(error.localizedDescription == "The Internet connection appears to be offline."){
            print("Network error")
            let alert = UIAlertController(title: "No Network", message: "No network, please check your internet                         connection and try again.", preferredStyle: .alert)
            let ok = UIAlertAction(title: "REFRESH", style: .default) { ( _ ) in
                self.webView.load(URLRequest(url: URL(string: "https://www.google.com")!))
            }
            alert.addAction(ok)
            self.present(alert, animated: true)
        }
    }
    
}


