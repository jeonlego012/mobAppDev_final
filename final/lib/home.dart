import 'package:flutter/material.dart';

import 'components/my_appbar.dart';
import 'components/body.dart';

class Home extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppbar(),
      body: Body(),
    );
  }
}
