import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/landmark_provider.dart';
import '../models/landmark.dart';

class LandmarkListScreen extends StatefulWidget {
  @override
  _LandmarkListScreenState createState() => _LandmarkListScreenState();
}

class _LandmarkListScreenState extends State<LandmarkListScreen> {
  double _minScore = 0;
  bool _sortByScore = false;

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<LandmarkProvider>(context);
    // Use activeLandmarks to exclude soft-deleted ones
    List<Landmark> landmarks = provider.activeLandmarks;

    // Filter by score
    landmarks = landmarks.where((l) => l.score >= _minScore).toList();

    // Sort by score if enabled
    if (_sortByScore) {
      landmarks.sort((a, b) => b.score.compareTo(a.score));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Landmarks List'),
        actions: [
          IconButton(
            icon: Icon(_sortByScore ? Icons.sort : Icons.sort_by_alpha),
            onPressed: () {
              setState(() {
                _sortByScore = !_sortByScore;
              });
            },
          ),
          IconButton(
            icon: Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
        ],
      ),
      body: provider.isLoading 
        ? Center(child: CircularProgressIndicator())
        : RefreshIndicator(
            onRefresh: () => provider.fetchAndSetLandmarks(),
            child: landmarks.isEmpty 
              ? ListView(
                  children: [
                    SizedBox(height: 200),
                    Center(child: Text('No landmarks found.')),
                  ],
                )
              : ListView.builder(
              itemCount: landmarks.length,
              itemBuilder: (ctx, i) {
                final l = landmarks[i];
                return Dismissible(
                  key: Key(l.id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: EdgeInsets.only(right: 20),
                    child: Icon(Icons.delete, color: Colors.white),
                  ),
                  confirmDismiss: (direction) async {
                    return await showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: Text('Delete Landmark?'),
                        content: Text('This will soft delete "${l.title}".'),
                        actions: [
                          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: Text('No')),
                          TextButton(onPressed: () => Navigator.of(ctx).pop(true), child: Text('Yes')),
                        ],
                      ),
                    );
                  },
                  onDismissed: (direction) async {
                    try {
                      await provider.deleteLandmark(l.id);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('${l.title} deleted')),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error deleting: $e')),
                      );
                    }
                  },
                  child: Card(
                    margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundImage: NetworkImage(l.image),
                        onBackgroundImageError: (_, __) => Icon(Icons.broken_image),
                      ),
                      title: Text(l.title),
                      subtitle: Text('Score: ${l.score.toStringAsFixed(1)} | Visits: ${l.visitCount}'),
                      trailing: Text('${l.avgDistance.toStringAsFixed(1)} km'),
                    ),
                  ),
                );
              },
            ),
      ),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Filter by Minimum Score'),
        content: StatefulBuilder(
          builder: (context, setDialogState) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Min Score: ${_minScore.toInt()}'),
              Slider(
                value: _minScore,
                min: 0,
                max: 100,
                divisions: 10,
                label: _minScore.round().toString(),
                onChanged: (value) {
                  setDialogState(() {
                    _minScore = value;
                  });
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            child: Text('Clear'),
            onPressed: () {
              setState(() {
                _minScore = 0;
              });
              Navigator.of(ctx).pop();
            },
          ),
          ElevatedButton(
            child: Text('Apply'),
            onPressed: () {
              setState(() {});
              Navigator.of(ctx).pop();
            },
          ),
        ],
      ),
    );
  }
}
