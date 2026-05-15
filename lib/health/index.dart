import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:intl/intl.dart';
import 'package:ptmate_client/_data/client.dart';
import 'package:ptmate_client/_data/graphql.dart';
import 'package:ptmate_client/_data/models.dart';
import 'package:ptmate_client/_data/sender.dart';
import 'package:ptmate_client/_data/variables.dart';
import 'package:ptmate_client/_helper/calendar.dart';
import 'package:ptmate_client/components/button-primary-small.dart';
import 'package:ptmate_client/components/button-primary.dart';
import 'package:ptmate_client/components/button-tertiary.dart';
import 'package:ptmate_client/components/data-column.dart';
import 'package:ptmate_client/components/empty-message.dart';
import 'package:ptmate_client/components/list-default.dart';
import 'package:ptmate_client/components/list-shopping.dart';
import 'package:ptmate_client/components/list-text.dart';
import 'package:ptmate_client/components/meal.dart';
import 'package:ptmate_client/components/subtitle.dart';
import 'package:ptmate_client/components/tab.dart';
import 'package:ptmate_client/components/trainingspace.dart';
import 'package:ptmate_client/health/assessment.dart';
import 'package:ptmate_client/health/habit.dart';
import 'package:ptmate_client/health/meal.dart';
import 'package:ptmate_client/health/new-assessment.dart';
import 'package:ptmate_client/health/nutrition.dart';
import 'package:ptmate_client/main.dart';

class HealthPage extends StatefulWidget {
  static _HealthPageState appState = _HealthPageState();
  @override
  _HealthPageState createState() {
    return HealthPage.appState = new _HealthPageState();
  }
}

class _HealthPageState extends State<HealthPage> {
  String mutateChecked(id, checked) {
    return ('''
      mutation updateListChecked {
        update_list_items_by_pk(pk_columns: {id: $id}, _set: {checked: $checked}) {
          id
          checked
        }
      }
    ''');
  }

  String queryUserCheck(id) {
    return ('''
      query getUserData {
        users_by_pk(id: $id) {
          form_status
        }
      }
    ''');
  }

  String current = "nutrition";
  List<ModelAssessment> assessments = [];
  double weight = 0;
  double fat = 0;
  int heart = 0;
  double bmr = 0;
  int calories = 0;
  double start = 0;
  double end = 0;
  ModelNutritionList shopping = GlobalData.shoppingThis;
  int shopTab = 0;
  List<ModelNutritionDay> days = GlobalData.nutritionDays;
  List<ModelNutritionRecipe> recipes = GlobalData.nutritionRecipes;
  int day = 9999;
  int dstart = 9999;
  List<ModelNutritionLikes> likes = GlobalData.nutritionLikes;
  var timer;
  String status = GlobalData.space.nutritionStatus;

  @override
  void initState() {
    super.initState();

    var istart = dstart;
    var today = DateFormat(DateFormat.YEAR_MONTH_DAY).format(DateTime.now());
    if (GlobalData.nutritionDays.length != 0) {
      for (var i = 0; i < GlobalData.nutritionDays.length; i++) {
        var df = DateFormat(DateFormat.YEAR_MONTH_DAY)
            .format(GlobalData.nutritionDays[i].date);
        if (df == today && day == 9999) {
          istart = i;
          dstart = i;
        }
      }
    }
    if (istart == 9999) {
      istart = GlobalData.nutritionDays.length - 1;
      if (istart < 0) {
        istart = 0;
      }
    }

    setState(() {
      assessments = GlobalData.assessments;
      days = GlobalData.nutritionDays;
      day = istart;
      recipes = GlobalData.nutritionRecipes;
      likes = GlobalData.nutritionLikes;
      status = GlobalData.space.nutritionStatus;
    });

    assessments.sort((a, b) => b.date.compareTo(a.date));
    if (assessments.length > 0) {
      setState(() {
        weight = assessments[0].weight;
        fat = assessments[0].fat;
        heart = assessments[0].heart;
        bmr = GlobalData.nutrition.bmr;
        calories = GlobalData.nutrition.calories;
        start = GlobalData.nutrition.weight;
        end = GlobalData.nutrition.goalWeight;
      });
    }
  }

