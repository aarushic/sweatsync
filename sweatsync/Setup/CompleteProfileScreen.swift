//
//  CompleteProfileScreen.swift
//  sweatsync
//
//  Created by aarushi chitagi on 10/14/24.
//

import Foundation
import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct CompleteProfileScreen: View {
    @State private var age: Int = 12
    @State private var height: Int = 48
    @State private var weight: Int = 50
    @State private var errorMessage: String? = nil
    @State private var isProfileCompleted: Bool = false
    
    @State private var lifting: Bool = false
    @State private var running: Bool = false
    @State private var biking: Bool = false
    @State private var swimming: Bool = false
    @State private var yoga: Bool = false
    @State private var hiking: Bool = false
    
    @EnvironmentObject var session: SessionManager

    var body: some View {
        NavigationStack {
            VStack(spacing: 50) {
                Text("Complete Your Profile")
                    .font(.custom(Theme.bodyFont, size: 24))
                    .bold()
                    .foregroundColor(.white)
                    .padding(.top, 40)
                
                VStack(spacing: 20) {
                    HStack {
                        Text("Age")
                            .font(.custom(Theme.bodyFont, size: 18))
                            .foregroundColor(.white)
                        Spacer()
                        Picker("Height", selection: $age) {
                            ForEach(12...100, id: \.self) { age in
                                Text("\(age)").tag(age)
                            }
                        }
                        .frame(width: 200, height: 50)
                        .clipped()
                        .labelsHidden()
                        .background(Theme.secondaryColor)
                        .cornerRadius(10)
                    }
                
                    HStack {
                        Text("Height (cm)")
                            .font(.custom(Theme.bodyFont, size: 18))
                            .foregroundColor(.white)
                        Spacer()
                        Picker("Height", selection: $height) {
                            ForEach(48...84, id: \.self) { height in
                                Text("\(height) in").tag(height)
                            }
                        }
                        .frame(width: 200, height: 50)
                        .clipped()
                        .labelsHidden()
                        .background(Theme.secondaryColor)
                        .cornerRadius(10)
                    }
                    
                    HStack {
                        Text("Weight (lb)")
                            .font(.custom(Theme.bodyFont, size: 18))
                            .foregroundColor(.white)
                        Spacer()
                        Picker("Weight", selection: $weight) {
                            ForEach(50...300, id: \.self) { weight in
                                Text("\(weight) lb").tag(weight)
                            }
                        }
                        .frame(width: 200, height: 50)
                        .clipped()
                        .labelsHidden()
                        .background(Theme.secondaryColor)
                        .cornerRadius(10)
                    }
                }
                .padding()
                .padding(.horizontal, 20)
                
                VStack(alignment: .leading) {
                    Text("Training Preferences")
                        .font(.custom(Theme.bodyFont, size: 20))
                        .foregroundColor(.white)
                        .padding(.bottom, 10)
                    
                    let columns = [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]
                    
                    LazyVGrid(columns: columns, spacing: 15) {
                        PreferenceToggle(title: "Lifting", isSelected: $lifting)
                        PreferenceToggle(title: "Running", isSelected: $running)
                        PreferenceToggle(title: "Biking", isSelected: $biking)
                        PreferenceToggle(title: "Swimming", isSelected: $swimming)
                        PreferenceToggle(title: "Yoga", isSelected: $yoga)
                        PreferenceToggle(title: "Hiking", isSelected: $hiking)
                    }
                }
                .frame(width: 340)
                .background(Color.black.ignoresSafeArea())
                
                Button(action: {
                    completeProfile()
                }) {
                    Text("Complete Profile")
                        .font(.custom(Theme.bodyFont, size: 18))
                        .frame(width: 250, height: 50)
                        .background(Theme.primaryColor)
                        .foregroundColor(.black)
                        .cornerRadius(25)
                }
                .padding(.top, 20)
                
                if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .font(.custom(Theme.bodyFont, size: 14))
                        .foregroundColor(.red)
                        .padding(.top, 10)
                }
                Spacer()
            }
            .background(Color.black.ignoresSafeArea())
            .fullScreenCover(isPresented: $isProfileCompleted) {
                OnboardingScreen1()
            }
        }
    }
    
    private func completeProfile() {
        //check if user is authenticated
        guard let user = Auth.auth().currentUser else {
            errorMessage = "Unable to retrieve user. Please log in again."
            return
        }

        //check fields are not empty
        guard age != 0, height != 0, weight != 0 else {
            errorMessage = "Please fill in all fields."
            return
        }

        let db = Firestore.firestore()
        
        //collect selected training priorities
        var trainingPreferences: [String] = []
        if lifting { trainingPreferences.append("Lifting") }
        if running { trainingPreferences.append("Running") }
        if biking { trainingPreferences.append("Biking") }
        if swimming { trainingPreferences.append("Swimming") }
        if yoga { trainingPreferences.append("Yoga") }
        if hiking { trainingPreferences.append("Hiking") }
        
        guard !trainingPreferences.isEmpty else {
            errorMessage = "Please select at least one training preference."
            return
        }
        
        let additionalProfileData: [String: Any] = [
            "age": age,
            "height": height,
            "weight": weight,
            "trainingPreferences": trainingPreferences
        ]

        //update profile data in Firebase
        db.collection("users").document(user.uid).updateData(additionalProfileData) { err in
            if let err = err {
                errorMessage = "Error: \(err.localizedDescription)"
            } else {
                errorMessage = nil
                isProfileCompleted = true
                print("Profile successfully updated with training preferences")
            }
        }
    }
}

#Preview {
    CompleteProfileScreen()
}
