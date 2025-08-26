//
//  ErrorAlert.swift
//  patpanic
//
//  Created by Claude Code on 26/08/2025.
//

import SwiftUI

struct ErrorAlert: View {
    let error: PatPanicError
    let onDismiss: () -> Void
    let onRetry: (() -> Void)?
    
    init(error: PatPanicError, onDismiss: @escaping () -> Void, onRetry: (() -> Void)? = nil) {
        self.error = error
        self.onDismiss = onDismiss
        self.onRetry = onRetry
    }
    
    var body: some View {
        VStack(spacing: 20) {
            // Icône d'erreur
            Image(systemName: errorIcon)
                .font(.system(size: 50))
                .foregroundColor(errorColor)
            
            // Titre
            Text("Oups !")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            // Message d'erreur
            Text(error.localizedDescription)
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .padding(.horizontal)
            
            // Suggestion de récupération
            if let recoverySuggestion = error.recoverySuggestion {
                Text(recoverySuggestion)
                    .font(.caption)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary)
                    .padding(.horizontal)
            }
            
            // Boutons d'action
            HStack(spacing: 15) {
                // Bouton Fermer
                Button("Fermer") {
                    onDismiss()
                }
                .buttonStyle(SecondaryButtonStyle())
                
                // Bouton Réessayer (si disponible)
                if let retryAction = onRetry {
                    Button("Réessayer") {
                        retryAction()
                        onDismiss()
                    }
                    .buttonStyle(PrimaryButtonStyle())
                }
            }
        }
        .padding(30)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
        )
        .padding(40)
    }
    
    private var errorIcon: String {
        switch error {
        case .gameManager:
            return "gamecontroller.fill"
        case .cardManager:
            return "rectangle.stack.fill"
        case .audioManager:
            return "speaker.slash.fill"
        case .timeManager:
            return "timer"
        case .playerValidation:
            return "person.fill.questionmark"
        case .fileSystem:
            return "doc.fill.badge.exclamationmark"
        case .configuration:
            return "gearshape.fill"
        }
    }
    
    private var errorColor: Color {
        switch error {
        case .gameManager:
            return .red
        case .cardManager:
            return .orange
        case .audioManager:
            return .purple
        case .timeManager:
            return .blue
        case .playerValidation:
            return .yellow
        case .fileSystem:
            return .brown
        case .configuration:
            return .gray
        }
    }
}

// MARK: - Button Styles

struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 16, weight: .semibold))
            .foregroundColor(.white)
            .padding(.horizontal, 24)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 25)
                    .fill(Color.blue)
                    .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            )
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 16, weight: .medium))
            .foregroundColor(.blue)
            .padding(.horizontal, 24)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 25)
                    .stroke(Color.blue, lineWidth: 2)
                    .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            )
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

// MARK: - Error Alert Modifier

struct ErrorAlertModifier: ViewModifier {
    @ObservedObject var errorHandler = ErrorHandler.shared
    let onRetry: (() -> Void)?
    
    init(onRetry: (() -> Void)? = nil) {
        self.onRetry = onRetry
    }
    
    func body(content: Content) -> some View {
        content
            .overlay(
                Group {
                    if errorHandler.showErrorAlert, let error = errorHandler.currentError {
                        Color.black.opacity(0.4)
                            .ignoresSafeArea()
                            .onTapGesture {
                                errorHandler.clearCurrentError()
                            }
                        
                        ErrorAlert(
                            error: error,
                            onDismiss: {
                                errorHandler.clearCurrentError()
                            },
                            onRetry: onRetry
                        )
                        .transition(.opacity.combined(with: .scale))
                        .animation(.spring(response: 0.6, dampingFraction: 0.8), value: errorHandler.showErrorAlert)
                    }
                }
            )
    }
}

// MARK: - View Extension

extension View {
    func errorAlert(onRetry: (() -> Void)? = nil) -> some View {
        self.modifier(ErrorAlertModifier(onRetry: onRetry))
    }
}

// MARK: - Preview

struct ErrorAlert_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            // Preview avec erreur de joueur
            ErrorAlert(
                error: .playerValidation(.emptyName),
                onDismiss: {}
            )
            .previewDisplayName("Erreur Joueur")
            
            // Preview avec erreur de carte
            ErrorAlert(
                error: .cardManager(.categoryNotFound(category: "Test")),
                onDismiss: {},
                onRetry: {}
            )
            .previewDisplayName("Erreur Carte avec Retry")
            
            // Preview avec erreur audio
            ErrorAlert(
                error: .audioManager(.soundFileNotFound(soundName: "test.mp3")),
                onDismiss: {}
            )
            .previewDisplayName("Erreur Audio")
        }
    }
}
