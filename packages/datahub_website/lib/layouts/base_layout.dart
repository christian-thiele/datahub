import 'package:jaspr/dom.dart';
import 'package:jaspr/server.dart';
import 'package:jaspr_content/jaspr_content.dart';

abstract class BaseLayout extends PageLayoutBase {
  const BaseLayout();

  @override
  Iterable<Component> buildHead(Page page) sync* {
    yield* super.buildHead(page);
    yield script(src: 'https://cdn.tailwindcss.com?plugins=forms,container-queries');
    yield script(src: '/js/tailwind-config.js');
    yield link(
      href:
          'https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700&family=Inter:wght@300;400;500;600;700&amp;display=swap',
      rel: 'stylesheet',
    );
    yield link(
      href:
          'https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:wght,FILL@100..700,0..1&amp;display=swap',
      rel: 'stylesheet',
    );
    yield link(
      href:
          'https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:wght,FILL@100..700,0..1&amp;display=swap',
      rel: 'stylesheet',
    );
    yield link(href: '/css/style.css', rel: 'stylesheet');
  }

  @override
  Component buildLayout(Page page, Component child) {
    return Document(
      lang: switch (page.data) {
        {'page': {'lang': final String lang}} => lang,
        {'site': {'lang': final String lang}} => lang,
        _ => null,
      },
      base: switch (page.data) {
        {'site': {'base': final String base}} => base,
        {'site': {'base': final bool base}} => base ? '/' : null,
        _ => '/',
      },
      meta: {},
      head: buildHead(page).toList(),
      body: Component.fragment([
        Document.body(
          attributes: {
            'class': 'bg-surface text-on-surface font-body selection:bg-primary/30',
          },
        ),
        buildBody(page, child),
      ]),
    );
  }
}
