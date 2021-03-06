import 'package:flutter/material.dart';
import 'package:media_player/ui/media_list/media_list_view.dart';
import 'package:media_player/ui/player/player_view.dart';

const String homeRoute = "/";
const String playerRoute = "player";

class Router {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case homeRoute:
        return MaterialPageRoute(builder: (_) => MediaListView());
      case playerRoute:
        return MaterialPageRoute(
            builder: (_) => PlayerView(), settings: settings);
      default:
        return MaterialPageRoute(
            builder: (_) => Scaffold(
                  body: Center(
                      child: Text('No route defined for ${settings.name}')),
                ));
    }
  }
}
