import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(const KasirApp());
}

class KasirApp extends StatelessWidget {
  const KasirApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Aplikasi Kasir',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const FormKasirPage(),
    );
  }
}

class FormKasirPage extends StatefulWidget {
  const FormKasirPage({super.key});

  @override
  State<FormKasirPage> createState() => _FormKasirPageState();
}

class _FormKasirPageState extends State<FormKasirPage> {
  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();
  final _hargaController = TextEditingController();
  final _jumlahController = TextEditingController();

  // Data keranjang belanja sementara
  List<Map<String, dynamic>> _keranjang = [];
  int _totalBelanja = 0;

  // Format currency
  final _currencyFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ');

  void _tambahKeKeranjang() {
    if (_formKey.currentState!.validate()) {
      try {
        String nama = _namaController.text;
        int harga = int.parse(_hargaController.text);
        int jumlah = int.parse(_jumlahController.text);
        int subtotal = harga * jumlah;

        setState(() {
          _keranjang.add({
            'nama': nama,
            'harga': harga,
            'jumlah': jumlah,
            'subtotal': subtotal,
          });
          _totalBelanja += subtotal;
        });

        // Bersihkan input setelah ditambah
        _namaController.clear();
        _hargaController.clear();
        _jumlahController.clear();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Barang ditambahkan ke keranjang')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Format angka tidak valid')),
        );
      }
    }
  }

  void _hapusDariKeranjang(int index) {
    setState(() {
      _totalBelanja -= _keranjang[index]['subtotal'];
      _keranjang.removeAt(index);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Barang dihapus dari keranjang')),
    );
  }

  void _prosesBayar() {
    if (_keranjang.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Keranjang masih kosong, Ji!')),
      );
      return;
    }

    // TODO: Di sini nanti lu hubungin ke database Bos (Firebase/Supabase)
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Transaksi Sukses!'),
        content: Text(
          'Total ${_currencyFormat.format(_totalBelanja)} berhasil dikirim ke dashboard Bos.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _keranjang.clear();
                _totalBelanja = 0;
              });
              Navigator.pop(context);
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _namaController.dispose();
    _hargaController.dispose();
    _jumlahController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Input Kasir Eji'),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // FORM INPUT
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _namaController,
                    decoration: const InputDecoration(
                      labelText: 'Nama Produk',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Jangan kosong napa';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _hargaController,
                    decoration: const InputDecoration(
                      labelText: 'Harga (Rp)',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Isi harganya';
                      }
                      if (int.tryParse(value) == null) {
                        return 'Harus angka';
                      }
                      if (int.parse(value) <= 0) {
                        return 'Harus lebih dari 0';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _jumlahController,
                    decoration: const InputDecoration(
                      labelText: 'Jumlah Beli',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Berapa biji?';
                      }
                      if (int.tryParse(value) == null) {
                        return 'Harus angka';
                      }
                      if (int.parse(value) <= 0) {
                        return 'Harus lebih dari 0';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _tambahKeKeranjang,
                    icon: const Icon(Icons.add_shopping_cart),
                    label: const Text('Tambah ke Keranjang'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(45),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Daftar Belanja:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            // LIST KERANJANG
            Expanded(
              child: _keranjang.isEmpty
                  ? const Center(child: Text('Belum ada barang masuk'))
                  : ListView.builder(
                      itemCount: _keranjang.length,
                      itemBuilder: (context, index) {
                        final item = _keranjang[index];
                        return ListTile(
                          title: Text(item['nama']),
                          subtitle: Text(
                            '${item['jumlah']} x ${_currencyFormat.format(item['harga'])}',
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                _currencyFormat.format(item['subtotal']),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _hapusDariKeranjang(index),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),

            // TOTAL DAN TOMBOL BAYAR
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  _currencyFormat.format(_totalBelanja),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _prosesBayar,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(50),
              ),
              child: const Text(
                'PROSES BAYAR (KIRIM KE BOS)',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
