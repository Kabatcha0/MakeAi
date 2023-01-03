import 'dart:io';

import 'package:ai/cubit/states.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite/tflite.dart';

class AiCubit extends Cubit<AiStates> {
  AiCubit() : super(AiInitilalState());
  static AiCubit get(context) => BlocProvider.of(context);
  File? file;
  ImagePicker? imagePicker;
  List? output;
  bool check = false;
  void getImage() {
    imagePicker = ImagePicker();
    imagePicker!.pickImage(source: ImageSource.gallery).then((value) {
      if (value != null) {
        file = File(value.path);
        classifyImage(file!);
        check = true;
      } else {
        return null;
      }
    });
    emit(AiCameraState());
  }

  void load() {
    Tflite.loadModel(model: "ai/model_unquant.tflite", labels: "ai/labels.txt")
        .then((value) {
      emit(AiLoadModelState());
    });
  }

  void classifyImage(File image) {
    Tflite.runModelOnImage(
            path: image.path,
            imageMean: 127.5, // defaults to 127.5
            imageStd: 127.5, // defaults to 127.5
            numResults: 2, // defaults to 5
            threshold: 0.1, // defaults to 0.1
            asynch: true // defaults to true
            )
        .then((value) {
      output = value;
      print(output);
      emit(AiClassifyImageState());
    });
  }
}
