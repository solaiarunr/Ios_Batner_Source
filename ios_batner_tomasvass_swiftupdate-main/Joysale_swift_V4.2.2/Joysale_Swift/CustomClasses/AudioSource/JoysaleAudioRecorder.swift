//
//  KAudioRecorder
//
//  Copyright © 2017 Kenan Atmaca. All rights reserved.
//  kenanatmaca.com
//
//

import UIKit
import AVFoundation

protocol JoyslaeAudioRecorderDelegate {
    func updateTimer(_ time: String)
}

class JoysaleAudioRecorder: NSObject {

    static var shared = JoysaleAudioRecorder()
    
    private var audioSession:AVAudioSession = AVAudioSession.sharedInstance()
    private var audioRecorder:AVAudioRecorder!
    var audioPlayer:AVAudioPlayer = AVAudioPlayer()
    private let settings = [AVFormatIDKey: Int(kAudioFormatMPEG4AAC), AVSampleRateKey: 12000, AVNumberOfChannelsKey: 1, AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue]
    fileprivate var timer:Timer!
    
    var isPlaying:Bool = false
    var isRecording:Bool = false
    var url:URL?
    var time:Int = 0
    var recordName:String = "recording"
    var delegate: JoyslaeAudioRecorderDelegate?
    
    override init() {
        super.init()

        isAuth()
    }
    
    private func recordSetup() {
       
        let newVideoName = getDir().appendingPathComponent(recordName.appending(".m4a"))
        
        do {
            
            try audioSession.setCategory(.playAndRecord, mode: .default)
            
                audioRecorder = try AVAudioRecorder(url: newVideoName, settings: self.settings)
                audioRecorder.delegate = self as AVAudioRecorderDelegate
                audioRecorder.isMeteringEnabled = true
                audioRecorder.prepareToRecord()
            
        } catch {
            print("Recording update error:",error.localizedDescription)
        }
    }
    
    func record() {
        recordSetup()
        if let recorder = self.audioRecorder {
            if !isRecording {
                
                do {
                    try audioSession.setActive(true)
                    
                    time = 0
                    timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
                
                    recorder.record()
                    isRecording = true
   
                } catch {
                    print("Record error:",error.localizedDescription)
                }
            }
        }
    }
    
    @objc private func updateTimer() {
        
        if isRecording && !isPlaying {
            
            time += 1
            self.getTime()
        } else {
            timer.invalidate()
        }
    }
    
    func stop() {
        
       audioRecorder.stop()
        
        do {
            try audioSession.setActive(false)
        } catch {
            print("stop()",error.localizedDescription)
        }
    }
    func cancelRecording() {
        if audioRecorder.isRecording {
            audioRecorder.stop()
            audioRecorder.deleteRecording()
        }
    }
    func play() {
        
        if !isRecording && !isPlaying {
            if let recorder = self.audioRecorder  {
                
                if recorder.url.path == url?.path && url != nil {
                    audioPlayer.play()
                    return
                }
                
                do {
                    
                    audioPlayer = try AVAudioPlayer(contentsOf: recorder.url)
                    audioPlayer.delegate = self as AVAudioPlayerDelegate
                    url = audioRecorder.url
                    audioPlayer.play()
                    
                } catch {
                    print("play(), ",error.localizedDescription)
                }
            }
            
        } else {
            return
        }
    }
    func playAudio(_ url: String) {
        self.stop()
        self.stopPlaying()
        if !isRecording && !isPlaying {
            do {
                if let urlVal = URL(string: url) {
                    let data = try Data(contentsOf: urlVal)
                    audioPlayer = try AVAudioPlayer.init(data: data)
                    audioPlayer.delegate = self as AVAudioPlayerDelegate
                    audioPlayer.prepareToPlay()
                }
            } catch {
                print("play(with name:), ",error.localizedDescription)
            }
        }
        else {
            return
        }
    }
    func playAct() {
        if !isRecording && !isPlaying {
            audioPlayer.play()
        }
    }
    func play(name:String) {
        
        let bundle = getDir().appendingPathComponent(name.appending(".m4a"))
        
        if FileManager.default.fileExists(atPath: bundle.path) && !isRecording && !isPlaying {
            
            do {
                
                audioPlayer = try AVAudioPlayer(contentsOf: bundle)
                audioPlayer.delegate = self as AVAudioPlayerDelegate
                audioPlayer.play()
                
            } catch {
                print("play(with name:), ",error.localizedDescription)
            }
            
        } else {
            return
        }
    }
    
    func delete(name:String) {
        
        let bundle = getDir().appendingPathComponent(name.appending(".m4a"))
        let manager = FileManager.default
        
        if manager.fileExists(atPath: bundle.path) {
            
            do {
                try manager.removeItem(at: bundle)
            } catch {
                print("delete()",error.localizedDescription)
            }
            
        } else {
            print("File is not exist.")
        }
    }
    
    func stopPlaying() {
        
        audioPlayer.stop()
        isPlaying = false
    }
    
    private func getDir() -> URL {
        
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        
        return paths.first!
    }
    func getFileUrl() -> URL
    {
        let filename = (recordName.appending(".m4a"))
        let filePath = getDir().appendingPathComponent(recordName.appending(".m4a"))
        return filePath
    }
    @discardableResult
    func isAuth() -> Bool {
        
        var result:Bool = false
        
        AVAudioSession.sharedInstance().requestRecordPermission { (res) in
            result = res == true ? true : false
        }
        
        return result
    }
    
    func getTime() {
        var mins = 0
        var secs = 0
        
        if time < 60 {
            secs = time
            
        } else if time >= 60 {
            secs = (time % 60)
            mins = (time / 60)
        }
        let s = String(format: "%02d:%02d", mins, secs)
        delegate?.updateTimer(s)
    }
    
}
extension JoysaleAudioRecorder: AVAudioRecorderDelegate {
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        isRecording = false
        url = nil
        timer.invalidate()
        print("record finish")
    }
    
    func audioRecorderEncodeErrorDidOccur(_ recorder: AVAudioRecorder, error: Error?) {
        print(error.debugDescription)
    }
}

extension JoysaleAudioRecorder: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        isPlaying = false
        print("playing finish")
    }
    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        print(error.debugDescription)
    }
}
