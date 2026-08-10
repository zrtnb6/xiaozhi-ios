//
//  SystemMusicViewModel.swift
//  xiaozhi
//
//  Created by Lee on 2026/1/1.
//

import SwiftUI
import MediaPlayer
import Combine

class SystemMusicViewModel: ObservableObject {
    
    // ✅ 单例：让全局都能访问同一个播放器实例
    static let shared = SystemMusicViewModel()
    
    private let player = MPMusicPlayerController.systemMusicPlayer
    
    @Published var isPlaying = false
    @Published var title: String = "未播放音乐"
    @Published var artist: String = ""
    @Published var artworkImage: Image? = nil
    
    @Published var currentTime: TimeInterval = 0
    @Published var duration: TimeInterval = 1
    
    var timer: Timer?
    
    private init() {
        setupPermissions()
        setupNotifications()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        player.endGeneratingPlaybackNotifications()
    }
    
    // 1. 权限
    func setupPermissions() {
        MPMediaLibrary.requestAuthorization { status in
            if status == .authorized {
                DispatchQueue.main.async {
                    self.updateCurrentItem()
                }
            }
        }
    }
    
    // 2. 监听
    func setupNotifications() {
        player.beginGeneratingPlaybackNotifications()
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleStateChange), name: .MPMusicPlayerControllerPlaybackStateDidChange, object: player)
        NotificationCenter.default.addObserver(self, selector: #selector(handleItemChange), name: .MPMusicPlayerControllerNowPlayingItemDidChange, object: player)
    }
    
    @objc func handleStateChange() {
        DispatchQueue.main.async {
            self.isPlaying = (self.player.playbackState == .playing)
            if self.isPlaying { self.startTimer() } else { self.stopTimer() }
        }
    }
    
    @objc func handleItemChange() {
        DispatchQueue.main.async {
            self.updateCurrentItem()
        }
    }
    
    // 3. 更新信息
    func updateCurrentItem() {
        if let item = player.nowPlayingItem {
            self.title = item.title ?? "未知标题"
            self.artist = item.artist ?? "未知艺术家"
            self.duration = item.playbackDuration
            
            if let artwork = item.artwork, let uiImage = artwork.image(at: CGSize(width: 200, height: 200)) {
                self.artworkImage = Image(uiImage: uiImage)
            } else {
                self.artworkImage = nil
            }
        } else {
            self.title = "请在音乐App播放"
            self.artist = ""
            self.artworkImage = nil
        }
        
        self.isPlaying = (player.playbackState == .playing)
    }
    
    // 4. 控制方法 (供 MCP 调用)
    func togglePlayPause() {
        if player.playbackState == .playing {
            player.pause()
        } else {
            player.play()
        }
    }
    
    func play() { player.play() }
    func pause() { player.pause() }
    func nextTrack() { player.skipToNextItem() }
    func prevTrack() {
        if player.currentPlaybackTime > 3.0 {
            player.skipToBeginning()
        } else {
            player.skipToPreviousItem()
        }
    }
    
    // 5. 进度条
    func startTimer() {
        stopTimer()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            self.currentTime = self.player.currentPlaybackTime
        }
    }
    
    func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
}
