import 'dart:convert';
import 'dart:core';

import 'package:flutter/material.dart';
import 'package:kang_image_picker/kang_image_picker.dart';

class PickerScreen extends StatefulWidget {
  const PickerScreen({super.key});

  @override
  State<PickerScreen> createState() => _PickerScreenState();
}

class _PickerScreenState extends State<PickerScreen> {
  String? _version;

  @override
  void initState() {
    super.initState();
    getPlatformVersion();
  }

  void getPlatformVersion() async {
    _version = await KangImagePicker.getPlatformVersion();
    if (_version != null) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _callPicker() async {}

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

  void initSdk() async {
    await KangImagePicker.openPicker();
  }

  void uploadSingle() async {}

  void uploadMultiSync() async {}

  void uploadAvatarWithCallbackSync() async {}

  void uploadPostWithCallbackSync() async {}

  void uploadTopicWithCallbackSync() async {}

  void uploadFeedbackWithCallbackSync() async {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Kang Picker ${_version ?? ''}'),
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
                    _button('选择图片', initSdk, color: Colors.pinkAccent),
                  ],
                ),
              ),
            ),
          ),
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

  // Widget _buildSuccessPathListView() {
  //   return Flexible(
  //     child: ListView.separated(
  //       shrinkWrap: true,
  //       itemBuilder: (_, int index) {
  //         final path = _uploadSuccessPathList.elementAt(index);
  //         return ListTile(
  //           title: SelectableText(
  //             '${index + 1} - $path',
  //             style: const TextStyle(
  //               fontSize: 14,
  //             ),
  //           ),
  //         );
  //       },
  //       itemCount: _uploadSuccessPathList.length,
  //       separatorBuilder: (BuildContext context, int index) {
  //         return const Divider();
  //       },
  //     ),
  //   );
  // }
  //
  // Widget _buildSelectedAssetsListView() {
  //   return Flexible(
  //     child: GridView.builder(
  //       shrinkWrap: true,
  //       physics: const BouncingScrollPhysics(),
  //       padding: const EdgeInsets.symmetric(horizontal: 8.0),
  //       itemCount: selectedAssets.length,
  //       gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
  //         crossAxisCount: 3,
  //       ),
  //       itemBuilder: (BuildContext _, int index) {
  //         final AssetEntity asset = selectedAssets.elementAt(index);
  //         final double? process = _uploadProcess?.elementAt(index)['process'];
  //         final bool shouldHide = process != null && process >= 1.0;
  //         // print('process:$process');
  //         // print('shouldShowProcess:$shouldShowProcess');
  //         return Padding(
  //           padding: const EdgeInsets.symmetric(
  //             horizontal: 8.0,
  //             vertical: 16.0,
  //           ),
  //           child: Column(
  //             mainAxisSize: MainAxisSize.min,
  //             children: [
  //               Expanded(
  //                 child: Stack(
  //                   alignment: Alignment.center,
  //                   clipBehavior: Clip.none,
  //                   children: [
  //                     RepaintBoundary(
  //                       child: ClipRRect(
  //                         borderRadius: BorderRadius.circular(8.0),
  //                         child: Image(image: AssetEntityImageProvider(asset)),
  //                       ),
  //                     ),
  //                     Positioned(
  //                       right: -8.0,
  //                       top: -8.0,
  //                       child: IconButton(
  //                         onPressed: () {
  //                           setState(() {
  //                             selectedAssets.removeAt(index);
  //                             _uploadProcess?.removeAt(index);
  //                           });
  //                         },
  //                         icon: Icon(Icons.cancel),
  //                         iconSize: 18,
  //                         color: Colors.pinkAccent,
  //                         padding: EdgeInsets.all(0.0),
  //                         alignment: Alignment.topRight,
  //                       ),
  //                     )
  //                   ],
  //                 ),
  //               ),
  //               const SizedBox(
  //                 height: 5.0,
  //               ),
  //               LinearProgressIndicator(
  //                 color: Colors.pinkAccent,
  //                 value: process,
  //                 minHeight: 3.0,
  //                 backgroundColor: Colors.white70,
  //               )
  //             ],
  //           ),
  //         );
  //       },
  //     ),
  //   );
  // }

  String strToBase64(String str) {
    //base64编码 - 转utf8
    return base64.encode(utf8.encode(str));
  }
}
