// ignore_for_file: avoid_print

import 'package:example/data/models/cart.dart';
import 'package:example/data/models/mocks.dart';
import 'package:example/testing_cases/use_effect_example.dart';
import 'package:flutter/material.dart';
import 'package:reactter/reactter.dart';

mixin UseCart on ReactterHook {
  late final cart = UseState<Cart?>(null, alwaysUpdate: true, context: this);

  removeItemFromCart(int productId) {
    final newProducts = cart.value?.products
        ?.where((element) => element.id != productId)
        .toList();

    final newCart = cart.value?.copyWith(products: newProducts);

    cart.value = newCart;
  }
}

class UserApp extends ReactterContext with UseCart {
  final user = Global.currentUser;

  UserApp() {
    UseEffect(() {
      cart.value = Mocks.getUserCart(user.value?.id ?? 0);
    }, [user]);
  }
}

class UserView extends StatelessWidget {
  const UserView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return UseProvider(
      contexts: [
        UseContext(
          () => UserApp(),
          init: true,
        ),
      ],
      builder: (context, _) {
        print("REBUILD ROOT");
        final userStatic = context.ofStatic<UserApp>();

        return Scaffold(
          appBar: AppBar(
            title: Text("User: " + userStatic.user.value!.firstName!),
          ),
          body: SingleChildScrollView(
            physics: const ScrollPhysics(),
            child: Builder(builder: (context) {
              final userDynamic = context.of<UserApp>();

              final cart = userDynamic.cart.value;

              print("- REBUILD CART");
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Text(appContext.userName.value),
                  const SizedBox(height: 20),
                  Text("items in cart: ${cart?.products?.length ?? 0}"),
                  const SizedBox(height: 20),
                  ListView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    padding: const EdgeInsets.all(8),
                    itemCount: cart?.products?.length ?? 0,
                    itemBuilder: (BuildContext context, int index) {
                      final product = cart?.products?[index];

                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedBox(
                            height: 50,
                            child: Center(
                              child: Text('${product?.title} '),
                            ),
                          ),
                          ElevatedButton(
                            style:
                                ElevatedButton.styleFrom(primary: Colors.red),
                            onPressed: () {
                              userDynamic.removeItemFromCart(product?.id ?? 0);
                            },
                            child: const Text("Remove"),
                          )
                        ],
                      );
                    },
                  )
                ],
              );
            }),
          ),
        );
      },
    );
  }
}
