import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
class Tagsscreen extends StatefulWidget {
  const Tagsscreen({super.key});

  @override
  State<Tagsscreen> createState() => _TagsscreenState();
}

class _TagsscreenState extends State<Tagsscreen> {

  Map<String, bool> all_tags = {};
  List<dynamic> filter_recipes = [];

  Future<void> getTags() async {
    try {
      final response = await http.get(Uri.parse("https://dummyjson.com/recipes/tags"));

      if (response.statusCode == 200) {

        final List<String> tags =List<String>.from(jsonDecode(response.body));

        for(var tag in tags)
        {

          print(tag);
          all_tags[tag] = false;

        }

      }
      else
      {
        throw Exception("Failed to load tags");
      }
    }
    catch (e)
    {
      throw Exception("Failed to load tags: $e");
    }
  }

  Future<void> filterTags(String tag) async {

    print(tag +  " <--- This is tag first");
    try
    {
      final response = await http.get(Uri.parse("https://dummyjson.com/recipes/tag/$tag"));
      if (response.statusCode == 200)
      {
        var data = jsonDecode(response.body);
        final List<dynamic> tags = data['recipes'];


        for(var t in tags)
        {


          filter_recipes.add(t);

        }
        setState(() {

          for(var t in filter_recipes.toSet().toList())
          {
            print(t["name"]);
          }
          // recipes = filter_recipes.toSet().toList();
          filter_recipes.clear();
        });

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
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    getTags();
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: Center(
        child: Column(
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
                              size: 30),
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
                onPressed: () {
                  for(var tag in all_tags.entries)
                  {
                    if(tag.value)
                    {
                      filterTags(tag.key);
                    }
                  }


                  Navigator.pop(context);

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

    );
  }
}
