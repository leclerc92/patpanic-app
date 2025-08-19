import SwiftUI

struct CancelButton: View {
    let onCancel: () -> Void
    
    var body: some View {
        Button(action: onCancel) {
            ZStack {
                Circle()
                    .fill(Color.black.opacity(0.1))
                    .frame(width: 40, height: 40)
                
                Image(systemName: "xmark")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.primary)
            }
        }
        .background(
            Circle()
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
        )
    }
}



#Preview {
    ZStack {

        VStack(spacing: 20) {
            CancelButton(onCancel: {})
            
        }
        .padding()
    }
}
