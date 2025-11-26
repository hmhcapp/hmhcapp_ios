import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:google_fonts/google_fonts.dart';

class InstallationVideoScreen extends StatefulWidget {
  const InstallationVideoScreen({super.key});

  @override
  State<InstallationVideoScreen> createState() => _InstallationVideoScreenState();
}

class _InstallationVideoScreenState extends State<InstallationVideoScreen> {
  late VideoPlayerController _videoPlayerController;
  ChewieController? _chewieController;
  
  // State to track if video is initialized to show a loader
  bool _isInitialized = false; 

  @override
  void initState() {
    super.initState();
    initializePlayer();
  }

  Future<void> initializePlayer() async {
    // 1. Create the video player controller with your asset
    _videoPlayerController = VideoPlayerController.asset(
      'assets/videos/Heat_Mat_Installation_Video_Compressed.mp4',
    );

    await _videoPlayerController.initialize();

    // 2. Create the Chewie controller (provides the UI wrappers)
    _chewieController = ChewieController(
      videoPlayerController: _videoPlayerController,
      autoPlay: true,
      looping: false,
      aspectRatio: _videoPlayerController.value.aspectRatio,
      // Customize the UI colors to match your app theme if desired
      materialProgressColors: ChewieProgressColors(
        playedColor: const Color(0xFFE9882A), // Matches your new button
        handleColor: const Color(0xFFE9882A),
        backgroundColor: Colors.grey,
        bufferedColor: Colors.white,
      ),
      placeholder: Container(
        color: Colors.black,
      ),
      autoInitialize: true,
    );

    setState(() {
      _isInitialized = true;
    });
  }

  @override
  void dispose() {
    // IMPORTANT: Dispose controllers to free resources
    _videoPlayerController.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text('Installation Video', style: GoogleFonts.raleway()),
        backgroundColor: const Color(0xFF333333),
        foregroundColor: Colors.white,
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      body: Center(
        child: _isInitialized && _chewieController != null
            ? Chewie(controller: _chewieController!)
            : const CircularProgressIndicator(color: Color(0xFFE9882A)),
      ),
    );
  }
}
