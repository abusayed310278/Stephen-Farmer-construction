

import 'package:flutter/material.dart';


 Text appName =  Text("Preissler's Lunch",style: TextStyle(fontSize: 28,fontWeight: FontWeight.w800,color: Color(0xFF000000)),);

 Widget fieldName( String fieldName){
  return Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(fieldName,style: TextStyle(fontSize:16,fontWeight: FontWeight.w500,color: Colors.black ),),
  );
 }

Widget agreeText(String agreeText){
  return Row(
    children: [
     //Icon(Icons.check_box_outline_blank_outlined),
     Checkbox(value: false, onChanged: (value){},),
      Expanded(child: Text(agreeText,style: TextStyle(fontSize:16,fontWeight: FontWeight.w500,color: Colors.black ),)),
    ],
  );
}





class BottonText extends StatelessWidget {
  const BottonText({super.key});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
      color: Colors.white,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Your Profile helps us customize your experience', style: TextStyle(fontSize: 16, color: Color(0xFF9CA3AF)), textAlign: TextAlign.center,),
          const SizedBox(height: 8),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.lock_open_outlined, size: 20, color: Color(0xFF9CA3AF)),
              SizedBox(width: 5),
              Text('Your data is secure and private', style: TextStyle(fontSize: 16, color: Color(0xFF9CA3AF)),),
            ],
          ),
        ],
      ),
    );
  }
  }
