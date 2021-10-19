import 'package:flutter/material.dart';
import 'package:ch13_local_persistence/classes/database.dart';
import 'package:intl/intl.dart'; //Format dates
import 'dart:math'; //Random() numbers

class EditEntry extends StatefulWidget {
  final bool add;
  final int index;
  final JournalEdit journalEdit;

  const EditEntry({Key? key,required this.add,required this.index,required this.journalEdit})
      : super(key: key);

  @override
  _EditEntryState createState() => _EditEntryState();
}

class _EditEntryState extends State<EditEntry> {

  late JournalEdit _journalEdit;
  late String _title;
  late DateTime _selectedDate;

  final TextEditingController _moodController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  final FocusNode _moodFocus = FocusNode();
  final FocusNode _noteFocus = FocusNode();


  //Date Picker
  Future<DateTime> _selectDate(DateTime selectedDate) async{
    DateTime _initialDate = selectedDate;
    final DateTime? _pickedDate = await showDatePicker(
      context: context,
      initialDate: _initialDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if(_pickedDate != null){
      selectedDate = DateTime(
        _pickedDate.year,
        _pickedDate.month,
        _pickedDate.day,
        _pickedDate.hour,
        _pickedDate.minute,
        _pickedDate.second,
        _pickedDate.millisecond,
        _pickedDate.microsecond,);
    }
    return selectedDate;
  }

  @override
  void initState() {
    super.initState();

    _journalEdit = JournalEdit(action: 'Cancel',journal: widget.journalEdit.journal);
    _title = widget.add ? 'Add':'Edit';
    _journalEdit.journal = widget.journalEdit.journal;
    if(widget.add){
      _selectedDate = DateTime.now();
      _moodController.text = '';
      _noteController.text = '';
    }else{
      _selectedDate = DateTime.parse(_journalEdit.journal.date);
      _moodController.text = _journalEdit.journal.mood;
      _noteController.text = _journalEdit.journal.note;
    }
  }

  @override
  void dispose() {
    _moodController.dispose();
    _noteController.dispose();
    _moodFocus.dispose();
    _noteFocus.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:Text('$_title Entry'),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              FlatButton(
                padding: const EdgeInsets.all(0.0),
                onPressed: () async {
                  FocusScope.of(context).requestFocus(FocusNode());
                  DateTime _pickerDate = await _selectDate(_selectedDate);
                  setState(() {
                    _selectedDate = _pickerDate;
                  });
                },
                child: Row(
                  children: [
                    const Icon(
                      Icons.calendar_today,
                      size: 22.0,
                      color: Colors.black54,
                    ),
                    const SizedBox(width: 16.0,),
                    Text(DateFormat.yMMMEd().format(_selectedDate),
                    style: const TextStyle(
                      color: Colors.black54,
                      fontWeight: FontWeight.bold),
                    ),
                    const Icon(
                      Icons.arrow_drop_down,
                      color:Colors.black54,
                    ),
                  ],
                ),
              ),
              TextField(
                controller: _moodController,
                autofocus: true,
                textInputAction: TextInputAction.next,
                focusNode: _moodFocus,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Mood',
                  icon: Icon(Icons.mood),
                ),
                onSubmitted: (submitted){
                  FocusScope.of(context).requestFocus(_noteFocus);
                },
              ),
              TextField(
                controller: _noteController,
                textInputAction: TextInputAction.newline,
                focusNode:_noteFocus,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  labelText: 'Note',
                  icon: Icon(Icons.subject),
                ),
                maxLines: null,
              ),
              Row(
                mainAxisAlignment:MainAxisAlignment.end,
                children:[
                  FlatButton(
                    child:const Text('Cancel') ,
                    color: Colors.grey.shade100, onPressed: () {
                      _journalEdit.action = 'Cancel';
                      Navigator.pop(context,_journalEdit);
                    },
                  ),
                  const SizedBox(width: 8.0,),
                  FlatButton(
                    child: const Text('Save'),
                    color: Colors.lightGreen.shade100,
                    onPressed: () {
                      _journalEdit.action = 'Save';
                      String _id = widget.add?Random().nextInt(9999999).toString():_journalEdit.journal.id;
                      _journalEdit.journal = Journal(id: _id, date: _selectedDate.toString(),
                          mood: _moodController.text, note: _noteController.text);
                      Navigator.pop(context,_journalEdit);
                    },
                  ),
                ]
              )
            ],
          ),
        ),
      ),
    );
  }
}
