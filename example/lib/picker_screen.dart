import 'dart:convert';
import 'dart:core';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kang_image_picker/kang_image_picker.dart';
import 'package:kang_image_picker/model/photo_pick_result.dart';
import 'package:kang_image_picker/model/picker_configuration.dart';
import 'package:kang_image_picker/model/video_pick_result.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:video_player/video_player.dart';

class PickerScreen extends StatefulWidget {
  const PickerScreen({super.key});

  @override
  State<PickerScreen> createState() => _PickerScreenState();
}

class _PickerScreenState extends State<PickerScreen> {
  String? _version;

  final List<FileImage> _selectedImageList = [];
  final List<String> _selectedImagePathList = [];
  VideoPickResult? _selectedVideoResult;

  VideoPlayerController? _playerController;

  @override
  void initState() {
    super.initState();
    getPlatformVersion();
  }

  @override
  void dispose() {
    _playerController?.dispose();
    _playerController = null;
    super.dispose();
  }

  void getPlatformVersion() async {
    _version = await KangImagePicker.getPlatformVersion();
    if (_version != null) {
      setState(() {});
    }
  }

  void openDialog() {
    showDialog(
      context: context,
      barrierColor: Colors.black54,
      builder: (BuildContext context) {
        return PhotoViewGallery.builder(
          scrollPhysics: const BouncingScrollPhysics(),
          backgroundDecoration: const BoxDecoration(
            color: Colors.black54,
          ),
          builder: (BuildContext ic, int index) {
            return PhotoViewGalleryPageOptions(
              onTapDown: (_, __, ___) {
                Navigator.of(ic).pop();
              },
              imageProvider: _selectedImageList.elementAt(index),
              tightMode: true,
              initialScale: PhotoViewComputedScale.contained * 0.8,
              heroAttributes: PhotoViewHeroAttributes(tag: index.toString()),
            );
          },
          itemCount: _selectedImageList.length,
          loadingBuilder: (context, ImageChunkEvent? event) => Center(
            child: SizedBox(
              width: 20.0,
              height: 20.0,
              child: CircularProgressIndicator(
                value: event == null
                    ? 0
                    : event.cumulativeBytesLoaded / event.expectedTotalBytes!,
              ),
            ),
          ),
          // backgroundDecoration: widget.backgroundDecoration,
          // pageController: widget.pageController,
          // onPageChanged: onPageChanged,
        );
      },
    );
  }

