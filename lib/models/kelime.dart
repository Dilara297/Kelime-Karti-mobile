class Kelime {
  final int id;
  final int list_id;
  final String eng;
  final String tr;
  final String example;
  bool? known; 

  Kelime({
    required this.id,
    required this.list_id,
    required this.eng,
    required this.tr,
    required this.example,
    this.known, 
  });

  // API'den gelen veriyi modelimize dönüştüren fabrikayı kurduk
  factory Kelime.fromJson(Map<String, dynamic> json) {
    return Kelime(
      id: json['id'],
      // Django'daki ForeignKey ismini (liste) burada kendi list_id değişkenimize mapliyoruz
      list_id: json['liste'] ?? 0, 
      eng: json['eng'] ?? "Kelime bulunamadı",
      tr: json['tr'] ?? "Anlamı yok",
      example: json['example'] ?? "Örnek cümle eklenmemiş.",
      // known alanı null gelebileceği için olduğu gibi alıyoruz
      known: json['known'], 
    );
  }
}