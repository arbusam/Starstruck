//
//  ViewController.swift
//  ChatStar
//
//  Created by Arhan Busam on 7/3/2023.
//

import UIKit
import MessageKit
import InputBarAccessoryView

// Globals
let sender = Sender(senderId: "self", displayName: "You")
var messages =  [MessageType]()

var alertShown = UserDefaults.standard.bool(forKey: "alertShown")

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
                let image = UIImage(systemName: "eraser.fill")?.applyingSymbolConfiguration(UIImage.SymbolConfiguration(pointSize: 30))
                button.image = image
                button.setSize(CGSize(width: 30, height: 30), animated: false)
            }.onSelected {button in
                self.clearTapped()
            }
        messageInputBar.leftStackView.alignment = .center
        messageInputBar.setStackViewItems([button], forStack: .left, animated: false)
        messageInputBar.setLeftStackViewWidthConstant(to: 40, animated: false)
//        let label = InputLabelItem(text: "0/5", backgroundColour: UIColor.green.cgColor, frame: CGRect(x: 0, y: 0, width: 20, height: 20))
        reloadMessagesCount()
        
        // Make the messages appear.
        
//        apiManager.chat(with: "Steve Jobs", message: "What is your perspective on Google Pixel phones?")
    }
    
    @objc func clearTapped() {
        if let bot = chatBot {
            messages.removeAll()
            messages.append(MyMessage(sender: bot, messageId: "0", sentDate: Date(), kind: .text("Hello, I'm \(currentBotName). How can I help you?")))
            messagesCollectionView.reloadData()
            reloadMessagesCount()
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
            let image: UIImage? = UIImage(systemName: "person.circle")?.withConfiguration(UIImage.SymbolConfiguration(hierarchicalColor: UIColor(red: 0, green: 114/255, blue: 248/255, alpha: 1)))
            avatarView.set(avatar: Avatar(image: image))
            avatarView.backgroundColor = .clear
        } else if message.sender.senderId == chatBot?.senderId {
            avatarView.set(avatar: Avatar(image: UIImage(imageLiteralResourceName: "botSymbol")))
            avatarView.backgroundColor = UIColor.white
            avatarView.tintColor = UIColor.white
        } else {
            print("Sender ID does not match when looking for avatar")
        }
    }
    
}

extension ChatViewController: InputBarAccessoryViewDelegate {
    fileprivate func reloadMessagesCount() {
        if let countButton = self.messageInputBar.bottomStackView.subviews.first {
            countButton.removeFromSuperview()
        }
        var userMessages = [MyMessage]()
        for message in messages {
            if message.sender.senderId == self.currentSender().senderId {
                userMessages.append(message as! MyMessage)
            }
        }
        let labelButton = InputBarButtonItem()
            .configure { button in
                button.setTitle("\(userMessages.count)/5", for: .normal)
                button.setTitleColor(UIColor.black, for: .normal)
                if userMessages.count <= 2 {
                    button.layer.backgroundColor = UIColor.green.cgColor
                } else if userMessages.count <= 4 {
                    button.layer.backgroundColor = UIColor.yellow.cgColor
                } else {
                    button.layer.backgroundColor = UIColor.red.cgColor
                }
                
                button.layer.cornerRadius = 5
            }.onSelected {button in
                self.botAlert.showAlert(with: "Max Messages", message: "You can only send up to 5 messages in one conversation without refreshing it. To refresh a conversation, click on the eraser button.", on: self)
            }
        
        self.messageInputBar.bottomStackView.addArrangedSubview(labelButton)
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
            self.reloadMessagesCount()
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
          
          self.reloadMessagesCount()
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
        var userMessages = [MyMessage]()
        for message in messages {
            if message.sender.senderId == self.currentSender().senderId {
                userMessages.append(message as! MyMessage)
            }
        }
        if userMessages.count >= 6 {
            botAlert.showAlert(with: "Conversation Limit Reached", message: "You can not send any more messages this conversation as you have reached the conversation limit of 5 messages. Please click the eraser button to reset the conversation and keep sending messages.", on: self)
            return
        }
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
            self.addMessage(text, as: self.chatBot!)
            DispatchQueue.main.async {
                self.setTypingIndicatorViewHidden(true, animated: true)
                inputBar.sendButton.stopAnimating()
                self.loading = false
                self.fails = 0
            }
        })
    }
    
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        if loading { return }
        setTypingIndicatorViewHidden(false, animated: true)
        inputBar.inputTextView.text = String()
        inputBar.sendButton.startAnimating()
        loading = true
        addMessage(text, as: currentSender() as! Sender)
        // Send the message to the API
        var myMessages = [MyMessage]()
        for message in messages {
            if let myMessage = message as? MyMessage {
                myMessages.append(myMessage)
            }
        }
        
        sendMessage(myMessages, inputBar)
    }
}

extension ChatViewController: MessagesDisplayDelegate, MessagesLayoutDelegate {
    func backgroundColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        if message.sender.senderId == currentSender().senderId {
            return UIColor(red: 0, green: 114/255, blue: 248/255, alpha: 1)
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
