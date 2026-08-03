//
//  HomeView.swift
//  SimplyJobTracker
//
//  Created by Arviejhay Alejandro on 8/2/26.
//

import SwiftUI
import SwiftData

struct HomeView: View {
    @State var viewModel: HomeViewModel
    
    @State private var currentPage = 0
    
    var body: some View {
        VStack {
            HeaderView(text: "OVERVIEW")
            TabView(selection: $currentPage) {
                HStack {
                    TileView(number: 1, text: "Applied", color: .blue)
                    TileView(number: 2, text: "Interviewing", color: .yellow)
                    TileView(number: 1, text: "Offers", color: .green)
                }
                .padding(.horizontal)
                .tag(0)
                .frame(maxHeight: .infinity, alignment: .top)
                
                HStack {
                    TileView(number: 1, text: "Rejected", color: .gray)
                    TileView(number: 2, text: "Passed", color: .pink.mix(with: .white, by: 0.3))
                }
                .padding(.horizontal)
                .tag(1)
                .frame(maxHeight: .infinity, alignment: .top)
            }
            .tabViewStyle(.page)
            .indexViewStyle(.page(backgroundDisplayMode: .always))
            .frame(height: 135)
            
            HeaderView(text: "ACTIVITY")
            
            Text("Content Here")
            
            HeaderView(text: "APPLICATION") {
                Button {
                    // ACtion here
                } label: {
                    Image(systemName: "magnifyingglass")
                }

            }
            
            Text("Content Here")
            
            Spacer()
        }
    }
}

private extension HomeView {
    struct TileView: View {
        let number: Int
        let text: String
        let color: Color
        
        var body: some View {
            VStack {
                Text("\(number)")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundStyle(color)
                Text(text)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 15)
                    .foregroundStyle(color)
                    .opacity(0.2)
                    .shadow(radius: 1)
            )
        }
    }
}

#Preview {
    let container = try! ModelContainer(
        for: JobApplication.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )
    let coordinator = HomeCoordinator(modelContainer: container)
    
    HomeView(viewModel: coordinator.homeViewModel)
        .modelContainer(container)
}
