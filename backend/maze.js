export class Maze {
  constructor(hgt, wid) {
    this.hgt = hgt;
    this.wid = wid;
    this.horiz = Array.from({ length: hgt + 1 }, (_) => Array(wid).fill(true));
    this.vert = Array.from({ length: hgt }, (_) => Array(wid + 1).fill(true));
  }
  generate() {
    let visited = Array.from({ length: this.hgt }, (_) =>
      Array(this.wid).fill(false)
    );
    let unvisited = this.hgt * this.wid - 1,
      curX = 0,
      curY = 0,
      stack = [[0, 0]];
    visited[0][0] = true;
    while (unvisited > 0) {
      let ngh = [];
      if (curY - 1 >= 0 && !visited[curY - 1][curX])
        ngh.push(["u", curX, curY - 1]);
      if (curY + 1 < this.hgt && !visited[curY + 1][curX])
        ngh.push(["d", curX, curY + 1]);
      if (curX - 1 >= 0 && !visited[curY][curX - 1])
        ngh.push(["l", curX - 1, curY]);
      if (curX + 1 < this.wid && !visited[curY][curX + 1])
        ngh.push(["r", curX + 1, curY]);
      if (ngh.length > 0) {
        let chosen = ngh[Math.floor(Math.random() * ngh.length)];
        if (chosen[0] == "u") this.horiz[curY][curX] = false;
        if (chosen[0] == "d") this.horiz[curY + 1][curX] = false;
        if (chosen[0] == "l") this.vert[curY][curX] = false;
        if (chosen[0] == "r") this.vert[curY][curX + 1] = false;
        stack.push([curX, curY]);
        [curX, curY] = [chosen[1], chosen[2]];
        visited[curY][curX] = true;
        unvisited--;
      } else if (stack.length > 0) {
        [curX, curY] = stack.pop();
      }
    }
  }
}
