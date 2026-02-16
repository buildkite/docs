import { defineConfig, loadEnv } from "vite";
import RubyPlugin from "vite-plugin-ruby";

export default defineConfig(({ mode }) => {
  const env = loadEnv(mode, process.cwd(), "");

  return {
    plugins: [
      RubyPlugin(),
      {
        name: "vite-ruby-manifest-compat",
        enforce: "post",
        config() {
          return {
            build: {
              manifest: "manifest.json",
            },
          };
        },
      },
    ],
    define: {
      __ALGOLIA_API_KEY__: JSON.stringify(env.ALGOLIA_API_KEY),
      __ALGOLIA_APP_ID__: JSON.stringify(env.ALGOLIA_APP_ID),
      __ALGOLIA_INDEX_NAME__: JSON.stringify(env.ALGOLIA_INDEX_NAME),
    },
    server: {
      allowedHosts: ["vite"],
      watch: {
        ignored: ["/app/log/**"],
      },
    },
  };
});
