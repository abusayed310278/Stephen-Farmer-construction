import 'package:flutter/material.dart';

class TypeWidget extends StatelessWidget {
  final String ?image;
  final String ?title;
  final String ?description;
  const TypeWidget({super.key,this.image,this.title,this.description});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 160,
      child: Row(children: [

        Padding(
          padding: const EdgeInsets.only(bottom: 15),
          child: Image.asset("$image",height: 24,width: 24,),
        ),
        SizedBox(width: 15,),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          Text(title!,style: TextStyle(color: Colors.white,fontSize: 16,fontWeight: FontWeight.w700),),
          Text(description!,style: TextStyle(color: Color(0xFFB4BABF),fontSize: 14,fontWeight: FontWeight.w400),),
        ],)
      ],),
    );
  }
}
