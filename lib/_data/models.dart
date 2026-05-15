// Training Space

class ModelSpace {
  String id;
  String name;
  String business;
  String email;
  String phone;
  String image;
  String client;
  String token;
  String goal;
  String stripe;
  List billing;
  List packs;
  List debits;
  bool active;
  bool comments;
  bool showBooked;
  bool allowBookings;
  String nutritionId;
  String nutritionStatus;
  int nutritionStart;
  int nutritionEnd;
  bool community;
  bool communityPost;
  String theme;
  String pin;
  List forms;
  bool showForms;
  String pre;
  int reminder;
  String parent;
  List linked;
  bool restricted;
  bool limitBooking;
  String country;
  bool lbs;
  String customer;
  bool allowRecurring;
  bool chargeSessions;
  bool showHabits;
  String address;
  String invoice;
  bool emailReminder;
  bool clientEmailReminder;
  String welcome;
  int welcomeTime;
  double gst;
  bool enterprise;
  List newLocations;
  List newGroups;

  ModelSpace(
      this.id,
      this.name,
      this.business,
      this.email,
      this.phone,
      this.image,
      this.client,
      this.token,
      this.goal,
      this.stripe,
      this.billing,
      this.packs,
      this.debits,
      this.active,
      this.comments,
      this.showBooked,
      this.allowBookings,
      this.nutritionId,
      this.nutritionStatus,
      this.nutritionStart,
      this.nutritionEnd,
      this.community,
      this.communityPost,
      this.theme,
      this.pin,
      this.forms,
      this.showForms,
      this.pre,
      this.reminder,
      this.parent,
      this.linked,
      this.restricted,
      this.limitBooking,
      this.country,
      this.lbs,
      this.customer,
      this.allowRecurring,
      this.chargeSessions,
      this.showHabits,
      this.address,
      this.invoice,
      this.emailReminder,
      this.clientEmailReminder,
      this.welcome,
      this.welcomeTime,
      this.gst,
      this.enterprise,
      this.newLocations,
      this.newGroups);
}

// Session

class ModelSession {
  String id;
  DateTime date;
  String name;
  int duration;
  List clients;
  List invitees;
  List waiting;
  String trainer;
  String type;
  String link;
  int attendance;
  int max;
  DateTime unlocked;
  DateTime locked;
  bool preview;
  List rating;
  ModelProgram program;
  List comments;
  List groups;
  bool availability;
  String desc;
  String template;
  List memberships;
  List bookings;
  String location;
  String locationName;
  List highfives;
  List noshows;
  String client;

  ModelSession(
    this.id,
    this.date,
    this.name,
    this.duration,
    this.clients,
    this.invitees,
    this.waiting,
    this.trainer,
    this.type,
    this.link,
    this.attendance,
    this.max,
    this.unlocked,
    this.preview,
    this.rating,
    this.comments,
    this.program,
    this.groups,
    this.availability,
    this.locked,
    this.desc,
    this.template,
    this.memberships,
    this.bookings,
    this.location,
    this.locationName,
    this.highfives,
    this.noshows,
    this.client,
  );

  @override
  String toString() {
    return 'ModelSession(id: $id, name: $name, date: $date, trainer: $trainer)';
  }
}

// Day

class ModelDay {
  String day;
  DateTime date;
  String dateString;
  List<ModelSession> sessions;

  ModelDay(this.day, this.date, this.dateString, this.sessions);
}

// Program

class ModelProgram {
  String id;
  String name;
  String desc;
  int time;
  int movements;
  String creator;
  List<ModelBlock> blocks;
  bool benchmark;
  String video;

  ModelProgram(this.id, this.name, this.desc, this.time, this.movements,
      this.creator, this.blocks, this.benchmark, this.video);

  @override
  String toString() {
    return '''
ModelProgram:
  id: $id
  name: $name
  desc: $desc
  time: $time
  movements: $movements
  creator: $creator
  benchmark: $benchmark
  video: $video
  blocks count: ${blocks.length}
  blocks: $blocks
''';
  }
}

// Program Block

class ModelBlock {
  String id;
  int cat;
  String name;
  int type;
  int rounds;
  int cycles;
  bool emom;
  String notes;
  String notesRes;
  int timeRes;
  List timeResGroup;
  List<ModelMovement> movements;
  bool logResults;
  bool simple;
  String notesSimple;
  List valueSimple;
  List amrapSimple;
  List scaledSimple;
  String unitSimple;

