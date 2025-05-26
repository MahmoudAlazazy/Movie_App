import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:movies/core/app_assets.dart';
import 'package:movies/cubit/search_cubit.dart';
import 'package:movies/cubit/states.dart';

import '../widgets/movie_card.dart';

class SearchTab extends StatelessWidget {
  const SearchTab({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SearchCubit(),
      child: SearchView(),
    );
  }
}

class SearchView extends StatelessWidget {
  const SearchView({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 370,
          height: 50,
          margin: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppAssets.gray,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              Padding(
                padding: EdgeInsets.only(left: 10),
                child: SvgPicture.asset(
                  AppAssets.search,
                  width: 20,
                  height: 20,
                ),
              ),
              Expanded(
                child: TextField(
                  style: TextStyle(color: AppAssets.white),
                  decoration: InputDecoration(
                    hintText: 'Search',
                    hintStyle: TextStyle(color: AppAssets.white),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 10),
                  ),
                  cursorColor: AppAssets.primary,
                  onChanged: (query) {
                    context.read<SearchCubit>().searchMovies(query);
                  },
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: BlocBuilder<SearchCubit, SearchState>(
            builder: (context, state) {
              if (state is SearchInitial) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        AppAssets.emptySearch,
                        width: 124,
                        height: 124,
                      ),
                      SizedBox(height: 100),
                    ],
                  ),
                );
              }

              if (state is SearchLoading) {
                return Center(child: CircularProgressIndicator());
              }

              if (state is SearchError) {
                return Center(
                  child: Text(
                    state.message,
                    style: TextStyle(color: Colors.white),
                  ),
                );
              }

              if (state is SearchLoaded) {
                if (state.movies.isEmpty) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        AppAssets.emptySearch,
                        width: 124,
                        height: 124,
                      ),
                      SizedBox(height: 100),
                    ],
                  );
                }

                return GridView.builder(
                  padding: EdgeInsets.all(16),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.7,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: state.movies.length,
                  itemBuilder: (context, index) {
                    return MovieCard(movie: state.movies[index]);
                  },
                );
              }

              return SizedBox();
            },
          ),
        ),
      ],
    );
  }
}

