

import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationView {
            VStack {
                Image("logo")
                    .resizable()
                    .frame(width: 200,height: 200)
                    
                
                
                
                // Canvas Studio Button
                NavigationLink(destination: CanvasStudioView()) {
                    HStack {
                        Image(systemName: "paintbrush")
                        Text("Canvas Studio")
                    }
                    .frame(width: 200, height: 50)
                    .background(Color.blue.opacity(0.8))
                    .foregroundColor(.white)
                    .cornerRadius(15)
                    .shadow(radius: 5)
                }
                .padding(.top, 20)

                // Text Drawing Button
                NavigationLink(destination: TextDrawingView()) {
                    HStack {
                        Image(systemName: "textformat")
                        Text("Text Drawing")
                    }
                    .frame(width: 200, height: 50)
                    .background(Color.green.opacity(0.8))
                    .foregroundColor(.white)
                    .cornerRadius(15)
                    .shadow(radius: 5)
                }
                .padding(.top, 20)

                // Photo Editing Button
                NavigationLink(destination: PhotoEditingView()) {
                    HStack {
                        Image(systemName: "photo")
                        Text("Photo Editing")
                    }
                    .frame(width: 200, height: 50)
                    .background(Color.purple.opacity(0.8))
                    .foregroundColor(.white)
                    .cornerRadius(15)
                    .shadow(radius: 5)
                }
                .padding(.top, 20)

               
                
                // Saved Images Button
                HStack {
                    Spacer()
                    NavigationLink(destination: SavedImagesView()) {
                        HStack {
                            Image(systemName: "photo.stack")
                            Text("Saved History")
                        }
                        .frame(width: 200, height: 50)
                        .background(Color.white.opacity(0.8))
                        .foregroundColor(.green)
                        .cornerRadius(15)
                        .shadow(radius: 5)
                    }
                    .padding(.top, 20)
                    Spacer()
                }
                Spacer()
            }
            .padding()
            .background(Color.red.opacity(0.8)) // Background color for the view
            .navigationTitle("Artify")
        }
    }
}

#Preview {
    ContentView()
}





















struct ArtGalleryView: View {
    @State private var showShareSheet = false
    @State private var showCopyAlert = false
    let artworks = ["Artwork 1", "Artwork 2", "Artwork 3"]
    
    var body: some View {
        VStack {
            Text("Your Art Gallery")
                .font(.largeTitle)
            
            List(artworks, id: \.self) { artwork in
                HStack {
                    Text(artwork)
                    
                    Spacer()
                    
                    Button(action: {
                        copyArtwork(artwork: artwork)
                    }) {
                        Image(systemName: "doc.on.doc")
                    }
                    .alert(isPresented: $showCopyAlert) {
                        Alert(title: Text("Copied"), message: Text("\(artwork) copied to clipboard"), dismissButton: .default(Text("OK")))
                    }
                    
                    Button(action: {
                        showShareSheet = true
                    }) {
                        Image(systemName: "square.and.arrow.up")
                    }
                    .sheet(isPresented: $showShareSheet) {
                        ActivityViewController(activityItems: [artwork])
                    }
                }
            }
        }
        .navigationTitle("Gallery")
    }
    
    func copyArtwork(artwork: String) {
        UIPasteboard.general.string = artwork
        showCopyAlert = true
    }
}




















import SwiftUI
import Photos
import UIKit



struct CanvasStudioView: View {
    @State private var currentPath = Path()
    @State private var allPaths: [Path] = []
    @State private var brushColor: Color = .black
    @State private var brushSize: CGFloat = 5.0
    @State private var msg: String = ""
    @State private var showSaveAlert = false
    @State private var showShareSheet = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Drawing indication
            Text("Draw freely in the box below!")
                .font(.title2)
                .fontWeight(.medium)
                .foregroundColor(.gray)
            
