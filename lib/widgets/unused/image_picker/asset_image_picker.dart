import 'dart:convert';

import 'package:climbing_alien/utils/utils.dart';
import 'package:flutter/material.dart';

class AssetImagePicker extends StatelessWidget {
  Future<List<String>> _loadImages(BuildContext context) async {
    /// `AssetManifest.json` contains all info about the assets
    final manifestContent = await DefaultAssetBundle.of(context).loadString('AssetManifest.json');
    final Map<String, dynamic> manifestMap = json.decode(manifestContent);

    return manifestMap.keys.where((String key) => key.contains('images/climbing_walls/')).toList();
  }

  void pickImage(BuildContext context, String path) {
    Navigator.pop(context, path);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Available asset images'),
      ),
      body: FutureBuilder<List<String>>(
        future: _loadImages(context),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            List<String> pathList = snapshot.data!;
            return pathList.isEmpty
                ? Center(child: Text('No images available'))
                : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text('Choose an image by tapping on it!', style: TextStyle(fontStyle: FontStyle.italic, fontSize: 20)),
                    ),
                    Expanded(
                      child: ListView.separated(
                          itemCount: pathList.length,
                          separatorBuilder: (context, index) => Divider(thickness: 1, color: Theme.of(context).colorScheme.primary,),
                          itemBuilder: (context, index) => ListTile(
                                title: Padding(
                                  padding: const EdgeInsets.only(bottom: 8.0),
                                  child: Text(Utils.getFilenameFromPath(pathList[index]), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                                ),
                                subtitle: Image.asset(pathList[index], fit: BoxFit.fill),
                                onTap: () => pickImage(context, pathList[index]),
                              )),
                    ),
                  ],
                );
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
