//
//  ContentView.swift
//  SearchSuggestions
//
//  Created by Noah budarf on 2024-12-28.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = ProductViewModel()
    @State private var searchText = ""
    
    let columns: [GridItem] = [
        GridItem(.adaptive(minimum: 100)) // Minimum width for each item
    ]
    
    var body: some View {
        NavigationStack {
            
            List(viewModel.filteredProducts(searchText: searchText), id: \.self) { product in
                NavigationLink(destination: DetailView(product: product, viewModel: viewModel)) {
                    ProductRow(product: product)
                }
            }
            .navigationTitle("Apple Products")
            .searchable(text: $searchText, prompt: "Search products...")
            .searchSuggestions {
                
                WordCloud.listRowSeparator(.hidden)
            }
        }
    }
    
    @State private var positions: [CGPoint] = []
    let rectangleSize: CGFloat = 75
    
    @ViewBuilder
    var WordCloud: some View {
        GeometryReader { geometry in
            
            ZStack {
                
                ForEach(0..<viewModel.filteredProducts(searchText: searchText).count, id: \.self) { index in
                    
                    if positions.indices.contains(index) {
                        
                        let text = viewModel.filteredProducts(searchText: searchText)[index]
                        
                        
                        Text(text)
                            .multilineTextAlignment(.center)
                            .lineLimit(2)
                            .padding(5)
                            .frame(maxWidth: rectangleSize, maxHeight: rectangleSize)
                            .background(Capsule().fill(Color.white).shadow(radius: 3))
                            .position(positions[index])

                                //TODO: tap to show product detail
                        
                    } else {
                        EmptyView()
                    }
                }
            }
            .frame(width: geometry.size.width, height: geometry.size.width)
            .onAppear {
                positions = generateNonOverlappingPositions(
                    count: viewModel.filteredProducts(searchText: searchText).count,
                    areaSize: geometry.size.width,
                    itemSize: rectangleSize
                )
            }
        }
    }
    
    private func generateNonOverlappingPositions(count: Int, areaSize: CGFloat, itemSize: CGFloat) -> [CGPoint] {
        var positions: [CGPoint] = []
        let maxAttempts = 10
        
        for _ in 0..<count {
            var newPoint: CGPoint
            var attempts = 0
            
            repeat {
                let x = CGFloat.random(in: itemSize / 2...(areaSize - itemSize / 2))
                let y = CGFloat.random(in: itemSize / 2...(areaSize - itemSize / 2))
                newPoint = CGPoint(x: x, y: y)
                attempts += 1
            } while positions.contains(where: { $0.distance(to: newPoint) < itemSize }) && attempts < maxAttempts
            
            if attempts != maxAttempts {
                positions.append(newPoint)
            }
        }
        
        return positions
    }
}

extension CGPoint {
    /// Calculates the distance between two points
    func distance(to point: CGPoint) -> CGFloat {
        sqrt(pow(x - point.x, 2) + pow(y - point.y, 2))
    }
}


#Preview {
    ContentView()
}

class WordCloudManager {
    
    var frames: [CGRect] = []
    
    func addFrame(_ frame: CGRect) {
        frames.append(frame)
    }
}

class ProductViewModel: ObservableObject {
    
    @Published var recentSearches: [String] = []
    
    let products = ["AirPods", "AirPods Max", "AirPods Pro", "Apple Pencil", "Apple TV", "Apple Watch", "HomePod", "HomePod mini", "iMac", "iMac Pro", "iPad", "iPad Air", "iPad mini", "iPad Pro", "iPhone", "iPhone Pro", "iPhone Pro Max", "iPod", "iPod classic", "iPod mini", "iPod nano", "iPod shuffle", "iPod touch", "Mac mini", "Mac Pro", "MacBook", "MacBook Air", "MacBook Pro", "Macintosh", "Magic Keyboard", "Magic Mouse", "Magic Trackpad", "Studio Display", "Vision Pro"]
        .sorted { $0 < $1 }
    
    func filteredProducts(searchText: String) -> [String] {
        if searchText.isEmpty { return products }
        return products.filter { $0.localizedCaseInsensitiveContains(searchText) }
    }
}

struct ProductRow: View {
    
    let product: String
    
    var body: some View {
        HStack {
            Image(systemName: "\(product.first!.lowercased()).circle.fill")
                .symbolRenderingMode(.hierarchical)
                .imageScale(.large)
            Text(product)
        }.listRowSeparator(.hidden)
    }
}

struct DetailView: View {
    
    let product: String
    @ObservedObject var viewModel: ProductViewModel
    
    var body: some View {
        VStack {
            Image(systemName: "macbook.and.iphone")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 160)
            
            Text(product)
                .font(.title)
        }
        .navigationTitle("Product Detail")
    }
}
