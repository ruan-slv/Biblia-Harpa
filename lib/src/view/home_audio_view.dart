import 'package:biblia_e_harpa/src/view/bible_feature.dart';
import 'package:biblia_e_harpa/src/view/harp_audio_wrapper.dart';
import 'package:biblia_e_harpa/src/view/playlist_view.dart';
import 'package:flutter/material.dart';
import 'component/app_bar_component.dart';

class HomeAudioView extends StatefulWidget {
  const HomeAudioView({super.key});

  @override
  State<HomeAudioView> createState() => _HomeAudioViewState();
}

class _HomeAudioViewState extends State<HomeAudioView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: CustomAppBar(
        automaticallyImplyLeading: true,
        title: "Áudios",
        centerTitle: false,
        tabBar: TabBar(
          controller: _tabController,
          labelColor: Theme.of(context)
              .colorScheme
              .secondary,
          unselectedLabelColor: Theme.of(context)
              .colorScheme
              .onSurface,
          indicatorColor: Theme.of(context)
              .colorScheme
              .secondary,
          indicatorSize: TabBarIndicatorSize.tab,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal),
          tabs: const [
            Tab(text: "Bíblia"),
            Tab(text: "Harpa"),
            Tab(text: "Personalizados"),
          ],
        ),
      ),
      body: TabBarView(
          controller: _tabController,
          children: [
            BibleFeature.bibleAudiosWrapper(),
            const HarpAudioWrapper(),
            const PlaylistView(),
          ],
        ),
    );
  }
}
