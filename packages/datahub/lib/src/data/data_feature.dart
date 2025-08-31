/// Annotation for extra generated features
abstract class DataObjectFeature {
  const DataObjectFeature();
}

class DataObjectMixinFeature<Mixin> extends DataObjectFeature {
  const DataObjectMixinFeature();
}

class DataObjectBeanFeature<Bean> extends DataObjectFeature {
  final String name;
  const DataObjectBeanFeature(this.name);
}