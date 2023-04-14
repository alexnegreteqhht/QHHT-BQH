import SwiftUI
import Photos
import Firebase
import FirebaseAuth
import FirebaseStorage
import FirebaseFirestore

struct EditProfileView_Previews: PreviewProvider {
    static var previews: some View {
        EditProfileView(userProfile: UserProfile(id: "", userName: "", userBio: "", userProfileImage: ""))
    }
}

struct EditProfileView: View {
    @ObservedObject var userProfile: UserProfile
    @Environment(\.presentationMode) private var presentationMode
    @State var userPhoto: UIImage? = nil
    @State private var userPhotoData: Data? = nil
    @State private var showImagePicker: Bool = false
    @State private var showAlert: Bool = false
    @State private var errorMessage: String = ""
    @State private var credentialImage: UIImage?
    @State private var credentialImageData: Data?
    @State private var showCredentialImagePicker = false
    @State private var isLoadingCredentialImage: Bool = false
    @State private var showDatePicker = false
    @State private var isBirthdaySet = false
    @State private var isLoadingUserPhoto: Bool = false
    @State private var userName: String = ""
    @State private var userBio: String = ""
    @State private var userLocation: String = ""
    @State private var userWebsite: String = ""
    @State private var isSavingProfile: Bool = false
    var onProfilePhotoUpdated: ((UIImage) -> Void)?
    var onProfileUpdated: (() -> Void)?
    
    func saveProfile() {
        isSavingProfile = true
        if let user = Auth.auth().currentUser {
            let userRef = Firestore.firestore().collection("users").document(user.uid)
            let dispatchGroup = DispatchGroup()
            
            if let credentialImageData = credentialImageData {
                dispatchGroup.enter()
                FirebaseHelper.uploadImageToStorage(imageData: credentialImageData, imagePath: "credentialImages/\(user.uid).jpg") { result in
                    switch result {
                    case .success(let urlString):
                        userProfile.userCredential = urlString
                    case .failure(let error):
                        errorMessage = "Error uploading credential image: \(error.localizedDescription)"
                        showAlert.toggle()
                    }
                    dispatchGroup.leave()
                }
            }
            
            if let profileImageData = userPhotoData {
                dispatchGroup.enter()
                FirebaseHelper.uploadImageToStorage(imageData: profileImageData, imagePath: "profileImages/\(user.uid).jpg") { result in
                    switch result {
                    case .success(let urlString):
                        userProfile.userProfileImage = urlString
                    case .failure(let error):
                        errorMessage = "Error uploading profile image: \(error.localizedDescription)"
                        showAlert.toggle()
                    }
                    dispatchGroup.leave()
                }
            }
            
            dispatchGroup.notify(queue: .main) {
                updateUserProfile(userRef: userRef)
            }
        }
    }
    
    func updateUserProfile(userRef: DocumentReference) {
        userRef.updateData([
            "name": userProfile.name,
            "email": userProfile.email,
            "location": userProfile.location,
            "userName": userProfile.userName,
            "userEmail": userProfile.userEmail,
            "userLocation": userProfile.userLocation,
            "userPhoneNumber": userProfile.userPhoneNumber,
            "userBio": userProfile.userBio,
            "userVerification": userProfile.userVerification,
            "userCredential": userProfile.userCredential ?? "",
            "userProfileImage": userProfile.userProfileImage ?? "",
            "userWebsite": userProfile.userWebsite,
            "userBirthday": FirebaseHelper().dateFormatter.string(from: userProfile.userBirthday),
            "userJoined": FirebaseHelper().dateFormatter.string(from: userProfile.userJoined)
        ]) { error in
            if let error = error {
                errorMessage = "Error updating profile: \(error.localizedDescription)"
                showAlert.toggle()
            } else {
                if let credentialURL = userProfile.userCredential {
                    FirebaseHelper.loadImageFromURL(urlString: credentialURL) { (image: UIImage?) in
                        if let image = image {
                            credentialImage = image
                        }
                    }
                }
                
                if let profileImageURL = userProfile.userProfileImage {
                    userProfile.profileImageURL = profileImageURL
                }
                DispatchQueue.main.async {
                    onProfileUpdated?() // Call the closure here
                    self.presentationMode.wrappedValue.dismiss()
                    isSavingProfile = false
                }
            }
            
        }
        
    }
    
    // Function to load user and credential images
    func loadImages() {
        isLoadingUserPhoto = true
        isLoadingCredentialImage = true
        
        if let profileImageURL = userProfile.userProfileImage {
            FirebaseHelper.loadImageFromURL(urlString: profileImageURL) { image in
                if let image = image {
                    userPhoto = image
                }
                isLoadingUserPhoto = false
            }
        } else {
            isLoadingUserPhoto = false
        }
        
        if let credentialImageURL = userProfile.userCredential {
            FirebaseHelper.loadImageFromURL(urlString: credentialImageURL) { image in
                if let image = image {
                    credentialImage = image
                }
                isLoadingCredentialImage = false
            }
        } else {
            isLoadingCredentialImage = false
        }
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    if let userPhoto = userPhoto {
                        Button(action: {
                            showImagePicker.toggle()
                        }) {
                            Image(uiImage: userPhoto)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 150, height: 150)
                                .clipShape(Circle())
                                .frame(maxWidth: .infinity, alignment: .center)
                        }
                    } else {
                        Button(action: {
                            showImagePicker.toggle()
                        }) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 75)
                                    .foregroundColor(.clear)
                                    .frame(width: 150, height: 150)
                                
                                if !isLoadingUserPhoto {
                                    Image(systemName: "person.crop.circle.fill.badge.plus")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 150, height: 150)
                                        .foregroundColor(.gray)
                                        .frame(maxWidth: .infinity, alignment: .center)
                                } else {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                }
                            }
                            .frame(maxWidth: .infinity, alignment: .center)
                        }
                    }
                    
                    Button(action: {
                        showImagePicker.toggle()
                    }) {
                        
                        if userPhoto != nil {
                            Text("Edit Photo")
                                .frame(maxWidth: .infinity, alignment: .center)
                                .sheet(isPresented: $showImagePicker) {
                                    ImagePicker(selectedImage: $userPhoto, imageData: $userPhotoData)
                                }
                        } else {
                            Text("Add Photo")
                                .frame(maxWidth: .infinity, alignment: .center)
                                .sheet(isPresented: $showImagePicker) {
                                    ImagePicker(selectedImage: $userPhoto, imageData: $userPhotoData)
                                }
                        }
                    }
                }
                .sheet(isPresented: $showImagePicker) {
                    ImagePicker(selectedImage: $userPhoto, imageData: $userPhotoData)
                }
                
                Section(header: Text("Name")) {
                    TextField("Your identity on the platform", text: $userName).onChange(of: userProfile.userName) { newValue in
                        userProfile.userName = newValue.trimmingCharacters(in: .whitespacesAndNewlines)
                    }
                }

                Section(header: Text("Headline")) {
                    TextField("Introduce yourself to the community", text: $userBio).onChange(of: userProfile.userBio) { newValue in
                        userProfile.userName = newValue.trimmingCharacters(in: .whitespacesAndNewlines)
                    }
                }

                Section(header: Text("Location")) {
                    TextField("Find practitioners near you", text: $userLocation).onChange(of: userProfile.userBio) { newValue in
                        userProfile.userLocation = newValue.trimmingCharacters(in: .whitespacesAndNewlines)
                    }
                }

                Section(header: Text("URL")) {
                    TextField("Primary website or social media", text: $userWebsite)
                        .autocapitalization(.none)
                        .onChange(of: userProfile.userWebsite) { newValue in
                            userProfile.userWebsite = newValue.trimmingCharacters(in: .whitespacesAndNewlines)
                        }
                }
            }
            
            .ignoresSafeArea(.keyboard)
            .gesture(DragGesture().onChanged({ _ in
                UIApplication.shared.endEditing()
            }))
            
            .navigationBarItems(leading: Button("Cancel") {
                presentationMode.wrappedValue.dismiss()
            }, trailing:
                Group {
                if isSavingProfile {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .gray))
                } else {
                    Button("Save") {
                        userProfile.userName = userName
                        userProfile.userBio = userBio
                        userProfile.userLocation = userLocation
                        userProfile.userWebsite = userWebsite
                        saveProfile()
                    }
                }
            })
            
            .onAppear {
                loadImages()
                userName = userProfile.userName
                userBio = userProfile.userBio
                userLocation = userProfile.userLocation
                userWebsite = userProfile.userWebsite
            }
        }
    }
}

extension UIApplication {
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