            // Canvas area
            ZStack {
                Canvas { context, size in
                    for path in allPaths {
                        context.stroke(path, with: .color(brushColor), lineWidth: brushSize)
                    }
                    context.stroke(currentPath, with: .color(brushColor), lineWidth: brushSize)
                }
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            currentPath.move(to: value.startLocation)
                            currentPath.addLine(to: value.location)
                        }
                        .onEnded { value in
                            allPaths.append(currentPath)
                            currentPath = Path()
                        }
                )
                .frame(height: 250)
                .border(Color.gray, width: 2)
                .background(Color.white)
            }

            // Brush size slider
            HStack {
                Text("Brush Size")
                    .font(.headline)
                Slider(value: $brushSize, in: 1...20)
                    .padding()
            }
            
            // Brush color and action buttons
            HStack(spacing: 10) {
                VStack{
                ColorPicker("Brush Color", selection: $brushColor)
                    .padding()
                
                // Save button
                HStack{
                    Button(action: {
                        saveArtwork()
                    }) {
                        Text("Save")
                            .frame(minWidth: 80)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    
                    // Download button
                    Button(action: {
                        downloadArtwork()
                    }) {
                        Text("Download")
                            .frame(minWidth: 80)
                            .padding()
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                }
                    HStack{
                        // Copy button
                        Button(action: {
                            copyArtwork()
                        }) {
                            Text("Copy")
                                .frame(minWidth: 80)
                                .padding()
                                .background(Color.orange)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                        
                        // Share button
                        Button(action: {
                            shareArtwork()
                        }) {
                            Text("Share")
                                .frame(minWidth: 80)
                                .padding()
                                .background(Color.purple)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                    }
                }
                .sheet(isPresented: $showShareSheet) {
                    let image = renderCanvasToImage()
                    ActivityView(activityItems: [image])
                }
            }
            .padding(.horizontal)
            .alert(isPresented: $showSaveAlert) {
                Alert(title: Text("Saved"), message: Text(msg), dismissButton: .default(Text("OK")))
            }
        }
        .padding(.horizontal)
        .navigationTitle("Canvas Studio")
        
    }
    
    // Functions for saving, downloading, copying, and sharing the artwork
    func saveArtwork() {
        let image = renderCanvasToImage()
        if let imageData = image.pngData() {
            var savedImages = UserDefaults.standard.object(forKey: "savedImages") as? [Data] ?? [Data]()
            savedImages.append(imageData)
            UserDefaults.standard.set(savedImages, forKey: "savedImages")
        }
        msg = "Artwork saved to Saved."
        showSaveAlert = true
    }

    func downloadArtwork() {
        let image = renderCanvasToImage()
        // Placeholder download action
        UIImageWriteToSavedPhotosAlbum(image, self, nil, nil)
        msg = "Artwork downloaded!"
        showSaveAlert = true
        print("Artwork downloaded!")
    }
    
    func copyArtwork() {
        let image = renderCanvasToImage()
        UIPasteboard.general.image = image
        msg = "Artwork copied!"
        showSaveAlert = true
        print("Artwork copied!")
    }
    
    func shareArtwork() {
        showShareSheet = true
    }

    // Render the canvas content to an image
    private func renderCanvasToImage() -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 400, height: 300))
        return renderer.image { context in
            context.cgContext.setFillColor(UIColor.white.cgColor)
            context.cgContext.fill(CGRect(x: 0, y: 0, width: 400, height: 400))
            for path in allPaths {
                context.cgContext.setStrokeColor(UIColor(brushColor).cgColor)
                context.cgContext.setLineWidth(brushSize)
                context.cgContext.addPath(path.cgPath)
                context.cgContext.strokePath()
            }
        }
    }
}














import SwiftUI
import PhotosUI


struct PhotoEditingView: View {
    var body: some View {
    
            ZStack {
                // Background
                LinearGradient(gradient: Gradient(colors: [Color.white, Color.mint,Color.gray]),
                               startPoint: .top, endPoint: .bottom)
                    .edgesIgnoringSafeArea(.all)
                
                // Floating objects
                VStack {
                    
                    Circle()
                        .fill(Color.white.opacity(0.5))
                        .frame(width: 100, height: 100)
                        .offset(x: -100, y: 0)
                    
                    Circle()
                        .fill(Color.black.opacity(0.9))
                        .frame(width: 150, height: 150)
                        .offset(x: 50, y: 200)
                    Circle()
                        .fill(Color.yellow.opacity(0.4))
                        .frame(width: 100, height: 150)
                        .offset(x: -50, y: -80)
                    Circle()
                        .fill(Color.white.opacity(0.6))
                        .frame(width: 150, height: 350)
                        .offset(x: 20, y: -150)
                    Circle()
                        .fill(Color.orange.opacity(0.8))
                        .frame(width: 150, height: 150)
                        .offset(x: -70, y: -200)
                    Circle()
                        .fill(Color.red.opacity(0.6))
                        .frame(width: 200, height: 200)
                        .offset(x: 50, y: -350)
                }
                
                // Main content
                VStack {
                    
                    
                
                    
                    VStack {
                        Text("Welcome to EffectPhoto")
                            .font(.largeTitle)
                            .foregroundColor(.white)
                            .padding()
                        
                        
                        
                        Image(systemName: "camera")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 150, height: 150)
                            .padding()
                            .foregroundColor(.white)
                        
                        HStack {
                            Spacer()
                            
                            NavigationLink(destination: PhotoSelectionView()) {
                                HStack {
                                    Image(systemName: "photo.on.rectangle.angled")
                                    Text("Select Photo")
                                }
                                .frame(width: 200, height: 50)
                                .background(Color.white.opacity(0.8))
                                .foregroundColor(.blue)
                                .cornerRadius(15)
                                .shadow(radius: 5)
                            }
                            .padding(.bottom, 20)
                            
                            Spacer()
                        }
                        
                      
                    }
                }
                .padding()
            }
           
        
    }
}












