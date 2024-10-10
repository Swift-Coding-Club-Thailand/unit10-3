//
//  ContentView.swift
//  Picker Demo
//
//

import SwiftUI
import PhotosUI

struct ContentView: View {
    @State private var selectedItem: PhotosPickerItem? = nil
    @State private var selectedImage: UIImage? = nil
    
    var body: some View {
        VStack {
            if let image = selectedImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 300, height: 200)
                    .clipped()
                Button(action: {
                    selectedItem = nil
                    selectedImage = nil
                }, label: {
                    Text("Reset Picture")
                })
            } else {
                PhotosPicker(selection: $selectedItem, matching: .images) {
                    ContentUnavailableView("No Picture", systemImage: "photo.badge.plus", description: Text("Tap to select a photo from Photo Library"))
                }
                .buttonStyle(.plain)
            }
        }
        .onChange(of: selectedItem) { oldValue, newValue in
            Task {
                if let data = try await newValue?.loadTransferable(type: Data.self) {
                    let image = UIImage(data: data)
                    selectedImage = image
                }
            }
        }
        .onAppear(perform: {
            requestPhotoLibraryAccess()
        })
    }
    
    // This app requires access to the photo library for demonstration.
    private func requestPhotoLibraryAccess() {
        let status = PHPhotoLibrary.authorizationStatus()
        
        switch status {
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization { newStatus in
                if newStatus == .authorized {
                    print("Access granted.")
                } else {
                    print("Access denied.")
                }
            }
        case .restricted, .denied:
            print("Access denied or restricted.")
        case .authorized:
            print("Access already granted.")
        case .limited:
            print("Access limited.")
        @unknown default:
            print("Unknown authorization status.")
        }
    }
}

#Preview {
    ContentView()
}

