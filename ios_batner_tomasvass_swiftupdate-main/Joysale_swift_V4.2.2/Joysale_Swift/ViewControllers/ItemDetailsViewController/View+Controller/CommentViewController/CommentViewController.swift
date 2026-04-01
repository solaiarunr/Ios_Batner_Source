//
//  CommentViewController.swift
//  Joysale_Swift
//
//  Created by Hitasoft on 30/07/20.
//  Copyright © 2020 Hitasoft. All rights reserved.
//

import UIKit

class CommentViewController: UIViewController {
    
    @IBOutlet weak var noCommentsDescLabel: UILabel!
    @IBOutlet weak var noCommentsTitleLabel: UILabel!
    @IBOutlet weak var noCommentsStackView: UIStackView!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var textViewHeightConst: NSLayoutConstraint!
    @IBOutlet weak var itemImageView: UIImageView!
    @IBOutlet weak var itemTitleLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var stackViewBottomConst: NSLayoutConstraint!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var tableView: UITableView!
    var itemModel: ItemModel?
    var viewModel = ItemDetailsViewModel()
    var itemVC: ItemDetailsViewController?
    var intercmntdel: InterCommentDelegate?
    var fromPage = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(indicatorView)
        self.configUI()
        self.stackViewBottomConst.constant = 10
    }
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return self.updateStatusBarStyle()
    }
    
