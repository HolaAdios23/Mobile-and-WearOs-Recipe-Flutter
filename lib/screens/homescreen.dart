import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dummy_json_recipes/screens/detailRecipes.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class Homescreen extends StatefulWidget {
  const Homescreen({super.key});

  @override
  State<Homescreen> createState() => _HomescreenState();
}

class _HomescreenState extends State<Homescreen> {

  List<dynamic> recipes = [];
  var _searchController = TextEditingController();

  Future<void> getRecipes(String query) async {
    try {
      // Make an API call with a dynamic search query
      final response = await http.get(Uri.parse("https://dummyjson.com/recipes/search?q=$query"));

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);

        setState(() {
          recipes = data['recipes'];
        });

      } else {
        throw Exception("Failed to load recipes");
      }
    } catch (e) {
      throw Exception("Failed to load recipes: $e");
    }
  }


  Future<List<String>> getTags() async {
    try {
      final response =
      await http.get(Uri.parse("https://dummyjson.com/recipes/tags"));

      if (response.statusCode == 200) {
        return List<String>.from(jsonDecode(response.body)); // ✅ Correct parsing
      } else {
        throw Exception("Failed to load tags");
      }
    } catch (e) {
      throw Exception("Failed to load tags: $e");
    }
  }


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getRecipes("");
  }




  @override
  Widget build(BuildContext context) {
    return Container(child: Scaffold(

      appBar: AppBar(


        title: Container(
           child: Padding(
              padding: EdgeInsets.all(0),
               child: Container(


                 decoration: BoxDecoration(
                     color: Colors.black12,
                     borderRadius: BorderRadius.circular(5)

                 ),


                 child: TextField(
                   controller: _searchController,
                   textInputAction: TextInputAction.search,
                   onSubmitted: (String query) {


                     getRecipes(query);

                   },
                   decoration: InputDecoration(
                       hintText: "Search",
                       border: InputBorder.none,
                       contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 13),
                       prefixIcon: Icon(Icons.search, color: Colors.black54)


                   ),
                 ),


          ),
          ),

        ),





      ),


      endDrawer: Drawer(

        child: FutureBuilder<List<dynamic>>(
          future: getTags(),
          builder: (context, snapshot){
            List tags = snapshot.data!;
            return Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: tags.length,
                    itemBuilder: (context, index) {
                      return InkWell(
                        onTap: (){

                        },
                        child: Padding(
                          padding:EdgeInsets.all(10),
                          child: Row(
                            children: [
                            Icon(Icons.check_box_outline_blank, color: Colors.black45, size: 30),
                            SizedBox(width: 5),
                              Text(
                                tags[index],
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
            );


          },

        ),


      ),

      body:  ListView.builder(
          itemCount: recipes.length,
          itemBuilder :(context, index){
            var recipe = recipes[index];
            return Padding(
              padding: EdgeInsets.all(1),
              child: InkWell(
                onTap: (){

                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => Detailrecipes(recipe_id: recipe['id'].toString())));
                },
                child: Card(


                  margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  child: Padding(
                      padding: EdgeInsets.all(10),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.network(
                              recipe['image'].toString(),
                              width: MediaQuery.of(context).size.width * 0.28,
                              height: MediaQuery.of(context).size.height * 0.14,
                              fit: BoxFit.cover,
                            ),
                          ),


                          SizedBox(
                            width: 10,
                          ),

                          Expanded(
                            child: Container(


                              child: Column(
                                children: [
                                  Container(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      recipe['name'],

                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 17,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 8,
                                  ),
                                  Container(


                                    alignment: Alignment.centerLeft,
                                    child: Row(
                                      children: [
                                        Icon(Icons.star, color: Colors.orange, size: 20,),
                                        Icon(Icons.star, color: Colors.orange, size: 20,),
                                        Icon(Icons.star, color: Colors.orange, size: 20,),
                                        Icon(Icons.star, color: Colors.orange, size: 20,),
                                        Icon(Icons.star, color: Colors.orange, size: 20,),
                                        SizedBox(
                                          width: 5,
                                        ),
                                        Text(
                                          "(${recipe['rating'].toString()})",
                                          style: const TextStyle(
                                            fontSize: 14,
                                            color: Colors.black54,
                                          ),
                                        ),

                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                    height: 8,
                                  ),

                                  Container(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      "Servings: ${recipe['servings']}",
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.black54,
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 8,
                                  ),

                                  Container(
                                      alignment: Alignment.centerLeft,
                                      child: Row(
                                        children: [


                                          Icon(Icons.remove_red_eye, color: Colors.black, size: 20,),
                                          SizedBox(
                                            width: 5,
                                          ),
                                          Text(
                                            recipe['reviewCount'].toString(),
                                            style: const TextStyle(
                                              fontSize: 14,
                                              color: Colors.black54,
                                            ),
                                          ),

                                        ],
                                      )
                                  ),


                                ],
                              ),
                            ),
                          )
                        ],
                      )
                  ),
                ),
              ),

            );
          }





      )


    ));
  }
}
