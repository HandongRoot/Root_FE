import 'package:get/get.dart';
import 'package:root_app/services/api_services.dart';

class FolderController extends GetxController {
  var folders = <Map<String, dynamic>>[].obs;
  var isLoading = false.obs;
  var isLoadingFolders = false.obs;
  var refreshGalleryFlag = false.obs;

  void refreshGallery() {
    refreshGalleryFlag.value = true;
  }

  void consumeGalleryRefreshFlag() {
    refreshGalleryFlag.value = false;
  }

  Future<void> loadFolders() async {
    isLoadingFolders.value = true;
    try {
      final loadedFolders = await ApiService.getFolders();
      folders.assignAll(loadedFolders);
    } finally {
      isLoadingFolders.value = false;
    }
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
