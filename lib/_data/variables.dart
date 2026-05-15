import 'package:intl/intl.dart';
import 'package:ptmate_client/_data/models.dart';


class GlobalUser {

  static String uid = "";
  static String name = "";
  static String email = "";
  static String phone = "";
  static String birth = "";
  static String goal = "";
  static String image = "";
  static int height = 0;
  static int spaces = 0;
  static bool lbs = false;
  static String country = "au";
  static String ecName = "";
  static String ecPhone = "";
  static int ecType = 99;
  static bool reminder = true;
  static String token = "";
  static String avatar = "";

}


class GlobalData {

  static ModelSpace space = ModelSpace("", "", "", "", "", "", "", "", "", "", ["","","","",""], [], [], false, false, true, false, "", "", 0, 0, false, false, "default", "", [], false, "", 24, "", [], false, false, "au", false, "", false, true, false, "", "", false, true, "", 0, 0, false, [], []);
  static ModelChat chat = ModelChat("", "", "", [], [], []);
  static List<ModelSpace> spaces = [];
  static List<ModelSession> training = [];
  static List<ModelSession> sessions = [];
  static List<ModelSession> archive = [];
  static List<ModelSession> events = [];
  static List<ModelProgram> programs = [];
  static List<ModelPlan> plans = [];
  static List<ModelPlan> plansSpace = [];
  static List<ModelProduct> products = [];
  static List<ModelProduct> productsAll = [];
  static List<ModelPayment> payments = [];
  static List<ModelInvoice> invoices = [];
  static List<ModelBest> best = [];
  static List<ModelClient> clients = [];
  static List<ModelPack> packs = [];
  static List<ModelDebit> debits = [];
  static List<ModelChat> chats = [];
  static List<ModelChat> chatsStaff = [];
  static List<ModelLog> logs = [];
  static List<ModelLog> logs2 = [];
  static List<ModelSpace> allspaces = [];
  static List<ModelClient> trainerClients = [];
  static List<ModelClientGroup> groups = [];
  static List<ModelClientGroup> allGroups = [];
  static List<ModelAssessment> assessments = [];
  static List<ModelConnect> connect = [];
  static List<ModelMovement> movements = [];
  static List<ModelPost> community = [];
  static ModelNutrition nutrition = ModelNutrition();
  static List<ModelNutritionDay> nutritionDays = [];
  static List<ModelNutritionMeal> nutritionMeals = [];
  static List<ModelNutritionRecipe> nutritionRecipes = [];
  static List<ModelNutritionLikes> nutritionLikes = [];
  static ModelNutritionList shoppingThis = ModelNutritionList("", DateTime.now(), []);
  static ModelNutritionList shoppingNext = ModelNutritionList("", DateTime.now(), []);
  static List<ModelClientChat> allStaff = [];
  static List<ModelRecurring> recurring = [];
  static List<ModelHabit> habits = [];
  static List<ModelDocument> documents = [];
  static List<ModelNote> notes = [];
  static List<ModelLocation> locations = [];
  static List<ModelLocation> allLocations = [];
  static List<ModelSchedule> schedule = [];
}


class GlobalUI {

  static DateFormat date = DateFormat("dd/MM/yyyy");
  static DateFormat dateTime = DateFormat("dd/MM/yyyy HH:mm");
  static DateFormat dateFull = DateFormat("d MMMM yyyy");
  static bool dark = false;
  static bool isLogsEnabled = false;
  static List<String> notification = ["", "", ""];
  static double lbsUp = 2.2046;
  static double lbsDown = 1/2.2046;
  static String appver = "1.0.0";
  static String token = "";
  static String mobile = "";
  static String currency = "aud";
  static String curSym = "\$";
  static String spaceToken = "";
  static bool isSignup = false;
  static String location = "";
  static bool locationsAll = false;
  static List emailImages = [];

  static List<String> cats = [
    "Monostructural",
    "Strength - Isolated",
    "Strength - Compound",
    "Mobility/Stretching",
    "Warm up/Activation",
    "Cool down",
    "Metabolic Conditioning",
    "Workout",
    "Stamina builder",
    "Skill",
    "Strength - Stamina",
    "Stabilisation",
    "Accessories",
  ];


  static List<int> exToolsWeight = [1, 2, 3, 4, 5, 8, 10, 12, 14, 24, 25, 26];
  

  static List<String> titles = [
    "AMRAP",
    "EMOM",
    "Intervals",
    "Tabata",
    "No time",
    "For time"
  ];

  static List<String> ecTypes = [
    "Spouse",
    "Family",
    "Friend"
  ];

  static List<String> meals = [
    "Breakfast",
    "Morning snack",
    "Lunch",
    "Afternoon snack",
    "Dinner",
    "Dessert",
    "Evening snack",
  ];

