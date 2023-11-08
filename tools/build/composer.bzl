# Composer related build rules.
"This is the docstring for the composer module"

def _composer_repository_impl(repository_ctx):
  print("FOOOOOOO")
  repository_ctx.execute(
      [repository_ctx.attr.composer_bin,
       'require',
       '--prefer-dist',
       repository_ctx.attr.package],
      quiet=False
  )
  repository_ctx.template(
    'composer_lib.bzl',
    Label("//tools/build/template:composer_lib.bzl.tpl"),
    substitutions={},
    executable=False
  )
  repository_ctx.template(
    'BUILD',
    Label("//tools/build/template:composer.BUILD.tpl"),
    substitutions={'%{NAME}': repository_ctx.name},
    executable=False
  )
  return None


composer_repository = repository_rule(
  implementation=_composer_repository_impl,
  local=False,
  attrs={
    "package": attr.string(mandatory=True),
    "digest": attr.string(mandatory=True),
    "composer_bin": attr.string(default="/usr/bin/composer")
  }
)
