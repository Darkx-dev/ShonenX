import 'package:flutter/material.dart';
import 'package:nekoflow/data/models/anime_model.dart'; // Adjusted import to use the correct model

class TrendingAnimes extends StatelessWidget {
  final List<TrendingAnime>
      trendingAnimes; // Accepting TrendingAnime list as a parameter

  const TrendingAnimes({Key? key, required this.trendingAnimes})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: trendingAnimes.length,
      itemBuilder: (context, index) {
        final anime = trendingAnimes[index];
        return ListTile(
          leading: CircleAvatar(
            radius: 25,
            backgroundImage: NetworkImage(
                anime.poster), // Using the poster from TrendingAnime
          ),
          title: Text(
            anime.name,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          subtitle: Text(
            anime.jname,
            maxLines: 1,
            style: TextStyle(overflow: TextOverflow.ellipsis),
          ), // Displaying rank from TrendingAnime
          trailing: Text(
            '# ${anime.rank}', // Assuming rating is not available in TrendingAnime
            style: TextStyle(
                color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 17),
          ),
          onTap: () {
            // Navigate to anime details
            Navigator.pushNamed(
              context,
              '/anime-details',
              arguments: anime,
            );
          },
        );
      },
    );
  }
}
