package coconut.awt.helpers;

import java.awt.Component;

import haxe.DynamicAccess as Dict;

class NodeType<Attr:{}, Real:Component> implements coconut.diffing.NodeType<Attr, Real> {
  static final EMPTY:Dynamic = {};

  final factory:Void->Real;
  final applicators:Dict<(Real, Any, ?Any)->Void>;

  public function new(factory, applicators) {
    this.factory = factory;
    this.applicators = applicators;
  }

  public function create(a:Attr):Real {
    var ret = factory();
    update(ret, EMPTY, a);
    return ret;
  }

  public function update(target:Real, old:Attr, nu:Attr):Void {
    var old:Dict<Any> = cast old,
        nu:Dict<Any> = cast nu;

    for (k => v in old)
      if (!nu.exists(k))
        applicators[k](target, null, v);

    for (k => v in nu)
      applicators[k](target, v, old[k]);
  }

}