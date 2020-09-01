import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:media_player/data/data_source/media_data_source.dart';
import 'package:media_player/data/dio_factory.dart';
import 'package:media_player/data/repository/media_list_repository.dart';
import 'package:media_player/data/repository/meida_list_repository_impl.dart';
import 'package:media_player/data/repository/player_repository_impl.dart';
import 'package:media_player/data/repository/player_states.dart';
import 'package:media_player/data/rest/rest_service.dart';
import 'package:media_player/ui/media_list/media_bloc.dart';
import 'package:media_player/ui/media_list/media_event.dart';
import 'package:media_player/ui/media_list/media_state.dart';
import 'package:media_player/ui/player/player_bloc.dart';
import 'package:media_player/ui/player/player_event.dart';
import 'package:media_player/ui/player/player_state.dart';
import 'package:media_player/ui/player/player_view.dart';
import 'package:media_player/ui/router.dart';

class MediaListView extends StatelessWidget {
  bool isPlaying = false;

  @override
  Widget build(BuildContext context) {
    final dioFactory = DioFactory();
    final RestService service = RestService(dioFactory);
    final dataSource = MediaDataSource(service);
    final MediaListRepository repository = MediaListRepositoryImpl(dataSource);

    return Scaffold(
      appBar: NeumorphicAppBar(
        title: NeumorphicText(
          "Audio Quran",
          textStyle: NeumorphicTextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 26,
          ),
          style: NeumorphicStyle(
              depth: 2,
              intensity: 1,
              shadowLightColor: Colors.white,
              shadowDarkColor: Colors.black45,
              color: Colors.blueGrey),
        ),
      ),
      body: MultiBlocProvider(
        providers: [
          BlocProvider<MediaBloc>(
            create: (context) => MediaBloc(repository),
          ),
          BlocProvider<PlayerBloc>(
            create: (context) => PlayerBloc(PlayerRepositoryImpl()),
          ),
        ],
        child: Builder(
          builder: (contextB) {
            BlocProvider.of<MediaBloc>(contextB).add(MediaEvent());
            BlocProvider.of<PlayerBloc>(contextB).add(ListenEvent());
            return StreamBuilder(
              stream: BlocProvider.of<PlayerBloc>(contextB).playerStatus,
              builder: (context, AsyncSnapshot<PlayerState> state) {
                print("55 $state");
                List<Widget> childs = [
                  Expanded(
                      child: Column(
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      BlocConsumer<MediaBloc, MediaState>(
                        listener: (context, state) {},
                        buildWhen: (context, state) =>
                            state is LoadingState || state is MediaListState,
                        builder: (context, state) {
                          print(state);
                          if (state is LoadingState) {
                            return Expanded(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Neumorphic(
                                      padding: EdgeInsets.all(5),
                                      style: NeumorphicStyle(
                                          shape: NeumorphicShape.concave,
                                          boxShape: NeumorphicBoxShape.circle(),
                                          depth: 8,
                                          lightSource: LightSource.topLeft),
                                      child: CircularProgressIndicator(
                                        valueColor: AlwaysStoppedAnimation(
                                            Colors.blueGrey),
                                      ))
                                ],
                              ),
                            );
                          } else if (state is MediaListState) {
                            return Expanded(
                              child: Container(
                                child: ListView.builder(
                                    itemCount: state.mediaItems.length,
                                    itemBuilder: (context, index) {
                                      return NeumorphicButton(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: <Widget>[
                                            Row(
                                              children: <Widget>[
                                                NeumorphicText(
                                                  "${index + 1}",
                                                  textStyle:
                                                      NeumorphicTextStyle(
                                                    fontSize: 22,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                  style: NeumorphicStyle(
                                                      depth: 0,
                                                      intensity: 1,
                                                      shadowLightColor:
                                                          Colors.white,
                                                      color: Colors.blueGrey),
                                                ),
                                                Container(
                                                  margin: EdgeInsets.only(
                                                      left: 10, right: 10),
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: <Widget>[
                                                      NeumorphicText(
                                                        "${state.mediaItems[index].englishName}",
                                                        textStyle:
                                                            NeumorphicTextStyle(
                                                          fontSize: 18,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                        style: NeumorphicStyle(
                                                            depth: 0,
                                                            intensity: 1,
                                                            shadowLightColor:
                                                                Colors.white38,
                                                            color: Colors
                                                                .blueGrey),
                                                      ),
                                                      NeumorphicText(
                                                        state.mediaItems[index]
                                                            .englishNameTranslation,
                                                        textStyle:
                                                            NeumorphicTextStyle(
                                                          fontSize: 16,
                                                        ),
                                                        style: NeumorphicStyle(
                                                            depth: 0,
                                                            intensity: 1,
                                                            shadowLightColor:
                                                                Colors.white38,
                                                            color: Colors
                                                                .blueGrey),
                                                      )
                                                    ],
                                                  ),
                                                )
                                              ],
                                            )
                                          ],
                                        ),
                                        onPressed: () {
                                          Navigator.pushNamed(
                                              contextB, playerRoute,
                                              arguments:
                                                  state.mediaItems[index]);
                                        },
                                        style: NeumorphicStyle(
                                            shadowLightColor: Colors.white,
                                            depth: 3,
                                            intensity: 1,
                                            lightSource: LightSource.topLeft),
                                        margin: EdgeInsets.all(10),
                                      );
                                    }),
                              ),
                            );
                          } else {
                            return Container();
                          }
                        },
                      )
                    ],
                  ))
                ];
                if (state != null && state.hasData) {
                  if (state.data.playerStatus == Status.playing) {
                    isPlaying = true;
                  } else {
                    isPlaying = false;
                  }
                  childs.add(NeumorphicButton(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Column(
                              children: <Widget>[
                                Row(
                                  children: <Widget>[
                                    CircleAvatar(
                                      backgroundImage: AssetImage(
                                          "assets/images/ic_flutter.png"),
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Hero(
                                          tag: "english name",
                                          flightShuttleBuilder: (
                                            BuildContext flightContext,
                                            Animation<double> animation,
                                            HeroFlightDirection flightDirection,
                                            BuildContext fromHeroContext,
                                            BuildContext toHeroContext,
                                          ) {
                                            return DefaultTextStyle(
                                              style: DefaultTextStyle.of(
                                                      toHeroContext)
                                                  .style,
                                              child: toHeroContext.widget,
                                            );
                                          },
                                          child: Material(
                                            type: MaterialType.transparency,
                                            child: Container(
                                              margin: EdgeInsets.only(
                                                  left: 10, right: 10),
                                              child: Text(
                                                state.data.item.englishName,
                                                style: TextStyle(
                                                  fontSize: 22,
                                                  decoration:
                                                      TextDecoration.none,
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        Hero(
                                          tag: "english translation",
                                          flightShuttleBuilder: (
                                            BuildContext flightContext,
                                            Animation<double> animation,
                                            HeroFlightDirection flightDirection,
                                            BuildContext fromHeroContext,
                                            BuildContext toHeroContext,
                                          ) {
                                            return DefaultTextStyle(
                                              style: DefaultTextStyle.of(
                                                      toHeroContext)
                                                  .style,
                                              child: toHeroContext.widget,
                                            );
                                          },
                                          child: Material(
                                            type: MaterialType.transparency,
                                            child: Container(
                                              margin: EdgeInsets.only(
                                                  left: 10, right: 10),
                                              child: Text(
                                                state.data.item
                                                    .englishNameTranslation,
                                                style: TextStyle(
                                                  fontSize: 18,
                                                  decoration:
                                                      TextDecoration.none,
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                  ],
                                )
                              ],
                            ),
                            Hero(
                              tag: "button",
                              child: Container(
                                height: 40,
                                width: 40,
                                child: Neumorphic(
                                  padding: EdgeInsets.all(2),
                                  style: NeumorphicStyle(
                                      shape: NeumorphicShape.concave,
                                      boxShape: NeumorphicBoxShape.circle(),
                                      depth: 8,
                                      shadowLightColor: Colors.white,
                                      lightSource: LightSource.topLeft),
                                  child: NeumorphicButton(
                                    padding: EdgeInsets.all(0),
                                    onPressed: () {
                                      if (state.data.playerStatus !=
                                          Status.playing) {
                                        BlocProvider.of<PlayerBloc>(context)
                                            .add(PlayEvent(state.data.item));
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
                                      state.data.playerStatus != Status.playing
                                          ? Icons.play_arrow
                                          : Icons.pause,
                                      color: Colors.white,
                                      size: 25,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                    onPressed: () {
                      Navigator.of(context).push(PageRouteBuilder(
                        transitionDuration: Duration(milliseconds: 1000),
                        pageBuilder: (BuildContext context,
                            Animation<double> animation,
                            Animation<double> secondaryAnimation) {
                          return PlayerView(
                            item: state.data.item,
                            isPlaying: isPlaying,
                          );
                        },
                        transitionsBuilder: (BuildContext context,
                            Animation<double> animation,
                            Animation<double> secondaryAnimation,
                            Widget child) {
                          return Align(
                            child: FadeTransition(
                              opacity: animation,
                              child: child,
                            ),
                          );
                        },
                      ));
                    },
                    style: NeumorphicStyle(
                        shadowLightColor: Colors.blue[100],
                        depth: 3,
                        intensity: 1,
                        color: Colors.blue[300],
                        lightSource: LightSource.topLeft),
                  ));
                }
                return Column(
                  mainAxisSize: MainAxisSize.max,
                  children: childs,
                );
              },
            );
          },
        ),
      ),
    );
  }
}
