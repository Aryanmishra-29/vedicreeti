import 'package:flutter/material.dart';
import 'realtime_buffer_service.dart';
class MassiveDataScreen extends StatefulWidget {
  const MassiveDataScreen({super.key});
  @override
  State<MassiveDataScreen> createState() => _MassiveDataScreenState();
}
class _MassiveDataScreenState extends State<MassiveDataScreen>
    with WidgetsBindingObserver {
  final RealtimeBufferService _service = RealtimeBufferService();
  final ScrollController _scrollController = ScrollController();
  int _currentMaxRender = 50;
  bool _isAppInBackground = false;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _service.initializeStream('your_massive_table');
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        setState(() {
          _currentMaxRender += 50;
        });
      }
    });
  }
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.hidden) {
      setState(() {
        _isAppInBackground = true;
      });
      print(
        "APP BACKGROUNDED: Suspending active WebSockets and Timers to save memory/battery.",
      );
      _service.dispose();
    } else if (state == AppLifecycleState.resumed) {
      setState(() {
        _isAppInBackground = false;
      });
      _service.initializeStream('your_massive_table');
    }
  }
  @override
  Widget build(BuildContext context) {
    if (_isAppInBackground) {
      return const Scaffold(body: SizedBox.shrink());
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Real-Time Stress Test')),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _service.dataStream,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final allData = snapshot.data!;
          final visibleData = allData.take(_currentMaxRender).toList();
          return ListView.builder(
            controller: _scrollController,
            itemCount: visibleData.length,
            cacheExtent: 500.0,
            addAutomaticKeepAlives: false,
            addRepaintBoundaries: true,
            itemBuilder: (context, index) {
              final item = visibleData[index];
              return ListTile(
                title: Text(item['title'] ?? 'Data Block'),
                subtitle: Text('ID: ${item['id'] ?? index}'),
              );
            },
          );
        },
      ),
    );
  }
  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _service.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}
