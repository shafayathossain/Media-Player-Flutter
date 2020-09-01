import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:media_player/data/model/media_item.dart';
import 'package:media_player/data/repository/player_repository_impl.dart';
import 'package:media_player/data/repository/player_states.dart';
import 'package:media_player/ui/player/player_bloc.dart';
import 'package:media_player/ui/player/player_event.dart';

class PlayerView extends StatelessWidget {
  MediaItem item;

  @override
  Widget build(BuildContext context) {
    item = ModalRoute.of(context).settings.arguments;

    return Scaffold(
        appBar: NeumorphicAppBar(),
        body: BlocProvider(
          create: (context) => PlayerBloc(PlayerRepositoryImpl()),
          child: StatefulPlayerView(item),
        ));
  }
}

class StatefulPlayerView extends StatefulWidget {
  final MediaItem item;

  StatefulPlayerView(this.item);

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
                    margin: EdgeInsets.only(top: 55, left: 55),
                    width: 40,
                    height: 40,
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
        Container(
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
              builder: (context, AsyncSnapshot<Status> snapshot) {
                if (snapshot.hasData) {
                  return NeumorphicButton(
                    padding: EdgeInsets.all(0),
                    onPressed: () {
                      if (snapshot.data != Status.playing) {
                        BlocProvider.of<PlayerBloc>(context)
                            .add(PlayEvent(widget.item));
                      } else {
                        BlocProvider.of<PlayerBloc>(context).add(PauseEvent());
                      }
                    },
                    style: NeumorphicStyle(
                        depth: 8,
                        shadowLightColor: Colors.white,
                        color: Colors.indigoAccent,
                        boxShape: NeumorphicBoxShape.circle()),
                    child: Icon(
                      snapshot.data != Status.playing
                          ? Icons.play_arrow
                          : Icons.pause,
                      color: Colors.white,
                      size: 35,
                    ),
                  );
                } else {
                  return NeumorphicButton(
                    padding: EdgeInsets.all(0),
                    onPressed: () {
                      BlocProvider.of<PlayerBloc>(context)
                          .add(PlayEvent(widget.item));
                    },
                    style: NeumorphicStyle(
                        depth: 8,
                        shadowLightColor: Colors.white,
                        color: Colors.indigoAccent,
                        boxShape: NeumorphicBoxShape.circle()),
                    child: Icon(
                      Icons.play_arrow,
                      color: Colors.white,
                      size: 35,
                    ),
                  );
                }
              },
            ),
          ),
        ),
      ],
    );
  }
}
