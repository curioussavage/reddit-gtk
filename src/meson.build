reddit_app_sources = [
  'main.vala',
  'window.vala',
]

reddit_app_deps = [
  dependency('gio-2.0', version: '>= 2.50'),
  dependency('gtk+-3.0', version: '>= 3.22'),
  dependency('libhandy-0.0'),
]

gnome = import('gnome')

reddit_app_sources += gnome.compile_resources('reddit-app-resources',
  'reddit-app.gresource.xml',
  c_name: 'reddit_app'
)

executable('reddit-app', reddit_app_sources,
  vala_args: '--target-glib=2.50 -D HANDY_USE_UNSTABLE_API',  dependencies: reddit_app_deps,
  install: true,
)
