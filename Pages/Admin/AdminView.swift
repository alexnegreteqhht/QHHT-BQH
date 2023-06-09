//
//  AdminView.swift
//  QHHT-BQH
//
//  Created by Alex Negrete on 4/21/23.
//

import Foundation
import SwiftUI

struct AdminView_Previews: PreviewProvider {
    static var previews: some View {
        AdminView()
    }
}

struct AdminView: View {
    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 16) {
                NavigationLink(destination: AdminPractitionerApprovalView()) {
                    Text("Approve Practitioners")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .padding(.vertical, 10)
                        .padding(.horizontal)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                
                // Add more admin features as needed

                Spacer()
            }
            .padding()
            .navigationBarTitle("Admin Panel", displayMode: .large)
        }
    }
}
