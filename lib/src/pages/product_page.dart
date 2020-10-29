import 'dart:io';

import 'package:flutter/material.dart';
import 'package:formvalidation/src/models/product_model.dart';
import 'package:formvalidation/src/providers/products_provider.dart';
import 'package:formvalidation/src/utils/utils.dart' as utils;
import 'package:image_picker/image_picker.dart';

class ProductoPage extends StatefulWidget {
  @override
  _ProductoPageState createState() => _ProductoPageState();
}

class _ProductoPageState extends State<ProductoPage> {
  final formKey = GlobalKey<FormState>();
  final scaffoldKey = GlobalKey<ScaffoldState>();
  bool _guardando = false;
  ProductoModel producto = new ProductoModel();
  ProductosProvider productosProvider = new ProductosProvider();
  File photo;

  @override
  Widget build(BuildContext context) {
    final ProductoModel prodData = ModalRoute.of(context).settings.arguments;

    if (prodData != null) {
      producto = prodData;
    }

    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        title: Text("Producto page"),
        actions: [
          IconButton(
              icon: Icon(Icons.photo_size_select_actual),
              onPressed: () => _processImage(ImageSource.gallery)),
          IconButton(
              icon: Icon(Icons.camera_alt),
              onPressed: () => _processImage(ImageSource.camera))
        ],
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(15),
          child: Form(
              key: formKey,
              child: Column(
                children: [
                  _mostrarFoto(),
                  _crearNombre(),
                  _crearPrecio(),
                  _crearDisponible(),
                  _crearBoton()
                ],
              )),
        ),
      ),
    );
  }

  _processImage(ImageSource origin) async {
    final _picker = ImagePicker();

    final pickedFile = await _picker.getImage(
      source: origin,
    );

    photo = File(pickedFile.path);

    if (photo != null) {
      producto.fotoUrl = null;
    }

    setState(() {});
  }

  Widget _mostrarFoto() {
    if (producto.fotoUrl != null) {
      return FadeInImage(
        placeholder: AssetImage('assets/jar-loading.gif'),
        image: NetworkImage(producto.fotoUrl),
        height: 300.0,
        width: double.infinity,
        fit: BoxFit.contain,
      );
    }
    return Image(
      image: AssetImage(photo?.path ?? 'assets/no-image.png'),
      height: 300.0,
      fit: BoxFit.cover,
    );
  }

  Widget _crearNombre() {
    return TextFormField(
        textCapitalization: TextCapitalization.sentences,
        decoration: InputDecoration(labelText: 'Producto'),
        initialValue: producto.titulo,
        onSaved: (value) => producto.titulo = value,
        validator: (value) =>
            value.length < 3 ? 'ingrese el nombre del producto' : null);
  }

  Widget _crearPrecio() {
    return TextFormField(
      keyboardType: TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(labelText: 'Precio'),
      initialValue: producto.precio.toString(),
      onSaved: (value) => producto.precio = double.parse(value),
      validator: (value) {
        if (utils.isNumeric(value)) {
          return null;
        }
        return 'Solo numeros';
      },
    );
  }

  Widget _crearBoton() {
    return RaisedButton.icon(
      icon: Icon(Icons.save),
      label: Text('Guardar'),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
      color: Colors.deepPurple,
      textColor: Colors.white,
      onPressed: (_guardando) ? null : _submit,
    );
  }

  Widget _crearDisponible() {
    return SwitchListTile(
      value: producto.disponible,
      activeColor: Colors.deepPurple,
      onChanged: (value) {
        setState(() {
          producto.disponible = value;
        });
      },
      title: Text('disponible'),
    );
  }

  void _submit() async {
    print('onSbumit');
    bool val = formKey.currentState.validate();
    print(val);
    if (!val) {
      return;
    }
    formKey.currentState.save();

    setState(() {
      _guardando = true;
    });

    if (photo != null) {
      producto.fotoUrl = await productosProvider.subirImagen(photo);
      print('foto url in object');
      print('foto url in object');
      print('foto url in object');
      print('foto url in object');
      print(producto.fotoUrl);
    }

    producto.id != null
        ? productosProvider.editarProducto(producto)
        : productosProvider.crearProducto(producto);

    _mostrarSnackBar('registro guardado');
    Navigator.pop(context);
  }

  void _mostrarSnackBar(String mensaje) {
    final snackbar = SnackBar(
      content: Text(mensaje),
      duration: Duration(milliseconds: 1500),
    );

    scaffoldKey.currentState.showSnackBar(snackbar);
  }
}
