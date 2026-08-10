//
//  LockScreenView.swift
//  xiaozhi
//
//  Created by Lee on 2025/12/25.
//

import SwiftUI
import Combine
import MediaPlayer

//class SystemMusicViewModel: ObservableObject {
//    // 使用系统播放器（这会让你的 App 像遥控器一样控制系统音乐）
//    private let player = MPMusicPlayerController.systemMusicPlayer
//    
//    @Published var isPlaying = false
//    @Published var title: String = "未播放音乐"
//    @Published var artist: String = ""
//    @Published var artworkImage: Image? = nil // 用于显示专辑封面
//    
//    @Published var currentTime: TimeInterval = 0
//    @Published var duration: TimeInterval = 1 // 避免除以0
//    
//    var timer: Timer?
//    
//    init() {
//        setupPermissions()
//        setupNotifications()
//    }
//    
//    deinit {
//        NotificationCenter.default.removeObserver(self)
//        player.endGeneratingPlaybackNotifications()
//    }
//    
//    // 1. 请求权限
//    func setupPermissions() {
//        MPMediaLibrary.requestAuthorization { status in
//            if status == .authorized {
//                DispatchQueue.main.async {
//                    self.updateCurrentItem() // 权限通过后立即刷新状态
//                    // 如果当前队列是空的，设置一个默认队列（例如所有歌曲）
//                    // self.player.setQueue(with: .songs())
//                }
//            }
//        }
//    }
//    
//    // 2. 监听系统播放状态变化（切歌、暂停等）
//    func setupNotifications() {
//        player.beginGeneratingPlaybackNotifications()
//        
//        NotificationCenter.default.addObserver(self, selector: #selector(handleMusicPlayerStateChange), name: .MPMusicPlayerControllerPlaybackStateDidChange, object: player)
//        
//        NotificationCenter.default.addObserver(self, selector: #selector(handleNowPlayingItemChange), name: .MPMusicPlayerControllerNowPlayingItemDidChange, object: player)
//    }
//    
//    @objc func handleMusicPlayerStateChange() {
//        DispatchQueue.main.async {
//            self.isPlaying = (self.player.playbackState == .playing)
//            if self.isPlaying {
//                self.startTimer()
//            } else {
//                self.stopTimer()
//            }
//        }
//    }
//    
//    @objc func handleNowPlayingItemChange() {
//        DispatchQueue.main.async {
//            self.updateCurrentItem()
//        }
//    }
//    
//    // 3. 更新当前歌曲信息
//    func updateCurrentItem() {
//        if let item = player.nowPlayingItem {
//            self.title = item.title ?? "未知标题"
//            self.artist = item.artist ?? "未知艺术家"
//            self.duration = item.playbackDuration
//            
//            // 获取封面图
//            if let artwork = item.artwork, let uiImage = artwork.image(at: CGSize(width: 100, height: 100)) {
//                self.artworkImage = Image(uiImage: uiImage)
//            } else {
//                self.artworkImage = nil // 没有封面就用默认的
//            }
//        } else {
//            self.title = "请在音乐App播放"
//            self.artist = ""
//            self.artworkImage = nil
//        }
//        
//        // 同步播放状态
//        self.isPlaying = (player.playbackState == .playing)
//        if isPlaying { startTimer() }
//    }
//    
//    // 4. 控制逻辑
//    func togglePlayPause() {
//        if player.playbackState == .playing {
//            player.pause()
//        } else {
//            // 如果队列没歌，这就没反应，属于正常现象，用户得先去音乐App选歌或者我们在App里做选歌逻辑
//            player.play()
//        }
//    }
//    
//    func nextTrack() {
//        player.skipToNextItem()
//    }
//    
//    func prevTrack() {
//        // 如果播放超过3秒，回到开头，否则上一首
//        if player.currentPlaybackTime > 3.0 {
//            player.skipToBeginning()
//        } else {
//            player.skipToPreviousItem()
//        }
//    }
//    
//    // 5. 进度条定时器
//    func startTimer() {
//        stopTimer()
//        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
//            guard let self = self else { return }
//            self.currentTime = self.player.currentPlaybackTime
//        }
//    }
//    
//    func stopTimer() {
//        timer?.invalidate()
//        timer = nil
//    }
//}

// MARK: - 2. 电池 ViewModel
class BatteryViewModel: ObservableObject {
    @Published var batteryLevel: Float = 0
    
