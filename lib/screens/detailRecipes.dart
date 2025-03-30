import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;


class Detailrecipes extends StatefulWidget
{
  final String recipe_id;

  const Detailrecipes({super.key, required this.recipe_id});

  @override
  State<Detailrecipes> createState() => _DetailrecipesState();
}

class _DetailrecipesState extends State<Detailrecipes> {

  Future<Map<String, dynamic>> fetchData() async {
    final response = await http.get(Uri.parse('https://dummyjson.com/recipes/1' + widget.recipe_id));
    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      return data;
    } else {
      throw Exception("Failed to View recipe");
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      body: FutureBuilder<Map<String, dynamic>>(
        future: fetchData(),
        builder: (context, snapshot) {

          final recipe = snapshot.data!;

          // Accessing the ingredients list
          List<dynamic> ingredients = recipe["ingredients"];
          List<dynamic> instruction = recipe["instructions"];

          return Scaffold(
            appBar: AppBar(
              title: Text(recipe['name']),
            ),
            body: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(
                        recipe['image'].toString(),
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height * 0.3,
                        fit: BoxFit.cover,
                      ),
                    ),
              
                    SizedBox(
                      height: 10,
                    ),
                
                    Text(recipe['name'],
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold
              
                    ),),
                    SizedBox(
                      height:5,
                    ),
              
                    Text(
                    "Ingredient",
                      style: TextStyle(
                          fontSize: 20,
              
              
                      ),),
                    SizedBox(
                      height:5,
                    ),
              
                    for (var ingredient in ingredients)
              
                      Text(
                        ingredient,
                        style: TextStyle(
                          fontSize: 15,
              
              
                        ),),
              
                    SizedBox(
                      height:5,
                    ),
              
                    Text(
                      "Instruction",
                      style: TextStyle(
                        fontSize: 20,
              
              
                      ),),
                    SizedBox(
                      height:5,
                    ),
              
                    for (var instruction in instruction)
              
                      Text(
                        instruction,
                        style: TextStyle(
                          fontSize: 15,
              
              
                        ),)
              
                
                
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
