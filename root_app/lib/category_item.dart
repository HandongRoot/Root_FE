class CategoryItem {
  final String title; // The title of the item
  final String url; // The URL associated with the item (e.g., YouTube link)
  final String category; // The category to which the item belongs

  // Constructor to initialize all fields, requiring title, url, and category
  CategoryItem({
    required this.title,
    required this.url,
    required this.category,
  });

  // Method to convert a CategoryItem object into a Map (JSON-like structure)
  Map<String, dynamic> toJson() => {
        'title': title, // Store title in JSON
        'url': url, // Store URL in JSON
        'category': category, // Store category in JSON
      };

  // Factory constructor to create a CategoryItem object from a JSON Map
  factory CategoryItem.fromJson(Map<String, dynamic> json) {
    return CategoryItem(
      title: json['title'], // Extract the title from the JSON Map
      url: json['url'], // Extract the URL from the JSON Map
      category: json['category'], // Extract the category from the JSON Map
    );
  }
}
