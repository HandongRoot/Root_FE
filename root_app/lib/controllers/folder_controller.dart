import 'package:get/get.dart';
import 'package:root_app/services/api_services.dart';

class FolderController extends GetxController {
  var folders = <Map<String, dynamic>>[].obs;
  var isLoading = false.obs;

  Future<void> loadFolders() async {
    isLoading.value = true;
    final result = await ApiService.getFolders();
    folders.assignAll(result);
    isLoading.value = false;
  }

  void addFolder(Map<String, dynamic> folder) {
    folders.add(folder);
  }

  void deleteFolderById(String folderId) {
    folders.removeWhere((f) => f['id'].toString() == folderId);
  }

  void renameContent(String folderId, String contentId, String newTitle) {
    final folderIndex =
        folders.indexWhere((f) => f['id'].toString() == folderId);
    if (folderIndex != -1) {
      final contentList = folders[folderIndex]['contentReadDtos'];
      for (var content in contentList) {
        if (content['id'].toString() == contentId) {
          content['title'] = newTitle;
          break;
        }
      }
      folders.refresh();
    }
  }

  void removeContent(String folderId, String contentId) {
    final folderIndex =
        folders.indexWhere((f) => f['id'].toString() == folderId);
    if (folderIndex != -1) {
      final contentList = folders[folderIndex]['contentReadDtos'];
      contentList.removeWhere((c) => c['id'].toString() == contentId);
      folders.refresh();
    }
  }
}
