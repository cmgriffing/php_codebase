load("//tools/build:php.bzl", "php_binary", "php_test")

php_binary(
  name="story",
  srcs=["Story.php"],
  deps=["//app/story/data"]
)

php_test(
  name="story_test",
  srcs=["StoryTest.php"],
  deps=[
    ":story",
    "//app/story/data"
  ],
  size="small",
)

# php_image(
#   name="story_img",
#   srcs=["Story.php"],
#   deps=[
#     "//base/math/complex:complex"
#   ],
#   # cmd="find 2>/dev/null | grep -e calc -e Calc"
# )