  ModelBlock(
      this.id,
      this.cat,
      this.name,
      this.type,
      this.rounds,
      this.emom,
      this.notes,
      this.notesRes,
      this.movements,
      this.logResults,
      this.cycles,
      this.timeRes,
      this.timeResGroup,
      this.simple,
      this.notesSimple,
      this.valueSimple,
      this.amrapSimple,
      this.scaledSimple,
      this.unitSimple);
}

// Movement

class ModelMovement {
  String id;
  String name;
  int type;
  int cat;
  int tool;
  int reps;
  String repsRounds;
  double weight;
  String weightRounds;
  String weightType;
  int work;
  int rest;
  double resWeight;
  int resReps;
  String resWeightGroup;
  String resRepsGroup;
  String resWeightRounds;
  String resRepsRounds;
  String image;
  String desc;
  String video;
  String unit;
  String notes;

  ModelMovement(
      this.id,
      this.name,
      this.type,
      this.cat,
      this.tool,
      this.reps,
      this.weight,
      this.work,
      this.rest,
      this.resWeight,
      this.resReps,
      this.resWeightGroup,
      this.resRepsGroup,
      this.image,
      this.weightType,
      this.repsRounds,
      this.weightRounds,
      this.resRepsRounds,
      this.resWeightRounds,
      this.desc,
      this.video,
      this.unit,
      this.notes);
}

// Training Plan

class ModelPlan {
  String id;
  String name;
  String desc;
  DateTime date;
  String video;
  int sessions;
  String creator;
  List<ModelPlanWeek> weeks;
  List<ModelProgram> programs;
  List sent;

  ModelPlan(this.id, this.name, this.desc, this.date, this.video, this.sessions,
      this.creator, this.weeks, this.programs, this.sent);
}

// Training Plan Week

class ModelPlanWeek {
  String id;
  int number;
  String name;
  String day1;
  String day2;
  String day3;
  String day4;
  String day5;
  String day6;
  String day7;

  ModelPlanWeek(this.id, this.number, this.name, this.day1, this.day2,
      this.day3, this.day4, this.day5, this.day6, this.day7);
}

// Product

class ModelProduct {
  String id;
  String name;
  String type;
  String billing;
  int interval;
  double price;
  String stype;
  int sessions;
  int sessions11;
  String product;
  int expires;
  String expType;
  String desc;
  int stock;

  ModelProduct(
      this.id,
      this.name,
      this.type,
      this.billing,
      this.interval,
      this.price,
      this.stype,
      this.sessions,
      this.sessions11,
      this.product,
      this.expires,
      this.expType,
      this.desc,
      this.stock);
}

// Payment

class ModelPayment {
  String id;
  String name;
  String type;
  String last4;
  DateTime date;
  double amount;
  String receipt;
  String sub;
  String desc;
  DateTime refund;

  ModelPayment(this.id, this.name, this.type, this.last4, this.date,
      this.amount, this.receipt, this.sub, this.desc, this.refund);
}

// Invoice

class ModelInvoice {
  String id;
  String number;
  String client;
  String product;
  double price;
  double gst;
  DateTime date;
  DateTime due;
  String status;
  String notes;
  String account;

  ModelInvoice(this.id, this.number, this.client, this.product, this.price,
      this.gst, this.date, this.due, this.status, this.notes, this.account);
}

// Client

class ModelClient {
  String id;
  String name;
  String image;
  String token;
  String uid;
  String parent;
  bool restricted;
  String avatar;

  ModelClient(this.id, this.name, this.image, this.token, this.uid, this.parent,
      this.restricted, this.avatar);
}

// Chat

class ModelChat {
  String id;
  String name;
  String trainer;
  List<ModelClientChat> clients;
  List<ModelClientChat> staff;
  List<ModelMessage> messages;

  ModelChat(this.id, this.name, this.trainer, this.clients, this.staff,
      this.messages);
}

// Chat client

class ModelClientChat {
  String id;
  DateTime date;
  String name;
  String token;

  ModelClientChat(this.id, this.date, this.name, this.token);
}

// Chat message

class ModelMessage {
  String id;
  String chat;
  String sender;
  String text;
  String image;
  DateTime date;
  String name;

  ModelMessage(this.id, this.chat, this.sender, this.text, this.image,
      this.date, this.name);
}

// Session comment

class ModelComment {
  String id;
  String sender;
  DateTime date;
  String text;

  ModelComment(this.id, this.sender, this.date, this.text);
}