  updateData() {
    if (this.mounted) {
      var start = day;
      var today = DateFormat(DateFormat.YEAR_MONTH_DAY).format(DateTime.now());
      if (GlobalData.nutritionDays.length != 0) {
        for (var i = 0; i < GlobalData.nutritionDays.length; i++) {
          var df = DateFormat(DateFormat.YEAR_MONTH_DAY)
              .format(GlobalData.nutritionDays[i].date);
          if (df == today && dstart == 9999) {
            start = i;
            dstart = i;
          }
        }
      }
      setState(() {
        assessments = GlobalData.assessments;
        days = GlobalData.nutritionDays;
        day = start;
        recipes = GlobalData.nutritionRecipes;
        likes = GlobalData.nutritionLikes;
        status = GlobalData.space.nutritionStatus;
      });
      assessments.sort((a, b) => b.date.compareTo(a.date));
      tapListNav(shopTab);
    }
  }

  checkStatus() {
    setState(() {
      status = "created";
    });
    timer = Timer.periodic(new Duration(seconds: 5), (timer) {
      checkPlan();
    });
  }

  checkPlan() async {
    GraphQLClient client = GraphQLClient(
      cache: GraphQLCache(),
      link: Config.link,
    );
    QueryResult queryResult = await client.query(
      QueryOptions(
        fetchPolicy: FetchPolicy.networkOnly,
        document: gql(queryUserCheck(int.parse(GlobalData.space.nutritionId))),
      ),
    );
    var status = queryResult.data!["users_by_pk"]["form_status"];
    if (status == "active") {
      timer.cancel();
      FirebaseSender.updateNutritionStatus(status);
      GlobalData.space.nutritionStatus = status;
      GQLConnector.getNutrition(id: GlobalData.space.nutritionId);
    }
  }

  showAlertUpdate() {
    AlertDialog alert = AlertDialog(
      title: Text("Preferences updated"),
      content: Text(
          "We'll create next week's meals for you based on the updates you just saved."),
      actions: [
        TextButton(
          child: Text("Got it"),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
    );
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  showAlertNew() {
    AlertDialog alert = AlertDialog(
      title: Text("You're all set!"),
      content: Text(
          "We're creating the first meal plan and shopping list for you. This may take a few minutes. Don't worry, you'll see your meals here once it's ready."),
      actions: [
        TextButton(
          child: Text("Got it"),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
    );
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  switchTab(val) {
    setState(() {
      current = val;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgColor,
      body: MediaQuery(
        child: Container(
            color: AppColors.bgColor,
            alignment: Alignment.topLeft,
            child: Column(children: [
              Container(
                  height: 160,
                  padding: EdgeInsets.only(top: 35),
                  alignment: Alignment.topLeft,
                  color: AppColors.bgColor,
                  child: Column(
                    children: [
                      TrainingSpace(),
                      Container(
                          padding: EdgeInsets.fromLTRB(20, 15, 20, 0),
                          child: Row(
                            children: [
                              TabLabel(
                                  label: "Nutrition",
                                  active: current == "nutrition" ? true : false,
                                  clickFn: switchTab,
                                  valueFn: "nutrition"),
                              TabLabel(
                                  label: "Progress",
                                  active: current == "progress" ? true : false,
                                  clickFn: switchTab,
                                  valueFn: "progress"),
                              _getTab()
                            ],
                          )),
                    ],
                  )),
              _createContent()
            ])),
        data:
            MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(1.0)),
      ),
    );
  }

  _getTab() {
    var show = true;
    if (GlobalData.space.nutritionId == "") {
      show = false;
    }
    if (GlobalData.space.nutritionStatus != "active") {
      show = false;
    }
    if (GlobalData.shoppingThis.id == "" && GlobalData.shoppingNext.id == "") {
      show = false;
    }
    var edate = DateTime.fromMillisecondsSinceEpoch(
        GlobalData.space.nutritionEnd.toInt() * 1000);
    if (edate.isBefore(DateTime.now())) {
      show = false;
    }
    if (show) {
      return (TabLabel(
          label: "Shopping Lists",
          active: current == "shopping" ? true : false,
          clickFn: switchTab,
          valueFn: "shopping"));
    } else {
      return Container();
    }
  }

  _createContent() {
    if (current == "nutrition") {
      return _getNutrition();
    } else if (current == "progress") {
      return _getProgress();
    } else {
      return _getShopping();
    }
  }

  _getNutrition() {
    if (GlobalData.space.nutritionId == "") {
      return (Container(
          alignment: Alignment.center,
          width: 300,
          height: MediaQuery.of(context).size.height - 250,
          child: EmptyMessage("empty-nutrition", "Nutrition",
              "Nutrition plans help you achieve your weight goals. Talk to your trainer if you're interested in nutrition plans. You'll be able to manage it from here.")));
    } else {
      if (GlobalData.space.nutritionStatus == "registered" &&
          GlobalData.space.nutritionStart <
              (DateTime.now().millisecondsSinceEpoch / 1000) &&
          GlobalData.space.nutritionEnd >
              (DateTime.now().millisecondsSinceEpoch / 1000).toInt()) {
        return (Container(
            alignment: Alignment.center,
            width: 300,
            height: MediaQuery.of(context).size.height - 230,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                EmptyMessage("empty-nutrition", "Nutrition",
                    "Set your nutrition preferences and create your first nutrition plan to get started. You can update your preferences any time."),
                BtnPrimarySmall(label: 'Get started', clickFn: tapPreferences)
              ],
            )));
      } else if (GlobalData.space.nutritionStatus == "created") {
        return (Container(
            alignment: Alignment.center,
            width: 300,
            height: MediaQuery.of(context).size.height - 230,
            child: EmptyMessage("empty-nutrition", "Nutrition",
                "We're cooking your first meal plan. This may take a few minutes. You'll see your meals here once it's ready.")));
      } else {
        var date = DateTime.now();
        var date2 = DateTime.now();
        if (GlobalData.space.nutritionEnd <
            (date.millisecondsSinceEpoch / 1000)) {
          return (Container(
              alignment: Alignment.center,
              width: 300,
              height: MediaQuery.of(context).size.height - 230,
              child: EmptyMessage("empty-nutrition", "Nutrition",
                  "You don't have an active nutrition plan at the moment. Talk to your trainer if you want to get another plan.")));
        } else if (GlobalData.space.nutritionStart >
            (date2.millisecondsSinceEpoch / 1000).toInt()) {
          return (Container(
              alignment: Alignment.center,
              width: 300,
              height: MediaQuery.of(context).size.height - 230,
              child: EmptyMessage(
                  "empty-nutrition",
                  "Nutrition",
                  "Your next plan will start\n" +
                      HelperCal.getSpecialDateBasic(
                          DateTime.fromMillisecondsSinceEpoch(
                              GlobalData.space.nutritionStart * 1000)) +
                      ". Your meals\nwill be available here.")));
        } else {
          if (days.length == 0 || recipes.length == 0 || day == 9999) {
            return (Column(children: [
              EmptyMessage("empty-nutrition", "Loading", "Getting your meals")
            ]));
          } else {
            return _getMeals();
          }
        }
      }
    }
  }

  _getMeals() {
    return (Column(
      children: [
        _getMealsNav(),
        Container(
            height: MediaQuery.of(context).size.height - 235,
            child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(20, 0, 20, 40),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: _getDay())))
      ],
    ));
  }

  _getDay() {
    List<Widget> items = [];
    for (var item in days[day].meals) {
      Meal meal = Meal(
          getMealName(item.recipe, item.gluten),
          GlobalUI.meals[item.type] +
              "\n" +
              item.calories.toString() +
              " of " +
              GlobalData.nutrition.calories.toString() +
              " cal" +
              getMealTime(item.recipe),
          item.recipe,
          getMealImage(item.recipe),
          item.checked,
          item.id,
          getMealLike(item.recipe),
          days[day].date);
      items.add(InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    MealPage(item.day, item, getRecipe(item.recipe))),
          );
        },
        child: meal,
      ));
    }
    items.add(_getPreferences());
    return items;
  }

  _getMealsNav() {
    return (Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        InkWell(
            onTap: () {
              tapListMeals('prev');
            },
            child: Container(
                margin: EdgeInsets.only(left: 15),
                height: 40,
                width: 40,
                child: SvgPicture.asset('assets/images/nav/prev.svg',
                    color: AppColors.PrimaryColor, width: 40, height: 40))),
        InkWell(
            onTap: () {
              _selectDate(context);
            },
            child: Container(
              alignment: Alignment.center,
              width: MediaQuery.of(context).size.width - 110,
              height: 40,
              child: Text(
                HelperCal.getSpecialDateBasic(days[day].date),
                textAlign: TextAlign.left,
                style: TextStyle(
                  color: AppColors.textColor,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
            )),
        InkWell(
            onTap: () {
              tapListMeals('next');
            },
            child: Container(
                margin: EdgeInsets.only(right: 15),
                height: 40,
                width: 40,
                child: SvgPicture.asset('assets/images/nav/next.svg',
                    color: AppColors.PrimaryColor, width: 40, height: 40))),
      ],
    ));
  }

  _getProgress() {
    return (Expanded(
        child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(20, 20, 20, 40),
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
                    child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Container(
                            padding: EdgeInsets.fromLTRB(15, 15, 0, 0),
                            width:
                                (MediaQuery.of(context).size.width - 50) * 0.33,
                            child: DataLabelCol(
                                "Weight",
                                (weight == 0 ? "-" : _getWeightNum(weight)),
                                (MediaQuery.of(context).size.width - 70) *
                                    0.33),
                          ),
                          Container(
                            padding: EdgeInsets.fromLTRB(15, 15, 0, 0),
                            width:
                                (MediaQuery.of(context).size.width - 50) * 0.33,
                            child: DataLabelCol(
                                "Body fat",
                                (fat == 0 ? "-" : fat.toStringAsFixed(1) + "%"),
                                (MediaQuery.of(context).size.width - 70) *
                                    0.33),
                          ),
                          Container(
                            padding: EdgeInsets.fromLTRB(15, 15, 0, 0),
                            width:
                                (MediaQuery.of(context).size.width - 50) * 0.33,
                            child: DataLabelCol(
                                "Heart rate",
                                (heart == 0 ? "-" : heart.toString() + " bpm"),
                                (MediaQuery.of(context).size.width - 70) *
                                    0.33),
                          ),
                        ])),
                _getProgressNutrition(),
                Container(height: 10),
                _getHabits(),
                _getHealthButton(),
                _getProgressData(),
                Container(height: 40),
                BtnPrimary(label: "New log entry", clickFn: tapNewLog),
                Container(height: 20),
                _getPreferences()
              ],
            ))));
  }

  _getHealthButton() {
    if (assessments.length < 5) {
      return Container();
    } else {
      return BtnTertiary(label: "New log entry", clickFn: tapNewLog);
    }
  }

  _getProgressNutrition() {
    var date = DateTime.now().subtract(Duration(days: 7));
    if (GlobalData.space.nutritionEnd >
            (date.millisecondsSinceEpoch / 1000).toInt() &&
        GlobalData.space.nutritionStatus == "active") {
      return (Card(
          elevation: 3,
          color: AppColors.boxColor,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(7),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: EdgeInsets.all(20),
                child: Text(
                  "Journey to your goal weight",
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    color: AppColors.textColor,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
              ),
              Container(
                  color: AppColors.fieldColor,
                  alignment: Alignment.topLeft,
                  margin: EdgeInsets.fromLTRB(20, 0, 20, 0),
                  height: 3,
                  child: Container(
                    color: AppColors.GreenColor,
                    width: getBarWidth(),
                    height: 3,
                  )),
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.fromLTRB(20, 5, 0, 0),
                    width: (MediaQuery.of(context).size.width - 50) * 0.5,
                    child: Text(
                      _getWeightNum(GlobalData.nutrition.weight.toInt()),
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        color: AppColors.textColor,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.fromLTRB(0, 5, 20, 0),
                    width: (MediaQuery.of(context).size.width - 50) * 0.5,
                    child: Text(
                      _getWeightNum(GlobalData.nutrition.goalWeight),
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        color: AppColors.textColor,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.fromLTRB(20, 15, 0, 0),
                    width: (MediaQuery.of(context).size.width - 50) * 0.5,
                    child: DataLabelCol(
                        "Daily calories",
                        (calories == 0 ? "-" : calories.toString() + " cal"),
                        (MediaQuery.of(context).size.width - 70) * 0.33),
                  ),
                  Container(
                    padding: EdgeInsets.fromLTRB(0, 15, 20, 0),
                    width: (MediaQuery.of(context).size.width - 50) * 0.5,
                    child: DataLabelCol(
                        "BMR",
                        (bmr == 0 ? "-" : bmr.toInt().toString() + " cal"),
                        (MediaQuery.of(context).size.width - 70) * 0.33),
                  ),
                ],
              )
            ],
          )));
    } else {
      return Container();
    }
  }

  getBarWidth() {
    var max = MediaQuery.of(context).size.width - 80;
    var dist = GlobalData.nutrition.weight - GlobalData.nutrition.goalWeight;
    double value = 0;
    if (dist != 0) {
      var multi =
          (GlobalData.nutrition.weight - GlobalData.nutrition.currentWeight) /
              dist;
      value = max * multi;
    }
    return value;
  }

  _getProgressData() {
    List<Widget> items = [];
    if (GlobalData.assessments.length == 0) {
      items.add(EmptyMessage("empty-log", "Health log empty",
          "The health log allows you to\nkeep track of your weight,\nbody fat, and other indicators."));
      items.add(Container(height: 40));
    } else {
      for (var item in assessments) {
        items.add(InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => AssessmentPage(item.id, item)),
              );
            },
            child: ListText(
                HelperCal.getSpecialDateYear(item.date),
                "Weight: " +
                    (item.weight == 0 ? '-' : _getWeightNum(item.weight)) +
                    "\nBody fat: " +
                    (item.fat == 0
                        ? '-'
                        : item.fat.toStringAsFixed(1) + '%'))));
      }
    }
    return Column(
      children: items,
    );
  }

  _getWeightNum(weight) {
    var label = weight.toStringAsFixed(1) + ' kg';
    if (GlobalUser.lbs) {
      label = (weight * GlobalUI.lbsUp).toStringAsFixed(1) + ' lbs';
    }
    return label;
  }

  _getHabits() {
    List<Widget> items = [];
    if (GlobalData.habits.length > 0 && GlobalData.space.showHabits) {
      items.add(SubtitleLabel("Habit Tracker"));
      for (var item in GlobalData.habits) {
        if (item.end.isAfter(DateTime.now())) {
          items.add(InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => HabitPage(item.id, item)),
                );
              },
              child: ListDefault(
                  item.name,
                  item.amount.toString() +
                      " " +
                      item.unit +
                      " per " +
                      (item.interval == 1 ? "day" : "week") +
                      "\nStarted " +
                      HelperCal.getSpecialDateYear(item.start),
                  "Tap to view details",
                  _getHabitCompliance(item, 'color'),
                  _getHabitCompliance(item, 'number') + "%",
                  true)));
        }
      }
      items.add(SubtitleLabel("Health Log"));
    }
    return Column(
      children: items,
    );
  }

  _getHabitCompliance(item, type) {
    var diff = DateTime.now().difference(item.start).inDays + 1;
    double per = 0;
    var color = "-red";
    if (diff != 0) {
      var good = 0;
      for (var i = 0; i < diff; i++) {
        var dlabel = GlobalUI.date.format(item.start.add(Duration(days: i)));
        for (var d in item.days) {
          if (d.contains(dlabel) && d.contains("||1||")) {
            good++;
          }
        }
      }
      per = good / diff;
    }
    if (type == "number") {
      return ((per * 100).round()).toStringAsFixed(0);
    } else {
      if (per > 0.29 && per < 0.80) {
        color = "-yellow";
      } else if (per > 0.79) {
        color = "-vividgreen";
      }
      return color;
    }
  }

  _getPreferences() {
    if (GlobalData.space.nutritionId != "" &&
        GlobalData.space.nutritionStatus == "active") {
      return (BtnTertiary(
          label: "Nutrition preferences", clickFn: tapPreferences));
    } else {
      return Container();
    }
  }

  _getShopping() {
    if (shopping.id == "") {
      return (Column(children: [
        _getShoppingNav(),
        EmptyMessage("empty-nutrition", "No shopping list",
            "There is no shopping list\nfor the selected week")
      ]));
    } else {
      return (Column(children: [
        _getShoppingNav(),
        Container(
            height: MediaQuery.of(context).size.height - 285,
            child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(20, 0, 20, 40),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: _assembleList()))),
        Container(
            height: 50,
            padding: EdgeInsets.all(10),
            child: Text(
              "Check the items you already bought so you\nkeep track of them and don't buy them twice",
              textAlign: TextAlign.left,
              style: TextStyle(
                color: AppColors.textColor,
                fontSize: 12,
              ),
            ))
      ]));
    }
  }

  _assembleList() {
    List<Widget> items = [];
    for (var item in GlobalUI.shopping) {
      List<Widget> items2 = [];
      int count = 0;
      items2.add(SubtitleLabel(item.name));
      for (var li in shopping.items) {
        if (li.cat == item.id) {
          items2.add(InkWell(
              onTap: () {
                tapCheck(li.id, li.checked);
              },
              child: ListShopping(
                  li.name,
                  getKind(li) + li.amount.toStringAsFixed(1) + ' ' + li.unit,
                  item.image,
                  li.checked)));
        }
      }
      if (items2.length > 1) {
        for (var it in items2) {
          items.add(it);
        }
      }
    }
    return items;
  }

  getKind(item) {
    var label = '';
    if (item.kind != null && item.kind != '') {
      label = item.kind + ' - ';
    }
    return label;
  }

  _getShoppingNav() {
    return (Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        InkWell(
            onTap: () {
              tapListNav(0);
            },
            child: Container(
              alignment: Alignment.center,
              width: MediaQuery.of(context).size.width / 2,
              height: 40,
              child: Text(
                "This week",
                textAlign: TextAlign.left,
                style: TextStyle(
                  color: (shopTab == 0
                      ? AppColors.textColor
                      : AppColors.textColor.withAlpha(60)),
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
            )),
        InkWell(
            onTap: () {
              tapListNav(1);
            },
            child: Container(
              alignment: Alignment.center,
              width: MediaQuery.of(context).size.width / 2,
              height: 40,
              child: Text(
                "Next week",
                textAlign: TextAlign.left,
                style: TextStyle(
                  color: (shopTab == 1
                      ? AppColors.textColor
                      : AppColors.textColor.withAlpha(60)),
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
            )),
      ],
    ));
  }

  tapCheck(id, check) {
    var checked = true;
    if (check) {
      checked = false;
    }
    GraphQLClient client = GraphQLClient(
      cache: GraphQLCache(),
      link: Config.link,
    );
    client.mutate(
      MutationOptions(
          document: gql(mutateChecked(id, checked)),
          onCompleted: (dynamic resultData) {
            if (resultData["update_list_items_by_pk"]["checked"] != checked) {
              for (var item in shopping.items) {
                if (item.id == id) {
                  item.checked =
                      resultData["update_list_items_by_pk"]["checked"];
                }
              }
              if (shopTab == 0) {
                GlobalData.shoppingThis = shopping;
              } else {
                GlobalData.shoppingNext = shopping;
              }
              setState(() {
                shopTab = shopTab;
              });
            }
          }),
    );
    for (var item in shopping.items) {
      if (item.id == id) {
        item.checked = checked;
      }
    }
    if (shopTab == 0) {
      GlobalData.shoppingThis = shopping;
    } else {
      GlobalData.shoppingNext = shopping;
    }
    setState(() {
      shopTab = shopTab;
    });
  }

  tapListNav(num) {
    if (num == 0) {
      setState(() {
        shopping = GlobalData.shoppingThis;
        shopTab = num;
      });
    } else {
      setState(() {
        shopping = GlobalData.shoppingNext;
        shopTab = num;
      });
    }
  }

  tapNewLog() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => NewAssessmentPage("")),
    );
  }

  tapPreferences() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => NutritionPage()),
    );
  }

  // Meals related

  getMealName(id, gluten) {
    var label = 'Meal';
    for (var item in GlobalData.nutritionRecipes) {
      if (item.id == id) {
        label = item.name;
        if (GlobalData.nutrition.gluten && gluten) {
          label += " (G)";
        }
      }
    }
    return label;
  }

  getMealTime(id) {
    var label = '';
    for (var item in GlobalData.nutritionRecipes) {
      if (item.id == id) {
        label = " - " + item.time.toString() + " min";
      }
    }
    return label;
  }

  getMealImage(id) {
    var label = '';
    var image = '';
    for (var item in GlobalData.nutritionRecipes) {
      if (item.id == id) {
        var base = "https://backtomybody-dev.s3.amazonaws.com/recipes/photos/";
        var num = "";
        for (var i = 0; i < (9 - id.length); i++) {
          num += "0";
        }
        num += id;
        label = base +
            num.substring(0, 3) +
            "/" +
            num.substring(3, 6) +
            "/" +
            num.substring(6, 9) +
            "/medium/" +
            item.image;
      }
    }
    return label;
  }

  getMealLike(id) {
    var label = -1;
    for (var item in likes) {
      if (item.recipe == id) {
        label = item.rating;
      }
    }
    return label;
  }

  tapListMeals(type) {
    var dy = day;
    if (type == 'next' && day > 0) {
      dy -= 1;
      setState(() {
        day = dy;
      });
      updateData();
    } else if (type == 'prev' && day < days.length - 1) {
      dy += 1;
      setState(() {
        day = dy;
      });
      updateData();
    }
  }

  _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
        context: context,
        initialDate: days[day].date,
        firstDate: days[days.length - 1].date,
        lastDate: days[0].date);
    if (picked != null) {
      var dy = 0;
      for (var i = 0; i < days.length; i++) {
        if (days[i].date == picked) {
          dy = i;
        }
      }
      setState(() {
        day = dy;
      });
      updateData();
    }
  }

  getRecipe(id) {
    for (var item in GlobalData.nutritionRecipes) {
      if (item.id == id) {
        return item;
      }
    }
  }
}
