export default {
  async fetch(request, env) {
    const url = new URL(request.url);
    const cookie = request.headers.get("Cookie") || "";

    // Theme
    if (url.pathname.endsWith("style.css")) {
      let theme = "red";
      if (cookie.includes("theme=blue")) theme = "blue";
      if (cookie.includes("theme=black")) theme = "black";

      const themeUrl = new URL(url);
      themeUrl.pathname = themeUrl.pathname.replace(
        "style.css",
        `style-${theme}.css`,
      );

      let themeResponse = await env.ASSETS.fetch(
        new Request(themeUrl, request),
      );
      if (themeResponse.ok) return themeResponse;
    }

    // Serve assets
    let response = await env.ASSETS.fetch(request);

    if (response.ok) {
      const newHeaders = new Headers(response.headers);
      newHeaders.set("Cache-Control", "public, max-age=60, s-maxage=60");
      return new Response(response.body, { ...response, headers: newHeaders });
    }

    return new Response("Repository not found.", { status: 404 });
  },
};