// MARK: - Image Picker
struct ImagePicker: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?

    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration()
        config.filter = .images
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let parent: ImagePicker

        init(_ parent: ImagePicker) {
            self.parent = parent
        }

        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            picker.dismiss(animated: true)
            guard let provider = results.first?.itemProvider else { return }
            if provider.canLoadObject(ofClass: UIImage.self) {
                provider.loadObject(ofClass: UIImage.self) { (image, error) in
                    DispatchQueue.main.async {
                        self.parent.selectedImage = image as? UIImage
                    }
                }
            }
        }
    }
}






















// MARK: - Text Drawing View


import SwiftUI

import SwiftUI

struct TextDrawingView: View {
    @State private var inputText: String = ""
    @State private var fontSize: CGFloat = 30
    @State private var textColor: Color = .black
    @State private var showSaveAlert = false
    @State private var showCopyAlert = false
    @State private var showDownloadAlert = false
    @State private var showShareSheet = false
    @State private var selectedFont: String = "System"  // State to manage font style

    // List of available fonts
    let fontStyles = ["System", "Helvetica", "Courier", "Times New Roman", "Arial"]

    var body: some View {
        VStack(spacing: 0) {
            TextField("Enter Text", text: $inputText)
                .padding()
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .font(.title2)

            // Drawing text area
            ZStack {
                Rectangle()
                    .stroke(Color.gray, lineWidth: 2)
                    .frame(height: 200)

                Text(inputText)
                    .font(selectedFontStyle())
                    .foregroundColor(textColor)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                    .padding()
            }

            // Font size slider
            HStack {
                Text("Font Size")
                Slider(value: $fontSize, in: 10...100)
                    .padding()
            }

            // Font style picker
            VStack(spacing: 4) {
                Text("Font Style: \(selectedFont)") // Shows selected font style
                    .font(.headline)
                    .padding()

                Picker("Font Style", selection: $selectedFont) {
                    ForEach(fontStyles, id: \.self) { font in
                        Text(font).tag(font)
                    }
                }
                .pickerStyle(MenuPickerStyle())
                .padding()

                // Color Picker and Action Buttons
                ColorPicker("Text Color", selection: $textColor)
                    .padding()

                HStack {
                    Button(action: saveArtwork) {
                        Text("Save")
                            .frame(minWidth: 80)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .alert(isPresented: $showSaveAlert) {
                        Alert(title: Text("Saved"), message: Text("Text saved to gallery and UserDefaults."), dismissButton: .default(Text("OK")))
                    }

                    Button(action: downloadArtwork) {
                        Text("Download")
                            .frame(minWidth: 80)
                            .padding()
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .alert(isPresented: $showDownloadAlert) {
                        Alert(title: Text("Downloaded"), message: Text("Text image downloaded."), dismissButton: .default(Text("OK")))
                    }
                }

                HStack {
                    Button(action: copyArtwork) {
                        Text("Copy")
                            .frame(minWidth: 80)
                            .padding()
                            .background(Color.orange)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .alert(isPresented: $showCopyAlert) {
                        Alert(title: Text("Copied"), message: Text("Text copied to clipboard."), dismissButton: .default(Text("OK")))
                    }

                    Button(action: {
                        showShareSheet = true
                    }) {
                        Text("Share")
                            .frame(minWidth: 80)
                            .padding()
                            .background(Color.purple)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                }
                .sheet(isPresented: $showShareSheet) {
                    let image = renderTextToImage()
                    ActivityView(activityItems: [image])
                }
            }
            .padding(.horizontal)
        }
        .padding(.horizontal)
        .navigationTitle("Text Drawing")
    }

    // Function to select the correct font based on the picker
    func selectedFontStyle() -> Font {
        switch selectedFont {
        case "Helvetica":
            return .custom("Helvetica", size: fontSize)
        case "Courier":
            return .custom("Courier", size: fontSize)
        case "Times New Roman":
            return .custom("Times New Roman", size: fontSize)
        case "Arial":
            return .custom("Arial", size: fontSize)
        default:
            return .system(size: fontSize)
        }
    }

    // Save artwork to UserDefaults and Photo Gallery
    func saveArtwork() {
        let image = renderTextToImage()

        // Save to UserDefaults
        if let imageData = image.pngData() {
            
            var savedImages = UserDefaults.standard.object(forKey: "savedImages") as? [Data] ?? [Data]()
            savedImages.append(imageData)
            UserDefaults.standard.set(savedImages, forKey: "savedImages")
        }
        showSaveAlert = true
    }

    // Download artwork
    func downloadArtwork() {
        let image = renderTextToImage()
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
        showDownloadAlert = true
    }

    // Copy artwork to clipboard
    func copyArtwork() {
        let image = renderTextToImage()
        UIPasteboard.general.image = image
        showCopyAlert = true
    }

    // Convert the text into an image
    private func renderTextToImage() -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 400, height: 300))
        return renderer.image { context in
            context.cgContext.setFillColor(UIColor.white.cgColor)
            context.cgContext.fill(CGRect(x: 0, y: 0, width: 400, height: 300))

            let uiColor = UIColor(textColor)
            let attributes: [NSAttributedString.Key: Any] = [
                .font: UIFont(name: selectedFont, size: fontSize) ?? UIFont.systemFont(ofSize: fontSize),
                .foregroundColor: uiColor
            ]
            let attributedString = NSAttributedString(string: inputText, attributes: attributes)
            attributedString.draw(in: CGRect(x: 20, y: 100, width: 360, height: 100))
        }
    }
}
















import SwiftUI
import UIKit
import CoreImage

struct PhotoSelectionView: View {
    @State private var selectedImage: UIImage?
    @State private var isImagePickerPresented = false
    @State private var brightness: Double = 0.0
    @State private var saturation: Double = 1.0
    @State private var contrast: Double = 1.0
    @State private var exposure: Double = 0.0
    @State private var highlights: Double = 1.0
    @State private var shadows: Double = 0.0
    @State private var sharpness: Double = 0.0
    @State private var selectedFilter: String = "None"
    @State private var isFilterPickerPresented = false
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""
    
