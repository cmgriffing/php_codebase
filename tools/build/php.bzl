# Bazel PHP build rules (php_library, php_binary, php_test, etc.).
"Hmmm, this is my php module docstring?"
load(
    "@io_bazel_rules_docker//lang:image.bzl",
    "app_layer",
)

def _build_impl(ctx):
  direct_src_files = [f.path for f in ctx.files.srcs]

  # Traverse dependencies, the dep files for the current target.
  deps_src_files = []
  for dep in ctx.attr.deps:
    deps_src_files = deps_src_files + dep[DefaultInfo].files.to_list()
    if hasattr(dep[DefaultInfo], 'files_to_run'):
      deps_src_files = deps_src_files + dep[DefaultInfo].default_runfiles.files.to_list()

  deps_src_files_depset = depset(deps_src_files)

  lib_outputs = []
  out_dir = ""
  for src in ctx.files.srcs:
    out_file = ctx.actions.declare_file(src.basename)
    lib_outputs.append(out_file)
    out_dir = out_file.root.path

  if ctx.attr.type == "binary" or ctx.attr.type == "test":
    lib_outputs.append(ctx.outputs.executable)
  elif ctx.attr.type == "resource":
    lib_outputs.append(ctx.actions.declare_file("StaticResource.php"))

  lib_outputs_depset = depset(lib_outputs)

  ctx.actions.run(
      inputs = ctx.files.srcs + deps_src_files_depset.to_list(),
      outputs = lib_outputs_depset.to_list(),
      arguments=["--type", ctx.attr.type] +
                ["--out", out_dir] +
                ["--src"] + direct_src_files +
                ["--dep"] + [f.short_path for f in deps_src_files] +
                ["--target", ctx.label.name],
      progress_message="Building lib %s" % ctx.label.name,
      executable=ctx.executable._build)

  if ctx.attr.type == "library" or ctx.attr.type == "resource":
    return [DefaultInfo(files = depset(lib_outputs_depset.to_list() + deps_src_files_depset.to_list()))]
  elif ctx.attr.type == "binary" or ctx.attr.type == "test":
    runfiles = ctx.runfiles(
        files=[ctx.outputs.executable] + lib_outputs_depset.to_list() + deps_src_files_depset.to_list())
    return [DefaultInfo(runfiles=runfiles)]
  else:
    fail("Unknown type: %s" % ctx.attr.type)


# def _php_resource_impl(ctx):
#   # Traverse dependencies, the dep files for the current target.
#   deps_src_files = depset()
#   for dep in ctx.attr.deps:
#     deps_src_files += dep.files

#   out_files = depset()
#   for src in ctx.files.srcs:
#     out = ctx.actions.declare_file(src.basename)
#     out_files += [out]
#     ctx.actions.run_shell(
#       inputs=[src],
#       outputs=[out],
#       mnemonic="CopyResource",
#       progress_message="Copy %s" % src.short_path,
#       command='cp {src} {dest}'.format(src=src.path, dest=out.path))
#   return [DefaultInfo(files=out_files + deps_src_files)]


# Common for library, testing & running.
build_common = {
  "attrs": {
      "srcs": attr.label_list(allow_files=True),
      "deps": attr.label_list(allow_files=False),
      "type": attr.string(default="library"),
      "_build": attr.label(executable=True,
                           cfg="exec",
                           allow_files=True,
                           default=Label("//tools/build:build")),
  },
}

_build_rule = rule(
  implementation=_build_impl,
  **build_common
)

_php_binary_rule = rule(
  implementation=_build_impl,
  executable=True,
  **build_common
)

_php_test = rule(
  implementation=_build_impl,
  test=True,
  **build_common
)

def php_library(**kwargs):
  kwargs['type'] = "library";
  _build_rule(**kwargs)


def php_resource(**kwargs):
  kwargs['type'] = "resource";
  _build_rule(**kwargs)


def php_binary(**kwargs):
  kwargs['type'] = "binary"
  _php_binary_rule(**kwargs)


def php_test(**kwargs):
  kwargs['deps'].append('@phpunit//:phpunit')
  kwargs['type'] = "test";
  _php_test(**kwargs)


def php_image(name, base=None, deps=[], layers=[], **kwargs):
  """Constructs a container image wrapping a php_binary target.

  Args:
    name: The name of the image..
    base: Not sure yet.
    deps: The list of dependencies
    layers: Augments "deps" with dependencies that should be put into
           their own layers.
    **kwargs: See php_binary.
  """
  DEFAULT_BASE = "@php81_base//image"
  binary_name = name + "_img_bin"

  php_binary(name=binary_name, deps=deps + layers, **kwargs)

  base = base or DEFAULT_BASE
  # for dep in layers:
  #   this_name = "%s.%d" % (name, index)
  #   container_layer(name=this_name, base=base, dep=dep)
  #   base = this_name
  #   index += 1

  app_layer(name=name, base=base, binary=binary_name, layers=layers)
