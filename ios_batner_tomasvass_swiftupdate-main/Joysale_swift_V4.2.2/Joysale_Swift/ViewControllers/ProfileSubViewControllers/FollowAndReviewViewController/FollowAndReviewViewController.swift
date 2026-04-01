//
//  FollowAndReviewViewController.swift
//  Joysale_Swift
//
//  Created by Hitasoft on 11/07/20.
//  Copyright © 2020 Hitasoft. All rights reserved.
//

import UIKit

class FollowAndReviewViewController: UIViewController {

    @IBOutlet weak var bottomLoader: UIActivityIndicatorView!
    @IBOutlet weak var noItemDesLabel: UILabel!
    @IBOutlet weak var noItemTitleLabel: UILabel!
    @IBOutlet weak var noItemStackView: UIStackView!

    @IBOutlet weak var tableView: UITableView!
    var viewModel = ProfileViewModel()
    var userId = ""
    
    var followersListArray = [FollowerResultModel]()
    var follwingListArray = [FollowerResultModel]()
    var reviewListArray = [ReviewResultModel]()

    var offset = 0
    var isFound = true
    private let refreshControl = UIRefreshControl()
    // Own User Follwed IDS
    var follwedArray = [String]()
    let delegate = UIApplication.shared.delegate as! AppDelegate
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return self.updateStatusBarStyle()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
       
//        self.configUI()
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        self.updateTheme(page: "present")
        self.configUI()
    }
    
    func configUI() {
        self.noItemStackView.isHidden = true
        self.noItemTitleLabel.config(color: UIColor(named: "AppTextColor"), font: UIFont(name: APP_FONT_REGULAR, size: 15), align: .center, text: "sorry")
        var descString = self.view.tag == 2 ? "noFollowers" : self.view.tag == 3 ? "noFollowing" : "noreviewyet"
        if userId != UserDefaultModule.shared.getUserData()?.user_id ?? "" && self.view.tag == 3{
            descString = "other_user_no_following"
        }
        self.noItemDesLabel.config(color: UIColor(named: "SecondaryTextColor"), font: UIFont(name: APP_FONT_REGULAR, size: 14), align: .center, text: descString)

        self.tableView.register(UINib(nibName: "FollowAndReviewTableCell", bundle: nil), forCellReuseIdentifier: "FollowAndReviewTableCell")
        
        self.tableView.sectionHeaderHeight = UITableView.automaticDimension
        self.tableView.estimatedSectionHeaderHeight = 50
        if #available(iOS 10.0, *) {
            self.tableView.refreshControl = refreshControl
        } else {
            self.tableView.addSubview(refreshControl)
        }
        self.refreshControl.addTarget(self, action: #selector(self.refreshAct), for: .valueChanged)
        self.offset = 0
        self.isFound = true
        self.loadData()

    }
    @objc func refreshAct() {
        self.offset = 0
        self.isFound = true
        self.followersListArray.removeAll()
        self.follwingListArray.removeAll()
        self.reviewListArray.removeAll()
        self.tableView.reloadData()
        self.loadData()
    }
    func loadData() {
        let group = DispatchGroup()
        self.refreshControl.beginRefreshing()
        if self.view.tag == 2 {
            group.enter()
            self.viewModel.getFollwerData(user_id: UserDefaultModule.shared.getUserData()?.user_id ?? "", offset: "\(self.offset)",profile_id: userId, onSuccess: { (success) in
                
                if !success {
                    self.isFound = false
                    if self.followersListArray.count == 0 {
                        self.noItemStackView.isHidden = false
                    }
                    else {
                        self.noItemStackView.isHidden = true
                    }
                }
                else {
                    if self.offset == 0 {
                        self.followersListArray.removeAll()
                    }
                    if self.viewModel.followerListModel?.result != nil {
                        self.followersListArray += self.viewModel.followerListModel!.result
                    }
                    else {
                        self.isFound = false
                    }
                    if self.followersListArray.count == 0 {
                        self.noItemStackView.isHidden = false
                    }
                    else {
                        self.noItemStackView.isHidden = true
                    }
                }
                group.leave()
            }) { (failure) in
                self.noItemStackView.isHidden = false
                group.leave()
            }
        }
        else if self.view.tag == 3 {
            group.enter()
            self.viewModel.getFollowingData(user_id: UserDefaultModule.shared.getUserData()?.user_id ?? "", offset: "\(self.offset)",profile_id: userId, onSuccess: { (success) in
                if !success {
                    self.isFound = false
                    if self.follwingListArray.count == 0 {
                        self.noItemStackView.isHidden = false
                    }
                    else {
                        self.noItemStackView.isHidden = true
                    }
                }
                else {
                    if self.offset == 0 {
                        self.follwingListArray.removeAll()
                    }
                    if self.viewModel.followingListModel?.result != nil {
                        self.follwingListArray += self.viewModel.followingListModel!.result
                    }
                    if self.follwingListArray.count == 0 {
                        self.noItemStackView.isHidden = false
                    }
                    else {
                        self.noItemStackView.isHidden = true
                    }
                }
                group.leave()
            }) { (failure) in
                self.noItemStackView.isHidden = false
                group.leave()
            }
        }
        else {
            group.enter()
            self.viewModel.getReviewDeta(user_id: UserDefaultModule.shared.getUserData()?.user_id ?? "", offset: "\(self.offset)",profile_id: userId, onSuccess: { (success) in
                if !success {
                    self.isFound = false
                    if self.reviewListArray.count == 0 {
                        self.noItemStackView.isHidden = false
                    }
                    else {
                        self.noItemStackView.isHidden = true
                    }
                }
                else {
                    if self.offset == 0 {
                        self.reviewListArray.removeAll()
                    }
                    if self.viewModel.reviewModel?.result != nil {
                        self.reviewListArray += self.viewModel.reviewModel!.result
                    }
                    if self.reviewListArray.count == 0 {
                        self.noItemStackView.isHidden = false
                    }
                    else {
                        self.noItemStackView.isHidden = true
                    }
                }
                group.leave()
            }) { (failure) in
                self.noItemStackView.isHidden = false
                group.leave()
            }
        }
        group.enter()
        self.viewModel.getFollowedUserId(user_id: (UserDefaultModule.shared.getUserData()?.user_id ?? ""), onSuccess: { (success) in
            self.follwedArray.removeAll()
            if success {
                if self.viewModel.followerModel?.result != nil {
                    self.follwedArray = self.viewModel.followerModel?.result ?? [String]()
                }
            }
            group.leave()
        }) { (failure) in
            group.leave()
        }
        group.notify(queue: DispatchQueue.main) {
            self.bottomLoader.stopAnimating()
            self.refreshControl.endRefreshing()
            self.tableView.reloadData()
        }
    }
}
extension FollowAndReviewViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        if self.view.tag == 2 {
            return self.followersListArray.count
        }
        else if self.view.tag == 3 {
            return self.follwingListArray.count
        }
        else {
            return self.reviewListArray.count
        }
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 8
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FollowAndReviewTableCell") as! FollowAndReviewTableCell
        cell.userImageView.isUserInteractionEnabled = true
        cell.userImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.profileImageAct(_:))))
        cell.followButton.tag = indexPath.section
        cell.followButton.addTarget(self, action: #selector(followButtonAct(_:)), for: .touchUpInside)
        cell.userImageView.tag = indexPath.section
        var totalCount = 0
        if self.view.tag != 4 {
            if self.view.tag == 2 {
                cell.loadData(self.followersListArray[indexPath.section], follwedArray: self.follwedArray)
                totalCount = self.followersListArray.count
            }
            else if self.view.tag == 3 {
                cell.loadData(self.follwingListArray[indexPath.section], follwedArray: self.follwedArray)
                totalCount = self.follwingListArray.count
            }
        }
        else {
            if self.reviewListArray.count > indexPath.section {
                cell.loadReviewData(self.reviewListArray[indexPath.section])
            }
            totalCount = self.reviewListArray.count
        }
        if indexPath.row == (totalCount - 1) && self.isFound && totalCount >= 20{
            self.offset = totalCount
            self.bottomLoader.startAnimating()
            self.loadData()
        }
        return cell
    }
    @objc func profileImageAct(_ sender: UITapGestureRecognizer) {
        if let profileViewTag = sender.view?.tag {
            var userVal = ""
            if self.view.tag == 2 {
                if self.followersListArray.count > profileViewTag {
                    userVal = "\(self.followersListArray[profileViewTag].userId ?? 0)"
                }
            }
            else if self.view.tag == 3 {
                if self.follwingListArray.count > profileViewTag {
                    userVal = "\(self.follwingListArray[profileViewTag].userId ?? 0)"
                }
            }
            else if self.view.tag == 4 {
                if (self.reviewListArray.count) > profileViewTag {
                    userVal = "\(self.reviewListArray[profileViewTag].userId ?? 0)"

                }
            }
            if userVal != self.userId {
                let pageObj = ViewProfileViewController()
                pageObj.userId = "\(userVal)"
                self.delegate.navigationController.pushViewController(pageObj, animated: true)
            }
        }
    }
    @objc func followButtonAct(_ sender: UIButton) {
        if (UserDefaultModule.shared.getUserData()?.user_id ?? "" != "") {
            var userId = ""
            if self.view.tag == 2 {
                userId = "\(self.followersListArray[sender.tag].userId ?? 0)"
            }
            else {
                userId = "\(self.follwingListArray[sender.tag].userId ?? 0)"
            }
            
            let type = sender.currentImage == #imageLiteral(resourceName: "Follow") ? "unfollow" : "follow"
            if type == "follow" {
                self.follwedArray.append(userId)
                sender.setImage(#imageLiteral(resourceName: "Follow"), for: .normal)
                sender.backgroundColor = UIColor(named: "AppThemeColorNew")
            }
            else {
                self.follwedArray.removeAll(where: {$0 == userId})
                sender.setImage(#imageLiteral(resourceName: "unFollow"), for: .normal)
                sender.backgroundColor = UIColor(named: "FollwerButtonColor")
            }
            self.viewModel.followUser(user_id: UserDefaultModule.shared.getUserData()?.user_id ?? "", follow_id: userId, type: type, onSuccess: { (success) in
                if !success {
                    self.loadData()
                }
            }) { (failure) in
            }
        }
        else{
            self.delegate.initVC(initialView: InitialViewController())
        }

    }
}
