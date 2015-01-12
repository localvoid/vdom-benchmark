library vcomponent.generator;

import 'dart:math' as math;

class Node {
  int key;
  bool dirty;
  List<Node> children;

  Node(this.key, [this.dirty = false, this.children = null]);

  Map toJson() {
    return {
      'key': key,
      'dirty': dirty,
      'children': children == null ? null : children.map((c) => c.toJson()).toList(),
    };
  }

  String toString() => '<$key>${children != null ? children.join() : ''}</$key>';
}

class Group {
  final List<Node> a;
  final List<List<Node>> bs;
  final List<String> names;

  Group(this.a, this.bs, this.names);

  Map toJson() {
    return {
      'a': a.map((i) => i.toJson()).toList(),
      'bs': bs.map((l) => l.map((i) => i.toJson()).toList()).toList(),
      'names': names
    };
  }
}

class Test {
  final String name;
  final List<Node> a;
  final List<Node> b;
  Test(this.name, this.a, this.b);
}

class Model {
  final List<Group> groups;
  List<Test> tests = [];

  Model(this.groups) {
    for (final g in groups) {
      for (var i = 0; i < g.bs.length; i++) {
        tests.add(new Test(g.names[i], g.a, g.bs[i]));
      }
    }
  }

  List toJson() {
    return groups.map((g) => g.toJson()).toList();
  }
}

typedef void TreeTransformer(List<Node> children);

void skip(List<Node> children) {}

void magic(List<Node> children) {
  if (children.length >= 4) {
    children.removeLast();
    children.removeAt(0);
    final first = children.first;
    final last = children.last;
    children[0] = last;
    children[children.length - 1] = first;
  }

}

void reverse(List<Node> children) {
  final copy = new List.from(children);
  children.clear();
  children.addAll(copy.reversed);
}

void shuffle(List<Node> children, math.Random r) {
  children.shuffle(r);
}

void insertFirst(List<Node> children, int n) {
  var i = children.length;
  while (n > 0) {
    children.insert(0, new Node(i++));
    n--;
  }
}

void insertLast(List<Node> children, int n) {
  var i = children.length;
  while (n > 0) {
    children.add(new Node(i++));
    n--;
  }
}

void insertMiddle(List<Node> children, int n) {
  if (children.length > (n + 1)) {
    final o = children.length ~/ (n + 1);
    var p = o;
    var i = children.length;
    while (n > 0) {
      children.insert(p, new Node(i++));
      p += o + 1;
      n--;
    }
  }
}

void removeLast(List<Node> children, int n) {
  if (children.length > n) {
    while (n > 0) {
      children.removeLast();
      n--;
    }
  }
}

void removeFirst(List<Node> children, int n) {
  if (children.length > n) {
    while (n > 0) {
      children.removeAt(0);
      n--;
    }
  }
}

void removeMiddle(List<Node> children, int n) {
  if (children.length > (n + 1)) {
    final o = children.length ~/ (n + 1);
    var p = o;
    while (n > 0) {
      children.removeAt(p);
      p += o - 1;
      n--;
    }
  }
}

void moveLastToFirst(List<Node> children) {
  if (children.length > 1) {
    children.insert(0, children.removeLast());
  }
}

void moveLastToMiddle(List<Node> children) {
  if (children.length > 2) {
    final m = children.length ~/ 2;
    children.insert(m, children.removeLast());
  }
}

void moveFirstToLast(List<Node> children) {
  if (children.length > 1) {
    children.add(children.removeAt(0));
  }
}

void moveFirstToMiddle(List<Node> children) {
  if (children.length > 2) {
    final m = children.length ~/ 2;
    children.insert(m, children.removeAt(0));
  }
}

void swapBorders(List<Node> children) {
  if (children.length > 1) {
    final first = children.first;
    final last = children.last;
    children[0] = last;
    children[children.length - 1] = first;
  }
}

void swapMiddle(List<Node> children) {
  if (children.length > 2) {
    final ai = children.length ~/ 3;
    final bi = ai * 2;
    final a = children[ai];
    final b = children[bi];
    children[bi] = a;
    children[ai] = b;
  }
}

void advanceKey(List<Node> children, int n) {
  for (final c in children) {
    c.key += n;
  }
}

void markDirtyAll(List<Node> children) {
  for (final c in children) {
    c.dirty = true;
  }
}

void markDirtyOne(List<Node> children, int i) {
  children[i].dirty = true;
}

var random = new math.Random(0);

List<TreeTransformer> transformers = [
    magic,
    reverse,
    (c) => shuffle(c, random),
    (c) => removeLast(c, 1),
    (c) => removeFirst(c, 1),
    (c) => removeMiddle(c, 1),
    (c) => insertLast(c, 1),
    (c) => insertFirst(c, 1),
    (c) => insertMiddle(c, 1),
    moveLastToFirst,
    moveLastToMiddle,
    moveFirstToLast,
    moveFirstToMiddle,
    swapBorders,
    swapMiddle];

List<String> transformerNames = [
    'magic',
    'reverse',
    'shuffle',
    'removeLast(1)',
    'removeFirst(1)',
    'removeMiddle(1)',
    'insertLast(1)',
    'insertFirst(1)',
    'insertMiddle(1)',
    'moveLastToFirst',
    'moveLastToMiddle',
    'moveFirstToLast',
    'moveFirstToMiddle',
    'swapBorders',
    'swapMiddle'];

List<Node> generateTree(List<Node> itemsPerLevel,
    List<TreeTransformer> transformers, [int level = 0]) {
  final levels = itemsPerLevel.length;
  final result = [];
  final itemsCount = itemsPerLevel[level];
  if (level == (levels - 1)) {
    for (var i = 0; i < itemsCount; i++) {
      result.add(new Node(i));
    }
  } else {
    for (var i = 0; i < itemsCount; i++) {
      result.add(new Node(i, false, generateTree(itemsPerLevel, transformers, level + 1)));
    }
  }
  transformers[level](result);
  return result;
}