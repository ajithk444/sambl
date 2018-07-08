import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:quiver/core.dart';
import 'package:redux/redux.dart';
import 'package:sambl/model/order.dart';
import 'package:sambl/model/order_detail.dart';
import 'package:sambl/state/app_state.dart';
import 'package:sambl/action/order_action.dart'; // Action
import 'package:sambl/main.dart'; // To access our store (which contains our current appState).
import 'package:sambl/widgets/shared/my_app_bar.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:sambl/widgets/pages/open_order_list_page/open_order_list_widget.dart';

class PlaceOrderPage extends StatefulWidget {
  final OrderModel orderModel;

  PlaceOrderPage(this.orderModel);

  @override
  _PlaceOrderPageState createState() => _PlaceOrderPageState();
}

class _PlaceOrderPageState extends State<PlaceOrderPage> {



  @override
  void initState() {
    super.initState();
  }

  /// This dialog shows up when +Add stall button is tapped. It returns Future<Stall> future when
  /// popped from Navigator.
  Future<Stall> _addStallDialog() {
    TextEditingController textEditingController = new TextEditingController();
    return showDialog<Stall>(
      context: context,
      builder: (BuildContext context) {
        return new AlertDialog(
          title: new Text("Stall Name"),
          content: new TextField(
            controller: textEditingController,
            autofocus: true,
            decoration: new InputDecoration(
              labelText: 'stall name',
              hintText: 'eg. Wakanda stall'
            ),
          ),
          actions: <Widget>[
            new FlatButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: new Text("Cancel")),
            new FlatButton(
              onPressed: () {
                Stall stall = new Stall(identifier: new HawkerCenterStall(name: textEditingController.text), dishes: new List<Dish>());
                Navigator.of(context).pop(stall);
              },
              child: new Text("Add")),
          ],
        );
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    // Inside this widget tree, we have three buttons that trigger some Action -
    // add dish, add stall, and place order.
    return new ScopedModel(
      model: widget.orderModel,
      child: Scaffold(
        appBar: new MyAppBar().build(context),
        backgroundColor: new Color(0xFFEBEBEB),
        body: new Column(
          children: <Widget>[
            // "Delivering From" title/banner.
            new Container(
              margin: new EdgeInsets.only(top: 10.0, bottom: 5.0),
              child: new Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  new Padding(
                    padding: new EdgeInsets.only(top: 10.0, bottom: 10.0),
                    child:  new Text("Delivering from",
                      style: new TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                ],
              ),
              color: Colors.white,
            ),

            // AddStallCard cards
            // Use Scoped Model Descendant to update the current Order model.
            new ScopedModelDescendant<OrderModel>(
              builder: (context, child, orderModel) {
                print("inside addstallcard, ordermodel is :  $orderModel");
                return new Expanded(
                    child: new ListView.builder(
                        itemCount: orderModel.order.stalls?.length ?? 0,
                        itemBuilder: (BuildContext context, int n) {
                          return new AddStallCard( orderModel.order.stalls[n]);
                              new Stall(
                                  identifier: new HawkerCenterStall(name: "Wakanda stall"),
                                  dishes: <Dish>[
                                    new Dish(name: "High Calorie yummy food"),
                                    new Dish(name: "Low Calorie not so yummy food"),
                                    new Dish(name: "African meat"),
                                    new Dish(name: "Sexy fish"),
                                    new Dish(name: "Sizzling butter pork with extra oozing cheese that is "
                                        "almost melting but not really. "),
                                  ]
                              );

                        }
                    )
                );
              },

            ),

            // just a space
            new Container(
              height: 10.0,
              color: new Color(0xFFEBEBEB),
            ),

            // Add stall button. Right at the bottom.
            new Container(
              color: Colors.white,
              child: new Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  new Padding(padding: new EdgeInsets.all(20.0)), // Just some space to the left.
                  // this add stall button edit orderModel.
                  new ScopedModelDescendant<OrderModel>(

                    builder: (context, child, orderModel){
                      return new FlatButton(
                        padding: new EdgeInsets.all(10.0),
                        onPressed: () async {
                          // pop up a textfield to for user to input stall name.
                          // We then create a Stall object based on the input.
                          Stall stall = await _addStallDialog();

                          // Update orderModel, then notify all descendants.
                          // Bad practice since I accessed order field directly.
                          orderModel.order.stalls.add(stall);
                          orderModel.editOrderModel(order: orderModel);

                          // TRIGGER AddStallAction action, which takes in our newly created stall.
                          // The reducer will add this newly created stall and add it to our existing list
                          // of stalls. The reducer shd create a new state w new Order obj w new list of stalls.
                          // store.dispatch(new AddStallAction(stall: stall));
                          print("stall added: " + stall.identifier.name);
                        },
                        child: new Text("+ Add stall",
                          style: new TextStyle(
                              fontSize: 17.0
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            // just a space
            new Container(
              height: 10.0,
              color: new Color(0xFFEBEBEB),
            ),

            //Place order button
            new Center(
              child: new Container(
                color: Colors.white,
                // TRIGGER SubmitOrderAction which I believe is async and involves Middleware(thunk).
                child: new StoreConnector<AppState, Store<AppState>>(
                  converter: (store) => store,
                  builder: (_, store){
                    return new FlatButton(
                      padding: new EdgeInsets.all(10.0),
                      onPressed: (){
                        //TRIGGER SubmitOrderAction.
                        Optional<Order> newOrder = store.state.currentOrder;
                        // The reducer shd create a new state w new Order. Then inform Firebase (async).
                        store.dispatch(new OrderAction(order: newOrder));

                        // Navigate to a page to view ur order

                        print("Order placed.");
                      },
                      child: new Container(
                        width: MediaQuery.of(context).size.width,
                        child: new Text("Place Order",
                          textAlign: TextAlign.center,
                          style: new TextStyle(
                              color: Colors.green,
                              fontSize: 17.0
                          ),
                        ),
                      ),
                    );
                  },

                ),


              ),
            ),

          ],
        ),
      ),
    );
  }
}

// This class constructs a card that represents a stall. When a user click 'Add Stalls' button,
// a new AddStallCard object will be created. It contains info such as the dish the user wants to
// order.
class AddStallCard extends StatefulWidget {
  Stall stall;


  AddStallCard(this.stall);

  @override
  _AddStallCardState createState() => _AddStallCardState();
}

class _AddStallCardState extends State<AddStallCard> {



  /// This dialog shows up when +Add dish button is tapped. It returns Future<Dish> future when
  /// popped from Navigator.
  Future<Dish> _addDishDialog() {
    TextEditingController textEditingController = new TextEditingController();
    return showDialog<Dish>(
        context: context,
        builder: (BuildContext context) {
          return new AlertDialog(
            title: new Text("Add dish"),
            content: new TextField(
              controller: textEditingController,
              autofocus: true,
              decoration: new InputDecoration(
                  labelText: "What's the dish you want to order?",
                  hintText: 'eg. butter chicken rice. Extra rice. '
              ),
            ),
            actions: <Widget>[
              new FlatButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: new Text("Cancel")),
              new FlatButton(
                  onPressed: () {
                    Dish dish = new Dish(name: textEditingController.text);
                    Navigator.of(context).pop(dish); // When popped, the dish is wrapped in a Future
                                                     // object which is returned by this _addDishDialog().
                  },
                  child: new Text("Add")),
            ],
          );
        }
    );
  }

  @override
  Widget build(BuildContext context) {
    return new StoreProvider<AppState>(
      store: store,
      child: new Container(
        // bottom padding for the card
        padding: new EdgeInsets.only(bottom: 15.0),
        child: new Column(
          children: <Widget>[

            // The title of the card, which is the stall name
            new Container(
              color: new Color(0xFF9A9A9A),
              padding: new EdgeInsets.all(15.0),
              child: new Row(
                children: <Widget>[
                  new Text(widget.stall.identifier.name,
                    // The grey part of the card
                    style: new TextStyle(
                        color: Colors.white,
                        fontSize: 17.0
                    ),
                  ),
                ],
              ),
            ),
            // The white part of the card.
            new Container(
              color: Colors.white,
              padding: new EdgeInsets.all(10.0),
              // dishes for this particular stall. Remember each card represents one stall.
              child: new Column(
                children: <Widget>[
                  // The ListView wraps all dishes in this card. Remember each card represents one stall.
                  new Container(
                    height: 150.0,
                    child: new ScopedModelDescendant<OrderModel>(

                      builder: (context, child, orderModel) {
                        print("inside list of dishes, dishes.length is ${widget.stall.dishes?.length}");
                        return new ListView.builder(
                            itemCount: widget.stall.dishes?.length ?? 0,
                            itemBuilder: (BuildContext context, int index) {
                              // A column consists of the string for stall name and a divider.
                              return new Column(
                                children: <Widget>[
                                  new Row(
                                    children: <Widget>[
                                      new Expanded(
                                        child: new Container(
                                          padding: new EdgeInsets.all(10.0) ,
                                          child: new Text(widget.stall.dishes[index].name,
                                            style: new TextStyle(fontSize: 20.0,),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  new Divider(
                                    color: Colors.black,
                                    height: 3.0,
                                  )
                                ],
                              );

                            }
                        );
                      },
                    ),
                  ),

                  // This is the +Add dish button
                  new Row(
                    children: <Widget>[
                      new Padding(padding: new EdgeInsets.all(16.0)), // Just some space to the left.
                      new ScopedModelDescendant<OrderModel>(
                        builder: (context, child, orderModel){
                          return new FlatButton(
                            padding: new EdgeInsets.all(10.0),
                            onPressed: () async {
                              // AddDishAction is dispatched. Create a new dish and add it to this
                              // particular stall. This addStallCard widget is rebuilt with the
                              // newly added dish.
                              Dish dish = await _addDishDialog();

                              // update our orderModel
                              widget.stall.dishes.add(dish);
                              print("indise add dish button, this particular stall's dish lengh is ${widget.stall.dishes.length}");
                              orderModel.editOrderModel(order: orderModel); // notify

                              // The reducer shd create new state w a new Order obj w new stall w one more dish.
                              //store.dispatch(new AddDishAction(stall: widget.stall, dish: dish));

                              print("dish added: " + dish.name);
                            },
                            child: new Text("+ Add dish"),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }


}