// Note

class ModelNote {
  String id;
  DateTime date;
  String text;

  ModelNote(this.id, this.text, this.date);
}

// Movement history

class ModelHistory {
  String id;
  int tool;
  DateTime date;
  String name;
  String reps;
  String weight;

  ModelHistory(
      this.id, this.tool, this.date, this.name, this.reps, this.weight);
}

// Community post

class ModelPost {
  String id;
  String text;
  String image;
  DateTime date;
  String author;
  String reaction1;
  String reaction2;
  String reaction3;
  String reaction4;
  String parent;
  int seq;
  String url;

  ModelPost(
      this.id,
      this.text,
      this.image,
      this.date,
      this.author,
      this.reaction1,
      this.reaction2,
      this.reaction3,
      this.reaction4,
      this.parent,
      this.seq,
      this.url);
}

// Exercise best 1 rep

class ModelBest {
  String id;
  String name;
  int tool;
  double value;
  double actual;
  double percent;
  DateTime date;
  String type;

  ModelBest(this.id, this.name, this.tool, this.value, this.actual,
      this.percent, this.date, this.type);
}

// Pack

class ModelPack {
  String id;
  bool group;
  int paid;
  int done;
  bool expires;
  DateTime expiry;
  String account;
  String name;
  String product;

  ModelPack(this.id, this.group, this.paid, this.done, this.expires,
      this.expiry, this.account, this.name, this.product);
}

// Direct debit

class ModelDebit {
  String id;
  String name;
  String cycle;
  int interval;
  double price;
  DateTime next;
  bool group;
  int sessions;
  int sessions11;
  String status;
  String account;
  bool is11;
  int done;
  int done11;
  String pause;
  String plan;

  ModelDebit(
      this.id,
      this.name,
      this.cycle,
      this.interval,
      this.price,
      this.next,
      this.group,
      this.sessions,
      this.sessions11,
      this.status,
      this.account,
      this.is11,
      this.done,
      this.done11,
      this.pause,
      this.plan);
}

// Assessment

class ModelAssessment {
  String id;
  DateTime date;
  double weight;
  double fat;
  int heart;
  String image;
  String notes;
  double abdomen;
  double chest;
  double hip;
  double neck;
  double armL;
  double armR;
  double thighL;
  double thighR;
  String nutrition;
  String image2;
  String image3;
  String image4;
  String blood1;
  String blood2;
  String custom;

  ModelAssessment(
      this.id,
      this.date,
      this.weight,
      this.fat,
      this.heart,
      this.image,
      this.notes,
      this.abdomen,
      this.chest,
      this.hip,
      this.neck,
      this.armL,
      this.armR,
      this.thighL,
      this.thighR,
      this.nutrition,
      this.image2,
      this.image3,
      this.image4,
      this.blood1,
      this.blood2,
      this.custom);
}

// Log

class ModelLog {
  String id;
  String type;
  String title;
  String message;

  ModelLog(this.id, this.type, this.title, this.message);
}

// Notification

class ModelNotification {
  String id;
  String name;
  String desc;
  String type;
  DateTime date;
  String link;

  ModelNotification(
      this.id, this.name, this.desc, this.type, this.date, this.link);
}

// Leaderboard

class ModelLeaderboard {
  String id;
  int reps;
  String weight;
  int time;
  double total;
  int pos;
  String session;
  int highfives;
  DateTime date;
  String type;

  ModelLeaderboard(this.id, this.reps, this.weight, this.time, this.total,
      this.pos, this.session, this.highfives, this.date, this.type);
}

// Scheduled notification

class ModelSchedule {
  String id;
  String title;
  String desc;
  String type;
  DateTime date;
  List tokens;
  String message;
  String uid;
  String iid;

  ModelSchedule(this.id, this.title, this.desc, this.type, this.date,
      this.tokens, this.message, this.uid, this.iid);
}

// Client group

class ModelClientGroup {
  String id;
  String name;
  List clients;

  ModelClientGroup(this.id, this.name, this.clients);
}

// Habit

class ModelHabit {
  String id;
  String name;
  String client;
  double amount;
  String unit;
  int interval;
  DateTime start;
  DateTime end;
  List days;

  ModelHabit(this.id, this.name, this.client, this.amount, this.unit,
      this.interval, this.start, this.end, this.days);
}

// Document

class ModelDocument {
  String id;
  String name;
  String ext;
  DateTime date;

  ModelDocument(this.id, this.name, this.ext, this.date);
}

