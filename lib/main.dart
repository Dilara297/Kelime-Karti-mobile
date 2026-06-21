import 'package:flutter/material.dart';
import 'api_service.dart';
import 'models/kelime.dart';
import 'kelime_ekle.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const AnaSayfa(),
    );
  }
}

// ana sayfa - kullanıcının listelerini gösteriyoruz
class AnaSayfa extends StatefulWidget {
  const AnaSayfa({super.key});

  @override
  State<AnaSayfa> createState() => _AnaSayfaState();
}

class _AnaSayfaState extends State<AnaSayfa> {

  // yeni liste eklemek için dialog açıyoruz
  void _yeniListePenceresiAc() {
    TextEditingController listeAdiController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: const Text("Yeni Liste Oluştur", style: TextStyle(color: Colors.blueGrey)),
          content: TextField(
            controller: listeAdiController,
            decoration: InputDecoration(
              labelText: "Liste Adı",
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("İptal", style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () async {
                if (listeAdiController.text.isEmpty) return;
                bool basarili = await listeEkle(listeAdiController.text);
                if (basarili) {
                  if (context.mounted) Navigator.pop(context);
                  setState(() {});
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueGrey.shade600,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text("Oluştur", style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  // liste adını değiştirmek için dialog
  void _listeDuzenlePenceresiAc(int id, String eskiIsim) {
    TextEditingController controller = TextEditingController(text: eskiIsim);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Text("Listeyi Düzenle", style: TextStyle(color: Colors.blueGrey)),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("İptal", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () async {
              if (controller.text.isEmpty) return;
              bool basarili = await listeDuzenle(id, controller.text);
              if (basarili) {
                setState(() {});
                if (context.mounted) Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueGrey.shade600,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text("Kaydet", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text(
          "Kelime Listelerim",
          style: TextStyle(color: Colors.blueGrey, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: listeleriGetir(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.blueGrey));
          }
          if (snapshot.hasError) {
            return const Center(child: Text("Listeler yüklenirken hata oluştu."));
          }

          if (snapshot.hasData) {
            List<Map<String, dynamic>> gercekListeler = snapshot.data!;

            if (gercekListeler.isEmpty) {
              return const Center(
                child: Text(
                  "Henüz hiç liste eklemediniz.",
                  style: TextStyle(color: Colors.grey, fontSize: 16),
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: gercekListeler.length,
              itemBuilder: (context, index) {
                var secilenListe = gercekListeler[index];

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade300, width: 0.5),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => KelimelerSayfasi(
                              listeId: secilenListe["id"],
                              listeIsmi: secilenListe["isim"],
                            ),
                          ),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.blueGrey.shade50,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(Icons.book_outlined, color: Colors.blueGrey.shade400, size: 24),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Text(
                                secilenListe["isim"],
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.blueGrey.shade800,
                                ),
                              ),
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit_outlined, color: Colors.grey, size: 20),
                                  onPressed: () => _listeDuzenlePenceresiAc(
                                    secilenListe["id"],
                                    secilenListe["isim"],
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                                  onPressed: () async {
                                    bool basarili = await listeSil(secilenListe["id"]);
                                    if (basarili) setState(() {});
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          }

          return const Center(child: Text("Veri bulunamadı."));
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blueGrey.shade600,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        child: const Icon(Icons.add, color: Colors.white, size: 26),
        onPressed: _yeniListePenceresiAc,
      ),
    );
  }
}

// seçilen listenin kelimelerini gösteren sayfa
class KelimelerSayfasi extends StatefulWidget {
  final int listeId;
  final String listeIsmi;

  const KelimelerSayfasi({super.key, required this.listeId, required this.listeIsmi});

  @override
  State<KelimelerSayfasi> createState() => _KelimelerSayfasiState();
}

class _KelimelerSayfasiState extends State<KelimelerSayfasi> {
  late Future<List<Kelime>> _kelimelerFuture;

  @override
  void initState() {
    super.initState();
    _kelimelerFuture = kelimeleriGetir();
  }

  // soru modundan veya kelime ekleme sayfasından dönünce listeyi yeniliyoruz
  void _sayfayiYenile() {
    setState(() {
      _kelimelerFuture = kelimeleriGetir();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: Text(
          widget.listeIsmi,
          style: const TextStyle(color: Colors.blueGrey, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.blueGrey),
        centerTitle: true,
      ),
      body: FutureBuilder<List<Kelime>>(
        future: _kelimelerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.blueGrey));
          }
          if (snapshot.hasError) {
            return Center(child: Text('Bir hata oluştu: ${snapshot.error}'));
          }

          if (snapshot.hasData) {
            List<Kelime> gelenTumKelimeler = snapshot.data!;

            // sadece bu listeye ait kelimeleri filtreliyoruz
            List<Kelime> ekrandaGosterilecekler = [];
            for (int i = 0; i < gelenTumKelimeler.length; i++) {
              if (gelenTumKelimeler[i].list_id == widget.listeId) {
                ekrandaGosterilecekler.add(gelenTumKelimeler[i]);
              }
            }

            if (ekrandaGosterilecekler.isEmpty) {
              return const Center(
                child: Text(
                  'Bu listede henüz kelime yok.',
                  style: TextStyle(color: Colors.grey, fontSize: 16),
                ),
              );
            }

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueGrey.shade600,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 1,
                      ),
                      onPressed: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SoruModuSayfasi(kelimeler: ekrandaGosterilecekler),
                          ),
                        );
                        _sayfayiYenile();
                      },
                      icon: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 24),
                      label: const Text(
                        "Çalışmaya Başla",
                        style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: ekrandaGosterilecekler.length,
                    itemBuilder: (context, index) {
                      return KelimeKarti(
                        id: ekrandaGosterilecekler[index].id,
                        eng: ekrandaGosterilecekler[index].eng,
                        tr: ekrandaGosterilecekler[index].tr,
                        example: ekrandaGosterilecekler[index].example,
                        known: ekrandaGosterilecekler[index].known,
                      );
                    },
                  ),
                ),
              ],
            );
          }

          return const Center(child: Text('Veri bulunamadı.'));
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blueGrey.shade600,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        child: const Icon(Icons.add, color: Colors.white, size: 26),
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => KelimeEkleSayfasi(listeId: widget.listeId)),
          );
          _sayfayiYenile();
        },
      ),
    );
  }
}

