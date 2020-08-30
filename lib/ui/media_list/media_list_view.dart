import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:media_player/data/data_source/media_data_source.dart';
import 'package:media_player/data/dio_factory.dart';
import 'package:media_player/data/repository/media_list_repository.dart';
import 'package:media_player/data/repository/meida_list_repository_impl.dart';
import 'package:media_player/data/rest/rest_service.dart';
import 'package:media_player/ui/media_list/media_bloc.dart';
import 'package:media_player/ui/media_list/media_event.dart';
import 'package:media_player/ui/media_list/media_state.dart';

class MediaListView extends StatelessWidget {
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
      body: BlocProvider<MediaBloc>(
        create: (context) => MediaBloc(repository),
        child: Builder(
          builder: (contextB) {
            BlocProvider.of<MediaBloc>(contextB).add(MediaEvent());
            return Container(
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
                                  valueColor:
                                      AlwaysStoppedAnimation(Colors.blueGrey),
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
                                            textStyle: NeumorphicTextStyle(
                                              fontSize: 26,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            style: NeumorphicStyle(
                                                depth: 1,
                                                intensity: 1,
                                                shadowLightColor: Colors.white,
                                                color: Colors.blue),
                                          ),
                                          Container(
                                            margin: EdgeInsets.only(
                                                left: 10, right: 10),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: <Widget>[
                                                NeumorphicText(
                                                  state.mediaItems[index]
                                                      .englishName
                                                      .trim(),
                                                  textStyle:
                                                      NeumorphicTextStyle(
                                                    fontSize: 20,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                  style: NeumorphicStyle(
                                                      depth: 0,
                                                      intensity: 1,
                                                      shadowLightColor:
                                                          Colors.white38,
                                                      color: Colors.blueGrey),
                                                ),
                                                NeumorphicText(
                                                  state.mediaItems[index]
                                                      .englishNameTranslation,
                                                  textStyle:
                                                      NeumorphicTextStyle(
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                  style: NeumorphicStyle(
                                                      depth: 0,
                                                      intensity: 1,
                                                      shadowLightColor:
                                                          Colors.white38,
                                                      color: Colors.blueGrey),
                                                )
                                              ],
                                            ),
                                          )
                                        ],
                                      )
                                    ],
                                  ),
                                  onPressed: () {},
                                  style: NeumorphicStyle(
                                      shadowLightColor: Colors.white38,
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
            ));
          },
        ),
      ),
    );
  }
}
