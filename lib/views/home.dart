import 'package:flutter/material.dart';
import 'package:wistream/constants.dart';
import 'package:hive/hive.dart';
import 'package:animations/animations.dart';
import 'package:html/parser.dart';
import 'package:http/http.dart' as http;
import 'package:wistream/views/chewie_player.dart';

class Home extends StatefulWidget {
  final int darkMode;
  final Box<dynamic> box;
  Home(this.darkMode, this.box);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int count = 0;

  TextEditingController source = TextEditingController(text: '');

  String currURL = '';

  late List currList;

  Future<void> fetchVideos() async {
    if (currURL.isNotEmpty) {
      http.Response response = await http.get(Uri.parse(currURL));
      if (response.statusCode == 200) {
        var document = parse(response.body);
        currList = document.getElementsByTagName('a');
        setState(() {
          if (currList.last.innerHtml.toString() == 'ecstatic')
            currList.removeLast();
        });
        // String nextUrl =
        //     document.getElementsByTagName('a').first.innerHtml.toString();
        // http.Response resp =
        //     await http.get(Uri.parse('http://192.168.2.7:8080/' + nextUrl));
        // var docu = parse(resp.body);
        // print(docu.getElementsByTagName('a').elementAt(2).innerHtml);
      } else {
        print(response.reasonPhrase);
      }
    } else {
      setState(() {
        currList = [];
      });
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.window.onPlatformBrightnessChanged = () {
      if (widget.darkMode == 2) widget.box.put('darkMode', 2);
    };
    fetchVideos();
  }

  @override
  Widget build(BuildContext context) {
    bool gridview = widget.box.get('gridview', defaultValue: true);
    return Scaffold(
      appBar: AppBar(
        key: ValueKey(1),
        toolbarHeight: 88,
        title: Row(
          children: [
            Container(
              color: Colors.transparent,
              child: Center(
                child: Tooltip(
                  message: 'Source URL',
                  child: InkWell(
                    onTap: () {
                      String sourceTemp = source.text;
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return SimpleDialog(
                            title: Text(
                              (source.text.isEmpty ? 'Set' : 'Change') +
                                  ' Source URL',
                            ),
                            children: [
                              Padding(
                                padding: const EdgeInsets.fromLTRB(
                                    24, 16.0, 24.0, 0),
                                child: TextField(
                                  cursorColor:
                                      Theme.of(context).primaryColor == kGlacier
                                          ? kMatte
                                          : kGlacier,
                                  controller: source,
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(),
                                    hintText: "Source URL",
                                  ),
                                  keyboardType: TextInputType.url,
                                  onChanged: (val) {
                                    currURL = val;
                                  },
                                ),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(0, 16.0, 16.0, 0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    TextButton(
                                      onPressed: () {
                                        source.text = sourceTemp;
                                        Navigator.of(context).pop();
                                      },
                                      child: Text('CANCEL'),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                        if (source.text.isNotEmpty &&
                                            source.text.endsWith('/')) {
                                          source.text = source.text.substring(
                                              0, source.text.length - 1);
                                          currURL = source.text;
                                          print(currURL);
                                        }
                                        fetchVideos();
                                      },
                                      child: Text(source.text.isEmpty
                                          ? 'SET'
                                          : 'CHANGE'),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          );
                        },
                      );
                    },
                    child: SizedBox(
                      width: 48,
                      height: 48,
                      child: Card(
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          source.text.isEmpty
                              ? Icons.cast
                              : Icons.cast_connected,
                          color: Theme.of(context).iconTheme.color,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(
              width: 16,
            ),
            Text(
              "WiStream",
              style: Theme.of(context).textTheme.headline4,
            ),
          ],
        ),
        actions: [
          Container(
            color: Colors.transparent,
            child: Center(
              child: Tooltip(
                message: !gridview ? "Grid View" : "List View",
                child: InkWell(
                  onTap: () {
                    widget.box.put('gridview', !gridview);
                  },
                  child: SizedBox(
                    width: 48,
                    height: 48,
                    child: Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        !gridview
                            ? Icons.grid_view_outlined
                            : Icons.view_agenda_outlined,
                        color: Theme.of(context).iconTheme.color,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(
            width: 8,
          ),
          Container(
            color: Colors.transparent,
            child: Center(
              child: Tooltip(
                message: widget.darkMode == 2
                    ? 'System Default'
                    : (widget.darkMode == 1 ? 'Dark Mode' : 'Light Mode'),
                child: InkWell(
                  onTap: () {
                    widget.box.put(
                        'darkMode',
                        widget.darkMode == 1
                            ? 2
                            : (widget.darkMode == 2 ? 0 : 1));
                  },
                  child: SizedBox(
                    width: 48,
                    height: 48,
                    child: Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        widget.darkMode == 2
                            ? Icons.devices_outlined
                            : (widget.darkMode == 1
                                ? Icons.dark_mode_outlined
                                : Icons.light_mode_outlined),
                        color: Theme.of(context).iconTheme.color,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(
            width: 16,
          ),
        ],
        elevation: 0,
      ),
      body: source.text.isEmpty
          ? Center(
              child: Text('Add a Source URL'),
            )
          : PageTransitionSwitcher(
              transitionBuilder: (
                Widget child,
                Animation<double> animation,
                Animation<double> secondaryAnimation,
              ) {
                return FadeThroughTransition(
                  animation: animation,
                  secondaryAnimation: secondaryAnimation,
                  child: child,
                  fillColor: Theme.of(context).primaryColor,
                );
              },
              duration: Duration(milliseconds: 200),
              child: gridview
                  ? AnimatedSwitcher(
                      key: ValueKey<int>(14),
                      duration: const Duration(milliseconds: 200),
                      transitionBuilder:
                          (Widget child, Animation<double> animation) {
                        return FadeTransition(child: child, opacity: animation);
                      },
                      child: Container(
                        key: ValueKey<int>(count == 1 ? --count : ++count),
                        child: Container(
                          key: PageStorageKey<String>('grid'),
                          child: GridView.builder(
                            padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
                            itemCount: currList.length,
                            physics: BouncingScrollPhysics(),
                            gridDelegate:
                                new SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisSpacing: 4,
                              mainAxisSpacing: 4,
                              crossAxisCount:
                                  MediaQuery.of(context).size.width ~/ 175,
                            ),
                            itemBuilder: (BuildContext context, int index) {
                              return InkWell(
                                onTap: () {
                                  if (currList[index]
                                      .innerHtml
                                      .toString()
                                      .endsWith('/')) {
                                    currURL = source.text +
                                        currList[index].attributes['href'];
                                    fetchVideos();
                                  }
                                  if (currList[index]
                                      .innerHtml
                                      .toString()
                                      .endsWith('.mp4')) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => ChewiePlayer(
                                            source.text +
                                                currList[index]
                                                    .attributes['href'],
                                            currList[index].innerHtml),
                                      ),
                                    );
                                  }
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(4.0),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: currList[index]
                                              .innerHtml
                                              .toString()
                                              .endsWith('../')
                                          ? Theme.of(context).cardColor
                                          : (currList[index]
                                                  .innerHtml
                                                  .toString()
                                                  .endsWith('/')
                                              ? holder
                                              : notes[index % 8]),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(12.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          if (currList[index]
                                              .innerHtml
                                              .toString()
                                              .endsWith('../'))
                                            RotatedBox(
                                                quarterTurns: 2,
                                                child: Icon(
                                                    Icons
                                                        .subdirectory_arrow_right,
                                                    size: 64)),
                                          Text(
                                            currList[index]
                                                    .innerHtml
                                                    .toString()
                                                    .endsWith('../')
                                                ? 'Go Back'
                                                : currList[index].innerHtml,
                                            style: currList[index]
                                                    .innerHtml
                                                    .toString()
                                                    .endsWith('../')
                                                ? Theme.of(context)
                                                    .textTheme
                                                    .headline5!
                                                : Theme.of(context)
                                                    .textTheme
                                                    .headline6!
                                                    .copyWith(
                                                      color: kMatte,
                                                    ),
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: MediaQuery.of(context)
                                                            .size
                                                            .width ~/
                                                        100 >
                                                    3
                                                ? 3
                                                : MediaQuery.of(context)
                                                        .size
                                                        .width ~/
                                                    100,
                                          ),
                                          if (!currList[index]
                                              .innerHtml
                                              .toString()
                                              .endsWith('../'))
                                            Row(
                                              children: [
                                                if (currList[index]
                                                    .innerHtml
                                                    .toString()
                                                    .endsWith('/'))
                                                  Icon(Icons.folder,
                                                      color: kShadow, size: 40),
                                                if (currList[index]
                                                    .innerHtml
                                                    .toString()
                                                    .endsWith('.mp4'))
                                                  Row(
                                                    children: [
                                                      Icon(Icons.smart_display,
                                                          color: kShadow),
                                                      Text(
                                                        'MP4',
                                                        style: Theme.of(context)
                                                            .textTheme
                                                            .bodyText1!
                                                            .copyWith(
                                                              color: kMatte,
                                                            ),
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                    ],
                                                  ),
                                              ],
                                            )
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    )
                  : AnimatedSwitcher(
                      key: ValueKey<int>(15),
                      duration: const Duration(milliseconds: 200),
                      transitionBuilder:
                          (Widget child, Animation<double> animation) {
                        return FadeTransition(child: child, opacity: animation);
                      },
                      child: Container(
                        key: ValueKey<int>(count == 1 ? --count : ++count),
                        child: Container(
                          key: PageStorageKey<String>('list'),
                          child: ListView.builder(
                            padding: EdgeInsets.fromLTRB(16, 0, 16, 0),
                            itemCount: 10,
                            physics: BouncingScrollPhysics(),
                            itemBuilder: (BuildContext context, int index) {
                              return Container(
                                child: Text('hi'),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
            ),
    );
  }
}
