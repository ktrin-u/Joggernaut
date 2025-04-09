import 'dart:async';
import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame_tiled/flame_tiled.dart';
import 'package:flutter_joggernaut_game/components/collision_block.dart';
import 'package:flutter_joggernaut_game/components/enemy.dart';
import 'package:flutter_joggernaut_game/components/player.dart';
import 'package:flutter_joggernaut_game/joggernaut_game.dart';

class Map extends World with HasGameRef<JoggernautGame> {
  final String mapName;
  final Player player;
  Map({required this.player, required this.mapName});

  late TiledComponent map;
  late TimerComponent enemySpawner;

  @override
  FutureOr<void> onLoad() async {
    super.onLoad();
    map = await TiledComponent.load('$mapName.tmx', Vector2.all(64));
    add(map);

    _spawnObjects();
    _enemySpawner("Torch", 3.0);
    _addCollisions();
  }

  void _spawnObjects() {
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
  }

  void _addCollisions() {
    final collisionLayer = map.tileMap.getLayer<ObjectGroup>('Collisions');

    if (collisionLayer != null) {
      for (final collision in collisionLayer.objects) {
        final wall = CollisionBlock(
          position: Vector2(collision.x, collision.y),
          size: Vector2(collision.width, collision.height),
        );
        add(wall);
      }
    }
  }

  void _enemySpawner(String enemyName, double period) {
    enemySpawner = TimerComponent(
      period: period,
      repeat: true,
      onTick: () => _spawnEnemy(enemyName),
    );

    add(enemySpawner);
  }

  void _spawnEnemy(String enemyName) {
    double minMapX = 1088, maxMapX = 3904; // based on actual map
    double minMapY = 1088, maxMapY = 3904; // based on actual map

    Random random = Random();

    final cameraPosition = gameRef.camera.viewfinder.position;
    final cameraSize = gameRef.size / 2;

    double screenMinX = cameraPosition.x - cameraSize.x;
    double screenMaxX = cameraPosition.x + cameraSize.x;
    double screenMinY = cameraPosition.y - cameraSize.y;
    double screenMaxY = cameraPosition.y + cameraSize.y;

    double x, y;
    double margin = 100;

    if (random.nextBool()) {
      x = random.nextBool() ? (screenMaxX + margin) : (screenMinX - margin);
      y = random.nextDouble() * (maxMapY - minMapY) + minMapY;
    } else {
      x = random.nextDouble() * (maxMapX - minMapX) + minMapX;
      y = random.nextBool() ? (screenMaxY + margin) : (screenMinY - margin);
    }

    // enemies may still spawn in the screen whenever the bounds are visible
    final enemy = Enemy(
      enemy: enemyName,
      position: Vector2(x.clamp(minMapX, maxMapX), y.clamp(minMapY, maxMapY)),
    );

    add(enemy);
  }

  void respawnPlayer() {
    final spawnLayer = map.tileMap.getLayer<ObjectGroup>('Spawnpoints');

    if (spawnLayer != null) {
      for (final spawnPoint in spawnLayer.objects) {
        if (spawnPoint.class_ == 'Player') {
          player.position = Vector2(spawnPoint.x, spawnPoint.y);
          player.currentHp = player.maxHp;
          player.updateHpBar();
          break;
        }
      }
    }
  }
}
