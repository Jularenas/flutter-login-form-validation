import 'dart:convert';
import 'dart:io';
import 'package:formvalidation/src/models/product_model.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime_type/mime_type.dart';

class ProductosProvider {
  final String _url = 'https://flutter-varios-88a7d.firebaseio.com';

  //Create-POST
  Future<bool> crearProducto(ProductoModel product) async {
    final url = '$_url/productos.json';

    final resp = await http.post(url, body: productoModelToJson(product));

    final decodedData = json.decode(resp.body);

    print(decodedData);

    return true;
  }

  //Retrieve-GET
  Future<List<ProductoModel>> cargarProductos() async {
    List<ProductoModel> res = new List();

    final url = '$_url/productos.json';

    final resp = await http.get(url);

    Map<String, dynamic> decodedData = json.decode(resp.body);

    if (decodedData == null) {
      return [];
    }

    decodedData.forEach((key, value) {
      ProductoModel prod = ProductoModel.fromJson(value);
      prod.id = key;
      res.add(prod);
    });

    return res;
  }

  //Update-PUT
  Future<bool> editarProducto(ProductoModel product) async {
    final url = '$_url/productos/${product.id}.json';

    final resp = await http.put(url, body: productoModelToJson(product));

    final decodedData = json.decode(resp.body);

    print(decodedData);

    return true;
  }

  //Delete-DELETE
  Future<bool> deleteProducto(String id) async {
    final url = '$_url/productos/$id.json';

    final resp = await http.delete(url);

    final decodedData = json.decode(resp.body);

    print(decodedData);

    return true;
  }

  Future<String> subirImagen(File imagen) async {
    final url = Uri.parse(
        'https://api.cloudinary.com/v1_1/it-auxilium/image/upload?upload_preset=cqxyei1k');

    final mimeType = mime(imagen.path).split('/');
    final imageUploadRequest = http.MultipartRequest('POST', url);

    final file = await http.MultipartFile.fromPath('file', imagen.path,
        contentType: MediaType(mimeType[0], mimeType[1]));

    imageUploadRequest.files.add(file);

    final streamResp = await imageUploadRequest.send();
    final resp = await http.Response.fromStream(streamResp);

    if (resp.statusCode != 200 && resp.statusCode != 201) {
      print('AAAAAAAAa');
      print(resp.statusCode);
      print(resp.body);
      return null;
    }

    final respData = json.decode(resp.body);
    print(resp.body);
    print('secure url');
    print('secure url');
    print('secure url');
    print('secure url');
    print(respData["secure_url"]);
    print('secure url');
    print('secure url');
    return respData['secure_url'];
  }
}
