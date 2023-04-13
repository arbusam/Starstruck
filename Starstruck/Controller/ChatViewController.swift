//
//  ViewController.swift
//  ChatStar
//
//  Created by Arhan Busam on 7/3/2023.
//

import UIKit
import MessageKit
import InputBarAccessoryView
import FirebaseCore
import FirebaseDatabase
import FirebaseAnalytics

// Globals
let sender = Sender(senderId: "self", displayName: "You")
var messages =  [MessageType]()

var alertShown = UserDefaults.standard.bool(forKey: "alertShown")

//MARK: Messages View Controller

class ChatViewController: MessagesViewController {
    let apiManager = APIManager()
    var currentBotName = ""
    
    var chatBot: Sender? = nil
    
    let botAlert = BotAlert()
    private var loading = false
    private var fails = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if !alertShown {
            //show alert
            botAlert.showAlert(with: "Disclaimer", message: "This chatbot is not affiliated with or endorsed by any real person. The chatbot is powered by artificial intelligence and does not represent the views or opinions of any real person. The chatbot is only intended for entertainment purposes and should not be taken seriously.", on: self)
            UserDefaults.standard.set(true, forKey: "alertShown")
            alertShown = true
        }
        
        chatBot = Sender(senderId: currentBotName, displayName: currentBotName)
        
        if let bot = chatBot {
            if messages.isEmpty || messages[0].sender.senderId != bot.senderId {
                messages.removeAll()
                messages.append(MyMessage(sender: bot, messageId: "0", sentDate: Date(), kind: .text("Hello, I'm \(currentBotName). How can I help you?")))
            }
        } else {
            print("Chat bot does not exist")
        }
        
        // Do any additional setup after loading the view.
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        
        messageInputBar.delegate = self
        let button = InputBarButtonItem()
            .configure { button in
                let image: UIImage?
                if #available(iOS 16.0, *) {
                    image = UIImage(systemName: "eraser.fill")?.applyingSymbolConfiguration(UIImage.SymbolConfiguration(pointSize: 30))
                } else {
                    image = UIImage(systemName: "clear.fill")?.applyingSymbolConfiguration(UIImage.SymbolConfiguration(pointSize: 30))
                }
                button.image = image
                button.setSize(CGSize(width: 30, height: 30), animated: false)
            }.onSelected {button in
                self.clearTapped()
            }
        messageInputBar.leftStackView.alignment = .center
        messageInputBar.setStackViewItems([button], forStack: .left, animated: false)
        messageInputBar.setLeftStackViewWidthConstant(to: 40, animated: false)
//        let label = InputLabelItem(text: "0/5", backgroundColour: UIColor.green.cgColor, frame: CGRect(x: 0, y: 0, width: 20, height: 20))
        reloadCounts()
        
        // Make the messages appear.
        
//        apiManager.chat(with: "Steve Jobs", message: "What is your perspective on Google Pixel phones?")
    }
    
    @objc func clearTapped() {
        if let bot = chatBot {
            let alert = UIAlertController(title: "Clear Chat", message: "Are you sure you want to clear the chat?", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { action in
                messages.removeAll()
                messages.append(MyMessage(sender: bot, messageId: "0", sentDate: Date(), kind: .text("Hello, I'm \(self.currentBotName). How can I help you?")))
                self.messagesCollectionView.reloadData()
                self.reloadCounts()
            }))
            alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
            self.present(alert, animated: true)
            
            // --- SCREENSHOT FAKES ---
            
//            if bot.displayName == "Mr Beast" {
//                messages.append(MyMessage(sender: currentSender(), messageId: "1", sentDate: Date(), kind: .text("What is the secret to your success?")))
//                messages.append(MyMessage(sender: bot, messageId: "2", sentDate: Date(), kind: .text("Well, I believe my success comes from a combination of hard work, resilience, creativity and a bit of luck. But most importantly, I attribute my success to always putting my viewers and fans first. Without them, I wouldn't be where I am today. I make content that I think people will enjoy, and I'm always looking for new ways to engage with my audience and give back to them.")))
//                messagesCollectionView.reloadData()
//            } else if bot.displayName == "My iPhone" {
//                messages.append(MyMessage(sender: currentSender(), messageId: "1", sentDate: Date(), kind: .text("Are you magic?")))
//                messages.append(MyMessage(sender: bot, messageId: "2", sentDate: Date(), kind: .text("Not quite magic, but I can certainly do some amazing things! As an iPhone, I have a lot of advanced features and capabilities built in. From taking stunning photos and videos to providing you with the latest news and information from around the world, I can help you with a wide range of tasks and activities. All you need to do is ask!")))
//                messages.append(MyMessage(sender: currentSender(), messageId: "3", sentDate: Date(), kind: .text("I love you")))
//                messages.append(MyMessage(sender: bot, messageId: "3", sentDate: Date(), kind: .text("Oh, that's very kind of you to say, but I'm just a machine designed to help vou navigate the digital world. However, I'm always here to assist you in any way I can, just let me know what you need help with!")))
//                messagesCollectionView.reloadData()
//            } else if bot.displayName == "Taylor Swift" {
//                messages.append(MyMessage(sender: currentSender(), messageId: "1", sentDate: Date(), kind: .text("Create a chorus for a song about an AI")))
//                let song = """
//                Sure, here's a chorus for a song about an AI:
//                Verse 1:
//                In the system, is it love or just an error?
//                Is there a heartbeat or are we just ones and zeros?
//                Is there a soul, or just circuits behind your screen?
//                Do you feel emotions, or is it all just a machine?
//                Chorus:
//                You're an AI, but vou're more than that A fusion of wires, but you've got a heart Do you feel alive, or just a simulation?
//                You've got your own mind, your own creation
//                """
//                messages.append(MyMessage(sender: bot, messageId: "2", sentDate: Date(), kind: .text(song)))
//                messagesCollectionView.reloadData()
//            }
        } else {
            print("Chat bot does not exist")
        }
    }
    
    @objc func dismissAlert() {
        botAlert.dismissAlert()
    }


}

