//
//  AdminHelper.swift
//  QHHT-BQH
//
//  Created by Alex Negrete on 4/27/23.
//

import Foundation
import SwiftUI

struct AdminHelper {
    static let shared = AdminHelper()
    
    struct AdminButtonStyle: ButtonStyle {
        func makeBody(configuration: Configuration) -> some View {
            configuration.label
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(RoundedRectangle(cornerRadius: 8)
                                .fill(Color.blue.opacity(0.1)))
                .foregroundColor(.blue)
        }
    }
    
    struct ApproveButtonStyle: ButtonStyle {
        func makeBody(configuration: Configuration) -> some View {
            configuration.label
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(8)
        }
    }
    
    static func userProfileToPractitionerProfile(userProfile: UserProfile) -> PractitionerProfile {
        let practitionerProfile = PractitionerProfile(
            name: userProfile.name,
            headline: userProfile.headline,
            location: userProfile.location,
            link: userProfile.link,
            profileImageURL: userProfile.profileImageURL,
            specializations: userProfile.specializations,
            rating: 0, // Set the initial rating to 0 or any default value
            reviews: [] // Initialize with an empty list of reviews
        )
        return practitionerProfile
    }
    
    static func approveButton(for practitioner: UserProfile) -> some View {
        Button(action: {
            let verificationManager = VerificationManager()
            verificationManager.approveUser(userProfile: practitioner)
            // Refresh the list of unapproved practitioners
            // ...
        }) {
            Text("Approve")
        }
        .buttonStyle(AdminHelper.ApproveButtonStyle())
    }
}

class VerificationManager {
    func approveUser(userProfile: UserProfile) {
        // Call the helper function to create a PractitionerProfile instance
        let practitionerProfile = AdminHelper.userProfileToPractitionerProfile(userProfile: userProfile)

        // Save the practitionerProfile to your backend, e.g., Firebase
        // Update the userProfile's status in the backend to reflect that it's approved
    }
}
