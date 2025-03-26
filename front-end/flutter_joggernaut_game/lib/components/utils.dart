bool checkCollision(player, wall) {
  // player's coordinates are anchored in the center
  double playerHalfHeight = player.height / 6;
  double playerHalfWidth = player.width / 6;

  return (player.y - playerHalfHeight < wall.y + wall.height &&
      player.y + playerHalfHeight > wall.y &&
      player.x - playerHalfWidth < wall.x + wall.width &&
      player.x + playerHalfWidth > wall.x);
}
