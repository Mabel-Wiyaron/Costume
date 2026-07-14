//
//  NewProjectCard.swift
//  Costume
//
//  Created by Nayla Abel Sabathyani on 14/07/26.
//

import SwiftUI

struct NewProjectCard: View {
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "plus")
                .font(.system(size: 50, weight: .medium))
                .foregroundColor(.accentColor)
            
            Text("New Project")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.text)
        }
                .frame(maxWidth: .infinity, minHeight: 154, maxHeight: 154)
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
        .onHover { isHovered in
            if isHovered { NSCursor.pointingHand.push() }
            else { NSCursor.pop() }
        }
    }
}

#Preview {
    NewProjectCard()
        .padding()
}