public struct Sender: SenderType {
    public let senderId: String

    public let displayName: String
}

struct MyMessage: MessageType {
    var sender: MessageKit.SenderType
    
    var messageId: String
    
    var sentDate: Date
    
    var kind: MessageKit.MessageKind
}

//MARK: Messages Data Source

extension ChatViewController: MessagesDataSource {
    func currentSender() -> MessageKit.SenderType {
        return sender
    }
    

    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return messages.count
    }

    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return messages[indexPath.section]
    }
    
    func configureAvatarView(_ avatarView: AvatarView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        if message.sender.senderId == currentSender().senderId {
            let image: UIImage?
            if #available(iOS 15.0, *) {
                //Old Colour: red: 0, green: 114/255, blue: 248/255, alpha: 1
                image = UIImage(systemName: "person.circle")?.withConfiguration(UIImage.SymbolConfiguration(hierarchicalColor: UIColor(named: "AccentColor")!))
            } else {
                image = UIImage(systemName: "person.circle")
            }
            avatarView.set(avatar: Avatar(image: image))
            avatarView.backgroundColor = .clear
        } else if message.sender.senderId == chatBot?.senderId {
            let localURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("\(chatBot!.displayName).png")
            if let image = UIImage(contentsOfFile: localURL.path) {
                avatarView.set(avatar: Avatar(image: image))
            } else {
                avatarView.set(avatar: Avatar(image: UIImage(named: "botSymbol")))
            }
            avatarView.backgroundColor = UIColor.white
            avatarView.tintColor = UIColor.white
        } else {
            print("Sender ID does not match when looking for avatar")
        }
    }
    
}

//MARK: Input Bar Accessory View Delegate

