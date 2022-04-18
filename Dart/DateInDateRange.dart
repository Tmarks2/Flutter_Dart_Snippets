import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;
main()async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(apiKey: '[YOURAPIKEY]',
     appId: '[YOURAPPID]', messagingSenderId: '[YOURSENDERID]',
      projectId: '[YOURPROJECT]')
  );
  
  //DATES THE USER INPUTS FOR RESERVATION
  DateTime start = DateTime(2022,4,18);
  DateTime end = DateTime(2022,4,21); 

  
  
  reservationChecker(start: start,end: end);

}


reservationChecker({required DateTime start,required DateTime end})async{

  var snapshots = await _firebaseFirestore
        .collection([COLID])
        .doc([DOCID])
        .collection([COLID])
        .where(['startDate'],isGreaterThanOrEqualTo: start)
        .get();


  debugPrint('Retrieved ${snapshots.docs.length.toString()}');
  
  List<String> good = [];
  List<String> conflictingRes =[];

  for (var i in snapshots.docs) { 
    //DATETIME from previously made reservations
    DateTime _start = i.get('startDate').toDate();
    DateTime _end = i.get('endDate').toDate();
    
    int count = 0;

    //First Check::: start is before _end and after _start
    //Second Check:: _start is before start and after start
    //is a OR Statement. 
    if(
        (start.isBefore(_end) && start.isAfter(_start))
        ||//OR SWITCH
        (_start.isBefore(end) && _start.isAfter(start))
    ){
      count++;
      debugPrint('This Res start is inbetween start end of res: '+i.get('Title'));
    }
    
    //First Check::: end is before _end and after _start 
    //second check:: _end is before end and after start 
    // is a OR statement  
    if(
        (end.isBefore(_end) && end.isAfter(_start))
        ||
        (_end.isBefore(end) && _end.isAfter(start))
    ){
      count++;
      debugPrint('This Res end is inbetween start end of res: '+i.get('Title'));
    }

    //checks if start is same as _start or _end.. 
    //if start == _start then error. 
    if(start.isAtSameMomentAs(_start)){
      debugPrint(i.get('Title')+' start dates are the same');
      count++;
    }else if(start.isAtSameMomentAs(_end)){
      debugPrint(i.get('Title')+' start is the same as the _end date');
      debugPrint('Could cause issue is start is the same as _end...');
    }

    //checks if end is same as _start or end 
    //if end == _end then error. 
    if(end.isAtSameMomentAs(_start)){
      debugPrint(i.get('Title')+' end is the same as _start');
      debugPrint('Could cause isssues if end date is same as _start');
    }else if(end.isAtSameMomentAs(_end)){
      debugPrint(i.get('Title')+' end Dates are the same');
      count++;
    }

    if(count!=0){      
      debugPrint('Res Should Not be Created due to conflicting Dates with '+i.get('Title'));
      conflictingRes.add(i.get('Title'));
    }else{
      debugPrint(i.get('Title')+' Res is okay');
      good.add(i.get('Title'));
    }

  }


  for(var item in conflictingRes){
    debugPrint('Bad $item');
  }

  if(conflictingRes.isNotEmpty){
    debugPrint('Reject Reservation Dates');
  }else{
    debugPrint('Accept Reservation Request.');
  }

}
