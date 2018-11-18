reddit_app_sources = [
  'main.vala',
  'post_model.vala',
  'window.vala',
  'api.vala',
]

reddit_app_deps = [
  dependency('gio-2.0', version: '>= 2.50'),
  dependency('gtk+-3.0', version: '>= 3.22'),
  dependency('libhandy-0.0'),
  dependency('libsoup-2.4', version: '>= 2.4'),
  dependency('json-glib-1.0', version: '>= 1.0'),
]

gnome = import('gnome')

reddit_app_sources += gnome.compile_resources('reddit-app-resources',
  'reddit-app.gresource.xml',
  c_name: 'reddit_app'
)

executable('reddit-app', reddit_app_sources,
  vala_args: '--target-glib=2.50',  dependencies: reddit_app_deps,
  c_args: '-DHANDY_USE_UNSTABLE_API',
  install: true,
)