//    override var preferredStatusBarStyle: UIStatusBarStyle {
//          return .lightContent
//    }
    override func viewWillAppear(_ animated: Bool) {
        self.updateTheme(page: "present")
        self.navigationController?.isNavigationBarHidden = true
    }
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = false
    }
    func configUI() {
        self.noCommentsStackView.isHidden = true
        self.noCommentsTitleLabel.config(color: UIColor(named: "AppTextColor"), font: UIFont(name: APP_FONT_REGULAR, size: 15), align: .center, text: "sorry")
        self.noCommentsDescLabel.config(color: UIColor(named: "SecondaryTextColor"), font: UIFont(name: APP_FONT_REGULAR, size: 14), align: .center, text: "nocomments")

        self.titleLabel.config(color: UIColor(named: "whitecolor"), font: UIFont(name: APP_FONT_REGULAR, size: 17), align: .left, text: "comments")
        self.backButton.setImage(#imageLiteral(resourceName: "detail_back").imageFlippedForRightToLeftLayoutDirection(), for: .normal)
        self.itemImageView.cornerViewRadius()
        self.itemImageView.sd_setImage(with: URL(string: self.itemModel?.photos.first?.itemUrlMain350 ?? ""), placeholderImage: #imageLiteral(resourceName: "applogo") , completed: nil)
        self.itemTitleLabel.config(color: UIColor(named: "whitecolor"), font: UIFont(name: APP_FONT_REGULAR, size: 17), align: .right, text: (self.itemModel?.itemTitle ?? ""))

        self.tableView.register(UINib(nibName: "CommentTableViewCell", bundle: nil), forCellReuseIdentifier: "CommentTableViewCell")
        self.tableView.estimatedRowHeight = 70.0  //Give an approximation here
        self.tableView.rowHeight = UITableView.automaticDimension
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow(sender:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide(sender:)), name: UIResponder.keyboardWillHideNotification, object: nil)

        self.setStatusBarBackgroundColor(color: UIColor(named: "AppThemeColor") ?? .black)
        self.sendButton.cornerMiniumRadius()
        self.textView.config(color: UIColor(named: "ThirdryTextColor") ?? .white, font: UIFont(name: APP_FONT_REGULAR, size: 15), align: .left, text: "addcomments")
        self.textView.addDoneButtonOnKeyboard()
        self.textViewHeightConst.priority = .defaultLow
        Utility.shared.startAnimation(viewController: self)
        self.loadData()
    }

    @objc func keyboardWillShow(sender: NSNotification) {
        let info = sender.userInfo!
        let keyboardFrame: CGRect = (info[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        var newHeight = keyboardFrame.height
        if #available(iOS 11.0, *) {
            newHeight = keyboardFrame.height - view.safeAreaInsets.bottom
//            newHeight = keyboardFrame.height - view.safeAreaInsets.bottom + 10
        } else {
            newHeight = keyboardFrame.height
//            newHeight = keyboardFrame.height + 10
        }
        self.stackViewBottomConst.constant = newHeight
        UIView.animate(withDuration: 0.5, animations: { () -> Void in
            self.view.layoutIfNeeded()
            self.tableView.reloadData()
            if let commentData = self.viewModel.commentModel?.result {
                DispatchQueue.main.async {
                    if commentData.comments.count > 1 {
                        self.tableView.scrollToRow(at: IndexPath(row: 0, section: (commentData.comments.count - 1)), at: .bottom, animated: false)
                    }
                }
            }
        })
        print(self.stackViewBottomConst.constant)
        self.viewDidLayoutSubviews()
    }
    @objc func keyboardWillHide(sender: NSNotification) {
        self.stackViewBottomConst.constant = 10
        print(self.stackViewBottomConst.constant)
        UIView.animate(withDuration: 0.5, animations: { () -> Void in
            self.view.layoutIfNeeded()
            self.tableView.reloadData()
            if let commentData = self.viewModel.commentModel?.result {
                DispatchQueue.main.async {
                    if commentData.comments.count > 1 {
                        self.tableView.scrollToRow(at: IndexPath(row: 0, section: (commentData.comments.count - 1)), at: .bottom, animated: false)
                    }
                }
            }
            
        })
    }
    func loadData() {
        self.viewModel.getComments(item_id: "\(self.itemModel?.id ?? 0)", onSuccess: { (success) in
            Utility.shared.stopAnimation(viewController: self)
            self.tableView.reloadData()
        }) { (failure) in
            Utility.shared.stopAnimation(viewController: self)
        }
    }
    @IBAction func backButtonAct(_ sender: UIButton) {
        
        if fromPage == "story"{
            
            self.updateStatusbarBackground()
            if let commentData = self.viewModel.commentModel?.result {
                self.intercmntdel?.commentAct((self.itemModel?.id ?? 0), count: ("\(commentData.comments.count)"))
            }
            else {
                self.intercmntdel?.commentAct((self.itemModel?.id ?? 0), count: "0")
            }
            self.navigationController?.popViewController(animated: true)
        }else{
            if let commentData = self.viewModel.commentModel?.result {
                self.itemVC?.itemDetails?.commentsCount = "\(commentData.comments.count)"
            }
            else {
                self.itemVC?.itemDetails?.commentsCount = "0"
            }
            self.navigationController?.popViewController(animated: true)
        }

        
//        if let commentData = self.viewModel.commentModel?.result {
//            self.itemVC?.itemDetails?.commentsCount = "\(commentData.comments.count)"
//        }
//        else {
//            self.itemVC?.itemDetails?.commentsCount = "0"
//        }
//        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func sendButtonAct(_ sender: UIButton) {
        
        
            if (UserDefaultModule.shared.getUserData()?.user_id ?? "") != "" {
            sender.isUserInteractionEnabled = false
            self.textView.endEditing(true)
            if self.textView.tag == 1 && self.textView.text != ""{
//                Utility.shared.startAnimation(viewController: self)
                self.viewModel.postComment(item_id: "\(self.itemModel?.id ?? 0)", comment: self.textView.text!, onSuccess: { (success) in
                    self.textView.text = ""
                    self.textViewHeightConst.constant = 45
                    self.textViewAct(self.textView)
                    sender.isUserInteractionEnabled = true
//                    Utility.shared.stopAnimation(viewController: self)
                    self.loadData()
                }) { (failure) in
                    sender.isUserInteractionEnabled = true
//                    Utility.shared.stopAnimation(viewController: self)
                }
            }
            
             else {
                sender.isUserInteractionEnabled = true
                let alert = UIAlertController(title: nil, message: getLanguage["please_give_comments"], preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: getLanguage["ok"] ?? "", style: .cancel, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }
        else {
            let vc = InitialViewController()
            vc.modalPresentationStyle = .overFullScreen
            vc.isFromList = true
            self.navigationController?.present(vc, animated: true, completion: nil)
        }
    }
}
extension CommentViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        self.noCommentsStackView.isHidden = false
        if let commentData = self.viewModel.commentModel?.result {
            return commentData.comments.count
        }
        return 0
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 5
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        self.noCommentsStackView.isHidden = true
        let cell = tableView.dequeueReusableCell(withIdentifier: "CommentTableViewCell") as! CommentTableViewCell
        if let commentData = self.viewModel.commentModel?.result.comments[indexPath.section] {
            cell.loadData(commentData)
        }
        cell.moreButton.tag = indexPath.section
        cell.moreButton.addTarget(self, action: #selector(self.moreButtonAct(_:)), for: .touchUpInside)
        cell.profileImageView.isUserInteractionEnabled = true
        cell.profileImageView.tag = indexPath.section
        cell.profileImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.profileImageAct(_:))))
        cell.userNameLabel.isUserInteractionEnabled = true
       cell.userNameLabel.tag = indexPath.section
        cell.userNameLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.profileImageAct(_:))))
        return cell
    }
    @objc func profileImageAct(_ sender: UITapGestureRecognizer) {
        if let commentData = self.viewModel.commentModel?.result.comments[sender.view?.tag ?? 0] {
            self.profileAct(commentData)
        }
    }
    func profileAct(_ commentData: CommentSubModel) {
        let pageObj = ViewProfileViewController()
        pageObj.userId = "\(commentData.userId ?? 0)"
        self.navigationController?.pushViewController(pageObj, animated: true)
    }
    @objc func userNameAct(_ sender: UIImageView) {
        
    }
    @objc func moreButtonAct(_ sender: UIButton) {
        if let commentData = self.viewModel.commentModel?.result.comments[sender.tag] {
            let alert = UIAlertController(title: getLanguage["alert"] ?? "", message: getLanguage["Did you like to delete this comment?"] ?? "", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: getLanguage["cancel"] ?? "", style: .cancel, handler: nil))
            alert.addAction(UIAlertAction(title: getLanguage["ok"] ?? "", style: .default, handler: { (UIAlertAction) in
                self.deleteAct("\(commentData.commentId ?? 0)")
            }))
            self.present(alert, animated: true, completion: nil)
        }
    }
    func deleteAct(_ commentID: String) {
        Utility.shared.startAnimation(viewController: self)
        self.viewModel.deleteComment(item_id: "\(self.itemModel?.id ?? 0)", comment_id: commentID, onSuccess: { (success) in
            Utility.shared.stopAnimation(viewController: self)
            let alert = UIAlertController(title: nil, message: getLanguage[self.viewModel.alertModel?.message ?? ""] ?? (self.viewModel.alertModel?.message ?? ""), preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: getLanguage["ok"] ?? "", style: .cancel, handler: { (UIAlertAction) in
                self.loadData()
            }))
            self.present(alert, animated: true, completion: nil)
        }) { (failure) in
            Utility.shared.stopAnimation(viewController: self)
        }
    }
}
extension CommentViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {

