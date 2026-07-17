//
//  CustomSegmentedControl.swift
//  Costume
//
//  Created by Matthew Regan Hadiwidjaja on 17/07/26.
//


import SwiftUI

struct CustomSegmentedControl: View {
    @Binding var selection: CVAnalysisTab
    @Namespace private var animationNamespace

    var body: some View {
        HStack(spacing: 0) {
            ForEach(CVAnalysisTab.allCases) { tab in
                Button(action: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        selection = tab
                    }
                }) {
                    Text(tab.title)
                        .font(.system(size: 13, weight: .medium))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .foregroundStyle(selection == tab ? Color.white : Color.primary)
                        .background(
                            ZStack {
                                if selection == tab {
                                    Capsule()
                                        .fill(Color("PrimaryColor"))
                                        .matchedGeometryEffect(id: "TabIndicator", in: animationNamespace)
                                }
                            }
                        )
                        .contentShape(Capsule())
                }
                .buttonStyle(.plain)
            }
        }
        .padding(2)
        .background(Color(NSColor.controlBackgroundColor))
        .clipShape(Capsule())
    }
}
