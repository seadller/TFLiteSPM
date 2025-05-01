
import Foundation
import TensorFlowLite

public class ModelRunner {
    private var interpreter: Interpreter?
    private var modelURL: URL?

    public init(remoteModelURL: URL, modelFileName: String, completion: @escaping (Bool) -> Void) {
        self.modelURL = remoteModelURL

        downloadModelIfNeeded(fileName: modelFileName) { localPath in
            guard let localPath = localPath else {
                print("Failed to download model.")
                completion(false)
                return
            }

            do {
                self.interpreter = try Interpreter(modelPath: localPath)
                try self.interpreter?.allocateTensors()
                print("Interpreter ready.")
                completion(true)
            } catch {
                print("Interpreter creation failed: \(error)")
                completion(false)
            }
        }
    }

    public func runModel(inputData: [Float]) -> [Float]? {
        guard let interpreter = interpreter else {
            print("Interpreter is not initialized.")
            return nil
        }

        do {
            // Convert the inputData array to Data
            let data = inputData.withUnsafeBufferPointer { buffer in
                Data(buffer: buffer)
            }

            try interpreter.copy(data, toInputAt: 0)
            try interpreter.invoke()

            let outputTensor = try interpreter.output(at: 0)
            return outputTensor.data.toArray(type: Float32.self)

        } catch {
            print("Error during model inference: \(error)")
            return nil
        }
    }


    private func downloadModelIfNeeded(fileName: String, completion: @escaping (String?) -> Void) {
        let fileManager = FileManager.default
        let docsDir = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let localPath = docsDir.appendingPathComponent("\(fileName).tflite")

        if fileManager.fileExists(atPath: localPath.path) {
            completion(localPath.path)
            return
        }

        guard let modelURL = modelURL else {
            completion(nil)
            return
        }

        let task = URLSession.shared.downloadTask(with: modelURL) { tempURL, _, error in
            if let error = error {
                print("Download error: \(error)")
                completion(nil)
                return
            }

            guard let tempURL = tempURL else {
                print("Download returned no file.")
                completion(nil)
                return
            }

            do {
                try fileManager.moveItem(at: tempURL, to: localPath)
                print("Model saved at \(localPath.path)")
                completion(localPath.path)
            } catch {
                print("Error saving model: \(error)")
                completion(nil)
            }
        }

        task.resume()
    }
}

extension Data {
    func toArray<T>(type: T.Type) -> [T] where T: Numeric {
        let count = self.count / MemoryLayout<T>.stride
        return withUnsafeBytes {
            Array(UnsafeBufferPointer<T>(start: $0.baseAddress!.assumingMemoryBound(to: T.self), count: count))
        }
    }
}
