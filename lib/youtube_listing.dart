import 'package:flutter/material.dart';
import 'package:planetcombo/common/widgets.dart';
import 'package:planetcombo/controllers/localization_controller.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';
import 'package:flutter_svg/svg.dart';

class YouTubeVideosPage extends StatefulWidget {
  const YouTubeVideosPage({Key? key}) : super(key: key);

  @override
  _YouTubeVideosPageState createState() => _YouTubeVideosPageState();
}

class _YouTubeVideosPageState extends State<YouTubeVideosPage> {
  // Sample video data - Replace with your actual video data
  final List<Map<String, String>> videos = [
    {
      'id': 'c6Akc4UQpwc',
      'title': 'Usability Video - Guide to login | Planetcombo.com',
      'description': 'Learn how to easily log in to Planetcombo.com. A step-by-step tutorial showing user registration, login process, and account features.',
      'thumbnail': 'https://static.vecteezy.com/system/resources/thumbnails/005/048/106/small/black-and-yellow-grunge-modern-thumbnail-background-free-vector.jpg',
    },
    // Add more videos as needed
  ];

  Future<void> showYouTubePopup(BuildContext context, String videoId) async {
    final controller = YoutubePlayerController(
      initialVideoId: videoId,
      params: const YoutubePlayerParams(
        autoPlay: true,
        showControls: true,
      ),
    );

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: SizedBox(
          width: MediaQuery.of(context).size.width * 0.8,
          height: MediaQuery.of(context).size.height * 0.6,
          child: YoutubePlayerIFrame(controller: controller),
        ),
        actions: [
          TextButton(
            onPressed: () {
              controller.close();
              Navigator.of(context).pop();
            },
            child: Text(LocalizationController.getInstance().getTranslatedValue("Close")),
          ),
        ],
      ),
    );
  }

  Widget buildVideoCard(Map<String, String> video) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // Thumbnail
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 120,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.rectangle,
                          image: DecorationImage(
                            image: NetworkImage(
                              video['thumbnail']!,
                              headers: {
                                'Access-Control-Allow-Origin': '*',
                                'Access-Control-Allow-Methods': 'GET',
                              },
                            ),
                            fit: BoxFit.cover,
                            onError: (error, stackTrace) {
                              print('Error loading image: $error');
                            },
                          ),
                        ),
                        child: Image.network(
                            video['thumbnail']!,
                          width: 120,
                          height: 80,
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
                            print('Web image error: $error');
                            return Container(
                              width: 120,
                              height: 80,
                              color: Colors.red[300],
                              child: const Icon(Icons.play_circle, size: 40),
                            );
                          },
                        ),
                      ),
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.redAccent.shade400,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.play_arrow,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                // Video details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      commonBoldText(
                        text: video['title']!,
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                      const SizedBox(height: 4),
                      commonText(
                        text: video['description']!,
                        fontSize: 14,
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
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  SvgPicture.asset(
                    'assets/svg/youtube.svg',
                    width: 48,
                    height: 48,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 8),
                  commonBoldText(
                    text: LocalizationController.getInstance().getTranslatedValue("Tutorial Videos"),
                    fontSize: 20,
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
                  padding: const EdgeInsets.only(top: 16, bottom: 16),
                  itemCount: videos.length,
                  itemBuilder: (context, index) => buildVideoCard(videos[index]),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}