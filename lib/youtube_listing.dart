import 'package:flutter/material.dart';
import 'package:planetcombo/common/widgets.dart';
import 'package:planetcombo/controllers/localization_controller.dart';
import 'package:flutter_svg/svg.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

class YouTubeVideosPage extends StatefulWidget {
  const YouTubeVideosPage({Key? key}) : super(key: key);

  @override
  _YouTubeVideosPageState createState() => _YouTubeVideosPageState();
}

class _YouTubeVideosPageState extends State<YouTubeVideosPage> {
  final List<Map<String, String>> videos = [
    {
      'id': 'eJd5DM0irk8',
      'title': 'How to login | Planetcombo.com',
      'description': 'Learn how to easily log in to Planetcombo.com. A step-by-step tutorial showing user registration, login process, and account features.',
      'thumbnail': 'https://static.vecteezy.com/system/resources/thumbnails/005/048/106/small/black-and-yellow-grunge-modern-thumbnail-background-free-vector.jpg',
    },
    {
      'id': 'pupzTEBZWeI',
      'title': 'How to create a chart | Planetcombo.com',
      'description': 'Learn how to easily crate a chart in to Planetcombo.com. A step-by-step tutorial',
      'thumbnail': 'https://static.vecteezy.com/system/resources/thumbnails/005/048/106/small/black-and-yellow-grunge-modern-thumbnail-background-free-vector.jpg',
    },
    {
      'id': 'PeUf6HRt5pA',
      'title': 'How to make payments | Planetcombo.com',
      'description': 'Learn how to easily pay in INR in to Planetcombo.com. A step-by-step tutorial',
      'thumbnail': 'https://static.vecteezy.com/system/resources/thumbnails/005/048/106/small/black-and-yellow-grunge-modern-thumbnail-background-free-vector.jpg',
    },
  ];

  Future<void> showYouTubePopup(BuildContext context, String videoId) async {
    final controller = YoutubePlayerController.fromVideoId(
      videoId: videoId,
      autoPlay: true,
      params: const YoutubePlayerParams(
        enableJavaScript: true,
        enableCaption: false,
        showControls: true,
        showFullscreenButton: true,
        mute: false,
      ),
    );

    final size = MediaQuery.of(context).size;
    final isLandscape = size.width > size.height;
    final isMobile = size.width < 600;

    await showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: isMobile
            ? const EdgeInsets.all(0) // Full screen for mobile
            : const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              children: [
                Container(
                  width: isMobile ? size.width : size.width * 0.8,
                  height: isMobile
                      ? isLandscape
                      ? size.height
                      : size.width * 9 / 16
                      : size.height * 0.7,
                  color: Colors.black,
                  child: YoutubePlayer(
                    controller: controller,
                    aspectRatio: 16 / 9,
                  ),
                ),
                if (!isLandscape) Positioned(
                  top: 8,
                  right: 8,
                  child: IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () {
                      controller.close();
                      Navigator.of(context).pop();
                    },
                  ),
                ),
              ],
            ),
            if (!isLandscape && !isMobile) // Don't show button in landscape or mobile
              Container(
                color: Colors.black,
                padding: const EdgeInsets.all(8),
                child: TextButton(
                  onPressed: () {
                    controller.close();
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    LocalizationController.getInstance().getTranslatedValue("Close"),
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget buildVideoCard(Map<String, String> video, bool isMobile) {
    return Container(
      margin: EdgeInsets.symmetric(
          horizontal: isMobile ? 12 : 16,
          vertical: isMobile ? 6 : 8
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () => showYouTubePopup(context, video['id']!),
          child: Padding(
            padding: EdgeInsets.all(isMobile ? 8 : 12),
            child: Row(
              children: [
                // Thumbnail
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Image.network(
                        video['thumbnail']!,
                        width: isMobile ? 100 : 120,
                        height: isMobile ? 70 : 80,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!
                                  : null,
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: isMobile ? 100 : 120,
                            height: isMobile ? 70 : 80,
                            color: Colors.red[300],
                            child: Icon(Icons.play_circle,
                                size: isMobile ? 32 : 40
                            ),
                          );
                        },
                      ),
                      Container(
                        width: isMobile ? 32 : 40,
                        height: isMobile ? 32 : 40,
                        decoration: BoxDecoration(
                          color: Colors.redAccent.shade400,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.play_arrow,
                          color: Colors.white,
                          size: isMobile ? 20 : 24,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: isMobile ? 12 : 16),
                // Video details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      commonBoldText(
                        text: video['title']!,
                        fontSize: isMobile ? 14 : 16,
                        color: Colors.black87,
                      ),
                      SizedBox(height: isMobile ? 2 : 4),
                      commonText(
                        text: video['description']!,
                        fontSize: isMobile ? 12 : 14,
                        color: Colors.grey[600],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      appBar: GradientAppBar(
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.chevron_left_rounded),
        ),
        title: LocalizationController.getInstance().getTranslatedValue("How to Use"),
        colors: const [Color(0xFFf2b20a), Color(0xFFf34509)],
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/Headletters_background.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: EdgeInsets.all(isMobile ? 12 : 16),
              child: Column(
                children: [
                  SvgPicture.asset(
                    'assets/svg/youtube.svg',
                    width: isMobile ? 40 : 48,
                    height: isMobile ? 40 : 48,
                    color: Colors.white,
                  ),
                  SizedBox(height: isMobile ? 6 : 8),
                  commonBoldText(
                    text: LocalizationController.getInstance().getTranslatedValue("Tutorial Videos"),
                    fontSize: isMobile ? 18 : 20,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
            // Videos List
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: ListView.builder(
                  padding: EdgeInsets.only(
                      top: isMobile ? 12 : 16,
                      bottom: isMobile ? 12 : 16
                  ),
                  itemCount: videos.length,
                  itemBuilder: (context, index) => buildVideoCard(videos[index], isMobile),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}