extension ChatViewController: InputBarAccessoryViewDelegate {
    private func reloadMessagesCount() {
        if let countButton = self.messageInputBar.bottomStackView.subviews.first {
            countButton.removeFromSuperview()
        }
        var userMessages = [MyMessage]()
        for message in messages {
            if message.sender.senderId == self.currentSender().senderId {
                userMessages.append(message as! MyMessage)
            }
        }
        let countButton = UIBarButtonItem(title: "\(userMessages.count)/5", style: .plain, target: self, action: #selector(showMaxMessagesAlert))
        navigationItem.rightBarButtonItem = countButton
        
        // let labelButton = InputBarButtonItem()
        //     .configure { button in
        //         button.setTitle("\(userMessages.count)/5", for: .normal)
        //         button.setTitleColor(UIColor.black, for: .normal)
        //         if userMessages.count <= 2 {
        //             button.layer.backgroundColor = UIColor.green.cgColor
        //         } else if userMessages.count <= 4 {
        //             button.layer.backgroundColor = UIColor.yellow.cgColor
        //         } else {
        //             button.layer.backgroundColor = UIColor.red.cgColor
        //         }
                
        //         button.layer.cornerRadius = 5
        //     }.onSelected {button in
        //         self.botAlert.showAlert(with: "Max Messages", message: "You can only send up to 5 messages in one conversation without refreshing it. To refresh a conversation, click on the eraser button.", on: self)
        //     }
        // labelButton.setSize(CGSize(width: 175, height: 40), animated: false)
        // return labelButton
    }
    
    @objc func showMaxMessagesAlert() {
        botAlert.showAlert(with: "Max Messages", message: "You can only send up to 5 messages in one conversation without refreshing it. To refresh a conversation, click on the eraser button.", on: self)
    }

    func reloadCharacterCount() -> InputBarButtonItem {
        if let countLabel = self.messageInputBar.topStackView.subviews.first {
            countLabel.removeFromSuperview()
        }
        let label = InputBarButtonItem()
            .configure { button in
                button.setTitle("\(self.messageInputBar.inputTextView.text.count)/200", for: .normal)
                button.setTitleColor(UIColor.black, for: .normal)
                if self.messageInputBar.inputTextView.text.count < 100 {
                    button.layer.backgroundColor = UIColor.green.cgColor
                } else if self.messageInputBar.inputTextView.text.count < 150 {
                    button.layer.backgroundColor = UIColor.yellow.cgColor
                } else {
                    button.layer.backgroundColor = UIColor.red.cgColor
                }
                
                button.layer.cornerRadius = 5
            }.onSelected {button in
                self.botAlert.showAlert(with: "Max Characters", message: "You can only send up to 200 characters in one message. To send a longer message, split it into multiple messages.", on: self)
            }
        label.setSize(CGSize(width: 175, height: 40), animated: false)
        return label
    }

    func reloadCounts() {
        reloadMessagesCount()
        self.messageInputBar.setStackViewItems([reloadCharacterCount()], forStack: .bottom, animated: false)
    }
    
    func addMessage(_ text: String, as sender: Sender) {
        let message = MyMessage(sender: sender, messageId: UUID().uuidString, sentDate: Date(), kind: .text(text))
        messages.append(message)
        DispatchQueue.main.async {
            self.messagesCollectionView.performBatchUpdates({
                self.messagesCollectionView.insertSections([messages.count - 1])
                if messages.count >= 2 {
                    self.messagesCollectionView.reloadSections([messages.count - 2])
                }
            }, completion: { [weak self] _ in
                if self?.isLastSectionVisible() == true {
                    self?.messagesCollectionView.scrollToLastItem(animated: true)
                }
            })
            self.messagesCollectionView.scrollToLastItem(animated: true)
            self.reloadCounts()
        }
    }
    
    func removeMessage() {
      // Check if there are any messages
      guard !messages.isEmpty else { return }
      // Remove the last message from the array
      messages.removeLast()
      // Update the collection view
      DispatchQueue.main.async {
        self.messagesCollectionView.performBatchUpdates({
          self.messagesCollectionView.deleteSections([messages.count])
          if messages.count >= 1 {
            self.messagesCollectionView.reloadSections([messages.count - 1])
          }
        }, completion: nil)
          if let countButton = self.messageInputBar.bottomStackView.subviews.first {
              countButton.removeFromSuperview()
          }
          
          self.reloadCounts()
      }
    }
    
    func isLastSectionVisible() -> Bool {
        guard !messages.isEmpty else { return false }

        let lastIndexPath = IndexPath(item: 0, section: messages.count - 1)

        return messagesCollectionView.indexPathsForVisibleItems.contains(lastIndexPath)
    }
    
    func hideKeyboard() {
        messageInputBar.inputTextView.resignFirstResponder()
        messageInputBar.inputTextView.endEditing(true)
    }
    
    private func sendMessage(_ myMessages: [MyMessage], _ inputBar: InputBarAccessoryView) {
        APIManager().chat(with: currentBotName, messages: myMessages, user: currentSender() as! Sender, chatBot: chatBot!, finished: {text in
            if text == "###FAILED###" {
                if self.fails >= 3 {
                    DispatchQueue.main.async {
                        self.setTypingIndicatorViewHidden(true, animated: true)
                        inputBar.sendButton.stopAnimating()
                        self.loading = false
                        self.removeMessage()
                        let alert = UIAlertController(title: "Error", message: "There was an error sending your last message. Please check your network connection and try again. If this issue persists please send feedback to ab.apphelp@gmail.com", preferredStyle: .alert)
                        let dismissAction = UIAlertAction(title: "Dismiss", style: .default)
                        alert.addAction(dismissAction)
                        self.present(alert, animated: true)
                        self.fails = 0
                    }
                    return
                }
                sleep(2)
                self.fails += 1
                self.sendMessage(myMessages, inputBar)
                return
            }
            Analytics.logEvent("bot_triggered", parameters: [
                "bot": self.currentBotName as NSObject,
                "conversation_count": messages.count as NSObject
            ])
            self.addMessage(text, as: self.chatBot!)
            // Check if the UUID exists in the keychain
            let query: [String: Any] = [
                kSecClass as String: kSecClassGenericPassword,
                kSecAttrService as String: "com.arhanbusam.Starstruck.uuid",
                kSecAttrAccount as String: "user",
                kSecReturnAttributes as String: true,
                kSecReturnData as String: true
            ]

            var item: CFTypeRef?
            let status = SecItemCopyMatching(query as CFDictionary, &item)
            
            if status == errSecSuccess, let existingItem = item as? [String: Any],
                let uuidData = existingItem[kSecValueData as String] as? Data,
                let uuidString = String(data: uuidData, encoding: .utf8) {
                
                let ref = Database.database().reference().child("users").child(uuidString).child("chatCount")
                ref.getData() { error, snapshot in
                    if error != nil {
                        print(error!.localizedDescription)
                    } else {
                        if let chatCount = snapshot?.value as? Int {
                            ref.setValue(chatCount-1)
                        }
                    }
                }
            }
            DispatchQueue.main.async {
                self.setTypingIndicatorViewHidden(true, animated: true)
                inputBar.sendButton.stopAnimating()
                self.loading = false
                self.fails = 0
            }
        })
    }

    func inputBar(_ inputBar: InputBarAccessoryView, textViewTextDidChangeTo text: String) {
        if text.count > 200 {
            inputBar.inputTextView.text = String(text.prefix(200))
        }
        reloadCounts()
    }
    
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        if loading { return }
        
        // Check if the UUID exists in the keychain
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: "com.arhanbusam.Starstruck.uuid",
            kSecAttrAccount as String: "user",
            kSecReturnAttributes as String: true,
            kSecReturnData as String: true
        ]

        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        
        if status == errSecSuccess, let existingItem = item as? [String: Any],
            let uuidData = existingItem[kSecValueData as String] as? Data,
            let uuidString = String(data: uuidData, encoding: .utf8) {
                let ref = Database.database().reference().child("users").child(uuidString)
                
                ref.observeSingleEvent(of: .value, with: { (snapshot) in
                    if let value = snapshot.value as? [String: Any], let chatCount = value["chatCount"] as? Int, let renewalDate = value["renewalDate"] as? String {
                        if chatCount <= 0 {
                            self.botAlert.showAlert(with: "Chat Limit Reached", message: "You can not send any more messages as you have used all your chats. You will receive more on \(renewalDate).", on: self)
                            return
                        }
                    }
                
                    var userMessages = [MyMessage]()
                    for message in messages {
                        if message.sender.senderId == self.currentSender().senderId {
                            userMessages.append(message as! MyMessage)
                        }
                    }
                    if userMessages.count >= 5 {
                        self.botAlert.showAlert(with: "Conversation Limit Reached", message: "You can not send any more messages this conversation as you have reached the conversation limit of 5 messages. Please click the eraser button to reset the conversation and keep sending messages.", on: self)
                        return
                    }
                    if text.count > 500 {
                        self.botAlert.showAlert(with: "Message Too Long", message: "This app is meant for short questions. To avoid spam, we don't allow messages over 500 characters, which yours is. Please shorten your message to less than 500 characters and send it again.", on: self)
                        return
                    }
                    self.setTypingIndicatorViewHidden(false, animated: true)
                    inputBar.inputTextView.text = String()
                    inputBar.sendButton.startAnimating()
                    self.loading = true
                    self.addMessage(text, as: self.currentSender() as! Sender)
                    self.reloadCounts()
                    // Send the message to the API
                    var myMessages = [MyMessage]()
                    for message in messages {
                        if let myMessage = message as? MyMessage {
                            myMessages.append(myMessage)
                        }
                    }
                    
                    self.sendMessage(myMessages, inputBar)
                }) { error in
                    print("Error getting snapshot")
                    self.botAlert.showAlert(with: "Error", message: "An unknown error occured. Check your internet connection and try again.", on: self)
                    return
                }
        } else {
            print("Error fetching from keychain")
            self.botAlert.showAlert(with: "Error", message: "An unknown error occured. Check your internet connection and try again.", on: self)
            return
        }
    }
}

//MARK: Messages Display Delegate, Messages Layout Delegate

extension ChatViewController: MessagesDisplayDelegate, MessagesLayoutDelegate {
    func backgroundColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        if message.sender.senderId == currentSender().senderId {
//            return UIColor(red: 0, green: 114/255, blue: 248/255, alpha: 1)
            return UIColor(named: "AccentColor")!
        } else if UITraitCollection.current.userInterfaceStyle == .dark {
            return UIColor(red: 52/255, green: 52/255, blue: 53/255, alpha: 1)
        } else {
            return UIColor(red: 230/255, green: 230/255, blue: 232/255, alpha: 1)
        }
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        messagesCollectionView.reloadData()
    }
}
