import SwiftUI
import Combine

enum CatState {
    case idle, sleeping, waitingForFood, eating, swallowing, happy
}

class CatViewModel: ObservableObject {
    @Published var currentState: CatState = .idle
    @Published var currentSprite: String = "cat_idle_1"
    @Published var statusIconName: String = "icon_happy"
    
    private var timer: Timer?
    private var animationTick = false
    
    init() {
        if UserDefaults.standard.object(forKey: "lastFed") == nil {
            UserDefaults.standard.set(Date(), forKey: "lastFed")
        }
        startLoop()
    }
    
    func startLoop() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { _ in
            self.updateCatStatus()
        }
    }
    
    private func updateCatStatus() {
        let now = Date()
        let hour = Calendar.current.component(.hour, from: now)
        
        // Sleep Logic (9PM - 9AM)
        if (hour >= 21 || hour < 9) {
            currentState = .sleeping
            currentSprite = "cat_sleep"
            statusIconName = "icon_sleep"
            return
        }
        
        if currentState == .sleeping { currentState = .idle }
        
        // Hunger Logic
        if let lastFed = UserDefaults.standard.object(forKey: "lastFed") as? Date {
            let timeSinceFed = now.timeIntervalSince(lastFed)
            statusIconName = timeSinceFed > 3600 ? "icon_sad" : "icon_happy"
        }
        
        // Animation Loop
        animationTick.toggle()
        if currentState == .idle {
            currentSprite = animationTick ? "cat_idle_1" : "cat_idle_2"
        } else if currentState == .eating {
            currentSprite = animationTick ? "cat_eat_1" : "cat_eat_2"
        }
    }
    
    func prepareToEat() { if currentState != .sleeping { currentState = .waitingForFood; currentSprite = "cat_mouth_open" } }
    func cancelEat() { if currentState == .waitingForFood { currentState = .idle } }
    
    func feedCat() {
        guard currentState != .sleeping else { return }
        UserDefaults.standard.set(Date(), forKey: "lastFed")
        currentState = .eating
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            self.currentState = .swallowing
            self.currentSprite = "cat_swallow"
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.currentState = .happy
                self.currentSprite = "cat_smile"
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    self.currentState = .idle
                }
            }
        }
    }
}
