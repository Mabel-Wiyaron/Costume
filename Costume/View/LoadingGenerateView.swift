//
//  LoadingGenerateView.swift
//  Costume
//
//  Created by Nayla Abel Sabathyani on 17/07/26.
//

import SwiftUI

struct LoadingGenerateView: View {
    @State private var orbitAngle: Double = 0
    @State private var wobbleAngle: Double = -15
    @State private var loadingProgress: Double = 0.0
    
    var body: some View {
        ZStack(alignment: .top) {
            Color.background
                .ignoresSafeArea()
            
            CustomHeaderShape()
                .fill(Color(.primary))
                .frame(height: 300)
                .ignoresSafeArea(edges: .top)
            
            VStack(spacing: 10) {
                
                ZStack {
                    Image(.paperLoading)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 200)
                        .padding(.top, 200)
                    Image(.glassLoading)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 200)
                        .padding(.top, 200)
                        .rotationEffect(.degrees(wobbleAngle))
                        .rotationEffect(.degrees(-orbitAngle))
                        .offset(x: 40, y: 40)
                        .rotationEffect(.degrees(orbitAngle))
                }
             
                VStack(spacing: 10) {
                    Text("Customizing Your Resumé…")
                        .font(.largeTitle)
                        .bold()
                        .foregroundColor(.text)
                        .padding(.top, -60)
                        .padding(.horizontal, 100)
                    
                    Text("We're analyzing your profile and customizing your Resumé. Please keep this tab open. You may switch to another tab or continue browsing.")
                        .font(.body)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.top, -30)
                        .padding(.horizontal, 100)
        
                }
                .frame(maxWidth: .infinity)
                .padding(.top, 100)
                
                VStack(spacing: 8) {
                    ProgressView(value: loadingProgress, total: 100)
                        .progressViewStyle(.linear)
                        .frame(width: 320)
                        .tint(.accent)
                        .padding(.top, -10)
                        .padding(.horizontal, 100)
                    
                    Text("\(Int(loadingProgress))%")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
        }
        .onAppear {
            animateProgressBar()
            startScanningAnimation()
        }.navigationBarBackButtonHidden(true)
    }
    private func startScanningAnimation() {
            // 1. The Circular Orbit (Smooth, continuous 360-degree loop)
            withAnimation(.linear(duration: 2.5).repeatForever(autoreverses: false)) {
                orbitAngle = 360
            }
            
            // 2. The Hand Wobble (Bounces back and forth between -15 and +15 degrees)
            withAnimation(.easeInOut(duration: 0.6).repeatForever(autoreverses: true)) {
                wobbleAngle = 15
            }
        }
    private func animateProgressBar() {
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in
            if loadingProgress < 95 {
                loadingProgress += 1.0
            } else {
                timer.invalidate()
            }
        }
    }
}

#Preview {
    LoadingGenerateView()
}
