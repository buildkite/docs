module.exports = {
  "stories": [
    "../stories/**/*.stories.mdx",
    "../stories/**/*.stories.@(js|jsx|ts|tsx)"
  ],
  "addons": [
    "@storybook/addon-links",
    "@storybook/addon-essentials",
    "@storybook/addon-interactions",
    "storybook-addon-designs",
    {
      name: "@storybook/preset-scss",
      options: {
        cssLoaderOptions: {
          url: false
        },
      },
    },
  ],
  "framework": "@storybook/html"
}