// kelime kartlarını tek tek gösterip biliyorum/bilmiyorum seçimi yaptıran ekran
class SoruModuSayfasi extends StatefulWidget {
  final List<Kelime> kelimeler;

  const SoruModuSayfasi({super.key, required this.kelimeler});

  @override
  State<SoruModuSayfasi> createState() => _SoruModuSayfasiState();
}

class _SoruModuSayfasiState extends State<SoruModuSayfasi> {
  int sayacIndex = 0;
  bool onYuzMu = true; // true ise ingilizce, false ise türkçe gösteriyoruz

  void _ileriGit() {
    if (sayacIndex < widget.kelimeler.length - 1) {
      setState(() {
        sayacIndex++;
        onYuzMu = true;
      });
    } else {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Listenin sonuna geldin!"),
          backgroundColor: Colors.blueGrey.shade600,
        ),
      );
    }
  }

  void _geriGit() {
    if (sayacIndex > 0) {
      setState(() {
        sayacIndex--;
        onYuzMu = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.kelimeler.isEmpty) return const Scaffold();

    var anlikKelime = widget.kelimeler[sayacIndex];

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: Text("${sayacIndex + 1} / ${widget.kelimeler.length}"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.blueGrey),
        centerTitle: true,
        titleTextStyle: const TextStyle(
          color: Colors.blueGrey,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
      body: Center(
        child: GestureDetector(
          onTap: () {
            setState(() {
              onYuzMu = !onYuzMu;
            });
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: MediaQuery.of(context).size.width * 0.85,
            height: 400,
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.grey.shade300, width: 1),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  onYuzMu ? anlikKelime.eng : anlikKelime.tr,
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueGrey.shade800,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 30),
                if (!onYuzMu)
                  Text(
                    anlikKelime.example,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.blueGrey.shade400,
                      fontStyle: FontStyle.italic,
                    ),
                    textAlign: TextAlign.center,
                  ),
                const SizedBox(height: 20),
                if (onYuzMu)
                  const Text(
                    "Çevirmek için dokun",
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(bottom: 40, left: 20, right: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back_ios_rounded),
              color: sayacIndex > 0 ? Colors.blueGrey : Colors.grey.shade300,
              iconSize: 28,
              onPressed: sayacIndex > 0 ? _geriGit : null,
            ),
            Row(
              children: [
                // bilmiyorum butonu
                Container(
                  decoration: BoxDecoration(color: Colors.red.shade50, shape: BoxShape.circle),
                  child: IconButton(
                    icon: Icon(Icons.close_rounded, color: Colors.red.shade400),
                    iconSize: 32,
                    onPressed: () {
                      kelimeDurumuGuncelle(anlikKelime.id, false);
                      _ileriGit();
                    },
                  ),
                ),
                const SizedBox(width: 20),
                // biliyorum butonu
                Container(
                  decoration: BoxDecoration(color: Colors.green.shade50, shape: BoxShape.circle),
                  child: IconButton(
                    icon: Icon(Icons.check_rounded, color: Colors.green.shade400),
                    iconSize: 32,
                    onPressed: () {
                      kelimeDurumuGuncelle(anlikKelime.id, true);
                      _ileriGit();
                    },
                  ),
                ),
              ],
            ),
            IconButton(
              icon: const Icon(Icons.arrow_forward_ios_rounded),
              color: Colors.blueGrey,
              iconSize: 28,
              onPressed: _ileriGit,
            ),
          ],
        ),
      ),
    );
  }
}

