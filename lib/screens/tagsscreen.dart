import 'dart:ffi';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:watch_connectivity/watch_connectivity.dart';

class Tagsscreen extends StatefulWidget {
  const Tagsscreen({super.key});

  @override
  State<Tagsscreen> createState() => _TagsscreenState();
}

class _TagsscreenState extends State<Tagsscreen> {
  List<dynamic> recipes = [];
  Map<String, bool> all_tags = {};
  List<dynamic> filter_recipes = [];
  bool isLoading = false;
  Future<void> getTags() async {
    try {
      final response = await http.get(Uri.parse("https://dummyjson.com/recipes/tags"));

      if (response.statusCode == 200) {
        final List<String> tags = List<String>.from(jsonDecode(response.body));
        for (var tag in tags) {
          all_tags[tag] = false;
        }


        setState(() {
          isLoading = true;
        });

      } else {
        throw Exception("Failed to load tags");
      }
    } catch (e) {
      throw Exception("Failed to load tags: $e");
    }
  }

  Future<void> filterTags(List<String> all_tag) async
  {
    for(var tag in all_tag)
    {

      try
      {
        final response = await http.get(Uri.parse("https://dummyjson.com/recipes/tag/$tag"));
        if (response.statusCode == 200)
        {
          var data = jsonDecode(response.body);
          final List<dynamic> tags = data['recipes'];
          print(tags);
          for(var t in tags)
          {
            print(t);

            filter_recipes.add(t);
          }

        }
        else
        {
          throw Exception("Failed to load recipes");
        }
      }
      catch (e)
      {
        print("Error: $e");
        throw Exception("Failed to load tags: $e");
      }

    }
    setState(() {

      recipes = {
        for (var recipe in filter_recipes) recipe['id']: recipe
      }.values.toList();

      filter_recipes.clear();
    });
  }
  String _receivedMessage = "No message received yet";
  late WatchConnectivity _watchConnectivity;
  @override
  void initState() {

    super.initState();

    _watchConnectivity = WatchConnectivity();
    getTags();
    // Listen for incoming messages
    _watchConnectivity.messageStream.listen((message) {
      setState(() {
        _receivedMessage = message["messageMobile"] ?? "No message content"; // Adjust based on message format
        print("Message received from mobile: $message");
      });
    });

  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: Padding(
        padding: EdgeInsets.only(top: 20),
        child: Center(
          child: !isLoading ? CircularProgressIndicator() : Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: all_tags.length,
                  itemBuilder: (context, index) {
                    return InkWell(
                      onTap: (){



                        setState(() {
                          all_tags[all_tags.keys.elementAt(index)] =!all_tags.values.elementAt(index);

                        });


                      },
                      child: Padding(
                        padding:EdgeInsets.all(10),
                        child: Row(
                          children: [
                            Icon(
                                (all_tags.values.elementAt(index) == true ? Icons.check_box : Icons.check_box_outline_blank),
                                color: Colors.black45,
                                size:25),
                            SizedBox(width: 5),
                            Text(
                              all_tags.keys.elementAt(index),
                              style: TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),


              Padding(
                padding: EdgeInsets.all(10),
                child: ElevatedButton.icon(
                  onPressed: () async {

                    // List<String> keyss = [];
                    //
                    // for(var i in all_tags.entries)
                    // {
                    //
                    //   if(i.value)
                    //   {
                    //     keyss.add(i.key);
                    //   }
                    //
                    // }
                    //
                    sendMessageToMobile();

                  },

                  label: Text("Done"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),

    );
  }

  void sendMessageToMobile() async {
    if (await _watchConnectivity.isReachable) {
      // Send a message to the mobile app
      await _watchConnectivity.sendMessage({
        "message": "Hello from Wear OS!"
      });
      print("Message sent to Mobile");
    } else {
      print("Mobile app is not reachable");
    }
  }
}
