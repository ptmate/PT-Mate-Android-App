import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:intl/intl.dart';
import 'package:ptmate_client/_data/client.dart';
import 'package:ptmate_client/_data/models.dart';
import 'package:ptmate_client/_data/variables.dart';
import 'package:ptmate_client/_data/sender.dart';

import 'package:ptmate_client/health/index.dart';


class GQLConnector {
  
  // Nutrition

  static GraphQLClient client = GraphQLClient(
    cache: GraphQLCache(),
    link: Config.link,
  );


  static String queryUser(id) {
    return ('''
      query getUserData {
        users_by_pk(id: $id) {
          id
          form_status
          sex
          bmr
          weight
          weight_unit
          u_weight
          u_goal_weight
          u_current_weight
          goal
          goal_weight
          current_weight
          activity_level
          current_period_start
          current_period_end

          dinner_serves
          leftover_lunches
          cheat_meal
          dessert
          snack_evening
          cold_breakfast

          gluten
          wheat
          lactose
          milk
          egg
          nuts
          shellfish
          fish
          red_meat
          pork
          chicken
          turkey
          fruit
          vegetable
          grain
          herb_spice
          legume
          berry
          lamb
          preference_length
          preference_string 

          v_meals
          v_type
          breakfast_rotations

          plan_type
          snack_morning_protein
          snack_afternoon_protein
          snack_evening_protein

          plans(
            distinct_on: [start_date]
            limit: 3
            order_by: {start_date: desc}
          ) {
            bmr
            start_date
            stop_date
            daily_cals

            meals {
              id
              recipe_id
              plan_id
              day_id
              checked
              
              gluten
              breakfast
              snack_morning
              lunch
              snack_afternoon
              dinner
              dessert
              snack_evening
              serve_now_servings
              next_meal_id
              calories
              size
            }
            
            days(order_by: {scheduled_date: asc}) {
              id
              plan_id
              scheduled_date
              calories
              breakfast
              snack_morning
              lunch
              snack_afternoon
              dinner
              dessert
              snack_evening
              cheat_meal
            }

            shopping_lists {
              id
              start_date
              stop_date
              list_items {
                id
                name
                checked
                kind
                base_amount
                alt_weight
                alt_volume
                measurement
                gluten
                amount
                shopping_cat  
              }
            }
          }

          recipe_preferences {
            id
            user_id
            recipe_id
            rating
          }
        }
      }
    ''');
  }


  static String queryRecipes() {
    return ('''
      query getRecipes {
        recipes {
            id
            name
            photo_file_name
            cooking_time
            protein
            sugars
            total_fat
            total_carbs
            method
            amounts {
              size
              ingredient {
                id
                name
                base_amount
                measurement
                increments
                kind
              }
            }
        }
    }
    ''');
  } 


  static String queryGenerating(id) {
    return('''
      query getGenerating {
        users_by_pk(id: $id) {
            generating_shopping_list
        }
      }
    ''');
  }

  


