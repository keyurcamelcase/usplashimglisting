//
//  UnsplashImageListVC.swift
//  unsplashImages
//
//  Created by Keyur barvaliya on 13/04/24.
//

import UIKit


// Define your collection view layout options
enum LayoutOption {
    case pintrest
    case normal
}

class UnsplashImageListVC: UIViewController {
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var collectionView: UICollectionView!{
        didSet {
            collectionView.register(UINib.init(nibName: "ImageViewCVCell", bundle: nil),forCellWithReuseIdentifier: "ImageViewCVCell")
        }
    }
    var currentLayoutOption: LayoutOption = .pintrest {
        didSet {
            // Update the right bar button item when the layout option changes
            updateRightBarButtonItem()
        }
    }
    
    
    
    
    var photos = [Photo]() // Your data source
    var currentPage = 1
    let perPage = 20 // Number of items per page
    var isLoading = false
    let refreshControl = UIRefreshControl()
    var drawerViewController: DrawerViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Configure collection view
        collectionView.dataSource = self
        collectionView.delegate = self
        
        // Add refresh control
        collectionView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        
        self.title = "Dashboard"
        // Change navigation bar background color
        // Set initial transparency state
        self.navigationController?.navigationBar.isTranslucent = false
        // Create a new instance of UINavigationBarAppearance
        let appearance = UINavigationBarAppearance()
        
        // Configure the appearance as desired
        appearance.backgroundColor = UIColor.init(white: 1, alpha: 0.8) // Set your desired background color
        
        // Set the scroll edge appearance of the navigation bar
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        //        // Create a left navigation bar button
        self.navigationController?.navigationBar.barStyle = .black
        self.navigationController?.navigationBar.tintColor = .black
        
