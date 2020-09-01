import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:media_player/data/model/media_item.dart';
import 'package:media_player/data/repository/player_repository_impl.dart';
import 'package:media_player/data/repository/player_states.dart';
import 'package:media_player/ui/player/player_bloc.dart';
import 'package:media_player/ui/player/player_event.dart';
import 'package:media_player/ui/player/player_state.dart';
import 'package:media_player/utils.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

class PlayerView extends StatelessWidget {
  MediaItem item;
  bool isPlaying;
  bool oldItem = false;

  PlayerView({this.item, this.isPlaying});

  @override
  Widget build(BuildContext context) {
    if (item != null) {
      oldItem = true;
    } else {
      oldItem = false;
    }
    if (item != null && isPlaying == null) {
      isPlaying = true;
    } else if (isPlaying == null) {
      isPlaying = false;
    }
    item ??= ModalRoute.of(context).settings.arguments;

    return Scaffold(
        appBar: NeumorphicAppBar(),
        body: BlocProvider(
          create: (context) => PlayerBloc(PlayerRepositoryImpl()),
          child: StatefulPlayerView(
            item,
            isPlaying: isPlaying,
            oldItem: oldItem,
          ),
        ));
  }
}

class StatefulPlayerView extends StatefulWidget {
  final MediaItem item;
  bool isPlaying = false;
  bool oldItem = false;

  StatefulPlayerView(this.item, {this.isPlaying = false, this.oldItem});

  @override
  State createState() {
    return PlayerViewState();
  }
}

