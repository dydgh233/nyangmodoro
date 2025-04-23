import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/cat_state.dart';

final catStateProvider = StateProvider<CatAnimationState>((ref) => CatAnimationState.idle);
final focusTimeProvider = StateProvider<int>((ref) => 0);