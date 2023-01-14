class Maze {
  constructor(sizes, space) {
    this.horiz = [[true], [true]];
    this.vert = [[true, true]];
    for (let cur = 1, next; sizes.length > 0; cur = next) {
      next = sizes.pop();
      this.expand(cur, next, space);
      this.loops(cur, next, space);
    }
  }
  expand(cur, next, space) {
    let shift = (next - cur) / 2,
      stack = [];
    for (let i = 0; i < cur; i++) {
      if (i > 0 && Math.random() > space) continue;
      this.horiz[0][i] =
        this.horiz[cur][i] =
        this.vert[i][0] =
        this.vert[i][cur] =
          false;
      stack.push(
        [shift - 1, shift + i],
        [shift + cur, shift + i],
        [shift + i, shift - 1],
        [shift + i, shift + cur]
      );
    }
    let visited = Array.from({ length: next }, (_, y) =>
      Array.from(
        { length: next },
        (_, x) => x >= shift && x < shift + cur && y >= shift && y < shift + cur
      )
    );
    for (let cell of stack) visited[cell[1]][cell[0]] = true;
    this.horiz = Array.from({ length: next + 1 }, (_, y) =>
      Array.from(
        { length: next },
        (_, x) =>
          x < shift ||
          x >= shift + cur ||
          y < shift ||
          y > shift + cur ||
          this.horiz[y - shift][x - shift]
      )
    );
    this.vert = Array.from({ length: next }, (_, y) =>
      Array.from(
        { length: next + 1 },
        (_, x) =>
          x < shift ||
          x > shift + cur ||
          y < shift ||
          y >= shift + cur ||
          this.vert[y - shift][x - shift]
      )
    );
    while (stack.length > 0) {
      let [x, y] = stack[stack.length - 1],
        nghbrs = [];
      if (y > 0 && !visited[y - 1][x]) nghbrs.push(["u", x, y - 1]);
      if (y < next - 1 && !visited[y + 1][x]) nghbrs.push(["d", x, y + 1]);
      if (x > 0 && !visited[y][x - 1]) nghbrs.push(["l", x - 1, y]);
      if (x < next - 1 && !visited[y][x + 1]) nghbrs.push(["r", x + 1, y]);
      if (nghbrs.length > 0) {
        let [dir, nx, ny] = nghbrs[Math.floor(Math.random() * nghbrs.length)];
        if (dir == "u") this.horiz[y][x] = false;
        if (dir == "d") this.horiz[y + 1][x] = false;
        if (dir == "l") this.vert[y][x] = false;
        if (dir == "r") this.vert[y][x + 1] = false;
        stack.push([nx, ny]);
        visited[ny][nx] = true;
      } else if (stack.length > 0) {
        stack.pop();
      }
    }
  }
  loops(cur, next, space) {
    let shift = (next - cur) / 2;
  }
}
