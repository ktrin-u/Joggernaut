import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame_tiled/flame_tiled.dart';
import 'package:flutter_joggernaut_game/components/collision_block.dart';
import 'package:flutter_joggernaut_game/components/player.dart';

class Map extends World {
  final String mapName;
  final Player player;
  Map({required this.player, required this.mapName});
  List<CollisionBlock> collisionBlocks = [];

  late TiledComponent map;

  @override
  FutureOr<void> onLoad() async {
    map = await TiledComponent.load('$mapName.tmx', Vector2.all(64));

    add(map);

    final spawnLayer = map.tileMap.getLayer<ObjectGroup>('Spawnpoints');

    if (spawnLayer != null) {
      for (final spawnPoint in spawnLayer.objects) {
        switch (spawnPoint.class_) {
          case 'Player':
            player.position = Vector2(spawnPoint.x, spawnPoint.y);
            add(player);
            break;
          default:
        }
      }
    }

    final collisionLayer = map.tileMap.getLayer<ObjectGroup>('Collisions');

    if (collisionLayer != null) {
      for (final collision in collisionLayer.objects) {
        final wall = CollisionBlock(
          position: Vector2(collision.x, collision.y),
          size: Vector2(collision.width, collision.height),
        );
        collisionBlocks.add(wall);
        add(wall);
      }
    }
    player.collisionBlocks = collisionBlocks;
    return super.onLoad();
  }
}
