import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:ptmate_client/_data/client.dart';
import 'package:ptmate_client/_data/graphql.dart';
import 'package:ptmate_client/_data/models.dart';
import 'package:ptmate_client/_data/variables.dart';
import 'package:ptmate_client/components/data-column.dart';
import 'package:ptmate_client/components/subtitle.dart';
import 'package:ptmate_client/components/titleback.dart';
import 'package:ptmate_client/components/button-primary.dart';
import 'package:ptmate_client/components/button-tertiary.dart';
import 'package:ptmate_client/main.dart';
import 'package:ptmate_client/health/index.dart';
import 'package:ptmate_client/components/empty.dart';
import 'package:ptmate_client/_helper/image_resolver.dart';


class MealPage extends StatefulWidget {
  final String id;
  final ModelNutritionMeal item;
  final ModelNutritionRecipe recipe;
  const MealPage(this.id, this.item, this.recipe);

  static _MealPageState appState = _MealPageState();
  @override
  _MealPageState createState(){
    return MealPage.appState = new _MealPageState();
  }
}


class _MealPageState extends State<MealPage> {


  final _scaffoldKey = GlobalKey<ScaffoldState>();
  String img = "";
  String id = "";
  ModelNutritionMeal item = ModelNutritionMeal("", "", "", 0, 0, false, false, "", 1, 1);
  ModelNutritionRecipe recipe = ModelNutritionRecipe("", "", "", 0, 0, 0, 0, 0, "", []);
  var image = "";
  int like = -1;
  List<ModelNutritionMeal> nexts = [];
  bool options = false;


  String mutateLike(id, value) {
    return('''
      mutation updateLike {
        update_recipe_preferences_by_pk(pk_columns: {id: $id}, _set: {rating: $value}) {
          id
          rating
        }
      }
    ''');
  }


  String mutateChecked(id, checked) {
    return('''
      mutation updateChecked {
        update_meals_by_pk(pk_columns: {id: $id}, _set: {checked: $checked}) {
          checked
        }
      }
    ''');
  }


  String mutateSwap(id1, id2) {
    return('''
      mutation swapMeal {
        swapMeals(meal1: $id1, meal2: $id2) {
          response
        }
      }
    ''');
  }


  @override
  void initState() {
    super.initState();
    setState(() {
      id = widget.id;
      item = widget.item;
      recipe = widget.recipe;
    });
    if(widget.recipe.image != "") {
      getImage();
    }
    getRating();
    getMeals(widget.item.next);
  }


  getImage() {
    var label = '';
    var base = "https://backtomybody-dev.s3.amazonaws.com/recipes/photos/";
    var num = "";
    for(var i=0; i<(9-widget.recipe.id.length); i++) {
      num += "0";
    }
    num += widget.recipe.id;
    label = base+num.substring(0,3)+"/"+num.substring(3,6)+"/"+num.substring(6,9)+"/medium/"+widget.recipe.image;
    setState(() {
      image = label;
    });
  }


  getRating() {
    for(var likes in GlobalData.nutritionLikes) {
      if(likes.recipe == recipe.id) {
        setState(() {
          like = likes.rating;
        });
      }
    }
  }


