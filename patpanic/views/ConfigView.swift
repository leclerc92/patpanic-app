//
//  ConfigView.swift
//  patpanic
//
//  Created by clement leclerc on 28/08/2025.
//

import SwiftUI

struct ConfigView: View {
    
    @StateObject private var viewModel: ConfigViewModel
    
    init(gameManager:GameManager) {
        self._viewModel = StateObject(
            wrappedValue: ConfigViewModel(gameManager: gameManager)
        )
    }
    
    
    var body: some View {
        // Arrière-plan gradient moderne
        ZStack {
            
            backgroundGradient
            
            VStack() {
                headerSection
                
                Spacer()
                
                timerSection
                
                Spacer()
            }
        }
        
    }
    
    private var backgroundGradient: some View {
        LinearGradient(
            colors: [
                Color.blue.opacity(0.15),
                Color.purple.opacity(0.15),
                Color.pink.opacity(0.15)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }
    
    
    private var headerSection: some View {
        HStack {
            Spacer()
            CancelButton(action: viewModel.cancelButton)
        }
        .padding(.top)
        .padding(.horizontal)
    }
    
    private var timerSection: some View {
        VStack{
            Stepper(value: $viewModel.timerRound1, in: 0...60, step: 1) {
                Text("Timer manche 1 : \(viewModel.timerRound1)")
            }
            
            Stepper(value: $viewModel.timerRound2, in: 0...60, step: 1) {
                Text("Timer manche 2 : \(viewModel.timerRound2)")
            }
            
            Stepper(value: $viewModel.timerRound3, in: 0...60, step: 1) {
                Text("Timer manche 3 : \(viewModel.timerRound3)")
            }
        }
    }
}




#Preview {
    let gameManager:GameManager = GameManager()
    ConfigView(gameManager: gameManager)
}
