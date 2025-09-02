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
                
                categoriesSelection
                
                Spacer()
                
                buttonSections
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
        VStack {
            HStack {
                Spacer()
                CancelButton(action: viewModel.cancelButton)
            }
            .padding(.top)
            .padding(.horizontal)
            
            GameTitle(icon: "⚒️", title: "Configuration", subtitle: "Changer les variables de jeu")
        }
        .padding()
        
        
        
    }
    
    private var timerSection: some View {
        VStack{
            Stepper(value: $viewModel.timerRound1, in: 0...60, step: 1) {
                Text("Timer manche 1 : \(viewModel.timerRound1)")
            }.padding(.bottom)
            
            Stepper(value: $viewModel.timerRound2, in: 0...60, step: 1) {
                Text("Timer manche 2 : \(viewModel.timerRound2)")
            }.padding(.bottom)
            
            Stepper(value: $viewModel.timerRound3, in: 0...60, step: 1) {
                Text("Timer manche 3 : \(viewModel.timerRound3)")
            }.padding(.bottom)
            
        }.padding()
    }
    
    private var categoriesSelection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 8) {
                        Text("🎯 Sélection des catégories")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.primary)
                    }
                    
                    Text("\(viewModel.selectedCategoriesCount) / \(viewModel.totalCategoriesCount) catégories sélectionnées")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Boutons Tout/Rien
                HStack(spacing: 8) {
                    Button("Tout", action: viewModel.selectAllCategories)
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.green.opacity(0.2))
                        .foregroundColor(.green)
                        .cornerRadius(6)
                    
                    Button("1 seule", action: viewModel.deselectAllCategories)
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.red.opacity(0.2))
                        .foregroundColor(.red)
                        .cornerRadius(6)
                }
            }
            
            VStack(spacing: 8) {
                // Dropdown personnalisé pour sélection multiple
                Button(action: viewModel.toggleDropdown) {
                    HStack {
                        Text(viewModel.selectedCategoriesCount > 0 ? 
                             "\(viewModel.selectedCategoriesCount) catégorie(s) sélectionnée(s)" : 
                             "Sélectionner les catégories")
                            .font(.system(size: 14))
                            .foregroundColor(viewModel.selectedCategoriesCount > 0 ? .primary : .secondary)
                        
                        Spacer()
                        
                        // Badges colorés pour les catégories sélectionnées
                        if viewModel.selectedCategoriesCount > 0 {
                            HStack(spacing: 4) {
                                ForEach(Array(viewModel.selectedCategories).prefix(3), id: \.self) { category in
                                    Circle()
                                        .fill(viewModel.colorForCategory(category))
                                        .frame(width: 8, height: 8)
                                }
                                if viewModel.selectedCategoriesCount > 3 {
                                    Text("+\(viewModel.selectedCategoriesCount - 3)")
                                        .font(.system(size: 8))
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                        
                        Image(systemName: viewModel.showCategoryDropdown ? "chevron.up" : "chevron.down")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color(.systemGray6))
                    )
                }
                
                // Liste déroulante persistante avec scroll
                if viewModel.showCategoryDropdown {
                    ScrollView(.vertical, showsIndicators: false) {
                        VStack(spacing: 4) {
                            ForEach(viewModel.availableCategories, id: \.self) { category in
                                Button(action: {
                                    viewModel.toggleCategory(category)
                                }) {
                                    HStack {
                                        Circle()
                                            .fill(viewModel.colorForCategory(category))
                                            .frame(width: 8, height: 8)
                                        
                                        Text(category.capitalized)
                                            .font(.system(size: 14))
                                            .foregroundColor(.primary)
                                        
                                        Spacer()
                                        
                                        Image(systemName: viewModel.isCategorySelected(category) ? "checkmark.circle.fill" : "circle")
                                            .foregroundColor(viewModel.isCategorySelected(category) ? .blue : .gray)
                                            .font(.system(size: 16))
                                            .opacity(viewModel.canDeselectCategory(category) ? 1.0 : 0.5)
                                    }
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .padding(.vertical, 4)
                    }
                    .frame(maxHeight: 150)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color(.systemBackground))
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color(.systemGray4), lineWidth: 1)
                            )
                    )
                    .animation(.easeInOut(duration: 0.2), value: viewModel.showCategoryDropdown)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
        )
        .padding(.horizontal)
    }
    
    private var buttonSections: some View {
        
        HStack {
            RoundButton.validateButton(size: 70) {
                
            }.padding(.horizontal)
            
            RoundButton.replayButton(size: 70) {
            }.padding(.horizontal)
            
            
        }.padding()
    }
}




#Preview {
    let gameManager:GameManager = GameManager()
    ConfigView(gameManager: gameManager)
}