  @override
  Widget build(BuildContext context) {

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.bgColor,
      body: MediaQuery(child: Container(
        color: AppColors.bgColor,
        padding: EdgeInsets.fromLTRB(0, 40, 0, 0),
        child: Column(
          children: <Widget>[
            Container (
              padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
              child: TitleLabelBack(GlobalUI.meals[item.type]),
            ),
            Container(
              width: MediaQuery.of(context).size.width,
              padding: EdgeInsets.fromLTRB(70, 0, 20, 20),
              child: Text(
                (options ? "Menu options" : recipe.name),
                textAlign: TextAlign.left,
                style: TextStyle(
                  color: AppColors.textColor,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
            ),
            showWhich()
          ],
        ),
      ),
      data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
      ),
    );
  }


  showWhich() {
    if(options) {
      return (
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: showOptions()
            ),
          ),
        )
      );
    } else {
      return showMeal();
    }
  }


  showMeal() {
    var ing = "Ingredients (1 serve)";
    if(item.serves > 1) {
      ing = "Ingredients ("+item.serves.toString()+" serves)";
    }
    return (
      Expanded(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(20, 0, 20, 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Card(
                elevation: 3,
                color: AppColors.boxColor,
                surfaceTintColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(7),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget> [
                    showImage(),
                    Row (
                      children: [
                        Container (
                          padding: EdgeInsets.fromLTRB(20, 15, 0, 0),
                          width: (MediaQuery.of(context).size.width-50)*0.5,
                          child: DataLabelCol("Calories", item.calories == 0 ? "-" : item.calories.toStringAsFixed(1)+" cal", (MediaQuery.of(context).size.width-70)*0.5),
                        ),
                        Container (
                          padding: EdgeInsets.fromLTRB(0, 15, 20, 0),
                          width: (MediaQuery.of(context).size.width-50)*0.5,
                          child: DataLabelCol("Daily target", GlobalData.nutrition.calories == 0 ? "-" : GlobalData.nutrition.calories.toStringAsFixed(1)+" cal", (MediaQuery.of(context).size.width-70)*0.5),
                        ),
                      ],
                    ),
                  ]
                )
              ),
              SubtitleLabel("Info"),
              Row (
                children: [
                  Container (
                    padding: EdgeInsets.fromLTRB(0, 15, 0, 0),
                    width: (MediaQuery.of(context).size.width-50)*0.25,
                    child: DataLabelCol("Fat", recipe.fat == 0 ? "-" : recipe.fat.toStringAsFixed(1)+"g", (MediaQuery.of(context).size.width-70)*0.25),
                  ),
                  Container (
                    padding: EdgeInsets.fromLTRB(0, 15, 0, 0),
                    width: (MediaQuery.of(context).size.width-50)*0.25,
                    child: DataLabelCol("Carbs", recipe.carbs == 0 ? "-" : recipe.carbs.toStringAsFixed(1)+"g", (MediaQuery.of(context).size.width-70)*0.25),
                  ),
                  Container (
                    padding: EdgeInsets.fromLTRB(0, 15, 0, 0),
                    width: (MediaQuery.of(context).size.width-50)*0.25,
                    child: DataLabelCol("Sugar", recipe.sugar == 0 ? "-" : recipe.sugar.toStringAsFixed(1)+"g", (MediaQuery.of(context).size.width-70)*0.25),
                  ),
                  Container (
                    padding: EdgeInsets.fromLTRB(0, 15, 0, 0),
                    width: (MediaQuery.of(context).size.width-50)*0.25,
                    child: DataLabelCol("Protein", recipe.protein == 0 ? "-" : recipe.protein.toStringAsFixed(1)+"g", (MediaQuery.of(context).size.width-70)*0.25),
                  ),
                ],
              ),
              SubtitleLabel(ing),
              Container (
                width: MediaQuery.of(context).size.width-40,
                padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
                child: Text(
                  _getIngredients(),
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    color: AppColors.textColor,
                    fontSize: 16,
                  ),
                )
              ),
              SubtitleLabel("Directions"),
              Container (
                width: MediaQuery.of(context).size.width-40,
                padding: EdgeInsets.fromLTRB(0, 10, 0, 20),
                child: Text(
                  (recipe.method == "" ? "-" : recipe.method.replaceAll('*', '\n\n')),
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    color: AppColors.textColor,
                    fontSize: 16,
                  ),
                )
              ),
              Container(
                height: 20
              ),
              _getButton(),
              Container(
                height: 10
              ),
            ]
          ),
        ),
      )
    );
  }


  showImage() {
    final decImage = ImageUrlResolver.safeDecorationImage(image, fit: BoxFit.cover);
    if(image != "" && decImage != null) {
      return (
        Stack(
          children: [
            Positioned(
              child: Container (
                width: MediaQuery.of(context).size.width-40,
                height: 190,
                color: AppColors.FieldColor,
                foregroundDecoration: BoxDecoration(
                  image: decImage,
                ),
              )
            ),
            Positioned(
              top: 15,
              left: 15,
              child: InkWell(
                onTap: () {
                  setLike(2);
                },
                child: SvgPicture.asset((like == 2 ? 'assets/images/nutrition/tup-active.svg' : 'assets/images/nutrition/tup-default.svg'), width: 40, height: 40)
              )
            ),
            Positioned(
              top: 15,
              left: 57,
              child: InkWell(
                onTap: () {
                  setLike(0);
                },
                child: SvgPicture.asset((like == 0 ? 'assets/images/nutrition/tdown-active.svg' : 'assets/images/nutrition/tdown-default.svg'), width: 40, height: 40)
              )
            ),
            showCheck(),
          ],
        )
      );
    } else {
      return(
        Stack(
          children: [
            Positioned(
              child: Container (
                width: MediaQuery.of(context).size.width-40,
                height: 190,
                color: AppColors.FieldColor,
              )
            ),
            Positioned(
              top: 15,
              left: 15,
              child: InkWell(
                onTap: () {
                  setLike(2);
                },
                child: SvgPicture.asset((like == 2 ? 'assets/images/nutrition/tup-active.svg' : 'assets/images/nutrition/tup-default.svg'), width: 40, height: 40)
              )
            ),
            Positioned(
              top: 15,
              left: 57,
              child: InkWell(
                onTap: () {
                  setLike(0);
                },
                child: SvgPicture.asset((like == 0 ? 'assets/images/nutrition/tdown-active.svg' : 'assets/images/nutrition/tdown-default.svg'), width: 40, height: 40)
              )
            ),
            showCheck(),
          ],
        )
      );
    }
  }


  showCheck() {
    if(item.checked) {
      return (
        Positioned(
          top: 15,
          right: 15,
          child:
          Container(
            padding: EdgeInsets.only(top: 10),
            width: 100,
            height: 40,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5.0),
              color: AppColors.GreenColor,
            ),
            child: Text(
              'Checked',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.WhiteColor,
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            )
          )
        )
      );
    } else {
      return Container();
    }
  }


  _getIngredients() {
    var label = "";
    for(var ing in recipe.ingredients) {
      double total = ing.amount*item.size*item.serves*ing.size;
      var size = total.ceil();
      /*if(total % ing.increments != 0) {
        print(ing.name);
        size = total.floor()+(((total % ing.increments) * ing.increments).ceil()).toDouble();
        print(size);
      }
      if(ing.increments == 1) {
        total = size.toDouble();
      }*/
      if(total % ing.increments != 0) {
        var rest = total % ing.increments;
        total = total-rest+ing.increments;
      }
      var tlabel = total.toString();
      if(total % 1 == 0) {
        tlabel = (total.toInt()).toString();
      }
      
      label += tlabel+" "+ing.unit+" x "+ing.kind+ing.name+"\n";
    }
    return label;
  }


  _getButton() {
    var date = DateTime.now();
    for(var day in GlobalData.nutritionDays) {
      if(day.id == item.day) {
        date = day.date;
      }
    }
    if(date.isAfter(DateTime.now())) {
      return (
        BtnTertiary(label: "View all menu options", clickFn: gotoOptions,)
      );
    } else {
      if(item.checked) {
        return (
          BtnTertiary(label: "I haven't eaten this meal", clickFn: setChecked)
        );
      } else {
        return (
          BtnPrimary(label: "I have eaten this meal", clickFn: setChecked)
        );
      }
    }
  }


  setLike(number) {
    var num = number;
    var rid = "";

    if(like == number) {
      num = -1;
    }
    for(var items in GlobalData.nutritionLikes) {
      if(items.recipe == widget.id) {
        items.rating = num;
        rid = items.id;
      }
      HealthPage.appState.updateData();
    }

    setState(() {
      like = num;
    });

    GraphQLClient client = GraphQLClient(
      cache: GraphQLCache(),
      link: Config.link,
    );
    client.mutate(
      MutationOptions(
        document: gql(mutateLike(int.parse(rid), num)),
      ),
    );
    
  }


  setChecked() {
    var value = true;
    var message = "Meal successfully checked";
    if(item.checked) {
      value = false;
      message = "Meal successfully unchecked";
    }
    GraphQLClient client = GraphQLClient(
      cache: GraphQLCache(),
      link: Config.link,
    );
    client.mutate(
      MutationOptions(
        document: gql(mutateChecked(int.parse(item.id), value)),
      ),
    );
    
    var ml = item;
    ml.checked = value;
    setState(() {
      item = ml;
    });
    HealthPage.appState.updateData();

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      duration: Duration(seconds: 2),
      backgroundColor: AppColors.GreenColor,
    ));
  }


  gotoOptions() {
    //Navigator.push(context, MaterialPageRoute(builder: (context) => SwapPage(item.id, item)));
    setState(() {
      options = true;
    });
  }


  goBackOptions() {
    setState(() {
      options = false;
    });
  }


  // Swapping


  getMeals(id) {
    var continueNext = false;
    for(var meal in GlobalData.nutritionMeals) {
      if(meal.id == id) {
        nexts.add(meal);
        if(meal.next != "" && meal.next != null && meal.next != widget.item.id) {
          continueNext = true;
          getMeals(meal.next);
        }
      }
    }
    if(!continueNext) {
      var tmp = nexts;
      setState(() {
        nexts = tmp;
      });
    }
  }


  showOptions() {
    List<Widget> items = [];
    items.add(Container(height: 20));
    for(var meal in nexts) {
      items.add(
        Card(
          elevation: 3,
          color: AppColors.boxColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(7),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget> [
              Container (
                width: MediaQuery.of(context).size.width-40,
                height: 190,
                color: AppColors.FieldColor,
                foregroundDecoration: ImageUrlResolver.safeDecorationImage(_getImage(meal.recipe), fit: BoxFit.cover) != null ? BoxDecoration(
                  image: ImageUrlResolver.safeDecorationImage(_getImage(meal.recipe), fit: BoxFit.cover),
                ) : null,
              ),
              Container (
                margin: EdgeInsets.fromLTRB(20, 13, 20, 5),
                width: MediaQuery.of(context).size.width-100,
                child: Text(
                  _getName(meal.recipe, meal.gluten),
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    color: AppColors.textColor,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
              ),
              Container (
                margin: EdgeInsets.fromLTRB(20, 0, 20, 0),
                width: MediaQuery.of(context).size.width-100,
                child: Text(
                  "Do you want to select this option and update your meal?",
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    color: AppColors.textColor,
                    fontSize: 14,
                  ),
                )
              ),
              Container (
                margin: EdgeInsets.fromLTRB(20, 13, 20, 20),
                child: BtnPrimary(label: "Select this option", clickFn: () => selectMeal(meal.id),),
              )
            ]
          )
        ),
      );
      items.add(Container(height: 20));
    }
    if(nexts.length == 0) {
      items.add(EmptyLabel('', 'No options available'));
      items.add(Container(height: 20));
    }
    items.add(BtnTertiary(label: "Cancel", clickFn: goBackOptions,));
    items.add(Container(height: 20));
    return items;
  }


  _getImage(id) {
    var label = '';
    var image = '';
    for(var item in GlobalData.nutritionRecipes) {
      if(item.id == id) {
        var base = "https://backtomybody-dev.s3.amazonaws.com/recipes/photos/";
        var num = "";
        for(var i=0; i<(9-id.length); i++) {
          num += "0";
        }
        num += id;
        label = base+num.substring(0,3)+"/"+num.substring(3,6)+"/"+num.substring(6,9)+"/medium/"+item.image;
      }
    }
    return label;
  }


  _getName(id, gluten) {
    var label = "Meal";
    for(var item in GlobalData.nutritionRecipes) {
      if(item.id == id) {
        label = item.name;
        if(GlobalData.nutrition.gluten && gluten) {
          label += " (G)";
        }
      }
    }
    return label;
  }


  selectMeal(ids) async {
    var newId = "";
    GraphQLClient client = GraphQLClient(
      cache: GraphQLCache(),
      link: Config.link,
    );
    client.mutate(
      MutationOptions(
        document: gql(mutateSwap(int.parse(item.id), ids)),
        onCompleted: (dynamic resultData) {
          var day = item.day;
          for(var ml in GlobalData.nutritionMeals) {
            if(ml.id == item.id) {
              ml.day = "";
            }
            if(ml.id == ids) {
              ml.day = day;
              newId = ml.id;
            }
          }
          showConfirmation(newId, day);
        }
      ),
    );
  }


  showConfirmation(nid, dy) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text("Menu successfully updated"),
      duration: Duration(seconds: 2),
      backgroundColor: AppColors.GreenColor,
    ));

    for(var day in GlobalData.nutritionDays) {
      if(day.id == dy) {
        for(var i=0; i<day.meals.length; i++) {

          if(day.meals[i].id == item.id) {
            day.meals.removeAt(i);
          }
        }
        for(var meal in GlobalData.nutritionMeals) {
          if(meal.id == nid) {
            day.meals.add(meal);
          }
        }
        day.meals.sort((a, b) => a.type.compareTo(b.type));
      }
    }
    HealthPage.appState.updateData();
    
    Future.delayed(const Duration(milliseconds: 1000), () { 
      Navigator.pop(context);     
    });
    Future.delayed(const Duration(milliseconds: 7000), () { 
      GQLConnector.getNutrition(id: GlobalData.space.nutritionId);
    });
  }


  getRecipe(id) {
    for(var item in GlobalData.nutritionRecipes) {
      if(item.id == id) {
        return item;
      }
    }
  }


}