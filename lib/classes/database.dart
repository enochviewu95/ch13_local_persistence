import 'package:path_provider/path_provider.dart'; //Filesystem locations
import 'dart:io'; //used by file
import 'dart:convert'; //used by json

class DatabaseFileRoutines{

  Future<String> get _localPath async{
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> get _localFile async{
    final path = await _localPath;
    return File('$path/local_persistence.json');
  }

  Future<String> readJournals() async{
    try{
      final file = await _localFile;
      if(!file.existsSync()){
        print("File does not Exist: ${file.absolute}");
        await writeJournals('{"journals": [] }');
      }
      //Read the file
      String contents = await file.readAsString();
      return contents;
    }catch (e){
      print("error readJournals: $e");
      return "";
    }
  }

  Future<File> writeJournals(String json) async{
    final file = await _localFile;

    //write the file
    return file.writeAsString(json);
  }
}

//To read and parse from JSON data - databaseFromJson(jsonString);
Database databaseFromJson(String str){
  final databaseFromJson = json.decode(str);
  return Database.fromJson(databaseFromJson);
}

//To save and parse to JSON data - databaseToJson(jsonString);
String databaseToJson(Database data){
  final dataToJson = data.toJson();
  return json.encode(dataToJson);
}

class Database{
  List<Journal> journal;

  Database({
    required this.journal,
  });

  factory Database.fromJson(Map<String,dynamic> json) => Database(
    journal: List<Journal>.from(json["journals"].map((x)=>Journal.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "journals":List<dynamic>.from(journal.map((e) => e.toJson())),
  };
}

class Journal{
  final id;
  final date;
  final mood;
  final note;

  Journal({
    this.id,
    this.date,
    this.mood,
    this.note,
  });

  //Convert Json object to Journal class
  factory Journal.fromJson(Map<String,dynamic> json) => Journal(
    id: json["id"],
    date:json["date"],
    mood:json["mood"],
    note: json["note"],
  );

  //Convert Journal class to Json object
  Map<String,dynamic> toJson() =>{
    "id":id,
    "date":date,
    "mood":mood,
    "note":note,
  };
}

class JournalEdit{
  String action;
  Journal journal;
  JournalEdit({required this.action,required this.journal});
}