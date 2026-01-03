function getCookie(cookieHeader, name) {
  if (!cookieHeader) return null;
  const cookies = cookieHeader.split(";");

  for (const cookie of cookies) {
    const [k, ...v] = cookie.trim().split("=");
    if (k === name) return v.join("=");
  }
  return null;
}

export default {
  async fetch(request, env) {
    const url = new URL(request.url);

    // Theme Switching
    if (url.pathname.endsWith("style.css")) {
      const theme = getCookie(request.headers.get("Cookie"), "theme_color");
      if (theme && theme !== "red") {
        const themeUrl = new URL(url);
        themeUrl.pathname = themeUrl.pathname.replace(
          "style.css",
          `style-${theme}.css`,
        );

        const themed = await env.ASSETS.fetch(new Request(themeUrl, request));

        if (themed.ok) {
          const headers = new Headers(themed.headers);
          headers.set("Vary", "Cookie");
          headers.set("Cache-Control", "no-store");
          return new Response(themed.body, {
            status: themed.status,
            headers,
          });
        }
      }
    }

    // Serve assets
    const response = await env.ASSETS.fetch(request);
    if (response.status === 404) {
      const fallbackUrl = new URL(request.url);
      fallbackUrl.pathname = "/index.html";
      return env.ASSETS.fetch(new Request(fallbackUrl, request));
    }
    return response;
  },
};
