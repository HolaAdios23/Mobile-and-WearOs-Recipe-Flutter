import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dummy_json_recipes/screens/detailRecipes.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:wear_plus/wear_plus.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:watch_connectivity/watch_connectivity.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cached_network_image/cached_network_image.dart';
class Homescreen extends StatefulWidget {
  const Homescreen({super.key});

  @override
  State<Homescreen> createState() => _HomescreenState();
}

class _HomescreenState extends State<Homescreen> {
  Map<String, bool> all_tags = {};
  List<dynamic> filter_recipes = [];
  List<dynamic> recipes = [];
  var _searchController = TextEditingController();

  // Function to get Recipes
  Future<void> getRecipes(String query) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? cachedRecipes = prefs.getString('recipes'); // Check for cached recipes

    if (cachedRecipes != null && cachedRecipes.isNotEmpty) {
      // If recipes exist in SharedPreferences, use them
      setState(() {
        recipes = jsonDecode(cachedRecipes);
      });

      print("Empty not");
    }
    else
    {
      try {
        // Fetch recipes from the API if no cached data exists
        final response = await http.get(Uri.parse("https://dummyjson.com/recipes/search?q=$query"));

        if (response.statusCode == 200) {
          var data = jsonDecode(response.body);
          // Store the response in SharedPreferences
          prefs.setString('recipes', jsonEncode(data['recipes']));

          setState(() {
            recipes = data['recipes'];

            for(var i in recipes)
              {
                print(i["name"]);
              }

          });
        } else {
          throw Exception("Failed to load recipes");
        }
      } catch (e) {
        throw Exception("Failed to load recipes: $e");
      }
    }
  }

  // Function to get Tags
  Future<void> getTags() async {
    try {
      final response = await http.get(Uri.parse("https://dummyjson.com/recipes/tags"));

      if (response.statusCode == 200) {
        final List<String> tags = List<String>.from(jsonDecode(response.body));

        for (var tag in tags) {
          all_tags[tag] = false;
        }
      } else {
        throw Exception("Failed to load tags");
      }
    } catch (e) {
      throw Exception("Failed to load tags: $e");
    }
  }

  // Function to filter recipes by tags
  Future<void> filterTags(List<String> selectedTags) async {
    filter_recipes.clear(); // Clear previous filter results

    for (var tag in selectedTags) {
      try {
        final response = await http.get(Uri.parse("https://dummyjson.com/recipes/tag/$tag"));
        if (response.statusCode == 200) {
          var data = jsonDecode(response.body);
          final List<dynamic> tags = data['recipes'];
          for (var t in tags) {
            filter_recipes.add(t);
          }
        } else {
          throw Exception("Failed to load recipes by tag");
        }
      } catch (e) {
        print("Error: $e");
        throw Exception("Failed to filter recipes: $e");
      }
    }

    // Update the recipes list after filtering
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
    getRecipes(""); // Initial fetch of recipes
    getTags(); // Fetch tags for filtering
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Container(
          child: Padding(
            padding: EdgeInsets.all(0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black12,
                borderRadius: BorderRadius.circular(5),
              ),
              child: TextField(
                controller: _searchController,
                textInputAction: TextInputAction.search,
                onSubmitted: (String query) {
                  getRecipes(query); // Fetch recipes based on search query
                },
                decoration: InputDecoration(
                  hintText: "Search",
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 13),
                  prefixIcon: Icon(Icons.search, color: Colors.black54),
                ),
              ),
            ),
          ),
        ),
      ),
      endDrawer: Drawer(
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: all_tags.length,
                itemBuilder: (context, index) {
                  return InkWell(
                    onTap: () {
                      setState(() {
                        all_tags[all_tags.keys.elementAt(index)] = !all_tags.values.elementAt(index);
                      });
                    },
                    child: Padding(
                      padding: EdgeInsets.all(10),
                      child: Row(
                        children: [
                          Icon(
                            (all_tags.values.elementAt(index) == true
                                ? Icons.check_box
                                : Icons.check_box_outline_blank),
                            color: Colors.black45,
                            size: 30,
                          ),
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
                  List<String> selectedTags = [];
                  for (var entry in all_tags.entries) {
                    if (entry.value) {
                      selectedTags.add(entry.key);
                    }
                  }

                  filterTags(selectedTags); // Filter recipes by selected tags
                  sendMessageToMobile();
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
      body: ListView.builder(
        itemCount: recipes.length,
        itemBuilder: (context, index) {
          var recipe = recipes[index];
          return Padding(
            padding: EdgeInsets.all(1),
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Detailrecipes(recipe_id: recipe['id'].toString())),
                );
              },
              child: Card(
                margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: Padding(
                  padding: EdgeInsets.all(10),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),

                          child: CachedNetworkImage(
                            imageUrl: recipe['image'].toString(),
                            placeholder: (context, url) => Center(
                              child: CircularProgressIndicator(), // Placeholder while loading
                            ),
                            errorWidget: (context, url, error) => Center(
                              child: Text('Image not found', style: TextStyle(fontSize: 16, color: Colors.red)),
                            ),
                            width: MediaQuery.of(context).size.width * 0.28,
                            height: MediaQuery.of(context).size.height * 0.14,
                            fit: BoxFit.cover,
                          )

                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          children: [
                            Container(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                recipe['name'],
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                              ),
                            ),
                            SizedBox(height: 8),
                            Container(
                              alignment: Alignment.centerLeft,
                              child: Row(
                                children: [
                                  Icon(Icons.star, color: Colors.orange, size: 20),
                                  Icon(Icons.star, color: Colors.orange, size: 20),
                                  Icon(Icons.star, color: Colors.orange, size: 20),
                                  Icon(Icons.star, color: Colors.orange, size: 20),
                                  Icon(Icons.star, color: Colors.orange, size: 20),
                                  SizedBox(width: 5),
                                  Text(
                                    "(${recipe['rating'].toString()})",
                                    style: const TextStyle(fontSize: 14, color: Colors.black54),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 8),
                            Container(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                "Servings: ${recipe['servings']}",
                                style: const TextStyle(fontSize: 14, color: Colors.black54),
                              ),
                            ),
                            SizedBox(height: 8),
                            Container(
                              alignment: Alignment.centerLeft,
                              child: Row(
                                children: [
                                  Icon(Icons.remove_red_eye, color: Colors.black, size: 20),
                                  SizedBox(width: 5),
                                  Text(
                                    recipe['reviewCount'].toString(),
                                    style: const TextStyle(fontSize: 14, color: Colors.black54),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void sendMessageToMobile() async {
    if (await _watchConnectivity.isReachable) {
      await _watchConnectivity.sendMessage({
        "messageMobile": "Hello from Wear OS!"
      });
      print("Message sent to Mobile");
    } else {
      print("Mobile app is not reachable");
    }
  }
}
