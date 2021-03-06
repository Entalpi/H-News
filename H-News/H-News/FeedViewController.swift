import UIKit
import SafariServices

class FeedViewController: UITableViewController {
    
    fileprivate var stories: [News] = [] {
        didSet {
            tableView.reloadData()
        }
    }
    
    var generator : Generator? = Generator<News>()
    var downloader: Scraper?   = Scraper<News>()
    
    override func viewDidLoad() {        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 160.0
                
        tableView.register(UINib(nibName: "HNewsTableViewCell", bundle: Bundle.main), forCellReuseIdentifier: HNewsTableViewCell.cellID)
        generator?.next(25, downloader?.fetchNextBatch, onFinish: updateDatasource)
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            clearsSelectionOnViewWillAppear = false
        }
        
        refreshControl = UIRefreshControl()
        refreshControl?.tintColor = Colors.white
        refreshControl?.addTarget(self, action: #selector(FeedViewController.didRefreshFeed(_:)), for: .valueChanged)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard let indexPathForSelectedRow = tableView.indexPathForSelectedRow else { return }
        tableView.deselectRow(at: indexPathForSelectedRow, animated: true)
    }
    
    func didRefreshFeed(_ sender: UIRefreshControl) {
        generator?.reset()
        downloader?.reset()
        stories.removeAll()
        generator?.next(25, downloader?.fetchNextBatch, onFinish: updateDatasource)
    }    
}

// MARK: - Paging
extension FeedViewController {
    fileprivate func updateDatasource(_ items: [News]) {
        stories += items
        refreshControl?.endRefreshing()
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == tableView.dataSource!.tableView(tableView, numberOfRowsInSection: 1) - 5 {
            Dispatcher.async { self.generator?.next(15, self.downloader?.fetchNextBatch, onFinish: self.updateDatasource) }
        }
    }
}

// MARK: - UITableViewDatasource
extension FeedViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return stories.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: HNewsTableViewCell.cellID) as? HNewsTableViewCell else { return UITableViewCell() }
        guard let news = stories[indexPath.row] as? News else { return UITableViewCell() }
        
        cell.story = news
        cell.showCommentsFor = showCommentsFor
        
        return cell
    }
    
    fileprivate func downloadArticle(_ url: URL, newsID: Int) {
        let request = URLRequest(url: url)
        let task = URLSession.shared.dataTask(with: request) { (data, response, err) in
            guard let data = data else { return }
            HNewsReadingPile()?.save(data, newsID: newsID)
        }
        task.resume()
    }
}

// MARK: - UITableViewDelegate
extension FeedViewController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let news = stories[indexPath.row] as? News else { return }
        guard let updatedNews = HNewsReadingPile()?.markNewsAsRead(news) else { return }
        stories[indexPath.row] = updatedNews
        
        switch Settings.browser {
        case .safari:
            UIApplication.shared.open(news.url, options: [:], completionHandler: nil)
        case .safariInApp:
            let safariVC = SFSafariViewController(url: news.url)
            safariVC.preferredBarTintColor = Colors.gray
            safariVC.preferredControlTintColor = Colors.peach
            navigationController?.isNavigationBarHidden = true
            if UIDevice.current.userInterfaceIdiom == .pad {
                let navContr = UINavigationController(rootViewController: safariVC)
                splitViewController?.present(navContr, animated: true)
            } else {
                navigationController?.pushViewController(safariVC, animated: true)
            }
        case .webview:
            let webViewVC = HNewsWebViewController()
            webViewVC.url = news.url
            webViewVC.item = news
            if UIDevice.current.userInterfaceIdiom == .pad {
                let navContr = UINavigationController(rootViewController: webViewVC)
                splitViewController?.present(navContr, animated: true)
            } else {
                navigationController?.pushViewController(webViewVC, animated: true)
            }
        }
    }
}

/// MARK: - Custom tap cell handling for comments
extension FeedViewController {
    func showCommentsFor(_ news: News) {
        let commentsVC = HNewsCommentsViewController()
        commentsVC.news = news
        if UIDevice.current.userInterfaceIdiom == .pad {
            let navContr = UINavigationController(rootViewController: commentsVC)
            splitViewController?.present(navContr, animated: true, completion: nil)
        } else {
            navigationController?.pushViewController(commentsVC, animated: true)
        }
    }
}
