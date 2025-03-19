import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'bloc/cart_bloc.dart';
import 'repositories/cart_repository.dart';
import 'screens/cart_screen.dart';

class CartModule extends StatelessWidget {
  final String userId;

  const CartModule({
    super.key,
    required this.userId,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Box<Map>>(
      future: Hive.openBox<Map>('cart_box'),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final box = snapshot.data!;
        final repository = CartRepository(
          box: box,
          firestore: FirebaseFirestore.instance,
          userId: userId,
        );

        return BlocProvider(
          create: (context) => CartBloc(repository),
          child: const CartScreen(),
        );
      },
    );
  }
}
