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

class ChatViewController: MessagesViewController {
    let apiManager = APIManager()
    var currentBotName = ""
    
    var chatBot: Sender? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        
        // Make the messages appear.
        
//        apiManager.chat(with: "Steve Jobs", message: "What is your perspective on Google Pixel phones?")
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
    
    func isLastSectionVisible() -> Bool {
        guard !messages.isEmpty else { return false }

        let lastIndexPath = IndexPath(item: 0, section: messages.count - 1)

        return messagesCollectionView.indexPathsForVisibleItems.contains(lastIndexPath)
    }
    
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        setTypingIndicatorViewHidden(false, animated: true)
        inputBar.inputTextView.text = String()
        addMessage(text, as: currentSender() as! Sender)
        // Send the message to the API
        var myMessages = [MyMessage]()
        for message in messages {
            if let myMessage = message as? MyMessage {
                myMessages.append(myMessage)
            }
        }
        
        APIManager().chat(with: currentBotName, messages: myMessages, user: currentSender() as! Sender, chatBot: chatBot!, finished: {text in
            self.addMessage(text, as: self.chatBot!)
            DispatchQueue.main.async {
                self.setTypingIndicatorViewHidden(true, animated: true)
            }
        })
    }
}

extension ChatViewController: MessagesDisplayDelegate, MessagesLayoutDelegate {
    func backgroundColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        return message.sender.senderId == currentSender().senderId ? UIColor(red: 0, green: 114/255, blue: 248/255, alpha: 1) : UIColor(red: 230/255, green: 230/255, blue: 232/255, alpha: 1)
    }
}
