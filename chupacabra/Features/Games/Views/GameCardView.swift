import SwiftUI

struct GameCardView: View {
    let game: FullGame
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("\(game.name) - \(game.category.name)")
                .font(.headline)
                .lineLimit(2)
            
            HStack {
                Text("\(game.minimumPlayersNumber) à \(game.maximumPlayersNumber) joueurs")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text("\(String(format: "%.2f", game.minimumPrice)) €")
                    .font(.headline)
                    .foregroundColor(.blue)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(10)
        .shadow(radius: 2)
        .frame(width: 300, height: 100)
    }
} 