  void showMsg(String title, String? content) {
    showDialog<void>(
      context: context,
      barrierDismissible: true,
      // false = user must tap button, true = tap outside dialog
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(title),
          content: Text(content ?? ''),
          actions: <Widget>[
            TextButton(
              child: const Text('好的'),
              onPressed: () {
                Navigator.of(dialogContext).pop(); // Dismiss alert dialog
              },
            ),
          ],
        );
      },
    );
  }

  // void selectOne() async {
  //   try {
  //     final resultList = await KangImagePicker.selectSinglePhoto(
  //       configuration: const PickerConfiguration(
  //         mediaType: PickerMediaType.photo,
  //         showsPhotoFilters: true,
  //         startOnScreen: PickerScreenEnum.library,
  //         screens: [
  //           PickerScreenEnum.library,
  //           PickerScreenEnum.photo,
  //         ],
  //         cropRatio: 1 / 1,
  //       ),
  //     );
  //     if (path == null) {
  //       print('结果为空');
  //       return;
  //     }
  //     _selectedImagePathList.add(path);
  //     _selectedImageList.add(FileImage(File(path)));
  //     setState(() {});
  //   } on PlatformException catch (e) {
  //     print('出错了，${e}');
  //   }
  // }

  void selectMulti() async {
    try {
      final res = await KangImagePicker.selectMultiPhotos(
        configuration: const PickerConfiguration(
          mediaType: PickerMediaType.photo,
          showsPhotoFilters: true,
          startOnScreen: PickerScreenEnum.photo,
          screens: [
            PickerScreenEnum.photo,
            PickerScreenEnum.library,
          ],
          cropRatio: 16 / 9,
          maxNumberOfItems: 9,
        ),
      );
      if (res == null) {
        print('结果为空');
        return;
      }
      for (PhotoPickResult pickResult in res) {
        print('图片选择结果：$pickResult');
        _selectedImagePathList.add(pickResult.path);
        _selectedImageList.add(FileImage(File(pickResult.path)));
      }
      setState(() {});
    } on PlatformException catch (e) {
      print('出错了，${e}');
    }
  }

  void selectVideo() async {
    try {
      await _playerController?.dispose();
      _playerController = null;
      _selectedVideoResult = await KangImagePicker.selectVideo(
        configuration: const PickerConfiguration(
          mediaType: PickerMediaType.video,
          showsPhotoFilters: true,
          startOnScreen: PickerScreenEnum.video,
          screens: [
            PickerScreenEnum.library,
            PickerScreenEnum.video,
          ],
          maxNumberOfItems: 1,
          videoRecordingTimeLimit: 30,
          trimmerMaxDuration: 30,
        ),
      );
      print('视频选择结果：$_selectedVideoResult');
      if (_selectedVideoResult == null) {
        return;
      }
      _playerController = VideoPlayerController.file(File(
        _selectedVideoResult!.videoPath,
      ));
      await _playerController!.initialize();
      setState(() {});
      await _playerController!.play();
    } on PlatformException catch (e) {
      print('出错了，${e}');
    }
  }

  void selectMultiVideo() async {
    try {
      await _playerController?.dispose();
      _playerController = null;
      final res = await KangImagePicker.selectMultiVideo(
        configuration: const PickerConfiguration(
          mediaType: PickerMediaType.video,
          showsPhotoFilters: true,
          startOnScreen: PickerScreenEnum.video,
          screens: [
            PickerScreenEnum.library,
            PickerScreenEnum.video,
          ],
          maxNumberOfItems: 6,
          videoRecordingTimeLimit: 30,
          trimmerMaxDuration: 30,
        ),
      );
      print('视频选择结果：${res?.length} ');
      res?.forEach((element) => print(element));
      if (res == null || res.isEmpty) {
        return;
      }
      _selectedVideoResult = res.first;
      _playerController = VideoPlayerController.file(File(
        _selectedVideoResult!.videoPath,
      ));
      await _playerController!.initialize();
      setState(() {});
      await _playerController!.play();
    } on PlatformException catch (e) {
      print('出错了，${e}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Kang Picker ${_version ?? ''}'),
        actions: [
          TextButton.icon(
            onPressed: () async {
              await _playerController?.dispose();
              setState(() {
                _playerController = null;
                _selectedVideoResult = null;
                _selectedImagePathList.clear();
                _selectedImageList.clear();
              });
            },
            icon: const Icon(Icons.clear),
            label: Text('清除图片'),
            style: const ButtonStyle(
              foregroundColor: MaterialStatePropertyAll(Colors.white),
            ),
          ),
        ],
      ),
      body: Flex(
        direction: Axis.vertical,
        children: [
          Flexible(
            child: SizedBox(
              width: MediaQuery.of(context).size.width,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Column(
                      children: [
                        // _button('选择单个图片', selectOne, color: Colors.pinkAccent),
                        _button(
                          '选择多个图片',
                          selectMulti,
                          color: Colors.indigoAccent,
                        ),
                        _button('选择视频', selectVideo, color: Colors.greenAccent),
                        _button(
                          '选择多个视频',
                          selectMultiVideo,
                          color: Colors.green,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (_selectedImageList.isNotEmpty) _buildSelectedAssetsListView(),
          if (_selectedVideoResult != null) _buildVideoPlayView(),
          if (_selectedImagePathList.isNotEmpty) _buildSuccessPathListView(),
          if (_selectedVideoResult != null) _buildVideoResultView(),
        ],
      ),
    );
  }

  Widget _button(String label, VoidCallback onTap, {Color? color}) {
    return ElevatedButton(
      onPressed: onTap,
      style: ButtonStyle(
        backgroundColor: MaterialStatePropertyAll(
          color ?? Colors.deepPurpleAccent,
        ),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 16),
      ),
    );
  }

  Widget _buildVideoResultView() {
    Widget? leading = Image.file(File(_selectedVideoResult!.thumbnailPath));
    double aspectRatio = _selectedVideoResult!.thumbnailWidth /
        _selectedVideoResult!.thumbnailHeight;
    leading = AspectRatio(
      aspectRatio: aspectRatio,
      child: leading,
    );
    return Flexible(
      child: ListTile(
        leading: leading,
        title: SelectableText(
          _selectedVideoResult!.toString(),
          style: const TextStyle(
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildSuccessPathListView() {
    return Flexible(
      child: ListView.separated(
        shrinkWrap: true,
        itemBuilder: (_, int index) {
          final path = _selectedImagePathList.elementAt(index);
          return ListTile(
            title: SelectableText(
              '${index + 1} - $path',
              style: const TextStyle(
                fontSize: 14,
              ),
            ),
          );
        },
        itemCount: _selectedImagePathList.length,
        separatorBuilder: (BuildContext context, int index) {
          return const Divider();
        },
      ),
    );
  }

  Widget _buildVideoPlayView() {
    return Flexible(
      flex: 2,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: AspectRatio(
          aspectRatio: _playerController!.value.aspectRatio,
          child: Stack(
            children: [
              VideoPlayer(_playerController!),
              Align(
                alignment: Alignment.bottomLeft,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ValueListenableBuilder<VideoPlayerValue>(
                    valueListenable: _playerController!,
                    builder: (_, VideoPlayerValue value, child) {
                      final second = value.position.inSeconds.round();
                      return Text(
                        '00:${second < 10 ? '0$second' : second}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                        ),
                      );
                    },
                  ),
                ),
              ),
              GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: () async {
                  if (_playerController?.value.isPlaying ?? false) {
                    await _playerController?.pause();
                    setState(() {});
                  } else {
                    await _playerController?.play();
                    setState(() {});
                  }
                },
                child: SizedBox.expand(
                  child: ValueListenableBuilder<VideoPlayerValue>(
                    valueListenable: _playerController!,
                    builder: (_, value, __) {
                      return ColoredBox(
                        color: value.isPlaying
                            ? Colors.transparent
                            : Colors.black38,
                        child: value.isPlaying
                            ? null
                            : const Center(
                                child: Icon(
                                  Icons.play_arrow,
                                  color: Colors.white70,
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
      ),
    );
  }

  //
  Widget _buildSelectedAssetsListView() {
    return Flexible(
      child: GridView.builder(
        shrinkWrap: true,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        itemCount: _selectedImageList.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
        ),
        itemBuilder: (BuildContext _, int index) {
          final FileImage asset = _selectedImageList.elementAt(index);
          return Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 8.0,
              vertical: 16.0,
            ),
            child: Stack(
              alignment: Alignment.center,
              clipBehavior: Clip.none,
              children: [
                GestureDetector(
                  onTap: openDialog,
                  child: RepaintBoundary(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
                      child: Image(
                        image: asset,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  right: -8.0,
                  top: -8.0,
                  child: IconButton(
                    onPressed: () {
                      setState(() {
                        _selectedImageList.removeAt(index);
                      });
                    },
                    icon: Icon(Icons.cancel),
                    iconSize: 18,
                    color: Colors.pinkAccent,
                    padding: EdgeInsets.all(0.0),
                    alignment: Alignment.topRight,
                  ),
                )
              ],
            ),
          );
        },
      ),
    );
  }

  String strToBase64(String str) {
    //base64编码 - 转utf8
    return base64.encode(utf8.encode(str));
  }
}
