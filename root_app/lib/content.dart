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
      title: json['title']?.toString() ?? 'Unknown Title',
      url: json['url']?.toString() ?? '',
      category: json['category']?.toString() ?? 'Uncategorized',
    );
  }
}
