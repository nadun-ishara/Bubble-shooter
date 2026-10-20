import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/theme/steampunk_theme.dart';
import 'features/bubble_shooter/data/datasources/game_local_datasource.dart';
import 'features/bubble_shooter/data/repositories/game_repository_impl.dart';
import 'features/bubble_shooter/data/repositories/score_repository_impl.dart';
import 'features/bubble_shooter/domain/usecases/aim_cannon_usecase.dart';
import 'features/bubble_shooter/domain/usecases/fire_bubble_usecase.dart';
import 'features/bubble_shooter/domain/usecases/get_high_score_usecase.dart';
import 'features/bubble_shooter/domain/usecases/initialize_game_usecase.dart';
import 'features/bubble_shooter/domain/usecases/save_high_score_usecase.dart';
import 'features/bubble_shooter/domain/usecases/swap_bubble_usecase.dart';
import 'features/bubble_shooter/domain/usecases/update_physics_usecase.dart';
import 'features/bubble_shooter/presentation/bloc/game_bloc.dart';
import 'features/bubble_shooter/presentation/pages/home_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Set portrait orientation for optimal arcade mobile feel
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Dark status bar
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  runApp(const BubbleShooterApp());
}

class BubbleShooterApp extends StatelessWidget {
  final GameBloc? gameBloc;

  const BubbleShooterApp({super.key, this.gameBloc});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        if (gameBloc != null)
          BlocProvider<GameBloc>.value(value: gameBloc!)
        else
          BlocProvider<GameBloc>(
            create: (_) {
              final localDataSource = GameLocalDataSourceImpl();
              final gameRepository = GameRepositoryImpl();
              final scoreRepository = ScoreRepositoryImpl(localDataSource);

              return GameBloc(
                initializeGameUseCase: InitializeGameUseCase(gameRepository),
                aimCannonUseCase: AimCannonUseCase(gameRepository),
                fireBubbleUseCase: FireBubbleUseCase(gameRepository),
                swapBubbleUseCase: SwapBubbleUseCase(gameRepository),
                updatePhysicsUseCase: UpdatePhysicsUseCase(gameRepository),
                getHighScoreUseCase: GetHighScoreUseCase(scoreRepository),
                saveHighScoreUseCase: SaveHighScoreUseCase(scoreRepository),
              );
            },
          ),
      ],
      child: MaterialApp(
        title: 'Chrono Bubble: Clockwork Shooter',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          brightness: Brightness.dark,
          scaffoldBackgroundColor: SteampunkTheme.darkBrassBg,
          colorScheme: const ColorScheme.dark(
            primary: SteampunkTheme.brightGold,
            secondary: SteampunkTheme.polishedBrass,
            surface: SteampunkTheme.deepBronzeBg,
          ),
          fontFamily: 'Roboto',
        ),
        home: const HomePage(),
      ),
    );
  }
}
