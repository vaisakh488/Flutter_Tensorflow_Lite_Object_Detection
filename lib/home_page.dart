import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite_v2/tflite_v2.dart';
import 'package:hive/hive.dart';
import 'login.dart';
import 'package:flutter/services.dart' show rootBundle;

class ObjectDetectionPage extends StatefulWidget {
  @override
  _ObjectDetectionPageState createState() => _ObjectDetectionPageState();
}

class _ObjectDetectionPageState extends State<ObjectDetectionPage> {
  File? _image;
  List<dynamic>? _recognitions;
  bool _busy = false;

  double _threshold = 0.9; // default 90%
  int _numResults = 2; // default 2 results

  late Box appBox;

  @override
  void initState() {
    super.initState();
    appBox = Hive.box('appBox');
    _loadModel();
  }

  Future<void> _loadModel() async {
    int? savedNumResults = appBox.get('numResults');
    double? savedThreshold = appBox.get('threshold');

    if (savedNumResults != null) _numResults = savedNumResults;
    if (savedThreshold != null) _threshold = savedThreshold;
    setState(() => _busy = true);
    await Tflite.loadModel(
      model: "assets/model.tflite",
      labels: "assets/labels.txt",
      numThreads: 1,
      isAsset: true,
      useGpuDelegate: false,
    );
    setState(() => _busy = false);
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );
    if (pickedFile == null) return;

