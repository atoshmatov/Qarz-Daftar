import PhotosUI
import SwiftUI

struct EditProfileView: View {
    @EnvironmentObject private var store: AppStore
    @Environment(\.dismiss) private var dismiss

    @State private var name: String
    @State private var phoneNumber: String
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var selectedImageData: Data?
    @State private var removeCurrentPhoto = false
    @State private var alertMessage: String?
    @State private var isAlertPresented = false

    private var language: AppLanguage { store.profile.selectedLanguage }

    init(profile: UserProfile) {
        _name = State(initialValue: profile.name)
        _phoneNumber = State(initialValue: Formatters.editableProfilePhone(profile.phoneNumber))
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    avatarPreview

                    PhotosPicker(
                        selection: $selectedPhoto,
                        matching: .images,
                        photoLibrary: .shared()
                    ) {
                        Label(L10n.text(.changePhoto, language), systemImage: "photo")
                    }

                    if store.profile.avatar.isEmpty == false || selectedImageData != nil {
                        Button(L10n.text(.removePhoto, language), role: .destructive) {
                            selectedPhoto = nil
                            selectedImageData = nil
                            removeCurrentPhoto = true
                        }
                    }
                }

                Section {
                    TextField(L10n.text(.personName, language), text: $name)
                    TextField(L10n.text(.phone, language), text: $phoneNumber)
                        .keyboardType(.phonePad)
                        .onChange(of: phoneNumber) { newValue in
                            let formattedValue = Formatters.formatProfilePhoneInput(newValue)
                            if formattedValue != newValue {
                                phoneNumber = formattedValue
                            }
                        }
                }
            }
            .navigationTitle(L10n.text(.editProfile, language))
            .scrollDismissesKeyboard(.interactively)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(L10n.text(.cancel, language)) {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(L10n.text(.save, language)) {
                        saveProfile()
                    }
                }
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button(L10n.text(.done, language)) {
                        Keyboard.dismiss()
                    }
                }
            }
            .alert(L10n.text(.details, language), isPresented: $isAlertPresented) {
                Button("OK", role: .cancel) {
                    alertMessage = nil
                }
            } message: {
                Text(alertMessage ?? "")
            }
            .onChange(of: selectedPhoto) { newItem in
                guard let newItem else { return }
                Task {
                    if let data = try? await newItem.loadTransferable(type: Data.self) {
                        await MainActor.run {
                            selectedImageData = data
                            removeCurrentPhoto = false
                        }
                    }
                }
            }
        }
    }

    @ViewBuilder
    private var avatarPreview: some View {
        HStack {
            Spacer()
            Group {
                if let image = selectedAvatarImage {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                } else {
                    Image(systemName: "person.crop.circle.fill")
                        .resizable()
                        .scaledToFit()
                        .padding(18)
                        .foregroundStyle(Color.accentColor)
                }
            }
            .frame(width: 104, height: 104)
            .background(Color(.secondarySystemBackground), in: Circle())
            .clipShape(Circle())
            Spacer()
        }
        .padding(.vertical, 6)
    }

    private var selectedAvatarImage: UIImage? {
        if removeCurrentPhoto {
            return nil
        }

        if let selectedImageData,
           let selectedUIImage = UIImage(data: selectedImageData) {
            return selectedUIImage
        }

        return AvatarStorage.loadImage(path: store.profile.avatar)
    }

    private func saveProfile() {
        var updatedProfile = store.profile
        updatedProfile.name = name.trimmingCharacters(in: .whitespacesAndNewlines)
        updatedProfile.phoneNumber = Formatters.profilePhoneStorageDigits(phoneNumber)

        if let selectedImageData {
            do {
                let path = try AvatarStorage.saveImage(data: selectedImageData, previousPath: store.profile.avatar)
                updatedProfile.avatar = path
            } catch {
                alertMessage = L10n.text(.details, language)
                isAlertPresented = true
                return
            }
        } else if removeCurrentPhoto {
            AvatarStorage.remove(path: store.profile.avatar)
            updatedProfile.avatar = ""
        }

        store.profile = updatedProfile
        dismiss()
    }
}
