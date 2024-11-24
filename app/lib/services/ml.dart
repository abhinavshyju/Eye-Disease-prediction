import 'dart:typed_data';

import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;
import 'dart:io';

class MLService {
  Interpreter? _interpreter;
  List<String>? _labels;

  Future<void> loadModel() async {
    try {
      _interpreter = await Interpreter.fromAsset('assets/model.tflite');
      // final labelsFile = await File('assets/labels.txt').readAsLines();
      final labelsFile = ['Cataract', 'Conjunctivitis', 'Glaucoma', 'Normal'];
      _labels = labelsFile;
    } catch (e) {
      print('Error loading model: $e');
    }
  }

  Future<String?> predict(File imageFile) async {
    if (_interpreter == null || _labels == null) {
      return 'Model not loaded';
    }

    var image = img.decodeImage(imageFile.readAsBytesSync());
    var resizedImage = img.copyResize(image!,
        width: 224, height: 224); // Adjust size as needed

    var input =
        imageToByteListFloat32(resizedImage, 224); // Adjust size as needed
    var output =
        List.filled(1 * _labels!.length, 0).reshape([1, _labels!.length]);

    _interpreter!.run(input, output);

    List<double> outputList = List<double>.from(output[0]);
    print(outputList);
    double maxValue =
        outputList.reduce((curr, next) => curr > next ? curr : next);

    int maxIndex = outputList.indexOf(maxValue);
    print(maxIndex);
    return _labels![maxIndex];
  }

  List imageToByteListFloat32(img.Image image, int inputSize) {
    var convertedBytes = Float32List(1 * inputSize * inputSize * 3);
    var buffer = Float32List.view(convertedBytes.buffer);
    int pixelIndex = 0;

    for (var i = 0; i < inputSize; i++) {
      for (var j = 0; j < inputSize; j++) {
        var pixel = image.getPixel(j, i);
        buffer[pixelIndex++] = (img.getRed(pixel) - 128) / 128;
        buffer[pixelIndex++] = (img.getGreen(pixel) - 128) / 128;
        buffer[pixelIndex++] = (img.getBlue(pixel) - 128) / 128;
      }
    }
    return buffer.buffer.asFloat32List().reshape([1, inputSize, inputSize, 3]);
  }
}