        self.activityIndicator.hidesWhenStopped = true
        self.setupUI()
        self.updateRightBarButtonItem()
        self.startMonitoringInternetStatus()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.stopMonitoringInternetStatus()
    }
    
    func startMonitoringInternetStatus() {
        NetworkManager.shared.startMonitoring()
        NotificationCenter.default.addObserver(self, selector: #selector(handleInternetStatusChanged(_:)), name: .internetStatusChanged, object: nil)
    }
    
    func stopMonitoringInternetStatus() {
        NetworkManager.shared.stopMonitoring()
        NotificationCenter.default.removeObserver(self, name: .internetStatusChanged, object: nil)
    }
    
    // Action method for the right bar button item
    @objc func rightButtonTapped() {
        // Toggle between layout options
        currentLayoutOption = (currentLayoutOption == .pintrest) ? .normal : .pintrest
        
        // Update your collection view layout based on the new option
        self.setupLayout()
    }
    
    @objc func handleInternetStatusChanged(_ notification: Notification) {
        if let isConnected = notification.userInfo?["isConnected"] as? Bool {
            if isConnected {
                self.showToast(message: "Internet is available")
                self.loadData()
            } else {
                print("No internet connection")
                self.showToast(message: "No internet connection")
            }
        }
    }
    
    // Method to update the right bar button item based on the layout option
    private func updateRightBarButtonItem() {
        let buttonImage: UIImage?
        
        switch currentLayoutOption {
        case .pintrest:
            buttonImage = UIImage(named: "grid_icon")
        case .normal:
            buttonImage = UIImage(named: "list_icon")
        }
        
        let rightBarButtonItem = UIBarButtonItem(image: buttonImage, style: .plain, target: self, action: #selector(rightButtonTapped))
        navigationItem.rightBarButtonItem = rightBarButtonItem
    }
    
    
    func setupUI() {
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.setupCollectionViewInsets()
        self.setupLayout()
        self.loadData()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func refreshData() {
        // Reset page count
        currentPage = 1
        
        // Fetch new data
        self.loadData()
    }
    
    
    //MARK: - Collectionview setup layout
    private func setupCollectionViewInsets() {
        self.collectionView.backgroundColor = .clear
        self.collectionView.contentInset = UIEdgeInsets(
            top: 15,
            left: 5,
            bottom: 5,
            right: 5
        )
    }
    
    private func setupLayout() {
        if self.currentLayoutOption == .pintrest {
            let layout: PinterestLayout = {
                if let layout = UICollectionViewLayout() as? PinterestLayout {
                    return layout
                }
                let layout = PinterestLayout()
                self.collectionView.collectionViewLayout = layout
                //            collectionView?.collectionViewLayout = layout
                
                return layout
            }()
            layout.delegate = self
            layout.cellPadding = 5
            layout.numberOfColumns = (DeviceManager.isiPhone == true) ? 2:3
        }else {
            self.collectionView.collectionViewLayout = UICollectionViewFlowLayout()
            let indexPath = IndexPath(item: 0, section: 0)
            self.collectionView.scrollToItem(at: indexPath, at: .top, animated: true)
        }
        DispatchQueue.main.async {
            
            self.collectionView.reloadData()
        }
    }
    
    @objc func showPopupMenu() {
        drawerViewController?.openDrawer()
    }
    
    func handleOptionSelected(option: String) {
        print("Selected option: \(option)")
        // Handle the selected option
    }
    
    func loadData() {
        DispatchQueue.main.async {
            guard !self.isLoading else { return }
            self.isLoading = true
            self.activityIndicator.startAnimating()
            UnsplashAPI.fetchPhotos(page: self.currentPage, perPage: self.perPage) { [weak self] result in
                guard let self = self else { return }
                DispatchQueue.main.async {
                    self.activityIndicator.stopAnimating()
                }
                switch result {
                case .success(let photos):
                    if self.currentPage == 1 {
                        // If it's the first page, replace existing data
                        self.photos = photos
                    } else {
                        // If it's a subsequent page, append to existing data
                        self.photos.append(contentsOf: photos)
                    }
                    
                    self.currentPage += 1
                    DispatchQueue.main.async {
                        self.collectionView.reloadData()
                        self.refreshControl.endRefreshing()
                        self.isLoading = false
                    }
                case .failure(let error):
                    print("Error loading data: \(error)")
                    DispatchQueue.main.async {
                        self.refreshControl.endRefreshing()
                    }
                    self.isLoading = false
                }
            }
            
        }
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}

extension UnsplashImageListVC: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, PinterestLayoutDelegate {
    func collectionView(collectionView: UICollectionView, heightForImageAtIndexPath indexPath: IndexPath, withWidth: CGFloat) -> CGFloat {
        //        let image = UIImage.init(named: "ic_g\(indexPath.row)")
        //        let galleryDetails = self.model.arrayofgallery?[indexPath.row]
        //        let simg = UIImageView()
        //        simg.setImage(url: URL.init(string: galleryDetails?.imgurl ?? ""),placeholderImage: UIImage.init(named: "ic_g0"))
        //        print(image?.height(forWidth: withWidth) ?? 0.0)
        //        return image?.height(forWidth: withWidth) ?? 0.0
        //        return 260.0
        var cellHeight = (DeviceManager.isiPhone == true) ? 125.0:220.0
        if indexPath.row%2 == 0 && indexPath.row != 0 {
            cellHeight = (DeviceManager.isiPhone == true) ? 260.0:320.0
            //            if indexPath.row == 0 {
            //                cellHeight = 260.0
            //            }
        }else if indexPath.row%7 == 0 && indexPath.row != 0 {
            cellHeight = (DeviceManager.isiPhone == true) ? 260.0:320.0
        }else {
            if indexPath.row == 1 {
                cellHeight = (DeviceManager.isiPhone == true) ? 260.0:320.0
            }
        }
        return cellHeight
    }
    
    func collectionView(collectionView: UICollectionView, heightForAnnotationAtIndexPath indexPath: IndexPath, withWidth: CGFloat) -> CGFloat {
        return 0.0
    }
    func collectionView(collectionView: UICollectionView, sizeForSectionHeaderViewForSection section: Int) -> CGSize {
        return CGSize.zero //section == 0 ? CGSize(width: collectionview.bounds.width, height: 66) : CGSize.zero
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.photos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        // Load more data when the last cell is about to be displayed
        if indexPath.item == photos.count - 1 {
            loadData()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageViewCVCell", for: indexPath) as! ImageViewCVCell
        // Get the photo object corresponding to the current index path
        let photo = photos[indexPath.item]
        
        // Check if the image is already cached
        if let cachedImage = ImageCache.shared.getImage(forKey: photo.id) {
            // If cached, use the cached image
            cell.imagView.image = cachedImage
        } else {
            // If not cached, set a placeholder image and start asynchronous image loading
            cell.imagView.image = UIImage(named: "placeholder")
            
            if let urlString = photo.urls["regular"], let url = URL(string: urlString) {
                DispatchQueue.global().async {
                    if let data = try? Data(contentsOf: url), let image = UIImage(data: data) {
                        DispatchQueue.main.async {
                            // Save the downloaded image to the cache
                            ImageCache.shared.setImage(image, forKey: photo.id)
                            
                            // Check if the cell is still displaying the same photo
                            if let currentIndexPath = collectionView.indexPath(for: cell), currentIndexPath == indexPath {
                                // Update the cell's imageView with the downloaded image
                                cell.imagView.image = image
                            }
                        }
                    }
                }
            }
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.bounds.width / 3 - 10 // Adjust spacing as needed
        return CGSize(width: width, height: width+40)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let fullScreenVC = FullScreenImageVC()
        fullScreenVC.photos = photos[indexPath.item]
        let navController = UINavigationController(rootViewController: fullScreenVC)
        navController.modalPresentationStyle = .fullScreen
        present(navController, animated: true, completion: nil)
    }
}

class DrawerViewController: UIViewController {
    
    var mainContentVC: UIViewController!
    var drawerContentVC: UIViewController!
    var drawerWidth: CGFloat = 300 // Default width
    var drawerHeight: CGFloat = 300 // Default height
    var isDrawerOpen = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupMainContent()
        setupDrawerContent()
    }
    
    func setupMainContent() {
        guard let mainContentVC = mainContentVC else {
            fatalError("Main content view controller is not set.")
        }
        
        addChild(mainContentVC)
        view.addSubview(mainContentVC.view)
        mainContentVC.didMove(toParent: self)
        mainContentVC.view.frame = view.bounds
    }
    
    func setupDrawerContent() {
        guard let drawerContentVC = drawerContentVC else {
            fatalError("Drawer content view controller is not set.")
        }
        
        addChild(drawerContentVC)
        view.addSubview(drawerContentVC.view)
        drawerContentVC.didMove(toParent: self)
        drawerContentVC.view.frame = CGRect(x: -drawerWidth, y: view.bounds.height, width: drawerWidth, height: drawerHeight)
    }
    
    func openDrawer() {
        guard !isDrawerOpen else { return }
        
        UIView.animate(withDuration: 0.3) {
            self.drawerContentVC.view.frame.origin.x = 0
            self.isDrawerOpen = true
        }
    }
    
    func closeDrawer() {
        guard isDrawerOpen else { return }
        
        UIView.animate(withDuration: 0.3) {
            self.drawerContentVC.view.frame.origin.x = -self.drawerWidth
            self.isDrawerOpen = false
        }
    }
}