  static void getNutrition({id = int}) async {
    QueryResult queryResult = await client.query(
      QueryOptions(
        fetchPolicy: FetchPolicy.networkOnly,
        document: gql(queryUser(id)),
      ),
    );
    GlobalData.nutrition.weight = (queryResult.data!["users_by_pk"]["weight"] ?? 0).toDouble();
    GlobalData.nutrition.goalWeight = (queryResult.data!["users_by_pk"]["goal_weight"] ?? 0).toDouble();
    GlobalData.nutrition.activity = queryResult.data!["users_by_pk"]["activity_level"] ?? 0;
    GlobalData.nutrition.currentWeight = (queryResult.data!["users_by_pk"]["current_weight"] ?? 0).toDouble();
    GlobalData.nutrition.gluten = queryResult.data!["users_by_pk"]["gluten"] ?? 0;
    GlobalData.nutrition.vegetarian = queryResult.data!["users_by_pk"]["v_type"] ?? 0;
    GlobalData.nutrition.vegMeals = queryResult.data!["users_by_pk"]["v_meals"] ?? 0;

    GlobalData.nutrition.people = queryResult.data!["users_by_pk"]["dinner_serves"] ?? 1;
    GlobalData.nutrition.leftover = queryResult.data!["users_by_pk"]["leftover_lunches"] ?? true;
    GlobalData.nutrition.cheat = queryResult.data!["users_by_pk"]["cheat_meal"] ?? 0;
    GlobalData.nutrition.cheat = queryResult.data!["users_by_pk"]["cheat_meal"] ?? 0;
    GlobalData.nutrition.dessert = queryResult.data!["users_by_pk"]["dessert"] ?? false;
    GlobalData.nutrition.snack = queryResult.data!["users_by_pk"]["snack_evening"] ?? false;
    GlobalData.nutrition.coldbreakfast = queryResult.data!["users_by_pk"]["cold_breakfast"] ?? false;

    GlobalData.nutrition.gluten = queryResult.data!["users_by_pk"]["gluten"] ?? false;
    GlobalData.nutrition.redmeat = queryResult.data!["users_by_pk"]["red_meat"] ?? false;
    GlobalData.nutrition.pork = queryResult.data!["users_by_pk"]["pork"] ?? false;
    GlobalData.nutrition.chicken = queryResult.data!["users_by_pk"]["chicken"] ?? false;
    GlobalData.nutrition.turkey = queryResult.data!["users_by_pk"]["turkey"] ?? false;
    GlobalData.nutrition.fish = queryResult.data!["users_by_pk"]["fish"] ?? false;
    GlobalData.nutrition.shellfish = queryResult.data!["users_by_pk"]["shellfish"] ?? false;

    GlobalData.nutrition.dairy = queryResult.data!["users_by_pk"]["lactose"] ?? false;
    GlobalData.nutrition.nuts = queryResult.data!["users_by_pk"]["nuts"] ?? false;
    GlobalData.nutrition.eggs = queryResult.data!["users_by_pk"]["eggs"] ?? false;

    GlobalData.nutrition.sex = queryResult.data!["users_by_pk"]["sex"] ?? "m";

    GlobalData.nutrition.planType = queryResult.data!["users_by_pk"]["plan_type"] ?? 0;
    GlobalData.nutrition.snackMorning = queryResult.data!["users_by_pk"]["snack_morning_protein"] ?? false;
    GlobalData.nutrition.snackAfternoon = queryResult.data!["users_by_pk"]["snack_afternoon_protein"] ?? false;
    GlobalData.nutrition.snackEvening = queryResult.data!["users_by_pk"]["snack_evening_protein"] ?? false;

    var plan = queryResult.data!["users_by_pk"]["plans"];

    DateTime now = DateTime.now();
    int currentDay = now.weekday;
    DateTime week = now.subtract(Duration(days: currentDay - 1));
    var wd = DateFormat(DateFormat.YEAR_MONTH_DAY).format(week);
    DateTime next = week.add(Duration(days: 7));
    var nd = DateFormat(DateFormat.YEAR_MONTH_DAY).format(next);
    List<ModelNutritionListItem> items = [];
    GlobalData.nutritionDays = [];
    GlobalData.nutritionMeals = [];

    for(var item in plan) {
      GlobalData.nutrition.bmr = (item["bmr"] ?? 0).toDouble();
      GlobalData.nutrition.calories = item["daily_cals"] ?? 0;

      var meals = item["meals"];
      for(var meal in meals) {
        var type = 0;
        var serves = meal["serve_now_servings"];
        if (meal["snack_morning"] == true) { type = 1; }
        if (meal["lunch"] == true) { type = 2; }
        if (meal["snack_afternoon"] == true) { type = 3; }
        if (meal["dinner"] == true) {
          type = 4;
          if(GlobalData.nutrition.leftover) {
            serves += 1;
          }
        }
        if (meal["dessert"] == true) { type = 5; }
        if (meal["snack_evening"] == true) { type = 6; }
        GlobalData.nutritionMeals.add(ModelNutritionMeal(meal["id"].toString(), meal["recipe_id"].toString(), meal["day_id"].toString(), type, meal["calories"], meal["gluten"], meal["checked"], meal["next_meal_id"].toString(), serves, (meal["size"]).toDouble()));
      }
      GlobalData.nutritionMeals.sort((a, b) => a.type.compareTo(b.type));

      var days = item["days"];
      for(var day in days) {
        List<ModelNutritionMeal> items = [];
        for(var item in GlobalData.nutritionMeals) {
          if(item.day == day["id"].toString()) {
            items.add(item);
          }
        }
        GlobalData.nutritionDays.add(ModelNutritionDay(day["id"].toString(), DateTime.parse(day["scheduled_date"]), items, false));
      }
      GlobalData.nutritionDays.sort((a, b) => b.date.compareTo(a.date));

      var list = item["shopping_lists"];
      for(var lst in list) {
        items = [];
        var lis = lst["list_items"];
        for(var li in lis) {
          var kind = "";
          var gluten = false;
          if(li["kind"] != null) { kind = li["kind"]; }
          if(li["gluten"] != null) { gluten = li["gluten"]; }
          items.add(ModelNutritionListItem(li["id"].toString(), li["shopping_cat"].toString(), (li["name"] is String ? li["name"] : ""), kind, li["amount"].toDouble(), li["measurement"], gluten, li["checked"]));
        }
        items.sort((a, b) => a.name.compareTo(b.name));
        DateTime date = DateTime.parse(lst["start_date"]);
        //var dd = DateFormat(DateFormat.YEAR_MONTH_DAY).format(date);
        var wstart = date.subtract(Duration(days: date.weekday - 1));
        var dd = DateFormat(DateFormat.YEAR_MONTH_DAY).format(wstart);
        if(dd == wd) {
          GlobalData.shoppingThis = ModelNutritionList(lst["id"].toString(), date, items);
        }
        if(dd == nd) {
          GlobalData.shoppingNext = ModelNutritionList(lst["id"].toString(), date, items);
        }
      }

      var prefs = queryResult.data!["users_by_pk"]["recipe_preferences"];
      GlobalData.nutritionLikes = [];
      for(var pref in prefs) {
        GlobalData.nutritionLikes.add(ModelNutritionLikes(pref["id"].toString(), pref["recipe_id"].toString(), pref["rating"]));
      }
    }

    
    if(queryResult.data!["users_by_pk"]["form_status"] != null) {
      if(GlobalData.space.nutritionStatus != queryResult.data!["users_by_pk"]["form_status"]) {
        GlobalData.space.nutritionStatus = queryResult.data!["users_by_pk"]["form_status"];
        FirebaseSender.updateNutritionStatus(GlobalData.space.nutritionStatus);
      }
    }
    HealthPage.appState.updateData();
  }



