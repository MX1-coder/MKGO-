import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:fr.innoyadev.mkgodev/download/expenseDetails.dart';
import 'package:path/path.dart' as path;



class TakePhotoController extends GetxController{

  final storage = GetStorage();

  RxString imageFileExpense = ''.obs; // Define as a reactive variable
  RxBool isImageLoaded = false.obs;

  void takePhoto(ImageSource source) async {
    final ImagePicker imagePicker = ImagePicker();
    final XFile? file2Expense = await imagePicker.pickImage(
      source: source,
      imageQuality: 85,
    );

    if (file2Expense != null) {
      final List<String> allowedExtensions = ['jpg', 'png', 'jpeg'];
      final String extension = file2Expense.path.split('.').last;

      if (allowedExtensions.contains(extension.toLowerCase())) {
        storage.write('imagePath', file2Expense.path);

        print('Image file path: ${file2Expense.path}');

        // Extracting the file name with extension using path.basename
        final String fileName = path.basename(file2Expense.path);
        print('Image file name: $fileName');

        imageFileExpense.value = file2Expense.path;

        print(imageFileExpense);

        isImageLoaded.value = true;

        storage.write('imagePath', imageFileExpense.value);

        Get.to(() => ExpenseDetails(), arguments: [imageFileExpense]);
      } else {
        print('Invalid file extension. Please select a file with jpg, png, or jpeg extension.');
      }
    }
  }
}