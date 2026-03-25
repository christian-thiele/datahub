import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

class TestimonialsSection extends StatelessComponent {
  const TestimonialsSection();

  @override
  Component build(BuildContext context) {
    return section(
      classes: 'py-24 bg-surface overflow-hidden',
      [
        div(
          classes: 'max-w-7xl mx-auto px-6',
          [
            div(
              classes: 'flex flex-col md:flex-row gap-12 items-center',
              [
                div(
                  classes: 'md:w-1/3',
                  [
                    h2(classes: 'text-4xl font-headline font-bold tracking-tight mb-6', [Component.text('Loved by Architects.')]),
                    p(classes: 'text-on-surface-variant mb-8', [
                      Component.text('Join thousands of developers who have migrated their critical infrastructure to DataHub.')
                    ]),
                    div(
                      classes: 'flex items-center gap-1 text-secondary',
                      [
                        for (var i = 0; i < 5; i++)
                          span(
                            classes: 'material-symbols-outlined',
                            attributes: {'style': "font-variation-settings: 'FILL' 1;"},
                            [Component.text('star')],
                          ),
                        span(classes: 'ml-2 text-on-surface font-semibold', [Component.text('4.9/5 Average')]),
                      ],
                    ),
                  ],
                ),
                div(
                  classes: 'md:w-2/3 grid grid-cols-1 sm:grid-cols-2 gap-6',
                  [
                    TestimonialCard(
                      quote: 'DataHub cut our deployment times by 70%. The security features aren\'t just an add-on; they\'re the foundation.',
                      author: 'Marcus Chen',
                      role: 'Lead Developer, FinTech Inc',
                      image:
                          'https://lh3.googleusercontent.com/aida-public/AB6AXuBxWvCE_ODl2mEPYQNUc_ObswJihF46cGmb6BXfd-lEp4_4rrlLnXQYEv3D6QbSnBYPXPTcNEr08jGLT5bNoFWvB1Ubf2q_n8dy7Xcq8QA5CIaugyi8RbRn5MBNBdDOC8RWSXVQzCOjyxWbAfvoqYmXwnfk8UBHv503DxIC7D5KyX5__Gg2kXDqZhrTy0e5mWJWXEvFAHEbH6azp-nHboDT3hvsLyqY7XEa21FjFoCrxIW0cqmXZYwMV8kmkj2Tdrf3rEH1bK1WW-fd',
                    ),
                    div(
                      classes: 'mt-6 sm:mt-12',
                      [
                        TestimonialCard(
                          quote: 'Scaling from 50 to 50,000 users overnight was seamless. We didn\'t even have to touch the infrastructure settings.',
                          author: 'Sarah Jenkins',
                          role: 'CTO, RapidFlow',
                          image:
                              'https://lh3.googleusercontent.com/aida-public/AB6AXuACLkHFweVuY1ar1x-_LdGRqAOKJyjJufB1ugGrSS10SBnhhDma2nSzOwS26WynR1oUfxbPcc2WbV59wZ0w0uWw4YcnQiVcnx9K1W5arvF6z6B-FNOq1uHrGctmQXovVC7ASE0XOrj2Xx2GRmzE7OXklR3f4kA-OaHI1rjylcMOlk3ulvPjHGqtJPthHl2BFj3oguFF0q0BjWnfhXiHp7GpUNJfgEGC1NSbbvpMbU2T7OZrhUQKlXb62GqA0Cppe3tWgQNiYoT3uD-i',
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}

class TestimonialCard extends StatelessComponent {
  final String quote;
  final String author;
  final String role;
  final String image;

  const TestimonialCard({
    required this.quote,
    required this.author,
    required this.role,
    required this.image,
  });

  @override
  Component build(BuildContext context) {
    return div(
      classes: 'bg-surface-container-low p-8 rounded-xl border border-outline-variant/10',
      [
        p(classes: 'text-on-surface leading-relaxed mb-6 italic', [Component.text('"$quote"')]),
        div(
          classes: 'flex items-center gap-4',
          [
            div(
              classes: 'w-10 h-10 rounded-full bg-surface-container-highest overflow-hidden',
              [
                img(
                  classes: 'w-full h-full object-cover',
                  src: image,
                  alt: author,
                ),
              ],
            ),
            div(
              [
                div(classes: 'font-bold text-sm', [Component.text(author)]),
                div(classes: 'text-xs text-on-surface-variant', [Component.text(role)]),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