    setState(() => _image = File(pickedFile.path));
    _detectObject(pickedFile.path);
  }

  Future<void> _captureImage() async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.camera,
    );
    if (pickedFile == null) return;

    setState(() => _image = File(pickedFile.path));
    _detectObject(pickedFile.path);
  }

  Future<int> countLabels() async {
    final String labelData = await rootBundle.loadString('assets/labels.txt');
    final lines = labelData.split('\n');
    // Remove empty lines and trim whitespace
    final labels =
        lines.map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
    return labels.length;
  }

  Future<void> _detectObject(String imagePath) async {
    setState(() => _busy = true);

    final recognitions = await Tflite.runModelOnImage(
      path: imagePath,
      imageMean: 127.5,
      imageStd: 127.5,
      numResults: _numResults,
      threshold: _threshold,
      asynch: true,
    );

    setState(() {
      _recognitions = recognitions;
      _busy = false;
    });
  }

  Future<void> _openInfoDialog() async {
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Trace Mind'),
          content: StatefulBuilder(
            builder: (context, setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Developed by:',
                    style: TextStyle(
                      color: const Color.fromARGB(255, 38, 68, 115),
                      fontSize: 17,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    '1.Awadh Ahmed Almansoori',
                    style: TextStyle(
                      color: const Color.fromARGB(255, 60, 132, 247),
                      fontSize: 15,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    '2.Abdullah Fadhl',
                    style: TextStyle(
                      color: const Color.fromARGB(255, 60, 132, 247),
                      fontSize: 15,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    '3.Abdelrahman Hesham',
                    style: TextStyle(
                      color: const Color.fromARGB(255, 60, 132, 247),
                      fontSize: 15,
                    ),
                  ),
                ],
              );
            },
          ),
          actions: [
            TextButton(
              child: Text('Close'),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        );
      },
    );
  }

  Future<void> _openSettingsDialog() async {
    // Temporary local variables to hold slider values inside the dialog
    double tempThreshold = _threshold;
    int tempNumResults = _numResults;
    int count = await countLabels();

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Settings'),
          content: StatefulBuilder(
            builder: (context, setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '*Number of Results- Specifies how many detections to show after processing the image',
                    style: TextStyle(
                      color: const Color.fromARGB(255, 87, 87, 87),
                      fontSize: 13,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    '*Threshold- Only detections with a confidence above this percentage will be shown.',
                    style: TextStyle(
                      color: const Color.fromARGB(255, 87, 87, 87),
                      fontSize: 13,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Models available in the current dataset: $count',
                    style: TextStyle(
                      color: const Color.fromARGB(255, 37, 130, 237),
                      fontSize: 13,
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    "Number of Results: $tempNumResults",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Slider(
                    value: tempNumResults.toDouble(),
                    min: 1,
                    max: 10,
                    divisions: 9,
                    label: '$tempNumResults',
                    onChanged: (value) {
                      setState(() => tempNumResults = value.toInt());
                    },
                  ),
                  SizedBox(height: 10),
                  Text(
                    "Threshold: ${(tempThreshold * 100).toStringAsFixed(0)}%",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Slider(
                    value: tempThreshold,
                    min: 0.1,
                    max: 0.9,
                    divisions: 8,
                    label: '${(tempThreshold * 100).toStringAsFixed(0)}%',
                    onChanged: (value) {
                      setState(() => tempThreshold = value);
                    },
                  ),
                ],
              );
            },
          ),
          actions: [
            TextButton(
              child: Text('Cancel'),
              onPressed: () => Navigator.pop(context),
            ),
            ElevatedButton(
              child: Text('Save'),
              onPressed: () async {
                setState(() {
                  _numResults = tempNumResults;
                  _threshold = tempThreshold;
                });

                // Save to Hive
                await appBox.put('numResults', _numResults);
                await appBox.put('threshold', _threshold);

                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    Tflite.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final double fontSize = screenWidth * 0.04; // ~18 on 400px width
    final double buttonFontSize = screenWidth * 0.055;
    final double buttonHeight = screenHeight * 0.07;
    final double spacing = screenHeight * 0.01;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset(
              'assets/logo.png', // Replace with your image path
              height: 32,
            ),
            const SizedBox(width: 8),
            const Text(
              'Trace Mind',
              style: TextStyle(
                color: Color.fromARGB(255, 78, 28, 10),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(icon: const Icon(Icons.info), onPressed: _openInfoDialog),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await appBox.put('isloggedin', false);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => LoginPage()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: _openSettingsDialog,
          ),
        ],
      ),

      body:
          _busy
              ? const Center(child: CircularProgressIndicator())
              : Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(4),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SizedBox(height: spacing),
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: const Color.fromARGB(255, 245, 233, 215),
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            "Trace Mind aims to preserve and enhance the fading expertise of animal trace tracking in desert using AI. This tool can identify animal tracks in desert, mimicking the skills of human trackers",
                            style: TextStyle(
                              fontSize: fontSize,
                              color: Colors.grey[800],
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        SizedBox(height: spacing * 1.5),

                        SizedBox(
                          height: buttonHeight,
                          child: ElevatedButton(
                            onPressed: _pickImage,
                            child: Text(
                              'Pick Image from Gallery',
                              style: TextStyle(fontSize: buttonFontSize),
                            ),
                          ),
                        ),
                        SizedBox(height: spacing),

                        SizedBox(
                          height: buttonHeight,
                          child: ElevatedButton(
                            onPressed: _captureImage,
                            child: Text(
                              'Capture Image from Camera',
                              style: TextStyle(fontSize: buttonFontSize),
                            ),
                          ),
                        ),
                        SizedBox(height: spacing),

                        _image != null
                            ? Expanded(
                              child: Column(
                                children: [
                                  Image.file(
                                    _image!,
                                    height: screenHeight * 0.35,
                                  ),
                                  (_recognitions != null &&
                                          _recognitions!.isNotEmpty)
                                      ? Expanded(
                                        child: ListView.builder(
                                          itemCount: _recognitions!.length,
                                          itemBuilder: (context, index) {
                                            final result =
                                                _recognitions![index];
                                            return ListTile(
                                              title: Center(
                                                child: Text(
                                                  result['label']
                                                      .toString()
                                                      .split(' ')
                                                      .skip(1)
                                                      .join(' '),
                                                  style: TextStyle(
                                                    fontSize: fontSize * 1.3,
                                                    fontWeight: FontWeight.w600,
                                                    color: const Color.fromARGB(
                                                      255,
                                                      21,
                                                      101,
                                                      166,
                                                    ),
                                                  ),
                                                  textAlign: TextAlign.center,
                                                ),
                                              ),
                                              subtitle: Center(
                                                child: Text(
                                                  "Confidence level: ${(result['confidence'] * 100).toStringAsFixed(2)}%",
                                                  style: TextStyle(
                                                    fontSize: fontSize * 1.1,
                                                    color: Colors.red,
                                                  ),
                                                  textAlign: TextAlign.center,
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      )
                                      : Padding(
                                        padding: const EdgeInsets.all(12),
                                        child: Text(
                                          'No detection found',
                                          style: TextStyle(
                                            fontSize: fontSize,
                                            color: Colors.grey,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                ],
                              ),
                            )
                            : const Center(
                              child: Text(
                                "No image selected",
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                      ],
                    ),
                  ),
                ],
              ),
    );
  }
}