  static List<ModelNutritionCat> shopping = [
    ModelNutritionCat('tin', 'Canned Goods', 'assets/images/nutrition/nutrition-tin.svg'),
    ModelNutritionCat('dairy', 'Dairy Produce', 'assets/images/nutrition/nutrition-dairy.svg'),
    ModelNutritionCat('deli', 'Deli Items', 'assets/images/nutrition/nutrition-deli.svg'),
    ModelNutritionCat('frozen', 'Frozen Food', 'assets/images/nutrition/nutrition-frozen.svg'),
    ModelNutritionCat('fruit', 'Fruit', 'assets/images/nutrition/nutrition-fruit.svg'),
    ModelNutritionCat('grains', 'Grains', 'assets/images/nutrition/nutrition-grains.svg'),
    ModelNutritionCat('meat', 'Meat', 'assets/images/nutrition/nutrition-meat.svg'),
    ModelNutritionCat('nut', 'Nuts', 'assets/images/nutrition/nutrition-nut.svg'),
    ModelNutritionCat('pantry', 'Pantry Goods', 'assets/images/nutrition/nutrition-pantry.svg'),
    ModelNutritionCat('seafood', 'Seafood', 'assets/images/nutrition/nutrition-seafood.svg'),
    ModelNutritionCat('veg', 'Vegetables', 'assets/images/nutrition/nutrition-veg.svg'),
  ];

  static List gradients = ["", "-vividgreen", "-orange", "-purple"];
  static List gradients0 = ["", "-vividgreen", "-orange", "-purple"]; //default
  static List gradients1 = ["-blue", "-vividgreen", "-orange", "-purple"]; //blue
  static List gradients2 = ["-blue", "-vividgreen", "-orange", "-purple"]; //darkblue
  static List gradients3 = ["-vividblue", "-vividgreen", "-yellow", "-orange"]; //vividblue
  static List gradients4 = ["-green", "", "-orange", "-purple"]; //green
  static List gradients5 = ["-darkgreen", "-red", "-orange", "-purple"]; //darkgreen
  static List gradients6 = ["-vividgreen", "", "-purple", "-orange"]; //vividgreen
  static List gradients7 = ["-yellow", "", "-vividgreen", "-red"]; //yellow
  static List gradients8 = ["-orange", "-vividgreen", "", "-green"]; //orange
  static List gradients9 = ["-red", "-purple", "-vividgreen", ""]; //red
  static List gradients10 = ["-purple", "-red", "", "-orange"]; //purple
  static List gradients11 = ["-pink", "-purple", "", "-vividgreen"]; //pink
  static List gradients12 = ["-brown", "-orange", "", "-vividgreen"]; //brown
  static List gradients13 = ["-red2", "-purple", "-vividgreen", ""]; //red2
  static List gradients14 = ["-pink2", "-purple", "", "-vividgreen"]; //pink2
  static List gradients15 = ["-lightblue", "-vividgreen", "-yellow", "-orange"]; //lightblue
  static List gradients16 = ["-purple2", "-red", "", "-orange"]; //purple2
  static List gradients17 = ["-emeraldgreen", "-red", "-orange", "-purple"]; //emeraldgreen

  static List avatars = [
    "animal1", "animal2", "animal3", "animal4", "animal5", "animal6", "animal7", "animal8", "animal9", "animal10", "animal11", "animal12", "animal13", "animal14", "animal15", "animal16", "animal17", "animal18", "animal19", "animal20",
    "nature1", "nature2", "nature3", "nature4", "nature5", "nature6", "nature7", "nature8", "nature9", "nature10", "nature11", "nature12", "nature13", "nature14", "nature15", "nature16", "nature17", "nature18", "nature19", "nature20",
    "plant1", "plant2", "plant3", "plant4", "plant5", "plant6", "plant7", "plant8", "plant9", "plant10", "plant11", "plant12", "plant13", "plant14", "plant15", "plant16", "plant17", "plant18", "plant19", "plant20",
    "sky1", "sky2", "sky3", "sky4", "sky5", "sky6", "sky7", "sky8", "sky9", "sky10", "sky11", "sky12", "sky13", "sky14", "sky15", "sky16", "sky17", "sky18", "sky19", "sky20",
    "vehicle1", "vehicle2", "vehicle3", "vehicle4", "vehicle5", "vehicle6", "vehicle7", "vehicle8", "vehicle9", "vehicle10", "vehicle11", "vehicle12", "vehicle13", "vehicle14", "vehicle15", "vehicle16", "vehicle17", "vehicle18", "vehicle19", "vehicle20"
  ];

  static List subsPro = ["price_1NV8IcAd6uNQtfqaM6TkUcLP", "price_1NlUnTAd6uNQtfqaccbmNsAb", "price_1R3tZpAd6uNQtfqasqvRC3cD", "price_1R3uPQAd6uNQtfqazp8HJsk0"];
  static List subsBus = ["price_1OOCAEAd6uNQtfqaqhBopmgh", "price_1OOCCzAd6uNQtfqalqT5jeD6", "price_1R3uQLAd6uNQtfqauEaaS7Sp", "price_1R3uRCAd6uNQtfqaVh5uxPjZ", "price_1R3uS7Ad6uNQtfqamRID4K0d", "price_1R3uT2Ad6uNQtfqa2w2bk3Wb"];

}