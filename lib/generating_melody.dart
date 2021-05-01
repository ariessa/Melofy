import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'miscellaneous.dart';
import 'package:azblob/azblob.dart';
import 'package:mime/mime.dart';
import 'package:path/path.dart' as path;

class GeneratingMelody extends StatefulWidget {
  @override
  _GeneratingMelodyState createState() => _GeneratingMelodyState();
}

class _GeneratingMelodyState extends State<GeneratingMelody> {


@override
void initState() {
  super.initState();
  uploadImageToAzure(context);
}

Future uploadImageToAzure(BuildContext context) async {

    File file = new File("/assets/bach-test.mid");
    String basename = path.basename(file.path);

    try{
      String fileName = basename;
      // read file as Uint8List 
      Uint8List content =  await file.readAsBytes();
      var storage = AzureStorage.parse(
        'BlobEndpoint=https://cs110033fffa40752de.blob.core.windows.net/;QueueEndpoint=https://cs110033fffa40752de.queue.core.windows.net/;FileEndpoint=https://cs110033fffa40752de.file.core.windows.net/;TableEndpoint=https://cs110033fffa40752de.table.core.windows.net/;SharedAccessSignature=sv=2020-02-10&ss=bfqt&srt=c&sp=rwdlacupx&se=2022-05-04T21:40:37Z&st=2021-05-01T13:40:37Z&spr=https&sig=pEOuL6Vo2W54RhlL%2FbRsVhEAoSRv8xhxj8hq%2BXqqmdc%3D');
      String container="melofy-api-input";
      // get the mine type of the file
      String contentType= lookupMimeType(fileName);
      await storage.putBlob('/$container/$fileName',bodyBytes: content,contentType: contentType,type: BlobType.BlockBlob);
      print("done");
    } on AzureStorageException catch(ex){
      print(ex.message);
    }catch(err){
      print(err);
    }
}

@override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    
    return WillPopScope(
        onWillPop: () => Future.value(false),
        child: Scaffold(
            body: SingleChildScrollView(
              child: Container(
                  height: SizeConfig.screenHeight,
                  child: Column(
                      children: <Widget>[


                      ]
                  )
              )
            ),
            
        )
    );
  }
}