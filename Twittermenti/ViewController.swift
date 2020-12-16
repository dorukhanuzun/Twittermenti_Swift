import UIKit
import SwifteriOS
import CoreML
import SwiftyJSON

class ViewController: UIViewController {
    
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var sentimentLabel: UILabel!
    
    let tweetCount = 100
    
    let sentimentClassifier = TweetSentimentClassifier()

    let swifter = Swifter(consumerKey: "N4mpNHxvrkYrORceuqo8IL7DY", consumerSecret: "gYprUCnNlVPXKSl312AYXevMrBaV59zsFGG9j1xUBa155lpLD0")

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func predictPressed(_ sender: Any) {
        fetchTweets()
    }
    
    func fetchTweets() {
        if let searchText = textField.text {
            
            swifter.searchTweet(using: searchText, lang: "en", count: tweetCount, tweetMode: .extended) { (results, metaData) in

                var tweets = [TweetSentimentClassifierInput]()
                
                for i in 0..<self.tweetCount {
                    if let tweet = results[i]["full_text"].string {
                        let tweetForClassification = TweetSentimentClassifierInput(text: tweet)
                        tweets.append(tweetForClassification)
                    }
                }
                
                self.makePrediction(with: tweets)
                
            } failure: { (error) in
                print("There was an error while fetching the data from Twitter API, \(error)")
            }
        }
    }
    
    func makePrediction(with tweets: [TweetSentimentClassifierInput]) {
        do{
            let predictions = try self.sentimentClassifier.predictions(inputs: tweets)
            
            var sentimentScore = 0
            
            for prediction in predictions {
                let sentiment = prediction.label
                
                if sentiment == "Pos" {
                    sentimentScore += 1
                }else if sentiment == "Neg" {
                    sentimentScore -= 1
                }
                
                updateUI(score: sentimentScore)
                
            }
        }catch {
            print(error)
        }
    }
    
    func updateUI(score sentimentScore: Int) {
        
        if sentimentScore > 20 {
            self.sentimentLabel.text = "😻"
        }else if sentimentScore > 10 {
            self.sentimentLabel.text = "😀"
        }else if sentimentScore > 0 {
            self.sentimentLabel.text = "🙂"
        }else if sentimentScore > -10 {
            self.sentimentLabel.text = "🙁"
        }else if sentimentScore > -20 {
            self.sentimentLabel.text = "😠"
        }else {
            self.sentimentLabel.text = "🤮"
        }
    }
}

