import 'package:flutter/material.dart';
import 'package:flutter_book/notes/note_model.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

extension Video on NoteModel{
  
}

class NoteVideoPlayer extends StatefulWidget {
  const new({super.key});

  @override
  State<NoteVideoPlayer> createState() => _NoteVideoPlayerState();
}

class _NoteVideoPlayerState extends State<NoteVideoPlayer> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    final note = context.read<NoteModel>().entryBeingEdited;
    super.initState();
    //_controller = VideoPlayerController.networkUrl(url)
  }

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}