// Location

class ModelLocation {
  String id;
  String name;
  List clients;

  ModelLocation(this.id, this.name, this.clients);
}

// Recurring template

class ModelRecurring {
  String id;
  List clients;
  int max;

  ModelRecurring(this.id, this.clients, this.max);
}

// Connect

class ModelConnect {
  String id;
  String space;
  String phone;
  String client;
  String email;

  ModelConnect(this.id, this.space, this.phone, this.client, this.email);
}

// Forms

class ModelForm {
  String id;
  String name;
  DateTime date;
  bool pre;
  String uid;
  int version;
  bool lock;
  List sections;

  ModelForm(this.id, this.name, this.date, this.pre, this.version, this.uid,
      this.lock, this.sections);
}

class ModelSection {
  String id;
  int seq;
  String type;
  String label;
  String response;
  int num;
  bool answer1;
  bool answer2;
  bool multiple;
  String detail;
  List options;
  bool mandatory;

  ModelSection(
      this.id,
      this.seq,
      this.type,
      this.label,
      this.num,
      this.multiple,
      this.answer1,
      this.answer2,
      this.response,
      this.detail,
      this.options,
      this.mandatory);
}

// Invoice counter

class ModelInvoiceCount {
  String cid;
  int paid;

  ModelInvoiceCount(this.cid, this.paid);
}

// Nutrition

class ModelNutrition {
  String sex = "";
  double bmr = 0;
  double weight = 0;
  double goalWeight = 0;
  double currentWeight = 0;
  int people = 1;
  bool leftover = true;
  bool dessert = true;
  bool snack = true;
  bool gluten = true;
  int vegetarian = 0;
  bool redmeat = false;
  bool pork = false;
  bool chicken = false;
  bool turkey = false;
  bool fish = false;
  bool shellfish = false;
  bool dairy = false;
  bool nuts = false;
  bool eggs = false;
  bool coldbreakfast = false;
  bool selectbreakfast = false;
  int activity = 0;
  int vegMeals = 0;
  int cheat = 0;
  int calories = 0;
  bool generating = false;
  int planType = 0;
  bool snackMorning = false;
  bool snackAfternoon = false;
  bool snackEvening = false;
}

class ModelNutritionList {
  String id;
  DateTime date;
  List<ModelNutritionListItem> items;

  ModelNutritionList(this.id, this.date, this.items);
}

class ModelNutritionListItem {
  String id;
  String cat;
  String name;
  String kind;
  double amount;
  String unit;
  bool gluten;
  bool checked;

  ModelNutritionListItem(this.id, this.cat, this.name, this.kind, this.amount,
      this.unit, this.gluten, this.checked);
}

class ModelNutritionDay {
  String id;
  DateTime date;
  List<ModelNutritionMeal> meals;
  bool swapping;

  ModelNutritionDay(this.id, this.date, this.meals, this.swapping);
}

class ModelNutritionMeal {
  String id;
  String recipe;
  String day;
  int type;
  int calories;
  bool gluten;
  bool checked;
  String next;
  int serves;
  double size;

  ModelNutritionMeal(this.id, this.recipe, this.day, this.type, this.calories,
      this.gluten, this.checked, this.next, this.serves, this.size);
}

class ModelNutritionRecipe {
  String id;
  String name;
  String image;
  int time;
  double fat;
  double carbs;
  double sugar;
  double protein;
  String method;
  List<ModelNutritionIngredient> ingredients;

  ModelNutritionRecipe(this.id, this.name, this.image, this.time, this.fat,
      this.carbs, this.sugar, this.protein, this.method, this.ingredients);
}

class ModelNutritionIngredient {
  String id;
  String name;
  int amount;
  String unit;
  double increments;
  double size;
  String kind;

  ModelNutritionIngredient(this.id, this.name, this.amount, this.unit,
      this.increments, this.size, this.kind);
}

class ModelNutritionLikes {
  String id;
  String recipe;
  int rating;

  ModelNutritionLikes(this.id, this.recipe, this.rating);
}

class ModelNutritionCat {
  String id;
  String name;
  String image;

  ModelNutritionCat(this.id, this.name, this.image);
}

// Push Notification

class PushNotification {
  String title;
  String body;

  PushNotification(
    this.title,
    this.body,
  );

  factory PushNotification.fromJson(Map<String, dynamic> json) {
    return PushNotification(
      json["notification"]["title"],
      json["notification"]["body"],
    );
  }
}