        if textView.frame.height >= 100 {
            textView.isScrollEnabled = true
            self.textViewHeightConst.constant = 100
        }
        else {
            textView.isScrollEnabled = false
            self.textViewHeightConst.constant = textView.frame.height
        }
        textViewAct(textView)
    }
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text.containsEmoji {
            return false
        }
        let strLength = textView.text?.count ?? 0
        let lngthToAdd = text.count
        let lengthCount = strLength + lngthToAdd
        if lengthCount > 120{
            return false
        }
         if text == "\n" {
            if textView.text == "" {
                textView.resignFirstResponder()
                return false
            }
        }
        return true
    }
    func textViewDidBeginEditing(_ textView: UITextView) {
        textViewAct(textView)
    }
   func textViewDidEndEditing(_ textView: UITextView) {
        textViewDidChange(textView)
    }
     
    func textViewAct(_ textView: UITextView) {
        if textView.tag == 0 {
            textView.textColor = UIColor(named: "AppTextColor")
            textView.text = ""
            textView.tag = 1
        }
        else {
            if textView.text == "" && textView.tag == 1{
                textView.text = getLanguage["addcomments"]
                textView.textColor = UIColor(named: "ThirdryTextColor")
                textView.tag = 0
            }
            else {
                textView.textColor = UIColor(named: "AppTextColor")
            }
        }
    }
}