    let filters = [
        "None", "CISepiaTone", "CIPhotoEffectNoir", "CIPhotoEffectChrome",
        "CIPhotoEffectFade", "CIPhotoEffectMono",
        "CIPhotoEffectProcess", "CIPhotoEffectTonal", "CIPhotoEffectTransfer",
        "CIColorInvert", "CIGaussianBlur"
    ]
    
    var body: some View {
        ScrollView {
            VStack {
                
                if let image = selectedImage {
                    Image(uiImage: applyEffects(to: image))
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxWidth: 300, maxHeight: 250)
                        .padding()
                } else {
                    Text("No Photo Selected")
                        .font(.headline)
                        .foregroundColor(.gray)
                        .padding()
                }
                
                Button(action: {
                    isImagePickerPresented.toggle()
                }) {
                    Text("Pick Photo")
                        .frame(width: 200, height: 50)
                        .background(Color.black)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .sheet(isPresented: $isImagePickerPresented) {
                    ImagePicker(selectedImage: $selectedImage)
                }
                
          
                .padding()
                .sheet(isPresented: $isFilterPickerPresented) {
                    VStack {
                        Text("Select a Filter")
                            .font(.headline)
                            .padding()
                        
                        Picker("Select Filter", selection: $selectedFilter) {
                            ForEach(filters, id: \.self) { filter in
                                Text(filter)
                            }
                        }
                        .pickerStyle(.menu)
                        .padding()
                        
                        Button("Done") {
                            isFilterPickerPresented.toggle()
                        }
                        .padding()
                    }
                }
                
                VStack(spacing: 20) {
                    VStack {
                        effectSlider(title: "Brightness", value: $brightness, range: -1...1)
                        effectSlider(title: "Saturation", value: $saturation, range: 0...2)
                    }
                    Button(action: {
                        isFilterPickerPresented.toggle()
                    }) {
                        Text("Add New Filter")
                            .frame(width: 200, height: 50)
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    
                    HStack {
                        effectSlider(title: "Contrast", value: $contrast, range: 0...4)
                        
                    }
                    
                
                    HStack {
                        effectSlider(title: "Exposure", value: $exposure, range: -2...2)
                        
                    }
                    
                }
                
                if selectedImage != nil {
                    HStack(spacing: 10) {
                        VStack{
                            Button(action: copyImage) {
                                HStack {
                                    Image(systemName: "doc.on.doc")
                                    Text("Copy")
                                }
                                .frame(width: 100, height: 50)
                                .background(Color.gray)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                            }
                            
                            Button(action: shareImage) {
                                HStack {
                                    Image(systemName: "square.and.arrow.up")
                                    Text("Share")
                                }
                                .frame(width: 100, height: 50)
                                .background(Color.gray)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                            }
                        }
                        VStack{
                            Button(action: saveToPhotos) {
                                HStack {
                                    Image(systemName: "square.and.arrow.down")
                                    Text("Download")
                                }
                                .frame(width: 200, height: 50)
                                .background(Color.gray)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                            }
                            
                            Button(action: saveImage) {
                                HStack {
                                    Image(systemName: "arrow.down.to.line.alt")
                                    Text("Save Here")
                                }
                                .frame(width: 150, height: 50)
                                .background(Color.purple)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                            }
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Select Photo")
            .padding()
            .background(LinearGradient(gradient: Gradient(colors: [Color.mint.opacity(0.9), Color.red.opacity(0.9),Color.yellow.opacity(0.9),Color.green.opacity(0.9)]), startPoint: .top, endPoint: .bottom))
            .alert(isPresented: $showAlert) {
                Alert(title: Text("Info"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
            }
        }
    }
    
    func effectSlider(title: String, value: Binding<Double>, range: ClosedRange<Double>) -> some View {
        VStack {
            Text(title)
            Slider(value: value, in: range)
                .padding(.horizontal)
        }
    }
    
    func applyEffects(to image: UIImage) -> UIImage {
        guard let inputImage = CIImage(image: image) else { return image }
        
        let colorControlsFilter = CIFilter(name: "CIColorControls")!
        colorControlsFilter.setValue(inputImage, forKey: kCIInputImageKey)
        colorControlsFilter.setValue(brightness, forKey: kCIInputBrightnessKey)
        colorControlsFilter.setValue(saturation, forKey: kCIInputSaturationKey)
        colorControlsFilter.setValue(contrast, forKey: kCIInputContrastKey)
        
        let exposureFilter = CIFilter(name: "CIExposureAdjust")!
        exposureFilter.setValue(colorControlsFilter.outputImage, forKey: kCIInputImageKey)
        exposureFilter.setValue(exposure, forKey: kCIInputEVKey)
        
        let highlightShadowFilter = CIFilter(name: "CIHighlightShadowAdjust")!
        highlightShadowFilter.setValue(exposureFilter.outputImage, forKey: kCIInputImageKey)
        highlightShadowFilter.setValue(highlights, forKey: "inputHighlightAmount")
        highlightShadowFilter.setValue(shadows, forKey: "inputShadowAmount")
        
        let sharpenFilter = CIFilter(name: "CISharpenLuminance")!
        sharpenFilter.setValue(highlightShadowFilter.outputImage, forKey: kCIInputImageKey)
        sharpenFilter.setValue(sharpness, forKey: kCIInputSharpnessKey)
        
        let selectedFilterOutput = applySelectedFilter(to: sharpenFilter.outputImage ?? inputImage)
        
        let context = CIContext()
        guard let cgImage = context.createCGImage(selectedFilterOutput, from: selectedFilterOutput.extent) else { return image }
        
        return UIImage(cgImage: cgImage)
    }
    
    func applySelectedFilter(to image: CIImage) -> CIImage {
        guard selectedFilter != "None" else { return image }
        
        let filter = CIFilter(name: selectedFilter)!
        filter.setValue(image, forKey: kCIInputImageKey)
        
        return filter.outputImage ?? image
    }
    
    func copyImage() {
        guard let selectedImage = selectedImage else { return }
        let editedImage = applyEffects(to: selectedImage)
        UIPasteboard.general.image = editedImage
        alertMessage = "Edited image copied to clipboard."
        showAlert = true
    }
    
    func shareImage() {
        guard let selectedImage = selectedImage else { return }
        let editedImage = applyEffects(to: selectedImage)
        let activityController = UIActivityViewController(activityItems: [editedImage], applicationActivities: nil)
        UIApplication.shared.windows.first?.rootViewController?.present(activityController, animated: true, completion: nil)
    }
    
    func saveToPhotos() {
        guard let selectedImage = selectedImage else { return }
        let editedImage = applyEffects(to: selectedImage)
        UIImageWriteToSavedPhotosAlbum(editedImage, nil, nil, nil)
        alertMessage = "Edited image saved to Photos."
        showAlert = true
    }
    
    func saveImage() {
        guard let selectedImage = selectedImage else { return }
        let editedImage = applyEffects(to: selectedImage)
        guard let imageData = editedImage.pngData() else {
            alertMessage = "Failed to convert image to data."
            showAlert = true
            return
        }
        
        var savedImages = UserDefaults.standard.object(forKey: "savedImages") as? [Data] ?? [Data]()
        savedImages.append(imageData)
        UserDefaults.standard.set(savedImages, forKey: "savedImages")
        
        alertMessage = "Image saved to UserDefaults!"
        showAlert = true
    }
}






#Preview {
    PhotoSelectionView()
}





import SwiftUI

struct SavedImagesView: View {
    @State private var savedImages: [UIImage] = []
    @State private var selectedImage: UIImage?
    @State private var showActionSheet = false
    @State private var selectedIndex: Int?
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        VStack {
            if savedImages.isEmpty {
                Text("No images saved.")
                    .font(.headline)
                    .padding()
            } else {
                ScrollView {
                    VStack(spacing: 10) {
                        ForEach(savedImages.indices, id: \.self) { index in
                            let image = savedImages[index]
                            ZStack(alignment: .topTrailing) {
                                Image(uiImage: image)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(maxWidth: .infinity, maxHeight: 200)
                                    .padding()
                                    .onTapGesture {
                                        selectedImage = image
                                        selectedIndex = index
                                        showActionSheet = true
                                    }
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle("Saved Images")
        .onAppear(perform: loadSavedImages)
        .actionSheet(isPresented: $showActionSheet) {
            ActionSheet(
                title: Text("Choose an action"),
                buttons: [
                    .default(Text("Download")) {
                        if let image = selectedImage {
                            saveToPhotos(image)
                            alertMessage = "Image saved to Photos."
                            showAlert = true
                        }
                    },
                    .default(Text("Share")) {
                        if let image = selectedImage {
                            shareImage(image)
                     
                        }
                    },
                    .default(Text("Copy")) {
                        if let image = selectedImage {
                            copyImage(image)
                            alertMessage = "Image copied to clipboard."
                            showAlert = true
                        }
                    },
                    .destructive(Text("Delete")) {
                        if let index = selectedIndex {
                            deleteImage(at: index)
                            alertMessage = "Image deleted."
                            showAlert = true
                        }
                    },
                    .cancel()
                ]
            )
        }
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("Info"),
                message: Text(alertMessage),
                dismissButton: .default(Text("OK"))
            )
        }
    }

    func loadSavedImages() {
        if let savedData = UserDefaults.standard.object(forKey: "savedImages") as? [Data] {
            savedImages = savedData.compactMap { UIImage(data: $0) }
        }
    }

    func saveToPhotos(_ image: UIImage) {
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
    }

    func shareImage(_ image: UIImage) {
        let av = UIActivityViewController(activityItems: [image], applicationActivities: nil)
        if let vc = UIApplication.shared.windows.first?.rootViewController {
            vc.present(av, animated: true, completion: nil)
        }
    }

    func copyImage(_ image: UIImage) {
        UIPasteboard.general.image = image
    }

    func deleteImage(at index: Int) {
        savedImages.remove(at: index)
        // Update UserDefaults
        let imageDataArray = savedImages.compactMap { $0.pngData() }
        UserDefaults.standard.set(imageDataArray, forKey: "savedImages")
    }
}