// tek bir kelimeyi gösteren kart widget'ı
// üstüne tıklayınca ingilizce/türkçe arasında geçiş yapıyor
class KelimeKarti extends StatefulWidget {
  final int id;
  final String eng;
  final String tr;
  final String example;
  final bool? known;

  const KelimeKarti({
    super.key,
    required this.id,
    required this.eng,
    required this.tr,
    required this.example,
    required this.known,
  });

  @override
  State<KelimeKarti> createState() => _KelimeKartiState();
}

class _KelimeKartiState extends State<KelimeKarti> {
  bool onYuzMu = true;
  late bool biliyorum;
  late bool bilmiyorum;
  bool silindiMi = false;
  late String guncelEng;
  late String guncelTr;
  late String guncelExample;

  @override
  void initState() {
    super.initState();
    guncelEng = widget.eng;
    guncelTr = widget.tr;
    guncelExample = widget.example;

    // başlangıçta known değerine göre durumu ayarlıyoruz
    if (widget.known == true) {
      biliyorum = true;
      bilmiyorum = false;
    } else if (widget.known == false) {
      biliyorum = false;
      bilmiyorum = true;
    } else {
      biliyorum = false;
      bilmiyorum = false;
    }
  }

  void _duzenlemePenceresiAc() {
    TextEditingController editEng = TextEditingController(text: guncelEng);
    TextEditingController editTr = TextEditingController(text: guncelTr);
    TextEditingController editOrnek = TextEditingController(text: guncelExample);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: const Text("Kelimeyi Düzenle", style: TextStyle(color: Colors.blueGrey)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: editEng,
                decoration: InputDecoration(
                  labelText: "İngilizce",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: editTr,
                decoration: InputDecoration(
                  labelText: "Türkçe",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: editOrnek,
                decoration: InputDecoration(
                  labelText: "Örnek Cümle",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("İptal", style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () async {
                bool basarili = await kelimeDuzenle(widget.id, editEng.text, editTr.text, editOrnek.text);
                if (basarili) {
                  setState(() {
                    guncelEng = editEng.text;
                    guncelTr = editTr.text;
                    guncelExample = editOrnek.text;
                  });
                  if (context.mounted) Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blueGrey.shade600),
              child: const Text("Kaydet", style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (silindiMi) return const SizedBox.shrink();

    // bilme durumuna göre kart rengini belirliyoruz
    Color kartRengi = Colors.white;
    if (biliyorum) kartRengi = Colors.green.shade50;
    else if (bilmiyorum) kartRengi = Colors.red.shade50;

    return GestureDetector(
      onTap: () => setState(() => onYuzMu = !onYuzMu),
      child: Card(
        color: kartRengi,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Colors.grey.shade300, width: 0.5),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      onYuzMu ? guncelEng : guncelTr,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.blueGrey.shade800,
                      ),
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit_outlined, color: Colors.grey, size: 20),
                        onPressed: _duzenlemePenceresiAc,
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                        onPressed: () async {
                          bool basarili = await kelimeSil(widget.id);
                          if (basarili) setState(() => silindiMi = true);
                        },
                      ),
                    ],
                  ),
                ],
              ),
              if (!onYuzMu) ...[
                const SizedBox(height: 4),
                Text(
                  guncelExample,
                  style: TextStyle(fontSize: 14, fontStyle: FontStyle.italic, color: Colors.grey.shade600),
                ),
              ],
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: () {
                      setState(() {
                        bilmiyorum = true;
                        biliyorum = false;
                      });
                      kelimeDurumuGuncelle(widget.id, false);
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(6.0),
                      child: Icon(
                        Icons.close_rounded,
                        size: 24,
                        color: bilmiyorum ? Colors.red.shade400 : Colors.grey.shade400,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: () {
                      setState(() {
                        biliyorum = true;
                        bilmiyorum = false;
                      });
                      kelimeDurumuGuncelle(widget.id, true);
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(6.0),
                      child: Icon(
                        Icons.check_rounded,
                        size: 24,
                        color: biliyorum ? Colors.green.shade400 : Colors.grey.shade400,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
