// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'slideshow.dart';

// **************************************************************************
// CopyWithExtensionGenerator
// **************************************************************************

extension SlideshowCopyExtension on Slideshow {
  Slideshow copyWith({
    String? author,
    String? date,
    String? title,
  }) {
    return Slideshow(
      author ?? this.author,
      date ?? this.date,
      title ?? this.title,
    );
  }
}

// **************************************************************************
// TransferBeanGenerator
// **************************************************************************

// ignore_for_file: constant_identifier_names

const SlideshowTransferBean = _SlideshowTransferBeanImpl._();

class _SlideshowTransferBeanImpl extends TransferBean<Slideshow> {
  const _SlideshowTransferBeanImpl._();

  @override
  Map<String, dynamic> toMap(Slideshow transferObject) {
    return {
      'author': encodeTyped<String>(transferObject.author),
      'date': encodeTyped<String>(transferObject.date),
      'title': encodeTyped<String>(transferObject.title),
    }..removeWhere((k, v) => v == null);
  }

  @override
  Slideshow toObject(Map<String, dynamic> data, {String? name}) {
    return Slideshow(
      decodeTyped<String>(data['author'],
          name: name == null ? 'author' : '$name.author'),
      decodeTyped<String>(data['date'],
          name: name == null ? 'date' : '$name.date'),
      decodeTyped<String>(data['title'],
          name: name == null ? 'title' : '$name.title'),
    );
  }
}

// **************************************************************************
// TransferSuperclassGenerator
// **************************************************************************

abstract class _TransferObject extends TransferObjectBase<void> {
  @override
  dynamic toJson() => SlideshowTransferBean.toMap(this as Slideshow);

  @override
  TransferBean<Slideshow> get bean => SlideshowTransferBean;

  @override
  void getId() {}
}
