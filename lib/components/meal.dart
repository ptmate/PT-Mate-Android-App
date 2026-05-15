import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:ptmate_client/health/index.dart';
import 'package:ptmate_client/main.dart';
import 'package:ptmate_client/_data/variables.dart';
import 'package:ptmate_client/health/index.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:ptmate_client/_data/client.dart';


class Meal extends StatefulWidget {
  final String label;
  final String sublabel;
  final String id;
  final String image;
  final bool checked;
  final String meal;
  final int like;
  final DateTime date;

  const Meal(this.label, this.sublabel, this.id, this.image, this.checked, this.meal, this.like, this.date);
  @override
  _MealState createState() => _MealState();
}


class _MealState extends State<Meal> {


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


  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(0,0,0,20),
      width: double.maxFinite,

      child: Card(
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
            Container (
              margin: EdgeInsets.fromLTRB(20, 13, 20, 5),
              width: MediaQuery.of(context).size.width-100,
              child: Text(
                widget.label,
                textAlign: TextAlign.left,
                style: TextStyle(
                  color: AppColors.textColor,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
            ),
            Container (
              margin: EdgeInsets.fromLTRB(20, 0, 20, 20),
              width: MediaQuery.of(context).size.width-100,
              child: Text(
                widget.sublabel,
                textAlign: TextAlign.left,
                style: TextStyle(
                  color: AppColors.textColor,
                  fontSize: 14,
                ),
              )
            )
          ]
        )
      ),
      
    );
  }


  showImage() {
    if(widget.image != "") {
      return (
        Stack(
          children: [
            Positioned(
              child: Container (
                width: MediaQuery.of(context).size.width-40,
                height: 190,
                color: AppColors.FieldColor,
                foregroundDecoration: BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage(widget.image),
                    fit: BoxFit.cover),
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
                child: SvgPicture.asset((widget.like == 2 ? 'assets/images/nutrition/tup-active.svg' : 'assets/images/nutrition/tup-default.svg'), width: 40, height: 40)
              )
            ),
            Positioned(
              top: 15,
              left: 57,
              child: InkWell(
                onTap: () {
                  setLike(0);
                },
                child: SvgPicture.asset((widget.like == 0 ? 'assets/images/nutrition/tdown-active.svg' : 'assets/images/nutrition/tdown-default.svg'), width: 40, height: 40)
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
                child: SvgPicture.asset((widget.like == 2 ? 'assets/images/nutrition/tup-active.svg' : 'assets/images/nutrition/tup-default.svg'), width: 40, height: 40)
              )
            ),
            Positioned(
              top: 15,
              left: 57,
              child: InkWell(
                onTap: () {
                  setLike(0);
                },
                child: SvgPicture.asset((widget.like == 0 ? 'assets/images/nutrition/tdown-active.svg' : 'assets/images/nutrition/tdown-default.svg'), width: 40, height: 40)
              )
            ),
            showCheck(),
          ],
        )
      );
    }
  }


  showCheck() {
    if(widget.date.isAfter(DateTime.now())) {
      return Container();
    } else {
      return showChecked();
    }
  }


  showChecked() {
    if(widget.checked) {
      return (
        Positioned(
          top: 15,
          right: 15,
          child: InkWell(
            onTap: () {
              setChecked(false);
            },
            child: Container(
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
          
        )
      );
    } else {
      return (
        Positioned(
          top: 15,
          right: 15,
          child: InkWell(
            onTap: () {
              setChecked(true);
            },
            child: Container(
              padding: EdgeInsets.only(top: 10),
              width: 100,
              height: 40,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5.0),
                color: AppColors.AvatarColor,
              ),
              child: Text(
                'Check',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.TextColor,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              )
            )
          )
        )
      );
    }
  }


  setLike(number) {
    var num = number;
    if(widget.like == number) {
      num = -1;
    }
    for(var item in GlobalData.nutritionLikes) {
      if(item.recipe == widget.id) {
        item.rating = num;
      }
      HealthPage.appState.updateData();
    }

    GraphQLClient client = GraphQLClient(
      cache: GraphQLCache(),
      link: Config.link,
    );
    client.mutate(
      MutationOptions(
        document: gql(mutateLike(int.parse(widget.id), num)),
      ),
    );
    
  }


  setChecked(value) {
    GraphQLClient client = GraphQLClient(
      cache: GraphQLCache(),
      link: Config.link,
    );
    client.mutate(
      MutationOptions(
        document: gql(mutateChecked(int.parse(widget.meal), value)),
      ),
    );

    for(var item in GlobalData.nutritionMeals) {
      if(item.id == widget.meal) {
        item.checked = value;
      }
      HealthPage.appState.updateData();
    }
  }
}
