import Foundation
import UIKit



func getAllTanksImages() {
    fetchAllTankIDs { result in
        switch result {
        case .success(let tankIDs):
            fetchTankImagesUrlsAll(tankIds: tankIDs) { result in
                switch result {
                case .success(let tankImages):
                    // Directly pass the list of dictionaries
                    downloadTankImages(from: tankImages)
                case .failure(let error):
                    print("Failed to fetch tank images URLs: \(error)")
                }
            }
        case .failure(let error):
            print("Failed to fetch tank IDs: \(error)")
        }
    }
    }

func downloadTankImages(from dictionaries: [[Int: [String]]], contourFolderName: String = "contour", iconFolderName: String = "icons") {
    let dispatchGroup = DispatchGroup()

    for dictionary in dictionaries {
        for (tankId, urls) in dictionary {
            guard urls.count == 2 else {
                print("Invalid URL count for tank \(tankId). Expected 2, got \(urls.count).")
                continue
            }

            // Contour Image
            let contourName = "\(tankId)_contour.png"
            if let contourURL = URL(string: urls[0]) {
                dispatchGroup.enter()
                downloadAndSaveImage(from: contourURL, fileName: contourName, folderName: contourFolderName) {
                    print("Downloaded and saved contour image for tank \(tankId)")
                    dispatchGroup.leave()
                }
            }

            // Big Icon Image
            let bigIconName = "\(tankId)_big_icon.png"
            if let bigIconURL = URL(string: urls[1]) {
                dispatchGroup.enter()
                downloadAndSaveImage(from: bigIconURL, fileName: bigIconName, folderName: iconFolderName) {
                    print("Downloaded and saved big icon image for tank \(tankId)")
                    dispatchGroup.leave()
                }
            }
        }
    }

    dispatchGroup.notify(queue: .main) {
        print("All tank images downloaded and saved.")
    }
}

private func downloadAndSaveImage(from url: URL, fileName: String, folderName: String, completion: @escaping () -> Void) {
    URLSession.shared.dataTask(with: url) { data, response, error in
        if let error = error {
            print("Failed to download image from \(url): \(error.localizedDescription)")
            completion()
            return
        }

        guard let data = data, let image = UIImage(data: data) else {
            print("Failed to decode image from \(url)")
            completion()
            return
        }

        saveImageToStaticFolder(image: image, name: fileName, folderName: folderName)
        completion()
    }.resume()
}

private func saveImageToStaticFolder(image: UIImage, name: String, folderName: String) {
    guard let bundleURL = Bundle.main.resourceURL else {
        print("Bundle resource URL not found.")
        return
    }

    let folderURL = bundleURL.appendingPathComponent(folderName, isDirectory: true)
    let fileURL = folderURL.appendingPathComponent(name)

    do {
        // Ensure the directory exists
        if !FileManager.default.fileExists(atPath: folderURL.path) {
            try FileManager.default.createDirectory(at: folderURL, withIntermediateDirectories: true, attributes: nil)
            print("Directory created: \(folderURL.path)")
        }

        // Save the image
        if let data = image.pngData() {
            try data.write(to: fileURL)
            print("Image saved to \(folderName) at \(fileURL.path)")
        } else {
            print("Failed to convert image to PNG data.")
        }
    } catch {
        print("Error saving image: \(error.localizedDescription)")
    }
}


/// Loads a UIImage from a static folder in the app bundle.
func loadImageFromStaticFolder(name: String, folderName: String) -> UIImage? {
    guard let bundleURL = Bundle.main.resourceURL else {
        print("Bundle resource URL not found.")
        return nil
    }

    let folderURL = bundleURL.appendingPathComponent(folderName, isDirectory: true)
    let fileURL = folderURL.appendingPathComponent(name)

    if FileManager.default.fileExists(atPath: fileURL.path) {
        return UIImage(contentsOfFile: fileURL.path)
    } else {
        print("Image not found at \(fileURL.path)")
        return nil
    }
}



