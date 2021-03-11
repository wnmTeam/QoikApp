import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:stumeapp/const_values.dart';
import 'package:stumeapp/localization.dart';

class MyDropdownButton extends StatefulWidget {
  Function(String) onSelected;
  List items;
  String label;

  MyDropdownButton({this.items, this.onSelected, this.label});

  @override
  _MyDropdownButtonState createState() => _MyDropdownButtonState();
}

class _MyDropdownButtonState extends State<MyDropdownButton> {
  String _currentSelected;

  List<DropdownMenuItem<String>> _dropDownMenuItems;

  @override
  void initState() {
    _dropDownMenuItems = getTypesDropDownMenuItems();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField(
      decoration: InputDecoration(
        labelText: widget.label,
//        contentPadding: EdgeInsets.symmetric(vertical: 5, horizontal: 12),
        border: OutlineInputBorder(),
      ),
      value: _currentSelected,
      items: _dropDownMenuItems,
      onChanged: (String selected) {
        widget.onSelected(selected);
        setState(() {
          _currentSelected = selected;
        });
      },
      validator: (String value) {
        if (value.isEmpty) {
          return Languages.translate(
            context,
            'field_requered',
          );
        }
        return null;
      },
    );
  }

  List<DropdownMenuItem<String>> getTypesDropDownMenuItems() {
    List<DropdownMenuItem<String>> items = List();
    for (String item in widget.items) {
      items.add(DropdownMenuItem(value: item, child: Text(item)));
    }
    return items;
  }
}

class ResetDialog extends StatelessWidget {
  final TextEditingController resetEmailController;
  final Function onPressed;

  ResetDialog({this.resetEmailController, this.onPressed});

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: resetEmailController,
                decoration: InputDecoration(
                  labelText: Languages.translate(
                    context,
                    'reset_email',
                  ),
                  border: OutlineInputBorder(),
                ),
                validator: (String value) {
                  if (value.isEmpty) {
                    return Languages.translate(
                      context,
                      'email_is_Requered',
                    );
                  }
                  return null;
                },
              ),
              SizedBox(
                height: 20,
              ),
              RaisedButton(
                onPressed: () {
                  if (_formKey.currentState.validate()) {
                    onPressed();
                    Navigator.of(context).pop();
                  }
                },
                color: Theme.of(context).primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0),
                ),
                child: Text(
                  Languages.translate(
                    context,
                    'done',
                  ),
                  style: TextStyle(
                    fontSize: MediaQuery.of(context).size.width /
                        ConstValues.fontSize_2,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class BottomSheetWidget extends StatefulWidget {
  BottomSheetWidget(
    this.type,
    this.future,
  );

  String type;
  Function future;

  @override
  _BottomSheetWidgetState createState() => _BottomSheetWidgetState();
}

class _BottomSheetWidgetState extends State<BottomSheetWidget> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: widget.future(),
      builder: (context, snapshot) {
        if (snapshot.hasData)
          return ListView.builder(
            itemCount: snapshot.data[widget.type],
            itemBuilder: (context, index) {
              String item = snapshot.data[widget.type][index];
              return ListTile(
                title: Text(item),
                onTap: () {
                  Navigator.pop(context, item);
                },
              );
            },
          );
        return Center(child: CircularProgressIndicator());
      },
    );
  }
}
