//
//  HomeViewController.swift
//  Log
//
//  Created by Andrei Villasana on 8/23/17.
//  Copyright © 2017 Andrei Villasana. All rights reserved.
//

import UIKit

class HomeCollectionViewController {
}

class HomeTableViewCell: UITableViewCell {
    @IBOutlet weak var friendPicture: UIImageView!;
    @IBOutlet weak var friendName: UILabel!;
    @IBOutlet weak var mostRecentMessageFromConversation: UILabel!;
    @IBOutlet weak var date: UILabel!
}

class HomeViewController: UIViewController {
    @IBOutlet weak var homeTableView: UITableView!;
    @IBOutlet weak var profileButton: UIButton!
    @IBOutlet weak var friendSearchBar: UISearchBar!
    @IBOutlet weak var newMessageButton: UIButton!

    var recentMessages: [MessageStack] = [];
    var selectedConversationWithFriend: LOGUser?;

    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        fetchRecentMessages();
    }

    func fetchRecentMessages() {
        HomeController.getRecentMessages { [weak self] (responseData) in
            guard let `self` = self else { return }
            guard let username = CoreDataController.getUserProfile()?.email else {
                return;
            }

            for messagePackets in responseData {
                var conversation = MessageStack();
                var friendProfile: LOGUser?;
                var image: UIImage?;

                guard let conversationArray = messagePackets as? NSArray,
                      let recentMessageDict = conversationArray[0] as? [String: Any],
                      let sentBy = recentMessageDict["sentBy"] as? String,
                      let sentTo = recentMessageDict["sentTo"] as? String,
                      let message = recentMessageDict["message"] as? String,
                      let date =  recentMessageDict["created_at"] as? String else {
                        return;
                }
                let imageString: String? = recentMessageDict["image"] as? String;
                let error: String? = recentMessageDict["error"] as? String;

                if imageString != nil {
                    let imageData = NSData(base64Encoded: imageString!, options: NSData.Base64DecodingOptions(rawValue:NSData.Base64DecodingOptions.RawValue(0)));
                    image = UIImage.init(data: imageData! as Data)!;
                } else {
                    image = UIImage(named: "defaultUserIcon");
                }

                switch (username) {
                    case sentBy:
                        friendProfile = LOGUser.init(email: sentTo, firstName: sentTo, lastName: sentTo, picture: image);
                        break;
                    case sentTo:
                        friendProfile = LOGUser.init(email: sentBy, firstName: sentBy, lastName: sentBy, picture: image);
                        break;
                    default:
                        break;
                }

                if let friendProfile = friendProfile {
                    let recentMessage = Message.init(sender: friendProfile, message: message, date: date);
                    conversation.setFriendProfile(friendProfile: friendProfile);
                    conversation.setStackOfMessages(stack: [recentMessage]);
                    self.recentMessages.append(conversation);
                }
            }

            DispatchQueue.main.async {
                self.homeTableView.reloadData();
            }
        }
    }

    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "HomeToMessageSegue") {
            if let messageViewController = segue.destination as? MessageViewController {
                var messageStack = MessageStack();
                messageStack.setFriendProfile(friendProfile: selectedConversationWithFriend);
                messageViewController.friendConversation = messageStack;
            }
        }
    }

    @IBAction func userTappedProfileButton(_ sender: UIButton) {
        let userProfileVC = UserProfileViewController(nibName: "UserProfileViewController", bundle: nil);
        present(userProfileVC, animated: true, completion: nil);
    }
}

extension HomeViewController: UITableViewDelegate, UITableViewDataSource {

    //Table View Delegate Methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recentMessages.count;
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let friendConversationData = recentMessages[indexPath.row];
//        let friendName = friendConversationData.conversationWithFriend?.getFullName();
        let friendEmail = friendConversationData.getFriendProfile()?.getEmail();
        let userImage = friendConversationData.getFriendProfile()?.getPicture();
        let mostRecentMessage = friendConversationData.getStackOfMessages()[0].getMessage();
        let date = friendConversationData.getStackOfMessages()[0].getDate();

        var cell: HomeTableViewCell?;
        cell = homeTableView.dequeueReusableCell(withIdentifier: "Friend Conversation Cell", for: indexPath) as? HomeTableViewCell;
        cell?.friendName.text = friendEmail;
        cell?.friendPicture.image = userImage;
        cell?.mostRecentMessageFromConversation.text = mostRecentMessage;
        cell?.date.text = DateConverter.handleDate(date: date);

        return cell!;
    }

    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        let friendConversationData = recentMessages[indexPath.row];
        selectedConversationWithFriend = friendConversationData.getFriendProfile();
        return indexPath;
    }

}
