load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")
load("@bazel_tools//tools/build_defs/repo:git.bzl", "git_repository")

http_archive(
    name = "bazel_skylib",
    sha256 = "66ffd9315665bfaafc96b52278f57c7e2dd09f5ede279ea6d39b2be471e7e3aa",
    urls = [
        "https://mirror.bazel.build/github.com/bazelbuild/bazel-skylib/releases/download/1.4.2/bazel-skylib-1.4.2.tar.gz",
        "https://github.com/bazelbuild/bazel-skylib/releases/download/1.4.2/bazel-skylib-1.4.2.tar.gz",
    ],
)

load("//tools/build:composer.bzl", "composer_repository")

composer_repository(
  name="phpunit",
  package="phpunit/phpunit",
  # TODO(kburnik): Implement sha256 check
  digest="sha256:deadbeef",
  composer_bin="/usr/local/bin/composer",
)

git_repository(
    name = "io_bazel_rules_docker",
    remote = "https://github.com/bazelbuild/rules_docker.git",
    tag = "v0.25.0",
)

load(
    "@io_bazel_rules_docker//container:container.bzl",
    "container_pull",
)
load(
    "@io_bazel_rules_docker//repositories:repositories.bzl",
    container_repositories = "repositories",
)

container_repositories()

container_pull(
    name = "php81_base",
    registry = "index.docker.io",
    repository = "library/php",
    tag = "8.2-fpm",
    digest = "1457c768eb24c9d9099ce9eaceed4c92763fa917fa4024558478cb05df996ffe",
)
