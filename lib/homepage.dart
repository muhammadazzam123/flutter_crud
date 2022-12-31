import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_crud/editdata.dart';
import 'package:flutter_crud/tambahdata.dart';
import 'package:http/http.dart' as http;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List _listdata = [];
  bool _isloading = true;

  Future _getdata() async {
    try {
      final response =
          await http.get(Uri.parse("http://192.168.0.31/crudflutter/read.php"));
      if (response.statusCode == 200) {
        print(response.body);
        final data = jsonDecode(response.body);
        setState(() {
          _listdata = data;
          _isloading = false;
        });
      }
    } catch (e) {
      print(e);
    }
  }

  Future _hapusdata(String id) async {
    try {
      final response = await http.post(
        Uri.parse("http://192.168.0.31/crudflutter/hapus.php"),
        body: {
          'nim': id,
        },
      );
      if (response.statusCode == 200) {
        return true;
      }
      return false;
    } catch (e) {
      print(e);
    }
  }

  @override
  void initState() {
    // print(_listdata);
    _getdata();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Page'),
        centerTitle: true,
      ),
      body: _isloading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : ListView.builder(
              itemCount: _listdata.length,
              itemBuilder: (context, index) {
                return Card(
                  child: ExpansionTile(
                    title: Text(
                      _listdata[index]['nama'],
                    ),
                    children: [
                      ListTile(
                        title: Text(_listdata[index]['nim']),
                        subtitle: Text(_listdata[index]['alamat']),
                        trailing: IconButton(
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    content: Text('Yakin Anda Menghapus Data'),
                                    actions: [
                                      ElevatedButton(
                                        onPressed: () {
                                          _hapusdata(_listdata[index]['nim'])
                                              .then((value) => {
                                                    if (value)
                                                      {
                                                        ScaffoldMessenger.of(
                                                                context)
                                                            .showSnackBar(
                                                                const SnackBar(
                                                          content: Text(
                                                              'Data berhasil Di Hapus'),
                                                          backgroundColor:
                                                              Colors.blue,
                                                        )),
                                                      }
                                                    else
                                                      {
                                                        ScaffoldMessenger.of(
                                                                context)
                                                            .showSnackBar(
                                                                const SnackBar(
                                                          content: Text(
                                                              'Data tidak berhasil Di Hapus'),
                                                          backgroundColor:
                                                              Colors.red,
                                                        ))
                                                      }
                                                  });
                                          Navigator.pushAndRemoveUntil(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      const HomePage()),
                                              (route) => false);
                                        },
                                        child: Text('Hapus'),
                                        style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.red),
                                      ),
                                      ElevatedButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                        child: Text('Batal'),
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                            icon: const Icon(Icons.delete)),
                        leading: IconButton(
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EditData(
                                listData: {
                                  "id": _listdata[index]['id'],
                                  "nim": _listdata[index]['nim'],
                                  "nama": _listdata[index]['nama'],
                                  "alamat": _listdata[index]['alamat'],
                                },
                              ),
                            ),
                          ),
                          icon: const Icon(Icons.edit),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => const TambahData()));
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
