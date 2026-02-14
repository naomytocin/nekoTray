import SwiftUI

struct ContentView: View {
    @ObservedObject var neko: CatViewModel
    let foods = ["food_1", "food_2", "food_3", "food_4", "food_5"]
    
    var body: some View {
        VStack(spacing: 15) {
            ZStack {
                Image(neko.currentSprite)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 120, height: 120)
                
                if neko.currentState == .sleeping {
                    Text("Zzz...")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .offset(x: 40, y: -40)
                }
            }
            .frame(height: 140)
            
            Divider().background(Color.white.opacity(0.2))
            
            if neko.currentState != .sleeping {
                HStack(spacing: 15) {
                    ForEach(foods, id: \.self) { food in
                        DraggableFood(imageName: food, neko: neko)
                    }
                }
            } else {
                Text("Sleeping until 9 AM").font(.caption).opacity(0.6)
            }
        }
        .padding()
        .frame(width: 250)
        .background(.ultraThinMaterial)
    }
}

struct DraggableFood: View {
    let imageName: String
    @ObservedObject var neko: CatViewModel
    @State private var dragOffset: CGSize = .zero
    
    var body: some View {
        Image(imageName)
            .resizable()
            .frame(width: 30, height: 30)
            .offset(dragOffset)
            .gesture(
                DragGesture()
                    .onChanged { gesture in
                        dragOffset = gesture.translation
                        if dragOffset.height < -40 { neko.prepareToEat() }
                    }
                    .onEnded { _ in
                        if dragOffset.height < -40 { neko.feedCat() }
                        else { neko.cancelEat() }
                        withAnimation(.spring()) { dragOffset = .zero }
                    }
            )
    }
}