  static void getRecipes() async {
    QueryResult queryResult = await client.query(
      QueryOptions(
        fetchPolicy: FetchPolicy.cacheAndNetwork,
        document: gql(queryRecipes()),
      ),
    );
    GlobalData.nutritionRecipes = [];
    var res = queryResult.data!["recipes"];
    for(var item in res) {
      List<ModelNutritionIngredient> ingredients = [];
      for(var ings in item["amounts"]) {
        double size = 1;
        if(ings["size"] != null) {
          size = (ings["size"]).toDouble();
        }
        double incr = 0.25;
        if(ings["ingredient"]["increments"] != null) {
          incr = (ings["ingredient"]["increments"]).toDouble();
        }
        String kind = "";
        if(ings["ingredient"]["kind"] != null) {
          kind = (ings["ingredient"]["kind"])+" ";
        }
        if(kind == " ") {
          kind = "";
        }
        ingredients.add(ModelNutritionIngredient(ings["ingredient"]["id"].toString(), ings["ingredient"]["name"], ings["ingredient"]["base_amount"].toInt(), ings["ingredient"]["measurement"], incr, size, kind));
      }
      var photo = "";
      if(item["photo_file_name"] != null) { photo = item["photo_file_name"]; }
      GlobalData.nutritionRecipes.add(ModelNutritionRecipe(item["id"].toString(), item["name"], photo, item["cooking_time"], item["total_fat"].toDouble(), item["total_carbs"].toDouble(), item["sugars"].toDouble(), item["protein"].toDouble(), item["method"], ingredients));
    }

    HealthPage.appState.updateData();
  }

}