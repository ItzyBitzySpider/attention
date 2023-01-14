export class Maze {
  constructor(sizes, space) {
    this.horiz = [[true], [true]];
    this.vert = [[true, true]];
    while (sizes.length > 0) this.expand(this.vert.length, sizes.pop(), space);
    this.loops(this.vert.length, space);
  }
  expand(cur, next, space) {
    let shift = (next - cur) / 2,
      stack = [],
      idx = Math.floor(Math.random() * cur);
    for (let i = 0; i < cur; i++) {
      if (i != idx && Math.random() > space) continue;
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
      if (y > 0 && !visited[y - 1][x]) nghbrs.push(["h", x, y - 1]);
      if (y < next - 1 && !visited[y + 1][x]) nghbrs.push(["h", x, y + 1]);
      if (x > 0 && !visited[y][x - 1]) nghbrs.push(["v", x - 1, y]);
      if (x < next - 1 && !visited[y][x + 1]) nghbrs.push(["v", x + 1, y]);
      if (nghbrs.length > 0) {
        let [dir, nx, ny] = nghbrs[Math.floor(Math.random() * nghbrs.length)];
        (dir == "h" ? this.horiz : this.vert)[Math.max(y, ny)][
          Math.max(x, nx)
        ] = false;
        stack.push([nx, ny]);
        visited[ny][nx] = true;
      } else stack.pop();
    }
  }
  loops(next, space) {
    for (let y = 1; y < next; y++)
      for (let x = 0; x < next; x++) {
        if (y > 0 && Math.random() < space) this.horiz[y][x] = false;
        if (x > 0 && Math.random() < space) this.vert[y][x] = false;
      }
  }
}
