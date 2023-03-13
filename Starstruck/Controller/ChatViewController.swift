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
        let button = UIButton()
        let image = UIImage(systemName: "eraser.fill")?.applyingSymbolConfiguration(UIImage.SymbolConfiguration(pointSize: 25))
        button.setImage(image, for: .normal)
        button.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        messageInputBar.leftStackView.addArrangedSubview(button)
        messageInputBar.setLeftStackViewWidthConstant(to: 40, animated: false)
        
        // Make the messages appear.
        
//        apiManager.chat(with: "Steve Jobs", message: "What is your perspective on Google Pixel phones?")
    }
    
    @objc func buttonTapped() {
        if let bot = chatBot {
            messages.removeAll()
            messages.append(MyMessage(sender: bot, messageId: "0", sentDate: Date(), kind: .text("Hello, I'm \(currentBotName). How can I help you?")))
            messagesCollectionView.reloadData()
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
      }
    }
    
    func isLastSectionVisible() -> Bool {
        guard !messages.isEmpty else { return false }

        let lastIndexPath = IndexPath(item: 0, section: messages.count - 1)

        return messagesCollectionView.indexPathsForVisibleItems.contains(lastIndexPath)
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
        
        APIManager().chat(with: currentBotName, messages: myMessages, user: currentSender() as! Sender, chatBot: chatBot!, finished: {text in
            if text == "###FAILED###" {
                DispatchQueue.main.async {
                    self.setTypingIndicatorViewHidden(true, animated: true)
                    inputBar.sendButton.stopAnimating()
                    self.loading = false
                    self.removeMessage()
                    let alert = UIAlertController(title: "Error", message: "There was an error sending your last message. Please try again", preferredStyle: .alert)
                    let dismissAction = UIAlertAction(title: "Dismiss", style: .default)
                    alert.addAction(dismissAction)
                    self.present(alert, animated: true)
                }
                return
            }
            self.addMessage(text, as: self.chatBot!)
            DispatchQueue.main.async {
                self.setTypingIndicatorViewHidden(true, animated: true)
                inputBar.sendButton.stopAnimating()
                self.loading = false
            }
        })
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
