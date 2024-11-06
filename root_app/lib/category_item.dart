class CategoryItem {
  final String title;
  final String url;
  final String category;

  CategoryItem({
    required this.title,
    required this.url,
    required this.category,
  });

  Map<String, dynamic> toJson() => {
        'title': title,
        'url': url,
        'category': category,
      };

  factory CategoryItem.fromJson(Map<String, dynamic> json) {
    return CategoryItem(
      title:
          json['title']?.toString() ?? 'Unknown Title', // Use default if null
      url: json['url']?.toString() ?? '', // Use default if null
      category: json['category']?.toString() ??
          'Uncategorized', // Use default if null
    );
  }
}