    init() {
        UIDevice.current.isBatteryMonitoringEnabled = true
        // 模拟器上电池可能是 -1，这里做一个容错
        let level = UIDevice.current.batteryLevel
        self.batteryLevel = level < 0 ? 0.99 : level // 如果是模拟器默认给99%演示
        
        // 监听电池变化
        NotificationCenter.default.addObserver(self, selector: #selector(batteryLevelDidChange), name: UIDevice.batteryLevelDidChangeNotification, object: nil)
    }
    
    @objc func batteryLevelDidChange(_ notification: Notification) {
        self.batteryLevel = UIDevice.current.batteryLevel
    }
}

// MARK: - 3. 主界面 View
struct LockScreenView: View {
    @StateObject var audioVM = SystemMusicViewModel.shared
    @StateObject var batteryVM = BatteryViewModel()
    
    // 用于时钟更新
    @State private var currentDate = Date()
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        NavigationStack {
            ZStack {
                // 背景层
                Image("bg_mountain")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
                    .overlay(Color.black.opacity(0.2))
                
                VStack(spacing: 0) {
                    HStack {
                        Text(currentDate.formatted(.dateTime.weekday(.wide).month().day()))
                            .font(.system(size: 18, weight: .medium))
//                        Text("•")
//                        Image(systemName: "cloud.rain.fill")
//                        Text("24°C")
                    }
                    .foregroundColor(.white)
                    .padding(.top, 60)
                    
                    Text(currentDate.formatted(.dateTime.hour(.defaultDigits(amPM: .omitted)) .minute()))
                        .font(.system(size: 130, weight: .thin, design: .rounded))
                        .foregroundColor(.white.opacity(0.5))
                        .tracking(-5)
                        .frame(height: 140)
                        .padding(.top, 20)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("你好呀")
                            .font(.title)
                            .fontWeight(.bold)
                        Text("......")
                        Text("对未来的真正慷慨\n是把一切都献给当下")
                            .font(.subheadline)
                            .opacity(0.9)
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 30)
                    .padding(.top, 40)
                    
                    Spacer()
                    
                    // 音乐播放器卡片 (保持不变)
                    MusicPlayerCard(vm: audioVM)
                        .padding(.horizontal, 20)
                        .padding(.bottom, 30)
                    
                    // --- 底部状态栏 ---
                    HStack(spacing: 25) {
                        // 电池 (保持不变)
                        VStack(alignment: .leading, spacing: 5) {
                            HStack {
                                Image(systemName: "battery.100.bolt")
                                Text("\(Int(batteryVM.batteryLevel * 100))%")
                            }
                            .font(.headline)
                            
                            Text("Phone Battery")
                                .font(.caption)
                                .opacity(0.8)
                            
                            Capsule()
                                .fill(Color.white.opacity(0.3))
                                .frame(width: 120, height: 8)
                                .overlay(
                                    Capsule()
                                        .fill(Color.white)
                                        .frame(width: 120 * CGFloat(batteryVM.batteryLevel), height: 8),
                                    alignment: .leading
                                )
                        }
                        .foregroundColor(.white)
                        
                        Spacer()
                        
                        // 2️⃣ 修改：替换原来的 CircularProgressView 为 NavigationLink
                        NavigationLink(destination: ContentView()) {
                            ChatEntryButton() // 抽取出来的按钮样式
                        }
                        
                        // 模拟时钟 (保持不变)
                        AnalogClockView(date: currentDate)
                            .frame(width: 50, height: 50)
                    }
                    .padding(.horizontal, 30)
                    .padding(.bottom, 40)
                }
            }
            .onReceive(timer) { input in
                currentDate = input
            }
        }
    }
}

