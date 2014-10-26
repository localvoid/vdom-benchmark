library vdom_benchmark.generator;

import 'dart:math' as math;

class Node {
  int key;
  List<Node> children;
  bool container = false;

  Node(this.key, [List<Node> children = null])
      : children = children,
        container = (children != null);

  String toString() => '<$key>${children != null ? children.join() : ''}</$key>';

  Map toJson() {
    return {
      'key': key,
      'children': children == null ? null : children.map((c) => c.toJson()).toList(),
      'container': container
    };
  }
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
  final List<Node> a;
  final List<Node> b;
  Test(this.a, this.b);
}

class Model {
  final List<Group> groups;
  List<Test> tests = [];

  Model(this.groups) {
    for (final g in groups) {
      for (final b in g.bs) {
        tests.add(new Test(g.a, b));
      }
    }
  }

  List toJson() {
    return groups.map((g) => g.toJson()).toList();
  }
}

typedef void TreeTransformer(List<Node> children);

void skip(List<Node> children) {}

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

var random = new math.Random(0);

List<TreeTransformer> transformers = [
    reverse,
    (c) => shuffle(c, random),
    (c) => removeLast(c, 1),
    (c) => removeFirst(c, 1),
    (c) => removeMiddle(c, 1),
    moveLastToFirst,
    moveLastToMiddle,
    moveFirstToLast,
    moveFirstToMiddle,
    swapBorders,
    swapMiddle];

List<String> transformerNames = [
    'reverse',
    'shuffle',
    'removeLast(1)',
    'removeFirst(1)',
    'removeMiddle(1)',
    'moveLastToFirst',
    'moveLastToMiddle',
    'moveFirstToLast',
    'moveFirstToMiddle',
    'swapBorders',
    'swapMiddle'];

List<Node> generateTree(int levels, List<Node> itemsPerLevel,
    List<TreeTransformer> transformers, [int level = 0]) {
  final result = [];
  final itemsCount = itemsPerLevel[level];
  if (level == (levels - 1)) {
    for (var i = 0; i < itemsCount; i++) {
      result.add(new Node(i));
    }
  } else {
    for (var i = 0; i < itemsCount; i++) {
      result.add(new Node(i, generateTree(levels, itemsPerLevel, transformers, level + 1)));
    }
  }
  transformers[level](result);
  return result;
}

Model generate() {
  final groups = [];
  var r;

  r = [5000];
  groups.add(new Group(
      generateTree(1, r, [skip]),
      transformers.map((t) => generateTree(1, r, [t])).toList(),
      transformerNames.map((n) => '$r [$n]').toList()
      ));

  r = [100, 50];
  groups.add(new Group(
      generateTree(2, r, [skip, skip]),
      transformers.map((t) => generateTree(2, r, [t, skip])).toList(),
      transformerNames.map((n) => '$r [$n, skip]').toList()
      ));

  r = [1000, 5];
  groups.add(new Group(
      generateTree(2, r, [skip, skip]),
      transformers.map((t) => generateTree(2, r, [t, skip])).toList(),
      transformerNames.map((n) => '$r [$n, skip]').toList()
      ));

  r = [100, 50];
  groups.add(new Group(
      generateTree(2, r, [skip, skip]),
      transformers.map((t) => generateTree(2, r, [skip, t])).toList(),
      transformerNames.map((n) => '$r [skip, $n]').toList()
      ));

  r = [1000, 5];
  groups.add(new Group(
      generateTree(2, r, [skip, skip]),
      transformers.map((t) => generateTree(2, r, [skip, t])).toList(),
      transformerNames.map((n) => '$r [skip, $n]').toList()
      ));

  r = [50, 10, 5];
  groups.add(new Group(
      generateTree(3, r, [skip, skip, skip]),
      transformers.map((t) => generateTree(3, r, [t, skip, skip])).toList(),
      transformerNames.map((n) => '$r [$n, skip, skip]').toList()
      ));

  r = [500, 5, 1];
  groups.add(new Group(
      generateTree(3, r, [skip, skip, skip]),
      transformers.map((t) => generateTree(3, r, [t, skip, skip])).toList(),
      transformerNames.map((n) => '$r [$n, skip, skip]').toList()
      ));

  r = [50, 10, 5];
  groups.add(new Group(
      generateTree(3, r, [skip, skip, skip]),
      transformers.map((t) => generateTree(3, r, [skip, skip, t])).toList(),
      transformerNames.map((n) => '$r [skip, skip, $n]').toList()
      ));

  r = [500, 5, 1];
  groups.add(new Group(
      generateTree(3, r, [skip, skip, skip]),
      transformers.map((t) => generateTree(3, r, [skip, skip, t])).toList(),
      transformerNames.map((n) => '$r [skip, skip, $n]').toList()
      ));

  return new Model(groups);
}
