import 'package:flutter/material.dart';
import '../providers/product.dart';
import 'package:provider/provider.dart';
import '../providers/products.dart';

class EditProductScreen extends StatefulWidget {
  static const routeName = '/edit-product';

  @override
  _EditProductScreenState createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _imageControler = TextEditingController();
  final _imageFocusNode = FocusNode();
  final _form = GlobalKey<FormState>();
  var _isAdd;
  var _isLoading = false;
  var _isInit = true;
  var _editProduct = Product(
      id: DateTime.now().toString(),
      description: '',
      imageUrl: '',
      price: 0,
      title: '');

  @override
  void initState() {
    _imageFocusNode.addListener(_updateImage);
    super.initState();
  }

  @override
  void didChangeDependencies() {
    if (_isInit) {
      final productId = ModalRoute.of(context)!.settings.arguments as String?;
      if (productId != null) {
        _editProduct =
            Provider.of<Products>(context, listen: false).findById(productId);
        _imageControler.text = _editProduct.imageUrl;
        _isAdd = false;
      } else {
        _isAdd = true;
      }
    }
    _isInit = false;
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _imageFocusNode.removeListener(_updateImage);
    _imageControler.dispose();
    _imageFocusNode.dispose();
    super.dispose();
  }

  void _updateImage() {
    if (!_imageFocusNode.hasFocus) {
      if ((!_imageControler.text.startsWith('http') &&
              !_imageControler.text.startsWith('https')) ||
          (!_imageControler.text.endsWith('.png') &&
              !_imageControler.text.endsWith('jpg') &&
              !_imageControler.text.endsWith('jpeg'))) {
        return;
      }
      setState(() {});
    }
  }

  Future<void> _saveForm() async {
    final isValid = _form.currentState!.validate();
    if (!isValid) {
      return;
    }
    _form.currentState!.save();
    setState(() {
      _isLoading = true;
    });
    final productData = Provider.of<Products>(context, listen: false);
    if (_isAdd) {
      try {
        await productData.addProduct(_editProduct);
      } catch (error) {
        await showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
                  title: Text('Error'),
                  content: Text('Somthing went wrong.'),
                  actions: [
                    TextButton(
                        onPressed: () {
                          Navigator.of(ctx).pop();
                        },
                        child: Text('Okay'))
                  ],
                ));
      }
    } else {
      try {
        await productData.updateProduct(_editProduct);
      } catch (error) {
        await showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
                  title: Text('Error'),
                  content: Text('Somthing went wrong.'),
                  actions: [
                    TextButton(
                        onPressed: () {
                          Navigator.of(ctx).pop();
                        },
                        child: Text('Okay'))
                  ],
                ));
      }
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Product'),
        actions: [IconButton(onPressed: _saveForm, icon: Icon(Icons.save))],
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Padding(
              padding: EdgeInsets.all(16),
              child: Form(
                key: _form,
                child: ListView(
                  children: [
                    TextFormField(
                      initialValue: _editProduct.title,
                      decoration: InputDecoration(labelText: 'Title'),
                      textInputAction: TextInputAction.next,
                      validator: (val) {
                        if (val!.isEmpty) {
                          return 'Please enter a value';
                        }
                        return null;
                      },
                      onSaved: (val) {
                        _editProduct = Product(
                            title: val!,
                            id: _editProduct.id,
                            description: _editProduct.description,
                            imageUrl: _editProduct.imageUrl,
                            price: _editProduct.price,
                            isFavorite: _editProduct.isFavorite);
                      },
                    ),
                    TextFormField(
                      initialValue: _editProduct.price.toString(),
                      decoration: InputDecoration(labelText: 'Price'),
                      textInputAction: TextInputAction.next,
                      keyboardType: TextInputType.number,
                      validator: (val) {
                        if (val!.isEmpty) {
                          return 'Please enter a value';
                        }
                        if (double.tryParse(val) == null) {
                          return 'Please enter a valid number';
                        }
                        if (double.parse(val) <= 0) {
                          return 'Please enter a number greater than zero';
                        }
                        return null;
                      },
                      onSaved: (val) {
                        _editProduct = Product(
                            title: _editProduct.title,
                            id: _editProduct.id,
                            description: _editProduct.description,
                            imageUrl: _editProduct.imageUrl,
                            price: double.parse(val!),
                            isFavorite: _editProduct.isFavorite);
                      },
                    ),
                    TextFormField(
                      initialValue: _editProduct.description,
                      decoration: InputDecoration(labelText: 'Description'),
                      keyboardType: TextInputType.multiline,
                      maxLines: 3,
                      validator: (val) {
                        if (val!.isEmpty) {
                          return 'Please enter a value';
                        }
                        if (val.length < 10) {
                          return ' Sould be at least 10 characters';
                        }
                        return null;
                      },
                      onSaved: (val) {
                        _editProduct = Product(
                            title: _editProduct.title,
                            id: _editProduct.id,
                            description: val!,
                            imageUrl: _editProduct.imageUrl,
                            price: _editProduct.price,
                            isFavorite: _editProduct.isFavorite);
                      },
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          margin: EdgeInsets.only(top: 8, right: 10),
                          decoration: BoxDecoration(
                              border: Border.all(width: 1, color: Colors.grey)),
                          child: _imageControler.text.isEmpty
                              ? Text('Enter a URL')
                              : FittedBox(
                                  child: Image.network(
                                    _imageControler.text,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                        ),
                        Expanded(
                          child: TextFormField(
                            decoration: InputDecoration(labelText: 'Image URL'),
                            keyboardType: TextInputType.url,
                            textInputAction: TextInputAction.done,
                            controller: _imageControler,
                            focusNode: _imageFocusNode,
                            onFieldSubmitted: (_) {
                              _saveForm();
                            },
                            validator: (val) {
                              if (val!.isEmpty) {
                                return 'Please enter a value';
                              }
                              if (!val.startsWith('http') &&
                                  !val.startsWith('https')) {
                                return 'Please enter a valid URL';
                              }
                              if (!val.endsWith('.png') &&
                                  !val.endsWith('jpg') &&
                                  !val.endsWith('jpeg')) {
                                return 'Please enter a valid image URL';
                              }
                              return null;
                            },
                            onSaved: (val) {
                              _editProduct = Product(
                                  title: _editProduct.title,
                                  id: _editProduct.id,
                                  description: _editProduct.description,
                                  imageUrl: val!,
                                  price: _editProduct.price,
                                  isFavorite: _editProduct.isFavorite);
                            },
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
    );
  }
}