class PlayerViewState extends State<StatefulPlayerView>
    with TickerProviderStateMixin {
  AnimationController controllerPlayer;
  Animation<double> animationPlayer;

  @override
  void initState() {
    super.initState();
    controllerPlayer = new AnimationController(
        duration: const Duration(milliseconds: 15000), vsync: this);
    animationPlayer =
        new CurvedAnimation(parent: controllerPlayer, curve: Curves.linear);
    animationPlayer.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        controllerPlayer.repeat();
      } else if (status == AnimationStatus.dismissed) {
        controllerPlayer.forward();
      }
    });
    BlocProvider.of<PlayerBloc>(context).add(ListenEvent());
    BlocProvider.of<PlayerBloc>(context).add(ProgressEvent());
    if (!widget.oldItem) {
      BlocProvider.of<PlayerBloc>(context).add(PlayEvent(widget.item));
    }
  }

  @override
  Widget build(BuildContext context) {
    controllerPlayer.forward();
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        Center(
          child: Neumorphic(
              padding: EdgeInsets.all(5),
              style: NeumorphicStyle(
                  shape: NeumorphicShape.concave,
                  boxShape: NeumorphicBoxShape.circle(),
                  depth: 8,
                  lightSource: LightSource.topLeft),
              child: Stack(
                children: <Widget>[
                  RotationTransition(
                    turns: animationPlayer,
                    child: Container(
                      width: 150,
                      height: 150,
                      child: CircleAvatar(
                        backgroundImage:
                            AssetImage("assets/images/img_afasi.jpg"),
                      ),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 50, left: 50),
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.blue,
                    ),
                    child: Neumorphic(
                      padding: EdgeInsets.all(5),
                      style: NeumorphicStyle(
                          shape: NeumorphicShape.concave,
                          boxShape: NeumorphicBoxShape.circle(),
                          depth: -20,
                          intensity: 1,
                          shadowLightColor: Colors.white),
                    ),
                  )
                ],
              )),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Column(
              children: <Widget>[
                Hero(
                  tag: "english name",
                  child: Material(
                    type: MaterialType.transparency,
                    child: Container(
                      child: Text(
                        widget.item.englishName,
                        style: TextStyle(
                            fontSize: 24,
                            color: Colors.blueGrey,
                            decoration: TextDecoration.none,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
                Hero(
                  tag: "english translation",
                  child: Material(
                    type: MaterialType.transparency,
                    child: Container(
                      child: Text(
                        widget.item.englishNameTranslation,
                        style: TextStyle(
                            fontSize: 18,
                            color: Colors.blueGrey,
                            decoration: TextDecoration.none,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(top: 10),
                  child: Text(
                    "Mishary bin Rashid Alafasy",
                    style: TextStyle(fontSize: 16, color: Colors.blueGrey),
                  ),
                )
              ],
            )
          ],
        ),
        Row(
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            Expanded(
              child: StreamBuilder(
                stream: BlocProvider.of<PlayerBloc>(context).playerProgress,
                builder: (context, AsyncSnapshot<List<double>> progress) {
                  print(progress);
                  return Column(
                    children: <Widget>[
                      Container(
                        margin: EdgeInsets.only(left: 15, right: 15),
                        child: Neumorphic(
                          padding: EdgeInsets.only(
                              left: 8, right: 8, top: 2, bottom: 2),
                          style: NeumorphicStyle(
                              shape: NeumorphicShape.convex,
                              depth: 8,
                              shadowLightColor: Colors.white,
                              lightSource: LightSource.topLeft),
                          child: LinearPercentIndicator(
                            padding: EdgeInsets.all(0),
                            animationDuration: 1000,
                            animation: true,
                            lineHeight: 14,
                            animateFromLastPercent: true,
                            percent: progress.hasData ? progress.data[2] : 0,
                            fillColor: Colors.blueGrey,
                            progressColor: Colors.blueGrey,
                          ),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(left: 15, right: 15, top: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text(
                              "${millisecondsToTimeString(progress.hasData ? progress.data[1] : 0)}",
                              style: TextStyle(
                                  color: Colors.blueGrey, fontSize: 16),
                            ),
                            Text(
                              "${millisecondsToTimeString(progress.hasData ? progress.data[0] : 0)}",
                              style: TextStyle(
                                  color: Colors.blueGrey, fontSize: 16),
                            )
                          ],
                        ),
                      )
                    ],
                  );
                },
              ),
            )
          ],
        ),
        Hero(
          tag: "button",
          child: Container(
            height: 60,
            width: 60,
            child: Neumorphic(
              padding: EdgeInsets.all(2),
              style: NeumorphicStyle(
                  shape: NeumorphicShape.concave,
                  boxShape: NeumorphicBoxShape.circle(),
                  depth: 8,
                  shadowLightColor: Colors.white,
                  lightSource: LightSource.topLeft),
              child: StreamBuilder(
                stream: BlocProvider.of<PlayerBloc>(context).playerStatus,
                builder: (context, AsyncSnapshot<PlayerState> snapshot) {
                  if (snapshot.hasData) {
                    if (snapshot.data.playerStatus == Status.playing) {
                      widget.isPlaying = true;
                    } else {
                      widget.isPlaying = false;
                    }
                    return NeumorphicButton(
                      padding: EdgeInsets.all(0),
                      onPressed: () {
                        if (snapshot.data.playerStatus != Status.playing) {
                          BlocProvider.of<PlayerBloc>(context)
                              .add(PlayEvent(widget.item));
                        } else {
                          BlocProvider.of<PlayerBloc>(context)
                              .add(PauseEvent());
                        }
                      },
                      style: NeumorphicStyle(
                          depth: 8,
                          shadowLightColor: Colors.white,
                          color: Colors.indigoAccent,
                          boxShape: NeumorphicBoxShape.circle()),
                      child: Icon(
                        !widget.isPlaying ? Icons.play_arrow : Icons.pause,
                        color: Colors.white,
                        size: 35,
                      ),
                    );
                  } else {
                    return NeumorphicButton(
                      padding: EdgeInsets.all(0),
                      onPressed: () {
                        if (!widget.isPlaying) {
                          BlocProvider.of<PlayerBloc>(context)
                              .add(PlayEvent(widget.item));
                        } else {
                          BlocProvider.of<PlayerBloc>(context)
                              .add(PauseEvent());
                        }
                      },
                      style: NeumorphicStyle(
                          depth: 8,
                          shadowLightColor: Colors.white,
                          color: Colors.indigoAccent,
                          boxShape: NeumorphicBoxShape.circle()),
                      child: Icon(
                        !widget.isPlaying ? Icons.play_arrow : Icons.pause,
                        color: Colors.white,
                        size: 35,
                      ),
                    );
                  }
                },
              ),
            ),
          ),
        ),
      ],
    );
  }
}