struct ChatEntryButton: View {
    var body: some View {
        ZStack {
            // 外圈圆环
            Circle()
                .stroke(Color.white.opacity(0.3), lineWidth: 2)
                .frame(width: 45, height: 45)
            
            // 进度条装饰 (可选，为了模仿原图风格)
            Circle()
                .trim(from: 0, to: 0.7)
                .stroke(Color.white, style: StrokeStyle(lineWidth: 2, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .frame(width: 45, height: 45)

            // 内容
            VStack(spacing: 2) {
                Image(systemName: "bubble.left.and.bubble.right.fill") // 对话图标
                    .font(.system(size: 14))
                
                Text("实时对话")
                    .font(.system(size: 8, weight: .bold))
            }
            .foregroundColor(.white)
        }
        // 添加点击时的按压效果
        .contentShape(Circle())
    }
}

// MARK: - 4. 组件：音乐播放卡片
struct MusicPlayerCard: View {
    // 👇 修改类型
    @ObservedObject var vm: SystemMusicViewModel
    @State private var rotation: Double = 0
    
    var body: some View {
        HStack(spacing: 15) {
            // 黑胶唱片部分
            ZStack {
                Circle()
                    .fill(Color.black)
                    .frame(width: 90, height: 90)
                
                // 👇 修改：显示真实的封面，如果没有则显示默认图
                Group {
                    if let artwork = vm.artworkImage {
                        artwork
                            .resizable()
                    } else {
                        // 默认图 (可以用系统图标或者 Asset 里的)
                        Image(systemName: "music.note")
                            .resizable()
                            .padding(10)
                            .background(Color.gray)
                    }
                }
                .scaledToFill()
                .frame(width: 50, height: 50)
                .clipShape(Circle())
                .rotationEffect(.degrees(rotation))
            }
            // 唱针装饰
            .overlay(
                Image(systemName: "circle.fill")
                    .font(.system(size: 8))
                    .foregroundColor(.white)
                    .offset(x: 35, y: -35)
                , alignment: .topTrailing
            )
            .shadow(radius: 5)
            
            // 信息与控制
            VStack(alignment: .leading, spacing: 8) {
                // 👇 修改：绑定真实的歌名
                Text(vm.title)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)
                    .lineLimit(1)
                
                // 👇 修改：绑定真实的歌手名
                Text(vm.artist.isEmpty ? "Local Music" : vm.artist)
                    .font(.system(size: 12))
                    .foregroundColor(.white.opacity(0.7))
                    .lineLimit(1)
                
                // 进度条
                ProgressView(value: vm.currentTime, total: vm.duration > 0 ? vm.duration : 1)
                    .tint(.white)
                    .scaleEffect(x: 1, y: 0.8, anchor: .center)
                
                // 按钮控制
                HStack(spacing: 20) {
                    // 👇 修改：绑定上一首
                    Button(action: { vm.prevTrack() }) {
                        Image(systemName: "backward.fill")
                    }
                    
                    Button(action: {
                        withAnimation(.linear) {
                            vm.togglePlayPause()
                        }
                    }) {
                        Image(systemName: vm.isPlaying ? "pause.fill" : "play.fill") // 注意这里图标逻辑
                            .font(.title2)
                    }
                    
                    // 👇 修改：绑定下一首
                    Button(action: { vm.nextTrack() }) {
                        Image(systemName: "forward.fill")
                    }
                }
                .foregroundColor(.white)
                .font(.system(size: 18))
                .padding(.top, 5)
            }
            .layoutPriority(1)
        }
        .padding(15)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                )
        )
        // 唱片旋转动画
        .onChange(of: vm.isPlaying) { isPlaying in
            if isPlaying {
                withAnimation(.linear(duration: 4).repeatForever(autoreverses: false)) {
                    rotation = 360
                }
            } else {
                withAnimation(.linear(duration: 0)) {
                    rotation = 0
                }
            }
        }
    }
}

// MARK: - 5. 组件：圆形进度 (年份)
struct CircularProgressView: View {
    var value: Double
    var label: String
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.white.opacity(0.3), lineWidth: 4)
            Circle()
                .trim(from: 0, to: value)
                .stroke(Color.white, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                .rotationEffect(.degrees(-90))
            
            Text(label)
                .font(.system(size: 10, weight: .bold))
                .multilineTextAlignment(.center)
                .foregroundColor(.white)
        }
        .frame(width: 45, height: 45)
    }
}

// MARK: - 6. 组件：模拟时钟
struct AnalogClockView: View {
    var date: Date
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.white.opacity(0.5), lineWidth: 1)
            
            // 时针
            Rectangle()
                .fill(Color.white)
                .frame(width: 2, height: 12)
                .offset(y: -6)
                .rotationEffect(Angle.degrees(Double(Calendar.current.component(.hour, from: date)) * 30 + Double(Calendar.current.component(.minute, from: date)) * 0.5))
            
            // 分针
            Rectangle()
                .fill(Color.white)
                .frame(width: 1.5, height: 18)
                .offset(y: -9)
                .rotationEffect(Angle.degrees(Double(Calendar.current.component(.minute, from: date)) * 6))
            
            // 秒针 (可选)
            Rectangle()
                .fill(Color.red)
                .frame(width: 1, height: 20)
                .offset(y: -10)
                .rotationEffect(Angle.degrees(Double(Calendar.current.component(.second, from: date)) * 6))
        }
    }
}

// 预览
struct LockScreenView_Previews: PreviewProvider {
    static var previews: some View {
        LockScreenView()
    }
}
