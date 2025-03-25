import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame_tiled/flame_tiled.dart';
import 'package:flutter_joggernaut_game/actors/player.dart';

class Map extends World {
  final Player player;
  Map({required this.player});

  late TiledComponent map;

  @override
  FutureOr<void> onLoad() async {
    map = await TiledComponent.load('world01.tmx', Vector2.all(16));
    add(map);
    add(player);
    return super.onLoad();
  }
}
