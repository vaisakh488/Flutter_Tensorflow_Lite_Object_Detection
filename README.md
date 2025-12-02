# Desert Animal Footprint Detection App

This Flutter application uses TensorFlow Lite object detection to identify animal footprints commonly found in desert environments.  
The detection model is trained using **Google Teachable Machine**, exported as a `.tflite` file, and integrated into the app to perform real-time object detection through the device camera.

The app is capable of detecting footprints from animals such as:
- **Camel**
- **Snake**
- **Eagle**
- **Crab**
- (and any additional classes you train)

This project demonstrates how lightweight machine learning models can be embedded directly into mobile applications for offline, real-time analysis.

---

## ✨ Features

- **TensorFlow Lite Object Detection**  
  Loads and runs a custom-trained `.tflite` model generated using Google Teachable Machine.

- **Real-time Footprint Recognition**  
  Uses the device's camera to detect animal footprints instantly.

- **Customizable Model**  
  Train your own classes in Google Teachable Machine, export the TFLite model, and plug it directly into the app.

- **Runs Offline**  
  No internet required—perfect for exploration in remote desert areas.

- **Cross-platform (Android & iOS)**  
  Built entirely with Flutter.

---

## 🧠 Model Training (Google Teachable Machine)

1. Visit: https://teachablemachine.withgoogle.com/
2. Choose **Image Project → Image Classification**.
3. Upload photos of animal footprints (camel, snake, crab, eagle, etc.).
4. Train the model using Teachable Machine’s interface.
5. Export the model in **TensorFlow Lite** format.
6. Include the following files in your Flutter project:
   - `model.tflite`
   - `labels.txt`

---

## 📁 Project Structure

Place the model files as follows:

