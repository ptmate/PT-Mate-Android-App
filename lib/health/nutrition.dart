import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'package:flutter_svg/svg.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:ptmate_client/_data/client.dart';
import 'package:ptmate_client/_data/graphql.dart';
import 'package:ptmate_client/_data/models.dart';
import 'package:ptmate_client/_data/variables.dart';
import 'package:ptmate_client/_data/sender.dart';
import 'package:ptmate_client/components/titleback.dart';
import 'package:ptmate_client/components/toggle.dart';
import 'package:ptmate_client/components/button-primary.dart';
import 'package:ptmate_client/health/index.dart';
import 'package:ptmate_client/main.dart';
import 'package:ptmate_client/components/subtitle.dart';


class NutritionPage extends StatefulWidget {
  const NutritionPage();

  static _NutritionPageState appState = _NutritionPageState();
  @override
  _NutritionPageState createState(){
    return NutritionPage.appState = new _NutritionPageState();
  }
}


class _NutritionPageState extends State<NutritionPage> {


  final _scaffoldKey = GlobalKey<ScaffoldState>();
  TextEditingController _field1 = TextEditingController();
  TextEditingController _fieldGoal = TextEditingController();
  TextEditingController _fieldPeople = TextEditingController();
  TextEditingController _fieldVeg = TextEditingController();
  TextEditingController _fieldHeight = TextEditingController();
  TextEditingController _fieldBirth = TextEditingController();
  TextEditingController _fieldCurrent = TextEditingController();
  DateTime bstring = GlobalUI.date.parse(GlobalUser.birth);
  int vegValue = GlobalData.nutrition.vegetarian;
  int cheatValue = GlobalData.nutrition.cheat;
  int sexValue = 0;
  int trainValue = GlobalData.nutrition.activity;
  List<bool> values = [GlobalData.nutrition.leftover, GlobalData.nutrition.dessert, GlobalData.nutrition.snack, GlobalData.nutrition.gluten, GlobalData.nutrition.coldbreakfast];
  List<bool> valuesProtein = [GlobalData.nutrition.redmeat, GlobalData.nutrition.pork, GlobalData.nutrition.chicken, GlobalData.nutrition.turkey, GlobalData.nutrition.fish, GlobalData.nutrition.shellfish];
  List<bool> valuesVegan = [GlobalData.nutrition.dessert, GlobalData.nutrition.nuts, GlobalData.nutrition.eggs];
  bool valuePlan = false;
  List<bool> valuesSnack = [GlobalData.nutrition.snackMorning, GlobalData.nutrition.snackAfternoon, GlobalData.nutrition.snackEvening];
  

  String mutatePrefs(id, sex, height, birth, gluten, dinner, goal, current, weight, leftover, cheat, dessert, snack, vegetarian, vegmeals, cold, meat, pork, chicken, turkey, fish, shellfish, lactose, nuts, eggs, activity, plan, snack1, snack2, snack3, status) {
    return('''
      mutation updatePreferences {
        update_users_by_pk(pk_columns: {id: $id},
        _set: {
            sex: $sex,
            height: $height,
            date_of_birth: "$birth",
            gluten: $gluten,
            dinner_serves: $dinner,
            goal_weight: $goal,
            u_goal_weight: $goal,
            current_weight: $current,
            u_current_weight: $current,
            weight: $weight,
            u_weight: $weight,
            leftover_lunches: $leftover,
            cheat_meal: $cheat,
            dessert: $dessert,
            snack_evening: $snack,
            snack_morning: true,
            snack_afternoon: true,
            weight_unit: "kg",
            alt_vol_in_recipes: false,
            v_type: $vegetarian,
            v_meals: $vegmeals,
            cold_breakfast: $cold,
            
            red_meat: $meat,
            pork: $pork,
            chicken: $chicken,
            turkey: $turkey,
            fish: $fish,
            shellfish: $shellfish,
            lactose: $lactose,
            nuts: $nuts,
            egg: $eggs,
            
            activity_level: $activity,
            form_status: $status,

            plan_type: $plan,
            snack_morning_protein: $snack1,
            snack_afternoon_protein: $snack2,
            snack_evening_protein: $snack3,
        })
    {
        id
        gluten
        dinner_serves
    }
      }
    ''');
  }


  String mutatePlan(id) {
    return('''
      mutation createPlan {
        createPlan(userId: $id) {
          response
        }
      }
    ''');
  }


  String mutateCreate(id, date, time, weight) {
    return('''
      mutation createWeight {
        insert_weights_one(object: {created_at: "$time", date_recorded: "$date", updated_at: "$time", u_weight: $weight, user_id: $id, weight: $weight}) {
          id
        }
      }
    ''');
  }


  @override
  void initState() {
    super.initState();

    var sex = 0;
    if(GlobalData.nutrition.sex == "f") {
      sex = 1;
    }
    if(GlobalData.nutrition.sex != "f" && GlobalData.nutrition.sex != "m") {
      sex = 2;
    }
    var plan = false;
    if(GlobalData.nutrition.planType == 1) {
      plan = true;
    }
    var hgt = GlobalUser.height.toString();
    if(GlobalUser.lbs) {
      var b = GlobalUser.height/2.54;
      var h1 = (b/12).toInt();
      var h2 = (b-(h1*12)).toStringAsFixed(0);
      hgt = h1.toString()+"."+h2;
    }
    setState(() {
      sexValue = sex;
      valuePlan = plan;
      _fieldGoal.text = GlobalData.nutrition.goalWeight.toString();
      if(GlobalUser.lbs) {
        _fieldGoal.text = (GlobalData.nutrition.goalWeight*GlobalUI.lbsUp).toStringAsFixed(1);
      }
      _fieldPeople.text = GlobalData.nutrition.people.toString();
      _fieldVeg.text = GlobalData.nutrition.vegMeals.toString();
      _fieldHeight.text = hgt;
      _fieldBirth.text = GlobalUI.dateFull.format(bstring);
    });
  }


  _setVeg(value) {
    if(valuePlan) {
      AlertDialog alert = AlertDialog(
      title: Text("Please note"),
      content: Text("You can't have a low carb plan with vegetarian or vegan options selected."),
      actions: [
        TextButton(
          child: Text("OK"),
          onPressed: () { Navigator.of(context).pop(); },
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
    setState(() {
      vegValue = value;
      valuePlan = false;
    });
  }


  _setCheat(value) {
    setState(() {
      cheatValue = value;
    });
  }


  _setPlan() {
    var tmp = valuePlan;
    if(vegValue > 0) {
      AlertDialog alert = AlertDialog(
      title: Text("Please note"),
      content: Text("You can't select vegetarian or vegan with a low carb plan."),
      actions: [
        TextButton(
          child: Text("OK"),
          onPressed: () { Navigator.of(context).pop(); },
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
    setState(() {
      valuePlan = !tmp;
      vegValue = 0;
    });
  }


  _setValues(num) {
    var tmp = values;
    tmp[num] = !tmp[num];
    setState(() {
      values = tmp;
    });
  }


  _setValuesProtein(num) {
    var tmp = valuesProtein;
    tmp[num] = !tmp[num];
    setState(() {
      valuesProtein = tmp;
    });
  }


  _setValuesVegan(num) {
    var tmp = valuesVegan;
    tmp[num] = !tmp[num];
    setState(() {
      valuesVegan = tmp;
    });
  }


  _setValuesSnack(num) {
    var tmp = valuesSnack;
    tmp[num] = !tmp[num];
    setState(() {
      valuesSnack = tmp;
    });
  }


  _setSex(value) {
    setState(() {
      sexValue = value;
    });
  }


  _setTraining(value) {
    setState(() {
      trainValue = value;
    });
  }


  _tapUpdate() {
    var passed = true;
    var message = "";
    if(_fieldGoal.text == "") {
      passed = false;
      message += "Goal weight\n";
    }
    if(_fieldPeople.text == "") {
      passed = false;
      message += "Dinner serves\n";
    }
    if(_fieldHeight.text == "") {
      passed = false;
      message += "Your height\n";
    }
    if(_fieldBirth.text == "") {
      passed = false;
      message += "Your date of birth\n";
    }
    if(vegValue == 1 && _fieldBirth.text == "") {
      passed = false;
      message += "Number of vegetarian dinners\n";
    }
    if(passed) {
      if(GlobalData.space.nutritionStatus == "registered") {
        _finishOnboarding();
      } else {
        _updateNutrition();
      }
    } else {
      AlertDialog alert = AlertDialog(
      title: Text("Please review the following"),
      content: Text(message),
      actions: [
        TextButton(
          child: Text("OK"),
          onPressed: () { Navigator.of(context).pop(); },
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
  }


  _finishOnboarding() {
    var sex = "m";
    if(sexValue == 1) {
      sex = "f";
    } else if(sexValue == 2) {
      sex = "o";
    }
    var plan = 0;
    if(valuePlan) {
      plan = 1;
    }
    var vegmeals = 0;
    if(vegValue == 1) {
      vegmeals = int.parse(_fieldVeg.text);
    }

    var tf = DateFormat('yyyy-MM-ddTHH:mm:ss');
    var time = tf.format(DateTime.now());

    //var date = DateFormat("dd/MM/yyyy");
    DateTime birth2 = GlobalUI.dateFull.parse(_fieldBirth.text);
    var tf2 = DateFormat('yyyy-MM-dd');
    var birth = tf2.format(birth2);

    var cweight = _fieldCurrent.text;
    if(GlobalUser.lbs) {
      cweight = (double.parse(_fieldCurrent.text)/GlobalUI.lbsUp).toStringAsFixed(2);
    }
    var gweight = _fieldGoal.text;
    var height = _fieldHeight.text;
    if(GlobalUser.lbs) {
      gweight = (double.parse(_fieldGoal.text)/GlobalUI.lbsUp).toStringAsFixed(2);
      //height = (double.parse(_fieldHeight.text)*30.48).toStringAsFixed(0);
      var ar = _fieldHeight.text.split(".");
      var h1 = double.parse(ar[0])*12.0*2.54;
      var h2 = 0.0;
      if(ar.length > 1) {
        h2 = double.parse(ar[1])*2.54;
      }
      height = (h1+h2).toStringAsFixed(0);
    }

    GraphQLClient client = GraphQLClient(
      cache: GraphQLCache(),
      link: Config.link,
    );
    client.mutate(
      MutationOptions(
        document: gql(mutatePrefs(int.parse(GlobalData.space.nutritionId), sex, int.parse(height), birth, values[3], int.parse(_fieldPeople.text), int.parse(gweight), double.parse(cweight), int.parse(cweight), values[0], cheatValue, values[1], values[2], vegValue, vegmeals, values[4], valuesProtein[0], valuesProtein[1], valuesProtein[2], valuesProtein[3], valuesProtein[4], valuesProtein[5], valuesVegan[0], valuesVegan[1], valuesVegan[2], trainValue, plan, valuesSnack[0], valuesSnack[1], valuesSnack[2], "created")),
        onCompleted: (dynamic resultData) {
          _createPlan('new');
        }
      ),
    );

    var tf3 = DateFormat('dd/MM/yyyy HH:mm');
    var date2= tf3.format(DateTime.now());

    var key = FirebaseSender.createAssessmentId();
    client.mutate(
      MutationOptions(
        document: gql(mutateCreate(int.parse(GlobalData.space.nutritionId), DateTime.now(), time, double.parse(_fieldCurrent.text))),
        onCompleted: (dynamic resultData) {
          FirebaseSender.updateAssessment(key, double.parse(_fieldCurrent.text), 0, 0, "", 0, 0, 0, 0, 0, 0, 0, 0, "", resultData["insert_weights_one"]["id"], date2, "", "", "");
        }
      ),
    );
  }


  _updateNutrition() {
    var sex = "m";
    if(sexValue == 1) {
      sex = "f";
    } else if(sexValue == 2) {
      sex = "o";
    }
    var plan = 0;
    if(valuePlan) {
      plan = 1;
    }
    var vegmeals = 0;
    if(vegValue == 1) {
      vegmeals = int.parse(_fieldVeg.text);
    }
    var gweight = _fieldGoal.text;
    var height = _fieldHeight.text;
    if(GlobalUser.lbs) {
      gweight = (double.parse(_fieldGoal.text)/GlobalUI.lbsUp).toStringAsFixed(2);
      //height = (double.parse(_fieldHeight.text)*30.48).toStringAsFixed(0);
      var ar = _fieldHeight.text.split(".");
      var h1 = double.parse(ar[0])*12.0*2.54;
      var h2 = 0.0;
      if(ar.length > 1) {
        h2 = double.parse(ar[1])*2.54;
      }
      height = (h1+h2).toStringAsFixed(0);
    }
    //var date = DateFormat("dd/MM/yyyy");
    DateTime birth2 = GlobalUI.dateFull.parse(_fieldBirth.text);
    var tf2 = DateFormat('yyyy-MM-dd');
    var birth = tf2.format(birth2);

    GraphQLClient client = GraphQLClient(
      cache: GraphQLCache(),
      link: Config.link,
    );
    client.mutate(
      MutationOptions(
        document: gql(mutatePrefs(int.parse(GlobalData.space.nutritionId), sex, int.parse(height), birth, values[3], int.parse(_fieldPeople.text), double.parse(gweight), GlobalData.nutrition.currentWeight, GlobalData.nutrition.weight, values[0], cheatValue, values[1], values[2], vegValue, vegmeals, values[4], valuesProtein[0], valuesProtein[1], valuesProtein[2], valuesProtein[3], valuesProtein[4], valuesProtein[5], valuesVegan[0], valuesVegan[1], valuesVegan[2], trainValue, plan, valuesSnack[0], valuesSnack[1], valuesSnack[2], GlobalData.space.nutritionStatus)),
        onCompleted: (dynamic resultData) {
          _createPlan('update');
          
        }
      ),
    );
    Future.delayed(const Duration(milliseconds: 2000), () {
      GQLConnector.getNutrition(id: GlobalData.space.nutritionId);
    });
  }


  _createPlan(type) {
    GraphQLClient client = GraphQLClient(
      cache: GraphQLCache(),
      link: Config.link,
    );
    client.mutate(
      MutationOptions(
        document: gql(mutatePlan(int.parse(GlobalData.space.nutritionId))),
        onCompleted: (dynamic resultData) {
          //check if new or update
          if(type == 'new') {
            GlobalData.space.nutritionStatus = "created";
            Future.delayed(const Duration(milliseconds: 1300), () {
              HealthPage.appState.showAlertNew();
              HealthPage.appState.checkStatus();
            });
            _showConfirmation('Preferences successfully set');
          } else {
            Future.delayed(const Duration(milliseconds: 1300), () {
              HealthPage.appState.showAlertUpdate();
            });
            _showConfirmation('Preferences successfully updated');
          }
        }
      ),
    );
  }


  _showConfirmation(message) {
    GQLConnector.getNutrition();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      duration: Duration(seconds: 2),
      backgroundColor: AppColors.GreenColor,
    ));

    Future.delayed(const Duration(milliseconds: 1000), () {
      Navigator.pop(context);
    });
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
              child: TitleLabelBack(('Nutrition')),
            ),
            Container(
              width: MediaQuery.of(context).size.width,
              padding: EdgeInsets.fromLTRB(70, 0, 20, 20),
              child: Text(
                GlobalData.space.nutritionStatus == 'active' ? 'Update your preferences' : 'Set your preferences',
                textAlign: TextAlign.left,
                style: TextStyle(
                  color: AppColors.textColor,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(20, 30, 20, 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [

                    Container (
                      padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                      margin: EdgeInsets.fromLTRB(0, 0, 0, 30),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5.0),
                        color: AppColors.fieldColor,
                      ),
                      child: TextField(
                        keyboardType: TextInputType.number,
                        controller: _fieldGoal,
                        style: TextStyle(color: AppColors.textColor),
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          labelText: 'Your goal weight',
                          suffixText: (GlobalUser.lbs ? 'lbs' : 'kg'),
                          suffixStyle: TextStyle(color: AppColors.textColor, fontWeight: FontWeight.w700),
                          labelStyle: TextStyle(color: AppColors.textColor),
                        ),
                        onChanged: (text) {
                          //_updateSec(text);
                        },
                      )
                    ),

                    SubtitleLabel('Dietary'),

                    Container (
                      padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
                      margin: EdgeInsets.fromLTRB(0, 20, 0, 30),
                      width: double.maxFinite,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5.0),
                        color: AppColors.fieldColor,
                      ),
                      child: DropdownButton(
                        underline: SizedBox(),
                        isExpanded: true,
                        value: vegValue,
                        dropdownColor: AppColors.boxColor,
                        onChanged: (value) {
                          _setVeg(value);
                        },
                        items: [
                          DropdownMenuItem(
                            value: 0,
                            child: Text(
                              'Not a vegetarian',
                              style: TextStyle(
                                color: AppColors.textColor,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          DropdownMenuItem(
                            value: 1,
                            child: Text(
                              'Sometimes vegetarian',
                              style: TextStyle(
                                color: AppColors.textColor,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          DropdownMenuItem(
                            value: 2,
                            child: Text(
                              'Full vegetarian',
                              style: TextStyle(
                                color: AppColors.textColor,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          DropdownMenuItem(
                            value: 3,
                            child: Text(
                              'Full vegan',
                              style: TextStyle(
                                color: AppColors.textColor,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ],
                      )
                    ),

                    showVegMeals(),

                    Container (
                      padding: EdgeInsets.fromLTRB(0, 0, 0, 10),
                      alignment: Alignment.topLeft,
                      child: Text(
                        'Low carb plan',
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          color: AppColors.textColor,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      )
                    ),
                    InkWell(
                      onTap: () {
                        _setPlan();
                      },
                      child: Container (
                        padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                        child: DataToggle('I want a low carb meal plan', valuePlan),
                      ),
                    ),

                    Container (
                      padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                      margin: EdgeInsets.fromLTRB(0, 0, 0, 30),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5.0),
                        color: AppColors.fieldColor,
                      ),
                      child: TextField(
                        keyboardType: TextInputType.number,
                        controller: _fieldPeople,
                        style: TextStyle(color: AppColors.textColor),
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          labelText: 'Cooking dinner for how many people?',
                          suffixStyle: TextStyle(color: AppColors.textColor, fontWeight: FontWeight.w700),
                          labelStyle: TextStyle(color: AppColors.textColor),
                        ),
                        onChanged: (text) {
                          //_updateSec(text);
                        },
                      )
                    ),

                    Container (
                      padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
                      margin: EdgeInsets.fromLTRB(0, 0, 0, 30),
                      width: double.maxFinite,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5.0),
                        color: AppColors.fieldColor,
                      ),
                      child: DropdownButton(
                        underline: SizedBox(),
                        isExpanded: true,
                        value: cheatValue,
                        dropdownColor: AppColors.boxColor,
                        onChanged: (value) {
                          _setCheat(value);
                        },
                        items: [
                          DropdownMenuItem(
                            value: 0,
                            child: Text(
                              'No cheat meal',
                              style: TextStyle(
                                color: AppColors.textColor,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          DropdownMenuItem(
                            value: 2,
                            child: Text(
                              'Cheat meal on Monday',
                              style: TextStyle(
                                color: AppColors.textColor,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          DropdownMenuItem(
                            value: 3,
                            child: Text(
                              'Cheat meal on Tuesday',
                              style: TextStyle(
                                color: AppColors.textColor,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          DropdownMenuItem(
                            value: 4,
                            child: Text(
                              'Cheat meal on Wednesday',
                              style: TextStyle(
                                color: AppColors.textColor,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          DropdownMenuItem(
                            value: 5,
                            child: Text(
                              'Cheat meal on Thursday',
                              style: TextStyle(
                                color: AppColors.textColor,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          DropdownMenuItem(
                            value: 6,
                            child: Text(
                              'Cheat meal on Friday',
                              style: TextStyle(
                                color: AppColors.textColor,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          DropdownMenuItem(
                            value: 7,
                            child: Text(
                              'Cheat meal on Saturday',
                              style: TextStyle(
                                color: AppColors.textColor,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          DropdownMenuItem(
                            value: 1,
                            child: Text(
                              'Cheat meal on Sunday',
                              style: TextStyle(
                                color: AppColors.textColor,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ],
                      )
                    ),

                    Container (
                      padding: EdgeInsets.fromLTRB(0, 0, 0, 10),
                      alignment: Alignment.topLeft,
                      child: Text(
                        'Dinner leftovers',
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          color: AppColors.textColor,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      )
                    ),
                    InkWell(
                      onTap: () {
                        _setValues(0);
                      },
                      child: Container (
                        padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                        child: DataToggle('Create leftovers for lunches', values[0]),
                      ),
                    ),
                    
                    Container (
                      padding: EdgeInsets.fromLTRB(0, 0, 0, 10),
                      alignment: Alignment.topLeft,
                      child: Text(
                        'Daily dessert',
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          color: AppColors.textColor,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      )
                    ),
                    InkWell(
                      onTap: () {
                        _setValues(1);
                      },
                      child: Container (
                        padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                        child: DataToggle('Have a daily dessert', values[1]),
                      ),
                    ),

                    Container (
                      padding: EdgeInsets.fromLTRB(0, 0, 0, 10),
                      alignment: Alignment.topLeft,
                      child: Text(
                        'Evening snack',
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          color: AppColors.textColor,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      )
                    ),
                    InkWell(
                      onTap: () {
                        _setValues(2);
                      },
                      child: Container (
                        padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                        child: DataToggle('Have an evening snack', values[2]),
                      ),
                    ),

                    Container (
                      padding: EdgeInsets.fromLTRB(0, 0, 0, 10),
                      alignment: Alignment.topLeft,
                      child: Text(
                        'Ingredients containing gluten',
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          color: AppColors.textColor,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      )
                    ),
                    InkWell(
                      onTap: () {
                        _setValues(3);
                      },
                      child: Container (
                        padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                        child: DataToggle('Show if ingredients contain gluten', values[3]),
                      ),
                    ),

                    showProtein(),
                    showVegan(),

                    Container (
                      padding: EdgeInsets.fromLTRB(0, 0, 0, 10),
                      alignment: Alignment.topLeft,
                      child: Text(
                        'Protein snacks',
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          color: AppColors.textColor,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      )
                    ),
                    InkWell(
                      onTap: () {
                        _setValuesSnack(0);
                      },
                      child: Container (
                        padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                        child: DataToggle('Morning protein snack', valuesSnack[0]),
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        _setValuesSnack(1);
                      },
                      child: Container (
                        padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                        child: DataToggle('Afternoon protein snack', valuesSnack[1]),
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        _setValuesSnack(2);
                      },
                      child: Container (
                        padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                        child: DataToggle('Evening protein snack', valuesSnack[2]),
                      ),
                    ),

                    Container (
                      padding: EdgeInsets.fromLTRB(0, 0, 0, 10),
                      alignment: Alignment.topLeft,
                      child: Text(
                        'Breakfast',
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          color: AppColors.textColor,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      )
                    ),
                    InkWell(
                      onTap: () {
                        _setValues(4);
                      },
                      child: Container (
                        padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                        child: DataToggle('Only cold/uncooked breakfasts', values[4]),
                      ),
                    ),

                    SubtitleLabel('Your details'),
                    
                    Container (
                      padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                      margin: EdgeInsets.fromLTRB(0, 20, 0, 30),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5.0),
                        color: AppColors.fieldColor,
                      ),
                      child: TextField(
                        keyboardType: TextInputType.name,
                        controller: _fieldHeight,
                        style: TextStyle(color: AppColors.textColor),
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          labelText: 'Your height',
                          suffixText: (GlobalUser.lbs ? "ft" : "cm"),
                          suffixStyle: TextStyle(color: AppColors.textColor, fontWeight: FontWeight.w700),
                          labelStyle: TextStyle(color: AppColors.textColor),
                        ),
                        onChanged: (text) {
                          //_updateSec(text);
                        },
                      )
                    ),

                    Container (
                      padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
                      margin: EdgeInsets.fromLTRB(0, 0, 0, 30),
                      width: double.maxFinite,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5.0),
                        color: AppColors.fieldColor,
                      ),
                      child: DropdownButton(
                        underline: SizedBox(),
                        isExpanded: true,
                        value: sexValue,
                        dropdownColor: AppColors.boxColor,
                        onChanged: (value) {
                          _setSex(value);
                        },
                        items: [
                          DropdownMenuItem(
                            value: 0,
                            child: Text(
                              'Male',
                              style: TextStyle(
                                color: AppColors.textColor,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          DropdownMenuItem(
                            value: 1,
                            child: Text(
                              'Female',
                              style: TextStyle(
                                color: AppColors.textColor,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          DropdownMenuItem(
                            value: 2,
                            child: Text(
                              'Other',
                              style: TextStyle(
                                color: AppColors.textColor,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ],
                      )
                    ),

                    Container (
                      padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                      margin: EdgeInsets.fromLTRB(0, 0, 0, 30),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5.0),
                        color: AppColors.fieldColor,
                      ),
                      child: GestureDetector(
                        onTap: () => _selectDate(context),
                        child: AbsorbPointer(
                          child: TextField(
                            keyboardType: TextInputType.name,
                            controller: _fieldBirth,
                            style: TextStyle(color: AppColors.textColor),
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              labelText: 'Your date of birth',
                              suffixStyle: TextStyle(color: AppColors.textColor, fontWeight: FontWeight.w700),
                              labelStyle: TextStyle(color: AppColors.textColor),
                            ),
                            onChanged: (text) {
                              //_updateSec(text);
                            },
                          )
                        )
                      )
                    ),

                    Container (
                      padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
                      margin: EdgeInsets.fromLTRB(0, 0, 0, 30),
                      width: double.maxFinite,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5.0),
                        color: AppColors.fieldColor,
                      ),
                      child: DropdownButton(
                        underline: SizedBox(),
                        isExpanded: true,
                        value: trainValue,
                        dropdownColor: AppColors.boxColor,
                        onChanged: (value) {
                          _setTraining(value);
                        },
                        items: [
                          DropdownMenuItem(
                            value: 0,
                            child: Text(
                              'Little or no training',
                              style: TextStyle(
                                color: AppColors.textColor,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          DropdownMenuItem(
                            value: 1,
                            child: Text(
                              '1-3 times per week',
                              style: TextStyle(
                                color: AppColors.textColor,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          DropdownMenuItem(
                            value: 2,
                            child: Text(
                              '3-5 times per week',
                              style: TextStyle(
                                color: AppColors.textColor,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          DropdownMenuItem(
                            value: 3,
                            child: Text(
                              '6-7 times per week',
                              style: TextStyle(
                                color: AppColors.textColor,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          DropdownMenuItem(
                            value: 4,
                            child: Text(
                              'More than 7 times per week',
                              style: TextStyle(
                                color: AppColors.textColor,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ],
                      )
                    ),

                    showCurrent(),

                    Container(height: 20),
                    BtnPrimary(label: 'Update preferences', clickFn: () => _tapUpdate(),),
                    
                  ]
                ),
              ),
            ),
          ],
        ),
      ),
      data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
      ),
    );
  }


  showVegMeals() {
    if(vegValue == 1) {
      return (
        Container (
          padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
          margin: EdgeInsets.fromLTRB(0, 0, 0, 30),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5.0),
            color: AppColors.fieldColor,
          ),
          child: TextField(
            keyboardType: TextInputType.number,
            controller: _fieldVeg,
            style: TextStyle(color: AppColors.textColor),
            decoration: InputDecoration(
              border: InputBorder.none,
              labelText: 'Vegetarian dinners each week',
              suffixStyle: TextStyle(color: AppColors.textColor, fontWeight: FontWeight.w700),
              labelStyle: TextStyle(color: AppColors.textColor),
            ),
            onChanged: (text) {
              //_updateSec(text);
            },
          )
        )
      );
    } else {
      return (
        Container()
      );
    }
  }


  showProtein() {
    if(vegValue < 2) {
      return (
        Column(
          children: [
            Container (
              padding: EdgeInsets.fromLTRB(0, 10, 0, 20),
              alignment: Alignment.topLeft,
              child: Text(
                'Proteins you like to AVOID',
                textAlign: TextAlign.left,
                style: TextStyle(
                  color: AppColors.textColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              )
            ),
            InkWell(
              onTap: () {
                _setValuesProtein(0);
              },
              child: Container (
                padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                child: DataToggle('Red meat', valuesProtein[0]),
              ),
            ),
            InkWell(
              onTap: () {
                _setValuesProtein(1);
              },
              child: Container (
                padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                child: DataToggle('Pork', valuesProtein[1]),
              ),
            ),
            InkWell(
              onTap: () {
                _setValuesProtein(2);
              },
              child: Container (
                padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                child: DataToggle('Chicken', valuesProtein[2]),
              ),
            ),
            InkWell(
              onTap: () {
                _setValuesProtein(3);
              },
              child: Container (
                padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                child: DataToggle('Turkey', valuesProtein[3]),
              ),
            ),
            InkWell(
              onTap: () {
                _setValuesProtein(4);
              },
              child: Container (
                padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                child: DataToggle('Fish', valuesProtein[4]),
              ),
            ),
            InkWell(
              onTap: () {
                _setValuesProtein(5);
              },
              child: Container (
                padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                child: DataToggle('Shellfish', valuesProtein[5]),
              ),
            ),
          ]
        )
      );
    } else {
      return (
        Container()
      );
    }
  }


  showVegan() {
    if(vegValue == 3) {
      return Container();
    } else {
      return (
        Column(
          children: [
            Container (
              padding: EdgeInsets.fromLTRB(0, 10, 0, 20),
              alignment: Alignment.topLeft,
              child: Text(
                'Ingredients you like to AVOID',
                textAlign: TextAlign.left,
                style: TextStyle(
                  color: AppColors.textColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              )
            ),
            InkWell(
              onTap: () {
                _setValuesVegan(0);
              },
              child: Container (
                padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                child: DataToggle('Dairy/Lactose', valuesVegan[0]),
              ),
            ),
            InkWell(
              onTap: () {
                _setValuesVegan(1);
              },
              child: Container (
                padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                child: DataToggle('Nuts', valuesVegan[1]),
              ),
            ),
            InkWell(
              onTap: () {
                _setValuesVegan(2);
              },
              child: Container (
                padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                child: DataToggle('Eggs', valuesVegan[2]),
              ),
            ),
          ]
        )
      );
    }
  }


  showCurrent() {
    if(GlobalData.space.nutritionStatus == 'registered') {
      return (
        Container (
          padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
          margin: EdgeInsets.fromLTRB(0, 0, 0, 30),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5.0),
            color: AppColors.fieldColor,
          ),
          child: TextField(
            keyboardType: TextInputType.name,
            controller: _fieldCurrent,
            style: TextStyle(color: AppColors.textColor),
            decoration: InputDecoration(
              border: InputBorder.none,
              labelText: 'Your current weight',
              suffixText: (GlobalUser.lbs ? "lb" : "kg"),
              suffixStyle: TextStyle(color: AppColors.textColor, fontWeight: FontWeight.w700),
              labelStyle: TextStyle(color: AppColors.textColor),
            ),
            onChanged: (text) {
              //_updateSec(text);
            },
          )
        )
      );
    } else {
      return Container();
    }
  }


  _selectDate(BuildContext context) async {
    var date = DateFormat("dd MMMM yyyy");
    final picked = await showDatePicker(
      context: context,
      initialDate: date.parse(_fieldBirth.text),
      firstDate: DateTime(1940, 8),
      lastDate: DateTime.now());
      if (picked != null && picked != DateTime.now()) {
        setState(() {
          _fieldBirth.text = date.format(picked);
        });
      }
    
  }


  _tapDeleteAssessment() {
    
  }

}